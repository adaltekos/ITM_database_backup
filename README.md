# Script for IT-Manager SQL Database Backup

## Description
This PowerShell script is used for IT-Manager SQL database backup. It creates a backup of all databases on a SQL Server instance, deletes old backup files in the local backup directory, copies the backup files created today to an online backup directory, and deletes backup files that are older than 7 days and were not created on Sundays or that are older than 90 days from the online backup directory.

## Prerequisites
- PowerShell version 3.0 or later.
- Microsoft.SqlServer.SmoExtended library.

## Configuration
1. Set the local backup directory by providing the path to the `$backupDirectory` variable. For example, `$backupDirectory = "C:\backup\mssql_backup"`.
2. Set the online backup directory by providing the path to the `$onlineDirectory` variable. For example, `$onlineDirectory = "\\192.168.0.0\backup_servers\database"`.
3. Set the SQL Server instance location by providing the server instance name to the `$mySrvConn.ServerInstance` variable. For example, `$mySrvConn.ServerInstance = "192.168.0.0\database"`.
4. Provide the login and password to the `$mySrvConn.Login` and `$mySrvConn.Password` variables, respectively.
