<#
.SYNOPSIS
    Prueft die Test-Ueberlagerung: jede ihrer Zeilen trifft einen Knoten der Mod, sie setzt
    nur Zahlen, und sie liegt nicht dort, wo das Paket gebaut wird.

.DESCRIPTION
    WARUM ES DIESES SKRIPT GIBT (Plan-0002 WP1.2/WP1.3, 2026-11-23). Die Test-Ueberlagerung
    (test\700_99_Test) verkuerzt Uhren fuer einen Spieltest. Ihre XPaths zeigen auf Knoten,
    die erst unsere Modlets anlegen; kette-pruefen.ps1 prueft gegen Vanilla und kann sie
    nicht sehen. Ein XPath, der nichts trifft, steht im Spiel nur im Protokoll - der Test
    liefe dann mit den langen Uhren, und niemand merkte es vor Ablauf einer halben Stunde.

    DIE REGELN (Vertrag 01, Nachtrag "Test-Ueberlagerung"):
      1. Die Ueberlagerung liegt unter test\, heisst 700_99_<Wort> und traegt eine
         ModInfo.xml. Unter mod\ liegt kein Ordner 700_99_*.
      2. Sie enthaelt nur ModInfo.xml und XML-Dateien unter Config\.
      3. Sie benutzt nur <set>.
      4. Jedes <set> trifft mindestens einen Knoten am Stand NACH unseren Modlets (Vanillas
         Datei, darauf der Reihe nach die gleichnamige Datei jedes Modlets).
      5. Jedes <set> aendert den Wert. Ein <set> auf denselben Wert ist ein Befund: dann
         ist die Zeile ueberholt.
      6. Nichts gelesen ist nicht gruen (Ausgang 2).
      Seit Nachtrag Teil 1d (Plan-0002 WP9.10, 2026-11-23) zusaetzlich, Regel 3 gelockert:
      7. <append> ist erlaubt, wenn jedes angehaengte Element einen Namen t700_* traegt (Probe)
         und das Ziel am Stand nach unseren Modlets trifft.
      8. Eine Probe gibt es dort noch nicht (kein Ueberschreiben unter gleichem Namen).
      9. Keine Datei unter mod\ nennt t700_ - die Mod haengt nie an einer Probe.

    AUSGAENGE: 0 gruen, 1 Befund, 2 nicht pruefbar.

.NOTES
    Rechnet mit patch-operationen.ps1 wie sprachverweise-pruefen.ps1. Bedingte Bloecke in
    den Modlet-Dateien werden nicht gerechnet und gezaehlt; trifft eine Zeile der
    Ueberlagerung nur deshalb nichts, steht die Zahl daneben. Nur ASCII.
#>
[CmdletBinding()]
param(
    [string]$ModOrdner,
    [string]$TestOrdner,
    [string]$Vanilla
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

function Stop-Unpruefbar {
    param([string]$Grund)
    Write-Output "testueberlagerung-pruefen: $Grund - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

trap {
    Write-Output "testueberlagerung-pruefen: unerwarteter Fehler ($($_.Exception.Message)) - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

$bibliothek = Join-Path $here 'patch-operationen.ps1'
if (-not [IO.File]::Exists($bibliothek)) { Stop-Unpruefbar 'patch-operationen.ps1 fehlt neben dem Skript' }
. $bibliothek

if (-not $ModOrdner) { $ModOrdner = Join-Path $repoRoot 'mod' }
if (-not $TestOrdner) { $TestOrdner = Join-Path $repoRoot 'test' }
if (-not $Vanilla) {
    if (-not $env:SDTD_PATH) { Stop-Unpruefbar 'SDTD_PATH ist nicht gesetzt und -Vanilla nicht angegeben' }
    try { $Vanilla = [IO.Path]::Combine($env:SDTD_PATH, 'Data\Config') }
    catch { Stop-Unpruefbar "SDTD_PATH ist kein gueltiger Pfad ($($env:SDTD_PATH))" }
}
foreach ($paar in @(@('der Modlet-Ordner', $ModOrdner), @('der Test-Ordner', $TestOrdner), @('Vanillas Config-Ordner', $Vanilla))) {
    $da = $false
    try { $da = [IO.Directory]::Exists($paar[1]) } catch { $da = $false }
    if (-not $da) { Stop-Unpruefbar "$($paar[0]) fehlt ($($paar[1]))" }
}

function Read-Xml {
    param([string]$Pfad, [string]$Rolle)
    $doc = New-Object System.Xml.XmlDocument
    try { $doc.LoadXml([IO.File]::ReadAllText($Pfad)) }
    catch { Stop-Unpruefbar "$Rolle '$Pfad' laesst sich nicht als XML lesen" }
    return $doc
}

$operationen = @('set', 'setattribute', 'append', 'prepend', 'insertAfter', 'insertBefore', 'remove', 'removeattribute', 'csv')
$behaelter = @('conditional', 'if', 'else')
$befunde = New-Object System.Collections.Generic.List[string]

# ---------------------------------------------------------------- Regel 1: Ort und Name
foreach ($ordner in [IO.Directory]::GetDirectories($ModOrdner)) {
    $name = [IO.Path]::GetFileName($ordner)
    if ($name -like '700_99*') { $befunde.Add("unter dem Modlet-Ordner liegt '$name' - eine Test-Ueberlagerung gehoert nach test\, sonst landet sie im Paket") }
}
$modlets = @([IO.Directory]::GetDirectories($ModOrdner) | Sort-Object)
$ueberlagerungen = @([IO.Directory]::GetDirectories($TestOrdner) | Sort-Object)
if ($ueberlagerungen.Count -eq 0) { Stop-Unpruefbar "unter $TestOrdner liegt keine Ueberlagerung" }

$dateien = 0
$zeilen = 0
$proben = 0
$geaendert = 0

# Regel 9 (Nachtrag Teil 1d): keine Datei der Mod nennt eine Probe.
foreach ($modDatei in ([IO.Directory]::GetFiles($ModOrdner, '*', [IO.SearchOption]::AllDirectories) | Sort-Object)) {
    $endung = [IO.Path]::GetExtension($modDatei).ToLowerInvariant()
    if ($endung -ne '.xml' -and $endung -ne '.csv' -and $endung -ne '.txt') { continue }
    # Mit Wortgrenze: 'ent700_' (Wesen, Vertrag 02) enthaelt 't700_' und ist keine Probe -
    # gefunden beim ersten echten Lauf am 2026-11-23 (4 falsche Befunde in 700_65 und 700_90).
    if ([regex]::IsMatch([IO.File]::ReadAllText($modDatei), '(?<![A-Za-z0-9_])t700_')) {
        $befunde.Add("$($modDatei.Substring($ModOrdner.Length + 1)): nennt eine Probe (t700_) - die Mod haengt nie an einer Probe der Test-Ueberlagerung")
    }
}
$uebergangen = 0
$ausgabe = New-Object System.Collections.Generic.List[string]

foreach ($ueber in $ueberlagerungen) {
    $ueberName = [IO.Path]::GetFileName($ueber)
    if ($ueberName -cnotmatch '^700_99_[A-Za-z0-9]+$') { $befunde.Add("${ueberName}: eine Ueberlagerung heisst 700_99_<Wort>") }
    if (-not [IO.File]::Exists([IO.Path]::Combine($ueber, 'ModInfo.xml'))) { $befunde.Add("${ueberName}: ModInfo.xml fehlt") }

    # Regel 2: nur ModInfo.xml und Config\*.xml
    $config = [IO.Path]::Combine($ueber, 'Config')
    foreach ($datei in ([IO.Directory]::GetFiles($ueber, '*', [IO.SearchOption]::AllDirectories) | Sort-Object)) {
        $relativ = $datei.Substring($ueber.Length + 1)
        if ($relativ -eq 'ModInfo.xml') { continue }
        $inConfig = $datei.StartsWith($config + '\', [StringComparison]::OrdinalIgnoreCase)
        if (-not $inConfig -or -not [IO.Path]::GetExtension($datei).Equals('.xml', [StringComparison]::OrdinalIgnoreCase)) {
            $befunde.Add("${ueberName}\${relativ}: eine Ueberlagerung traegt nur ModInfo.xml und XML unter Config")
        }
    }
    if (-not [IO.Directory]::Exists($config)) { continue }

    foreach ($datei in ([IO.Directory]::GetFiles($config, '*.xml', [IO.SearchOption]::AllDirectories) | Sort-Object)) {
        $relativ = $datei.Substring($config.Length + 1)
        $kurz = "$ueberName\Config\$relativ"
        $vanillaDatei = [IO.Path]::Combine($Vanilla, $relativ)
        if (-not [IO.File]::Exists($vanillaDatei)) {
            $befunde.Add("${kurz}: Vanilla hat keine Datei dieses Namens")
            continue
        }
        $dateien++
        $stand = Read-Xml $vanillaDatei 'Vanillas Datei'

        # Der Stand nach unseren Modlets: jede gleichnamige Datei, in Ladereihenfolge.
        foreach ($modlet in $modlets) {
            $modDatei = [IO.Path]::Combine($modlet, 'Config', $relativ)
            if (-not [IO.File]::Exists($modDatei)) { continue }
            $patch = Read-Xml $modDatei 'die Patch-Datei'
            foreach ($operation in $patch.get_DocumentElement().get_ChildNodes()) {
                if ($operation.get_NodeType() -ne $element) { continue }
                $name = $operation.get_LocalName()
                if (Test-In $name $behaelter) { $uebergangen++; continue }
                if (-not (Test-In $name $operationen)) { $uebergangen++; continue }
                $treffer = New-Object System.Collections.Generic.List[object]
                try { foreach ($knoten in $stand.SelectNodes($operation.GetAttribute('xpath'))) { $treffer.Add($knoten) } }
                catch { $uebergangen++; continue }
                if ($treffer.Count -eq 0) { continue }
                if ($null -ne (Get-Hindernis $name $treffer)) { $uebergangen++; continue }
                foreach ($knoten in $treffer) { Invoke-Operation $name $operation $knoten $stand }
            }
        }

        # Die Ueberlagerung selbst.
        $ueberDoc = Read-Xml $datei 'die Datei der Ueberlagerung'
        foreach ($operation in $ueberDoc.get_DocumentElement().get_ChildNodes()) {
            if ($operation.get_NodeType() -ne $element) { continue }
            $name = $operation.get_LocalName()
            $xpath = $operation.GetAttribute('xpath')
            $zeilen++
            # Regel 7-9 (Nachtrag Teil 1d, WP9.10): <append> nur fuer Proben t700_*.
            if (Test-Gleich $name 'append') {
                $kinder = @($operation.get_ChildNodes() | Where-Object { $_.get_NodeType() -eq $element })
                $vorher = $befunde.Count
                if ($kinder.Count -eq 0) { $befunde.Add("${kurz}: <append> haengt nichts an  (xpath=""$xpath"")") }
                foreach ($kind in $kinder) {
                    $probe = $kind.GetAttribute('name')
                    if (-not $probe) { $probe = '(ohne name)' }
                    if ($probe -cnotlike 't700_*') {
                        $befunde.Add("${kurz}: <append> legt '$probe' an - eine Ueberlagerung legt nur Proben an, deren Name mit t700_ beginnt  (xpath=""$xpath"")")
                    }
                }
                $treffer = New-Object System.Collections.Generic.List[object]
                try { foreach ($knoten in $stand.SelectNodes($xpath)) { $treffer.Add($knoten) } }
                catch { $befunde.Add("${kurz}: XPath laesst sich nicht auswerten: $xpath"); continue }
                if ($treffer.Count -eq 0) {
                    $befunde.Add("${kurz}: <append> trifft nichts am Stand nach unseren Modlets: $xpath")
                    continue
                }
                foreach ($knoten in $treffer) {
                    foreach ($kind in $kinder) {
                        $probe = $kind.GetAttribute('name')
                        if (-not $probe) { continue }
                        foreach ($geschwister in $knoten.get_ChildNodes()) {
                            if ($geschwister.get_NodeType() -eq $element -and $geschwister.GetAttribute('name') -ceq $probe) {
                                $befunde.Add("${kurz}: Probe '$probe' gibt es am Stand nach unseren Modlets schon - kein Ueberschreiben unter gleichem Namen")
                                break
                            }
                        }
                    }
                }
                if ($befunde.Count -eq $vorher) {
                    $proben += $kinder.Count
                    foreach ($kind in $kinder) { $ausgabe.Add("    + Probe $($kind.get_LocalName()) '$($kind.GetAttribute('name'))'   $xpath") }
                    foreach ($knoten in $treffer) { Invoke-Operation $name $operation $knoten $stand }
                }
                continue
            }
            if (-not (Test-Gleich $name 'set')) {
                $befunde.Add("${kurz}: <$name> - eine Ueberlagerung benutzt nur <set> und <append> von Proben (t700_)  (xpath=""$xpath"")")
                continue
            }
            $treffer = New-Object System.Collections.Generic.List[object]
            try { foreach ($knoten in $stand.SelectNodes($xpath)) { $treffer.Add($knoten) } }
            catch { $befunde.Add("${kurz}: XPath laesst sich nicht auswerten: $xpath"); continue }
            if ($treffer.Count -eq 0) {
                $befunde.Add("${kurz}: <set> trifft nichts am Stand nach unseren Modlets: $xpath")
                continue
            }
            $hindernis = Get-Hindernis $name $treffer
            if ($null -ne $hindernis) { $befunde.Add("${kurz}: <set> trifft ${hindernis}: $xpath"); continue }
            $neu = $operation.get_InnerText().Trim()
            foreach ($knoten in $treffer) {
                $alt = if ($knoten.get_NodeType() -eq $attributArt) { $knoten.get_Value() } else { $knoten.get_InnerText() }
                if (Test-Gleich $alt $neu) {
                    $befunde.Add("${kurz}: <set> aendert nichts, der Wert ist schon '$neu': $xpath")
                }
                else {
                    $geaendert++
                    $ausgabe.Add("    $alt -> $neu   $xpath")
                }
                Invoke-Operation $name $operation $knoten $stand
            }
        }
    }
}
if ($zeilen -eq 0 -and $befunde.Count -eq 0) { Stop-Unpruefbar "keine Ueberlagerung unter $TestOrdner traegt eine Patch-Zeile" }

Write-Output "testueberlagerung-pruefen: $TestOrdner"
Write-Output ("  Ueberlagerungen: {0}; Dateien: {1}; Zeilen: {2}; geaenderte Werte: {3}; Proben: {4}" -f $ueberlagerungen.Count, $dateien, $zeilen, $geaendert, $proben)
Write-Output ("  Operationen der Modlets, die nicht gerechnet wurden (bedingte Bloecke u. a.): {0}" -f $uebergangen)
foreach ($a in $ausgabe) { Write-Output $a }
foreach ($b in $befunde) { Write-Output "  BEFUND: $b" }
Write-Output ''
if ($befunde.Count -gt 0) {
    Write-Output "== Ergebnis: $($befunde.Count) Befunde -> RED =="
    exit 1
}
Write-Output '== Ergebnis: 0 Befunde -> GREEN =='
exit 0
