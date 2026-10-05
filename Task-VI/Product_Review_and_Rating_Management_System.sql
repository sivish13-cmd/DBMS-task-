-- TASK VI: Product Review and Rating Management System

CREATE TABLE Review (
    Review_ID INT PRIMARY KEY,
    Product_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    Review_Text VARCHAR(500),
    Review_Date DATE NOT NULL,
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

CREATE TABLE Rating (
    Rating_ID INT PRIMARY KEY,
    Product_ID INT NOT NULL,
    Customer_ID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID),
    FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)
);

-- Insert customer reviews
INSERT INTO Review
(Review_ID, Product_ID, Customer_ID, Review_Text, Review_Date)
VALUES
(1, 101, 1, 'Good product and fast delivery.', '2026-10-05');

-- Insert ratings
INSERT INTO Rating
(Rating_ID, Product_ID, Customer_ID, Rating)
VALUES
(1, 101, 1, 5);

-- Retrieve product reviews
SELECT
    r.Review_ID,
    r.Product_ID,
    c.Customer_Name,
    r.Review_Text,
    r.Review_Date
FROM Review r
JOIN Customer c ON r.Customer_ID = c.Customer_ID
WHERE r.Product_ID = 101;

-- Calculate average product ratings
SELECT
    Product_ID,
    AVG(Rating) AS Average_Rating
FROM Rating
GROUP BY Product_ID;

-- Identify highly rated products
SELECT
    Product_ID,
    AVG(Rating) AS Average_Rating
FROM Rating
GROUP BY Product_ID
HAVING AVG(Rating) >= 4.0
ORDER BY Average_Rating DESC;
