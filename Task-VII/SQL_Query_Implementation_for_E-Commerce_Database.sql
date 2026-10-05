-- TASK VII: SQL Query Implementation for E-Commerce Database

-- 1. SELECT
SELECT * FROM Product;

-- 2. WHERE: products above a given price
SELECT Product_ID, Product_Name, Price
FROM Product
WHERE Price > 1000;

-- 3. ORDER BY: highest-priced products first
SELECT Product_ID, Product_Name, Price
FROM Product
ORDER BY Price DESC;

-- 4. DISTINCT: list product categories
SELECT DISTINCT Category
FROM Product;

-- 5. Search by price range
SELECT Product_ID, Product_Name, Price
FROM Product
WHERE Price BETWEEN 1000 AND 5000;

-- 6. Search by category
SELECT Product_ID, Product_Name, Category, Price
FROM Product
WHERE Category = 'Electronics';

-- 7. Search available products
SELECT
    p.Product_ID,
    p.Product_Name,
    i.Stock_Quantity,
    i.Stock_Status
FROM Product p
JOIN Inventory i ON p.Product_ID = i.Product_ID
WHERE i.Stock_Quantity > 0;

-- 8. Retrieve customer information
SELECT
    Customer_ID,
    Customer_Name,
    Email,
    Phone
FROM Customer;

-- 9. Retrieve product information
SELECT
    Product_ID,
    Product_Name,
    Category,
    Price
FROM Product;

-- 10. Apply multiple filtering conditions
SELECT
    Product_ID,
    Product_Name,
    Category,
    Price
FROM Product
WHERE Price BETWEEN 1000 AND 5000
  AND Category = 'Electronics'
ORDER BY Price ASC;

-- 11. Basic business report: products by category
SELECT
    Category,
    COUNT(*) AS Product_Count
FROM Product
GROUP BY Category;

-- 12. Basic business report: inventory status
SELECT
    Stock_Status,
    COUNT(*) AS Product_Count
FROM Inventory
GROUP BY Stock_Status;
