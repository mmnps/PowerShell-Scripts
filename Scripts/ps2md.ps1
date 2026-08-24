<#
.SYNOPSIS
    Generate a markdown file from a PowerShell file.

.DESCRIPTION
    This script generates a simple documentation for a PowerShell script.
    The markdown file will be stored in the same folder as the script,
    unless a different output path is specified.

.PARAMETER File
    The path to the .ps1 file that should be documented.

.PARAMETER OutputPath
    The folder where the markdown file should be stored. The default is the same folder as the script.

.EXAMPLE
    .\ps2md.ps1 -File "C:\Scripts\CheckPort.ps1"

.EXAMPLE
    .\ps2md.ps1 -File ".\CheckPort.ps1" -OutputPath "C:\Docs"

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
    [Parameter(Mandatory)][ValidateScript({ Test-Path $_ -PathType Leaf })][string]$File,
    [string]$OutputPath
)

#####################
###   Main logic  ###
#####################
$ResolvedFile = (Resolve-Path $File).Path
$Help = Get-Help -Full $ResolvedFile

if (-not $OutputPath) {
    $OutputPath = Split-Path $ResolvedFile -Parent
}

if (-not (Test-Path $OutputPath)) {
    try {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }
    catch {
        Write-Host "The output path cannot be created. -> $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

$ScriptName = Split-Path $ResolvedFile -Leaf
$MdName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptName) + ".md"
$MdFile = Join-Path $OutputPath $MdName

$sb = New-Object System.Text.StringBuilder

[void]$sb.AppendLine("# $ScriptName")
[void]$sb.AppendLine()

# --- Synopsis ---
if ($Help.Synopsis) {
    [void]$sb.AppendLine("## Synopsis")
    [void]$sb.AppendLine($Help.Synopsis.Trim())
    [void]$sb.AppendLine()
}

# --- Description ---
if ($Help.Description) {
    [void]$sb.AppendLine("## Description")
    foreach ($d in $Help.Description) {
        [void]$sb.AppendLine($d.Text.Trim())
    }
    [void]$sb.AppendLine()
}

# --- Parameters ---
if ($Help.Parameters.Parameter) {
    [void]$sb.AppendLine("## Parameters")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("| Parameter | Type | Mandatory | Default | Description |")
    [void]$sb.AppendLine("| --- | --- | --- | --- | --- |")

    foreach ($p in $Help.Parameters.Parameter) {
        $Name = "-$($p.Name)"
        $Type = if ($p.Type.Name) { $p.Type.Name } else { "-" }
        $Mandatory = $p.Required
        $Default = if ($p.DefaultValue) { $p.DefaultValue } else { "-" }
        $Description = (($p.Description | ForEach-Object { $_.Text }) -join " ").Trim()

        [void]$sb.AppendLine("| $Name | $Type | $Mandatory | $Default | $Description |")
    }
    [void]$sb.AppendLine()
}

# --- Examples ---
if ($Help.Examples.Example) {
    [void]$sb.AppendLine("## Examples")
    [void]$sb.AppendLine()
    foreach ($Example in $Help.Examples.Example) {
        [void]$sb.AppendLine('```powershell')
        [void]$sb.AppendLine($Example.Code.Trim())
        [void]$sb.AppendLine('```')
        [void]$sb.AppendLine()
    }
}

# --- Notes ---
if ($Help.AlertSet.Alert) {
    [void]$sb.AppendLine("## Notes")
    foreach ($Note in $Help.AlertSet.Alert) {
        [void]$sb.AppendLine($Note.Text.Trim())
    }
    [void]$sb.AppendLine()
}

try {
    Set-Content -Path $MdFile -Value $sb.ToString() -Encoding UTF8
    Write-Host "Documentation created: $MdFile" -ForegroundColor Green
}
catch {
    Write-Host "The markdown file could not be created. -> $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}