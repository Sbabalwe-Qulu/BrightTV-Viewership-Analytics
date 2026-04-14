--Understanding what's in the tables, rows and columns
SELECT *
FROM viewership
LIMIT 10;

-- findind  columns with null values
SELECT *
FROM viewership
WHERE Channel2 IS NULL 
      OR RecordDate2 IS NULL
      OR `Duration 2` IS NULL;
-- how many different channels are in the data
SELECT DISTINCT Channel2
FROM viewership;
-- counting different channels in the data
SELECT COUNT(DISTINCT Channel2) AS Number_of_channels
FROM viewership;

--Top 3 channels with most viewers
SELECT COUNT(Channel2) AS Total_viewers,
       Channel2
FROM viewership
GROUP BY Channel2
ORDER BY Total_viewers DESC
LIMIT 3;

--converting duration to seconds
SELECT `Duration 2`,
        HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`) AS duration_seconds
FROM viewership
LIMIT 5;

SELECT 
    MIN(duration_seconds) AS min_duration,
    AVG(duration_seconds) AS avg_duration,
    MAX(duration_seconds) AS max_duration
FROM (
      SELECT `Duration 2`,
        HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`) AS duration_seconds
FROM viewership)
LIMIT 5;

SELECT*,
        CASE
          WHEN duration_seconds BETWEEN 0 AND 600 THEN "Low Watch Time"
          WHEN duration_seconds BETWEEN 601 AND 1800 THEN "Medium Watch Time"
          WHEN duration_seconds > 1801 THEN "High Watch Time"
    END AS watch_category
FROM(
SELECT *,

        HOUR(`Duration 2`)*3600 + MINUTE(`Duration 2`)*60 + SECOND(`Duration 2`) AS duration_seconds
        FROM viewership
);

----------------------------------------------------------------------
-- View sample records from Profiles table
SELECT *
FROM Profiles
LIMIT 10;

-- Total number of users in the dataset
SELECT COUNT(*) AS total_users
FROM Profiles;

--Cleaned Base Table
WITH cleaned_profiles AS (
    SELECT 
        UserID,
        age,

        -- Clean gender
        CASE 
            WHEN gender IS NULL 
                 OR TRIM(gender) = '' 
                 OR LOWER(TRIM(gender)) = 'none'
            THEN NULL
            ELSE gender
        END AS gender,

        -- Clean race
        CASE 
            WHEN race IS NULL 
                 OR TRIM(race) = '' 
                 OR LOWER(TRIM(race)) = 'none'
            THEN NULL
            ELSE race
        END AS race,

        -- Clean province
        CASE 
            WHEN province IS NULL 
                 OR TRIM(province) = '' 
                 OR LOWER(TRIM(province)) = 'none'
            THEN NULL
            ELSE province
        END AS province

    FROM Profiles
)

--Distinct race
SELECT DISTINCT race
FROM cleaned_profiles;

--Age bucket
SELECT 
    UserID,
    age,
    CASE 
        WHEN age < 13 THEN 'Pre-Teen'
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 25 THEN 'Young Adult'
        WHEN age BETWEEN 26 AND 49 THEN 'Adult'
        ELSE 'Senior'
    END AS age_bucket
FROM Profiles;

--Count per brucket
SELECT 
    CASE 
        WHEN age < 13 THEN 'Pre-Teen'
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 25 THEN 'Young Adult'
        WHEN age BETWEEN 26 AND 59 THEN 'Adult'
        ELSE 'Senior'
    END AS age_bucket,
    COUNT(*) AS total_users
FROM Profiles
GROUP BY 
    CASE 
        WHEN age < 13 THEN 'Pre-Teen'
        WHEN age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN age BETWEEN 20 AND 25 THEN 'Young Adult'
        WHEN age BETWEEN 26 AND 59 THEN 'Adult'
        ELSE 'Senior'
    END
ORDER BY total_users DESC;

--Gender + Race
WITH cleaned_profiles AS (
    SELECT 
        CASE 
            WHEN gender IS NULL OR TRIM(gender) = '' OR LOWER(TRIM(gender)) = 'none'
            THEN NULL ELSE gender END AS gender,

        CASE 
            WHEN race IS NULL OR TRIM(race) = '' OR LOWER(TRIM(race)) = 'none'
            THEN NULL ELSE race END AS race
    FROM Profiles
)
SELECT 
    gender,
    race,
    COUNT(*) AS total_users
FROM cleaned_profiles
GROUP BY gender, race
ORDER BY total_users DESC;

--Province + Gender
WITH cleaned_profiles AS (
    SELECT 
        CASE 
            WHEN gender IS NULL OR TRIM(gender) = '' OR LOWER(TRIM(gender)) = 'none'
            THEN NULL ELSE gender END AS gender,

        CASE 
            WHEN province IS NULL OR TRIM(province) = '' OR LOWER(TRIM(province)) = 'none'
            THEN NULL ELSE province END AS province
    FROM Profiles
)
SELECT 
    province,
    gender,
    COUNT(*) AS total_users
FROM cleaned_profiles
GROUP BY province, gender
ORDER BY province;


------------------
SELECT
    -- ======================
    -- USER IDENTIFIER
    -- ======================
    v.UserID0,

    -- ======================
    -- PROFILE DATA (CLEANED)
    -- ======================
    p.age,

    CASE 
        WHEN p.age < 13 THEN 'Pre-Teen'
        WHEN p.age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN p.age BETWEEN 20 AND 25 THEN 'Young Adult'
        WHEN p.age BETWEEN 26 AND 59 THEN 'Adult'
        ELSE 'Senior'
    END AS age_bucket,

    CASE 
        WHEN p.gender IS NULL 
             OR TRIM(p.gender) = '' 
             OR LOWER(TRIM(p.gender)) = 'none'
        THEN NULL ELSE p.gender
    END AS gender,

    CASE 
        WHEN p.race IS NULL 
             OR TRIM(p.race) = '' 
             OR LOWER(TRIM(p.race)) = 'none'
        THEN NULL ELSE p.race
    END AS race,

    CASE 
        WHEN p.province IS NULL 
             OR TRIM(p.province) = '' 
             OR LOWER(TRIM(p.province)) = 'none'
        THEN NULL ELSE p.province
    END AS province,

    -- ======================
    -- DATE & TIME (UTC → SAST FIXED)
    -- ======================
    DATE(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS date_only,

    DAYNAME(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS day_name,

    MONTHNAME(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS month_name,

    DAY(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS day_of_month,

    CASE 
        WHEN DAYOFWEEK(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) IN (1,7) 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    HOUR(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS hour_of_day,

    CASE 
        WHEN HOUR(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) BETWEEN 0 AND 5 THEN 'Early Morning'
        WHEN HOUR(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) BETWEEN 12 AND 17 THEN 'Afternoon'
        WHEN HOUR(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) BETWEEN 18 AND 21 THEN 'Evening'
        ELSE 'Late Night'
    END AS time_bucket,

    -- ======================
    -- DURATION ANALYSIS (FIXED COLUMN NAME)
    -- ======================
    v.`Duration 2`,

    (HOUR(v.`Duration 2`)*3600 + MINUTE(v.`Duration 2`)*60 + SECOND(v.`Duration 2`)) AS duration_seconds,

    CASE
        WHEN (HOUR(v.`Duration 2`)*3600 + MINUTE(v.`Duration 2`)*60 + SECOND(v.`Duration 2`)) <= 600 
            THEN 'Low Watch'
        WHEN (HOUR(v.`Duration 2`)*3600 + MINUTE(v.`Duration 2`)*60 + SECOND(v.`Duration 2`)) <= 1800 
            THEN 'Medium Watch'
        ELSE 'High Watch'
    END AS duration_bucket,

    -- ======================
    -- CONTENT INFO
    -- ======================
    v.Channel2

FROM Viewership v
LEFT JOIN Profiles p
ON v.UserID0 = p.UserID;