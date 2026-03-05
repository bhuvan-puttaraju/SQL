create database if not exists Foodie_Fi;
use Foodie_Fi;

show tables;

CREATE TABLE subscription_plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50),
    price DECIMAL(10,2) NULL
);

select * from subscription_plans;

INSERT INTO subscription_plans (plan_id, plan_name, price) VALUES
(0, 'trial', 0),
(1, 'basic monthly', 9.90),
(2, 'pro monthly', 19.90),
(3, 'pro annual', 199),
(4, 'churn', NULL);


CREATE TABLE customer_subscriptions (
    customer_id INT,
    plan_id INT,
    start_date DATE,
    PRIMARY KEY (customer_id, start_date),
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id)
);

INSERT INTO customer_subscriptions (customer_id, plan_id, start_date) VALUES
(1, 0, '2020-08-01'),
(1, 1, '2020-08-08'),
(2, 0, '2020-09-20'),
(2, 3, '2020-09-27'),
(11, 0, '2020-11-19'),
(11, 4, '2020-11-26'),
(13, 0, '2020-12-15'),
(13, 1, '2020-12-22'),
(13, 2, '2021-03-29'),
(15, 0, '2020-03-17'),
(15, 2, '2020-03-24'),
(15, 4, '2020-04-29'),
(16, 0, '2020-05-31'),
(16, 1, '2020-06-07'),
(16, 3, '2020-10-21'),
(18, 0, '2020-07-06'),
(18, 2, '2020-07-13'),
(19, 0, '2020-06-22'),
(19, 2, '2020-06-29'),
(19, 3, '2020-08-29');


# A. Customer Journey

SELECT cs.customer_id, sp.plan_name, cs.start_date
FROM customer_subscriptions cs
JOIN subscription_plans sp ON cs.plan_id = sp.plan_id
ORDER BY cs.customer_id, cs.start_date;

# B. Data Analysis Questions

# 1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customer_subscriptions;

# 2. Monthly distribution of trial plan start dates

SELECT DATE_FORMAT(start_date, '%Y-%m') AS month, COUNT(*) AS trial_count
FROM customer_subscriptions
WHERE plan_id = 0
GROUP BY month
ORDER BY month;

# 3. Plan start dates after 2020, breakdown by plan_name

SELECT sp.plan_name, COUNT(*) AS count_events
FROM customer_subscriptions cs
JOIN subscription_plans sp ON cs.plan_id = sp.plan_id
WHERE YEAR(cs.start_date) > 2020
GROUP BY sp.plan_name
ORDER BY count_events DESC;

#4. Customer count and percentage of churned customers (rounded to 1 decimal place)

SELECT 
    COUNT(DISTINCT customer_id) AS churned_customers,
    ROUND(100 * COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM customer_subscriptions), 1) AS churn_percentage
FROM customer_subscriptions
WHERE plan_id = 4;

# 5. Customers who churned straight after the free trial (rounded to whole number)

SELECT 
    COUNT(DISTINCT cs1.customer_id) AS churn_after_trial,
    ROUND(100 * COUNT(DISTINCT cs1.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM customer_subscriptions), 0) AS percentage
FROM customer_subscriptions cs1
JOIN customer_subscriptions cs2 
    ON cs1.customer_id = cs2.customer_id 
    AND cs1.start_date < cs2.start_date
WHERE cs1.plan_id = 0 AND cs2.plan_id = 4;

# 6. Number and percentage of customer plans after the initial free trial

SELECT 
    sp.plan_name,
    COUNT(DISTINCT cs2.customer_id) AS customer_count,
    ROUND(100 * COUNT(DISTINCT cs2.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM customer_subscriptions), 1) AS percentage
FROM customer_subscriptions cs1
JOIN customer_subscriptions cs2 
    ON cs1.customer_id = cs2.customer_id 
    AND cs1.start_date < cs2.start_date
JOIN subscription_plans sp ON cs2.plan_id = sp.plan_id
WHERE cs1.plan_id = 0 
AND cs2.plan_id != 4
GROUP BY sp.plan_name
ORDER BY customer_count DESC;

# 7. Customer count and percentage breakdown of all plans as of 2020-12-31

SELECT 
    sp.plan_name,
    COUNT(DISTINCT cs.customer_id) AS customer_count,
    ROUND(100 * COUNT(DISTINCT cs.customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM customer_subscriptions), 1) AS percentage
FROM customer_subscriptions cs
JOIN subscription_plans sp ON cs.plan_id = sp.plan_id
WHERE cs.start_date <= '2020-12-31'
GROUP BY sp.plan_name
ORDER BY customer_count DESC;

# 8. Customers who upgraded to an annual plan in 2020

SELECT COUNT(DISTINCT customer_id) AS annual_plan_customers
FROM customer_subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = 2020;

# 9. Average days to upgrade to an annual plan

SELECT 
    ROUND(AVG(DATEDIFF(cs2.start_date, cs1.start_date)), 1) AS avg_days_to_annual
FROM customer_subscriptions cs1
JOIN customer_subscriptions cs2 
    ON cs1.customer_id = cs2.customer_id
WHERE cs1.plan_id = 0 AND cs2.plan_id = 3;

# 10. Breakdown of time taken to upgrade to an annual plan in 30-day periods

SELECT 
    CASE 
        WHEN days_to_annual <= 30 THEN '0-30 days'
        WHEN days_to_annual <= 60 THEN '31-60 days'
        WHEN days_to_annual <= 90 THEN '61-90 days'
        ELSE '90+ days'
    END AS period_range,
    COUNT(*) AS customer_count
FROM (
    SELECT 
        cs1.customer_id,
        DATEDIFF(cs2.start_date, cs1.start_date) AS days_to_annual
    FROM customer_subscriptions cs1
    JOIN customer_subscriptions cs2 
        ON cs1.customer_id = cs2.customer_id
    WHERE cs1.plan_id = 0 AND cs2.plan_id = 3
) subquery
GROUP BY period_range
ORDER BY period_range;

# 11. Customers who downgraded from pro monthly to basic monthly in 2020

SELECT COUNT(DISTINCT cs1.customer_id) AS downgraded_customers
FROM customer_subscriptions cs1
JOIN customer_subscriptions cs2 
    ON cs1.customer_id = cs2.customer_id
WHERE cs1.plan_id = 2 AND cs2.plan_id = 1
AND YEAR(cs1.start_date) = 2020
AND YEAR(cs2.start_date) = 2020;