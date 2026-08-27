# CompressFolders.ps1

## Synopsis
Compresses multiple folders at once.

## Description
This script compresses multiple folders at once and
stores them to a different path.
A logging feature is also available as an option.

## Parameters

| Parameter | Type | Mandatory | Default | Description |
| --- | --- | --- | --- | --- |
| -InputPath | String | true | - | The source folder whose contents are to be compressed. |
| -OutputPath | String | true | - | The folder where the .zip files will be stored. If it doesn't exist, the script creates it automatically. |
| -EnableLogging | SwitchParameter | false | False | Enables the logging function. |
| -LogPath | String | false | - | Specifies the path where the log file should be stored. The default is a folder called Logs next to the script |

## Examples

```powershell
.\CompressFolders.ps1 -InputPath "C:\SourceFolders" -OutputPath "C:\Archive" -EnableLogging -LogPath "C:\Logs"
```


