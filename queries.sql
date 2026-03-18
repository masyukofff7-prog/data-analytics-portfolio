-- =====================================
-- Анализ в приложении Sleepy
-- =====================================

-- таблица
-- entries(user, dt)

--------------------------------------------------
-- 1. DAU (Daily Active Users)
--------------------------------------------------

SELECT 
    dt,
    COUNT(DISTINCT user) AS dau
FROM entries
GROUP BY dt
ORDER BY dt;


--------------------------------------------------
-- 2. MAU (Monthly Active Users)
--------------------------------------------------

SELECT 
    DATE_TRUNC('month', dt) AS month,
    COUNT(DISTINCT user) AS mau
FROM entries
GROUP BY month
ORDER BY month;


--------------------------------------------------
-- 3. First user visit (cohort start)
--------------------------------------------------

WITH first_visit AS (
SELECT 
    user,
    MIN(dt) AS first_dt
FROM entries
GROUP BY user
)

SELECT * 
FROM first_visit;


--------------------------------------------------
-- 4. Retention calculation
--------------------------------------------------

WITH first_visit AS (

SELECT
    user,
    MIN(dt) AS first_dt
FROM entries
GROUP BY user

),

retention AS (

SELECT
    e.user,
    e.dt,
    f.first_dt,
    e.dt - f.first_dt AS lifetime_day
FROM entries e
JOIN first_visit f
ON e.user = f.user

)

SELECT
    lifetime_day,
    COUNT(DISTINCT user) AS users
FROM retention
GROUP BY lifetime_day
ORDER BY lifetime_day;


--------------------------------------------------
-- 5. Retention rate
--------------------------------------------------

WITH first_visit AS (

SELECT
    user,
    MIN(dt) AS first_dt
FROM entries
GROUP BY user

),

retention AS (

SELECT
    e.user,
    e.dt - f.first_dt AS lifetime_day
FROM entries e
JOIN first_visit f
ON e.user = f.user

),

day0 AS (

SELECT COUNT(DISTINCT user) AS cohort_size
FROM retention
WHERE lifetime_day = 0

)

SELECT
    lifetime_day,
    COUNT(DISTINCT user)::numeric /
    (SELECT cohort_size FROM day0) AS retention
FROM retention
GROUP BY lifetime_day
ORDER BY lifetime_day;


--------------------------------------------------
-- 6. Sticky Factor
-- Sticky = avg(DAU) / avg(MAU)
--------------------------------------------------

WITH dau AS (

SELECT
    dt,
    COUNT(DISTINCT user) AS dau
FROM entries
GROUP BY dt

),

mau AS (

SELECT
    DATE_TRUNC('month', dt) AS month,
    COUNT(DISTINCT user) AS mau
FROM entries
GROUP BY month

)

SELECT
    AVG(dau) / AVG(mau) AS sticky_factor
FROM dau, mau;


--------------------------------------------------
-- 7. MAU peak month
--------------------------------------------------

SELECT
    DATE_TRUNC('month', dt) AS month,
    COUNT(DISTINCT user) AS mau
FROM entries
GROUP BY month
ORDER BY mau DESC
LIMIT 1;