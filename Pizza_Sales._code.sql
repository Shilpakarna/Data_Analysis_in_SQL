create table order_details(
       order_details_id int8 primary key,
	   order_id int8 ,
	   pizza_id varchar(50),
	   quantity int8

)

create table orders(
        order_id int8 primary key,
		date date,
		time time
)

create table pizza_types(
pizza_type_id varchar(200) primary key,
name varchar (100),
category varchar(100),
ingredients varchar(200)
)

create table pizzas (
pizza_id varchar(100) primary key,
pizza_type_id varchar(200),
size varchar(10),
price float
)

select * from orders


--Questions:

/* Q1.Retrieve the total number of orders placed.*/

select 
 count(*) as total_number_of_orders
from orders


/* Q2.Calculate the total revenue generated from pizza sales.*/

select 
 sum(o.quantity*p.price) as total_revenue 
from pizzas p
join order_details o on o.pizza_id = p.pizza_id


/* Q3.Identify the highest-priced pizza.*/

select 
 pt.name,
 p.price 
from pizzas p
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
order by 2 desc
limit 1

/* Q4. Identify the most common pizza size ordered.*/

select 
 p.size,
 count(o.quantity)
from order_details o
join pizzas p on p.pizza_id = o.pizza_id
group by p.size
order by count(o.quantity) desc


/* Q5. List the top 5 most ordered pizza types along with their quantities.*/

select 
 pt.name,
 sum(o.quantity)as quantities_order 
from pizza_types pt
join pizzas p on p.pizza_type_id = pt.pizza_type_id
join order_details o on o.pizza_id = p.pizza_id
group by pt.name
order by 2 desc
limit 5

/* Q6.Join the necessary tables to find the total quantity of each pizza category ordered.*/
select 
  pt.category, 
  sum(o.quantity) as total_orders 
from pizza_types pt
 join pizzas p on p.pizza_type_id = pt.pizza_type_id
 join order_details o on o.pizza_id = p.pizza_id
group by 1
order by 2 desc


/* Q7.Determine the distribution of orders by hour of the day.*/

select 
  extract(hour from time),
  count(order_id)
from orders
  group by 1
  order by 2 desc

/* Q8.Join relevant tables to find the category-wise distribution of pizzas.*/

select 
  category,
  count(pizza_type_id) 
from pizza_types
  group by category
  order by 2 desc


/* Q9. Group the orders by date and calculate the average number of pizzas ordered per day.*/

select round(avg(quantity),0)from 
(
select  
  o.date, 
  sum(od.quantity) as quantity 
from orders o
  join order_details od on od.order_id = o.order_id
  group by 1
  order by 1 asc)
  as order_quantity




/* Q10. Determine the top 3 most ordered pizza types based on revenue.*/

select 
  pt.name,
  sum(od.quantity*p.price) as revenue 
from order_details od
  join pizzas p on od.pizza_id = p.pizza_id
  join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc
limit 3

/* Q11.Calculate the percentage contribution of each pizza type to total revenue.*/

select 
  pt.category,
  (sum(od.quantity*p.price)/
  (select(sum(od.quantity*p.price)) as total_sales 
  from pizzas p
  join order_details od on od.pizza_id = p.pizza_id) *100)
  as revenue 
from order_details od
join pizzas p on od.pizza_id = p.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by 1
order by 2 desc



/* Q12.Analyze the cumulative revenue generated over time.*/

select 
  date, 
  sum(revenue) over(order by date) as cumulative 
  from
    (select o.date,
	sum(od.quantity*p.price) as revenue 
	from order_details od
    join pizzas p on p.pizza_id = od.pizza_id
    join orders o on o.order_id = od.order_id
    group by 1
    order by 1 asc) 
as sales




/* Q13.Determine the top 3 most ordered pizza types based on revenue for each pizza category.*/


with most_order_pizza as(
  select 
     pt.name,
	 pt.category,
	 sum(od.quantity*p.price) as total_revenue,
     rank() 
	 over (
	 partition by pt.category 
	 order by 
	 sum(od.quantity*p.price)desc)
	 as rn 
  from order_details od
  join pizzas p on p.pizza_id = od.pizza_id
  join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
  group by 1,2
  order by 3 desc)
select * from most_order _pizza
where rn<=3 order by rn asc






