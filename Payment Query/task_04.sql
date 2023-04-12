-- CORRECT HOMEWORK 4: SUBQUERY - GROUP BY - CTE 

/* Task 1: Retrieve an overview report of payment types
1.1.	Paytm has a wide variety of transaction types in its business. 
Your manager wants to know the contribution (by percentage) of each transaction type to total transactions. 
Retrieve a report that includes the following information: transaction type, 
number of transaction and proportion of each type in total. 
These transactions must meet the following conditions: 
•	Were created in 2019 
•	Were paid successfully
Show only the results of the top 5 types with the highest percentage of the total. */ 

-- Your code here
-- b1: JOIN 3 tables: fact_transaction_2019, dim_scenario, status --> LEFT JOIN từ fact và lấy success, và lấy trans type 
-- b2: Gom nhóm theo transaction type -> tính số giao dịch --> GROUP BY , COUNT (transaction_id)
-- b3: Tính tổng số giao dịch success của 2019 --> SUBQUERY để đếm số giao dịch 2019 
-- b4: Tỉnh tỉ trọng = b1/b2 
-- b5: Chọn top 5 cao nhất --> SELECT TOP 5 , ORDER BY ... 

WITH joined_table AS ( -- b1
SELECT fact_19.*, transaction_type
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
    ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS stat 
    ON fact_19.status_id = stat.status_id
WHERE status_description = 'success' 
)
, total_table AS (
SELECT transaction_type -- group by cái gì select cái đó
    , COUNT(transaction_id) AS number_trans
    , (SELECT COUNT(transaction_id) FROM joined_table) AS total_trans -- subquery lấy ra total trans
FROM joined_table
GROUP BY transaction_type
)
SELECT TOP 5 
    *
    , FORMAT ( number_trans*1.0/total_trans, 'p') AS pct  --> SQL trả ra INT, 0.4732
FROM total_table
ORDER BY number_trans DESC 


/* 1.2.	After your manager looks at the results of these top 5 types, 
he wants to deep dive more to gain more insights. 
Retrieve a more detailed report with following information: transaction type, category, 
number of transaction and proportion of each category in the total of that transaction type.
These transactions must meet the following conditions: 
•	Were created in 2019 
•	Were paid successfully */ 

-- Your code here
-- b1: JOIN fact19 , scenario, status --> success, lấy trans type và category 
-- b2: Group by theo type, category để tìm mỗi category có bao nhiêu trans 
-- b3: Group by theo type để tìm mỗi type có bao nhiêu trans 
-- b4: JOIN 2 kết quả trên lại : key: transaction_type 
-- b5: tính pct 

WITH join_table AS ( -- b1
SELECT fact_19.*, transaction_type, category
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
    ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS stat 
    ON fact_19.status_id = stat.status_id
WHERE status_description = 'success' 
)
, count_category AS ( -- b2
SELECT transaction_type, category
    , COUNT(transaction_id) AS number_trans_category
FROM join_table 
GROUP BY transaction_type, category
) 
, count_type AS ( -- b3
SELECT transaction_type
    , COUNT(transaction_id) AS number_trans_type
FROM join_table 
GROUP BY transaction_type
)
SELECT count_category.*, number_trans_type -- b4
    , FORMAT( number_trans_category*1.0/number_trans_type, 'p') AS pct -- varchar : chuỗi 
FROM count_category 
FULL JOIN count_type 
ON count_category.transaction_type = count_type.transaction_type
WHERE number_trans_type IS NOT NULL AND number_trans_category IS NOT NULL 
ORDER BY number_trans_category*1.0/number_trans_type DESC
-- ORDER BY pct DESC


/* Task 2: Retrieve an overview report of customer’s payment behaviors
2.1. Paytm has acquired a lot of customers. 
Retrieve a report that includes the following information: the number of transactions, 
the number of payment scenarios, the number of transaction types, 
the number of payment category and the total of charged amount of each customer.

•	Were created in 2019
•	Had status description is successful
•	Had transaction type is payment
•	Only show Top 10 highest customers by the number of transactions */

-- Your code here
-- b1: Join tables và Đặt điều kiện status và type 
-- b2: group by customer_id --> COUNT và SUM để tính các chỉ số

SELECT 
    -- TOP 10 
    customer_id
    , COUNT(transaction_id) AS number_trans
    , COUNT(DISTINCT fact_19.scenario_id) AS number_scenarios -- đếm k trùng là COUNT (DISTINCT column)
    , COUNT(DISTINCT scena.category) AS number_categories
    , SUM(charged_amount*1.0) AS total_amount
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id -- gom nhóm 
ORDER BY number_trans DESC
-- 20,020 khách hàng 

/* 2.2.	After looking at the above metrics of customer’s payment behaviors, 
we want to analyze the distribution of each metric. Before calculating and plotting the distribution 
to check the frequency of values in each metric, we need to group the observations into range.
2.2.1.	 How can we group the observations in the most logical way? Binning is useful 
to help us deal with problem. To use binning method, we need to determine how many bins for 
each distribution of each field.
Retrieve a report that includes the following columns: metric, minimum value, maximum value 
and average value of these metrics:

•	The total charged amount
•	The number of transactions
•	The number of payment scenarios
•	The number of payment categories  */ 

-- The number of transactions

WITH summary_table AS (
SELECT customer_id
    , COUNT(transaction_id) AS number_trans
    , COUNT(DISTINCT fact_19.scenario_id) AS number_scenarios
    , COUNT(DISTINCT scena.category) AS number_categories
    , SUM(charged_amount) AS total_amount
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT 'The number of transaction' AS metric -- k quen làm cái , 
    , MIN(number_trans) AS min_value
    , MAX(number_trans) AS max_value
    , AVG(number_trans) AS avg_value
FROM summary_table
UNION 
SELECT 'The number of scenarios' AS metric
    , MIN(number_scenarios) AS min_value
    , MAX(number_scenarios) AS max_value
    , AVG(number_scenarios) AS avg_value
FROM summary_table
UNION 
SELECT 'The number of categories' AS metric
    , MIN(number_categories) AS min_value
    , MAX(number_categories) AS max_value
    , AVG(number_categories) AS avg_value
FROM summary_table
UNION 
SELECT 'The total charged amount' AS metric
    , MIN(total_amount) AS min_value
    , MAX(total_amount) AS max_value
    , AVG(1.0*total_amount) AS avg_value
FROM summary_table


/* Bin the total charged amount and number of transactions then calculate the frequency of each field in each metric

Metric 3: The total charged amount */ 

WITH summary_table AS (
SELECT customer_id
    , SUM(charged_amount) AS total_amount
    , CASE
        WHEN SUM(charged_amount) < 1000000 THEN '0-01M'
        WHEN SUM(charged_amount) < 2000000 THEN '01M-02M'
        WHEN SUM(charged_amount) < 3000000 THEN '02M-03M'
        WHEN SUM(charged_amount) < 4000000 THEN '03M-04M'
        WHEN SUM(charged_amount) < 5000000 THEN '04M-05M'
        WHEN SUM(charged_amount) < 6000000 THEN '05M-06M'
        WHEN SUM(charged_amount) < 7000000 THEN '06M-07M'
        WHEN SUM(charged_amount) < 8000000 THEN '07M-08M'
        WHEN SUM(charged_amount) < 9000000 THEN '08M-09M'
        WHEN SUM(charged_amount) < 10000000 THEN '09M-10M'
        WHEN SUM(charged_amount) >= 10000000 THEN 'more > 10M'
        END AS charged_amount_range
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT charged_amount_range
    , COUNT(customer_id) AS number_customers
FROM summary_table
GROUP BY charged_amount_range 
ORDER BY charged_amount_range

-- Metric 1: The number of payment categories */ 
WITH summary_table AS (
SELECT customer_id
    , COUNT(DISTINCT scena.category) AS number_categories
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id -- 
)
SELECT number_categories
    , COUNT(customer_id) AS number_customers
FROM summary_table
GROUP BY number_categories 
ORDER BY number_categories

-- Metric 2: The number of payment scenarios
WITH summary_table AS (
SELECT customer_id
    , COUNT(DISTINCT fact_19.scenario_id) AS number_scenarios
FROM fact_transaction_2019 AS fact_19
LEFT JOIN dim_scenario AS scena 
        ON fact_19.scenario_id = scena.scenario_id
LEFT JOIN dim_status AS sta 
        ON fact_19.status_id = sta.status_id 
WHERE status_description = 'success'
    AND transaction_type = 'payment'
GROUP BY customer_id
)
SELECT number_scenarios
    , COUNT(customer_id) AS number_customers
FROM summary_table
GROUP BY number_scenarios 
ORDER BY number_scenarios



