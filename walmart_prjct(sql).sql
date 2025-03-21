create database prjct_walmart;
use prjct_walmart;

select * from walmart_prjct;

select count(*) from walmart_prjct;

select payment_method,count(*) as transactions from walmart_prjct group by payment_method;

select count(distinct branch) from walmart_prjct;

select max(quantity),category from walmart_prjct group by category;

-- Find different payment method and number of transactions,number of qty sold
select payment_method,sum(quantity) as no_qty_sold,count(*) as no_payments from walmart_prjct group by payment_method order by no_qty_sold desc;

-- Identify the highest-rated category in each branch,displaying the branch, category, avg rating
select branch,category,avg_rating
from 
( select 
         branch,
         category,
         avg(rating) as avg_rating,
         rank() over(partition by branch order by avg(rating) desc) as rnk
         from walmart_prjct 
         group by branch,category
) as ranked_category
where rnk = 1;

-- identify the busiest day for each branch based on number of transactions
select * from walmart_prjct;
describe walmart_prjct;
select
     branch, 
     day_name,
     no_transactions 
from
(select 
       branch,
       dayname(str_to_date(date,'%d-%m-%y')) as day_name,
	    count(*) as no_transactions,
        rank() over(partition by branch order by count(*) desc) as rnk
from walmart_prjct
group by branch,day_name) as busiest_day 
where rnk=1;

-- calculate total quantity of items sold per payment method. list payment_method and totl_quantity
select * from walmart_prjct;
select 
      payment_method,
      sum(quantity) as total_quantity 
from walmart_prjct 
group by payment_method;

-- determine the avg,min,max rating of products for each city. list the city,avg_rating,min_rating and max_rating
select * from walmart_prjct;
select 
   city, 
   category,
   avg(rating) as avg_rating,
   min(rating) as min_rating,
   max(rating) as max_rating 
from walmart_prjct 
group by city,category;

-- calculate the total profit for each category by considering total_profit as (unit_price*quantity*profit_margin).
-- list category and total_profit, ordered from highest to lowest profit.
 select * from walmart_prjct;  
 select 
     category,
     sum(unit_price*quantity*profit_margin) as total_profit 
from walmart_prjct 
group by category 
order by total_profit desc;

-- determine the most common payment method for each branch. display branch and the preferred payment_method
select * 
from 
(select  
   branch,
   payment_method,
   count(*) as no_transactions,
   rank() over(partition by branch order by count(*) desc) as rnk 
from walmart_prjct 
group by branch,payment_method) as p_p_m
where rnk=1;

-- categorize sales into 3 group morning,afternoon,evening. find out each shift and number of invoices
describe walmart_prjct;
select 
    branch,
case 
      when hour(str_to_date(time,'%h-%m-%s'))<12 then 'Morning'
	  when hour(str_to_date(time,'%h-%m-%s')) between 12 and 17 then 'Afternoon'
      else 'Evening' 
    end day_time,
    count(*) as no_invoices
from walmart_prjct
group by branch,day_time
order by branch,no_invoices desc;

-- identify 5 branch with highest decrease ration in revenue campare to last year(current yr 2023 nd last yr 2022)
select distinct year(str_to_date(date,'%d-%m-%Y')) from walmart_prjct;    

with revenue_2022
as
(
      select
          branch,
          sum(total) as revenue 
      from walmart_prjct 
      where year(str_to_date(date,'%d-%m-%Y'))=2022
      group by branch
 ),
 revenue_2023
 as
 (
      select
          branch,
          sum(total) as revenue 
      from walmart_prjct 
      where year(str_to_date(date,'%d-%m-%Y'))=2023
      group by branch
)
select 
      ls.branch,
      ls.revenue as last_yr_revenue,
      cs.revenue as cr_yr_revenue,
      round((ls.revenue-cs.revenue)/nullif(ls.revenue,0)*100,2) as rev_dec_ratio
from revenue_2022 as ls
join 
revenue_2023 as cs
on ls.branch=cs.branch
where 
     ls.revenue>cs.revenue
order by rev_dec_ratio desc
limit 5;



