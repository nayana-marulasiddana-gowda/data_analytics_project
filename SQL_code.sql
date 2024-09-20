select * from df_orders;

--find top 10 highest revenue generating projects
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc;

--find top 5 highest selling products in each region
with cte as (
select region, product_id, sum(quantity) as sales
from df_orders
group by region, product_id)
select * from (
select *
, row_number() over (partition by region order by sales desc) as rn
from cte) A
where rn<=5;


--find month over month growth comparison for 2022 and 2023 sales

with cte as(
select YEAR(order_date) as year_of_sale, month(order_date) as month_of_sale, sum(sale_price) as sales
from df_orders
group by YEAR(order_date),month(order_date)
)
select month_of_sale
,sum(case when year_of_sale=2022 then sales else 0 end) as sales_2022
,sum(case when year_of_sale=2023 then sales else 0 end) as sales_2023
from cte
group by month_of_sale
order by month_of_sale;


--for each category which month had highest sales
with cte as(
select category,format(order_date,'yyyyMM') as order_year_month, sum(sale_price) as sales 
from df_orders
group by category,format(order_date,'yyyyMM')
--order by category,format(order_date,'yyyyMM')
)
select * from(
select *, 
row_number() over (partition by category order by sales desc) as rn
from cte) a
where rn=1


--which subcategory had highest growth by profit in 2023 compared to 2022
with cte as(
select sub_category
,YEAR(order_date) as year_of_sale
,sum(sale_price) as sales
from df_orders
group by sub_category,YEAR(order_date)
)
, cte2 as(
select sub_category
,sum(case when year_of_sale=2022 then sales else 0 end) as sales_2022
,sum(case when year_of_sale=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select top 1 *
, (sales_2023-sales_2022)*100/sales_2022 as profit_percentage
from cte2
order by (sales_2023-sales_2022)*100/sales_2022 desc