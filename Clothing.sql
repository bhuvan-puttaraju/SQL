-- Create and use the database
CREATE DATABASE IF NOT EXISTS Products;
USE Products;

-- Products table
CREATE TABLE Products (
     product_id INT PRIMARY KEY,
     Price DECIMAL(10, 2),
     Product_name VARCHAR(255),
     Category_id INT,
     Segment_id INT
);

INSERT INTO Products VALUES 
(1, 500.00, 'Headphones', 101, 1),
(2, 1500.00, 'Smartwatch', 101, 1),
(3, 700.00, 'T-shirt', 102, 2),
(4, 900.00, 'Jeans', 102, 2);

-- Product Sales table
CREATE TABLE Product_Sales (
   prod_id INT,
   qty INT,
   price DECIMAL(10, 2),
   Discount DECIMAL(5, 2),
   member BOOLEAN,
   txn_id INT PRIMARY KEY,
   Start_txn_time TIMESTAMP,
   FOREIGN KEY (prod_id) REFERENCES Products(product_id)
);

INSERT INTO Product_Sales VALUES
(1, 2, 500.00, 50.00, TRUE, 1001, '2024-01-01 10:00:00'),
(2, 1, 1500.00, 150.00, TRUE, 1002, '2024-01-01 11:00:00'),
(3, 3, 700.00, 70.00, FALSE, 1003, '2024-01-02 09:00:00'),
(4, 2, 900.00, 90.00, FALSE, 1004, '2024-01-02 10:00:00');

-- Product Hierarchy table
CREATE TABLE Product_Hierarchy (
    price_id INT PRIMARY KEY,
    Parent_id INT,
    level_text VARCHAR(255),
    level_name VARCHAR(255),
    FOREIGN KEY (Parent_id) REFERENCES Product_Hierarchy(price_id)
);

INSERT INTO Product_Hierarchy VALUES 
(1, NULL, 'All', 'Root'),
(2, 1, 'Gadgets', 'Category'),
(3, 1, 'Apparel', 'Category');

-- Categories table
CREATE TABLE Categories (
   category_id INT PRIMARY KEY,
   category_name VARCHAR(255)
);

INSERT INTO Categories VALUES 
(101, 'Gadgets'),
(102, 'Apparel');

-- Segments table
CREATE TABLE Segments (
    segment_id INT PRIMARY KEY,
    segment_name VARCHAR(255)
);

INSERT INTO Segments VALUES 
(1, 'Electronics'),
(2, 'Clothing');

-- Questions and Answers

-- 1. Total quantity sold

SELECT SUM(qty) AS total_quantity_sold
FROM Product_Sales;

-- 2. Total revenue before discount

SELECT SUM(price * qty) AS total_revenue_before_discount
FROM Product_Sales;

-- 3. Total discount amount

SELECT SUM(discount * qty) AS total_discount_amount
FROM Product_Sales;

-- 4. Unique transactions

SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM Product_Sales;

-- 5. Average unique products per transaction

SELECT AVG(unique_products) AS avg_unique_products_per_transaction
FROM (
    SELECT txn_id, COUNT(DISTINCT prod_id) AS unique_products
    FROM Product_Sales
    GROUP BY txn_id
) AS transaction_summary;

-- 6. Average discount per transaction

SELECT AVG(discount * qty) AS avg_discount_per_transaction
FROM Product_Sales;

-- 7. Member vs Non-Member percentage split

SELECT
   SUM(CASE WHEN member = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS member_percentage,
   SUM(CASE WHEN member = FALSE THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS non_member_percentage
FROM Product_Sales;

-- 8. Average revenue by member type

SELECT
  AVG(CASE WHEN member = TRUE THEN price * qty ELSE NULL END) AS avg_revenue_member_transaction,
  AVG(CASE WHEN member = FALSE THEN price * qty ELSE NULL END) AS avg_revenue_non_member_transactions
FROM Product_Sales;

-- 9. Top 3 products by revenue before discount

SELECT prod_id,
       SUM(price * qty) AS total_revenue_before_discount
FROM Product_Sales
GROUP BY prod_id
ORDER BY total_revenue_before_discount DESC
LIMIT 3;

-- 10. Total quantity, revenue, and discount for each segment

SELECT 
    s.segment_id,
    s.segment_name,
    SUM(ps.qty) AS total_quantity,
    SUM(ps.price * ps.qty) AS total_revenue,
    SUM(ps.discount * ps.qty) AS total_discount
FROM Product_Sales ps
JOIN Products p ON ps.prod_id = p.product_id
JOIN Segments s ON p.segment_id = s.segment_id
GROUP BY s.segment_id, s.segment_name;

-- 11. Top selling product by quantity in each segment

WITH Segment_Product_Sales AS (
    SELECT
        s.segment_id,
        p.product_id,
        p.product_name,
        SUM(ps.qty) AS total_quantity_sold
    FROM Product_Sales ps
    JOIN Products p ON ps.prod_id = p.product_id
    JOIN Segments s ON p.segment_id = s.segment_id
    GROUP BY s.segment_id, p.product_id, p.product_name
)
SELECT segment_id, product_id, product_name, total_quantity_sold
FROM Segment_Product_Sales sps
WHERE (segment_id, total_quantity_sold) IN (
    SELECT segment_id, MAX(total_quantity_sold)
    FROM Segment_Product_Sales
    GROUP BY segment_id
);