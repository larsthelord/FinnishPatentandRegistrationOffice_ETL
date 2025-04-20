CREATE OR REPLACE TABLE fro_RegisteredEntries as
SELECT
  w.businessId_value as businessId_value,
  unnest(re)
FROM (
  select businessId_value, unnest(registeredEntries) as re from fro
) w;



SELECT DISTINCT
  businessId_value as BusinessID,
  CONCAT_WS('_', register, "type") as RegisteredEntryTypeID,  /*Connect to final_registeredEntryType*/
  registrationDate::DATE as RegistrationDate,
  IFNULL(endDate, '2099-12-31')::DATE as EndDate,
  register as RegisterID,   /*Connect to final_register*/
  authority as AuthorityID  /*Connect to final_authority*/
FROM 
  fro_RegisteredEntries