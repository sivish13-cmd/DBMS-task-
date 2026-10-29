/*
E-COMMERCE INTELLIGENCE PLATFORM
DBMS Tasks IX–XV | MySQL 8.0+
Educational sample project

Run in MySQL Workbench or the MySQL CLI as an administrator.
The script creates a fresh database named ecommerce_intelligence and sample users.
WARNING: DROP DATABASE deletes an existing database of the same name. Remove the
DROP DATABASE line if you need to preserve existing data.
*/

DROP DATABASE IF EXISTS ecommerce_intelligence;
CREATE DATABASE ecommerce_intelligence
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE ecommerce_intelligence;

-- ============================================================
-- COMMON SCHEMA + SAMPLE DATA (used by Tasks IX–XV)
-- ============================================================

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    created_at DATE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(80) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(120) NOT NULL,
    category_id INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
      REFERENCES categories(category_id),
    CONSTRAINT chk_product_price CHECK (unit_price >= 0),
    CONSTRAINT chk_product_stock CHECK (stock_quantity >= 0),
    INDEX idx_products_category_price (category_id, unit_price)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING','PAID','PROCESSING','SHIPPED','DELIVERED','CANCELLED')
      NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
      REFERENCES customers(customer_id),
    INDEX idx_orders_customer_date (customer_id, order_date),
    INDEX idx_orders_status_date (status, order_date)
) ENGINE=InnoDB;

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_items_order FOREIGN KEY (order_id)
      REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id)
      REFERENCES products(product_id),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id),
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (unit_price >= 0),
    INDEX idx_order_items_product (product_id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('CARD','UPI','NETBANKING','COD') NOT NULL,
    payment_status ENUM('PENDING','SUCCESS','FAILED','REFUNDED') NOT NULL,
    paid_at DATETIME NULL,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id)
      REFERENCES orders(order_id),
    CONSTRAINT chk_payment_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE order_audit (
    audit_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    action_name VARCHAR(60) NOT NULL,
    details VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_order_date (order_id, created_at)
) ENGINE=InnoDB;

INSERT INTO customers (full_name,email,city,created_at) VALUES
('Aarav Sharma','aarav@example.com','Chennai','2025-01-10'),
('Diya Patel','diya@example.com','Bengaluru','2025-02-14'),
('Kabir Singh','kabir@example.com','Chennai','2025-03-05'),
('Meera Iyer','meera@example.com','Hyderabad','2025-04-21'),
('Rohan Das','rohan@example.com','Mumbai','2025-05-11'),
('Ananya Rao','ananya@example.com','Bengaluru','2025-06-02');

INSERT INTO categories (category_name) VALUES
('Electronics'),('Home'),('Books'),('Accessories');

INSERT INTO products (product_name,category_id,unit_price,stock_quantity) VALUES
('Laptop',1,65000.00,12),
('Wireless Mouse',1,1200.00,50),
('Desk Lamp',2,1800.00,25),
('SQL Fundamentals',3,750.00,40),
('Data Science Handbook',3,1500.00,30),
('USB-C Hub',4,2400.00,35),
('Keyboard',1,3200.00,20),
('Water Bottle',2,500.00,60);

INSERT INTO orders (customer_id,order_date,status) VALUES
(1,'2026-01-05 10:00:00','DELIVERED'),
(2,'2026-01-08 11:30:00','DELIVERED'),
(1,'2026-02-10 14:00:00','DELIVERED'),
(3,'2026-02-15 09:15:00','DELIVERED'),
(4,'2026-03-01 16:20:00','PAID'),
(2,'2026-03-05 12:00:00','DELIVERED'),
(5,'2026-03-09 13:45:00','DELIVERED'),
(3,'2026-03-14 15:10:00','PAID'),
(6,'2026-03-20 10:30:00','DELIVERED');

INSERT INTO order_items (order_id,product_id,quantity,unit_price) VALUES
(1,1,1,65000.00),(1,2,2,1200.00),
(2,4,2,750.00),(2,5,1,1500.00),
(3,7,1,3200.00),(3,6,1,2400.00),
(4,1,1,65000.00),(4,3,2,1800.00),
(5,5,2,1500.00),(5,8,3,500.00),
(6,2,3,1200.00),(6,7,1,3200.00),
(7,3,1,1800.00),(7,8,2,500.00),
(8,6,2,2400.00),(8,4,1,750.00),
(9,5,1,1500.00),(9,2,1,1200.00);

INSERT INTO payments (order_id,amount,payment_method,payment_status,paid_at) VALUES
(1,67400.00,'CARD','SUCCESS','2026-01-05 10:02:00'),
(2,3000.00,'UPI','SUCCESS','2026-01-08 11:32:00'),
(3,5600.00,'CARD','SUCCESS','2026-02-10 14:02:00'),
(4,68600.00,'NETBANKING','SUCCESS','2026-02-15 09:20:00'),
(5,4500.00,'UPI','SUCCESS','2026-03-01 16:22:00'),
(6,6800.00,'UPI','SUCCESS','2026-03-05 12:03:00'),
(7,2800.00,'COD','SUCCESS','2026-03-09 13:50:00'),
(8,5550.00,'CARD','SUCCESS','2026-03-14 15:15:00'),
(9,2700.00,'UPI','SUCCESS','2026-03-20 10:35:00');

-- ============================================================
-- TASK IX: SALES AND CUSTOMER ANALYTICS
-- ============================================================

-- IX.1 COUNT, SUM, AVG, MIN, MAX
SELECT COUNT(*) AS product_count,
       SUM(stock_quantity) AS total_units_in_stock,
       ROUND(AVG(unit_price),2) AS average_product_price,
       MIN(unit_price) AS minimum_price,
       MAX(unit_price) AS maximum_price
FROM products;

-- IX.2 Total sales report: successful payment amounts by order
SELECT o.order_id, o.order_date, c.full_name,
       SUM(oi.quantity * oi.unit_price) AS order_value,
       p.amount AS paid_amount, p.payment_status
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
LEFT JOIN payments p ON p.order_id = o.order_id
GROUP BY o.order_id, o.order_date, c.full_name, p.amount, p.payment_status
ORDER BY o.order_date;

-- IX.3 Top customers by purchase amount (paid/successful orders only)
SELECT c.customer_id, c.full_name,
       SUM(oi.quantity * oi.unit_price) AS purchase_amount
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY c.customer_id, c.full_name
ORDER BY purchase_amount DESC
LIMIT 5;

-- IX.4 Best-selling products by units sold
SELECT pr.product_id, pr.product_name,
       SUM(oi.quantity) AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS sales_value
FROM products pr
JOIN order_items oi ON oi.product_id = pr.product_id
JOIN orders o ON o.order_id = oi.order_id
JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY pr.product_id, pr.product_name
ORDER BY units_sold DESC, sales_value DESC;

-- IX.5 Category-wise sales analysis
SELECT cat.category_name,
       SUM(oi.quantity) AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price),2) AS category_sales
FROM categories cat
JOIN products pr ON pr.category_id = cat.category_id
JOIN order_items oi ON oi.product_id = pr.product_id
JOIN payments p ON p.order_id = oi.order_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY cat.category_id, cat.category_name
ORDER BY category_sales DESC;

-- ============================================================
-- TASK X: ADVANCED SQL QUERIES
-- ============================================================

-- X.1 Subquery: products priced above the average product price
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

-- X.2 Customers whose total purchase is the maximum total purchase
WITH customer_totals AS (
    SELECT c.customer_id, c.full_name,
           SUM(oi.quantity * oi.unit_price) AS total_purchase
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN payments p ON p.order_id = o.order_id
    WHERE p.payment_status = 'SUCCESS'
    GROUP BY c.customer_id, c.full_name
)
SELECT customer_id, full_name, total_purchase
FROM customer_totals
WHERE total_purchase = (SELECT MAX(total_purchase) FROM customer_totals);

-- X.3 Nested query: customers with at least one order above average order value
SELECT DISTINCT c.customer_id, c.full_name
FROM customers c
WHERE c.customer_id IN (
    SELECT o.customer_id
    FROM orders o
    WHERE o.order_id IN (
        SELECT oi.order_id
        FROM order_items oi
        GROUP BY oi.order_id
        HAVING SUM(oi.quantity * oi.unit_price) >
            (SELECT AVG(order_total)
             FROM (
                 SELECT SUM(oi2.quantity * oi2.unit_price) AS order_total
                 FROM order_items oi2
                 GROUP BY oi2.order_id
             ) AS order_averages)
    )
);

-- X.4 Business query: monthly sales, order count and average order value
SELECT DATE_FORMAT(o.order_date,'%Y-%m') AS sales_month,
       COUNT(DISTINCT o.order_id) AS order_count,
       SUM(oi.quantity * oi.unit_price) AS gross_sales,
       ROUND(SUM(oi.quantity * oi.unit_price) /
             COUNT(DISTINCT o.order_id),2) AS average_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN payments p ON p.order_id = o.order_id
WHERE p.payment_status = 'SUCCESS'
GROUP BY DATE_FORMAT(o.order_date,'%Y-%m')
ORDER BY sales_month;

-- X.5 Customers who spent more than the average customer spend
WITH customer_spend AS (
    SELECT c.customer_id, c.full_name,
           COALESCE(SUM(CASE WHEN p.payment_status='SUCCESS'
               THEN oi.quantity * oi.unit_price ELSE 0 END),0) AS spend
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    LEFT JOIN payments p ON p.order_id = o.order_id
    GROUP BY c.customer_id, c.full_name
)
SELECT customer_id, full_name, spend
FROM customer_spend
WHERE spend > (SELECT AVG(spend) FROM customer_spend)
ORDER BY spend DESC;

-- ============================================================
-- TASK XI: VIEWS, STORED PROCEDURES, FUNCTIONS, AUTOMATION
-- ============================================================

CREATE OR REPLACE VIEW v_order_sales AS
SELECT o.order_id, o.order_date, o.status, c.customer_id, c.full_name,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.status, c.customer_id, c.full_name;

CREATE OR REPLACE VIEW v_category_sales AS
SELECT cat.category_id, cat.category_name,
       COALESCE(SUM(oi.quantity),0) AS units_sold,
       COALESCE(SUM(oi.quantity * oi.unit_price),0) AS sales_value
FROM categories cat
LEFT JOIN products pr ON pr.category_id = cat.category_id
LEFT JOIN order_items oi ON oi.product_id = pr.product_id
GROUP BY cat.category_id, cat.category_name;

DELIMITER $$

CREATE FUNCTION fn_order_total(p_order_id INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(12,2);
    SELECT COALESCE(SUM(quantity * unit_price),0)
      INTO v_total
      FROM order_items
     WHERE order_id = p_order_id;
    RETURN v_total;
END$$

CREATE PROCEDURE sp_get_customer_orders(IN p_customer_id INT)
BEGIN
    SELECT order_id, order_date, status, order_total
    FROM v_order_sales
    WHERE customer_id = p_customer_id
    ORDER BY order_date DESC;
END$$

-- Adds one order line and decreases stock atomically.
-- The caller should invoke this inside a transaction.
CREATE PROCEDURE sp_add_order_item(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock INT;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be positive';
    END IF;

    SELECT unit_price, stock_quantity
      INTO v_price, v_stock
      FROM products
     WHERE product_id = p_product_id
     FOR UPDATE;

    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    INSERT INTO order_items(order_id,product_id,quantity,unit_price)
    VALUES(p_order_id,p_product_id,p_quantity,v_price);

    UPDATE products
       SET stock_quantity = stock_quantity - p_quantity
     WHERE product_id = p_product_id;

    INSERT INTO order_audit(order_id,action_name,details)
    VALUES(p_order_id,'ADD_ORDER_ITEM',
           CONCAT('Product ',p_product_id,', quantity ',p_quantity));
END$$

DELIMITER ;

-- XI.1 View report
SELECT * FROM v_order_sales ORDER BY order_id;
SELECT * FROM v_category_sales ORDER BY sales_value DESC;

-- XI.2 Stored procedure demonstration
CALL sp_get_customer_orders(1);

-- XI.3 Function demonstration
SELECT fn_order_total(1) AS order_1_total;

-- ============================================================
-- TASK XII: TRANSACTIONS AND ACID
-- ============================================================

-- XII.1 Successful order placement transaction.
-- Demo uses product 8, which has sufficient stock. Run this block once.
START TRANSACTION;
INSERT INTO orders(customer_id,order_date,status)
VALUES(6,NOW(),'PENDING');
SET @new_order_id = LAST_INSERT_ID();

-- Add item and reduce stock using the procedure; the outer transaction controls commit.
CALL sp_add_order_item(@new_order_id,8,2);

SET @new_total = fn_order_total(@new_order_id);
INSERT INTO payments(order_id,amount,payment_method,payment_status,paid_at)
VALUES(@new_order_id,@new_total,'UPI','SUCCESS',NOW());

UPDATE orders SET status='PAID' WHERE order_id=@new_order_id;
COMMIT;

SELECT @new_order_id AS created_order_id, fn_order_total(@new_order_id) AS order_total;
SELECT product_id,product_name,stock_quantity
FROM products WHERE product_id=8;

-- XII.2 ROLLBACK demonstration: stock and order should remain unchanged.
-- This transaction intentionally creates a temporary order and rolls it back.
START TRANSACTION;
INSERT INTO orders(customer_id,order_date,status)
VALUES(5,NOW(),'PENDING');
SET @rollback_order_id = LAST_INSERT_ID();
CALL sp_add_order_item(@rollback_order_id,2,1);
ROLLBACK;

-- The following should return zero rows for the rolled-back order.
SELECT * FROM orders WHERE order_id=@rollback_order_id;
-- Stock for product 2 should be unchanged by the rolled-back transaction.
SELECT product_id,product_name,stock_quantity FROM products WHERE product_id=2;

-- XII.3 ACID summary (explanation):
-- Atomicity: order, order line, stock reduction, and payment are committed together.
-- Consistency: constraints + checks + application/procedure rules preserve valid data.
-- Isolation: InnoDB locks the selected product row with SELECT ... FOR UPDATE.
-- Durability: COMMIT persists the transaction (subject to server/storage configuration).

-- ============================================================
-- TASK XIII: DATABASE SECURITY AND PERFORMANCE
-- ============================================================

-- Create a least-privilege reporting role and account.
-- Run as an administrator. If re-running, drop the role/user first as appropriate.
CREATE ROLE IF NOT EXISTS 'ecommerce_reporter';
GRANT SELECT ON ecommerce_intelligence.v_order_sales TO 'ecommerce_reporter';
GRANT SELECT ON ecommerce_intelligence.v_category_sales TO 'ecommerce_reporter';

CREATE USER IF NOT EXISTS 'report_user'@'localhost'
  IDENTIFIED BY 'ChangeThis_StrongPassword_2026!';
GRANT 'ecommerce_reporter' TO 'report_user'@'localhost';
SET DEFAULT ROLE 'ecommerce_reporter' TO 'report_user'@'localhost';

-- Example GRANT and REVOKE. This temporary grant is immediately revoked.
GRANT SELECT ON ecommerce_intelligence.products TO 'report_user'@'localhost';
REVOKE SELECT ON ecommerce_intelligence.products FROM 'report_user'@'localhost';

-- Existing indexes are defined alongside tables:
-- products(category_id, unit_price)
-- orders(customer_id, order_date), orders(status, order_date)
-- order_items(product_id), order_audit(order_id, created_at)
-- Add an index only when query patterns justify it; indexes increase write/storage cost.
CREATE INDEX idx_customers_city ON customers(city);

-- Inspect the query plan; look for index usage and estimated rows.
EXPLAIN
SELECT order_id, customer_id, order_date
FROM orders
WHERE customer_id = 1
ORDER BY order_date DESC;

-- Security note: replace the example password; do not store real passwords in SQL files.
-- Do not grant INSERT/UPDATE/DELETE to a reporting account.

-- ============================================================
-- TASK XIV: BUSINESS INTELLIGENCE AND AI DATA PREPARATION
-- ============================================================

-- XIV.1 Ranking products by sales within each category
WITH product_sales AS (
    SELECT cat.category_name, pr.product_id, pr.product_name,
           COALESCE(SUM(oi.quantity * oi.unit_price),0) AS sales_value
    FROM categories cat
    JOIN products pr ON pr.category_id = cat.category_id
    LEFT JOIN order_items oi ON oi.product_id = pr.product_id
    GROUP BY cat.category_name, pr.product_id, pr.product_name
)
SELECT category_name, product_name, sales_value,
       RANK() OVER (PARTITION BY category_name ORDER BY sales_value DESC) AS sales_rank,
       ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY sales_value DESC, product_id) AS row_num
FROM product_sales
ORDER BY category_name, sales_rank;

-- XIV.2 Customer segmentation features for AI / analytics.
-- Features are based on all recorded orders; adapt to paid-only if required.
WITH customer_features AS (
    SELECT c.customer_id, c.full_name, c.city,
           COUNT(DISTINCT o.order_id) AS order_count,
           COALESCE(SUM(oi.quantity * oi.unit_price),0) AS lifetime_value,
           COALESCE(SUM(oi.quantity),0) AS items_purchased,
           MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.full_name, c.city
)
SELECT customer_id, full_name, city, order_count, lifetime_value, items_purchased,
       DATEDIFF(CURDATE(), DATE(last_order_date)) AS days_since_last_order,
       CASE
         WHEN order_count >= 3 AND lifetime_value >= 50000 THEN 'VIP'
         WHEN order_count >= 2 THEN 'LOYAL'
         WHEN order_count = 1 THEN 'NEW_OR_OCCASIONAL'
         ELSE 'NO_PURCHASE'
       END AS customer_segment
FROM customer_features
ORDER BY lifetime_value DESC;

-- XIV.3 Feature extraction dataset (one row per customer).
CREATE OR REPLACE VIEW v_customer_ai_features AS
SELECT c.customer_id,
       c.city,
       COUNT(DISTINCT o.order_id) AS order_count,
       COALESCE(SUM(oi.quantity),0) AS total_items,
       COALESCE(SUM(oi.quantity * oi.unit_price),0) AS lifetime_value,
       ROUND(COALESCE(AVG(oi.unit_price),0),2) AS average_item_price,
       MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.city;

SELECT * FROM v_customer_ai_features ORDER BY customer_id;

-- XIV.4 Export-ready product/category dataset
SELECT pr.product_id, pr.product_name, cat.category_name,
       pr.unit_price, pr.stock_quantity,
       COALESCE(SUM(oi.quantity),0) AS historical_units_sold,
       COALESCE(SUM(oi.quantity * oi.unit_price),0) AS historical_sales_value
FROM products pr
JOIN categories cat ON cat.category_id = pr.category_id
LEFT JOIN order_items oi ON oi.product_id = pr.product_id
GROUP BY pr.product_id, pr.product_name, cat.category_name,
         pr.unit_price, pr.stock_quantity
ORDER BY historical_sales_value DESC;

-- ============================================================
-- TASK XV: INDUSTRY CAPSTONE / FINAL VALIDATION REPORTS
-- ============================================================

-- XV.1 Schema integrity: check row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments;

-- XV.2 Revenue dashboard summary (successful payments only)
SELECT
  (SELECT COUNT(*) FROM orders o JOIN payments p ON p.order_id=o.order_id
    WHERE p.payment_status='SUCCESS') AS paid_orders,
  (SELECT COUNT(DISTINCT o.customer_id) FROM orders o
    JOIN payments p ON p.order_id=o.order_id
    WHERE p.payment_status='SUCCESS') AS purchasing_customers,
  (SELECT SUM(oi.quantity) FROM order_items oi
    JOIN payments p ON p.order_id=oi.order_id
    WHERE p.payment_status='SUCCESS') AS units_sold,
  (SELECT SUM(oi.quantity * oi.unit_price) FROM order_items oi
    JOIN payments p ON p.order_id=oi.order_id
    WHERE p.payment_status='SUCCESS') AS gross_order_value,
  (SELECT SUM(p.amount) FROM payments p
    WHERE p.payment_status='SUCCESS') AS collected_payment_amount;

-- XV.3 Low-stock inventory alert
SELECT product_id, product_name, stock_quantity
FROM products
WHERE stock_quantity < 10
ORDER BY stock_quantity;

-- XV.4 Data quality: orders whose item total differs from payment amount
SELECT o.order_id,
       SUM(oi.quantity * oi.unit_price) AS calculated_total,
       p.amount AS payment_total
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN payments p ON p.order_id = o.order_id
GROUP BY o.order_id, p.amount
HAVING calculated_total <> payment_total;

-- XV.5 ERD relationship guide:
-- customers 1---many orders
-- orders 1---many order_items
-- products 1---many order_items
-- categories 1---many products
-- orders 1---0/1 payments
-- orders 1---many order_audit rows

-- Suggested presentation conclusion:
-- The platform combines normalized e-commerce tables, sales analytics, nested SQL,
-- views/functions/procedures, ACID transactions, role-based access, indexes,
-- window functions, and customer/product feature extraction for business intelligence.