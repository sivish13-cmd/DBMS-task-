-- DBMS XIII: Database Security and Performance
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
