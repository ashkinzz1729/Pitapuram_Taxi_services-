-- ============================================================
-- PROJECT 4: NYC Taxi Trip Analytics
-- Schema + Sample Data
-- Tool: PostgreSQL 14+
-- ============================================================

DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS trips CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS zones CASCADE;

-- ------------------------------------------------------------
-- TABLE 1: zones
-- ------------------------------------------------------------
CREATE TABLE zones (
    zone_id         SERIAL PRIMARY KEY,
    zone_name       VARCHAR(100),
    borough         VARCHAR(50),
    zone_type       VARCHAR(30)    -- Airport, Downtown, Suburb, Midtown
);

INSERT INTO zones (zone_name, borough, zone_type) VALUES
('JFK Airport',         'Queens',    'Airport'),
('Times Square',        'Manhattan', 'Midtown'),
('Brooklyn Bridge',     'Brooklyn',  'Downtown'),
('LaGuardia Airport',   'Queens',    'Airport'),
('Central Park',        'Manhattan', 'Midtown'),
('Bronx Zoo Area',      'Bronx',     'Suburb'),
('Staten Island Ferry', 'Staten Is.','Suburb'),
('Harlem',              'Manhattan', 'Downtown'),
('Flushing Meadows',    'Queens',    'Suburb'),
('Wall Street',         'Manhattan', 'Downtown');

-- ------------------------------------------------------------
-- TABLE 2: drivers
-- ------------------------------------------------------------
CREATE TABLE drivers (
    driver_id       SERIAL PRIMARY KEY,
    driver_name     VARCHAR(100),
    license_no      VARCHAR(20),
    rating          NUMERIC(3,1),
    joined_date     DATE,
    vehicle_type    VARCHAR(30)    -- Standard, SUV, Luxury
);

INSERT INTO drivers (driver_name, license_no, rating, joined_date, vehicle_type) VALUES
('Marcus Johnson',   'NYC-DRV-001', 4.8, '2020-03-15', 'Standard'),
('Carlos Rivera',    'NYC-DRV-002', 4.6, '2019-07-22', 'SUV'),
('Amit Patel',       'NYC-DRV-003', 4.9, '2021-01-10', 'Luxury'),
('James O Brien',    'NYC-DRV-004', 4.3, '2018-11-05', 'Standard'),
('Lin Wei',          'NYC-DRV-005', 4.7, '2020-08-30', 'Standard'),
('David Kim',        'NYC-DRV-006', 4.5, '2022-02-14', 'SUV'),
('Sofia Morales',    'NYC-DRV-007', 4.4, '2021-06-19', 'Standard'),
('Robert Brown',     'NYC-DRV-008', 4.8, '2019-04-25', 'Luxury');

-- ------------------------------------------------------------
-- TABLE 3: trips
-- ------------------------------------------------------------
CREATE TABLE trips (
    trip_id             SERIAL PRIMARY KEY,
    driver_id           INT REFERENCES drivers(driver_id),
    pickup_zone_id      INT REFERENCES zones(zone_id),
    dropoff_zone_id     INT REFERENCES zones(zone_id),
    pickup_datetime     TIMESTAMP,
    dropoff_datetime    TIMESTAMP,
    trip_distance_km    NUMERIC(6,2),
    passenger_count     INT,
    trip_status         VARCHAR(20)    -- Completed, Cancelled
);

INSERT INTO trips (driver_id, pickup_zone_id, dropoff_zone_id, pickup_datetime, dropoff_datetime, trip_distance_km, passenger_count, trip_status) VALUES
(1, 2,  1,  '2024-01-08 07:30:00', '2024-01-08 08:45:00', 28.5, 1, 'Completed'),
(2, 4,  2,  '2024-01-08 08:00:00', '2024-01-08 08:55:00', 22.3, 3, 'Completed'),
(3, 5,  3,  '2024-01-09 09:15:00', '2024-01-09 09:45:00', 8.2,  2, 'Completed'),
(4, 8,  10, '2024-01-09 17:30:00', '2024-01-09 18:10:00', 12.1, 1, 'Completed'),
(5, 1,  5,  '2024-01-10 06:45:00', '2024-01-10 07:50:00', 25.4, 2, 'Completed'),
(6, 2,  9,  '2024-01-10 19:00:00', '2024-01-10 19:50:00', 18.6, 1, 'Completed'),
(7, 6,  2,  '2024-01-11 08:20:00', '2024-01-11 09:30:00', 21.0, 4, 'Completed'),
(8, 3,  4,  '2024-01-11 12:00:00', '2024-01-11 13:15:00', 19.5, 2, 'Completed'),
(1, 10, 2,  '2024-01-15 07:00:00', '2024-01-15 07:40:00', 9.8,  1, 'Completed'),
(2, 5,  1,  '2024-01-15 18:30:00', '2024-01-15 19:45:00', 30.2, 3, 'Completed'),
(3, 2,  8,  '2024-01-16 10:00:00', '2024-01-16 10:30:00', 6.5,  1, 'Completed'),
(4, 9,  3,  '2024-01-16 21:00:00', '2024-01-16 21:45:00', 14.3, 2, 'Completed'),
(5, 4,  10, '2024-02-05 07:15:00', '2024-02-05 08:30:00', 23.1, 1, 'Completed'),
(6, 1,  2,  '2024-02-05 08:45:00', '2024-02-05 09:50:00', 27.8, 2, 'Completed'),
(7, 2,  5,  '2024-02-06 16:00:00', '2024-02-06 16:55:00', 11.2, 3, 'Completed'),
(8, 10, 4,  '2024-02-06 19:30:00', '2024-02-06 20:45:00', 26.4, 1, 'Completed'),
(1, 3,  2,  '2024-02-07 07:45:00', '2024-02-07 08:25:00', 10.5, 2, 'Completed'),
(2, 5,  3,  '2024-02-07 12:30:00', '2024-02-07 13:10:00', 8.9,  4, 'Cancelled'),
(3, 8,  1,  '2024-03-01 06:00:00', '2024-03-01 07:20:00', 32.1, 1, 'Completed'),
(4, 2,  6,  '2024-03-02 17:45:00', '2024-03-02 18:50:00', 20.7, 2, 'Completed');

-- ------------------------------------------------------------
-- TABLE 4: payments
-- ------------------------------------------------------------
CREATE TABLE payments (
    payment_id      SERIAL PRIMARY KEY,
    trip_id         INT REFERENCES trips(trip_id),
    base_fare       NUMERIC(10,2),
    distance_charge NUMERIC(10,2),
    surge_charge    NUMERIC(10,2),
    tip_amount      NUMERIC(10,2),
    total_fare      NUMERIC(10,2),
    payment_type    VARCHAR(20)    -- Cash, Credit Card, App Wallet
);

INSERT INTO payments (trip_id, base_fare, distance_charge, surge_charge, tip_amount, total_fare, payment_type) VALUES
(1,  3.50, 28.00, 5.00, 4.00, 40.50, 'Credit Card'),
(2,  3.50, 21.00, 3.00, 3.00, 30.50, 'App Wallet'),
(3,  3.50,  7.50, 0.00, 2.00, 13.00, 'Cash'),
(4,  3.50, 11.00, 2.50, 1.50, 18.50, 'Credit Card'),
(5,  3.50, 24.00, 4.00, 3.50, 35.00, 'App Wallet'),
(6,  3.50, 17.00, 0.00, 2.00, 22.50, 'Cash'),
(7,  3.50, 19.50, 3.50, 2.50, 29.00, 'Credit Card'),
(8,  3.50, 18.00, 0.00, 4.00, 25.50, 'App Wallet'),
(9,  3.50,  9.00, 0.00, 1.00, 13.50, 'Cash'),
(10, 3.50, 29.50, 6.00, 5.00, 44.00, 'Credit Card'),
(11, 3.50,  6.00, 0.00, 1.50, 11.00, 'App Wallet'),
(12, 3.50, 13.00, 2.00, 2.00, 20.50, 'Cash'),
(13, 3.50, 22.00, 4.50, 3.00, 33.00, 'Credit Card'),
(14, 3.50, 27.00, 5.50, 4.50, 40.50, 'App Wallet'),
(15, 3.50, 10.50, 1.50, 2.00, 17.50, 'Credit Card'),
(16, 3.50, 25.50, 5.00, 3.50, 37.50, 'Cash'),
(17, 3.50,  9.50, 0.00, 1.50, 14.50, 'App Wallet'),
(19, 3.50, 31.00, 6.50, 5.00, 46.00, 'Credit Card'),
(20, 3.50, 19.50, 3.00, 2.50, 28.50, 'App Wallet');
