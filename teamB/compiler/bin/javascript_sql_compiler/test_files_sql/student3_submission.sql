SELECT product_name, price, category
FROM products
WHERE price < 100
ORDER BY price DISCO;
INSERT INTO customers (first_name, last_name, email)
VALUES ('John', 'Doe', 'john.doe@example.com');
UPDATE orders
SET status = 'Shipped'
WHERE order_id = 1234;
DELETE FROM inventory
WHERE quantity = 0 AND last_updated < '2023-01-01';
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date DATE,
    salary DECIMAL(10, 2)
);
