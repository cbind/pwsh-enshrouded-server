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
$processName = $config.processName

# Output
Write-Host ""
Write-Host "## STOPPING ENSHROUDED SERVER"
Write-Host "------------------------------------"

# Start the process in the background
try {
  Write-Host "Searching for process '$processName'"
  $process = Get-Process | Where-Object { $_.ProcessName -like "*$processName*" }

  # Check if the process is still running
  if ($process) {
    Write-Host "The process '$($process.name):$($process.id)' is running"

    # Step 1: Graceful shutdown
    Write-Host "Initiating graceful shutdown of the Enshrouded server..."
    try {
      $process | Stop-Process
    } catch {
      Write-Host "Failed to send graceful shutdown command: $_"
    }

    # Step 2: Verify the server has stopped
    Write-Output "Verifying if the server process has stopped..."
    Start-Sleep -Seconds 5
    if (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*$processName*" }) {
      Write-Host "Server process is still running. Stopping the process forcefully..." 
      $process | Stop-Process -Force
      Start-Sleep -Seconds 5
    } else {
      Write-Host "Server process has stopped successfully!" 
    }
  } else {
    Write-Host "The process is not running"
  }
} catch {
  Write-Host "Failed to start the server: $_"
  exit 1
}