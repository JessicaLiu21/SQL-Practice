/* 
Table1: adv_info: advertiser_id|ad_id|spend(The advertiser pay for this ad

Table2: ad_info: ad_id|user_id|price(The user spend through this ad, assume that all prices in this column > 0)

*/
-- Q1: The fraction of advertiser has at least 1 conversion?
-- sqlserver 
SELECT 
COUNT(DISTINCT advertiser_id)/(SELECT 
COUNT(DISTINCT advertiser_id) FROM adv_Info) AS fraction
FROM adv_info adv
LEFT JOIN ad_info ad
ON adv.ad_id = ad.ad_id 
WHERE ad.price IS NOT NULL;


-- Q2: What metrics would you show to advertisers?
-- We will use the ROI metric to show to advertiser 
SELECT advertiser_id, 
ISNULL((SUM(adv.spend)-SUM(ad.ad_income)) / SUM(ad.ad_income) ,0) AS ROI 
FROM adv_info adv
LEFT JOIN 
(SELECT ad_id, SUM(price) AS ad_income 
FROM ad_info
GROUP BY ad_id) AS ad 
ON adv.ad_id = ad.ad_id 
GROUP BY adv.advertiser_id 

/*
Table: 
Time (Date, Sessionid, time_spent) (Sessionid is THE primary key for the time table)
Session (date, sessionid, userid, action) (action: enter, click, send, exit)
*/

--Q1: Average sessions/user per day within the last 30 days
SELECT Date, COUNT(Sessionid)/COUNT(DISTINCT userid) AS ave_ses
FROM Session
WHERE DATEDIFF(Date, CURDATE()) <= 30
GROUP BY Date;
-- DATEDIFF(Date, CURDATE())
--Q2: # of users who at least spent more than 10s on each session
SELECT COUNT(DISTINCT s.userid) AS num
FROM Session s
LEFT JOIN Time t
ON s.sessionid = t.sessionid
WHERE s.userid NOT IN (SELECT l.userid FROM
			Session l 
			LEFT JOIN Time r
			ON l.sessionid = r.sessionid
			WHERE r.time_spent <= 10);

-- Q3: Time Distribution of users today 
SELECT total_time, COUNT(DISTINCT user_id) AS num
FROM 
(SELECT s.userid, SUM(t.time_spent) AS total_time
FROM Session s
JOIN Time t
ON s.sessionid = t.sessionid AND s.date = t.date
WHERE s.date = CURDATE()
GROUP BY 1) 
GROUP BY 1;

/* Interaction 
Table1: user_action: date|actor_id|post_id|relationship:{'friend','page','group'}|interaction:{'like','comment','wow'}
Table2: user_post: date|poster_id|post_id
*/
-- Q1: # of likes between friends 
SELECT SUM(CASE WHEN interaction = 'like' THEN 1 ELSE 0 END) AS num_of_likes
FROM user_action ua 
WHERE relationship = 'friend'

-- Q2: Ratio of like that user 123 received. 
SELECT IFNULL(SUM(CASE WHEN interaction = 'like' THEN 1 ELSE 0 END)/COUNT(*) ,0) 
AS like_ratio
FROM user_action ua
RIGHT JOIN user_post up
ON ua.post_id = up.post_id
WHERE poster_id = 123

/* Friend 
Table1: connection: user1|user2
Table2: Interaction: sender|receiver|action|date
*/
-- Q1: Find friends who haven't had interactions last year
SELECT DISTINCT l.user1, l.user2
FROM connection l
LEFT JOIN (SELECT sender AS user1, receiver AS user2, action, date
		FROM interaction
		WHERE date BETWEEN '2019-01-01' AND '2019-12-31'
		UNION ALL
		SELECT receiver AS user1, sender AS user2, action, date
		FROM interaction
		WHERE date BETWEEN '2019-01-01' AND '2019-12-31') r
ON l.user1 = r.user1 AND l.user2 = r.user2
WHERE r.action IS NULL;

/*  
● user_actions: date | user_id | post_id | content_type | extra 
● content_type: 'view', 'comment', 'photo', 'report' 
● extra: post text, comment text, report type = {'SPAM', ...} 
*/
-- Q1: Introduce a new table: reviewer_removals,  reviewer_id | post_id 
--please calculate what percent of daily content that users view on FB is actually Spam?
SELECT l.date, SUM(CASE WHEN r.reviewer_id IS NOT NULL 
                    AND l.content_type = ‘view’ THEN 1 ELSE 0 END)/SUM(CASE WHEN 
                                                                    l.content_type = ‘view’ THEN 1 ELSE 0 END) AS percent_spam
FROM user_actions l
LEFT JOIN reviewer_removals r
ON l.post_id = r.post_id
GROUP BY 1;

SELECT view.date, SUM(CASE WHEN remove.post_id IS NOT NULL THEN 1 ELSE 0 END)/ COUNT(*) AS spam_ratio
FROM(
SELECT  view.date, DISTINCT post_id 
FROM user_actions 
WHERE content_type ='view') AS view
LEFT JOIN 
(SELECT post_id 
FROM reviewer_removals ) AS remove
ON view.post_id = remove.post_id
GROUP BY view.date 

-- How to find the user who abuses this spam system?
SELECT l. User_id, 
SUM(CASE WHEN r.reviewer_id IS NOT NULL THEN 1 ELSE 0 END)/SUM(CASE WHEN l.content_type = ‘report’ AND extra = ‘SPAM’ THEN 1 ELSE 0 END) AS precent_spam, SUM(CASE WHEN l.content_type = ‘report’ AND extra = ‘SPAM’ THEN 1 ELSE 0 END) AS reported_num
FROM user_actions l
LEFT JOIN reviewer_removals r
ON l.post_id = r.post_id
GROUP BY 1
ORDER BY 2 DESC 3
LIMIT 1;

SELECT report.user_id, SUM(CASE WHEN 
remove.post_id IS NOT NULL THEN 1 ELSE 0 END)/ COUNT(*) AS report_spam_ratio, 
COUNT( report.post_id) AS real_spam_num 
FROM
(
SELECT DISTINCT view.user_id, post_id 
FROM user_actions 
WHERE content_type ='report'
AND extra =’Spam’) AS report
LEFT JOIN 
(SELECT DISTINCT post_id 
FROM reviewer_removals ) AS remove
ON view.post_id = remove.post_id 
GROUP BY view.user_id
ORDER BY real_spam_num DESC, spam_ration ASC 

/*
表格1 video_calls:   caller| recipient| date| call_id| duration-baidu 1point3acres
表格2 fb_dau:        user_id| DAU_flag| date| country
*/

--Q1: On '2020-01-01' how many people initiate multiple calls? 
SELECT COUNT(caller) FROM
(SELECT caller, COUNT(*) AS call_num
FROM video_calls
WHERE date = ‘2020-01-01’
GROUP BY 1
HAVING call_num > 1);

--Q2: % of DAU used the video calls functions on '2020-01-01' in France?
SELECT date, SUM(CASE WHEN l.user_id IS NOT NULL THEN 1 ELSE 0 END)/COUNT(DISTINCT r.user_id) AS percent_dau
FROM (SELECT caller AS user_id, date
	FROM video_calls 
	UNION ALL 
	SELECT recipient AS user_id, date
	FROM video_calls) as l
RIGHT JOIN (SELECT user_id
FROM fb_dau
WHERE DAU_flag = 1 AND country = ‘France’) r
ON l.user_id = r.user_id AND l.date = r.date
GROUP BY 1;

/*
Table: date | time | sender_id | receiver_id
*/
-- Q: What's the fraction of unique users who have over 5 friend?
CREATE VIEW temp 
AS 
SELECT DISTINCT sender_id, receiver_id 
FROM Table 

SELECT SUM( CASE WHEN num_friend>5 THEN 1 ELSE 0 END) / COUNT(*)
FROM 
(
SELECT id1, COUNT(*) AS num_friend 
FROM (
SELECT sender_id AS id1, receiver_id id2
FROM temp
UNION ALL 
SELECT  receiver_id AS id1, sender_id id2 
FROM temp ) AS t1
GROUP BY id1 
) AS t2 

-- Q:求fraction: 有多少信息在1分钟内回复
SELECT date, sender_id, receiver_id 
FROM Table t2 
GROUP BY date, sender_id, receiver_id 
ORDER BY date, time 

SELECT DISTINCT t1.sender_id
FROM table t1
JOIN table t2
ON t1.sender_id = t2.receiver_id AND t1.receiver_id = t2.sender_id
WHERE t2.timestamp - t1.timestamp <= 60;

/*Adaccount: account_id | date | status:{'active','closed','fraud'}
*/
-- Q1: What percent of active accounts are fraud?
SELECT SUM( CASE WHEN r.account_id IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*) 
AS percent_fraud_to_active 
FROM 
(
SELECT DISTINCT account_id 
FROM adaccount 
WHERE status = ‘active’ ) l 
LEFT JOIN 
(
SELECT DISTINCT account_id 
FROM adaccount 
WHERE status = ‘fraud’ ) r
ON l.account_id = r.account_id 

-- Q2: How many accounts become fraud today for the first time?
SELECT COUNT(account_id ) 
FROM (
SELECT account_id, MIN (date) AS first_date, MAX(date) AS lastest_date 
FROM adacount 
WHERE status = ‘fraud’
GROUP BY account_id ) AS temp 
WHERE first_date = lastest_date 
AND first_date = CURDATE()

CREATE VIEW fraud_account AS
SELECT account_id, ds 
FROM fraud
WHERE statuss = 'fraud';

SELECT COUNT(account_id) FROM
(SELECT account_id, MIN(ds) AS min_date
FROM fraud_account
GROUP BY account_id
HAVING min_date = CURDATE()) temp;

/* Spotify
Table1: time|user_id|song_id|
Table2: user_id1|user_id2
*/
-- Q: 寻找一个list有user_id1和|user_id2 :有多于两首共同听过的的user list pair 
SELECT DISTINCT user_id1, user_id2
FROM
(SELECT user_id1, user_id2, u1, s1, t3.user_id AS u2, t3.song_id AS s2 
FROM 
(SELECT user_id1, user_id2, t1.user_id AS u1, song_id AS s1
FROM table1 t1 
JOIN table t2 
ON t1.user_id = t2.user_id1 ) AS temp
JOIN table1 t3
ON temp.user_id2 = t3.user_id )  AS temp2 
WHERE temp2.u1 IS NOT NULL AND temp2.u2 IS NOT NULL 
AND  temp2.s1 =  temp2.s2 
GROUP BY  temp2.user_id1,  temp2.user_id2
HAVING DISTINCT ( temp2.s1) > 2 

SELECT l.user_id1, l.user_id2
FROM table2 l
JOIN table1 r1
ON l.user_id1 = r1.user_id
JOIN table1 r2
ON l.user_id2 = r2.user_id
WHERE r1.song_id = r2.song_id
GROUP BY l.user_id1, l.user_id2
HAVING COUNT(DISTINCT r1.song_id) > 2;
