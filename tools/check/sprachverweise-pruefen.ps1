<#
.SYNOPSIS
    Haelt die Sprachschluessel, die unsere XML-Dateien nennen, gegen die Sprachdateien -
    und unsere Zeilen gegen das, was das Spiel wirklich liest.

.DESCRIPTION
    WARUM ES DIESES SKRIPT GIBT (WP8.8, 2026-11-22). 'mod700check localization' prueft die
    FORM unserer Sprachdatei: Spalten, Pflichtsprachen, doppelte Schluessel. Es prueft
    nicht, ob ein Schluessel, den eine XML-Datei nennt, eine Zeile hat - und nicht, ob eine
    Zeile von irgendetwas gelesen wird. Gemessen: sechs Beschreibungen (die Bruchstuecke
    aus dem Zerlegen) standen in der Datei, und das Spiel las sie nie, weil die
    Gegenstaende ihren Beschreibungsschluessel ueber Extends erben
    (docs/rea/findings/WP8-beschreibungsschluessel-wird-vererbt.md).

    DIE REGELN stehen in Vertrag 04, "Nachtrag WP8.8" und den Nachtraegen "Review",
    "zweites Review" und "drittes Review zu WP8.8":
      1. Jeder genannte Schluessel hat eine Zeile (unsere Datei oder Vanilla).
      2. Jede Zeile, die Vanilla nicht hat, wird gelesen.
      3. Jede Zeile <Name>Desc eines Gegenstands oder Blocks wird gelesen - auch, wenn es
         den Gegenstand nur in Vanilla gibt und ein Patch ihn entfernt oder umbenennt.
      4. Der wirksame Beschreibungsschluessel wird am GEPATCHTEN Stand gerechnet: eigene
         Eigenschaft DescriptionKey, sonst geerbt ueber Extends (ausser param1 schliesst
         sie aus), sonst <Name>Desc. Bei einem Block, dessen Schluessel keine Zeile hat,
         danach die Gruppenbeschreibung (defaultDescriptionKey am Wurzelknoten).
      5. Was sich nicht anwenden laesst, ist rot.
      6. Nichts gelesen ist nicht gruen (Ausgang 2).

    PATCHES WERDEN ANGEWANDT, NICHT ERKANNT (Review vom 2026-11-22). Die erste Fassung
    erkannte zwei Patch-Formen an ihrem Text. Ein <prepend>, ein <remove> ohne das Wort
    DescriptionKey im XPath, ein <set>, der nichts trifft, ein zweiter <set>, der den
    ersten ueberschreibt - jedes davon rechnete sie falsch und meldete gruen. Jetzt wendet
    das Skript jede Patch-Datei namens items.xml oder blocks.xml auf Vanillas Datei an und
    liest das Ergebnis.

    AUSGAENGE: 0 gruen, 1 Befund, 2 nicht pruefbar.

.NOTES
    Der Aufbau eines XML-Knotens wird ueber METHODEN gelesen (get_NodeType(),
    get_LocalName(), get_ChildNodes(), get_InnerText(), GetAttribute()), nie ueber
    Eigenschaften: in Windows PowerShell 5.1 legt der XML-Adapter Attribute und
    Kindelemente als Eigenschaften ueber den Knoten (Vertrag 04, viertes Review zu WP8.7).
    Die Datei enthaelt nur ASCII und braucht darum keine BOM.
#>
[CmdletBinding()]
param(
    # Unsere XML-Patch-Dateien, in Ladereihenfolge. Ohne Angabe alle unter mod/ ausser
    # ModInfo.xml, nach Pfad sortiert.
    [string[]]$Patches,
    # Unsere Sprachdatei. Ohne Angabe die des Sprach-Modlets.
    [string]$Sprachdatei,
    # Vanilla Data/Config (Localization.csv, items.xml, blocks.xml). Ohne Angabe aus SDTD_PATH.
    [string]$Vanilla
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

function Stop-Unpruefbar {
    param([string]$Grund)
    Write-Output "sprachverweise-pruefen: $Grund - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

# Jeder Fehler, den keine Stelle unten abfaengt, ist "nicht pruefbar" und nicht "Befund":
# ohne das endete ein direkter Aufruf nach einer Ausnahme mit Ausgang 1.
trap {
    Write-Output "sprachverweise-pruefen: unerwarteter Fehler ($($_.Exception.Message)) - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

function Test-Gleich {
    # Zeichen fuer Zeichen. -eq und -ceq vergleichen nach Kulturregeln.
    param([string]$Links, [string]$Rechts)
    return [string]::Equals($Links, $Rechts, [System.StringComparison]::Ordinal)
}

function Test-In {
    param([string]$Wert, [string[]]$Menge)
    foreach ($m in $Menge) { if (Test-Gleich $Wert $m) { return $true } }
    return $false
}

function Get-Innerste {
    param($Ausnahme)
    while ($Ausnahme.InnerException) { $Ausnahme = $Ausnahme.InnerException }
    return $Ausnahme.Message
}

function Get-Kurz {
    # Die letzten drei Glieder: 'items.xml' allein gibt es in mehreren Modlets.
    param([string]$Pfad)
    return (($Pfad.Split('\') | Select-Object -Last 3) -join '\')
}

# Test-Path und Resolve-Path WERFEN bei einem Pfad mit unzulaessigen Zeichen
# ('C:\invalid<file>'). Das ist "gibt es nicht", keine Ausnahme (Review, Befund 6).
function Test-Datei {
    param([string]$Pfad)
    if (-not $Pfad) { return $false }
    try { return [bool](Test-Path -LiteralPath $Pfad -PathType Leaf) } catch { return $false }
}

function Test-Ordner {
    param([string]$Pfad)
    if (-not $Pfad) { return $false }
    try { return [bool](Test-Path -LiteralPath $Pfad -PathType Container) } catch { return $false }
}

function Get-Voll {
    param([string]$Pfad)
    try { return (Resolve-Path -LiteralPath $Pfad).ProviderPath } catch { return $null }
}

# ------------------------------------------------------------------ Eingaben finden
if (-not $Vanilla) {
    if (-not $env:SDTD_PATH) { Stop-Unpruefbar 'SDTD_PATH ist nicht gesetzt und -Vanilla nicht angegeben' }
    try { $Vanilla = [IO.Path]::Combine($env:SDTD_PATH, 'Data\Config') }
    catch { Stop-Unpruefbar "SDTD_PATH ist kein gueltiger Pfad ($($env:SDTD_PATH))" }
}
if (-not (Test-Ordner $Vanilla)) { Stop-Unpruefbar "den Vanilla-Ordner '$Vanilla' gibt es nicht (zeigt SDTD_PATH auf eine Installation?)" }
$vanillaVoll = Get-Voll $Vanilla
if (-not $vanillaVoll) { Stop-Unpruefbar "der Vanilla-Ordner '$Vanilla' laesst sich nicht aufloesen" }
$Vanilla = $vanillaVoll

if (-not $Sprachdatei) { $Sprachdatei = Join-Path $repoRoot 'mod\700_90_Sprache\Config\Localization.csv' }
if (-not (Test-Datei $Sprachdatei)) { Stop-Unpruefbar "die Sprachdatei '$Sprachdatei' gibt es nicht" }
$sprachdateiVoll = Get-Voll $Sprachdatei
if (-not $sprachdateiVoll) { Stop-Unpruefbar "die Sprachdatei '$Sprachdatei' laesst sich nicht aufloesen" }
$Sprachdatei = $sprachdateiVoll

if ($PSBoundParameters.ContainsKey('Patches')) {
    foreach ($pfad in @($Patches)) {
        if (-not (Test-Datei $pfad)) { Stop-Unpruefbar "-Patches nennt '$pfad', und das ist keine Datei" }
    }
}
else {
    $modOrdner = Join-Path $repoRoot 'mod'
    if (-not (Test-Ordner $modOrdner)) { Stop-Unpruefbar "den Ordner '$modOrdner' gibt es nicht" }
    $Patches = @(Get-ChildItem -LiteralPath $modOrdner -Recurse -Filter '*.xml' |
        Where-Object { -not (Test-Gleich $_.Name 'ModInfo.xml') -and $_.FullName -notmatch '\\\.relay\\' } |
        Sort-Object FullName |
        Select-Object -ExpandProperty FullName)
}
if (@($Patches).Count -eq 0) { Stop-Unpruefbar 'es gibt keine Patch-Datei zu lesen' }

# ------------------------------------------------------------------ Sprachdateien lesen
function Read-Schluessel {
    # Die Schluesselspalte einer Sprachdatei, in der Reihenfolge der Datei. Import-Csv
    # vertraegt Felder in Anfuehrungszeichen mit Zeilenumbruch; die FORM der Datei prueft
    # 'mod700check localization', nicht dieses Skript.
    param([string]$Pfad, [string]$Rolle)
    try { $zeilen = @(Import-Csv -LiteralPath $Pfad -Encoding UTF8) }
    catch { Stop-Unpruefbar "$Rolle '$Pfad' laesst sich nicht lesen ($(Get-Innerste $_.Exception))" }
    if ($zeilen.Count -eq 0) { Stop-Unpruefbar "$Rolle '$Pfad' hat keine Zeile" }
    $hatKey = $false
    foreach ($spalte in $zeilen[0].PSObject.Properties) {
        if (Test-Gleich $spalte.Name 'Key') { $hatKey = $true }
    }
    if (-not $hatKey) { Stop-Unpruefbar "$Rolle '$Pfad' hat keine Spalte 'Key'" }
    $liste = New-Object System.Collections.Generic.List[string]
    foreach ($zeile in $zeilen) {
        $wert = [string]$zeile.Key
        if ($wert) { $wert = $wert.Trim() }
        if ($wert) { $liste.Add($wert) }
    }
    if ($liste.Count -eq 0) { Stop-Unpruefbar "$Rolle '$Pfad' hat keinen Schluessel" }
    return , $liste
}

$vanillaSprachdatei = Join-Path $Vanilla 'Localization.csv'
if (-not (Test-Datei $vanillaSprachdatei)) { Stop-Unpruefbar "$vanillaSprachdatei fehlt (zeigt SDTD_PATH auf eine Installation?)" }

$unsereListe = Read-Schluessel $Sprachdatei 'die Sprachdatei'
$vanillaListe = Read-Schluessel $vanillaSprachdatei 'Vanillas Sprachdatei'
$unsereSchluessel = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($k in $unsereListe) { [void]$unsereSchluessel.Add($k) }
$vanillaSchluessel = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($k in $vanillaListe) { [void]$vanillaSchluessel.Add($k) }

# ------------------------------------------------------------------ XML lesen
function Read-Xml {
    param([string]$Pfad, [string]$Rolle)
    $doc = New-Object System.Xml.XmlDocument
    try { $doc.LoadXml([IO.File]::ReadAllText($Pfad)) }
    catch { Stop-Unpruefbar "$Rolle '$Pfad' laesst sich nicht als XML lesen ($(Get-Innerste $_.Exception))" }
    return $doc
}

$element = [System.Xml.XmlNodeType]::Element
$attributArt = [System.Xml.XmlNodeType]::Attribute

function Get-Tabelle {
    # Je <item> oder <block> unmittelbar unter der Wurzel: was es ueber seine Beschreibung
    # sagt - eigene Eigenschaft, Elternteil, und was es vom Elternteil NICHT uebernimmt
    # (param1). 'Anzahl' zaehlt die eigenen Eigenschaften DescriptionKey: zwei davon sind
    # ein Befund, weil nicht gelesen ist, welche gilt.
    param($Doc, [string]$Art)
    $tabelle = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
    foreach ($knoten in $Doc.get_DocumentElement().get_ChildNodes()) {
        if ($knoten.get_NodeType() -ne $element) { continue }
        if (-not (Test-Gleich $knoten.get_LocalName() $Art)) { continue }
        $nameDing = $knoten.GetAttribute('name')
        if (-not $nameDing) { continue }
        $eintrag = @{ Name = $nameDing; Eigen = $null; Eltern = $null; Aus = @(); Anzahl = 0 }
        foreach ($kind in $knoten.get_ChildNodes()) {
            if ($kind.get_NodeType() -ne $element) { continue }
            if (-not (Test-Gleich $kind.get_LocalName() 'property')) { continue }
            $eigenschaft = $kind.GetAttribute('name')
            if (Test-Gleich $eigenschaft 'DescriptionKey') {
                $eintrag.Anzahl++
                # Der GANZE Wert ist ein Schluessel; ein Komma darin teilt nichts.
                $wert = $kind.GetAttribute('value').Trim()
                if ($wert) { $eintrag.Eigen = $wert }
            }
            elseif (Test-Gleich $eigenschaft 'Extends') {
                $eintrag.Eltern = $kind.GetAttribute('value').Trim()
                $eintrag.Aus = @($kind.GetAttribute('param1').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
            }
        }
        $tabelle[$nameDing] = $eintrag
    }
    return , $tabelle
}

# Die zwei Dateien, auf die Patches angewandt werden. 'Doc' ist zuerst Vanilla und nach
# dem Anwenden der gepatchte Stand; 'Vanilla' ist die Tabelle VOR den Patches.
$ziele = @{
    item  = @{ Datei = 'items.xml';  Wurzel = 'items';  Doc = $null; Vanilla = $null }
    block = @{ Datei = 'blocks.xml'; Wurzel = 'blocks'; Doc = $null; Vanilla = $null }
}
foreach ($art in 'item', 'block') {
    $pfad = Join-Path $Vanilla $ziele[$art].Datei
    if (-not (Test-Datei $pfad)) { Stop-Unpruefbar "$pfad fehlt (zeigt SDTD_PATH auf eine Installation?)" }
    $doc = Read-Xml $pfad 'die Vanilla-Datei'
    # JEDE der beiden Dateien fuer sich (Review, Befund 5): mit einer leeren blocks.xml
    # reichte vorher die Zahl der Gegenstaende, und alle Block-Beschreibungen blieben
    # ungeprueft - gruen.
    $wurzel = $doc.get_DocumentElement().get_LocalName()
    if (-not (Test-Gleich $wurzel $ziele[$art].Wurzel)) {
        Stop-Unpruefbar "die Vanilla-Datei '$pfad' hat die Wurzel <$wurzel>, erwartet ist <$($ziele[$art].Wurzel)>"
    }
    $tabelle = Get-Tabelle $doc $art
    if ($tabelle.Count -eq 0) { Stop-Unpruefbar "in der Vanilla-Datei '$pfad' steht kein einziges <$art> mit Namen" }
    $ziele[$art].Doc = $doc
    $ziele[$art].Vanilla = $tabelle
}
# Die Gruppenbeschreibung der Bloecke, wie Vanilla sie traegt - VOR den Patches.
$gruppeVanilla = $ziele.block.Doc.get_DocumentElement().GetAttribute('defaultDescriptionKey').Trim()

# ------------------------------------------------------------------ Nennungen sammeln
$befunde = New-Object System.Collections.Generic.List[string]
$genannt = New-Object System.Collections.Generic.List[object]     # Schluessel, Art, Datei, Zaehlt
$genanntGesehen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)

$operationen = @('set', 'setattribute', 'append', 'prepend', 'insertAfter', 'insertBefore', 'remove', 'removeattribute', 'csv')
$einfuegend = @('append', 'prepend', 'insertAfter', 'insertBefore')
$behaelter = @('conditional', 'if', 'else')
$attributMuster = New-Object System.Text.RegularExpressions.Regex('/@([A-Za-z0-9_]+)\s*$')
$beschreibungMuster = New-Object System.Text.RegularExpressions.Regex('property\[\s*@name\s*=\s*([''"])DescriptionKey\1\s*\]/@value\s*$')

function Add-Genannt {
    # -Einzeln: der Wert ist EIN Schluessel (DescriptionKey). Sonst zaehlt eine Kommaliste
    # je Teil (name_key="a,b,c" an einer Anzeigezeile).
    # -Zaehlt: ob die Nennung den Schluessel fuer die Regeln 2 und 3 als GELESEN ausweist.
    # Das tut sie nur in einer Datei, die das Skript nicht anwendet; in items.xml und
    # blocks.xml zaehlt, was nach den Patches dasteht (Review, Befund 3).
    param([string]$Wert, [string]$Art, [string]$Datei, [switch]$Einzeln, [bool]$Zaehlt = $true)
    $teile = @($Wert)
    if (-not $Einzeln) { $teile = @($Wert.Split(',')) }
    foreach ($teil in $teile) {
        $schluessel = $teil.Trim()
        if (-not $schluessel) { continue }
        if ($script:genanntGesehen.Add("$schluessel|$Art|$Datei")) {
            $script:genannt.Add(@{ Schluessel = $schluessel; Art = $Art; Datei = $Datei; Zaehlt = $Zaehlt })
        }
    }
}

function Read-Knoten {
    # Was ein Knoten (und alles darunter) an Schluesseln NENNT.
    # -Angewandt: die Datei ist ein Patch fuer items.xml oder blocks.xml. Dann zaehlt keine
    # Nennung als "gelesen", und DescriptionKey wird hier gar nicht gesammelt - beides
    # kommt aus dem gepatchten Stand.
    param($Knoten, [string]$Datei, [bool]$Angewandt)
    if ($Knoten.get_NodeType() -ne $element) { return }
    $name = $Knoten.get_LocalName()
    $zaehlt = -not $Angewandt

    if (Test-In $name $operationen) {
        $xpath = $Knoten.GetAttribute('xpath')
        if (Test-Gleich $name 'set') {
            $text = $Knoten.get_InnerText().Trim()
            if ($script:beschreibungMuster.IsMatch($xpath)) {
                if (-not $Angewandt) { Add-Genannt $text 'set DescriptionKey' $Datei -Einzeln -Zaehlt $zaehlt }
            }
            else {
                $attribut = $script:attributMuster.Match($xpath)
                if ($attribut.Success -and $attribut.Groups[1].Value.EndsWith('_key', [System.StringComparison]::Ordinal)) {
                    Add-Genannt $text "set @$($attribut.Groups[1].Value)" $Datei -Zaehlt $zaehlt
                }
            }
            return
        }
        if (Test-Gleich $name 'setattribute') {
            $attribut = $Knoten.GetAttribute('name')
            if ($attribut.EndsWith('_key', [System.StringComparison]::Ordinal)) {
                Add-Genannt $Knoten.get_InnerText().Trim() "setattribute @$attribut" $Datei -Zaehlt $zaehlt
            }
            return
        }
        if (Test-In $name $einfuegend) {
            foreach ($kind in $Knoten.get_ChildNodes()) { Read-Knoten $kind $Datei $Angewandt }
        }
        return
    }

    if (Test-In $name $behaelter) {
        foreach ($kind in $Knoten.get_ChildNodes()) { Read-Knoten $kind $Datei $Angewandt }
        return
    }

    # Ein Inhaltsknoten.
    foreach ($attribut in $Knoten.get_Attributes()) {
        if ($attribut.get_LocalName().EndsWith('_key', [System.StringComparison]::Ordinal)) {
            Add-Genannt $attribut.get_Value() "<$name> @$($attribut.get_LocalName())" $Datei -Zaehlt $zaehlt
        }
    }
    if (-not $Angewandt -and (Test-Gleich $name 'property') -and (Test-Gleich $Knoten.GetAttribute('name') 'DescriptionKey')) {
        Add-Genannt $Knoten.GetAttribute('value') 'Eigenschaft DescriptionKey' $Datei -Einzeln -Zaehlt $zaehlt
    }
    foreach ($kind in $Knoten.get_ChildNodes()) { Read-Knoten $kind $Datei $Angewandt }
}

# ------------------------------------------------------------------ Patches anwenden
$angewandt = 0
$ohneTreffer = 0
$nichtGerechnet = 0
$angewandteDateien = 0

function Get-Kinder {
    # Die Kindelemente einer Operation, fuer das Zieldokument uebernommen.
    param($Operation, $ZielDoc)
    $kinder = New-Object System.Collections.Generic.List[object]
    foreach ($kind in $Operation.get_ChildNodes()) {
        if ($kind.get_NodeType() -ne $element) { continue }
        $kinder.Add($ZielDoc.ImportNode($kind, $true))
    }
    return , $kinder
}

function Invoke-Operation {
    # EINE Operation auf EINEN getroffenen Knoten. So, wie Vertrag 03 und das Finding WP1
    # die neun Operationen beschreiben.
    param([string]$Name, $Operation, $Treffer, $ZielDoc)
    $text = $Operation.get_InnerText().Trim()
    $istAttribut = ($Treffer.get_NodeType() -eq $attributArt)

    if (Test-Gleich $Name 'set') {
        if ($istAttribut) { $Treffer.set_Value($text) } else { $Treffer.set_InnerText($text) }
        return
    }
    # Welche Paare aus Operation und Knotenart hier ankommen, entscheidet Get-Hindernis:
    # setattribute, removeattribute, remove, insertAfter und insertBefore nur mit einem
    # Element, csv nur mit einem Attribut. Darum steht unten kein stilles "sonst nichts".
    if (Test-Gleich $Name 'setattribute') {
        $Treffer.SetAttribute($Operation.GetAttribute('name'), $text)
        return
    }
    if (Test-Gleich $Name 'removeattribute') {
        $Treffer.RemoveAttribute($Operation.GetAttribute('name'))
        return
    }
    if (Test-Gleich $Name 'remove') {
        [void]$Treffer.get_ParentNode().RemoveChild($Treffer)
        return
    }
    if (Test-Gleich $Name 'csv') {
        $trenner = $Operation.GetAttribute('delim')
        if (-not $trenner) { $trenner = ',' }
        $liste = New-Object System.Collections.Generic.List[string]
        foreach ($teil in $Treffer.get_Value().Split(@($trenner), [System.StringSplitOptions]::None)) { $liste.Add($teil) }
        $weg = Test-Gleich $Operation.GetAttribute('op') 'remove'
        foreach ($teil in $text.Split(@($trenner), [System.StringSplitOptions]::None)) {
            if ($weg) { [void]$liste.Remove($teil) }
            elseif (-not $liste.Contains($teil)) { $liste.Add($teil) }
        }
        $Treffer.set_Value(($liste -join $trenner))
        return
    }
    if (Test-Gleich $Name 'append') {
        if ($istAttribut) { $Treffer.set_Value($Treffer.get_Value() + $text); return }
        foreach ($neu in (Get-Kinder $Operation $ZielDoc)) { [void]$Treffer.AppendChild($neu) }
        return
    }
    if (Test-Gleich $Name 'prepend') {
        if ($istAttribut) { $Treffer.set_Value($text + $Treffer.get_Value()); return }
        $erstes = $Treffer.get_FirstChild()
        foreach ($neu in (Get-Kinder $Operation $ZielDoc)) {
            if ($null -eq $erstes) { [void]$Treffer.AppendChild($neu) } else { [void]$Treffer.InsertBefore($neu, $erstes) }
        }
        return
    }
    $eltern = $Treffer.get_ParentNode()
    if (Test-Gleich $Name 'insertBefore') {
        foreach ($neu in (Get-Kinder $Operation $ZielDoc)) { [void]$eltern.InsertBefore($neu, $Treffer) }
        return
    }
    # insertAfter: der Reihe nach, jedes hinter das vorige.
    $hinter = $Treffer
    foreach ($neu in (Get-Kinder $Operation $ZielDoc)) {
        [void]$eltern.InsertAfter($neu, $hinter)
        $hinter = $neu
    }
}

$nurElement = @('setattribute', 'removeattribute', 'insertAfter', 'insertBefore')

function Get-Hindernis {
    # Warum sich eine Operation an ihren Treffern NICHT rechnen laesst - oder $null.
    # Vorher tat das Skript an diesen Stellen nichts und zaehlte die Operation als
    # angewandt; ein <remove> auf ein Attribut entfernte es sogar, obwohl das Spiel genau
    # das ablehnt (zweites Review zu WP8.8, Befund 1; Vertrag 03, Abschnitt 2).
    param([string]$Name, $Treffer)
    foreach ($knoten in $Treffer) {
        $art = $knoten.get_NodeType()
        if ($art -eq $script:attributArt) {
            # Die Namespace-Achse (/items/namespace::xml) liefert ein Attribut, das an
            # keinem Element haengt. Es zu setzen aendert am Dokument nichts (drittes
            # Review zu WP8.8, Befund 2).
            if ($null -eq $knoten.get_OwnerElement()) {
                return 'einen Namespace-Knoten; er gehoert zu keinem Element'
            }
            if (Test-Gleich $Name 'remove') {
                return 'ein Attribut; das Spiel lehnt das ab ("use removeattribute instead")'
            }
            if (Test-In $Name $script:nurElement) {
                return "ein Attribut; <$Name> rechnet diese Pruefung nur auf einem Element"
            }
        }
        elseif ($art -eq $script:element) {
            if (Test-Gleich $Name 'csv') {
                return 'ein Element; <csv> rechnet diese Pruefung nur auf einem Attribut'
            }
        }
        else {
            return "einen Knoten der Art $art; gerechnet werden nur Elemente und Attribute"
        }
    }
    return $null
}

function Invoke-Patchdatei {
    # Wendet eine Patch-Datei auf das Zieldokument an, Operation fuer Operation, jeden
    # XPath gegen den Stand, den die Operationen davor hinterlassen haben. Was sich nicht
    # anwenden laesst, ist ein Befund (Regel 5): der gerechnete Stand waere sonst geraten.
    param($PatchDoc, $ZielDoc, [string]$Datei)
    foreach ($operation in $PatchDoc.get_DocumentElement().get_ChildNodes()) {
        if ($operation.get_NodeType() -ne $element) { continue }
        $name = $operation.get_LocalName()
        if (Test-In $name $behaelter) {
            $script:befunde.Add("bedingter Block in einer Datei, die diese Pruefung anwendet: <$name> wird nicht gerechnet  ($Datei)")
            continue
        }
        if (-not (Test-In $name $operationen)) {
            $script:befunde.Add("unbekannte Patch-Operation <$name>, nicht angewandt  ($Datei)")
            continue
        }
        $xpath = $operation.GetAttribute('xpath')
        $treffer = New-Object System.Collections.Generic.List[object]
        try {
            # Erst ALLE Treffer einsammeln, dann aendern: die Liste von SelectNodes wird
            # beim Durchlaufen berechnet und vertraegt keine Aenderung am Dokument.
            foreach ($knoten in $ZielDoc.SelectNodes($xpath)) { $treffer.Add($knoten) }
        }
        catch {
            $script:befunde.Add("XPath laesst sich nicht auswerten: <$name xpath=""$xpath"">  ($Datei; $(Get-Innerste $_.Exception))")
            continue
        }
        if ($treffer.Count -eq 0) {
            $script:ohneTreffer++
            $script:befunde.Add("Patch trifft nichts: <$name xpath=""$xpath"">  ($Datei)")
            continue
        }
        # Erst pruefen, dann aendern: ist EIN Treffer nicht rechenbar, bleibt die ganze
        # Operation weg - halb angewandt waere der Stand wieder geraten.
        $hindernis = Get-Hindernis $name $treffer
        if ($null -ne $hindernis) {
            $script:nichtGerechnet++
            $script:befunde.Add("Patch laesst sich nicht rechnen: <$name xpath=""$xpath""> trifft $hindernis  ($Datei)")
            continue
        }
        foreach ($knoten in $treffer) { Invoke-Operation $name $operation $knoten $ZielDoc }
        $script:angewandt++
    }
}

foreach ($pfad in $Patches) {
    $voll = Get-Voll $pfad
    if (-not $voll) { Stop-Unpruefbar "die Patch-Datei '$pfad' laesst sich nicht aufloesen" }
    $doc = Read-Xml $voll 'die Patch-Datei'
    $kurz = Get-Kurz $voll
    $blatt = [IO.Path]::GetFileName($voll)
    $zielArt = $null
    foreach ($art in 'item', 'block') {
        if ([string]::Equals($blatt, $ziele[$art].Datei, [System.StringComparison]::OrdinalIgnoreCase)) { $zielArt = $art }
    }
    foreach ($kind in $doc.get_DocumentElement().get_ChildNodes()) { Read-Knoten $kind $kurz ($null -ne $zielArt) }
    if ($null -ne $zielArt) {
        $angewandteDateien++
        Invoke-Patchdatei $doc $ziele[$zielArt].Doc $kurz
    }
}

# ------------------------------------------------------------------ der gepatchte Stand
$tabellen = @{
    item  = (Get-Tabelle $ziele.item.Doc 'item')
    block = (Get-Tabelle $ziele.block.Doc 'block')
}

function Get-Wirksam {
    # Regel 4. Gibt Schluessel und Herkunft zurueck.
    param([string]$Art, [string]$Name)
    $tabelle = $script:tabellen[$Art]
    $aktuell = $tabelle[$Name]
    $tiefe = 0
    while ($true) {
        if ($aktuell.Eigen) {
            if (Test-Gleich $aktuell.Name $Name) { return @{ Schluessel = $aktuell.Eigen; Woher = 'eigene Eigenschaft' } }
            return @{ Schluessel = $aktuell.Eigen; Woher = "geerbt von '$($aktuell.Name)'" }
        }
        if (-not $aktuell.Eltern) { break }
        if (Test-In 'DescriptionKey' $aktuell.Aus) { break }
        if (-not $tabelle.ContainsKey($aktuell.Eltern)) { break }
        if ($tiefe -ge 50) { break }
        $aktuell = $tabelle[$aktuell.Eltern]
        $tiefe++
    }
    return @{ Schluessel = ($Name + 'Desc'); Woher = 'Vorgabe <Name>Desc' }
}

$wort = @{ item = 'Gegenstand'; block = 'Block' }
$wirksam = @{
    item  = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
    block = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
}
$eigeneNamen = @{ item = (New-Object System.Collections.Generic.List[string]); block = (New-Object System.Collections.Generic.List[string]) }
$gelesen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$gesetzt = 0

foreach ($art in 'item', 'block') {
    $vorher = $ziele[$art].Vanilla
    foreach ($nameDing in @($tabellen[$art].Keys)) {
        $eintrag = $tabellen[$art][$nameDing]
        $w = Get-Wirksam $art $nameDing
        $wirksam[$art][$nameDing] = $w
        [void]$gelesen.Add($w.Schluessel)
        [void]$gelesen.Add($nameDing)

        $neu = -not $vorher.ContainsKey($nameDing)
        if ($neu) {
            $eigeneNamen[$art].Add($nameDing)
            Add-Genannt $nameDing "Name, eigener $($wort[$art])" 'gepatchter Stand' -Einzeln -Zaehlt $false
        }
        # Regel 1 am Stand: eine eigene Eigenschaft DescriptionKey, die Vanilla hier nicht
        # oder anders hat, haben WIR gesetzt - ihr Wert braucht eine Zeile.
        if ($eintrag.Eigen -and ($neu -or -not (Test-Gleich $vorher[$nameDing].Eigen $eintrag.Eigen))) {
            $gesetzt++
            Add-Genannt $eintrag.Eigen "DescriptionKey am $($wort[$art]) '$nameDing'" 'gepatchter Stand' -Einzeln -Zaehlt $false
        }
        # Regel 5, letzter Punkt.
        if ($eintrag.Anzahl -gt 1 -and ($neu -or $vorher[$nameDing].Anzahl -lt $eintrag.Anzahl)) {
            $befunde.Add("$($wort[$art]) '$nameDing' traegt nach den Patches $($eintrag.Anzahl) Eigenschaften DescriptionKey; welche gilt, ist nicht gelesen")
        }
    }
}

# Regel 4, dritter Schritt fuer Bloecke (drittes Review zu WP8.8, Befund 1): hat der
# wirksame Schluessel eines Blocks KEINE Zeile, liest das Spiel die Gruppenbeschreibung vom
# Wurzelknoten. Der Schluessel gilt als gelesen, sobald EIN Block so auf ihn zurueckfaellt
# - und nur dann. Haben WIR ihn gesetzt, braucht er eine Zeile (Regel 1).
$gruppe = $ziele.block.Doc.get_DocumentElement().GetAttribute('defaultDescriptionKey').Trim()
$gruppeLeser = 0
if ($gruppe) {
    foreach ($nameDing in $tabellen.block.Keys) {
        $schluessel = $wirksam.block[$nameDing].Schluessel
        if (-not $unsereSchluessel.Contains($schluessel) -and -not $vanillaSchluessel.Contains($schluessel)) { $gruppeLeser++ }
    }
    if ($gruppeLeser -gt 0) { [void]$gelesen.Add($gruppe) }
    if (-not (Test-Gleich $gruppe $gruppeVanilla)) {
        Add-Genannt $gruppe 'defaultDescriptionKey an <blocks>' 'gepatchter Stand' -Einzeln -Zaehlt $false
    }
}

# Regel 1, letzter Punkt: die Beschreibung jedes EIGENEN Gegenstands braucht eine Zeile.
# Bei Bloecken nicht - fehlt sie, nimmt das Spiel die Gruppenbeschreibung (Finding).
# Nur, wenn den Schluessel nicht schon etwas nennt: derselbe fehlende Schluessel soll
# EINE Zeile geben.
$schonGenannt = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($g in $genannt) { [void]$schonGenannt.Add($g.Schluessel) }
foreach ($nameDing in $eigeneNamen.item) {
    $beschreibung = $wirksam.item[$nameDing].Schluessel
    if ($schonGenannt.Add($beschreibung)) {
        Add-Genannt $beschreibung "Beschreibung des eigenen Gegenstands '$nameDing'" 'gepatchter Stand' -Einzeln -Zaehlt $false
    }
}

# Was als GELESEN gilt (Regeln 2 und 3): Namen und wirksame Schluessel stehen schon drin.
# Dazu jedes Attribut auf '_key' im gepatchten Stand (message_key an einer Wirkung) und
# jede Nennung in einer Datei, die das Skript nicht anwendet.
foreach ($art in 'item', 'block') {
    foreach ($attribut in $ziele[$art].Doc.SelectNodes("//@*[substring(local-name(), string-length(local-name()) - 3) = '_key']")) {
        foreach ($teil in $attribut.get_Value().Split(',')) {
            $schluessel = $teil.Trim()
            if ($schluessel) { [void]$gelesen.Add($schluessel) }
        }
    }
}
foreach ($g in $genannt) { if ($g.Zaehlt) { [void]$gelesen.Add($g.Schluessel) } }

# ------------------------------------------------------------------ Regel 1: vorwaerts
$inUnserer = 0
$nurVanilla = 0
$ohneZeile = 0
foreach ($g in $genannt) {
    if ($unsereSchluessel.Contains($g.Schluessel)) { $inUnserer++ }
    elseif ($vanillaSchluessel.Contains($g.Schluessel)) { $nurVanilla++ }
    else {
        $ohneZeile++
        $befunde.Add("Schluessel '$($g.Schluessel)' hat keine Zeile, weder in unserer Sprachdatei noch in Vanilla  ($($g.Art), $($g.Datei))")
    }
}

# ------------------------------------------------------------------ Regeln 2 und 3: rueckwaerts
function Test-AlsWertGelesen {
    # Steht der Schluessel als Wert irgendeiner Eigenschaft im GEPATCHTEN Stand von
    # items.xml oder blocks.xml? So liest z. B. 'PromptDescription' einen Schluessel, der
    # nicht der Beschreibungsschluessel ist. Nur dort: eine gleichlautende Eigenschaft in
    # einer anderen unserer Dateien liest nichts (Review, Befund 3).
    param([string]$Schluessel)
    if ($Schluessel.IndexOf("'") -ge 0) { return $false }
    $frage = "//property[@value='$Schluessel']"
    foreach ($art in 'item', 'block') {
        if ($null -ne $script:ziele[$art].Doc.SelectSingleNode($frage)) { return $true }
    }
    return $false
}

$geprueftNeu = 0
$geprueftBeschreibung = 0
$ungelesen = 0
foreach ($k in $unsereListe) {
    $ding = $null
    $artDing = $null
    $weg = $false
    if ($k.EndsWith('Desc', [System.StringComparison]::Ordinal) -and $k.Length -gt 4) {
        $stamm = $k.Substring(0, $k.Length - 4)
        if ($tabellen.item.ContainsKey($stamm)) { $ding = $stamm; $artDing = 'item' }
        elseif ($tabellen.block.ContainsKey($stamm)) { $ding = $stamm; $artDing = 'block' }
        # Auch, was es nur in VANILLA gibt (zweites Review zu WP8.8, Befund 2): entfernt
        # oder benennt ein Patch den Gegenstand um, fiel seine Zeile vorher aus der Pruefung
        # - Vanilla hat den Schluessel, und im gepatchten Stand stand der Name nicht mehr.
        # WER die Zeile liest, entscheidet weiter allein der gepatchte Stand.
        elseif ($ziele.item.Vanilla.ContainsKey($stamm)) { $ding = $stamm; $artDing = 'item'; $weg = $true }
        elseif ($ziele.block.Vanilla.ContainsKey($stamm)) { $ding = $stamm; $artDing = 'block'; $weg = $true }
    }
    $neu = -not $vanillaSchluessel.Contains($k)
    if (-not $neu -and $null -eq $ding) { continue }
    if ($null -ne $ding) { $geprueftBeschreibung++ } else { $geprueftNeu++ }

    if ($gelesen.Contains($k)) { continue }
    if (Test-AlsWertGelesen $k) { continue }

    $ungelesen++
    if ($weg) {
        $befunde.Add("Zeile '$k' wird nicht gelesen: $($wort[$artDing]) '$ding' steht in Vanilla und nach den Patches nicht mehr (entfernt oder umbenannt), und nichts im gepatchten Stand liest den Schluessel")
    }
    elseif ($null -ne $ding) {
        $w = $wirksam[$artDing][$ding]
        $befunde.Add("Zeile '$k' wird nicht gelesen: $($wort[$artDing]) '$ding' liest '$($w.Schluessel)' ($($w.Woher))")
    }
    else {
        $befunde.Add("Zeile '$k' wird nicht gelesen: Vanilla hat den Schluessel nicht, und nichts im gepatchten Stand oder in einer anderen Datei nennt ihn")
    }
}

# ------------------------------------------------------------------ Ausgabe
if ($genannt.Count -eq 0 -and ($geprueftNeu + $geprueftBeschreibung) -eq 0 -and $befunde.Count -eq 0) {
    Stop-Unpruefbar 'keine Patch-Datei nennt einen Schluessel, und keine Zeile der Sprachdatei faellt unter die Regeln 2 und 3'
}

Write-Output '== sprachverweise-pruefen =='
Write-Output "  Vanilla: $Vanilla"
Write-Output ("  Sprachdatei: {0} Schluessel; Vanillas Sprachdatei: {1}" -f $unsereSchluessel.Count, $vanillaSchluessel.Count)
Write-Output ("  Patch-Dateien: {0}, davon auf items.xml und blocks.xml angewandt: {1}" -f @($Patches).Count, $angewandteDateien)
Write-Output ("  Patch-Operationen angewandt: {0}, ohne Treffer: {1}, nicht gerechnet: {2}" -f $angewandt, $ohneTreffer, $nichtGerechnet)
Write-Output ("  Definitionen: {0} Gegenstaende und {1} Bloecke in Vanilla; nach den Patches {2} und {3}, davon eigene {4} und {5}" -f $ziele.item.Vanilla.Count, $ziele.block.Vanilla.Count, $tabellen.item.Count, $tabellen.block.Count, $eigeneNamen.item.Count, $eigeneNamen.block.Count)
Write-Output ("  Beschreibungsschluessel von uns gesetzt: {0}" -f $gesetzt)
Write-Output ("  Gruppenbeschreibung der Bloecke: '{0}'; Bloecke ohne eigene Zeile, die sie lesen: {1}" -f $gruppe, $gruppeLeser)
Write-Output ("  genannte Schluessel: {0} (in unserer Datei: {1}, nur in Vanilla: {2}, ohne Zeile: {3})" -f $genannt.Count, $inUnserer, $nurVanilla, $ohneZeile)
Write-Output ("  Zeilen rueckwaerts geprueft: {0} (neu gegenueber Vanilla: {1}, Beschreibungen von Gegenstaenden und Bloecken: {2}), nicht gelesen: {3}" -f ($geprueftNeu + $geprueftBeschreibung), $geprueftNeu, $geprueftBeschreibung, $ungelesen)

if ($befunde.Count -gt 0) {
    Write-Output ''
    foreach ($b in $befunde) { Write-Output "  [ROT]  $b" }
}

Write-Output ''
Write-Output '  Grenzen dieser Pruefung:'
Write-Output '    - Gelesen wird, was in XML steht. Schluessel, die der Spielcode zusammensetzt oder'
Write-Output '      fest nennt, sieht die Pruefung nicht; eine neue Zeile dafuer waere rot.'
Write-Output '    - Rueckwaerts geprueft werden neue Zeilen und Beschreibungen von Gegenstaenden und'
Write-Output '      Bloecken. Ob eine ueberschriebene Vanilla-Zeile anderer Art noch gelesen wird,'
Write-Output '      prueft niemand.'
Write-Output '    - Angewandt werden nur Patches fuer items.xml und blocks.xml, in der Reihenfolge der'
Write-Output '      Dateien. In allen anderen Dateien zaehlt die Nennung, auch in einem bedingten Block.'
Write-Output '    - Das Skript ist kein zweiter Patcher des Spiels: csv und append/prepend auf ein'
Write-Output '      Attribut sind nachgebaut, nicht am Spiel gemessen.'
Write-Output '    - Die Form der Sprachdatei prueft mod700check localization.'
Write-Output '    - Dass ein Schluessel eine Zeile hat, heisst nicht, dass der Text passt.'
Write-Output ''
if ($befunde.Count -gt 0) {
    Write-Output ("== Ergebnis: {0} rot -> RED ==" -f $befunde.Count)
    exit 1
}
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
