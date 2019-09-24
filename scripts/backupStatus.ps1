 #region Parameters
[CmdletBinding()]
param
(
        [String]$ServerName
)
#endregion Parameters
$rsession = New-PSSession -ComputerName $ServerName
Invoke-Command -Session $rsession -ScriptBlock {add-pssnapin windows.serverbackup -ErrorAction SilentlyContinue; $status = get-wbjob -previous 1;$runstatus = get-wbjob}
$rstatus = Invoke-Command -Session $rsession -ScriptBlock {$status}
$runningstatus = Invoke-Command -Session $rsession -ScriptBlock {$runstatus}
remove-pssession $rsession
$hresult=$rstatus.errordescription
$outstatus="Success"
if ($rstatus.hresult -eq "0" -and !$hresult)
    {
    $Backup = "{0} {1}" -f $outstatus, $rstatus.endtime
    }
elseif ($hresult.Contains("warnings"))
    {
    $Backup = "Warning {0}" -f $rstatus.endtime
    }
else
    {
    $Backup = "Failed {0}" -f $rstatus.endtime
    }
if ($runningstatus.CurrentOperation)
    {$Backup = $runningstatus.CurrentOperation}
Write-output $Backup
