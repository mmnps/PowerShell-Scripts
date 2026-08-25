# CheckConnection.ps1

## Synopsis
Checks if a host is reachable.

## Description
Continuously checks if a host is reachable and writes the results into a log file.
At the end, it displays a report showing how often a host was offline or online.

## Parameters

| Parameter | Type | Mandatory | Default | Description |
| --- | --- | --- | --- | --- |
| -Target | String | true | - | The host to be checked. |
| -CheckInterval | Int32 | false | 10 | How many seconds there will be between every check. |
| -EnableLogging | SwitchParameter | false | False | Enables the logging function. |
| -LogPath | String | false | - | Shows the path to the log file. The default is a "Logs" folder next to the script. |

## Examples

```powershell
.\TestConnection.ps1 -Target 192.168.1.10 -CheckInterval 30 -EnableLogging -LogPath "C:\Logs"
```
