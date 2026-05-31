DROP database ONLINE_FOOD_DEL;
CREATE DATABASE ONLINE_FOOD_DEL;
use ONLINE_FOOD_DEL;
create table Customer_table(
customer_id int Primary Key,
customer_name VARCHAR(60),
email VARCHAR(60),
city VARCHAR(60),
signup_date date);

SELECT * FROM Customer_table; 

CREATE TABLE Restaurant(
Restaurant_id int PRIMARY KEY,
Restaurant_name VARCHAR(60),
City VARCHAR(60),
reg_date date);

SELECT * FROM Restaurant;

CREATE TABLE Menu_item(
item_id int primary KEY,
Restaurant_id int,
item_name varchar(60),
price DECIMAL(10,2),
constraint FK_MENU_RES
Foreign KEY (Restaurant_id) 
references Restaurant(Restaurant_id)
);
SELECT * FROM Menu_item;

CREATE TABLE Orders(
order_id int PRIMARY KEY,
customer_id int,
restaurant_id int,
order_date date,
constraint FK_Orders_Customer
FOREIGN KEY (customer_id)
references Customer_table(customer_id),
constraint FK_Orders_Restaurant
FOREIGN KEY (restaurant_id)
REFERENCES Restaurant(Restaurant_id));

SELECT * FROM Orders;

CREATE TABLE Order_details(
Orderdetail_id int PRIMARY KEY,
order_id int,
item_id int,
quantity int,
constraint FK_OD_ORDER
FOREIGN KEY (order_id) 
REFERENCES Orders(order_id),
constraint FK_OD_MI
FOREIGN KEY (item_id)
REFERENCES Menu_item(item_id));

SELECT * FROM Order_details;



SELECT Restaurant_name,City from restaurant WHERE City="Delhi";

SELECT item_name,price FROM menu_item 
ORDER BY price DESC 
LIMIT 3;

SELECT order_id FROM order_details WHERE quantity>2;

-- Show all orders along with the restaurant name from which they were placed
SELECT o.order_id ,r.restaurant_name from orders o join restaurant r ON o.restaurant_id=r.Restaurant_id;


-- show customer names and order dates for orders placed in January 2023
select C.customer_name , O.order_date,O.order_id 
from customer_table C join orders O 
WHERE O.order_date Between "2023-01-01" AND "2023-01-31";

-- List all customers along with their city who placed an order on or after '2023-01-01
SELECT C.customer_name ,C.city,O.order_date 
from customer_table C JOIN orders O ON C.customer_id=O.customer_id
 WHERE O.order_date>="2023-01-01";
 -- Show restaurant names and order IDs for orders placed from restaurants in Mumbai
 SELECT R.restaurant_name,O.order_id,R.city 
 from orders O join restaurant R ON R.restaurant_id = O.restaurant_id
 WHERE R.city="Mumbai";
-- Customers who have ordered from a specific restaurant - ‘Spice Villa’
SELECT O.customer_id, R.Restaurant_name 
FROM restaurant R JOIN orders O ON R.Restaurant_id = O.restaurant_id
 WHERE R.Restaurant_name LIKE "Spice%";
 
 
-- count how many orders each customer has placed;
SELECT C.customer_id ,C.customer_name,count(O.customer_id) from 
orders O join customer_table C 
ON C.customer_id=O.customer_id group by C.customer_id;


-- Show total revenue earned from each city


SELECT R.city , SUM(OD.quantity*M.price) as total_revenue
from menu_item M 
JOIN order_details OD ON M.item_id=OD.item_id 
JOIN restaurant R ON R.Restaurant_id=M.Restaurant_id 
GROUP BY R.city;


--  Find the total number of times each food item was ordered
SELECT MI.item_name,MI.item_id,count(O.order_id) AS no_of_times_ordered 
from orders O 
JOIN menu_item MI ON O.restaurant_id=MI.restaurant_id 
GROUP BY MI.item_id; 

-- .  Calculate the average order value for each customer city
SELECT C.city AS Customer_city,ROUND(AVG(OD.quantity*M.price),2) as Average_order_value
from menu_item M 
JOIN order_details OD ON M.item_id=OD.item_id 
JOIN Customer_table C ON C.customer_id=M.Restaurant_id 
GROUP BY C.city;
-- Find how many different food items were ordered per restaurant

SELECT R.restaurant_name,COUNT(Distinct MI.item_name) as count_of_items 
FROM restaurant R JOIN menu_item MI ON MI.restaurant_id=R.restaurant_id 
GROUP BY R.restaurant_name;

-- List customers who placed more than 3 orders;
select O.customer_id,C.customer_name,count(O.customer_id) as NO_OF_ORDERS 
from customer_table C join orders O 
ON C.customer_id=O.customer_id
Group BY O.customer_id 
having NO_OF_ORDERS>3;
-- Display menu items that were ordered more than 2 times
SELECT OD.item_id,MI.item_name,count(OD.item_id) as NO_OF_ORDERS 
from menu_item MI JOIN order_details OD 
ON MI.item_id=OD.item_id 
group BY OD.item_id 
HAVING NO_OF_ORDERS>2;

-- Show each food item and how much more it costs than the average
SELECT item_name,
ROUND(price-(SELECT AVG(price) from menu_item),2) as varience
from menu_item;
-- List food items that cost more than the average price
SELECT item_name,
price,(SELECT AVG(price) from menu_item) as average
from menu_item WHERE price > (SELECT AVG(price) from menu_item);
-- Show customers who haven’t placed any orders (HINT: USE “not in” )

SELECT customer_id from customer_table 
WHERE customer_id not in(SELECT customer_id from orders);

-- Top 5 Spending Customers
SELECT O.customer_id,C.customer_name,sum(MI.price*OD.quantity) as Customer_spending
from order_details OD 
JOIN menu_item MI ON OD.item_id=MI.item_id 
JOIN orders O ON OD.order_id=O.order_id
JOIN customer_table C ON C.customer_id= O.customer_id 
GROUP BY O.customer_id
ORDER BY Customer_spending DESC LIMIT 5;

-- Restaurant-wise Order Count
SELECT R.Restaurant_id,R.Restaurant_name ,count(O.order_id) 
from Restaurant R JOIN Orders O 
ON R.Restaurant_id=O.restaurant_id 
group by R.Restaurant_id;

-- Average Order Value by City
SELECT R.city,AVG(MI.price*OD.quantity) AS Average 
from restaurant R 
JOIN menu_item MI ON MI.restaurant_id=R.Restaurant_id
JOIN order_details OD ON MI.item_id=OD.item_id 
GROUP BY R.city;

-- Number of Unique Customers per City 
SELECT city, count(Distinct customer_id) AS NO_OF_Customers
FROM customer_table 
GROUP BY city;

-- Most Frequently Ordered Items

SELECT OD.item_id,MI.item_name,count(OD.item_id) as count 
from order_details OD 
JOIN menu_item MI ON MI.item_id=OD.item_id 
GROUP BY OD.item_id 
ORDER BY count DESC LIMIT 5;

-- Restaurants with Low Order Counts (< 30)

SELECT O.restaurant_id,R.restaurant_name,count(R.restaurant_id) as count_of_restaurant 
from Restaurant R 
JOIN orders O ON O.restaurant_id=R.Restaurant_id 
GROUP BY O.restaurant_id 
HAVING count_of_restaurant<30;