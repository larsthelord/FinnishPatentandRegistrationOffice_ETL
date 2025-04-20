SELECT
  w.id as RegisteredEntryTypeID,
  MAX(CASE WHEN "language" = 'en' THEN Description END) as RegisteredEntryType_English,
  MAX(CASE WHEN "language" = 'fi' THEN Description END) as RegisteredEntryType_Finnish,
  MAX(CASE WHEN "language" = 'sv' THEN Description END) as RegisteredEntryType_Swedish
FROM (
  SELECT
    column0 as id,
    column1 as Description,
    REPLACE(REPLACE(parse_path(filename)[-1], 'REK_KDI_', ''), '.tsv', '') as "language"
  FROM
    read_csv(['<<FILEPATH>>'], filename = true, delim = "\t", header = false)
  ) w
GROUP BY
  w.id