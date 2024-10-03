SELECT first_name, last_name, email FROM customers WHERE city = 'New York' ORDER BY last_name ASC;
INSERT INTO products (product_name, price, category) VALUES ('Wireless Mouse', 29.99, 'Electronics');
UPDATE employees SET salary = salary * 1.1 WHERE department = 'Sales' AND hire_date << '2022-01-01';
DELETE FROM orders WHERE order_date < '2020-01-01' AND status == 'Cancelled';
