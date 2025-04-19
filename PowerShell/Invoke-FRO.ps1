$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$Uri = "https://avoindata.prh.fi/opendata-ytj-api/v3/all_companies"

$TempPath = [System.IO.Path]::GetTempPath()
$TempFile = New-Item -Path ([System.IO.Path]::Combine($TempPath, "fi_all_companies.zip")) -Force

Invoke-WebRequest -Uri $Uri -Headers @{accept = "application/zip"} -OutFile $TempFile

#Extract to current folder and remove zip-file
[System.IO.Compression.ZipFile]::ExtractToDirectory($TempFile, ".") 
Remove-Item $TempFile.FullName -Force

$BusinessFile = (Get-Item -Path ".\data*.json" | Sort-Object -Descending)[0]



<#
    Get description information
#>

if(-not (Test-Path -Path ".\Descriptions" -PathType Container)){
    $null = New-Item -Path ".\Descriptions" -ItemType Directory
}

$Descriptions = @("YRMU", "REK_KDI", "TLAJI", "SELTILA", "REK", "VIRANOM", "TLAHDE", "KIELI", "TOIMI", "TOIMI2", "TOIMI3", "KONK", "SANE", "STATUS3", "SELTILA,SANE,KONK")
$Langugages = @("en", "fi", "sv")

foreach($Description in $Descriptions){
    if(-not (Test-Path -Path ".\Descriptions\$Description" -PathType Container)){
        $null = New-Item -Path ".\Descriptions\$Description" -ItemType Directory
    }
    foreach($Language in $Langugages){
        $Response = Invoke-WebRequest -Uri "https://avoindata.prh.fi/opendata-ytj-api/v3/description?code=$Description&lang=$Language" -Method Get -UseBasicParsing -Headers @{accept = "text/plain"}
        $Response.Content | Out-File ".\Descriptions\$Description\$Description`_$Language.tsv"
        Start-Sleep -Milliseconds (Get-Random -Minimum 250 -Maximum 750)
    }
}


Add-Type -Path ".\Powershell\duckdb\DuckDB.NET.Data.dll"
Add-Type -Path ".\Powershell\duckdb\DuckDB.NET.Bindings.dll"

#Get SourceDescription

$SourceFiles = Get-ChildItem -Path "./Descriptions/TLAHDE/*"

$DuckDbConnection = [DuckDB.NET.Data.DuckDBConnection]::new("DataSource = :memory:")
$DuckDbConnection.Open()
$DuckdbCommand = $DuckDbConnection.CreateCommand()
$DuckdbCommand.CommandTimeout = 0


#Load Source Data
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\final_source.sql").Replace("<<FILEPATH>>", ($SourceFiles.FullName -join "','"))
$Reader = $DuckdbCommand.ExecuteReader()

#Load Source to datatable: -- Write these to your storage instead of datatable
$SourceDatatable = [System.Data.DataTable]::new()
$SourceDatatable.Load($Reader)


$RegisterFiles = Get-ChildItem -Path "./Descriptions/REK/*"
#Load Source Register
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\final_register.sql").Replace("<<FILEPATH>>", ($RegisterFiles.FullName -join "','"))
$Reader = $DuckdbCommand.ExecuteReader()

#Load Source to Register: -- Write these to your storage instead of datatable
$RegisterDatatable = [System.Data.DataTable]::new()
$RegisterDatatable.Load($Reader)



$RegisterFiles = Get-ChildItem -Path "./Descriptions/REK/*"
#Load Source Register
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\final_register.sql").Replace("<<FILEPATH>>", ($RegisterFiles.FullName -join "','"))
$Reader = $DuckdbCommand.ExecuteReader()

#Load Source to Register: -- Write these to your storage instead of datatable
$RegisterDatatable = [System.Data.DataTable]::new()
$RegisterDatatable.Load($Reader)




$RegisteredEntryTypeFiles = Get-ChildItem -Path "./Descriptions/REK_KDI/*"
#Load Source Register
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\final_registeredEntryType.sql").Replace("<<FILEPATH>>", ($RegisteredEntryTypeFiles.FullName -join "','"))
$Reader = $DuckdbCommand.ExecuteReader()

#Load Source to Register: -- Write these to your storage instead of datatable
$RegisteredEntryTypeDatatable = [System.Data.DataTable]::new()
$RegisteredEntryTypeDatatable.Load($Reader)




$AuthorityFiles = Get-ChildItem -Path "./Descriptions/VIRANOM/*"
#Load Source Register
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\final_authority.sql").Replace("<<FILEPATH>>", ($AuthorityFiles.FullName -join "','"))
$Reader = $DuckdbCommand.ExecuteReader()

#Load Source to Register: -- Write these to your storage instead of datatable
$AuthorityDatatable = [System.Data.DataTable]::new()
$AuthorityDatatable.Load($Reader)



#Load main file into memory
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\load_FRO.sql").Replace("<<FILEPATH>>", $BusinessFile.FullName)
$null = $DuckdbCommand.ExecuteNonQuery()


#Unpack Registered Entries
$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\load_FRO_RegisteredEntries.sql")
$null = $DuckdbCommand.ExecuteNonQuery()

$DuckdbCommand.CommandText = (Get-Content ".\SqlQueries\final_registeredEntries.sql")
$Reader = $DuckdbCommand.ExecuteReader()


#Load Source to Register: -- Write these to your storage instead of datatable
$RegisteredEntriesDatatable = [System.Data.DataTable]::new()
$RegisteredEntriesDatatable.Load($Reader)