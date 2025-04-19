$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"
$Uri = "https://avoindata.prh.fi/opendata-ytj-api/v3/all_companies"

$TempPath = [System.IO.Path]::GetTempPath()
$TempFile = New-Item -Path ([System.IO.Path]::Combine($TempPath, "fi_all_companies.zip")) -Force

Invoke-WebRequest -Uri $Uri -Headers @{accept = "application/zip"} -OutFile $TempFile

#Extract to current folder and remove zip-file
[System.IO.Compression.ZipFile]::ExtractToDirectory($TempFile, ".") 
Remove-Item $TempFile.FullName -Force

$BusinessFile = Get-Item -Path ".\data*.json" | Sort-Object -Descending




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