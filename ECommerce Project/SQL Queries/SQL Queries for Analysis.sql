-- Overall Business Metrics
SELECT 
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as total_customers,
    ROUND(SUM(payment_value)::numeric, 2) as total_revenue,
    ROUND(AVG(payment_value)::numeric, 2) as avg_order_value
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE order_status = 'delivered';

--Monthly Sales Trend
SELECT 
    DATE_TRUNC('month', order_purchase_timestamp) as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(payment_value)::numeric, 2) as revenue
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE order_status = 'delivered'
GROUP BY month
ORDER BY month;

--Top 10 Product Categories by Revenue
SELECT 
    COALESCE(pr.product_category_name, 'Unknown') as category,
    COUNT(DISTINCT oi.order_id) as total_orders,
    ROUND(SUM(oi.price)::numeric, 2) as revenue,
    ROUND(AVG(oi.price)::numeric, 2) as avg_price
FROM olist_order_items oi
JOIN olist_products pr ON oi.product_id = pr.product_id
JOIN olist_orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY pr.product_category_name
ORDER BY revenue DESC
LIMIT 10;


-- Sales by State (Geographic Analysis)
SELECT 
    c.customer_state as state,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) as revenue,
    COUNT(DISTINCT c.customer_id) as unique_customers
FROM olist_orders o
JOIN olist_customers c ON o.customer_id = c.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- Payment Method Analysis
SELECT 
    payment_type,
    COUNT(*) as transaction_count,
    ROUND(SUM(payment_value)::numeric, 2) as total_value,
    ROUND(AVG(payment_value)::numeric, 2) as avg_value,
    ROUND(AVG(payment_installments)::numeric, 2) as avg_installments
FROM olist_order_payments
GROUP BY payment_type
ORDER BY total_value DESC;


-- Customer Review Analysis
SELECT 
    review_score,
    COUNT(*) as review_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM olist_order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- Delivery Performance Analysis
SELECT 
    ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp))/86400)::numeric, 2) as avg_delivery_days,
    ROUND(AVG(EXTRACT(EPOCH FROM (order_estimated_delivery_date - order_delivered_customer_date))/86400)::numeric, 2) as avg_delay_days,
    COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) as delayed_orders,
    COUNT(*) as total_delivered_orders,
    ROUND(COUNT(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 END) * 100.0 / COUNT(*), 2) as delay_percentage
FROM olist_orders
WHERE order_status = 'delivered' 
    AND order_delivered_customer_date IS NOT NULL;


-- Top 10 Sellers by Revenue
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) as total_orders,
    ROUND(SUM(oi.price + oi.freight_value)::numeric, 2) as total_revenue,
    ROUND(AVG(r.review_score)::numeric, 2) as avg_review_score
FROM olist_sellers s
JOIN olist_order_items oi ON s.seller_id = oi.seller_id
JOIN olist_orders o ON oi.order_id = o.order_id
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


--RFM Analysis (Customer Segmentation)
WITH customer_rfm AS (
    SELECT 
        c.customer_unique_id,
        MAX(o.order_purchase_timestamp) as last_purchase_date,
        COUNT(DISTINCT o.order_id) as frequency,
        ROUND(SUM(p.payment_value)::numeric, 2) as monetary
    FROM olist_customers c
    JOIN olist_orders o ON c.customer_id = o.customer_id
    JOIN olist_order_payments p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT 
        customer_unique_id,
        EXTRACT(EPOCH FROM (CURRENT_DATE - last_purchase_date::timestamp))::numeric/86400 as recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY EXTRACT(EPOCH FROM (CURRENT_DATE - last_purchase_date::timestamp))::numeric/86400 DESC) as r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) as f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) as m_score
    FROM customer_rfm
)
SELECT 
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 3 AND f_score < 3 THEN 'Potential Loyalists'
        WHEN r_score < 3 AND f_score >= 3 THEN 'At Risk'
        ELSE 'Need Attention'
    END as customer_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(monetary)::numeric, 2) as avg_monetary_value,
    ROUND(AVG(frequency)::numeric, 2) as avg_frequency
FROM rfm_scores
GROUP BY customer_segment
ORDER BY customer_count DESC;


-- Order Status Distribution
SELECT 
    order_status,
    COUNT(*) as order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM olist_orders
GROUP BY order_status
ORDER BY order_count DESC;


-- Day of Week Sales Pattern
SELECT 
    TO_CHAR(order_purchase_timestamp, 'Day') as day_of_week,
    EXTRACT(DOW FROM order_purchase_timestamp) as day_number,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) as revenue
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY day_of_week, day_number
ORDER BY day_number;


-- Product Price Range Analysis
WITH product_ranges AS (
    SELECT 
        CASE 
            WHEN price < 50 THEN '0-50'
            WHEN price < 100 THEN '50-100'
            WHEN price < 200 THEN '100-200'
            WHEN price < 500 THEN '200-500'
            ELSE '500+'
        END AS price_range,
        price
    FROM olist_order_items
)
SELECT 
    price_range,
    COUNT(*) AS product_count,
    ROUND(SUM(price)::numeric, 2) AS total_revenue
FROM product_ranges
GROUP BY price_range
ORDER BY 
    CASE price_range
        WHEN '0-50' THEN 1
        WHEN '50-100' THEN 2
        WHEN '100-200' THEN 3
        WHEN '200-500' THEN 4
        ELSE 5
    END;


-- Seller Performance with Reviews
SELECT 
    s.seller_state,
    COUNT(DISTINCT s.seller_id) as seller_count,
    COUNT(DISTINCT oi.order_id) as total_orders,
    ROUND(AVG(r.review_score)::numeric, 2) as avg_review_score,
    ROUND(SUM(oi.price)::numeric, 2) as total_revenue
FROM olist_sellers s
JOIN olist_order_items oi ON s.seller_id = oi.seller_id
JOIN olist_orders o ON oi.order_id = o.order_id
LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
HAVING COUNT(DISTINCT oi.order_id) > 100
ORDER BY total_revenue DESC;



-- Year-over-Year Growth
SELECT 
    EXTRACT(YEAR FROM order_purchase_timestamp) as year,
    EXTRACT(MONTH FROM order_purchase_timestamp) as month,
    COUNT(DISTINCT o.order_id) as orders,
    ROUND(SUM(p.payment_value)::numeric, 2) as revenue,
    LAG(ROUND(SUM(p.payment_value)::numeric, 2)) OVER (
        PARTITION BY EXTRACT(MONTH FROM order_purchase_timestamp) 
        ORDER BY EXTRACT(YEAR FROM order_purchase_timestamp)
    ) as prev_year_revenue
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;


-- Customer Lifetime Value (Top Customers)
SELECT 
    c.customer_unique_id,
    c.customer_state,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(SUM(p.payment_value)::numeric, 2) as lifetime_value,
    ROUND(AVG(p.payment_value)::numeric, 2) as avg_order_value,
    MIN(o.order_purchase_timestamp) as first_purchase,
    MAX(o.order_purchase_timestamp) as last_purchase
FROM olist_customers c
JOIN olist_orders o ON c.customer_id = o.customer_id
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id, c.customer_state
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY lifetime_value DESC
LIMIT 20;