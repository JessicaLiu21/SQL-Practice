USE flight
create table movie(mID int,title varchar(50),year int,director varchar(50));
insert into movie values(101,'Gone with the Wind',1939,'Victor Fleming');
insert into movie values(102,'Star Wars',1977,'George Lucas');
insert into movie values(103,'The Sound of Music',1965,'Robert Wise');
insert into movie values(104,'E.T.',1982,'Steve Spielberg');
insert into movie values(105,'Titanic',1997,'James Cameron');
insert into movie values(106,'Snow White',1937,'<null>');
insert into movie values(107,'Avatar',2009,'James Cameron');
insert into movie values(108,'Raiders of the Lost Ark',1981,'Steven Spielberg');
create table reviewer(rID int, name varchar(50));
insert into reviewer values(201,'Sarah Martinez');
insert into reviewer values(202,'Daniel Lewis');
insert into reviewer values(203,'Brittany Harris');
insert into reviewer values(204,'Mike Anderson');
insert into reviewer values(205,'Chris Jackson');
insert into reviewer values(206,'Elizabeth Thomas');
insert into reviewer values(207,'James Cameron');
insert into reviewer values(208,'Ashley White');
create table rating(rID int,mID int,stars int,ratingDate varchar(50));
insert into rating values(201,101,2,'2011-01-22');
insert into rating values(201,101,4,'2011-01-27');
insert into rating values(202,106,4,'null');
insert into rating values(203,103,2,'2011-01-20');
insert into rating values(203,108,4,'2011-01-12');
insert into rating values(203,108,2,'2011-01-30');
insert into rating values(204,101,3,'2011-01-09');
insert into rating values(205,103,3,'2011-01-27');
insert into rating values(205,104,2,'2011-01-22');
insert into rating values(205,108,4,'null');
insert into rating values(206,107,3,'2011-01-15');
insert into rating values(206,106,5,'2011-01-19');
insert into rating values(207,107,5,'2011-01-20');
insert into rating values(208,104,3,'2011-01-02');
.headers on
.mode col
SELECT * FROM movie
SELECT * FROM rating
SELECT * FROM reviewer
--** core set
select title from movie where director='Steven Spielberg';
--Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order.
 
select year from movie where mID in (select distinct mID from rating where stars=4 or stars=5)
order by year;

select distinct year from movie 
join rating on movie.mID=rating.mID 
where rating.stars=4 or rating.stars=5
order by year;
--Find the titles of all movies that have no ratings. 

--this is wrong--select title from movie join rating on movie.mID=rating.mID where ratingDate="null";
select title from movie where mID not in (select mID from rating);
--Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. 
select name from reviewer join rating on reviewer.rID=rating.rID
where ratingDate="null";
--Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. 
CREATE VIEW NEW(reviewer_name, movie_title, stars,ratingDate)
AS
select name,title,stars,ratingDate 
from movie,reviewer,rating where movie.mID=rating.mID and reviewer.rID=rating.rID
order by name,title,stars;
--???怎么组个新表啊 并且命名
--For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time,
-- return the reviewer's name and the title of the movie. 
SELECT distinct name, title 
from reviewer
join rating r1 on reviewer.rID=r1.rID
join movie on r1.mID=movie.mID
join rating r2 
on r1.rID=r2.rID  and r1.mID=r2.mID
where r1.stars>r2.stars and r1.ratingDate>r2.ratingDate
--正确

select reviewer.name,movie.title
from (select R1.rID, R1.mID from rating R1 join rating R2 on R1.rID=R2.rID 
	 where R1.mID=R2.mID and R1.stars>R2.stars and R1.ratingDate>R2.ratingDate) as S,reviewer,movie
where S.rID=reviewer.rID
and movie.mID=S.mID;
--错误
select R2.rID
from movie, reviewer, rating R1, rating R2
where movie.mID=R1.mID and R1.rID=R2.rID and R2.rID=reviewer.rID 
and R2.stars>R1.stars;
--For each movie that has at least one rating, find the highest number of stars that movie received. 
--Return the movie title and number of stars. Sort by movie title. 

select movie.title, S.stars
from movie, (select R2.stars, R2.mID from rating R1 join rating R2 on R1.mID=R2.mID where R2.stars>R1.stars) as S
where movie.mID=S.mID 
group by title;
--List movie titles and average ratings, from highest-rated to lowest-rated. 
--If two or more movies have the same average rating, list them in alphabetical order.
select movie.title,avg(stars) as A
from movie,rating
where movie.mID=rating.mID 
group by movie.title
order by A desc,movie.title;
--Find the names of all reviewers who have contributed three or more ratings. 
--(As an extra challenge, try writing the query without HAVING or without COUNT.) 
--wrong
select reviewer.name
from reviewer,rating 
where reviewer.rID=rating.rID and count(rating.rID)>3;
--right/ but need rethink 
select name from Reviewer where rID in (
select rID from (
select rID, count(mID) as cnt
from rating
group by rID
having cnt > 2) as t);

--**movie-rating challeging level 
--1.For each movie, return the title and the 'rating spread',
-- that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. 
select movie.title, max(rating.stars)-min(rating.stars) as RS 
from rating, movie 
where rating.mID=movie.mID
group by rating.mID
order by RS desc,movie.title;
--select 里面有聚合函数的时候一定要group by 
select title, max(stars)-min(stars) as spread
from rating join movie using (mid)
group by mid
order by spread desc, title
--2.Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. 
--(Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. 
--Don't just calculate the overall average rating before and after 1980.) 
select 
(select avg(A1) from (select avg(rating.stars) as A1 from movie join rating on movie.mID=rating.mID group by mID where year>1980))-
(select avg(A2) from (select avg(rating.stars) as A2 from movie join rating on movie.mID=rating.mID group by mID where year<1980));
--need rethinking 
--正确的
select (select avg(av)
        from (select mid, year, avg(stars) as av 
              from rating join movie using(mid) 
              group by mid) 
        where year<1980) 
     - (select avg(av)
        from (select mid, year, avg(stars) as av 
              from rating join movie using(mid) 
              group by mid) 
        where year>1980);
--3.Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. 
--Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) 
select m.title,m.director
from movie as m
where mID in 
(select mID from movie group by director having count(mID) >1)
order by m.director,m.title;
---
select m.title,m.director
from movie as m
where director in 
(select director from movie group by director having count(mID) >1)
order by m.director,m.title;
--反思：where后面跟的东西必须要是select里面的吗？？？ 不是，这个题还要在想想
select m.title,m.director
from movie as m 
group by m.director 
having count(m.mID) >2;
order by m.director,m.title;
--分析，首先大于2是错的 
--正确；
select title, director 
from movie 
where director in (select director 
                  from (select director, count(title) as s 
                        from movie 
                        group by director) as t
                  where t.s>1)
order by 2,1;
--正确 yes/yes/yes/yes 
select director,title
from movie  as m 
where director in (select director from movie group by director having count(mID)>1)
order by director,title;
--------------------------------------------------
select title, director 
from movie 
group by director 
having count(title)>1;
--结果有一个答案，为啥不可以不嵌套？不嵌套的时候为啥只有一个结果？--貌似又是group by的原则，select后面的选项必须是group by后面有的。

--4.Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. 
--(Hint: This query is more difficult to write in SQLite than other systems;
--正确的 自己写的
select title, max
from movie join 
(select mID, max(A1) as max from 
(select mID, avg(stars) as A1 from rating group by mID)) B 
on movie.mID=B.mID;
--正确的 别人写的（回头需要看一下）
select m.title, avg(r.stars) as strs from rating r
join movie m on m.mid = r.mid group by r.mid
having strs = (select max(s.stars) as stars from (select mid, avg(stars) as stars from rating
group by mid) as s)
-- you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) 

--5.Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
-- (Hint: This query may be more difficult to write in SQLite than other systems; 
--you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) 
--正确的，自己写的
select title, min
from movie join 
(select mID, min(A1) as min from 
(select mID, avg(stars) as A1 from rating group by mID)) B 
on movie.mID=B.mID;
--正确的，别人写的
select m.title, avg(r.stars) as strs from rating r
join movie m on m.mid = r.mid group by r.mid
having strs = (select min(s.stars) as stars from (select mid, avg(stars) as stars from rating
group by mid) as s)；
--6.For each director, return the director's name together with the title(s) of the movie(s) they directed 
--that received the highest rating among all of their movies, 
--and the value of that rating. Ignore movies whose director is NULL. 
select M.director, M.title, Star
from movie M join
(select mID, max(stars) as Star from rating group by mID) as R 
on M.mID=R.mID
order by star desc;

--需要这种最大最小值筛选的时候可以考虑join一个新的自己定义的表，把最大最小放在select后面时候，其实也相当于自动筛选了

--**movie-rating extra practice 
--1\Find the names of all reviewers who rated Gone with the Wind. 
--自己写的，正确
select distinct name from rating join reviewer 
on rating.rid=reviewer.rid
where rating.mid in 
(select mid from movie where movie.title="Gone with the Wind");
--别人写的，正确
select distinct name
from Reviewer join Rating using(rID)
where rID in (
select rID
from Rating join Movie using(mID)
where title = "Gone with the Wind")；
--2\For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. 
--不正确，有重要错误
select distinct reviewer.name,movie.director,movie.title,rating.stars
from reviewer inner join movie 
on  reviewer.name=movie.director 
inner join rating 
on movie.mID=rating.mID;
--name           director       title       stars     
-------------  -------------  ----------  ----------
--James Cameron  James Cameron  Avatar      3         
--James Cameron  James Cameron  Avatar      5    
--这样输出的结果是错的原因是rating里面的rID没有被唯一识别，先把相同的名字匹配后，在rating里面只有mID唯一识别，所以分别和107的分数匹配了两次
--所以这种题第一步先把各个表之间的连接唯一识别好后，再加条件
--正确
SELECT name, title, stars
FROM Movie
INNER JOIN Rating USING(mId)
INNER JOIN Reviewer USING(rId)
WHERE director = name;

--3\Return all reviewer names and movie names together in a single list, alphabetized.
-- (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) 
--错误，没有想起来用union
select distinct reviewer.name, movie.director
from movie outer join rating on movie.mID=rating.mID
join reviewer on rating.rID=reviewer.rID;

SELECT title FROM Movie
UNION
SELECT name FROM Reviewer
ORDER BY name, title;
--union操作符用于合并两个或多个select语句的结果集、union内部的select语句必须拥有相同数量的列，列必须有相似的数据类型
--默认的union的操作符选取不同的值，如果允许重复的值，使用union all
--4\Find the titles of all movies not reviewed by Chris Jackson. 
--错误，需要rethink
select distinct title 
FROM Movie
JOIN Rating USING(mId)
JOIN Reviewer USING(rId)
where reviewer.rID
not in (select rID from reviewer where name="Chris Jackson");
--因为他的顺序是显示from然后之后是where,所以按照这样的理解 from之后是join的整体的一个表，之后再选，所以这样范围就算是比较大的

select title 
from movie 
where mID not IN 
(SELECT mID FROM  Rating inner join reviewer using(rID) where name="Chris Jackson")
--5\For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. 
--Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. 
select distinct name 
from reviewer
where reviewer.rID in 
(select R1.rID, R1.mID from rating R1 join rating R2)
on R1.mID=R2.mID
group by R1.mID 
where R1.rID>R2.rID or R1.rID<R2.rID);

--别人 正确
SELECT DISTINCT Re1.name, Re2.name
FROM Rating R1, Rating R2, Reviewer Re1, Reviewer Re2
WHERE R1.mID = R2.mID
AND R1.rID = Re1.rID
AND R2.rID = Re2.rID
AND Re1.name > Re2.name
ORDER BY Re1.name, Re2.name;
--不等于也可以用小于号或者大于号表示，但是这里的小于大于号是什么含义
--6\For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. 
--正确
select movie.title,rating.stars,reviewer.name
from movie, rating, reviewer
where movie.mID=rating.mID
and rating.rID=reviewer.rID 
and rating.stars in 
(select min(stars) from rating);
--别人写的 正确
--git hub看的 补充
--7. List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. 
-- 8. Find the names of all reviewers who have contributed three or more ratings.
-- At least 3 ratings to different movies (Remainder to myself)
-- 9. Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title.
-- 10. Find the movie(s) with the highest average rating. Return the movie title(s) and average rating.
-- 11. Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating.
-- 12. For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. 
--**movie-rating modification exercises 
-- 1. Add the reviewer Roger Ebert to your database, with an rID of 209.
insert into reviewer values ( 209, "Roger Ebert");
-- 2. Insert 5-star ratings by James Cameron for all movies in the database. Leave the review date as NULL.
insert into rating 
select (select rID from Reviewer where name="James Cameron"), mID,5, null
from movie;
--？？为什么可以这么插
-- 3. For all movies that have an average rating of 4 stars or higher, add 25 to the release year.
-- (Update the existing tuples; don't insert new tuples.)
--自己的
update movie 
set year=year+25
where movie.mID in (select rating.mID from rating where rating.stars>=4);
--忽略了avaerage的条件
update movie 
set year=year+25
where movie.mID in (select rating.mID from rating group by rating.mID having avg(rating.stars)>=4);
--别人的 
UPDATE Movie
SET year = year + 25
WHERE mId IN (
  SELECT mId
  FROM Movie
  INNER JOIN Rating USING(mId)
  GROUP BY mId
  HAVING AVG(stars) >= 4
);
--正不正确需要单独执行以下 正确的

-- 4. Remove all ratings where the movie's year is before 1970 or after 2000, and the rating is fewer than 4 stars.
--**social-network core set
--**social-network challenge level 
--**social-network extra practice 
--**social-network modification exercises 
































