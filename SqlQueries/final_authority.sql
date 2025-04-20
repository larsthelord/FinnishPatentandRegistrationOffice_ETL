SELECT
  w.id as AuthorityID,
  MAX(CASE WHEN "language" = 'en' THEN Description END) as Authority_English,
  MAX(CASE WHEN "language" = 'fi' THEN Description END) as Authority_Finnish,
  MAX(CASE WHEN "language" = 'sv' THEN Description END) as Authority_Swedish
FROM (
  SELECT
    column0 as id,
    column1 as Description,
    REPLACE(REPLACE(parse_path(filename)[-1], 'VIRANOM_', ''), '.tsv', '') as "language"
  FROM
    read_csv('./Descriptions/VIRANOM/*.tsv', filename = true, delim = "\t", header = false)
  ) w
GROUP BY
  w.id