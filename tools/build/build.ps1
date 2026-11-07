<#
.SYNOPSIS
    Baut die C#-DLL, packt die Mod nach dist/Mods/7DTD_700 und kopiert sie optional
    in die Spielinstallation.

.DESCRIPTION
    Ein Befehl für den ganzen Weg. Die Spiel-DLLs werden nur referenziert (Private=false),
    nie mitkopiert und nie committet. Das Paket enthält genau, was der Lader braucht:
    ModInfo.xml, Mod700.dll und den Config-Ordner.

.PARAMETER Configuration
    Release (Standard) oder Debug.

.PARAMETER Install
    Kopiert das fertige Paket zusätzlich nach $env:SDTD_PATH\Mods\7DTD_700.

.PARAMETER Clean
    Löscht dist/ vor dem Bauen.

.PARAMETER NoSign
    Überspringt das Signieren. Standard ist signieren: jede Windows-Binary aus einem Build
    bekommt die Signatur "CN=Lupus Malus Deviant" (Skill sign-binary).

.EXAMPLE
    $env:SDTD_PATH = "C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die"
    .\tools\build\build.ps1 -Install

.NOTES
    ACHTUNG, Kodierung: Diese Datei MUSS mit UTF-8-BOM gespeichert bleiben. Windows
    PowerShell 5.1 liest eine Datei ohne BOM als ANSI; ein Geviertstrich wird dabei zu
    Byte 0x94, das PowerShell als schliessendes Anfuehrungszeichen deutet - das Skript
    laesst sich dann nicht mehr parsen. Nach einer Bearbeitung mit einem Werkzeug, das
    BOM-los schreibt, so wiederherstellen:

        $p = Resolve-Path tools\build\build.ps1
        $t = [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($true))
#>
[CmdletBinding()]
param(
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release',
    [switch]$Install,
    [switch]$Clean,
    [switch]$NoSign
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$project = Join-Path $repoRoot 'src\Mod700\Mod700.csproj'
$modSource = Join-Path $repoRoot 'mod'
$distRoot = Join-Path $repoRoot 'dist'
$package = Join-Path $distRoot 'Mods\7DTD_700'

if (-not $env:SDTD_PATH) {
    throw "SDTD_PATH ist nicht gesetzt. Beispiel: `$env:SDTD_PATH = 'C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die'"
}
if (-not (Test-Path (Join-Path $env:SDTD_PATH '7DaysToDie_Data\Managed\Assembly-CSharp.dll'))) {
    throw "Unter SDTD_PATH ('$env:SDTD_PATH') liegt keine Assembly-CSharp.dll. Stimmt der Pfad?"
}

if ($Clean -and (Test-Path $distRoot)) {
    Write-Output "Räume dist/ ..."
    Remove-Item $distRoot -Recurse -Force
}

# --- 1. Bauen ---------------------------------------------------------------
Write-Output "Baue Mod700 ($Configuration) ..."
& dotnet build $project -c $Configuration --nologo
if ($LASTEXITCODE -ne 0) { throw "dotnet build fehlgeschlagen (Exit $LASTEXITCODE)." }

$builtDll = Join-Path $repoRoot "src\Mod700\bin\$Configuration\Mod700.dll"
if (-not (Test-Path $builtDll)) { throw "Erwartete Ausgabe fehlt: $builtDll" }

# --- 2. Packen --------------------------------------------------------------
Write-Output "Packe nach $package ..."
if (Test-Path $package) { Remove-Item $package -Recurse -Force }
New-Item -ItemType Directory -Force -Path $package | Out-Null

Copy-Item (Join-Path $modSource 'ModInfo.xml') $package
Copy-Item $builtDll $package

$configSource = Join-Path $modSource 'Config'
$configTarget = Join-Path $package 'Config'
New-Item -ItemType Directory -Force -Path $configTarget | Out-Null
# README.md ist Repo-Doku und gehört nicht ins Paket.
Get-ChildItem $configSource -Recurse -File |
    Where-Object { $_.Name -ne 'README.md' } |
    ForEach-Object {
        $relative = $_.FullName.Substring($configSource.Length).TrimStart('\')
        $destination = Join-Path $configTarget $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item $_.FullName $destination
    }

# Kontrolle: keine Spiel-DLL im Paket (CLAUDE.md, harte Regel 1).
$strays = Get-ChildItem $package -Recurse -File -Include *.dll |
    Where-Object { $_.Name -ne 'Mod700.dll' }
if ($strays) {
    throw "Fremde DLLs im Paket, das darf nicht ausgeliefert werden: $($strays.Name -join ', ')"
}

$files = Get-ChildItem $package -Recurse -File
Write-Output "Paket fertig: $($files.Count) Dateien"
$files | ForEach-Object { Write-Output ("  " + $_.FullName.Substring($package.Length).TrimStart('\')) }

# --- 3. Signieren -----------------------------------------------------------
# Signiert wird das ausgelieferte Artefakt, also die Kopie in dist/, nicht die
# Bauausgabe. Ein Aufruf je Datei: der Skill-Skript bindet mehrere Pfade sonst
# auf den falschen Parameter.
if (-not $NoSign) {
    $signScript = Join-Path $env:USERPROFILE '.claude\skills\sign-binary\sign.ps1'
    if (-not (Test-Path $signScript)) {
        Write-Warning "Signier-Skript nicht gefunden ($signScript) — Paket bleibt unsigniert."
    }
    else {
        $packagedDll = Join-Path $package 'Mod700.dll'
        Write-Output "Signiere Mod700.dll ..."
        & powershell -NoProfile -ExecutionPolicy Bypass -File $signScript -Exe "$packagedDll"
        $status = (Get-AuthenticodeSignature $packagedDll).Status
        if ($status -eq 'NotSigned') { throw "Signieren fehlgeschlagen: Status NotSigned." }
        Write-Output "Signatur: $status"
    }
}

# --- 4. Optional installieren ----------------------------------------------
if ($Install) {
    $target = Join-Path $env:SDTD_PATH 'Mods\7DTD_700'
    Write-Output "Installiere nach $target ..."
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Copy-Item (Join-Path $package '*') $target -Recurse -Force
    Write-Output "Installiert. EAC muss aus sein, sonst lädt der Lader die DLL nicht."
}

Write-Output "Fertig."
