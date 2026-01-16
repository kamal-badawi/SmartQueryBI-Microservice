-- =====================================================
-- PRODUCT DIMENSION
-- =====================================================
INSERT INTO product_dim (product_id, product_name, category, brand, supplier, cost_price) VALUES
(gen_random_uuid(), 'Model S', 'Sedan', 'Tesla', 'Tesla Inc', 75000.00),
(gen_random_uuid(), 'Model 3', 'Sedan', 'Tesla', 'Tesla Inc', 45000.00),
(gen_random_uuid(), 'Mustang', 'Coupe', 'Ford', 'Ford Motors', 55000.00),
(gen_random_uuid(), 'F-150', 'Truck', 'Ford', 'Ford Motors', 40000.00),
(gen_random_uuid(), 'Civic', 'Sedan', 'Honda', 'Honda Ltd', 25000.00),
(gen_random_uuid(), 'Accord', 'Sedan', 'Honda', 'Honda Ltd', 30000.00),
(gen_random_uuid(), 'Corolla', 'Sedan', 'Toyota', 'Toyota Co', 22000.00),
(gen_random_uuid(), 'Camry', 'Sedan', 'Toyota', 'Toyota Co', 28000.00),
(gen_random_uuid(), 'RAV4', 'SUV', 'Toyota', 'Toyota Co', 35000.00),
(gen_random_uuid(), 'CX-5', 'SUV', 'Mazda', 'Mazda Motors', 32000.00);


-- =====================================================
-- EMPLOYEE DIMENSION
-- =====================================================
INSERT INTO employee_dim (employee_id, first_name, last_name, role, hire_date, department) VALUES
(gen_random_uuid(), 'Max', 'Müller', 'Salesperson', '2018-05-12', 'Sales'),
(gen_random_uuid(), 'Anna', 'Schmidt', 'Salesperson', '2019-03-01', 'Sales'),
(gen_random_uuid(), 'Lukas', 'Weber', 'Manager', '2015-07-23', 'Management'),
(gen_random_uuid(), 'Sophie', 'Fischer', 'Salesperson', '2020-01-15', 'Sales'),
(gen_random_uuid(), 'Tom', 'Neumann', 'Salesperson', '2021-09-30', 'Sales');


-- =====================================================
-- STORE DIMENSION
-- =====================================================
INSERT INTO store_dim (store_id, store_name, location, region, manager_id) VALUES
(gen_random_uuid(), 'AutoCity Berlin', 'Berlin', 'North',
 (SELECT employee_id FROM employee_dim 
  WHERE first_name='Lukas' AND last_name='Weber' 
  LIMIT 1)),
(gen_random_uuid(), 'CarWorld Hamburg', 'Hamburg', 'North',
 (SELECT employee_id FROM employee_dim 
  WHERE first_name='Lukas' AND last_name='Weber' 
  LIMIT 1)),
(gen_random_uuid(), 'Autohaus München', 'Munich', 'South',
 (SELECT employee_id FROM employee_dim 
  WHERE first_name='Lukas' AND last_name='Weber' 
  LIMIT 1)),
(gen_random_uuid(), 'Drive Frankfurt', 'Frankfurt', 'West',
 (SELECT employee_id FROM employee_dim 
  WHERE first_name='Lukas' AND last_name='Weber' 
  LIMIT 1));


-- =====================================================
-- CUSTOMER DIMENSION
-- =====================================================
INSERT INTO customer_dim (customer_id, first_name, last_name, email, phone, city, country) VALUES
(gen_random_uuid(), 'Jonas', 'Klein', 'jonas.klein@example.com', '01761234567', 'Berlin', 'Germany'),
(gen_random_uuid(), 'Laura', 'Becker', 'laura.becker@example.com', '01769876543', 'Hamburg', 'Germany'),
(gen_random_uuid(), 'Felix', 'Hofmann', 'felix.hofmann@example.com', '01763456789', 'Munich', 'Germany'),
(gen_random_uuid(), 'Marie', 'Wolf', 'marie.wolf@example.com', '01762345678', 'Frankfurt', 'Germany'),
(gen_random_uuid(), 'Lena', 'Schulz', 'lena.schulz@example.com', '01761239876', 'Berlin', 'Germany');


-- =====================================================
-- DATE DIMENSION (ONLY REQUIRED PERIOD)
-- =====================================================
INSERT INTO date_dim (date_id, year, month, day, quarter, weekday)
SELECT 
    d::date AS date_id,
    EXTRACT(YEAR FROM d)::int AS year,
    EXTRACT(MONTH FROM d)::int AS month,
    EXTRACT(DAY FROM d)::int AS day,
    EXTRACT(QUARTER FROM d)::int AS quarter,
    EXTRACT(DOW FROM d)::int + 1 AS weekday
FROM generate_series(
    '2025-11-01'::date,
    '2026-01-16'::date,
    interval '1 day'
) AS d;


-- =====================================================
-- SALES FACT (ONLY NOV 2025 – 16 JAN 2026)
-- =====================================================
DO $$
DECLARE
    i INTEGER;
    v_date_id DATE;
    v_product_id UUID;
    v_employee_id UUID;
    v_store_id UUID;
    v_customer_id UUID;
    v_quantity INTEGER;
    v_unit_price NUMERIC(10,2);
    v_discount NUMERIC(5,2);
    v_base_price NUMERIC(10,2);
BEGIN
    FOR i IN 1..300 LOOP

        -- Date only in requested period
        SELECT date_id
        INTO v_date_id
        FROM date_dim
        WHERE date_id BETWEEN '2025-11-01' AND '2026-01-16'
        ORDER BY RANDOM()
        LIMIT 1;

        -- Product
        SELECT product_id, cost_price
        INTO v_product_id, v_base_price
        FROM product_dim
        ORDER BY RANDOM()
        LIMIT 1;

        -- Salesperson
        SELECT employee_id
        INTO v_employee_id
        FROM employee_dim
        WHERE role = 'Salesperson'
        ORDER BY RANDOM()
        LIMIT 1;

        -- Store
        SELECT store_id
        INTO v_store_id
        FROM store_dim
        ORDER BY RANDOM()
        LIMIT 1;

        -- Customer
        SELECT customer_id
        INTO v_customer_id
        FROM customer_dim
        ORDER BY RANDOM()
        LIMIT 1;

        -- Quantity
        v_quantity := CASE
            WHEN RANDOM() < 0.8 THEN 1
            WHEN RANDOM() < 0.95 THEN 2
            ELSE 3
        END;

        -- Price with margin
        v_unit_price := v_base_price * (1.1 + RANDOM() * 0.2);

        -- Discount
        v_discount := CASE
            WHEN RANDOM() < 0.6 THEN 0
            WHEN RANDOM() < 0.9 THEN ROUND((RANDOM() * 10)::numeric, 2)
            ELSE ROUND((RANDOM() * 20)::numeric, 2)
        END;

        INSERT INTO sales_fact
            (date_id, product_id, employee_id, store_id, customer_id,
             quantity, unit_price, discount)
        VALUES
            (v_date_id, v_product_id, v_employee_id, v_store_id,
             v_customer_id, v_quantity, v_unit_price, v_discount);
    END LOOP;
END $$;


