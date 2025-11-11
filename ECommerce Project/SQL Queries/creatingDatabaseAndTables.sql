-- Create database
CREATE DATABASE olist_ecommerce;

-- Create tables with proper schema
CREATE TABLE olist_customers (
    customer_id VARCHAR(255) PRIMARY KEY,
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(255),
    customer_state VARCHAR(2)
);

CREATE TABLE olist_sellers (
    seller_id VARCHAR(255) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(255),
    seller_state VARCHAR(2)
);

CREATE TABLE olist_products (
    product_id VARCHAR(255) PRIMARY KEY,
    product_category_name VARCHAR(255),
    product_name_length INTEGER,
    product_description_length INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE olist_orders (
    order_id VARCHAR(255) PRIMARY KEY,
    customer_id VARCHAR(255),
    order_status VARCHAR(50),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES olist_customers(customer_id)
);

CREATE TABLE olist_order_items (
    order_id VARCHAR(255),
    order_item_id INTEGER,
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES olist_orders(order_id),
    FOREIGN KEY (product_id) REFERENCES olist_products(product_id),
    FOREIGN KEY (seller_id) REFERENCES olist_sellers(seller_id)
);

CREATE TABLE olist_order_payments (
    order_id VARCHAR(255),
    payment_sequential INTEGER,
    payment_type VARCHAR(50),
    payment_installments INTEGER,
    payment_value DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES olist_orders(order_id)
);

CREATE TABLE olist_order_reviews (
    review_id VARCHAR(255) PRIMARY KEY,
    order_id VARCHAR(255),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES olist_orders(order_id)
);

CREATE TABLE olist_geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DECIMAL(10,8),
    geolocation_lng DECIMAL(10,8),
    geolocation_city VARCHAR(255),
    geolocation_state VARCHAR(2)
);


-- Import data (adjust file paths as needed)
COPY olist_customers FROM 'C:/Program Files/PostgreSQL/17/data/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY olist_sellers FROM 'C:/Program Files/PostgreSQL/17/data/olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY olist_products FROM 'C:/Program Files/PostgreSQL/17/data/olist_products_dataset.csv' DELIMITER ',' CSV HEADER;
COPY olist_orders FROM 'C:/Program Files/PostgreSQL/17/data/olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;
COPY olist_order_items FROM 'C:/Program Files/PostgreSQL/17/data/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;
COPY olist_order_payments FROM 'C:/Program Files/PostgreSQL/17/data/olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;

-- since there was error in precision we alter the table to double precision
ALTER TABLE olist_geolocation
ALTER COLUMN geolocation_lng TYPE DOUBLE PRECISION,
ALTER COLUMN geolocation_lat TYPE DOUBLE PRECISION;

COPY olist_geolocation FROM 'C:/Program Files/PostgreSQL/17/data/olist_geolocation_dataset.csv' DELIMITER ',' CSV HEADER;

--When we copy the csv to populate the data into table olist_order_reviews; here in the orginal csv file there are duplicates in the order id so we are not able to create it as the primary key. So to handle that error we are going to take the following steps
COPY olist_order_reviews FROM 'C:/Program Files/PostgreSQL/17/data/olist_order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;

-- Step1: Clear existing data
TRUNCATE TABLE olist_order_reviews CASCADE;

-- Step2: Temp table
CREATE TEMP TABLE temp_reviews AS SELECT * FROM olist_order_reviews WITH NO DATA;

-- Step3: Load CSV
COPY temp_reviews FROM 'C:/Program Files/PostgreSQL/17/data/olist_order_reviews_dataset.csv' 
DELIMITER ',' CSV HEADER;

-- Step4: Insert unique records (keep latest)
INSERT INTO olist_order_reviews
SELECT DISTINCT ON (review_id) *
FROM temp_reviews
ORDER BY review_id, review_creation_date DESC;
