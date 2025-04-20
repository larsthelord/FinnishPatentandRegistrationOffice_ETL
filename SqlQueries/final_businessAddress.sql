CREATE OR REPLACE TABLE BusinessAddress as 
SELECT
  BusinessID,
  unnest(addresses_unnest)
FROM (
  SELECT
    businessId_value as BusinessID,
    unnest(addresses) as addresses_unnest
  FROM
    fro
) w;

SELECT
  BusinessID,
  CASE 
    WHEN "type" = 1 THEN 'Street Address'
    WHEN "type" = 2 THEN 'Postal Address'
    END as AddressType,
  street as Street,
  postOfficeBox as PostOfficeBox,
  buildingNumber as BuildingNumber,
  entrance as Entrance,
  apartmentNumber as ApartmentNumber,
  apartmentIdSuffix as ApartmentIdSuffix,
  co as CO,
  country as Country,
  freeAddressLine as FreeAddressLine,
  ba.postCode as PostCode,
  pc.City_English,
  pc.City_Finnish,
  pc.City_Swedish,
  pc.Active as PostCodeActive,
  pc.MunicipalityCode,
  registrationDate as RegistrationDate,
  source as SourceID
FROM
  BusinessAddress ba
LEFT OUTER JOIN
  PostCodes pc
  ON
    ba.postCode = pc.postCode