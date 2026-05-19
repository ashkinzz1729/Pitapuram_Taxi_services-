-- ============================================================
-- PROJECT 4: NYC Taxi Trip Analytics
-- Queries File — 10 Business Questions
-- Tool: PostgreSQL 14+
-- ============================================================


-- Q1: Revenue by hour of day — identify peak earning hours (EXTRACT + PARTITION BY)
SELECT
    EXTRACT(HOUR FROM t.pickup_datetime)                            AS pickup_hour,
    COUNT(t.trip_id)                                                AS total_trips,
    ROUND(AVG(p.total_fare), 2)                                     AS avg_fare,
    SUM(p.total_fare)                                               AS total_revenue,
    RANK() OVER (ORDER BY SUM(p.total_fare) DESC)                   AS revenue_rank
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY EXTRACT(HOUR FROM t.pickup_datetime)
ORDER BY pickup_hour;


-- Q2: Driver earnings ranked with cumulative total (PARTITION BY + running sum)
SELECT
    d.driver_name,
    d.vehicle_type,
    COUNT(t.trip_id)                                                AS trips_completed,
    SUM(p.total_fare)                                               AS total_earnings,
    RANK() OVER (ORDER BY SUM(p.total_fare) DESC)                   AS earnings_rank,
    SUM(SUM(p.total_fare)) OVER (ORDER BY SUM(p.total_fare) DESC)   AS cumulative_earnings
FROM drivers d
JOIN trips t    ON d.driver_id = t.driver_id AND t.trip_status = 'Completed'
JOIN payments p ON t.trip_id   = p.trip_id
GROUP BY d.driver_name, d.vehicle_type
ORDER BY earnings_rank;


-- Q3: Busiest pickup zones by trip count
SELECT
    z.zone_name,
    z.borough,
    z.zone_type,
    COUNT(t.trip_id)                AS total_pickups,
    ROUND(AVG(p.total_fare), 2)     AS avg_fare_from_zone
FROM trips t
JOIN zones z    ON t.pickup_zone_id = z.zone_id
JOIN payments p ON t.trip_id        = p.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY z.zone_name, z.borough, z.zone_type
ORDER BY total_pickups DESC;


-- Q4: Rush hour vs off-peak comparison using CASE + time buckets
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 7  AND 10 THEN 'Morning Rush (7–10am)'
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 17 AND 20 THEN 'Evening Rush (5–8pm)'
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 22 AND 23
          OR EXTRACT(HOUR FROM pickup_datetime) BETWEEN 0  AND 5  THEN 'Late Night (10pm–5am)'
        ELSE 'Daytime Off-peak'
    END                             AS time_bucket,
    COUNT(t.trip_id)                AS total_trips,
    ROUND(AVG(p.total_fare), 2)     AS avg_fare,
    ROUND(AVG(p.surge_charge), 2)   AS avg_surge
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY time_bucket
ORDER BY avg_fare DESC;


-- Q5: Average trip duration in minutes by borough (pickup side)
SELECT
    z.borough,
    COUNT(t.trip_id)                                                        AS total_trips,
    ROUND(AVG(EXTRACT(EPOCH FROM (t.dropoff_datetime - t.pickup_datetime)) / 60), 2)
                                                                            AS avg_duration_mins,
    ROUND(AVG(t.trip_distance_km), 2)                                       AS avg_distance_km
FROM trips t
JOIN zones z ON t.pickup_zone_id = z.zone_id
WHERE t.trip_status = 'Completed'
GROUP BY z.borough
ORDER BY avg_duration_mins DESC;


-- Q6: Top 3 most profitable routes (pickup → dropoff zone pairs)
SELECT
    pz.zone_name                    AS pickup_zone,
    dz.zone_name                    AS dropoff_zone,
    COUNT(t.trip_id)                AS trip_count,
    ROUND(AVG(t.trip_distance_km), 2) AS avg_distance_km,
    SUM(p.total_fare)               AS total_revenue
FROM trips t
JOIN zones pz   ON t.pickup_zone_id  = pz.zone_id
JOIN zones dz   ON t.dropoff_zone_id = dz.zone_id
JOIN payments p ON t.trip_id         = p.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY pz.zone_name, dz.zone_name
ORDER BY total_revenue DESC
LIMIT 3;


-- Q7: Payment method preference and average tip by type
SELECT
    payment_type,
    COUNT(payment_id)           AS transaction_count,
    ROUND(AVG(tip_amount), 2)   AS avg_tip,
    ROUND(AVG(total_fare), 2)   AS avg_fare,
    SUM(total_fare)             AS total_collected
FROM payments
GROUP BY payment_type
ORDER BY total_collected DESC;


-- Q8: Weekly trip count and revenue trend
SELECT
    DATE_TRUNC('week', t.pickup_datetime)::DATE     AS week_start,
    COUNT(t.trip_id)                                AS weekly_trips,
    SUM(p.total_fare)                               AS weekly_revenue,
    ROUND(AVG(p.total_fare), 2)                     AS avg_fare
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY DATE_TRUNC('week', t.pickup_datetime)
ORDER BY week_start;


-- Q9: Driver earnings vs their rating (correlation view)
SELECT
    d.driver_name,
    d.rating,
    d.vehicle_type,
    COUNT(t.trip_id)            AS trips,
    SUM(p.total_fare)           AS total_earned,
    ROUND(AVG(p.tip_amount), 2) AS avg_tip_received
FROM drivers d
JOIN trips t    ON d.driver_id = t.driver_id AND t.trip_status = 'Completed'
JOIN payments p ON t.trip_id   = p.trip_id
GROUP BY d.driver_name, d.rating, d.vehicle_type
ORDER BY d.rating DESC;


-- Q10: Airport trips vs non-airport — fare and surge comparison
SELECT
    CASE
        WHEN z.zone_type = 'Airport' THEN 'Airport Trip'
        ELSE 'Non-Airport Trip'
    END                             AS trip_category,
    COUNT(t.trip_id)                AS total_trips,
    ROUND(AVG(p.total_fare), 2)     AS avg_total_fare,
    ROUND(AVG(p.surge_charge), 2)   AS avg_surge_charge,
    ROUND(AVG(t.trip_distance_km), 2) AS avg_distance_km
FROM trips t
JOIN zones z    ON t.pickup_zone_id = z.zone_id
JOIN payments p ON t.trip_id        = p.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY trip_category
ORDER BY avg_total_fare DESC;
