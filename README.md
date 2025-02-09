# Enshrouded Dedicated Server Powershell Scripts

This repository provides some scripts to run a dedicated server for Enshrouded in Windows over Powershell. <br>
I created this repository just for fun. Feel free to use or change it.

## Before getting started

1. Download [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) and add the cmdlet to your path environment
2. If you are not allowed to execute Powershell scripts, run Powershell as an administrator and execute the following command
    ```pwsh
    Set-ExecutionPolicy Bypass -Scope Process -Force
    ```

## Configuring the JSON file

You have to configure the `config.json` file because the values are used in all the scripts. You can choose any folders you want. The folders for the server files and the executable should be the same.

```json
{
  "processName": "enshrouded_server",
  "serverFilesPath": "C:\\Folder\\AnotherFolder\\EnshroudedServerFolder",
  "serverConsoleExe": "C:\\Folder\\AnotherFolder\\EnshroudedServerFolder\\enshrouded_server.exe",
  "backupFoldersCount": 1000
}
```

* **processName** The name of the process (you should not change it if you not have to)
* **serverFilesPath** The path to the installation location of the dedicated server
* **serverConsoleExe** The path to the executable of the dedicated server
* **backupFoldersCount** The maximum amount of backups by the descending backup folder creation time

**Note:** Be careful that there are no trailing backslashes on the folder paths.

## Local firewall and ports

Run Powershell as administrator and insert the following commands:

```pwsh
New-NetFirewallRule -DisplayName "Enshrouded Server" -Direction Inbound -LocalPort 15636,15637 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Enshrouded Server" -Direction Inbound -LocalPort 15636,15637 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Enshrouded Server" -Direction Outbound -LocalPort 15636,15637 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Enshrouded Server" -Direction Outbound -LocalPort 15636,15637 -Protocol UDP -Action Allow
```

You also have to grand UDP/TCP ports 15636 and 15637 into your router if you want to access the server from the world wide web. 
If you're running the server in your home it is maybe recommended to configure DynDNS into your router because the public IPv4 address is changing over time by your provider.

## Server installation

Install the server by running the powershell script `.\install.ps1` in your Powershell. If the script is executing successfully, you should see the server files in your configured `serverFilesPath` location.

You have to start the `enshrouded_server.exe` file inside the server installation location once because it creates some other files like the `enshrouded_server.json`.

## Server Configuration

After installing the server you can configure the server before you start it first. Inside the `serverFilesPath` location there is a `enshrouded_server.json` file you can edit. 
I recommend to NOT CHANGE the IP and Port if you dont know what you are doing.

Recommended settings are:

- Name
- Password for Default user group
- Maximum Server slots

Add a default access group to protect the server for foreign access.

```json
"userGroups": [
  {
    "name": "Friend",
    "password": "<your-password-here>",
    "canKickBan": false,
    "canAccessInventories": true,
    "canEditBase": true,
    "canExtendBase": true,
    "reservedSlots": 0
  }
]
```

## Running the scripts manually

**Start**

Run `.\start.ps1` in your Powershell to start the server. If it starts correctly, you can try to search for your server over the IP adresss `127.0.0.1:15637`. After adding the server to your favorites, you can try to join.

**Stop**

Run `.\stop.ps1` in your Powershell to stop the server. If your server is currently running it should disappear from the servers list.

**Restart**

Try to execute the `.\restart.ps1` script in to szenarios:

- Server is not running &rarr; Server should be started correctly
- Server is running &rarr; Server should be restarted correctly

The restart script is working a bit different. It outputs all messages into a file located under `{serverFilesPath}\logs\_scripts`. <br>
Check if the backup from the saved game are located under `{serverFilesPath}\_backup`.

## Cronjob for restarting the server

It is recommended to restarting the server every night for avoiding performance issues. You can use the task scheduler in windows to execute the `restart.ps1` script whenever you want to.

## Backups

The `restart.ps1` script automatically creates backups under `{serverFilesPath}\_backup`. Inside the `configig.json` you can configure the amount of backups.


