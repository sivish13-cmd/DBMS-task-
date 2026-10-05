-- TASK IV: Order Management System

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT NOT NULL,
    Order_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL,
    Order_Status VARCHAR(30) DEFAULT 'Placed',
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Order_Details (
    Order_Detail_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Product_ID INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID)
);

-- Insert an order
INSERT INTO Orders (Order_ID, Customer_ID, Order_Date, Total_Amount, Order_Status)
VALUES (1001, 1, '2026-10-05', 2500.00, 'Placed');

-- Insert order details
INSERT INTO Order_Details (Order_Detail_ID, Order_ID, Product_ID, Quantity, Price)
VALUES (1, 1001, 101, 2, 1250.00);

-- Modify an order
UPDATE Orders
SET Total_Amount = 2750.00, Order_Status = 'Confirmed'
WHERE Order_ID = 1001;

-- Customer order history
SELECT
    o.Order_ID,
    o.Order_Date,
    o.Order_Status,
    o.Total_Amount
FROM Orders o
WHERE o.Customer_ID = 1
ORDER BY o.Order_Date DESC;

-- Complete order details
SELECT
    o.Order_ID,
    o.Customer_ID,
    od.Product_ID,
    od.Quantity,
    od.Price,
    o.Total_Amount,
    o.Order_Date,
    o.Order_Status
FROM Orders o
JOIN Order_Details od ON o.Order_ID = od.Order_ID;
