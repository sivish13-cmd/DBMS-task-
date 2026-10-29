-- DBMS IX: Sales and Customer Analytics
-- Standalone MySQL 8.0+ script. This task file includes the shared schema and sample data setup.
-- WARNING: the setup drops and recreates the ecommerce_intelligence database.

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
