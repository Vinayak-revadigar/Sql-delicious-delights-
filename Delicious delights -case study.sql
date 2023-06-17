
/*  "Delicious Delights: Unleashing the Power of Data in Online Food Delivery"

Objective: The objective of this case study is to analyze the data from an online food delivery app
to gain insights into customer behavior, restaurant performance, and revenue growth. 
We aim to answer various questions related to customer orders, restaurant popularity, revenue growth,
customer preferences, and more.

Schema Design: The database schema consists of the following tables:

1)users$: Contains information about app users.
2)delivery_partner$: Stores details of delivery partners.
3)food$: Holds information about different food items.
4)menu$: Represents the menu items available in restaurants.
5)restaurants$: Contains information about restaurants.
6)orders$: Stores details of customer orders.
7)order_details$: Holds information about individual food items in each order.

In this project, we begin by cleaning the data, treating null values, and modifying the data types wherever required. 
We then proceed to explore the data by querying the tables and answering specific questions.

The questions addressed in this case study are as follows:

1)Finding customers who have never ordered.
2)Calculating the average price per dish.
3)Identifying the top restaurant in terms of the number of orders.
4)Finding the top restaurant in terms of the number of orders in a given month.
5)Identifying restaurants with monthly sales greater than 500 in June.
6)Showing all orders with order details for a particular customer within a specific date range.
7)Finding restaurants with the maximum number of repeated customers.
8)Analyzing month-over-month revenue growth for the platform.
9)Determining customer names and their favorite food items.

Throughout the project, SQL queries are used to extract relevant information from the database.
The results are presented in a clear and concise manner, providing insights into customer behavior,
restaurant performance, revenue growth, and customer preferences.

Overall, this project showcases the power of data analysis in the online food delivery 
industry and highlights the potential insights that can be gained from analyzing customer and restaurant data.
*/
use Food_delievery
select*from order_details$
select*from orders$

--treating null values---
delete from orders$
where order_id is null
----change data type of column----
alter table orders$
alter column date date

--this will last only for that particular query--
SELECT CONVERT(varchar, CAST(date AS date), 105) AS FormattedDate from orders$

-- reading all tables for reference---

select*from delivery_partner$
select*from food$
select*from menu$
select*from restaurants$
select*from orders$
select*from users$

--Question1) Find customers who have never ordered----
--we need to match user_id's with user_id's in orders table,user_id's which are not present in the orders tabel are the customers who have not ordered-----

select t1.user_id,t1.name,count(t2.order_id) as 'no of orders' from users$ t1
left join orders$ t2 on t1.user_id=t2.user_id
group by t1.user_id,t1.name
having COUNT(t2.order_id)<1

--Quetion2) Find the average price per dish--
--join food and menu table and do group by on food id ,and food name to find average price of each dish---
select t2.f_name,avg(t1.price) as 'average price of the dish' from menu$ t1
join food$ t2 on t1.f_id=t2.f_id
group by t1.f_id,t2.f_name

--Question3) Find top restaurant interms of number of orders --
--join restaurants and orders table , group by restaurant id to find count of orders at each restaurant level--

select top 1 t1.r_id,t1.r_name,count(t2.order_id) as 'number of orders'
from restaurants$ t1
left join orders$ t2 on t1.r_id=t2.r_id
group by t1.r_id,t1.r_name
order by count(t2.order_id) desc


--Question4) Find top restaurant interms of number of orders in a given month--
--join restaurants and orders table , group by restaurant id to find count of orders at each restaurant level--

SELECT r_id,count(*)
FROM orders$
where DATENAME(MONTH, date) like 'June'
group by r_id

SELECT top 1 t1.r_id,count(t1.order_id) AS 'number of orders in June' ,t2.r_name
FROM orders$ t1
join restaurants$ t2 on t1.r_id=t2.r_id
where DATENAME(MONTH, t1.date) like 'June'
group by t1.r_id,t2.r_name
order by count(t1.order_id) desc

---Question5) Restaurants with monthly sales > 500 for June----
---join orders and restaurants tables filter t1 for june month using datename function,group by r-id and find sum of 
---monthly revenue to display revenues greater than 500 rupees------

select t1.r_id,t2.r_name,sum(t1.amount) as'June revenue' from orders$ t1
join restaurants$ t2 on t1.r_id=t2.r_id
where Datename(Month,date) like'June'
group by t1.r_id,t2.r_name
having sum(t1.amount)>500

--Question6)Show all orders with order details for a particular customer in a particular date range---
---Order history for Ankit between 10th june 2022 to 10th july 2022-----

select o.order_id,r.r_name ,od.f_id,f.f_name
from orders$ o
join restaurants$ r on o.r_id=r.r_id
join order_details$ od on od.order_id=o.order_id
join food$ f on od.f_id=f.f_id
where o.user_id=(select user_id from users$  where name like 'Ankit') 
and (o.date > '2022-06-10' and o.date <'2022-10-07')


----Question 7) Find restaurants with max repeated customers ---
--write a subquery to find no of orders at each restaurant by individual customers --
--most repeated restaurant ids with orders greater than 1 will be restaurant having max number of repeated orders--
---join on restaurants table is done to find the name of the restaurant---
select*from restaurants$
select*from order_details$
select*from orders$


select top 1 t.r_id,r.r_name,count(*) as 'No of repeated customers'
from
(
select r_id,user_id ,count(*) as 'no of orders by each customer'
from orders$
group by r_id,user_id
having count(*)>1 
)
t
join restaurants$ r on r.r_id=t.r_id 
group by t.r_id,r.r_name
order by count(*) desc

--Question 8) Month over month revenue growth for the Platform--

WITH sales AS (
    SELECT
        MONTH(date) AS month_number,
        DATENAME(month, date) AS month_name,
        SUM(amount) AS revenue
    FROM
        orders$
    GROUP BY
        MONTH(date),
        DATENAME(month, date)
)
SELECT
    month_name,
    ((revenue - prev) / prev) * 100 AS growth_percentage
FROM
(
    SELECT
        month_name,
        revenue,
        LAG(revenue, 1) OVER (ORDER BY month_number) AS prev
    FROM
        sales
) t;


	WITH sales AS (
    SELECT
        MONTH(date) AS month_number,
        DATENAME(month, date) AS month_name,
        SUM(amount) AS revenue
    FROM
        orders$
    GROUP BY
        MONTH(date),
        DATENAME(month, date)
)
SELECT
    month_name,
    ((revenue - LAG(revenue, 1) OVER (ORDER BY month_number)) / LAG(revenue, 1) OVER (ORDER BY month_number)) * 100 AS growth_percentage
FROM
    sales;


----Question 9) customer name and their favourite food ----
with temp as (
select o.user_id,od.f_id,count(*) as frequency from orders$ o
join order_details$ od
on o.order_id=od.order_id
group by o.user_id,od.f_id

)
select u.name,f.f_name from
temp t1
join users$ u 
on u.user_id =t1.user_id
join food$ f 
on t1.f_id=f.f_id
where t1.frequency=(select max(frequency) from temp t2 where t2.user_id=t1.user_id) 

