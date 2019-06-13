--hacker rank 
--Query the two cities in STATION with the shortest and longest CITY names, as well as their respective lengths (i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.

select city ,length(city) from station where length(city)= (select min(length(city)) from station order by length(city), city asc limit 1) order by city limit 1;
select city ,length(city) from station where length(city)= (select max(length(city)) from station order by length(city), city asc limit 1);
--Query the list of CITY names starting with vowels (i.e., a, e, i, o, or u) from STATION. Your result cannot contain duplicates.
select city from station where substr(city,1,1) in ('A','E','I','O','U') group by city;
--substr(str,pos,len)从pos的位置开始截取Len个字符 substr(name,1,1) 截取name的字符串中从第一个位置开始的第一个字符
select distinct city from station where substr(city,-1,1) in ('A','E','I','O','U') group by city;
SELECT DISTINCT city FROM station where substr(city,-1,1) in ('A','E','I','O','U') and substr(city,1,1) in ('A','E','I','O','U') group by city;
select distinct city from station where substr(city,1,1) not in ('A','E','I','O','U') group by city;
select distinct city from station where substr(city,-1,1) not in ('A','E','I','O','U') group by city;
SELECT DISTINCT city FROM station where substr(city,-1,1) not in ('A','E','I','O','U') or substr(city,1,1) not in ('A','E','I','O','U') group by city;
SELECT DISTINCT city FROM station where substr(city,-1,1) not in ('A','E','I','O','U') and  substr(city,1,1) not in ('A','E','I','O','U') group by city;

select name from students where marks>75 order by substr(name,-3,3);
select name from students where marks>75 order by substr(name,-3,3), ID asc;

select name from employee order by name asc;
select name from employee where salary>2000 and months<10 order by employee_id asc;

Select round(S.LAT_N,4) median from station S where (select count(Lat_N) from station where Lat_N < S.LAT_N ) = (select count(Lat_N) from station where Lat_N > S.LAT_N);
--round(name,4)就是给数字结果取几位余数、、、、中位数
--中位数的写法 select s.lat_n from station as s where (select count(Lat_N) from station where Lat_N<S.Lat_N)-(select count(Lat_N) from station where Lat_N>S.LaT_N);

select hacker_id, name, count(challenge_id) as sum  from hackers join challenges on hackers.hacker_id=challenges.hacker_id 
group by hacker_id

--not a right answer and need to be solved 
select c.hacker_id, h.name, count(c.hacker_id) as c_count
from hackers as h
inner join 
challenges as c 
on c.hacker_id=h.hacker_id 
group by c.hacker_id
having c_count=(select max(temp1.cnt) from (select count(hacker_id) as cnt from challenges group by hacker_id order by hacker_id) temp1)
or 
c_count in 
(select t.cnt from (select count(*) as cnt from challenges group by hacker_id t group by t.cnt having count(t.cnt)=1))
order by c_count desc, c.hacker_id

--
select name, substr(occupation,1,1) from occupations; 
select concat(Name,'(',Substring(Occupation,1,1),')') as Name from occupations Order by Name; 
select concat('There are total',' ',count(occupation),' ',lower(occupation),'s.') as total from occupations
group by occupation order by count(occupation);
--答案是错的，但是学会了如何output 字符串，用函数concat

--这个又是错的  但是正确的好复杂
select name from occupations group by occupation order by name asc;
update occupations set name="null" when sum(occupation)=0;

---到达了medium难度 想问下
set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from(
  select case when Occupation='Doctor' then (@r1:=@r1+1)
            when Occupation='Professor' then (@r2:=@r2+1)
            when Occupation='Singer' then (@r3:=@r3+1)
            when Occupation='Actor' then (@r4:=@r4+1) end as RowNumber,
    case when Occupation='Doctor' then Name end as Doctor,
    case when Occupation='Professor' then Name end as Professor,
    case when Occupation='Singer' then Name end as Singer,
    case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name
) Temp
group by RowNumber；
--这是一道关于二分树的题
SELECT N, IF(P IS NULL,'Root',IF((SELECT COUNT(*) FROM BST WHERE P=B.N)>0,'Inner','Leaf')) 
FROM BST AS B ORDER BY N;
--熟悉一下if的用法

select distinct company_code, founder_name,count(lead_manager_code),
count(senior_manager_code),count(manager_code),count(employee_code)
from company, lead_manager, senior_manager, manager, employee
where company.company_code=lead_manager.company_code
and lead_manager.lead_manager_code=senior_manager.lead_manager_code
and senior_manager.senior_manager_code=manager.senior_manager_code
and manager.manager_code=employee.manager_code
group by company_code
order by company_code asc;

select c.company_code, c.founder, 
    count(distinct l.lead_manager_code), count(distinct s.senior_manager_code), 
    count(distinct m.manager_code),count(distinct e.employee_code) 
from Company c, Lead_Manager l, Senior_Manager s, Manager m, Employee e 
where c.company_code = l.company_code 
    and l.lead_manager_code=s.lead_manager_code 
    and s.senior_manager_code=m.senior_manager_code 
    and m.manager_code=e.manager_code 
group by c.company_code order by c.company_code;


select count(name) from city where population>100000;
select sum(population) from city where district="California";
SELECT AVG(population) FROM CITY WHERE DISTRICT="CALIFORNIA";

select floor(avg(population)) from city; 

--取四位小数就是这么写的,sum函数的应用也不完全是要先用group by 
SELECT ROUND(SUM(Lat_N), 4)
FROM STATION
WHERE Lat_N > 38.7880 AND Lat_N < 137.2345;
--the difference between is and =
select round(LONG_W, 4) from station where LAT_N=(select max(LAT_N) FROM STATION WHERE LAT_N<137.2345);
--
select ROUND((max(LAT_N)-min(LAT_N))+(MAX(LONG_W)-MIN(LONG_W)),4) FROM STATION;
--乘方和开方 乘方用power 开方用sqrt
select round(sqrt(power(min(lat_n)-max(lat_n),2)+power(min(long_w)-max(long_w),2)),4) from station;

--输出人名和职业的 有点问题
select concat(Name,'(',Substring(Occupation,1,1),')') as Name from occupations Order by Name; 
select concat('There are total',' ',count(occupation),' ',lower(occupation),'s.') as total from occupations
group by occupation order by count(occupation);

--round 四舍五入一个整数、 ceil返回最小的整数、floor返回最大的整数
SELECT CEIL(AVG(Salary)-AVG(REPLACE(Salary,'0',''))) FROM EMPLOYEES;

select max(salary*months) from employee group by employee_id;

select (salary * months)as earnings ,count(*) from employee group by 1 order by earnings desc limit 1;

select round(sum(LaT_N),2), round(sum(LONG_W),2) from station;

--avg population in each city
--第二个答案是正确的 join的时候具体是什么join要在MySQL里写清楚
select  C2.continent, round(avg(c1.population))
from CITY C1 join COUNTRY C2 in C1.countrycode=C2.code 
group by c2.continent;

select country.continent, floor(avg(city.population)) from country 
inner join city on city.countrycode = country.code 
GROUP BY country.continent;

--答案2是正确的，难道SQL不接受where连接吗
select sum(city.population) 
from CITY, COUNTRY
WHERE CITY.COUNTRYCODE=COUNTRY.code
WHERE CONTINENT="ASIA";

select sum(city.population) 
from CITY 
inner join COUNTRY
on  CITY.COUNTRYCODE=COUNTRY.code
WHERE CONTINENT="ASIA";
--yes
select city.name
from CITY 
inner join COUNTRY
on  CITY.COUNTRYCODE=COUNTRY.code
WHERE CONTINENT="Africa";
-- case when的情景  需要研究下between的连接大法
select name,  Marks from students
select case when 90<makrs<100 then name end as 10,
select case when 80<makrs<89 then name end as 9,
select case when 70<makrs<79 then name end as 8,
select case when 90<makrs<100 then name end as 10,

SELECT (CASE g.grade>=8 WHEN TRUE THEN s.name ELSE null END),g.grade,s.marks 
FROM students s INNER JOIN grades g ON s.marks BETWEEN min_mark AND max_mark 
ORDER BY g.grade DESC,s.name,s.marks;

SELECT g.grade,s.marks 
FROM students s INNER JOIN grades g ON s.marks BETWEEN min_mark AND max_mark 
ORDER BY g.grade DESC,s.marks;


set @r1=0, @r2=0, @r3=0, @r4=0;
select min(Doctor), min(Professor), min(Singer), min(Actor)
from(
  select case when Occupation='Doctor' then (@r1:=@r1+1)
            when Occupation='Professor' then (@r2:=@r2+1)
            when Occupation='Singer' then (@r3:=@r3+1)
            when Occupation='Actor' then (@r4:=@r4+1) end as RowNumber,
    case when Occupation='Doctor' then Name end as Doctor,
    case when Occupation='Professor' then Name end as Professor,
    case when Occupation='Singer' then Name end as Singer,
    case when Occupation='Actor' then Name end as Actor
  from OCCUPATIONS
  order by Name
) Temp
group by RowNumber；

--画星星题 倒三角
--S1
SELECT REPEAT('* ', @NUMBER := @NUMBER - 1) 
FROM information_schema.tables, (SELECT @NUMBER:=21) t LIMIT 20;
--S2
set @number = 21;
select repeat('* ', @number := @number - 1) from information_schema.tables;

--画星星题 正三角
Set @num=0; 
Select Repeat("* ",@num :=@num+1) from information_schema.tables where @num<20;

select 
(select hacker_id from challenges group by hacker_id having count(challenge_id)>2) as id, hackers.name
from submissions inner join hackers
on submissions.hacker_id=hackers.hacker_id
where score=100;


Select h.hacker_id, h.name 
from hackers  h join challenges c
On h.hacker_id =c.hacker_id
Join difficulty d on d.difficulty_level=c.difficulty_level 
Join submissions S on s.score=d.score
Where s.score=100
group by hacker_id
Having count(challenge_id)>2 
Order by hacker_id desc;







































































