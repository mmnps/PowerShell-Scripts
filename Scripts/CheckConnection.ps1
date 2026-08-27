<#
.SYNOPSIS
    Checks if a host is reachable.

.DESCRIPTION
    Continuously checks if a host is reachable and writes the results into a log file.
    At the end, it displays a report showing how often a host was offline or online.

.PARAMETER Target
    The host to be checked.

.PARAMETER CheckInterval
    How many seconds there will be between every check.

.PARAMETER EnableLogging
    Enables the logging function.

.PARAMETER LogPath
    Shows the path to the log file. The default is a "Logs" folder next to the script.

.EXAMPLE
    .\TestConnection.ps1 -Target 192.168.1.10 -CheckInterval 30 -EnableLogging -LogPath "C:\Logs"

.NOTES
    Version:    1.1
    Author:     https://github.com/mmnps
#>

#Requires -Version 3.0

#####################
###   Parameter   ###
#####################
[CmdletBinding()]
param (
    [Parameter(Mandatory)][string]$Target,
    [ValidateRange(1, [int]::MaxValue)][int]$CheckInterval = 10,
    [switch]$EnableLogging,
    [string]$LogPath
)

#########################
###   Configuration   ###
#########################
$ProgramName = "CheckConnection"
$WarningPreference = "SilentlyContinue"


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
                        $EnableLogging = $false
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
$CountOffline = 0
$CountOnline = 0
$Offline = $false

try {
    while ($true) {
        $Connection = Test-Connection -ComputerName $Target -Quiet -Count 2 -ErrorAction SilentlyContinue

        if (-not $Connection) {
            Write-Log -Level ERROR -Text "$Target is not reachable."
            $CountOffline++
            $Offline = $true
        }
        else {
            if ($Offline) {
                Write-Log -Level OK -Text "$Target is reachable again."
                $Offline = $false
            }
            else {
                Write-Host "$Target is online."
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
