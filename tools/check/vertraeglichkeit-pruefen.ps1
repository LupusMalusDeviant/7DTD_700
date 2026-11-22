<#
.SYNOPSIS
    Rechnet aus, wo sich unsere Modlets und eine fremde Mod in derselben XML-Datei
    beruehren - ohne das Spiel zu starten.

.DESCRIPTION
    WARUM ES DIESES SKRIPT GIBT (WP8.9, 2026-11-22). D86 nennt zwei Referenz-UI-Mods; ob
    sich unsere Modlets mit ihnen vertragen, zeigt die Testmatrix im Spiel (Plan,
    Pruefliste 24). Davor liess sich nur am Text suchen, und eine Textsuche sieht nicht,
    ob die fremde Mod einen Elternknoten unserer Ziele entfernt oder einen Wert
    ueberschreibt. Dieses Skript wendet die Patches an und vergleicht die Staende.
    ES ERSETZT KEINEN LAUF: es sagt, wo ein Lauf hinsehen muss.

    DIE REGELN stehen in Vertrag 04, "Nachtrag WP8.9":
      1. Geladen wird wie im Spiel: je Mod eine Patch-Datei je Vanilla-Datei gleichen
         Pfads unter Config; unsere Modlets in der Reihenfolge ihrer Ordnernamen.
      2. Je gemeinsamer Datei vier Staende, jeder von der frischen Vanilla-Datei aus:
         wir allein, die fremde Mod allein, wir dann fremd, fremd dann wir.
      3. Beide Reihenfolgen werden gerechnet; erwartet ist die der Ordnernamen.
      4. Befund ist: Ziel verloren, Zweig wechselt, Wirkung veraendert, nicht gerechnet,
         gemeinsamer Sprachschluessel.
      5. Kein Befund, aber genannt: was schon allein nichts trifft, und Dateien ohne
         Vanilla-Gegenstueck.
      6. Bedingungen liest die NCalc.dll des Spiels; xpath(...) laeuft gegen den Stand
         vor der Operation, mod_loaded(...) gegen die Namen aus ModInfo.xml.
      7. Nichts gerechnet ist nicht gruen (Ausgang 2).
      8. Fremde Dateien sind Daten: XML ohne DTD, nichts wird ausgefuehrt oder geladen.

    AUSGAENGE: 0 gruen, 1 Befund, 2 nicht pruefbar.

.NOTES
    Der Aufbau eines XML-Knotens wird ueber METHODEN gelesen (get_NodeType(),
    get_LocalName(), get_ChildNodes(), GetAttribute()), nie ueber Eigenschaften: in
    Windows PowerShell 5.1 legt der XML-Adapter Attribute und Kindelemente als
    Eigenschaften ueber den Knoten (Vertrag 04, viertes Review zu WP8.7).
    Die Datei enthaelt nur ASCII und braucht darum keine BOM.
#>
[CmdletBinding()]
param(
    # Ordner fremder Mods, jeder mit ModInfo.xml und Config direkt darin. Ohne Angabe jeder
    # solche Ordner unmittelbar unter GameRefs\ui-mods.
    [string[]]$Fremd,
    # Unsere Modlet-Ordner. Ohne Angabe jeder Ordner unter mod\ mit ModInfo.xml.
    [string[]]$Unsere,
    # Vanilla Data/Config. Ohne Angabe aus SDTD_PATH.
    [string]$Vanilla,
    # Die NCalc.dll des Spiels. Ohne Angabe <SDTD_PATH>\7DaysToDie_Data\Managed\NCalc.dll.
    [string]$NCalc
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

# "Nicht pruefbar" wird GEWORFEN und unten in der Falle geschrieben - nicht an der Stelle
# selbst. Eine Meldung, die eine Funktion schreibt, waehrend ihr Aufrufer die Ausgabe
# einsammelt (@(...)), ginge mit dem 'exit' verloren: der Ausgang waere 2, der Grund fehlte.
$abbruchGrund = $null
function Stop-Unpruefbar {
    param([string]$Grund)
    $script:abbruchGrund = $Grund
    throw "nicht pruefbar: $Grund"
}

# Die Falle faengt beides: den geworfenen Abbruch und jeden Fehler, den keine Stelle unten
# abfaengt. Beides ist "nicht pruefbar" und nicht "Befund".
trap {
    if ($null -ne $script:abbruchGrund) {
        Write-Output "vertraeglichkeit-pruefen: $($script:abbruchGrund) - NICHT GEPRUEFT."
    }
    else {
        Write-Output "vertraeglichkeit-pruefen: unerwarteter Fehler ($($_.Exception.Message)) - NICHT GEPRUEFT."
    }
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

# Die neun Patch-Operationen, Test-Gleich und Test-In (auch von sprachverweise-pruefen.ps1
# eingelesen). Fehlt die Datei, ist nichts gerechnet.
$bibliothek = Join-Path $here 'patch-operationen.ps1'
$bibliothekDa = $false
try { $bibliothekDa = [bool](Test-Path -LiteralPath $bibliothek -PathType Leaf) } catch { $bibliothekDa = $false }
if (-not $bibliothekDa) { Stop-Unpruefbar "patch-operationen.ps1 fehlt neben dem Skript ($bibliothek)" }
. $bibliothek

$operationen = @('set', 'setattribute', 'append', 'prepend', 'insertAfter', 'insertBefore', 'remove', 'removeattribute', 'csv')
$dokumentArt = [System.Xml.XmlNodeType]::Document

function Get-Innerste {
    param($Ausnahme)
    while ($Ausnahme.InnerException) { $Ausnahme = $Ausnahme.InnerException }
    return (($Ausnahme.Message -replace '\s+', ' ').Trim())
}

# Test-Path und Resolve-Path WERFEN bei einem Pfad mit unzulaessigen Zeichen. Das ist
# "gibt es nicht", keine Ausnahme.
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
    try { return (Resolve-Path -LiteralPath $Pfad).ProviderPath.TrimEnd('\') } catch { return $null }
}

function Read-Xml {
    # Regel 8: ohne DTD, ohne Aufloesen fremder Verweise. Ein <!DOCTYPE wirft hier und ist
    # damit "nicht lesbar".
    param([string]$Pfad, [string]$Rolle)
    $einstellung = New-Object System.Xml.XmlReaderSettings
    $einstellung.DtdProcessing = [System.Xml.DtdProcessing]::Prohibit
    $einstellung.XmlResolver = $null
    $doc = New-Object System.Xml.XmlDocument
    $doc.XmlResolver = $null
    $text = $null
    $leser = $null
    try {
        $text = New-Object System.IO.StringReader -ArgumentList ([IO.File]::ReadAllText($Pfad))
        $leser = [System.Xml.XmlReader]::Create([System.IO.TextReader]$text, $einstellung)
        $doc.Load($leser)
    }
    catch { Stop-Unpruefbar "$Rolle '$Pfad' laesst sich nicht als XML lesen ($(Get-Innerste $_.Exception))" }
    finally {
        if ($null -ne $leser) { $leser.Close() }
        if ($null -ne $text) { $text.Close() }
    }
    if ($null -eq $doc.get_DocumentElement()) { Stop-Unpruefbar "$Rolle '$Pfad' hat keinen Wurzelknoten" }
    return $doc
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

function Get-ModOrdner {
    # Die Unterordner mit ModInfo.xml, wenn kein Parameter sie nennt.
    param([string]$Eltern, [string]$Rolle)
    if (-not (Test-Ordner $Eltern)) { Stop-Unpruefbar "den Ordner '$Eltern' gibt es nicht ($Rolle)" }
    $liste = New-Object System.Collections.Generic.List[string]
    foreach ($ordner in @(Get-ChildItem -LiteralPath $Eltern -Directory)) {
        if (Test-Datei (Join-Path $ordner.FullName 'ModInfo.xml')) { $liste.Add($ordner.FullName) }
    }
    if ($liste.Count -eq 0) { Stop-Unpruefbar "unter '$Eltern' liegt kein Ordner mit ModInfo.xml ($Rolle)" }
    return $liste.ToArray()
}

function Read-Mod {
    # Ein Mod-Ordner: Name aus ModInfo.xml, XML-Dateien unter Config (Pfad relativ zu
    # Config -> voller Pfad), die Sprachdatei, falls es eine gibt.
    param([string]$Pfad, [string]$Rolle)
    if (-not (Test-Ordner $Pfad)) { Stop-Unpruefbar "$Rolle '$Pfad' ist kein Ordner" }
    $voll = Get-Voll $Pfad
    if (-not $voll) { Stop-Unpruefbar "$Rolle '$Pfad' laesst sich nicht aufloesen" }
    $modInfo = Join-Path $voll 'ModInfo.xml'
    if (-not (Test-Datei $modInfo)) { Stop-Unpruefbar "$Rolle '$voll' hat keine ModInfo.xml direkt im Ordner" }
    $doc = Read-Xml $modInfo 'die ModInfo.xml'
    $name = ''
    foreach ($knoten in $doc.SelectNodes('//Name')) {
        if ($knoten.get_NodeType() -ne $element) { continue }
        $name = $knoten.GetAttribute('value').Trim()
        break
    }
    if (-not $name) { Stop-Unpruefbar "die ModInfo.xml '$modInfo' nennt keinen Namen (<Name value=...>)" }
    $dateien = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' ([StringComparer]::OrdinalIgnoreCase)
    $sprachdatei = $null
    $config = Join-Path $voll 'Config'
    if (Test-Ordner $config) {
        foreach ($datei in @(Get-ChildItem -LiteralPath $config -Recurse -File)) {
            if ($datei.FullName -match '\\\.relay\\') { continue }
            if (-not [string]::Equals($datei.Extension, '.xml', [System.StringComparison]::OrdinalIgnoreCase)) { continue }
            $dateien[$datei.FullName.Substring($config.Length + 1)] = $datei.FullName
        }
        $kandidat = Join-Path $config 'Localization.csv'
        if (Test-Datei $kandidat) { $sprachdatei = $kandidat }
    }
    return @{ Ordner = $voll; Blatt = [IO.Path]::GetFileName($voll); Name = $name; Dateien = $dateien; Sprachdatei = $sprachdatei }
}

if ($PSBoundParameters.ContainsKey('Unsere')) { $unsereOrdner = @($Unsere) }
else { $unsereOrdner = @(Get-ModOrdner (Join-Path $repoRoot 'mod') 'unsere Modlets') }
if ($unsereOrdner.Count -eq 0) { Stop-Unpruefbar '-Unsere nennt keinen Ordner' }
if ($PSBoundParameters.ContainsKey('Fremd')) { $fremdOrdner = @($Fremd) }
else { $fremdOrdner = @(Get-ModOrdner (Join-Path $repoRoot 'GameRefs\ui-mods') 'fremde Mods; -Fremd nennt sie sonst') }
if ($fremdOrdner.Count -eq 0) { Stop-Unpruefbar '-Fremd nennt keinen Ordner' }

# Unsere Modlets in der Reihenfolge ihrer Ordnernamen (Regel 1), Zeichen fuer Zeichen.
$unsereRoh = New-Object System.Collections.Generic.List[object]
foreach ($ordner in $unsereOrdner) { $unsereRoh.Add((Read-Mod $ordner 'das Modlet')) }
$schluessel = New-Object string[] $unsereRoh.Count
$werte = New-Object object[] $unsereRoh.Count
for ($i = 0; $i -lt $unsereRoh.Count; $i++) { $schluessel[$i] = $unsereRoh[$i].Blatt; $werte[$i] = $unsereRoh[$i] }
[Array]::Sort($schluessel, $werte, [StringComparer]::Ordinal)
$unsereMods = $werte

$unsereNamen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
foreach ($mod in $unsereMods) { [void]$unsereNamen.Add($mod.Name) }

function Test-Gegenstueck {
    param([string]$Rel)
    return (Test-Datei ([IO.Path]::Combine($Vanilla, $Rel)))
}

$unsereDateien = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($mod in $unsereMods) {
    foreach ($rel in $mod.Dateien.Keys) { if (Test-Gegenstueck $rel) { [void]$unsereDateien.Add($rel) } }
}
if ($unsereDateien.Count -eq 0) { Stop-Unpruefbar 'unsere Modlets haben keine einzige XML-Patch-Datei mit Vanilla-Gegenstueck' }

# ------------------------------------------------------------------ Dokumente
$vanillaDocs = @{}
$patchDocs = @{}

function Get-Frisch {
    # Eine unveraenderte Kopie der Vanilla-Datei.
    param([string]$Rel)
    $key = $Rel.ToLowerInvariant()
    if (-not $script:vanillaDocs.ContainsKey($key)) {
        $script:vanillaDocs[$key] = Read-Xml ([IO.Path]::Combine($Vanilla, $Rel)) 'die Vanilla-Datei'
    }
    return $script:vanillaDocs[$key].CloneNode($true)
}

function Get-Patch {
    param([string]$Pfad)
    if (-not $script:patchDocs.ContainsKey($Pfad)) { $script:patchDocs[$Pfad] = Read-Xml $Pfad 'die Patch-Datei' }
    return $script:patchDocs[$Pfad]
}

# ------------------------------------------------------------------ NCalc (Regel 6)
$ncalcGeladen = $false
$ncalcOpt = $null
$ncalcHandler = $null

function Initialize-NCalc {
    # Wie in kette-pruefen.ps1: die Bibliothek des Spiels, mit den Optionen des Spiels
    # (1542). Geladen wird sie erst, wenn eine gerechnete Datei einen bedingten Block hat -
    # dann aber fuer JEDEN Block, bevor er angesehen wird (Invoke-Bedingt).
    if ($script:ncalcGeladen) { return }
    $pfad = $NCalc
    if (-not $pfad) {
        if (-not $env:SDTD_PATH) {
            Stop-Unpruefbar 'eine Patch-Datei hat einen bedingten Block, und SDTD_PATH ist nicht gesetzt: die NCalc.dll des Spiels wird gebraucht, um die Bedingung zu lesen (oder -NCalc <Pfad>)'
        }
        try { $pfad = [IO.Path]::Combine($env:SDTD_PATH, '7DaysToDie_Data\Managed\NCalc.dll') }
        catch { Stop-Unpruefbar 'SDTD_PATH ist kein gueltiger Pfad: die NCalc.dll des Spiels laesst sich nicht suchen' }
    }
    if (-not (Test-Datei $pfad)) {
        Stop-Unpruefbar "eine Patch-Datei hat einen bedingten Block, aber die NCalc.dll des Spiels fehlt: $pfad"
    }
    try {
        Add-Type -AssemblyName System.Xml.Linq
        $asm = [Reflection.Assembly]::LoadFrom((Resolve-Path -LiteralPath $pfad).ProviderPath)
        $script:ncalcOpt = [Enum]::ToObject($asm.GetType('NCalc.EvaluateOptions', $true), 1542)
        # mod_loaded und xpath werden nachgestellt. Jede andere Funktion bekommt kein
        # Ergebnis - NCalc wirft dann "Function not found", und die Bedingung gilt als
        # nicht gerechnet.
        # Beide bekommen GENAU EIN Argument, wie das Spiel es verlangt (Vertrag 04, Nachtrag
        # Review zu WP8.9, Regel 2). Vorher wurde nur das erste gelesen, und
        # mod_loaded('X', 'zuviel') galt als gerechnet. Wer hier wirft, macht die Bedingung
        # "nicht gerechnet" (Get-Bedingung faengt es).
        $script:ncalcHandler = [NCalc.EvaluateFunctionHandler] {
            param($name, $fa)
            if ([string]::Equals([string]$name, 'mod_loaded', [System.StringComparison]::OrdinalIgnoreCase)) {
                $zahl = @($fa.Parameters).Count
                if ($zahl -ne 1) { throw "mod_loaded(...) bekommt $zahl Argumente, das Spiel verlangt genau eines" }
                $modName = ([string]$fa.Parameters[0].Evaluate()).Trim()
                $fa.Result = [bool]$script:geladen.Contains($modName)
            }
            elseif ([string]::Equals([string]$name, 'xpath', [System.StringComparison]::OrdinalIgnoreCase)) {
                $zahl = @($fa.Parameters).Count
                if ($zahl -ne 1) { throw "xpath(...) bekommt $zahl Argumente, das Spiel verlangt genau eines" }
                $pfadText = [string]$fa.Parameters[0].Evaluate()
                $roh = [System.Xml.XPath.Extensions]::XPathEvaluate($script:zustandX, $pfadText)
                if ($roh -is [string] -or $roh -is [double] -or $roh -is [bool]) {
                    throw "xpath('$pfadText') liefert keine Knotenmenge"
                }
                $gefunden = @($roh)
                if ($gefunden.Count -eq 0) { $fa.Result = $null }
                elseif ($gefunden.Count -gt 1) { $fa.Result = 'More than one match' }
                else { $fa.Result = $gefunden[0].ToString() }
            }
        }
    }
    catch {
        Stop-Unpruefbar "die NCalc.dll des Spiels laesst sich nicht laden ($pfad): $(Get-Innerste $_.Exception)"
    }
    $script:ncalcGeladen = $true
}

# ------------------------------------------------------------------ der Lauf ueber einen Stand
# Was waehrend eines Standes gilt. Die Funktionen unten lesen und schreiben es.
$zielDoc = $null          # das Dokument, auf das gerade gepatcht wird
$zustandX = $null         # derselbe Stand als XDocument fuer xpath(); $null = veraltet
$geladen = $null          # Namen der Mods, die in diesem Stand geladen sind
$protokoll = $null        # das Protokoll der Seite, die gerade laeuft
$spuren = $null           # sammelt, was die erste Seite schreibt; $null = nicht sammeln
$waechter = $null         # die Spuren der ersten Seite, waehrend die zweite laeuft
$aktMod = ''
$aktDatei = ''
$aktReihenfolge = ''
$aktStand = ''

$befunde = New-Object System.Collections.Generic.List[object]     # Klasse, Text
$nichtGerechnet = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
$nichtFolge = New-Object System.Collections.Generic.List[string]

function Add-Befund {
    param([string]$Klasse, [string]$Text)
    $script:befunde.Add(@{ Klasse = $Klasse; Text = $Text })
}

function Add-Nicht {
    # "Nicht gerechnet" - dieselbe Stelle taucht in bis zu vier Staenden auf und wird
    # einmal gemeldet, mit den Staenden dahinter.
    # Eine Stelle ist Mod, Datei, Position und Text. Der Mod-Name steckt in $Id; die Datei
    # muss dazu, sonst fallen gleiche Meldungen am selben Platz zweier Dateien zusammen
    # (Vertrag 04, Nachtrag Review zu WP8.9, Regel 3).
    param([string]$Id, [string]$Text)
    $key = "$($script:aktDatei)|$Id|$Text"
    if (-not $script:nichtGerechnet.ContainsKey($key)) {
        $script:nichtGerechnet[$key] = @{
            Text    = "$($script:aktMod): $Text  ($($script:aktDatei))"
            Staende = New-Object System.Collections.Generic.List[string]
        }
        $script:nichtFolge.Add($key)
    }
    $eintrag = $script:nichtGerechnet[$key]
    if (-not $eintrag.Staende.Contains($script:aktStand)) { $eintrag.Staende.Add($script:aktStand) }
    $script:protokoll.Nicht++
}

function New-Protokoll {
    return @{
        Ops    = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
        Zweige = New-Object 'System.Collections.Generic.Dictionary[string,object]' ([StringComparer]::Ordinal)
        Nicht  = 0
    }
}

function Get-OpText {
    param($Operation)
    $pfadText = $Operation.GetAttribute('xpath')
    if ($pfadText.Length -gt 200) { $pfadText = $pfadText.Substring(0, 197) + '...' }
    $zusatz = ''
    if ((Test-In $Operation.get_LocalName() @('setattribute', 'removeattribute')) -and $Operation.HasAttribute('name')) { $zusatz = " name=""$($Operation.GetAttribute('name'))""" }
    return "<$($Operation.get_LocalName()) xpath=""$pfadText""$zusatz>"
}

function Get-ElementText {
    param($Knoten)
    $text = "<$($Knoten.get_LocalName())"
    if ($Knoten.HasAttribute('name')) { $text += " name=""$($Knoten.GetAttribute('name'))""" }
    return $text + '>'
}

function Test-Haengt {
    # Haengt der Knoten noch am Dokument?
    param($Knoten)
    $k = $Knoten
    while ($null -ne $k) {
        if ($k.get_NodeType() -eq $script:dokumentArt) { return $true }
        $k = $k.get_ParentNode()
    }
    return $false
}

function Add-Spur {
    # Art 'Attribut': Knoten ist das Element, Name der Attributname.
    # Art 'Element': ein eingefuegtes Element. Art 'Text': ein Element, dessen Text gesetzt wurde.
    param([string]$Art, $Knoten, [string]$Name, [string]$OpText)
    [void]$script:spuren.Add(@{ Art = $Art; Knoten = $Knoten; Name = $Name; Op = $OpText; Mod = $script:aktMod; Soll = $null; Gemeldet = $false })
}

function Get-Ist {
    # Was eine Spur JETZT zeigt: @{ Da; Wert }.
    param($Spur)
    if (-not (Test-Haengt $Spur.Knoten)) { return @{ Da = $false; Wert = $null } }
    if (Test-Gleich $Spur.Art 'Attribut') {
        if (-not $Spur.Knoten.HasAttribute($Spur.Name)) { return @{ Da = $false; Wert = $null } }
        return @{ Da = $true; Wert = $Spur.Knoten.GetAttribute($Spur.Name) }
    }
    if (Test-Gleich $Spur.Art 'Text') { return @{ Da = $true; Wert = $Spur.Knoten.get_InnerXml() } }
    return @{ Da = $true; Wert = $Spur.Knoten.get_OuterXml() }
}

function Complete-Spuren {
    # Am Ende der ersten Seite: der Stand, den sie hinterlaesst, ist das Soll. Schreibt sie
    # dieselbe Stelle zweimal, gilt die letzte Operation; was sie selbst wieder entfernt
    # hat, ist keine Spur.
    param($Liste)
    $gesehen = New-Object 'System.Collections.Generic.Dictionary[object,object]'
    $fertig = New-Object System.Collections.Generic.List[object]
    for ($i = $Liste.Count - 1; $i -ge 0; $i--) {
        $spur = $Liste[$i]
        $marke = $spur.Art
        if (Test-Gleich $spur.Art 'Attribut') { $marke = "Attribut|$($spur.Name)" }
        if (-not $gesehen.ContainsKey($spur.Knoten)) {
            $gesehen.Add($spur.Knoten, (New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)))
        }
        if (-not $gesehen[$spur.Knoten].Add($marke)) { continue }
        $ist = Get-Ist $spur
        if (-not $ist.Da) { continue }
        $spur.Soll = $ist.Wert
        $fertig.Add($spur)
    }
    $fertig.Reverse()
    return , $fertig
}

function Get-Kurzwert {
    param([string]$Wert)
    $kurz = ($Wert -replace '\s+', ' ').Trim()
    if ($kurz.Length -gt 120) { $kurz = $kurz.Substring(0, 117) + '...' }
    return $kurz
}

function Test-Waechter {
    # Nach jeder Operation der zweiten Seite: ist eine Spur der ersten anders als ihr Soll?
    # Gemeldet wird jede Spur einmal, mit der Operation, nach der sie zuerst anders war.
    param($Operation)
    foreach ($spur in $script:waechter) {
        if ($spur.Gemeldet) { continue }
        $ist = Get-Ist $spur
        if ($ist.Da -and (Test-Gleich $ist.Wert $spur.Soll)) { continue }
        $spur.Gemeldet = $true
        if (Test-Gleich $spur.Art 'Attribut') {
            $was = "Attribut '$($spur.Name)' an $(Get-ElementText $spur.Knoten)"
            if ($ist.Da) { $was += ": gesetzt '$(Get-Kurzwert $spur.Soll)', jetzt '$(Get-Kurzwert $ist.Wert)'" } else { $was += ' ist entfernt' }
        }
        elseif (Test-Gleich $spur.Art 'Text') {
            $was = "Text von $(Get-ElementText $spur.Knoten)"
            if ($ist.Da) { $was += ": gesetzt '$(Get-Kurzwert $spur.Soll)', jetzt '$(Get-Kurzwert $ist.Wert)'" } else { $was += ' ist entfernt' }
        }
        else {
            $was = "eingefuegtes Element $(Get-ElementText $spur.Knoten)"
            if ($ist.Da) { $was += ' ist geaendert' } else { $was += ' ist entfernt' }
        }
        Add-Befund 'Wirkung veraendert' "[$($script:aktReihenfolge)] $($spur.Mod) $($spur.Op): $was - zuerst nach $($script:aktMod) $(Get-OpText $Operation)  ($($script:aktDatei))"
    }
}

function Get-Bedingung {
    # Wertet eine Bedingung gegen den Stand vor dieser Operation aus.
    # @{ Ok = $true; Wert = <bool> } oder @{ Ok = $false; Grund = <Text> }.
    param([string]$Ausdruck)
    Initialize-NCalc
    if ($null -eq $script:zustandX) {
        try { $script:zustandX = [System.Xml.Linq.XDocument]::Parse($script:zielDoc.get_OuterXml()) }
        catch { return @{ Ok = $false; Grund = "der Stand laesst sich fuer xpath() nicht lesen ($(Get-Innerste $_.Exception))" } }
    }
    $ergebnis = $null
    try {
        $rechnung = New-Object NCalc.Expression -ArgumentList $Ausdruck, $script:ncalcOpt
        if ($rechnung.HasErrors()) {
            return @{ Ok = $false; Grund = "NCalc kann sie nicht lesen ($((([string]$rechnung.Error) -replace '\s+', ' ').Trim()))" }
        }
        # Das Spiel gibt jeder Bedingung die Zieldatei unter dem Namen 'xml' mit.
        $rechnung.Parameters['xml'] = $script:zustandX
        $rechnung.add_EvaluateFunction($script:ncalcHandler)
        $ergebnis = $rechnung.Evaluate()
    }
    catch { return @{ Ok = $false; Grund = "sie laesst sich nicht auswerten ($(Get-Innerste $_.Exception))" } }
    if ($ergebnis -isnot [bool]) {
        $art = 'null'
        if ($null -ne $ergebnis) { $art = $ergebnis.GetType().Name }
        return @{ Ok = $false; Grund = "sie liefert keinen Wahrheitswert, sondern $art" }
    }
    return @{ Ok = $true; Wert = [bool]$ergebnis }
}

function Invoke-Bedingt {
    # Ein <conditional>: das erste <if>, dessen Bedingung wahr ist, gewinnt, sonst <else>.
    # Ein falscher Aufbau oder eine Bedingung, die sich nicht rechnen laesst, macht den
    # ganzen Block "nicht gerechnet" - es laeuft dann kein Zweig.
    param($Block, [string]$Id)
    # Die Bibliothek des Spiels zuerst, fuer JEDEN Block - auch einen nur mit <else> und
    # einen falsch gebauten (Vertrag 04, Nachtrag Review zu WP8.9, Regel 1). Vorher lud erst
    # das Auswerten eines <if> sie, und ein Block ohne auswertbares <if> lief ohne sie durch.
    Initialize-NCalc
    $zweige = New-Object System.Collections.Generic.List[object]
    $j = -1
    foreach ($kind in $Block.get_ChildNodes()) {
        if ($kind.get_NodeType() -ne $element) { continue }
        $j++
        $art = $kind.get_LocalName()
        if (-not (Test-Gleich $art 'if') -and -not (Test-Gleich $art 'else')) {
            Add-Nicht $Id "bedingter Block mit dem Kind <$art>; erlaubt sind <if cond=...> und <else>"
            return
        }
        if ((Test-Gleich $art 'if') -and -not $kind.HasAttribute('cond')) {
            Add-Nicht $Id "bedingter Block mit einem <if> ohne 'cond'"
            return
        }
        $zahl = 0
        foreach ($enkel in $kind.get_ChildNodes()) { if ($enkel.get_NodeType() -eq $element) { $zahl++ } }
        $text = '<else>'
        if (Test-Gleich $art 'if') { $text = "<if cond=""$(Get-Kurzwert $kind.GetAttribute('cond'))"">" }
        $zweige.Add(@{ Knoten = $kind; Art = $art; Id = "$Id.$j"; Text = $text; Zahl = $zahl })
    }
    if ($zweige.Count -eq 0) {
        Add-Nicht $Id 'bedingter Block ohne <if> und ohne <else>'
        return
    }
    $gewinner = $null
    foreach ($zweig in $zweige) {
        if (Test-Gleich $zweig.Art 'else') { $gewinner = $zweig; break }
        $bedingung = $zweig.Knoten.GetAttribute('cond')
        $gerechnet = Get-Bedingung $bedingung
        if (-not $gerechnet.Ok) {
            Add-Nicht $Id "Bedingung ""$(Get-Kurzwert $bedingung)"": $($gerechnet.Grund)"
            return
        }
        if ($gerechnet.Wert) { $gewinner = $zweig; break }
    }
    foreach ($zweig in $zweige) {
        $lief = ($null -ne $gewinner) -and [object]::ReferenceEquals($zweig, $gewinner)
        $script:protokoll.Zweige[$zweig.Id] = @{ Lief = $lief; Text = $zweig.Text; Zahl = $zweig.Zahl; Mod = $script:aktMod }
    }
    if ($null -ne $gewinner) { Invoke-Ebene $gewinner.Knoten "$($gewinner.Id)." }
}

function Invoke-Ebene {
    # Die Kinder des Wurzelknotens einer Patch-Datei oder eines gewinnenden Zweigs, der
    # Reihe nach, jede Operation gegen den Stand, den die davor hinterlassen haben.
    param($Behaelter, [string]$Praefix)
    $i = -1
    foreach ($operation in $Behaelter.get_ChildNodes()) {
        if ($operation.get_NodeType() -ne $element) { continue }
        $i++
        $id = "$Praefix$i"
        $name = $operation.get_LocalName()
        if (Test-Gleich $name 'conditional') { Invoke-Bedingt $operation $id; continue }
        if (Test-Gleich $name 'include') { Add-Nicht $id '<include> wird nicht gerechnet'; continue }
        if (-not (Test-In $name $script:operationen)) { Add-Nicht $id "unbekannte Patch-Operation <$name>"; continue }
        if (-not $operation.HasAttribute('xpath') -or -not $operation.GetAttribute('xpath')) {
            Add-Nicht $id "<$name> ohne xpath"
            continue
        }
        $xpath = $operation.GetAttribute('xpath')
        $treffer = New-Object System.Collections.Generic.List[object]
        try {
            # Erst ALLE Treffer einsammeln, dann aendern.
            foreach ($knoten in $script:zielDoc.SelectNodes($xpath)) { $treffer.Add($knoten) }
        }
        catch {
            Add-Nicht $id "XPath laesst sich nicht auswerten: $(Get-OpText $operation) ($(Get-Innerste $_.Exception))"
            continue
        }
        $opText = Get-OpText $operation
        if ($treffer.Count -eq 0) {
            $script:protokoll.Ops[$id] = @{ Status = 'ohne'; Treffer = 0; Text = $opText; Mod = $script:aktMod }
            continue
        }
        # Erst pruefen, dann aendern: ist EIN Treffer nicht rechenbar, bleibt die ganze
        # Operation weg.
        $hindernis = Get-Hindernis $name $treffer
        if ($null -ne $hindernis) {
            Add-Nicht $id "$opText trifft $hindernis"
            continue
        }
        foreach ($knoten in $treffer) {
            $eingefuegt = $null
            $besitzer = $null
            $attributName = ''
            $istAttribut = ($knoten.get_NodeType() -eq $attributArt)
            if ($null -ne $script:spuren) {
                $eingefuegt = New-Object System.Collections.ArrayList
                if ($istAttribut) { $besitzer = $knoten.get_OwnerElement(); $attributName = $knoten.get_Name() }
            }
            Invoke-Operation $name $operation $knoten $script:zielDoc $eingefuegt
            if ($null -eq $script:spuren) { continue }
            if (Test-Gleich $name 'setattribute') { Add-Spur 'Attribut' $knoten $operation.GetAttribute('name') $opText }
            elseif ($istAttribut) { Add-Spur 'Attribut' $besitzer $attributName $opText }
            elseif (Test-Gleich $name 'set') { Add-Spur 'Text' $knoten '' $opText }
            foreach ($neu in $eingefuegt) { Add-Spur 'Element' $neu '' $opText }
        }
        $script:zustandX = $null
        $script:protokoll.Ops[$id] = @{ Status = 'ok'; Treffer = $treffer.Count; Text = $opText; Mod = $script:aktMod }
        if ($null -ne $script:waechter) { Test-Waechter $operation }
    }
}

function Invoke-Seite {
    # Alle Mods einer Seite, die diese Datei patchen, in ihrer Reihenfolge.
    param($Mods, [string]$Rel)
    $lauf = New-Protokoll
    $script:protokoll = $lauf
    foreach ($mod in $Mods) {
        if (-not $mod.Dateien.ContainsKey($Rel)) { continue }
        $script:aktMod = $mod.Name
        $patch = Get-Patch $mod.Dateien[$Rel]
        Invoke-Ebene $patch.get_DocumentElement() "$($mod.Name)|"
    }
    return $lauf
}

function Invoke-Stand {
    # Ein Stand: erst die Mods von $Erste, dann die von $Zweite, auf die frische
    # Vanilla-Datei. Mit $Zweite wird verfolgt, was $Erste schreibt (Wirkung veraendert).
    param([string]$Rel, $Erste, $Zweite, $Geladen, [string]$Stand, [string]$Reihenfolge)
    $script:zielDoc = Get-Frisch $Rel
    $script:zustandX = $null
    $script:geladen = $Geladen
    $script:aktDatei = $Rel
    $script:aktStand = $Stand
    $script:aktReihenfolge = $Reihenfolge
    $script:waechter = $null
    $script:spuren = $null
    if ($null -ne $Zweite) { $script:spuren = New-Object System.Collections.ArrayList }
    $erstesProtokoll = Invoke-Seite $Erste $Rel
    $zweitesProtokoll = $null
    if ($null -ne $Zweite) {
        $script:waechter = Complete-Spuren $script:spuren
        $script:spuren = $null
        $zweitesProtokoll = Invoke-Seite $Zweite $Rel
        $script:waechter = $null
    }
    return @{ Erste = $erstesProtokoll; Zweite = $zweitesProtokoll }
}

function Compare-Protokoll {
    # Regel 4: Ziel verloren und Zweig wechselt - eine Seite allein gegen dieselbe Seite
    # in der Kombination.
    param($Allein, $Kombi, [string]$Reihenfolge, [string]$Rel)
    foreach ($id in $Allein.Ops.Keys) {
        if (-not $Kombi.Ops.ContainsKey($id)) { continue }
        $a = $Allein.Ops[$id]
        $k = $Kombi.Ops[$id]
        if ($a.Treffer -gt 0 -and (Test-Gleich $k.Status 'ohne')) {
            Add-Befund 'Ziel verloren' "[$Reihenfolge] $($a.Mod) $($a.Text) trifft allein $($a.Treffer) Knoten, hier keinen  ($Rel)"
        }
    }
    foreach ($id in $Allein.Zweige.Keys) {
        if (-not $Kombi.Zweige.ContainsKey($id)) { continue }
        $a = $Allein.Zweige[$id]
        $k = $Kombi.Zweige[$id]
        if ($a.Lief -eq $k.Lief) { continue }
        $wie = 'laeuft allein nicht, hier schon'
        if ($a.Lief) { $wie = 'laeuft allein, hier nicht' }
        Add-Befund 'Zweig wechselt' "[$Reihenfolge] $($a.Mod) $($a.Text) mit $($a.Zahl) Operationen $wie  ($Rel)"
    }
}

function Read-Sprachschluessel {
    # Die Schluesselspalte einer Sprachdatei, oder $null mit dem Grund in $script:sprachGrund.
    param([string]$Pfad)
    $script:sprachGrund = ''
    try { $zeilen = @(Import-Csv -LiteralPath $Pfad -Encoding UTF8) }
    catch { $script:sprachGrund = Get-Innerste $_.Exception; return $null }
    $menge = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    if ($zeilen.Count -eq 0) { return , $menge }
    $spalte = $null
    foreach ($eigenschaft in $zeilen[0].PSObject.Properties) {
        if ([string]::Equals($eigenschaft.Name, 'Key', [System.StringComparison]::OrdinalIgnoreCase)) { $spalte = $eigenschaft.Name }
    }
    if ($null -eq $spalte) { $script:sprachGrund = "keine Spalte 'Key'"; return $null }
    foreach ($zeile in $zeilen) {
        $wert = [string]$zeile.PSObject.Properties[$spalte].Value
        if ($wert) { $wert = $wert.Trim() }
        if ($wert) { [void]$menge.Add($wert) }
    }
    return , $menge
}

# Unsere Sprachschluessel, einmal gelesen. Eine eigene Sprachdatei, die sich nicht lesen
# laesst, ist ein Ausfall und kein Befund ueber die fremde Mod.
$unsereSchluessel = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
$unsereSprachdateien = 0
foreach ($mod in $unsereMods) {
    if (-not $mod.Sprachdatei) { continue }
    $unsereSprachdateien++
    $gelesen = Read-Sprachschluessel $mod.Sprachdatei
    if ($null -eq $gelesen) { Stop-Unpruefbar "unsere Sprachdatei '$($mod.Sprachdatei)' laesst sich nicht lesen ($($script:sprachGrund))" }
    foreach ($k in $gelesen) { [void]$unsereSchluessel.Add($k) }
}

# ------------------------------------------------------------------ je fremder Mod
$klassen = @('Ziel verloren', 'Zweig wechselt', 'Wirkung veraendert', 'nicht gerechnet', 'gemeinsamer Sprachschluessel')
$gesamt = 0
$textA = 'wir, dann die fremde Mod'
$textB = 'die fremde Mod, dann wir'

foreach ($ordner in $fremdOrdner) {
    $fremdMod = Read-Mod $ordner 'die fremde Mod'
    $befunde.Clear()
    $nichtGerechnet.Clear()
    $nichtFolge.Clear()

    $mit = New-Object System.Collections.Generic.List[string]
    $ohne = New-Object System.Collections.Generic.List[string]
    foreach ($rel in $fremdMod.Dateien.Keys) { if (Test-Gegenstueck $rel) { $mit.Add($rel) } else { $ohne.Add($rel) } }
    if ($mit.Count -eq 0) {
        Stop-Unpruefbar "die fremde Mod '$($fremdMod.Name)' ($($fremdMod.Ordner)) hat keine einzige XML-Patch-Datei mit Vanilla-Gegenstueck"
    }
    $gemeinsam = New-Object System.Collections.Generic.List[string]
    foreach ($rel in $mit) { if ($unsereDateien.Contains($rel)) { $gemeinsam.Add($rel) } }

    # Regel 3: welche Reihenfolge ergeben die Ordnernamen? Der Lader sortiert sie; ob er
    # Zeichen fuer Zeichen oder sprachabhaengig vergleicht, ist nicht gelesen - erwartet
    # ist eine Reihenfolge nur, wenn beide Vergleiche dasselbe sagen.
    $davor = 0
    $danach = 0
    $unklar = $false
    foreach ($mod in $unsereMods) {
        $zeichen = [math]::Sign([string]::CompareOrdinal($mod.Blatt, $fremdMod.Blatt))
        $sprache = [math]::Sign([string]::Compare($mod.Blatt, $fremdMod.Blatt, [System.Globalization.CultureInfo]::InvariantCulture, [System.Globalization.CompareOptions]::None))
        if ($zeichen -ne $sprache -or $zeichen -eq 0) { $unklar = $true }
        elseif ($zeichen -lt 0) { $davor++ }
        else { $danach++ }
    }
    $markeA = ''
    $markeB = ''
    $erwartet = 'keine - die Ordnernamen sortieren nicht eindeutig'
    if (-not $unklar) {
        if ($davor -eq $unsereMods.Count) { $erwartet = $textA; $markeA = ', erwartet'; $markeB = ', umgekehrt' }
        elseif ($danach -eq $unsereMods.Count) { $erwartet = $textB; $markeB = ', erwartet'; $markeA = ', umgekehrt' }
        else { $erwartet = 'keine - die fremde Mod laege zwischen unseren Modlets' }
    }
    $reihenfolgeA = "$textA$markeA"
    $reihenfolgeB = "$textB$markeB"

    $alleNamen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    foreach ($n in $unsereNamen) { [void]$alleNamen.Add($n) }
    [void]$alleNamen.Add($fremdMod.Name)
    $nurFremd = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::Ordinal)
    [void]$nurFremd.Add($fremdMod.Name)

    $fremdOps = 0
    $unsereOps = 0
    $fremdOhne = New-Object System.Collections.Generic.List[string]
    $unsereOhne = New-Object System.Collections.Generic.List[string]
    $fremdListe = @($fremdMod)

    foreach ($rel in $mit) {
        $fremdAllein = (Invoke-Stand $rel $fremdListe $null $nurFremd 'die fremde Mod allein' '').Erste
        foreach ($id in $fremdAllein.Ops.Keys) {
            $fremdOps++
            $op = $fremdAllein.Ops[$id]
            if (Test-Gleich $op.Status 'ohne') { $fremdOhne.Add("$($op.Text)  ($rel)") }
        }
        if (-not $unsereDateien.Contains($rel)) { continue }

        $wirAllein = (Invoke-Stand $rel $unsereMods $null $unsereNamen 'wir allein' '').Erste
        foreach ($id in $wirAllein.Ops.Keys) {
            $unsereOps++
            $op = $wirAllein.Ops[$id]
            if (Test-Gleich $op.Status 'ohne') { $unsereOhne.Add("$($op.Mod) $($op.Text)  ($rel)") }
        }
        $standA = Invoke-Stand $rel $unsereMods $fremdListe $alleNamen $textA $reihenfolgeA
        Compare-Protokoll $wirAllein $standA.Erste $reihenfolgeA $rel
        Compare-Protokoll $fremdAllein $standA.Zweite $reihenfolgeA $rel
        $standB = Invoke-Stand $rel $fremdListe $unsereMods $alleNamen $textB $reihenfolgeB
        Compare-Protokoll $fremdAllein $standB.Erste $reihenfolgeB $rel
        Compare-Protokoll $wirAllein $standB.Zweite $reihenfolgeB $rel
    }
    if ($fremdOps -eq 0 -and $nichtGerechnet.Count -eq 0) {
        Stop-Unpruefbar "die fremde Mod '$($fremdMod.Name)' hat in $($mit.Count) Dateien keine einzige Patch-Operation"
    }
    foreach ($key in $nichtFolge) {
        $eintrag = $nichtGerechnet[$key]
        Add-Befund 'nicht gerechnet' "$($eintrag.Text) - Stand: $($eintrag.Staende -join '; ')"
    }

    # Gemeinsame Sprachschluessel (Regel 4, letzte Klasse).
    $sprachZeile = 'die fremde Mod hat keine Config\Localization.csv'
    if ($fremdMod.Sprachdatei) {
        $fremdSchluessel = Read-Sprachschluessel $fremdMod.Sprachdatei
        if ($null -eq $fremdSchluessel) {
            Add-Befund 'nicht gerechnet' "$($fremdMod.Name): die Sprachdatei laesst sich nicht lesen ($($script:sprachGrund)); gemeinsame Schluessel sind nicht verglichen  (Localization.csv)"
            $sprachZeile = 'die Sprachdatei der fremden Mod laesst sich nicht lesen'
        }
        else {
            $gleiche = New-Object System.Collections.Generic.List[string]
            foreach ($k in $fremdSchluessel) { if ($unsereSchluessel.Contains($k)) { $gleiche.Add($k) } }
            $gleiche.Sort([StringComparer]::Ordinal)
            foreach ($k in $gleiche) {
                Add-Befund 'gemeinsamer Sprachschluessel' "'$k' steht in unserer Sprachdatei und in der von $($fremdMod.Name); es gilt der Text der spaeter geladenen Mod  (Localization.csv)"
            }
            $sprachZeile = "unsere Schluessel: $($unsereSchluessel.Count) aus $unsereSprachdateien Dateien, die der fremden Mod: $($fremdSchluessel.Count), gemeinsam: $($gleiche.Count)"
        }
    }

    Write-Output "== Vertraeglichkeit: unsere $($unsereMods.Count) Modlets und '$($fremdMod.Name)' (Ordner $($fremdMod.Blatt)) =="
    Write-Output "  XML-Dateien der fremden Mod unter Config: $($fremdMod.Dateien.Count) (mit Vanilla-Gegenstueck: $($mit.Count), ohne: $($ohne.Count))"
    foreach ($rel in $ohne) { Write-Output "    ohne Vanilla-Gegenstueck, das Spiel laedt daraus nichts: $rel" }
    Write-Output "  gemeinsame Dateien: $($gemeinsam.Count)"
    foreach ($rel in $gemeinsam) { Write-Output "    $rel" }
    Write-Output "  erwartete Reihenfolge: $erwartet"
    Write-Output "  Operationen der fremden Mod allein: $fremdOps, davon ohne Treffer: $($fremdOhne.Count)"
    foreach ($zeile in $fremdOhne) { Write-Output "    trifft allein nichts: $zeile" }
    Write-Output "  unsere Operationen allein, in den gemeinsamen Dateien: $unsereOps, davon ohne Treffer: $($unsereOhne.Count)"
    foreach ($zeile in $unsereOhne) { Write-Output "    trifft allein nichts: $zeile" }
    Write-Output "  Sprachschluessel: $sprachZeile"
    if ($gemeinsam.Count -eq 0) {
        Write-Output '  Keine gemeinsame XML-Datei: die Patches der beiden Seiten koennen einander in keiner Datei treffen.'
    }
    $zahlen = New-Object System.Collections.Generic.List[string]
    foreach ($klasse in $klassen) {
        $zahl = 0
        foreach ($befund in $befunde) { if (Test-Gleich $befund.Klasse $klasse) { $zahl++ } }
        $zahlen.Add("$klasse $zahl")
        if ($zahl -eq 0) { continue }
        Write-Output "  -- $klasse ($zahl) --"
        foreach ($befund in $befunde) { if (Test-Gleich $befund.Klasse $klasse) { Write-Output "    $($befund.Text)" } }
    }
    $urteil = 'GREEN'
    if ($befunde.Count -gt 0) { $urteil = 'RED' }
    Write-Output "  == '$($fremdMod.Name)': $($befunde.Count) Befunde ($($zahlen -join ', ')) -> $urteil =="
    Write-Output ''
    $gesamt += $befunde.Count
}

Write-Output '  Grenzen:'
Write-Output '    - Nur XML. Was eine DLL der fremden Mod zur Laufzeit aendert, sieht diese Pruefung nicht.'
Write-Output '    - Nur dieselbe Datei. Ein Stil, eine Vorlage oder ein Steuerelement aus einer anderen'
Write-Output '      Datei, auf die ein Fenster zeigt, bleibt ungesehen - ebenso, was sich am Bildschirm verdeckt.'
Write-Output '    - Die Operationen sind nachgebaut, nicht im Spiel gemessen. Diese Pruefung ersetzt keinen Lauf.'
Write-Output ''
if ($gesamt -gt 0) {
    Write-Output "== Ergebnis: $gesamt Befunde -> RED =="
    exit 1
}
Write-Output '== Ergebnis: 0 Befunde -> GREEN =='
exit 0
