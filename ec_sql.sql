USE sakila;


-- 1a. Display the first and last names of all actors from the table actor.

SELECT first_name, last_name FROM actor;

-- 1b.  Display the first and last names of all actors from the table actor.

SELECT UPPER(CONCAT(first_name,' ',last_name)) as 'Actor Name' 
FROM actor;

-- 2a.  You need to find the ID number, first name, and last name of an actor, of whom you know only the first name,
--  "Joe." What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, 
-- in that order:

SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify 
-- the data type.

ALTER TABLE actor
ADD middle_name VARCHAR(45) AFTER first_name;


-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
ALTER TABLE actor
MODIFY middle_name BLOB;


-- 3c. Now delete the middle_name column.

ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(*)
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by 
-- at least two actors

SELECT last_name, COUNT(*) AS count
FROM actor
GROUP BY last_name
HAVING count > 1;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's 
-- second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";


-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct 
-- name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. 
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous 
-- error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record 
-- using a unique identifier.)

UPDATE actor 
SET first_name = "GROUCHO"
WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE sakila.address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT * FROM address;
SELECT * FROM staff;

SELECT address.address_id, first_name, last_name, address
FROM address
INNER JOIN staff ON address.address_id = staff.address_id;


-- 6b.  Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT * FROM staff;
SELECT * FROM payment;

SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount) AS 'Total Amount'
FROM staff s
INNER JOIN payment p ON p.staff_id = s.staff_id
WHERE p.payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-09-01 00:00:00'
GROUP BY  s.staff_id, s.first_name, s.last_name;


-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT * FROM film_actor;
SELECT * FROM film;

SELECT film.film_id, film.title, COUNT(film_actor.actor_id) AS 'actor count'
FROM film
INNER JOIN film_actor ON film_actor.film_id = film.film_id
GROUP BY film.film_id;


-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM inventory;
SELECT * FROM film;

SELECT COUNT(inventory.inventory_id), film.title, inventory.film_id
FROM inventory
INNER JOIN film ON film.film_id = inventory.film_id
WHERE film.title = "Hunchback Impossible"
GROUP BY film.title, inventory.film_id;


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

SELECT * FROM payment;
SELECT * FROM customer;

-- payment  = customer_id, amount
-- customer = first_name, last_name

SELECT p.customer_id, c.first_name, c.last_name, SUM(p.amount) as 'total amount purchased'
FROM payment p
INNER JOIN customer c ON c.customer_id = p.customer_id
GROUP BY p.customer_id, c.first_name, c.last_name
ORDER BY c.last_name;



-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of 
-- movies starting with the letters K and Q whose language is English.


SELECT * FROM film
WHERE title LIKE ('K%') OR title LIKE ('Q%');


SELECT * FROM film 
WHERE language_id = 1 AND title IN (
	SELECT title FROM film
	WHERE title LIKE ('K%') OR title LIKE ('Q%'));

	
--  7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
    WHERE film_id IN (
		SELECT film_id FROM film
        WHERE title = "Alone Trip")
        );
		

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
-- email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT * FROM customer;
SELECT * FROM address;
SELECT * FROM city WHERE country_id = 20;
SELECT * FROM country;

# city = city_id
# address = city_id, address_id
# customer first_name, last_name, email, address_id
# country = country, country_id

SELECT cu.first_name, cu.last_name, cu.email, co.country
FROM city ci
INNER JOIN country co ON co.country_id = ci.country_id
INNER JOIN address a ON a.city_id = ci.city_id
INNER JOIN customer cu ON cu.address_id = a.address_id
WHERE co.country = 'Canada';



-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM film;

# c category = category_id, name
# fc film_category = film_id, category_id
# f film = film_id, title

SELECT f.film_id, f.title, c.name AS 'category_type'
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

SELECT * FROM rental;
SELECT * FROM inventory;
SELECT * FROM film;

# r rental = rental_id, inventory_id
# i inventory = inventory_id, film_id
# f film = film_id, title

SELECT f.film_id, f.title, COUNT(r.inventory_id) AS 'rental_count'
FROM film f
INNER JOIN inventory i ON f.film_id = i.inventory_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id, f.title
ORDER BY rental_count DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT * FROM payment;
SELECT * FROM staff;

# p payment = staff_id, amount
# s staff = staff_id, store_id

SELECT s.store_id AS 'store', SUM(p.amount) AS 'total_amount_paid (dollars)'
FROM payment p 
INNER JOIN staff s ON p.staff_id = s.staff_id
GROUP BY store_id;


-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT * FROM store;
SELECT * FROM address;
SELECT * FROM city;
SELECT * FROM country;

# s store = store_id, address_id
# a address = address_id, city_id
# ci city = city_id, city, country_id
# co country = country_id, country

SELECT s.store_id, ci.city, co.country
FROM store s 
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id;



-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT * FROM category;
SELECT * FROM film_category;
SELECT * FROM inventory;
SELECT * FROM rental;
SELECT * FROM payment;

# c category = category_id, name
# f film_category = category_id, film_id
# i inventory = film_id, inventory_id
# r rental = rental_id, inventory_id
# p payment = amount, rental_id


SELECT c.name AS 'genre_name', SUM(p.amount) AS 'gross_revenue'
FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category f ON i.film_id = f.film_id
INNER JOIN category c ON f.category_id = c.category_id
GROUP BY genre_name
ORDER BY gross_revenue DESC 
LIMIT 5;



-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query 
-- to create a view.

CREATE VIEW top_five_genres AS
SELECT c.name AS 'genre_name', SUM(p.amount) AS 'gross_revenue'
FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category f ON i.film_id = f.film_id
INNER JOIN category c ON f.category_id = c.category_id
GROUP BY genre_name
ORDER BY gross_revenue DESC 
LIMIT 5
;


-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;

