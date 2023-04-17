-- Creating view
CREATE OR REPLACE VIEW
  forestation AS
SELECT
  f.country_code,
  f.country_name,
  f.year,
  f.forest_area_sqkm,
  l.total_area_sq_mi,
  r.region,
  r.income_group,
  (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59)*100) percent_forest
FROM
  forest_area f
JOIN
  land_area l
ON
  f.country_code = l.country_code
  AND f.year = l.year
JOIN
  regions r
ON
  r.country_code = l.country_code;
-- Checking view
SELECT
  *
FROM
  forestation;

--1.a) What was the total forest area (in sq km) of the world in 1990?
SELECT
  f.forest_area_sqkm
FROM
  forestation f
WHERE
  f.region = 'World'
  AND f.year = 1990;

--1.b. What was the total forest area (in sq km) of the world in 2016? 
SELECT
  f.forest_area_sqkm
FROM
  forestation f
WHERE
  f.region = 'World'
  AND f.year = 2016;

--1.c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
SELECT
  pre.forest_area_sqkm - cur.forest_area_sqkm forest_loss_sqkm
FROM
  forest_area pre
JOIN
  forest_area cur
ON
  (pre.country_name = 'World'
    AND cur.country_name = 'World'
    AND pre.year = '1990'
    AND cur.year = '2016');

--1.d. What was the percent change in forest area of the world between 1990 and 2016?
SELECT
  ((1 - (cur.forest_area_sqkm / pre.forest_area_sqkm))*100) percent_forest_loss
FROM
  forest_area pre
JOIN
  forest_area cur
ON
  (pre.country_name = 'World'
    AND cur.country_name = 'World'
    AND pre.year = '1990'
    AND cur.year = '2016');

--1.e. If you compare the amount of forest area lost between 1990 and 2016, to which 
--country's total area in 2016 is it closest to?
SELECT
  l.country_name,
  (l.total_area_sq_mi * 2.59) total_area_sq_km
FROM
  land_area l
WHERE
  (l.total_area_sq_mi * 2.59) <= 1324449
GROUP BY
  l.country_name,
  (l.total_area_sq_mi * 2.59)
ORDER BY
  total_area_sq_km DESC
LIMIT
  1;

--2.a. What was the percent forest of the entire world in 2016? Which region had the 
--HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
--2.a.1
SELECT
  f.percent_forest
FROM
  forestation f
WHERE
  year = 2016
  AND region= 'World';

--2.a.2
SELECT
  ROUND(100*(SUM(forest_area_sqkm)/
  SUM(total_area_sq_mi*2.59))::numeric, 2) percent_by_region,
  region
FROM
  forestation
WHERE
  year = 2016
  AND region != 'World'
GROUP BY
  region
ORDER BY
  1 DESC;

--2.b. What was the percent forest of the entire world in 1990? Which region had the 
--HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places? 
--2.b.1
SELECT
  f.percent_forest
FROM
  forestation f
WHERE
  year = 1990
  AND region= 'World';

--2.b.2
SELECT
  ROUND(100*(SUM(forest_area_sqkm)/SUM(total_area_sq_mi*2.59))::numeric, 2) percent_by_region,
  region
FROM
  forestation
WHERE
  year = 1990
  AND region != 'World'
GROUP BY
  region
ORDER BY
  1 DESC;

--2.c. Based on the table you created, which regions of the world DECREASED 
--in forest area from 1990 to 2016?
SELECT
  f.region,
  (f1.percent_by_region_1990 > f.percent_by_region_2016) decreased,
  f1.percent_by_region_1990,
  f.percent_by_region_2016
FROM (
  SELECT
    ROUND(100*(SUM(f.forest_area_sqkm)/
    SUM(f.total_area_sq_mi*2.59))::numeric, 2) percent_by_region_2016,
    f.region
  FROM
    forestation f
  WHERE
    year = 2016
    AND region != 'World'
  GROUP BY
    f.region) f
JOIN (
  SELECT
    ROUND(100*(SUM(f1.forest_area_sqkm)/
    SUM(f1.total_area_sq_mi*2.59))::numeric, 2) percent_by_region_1990,
    region
  FROM
    forestation f1
  WHERE
    year = 1990
    AND region != 'World'
  GROUP BY
    f1.region) f1
ON
  f.region = f1.region
GROUP BY
  f.region,
  f1.percent_by_region_1990,
  f.percent_by_region_2016
ORDER BY
  2 DESC;

--3.a. Which 5 countries saw the largest amount decrease in forest area from 1990 to 2016? 
--What was the difference in forest area for each?
SELECT
  f.country_name,
  SUM(f.forest_area_sqkm) AS forest_area_2016,
  SUM(f1.forest_area_sqkm) AS forest_area_1990,
  (SUM(f.forest_area_sqkm)-SUM(f1.forest_area_sqkm)) AS area_diff
FROM
  forestation f
JOIN
  forestation f1
ON
  f.country_name = f1.country_name
  AND f.year = 2016
  AND f1.year = 1990
  AND f.forest_area_sqkm IS NOT NULL
  AND f1.forest_area_sqkm IS NOT NULL
GROUP BY
  f.country_name
ORDER BY
  4
LIMIT
  5;

--3.b. Which 5 countries saw the largest percent decrease in forest area from 1990 to 2016? 
--What was the percent change to 2 decimal places for each?
SELECT
  f.country_name,
  SUM(f.forest_area_sqkm) AS forest_area_2016,
  SUM(f1.forest_area_sqkm) AS forest_area_1990,
  ROUND((100.0*(SUM(f.forest_area_sqkm)-SUM(f1.forest_area_sqkm))/
  SUM(f1.forest_area_sqkm) )::numeric,2) AS area_diff_percent,
  (SUM(f.forest_area_sqkm)-SUM(f1.forest_area_sqkm)) AS area_diff,
  f.region
FROM
  forestation f
JOIN
  forestation f1
ON
  f.country_name = f1.country_name
  AND f.year = 2016
  AND f1.year = 1990
  AND f.forest_area_sqkm IS NOT NULL
  AND f1.forest_area_sqkm IS NOT NULL
GROUP BY
  f.country_name,
  f.region
ORDER BY
  5
LIMIT
  5;

--3.c. If countries were grouped by percent forestation in quartiles, which group 
--had the most countries in it in 2016?
SELECT
  percentile,
  COUNT(percent_forest) count
FROM (
  SELECT
    country_name,
    percent_forest,
    CASE
      WHEN percent_forest > 75 THEN '%75-100'
      WHEN percent_forest > 50
    AND percent_forest <=75 THEN '%50-75'
      WHEN percent_forest > 25 AND percent_forest <=50 THEN '%25-50'
    ELSE
    '%0-25'
  END
    AS percentile
  FROM
    forestation
  WHERE
    year = 2016
    AND country_name != 'World') sub
GROUP BY
  1
ORDER BY
  2 DESC;

--3.d. List all of the countries that were in the 4th quartile (percent forest > 75%) in 2016.
SELECT
  country_name,
  percent_forest,
  CASE
    WHEN percent_forest > 75 THEN '%75-100'
    WHEN percent_forest > 50
  AND percent_forest <=75 THEN '%50-75'
    WHEN percent_forest > 25 AND percent_forest <=50 THEN '%25-50'
  ELSE
  '%0-25'
END
  AS percentile
FROM
  forestation
WHERE
  year = 2016
GROUP BY
  1,
  2
HAVING
  percent_forest > 75
ORDER BY
  2 DESC;
  --
SELECT
  country_name,
  region,
  percent_forest
FROM
  forestation
WHERE
  year = 2016
GROUP BY
  1,
  2,
  3
HAVING
  percent_forest > 75
ORDER BY
  3 DESC;
-- 3.e. How many countries had a percent forestation higher than the United States in 2016?
WITH
  USA AS (
  SELECT
    percent_forest
  FROM
    forestation
  WHERE
    country_name = 'United States'
    AND year = 2016)
SELECT
  COUNT (*) AS count
FROM (
  SELECT
    country_name,
    percent_forest
  FROM
    forestation
  WHERE
    year = 2016
  GROUP BY
    1,
    2
  HAVING
    percent_forest > (
    SELECT
      *
    FROM
      USA)
  ORDER BY
    2 DESC) SUB

