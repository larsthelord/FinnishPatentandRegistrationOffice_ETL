SELECT
  f.businessId_value as BusinessID,
  f.businessId ->> 'registrationDate' as BusinessID_RegistrationDate,
  f.businessId ->> 'source' as BusinessId_SourceID,
  bn."Name",
  euId ->> 'value' as EuID,
  euId ->> 'source' as EuID_SourceID,
  registrationDate::DATE as RegistrationDate,
  endDate::DATE as EndDate,
  status as StatusID,
  CASE WHEN tradeRegisterStatus = 0 THEN 'Unregistered' ELSE 'Registered' END as TradeRegisterStatus,
  CONCAT_WS('.', mainBusinessLine ->> 'typeCodeSet', mainBusinessLine ->> 'type') as MainBusinessLineID,
  MainBusinessLine ->> 'source' as MainBusinessLine_SourceID,
  (MainBusinessLine ->> 'registrationDate')::DATE as MainBusinessLine_RegistrationDate,
  lastModified::DATETIME as LastModified
FROM
  fro f
LEFT OUTER JOIN
  BusinessNames bn
  ON
    bn.businessID = f.businessId_value
    AND bn.BusinessNameTypeID = 1
    AND bn."Version" = 1