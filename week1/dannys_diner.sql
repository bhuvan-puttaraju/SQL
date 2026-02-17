#Week 1 of 8 week SQL Challange
create database case_study;
use case_study;
select*from sales;
select*from members;
select*from menu;

#1. What is the total amount each customer spent at the restaurant?					
select customer_id,sum(price)as Total_amount_spent from sales as s inner join menu as m using(product_id)group by customer_id ;

#2. How many days has each customer visited the restaurant?
select customer_id,count(distinct order_date)as visit_days from sales group by customer_id;

#3. What was the first item from the menu purchased by each customer?
select customer_id,product_name as first_order from (
select*,row_number() over(partition by customer_id order by order_date asc)as rn from  sales s inner join menu m using (product_id))as t
where rn=1;

#4. What is the most purchased item on the menu and how many times was it purchased by all customers?							
select product_name,count(*) as No_of_times
from sales s inner join menu m using (product_id)
group by product_name order by No_of_times desc limit 1;

#5. Which item was the most popular for each customer?	
select *from(				
select customer_id,product_name,count(*) as no_of_orders,rank() over(partition by customer_id order by count(*) desc)as rn
 from sales as s inner join menu m using (product_id)
group by product_name,customer_id)as t
where rn=1;

#6. Which item was purchased first by the customer after they became a member?
select customer_id,product_name from(
select*,row_number() over(partition by customer_id order by order_date asc)as rn
from sales s inner join menu m using(product_id) inner join members mb using (customer_id) where s.order_date>mb.join_date)as t
where rn=1;

#7. Which item was purchased just before the customer became a member?			
select *from (
select*,rank() over(partition by customer_id order by order_date desc)as rnk
from sales s inner join menu m using(product_id) inner join members as mb using (customer_id) 
where s.order_date<mb.join_date)as t where rnk=1;

#8. What is the total items and amount spent for each member before they became a member?				
select customer_id,count(*) as total_items,sum(price) as total_amount_spent from sales s inner join menu m using(product_id) inner join members as mb using (customer_id) 
where s.order_date<mb.join_date group by customer_id order by customer_id asc;

#9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?							
select customer_id,sum(case when product_name="sushi" then price * 20 else price *10 end) as bonus
from sales s inner join menu m using(product_id) group by customer_id 
