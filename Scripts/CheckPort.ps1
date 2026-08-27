<#
.SYNOPSIS
    This script checks if a port is reachable on a specific host.

.DESCRIPTION
    The script checks if a port is reachable on a client and
    optionally writes a log entry if the host offline or the port is not reachable.

.PARAMETER Target
    The target ip or hostname to be checked.

.PARAMETER Port
    The port to be checked.

.PARAMETER CheckInterval
    How many seconds there should be between every check.

.PARAMETER EnableLogging
    Enables the logging function.

.PARAMETER LogPath
    Specifies the path where the log file should be stored The default is a folder called Logs next to the script

.EXAMPLE
    .\CheckPort.ps1 -Target "192.168.1.10" -Port 443 -EnableLogging -LogPath "C:\Logs"

.NOTES
    Version:    1.0
    Author:     https://github.com/mmnps
#>

#Requires -Version 4.0

######################
###   Parameters   ###
######################
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$Target,
    [Parameter(Mandatory)][ValidateRange(1,65535)][int]$Port,
    [int]$CheckInterval = 60,
    [switch]$EnableLogging,
    [string]$LogPath
)


#########################
###   Configutation   ###
#########################
$ProgramName = "CheckPort"
$global:ProgressPreference = "SilentlyContinue"
$global:WarningPreference = "SilentlyContinue"


#####################
###   Functions   ###
#####################
function Write-Log {
    param (
        [ValidateSet('OK','ERROR')][string]$Level = "OK",
        [Parameter(Mandatory)][string]$Text
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Msg = "[$Timestamp] - $Level - $Text"
    $LogName = "$($ProgramName)_$(Get-Date -Format yyyy-MM-dd).log"

    if ($EnableLogging) {
        if (-not $LogPath) {
            $LogPath = Join-Path $PSScriptRoot "Logs"
        }
        if (-not (Test-Path $LogPath)) {
            try {
                New-Item -ItemType Directory -Path $LogPath | Out-Null
            }
            catch {
                Write-Host "The log path cannot be created. It will be set to the default path. -> $($_.Exception.Message)" -ForegroundColor Red
                $LogPath = Join-Path $PSScriptRoot "Logs"
                if (-not (Test-Path $LogPath)) {
                    try {
                        New-Item -ItemType Directory -Path $LogPath | Out-Null
                    }
                    catch {
                        Write-Host "The default log path cannot be created either. Logging is disabled. -> $($_.Exception.Message)" -ForegroundColor Red
                        $script:EnableLogging = $false
                    }
                }
            }
        }

        if ($EnableLogging) {
            $LogFile = Join-Path $LogPath $LogName
            try {
                Add-Content -Path $LogFile -Value $Msg
            }
            catch {
                Write-Host "The log entry cannot be written. -> $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    switch ($Level) {
        'OK'    { Write-Host $Msg -ForegroundColor Green }
        'ERROR' { Write-Host $Msg -ForegroundColor Red }
    }
}


######################
###   Main logic   ###
######################
$Connection = Test-Connection -ComputerName $Target -Count 1 -Quiet -ErrorAction SilentlyContinue
if (-not $Connection) {
    Write-Log -Level ERROR -Text "The host is offline. The port cannot be checked."
    exit 1
}

$Offline = $false
$CountOffline = 0
$CountOnline = 0

try {
    while ($true) {
        $PortStatus = Test-NetConnection -ComputerName $Target -Port $Port -InformationLevel Quiet

        if (-not $PortStatus) {
            Write-Log -Level ERROR -Text "Port $Port is not reachable on $Target."
            $Offline = $true
            $CountOffline++
        }
        else {
            if ($Offline) {
                Write-Log -Level OK -Text "Port $Port is reachable again on $Target."
                $Offline = $false
            }
            else {
                Write-Host "Port $Port is reachable on $Target." -ForegroundColor Green
            }
            $CountOnline++
        }

        Start-Sleep -Seconds $CheckInterval
    }
}

finally {
    Write-Host "`n----------------------------------" -ForegroundColor DarkGray
    Write-Host "Summary:"
    Write-Host "Online: " -NoNewline
    Write-Host $CountOnline -ForegroundColor Green
    Write-Host "Offline: " -NoNewline
    Write-Host $CountOffline -ForegroundColor Red
}

