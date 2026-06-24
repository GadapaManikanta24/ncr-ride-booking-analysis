-- ============================================================
-- NCR RIDE BOOKING ANALYSIS — SQL QUERIES
-- Database : govt
-- Table    : cleaned_ride_bookings
-- ============================================================


-- ============================================================
-- SECTION 1 : KPI SUMMARY
-- ============================================================

-- Total Bookings
SELECT COUNT(*) AS total_bookings
FROM cleaned_ride_bookings;

-- Completed Rides
SELECT COUNT(*) AS completed_rides
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed';

-- Overall Completion Rate
SELECT ROUND(
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cleaned_ride_bookings), 2
) AS completion_rate
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed';

-- Total Revenue (completed rides only)
SELECT SUM(`Booking Value`) AS total_revenue
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed';

-- Average Booking Value (completed rides only)
SELECT ROUND(AVG(`Booking Value`), 2) AS avg_booking_value
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed';


-- ============================================================
-- SECTION 2 : BOOKING STATUS ANALYSIS
-- ============================================================

-- Booking Status Distribution with Percentage
SELECT
    `Booking Status`,
    COUNT(*) AS total_bookings,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cleaned_ride_bookings), 2
    ) AS percentage
FROM cleaned_ride_bookings
GROUP BY `Booking Status`
ORDER BY total_bookings DESC;


-- ============================================================
-- SECTION 3 : REVENUE ANALYSIS
-- ============================================================

-- Revenue by Vehicle Type
SELECT
    `Vehicle Type`,
    SUM(`Booking Value`) AS revenue
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY revenue DESC;

-- Average Booking Value by Vehicle Type
SELECT
    `Vehicle Type`,
    ROUND(AVG(`Booking Value`), 2) AS avg_booking_value
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY avg_booking_value DESC;

-- Revenue Share by Vehicle Type
SELECT
    `Vehicle Type`,
    SUM(`Booking Value`) AS revenue,
    ROUND(
        SUM(`Booking Value`) * 100.0 /
        (SELECT SUM(`Booking Value`) FROM cleaned_ride_bookings WHERE `Booking Status` = 'Completed'),
        2
    ) AS revenue_share_pct
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY revenue DESC;

-- Revenue per Kilometer by Vehicle Type
SELECT
    `Vehicle Type`,
    ROUND(SUM(`Booking Value`) / SUM(`Ride Distance`), 2) AS revenue_per_km
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY revenue_per_km DESC;


-- ============================================================
-- SECTION 4 : DISTANCE ANALYSIS
-- ============================================================

-- Overall Average Ride Distance
SELECT ROUND(AVG(`Ride Distance`), 2) AS avg_distance
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed';

-- Average Distance by Vehicle Type
SELECT
    `Vehicle Type`,
    ROUND(AVG(`Ride Distance`), 2) AS avg_distance
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY avg_distance DESC;


-- ============================================================
-- SECTION 5 : CANCELLATION ANALYSIS
-- ============================================================

-- Customer Cancellation Reasons
SELECT
    `Reason for cancelling by Customer`,
    COUNT(*) AS total_cancellations
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Cancelled by Customer'
GROUP BY `Reason for cancelling by Customer`
ORDER BY total_cancellations DESC;

-- Driver Cancellation Reasons
SELECT
    `Driver Cancellation Reason`,
    COUNT(*) AS total_cancellations
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Cancelled by Driver'
GROUP BY `Driver Cancellation Reason`
ORDER BY total_cancellations DESC;

-- Cancellation Rate by Vehicle Type
SELECT
    `Vehicle Type`,
    ROUND(
        SUM(CASE
            WHEN `Booking Status` IN ('Cancelled by Customer', 'Cancelled by Driver') THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*), 2
    ) AS cancellation_rate
FROM cleaned_ride_bookings
GROUP BY `Vehicle Type`
ORDER BY cancellation_rate DESC;


-- ============================================================
-- SECTION 6 : CUSTOMER EXPERIENCE
-- ============================================================

-- Average Customer Rating
SELECT ROUND(AVG(`Customer Rating`), 2) AS avg_customer_rating
FROM cleaned_ride_bookings
WHERE `Customer Rating` IS NOT NULL;

-- Average Driver Rating
SELECT ROUND(AVG(`Driver Ratings`), 2) AS avg_driver_rating
FROM cleaned_ride_bookings
WHERE `Driver Ratings` IS NOT NULL;

-- Customer Rating by Vehicle Type
SELECT
    `Vehicle Type`,
    ROUND(AVG(`Customer Rating`), 2) AS avg_customer_rating
FROM cleaned_ride_bookings
WHERE `Customer Rating` IS NOT NULL
GROUP BY `Vehicle Type`
ORDER BY avg_customer_rating DESC;


-- ============================================================
-- SECTION 7 : OPERATIONAL METRICS (VTAT / CTAT)
-- ============================================================

-- Overall Average Wait Times
SELECT
    ROUND(AVG(`Avg VTAT`), 2) AS avg_vtat,
    ROUND(AVG(`Avg CTAT`), 2) AS avg_ctat
FROM cleaned_ride_bookings;

-- Wait Times by Booking Status
SELECT
    `Booking Status`,
    ROUND(AVG(`Avg CTAT`), 2) AS avg_ctat,
    ROUND(AVG(`Avg VTAT`), 2) AS avg_vtat
FROM cleaned_ride_bookings
GROUP BY `Booking Status`;


-- ============================================================
-- SECTION 8 : PAYMENT ANALYSIS
-- ============================================================

-- Payment Method Distribution
SELECT
    `Payment Method`,
    COUNT(*) AS total_transactions
FROM cleaned_ride_bookings
WHERE `Payment Method` IS NOT NULL
GROUP BY `Payment Method`
ORDER BY total_transactions DESC;

-- Average Booking Value by Payment Method
SELECT
    `Payment Method`,
    ROUND(AVG(`Booking Value`), 2) AS avg_booking_value
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Payment Method`
ORDER BY avg_booking_value DESC;


-- ============================================================
-- SECTION 9 : LOCATION ANALYSIS
-- ============================================================

-- Top 10 Pickup Locations
SELECT
    `Pickup Location`,
    COUNT(*) AS total_bookings
FROM cleaned_ride_bookings
GROUP BY `Pickup Location`
ORDER BY total_bookings DESC
LIMIT 10;

-- Top 10 Drop Locations
SELECT
    `Drop Location`,
    COUNT(*) AS total_bookings
FROM cleaned_ride_bookings
GROUP BY `Drop Location`
ORDER BY total_bookings DESC
LIMIT 10;

-- Top 10 Routes (Completed rides only)
SELECT
    `Pickup Location`,
    `Drop Location`,
    COUNT(*) AS total_rides
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Pickup Location`, `Drop Location`
ORDER BY total_rides DESC
LIMIT 10;


-- ============================================================
-- SECTION 10 : WINDOW FUNCTIONS — ADVANCED ANALYSIS
-- ============================================================

-- ------------------------------------------------------------
-- 10A : RANK vehicle types by revenue
-- Shows which vehicle type is #1, #2 etc. in revenue
-- Uses RANK() window function
-- ------------------------------------------------------------
SELECT
    `Vehicle Type`,
    SUM(`Booking Value`)                             AS revenue,
    RANK() OVER (ORDER BY SUM(`Booking Value`) DESC) AS revenue_rank
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`;


-- ------------------------------------------------------------
-- 10B : RANK cancellation reasons within each cancellation type
-- Shows top reason per cancellation side (customer vs driver)
-- Uses RANK() partitioned by cancellation type
-- ------------------------------------------------------------
SELECT
    cancellation_type,
    reason,
    total_cancellations,
    RANK() OVER (
        PARTITION BY cancellation_type
        ORDER BY total_cancellations DESC
    ) AS reason_rank
FROM (
    SELECT
        'Customer' AS cancellation_type,
        `Reason for cancelling by Customer` AS reason,
        COUNT(*) AS total_cancellations
    FROM cleaned_ride_bookings
    WHERE `Booking Status` = 'Cancelled by Customer'
    GROUP BY `Reason for cancelling by Customer`

    UNION ALL

    SELECT
        'Driver' AS cancellation_type,
        `Driver Cancellation Reason` AS reason,
        COUNT(*) AS total_cancellations
    FROM cleaned_ride_bookings
    WHERE `Booking Status` = 'Cancelled by Driver'
    GROUP BY `Driver Cancellation Reason`
) AS combined_reasons
ORDER BY cancellation_type, reason_rank;


-- ------------------------------------------------------------
-- 10C : RUNNING TOTAL of revenue by vehicle type
-- Shows cumulative revenue as you go down the ranked list
-- Uses SUM() OVER with ORDER BY (cumulative window)
-- ------------------------------------------------------------
SELECT
    `Vehicle Type`,
    SUM(`Booking Value`) AS revenue,
    ROUND(
        SUM(SUM(`Booking Value`)) OVER (ORDER BY SUM(`Booking Value`) DESC),
        2
    ) AS cumulative_revenue
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY revenue DESC;


-- ------------------------------------------------------------
-- 10D : COMPARE each vehicle type's avg booking value
--       against the overall platform average
-- Uses AVG() OVER() — no partition = entire table average
-- ------------------------------------------------------------
SELECT
    `Vehicle Type`,
    ROUND(AVG(`Booking Value`), 2) AS avg_booking_value,
    ROUND(AVG(AVG(`Booking Value`)) OVER (), 2) AS platform_avg_booking_value,
    ROUND(
        AVG(`Booking Value`) - AVG(AVG(`Booking Value`)) OVER (),
        2
    ) AS diff_from_platform_avg
FROM cleaned_ride_bookings
WHERE `Booking Status` = 'Completed'
GROUP BY `Vehicle Type`
ORDER BY avg_booking_value DESC;


-- ------------------------------------------------------------
-- 10E : PICKUP LOCATION PERCENTILE RANKING
-- Tells you what percentile each location falls in
-- Uses NTILE(100) — splits locations into 100 equal buckets
-- A location in percentile 100 = top 1% by bookings
-- ------------------------------------------------------------
SELECT
    `Pickup Location`,
    total_bookings,
    NTILE(100) OVER (ORDER BY total_bookings) AS booking_percentile
FROM (
    SELECT
        `Pickup Location`,
        COUNT(*) AS total_bookings
    FROM cleaned_ride_bookings
    GROUP BY `Pickup Location`
) AS location_counts
ORDER BY booking_percentile DESC;


-- ------------------------------------------------------------
-- 10F : CTE — Full vehicle type performance summary in one query
-- Combines revenue, cancellation rate, avg rating, revenue rank
-- Uses CTE + RANK() window function
-- ------------------------------------------------------------
WITH vehicle_stats AS (
    SELECT
        `Vehicle Type`,
        COUNT(*) AS total_bookings,
        SUM(CASE WHEN `Booking Status` = 'Completed' THEN `Booking Value` ELSE 0 END) AS total_revenue,
        ROUND(AVG(CASE WHEN `Booking Status` = 'Completed' THEN `Booking Value` END), 2) AS avg_booking_value,
        ROUND(
            SUM(CASE
                WHEN `Booking Status` IN ('Cancelled by Customer', 'Cancelled by Driver') THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*), 2
        ) AS cancellation_rate,
        ROUND(AVG(CASE WHEN `Customer Rating` IS NOT NULL THEN `Customer Rating` END), 2) AS avg_customer_rating
    FROM cleaned_ride_bookings
    GROUP BY `Vehicle Type`
)
SELECT
    `Vehicle Type`,
    total_bookings,
    total_revenue,
    avg_booking_value,
    cancellation_rate,
    avg_customer_rating,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM vehicle_stats
ORDER BY revenue_rank;
