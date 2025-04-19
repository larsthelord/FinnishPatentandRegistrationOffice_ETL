CREATE OR REPLACE TABLE fro AS
SELECT
  businessId ->> 'value' as businessId_value,
  *
FROM
  read_json('<<FILEPATH>>')