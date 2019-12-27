-- 1179. Reformat Department Table 
/* Write your T-SQL query statement below */
select id,
Jan as Jan_Revenue,
Feb as Feb_Revenue,
Mar as Mar_Revenue,
Apr as Apr_Revenue,
May as May_Revenue,
Jun as Jun_Revenue,
Jul as Jul_Revenue,
Aug as Aug_Revenue,
Sep as Sep_Revenue,
Oct as Oct_Revenue,
Nov as Nov_Revenue,
Dec as Dec_Revenue
FROM Department
PIVOT
(
Sum(revenue) 
FOR Month
IN (Jan, Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct, Nov, Dec) 
) as tb;


--1142 
-- ISNULL/ NULLIF / 
-- ISNULL requires all data types are the same 
-- Need to redo it 



-- 1076 
-- 想的太复杂

--1083
-- Use Except Function 

--577 
-- Need to use left or right join to keep null values 

SELECT E.name, B.bonus 
FROM Employee AS E 
LEFT JOIN Bonus AS B 
ON E.empId = B.empId
WHERE B.bonus < 1000 
OR B.bonus is null

--607
SELECT 
name FROM 
salesperson 
WHERE sales_id NOT IN
(
SELECT O.sales_id
FROM orders AS O 
LEFT JOIN company AS C
ON O.com_id = C.com_id 
WHERE C.name = 'RED'
    )
    
    
/*    
SELECT 
name FROM 
salesperson 
WHERE sales_id IN
(
SELECT O.sales_id
FROM orders AS O 
LEFT JOIN company AS C
ON O.com_id = C.com_id 
WHERE C.name != 'RED'
    )
*/ 
-- WHY IT IS NOT CORRENT TO USE IN 

--603
-- consectutive problem 
select distinct a.seat_id
from cinema a 
join cinema b
on abs(a.seat_id - b.seat_id) = 1
and a.free = 1 
and b.free = 1
order by a.seat_id

--626 EXCHANGE COUNTS 
SELECT
    (CASE
        WHEN id%2 != 0 AND counts != id THEN id + 1
        WHEN id%2 != 0 AND counts = id THEN id
        ELSE id - 1
    END) AS id,
    student
FROM
    seat,
    (SELECT
        COUNT(*) AS counts
    FROM
        seat) AS seat_counts
ORDER BY id ASC;

-- 180 
-- CONSECUTIVE PROBLEM 
-- SOLUTION A -- Use Lag and Lead 
SELECT DISTINCT NUM AS ConsecutiveNums
FROM 
(SELECT id,num,
lag(num) OVER (ORDER BY Id) AS Before,
lead(num) OVER (ORDER BY Id) AS After
FROM logs) Nlogs
WHERE Num=Before AND Before=After
-- SOLUTION B -- Use Self-Join 
SELECT DISTINCT
    l1.Num AS ConsecutiveNums
FROM
    Logs l1,
    Logs l2,
    Logs l3
WHERE
    l1.Id = l2.Id - 1
    AND l2.Id = l3.Id - 1
    AND l1.Num = l2.Num
    AND l2.Num = l3.Num

-- Leetcode 602 
--Union All 
SELECT TOP 1 ids AS id, COUNT(ids) AS num
FROM(
SELECT requester_id AS ids
FROM request_accepted
UNION ALL
SELECT accepter_id AS ids
FROM request_accepted) AS tb1
GROUP BY ids
ORDER BY COUNT(ids) DESC

-- 574 
-- JOIN and Count 
SELECT TOP 1 C.Name
FROM Vote AS V
JOIN Candidate AS C
ON V.CandidateId = C.id
GROUP BY C.Name
ORDER BY COUNT( C.id) DESC 
-- row_number() 是没有重复值的排序(即使两天记录相等也是不重复的)，可以利用它来实现分页
-- dense_rank() 是连续排序，两个第二名仍然跟着第三名
-- rank()       是跳跃拍学，两个第二名下来就是第四名

-- 608 tree node
-- need to be clear about the join result 
SELECT distinct id, 
CASE WHEN ( p2_id is null )  THEN 'Root'
WHEN ( p2_id is not null ) and (p1_id is not null) THEN 'Inner'
WHEN ( p2_id is not null ) and (p1_id is null) THEN 'Leaf'
END AS Type
FROM (
SELECT t1.p_id AS p1_id, t2.id, t2.p_id AS p2_id
FROM tree AS t1
RIGHT JOIN tree AS t2 
ON t1.p_id = t2.id ) as a

-- ???rethink this piece of code 
SELECT DISTINCT a.id, CASE 
    WHEN a.p_id IS NULL THEN 'Root' 
    WHEN b.id IS NULL THEN 'Leaf'
    ELSE 'Inner' 
        END AS Type
FROM tree a
LEFT JOIN tree b ON a.id = b.p_id
ORDER BY a.id

--1204 累计加和
SELECT turn, SUM(weight)OVER(ORDER BY turn) AS subTotal
FROM   Queue

