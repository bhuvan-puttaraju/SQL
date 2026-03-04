create database  Pizza_Runner;
use  Pizza_Runner;


DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
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
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
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
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
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


show tables;
describe customer_orders;

# A. Pizza Metrics

# 1. How many pizzas were ordered?

select count(*) as total_orders 
from customer_orders;

# 2.How many unique customer orders were made?

select count(distinct order_id) as unique_customer from customer_orders;     

# 3.How many successful orders were delivered by each runner?

select * from runner_orders;

select runner_id ,count(*) as successful_orders
 from runner_orders where cancellation = "" or cancellation is Null  group by runner_id;

# 4. How many of each type of pizza was delivered?

select * from pizza_names;

select  pizza_name,count(*)as delivered   from 
customer_orders inner join pizza_names using(pizza_id)group by pizza_name ;

# 5. How many Vegetarian and Meatlovers were ordered by each customer?

select * from pizza_names;
select * from customer_orders;

select  pizza_name,customer_id,count(*)  as orders 
from customer_orders inner join pizza_names using(pizza_id) group by pizza_name,customer_id order by customer_id;

# alternate way

SELECT
    co.customer_id,
    SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS vegetarian_count,
    SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS meatlovers_count
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id;


#  What was the maximum number of pizzas delivered in a single order?

select * from customer_orders ;
select order_id,count(*) as max_number from customer_orders group by order_id order by max_number desc limit 1 ;

# 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select * from customer_orders ;
select * from runner_orders;

select customer_id , 
SUM(CASE WHEN (exclusions IS NOT NULL AND extras IS NOT NULL AND exclusions != '' AND extras != '') THEN 1 ELSE 0 END) AS pizzas_with_changes,
SUM(CASE WHEN (exclusions IS NULL OR extras IS NULL OR exclusions = '' OR extras = '') THEN 1 ELSE 0 END) AS pizzas_without_changes
from customer_orders  group by customer_id ;

# 8.How many pizzas were delivered that had both exclusions and extras?

select count(*) as exclusion_extras_both
from customer_orders
where exclusions is not null
  and extras is not null;

# 9.  What was the total volume of pizzas ordered for each hour of the day?

select hour(order_time),count(*) as each_hours 
from customer_orders group by hour(order_time) ;

# 10. What was the volume of orders for each day of the week?

select dayname(order_time),count(*) as week_counts 
from customer_orders group by dayname(order_time);


# B. Runner and Customer Experience

# 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

select * from runners ;

select date_format(registration_date, "%Y-%u") as week_period , count(runner_id) as counts  from runners 
group by week_period order by week_period;

# 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select runner_id ,avg(timestampdiff(minute,order_time,pickup_time)) as avg_time from  customer_orders inner join  runner_orders using (order_id) 
where pickup_time is not null group by runner_id;

# 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?

select co.order_id, count(*) as count_of_pizza,
timestampdiff(minute,(min(co.order_time)),MIN(ro.pickup_time)) as prep_time
 from customer_orders  co  join runner_orders ro using(order_id)
 where  ro.pickup_time is not null 
 group by co.order_id ;
 
# 4.What was the average distance travelled for each customer?

select customer_id, avg(cast(replace(distance,"km","") as decimal(5,2)))as distance_travelled  from customer_orders 
 inner join runner_orders using(order_id) where distance is not null 
group by customer_id;

# 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT 
    MAX(cast(REGEXP_REPLACE(duration, '[^0-9]', '') as signed)) -
    MIN(cast(REGEXP_REPLACE(duration, '[^0-9]', '')as signed)) AS delivery_time_difference
FROM runner_orders WHERE duration IS NOT NULL AND duration <> 'null';

# 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select * from runner_orders;

select cast(REGEXp_REPLACE(duration,'[^0-9]',"") as signed) as duration_time,
cast(REGEXp_REPLACE(distance,'[^0-9]',"") as signed) as actual_distance,

CAST(REGEXP_REPLACE(distance, '[^0-9]', '') AS DECIMAL(5,2)) /
(CAST(REGEXP_REPLACE(duration, '[^0-9]', '') AS DECIMAL(5,2))) AS avg_speed

 from runner_orders WHERE distance IS NOT NULL AND distance <> 'null'
 AND duration IS NOT NULL AND duration <> 'null';
 
 #7.What is the successful delivery percentage for each runner?
 select runner_id,sum(case when pickup_time="null" then 0 else 1 end)/count(order_id)as successful_delivery_percentage from runner_orders group by runner_id;
 
 #C. Ingredient Optimisation
 
 #1.What are the standard ingredients for each pizza?

select*from pizza_toppings;
select pn.pizza_name,GROUP_CONCAT(pt.topping_name order by pt.topping_name separator ', ') as standard_ingredients
from pizza_recipes pr join pizza_names pn on pr.pizza_id = pn.pizza_id join pizza_toppings pt ON pt.topping_id = topping_id
group by pn.pizza_name
order by pn.pizza_name;

#2.What was the most commonly added extra?

SELECT pt.topping_name, COUNT(*) AS frequency FROM customer_orders co JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.extras)
GROUP BY pt.topping_name
ORDER BY frequency DESC LIMIT 1;

#3.# 3. What was the most common exclusion?
SELECT pt.topping_name, COUNT(*) AS frequency FROM customer_orders co JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, co.exclusions)
GROUP BY pt.topping_name
ORDER BY frequency DESC LIMIT 1;

#4.Generate an order item for each record in the customer_orders table in the specified format

SELECT co.order_id,pn.pizza_name,CASE 
WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL THEN CONCAT(pn.pizza_name, ' - Exclude ', GROUP_CONCAT(DISTINCT pt1.topping_name ORDER BY pt1.topping_name SEPARATOR ', '), ' - Extra ', GROUP_CONCAT(DISTINCT pt2.topping_name ORDER BY pt2.topping_name SEPARATOR ', '))
WHEN co.exclusions IS NOT NULL THEN CONCAT(pn.pizza_name, ' - Exclude ', GROUP_CONCAT(DISTINCT pt1.topping_name ORDER BY pt1.topping_name SEPARATOR ', '))
WHEN co.extras IS NOT NULL THEN CONCAT(pn.pizza_name, ' - Extra ', GROUP_CONCAT(DISTINCT pt2.topping_name ORDER BY pt2.topping_name SEPARATOR ', '))
ELSE pn.pizza_name END AS order_item FROM customer_orders co JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
LEFT JOIN pizza_toppings pt1 ON FIND_IN_SET(pt1.topping_id, co.exclusions)
LEFT JOIN pizza_toppings pt2 ON FIND_IN_SET(pt2.topping_id, co.extras)
GROUP BY co.order_id, pn.pizza_name, co.exclusions, co.extras;


# 5. Generate an alphabetically ordered comma-separated ingredient list for each pizza order and
#  add a 2x in front of any relevant ingredients

SELECT 
    co.order_id,
    pn.pizza_name,
    CONCAT(
        pn.pizza_name, ': ', 
        GROUP_CONCAT(DISTINCT 
            CASE 
                WHEN FIND_IN_SET(pt.topping_id, co.extras) THEN CONCAT('2x', pt.topping_name)
                ELSE pt.topping_name
            END
        ORDER BY pt.topping_name SEPARATOR ', ')
    ) AS ingredient_list
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
GROUP BY co.order_id, pn.pizza_name;

# 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

SELECT 
    pt.topping_name, 
    SUM(CASE WHEN FIND_IN_SET(pt.topping_id, co.extras) THEN 2 ELSE 1 END) AS total_quantity
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
WHERE ro.cancellation IS NULL OR ro.cancellation = ''
GROUP BY pt.topping_name
ORDER BY total_quantity DESC;

#D. Pricing and Ratings

# 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes, 
# how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
    SUM(
        CASE 
            WHEN pn.pizza_name = 'Meatlovers' THEN 12 
            WHEN pn.pizza_name = 'Vegetarian' THEN 10 
        END
    ) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;

# 2. What if there was an additional $1 charge for any pizza extras? - Add cheese is $1 extra

SELECT 
    SUM(
        CASE 
            WHEN pn.pizza_name = 'Meatlovers' THEN 12 
            WHEN pn.pizza_name = 'Vegetarian' THEN 10 
        END + IF(co.extras IS NOT NULL, LENGTH(REPLACE(co.extras, ',', '')) + 1, 0)
    ) AS total_revenue
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;

# 3. The Pizza Runner team now wants to add an additional ratings system that allows 
-- customers to rate their runner. Design an additional table for this new dataset - generate a 
-- schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.


-- Step 1: Add Indexes
ALTER TABLE runner_orders ADD INDEX (order_id);
ALTER TABLE runners ADD INDEX (runner_id);

-- Step 2: Create the `runner_ratings` Table with Foreign Keys
CREATE TABLE runner_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    runner_id INT,
    rating INT,
    FOREIGN KEY (order_id) REFERENCES runner_orders(order_id),
    FOREIGN KEY (runner_id) REFERENCES runners(runner_id)
);

-- Step 3: Insert Sample Data into the `runner_ratings` Table
INSERT INTO runner_ratings (order_id, runner_id, rating) VALUES
(1, 1, 5),
(2, 1, 4),
(3, 1, 5),
(4, 2, 3),
(5, 3, 4),
(7, 2, 5),
(8, 2, 4),
(10, 1, 5);

# 4. Using your newly generated table - can you join all the information together to form a table 
-- with the following information for successful deliveries?

SELECT 
    co.customer_id,
    co.order_id,
    ro.runner_id,
    rr.rating,
    co.order_time,
    ro.pickup_time,
    TIMESTAMPDIFF(MINUTE, co.order_time, STR_TO_DATE(ro.pickup_time, '%Y-%m-%d %H:%i:%s')) AS time_between_order_and_pickup,
    ro.duration,
    CAST(REPLACE(ro.distance, 'km', '') AS DECIMAL(5,2)) / (CAST(SUBSTRING_INDEX(ro.duration, ' ', 1) AS DECIMAL(5,2)) / 60) AS avg_speed,
    COUNT(co.pizza_id) AS total_number_of_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN runner_ratings rr ON ro.order_id = rr.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = ''
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time, ro.duration, ro.distance;

# 5. If a Meat Lovers pizza was $12 and Vegetarian $10 with no cost for extras and 
# each runner is paid $0.30 per kilometer traveled, how much money does Pizza Runner have left over after these deliveries?

SELECT 
    SUM(
        CASE 
            WHEN pn.pizza_name = 'Meatlovers' THEN 12 
            WHEN pn.pizza_name = 'Vegetarian' THEN 10 
        END
    ) - SUM(CAST(REPLACE(ro.distance, 'km', '') AS DECIMAL(5,2)) * 0.30) AS total_leftover
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation = '';


