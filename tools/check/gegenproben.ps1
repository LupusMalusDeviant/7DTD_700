<#
.SYNOPSIS
    Weist nach, dass mod700check an falschen Eingaben scheitert (Projektregel 5).

.DESCRIPTION
    Ein Pruefwerkzeug, das nie rot wird, ist kein Signal. Dieses Skript laesst jeden der
    drei Befehle einmal gegen einen bekannt SAUBEREN und einmal gegen einen bekannt
    FALSCHEN Satz Pruefdaten laufen und vergleicht den Exit-Code mit der Erwartung.

    Die Pruefdaten unter testdaten/ bestehen aus erfundenen Kennungen, nicht aus
    Spielinhalt (Projektregel 1 und 7).

    Erst wenn dieses Skript gruen ist, zaehlt ein "0 rot" der Werkzeuge als Nachweis.

.NOTES
    ACHTUNG, Kodierung: UTF-8 MIT BOM, sonst liest Windows PowerShell 5.1 die Datei als
    ANSI. Wiederherstellen:

        $p = Resolve-Path tools\check\gegenproben.ps1
        $t = [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($true))
#>
[CmdletBinding()]
param(
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)
$exe = Join-Path $repoRoot "tools\check\Mod700.Check\bin\$Configuration\net10.0\mod700check.exe"
$data = Join-Path $here 'testdaten'

if (-not (Test-Path $exe)) {
    throw "mod700check nicht gebaut: $exe fehlt. Erst 'dotnet build tools/check/Mod700.Check/Mod700.Check.csproj -c $Configuration'."
}

$failed = 0
$checked = 0

function Test-Case {
    param(
        [string]$Name,
        [int]$Expected,
        [string[]]$Arguments
    )

    $script:checked++
    # Kein '2>&1' auf eine native Exe: Windows PowerShell 5.1 verpackt dann jede
    # stderr-Zeile in einen ErrorRecord (NativeCommandError), und mit
    # ErrorActionPreference='Stop' bricht das Skript mitten in der Gegenprobe ab -
    # genau bei den Faellen, die stderr benutzen (Exit 2). stderr darf also durchlaufen.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $exe @Arguments
    }
    finally {
        $ErrorActionPreference = $previous
    }
    $actual = $LASTEXITCODE

    if ($actual -eq $Expected) {
        Write-Output ("  [ok]   " + $Name + "  (Exit $actual)")
    }
    else {
        $script:failed++
        Write-Output ("  [ROT]  " + $Name + "  -> Exit $actual erwartet $Expected")
        $output | Select-Object -First 6 | ForEach-Object { Write-Output ("         " + $_) }
    }
}

Write-Output "== Gegenproben: der saubere Satz muss gruen sein =="
Test-Case 'anachronisms, sauberer Satz' 0 @(
    'anachronisms', (Join-Path $data 'sauber'),
    '--denylist', (Join-Path $here 'denylist.txt'))
Test-Case 'recipes, sauberer Satz' 0 @(
    'recipes', (Join-Path $data 'sauber'),
    '--world-roots', (Join-Path $data 'world-roots.txt'))
Test-Case 'localization, sauberer Satz' 0 @(
    'localization', (Join-Path $data 'Localization-sauber.csv'), '--prefix', '700_')

Write-Output ""
Write-Output "== Gegenproben: der falsche Satz MUSS rot werden =="
Test-Case 'anachronisms findet die erreichbare Pistole' 1 @(
    'anachronisms', (Join-Path $data 'rot'),
    '--denylist', (Join-Path $here 'denylist.txt'))
Test-Case 'recipes findet Zyklus und unbekannte Zutat' 1 @(
    'recipes', (Join-Path $data 'rot'),
    '--world-roots', (Join-Path $data 'world-roots.txt'))
Test-Case 'localization findet Dubletten, Luecken, fehlendes Praefix' 1 @(
    'localization', (Join-Path $data 'Localization-rot.csv'), '--prefix', '700_')

Write-Output ""
Write-Output "== Gegenproben: eine fehlende Annahme macht den sauberen Satz rot =="
# Ohne world-roots.txt ist pruefSchmelzEinheit unerreichbar - der Beweis, dass die
# Datei wirklich etwas beitraegt und nicht nur dekorativ dabeiliegt.
Test-Case 'recipes ohne world-roots wird rot' 1 @(
    'recipes', (Join-Path $data 'sauber'), '--no-world-roots')

Write-Output ""
Write-Output "== Gegenproben: Benutzungsfehler ist Exit 2, nicht rot und nicht gruen =="
Test-Case 'unbekannter Befehl' 2 @('gibtesnicht', $data)
Test-Case 'fehlender Pfad' 2 @('recipes')
Test-Case 'Ordner ohne items.xml' 2 @('recipes', $here)
Test-Case 'unbekannte Option' 2 @(
    'recipes', (Join-Path $data 'sauber'), '--quatsch')

Write-Output ""
Write-Output ("== Ergebnis: $checked Gegenproben, $failed fehlgeschlagen ==")
if ($failed -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
