# ps2md.ps1

## Synopsis
Generate a markdown file from a PowerShell file.

## Description
This script generates a simple documentation for a PowerShell script.

The markdown file will be stored in the same folder as the script, unless a different output path is specified.

## Parameters

| Parameter | Type | Mandatory | Default | Description |
| --- | --- | --- | --- | --- |
| -File | String | true | - | The path to the .ps1 file that should be documented. |
| -OutputPath | String | false | - | The folder where the markdown file should be stored. The default is the same folder as the script. |

## Examples

```powershell
.\ps2md.ps1 -File "C:\Scripts\CheckPort.ps1"
```

```powershell
.\ps2md.ps1 -File ".\CheckPort.ps1" -OutputPath "C:\Docs"
```