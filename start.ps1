# Path to config file
$configFilePath = ".\config.json"

# Check if config.json exists
if (!(Test-Path $configFilePath)) {
  Write-Host "Error: Configuration file not found at $configFilePath"
  exit 1
}

# Read and parse the JSON file
$config = Get-Content -Raw -Path $configFilePath | ConvertFrom-Json

# Variables
$appID = "2278520"
$processName = $config.processName
$serverFilesPath = $config.serverFilesPath
$serverConsoleExe = $config.serverConsoleExe
$savegame = "$serverFilesPath\savegame"

# Output
Write-Host ""
Write-Host "## STARTING ENSHROUDED SERVER"
Write-Host "------------------------------------"
Write-Host "Process name: $processName"
Write-Host "Server location: $serverFilesPath"
Write-Host "Server executable file: $serverConsoleExe"
Write-Host ""

try {
  # Run SteamCMD to update the Enshrouded Dedicated Server
  Write-Host "Updateing server"
  Start-Process -FilePath "steamcmd" -ArgumentList "+force_install_dir `"$serverFilesPath`" +login anonymous +app_update $appID validate +quit" -NoNewWindow -Wait

  # Start the process in the background
  Write-Host "Starting server"
  Start-Process -WindowStyle hidden -FilePath $serverConsoleExe

  # Wait for 5 seconds before getting the startet process
  Write-Host "Wait 5 seconds before checking if the server is running"
  Start-Sleep -Seconds 5
 
  $process = Get-Process | Where-Object { $_.ProcessName -like "*$processName*" }

  # Check if the process is still running
  if ($process) {
    Write-Host "The process '$($process.name)' is running"
    $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::RealTime
  } else {
    Write-Host "The process is not running."
    exit 1
  }
} catch {
  Write-Host "Failed to start the server: $_"
  exit 1
}