--1121 Query Quality and Percentage 
SELECT query_name,
CAST( SUM(1.0 *rating/position)/COUNT(query_name) AS DECIMAL(10,2))AS quality, 
CAST(1.0* 100*SUM( CASE WHEN rating< 3 THEN 1 ELSE 0 END)/COUNT(rating) AS DECIMAL(10,2))
AS poor_query_percentage 
FROM queries 
GROUP BY query_name

SELECT query_name,
ROUND( SUM(1.0 *rating/position)/COUNT(query_name), 2)AS quality, 
ROUND(1.0* 100*SUM( CASE WHEN rating< 3 THEN 1 ELSE 0 END)/COUNT(rating), 2)
AS poor_query_percentage 
FROM queries 
GROUP BY query_name


--Notes:
-- The result will be different when you multiple 1.0 or not/ or put 1.0 inside the calculation or not
-- CAST is faster than ROUND 

--1173 Immediate Food Delivery 1 
--Key Knowledge: CASE WHEN// DATEDIFF 
SELECT 
ROUND(1.0*100*SUM(CASE WHEN 
DATEDIFF(day, customer_pref_delivery_date, order_date)=0 THEN 1 ELSE 0 END) / COUNT(*),2)
AS immediate_percentage 
FROM Delivery 

--1141 User Activity for the Past 30 Days I 
SELECT activity_date AS day, COUNT(DISTINCT user_id) AS active_users
FROM Activity 
WHERE activity_date BETWEEN DATEADD(day,-29, '2019-07-27')
AND '2019-07-27'
GROUP BY activity_date

--Notes: How to define user_activity
-- How to use dateadd and datediff appropriatedly 

--1050 
SELECT actor_id,director_id
FROM ActorDirector 
GROUP BY actor_id,director_id
HAVING COUNT(*)>=3

--1126 Active Business 
-- use windows function to do aggregation calculation 
SELECT e.business_id
FROM Events AS e
JOIN (SELECT business_id, event_type, AVG (occurences) OVER (PARTITION BY event_type ) AS avg_occ FROM Events) AS a 
ON e.business_id=a.business_id and a.event_type=e.event_type
WHERE e.occurences> a.avg_occ
GROUP BY e.business_id
HAVING COUNT(e.event_type)>1

--notes: need to understand which levels of comparison are we doing// use where or having 
-- no typo 
-- With define a subquery relation 

WITH avg AS 
(SELECT business_id, occurences, AVG(occurences) OVER(PARTITION BY event_type) AS avg_occurences
FROM events)

SELECT business_id 
FROM avg
WHERE occurences> avg_occurences
GROUP BY business_id
HAVING COUNT(*)>1;


