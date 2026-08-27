<#
.SYNOPSIS
    Compresses multiple folders at once.

.DESCRIPTION
    This script compresses multiple folders at once and
    stores them to a different path.
    A logging feature is also available as an option.

.PARAMETER InputPath
    The source folder whose contents are to be compressed.

.PARAMETER OutputPath
    The folder where the .zip files will be stored. If it doesn't exist, the script creates it automatically.

.PARAMETER EnableLogging
    Enables the logging function.

.PARAMETER LogPath
    Specifies the path where the log file should be stored. The default is a folder called Logs next to the script

.EXAMPLE
    .\CompressFolders.ps1 -InputPath "C:\SourceFolders" -OutputPath "C:\Archive" -EnableLogging -LogPath "C:\Logs"

.NOTES
    Version:    1.0
    Author:     https://github.com/mmnps
#>

#Requires -Version 5.0


######################
###   Parameters   ###
######################
[CmdletBinding()]
param (
    [Parameter(Mandatory)][ValidateScript({ Test-Path $_ })][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputPath,
    [switch]$EnableLogging,
    [string]$LogPath
)


#########################
###   Configuration   ###
#########################
$ProgramName = "CompressFolders"
$global:ProgressPreference = "SilentlyContinue"



#####################
###   Functions   ###
#####################
function Write-Log {
    param (
        [ValidateSet('INFO','ERROR')][string]$Level = "INFO",
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
        'INFO'    { Write-Host $Msg -ForegroundColor Green }
        'ERROR' { Write-Host $Msg -ForegroundColor Red }
    }
}


######################
###   Main logic   ###
######################

# Check output path
if (-not (Test-Path $OutputPath)) {
    try {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
        Write-Log -Level INFO -Text "The output path $OutputPath was created." 
    }
    catch {
        Write-Log -Level ERROR -Text "Output path cannot be created. -> $($_.Exception.Message)"
        exit 1
    }
}

# Get the folders in the InputPath
$Folders = Get-ChildItem -Directory -Path $InputPath

# Statistics
$CountErrors = 0
$CountSuccesses = 0
$ErrorFolders = @()

# Process folders
foreach ($Folder in $Folders) {
    $FolderName = $Folder.Basename + ".zip"
    $NewFolderPath = Join-Path $OutputPath $FolderName

    try {
        Compress-Archive -Path $Folder.Fullname -DestinationPath $NewFolderPath -Force
        Write-Log -Level INFO -Text "$Folder successfully compressed."
        $CountSuccesses++
    }
    catch {
        Write-Log -Level ERROR -Text "An error occurred while processing the folder $Folder."
        $CountErrors++
        $ErrorFolders += $Folder
    }
}

# Log statistics
Write-Log -Level INFO -Text "---------------------------"
Write-Log -Level INFO -Text "Processing has been completed..."
Write-Log -Level INFO -Text "Successes: $CountSuccesses"
Write-Log -Level INFO -Text "Errors: $CountErrors"
Write-Log -Level INFO -Text "---------------------------"
if ($ErrorFolders.Count -gt 0) {
    Write-Log -Level INFO -Text "Failed folders:"
    Write-Log -Level INFO -Text ($ErrorFolders -join "`n")
}