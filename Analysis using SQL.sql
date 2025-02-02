-- For this Case Study, I decided to also show using SQL (BigQuery) instead of using R. This will also demonstrate the steps of the data analysis process: Ask, Prepare, Process, Analyze, Share, and Act.


-- Ask: How do annual members and casual riders use Cyclistic bikes differently?


-- Prepare: Download the historical trip data for January 2024 to December 2024. Create Project in BigQuery, create Dataset and then create tables for each csv. For the csvs that were above the 100mb limit of the BigQuery Sandbox, I decided to divide those files and upload them separate (e.g. Jun_2024_1 and Jun_2024_2). With each creation of table, I checked the Schema and Data type for each column. All of them had the same 13 columns, with the same data types which makes the data consistent and organized in a way that allows analysis of trends and patterns.


-- Process: I chose to use SQL to clean, aggregate and analyze the large amount of monthly data that I created tables for in BigQuery.

-- Combining all the tables into one. Using UNION DISTINCT makes sure that only unique rows will be combined. 
SELECT
  *
FROM
  bikeshareanalysis202501.tripdata2024.Jan_2024
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Feb_2024
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Mar_2024
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Apr_2024
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.May_2024_1
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.May_2024_2
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Jun_2024_1
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Jun_2024_2
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Jul_2024_1
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Jul_2024_2
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Aug_2024_1
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Aug_2024_2
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Sep_2024_1
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Sep_2024_2
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Oct_2024_1
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Oct_2024_2
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Nov_2024
UNION DISTINCT
  SELECT
    *
  FROM
    bikeshareanalysis202501.tripdata2024.Dec_2024
ORDER BY
  started_at ASC

-- After combining the tables, I decided to save the result as a BigQuery table: all_trips. Then, I checked for the NULLs in the all_trips table.
SELECT 
  col_name, 
  COUNT(1) AS nulls_count
FROM 
  bikeshareanalysis202501.tripdata2024.all_trips AS t,
  UNNEST(REGEXP_EXTRACT_ALL(TO_JSON_STRING(t), r'"(\w+)":null')) AS col_name
GROUP BY 
  col_name

-- Knowing there are NULLs, I decided to filter them out and save a new table without them. 
SELECT
  *
FROM
  bikeshareanalysis202501.tripdata2024.all_trips
WHERE 
  end_station_name IS NOT NULL
  AND end_station_id IS NOT NULL 
  AND start_station_name IS NOT NULL
  AND start_station_id IS NOT NULL
  AND end_lat IS NOT NULL
  AND end_lng IS NOT NULL
ORDER BY
  started_at ASC

-- I saved the result of the previous query as a new BigQuery table: nonulls. Next is to remove erroneous data where started_at is greater than ended_at. These two columns record date and time, so logically, the ended_at should always be greater. Removing them ensures that the data is accurate and meaningful.
SELECT
  *
FROM
  bikeshareanalysis202501.tripdata2024.nonulls
WHERE
  started_at < ended_at
ORDER BY
  started_at ASC

-- I saved the result of the previous query as a new BigQuery table: clean_trips. Next, I decided to rename the member_casual column into user_type. And save the results as a new BigQuery table: clean_trips2.
CREATE OR REPLACE TABLE bikeshareanalysis202501.tripdata2024.clean_trips2 AS 
SELECT
  ride_id, rideable_type, started_at,
  ended_at, start_station_name, start_station_id,
  end_station_name, end_station_id, start_lat,
  start_lng, end_lat, end_lng,
  member_casual AS user_type
FROM
  bikeshareanalysis202501.tripdata2024.clean_trips
ORDER BY
  started_at ASC

-- An additional column, ride_length was added for the analysis of duration of trips. The result of this query is saved as a new BigQuery table: clean_trips3.
SELECT
  *,
  ROUND(TIMESTAMP_DIFF(ended_at,started_at, SECOND)/60, 2) AS ride_length
FROM
  bikeshareanalysis202501.tripdata2024.clean_trips2
ORDER BY
  started_at ASC

-- It was also necessary to remove excessively long rides and too short rides. I decided to limit the results to those rides that were between five minutes and two days long. The result of this query is saved as a new BigQuery table: clean_trips4. 
SELECT
  *
FROM
  bikeshareanalysis202501.tripdata2024.clean_trips3
WHERE
  ride_length <= 2880
  AND ride_length > 5
ORDER BY
  started_at ASC

-- To facilitate deeper analysis, I created additional columns for: started_date, started_weekday, and started hour. The result of this query is saved as a new BigQuery table: clean_trips_final. 
SELECT
  *,
  DATE(started_at) AS started_date,
  FORMAT_TIMESTAMP('%A', started_at) AS started_weekday,
  EXTRACT(HOUR FROM started_at) AS started_hour 
FROM
  bikeshareanalysis202501.tripdata2024.clean_trips4
ORDER BY
  started_at ASC

-- To analyze the basic metrics of this dataset, I computed for the mean, maximum and minimum of the ride_lengths. From the result of the query below, it seems that casual riders use Cyclistic bikes for longer periods compared to annual members. Given this valuable information, it would be worth exploring ways to encourage casual riders to become annual members given their high usage. It would also be important to study the reasons behind the high maximum ride lengths as this might lead to potential misuse or misunderstanding of rental policies.
SELECT
  user_type,
  AVG(ride_length) AS mean_ride_length,
  MAX(ride_length) AS max_ride_length,
  MIN(ride_length) AS min_ride_length
FROM
  bikeshareanalysis202501.tripdata2024.clean_trips_final
GROUP BY
  user_type

-- Initially, I planned to export the clean_trips_final table into a csv so that I can analyze and create visualizations using Tableau. Unfortunately, having a Sandbox account does not allow this. Instead, I chose the option to Export > Explore with Sheets. This will allow analysis using Google sheets. 
