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

    DIE REGELN stehen in Vertrag 04, "Nachtrag WP8.8":
      1. Jeder genannte Schluessel hat eine Zeile (unsere Datei oder Vanilla).
      2. Jede Zeile, die Vanilla nicht hat, wird gelesen.
      3. Jede Zeile <Name>Desc eines Gegenstands oder Blocks wird gelesen.
      4. Der wirksame Beschreibungsschluessel: eigene Eigenschaft DescriptionKey, sonst
         geerbt ueber Extends (ausser param1 schliesst sie aus), sonst <Name>Desc.
      5. Eine Patch-Form an DescriptionKey, die Regel 4 nicht lesen kann, ist rot.
      6. Nichts gelesen ist nicht gruen (Ausgang 2).

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
    # Unsere XML-Patch-Dateien. Ohne Angabe alle unter mod/ ausser ModInfo.xml.
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

function Test-Gleich {
    # Zeichen fuer Zeichen. -eq und -ceq vergleichen nach Kulturregeln.
    param([string]$Links, [string]$Rechts)
    return [string]::Equals($Links, $Rechts, [System.StringComparison]::Ordinal)
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

# ------------------------------------------------------------------ Eingaben finden
if (-not $Vanilla) {
    if (-not $env:SDTD_PATH) { Stop-Unpruefbar 'SDTD_PATH ist nicht gesetzt und -Vanilla nicht angegeben' }
    try { $Vanilla = [IO.Path]::Combine($env:SDTD_PATH, 'Data\Config') }
    catch { Stop-Unpruefbar "SDTD_PATH ist kein gueltiger Pfad ($($env:SDTD_PATH))" }
}
$vanillaDa = $false
try { $vanillaDa = Test-Path -LiteralPath $Vanilla -PathType Container } catch { $vanillaDa = $false }
if (-not $vanillaDa) { Stop-Unpruefbar "den Vanilla-Ordner '$Vanilla' gibt es nicht (zeigt SDTD_PATH auf eine Installation?)" }
$Vanilla = (Resolve-Path -LiteralPath $Vanilla).ProviderPath

if (-not $Sprachdatei) { $Sprachdatei = Join-Path $repoRoot 'mod\700_90_Sprache\Config\Localization.csv' }
if (-not (Test-Path -LiteralPath $Sprachdatei -PathType Leaf)) { Stop-Unpruefbar "die Sprachdatei '$Sprachdatei' gibt es nicht" }
$Sprachdatei = (Resolve-Path -LiteralPath $Sprachdatei).ProviderPath

if ($PSBoundParameters.ContainsKey('Patches')) {
    foreach ($pfad in @($Patches)) {
        if (-not $pfad -or -not (Test-Path -LiteralPath $pfad -PathType Leaf)) {
            Stop-Unpruefbar "-Patches nennt '$pfad', und das ist keine Datei"
        }
    }
}
else {
    $modOrdner = Join-Path $repoRoot 'mod'
    if (-not (Test-Path -LiteralPath $modOrdner -PathType Container)) { Stop-Unpruefbar "den Ordner '$modOrdner' gibt es nicht" }
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
if (-not (Test-Path -LiteralPath $vanillaSprachdatei -PathType Leaf)) { Stop-Unpruefbar "$vanillaSprachdatei fehlt (zeigt SDTD_PATH auf eine Installation?)" }

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

function Get-Eintrag {
    # Was ein <item> oder <block> ueber seine Beschreibung sagt: eigene Eigenschaft,
    # Elternteil, und was es vom Elternteil NICHT uebernimmt (param1).
    param($Knoten)
    $eintrag = @{ Name = $Knoten.GetAttribute('name'); Eigen = $null; Eltern = $null; Aus = @(); HatEigenschaft = $false }
    foreach ($kind in $Knoten.get_ChildNodes()) {
        if ($kind.get_NodeType() -ne $element) { continue }
        if (-not (Test-Gleich $kind.get_LocalName() 'property')) { continue }
        $eintrag.HatEigenschaft = $true
        $eigenschaft = $kind.GetAttribute('name')
        if (Test-Gleich $eigenschaft 'DescriptionKey') {
            $wert = $kind.GetAttribute('value').Trim()
            if ($wert) { $eintrag.Eigen = $wert }
        }
        elseif (Test-Gleich $eigenschaft 'Extends') {
            $eintrag.Eltern = $kind.GetAttribute('value').Trim()
            $eintrag.Aus = @($kind.GetAttribute('param1').Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        }
    }
    return $eintrag
}

# Zwei Tabellen, je Art eine: 'item' -> Gegenstaende, 'block' -> Bloecke.
$tabellen = @{
    item  = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
    block = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
}
$vanillaDocs = @()
foreach ($paar in @(@('items.xml', 'item'), @('blocks.xml', 'block'))) {
    $pfad = Join-Path $Vanilla $paar[0]
    if (-not (Test-Path -LiteralPath $pfad -PathType Leaf)) { Stop-Unpruefbar "$pfad fehlt (zeigt SDTD_PATH auf eine Installation?)" }
    $doc = Read-Xml $pfad 'die Vanilla-Datei'
    $vanillaDocs += $doc
    foreach ($knoten in $doc.get_DocumentElement().get_ChildNodes()) {
        if ($knoten.get_NodeType() -ne $element) { continue }
        if (-not (Test-Gleich $knoten.get_LocalName() $paar[1])) { continue }
        $eintrag = Get-Eintrag $knoten
        if ($eintrag.Name) { $tabellen[$paar[1]][$eintrag.Name] = $eintrag }
    }
}
$vanillaGegenstaende = $tabellen.item.Count
$vanillaBloecke = $tabellen.block.Count
if (($vanillaGegenstaende + $vanillaBloecke) -eq 0) { Stop-Unpruefbar "in '$Vanilla' steht kein einziger Gegenstand oder Block" }

# ------------------------------------------------------------------ unsere Dateien lesen
$befunde = New-Object System.Collections.Generic.List[string]
$genannt = New-Object System.Collections.Generic.List[object]     # Schluessel, Art, Datei
$genanntGesehen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$umsetzungen = New-Object System.Collections.Generic.List[object] # Art, Name, Schluessel
$eigeneNamen = @{ item = (New-Object System.Collections.Generic.List[string]); block = (New-Object System.Collections.Generic.List[string]) }
$patchDocs = @()

$operationen = @('set', 'setattribute', 'append', 'insertAfter', 'insertBefore', 'remove', 'removeattribute', 'csv')
$behaelter = @('conditional', 'if', 'else')
$zielMuster = New-Object System.Text.RegularExpressions.Regex('^\s*/(items|blocks)/(item|block)\[\s*@name\s*=\s*([''"])([^''"]+)\3\s*\]\s*$')
$setzMuster = New-Object System.Text.RegularExpressions.Regex('^\s*/(items|blocks)/(item|block)\[\s*@name\s*=\s*([''"])([^''"]+)\3\s*\]/property\[\s*@name\s*=\s*([''"])DescriptionKey\5\s*\]/@value\s*$')
$attributMuster = New-Object System.Text.RegularExpressions.Regex('/@([A-Za-z0-9_]+)\s*$')

function Test-In {
    param([string]$Wert, [string[]]$Menge)
    foreach ($m in $Menge) { if (Test-Gleich $Wert $m) { return $true } }
    return $false
}

function Add-Genannt {
    param([string]$Wert, [string]$Art, [string]$Datei)
    foreach ($teil in $Wert.Split(',')) {
        $schluessel = $teil.Trim()
        if (-not $schluessel) { continue }
        if ($script:genanntGesehen.Add("$schluessel|$Art|$Datei")) {
            $script:genannt.Add(@{ Schluessel = $schluessel; Art = $Art; Datei = $Datei })
        }
    }
}

function Add-FormBefund {
    param([string]$Was, [string]$Datei)
    $script:befunde.Add("DescriptionKey wird in einer Form geaendert, die diese Pruefung nicht liest: $Was  ($Datei)")
}

function Read-Knoten {
    param($Knoten, [string]$Datei)
    if ($Knoten.get_NodeType() -ne $element) { return }
    $name = $Knoten.get_LocalName()

    if (Test-In $name $operationen) {
        $xpath = $Knoten.GetAttribute('xpath')
        $nenntBeschreibung = ($xpath.IndexOf('DescriptionKey', [System.StringComparison]::Ordinal) -ge 0)
        if (Test-Gleich $name 'set') {
            $text = $Knoten.get_InnerText().Trim()
            $treffer = $script:setzMuster.Match($xpath)
            if ($treffer.Success) {
                $script:umsetzungen.Add(@{ Art = $treffer.Groups[2].Value; Name = $treffer.Groups[4].Value; Schluessel = $text })
                Add-Genannt $text 'set DescriptionKey' $Datei
            }
            elseif ($nenntBeschreibung) { Add-FormBefund "<set xpath=""$xpath"">" $Datei }
            else {
                $attribut = $script:attributMuster.Match($xpath)
                if ($attribut.Success -and $attribut.Groups[1].Value.EndsWith('_key', [System.StringComparison]::Ordinal)) {
                    Add-Genannt $text "set @$($attribut.Groups[1].Value)" $Datei
                }
            }
            return
        }
        if (Test-Gleich $name 'setattribute') {
            if ($nenntBeschreibung) { Add-FormBefund "<setattribute xpath=""$xpath"">" $Datei }
            $attribut = $Knoten.GetAttribute('name')
            if ($attribut.EndsWith('_key', [System.StringComparison]::Ordinal)) {
                Add-Genannt $Knoten.get_InnerText().Trim() "setattribute @$attribut" $Datei
            }
            return
        }
        if ((Test-Gleich $name 'remove') -or (Test-Gleich $name 'removeattribute') -or (Test-Gleich $name 'csv')) {
            if ($nenntBeschreibung) { Add-FormBefund "<$name xpath=""$xpath"">" $Datei }
            return
        }
        # append, insertAfter, insertBefore: der Inhalt wird eingefuegt.
        if ($nenntBeschreibung) { Add-FormBefund "<$name xpath=""$xpath"">" $Datei }
        $ziel = $script:zielMuster.Match($xpath)
        foreach ($kind in $Knoten.get_ChildNodes()) {
            if ($kind.get_NodeType() -ne $element) { continue }
            if ((Test-Gleich $kind.get_LocalName() 'property') -and (Test-Gleich $kind.GetAttribute('name') 'DescriptionKey')) {
                # Ein DescriptionKey als unmittelbares Kind: der Patch haengt ihn an das Ziel.
                if ((Test-Gleich $name 'append') -and $ziel.Success) {
                    $script:umsetzungen.Add(@{ Art = $ziel.Groups[2].Value; Name = $ziel.Groups[4].Value; Schluessel = $kind.GetAttribute('value').Trim() })
                }
                elseif (-not $nenntBeschreibung) { Add-FormBefund "<$name xpath=""$xpath""> mit einem Kind DescriptionKey" $Datei }
            }
            Read-Knoten $kind $Datei
        }
        return
    }

    if (Test-In $name $behaelter) {
        foreach ($kind in $Knoten.get_ChildNodes()) { Read-Knoten $kind $Datei }
        return
    }

    # Ein Inhaltsknoten: was er an Schluesseln nennt.
    foreach ($attribut in $Knoten.get_Attributes()) {
        if ($attribut.get_LocalName().EndsWith('_key', [System.StringComparison]::Ordinal)) {
            Add-Genannt $attribut.get_Value() "<$name> @$($attribut.get_LocalName())" $Datei
        }
    }
    if ((Test-Gleich $name 'property') -and (Test-Gleich $Knoten.GetAttribute('name') 'DescriptionKey')) {
        Add-Genannt $Knoten.GetAttribute('value') 'Eigenschaft DescriptionKey' $Datei
    }
    if ((Test-Gleich $name 'item') -or (Test-Gleich $name 'block')) {
        $eintrag = Get-Eintrag $Knoten
        # Mit mindestens einer Eigenschaft: ein <item name=".." count=".."/> in einer
        # Beuteliste ist ein Verweis, keine Definition.
        if ($eintrag.Name -and $eintrag.HatEigenschaft) {
            $script:tabellen[$name][$eintrag.Name] = $eintrag
            $script:eigeneNamen[$name].Add($eintrag.Name)
            Add-Genannt $eintrag.Name "<$name> Name" $Datei
        }
    }
    foreach ($kind in $Knoten.get_ChildNodes()) { Read-Knoten $kind $Datei }
}

foreach ($pfad in $Patches) {
    $voll = (Resolve-Path -LiteralPath $pfad).ProviderPath
    $doc = Read-Xml $voll 'die Patch-Datei'
    $patchDocs += $doc
    $kurz = Get-Kurz $voll
    foreach ($kind in $doc.get_DocumentElement().get_ChildNodes()) { Read-Knoten $kind $kurz }
}

# Die Umsetzungen NACH dem Lesen aller Dateien: sie koennen auf eine eigene Definition
# zielen, die in einer spaeteren Datei steht.
$umgesetzt = 0
foreach ($u in $umsetzungen) {
    if ($tabellen[$u.Art].ContainsKey($u.Name) -and $u.Schluessel) {
        $tabellen[$u.Art][$u.Name].Eigen = $u.Schluessel
        $umgesetzt++
    }
}

# ------------------------------------------------------------------ wirksame Schluessel
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

$wirksam = @{
    item  = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
    block = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
}
$gelesen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($art in 'item', 'block') {
    foreach ($nameDing in @($tabellen[$art].Keys)) {
        $w = Get-Wirksam $art $nameDing
        $wirksam[$art][$nameDing] = $w
        [void]$gelesen.Add($w.Schluessel)
        [void]$gelesen.Add($nameDing)
    }
}

# Regel 1, letzter Punkt: die Beschreibung jedes EIGENEN Gegenstands braucht eine Zeile.
# Bei Bloecken nicht - fehlt sie, nimmt das Spiel die Gruppenbeschreibung (Finding).
# Nur, wenn den Schluessel nicht schon eine Datei nennt (die eigene Eigenschaft
# DescriptionKey steht dort bereits): derselbe fehlende Schluessel soll EINE Zeile geben.
$schonGenannt = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($g in $genannt) { [void]$schonGenannt.Add($g.Schluessel) }
foreach ($nameDing in $eigeneNamen.item) {
    $beschreibung = $wirksam.item[$nameDing].Schluessel
    if ($schonGenannt.Add($beschreibung)) {
        Add-Genannt $beschreibung "Beschreibung des eigenen Gegenstands '$nameDing'" 'wirksamer Schluessel'
    }
}
foreach ($g in $genannt) { [void]$gelesen.Add($g.Schluessel) }

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
function Test-AlsWertGenannt {
    # Steht der Schluessel als Wert irgendeiner Eigenschaft in items.xml/blocks.xml
    # (Vanilla) oder in einer unserer Dateien? So liest z. B. 'PromptDescription' einen
    # Schluessel, der nicht der Beschreibungsschluessel ist.
    param([string]$Schluessel)
    if ($Schluessel.IndexOf("'") -ge 0) { return $false }
    $frage = "//property[@value='$Schluessel']"
    foreach ($doc in (@($script:vanillaDocs) + @($script:patchDocs))) {
        if ($null -ne $doc.SelectSingleNode($frage)) { return $true }
    }
    return $false
}

$geprueftNeu = 0
$geprueftBeschreibung = 0
$ungelesen = 0
foreach ($k in $unsereListe) {
    $ding = $null
    $artDing = $null
    if ($k.EndsWith('Desc', [System.StringComparison]::Ordinal) -and $k.Length -gt 4) {
        $stamm = $k.Substring(0, $k.Length - 4)
        if ($tabellen.item.ContainsKey($stamm)) { $ding = $stamm; $artDing = 'item' }
        elseif ($tabellen.block.ContainsKey($stamm)) { $ding = $stamm; $artDing = 'block' }
    }
    $neu = -not $vanillaSchluessel.Contains($k)
    if (-not $neu -and $null -eq $ding) { continue }
    if ($null -ne $ding) { $geprueftBeschreibung++ } else { $geprueftNeu++ }

    if ($gelesen.Contains($k)) { continue }
    if (Test-AlsWertGenannt $k) { continue }

    $ungelesen++
    if ($null -ne $ding) {
        $w = $wirksam[$artDing][$ding]
        $wort = 'Gegenstand'
        if (Test-Gleich $artDing 'block') { $wort = 'Block' }
        $befunde.Add("Zeile '$k' wird nicht gelesen: $wort '$ding' liest '$($w.Schluessel)' ($($w.Woher))")
    }
    else {
        $befunde.Add("Zeile '$k' wird nicht gelesen: Vanilla hat den Schluessel nicht, und keine XML-Datei nennt ihn")
    }
}

# ------------------------------------------------------------------ Ausgabe
if ($genannt.Count -eq 0 -and ($geprueftNeu + $geprueftBeschreibung) -eq 0 -and $befunde.Count -eq 0) {
    Stop-Unpruefbar 'keine Patch-Datei nennt einen Schluessel, und keine Zeile der Sprachdatei faellt unter die Regeln 2 und 3'
}

Write-Output '== sprachverweise-pruefen =='
Write-Output "  Vanilla: $Vanilla"
Write-Output ("  Sprachdatei: {0} Schluessel; Vanillas Sprachdatei: {1}" -f $unsereSchluessel.Count, $vanillaSchluessel.Count)
Write-Output ("  Patch-Dateien: {0}" -f @($Patches).Count)
Write-Output ("  Definitionen: {0} Gegenstaende und {1} Bloecke aus Vanilla, {2} und {3} eigene" -f $vanillaGegenstaende, $vanillaBloecke, $eigeneNamen.item.Count, $eigeneNamen.block.Count)
Write-Output ("  DescriptionKey-Patches gelesen: {0} (davon auf ein bekanntes Ziel: {1})" -f $umsetzungen.Count, $umgesetzt)
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
Write-Output '    - Ein Patch in einem bedingten Block gilt als angewandt; ein Patch, der Extends'
Write-Output '      umsetzt, bleibt ungesehen.'
Write-Output '    - Die Form der Sprachdatei prueft mod700check localization.'
Write-Output '    - Dass ein Schluessel eine Zeile hat, heisst nicht, dass der Text passt.'
Write-Output ''
if ($befunde.Count -gt 0) {
    Write-Output ("== Ergebnis: {0} rot -> RED ==" -f $befunde.Count)
    exit 1
}
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
