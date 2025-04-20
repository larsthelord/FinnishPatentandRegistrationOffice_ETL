SELECT
  w.id as StatusID,
  MAX(CASE WHEN "language" = 'en' THEN Description END) as Status_English,
  MAX(CASE WHEN "language" = 'fi' THEN Description END) as Status_Finnish,
  MAX(CASE WHEN "language" = 'sv' THEN Description END) as Status_Swedish
FROM (
  SELECT
    column0 as id,
    column1 as Description,
    REPLACE(REPLACE(parse_path(filename)[-1], 'STATUS3_', ''), '.tsv', '') as "language"
  FROM
    read_csv('./Descriptions/STATUS3/*.tsv', filename = true, delim = "\t", header = false)
  ) w
GROUP BY
  w.id