# CheckPort.ps1

## Synopsis
This script checks if a port is reachable on a specific host.

## Description
The script checks if a port is reachable on a client and
optionally writes a log entry if the host offline or the port is not reachable.

## Parameters

| Parameter | Type | Mandatory | Default | Description |
| --- | --- | --- | --- | --- |
| -Target | String | true | - | The target ip or hostname to be checked. |
| -Port | Int32 | true | 0 | The port to be checked. |
| -CheckInterval | Int32 | false | 60 | How many seconds there should be between every check. |
| -EnableLogging | SwitchParameter | false | False | Enables the logging function. |
| -LogPath | String | false | - | Shows the path where the log file should be stored. The default is a folder called Logs next to the script |

## Examples

```powershell
.\CheckPort.ps1 -Target "192.168.1.10" -Port 443 -EnableLogging -LogPath "C:\Logs"
```

## Notes
Version:    1.0
Author:     https://github.com/mmnps


