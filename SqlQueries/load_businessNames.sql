/*Requires load_businessNameType to be loaded*/
/*Requires load_FRO to be loaded*/

CREATE OR REPLACE TABLE fro_Names as 
SELECT
  businessId_value as BusinessID,
  index as Index,
  unnest(names_unnest)
FROM (
SELECT
  businessId_value,
  generate_subscripts(names, 1) as index,
  unnest(names) as names_unnest
FROM
  fro
) w;

CREATE OR REPLACE TABLE BusinessNames as 
SELECT
  BusinessID,
  "Index",
  "name" as "Name",
  registrationDate::DATE as Name_RegistrationDate,
  endDate::DATE as Name_EndDate,
  "version" as "Version",
  CASE WHEN "version" = 1 then 'Current Version' ELSE 'Past Version' END as CurrentVersion,
  source as SourceID,
  fn."type" as BusinessNameTypeID,
  cnt.BusinessNameType_English,
  cnt.BusinessNameType_Finnish,
  cnt.BusinessNameType_Swedish
FROM
  fro_Names fn
LEFT OUTER JOIN
  BusinessNameType cnt
  ON
    cnt.BusinessNameTypeID = fn."type"