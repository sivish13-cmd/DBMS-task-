-- TASK VIII: Database Relationship Analysis using Joins

-- 1. INNER JOIN: customers and their orders
SELECT
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount
FROM Customer c
INNER JOIN Orders o
    ON c.Customer_ID = o.Customer_ID;

-- 2. INNER JOIN: complete order details
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    p.Product_Name,
    od.Quantity,
    od.Price,
    o.Total_Amount
FROM Customer c
INNER JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
INNER JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
INNER JOIN Product p
    ON od.Product_ID = p.Product_ID;

-- 3. LEFT JOIN: all customers, including those without orders
SELECT
    c.Customer_ID,
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount
FROM Customer c
LEFT JOIN Orders o
    ON c.Customer_ID = o.Customer_ID;

-- 4. RIGHT JOIN: all orders, including their customer information
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount
FROM Customer c
RIGHT JOIN Orders o
    ON c.Customer_ID = o.Customer_ID;

-- 5. Customer purchase history
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    p.Product_Name,
    od.Quantity,
    od.Price
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
JOIN Product p
    ON od.Product_ID = p.Product_ID
ORDER BY c.Customer_Name, o.Order_Date DESC;

-- 6. Multi-table report: customer + order + payment
SELECT
    c.Customer_Name,
    o.Order_ID,
    o.Order_Date,
    o.Total_Amount,
    pay.Payment_Mode,
    pay.Payment_Status
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
LEFT JOIN Payment pay
    ON o.Order_ID = pay.Order_ID
ORDER BY o.Order_Date DESC;

-- 7. Multi-table business report: customer + product + order + payment
SELECT
    c.Customer_Name,
    p.Product_Name,
    od.Quantity,
    od.Price,
    o.Order_Date,
    pay.Payment_Mode,
    pay.Payment_Status
FROM Customer c
JOIN Orders o
    ON c.Customer_ID = o.Customer_ID
JOIN Order_Details od
    ON o.Order_ID = od.Order_ID
JOIN Product p
    ON od.Product_ID = p.Product_ID
LEFT JOIN Payment pay
    ON o.Order_ID = pay.Order_ID;
