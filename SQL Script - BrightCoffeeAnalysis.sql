----------------------------------------------------------------
--Data Inspection & Exploratory Data Analysis
----------------------------------------------------------------

-- 1.1 Sample of all the available columns and types of data 
-----------------------------------------------------------------------------------

select * 
from bright_coffee_shop_analysis_case_study_1
limit 10;

--1.2 How many rows of data in our table
-----------------------------------------------------------------------------------
select count(*) AS number_of_rows,
count( distinct transaction_id) AS number_of_sales
from bright_coffee_shop_analysis_case_study_1


select min(transaction_date) AS Start_Date,
      max (transaction_date) AS End_Date 
from bright_coffee_shop_analysis_case_study_1;
--The available data is for a period of 6 months, from January 2023 to June 2023

-- 3.  Lets see all our Store location
--------------------------------------------------------------------------------------
select distinct store_location
from bright_coffee_shop_analysis_case_study_1;
--we have three stores. Namely, Lower Manhattan, Hell's Kitchen and Astoria

-- 4 Lets get familiar with our products --
-----------------------------------------------------------------------------------------
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

--4.1 Lets rank all our products by price. Allows us to see what is the most expensive and the cheapeast item
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
