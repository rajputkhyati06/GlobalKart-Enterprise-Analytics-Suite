-- ============================================================
-- PROJECT: GlobalKart Enterprise Data Engineering & Analytics Platform
-- ENGINE: PostgreSQL (pgAdmin 4 Compatible)
-- AUTHOR: Khyati Rajput (Lead Data Analyst)
-- FEATURES: Star Schema, Database Indexing, Audit Triggers, Stored Functions, Advanced Window Functions & RFM Segmentation
-- ============================================================

-- ------------------------------------------------------------
-- STEP 1: CLEANUP & SCHEMA CREATION
-- ------------------------------------------------------------
DROP TABLE IF EXISTS Audit_Logs CASCADE;
DROP TABLE IF EXISTS Fact_OrderItems CASCADE;
DROP TABLE IF EXISTS Fact_Orders CASCADE;
DROP TABLE IF EXISTS Dim_Products CASCADE;
DROP TABLE IF EXISTS Dim_Customers CASCADE;

-- 1. Dim_Customers Table
CREATE TABLE Dim_Customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    segment VARCHAR(30)
);

-- 2. Dim_Products Table
CREATE TABLE Dim_Products (
    product_id VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_cost NUMERIC(10,2),
    unit_price NUMERIC(10,2)
);

-- 3. Fact_Orders Table
CREATE TABLE Fact_Orders (
    order_id INT PRIMARY KEY,
    customer_id VARCHAR(20) REFERENCES Dim_Customers(customer_id),
    order_date DATE NOT NULL,
    shipping_date DATE,
    order_status VARCHAR(20),
    payment_mode VARCHAR(30)
);

-- 4. Fact_OrderItems Table
CREATE TABLE Fact_OrderItems (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES Fact_Orders(order_id),
    product_id VARCHAR(20) REFERENCES Dim_Products(product_id),
    quantity INT CHECK (quantity > 0),
    discount_pct NUMERIC(4,2) DEFAULT 0.00
);

-- 5. Audit_Logs Table (For Database Triggers)
CREATE TABLE Audit_Logs (
    log_id SERIAL PRIMARY KEY,
    order_id INT,
    old_status VARCHAR(20),
    new_status VARCHAR(20),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ------------------------------------------------------------
-- STEP 2: PERFORMANCE DATABASE INDEXING
-- ------------------------------------------------------------
CREATE INDEX idx_orders_date ON Fact_Orders(order_date);
CREATE INDEX idx_orders_customer ON Fact_Orders(customer_id);
CREATE INDEX idx_orderitems_product ON Fact_OrderItems(product_id);
CREATE INDEX idx_customers_city ON Dim_Customers(city);

-- ------------------------------------------------------------
-- STEP 3: DATABASE TRIGGER FOR ORDER STATUS CHANGES
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.order_status IS DISTINCT FROM NEW.order_status THEN
        INSERT INTO Audit_Logs (order_id, old_status, new_status)
        VALUES (NEW.order_id, OLD.order_status, NEW.order_status);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_order_status
AFTER UPDATE ON Fact_Orders
FOR EACH ROW
EXECUTE FUNCTION log_order_status_change();

-- ------------------------------------------------------------
-- STEP 4: STORED FUNCTION (CUSTOMER LIFETIME VALUE CALCULATOR)
-- ------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_get_customer_ltv(cust_id VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    total_ltv NUMERIC;
BEGIN
    SELECT COALESCE(SUM(i.quantity * p.unit_price * (1 - i.discount_pct)), 0.00)
    INTO total_ltv
    FROM Fact_Orders o
    JOIN Fact_OrderItems i ON o.order_id = i.order_id
    JOIN Dim_Products p ON i.product_id = p.product_id
    WHERE o.customer_id = cust_id AND o.order_status = 'Delivered';
    
    RETURN total_ltv;
END;
$$ LANGUAGE plpgsql;
