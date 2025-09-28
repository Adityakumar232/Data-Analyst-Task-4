CREATE DATABASE ecommerce1;
use ecommerce1;
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status ENUM('Pending','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Credit Card','Debit Card','UPI','Net Banking','Cash on Delivery') NOT NULL,
    payment_status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
INSERT INTO users (full_name, email, password, phone, address) VALUES
('Rahul Sharma', 'rahul.sharma@example.com', 'pass123', '9876543210', 'Delhi, India'),
('Priya Verma', 'priya.verma@example.com', 'pass123', '9123456780', 'Mumbai, India'),
('Aman Singh', 'aman.singh@example.com', 'pass123', '9988776655', 'Bangalore, India'),
('Neha Kapoor', 'neha.kapoor@example.com', 'pass123', '9090909090', 'Kolkata, India'),
('Ravi Kumar', 'ravi.kumar@example.com', 'pass123', '9112233445', 'Chennai, India');
INSERT INTO categories (category_name, description) VALUES
('Electronics', 'Devices, gadgets, and accessories'),
('Fashion', 'Clothing and lifestyle products'),
('Home Appliances', 'Appliances and furniture for home');
INSERT INTO products (product_name, description, price, stock, category_id) VALUES
('Smartphone X10', 'Latest 5G smartphone with 128GB storage', 25000.00, 50, 1),
('Wireless Earbuds', 'Bluetooth noise-cancelling earbuds', 3500.00, 100, 1),
('Men T-Shirt', 'Cotton round-neck t-shirt', 599.00, 200, 2),
('Women Jeans', 'Denim skinny-fit jeans', 1200.00, 150, 2),
('Microwave Oven', '20L Solo microwave oven', 7500.00, 30, 3),
('Washing Machine', 'Fully automatic washing machine 7kg', 18000.00, 20, 3);
INSERT INTO orders (user_id, total_amount, status) VALUES
(1, 28500.00, 'Delivered'),
(2, 1799.00, 'Shipped'),
(3, 18000.00, 'Pending');
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 25000.00), -- Smartphone
(1, 2, 1, 3500.00),  -- Earbuds
(2, 3, 3, 1797.00),  -- 3 T-shirts
(3, 6, 1, 18000.00); -- Washing Machine
INSERT INTO payments (order_id, amount, payment_method, payment_status) VALUES
(1, 28500.00, 'Credit Card', 'Completed'),
(2, 1799.00, 'UPI', 'Completed'),
(3, 18000.00, 'Debit Card', 'Pending');
INSERT INTO reviews (product_id, user_id, rating, comment) VALUES
(1, 1, 5, 'Amazing smartphone! Worth the price.'),
(2, 1, 4, 'Good sound quality, battery could be better.'),
(3, 2, 4, 'Comfortable t-shirt, good fabric.'),
(6, 3, 5, 'Very efficient washing machine, saves time.');
SELECT product_name, price, stock
FROM products
WHERE price > 5000
ORDER BY price DESC;
SELECT c.category_name,COUNT(p.product_id) AS total_products
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name;
-- 3. INNER JOIN: Show all orders with customer names
SELECT o.order_id, u.full_name, o.total_amount, o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.user_id;

-- 4. LEFT JOIN: Show all products with their category (even if no category)
SELECT p.product_name, c.category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;

-- 5. RIGHT JOIN: Show all categories with products (some categories may be empty)
-- (Note: MySQL supports RIGHT JOIN, SQLite does not)
SELECT c.category_name, p.product_name
FROM products p
RIGHT JOIN categories c ON p.category_id = c.category_id;

-- 6. Find users who spent more than the average total order amount
SELECT full_name, user_id
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM orders
    GROUP BY user_id
    HAVING SUM(total_amount) > (
        SELECT AVG(total_amount) FROM orders
    )
);

-- 7. Get the most expensive product
SELECT product_name, price
FROM products
WHERE price = (SELECT MAX(price) FROM products);

-- 8. Average order amount
SELECT AVG(total_amount) AS avg_order_value
FROM orders;

-- 9. Total sales per product
SELECT p.product_name, SUM(oi.quantity * oi.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- 10. View for top customers (total spending)
CREATE VIEW top_customers AS
SELECT u.full_name, SUM(o.total_amount) AS total_spent
FROM orders o
JOIN users u ON o.user_id = u.user_id
GROUP BY u.full_name
ORDER BY total_spent DESC;

-- 11. View for product performance (sales + reviews)
CREATE VIEW product_performance AS
SELECT p.product_name, 
       COALESCE(SUM(oi.quantity), 0) AS total_sold,
       COALESCE(AVG(r.rating), 0) AS avg_rating
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_name;

-- 12. Create indexes for faster search
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_orders_userid ON orders(user_id);

-- Example optimized query using index:
SELECT * FROM users WHERE email = 'rahul.sharma@example.com';









