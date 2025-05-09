CREATE OR REPLACE TABLE BusinessNameType AS 
SELECT
  w.id as BusinessNameTypeID,
  MAX(CASE WHEN "language" = 'en' THEN Description END) as BusinessNameType_English,
  MAX(CASE WHEN "language" = 'fi' THEN Description END) as BusinessNameType_Finnish,
  MAX(CASE WHEN "language" = 'sv' THEN Description END) as BusinessNameType_Swedish
FROM (
  SELECT
    column0 as id,
    column1 as Description,
    REPLACE(REPLACE(parse_path(filename)[-1], 'TLAJI_', ''), '.tsv', '') as "language"
  FROM
    read_csv('./Descriptions/TLAJI/*.tsv', filename = true, delim = "\t", header = false)
  ) w
GROUP BY
  w.id
