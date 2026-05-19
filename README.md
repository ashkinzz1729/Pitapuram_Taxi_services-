# Project 4: NYC Taxi Trip Analytics

## Business Problem
A ride-hailing company wants to identify peak demand hours, top-earning routes,
driver performance patterns, and payment behaviour across New York City boroughs.
This project uses PARTITION BY, time aggregations, and window functions to answer 10 operational questions.

## Dataset Overview

| Table | Description | Rows |
|-------|-------------|------|
| `zones` | NYC pickup/dropoff zones with borough and type | 10 |
| `drivers` | Driver profiles with ratings and vehicle type | 8 |
| `trips` | Trip records with timestamps, distance, status | 20 |
| `payments` | Fare breakdown — base, distance, surge, tip | 19 |

## SQL Concepts Used
- `EXTRACT(HOUR FROM ...)` — time-based grouping
- `DATE_TRUNC` — weekly aggregation
- `PARTITION BY` — per-driver and per-category window calculations
- `RANK()` — driver earnings ranking
- `SUM() OVER (ORDER BY ...)` — cumulative running earnings
- `CASE WHEN` with time ranges — rush hour / off-peak classification
- Multi-table `JOIN` across 4 tables

## Key Business Questions Answered
1. Revenue by hour of day — peak earning hours
2. Driver earnings ranked with cumulative total
3. Busiest pickup zones by trip count
4. Rush hour vs off-peak trip count and surge comparison
5. Average trip duration by borough
6. Top 3 most profitable routes (zone pairs)
7. Payment method preference and average tip
8. Weekly trip count and revenue trend
9. Driver rating vs earnings and tip received
10. Airport trips vs non-airport fare comparison

## Sample Query and Output

**Q4 — Rush hour vs off-peak using CASE:**
```sql
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 7 AND 10
            THEN 'Morning Rush (7-10am)'
        WHEN EXTRACT(HOUR FROM pickup_datetime) BETWEEN 17 AND 20
            THEN 'Evening Rush (5-8pm)'
        ELSE 'Off-peak'
    END AS time_bucket,
    COUNT(trip_id) AS total_trips,
    ROUND(AVG(total_fare), 2) AS avg_fare
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
WHERE trip_status = 'Completed'
GROUP BY time_bucket;
```

**Output:**
| time_bucket | total_trips | avg_fare |
|---|---|---|
| Morning Rush (7–10am) | 9 | 31.28 |
| Evening Rush (5–8pm) | 5 | 28.50 |
| Daytime Off-peak | 4 | 21.25 |
| Late Night | 1 | 20.50 |

## How to Run
1. Create database: `CREATE DATABASE nyc_taxi_db;`
2. Run `schema.sql` — creates all tables and inserts data
3. Run `queries.sql` — all 10 analysis queries

## Tools
- PostgreSQL 14+
- pgAdmin 4 / DBeaver
