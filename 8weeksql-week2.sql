/* Create tables & data for exercises

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

  */

/* Begin creation of master table for ease of analysis
SELECT
	c.order_id,
	customer_id,
	c.pizza_id,
	c.exclusions,
	c.extras,
	c.order_time,
	pizza_name,
	toppings,
	runner_id,
	pickup_time,
	distance,
	duration,
	cancellation
INTO master_table FROM customer_orders c
	LEFT JOIN runner_orders r
	ON (r.order_id = c.order_id)
	LEFT JOIN pizza_names pn
	ON (pn.pizza_id = c.pizza_id)
	LEFT JOIN pizza_recipes pr
	ON (pr.pizza_id = c.pizza_id);
*/

/* Clean pickup time column by dropping 'null' string and changing to timestamp
UPDATE master_table
SET pickup_time = NULLIF(pickup_time, 'null');

ALTER TABLE master_table
ALTER COLUMN pickup_time TYPE timestamp
USING to_timestamp(pickup_time, 'YYYY-MM-DD HH24:MI:SS');
*/

/* Set 'null' strings and empty data to NULL
UPDATE master_table
SET exclusions = NULLIF(exclusions, 'null');

UPDATE master_table
SET exclusions = NULLIF(exclusions, '');

UPDATE master_table
SET extras = NULLIF(extras, '');

UPDATE master_table
SET extras = NULLIF(extras, 'null');

UPDATE master_table
SET distance = NULLIF(distance, 'null');

UPDATE master_table
SET duration = NULLIF(duration, 'null');

UPDATE master_table
SET cancellation = NULLIF(cancellation, 'null');

UPDATE master_table
SET cancellation = NULLIF(cancellation, '');
*/

/* Add runner registration date to master
ALTER TABLE master_table
ADD registration_date timestamp;

UPDATE master_table m
SET registration_date = r.registration_date
FROM runners r
WHERE m.runner_id = r.runner_id;
*/

/* Change NULL values to 'Not Cancelled' for cancellation column
UPDATE master_table
SET cancellation = COALESCE(cancellation, 'not cancelled');
*/

/* Remove text from distance and duration columns and adjust type to decimal/integer
UPDATE master_table
SET distance = REGEXP_REPLACE(distance, '[^0-9.]','','g');

UPDATE master_table
SET duration = REGEXP_REPLACE(duration, '[^0-9]','','g');

ALTER TABLE master_table
ALTER COLUMN distance TYPE decimal
USING CAST(distance AS decimal(5,2));

ALTER TABLE master_table
ALTER COLUMN duration TYPE integer
USING CAST(duration AS integer);
*/

/* Further simplify cancellations
UPDATE master_table
SET cancellation =
CASE
	WHEN cancellation = 'not cancelled' THEN 'N'
	ELSE 'Y'
END;
*/

/* Replace NULL with none
UPDATE master_table
SET exclusions = COALESCE(exclusions, 'none');

UPDATE master_table
SET extras = COALESCE(extras, 'none');
*/

-- 1. Total pizzas ordered (not cancelled)
SELECT
	COUNT(order_id) AS total_orders
FROM master_table
WHERE cancellation = 'N'; -- 12 total pizzas were ordered

-- 2. Total unique customers who placed an order
SELECT
	COUNT(DISTINCT customer_id) AS unique_customers
FROM master_table
WHERE cancellation = 'N'; -- 5 unique customers placed an order

-- 3. Total successful orders delivered by runner
SELECT
	runner_id,
	COUNT(DISTINCT order_id) AS successful_deliveries
FROM master_table
WHERE cancellation = 'N' 
GROUP BY runner_id; -- 1 had 4 deliveries, 2 had 3, and 3 had 1

-- 4. Total pizzas delivered by type
SELECT
	pizza_name,
	COUNT(order_id) AS num_delivered
FROM master_table
WHERE cancellation = 'N'
GROUP BY pizza_name
ORDER BY COUNT(order_id) DESC; -- 9 meatlovers and 3 vegetarian pizzas were delivered

-- 5. Veg and meatlovers ordered by customer
SELECT 
	customer_id,
	pizza_name,
	COUNT(order_id) AS total_ordered
FROM master_table
WHERE cancellation = 'N'
GROUP BY customer_id, pizza_name
ORDER BY customer_id, COUNT(order_id) DESC;
/* 101 - 2m, 102 & 103 - 2m & 1v, 104 - 3m, 105 - 1v */

-- 6. Maximum pizzas in single order
WITH master_temp AS (
SELECT
	DISTINCT order_id,
	COUNT(*) AS pizzas_per_order,
	RANK() OVER (
	ORDER BY COUNT(*) DESC) AS rank
FROM master_table
WHERE cancellation = 'N'
GROUP BY order_id
ORDER BY order_id
)
SELECT
	order_id,
	pizzas_per_order
FROM master_temp
WHERE rank = 1; -- Order 4 had the most pizzas with 3

-- 7. Get count of pizzas per customer with and without changes
SELECT
	customer_id,
	COUNT(*) FILTER(WHERE exclusions <> 'none' OR extras <> 'none') AS with_changes,
	COUNT(*) FILTER(WHERE exclusions = 'none' AND extras = 'none') AS no_change
FROM master_table
WHERE cancellation = 'N'
GROUP BY customer_id
ORDER BY customer_id;
-- No change: 101 - 2, 102 - 3, 104 - 1 With change: 103 - 3, 104 - 2, 105 - 1

-- 8. Num deliveries with both exclusions and extras
SELECT
	COUNT(*) FILTER(WHERE exclusions <> 'none' AND extras <> 'none')
FROM master_table
WHERE cancellation = 'N'; -- 1 order had both extras and exclusions

-- 9. Num pizzas ordered per hour
SELECT 
	COUNT(*) AS pizzas_ordered,
	EXTRACT(HOUR FROM order_time) AS hour_of_day
FROM master_table
WHERE cancellation = 'N'
GROUP BY EXTRACT(HOUR FROM order_time); -- 1 ordered at 19:00, 2 at 21:00, and 3 at 13:00, 18:00, and 23:00 each

-- 10. Num pizzas ordered per weekday
SELECT
	COUNT(*) AS pizzas_ordered,
	EXTRACT(DOW FROM order_time) AS dow
FROM master_table
WHERE cancellation = 'N'
GROUP BY EXTRACT(DOW FROM order_time); -- 5 ordered on Saturday, 4 on Wednesday, 3 on Thursday

-- 11. Average time in minutes for each runner to arrive to pickup pizza
SELECT 
	runner_id,
	AVG(pickup_time - order_time) AS avg_time
FROM master_table
WHERE cancellation = 'N'
GROUP BY runner_id; -- 1 took ~16 min on average, 3 took ~10, and 2 took ~24

-- 12. Average order time for number of pizzas
SELECT
	DISTINCT order_id,
	COUNT(order_id) AS num_pizzas,
	AVG(pickup_time - order_time) AS avg_time
FROM master_table
WHERE cancellation = 'N'
GROUP BY order_id
ORDER BY AVG(pickup_time - order_time); -- Orders with more pizzas typically take 15-20 minutes vs ~10 for 1 pizza

-- 13. Average distance travelled by customer
SELECT 
	customer_id,
	ROUND(AVG(distance), 2) AS avg_distance
FROM master_table
WHERE cancellation = 'N'
GROUP BY customer_id
ORDER BY customer_id;
-- 101 - 20km, 102 - 16.73km, 103 - 23.4km, 104 - 10km, 105 - 25km

-- 14. longest-shortest delivery time for all orders
SELECT 
	longest_time-shortest_time as diff_min
FROM (
	SELECT
		MIN(duration) AS shortest_time,
		MAX(duration) AS longest_time
	FROM master_table
); -- Difference was 30 minutes

-- 15. Average speed (distance/duration) for each runner
SELECT
	runner_id,
	COUNT(order_id) AS num_orders,
	SUM(distance) AS total_km,
	SUM(duration) AS total_min,
	ROUND(AVG(distance/duration),2)*60 AS avg_kph
FROM master_table
WHERE cancellation = 'N'
GROUP BY runner_id; -- 1 averaged 46.8 km/h, 2 averaged 51.6 km/h, and 3 averaged 40.2 km/h
-- 1 had the most orders, but travelled fewer km than 2

-- 16. Success rate for each driver (find percentage of orders not cancelled)
SELECT
	runner_id,
	(success_orders::float/all_orders)*100 AS success_rate
FROM (
	SELECT
		runner_id,
		COUNT(order_id) FILTER (WHERE cancellation LIKE 'N') AS success_orders, --removes cancellations
		COUNT(order_id) AS all_orders
	FROM master_table
	GROUP BY runner_id
); -- 1 had 100% success, 2 had 83.3%, and 3 had 50%

-- 17. Total earnings (meat lovers = $12 and veg = $10)
WITH price_cte AS (
SELECT
	order_id,
	pizza_name,
	CASE
		WHEN pizza_name = 'Vegetarian' THEN 10.0
		ELSE 12.0
	END AS price
FROM master_table
WHERE cancellation = 'N'
)
SELECT
	SUM(price) AS total_revenue
FROM price_cte; -- $138 total earned

-- 18. Total spent per customer and number of pizzas ordered
WITH price_cte AS (
SELECT
	customer_id,
	pizza_name,
	CASE
		WHEN pizza_name = 'Vegetarian' THEN 10.0
		ELSE 12.0
	END AS price
FROM master_table
WHERE cancellation = 'N'
)
SELECT
	customer_id,
	COUNT(*) AS num_pizzas,
	SUM(price) AS total_spent
FROM price_cte
GROUP BY customer_id
ORDER BY customer_id; -- 101 - $24 & 2, 102 - $34 & 3, 103 - $34 & 3, 104 - $36 & 3, 105 - $10 & 1

-- 19. With runner fee of $0.30 per km, find total profit for restaurant
WITH price_cte AS (
SELECT
	customer_id,
	pizza_name,
	CASE
		WHEN pizza_name = 'Vegetarian' THEN 10.0
		ELSE 12.0
	END AS price,
	ROUND(distance*0.30, 2) AS delivery_cost
FROM master_table
WHERE cancellation = 'N'
)
SELECT
	SUM(price) - SUM(delivery_cost) AS profit
FROM price_cte; -- $73.38 total profit