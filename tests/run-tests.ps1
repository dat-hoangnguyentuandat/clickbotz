$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$runtime = Join-Path $root 'tools\autohotkey\AutoHotkey64.exe'
$script = Join-Path $PSScriptRoot 'macro-tests.ahk'
$arguments = '/ErrorStdOut "{0}"' -f $script
$process = Start-Process -FilePath $runtime -ArgumentList $arguments -PassThru -WindowStyle Hidden `
    -RedirectStandardOutput (Join-Path $PSScriptRoot 'stdout.log') `
    -RedirectStandardError (Join-Path $PSScriptRoot 'stderr.log')
$process.WaitForExit()
Get-Content (Join-Path $PSScriptRoot 'stdout.log')
Get-Content (Join-Path $PSScriptRoot 'stderr.log')
if ($process.ExitCode -ne 0) { throw "Tests failed: $($process.ExitCode)" }
