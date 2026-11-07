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
    [switch]$SkipLog
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
Write-Output "== Paket =="

$modDir = Join-Path $env:SDTD_PATH 'Mods\7DTD_700'
$infoPath = Join-Path $modDir 'ModInfo.xml'
$dllPath = Join-Path $modDir 'Mod700.dll'

Test-Item 'Mod-Ordner installiert' (Test-Path $modDir) $modDir
Test-Item 'ModInfo.xml vorhanden' (Test-Path $infoPath)
Test-Item 'Mod700.dll vorhanden' (Test-Path $dllPath)

if (Test-Path $modDir) {
    $foreign = Get-ChildItem $modDir -Recurse -File -Filter *.dll |
        Where-Object { $_.Name -ne 'Mod700.dll' }
    Test-Item 'keine fremden DLLs im Mod-Ordner' (-not $foreign) ($foreign.Name -join ', ')
}

if (Test-Path $dllPath) {
    $sig = Get-AuthenticodeSignature $dllPath
    Test-Item 'Mod700.dll ist signiert' ($sig.Status -ne 'NotSigned') ("Status $($sig.Status)")
}

if (Test-Path $infoPath) {
    $xml = $null
    try { $xml = [xml](Get-Content $infoPath -Raw) } catch { }
    Test-Item 'ModInfo.xml ist wohlgeformtes XML' ($null -ne $xml)

    if ($null -ne $xml) {
        # Belegte Laderegeln (Mod::parseModInfoV2 / Mod::LoadDefinitionFromFolder):
        # Wurzel <xml>, Felder als direkte Kinder mit value="...", Name und DisplayName
        # Pflicht, Name gegen ^[0-9a-zA-Z_\-]+$, Version per Version.TryParse.
        $root = $xml.DocumentElement
        # get_Name() statt .Name: der XML-Adapter von PowerShell blendet Kindelemente als
        # Eigenschaften ein, und die Wurzel <xml> hat ein Kind <Name> - .Name liefert sonst
        # dieses Kind statt des Elementnamens.
        $rootName = $root.get_Name()
        Test-Item 'Wurzelelement ist <xml>' ($rootName -eq 'xml') ("gefunden <$rootName>")
        Test-Item 'keine <ModInfo>-Huelle (Altformat laedt nicht)' ($null -eq $root.SelectSingleNode('ModInfo'))

        function Get-Field { param([string]$n) $node = $root.SelectSingleNode($n); if ($node) { $node.GetAttribute('value') } else { $null } }

        $name = Get-Field 'Name'
        $display = Get-Field 'DisplayName'
        $version = Get-Field 'Version'
        $skip = Get-Field 'SkipWithAntiCheat'

        Test-Item 'Name gesetzt' (-not [string]::IsNullOrEmpty($name))
        Test-Item 'Name passt auf ^[0-9a-zA-Z_\-]+$' ($name -match '^[0-9a-zA-Z_\-]+$') "Name '$name'"
        Test-Item 'DisplayName gesetzt' (-not [string]::IsNullOrEmpty($display))
        $parsed = [Version]::new(0, 0)
        Test-Item 'Version ist per Version.TryParse lesbar' ([Version]::TryParse($version, [ref]$parsed)) "Version '$version'"
        $skipOk = $false
        Test-Item 'SkipWithAntiCheat ist ein Boolescher Wert' ([bool]::TryParse($skip, [ref]$skipOk)) "Wert '$skip'"

        $known = @('Name', 'DisplayName', 'Description', 'Author', 'Version', 'Website', 'SkipWithAntiCheat')
        $unknown = @($root.ChildNodes | Where-Object { $_.NodeType -eq 'Element' -and $known -notcontains $_.Name } | ForEach-Object { $_.Name })
        Test-Item 'nur Felder, die der Lader liest' ($unknown.Count -eq 0) ("ignoriert: " + ($unknown -join ', '))
    }
}

# ------------------------------------------------------------ Teil 2: Protokoll
if (-not $SkipLog) {
    Write-Output ""
    Write-Output "== Protokoll =="

    if (-not $LogPath) {
        $candidates = @(
            (Join-Path $env:LOCALAPPDATA '..\LocalLow\The Fun Pimps\7 Days To Die'),
            (Join-Path $env:SDTD_PATH '7DaysToDie_Data')
        )
        $LogPath = $candidates |
            Where-Object { Test-Path $_ } |
            ForEach-Object { Get-ChildItem $_ -Filter *.log -File -ErrorAction SilentlyContinue } |
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
        $log = Get-Content $LogPath -Raw

        $required = @(
            @{ Text = 'Initializing mod 7DTD_700'; Name = 'Lader nimmt die Mod auf' },
            @{ Text = "Initialized code in mod '7DTD_700'"; Name = 'IModApi-Instanz erzeugt' },
            @{ Text = '[700] loaded v'; Name = 'Mod meldet sich mit Fassung und Spielbuild' },
            @{ Text = '[700] Harmony'; Name = 'HarmonyX zur Laufzeit aufgeloest' },
            @{ Text = '[700] Login-Handler registriert'; Name = 'PlayerLogin-Handler haengt' }
        )
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
