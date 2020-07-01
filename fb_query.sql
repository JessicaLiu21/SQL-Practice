/* 
Table1: adv_info: advertiser_id|ad_id|spend(The advertiser pay for this ad

Table2: ad_info: ad_id|user_id|price(The user spend through this ad, assume that all prices in this column > 0)

*/
Q1: The fraction of advertiser has at least 1 conversion?
-- sqlserver 
SELECT ISNULL( SUM(CASE WHEN ad.price IS NOT NULL THEN 1 ELSE 0 END)/COUNT(*) ,0) AS fraction  
COUNT(DISTINCT advertiser_id)/(SELECT COUNT(DISTINCT advertiser_id) FROM adv_Info) AS fraction
FROM adv_info adv
LEFT JOIN ad_info ad
ON adv.ad_id = ad.ad_id 
WHERE ad.price IS NOT NULL;


Q2: What metrics would you show to advertisers?

SELECT advertiser_id, ISNULL((SUM(adv.spend)-SUM(ad.ad_income)) / SUM(ad.ad_income) ,0) AS ROI 
FROM adv_info adv
LEFT JOIN 
(SELECT ad_id, SUM(price) AS ad_income 
FROM ad_info
GROUP BY ad_id) AS ad 
ON adv.ad_id = ad.ad_id 
GROUP BY advertiser_id 

