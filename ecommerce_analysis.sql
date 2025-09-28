
-- ============================================
-- E-commerce Database SQL Practice Queries
-- ============================================

-- A. SELECT, WHERE, ORDER BY, GROUP BY

-- 1. Get all products above ₹5000, ordered by price descending
SELECT product_name, price, stock
FROM products
WHERE price > 5000
ORDER BY price DESC;

-- 2. Find total number of products in each category
SELECT c.category_name, COUNT(p.product_id) AS total_products
FROM categories c
LEFT JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name;

-- B. JOINS (INNER, LEFT, RIGHT)

-- 3. INNER JOIN: Show all orders with customer names
SELECT o.order_id, u.full_name, o.total_amount, o.status
FROM orders o
INNER JOIN users u ON o.user_id = u.user_id;

-- 4. LEFT JOIN: Show all products with their category (even if no category)
SELECT p.product_name, c.category_name
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id;

-- 5. RIGHT JOIN: Show all categories with products (some categories may be empty)
SELECT c.category_name, p.product_name
FROM products p
RIGHT JOIN categories c ON p.category_id = c.category_id;

-- C. Subqueries

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

-- D. Aggregate Functions (SUM, AVG, COUNT)

-- 8. Average order amount
SELECT AVG(total_amount) AS avg_order_value
FROM orders;

-- 9. Total sales per product
SELECT p.product_name, SUM(oi.quantity * oi.price) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- E. Create Views for Analysis

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

-- F. Optimize Queries with Indexes

-- 12. Create indexes for faster search
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_orders_userid ON orders(user_id);

-- Example optimized query using index:
SELECT * FROM users WHERE email = 'rahul.sharma@example.com';
