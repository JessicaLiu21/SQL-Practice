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

-- 1107
--New User Daily Count 
-- Need to pay attention where should we out the filter conditions 
-- Within or out of the subquery
SELECT  activity_date AS login_date,
COUNT(DISTINCT user_id) AS user_count
FROM (
SELECT user_id, activity_date,
row_number() over(PARTITION BY user_id ORDER BY activity_date ASC) AS date_rank 
FROM traffic 
WHERE activity = 'login'
)
AS A
WHERE date_rank = 1
AND activity_date 
BETWEEN DATEADD(day, -90, '2019-06-30') AND '2019-06-30'
GROUP BY activity_date

-- If the problem allows us to use two statement, we could use CTE first.
-- Try to think problme in MIN/MAX problem first then windows function
WITH first_login AS 
(SELECT DISTINCT user_id, MIN(activity_date) AS first_login
FROM Traffic WHERE activity = 'login' GROUP BY user_id)

SELECT f_login AS login_date, COUNT(user_id) AS user_count 
FROM first_login 
WHERE datediff(day,f_login, '2019-06-30')<=90
GROUP BY f_login 


--1212 Team Scores in Football Tournament 
-- The ISNULL() function is used to replace NULL with the specified replacement value. This function contains only two arguments.
-- Syntax  ISNULL (check_exp, change_value)

-- the NULLIF function compares expression1 and expression2. 
-- If expression1 and expression2 are equal, the NULLIF function returns NULL. 
-- Otherwise, it returns the first expression which is expression1.
SELECT Teams.team_id AS team_id, team_name, 
isnull(sum(score),0) AS num_points
FROM (
SELECT host_team AS team_num,
CASE WHEN host_goals > guest_goals THEN 3 
WHEN host_goals = guest_goals THEN 1
WHEN host_goals < guest_goals THEN 0
END AS score FROM Matches 
UNION ALL
SELECT guest_team AS team_num,
CASE WHEN host_goals > guest_goals THEN 0
WHEN host_goals = guest_goals THEN 1
WHEN host_goals < guest_goals THEN 3
END AS score FROM Matches )
AS A 
RIGHT JOIN Teams 
ON Teams.team_id = A.team_num
GROUP BY Teams.team_id, team_name
ORDER BY num_points DESC, Teams.team_id

--1285
--Classical Methods of calculating continuous variables 
SELECT MIN(log_id) AS start_id, MAX(log_id) AS end_id
FROM
(
SELECT log_id, row_number() OVER(ORDER BY log_id) AS rank
FROM logs)
AS A 
GROUP BY log_id-rank

--580 Count Student Number in Departments 
-- Right Join AND ISNULL 
SELECT dept_name, ISNULL(COUNT(DISTINCT student_id),0) AS student_number
FROM student AS s
RIGHT JOIN  department AS d
ON s.dept_id = d.dept_id 
GROUP BY dept_name
ORDER BY student_number DESC, dept_name

--1174  Immediate Food Delivery II 
--The speed is not so fast, need to redo 
/* Write your T-SQL query statement below */
SELECT ROUND((SUM(deliver_state)*100.00/COUNT(*)),2)
AS  immediate_percentage       
FROM (
SELECT CASE WHEN DATEDIFF(day,min_date,customer_pref_delivery_date) = 0 THEN 1
ELSE 0
END AS deliver_state
FROM(
SELECT customer_id, min(order_date) AS min_date
FROM delivery
GROUP BY customer_id
) AS A JOIN delivery 
ON delivery.order_date = A.min_date
AND delivery.customer_id = A.customer_id
)  AS B

-- 1270 All Peaple Report to the Given Manager 
-- 想好 连接链条的顺序， 然后再想filter 条件
SELECT DISTINCT E1.employee_id 
FROM 
Employees AS E1
JOIN Employees AS E2
ON (E2.employee_id = E1.manager_id)
AND (E1.Employee_id != 1)
JOIN Employees AS E3
ON (E3.employee_id = E2.manager_id )
WHERE E1.manager_id = 1
OR E2.manager_id = 1
OR E3.manager_id = 1

-- 1264  Page Recommendatio 
-- 注意什么时候where的condition是OR，什么时候用什么筛选条件
SELECT  DISTINCT L.page_id AS recommended_page
FROM Friendship AS F 
JOIN Likes AS L
ON( F.user2_id = L.user_id 
OR F.user1_id = L.user_id )
WHERE
(F.user1_id =1 
OR F.user2_id = 1)
AND L.page_id NOT IN (SELECT page_id FROM Likes where user_id =1)

--1193 Monthly Transactions I 
-- 日期的提取方式/ 用case when 有条件的进行aggregation 

SELECT left(trans_date, 7) as month, 
country, 
COUNT(*) AS trans_count,
SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 end) AS approved_count,
SUM(amount) AS trans_total_amount,
SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 end) AS approved_total_amount
FROM Transactions 
GROUP BY left(trans_date, 7), country 

/*
cast(YEAR(trans_date) as varchar) + '-' + cast(Month(trans_date) as varchar) AS month
*/
-- 这种方式也可以提取年和月，但是结果是2019-1这样。不如left写法来的高效


-- 1205 Monthly Transactions II
-- 用CTE分别写，然后再用case when来合并
-- 用CTE分别写的时候只管自己的条件/ CTE用自己的CASE WHEN的时候注意考虑结果是否要保0
-- 注意join/ right join/ full join不同的使用情况
WITH CTE1 
AS 
(SELECT left(T.trans_date, 7) as month, 
country, 
--SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 end) AS approved_count,
--SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 end) AS approved_amount
count(*) as approved_count,
sum(amount) as approved_amount
FROM Transactions AS T
WHERE T.state = 'approved'
GROUP BY left(T.trans_date, 7), country  
)
,CTE2 
AS 
(SELECT left(C.trans_date, 7) as month, 
country, 
COUNT(DISTINCT C.trans_id ) AS chargeback_count,
SUM( amount) AS chargeback_amount
FROM Transactions AS T
RIGHT JOIN Chargebacks AS C 
ON T.id = C.trans_id 
GROUP BY left(C.trans_date, 7), country 
)

SELECT CASE WHEN C1.month is not null THEN C1.month ELSE C2.month END AS month,
CASE WHEN C1.country is not null THEN C1.country ELSE C2.country END AS country,
ISNULL(C1.approved_count,0) AS approved_count,
ISNULL(C1.approved_amount,0) AS approved_amount,
ISNULL(C2.chargeback_count,0) AS chargeback_count,
ISNULL(C2.chargeback_amount,0) AS chargeback_amount
FROM CTE1  AS C1 
FULL OUTER JOIN 
CTE2 AS C2
ON C1.month = C2.month 
AND C1.country = C2.country
ORDER BY Month 


--1164 Product Price at a Given Date 
-- windows function 复杂嵌套
SELECT distinct  P.product_id,
CASE WHEN  B.change_date <='2019-08-16' THEN B.new_price
ELSE 10 
END AS price
FROM 
(SELECT * FROM (
SELECT *, row_number() OVER (PARTITION BY product_id ORDER BY change_date DESC) AS date_rank 
FROM Products 
WHERE change_date < = '2019-08-16') AS A
WHERE A.date_rank = 1
) AS B 
RIGHT JOIN products AS P
ON B.product_id = P.product_id 

-- CTE和各种Join 
with t1 as (
    select product_id, max(change_date) as close_date
    from Products
    where change_date<='2019-08-16'
    group by product_id)

select t2.product_id,
		max(case when t2.change_date = t1.close_date then new_price
			when t1.close_date is null then 10
			else null end) as price
from Products t2
	left join t1
	on t2.product_id = t1.product_id
group by t2.product_id

--1149 Article Views II
-- 不要把问题想的太复杂
-- 复杂版
SELECT DISTINCT B.viewer_id AS id
FROM 
(
SELECT A.view_date, A.viewer_id 
FROM 
(SELECT DISTINCT article_id, author_id, viewer_id, view_date
FROM Views) AS A 
GROUP BY A.view_date, A.viewer_id
HAVING COUNT(DISTINCT A.article_id)>1
) AS B 

--简易版
SELECT   DISTINCT viewer_id AS id
FROM     Views 
GROUP BY viewer_id, view_date
HAVING   COUNT(DISTINCT article_id)  >1
ORDER BY viewer_id ASC

-- 1158 Market Analysis I 
-- 注意筛选条件到底是having level的还是where level的
-- 注意最后的result到底是left join哪边 
-- 如果想不清楚就拆分着来 不要一次解决多个问题
SELECT A.user_id AS buyer_id, A.join_date,ISNULL(B.orders_count, 0) AS orders_in_2019
FROM
(SELECT DISTINCT U.user_id ,U.join_date
FROM Users AS U) AS A 
LEFT JOIN 
(SELECT O.buyer_id,
COUNT(DISTINCT O.order_id) AS orders_count
FROM Orders AS O
WHERE O.order_date BETWEEN ' 2019-01-01'  AND '2019-12-31'
GROUP BY O.buyer_id) AS B
ON A.user_id = B. buyer_id

