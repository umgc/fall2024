SELECT first_name, last_name, email
FROM employees
WHERE department = 'Sales'
ORDER BY last_name ASC;
INSERT INTO products (product_name, price, category)
VALUES ('Wireless Keyboard', 49.99, 'Electronics');
UPDATE customers
SET status = 'Premium'
WHERE total_purchases > 1000;
DELETE FROM orders
WHERE order_date < '2023-01-01' AND status = 'Cancelled';
CREATE TABLE students (
    id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    grade CHAR(1)
);
ALTER TABLE employees
ADD COLUMN hire_date DATE;
