CREATE OR REPLACE TABLE PostCodes AS 
SELECT
  postCode as PostCode,
  MAX(CASE WHEN REPLACE(REPLACE(parse_path(filename)[-1], 'PostCodes_', ''), '.json', '') = 'fi' THEN city END) as City_Finnish,
  MAX(CASE WHEN REPLACE(REPLACE(parse_path(filename)[-1], 'PostCodes_', ''), '.json', '') = 'sv' THEN city END) as City_Swedish,
  MAX(CASE WHEN REPLACE(REPLACE(parse_path(filename)[-1], 'PostCodes_', ''), '.json', '') = 'en' THEN city END) as City_English,
  municipalityCode as MunicipalityCode,
  active as Active
FROM
  read_json('./PostCodes/*.json', filename=true)
GROUP BY
  postCode,
  municipalityCode,
  active