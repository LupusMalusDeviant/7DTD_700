<#
.SYNOPSIS
    Prueft die installierte Mod und das Spielprotokoll. Exit 0 nur, wenn alles gruen ist.

.DESCRIPTION
    Teil 1 (Paket) laeuft immer und braucht keinen Spielstart: Dateien, ModInfo.xml gegen
    die belegten Laderegeln, Signatur.
    Teil 2 (Protokoll) laeuft, sobald ein Player.log existiert: sucht die Zeilen, die beim
    Laden der Mod erscheinen muessen, und die Zeilen, die einen Fehlschlag verraten.

    Die Pflichtzeilen und die Fehlerzeilen sind woertliche Zeichenketten aus
    Mod::InitModCode bzw. Mod::LoadAssemblies, siehe
    docs/rea/findings/F-00-modloader-events-version.md.

.PARAMETER LogPath
    Protokolldatei. Ohne Angabe wird die neueste gefundene genommen.

.PARAMETER SkipLog
    Nur die Paketpruefung laufen lassen.

.EXAMPLE
    $env:SDTD_PATH = "C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die"
    .\tools\build\smoke.ps1

.NOTES
    ACHTUNG, Kodierung: wie build.ps1 muss diese Datei UTF-8 MIT BOM bleiben, sonst liest
    Windows PowerShell 5.1 sie als ANSI. Wiederherstellen:

        $p = Resolve-Path tools\build\smoke.ps1
        $t = [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($true))
#>
[CmdletBinding()]
param(
    [string]$LogPath,
    [switch]$SkipLog,
    # Die Test-Ueberlagerung 700_99_Test ist fuer diesen Lauf erwartet (installiert mit
    # 'build.ps1 -Install -MitTest'). Ohne den Schalter ist sie ein eigener roter Punkt.
    [switch]$MitTest
)

$ErrorActionPreference = 'Stop'

$failed = 0
$checked = 0

function Test-Item {
    param([string]$Name, [bool]$Ok, [string]$Detail = '')
    $script:checked++
    if ($Ok) {
        Write-Output ("  [ok]   " + $Name)
    }
    else {
        $script:failed++
        Write-Output ("  [ROT]  " + $Name + $(if ($Detail) { "  -> $Detail" } else { '' }))
    }
}

if (-not $env:SDTD_PATH) {
    throw "SDTD_PATH ist nicht gesetzt."
}

# ---------------------------------------------------------------- Teil 1: Paket
# Seit D53 acht Modlets statt einem, seit D149 neun (700_65_Wesen), seit D158 zehn
# (700_70_Handel), seit D177 elf (700_75_Magie; alle Vertrag 01, Nachtrag Phase 2 Teil 2). Geprueft wird jedes einzeln, dazu die Dinge, die
# nur im Zusammenspiel gelten: eine einzige DLL, und die liegt im Kern-Modlet; alle
# Modlets tragen dieselbe Fassung. Siehe docs/contracts/01-modlet-grenzen.md.
Write-Output "== Paket =="

$coreModlet = '700_00_Core'
$modsRoot = Join-Path $env:SDTD_PATH 'Mods'
$expected = @($coreModlet, '700_10_Purge', '700_20_Material', '700_30_Ausruestung',
              '700_40_Bauen', '700_50_Fortschritt', '700_60_Welt', '700_65_Wesen',
              '700_70_Handel', '700_75_Magie', '700_90_Sprache')

Test-Item 'Mods-Ordner vorhanden' (Test-Path $modsRoot) $modsRoot

$installed = @()
if (Test-Path $modsRoot) {
    $installed = @(Get-ChildItem $modsRoot -Directory | Where-Object { $_.Name -like '700_*' } |
        ForEach-Object { $_.Name })
}

foreach ($name in $expected) {
    Test-Item "$name installiert" ($installed -contains $name)
}

# Die Test-Ueberlagerung (Vertrag 01, Nachtrag "Test-Ueberlagerung") hat ihre eigene Zeile:
# wer sie liegen laesst, soll lesen, WAS da liegt, und nicht "unbekanntes Modlet".
$testInstalliert = @($installed | Where-Object { $_ -like '700_99_*' })
if ($MitTest) {
    Test-Item 'Test-Ueberlagerung installiert (-MitTest)' ($testInstalliert.Count -gt 0) 'kein 700_99_* in Mods'
}
else {
    Test-Item 'keine Test-Ueberlagerung installiert (kurze Uhren)' ($testInstalliert.Count -eq 0) ("gefunden: " + ($testInstalliert -join ', ') + " - mit 'build.ps1 -Install' entfernen oder smoke.ps1 -MitTest")
}

$extra = @($installed | Where-Object { $expected -notcontains $_ -and $_ -notlike '700_99_*' })
Test-Item 'keine unbekannten 700er-Modlets' ($extra.Count -eq 0) ("gefunden: " + ($extra -join ', '))

# Die alte Ein-Modlet-Installation darf nicht daneben liegenbleiben.
Test-Item 'alte Installation Mods\7DTD_700 ist weg' (-not (Test-Path (Join-Path $modsRoot '7DTD_700')))

# --- genau eine DLL, und die im Kern-Modlet
$allDlls = @()
if (Test-Path $modsRoot) {
    $allDlls = @(Get-ChildItem $modsRoot -Recurse -File -Filter *.dll |
        Where-Object { $_.FullName -like "*\700_*" })
}
Test-Item 'genau eine DLL in den 700er-Modlets' ($allDlls.Count -eq 1) ("gefunden: " + $allDlls.Count)
if ($allDlls.Count -ge 1) {
    Test-Item 'die DLL heisst Mod700.dll' ($allDlls[0].Name -eq 'Mod700.dll') $allDlls[0].Name
    Test-Item "die DLL liegt in $coreModlet" ($allDlls[0].Directory.Name -eq $coreModlet) $allDlls[0].Directory.Name
    $sig = Get-AuthenticodeSignature $allDlls[0].FullName
    Test-Item 'Mod700.dll ist signiert' ($sig.Status -ne 'NotSigned') ("Status $($sig.Status)")
}

# --- jede ModInfo.xml gegen die belegten Laderegeln
$known = @('Name', 'DisplayName', 'Description', 'Author', 'Version', 'Website', 'SkipWithAntiCheat')
$versions = @{}

foreach ($name in ($installed | Where-Object { $expected -contains $_ })) {
    $infoPath = Join-Path (Join-Path $modsRoot $name) 'ModInfo.xml'
    if (-not (Test-Path $infoPath)) {
        Test-Item "$name : ModInfo.xml vorhanden" $false
        continue
    }

    $xml = $null
    try { $xml = [xml](Get-Content $infoPath -Raw) } catch { }
    Test-Item "$name : ModInfo.xml ist wohlgeformtes XML" ($null -ne $xml)
    if ($null -eq $xml) { continue }

    # Belegte Laderegeln (Mod::parseModInfoV2 / Mod::LoadDefinitionFromFolder):
    # Wurzel <xml>, Felder als direkte Kinder mit value="...", Name und DisplayName
    # Pflicht, Name gegen ^[0-9a-zA-Z_\-]+$, Version per Version.TryParse.
    $root = $xml.DocumentElement
    # get_Name() statt .Name: der XML-Adapter von PowerShell blendet Kindelemente als
    # Eigenschaften ein, und die Wurzel <xml> hat ein Kind <Name> - .Name liefert sonst
    # dieses Kind statt des Elementnamens.
    $rootName = $root.get_Name()
    Test-Item "$name : Wurzelelement ist <xml>" ($rootName -eq 'xml') ("gefunden <$rootName>")
    Test-Item "$name : keine <ModInfo>-Huelle (Altformat laedt nicht)" ($null -eq $root.SelectSingleNode('ModInfo'))

    $field = {
        param([string]$n)
        $node = $root.SelectSingleNode($n)
        if ($node) { $node.GetAttribute('value') } else { $null }
    }

    $modName = & $field 'Name'
    $display = & $field 'DisplayName'
    $version = & $field 'Version'
    $skip = & $field 'SkipWithAntiCheat'

    Test-Item "$name : Name passt auf ^[0-9a-zA-Z_\-]+$" ($modName -match '^[0-9a-zA-Z_\-]+$') "Name '$modName'"
    # Vertrag 02: Name == Ordnername. Sonst ist nicht nachvollziehbar, welche
    # Protokollzeile zu welchem Ordner gehoert.
    Test-Item "$name : Name gleich Ordnername" ($modName -eq $name) "Name '$modName'"
    Test-Item "$name : DisplayName gesetzt" (-not [string]::IsNullOrEmpty($display))

    $parsed = [Version]::new(0, 0)
    $versionOk = [Version]::TryParse($version, [ref]$parsed)
    Test-Item "$name : Version ist per Version.TryParse lesbar" $versionOk "Version '$version'"
    # Haeufigster Fehler beim Packen: der Platzhalter blieb stehen.
    Test-Item "$name : kein __VERSION__-Platzhalter mehr" ($version -ne '__VERSION__')
    if ($versionOk) { $versions[$name] = $version }

    $skipOk = $false
    Test-Item "$name : SkipWithAntiCheat ist ein Boolescher Wert" ([bool]::TryParse($skip, [ref]$skipOk)) "Wert '$skip'"
    # Nur das Kern-Modlet bringt Code mit; die XML-Modlets sollen mit aktivem EAC laden.
    $skipExpected = ($name -eq $coreModlet)
    Test-Item "$name : SkipWithAntiCheat ist $skipExpected" ($skipOk -eq $skipExpected) "Wert '$skip'"

    $unknown = @($root.ChildNodes | Where-Object { $_.NodeType -eq 'Element' -and $known -notcontains $_.Name } | ForEach-Object { $_.Name })
    Test-Item "$name : nur Felder, die der Lader liest" ($unknown.Count -eq 0) ("ignoriert: " + ($unknown -join ', '))
}

# --- eine Fassung fuer alle
$distinct = @($versions.Values | Sort-Object -Unique)
Test-Item 'alle Modlets tragen dieselbe Fassung' ($distinct.Count -le 1) ("gefunden: " + ($distinct -join ', '))

# ------------------------------------------------------------ Teil 2: Protokoll
if (-not $SkipLog) {
    Write-Output ""
    Write-Output "== Protokoll =="

    if (-not $LogPath) {
        # Der echte Ort, nachgesehen am 2026-11-07: %APPDATA%\7DaysToDie\logs\ mit Dateien
        # output_log_client__<datum>.txt. Die beiden fruehen Kandidaten (LocalLow und der
        # Spielordner) waren geraten und falsch - darum fand der erste Lauf kein Protokoll und
        # hat daraus geschlossen, das Spiel sei nie gestartet worden. Beide bleiben als
        # Rueckfalloption stehen, falls eine andere Installation sie doch benutzt.
        $candidates = @(
            (Join-Path $env:APPDATA '7DaysToDie\logs'),
            (Join-Path $env:LOCALAPPDATA '..\LocalLow\The Fun Pimps\7 Days To Die'),
            (Join-Path $env:SDTD_PATH '7DaysToDie_Data')
        )
        $LogPath = $candidates |
            Where-Object { Test-Path $_ } |
            ForEach-Object {
                Get-ChildItem $_ -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Extension -in '.log', '.txt' -and $_.Name -notlike 'launcher*' }
            } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1 -ExpandProperty FullName
    }

    if (-not $LogPath -or -not (Test-Path $LogPath)) {
        Write-Output "  Kein Protokoll gefunden. Das Spiel wurde noch nicht gestartet."
        Write-Output "  Vorgehen: EAC abschalten (Launcher), Spiel starten, Welt laden, beenden,"
        Write-Output "  dann dieses Skript erneut laufen lassen."
        $script:failed++
        $script:checked++
    }
    else {
        Write-Output ("  Datei: " + $LogPath)
        Write-Output ("  Stand: " + (Get-Item $LogPath).LastWriteTime)
        $log = Get-Content $LogPath -Raw -Encoding UTF8

        # Woertliche Zeichenketten aus Mod::InitModCode, Mod::LoadMod und
        # ModManager::loadModsFromFolder, als Anker. Die Modlet-Namen seit D53.
        $required = @(
            @{ Text = "Trying to load from folder: '$coreModlet'"; Name = 'Lader sieht das Kern-Modlet' },
            @{ Text = "Initializing mod $coreModlet"; Name = 'Lader nimmt das Kern-Modlet auf' },
            @{ Text = "Initialized code in mod '$coreModlet'"; Name = 'IModApi-Instanz erzeugt' },
            @{ Text = '[700] loaded v'; Name = 'Mod meldet sich mit Fassung und Spielbuild' },
            @{ Text = '[700] Harmony'; Name = 'HarmonyX zur Laufzeit aufgeloest' },
            @{ Text = '[700] Login-Handler registriert'; Name = 'PlayerLogin-Handler haengt' }
        )

        # Jedes XML-Modlet muss im Protokoll auftauchen, sonst hat der Lader es nicht
        # gesehen - der haeufigste Grund ist ein Tippfehler im Ordnernamen.
        foreach ($name in ($expected | Where-Object { $_ -ne $coreModlet })) {
            $required += @{ Text = "Trying to load from folder: '$name'"; Name = "Lader sieht $name" }
        }
        foreach ($r in $required) {
            Test-Item $r.Name ($log.Contains($r.Text)) ("fehlt: " + $r.Text)
        }

        # Mindestens eine Aussage des Build-Guards muss da sein.
        $guard = @('entspricht der geprueften Fassung', 'entspricht der geprüften Fassung',
                   'dieselbe Minor-Fassung', 'ist NEUER als geprueft', 'ist NEUER als geprüft',
                   'ist AELTER', 'ist ÄLTER', 'Andere Major-Fassung')
        Test-Item 'Build-Guard hat sich geaeussert' ([bool]($guard | Where-Object { $log.Contains($_) }))

        $fatal = @(
            @{ Text = 'No ModAPI found in mod DLLs'; Name = 'Einstiegsklasse nicht gefunden' },
            @{ Text = 'AntiCheat needs to be disabled'; Name = 'EAC ist noch an' },
            @{ Text = 'mod skipped because it is set not to load'; Name = 'wegen EAC uebersprungen' },
            @{ Text = 'Failed initializing ModAPI instance'; Name = 'InitMod geworfen' },
            @{ Text = '[700] InitMod fehlgeschlagen'; Name = 'eigene Ausnahme in InitMod' }
        )
        foreach ($f in $fatal) {
            Test-Item ("kein Fehlschlag: " + $f.Name) (-not $log.Contains($f.Text))
        }
    }
}

Write-Output ""
Write-Output ("== Ergebnis: $checked geprueft, $failed rot ==")
if ($failed -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
