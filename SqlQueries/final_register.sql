SELECT
  w.id as RegisterID,
  MAX(CASE WHEN "language" = 'en' THEN Description END) as Register_English,
  MAX(CASE WHEN "language" = 'fi' THEN Description END) as Register_Finnish,
  MAX(CASE WHEN "language" = 'sv' THEN Description END) as Register_Swedish
FROM (
  SELECT
    column0 as id,
    column1 as Description,
    REPLACE(REPLACE(parse_path(filename)[-1], 'REK_', ''), '.tsv', '') as "language"
  FROM
    read_csv('./Descriptions/REK/*.tsv', filename = true, delim = "\t", header = false)
  ) w
GROUP BY
  w.id