﻿Enable-PSRemoting
Add-WindowsFeature DSC-Service
Configuration SimpleMetaConfigurationForPull 
{ 
     $NodeGUID="2bb7ecb4-c755-484d-bd24-228cdc1cb0cd";
     LocalConfigurationManager 
     { 
       ConfigurationID = $NodeGUID;
       RefreshMode = "PULL";
       DownloadManagerName = "WebDownloadManager";
       RebootNodeIfNeeded = $true;
       RefreshFrequencyMins = 15;
       ConfigurationModeFrequencyMins = 30; 
       ConfigurationMode = "ApplyAndAutoCorrect";
       DownloadManagerCustomData = @{ServerUrl ="http://PULLSERVER:8080/PSDSCPullServer.svc"; AllowUnsecureConnection = “TRUE”}
     } 
}  

SimpleMetaConfigurationForPull
$FilePath = (Get-Location -PSProvider FileSystem).Path + "\SimpleMetaConfigurationForPull"
Set-DscLocalConfigurationManager -ComputerName "localhost" -Path $FilePath -Verbose
