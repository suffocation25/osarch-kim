param(
  [Parameter(Mandatory=$true)][string]$From,
  [ValidateSet('LF','CRLF')][string]$Eol = 'LF',
  [switch]$Bom
)
# Lab 5: convert evidence\staff-broken.csv from $From to UTF-8
# Usage: powershell -ExecutionPolicy Bypass -File scripts\fix.ps1 -From RK1048 -Eol LF -Bom
$ErrorActionPreference = 'Stop'
$iconv = 'C:\Program Files\Git\usr\bin\iconv.exe'
$in  = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\evidence\staff-broken.csv'))
$out = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\evidence\staff-fixed.csv'))
$psi = New-Object Diagnostics.ProcessStartInfo $iconv
$psi.Arguments = "-f $From -t UTF-8 `"$in`""
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$p = [Diagnostics.Process]::Start($psi)
$ms = New-Object IO.MemoryStream
$p.StandardOutput.BaseStream.CopyTo($ms)
$err = $p.StandardError.ReadToEnd()
$p.WaitForExit()
if ($p.ExitCode -ne 0) { throw "iconv failed (wrong source encoding?): $err" }
$bytes = $ms.ToArray()
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $bytes = [byte[]]($bytes[3..($bytes.Length - 1)]) }
$text = [Text.Encoding]::UTF8.GetString($bytes)
$text = $text -replace "`r`n", "`n"
if ($Eol -eq 'CRLF') { $text = $text -replace "`n", "`r`n" }
[IO.File]::WriteAllText($out, $text, (New-Object Text.UTF8Encoding($Bom.IsPresent)))
"written: $out"