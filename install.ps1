# Define variables
$configFilePath = ".\config.json"
$appID = "2278520"                         # Enshrouded Dedicated Server App ID

# Check if config.json exists
if (!(Test-Path $configFilePath)) {
    Write-Host "Error: Configuration file not found at $configFilePath"
    exit 1
}

# Read and parse the JSON file
$config = Get-Content -Raw -Path $configFilePath | ConvertFrom-Json

# Define install path
$installPath = $config.serverFilesPath     

# Ensure the install path exists
if (!(Test-Path $installPath)) {
  Write-Host "Creating server installation directory at $installPath..."
  New-Item -ItemType Directory -Path $installPath | Out-Null
}

# Check if steamcmd is available in the system path
if (-not (Get-Command steamcmd -ErrorAction SilentlyContinue)) {
  Write-Host "Error: SteamCMD is not found in the system path. Please install it or add it to the PATH environment variable."
  exit 1
}

# Run SteamCMD to install/update the Enshrouded server
Write-Host "Installing or updating Enshrouded Dedicated Server..."
Start-Process -FilePath "steamcmd" -ArgumentList "+force_install_dir `"$installPath`" +login anonymous +app_update $appID validate +quit" -NoNewWindow -Wait

Write-Host "Installation complete. Server is located at: $installPath"
Write-Host "You can start your server using the appropriate executable inside the installation directory."