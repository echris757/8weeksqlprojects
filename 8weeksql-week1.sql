-- Create tables and necessary data for exercises
-- Remove comment format below to create

/*
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
 */

-- 1. Total spend per customer at restaurant
SELECT customer_id, SUM(price) AS total_spend FROM sales
JOIN menu
ON (menu.product_id = sales.product_id)
GROUP BY customer_id
ORDER BY customer_id;
-- Customer A spent $76, B spent $74, and C spent $36

-- 2. Number of days each customer has visited the restaurant
SELECT customer_id, COUNT(order_date) AS num_days FROM sales
GROUP BY customer_id
ORDER BY customer_id;
-- A and B visited 6 days each, and C visited 3 days

-- 3. First item ordered by customer
SELECT customer_id, order_date, product_name FROM sales 
JOIN menu
ON (menu.product_id = sales.product_id)
WHERE (customer_id, order_date) IN (
	SELECT customer_id, MIN(order_date)
	FROM sales
	GROUP BY customer_id
)
ORDER BY customer_id;
-- A ordered both sushi & curry, B ordered curry, and C ordered 2 ramen

-- 4. Most purchased item and # of times purchased by all customers
SELECT product_name, COUNT(sales.product_id) AS times_bought FROM sales
JOIN menu
ON (menu.product_id = sales.product_id)
GROUP BY product_name
ORDER BY times_bought DESC
LIMIT 1;
-- Ramen was most popular item, being purchased 8 times total between all customers

-- 5. Most popular item by customer
SELECT customer_id, product_name, order_count FROM (
	SELECT customer_id, product_name, COUNT(*) AS order_count,
		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rank
	FROM sales
	JOIN menu 
	ON (menu.product_id = sales.product_id)
	GROUP BY customer_id, product_name
)
WHERE rank = 1;
-- A's most popular was ramen (3 times), B's was sushi (2 times), and C's ramen (3 times)

-- 6 & 7. First item purchased after becoming member
SELECT s.customer_id, order_date, product_name, join_date,
	CASE
		WHEN order_date < join_date THEN 'before joining'
		WHEN order_date >= join_date THEN 'after joining'
		ELSE 'not member'
	END AS status
FROM sales s
FULL OUTER JOIN members m 
	ON (m.customer_id = s.customer_id)
JOIN menu me
	ON (me.product_id = s.product_id)
ORDER BY customer_id, order_date;
-- 6. A ordered curry after joining and B ordered sushi
-- 7. A ordered curry and sushi prior to joining and B ordered sushi

-- 8. Total items and spend per members prior to joining
SELECT customer_id, SUM(price) AS total_spend, COUNT(*) AS total_orders 
FROM (
	SELECT s.customer_id, price,
		CASE
			WHEN order_date < join_date THEN 'before joining'
			WHEN order_date >= join_date THEN 'after joining'
			ELSE 'not member'
		END AS status
	FROM sales s
	FULL OUTER JOIN members m 
		ON (m.customer_id = s.customer_id)
	JOIN menu me
		ON (me.product_id = s.product_id)
)
WHERE status = 'before joining'
GROUP BY customer_id;
-- A spent $25 on 2 orders prior to joining, while B spent $40 on 3 orders

-- 9. 10 points per $1 spent, with 2x points on sushi, find total points per customer
SELECT customer_id, SUM(unit_points) AS total_points
FROM (
	-- subquery creates column for points per item, where sushi has a 2x multiplier
	SELECT customer_id,
		CASE
			WHEN product_name IN ('curry','ramen') THEN 10*price
			ELSE 20*price
		END AS unit_points
	FROM sales s
	JOIN menu m 
	ON (m.product_id = s.product_id)
)
GROUP BY customer_id
ORDER BY customer_id;
-- A has 860 points, B has 940, and C has 360

--10. Customer earns 2x points in first week after joining; total points for A & B in January
SELECT customer_id, SUM(points) AS total_points FROM (
	-- Subquery creates points column where purchases within a week of joining give 2x points
	SELECT s.customer_id, order_date,
		CASE
			WHEN join_date - order_date <= 0 AND join_date - order_date >= -7 THEN 20*price
			ELSE 10*price
		END AS points
	FROM sales s
	JOIN members m
		ON (m.customer_id = s.customer_id)
	JOIN menu me
		ON (me.product_id = s.product_id)
	WHERE order_date BETWEEN '2021-01-01' AND '2021-01-31'
	ORDER BY customer_id, order_date
)
GROUP BY customer_id;
-- A has a total of 1270 points in January while B has 840

-- Bonus 1. Create new table as a join of other tables with columns for customer, order date, product, price, and membership status
-- Remove comment format below on code to run

/*CREATE TABLE customer_master AS
SELECT s.customer_id, order_date, product_name, price,
	CASE
		WHEN order_date < join_date THEN 'N'
		WHEN order_date >= join_date THEN 'Y'
		ELSE 'N'
	END AS member
FROM sales s
FULL OUTER JOIN members m
	ON (m.customer_id = s.customer_id)
JOIN menu me
	ON (me.product_id = s.product_id)
ORDER BY customer_id, order_date;*/

SELECT * FROM customer_master; --check if table created correctly