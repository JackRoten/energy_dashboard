-- SELECT 
-- location,
-- fuel_type_description, 
-- consumption_for_eg_units,
-- SUM(CAST(consumption_for_eg AS DECIMAL))
-- FROM electric_power_operational
-- GROUP BY location, fuel_type_description, consumption_for_eg_units
-- ORDER BY location DESC;


SELECT 
location,
SUM(CAST(consumption_for_eg AS DECIMAL)) amount
FROM electric_power_operational
GROUP BY location
ORDER BY location DESC;


-- avaliable units:
-- thousand physical units
-- thousand barrels
-- thousand short tons
-- thousand Mcf