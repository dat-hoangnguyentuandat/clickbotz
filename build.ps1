param([string]$OutputName = 'ClickBotz.exe')
$ErrorActionPreference = 'Stop'
$compiler = Join-Path $PSScriptRoot 'tools\compiler\Ahk2Exe.exe'
$runtime = Join-Path $PSScriptRoot 'tools\autohotkey\AutoHotkey64.exe'
$source = Join-Path $PSScriptRoot 'clickbotz.ahk'
$output = Join-Path $PSScriptRoot $OutputName
if (!(Test-Path -LiteralPath $compiler) -or !(Test-Path -LiteralPath $runtime)) {
    throw 'Missing local AutoHotkey runtime or Ahk2Exe; see README.md.'
}
$arguments = '/in "{0}" /out "{1}" /base "{2}" /compress 0 /silent verbose' -f $source, $output, $runtime
$process = Start-Process -FilePath $compiler -ArgumentList $arguments -PassThru -Wait -WindowStyle Hidden
if ($process.ExitCode -ne 0) { throw "Compiler exited with $($process.ExitCode)" }
Get-Item -LiteralPath $output | Select-Object FullName, Length, LastWriteTime
