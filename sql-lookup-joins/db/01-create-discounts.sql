CREATE TABLE customer_discounts (
    customer_id VARCHAR(50) PRIMARY KEY,
    discount DECIMAL(5, 2) NOT NULL
);

INSERT INTO customer_discounts (customer_id, discount)
VALUES
    ('u123', 10.00),
    ('u456', 15.00),
    ('u789', 5.00);
