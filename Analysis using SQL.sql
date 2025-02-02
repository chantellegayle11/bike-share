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




