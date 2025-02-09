# Path to config file
$configFilePath = ".\config.json"

# Check if config.json exists
if (!(Test-Path $configFilePath)) {
  Write-Log -Message "Error: Configuration file not found at $configFilePath"
  exit 1
}

# Read and parse the JSON file
$config = Get-Content -Raw -Path $configFilePath | ConvertFrom-Json

# Variables
$processName = $config.processName
$serverFilesPath = $config.serverFilesPath
$serverConsoleExe = $config.serverConsoleExe
$backupFoldersCount = $config.backupFoldersCount
$savegame = "$serverFilesPath\savegame"
$currentBackupFolder = "$serverFilesPath\_backup\Enshrouded_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')"  # Backup directory with timestamp
$logFilePath = "$serverFilesPath\logs\_scripts\cronjob.log"  # Log file path

# Functions
function Write-Log {
  param (
    [string]$Message
  )

  # Create the log message with a timestamp
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  $logMessage = "[$timestamp] $Message"

  # Append the log message to the log file
  Add-Content -Path $logFilePath -Value $logMessage
}

# Creating sub-folders if they do not exist
if (!(Test-Path "$serverFilesPath\_backup")) {
  New-Item -ItemType Directory -Path "$serverFilesPath\_backup" | Out-Null
  Write-Host "Folder created: '$serverFilesPath\_backup'"
}

if (!(Test-Path "$serverFilesPath\logs\_scripts")) {
  New-Item -ItemType Directory -Path "$serverFilesPath\logs\_scripts" | Out-Null
  Write-Host "Folder created: '$serverFilesPath\logs\_scripts'"
}

if (!(Test-Path $savegame)) {
  New-Item -ItemType Directory -Path $savegame | Out-Null
  Write-Host "Folder created: '$savegame'"
}

# Start the job
try {
  Write-Log -Message "## (RE-)STARTING ENSHROUDED SERVER"
  Write-Log -Message "Process name: '$processName'"
  Write-Log -Message "Server location: '$serverFilesPath'"
  Write-Log -Message "Server executable file: '$serverConsoleExe'"
  Write-Log -Message "Server game files: '$savegame'"

  Write-Log -Message "Searching for process '$processName'"
  $process = Get-Process | Where-Object { $_.ProcessName -like "*$processName*" }

  # Server is running -> stop
  if ($process) {
    Write-Log -Message "The process '$($process.name) (PID: $($process.id))' is running"

    # Graceful shutdown
    Write-Log -Message "Initiating graceful shutdown of the Enshrouded server..."
    try {
      $process | Stop-Process
    } catch {
      Write-Log -Message "Failed to send graceful shutdown command: $_"
    }

    # Force shutdown if the process is still running
    Write-Log -Message "Verifying if the server process has stopped..."
    Start-Sleep -Seconds 5
    if (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*$processName*" }) {
      Write-Log -Message "Server process is still running. Stopping the process forcefully..." 
      $process | Stop-Process -Force
      Start-Sleep -Seconds 5
    } else {
      Write-Log -Message "Server process has stopped successfully!" 
    }
  } else {
    Write-Log -Message "The process is not running"
  }

  # Backup of the game files
  Write-Log -Message "Starting backup of server gamefiles files to '$currentBackupFolder'..."
  try {
    Copy-Item -Path $savegame -Destination $currentBackupFolder -Recurse -Force
    Write-Log -Message "Backup completed successfully"
  } catch {
    Write-Log -Message "Backup failed: $_"
  }

  # Deleting older backup folders - sorted by creation date, descending
  Write-Log -Message "Searching for older backups in '$currentBackupFolder'..."
  $backupDirs = Get-ChildItem -Path "$serverFilesPath\_backup" -Directory | Sort-Object CreationTime -Descending
  $foldersToDelete = $backupDirs | Select-Object -Skip $backupFoldersCount

  Write-Log -Message "Number of folders to delete: $($foldersToDelete.Count)"

  foreach ($folder in $foldersToDelete) {
    Write-Log -Message "Deleting folder: '$($folder.FullName)'"
    Remove-Item -Path $folder.FullName -Recurse -Force
  }

  # Starting the server
  Write-Log -Message "Starting server"
  Start-Process -WindowStyle hidden -FilePath $serverConsoleExe

  # Wait for 5 seconds before getting the startet process
  Write-Log -Message "Wait 5 seconds before checking if the server is running"
  Start-Sleep -Seconds 5
 
  $process = Get-Process | Where-Object { $_.ProcessName -like "*$processName*" }

  # Check if the process is still running
  if ($process) {
    Write-Log -Message "The process '$($process.name)' is running"
    $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::RealTime
  } else {
    Write-Log -Message "The process is not running."
    exit 1
  }

} catch {
  Write-Log -Message "Failed to restart the server: $_"
  exit 1
} finally {
  Write-Log -Message "## SCRIPT ENDED"
  Write-Log -Message "------------------------------------"
}