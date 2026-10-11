<#
.SYNOPSIS
  Isolation proof helper (gate G0). Lists path|bytes|mtime|sha256 for every file under the given roots.
  Run before and after a conversion; diff the two outputs. Read-only.
.EXAMPLE
  .\tools\Snapshot-Tree.ps1 -Roots "D:\Games\Fallout4\Data","D:\Games\FNV\Data","$env:USERPROFILE\Documents\My Games\Fallout4\Saves" -Out artifacts\isolation\before.txt
  # ... run converter ...
  .\tools\Snapshot-Tree.ps1 -Roots <same> -Out artifacts\isolation\after.txt
  fc artifacts\isolation\before.txt artifacts\isolation\after.txt   # must report no differences
#>
param([Parameter(Mandatory)][string[]]$Roots, [Parameter(Mandatory)][string]$Out, [switch]$NoHash)
New-Item -ItemType Directory -Force -Path (Split-Path $Out) | Out-Null
$lines = foreach ($root in $Roots) {
  Get-ChildItem -LiteralPath $root -Recurse -File -Force -ErrorAction SilentlyContinue | Sort-Object FullName | ForEach-Object {
    $h = if ($NoHash) { "-" } else { (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash }
    "{0}|{1}|{2}|{3}" -f $_.FullName, $_.Length, $_.LastWriteTimeUtc.ToString("o"), $h
  }
}
$lines | Set-Content -Encoding UTF8 -Path $Out
Write-Host ("{0} files recorded -> {1}" -f @($lines).Count, $Out)
