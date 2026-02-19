use monday_coffee_shop;

-- how many people in each city consume coffee , given that 25% population does? 
select city_id, city_name,
round((population*0.25)/1000000,2) as coffee_consumer_in_millions
 from city
 order by 3 desc; -- delhi has most number of coffee consumers 
 

-- what is total revenue genrated from coffee sales across all cities in the last quarter of 2023

with cte as 
(
select * , 
quarter(sale_date) as qtr,
year(sale_date) as yr
from sales) 
select city_name, sum(cte.total) as total_revenue
from cte
join customers cu 
on cte.customer_id = cu.customer_id
join city ci 
on ci.city_id = cu.city_id
where qtr = 4 and yr = 2023
group by city_name 
order by total_revenue desc; -- pune has highest sales in last querter of 2023 i.e., 434330

-- How many of units of each coffee product have been sold 
select product_name, count(*) as total_unit_sold 
from products p 
join sales s 
on s.product_id = p.product_id
group by 1
order by 2 desc; -- most sold Cold Brew Coffee Pack (6 Bottles) = 1326 units , least sold Coffee Mug (Ceramic) =  73 units

-- what is average sales per customer in each city 
select city_name, 
sum(total) as total_rev, 
count(distinct s.customer_id) as unique_cust, 
round(sum(total)/count(distinct s.customer_id),2) as avg_sales_per_cust
from city ci 
join customers cu 
on ci.city_id = cu.city_id
join sales s 
on s.customer_id = cu.customer_id
group by 1
order by 4 desc; -- jaipur has most unique customer = 69 ; lucknow has least unique customer with indore, hyderabad  = 21 ; pune has highest avg_sales_per_cust = 24197.88


/* provide a list of cities along with their populations and estimated coffee consumers , 
 return city_name, total current cx , estimted coffee customers (25%) */
 with cte as (
 select city_name , count(distinct customer_id) as unique_customers 
 from city ci 
 join customers cu 
 on ci.city_id = cu.city_id
 group by 1) , 
 
 cte2 as(
 select city_name,
 round((population * 0.25 )/1000000,2) as coffee_consumers_in_millions
 from city ) 
 
 select cte.city_name,coffee_consumers_in_millions,unique_customers
 from cte 
 join cte2 
 on cte.city_name = cte2.city_name
 order by 2 desc; -- Delhi has most number of coffee_consumer = approx. 7.75 million while Nagpur has least = 0.73 millions 
 
 
 
 /* what are top 3 selling product in each city based on the sales volume */
 
 
 with cte as (
 select  city_name, product_name, count(sale_id) as total_orders , 
 rank() over(partition by city_name order by count(sale_id) desc ) as rnk 
 from  products p 
 join sales s
 on s.product_id = p.product_id
 join customers c 
 on c.customer_id = s.customer_id 
 join city ci
 on ci.city_id = c.city_id
 group by 1,2) 
 select city_name, product_name, total_orders 
 from cte 
 where rnk < 4;
 
 /* how many unique customers are there in each city who have purchased coffee products */
 
select city_name, count(distinct c.customer_id) as unique_cus
 from  products p 
 join sales s
 on s.product_id = p.product_id
 join customers c 
 on c.customer_id = s.customer_id 
 join city ci
 on ci.city_id = c.city_id 
 where s.product_id <= 14
 group by 1
 order by 2 desc;
 
 
 /* find each city and their avg sale per customer and avg rent per customer */
 
 with cte as (
 select city_name , count( distinct s.customer_id) as customer_count , 
 round(sum(total) / count( distinct s.customer_id),0) as avg_sale_per_customer
 from city c 
 join customers  cu  
 on cu.city_id = c.city_id
 join sales s 
 on s.customer_id =  cu.customer_id
 group by 1 ), 
 
 
 cte2 as (
 select city_name ,estimated_rent, 
 round(estimated_rent/count(distinct customer_id),0) as avg_rent_per_cust
 from city ci 
 join customers cu 
 on ci.city_id = cu.city_id
 group by 1 , 2) 
  
  select cte.city_name,avg_rent_per_cust,avg_sale_per_customer  
  from cte 
  join cte2 
  on cte.city_name = cte2.city_name
  order by 3 desc; 
  -- mumbai has highest avg rent per customer = 1167 while jaipur has least = 157
  -- pune has highest avg sale per customer = 24198 while lucknow has laest = 5210
  
  
  
/*Calculate the percentage growth ( or decline) in sales over different time periods (monthly) by each city*/
 with cte as(
 select city_name , month(sale_date) as sale_month ,
 year(sale_date) as sale_year,  sum(total) as curr_month_sales
 from sales s 
 join customers cu 
 on cu.customer_id = s.customer_id
 join city c 
 on c.city_id = cu.city_id
 group by 1, 2,3
 order by 1 asc, 3 asc, 2 asc),
 
cte2 as(
 select * , 
 lag(curr_month_sales) over() as last_month_sale
 from cte) 
 
 select * , 
 round((curr_month_sales - last_month_sale )*100/last_month_sale,2) as growth_rate
 from cte2;
 
 
 
 
 
 
 
 
 
 
