 
-- Total Order volume per hour (0 = midnight to 23 = 11 pm)
SELECT order_hour_of_day, COUNT(order_id) AS order_count FROM orders GROUP BY order_hour_of_day 

-- Order volume per customer per hour
SELECT user_id,order_hour_of_day,COUNT(order_hour_of_day) AS order_per_hour
FROM orders GROUP BY user_id,order_hour_of_day

-- Cumulative(running total)orders per hour
SELECT user_id,order_hour_of_day,order_count,
SUM(order_count)OVER(PARTITION BY user_id ORDER BY order_hour_of_day)AS running_total_orders FROM(
SELECT user_id,order_hour_of_day,COUNT(*)AS order_count FROM orders
GROUP BY user_id,order_hour_of_day)a 
GROUP BY user_id,order_hour_of_day,order_count LIMIT 20


-- Number of order on each day of the week (0 to 6) WHERE 0 Saturday to 6 Friday
SELECT order_dow, COUNT(order_dow)FROM orders GROUP BY order_dow ORDER BY order_dow

-- Customers who ordered ONLY on weekend
(SELECT  DISTINCT user_id FROM orders WHERE order_dow IN (0,1))
EXCEPT
(SELECT DISTINCT user_id FROM orders WHERE order_dow NOT IN (0,1))
ORDER BY user_id 

-- How many are FIRST TIME customers (First time ordering)
SELECT * FROM orders WHERE user_id IN (
(SELECT DISTINCT user_id FROM orders WHERE days_since_prior_order = 0 ORDER BY user_id)
EXCEPT
(SELECT DISTINCT user_id FROM orders WHERE days_since_prior_order > 0 ORDER BY user_id)
ORDER BY user_id)

-- Customers who ALWAYS reorder in less than 30 days
SELECT * FROM orders WHERE user_id IN(
(SELECT DISTINCT user_id FROM orders WHERE days_since_prior_order < 30 ORDER BY user_id)
EXCEPT
(SELECT DISTINCT user_id FROM orders WHERE days_since_prior_order >= 30 ORDER BY user_id) )
ORDER BY user_id LIMIT 50


--reordering pattern per customer based on days_since_last_order
SELECT user_id,reorder_category,COUNT(reorder_category) AS reorder_frequency_count
FROM(
SELECT user_id,order_number,days_since_prior_order AS days_since_last_order,CASE
WHEN days_since_prior_order <=7 THEN 'frequent_order'
WHEN days_since_prior_order>=30 THEN 'ocassional_order'
ELSE 'regular_order' END AS reorder_category
FROM orders 
ORDER BY user_id,order_number)a  
GROUP BY user_id,reorder_category
--How often customers placed orders
SELECT order_frequency,COUNT(order_frequency) AS order_population_by_category 
FROM (
SELECT user_id,CASE
WHEN COUNT(order_number) < 25 THEN 'Low_frequency'
WHEN COUNT(order_number)>= 25 AND COUNT(order_number)<=50 THEN 'Regular_frequency'
ELSE 'High_frequency' END AS order_frequency,
COUNT(order_number) AS order_count
FROM orders 
GROUP BY user_id)a
GROUP BY order_frequency
LIMIT 100
--How long it takes for customers to reorder
SELECT order_category,COUNT(order_id) AS order_count
FROM (
SELECT order_id,CASE WHEN days_since_prior_order>= 30 THEN 'Ocassional_order'
                    WHEN days_since_prior_order <= 7 THEN 'Frequent_order'
					ELSE 'Regular_order' END AS order_category
FROM orders) a
GROUP BY order_category 
LIMIT 100


