<#
.SYNOPSIS
    Prueft, ob jedes Bild, das unsere Modlets nennen, wirklich da ist - und ob jedes Bild,
    das wir mitliefern, die Form hat, die das Spiel erwartet (Vertrag 05, Abschnitt 6,
    Pruefung "symbole").

.DESCRIPTION
    WARUM ES DIESES SKRIPT GIBT (Plan-0002 WP2.5, 2026-11-23). CustomIcon ist ein Name, und
    ein Name ohne Bild ergibt im Beutel ein leeres Feld - ohne jede Meldung im Log. Bis hier
    hat das nur ein Blick in Vanillas Bilderordner geprueft.

    DIE REGELN:
      1. Jeder Wert von CustomIcon in unseren XML-Dateien nennt ein Bild, das es gibt:
         entweder <Name>.png in Vanillas Data\ItemIcons oder <Name>.png unter
         UIAtlases\ItemIconAtlas eines unserer Modlets. Gross- und Kleinschreibung zaehlt.
      2. Jedes Bild unter UIAtlases\ItemIconAtlas ist ein PNG mit Alphakanal, 160x160.
      3. Jedes dieser Bilder heisst ico700_<wort> in Kleinbuchstaben und traegt nicht den
         Namen eines Vanilla-Bildes.
      4. Kein Bildname kommt in zwei Modlets vor.
      5. Unter UIAtlases liegt nichts ausser PNG-Dateien in ItemIconAtlas.
      6. Nichts gelesen ist nicht gruen: ohne Vanillas Bilderordner oder ohne ein einziges
         CustomIcon ist der Ausgang 2.

    Gelesen werden zwei Formen: <property name="CustomIcon" value="..."/> an jeder Stelle
    einer XML-Datei, und <set xpath="...property[@name='CustomIcon']/@value">Name</set>.

    AUSGAENGE: 0 gruen, 1 Befund, 2 nicht pruefbar.

.NOTES
    XML-Knoten werden ueber SelectNodes und Methoden gelesen, nie ueber Eigenschaften
    (Vertrag 04, viertes Review zu WP8.7). Die Datei enthaelt nur ASCII.
#>
[CmdletBinding()]
param(
    # Ordner mit unseren Modlets. Ohne Angabe 'mod' im Repository.
    [string]$ModOrdner,
    # Vanillas Bilderordner. Ohne Angabe Data\ItemIcons unter SDTD_PATH.
    [string]$VanillaBilder
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

function Stop-Unpruefbar {
    param([string]$Grund)
    Write-Output "symbole-pruefen: $Grund - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

trap {
    Write-Output "symbole-pruefen: unerwarteter Fehler ($($_.Exception.Message)) - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

if (-not $ModOrdner) { $ModOrdner = Join-Path $repoRoot 'mod' }
if (-not $VanillaBilder) {
    if (-not $env:SDTD_PATH) { Stop-Unpruefbar 'SDTD_PATH ist nicht gesetzt und -VanillaBilder nicht angegeben' }
    try { $VanillaBilder = [IO.Path]::Combine($env:SDTD_PATH, 'Data\ItemIcons') }
    catch { Stop-Unpruefbar "SDTD_PATH ist kein gueltiger Pfad ($($env:SDTD_PATH))" }
}

$modDa = $false
try { $modDa = [IO.Directory]::Exists($ModOrdner) } catch { $modDa = $false }
if (-not $modDa) { Stop-Unpruefbar "der Modlet-Ordner fehlt ($ModOrdner)" }
$vanillaDa = $false
try { $vanillaDa = [IO.Directory]::Exists($VanillaBilder) } catch { $vanillaDa = $false }
if (-not $vanillaDa) { Stop-Unpruefbar "Vanillas Bilderordner fehlt ($VanillaBilder)" }

# Vanillas Bilder: Name ohne Endung. Zwei Tabellen - genau und ohne Gross/Klein.
$vanillaGenau = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$vanillaLocker = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($datei in [IO.Directory]::GetFiles($VanillaBilder, '*.png')) {
    $name = [IO.Path]::GetFileNameWithoutExtension($datei)
    [void]$vanillaGenau.Add($name)
    $vanillaLocker[$name] = $name
}
if ($vanillaGenau.Count -eq 0) { Stop-Unpruefbar "in Vanillas Bilderordner liegt kein PNG ($VanillaBilder)" }

Add-Type -AssemblyName System.Drawing
$befunde = @()

# ---------------------------------------------------------------- unsere Bilder
$eigeneGenau = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::Ordinal)
$eigeneLocker = New-Object 'System.Collections.Generic.Dictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)
$bilder = 0
$modlets = @([IO.Directory]::GetDirectories($ModOrdner) | Sort-Object)
foreach ($modlet in $modlets) {
    $modletName = [IO.Path]::GetFileName($modlet)
    $atlasWurzel = [IO.Path]::Combine($modlet, 'UIAtlases')
    if (-not [IO.Directory]::Exists($atlasWurzel)) { continue }
    $itemAtlas = [IO.Path]::Combine($atlasWurzel, 'ItemIconAtlas')
    foreach ($datei in ([IO.Directory]::GetFiles($atlasWurzel, '*', [IO.SearchOption]::AllDirectories) | Sort-Object)) {
        $kurz = $modletName + $datei.Substring($modlet.Length)
        $ordner = [IO.Path]::GetDirectoryName($datei)
        if (-not $ordner.Equals($itemAtlas, [StringComparison]::OrdinalIgnoreCase) -or
            -not [IO.Path]::GetExtension($datei).Equals('.png', [StringComparison]::OrdinalIgnoreCase)) {
            $befunde += "${kurz}: unter UIAtlases ist nur ItemIconAtlas\<Name>.png geregelt"
            continue
        }
        $bilder++
        $name = [IO.Path]::GetFileNameWithoutExtension($datei)
        if ($name -cnotmatch '^ico700_[a-z0-9_]+$') { $befunde += "${kurz}: ein eigenes Bild heisst ico700_<wort> in Kleinbuchstaben" }
        if ($vanillaLocker.ContainsKey($name)) { $befunde += "${kurz}: traegt den Namen des Vanilla-Bildes '$($vanillaLocker[$name])'" }
        if ($eigeneLocker.ContainsKey($name)) { $befunde += "${kurz}: denselben Bildnamen traegt schon $($eigeneLocker[$name])" }
        else {
            $eigeneLocker[$name] = $kurz
            $eigeneGenau[$name] = $kurz
        }
        try {
            $bild = New-Object System.Drawing.Bitmap $datei
            try {
                $istPng = $bild.RawFormat.Equals([System.Drawing.Imaging.ImageFormat]::Png)
                $hatAlpha = [System.Drawing.Image]::IsAlphaPixelFormat($bild.PixelFormat)
                if (-not $istPng) { $befunde += "${kurz}: ist kein PNG, auch wenn es so heisst" }
                if (-not $hatAlpha) { $befunde += "${kurz}: hat keinen Alphakanal ($($bild.PixelFormat))" }
                if ($bild.Width -ne 160 -or $bild.Height -ne 160) { $befunde += "${kurz}: ist $($bild.Width)x$($bild.Height) statt 160x160" }
            }
            finally { $bild.Dispose() }
        }
        catch { $befunde += "${kurz}: laesst sich nicht als Bild lesen" }
    }
}

# ---------------------------------------------------------------- genannte Bilder
$genannt = 0
$ausVanilla = 0
$ausModlet = 0
$dateien = 0
$benutzt = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($modlet in $modlets) {
    $modletName = [IO.Path]::GetFileName($modlet)
    $config = [IO.Path]::Combine($modlet, 'Config')
    if (-not [IO.Directory]::Exists($config)) { continue }
    foreach ($datei in ([IO.Directory]::GetFiles($config, '*.xml', [IO.SearchOption]::AllDirectories) | Sort-Object)) {
        $kurz = $modletName + $datei.Substring($modlet.Length)
        $xml = New-Object System.Xml.XmlDocument
        try { $xml.Load($datei) }
        catch { Stop-Unpruefbar "$kurz laesst sich nicht als XML lesen" }
        $dateien++
        $namen = @()
        foreach ($knoten in $xml.SelectNodes("//property[@name='CustomIcon']")) {
            $namen += , $knoten.GetAttribute('value')
        }
        foreach ($knoten in $xml.SelectNodes("//set[contains(@xpath, 'CustomIcon') and contains(@xpath, '@value')]")) {
            if ($knoten.GetAttribute('xpath') -match "property\[@name=['""]CustomIcon['""]\]/@value\s*$") {
                $namen += , $knoten.get_InnerText().Trim()
            }
        }
        foreach ($name in $namen) {
            $genannt++
            if ($name -eq '') { $befunde += "${kurz}: CustomIcon ohne Wert"; continue }
            if ($eigeneGenau.ContainsKey($name)) { $ausModlet++; [void]$benutzt.Add($name); continue }
            if ($vanillaGenau.Contains($name)) { $ausVanilla++; continue }
            if ($eigeneLocker.ContainsKey($name) -or $vanillaLocker.ContainsKey($name)) {
                $richtig = if ($eigeneLocker.ContainsKey($name)) { [IO.Path]::GetFileNameWithoutExtension($eigeneLocker[$name]) } else { $vanillaLocker[$name] }
                $befunde += "${kurz}: CustomIcon '$name' - das Bild heisst '$richtig' (Gross- und Kleinschreibung)"
                continue
            }
            $befunde += "${kurz}: CustomIcon '$name' nennt ein Bild, das es weder in Vanilla noch in einem unserer Modlets gibt"
        }
    }
}
if ($genannt -eq 0) { Stop-Unpruefbar "keine der $dateien XML-Dateien unter $ModOrdner nennt ein CustomIcon" }

$unbenutzt = @($eigeneGenau.Keys | Where-Object { -not $benutzt.Contains($_) } | Sort-Object)
foreach ($name in $unbenutzt) { $befunde += "$($eigeneGenau[$name]): kein CustomIcon nennt dieses Bild" }

Write-Output "symbole-pruefen: Modlets unter $ModOrdner"
Write-Output ("  Vanilla-Bilder: {0}; eigene Bilder: {1}" -f $vanillaGenau.Count, $bilder)
Write-Output ("  XML-Dateien: {0}; CustomIcon genannt: {1} (aus Vanilla: {2}, aus einem Modlet: {3})" -f $dateien, $genannt, $ausVanilla, $ausModlet)
foreach ($b in $befunde) { Write-Output "  BEFUND: $b" }
Write-Output ''
if ($befunde.Count -gt 0) {
    Write-Output "== Ergebnis: $($befunde.Count) Befunde -> RED =="
    exit 1
}
Write-Output '== Ergebnis: 0 Befunde -> GREEN =='
exit 0
