# Finnish Patentand Registration Office -- ETL

IN PROGRESS

## English

Download and ETL-process of data from Finnish Patent and Registration Office

There is one PowerShell-Script showing how to download and run ETL-process of the data from the API at https://avoindata.prh.fi/fi/ytj/swagger-ui using the "all_companies" endpoint.

The final outputs of the SQL-transformation are all scripts with prefix final_


Files / Tables with supporting information:
- final_authority:
    - Which authority in Finland has provided the data, descriptions in English, Finnish and Swedish
- final_source:
    - What is the source of the business information, descriptions in English, Finnish and Swedish
- final_register:
    - Which registry in Finland the business is registered with, descriptions in English, Finnish and Swedish
- final_registeredEntryType:
    - What type of business the business is, descriptions in English, Finnish and Swedish




# Links to DuckDB
This project uses [DuckDB](https://duckdb.org/) and [DuckDb.net](https://duckdb.net/).
The .dll-files included in this project is of version 1.2.1


# Did I make your life easier?
Why not buy me a coffee

![Buy me a coffee](./corporateshill/bmc_qr_small.png)