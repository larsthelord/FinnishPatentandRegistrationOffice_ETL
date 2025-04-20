$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

#Download main file containing all companies
$Uri = "https://avoindata.prh.fi/opendata-ytj-api/v3/all_companies"
$TempPath = [System.IO.Path]::GetTempPath()
$TempFile = New-Item -Path ([System.IO.Path]::Combine($TempPath, "fi_all_companies.zip")) -Force

Invoke-WebRequest -Uri $Uri -Headers @{accept = "application/zip"} -OutFile $TempFile

#Extract to current folder and remove zip-file
[System.IO.Compression.ZipFile]::ExtractToDirectory($TempFile, ".") 
Remove-Item $TempFile.FullName -Force

#Rename extracted file to data_FRO.json
if(Test-Path -Path "./data_FRO.json" -PathType Leaf){
    Remove-Item "./data_FRO.json" -Force
}
Get-Item -Path "./data*.json" | Rename-Item -NewName "data_FRO.json"


<#
    Get description information from API
#>
if(-not (Test-Path -Path ".\Descriptions" -PathType Container)){
    $null = New-Item -Path ".\Descriptions" -ItemType Directory
}

$Descriptions = @("YRMU", "REK_KDI", "TLAJI", "SELTILA", "REK", "VIRANOM", "TLAHDE", "KIELI", "TOIMI", "TOIMI2", "TOIMI3", "KONK", "SANE", "STATUS3", "SELTILA,SANE,KONK")
$Languages = @("en", "fi", "sv")
foreach($Description in $Descriptions){
    if(-not (Test-Path -Path ".\Descriptions\$Description" -PathType Container)){
        $null = New-Item -Path ".\Descriptions\$Description" -ItemType Directory
    }
    foreach($Language in $Languages){
        $Response = Invoke-WebRequest -Uri "https://avoindata.prh.fi/opendata-ytj-api/v3/description?code=$Description&lang=$Language" -Method Get -UseBasicParsing -Headers @{accept = "text/plain"}
        $Response.Content | Out-File ".\Descriptions\$Description\$Description`_$Language.tsv" -Force
        Start-Sleep -Milliseconds (Get-Random -Minimum 250 -Maximum 750)
    }
}

<#
    Get Postcode Information
#>
if(-not (Test-Path -Path ".\PostCodes" -PathType Container)){
    $null = New-Item -Path ".\PostCodes" -ItemType Directory
}
foreach($Language in $Languages){
    $Response = Invoke-WebRequest -Uri "https://avoindata.prh.fi/opendata-ytj-api/v3/post_codes?lang=$Language"
    $Response.Content | Out-File ".\PostCodes\PostCodes_$Language.json"
    Start-Sleep -Milliseconds (Get-Random -Minimum 250 -Maximum 750)
}


#Import DuckDB.NET
Add-Type -Path ".\Powershell\duckdb\DuckDB.NET.Data.dll"
Add-Type -Path ".\Powershell\duckdb\DuckDB.NET.Bindings.dll"

#Establish connectionString
$DuckDBConnection = [DuckDB.NET.Data.DuckDBConnection]::new("DataSource = :memory:")
$DuckDBConnection.Open()
$DuckDBCommand = $DuckDBConnection.CreateCommand()
$DuckDBCommand.CommandTimeout = 0

#Load temporary tables into meory
$TemporaryTables = @("load_businessNameType.sql", "load_FRO.sql", "load_businessNames.sql", "load_postCodes.sql")
foreach($TemporaryTable in $TemporaryTables){
    "$((Get-Date).ToString("yyyy-MM-dd HH\:mm\:ss")) :: Loading temporary table $TemporaryTable into memory"
    $DuckDBCommand.CommandText = Get-Item -Path "./SqlQueries/$TemporaryTable" | Get-Content
    $null = $DuckDBCommand.ExecuteNonQuery()
}

#Load all exported tables into your storage, or DataTable as shown in example.
foreach($FinalTable in (Get-ChildItem -Path "./SqlQueries/final_*")){
    "$((Get-Date).ToString("yyyy-MM-dd HH\:mm\:ss")) :: Loading table $($FinalTable.Name)"
    $DuckDBCommand.CommandText = Get-Content -Path $FinalTable.FullName
    $Reader = $DuckDBCommand.ExecuteReader()
    $DataTable = [System.Data.DataTable]::new()
    $Datatable.Load($Reader)
}

$DuckDBCommand.Dispose()
$DuckDBConnection.Dispose()

