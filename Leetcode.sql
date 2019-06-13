--leetcode  176-second highest salary 
select salary as SecondHighestSalary 
from employee 
order by salary desc
limit 1;
--this is not right because we need to consider if there is just one record in the table. and we could take this as a temp table.
--answer1：
SELECT
    (SELECT DISTINCT
            Salary
        FROM
            Employee
        ORDER BY Salary DESC
        LIMIT 1 OFFSET 1) AS SecondHighestSalary
;
--what the difference between my answer and answer1?
--answer2:
SELECT
    IFNULL(
      (SELECT DISTINCT Salary
       FROM Employee
       ORDER BY Salary DESC
        LIMIT 1 OFFSET 1),
    NULL) AS SecondHighestSalary;

-----leetcode 181
--there is a problem in understandig the meaning of the question and the table. Always, I need to understand the table of the data first, then I should do the analysis or write the query. 
--for the column ManagerId, it means the employee's manager's id. Please understand the data, understand the data 
--my answer
select e.name as employee from employee as e
where e.salary > 
(select min(e1.salary) from employee as e1 where e1.Id=e.ManagerId);
--Be clear of what they require you to write in the header of output.
--example answer
SELECT
    a.Name AS 'Employee'
FROM
    Employee AS a,
    Employee AS b
WHERE
    a.ManagerId = b.Id
        AND a.Salary > b.Salary

--example answer
SELECT
     a.NAME AS Employee
FROM Employee AS a JOIN Employee AS b
     ON a.ManagerId = b.Id
     AND a.Salary > b.Salary
;
---182.Duplicate Email 
--why could I think about problems in such a complex way??
select Email 
from Person 
group by email 
having count(email)>1;

--nested 
selecy email from 
(select email, count(email) as num 
from person
group by email )
as statistic 
where num>1;

--183 Customers who never order 
--my answer
select distinct name as Customers 
from customers, orders 
where name not in 
(select name from customers, orders where customers.Id=orders.customerId);
--exmaple answer 
select customers.name as 'Customers'
from customers
where customers.id not in
(
    select customerid from orders
);
--the final output from my answer is the same withe the output of sample answer, but my query my be more complicated. 
---196 Delet Duplicate Emails 
--how to start thinking a problem correctly when thinking of a question 
delete from Person Where 
Id not in 
(Select min(p.Id) from (select * from person) p group by p.email);
--it is a good idea to group by email. 

















