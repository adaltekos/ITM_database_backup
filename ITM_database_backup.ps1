# Set local and online directory
$backupDirectory = "" #complete with local backup directory (ex. C:\backup\mssql_backup)
$onlineDirectory = "" #complete with online backup directory (ex. \\192.168.0.0\backup_servers\database)

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

# Set variables
$mySrvConn = new-object Microsoft.SqlServer.Management.Common.ServerConnection
$mySrvConn.ServerInstance = "" #complete with database location (ex. 192.168.0.0\database)
$mySrvConn.LoginSecure = $false
$mySrvConn.Login = "" #complete with login to database
$mySrvConn.Password = '' #complete with password to database

$server = new-object Microsoft.SqlServer.Management.SMO.Server($mySrvConn)
$server.ConnectionContext.StatementTimeout = 0

$dbs = $server.Databases

#Delete items in local directory that are older than 7 days
Get-ChildItem "$backupDirectory\*.bak" |
Where-Object { $_.LastWriteTime -le (Get-Date).AddDays(-7) } |
ForEach-Object { Remove-Item $_ -Force }

foreach ($database in $dbs | where { $_.IsSystemObject -eq $False})
{
    $dbName = $database.Name      
    $timestamp = Get-Date -format yyyy-MM-dd-HHmmss
    $targetPath = $backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak"
    $smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
    $smoBackup.Action = "Database"
    $smoBackup.BackupSetDescription = "Full Backup of " + $dbName
    $smoBackup.BackupSetName = $dbName + " Backup"
    $smoBackup.Database = $dbName
    $smoBackup.MediaDescription = "Disk"
    $smoBackup.Devices.AddDevice($targetPath, "File")
    $smoBackup.SqlBackup($server)                
}

Start-Sleep -s 15

#Copy all items that were create today and copy them to $onlineDirectory
Get-ChildItem "$backupDirectory\*.bak" |
Where-Object { $_.lastwritetime -ge (Get-Date).AddDays(-1)} |
ForEach-Object {Copy-Item $_ -Destination $onlineDirectory }

#Delete all items that are older than 7 days and were not created on Sundays, or delete them always if they are older than 90 days
Get-ChildItem "$onlineDirectory\*.bak" |
Where-Object {((($_.lastwritetime -lt (Get-Date).AddDays(-7)) -and ($_.lastwritetime.Dayofweek -ne 'Sunday')) -or ($_.lastwritetime -lt (Get-Date).AddDays(-90)))} |
ForEach-Object {Remove-Item $_ -force }
