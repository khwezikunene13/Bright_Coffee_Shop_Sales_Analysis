-----------------------------------------------------------------------------------------------------------
--1. Data Inspection & Exploratory Data Analysis
------------------------------------------------------------------------------------------------------------

-- 1.1 Sample of all the available columns and types of data 
------------------------------------------------------------------------------
select * 
from bright_coffee_shop_analysis_case_study_1
limit 10;

--1.2 How many rows of data in our table
------------------------------------------------------------------------------
select count(*) AS number_of_rows,
       count(distinct transaction_id) AS number_of_sales
from bright_coffee_shop_analysis_case_study_1;

--we have 149116 rows of data. It looks like each row is a new transaction, we have 149116 number of sales--

-- 1.3  What is the range of the analysis period of our  data
------------------------------------------------------------------------------
select min(transaction_date) AS Start_Date,
       max (transaction_date) AS End_Date 
from bright_coffee_shop_analysis_case_study_1;
--The available data is for a period of 6 months, from January 2023 to June 2023

-- 1.4  Lets see all our Store location
------------------------------------------------------------------------------
select distinct store_location
from bright_coffee_shop_analysis_case_study_1;
--we have three stores. Namely, Lower Manhattan, Hell's Kitchen and Astoria

-- 1.5 Lets get familiar with our products
------------------------------------------------------------------------------
select distinct product_category
from bright_coffee_shop_analysis_case_study_1;

select distinct product_type
from bright_coffee_shop_analysis_case_study_1;

select distinct product_detail
from bright_coffee_shop_analysis_case_study_1;

select count(distinct product_detail) AS number_of_products,
       count(distinct product_category) AS number_of_categories,
       count(distinct product_type) AS number_of_type
from bright_coffee_shop_analysis_case_study_1;

--We have 80 different products, grouped in 29 different kinds of products (e.g. kind of tea), that are categorised into 9 groups

--1.6 Lets rank all our products by price. Allows us to see what is the most expensive and the cheapeast item
--------------------------------------------------------------------------------------------------------------------

select distinct product_detail AS product_name,
product_category,
product_type,
unit_price
from bright_coffee_shop_analysis_case_study_1
order by unit_price desc;
--Our most expensive item is called Civet Cat (R45), which is a premium coffee bean. The cheapest item is a chocolate syrup (R0.80), which is just a flavour

select min(unit_price) AS cheapest_item,
max(unit_price) AS expensive_item
from brightcoffee_shop_sales;

-----------------------------------------------------------------------------------------------------------
----2. Feature Engineering 
------------------------------------------------------------------------------------------------------------

--2.1 How much revenue did we generate per day and how many sales per day --
------------------------------------------------------------------------------------
select 
      transaction_date,
       dayname(transaction_date)AS day_name,
       monthname(transaction_date) AS month_name,
       dayofmonth(transaction_date) AS day_of_month,
       sum(transaction_qty*unit_price) AS revenue_per_day,
       count(distinct transaction_id) AS sales_per_day,
       sum(transaction_qty) AS quantity_sold_per_day
from bright_coffee_shop_analysis_case_study_1
group by transaction_date;


--2.2 Include the purchase time (we will have to run our data per transaction again)--
------------------------------------------------------------------------------------
select transaction_date,
       dayname(transaction_date)AS day_name,
       monthname(transaction_date) AS month_name,
       dayofmonth(transaction_date) AS day_of_month,
       sum(transaction_qty*unit_price) AS revenue_per_trnx,
       count(distinct transaction_id) AS sales_per_trnx,
       date_format(transaction_time, 'HH:mm:ss' ) AS purchase_time
from bright_coffee_shop_analysis_case_study_1
group by transaction_date,
         date_format(transaction_time, 'HH:mm:ss' );

--2.3 Okay, lets add our categorical columns and other columns we want, let me go step by step
--------------------------------------------------------------------------------------------
select 
------Time related features and columns
      transaction_date,
      dayname(transaction_date)AS day_name,
      monthname(transaction_date) AS month_name,
      dayofmonth(transaction_date) AS day_of_month,
      count(distinct transaction_id) AS sales_per_trnx,
      date_format(transaction_time, 'HH:mm:ss' ) AS purchase_time,
-------Categorical Columns
      store_location,
      product_category,
      product_detail AS product_name,
------Revenue and quantity sold
      sum(transaction_qty*unit_price) AS revenue,
      sum(transaction_qty) AS quantity_sold
from bright_coffee_shop_analysis_case_study_1
group by transaction_date,
         date_format(transaction_time, 'HH:mm:ss'),
         store_location,
         product_category,
         product_detail;

--Lets Input the time segments (Yoh, Lord be with me!!!)----
--okay but first, lets see what is earliest and latest time. To make proper segments
----------------------------------------------------------------------------------------
select min (date_format(transaction_time,'HH:mm:ss')) AS Earliest_purchase,
max (date_format(transaction_time,'HH:mm:ss')) AS latest_purchase
from bright_coffee_shop_analysis_case_study_1;
---Our earliest transaction is at 6am and the lastest at 9pm. 

select min(transaction_qty*unit_price) as lowest_spend,
        max(transaction_qty*unit_price) as Highest_spend
from bright_coffee_shop_analysis_case_study_1;
--most expensive product costs R0.80 and the most expensive costs R360.00

-------------------------------------------------------------------------------------------------------------------------
--Final Script 
----------------------------------------------------------------------------------------------------------------------------
select
------Time related features and columns
      transaction_date,
      dayname(transaction_date)AS day_name,
      monthname(transaction_date) AS month_name,
      dayofmonth(transaction_date) AS day_of_month,
-----Daily Time segments
case 
     when date_format(transaction_time, 'HH:mm:ss') between '06:00:00' and '10:29:59' then 'morning rush'
     when date_format(transaction_time, 'HH:mm:ss') between '10:30:00' and '11:59:59' then 'mid-morning'
     when date_format(transaction_time, 'HH:mm:ss') between '12:00:00' and '14:29:59' then 'lunch time rush'
     when date_format(transaction_time, 'HH:mm:ss') between '14:30:00' and '16:29:59' then 'Afternoon'
     when date_format(transaction_time, 'HH:mm:ss') between '16:30:00' and '18:59:59' then 'Home Time'
     when date_format(transaction_time, 'HH:mm:ss') >= '19:00:00' then 'evening'
     end as time_segments,
-----Weekend classification
case 
      when dayname(transaction_date) in ('Sat','Sun') then 'weekend'
      else 'weekday'
end as day_classification,
-------Categorical Columns
      store_location,
      product_category,
      product_detail AS product_name,
      unit_price,
------Revenue and quantity sold
      sum(transaction_qty*unit_price) AS revenue,
case
      when (transaction_qty*unit_price) <=50 then 'low spend'
      when (transaction_qty*unit_price) between 51 and 100 then 'med spend'
      else 'high spend'
end as spend_segment,
      sum(transaction_qty) AS quantity_sold,
      count(distinct transaction_id) AS number_of_sales
from bright_coffee_shop_analysis_case_study_1
group by transaction_date,
         store_location,
         product_category,
         product_detail,
         unit_price,
         transaction_qty,
      case 
            when date_format(transaction_time, 'HH:mm:ss') between '06:00:00' and '10:29:59' then 'morning rush'
            when date_format(transaction_time, 'HH:mm:ss') between '10:30:00' and '11:59:59' then 'mid-morning'
            when date_format(transaction_time, 'HH:mm:ss') between '12:00:00' and '14:29:59' then 'lunch time rush'
            when date_format(transaction_time, 'HH:mm:ss') between '14:30:00' and '16:29:59' then 'Afternoon'
            when date_format(transaction_time, 'HH:mm:ss') between '16:30:00' and '18:59:59' then 'Home Time'
            when date_format(transaction_time, 'HH:mm:ss') >= '19:00:00' then 'evening'
      end,
      case 
            when dayname(transaction_date) in ('Sat','Sun') then 'weekend'
            else 'weekday'
      end,
      case
            when (transaction_qty*unit_price) <=50 then 'low spend'
            when (transaction_qty*unit_price) between 51 and 100 then 'med spend'
            else 'high spend'
      end;
