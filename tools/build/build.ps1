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
# Seit D53 acht Modlets statt einem: dist\Mods\ enthaelt alle Ordner, die nach
# <Spielpfad>\Mods\ kopiert werden. Siehe docs/contracts/01-modlet-grenzen.md.
$package = Join-Path $distRoot 'Mods'
$coreModlet = '700_00_Core'

# Eine Fassung fuer alle acht ModInfo.xml (Vertrag 01, §4). Quelle ist
# Directory.Build.props; die Quelldateien tragen __VERSION__ als Platzhalter.
$propsPath = Join-Path $repoRoot 'Directory.Build.props'
$modVersion = ([xml](Get-Content $propsPath -Raw)).Project.PropertyGroup.Mod700Version |
    Where-Object { $_ } | Select-Object -First 1
if (-not $modVersion) { throw "Mod700Version steht nicht in $propsPath." }
$parsedVersion = [Version]::new(0, 0)
if (-not [Version]::TryParse($modVersion, [ref]$parsedVersion)) {
    throw "Mod700Version '$modVersion' ist keine lesbare Fassung."
}
Write-Output "Fassung: $modVersion"

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

$modlets = Get-ChildItem $modSource -Directory | Sort-Object Name
if (-not $modlets) { throw "Unter $modSource liegt kein Modlet-Ordner." }
if (-not ($modlets.Name -contains $coreModlet)) {
    throw "Das Kern-Modlet $coreModlet fehlt unter $modSource."
}

foreach ($modlet in $modlets) {
    $target = Join-Path $package $modlet.Name
    New-Item -ItemType Directory -Force -Path $target | Out-Null

    # README.md ist Repo-Doku, .gitkeep haelt leere Ordner im Git - beides nicht ins Paket.
    Get-ChildItem $modlet.FullName -Recurse -File |
        Where-Object { $_.Name -ne 'README.md' -and $_.Name -ne '.gitkeep' } |
        ForEach-Object {
            $relative = $_.FullName.Substring($modlet.FullName.Length).TrimStart('\')
            $destination = Join-Path $target $relative
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
            Copy-Item $_.FullName $destination
        }

    # Fassung einsetzen. Der Platzhalter MUSS vorhanden sein, sonst traegt ein Modlet
    # stillschweigend eine falsche Nummer.
    $infoPath = Join-Path $target 'ModInfo.xml'
    if (-not (Test-Path $infoPath)) { throw "$($modlet.Name) hat keine ModInfo.xml." }
    $info = [IO.File]::ReadAllText($infoPath, [Text.UTF8Encoding]::new($false))
    if ($info -notmatch '__VERSION__') {
        throw "$($modlet.Name)\ModInfo.xml hat keinen __VERSION__-Platzhalter."
    }
    [IO.File]::WriteAllText($infoPath, $info.Replace('__VERSION__', $modVersion),
        [Text.UTF8Encoding]::new($false))

    # Die DLL gehoert ausschliesslich ins Kern-Modlet (Vertrag 01, §5).
    if ($modlet.Name -eq $coreModlet) { Copy-Item $builtDll $target }
}

# Kontrolle: keine Spiel-DLL im Paket (CLAUDE.md, harte Regel 1).
$strays = Get-ChildItem $package -Recurse -File -Include *.dll |
    Where-Object { $_.Name -ne 'Mod700.dll' }
if ($strays) {
    throw "Fremde DLLs im Paket, das darf nicht ausgeliefert werden: $($strays.Name -join ', ')"
}

# Kontrolle: genau eine DLL, und die liegt im Kern-Modlet.
$dlls = Get-ChildItem $package -Recurse -File -Include *.dll
if ($dlls.Count -ne 1) {
    throw "Erwartet wird genau eine DLL im Paket, gefunden: $($dlls.Count)."
}
if ($dlls[0].Directory.Name -ne $coreModlet) {
    throw "Mod700.dll liegt in '$($dlls[0].Directory.Name)' statt in $coreModlet."
}

$files = Get-ChildItem $package -Recurse -File
Write-Output "Paket fertig: $($modlets.Count) Modlets, $($files.Count) Dateien"
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
        $packagedDll = Join-Path $package "$coreModlet\Mod700.dll"
        Write-Output "Signiere Mod700.dll ..."
        & powershell -NoProfile -ExecutionPolicy Bypass -File $signScript -Exe "$packagedDll"
        $status = (Get-AuthenticodeSignature $packagedDll).Status
        if ($status -eq 'NotSigned') { throw "Signieren fehlgeschlagen: Status NotSigned." }
        Write-Output "Signatur: $status"
    }
}

# --- 4. Optional installieren ----------------------------------------------
if ($Install) {
    $modsRoot = Join-Path $env:SDTD_PATH 'Mods'
    Write-Output "Installiere nach $modsRoot ..."

    # Der Ordner der alten Ein-Modlet-Fassung. Bleibt er liegen, laedt das Spiel eine
    # zweite, veraltete Mod daneben - mit anderem Name-Feld greift auch die
    # "Mod with same name"-Sperre des Laders nicht.
    $legacy = Join-Path $modsRoot '7DTD_700'
    if (Test-Path $legacy) {
        Write-Output "Entferne die alte Ein-Modlet-Installation: $legacy"
        Remove-Item $legacy -Recurse -Force
    }

    foreach ($modlet in $modlets) {
        $target = Join-Path $modsRoot $modlet.Name
        if (Test-Path $target) { Remove-Item $target -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        Copy-Item (Join-Path (Join-Path $package $modlet.Name) '*') $target -Recurse -Force
    }

    # Fremde 700er-Modlets, die wir nicht gerade geschrieben haben: Reste einer
    # frueheren Aufteilung. Nur melden, nicht loeschen.
    $orphans = Get-ChildItem $modsRoot -Directory |
        Where-Object { $_.Name -like '700_*' -and $modlets.Name -notcontains $_.Name }
    foreach ($orphan in $orphans) {
        Write-Warning "Unbekanntes 700er-Modlet in Mods\: $($orphan.Name) - von Hand pruefen."
    }

    Write-Output "Installiert: $($modlets.Count) Modlets."
    Write-Output "EAC muss aus sein, sonst laedt der Lader $coreModlet nicht."
    Write-Output "Die reinen XML-Modlets sollten auch mit aktivem EAC laden - Folgerung, noch nicht belegt."
}

Write-Output "Fertig."
