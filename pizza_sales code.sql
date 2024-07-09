USE sql_pizza_project;

-- 1 retrive the total number of orders placed

SELECT 
    COUNT(order_id) AS "Total Orders"
FROM
    orders;

-- 2 Calculate total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS 'Total  Revenue ($)'
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3 Identify the highest priced pizza

SELECT 
    pizza_types.name AS 'Name of the Pizza',
    pizzas.price AS 'Price ($)'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- 4 Identity the most common pizza size ordered.

SELECT 
    pizzas.size AS 'Size of Pizza',
    COUNT(order_details.order_details_id) AS 'Order Count'
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY 'Order Count' DESC
LIMIT 1;

-- 5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name AS 'Name of the Pizza',
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- 6 Join the neccessary tables to find the total quantity of each pizza cateogry orderd.

SELECT 
    pizza_types.category AS Category,
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY Category
ORDER BY Quantity DESC;

-- 7 Determine the distribuition of orders by hour of the day

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS 'Order Count'
FROM
    orders
GROUP BY HOUR(order_time);

-- 8 Join relevant tables to find the category wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY category;

-- 9 Group the orders by date and calculate the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(Quantity), 0) as "Average no. of orders per day"
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- 10 Determine the top 3 most ordred pizza types based on revenue.

SELECT 
    pizza_types.name AS 'Name of the Pizza',
    ROUND(SUM(order_details.quantity * pizzas.price),
            0) AS 'Revenue ($)'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY 'Revenue ($)' DESC
LIMIT 3;

-- 11 Calculate the contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category AS 'Category of Pizza',
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS 'Total  Revenue ($)'
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS 'Contribution in Revenue (%)'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- 12 Analyze the cumulative revenue generated over time

SELECT 
		order_date as 'Order Date',
			round(sum(revenue) over(order by order_date), 2) as 'Cumulative Revenue' 
				from 
    (SELECT 
            orders.order_date,
                SUM(order_details.quantity * pizzas.price) AS revenue
        FROM
            order_details
                JOIN
            pizzas ON order_details.pizza_id = pizzas.pizza_id
                JOIN
            orders ON orders.order_id = order_details.order_id
        GROUP BY orders.order_date) AS sales;
        
-- 13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT Category,
	   name 'Top 3 Pizzas under specified category respectively',
       Revenue as 'Revenue ($)'
			FROM
(SELECT 
		category AS 'Category',
		name,
		revenue, RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
			FROM
(SELECT 
    pizza_types.category,
    pizza_types.name,
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category , pizza_types.name) as a) as b
WHERE rn <= 3;
