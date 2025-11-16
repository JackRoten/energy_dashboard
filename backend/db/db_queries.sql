SELECT 
location,
fuel_type_description, 
consumption_for_eg_units,
SUM(CAST(consumption_for_eg AS DECIMAL)) amount
FROM electric_power_operational
WHERE consumption_for_eg IS NOT NULL
AND CAST(TRIM(consumption_for_eg) AS DECIMAL) <> 0
GROUP BY location, fuel_type_description, consumption_for_eg_units
ORDER BY location DESC
;


-- Is there a way to normalize based on equal amounts 
-- and strings that have a fuzzy match
-- SELECT pg_typeof(consumption_for_eg) FROM electric_power_operational LIMIT 1;


-- SELECT CAST(TRIM(consumption_for_eg) AS DECIMAL) FROM electric_power_operational 
-- WHERE CAST(TRIM(consumption_for_eg) AS DECIMAL) <> 0;


--  SELECT pg_typeof(electric_power_operational);
-- SELECT 
-- state_description,
-- SUM(CAST(consumption_for_eg AS DECIMAL)) amount
-- FROM electric_power_operational
-- GROUP BY state_description
-- ORDER BY amount DESC;


-- avaliable units:
-- thousand physical units
-- thousand barrels
-- thousand short tons
-- thousand Mcf
-- 2260908
-- 2500000