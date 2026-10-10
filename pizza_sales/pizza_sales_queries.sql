-- Pizza Sales Analysis (MySQL)
USE PIZZA_SALES;

-- Q1: Retrieve the total number of orders placed.
select count(order_id) as total_orders
from orders;

-- Q2: Calculate the total revenue generated from pizza sales.
SELECT SUM(o.quantity * p.price) AS total_sales
FROM order_details AS o
JOIN pizzas AS p
  ON p.pizza_id = o.pizza_id;

-- Q3: Identify the highest-priced pizza.
select p.name, ps.price
from pizza_types p
join pizzas ps
  on p.pizza_type_id = ps.pizza_type_id
order by ps.price desc
limit 1;

-- Q4: Identify the most common pizza size ordered.
select p.size, sum(d.quantity) as total_quantity
from order_details d
join pizzas p
on d.pizza_id=p.pizza_id
group by p.size
order by total_quantity desc
limit 1;

-- Q5: List the top 5 most ordered pizza types along with their quantities.
select t.name, sum(d.quantity) as total_quantity
from order_details d
join pizzas p
on d.pizza_id=p.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.name
order by total_quantity desc
limit 5;

-- Q6: Join the necessary tables to find the total quantity of each pizza category ordered.
select t.category, sum(d.quantity) as total_quantity
from order_details d
join pizzas p
on d.pizza_id=p.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.category;

-- Q7: Determine the distribution of orders by hour of the day.
select hour(order_time) as order_hour,
count(*) as total_orders
from orders
group by hour(order_time)
order by order_hour;

-- Q8: Join relevant tables to find the category-wise distribution of pizzas.
select t.category,
count(distinct p.pizza_type_id) as total_pizza_types
from pizzas p
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.category;

-- Q9: Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_quantity
from (
    select o.order_date,
           sum(od.quantity) as quantity
    from orders o
    join order_details od
    on o.order_id=od.order_id
    group by o.order_date
) as order_quantity;

-- Q10: Determine the top 3 most ordered pizza types based on revenue.
select t.name,
round(sum(d.quantity*p.price),2) as revenue
from order_details d
join pizzas p
on d.pizza_id=p.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.name
order by revenue desc
limit 3;

-- Q11: Calculate the percentage contribution of each pizza type to total revenue.
select t.name,
round(sum(d.quantity*p.price),2) as pizza_revenue,
round(
    sum(d.quantity*p.price)*100 /
    (select sum(d2.quantity*p2.price)
     from order_details d2
     join pizzas p2
     on d2.pizza_id=p2.pizza_id),
2
) as revenue_percentage
from order_details d
join pizzas p
on d.pizza_id=p.pizza_id
join pizza_types t
on p.pizza_type_id=t.pizza_type_id
group by t.name
order by revenue_percentage desc;

-- Q12: Analyze the cumulative revenue generated over time.
select order_date, daily_revenue,
sum(daily_revenue) over(order by order_date)
  as cumulative_revenue
from (
    select o.order_date,
    sum(d.quantity*p.price) as daily_revenue
    from orders o
    join order_details d
    on o.order_id=d.order_id
    join pizzas p
    on d.pizza_id=p.pizza_id
    group by o.order_date
) as daily_sales
order by order_date;

-- Q13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name, total_revenue
from (
    select t.category, t.name,
    sum(d.quantity*p.price) as total_revenue,
    rank() over(
        partition by t.category
        order by sum(d.quantity*p.price) desc
    ) as pizza_rank
    from order_details d
    join pizzas p
    on d.pizza_id=p.pizza_id
    join pizza_types t
    on p.pizza_type_id=t.pizza_type_id
    group by t.category, t.name
) as ranked_pizzas
where pizza_rank<=3
order by category, pizza_rank;

