 $api_key = ""
$api_secret = ""
$url=""
$server_name=""

#Get Backup status
$backup=(C:\Scripts\BackupStatus.ps1 $server_name) | Out-String
$arr = $backup -split ' '

$backupStatus=$arr[0];

$time=$arr[1..($arr.length-1)] -join ' '

$backupTime=(($time | Get-Date).ToUniversalTime()) | Get-Date -format s
$timestamp=Get-Date -format s

#Generate signature
$message = "$timestamp$api_key"
$hmacsha = New-Object System.Security.Cryptography.HMACSHA256
$hmacsha.key = [Text.Encoding]::ASCII.GetBytes($api_secret)
$signature = $hmacsha.ComputeHash([Text.Encoding]::ASCII.GetBytes($message))
$signature = [BitConverter]::ToString($signature).Replace('-','').ToLower()

$params = @{"status"=$backupStatus;
"time"=$backupTime;
"timestamp"=$timestamp;
"token"=$api_key;
"signature"=$signature;
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -Method POST -Body $params
