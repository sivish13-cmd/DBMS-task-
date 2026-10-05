-- TASK V: Payment Transaction Management System

CREATE TABLE Payment (
    Payment_ID INT PRIMARY KEY,
    Order_ID INT NOT NULL,
    Payment_Mode VARCHAR(30) NOT NULL,
    Payment_Date DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Payment_Status VARCHAR(20) NOT NULL,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID)
);

-- Insert payment transactions
INSERT INTO Payment
(Payment_ID, Order_ID, Payment_Mode, Payment_Date, Amount, Payment_Status)
VALUES
(501, 1001, 'UPI', '2026-10-05', 2750.00, 'Successful');

INSERT INTO Payment
(Payment_ID, Order_ID, Payment_Mode, Payment_Date, Amount, Payment_Status)
VALUES
(502, 1002, 'Credit Card', '2026-10-05', 1800.00, 'Failed');

-- Update a failed transaction
UPDATE Payment
SET Payment_Status = 'Successful'
WHERE Payment_ID = 502;

-- Successful transactions
SELECT *
FROM Payment
WHERE Payment_Status = 'Successful';

-- Failed transactions
SELECT *
FROM Payment
WHERE Payment_Status = 'Failed';

-- Analyze payment methods
SELECT
    Payment_Mode,
    COUNT(*) AS Total_Transactions,
    SUM(Amount) AS Total_Amount
FROM Payment
GROUP BY Payment_Mode;

-- Payment transaction report
SELECT
    p.Payment_ID,
    p.Order_ID,
    c.Customer_Name,
    p.Payment_Mode,
    p.Payment_Date,
    p.Amount,
    p.Payment_Status
FROM Payment p
JOIN Orders o ON p.Order_ID = o.Order_ID
JOIN Customer c ON o.Customer_ID = c.Customer_ID
ORDER BY p.Payment_Date DESC;
