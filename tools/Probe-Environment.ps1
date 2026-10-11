<#
.SYNOPSIS
  Read-only inventory of the Windows PC for the FNV -> FO4 project.
.DESCRIPTION
  Writes docs/ENVIRONMENT.probe.json and prints a short summary. It changes nothing,
  launches no game and never prints credentials or token values: API-key variables are
  reported only as "set" / "not set". Run from the repo root:
    powershell -ExecutionPolicy Bypass -File tools\Probe-Environment.ps1
#>
param([string]$Out = "docs\ENVIRONMENT.probe.json")
$ErrorActionPreference = "Continue"

function Try-Get($sb) { try { & $sb } catch { $null } }
function Hash($p) { if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) { (Get-FileHash -LiteralPath $p -Algorithm SHA256).Hash } }
function FileInfo($p) {
  if ($p -and (Test-Path -LiteralPath $p -PathType Leaf)) {
    $i = Get-Item -LiteralPath $p
    [ordered]@{ path = $p; bytes = $i.Length; modified = $i.LastWriteTimeUtc.ToString("o"); version = $i.VersionInfo.FileVersion; sha256 = (Hash $p) }
  }
}

$r = [ordered]@{ probed_utc = (Get-Date).ToUniversalTime().ToString("o") }
$os = Try-Get { Get-CimInstance Win32_OperatingSystem }
$r.os = [ordered]@{ caption = $os.Caption; version = $os.Version; build = $os.BuildNumber; arch = $os.OSArchitecture }
$r.is_admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$r.disks = @(Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -ne $null } |
  ForEach-Object { [ordered]@{ drive = $_.Name; free_gb = [math]::Round($_.Free/1GB,1); used_gb = [math]::Round($_.Used/1GB,1) } })

# --- Game installs (registry first, then common Steam libraries) ---
$regs = @{
  fnv = @("HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\FalloutNV", "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games\1454587428")
  fo4 = @("HKLM:\SOFTWARE\Wow6432Node\Bethesda Softworks\Fallout4",  "HKLM:\SOFTWARE\WOW6432Node\GOG.com\Games\1998527297")
}
$paths = @{}
foreach ($g in $regs.Keys) {
  foreach ($k in $regs[$g]) {
    $v = Try-Get { $p = Get-ItemProperty -Path $k; if ($p.'Installed Path') { $p.'Installed Path' } else { $p.path } }
    if ($v -and (Test-Path -LiteralPath $v)) { $paths[$g] = $v; break }
  }
}
$steam = @(); foreach ($d in (Get-PSDrive -PSProvider FileSystem).Root) {
  foreach ($s in @("Program Files (x86)\Steam\steamapps\common","SteamLibrary\steamapps\common","Steam\steamapps\common")) {
    $c = Join-Path $d $s; if (Test-Path $c) { $steam += $c } } }
if (-not $paths.fnv) { foreach ($c in $steam) { foreach ($n in "Fallout New Vegas","Fallout New Vegas enhanced edition") { if (Test-Path "$c\$n\FalloutNV.exe") { $paths.fnv = "$c\$n" } } } }
if (-not $paths.fo4) { foreach ($c in $steam) { if (Test-Path "$c\Fallout 4\Fallout4.exe") { $paths.fo4 = "$c\Fallout 4" } } }

foreach ($g in "fnv","fo4") {
  $root = $paths[$g]; $exe = if ($g -eq "fnv") { "FalloutNV.exe" } else { "Fallout4.exe" }
  $entry = [ordered]@{ root = $root }
  if ($root) {
    $data = Join-Path $root "Data"
    $entry.exe = FileInfo (Join-Path $root $exe)
    $entry.masters = @(Get-ChildItem -LiteralPath $data -Include *.esm,*.esp,*.esl -File -ErrorAction SilentlyContinue |
      ForEach-Object { [ordered]@{ name = $_.Name; bytes = $_.Length; sha256 = (Hash $_.FullName) } })
    $entry.archives = @(Get-ChildItem -LiteralPath $data -Filter *.ba? -File -ErrorAction SilentlyContinue | ForEach-Object { [ordered]@{ name = $_.Name; bytes = $_.Length } })
    $entry.strings_dirs = @(Get-ChildItem -LiteralPath $data -Directory -ErrorAction SilentlyContinue | Where-Object Name -match 'Strings|Video|F4SE|NVSE' | ForEach-Object Name)
    $entry.loose_top_level_dirs = @(Get-ChildItem -LiteralPath $data -Directory -ErrorAction SilentlyContinue | ForEach-Object Name)
  }
  $r[$g] = $entry
}
if ($paths.fo4) {
  $r.fo4.creation_kit = FileInfo (Join-Path $paths.fo4 "CreationKit.exe")
  $r.fo4.tools = [ordered]@{ archive2 = FileInfo (Join-Path $paths.fo4 "Tools\Archive2\Archive2.exe"); elric = FileInfo (Join-Path $paths.fo4 "Tools\Elric\Elrich.exe") }
  $r.fo4.f4se = FileInfo (Join-Path $paths.fo4 "f4se_loader.exe")
  $r.fo4.papyrus_compiler = FileInfo (Join-Path $paths.fo4 "Papyrus Compiler\PapyrusCompiler.exe")
  $ck = Join-Path $paths.fo4 "CreationKit.ini"
  $r.fo4.creationkit_ini_multiple_masters = if (Test-Path $ck) { (Select-String -Path $ck -Pattern 'bAllowMultipleMaster' | ForEach-Object Line) } else { "CreationKit.ini absent" }
  $docs = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "My Games\Fallout4"
  $r.fo4.documents_dir = $docs
  $r.fo4.plugins_txt_present = Test-Path (Join-Path $env:LOCALAPPDATA "Fallout4\plugins.txt")
  $r.fo4.save_count = @(Get-ChildItem (Join-Path $docs "Saves") -Filter *.fos -ErrorAction SilentlyContinue).Count
  $r.fo4.language_ini = if (Test-Path "$docs\Fallout4.ini") { (Select-String "$docs\Fallout4.ini" -Pattern 'sLanguage' | ForEach-Object Line) }
}

# --- Mod managers / profiles ---
$r.mod_managers = [ordered]@{
  mo2_instances = @(Get-ChildItem "$env:LOCALAPPDATA\ModOrganizer" -Directory -ErrorAction SilentlyContinue | ForEach-Object Name)
  vortex_present = Test-Path "$env:APPDATA\Vortex"
}

# --- Tooling ---
$tools = [ordered]@{}
foreach ($t in @(@("git","--version"),@("python","--version"),@("py","--version"),@("dotnet","--version"),@("node","--version"),@("claude","--version"),@("pwsh","--version"))) {
  $c = Get-Command $t[0] -ErrorAction SilentlyContinue
  $tools[$t[0]] = if ($c) { [ordered]@{ path = $c.Source; version = (Try-Get { & $t[0] $t[1] 2>&1 | Select-Object -First 1 }) } } else { "not found" }
}
foreach ($n in "xEdit.exe","FO4Edit.exe","FNVEdit.exe","ModOrganizer.exe","NifSkope.exe","Delphi") { $tools[$n] = "check manually" }
$r.tools = $tools

# --- Claude CLI: version + auth status only. No tokens printed. ---
$cli = [ordered]@{}
if (Get-Command claude -ErrorAction SilentlyContinue) {
  $st = Try-Get { claude auth status 2>&1 | Out-String }
  # Redact anything that looks like a token or key.
  $cli.auth_status = ($st -replace '(sk-[A-Za-z0-9_\-]{6,}|eyJ[A-Za-z0-9_\-\.]{10,}|[A-Za-z0-9_\-]{32,})','<redacted>').Trim()
}
$cli.ANTHROPIC_API_KEY = if ($env:ANTHROPIC_API_KEY) { "set (value not read; confirm this is NOT intended for billing)" } else { "not set" }
$cli.ANTHROPIC_AUTH_TOKEN = if ($env:ANTHROPIC_AUTH_TOKEN) { "set" } else { "not set" }
$cli.CLAUDE_CODE_USE_BEDROCK = if ($env:CLAUDE_CODE_USE_BEDROCK) { "set" } else { "not set" }
$cli.CLAUDE_CODE_USE_VERTEX = if ($env:CLAUDE_CODE_USE_VERTEX) { "set" } else { "not set" }
$r.claude_cli = $cli

New-Item -ItemType Directory -Force -Path (Split-Path $Out) | Out-Null
$r | ConvertTo-Json -Depth 6 | Set-Content -Encoding UTF8 -Path $Out
Write-Host "Wrote $Out"
Write-Host ("FNV: {0}`nFO4: {1}`nCK: {2}`nAdmin: {3}" -f $paths.fnv, $paths.fo4, ($r.fo4.creation_kit -ne $null), $r.is_admin)
