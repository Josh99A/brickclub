param(
  [Alias("d")]
  [string]$DeviceId,

  [string]$EmulatorHost,

  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$FlutterArgs = @()
)

$ErrorActionPreference = "Stop"

$adbCandidates = @()
$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
if ($adbCommand) {
  $adbCandidates += $adbCommand.Source
}
if ($env:ANDROID_HOME) {
  $adbCandidates += Join-Path $env:ANDROID_HOME "platform-tools\adb.exe"
}
if ($env:ANDROID_SDK_ROOT) {
  $adbCandidates += Join-Path $env:ANDROID_SDK_ROOT "platform-tools\adb.exe"
}
if ($env:LOCALAPPDATA) {
  $adbCandidates += Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
}

$adbCandidates = $adbCandidates | Where-Object { $_ -and (Test-Path $_) }

if (-not $adbCandidates) {
  throw "adb.exe was not found. Install Android SDK Platform Tools or add adb to PATH."
}

$adb = @($adbCandidates)[0]
$ports = @(9099, 5001, 8080, 9199, 4000, 8025)

if (-not $EmulatorHost) {
  $candidateHosts = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
      $_.IPAddress -notlike "127.*" -and
      $_.IPAddress -notlike "169.254.*" -and
      $_.PrefixOrigin -ne "WellKnown" -and
      $_.InterfaceAlias -notmatch "vEthernet|WSL|Docker|Loopback"
    } |
    Sort-Object -Property InterfaceMetric, PrefixLength |
    Select-Object -ExpandProperty IPAddress

  $EmulatorHost = $candidateHosts |
    Where-Object {
      Test-NetConnection -ComputerName $_ -Port 9099 -InformationLevel Quiet -WarningAction SilentlyContinue
    } |
    Select-Object -First 1

  if (-not $EmulatorHost) {
    $EmulatorHost = $candidateHosts | Select-Object -First 1
  }
}

if (-not $EmulatorHost) {
  throw "Could not detect a LAN IPv4 address. Pass one with -EmulatorHost, for example: -EmulatorHost 192.168.1.20"
}

if (-not (Test-NetConnection -ComputerName $EmulatorHost -Port 9099 -InformationLevel Quiet -WarningAction SilentlyContinue)) {
  throw "Firebase Auth emulator is not reachable at ${EmulatorHost}:9099. Restart the Firebase emulators after the firebase.json host change, and allow the emulator ports through Windows Firewall."
}

Write-Host "Configuring adb reverse ports for BrickClub development..."
foreach ($port in $ports) {
  & $adb reverse "tcp:$port" "tcp:$port" | Out-Null
  Write-Host "  device 127.0.0.1:$port -> host 127.0.0.1:$port"
}

Write-Host ""
Write-Host "Starting Flutter with Firebase emulators on ${EmulatorHost}..."
$flutterCommandArgs = @(
  "run",
  "--dart-define=USE_FIREBASE_EMULATORS=true",
  "--dart-define=FIREBASE_EMULATOR_HOST=$EmulatorHost"
)
if ($DeviceId) {
  $flutterCommandArgs += @("-d", $DeviceId)
}
$flutterCommandArgs += $FlutterArgs

& flutter @flutterCommandArgs
