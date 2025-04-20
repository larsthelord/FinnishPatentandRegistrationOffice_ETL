SELECT
  BusinessLineID,
  BusinessLineCode,
  BusinessLineCodeType,
  MAX(CASE WHEN "Language" = 'en' THEN column1 END) as BusinessLineDescription_English,
  MAX(CASE WHEN "Language" = 'fi' THEN column1 END) as BusinessLineDescription_Finnish,
  MAX(CASE WHEN "Language" = 'sv' THEN column1 END) as BusinessLineDescription_Swedish
FROM (
SELECT
  CONCAT_WS('.', parse_path(filename)[-2], column0) as BusinessLineID,
  column0 as BusinessLineCode,
  column1,
  parse_path(filename)[-2] as BusinessLineCodeType,
  REPLACE(RIGHT(parse_path(filename)[-1], LEN(parse_path(filename)[-1]) - instr(parse_path(filename)[-1], '_')), '.tsv', '') as "Language"
FROM
  read_csv(['./Descriptions/TOIMI/*.tsv', './Descriptions/TOIMI2/*.tsv', './Descriptions/TOIMI3/*.tsv'], delim = "\t", header = false, filename = true)
) w
GROUP BY
  BusinessLineID,
  BusinessLineCode,
  BusinessLineCodeType