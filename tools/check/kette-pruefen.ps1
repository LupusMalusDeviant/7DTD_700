<#
.SYNOPSIS
    Loest jeden Verweis unserer eigenen Rezepte auf: Ergebnis, Zutaten, Werkzeug.

.DESCRIPTION
    WARUM ES DIESES SKRIPT GIBT. 'mod700check recipes' prueft den Rezeptgraphen - aber es
    prueft eine QUELLE, und unsere Modlets sind in keiner Quelle, die ohne Spielstart zu
    haben ist. Der ConfigsDump ist die gemergte Config des Spiels; bis WP3.6 ist der
    vorhandene Dump vom 7. Juli und kennt unsere Dateien nicht. 'recipes' gruen heisst
    darum heute: VANILLA hat keine Sackgasse. Ueber unsere Kette sagt es nichts.

    Dieses Skript schliesst die kleinere Haelfte der Luecke: es liest unsere
    Rezept-Patches, sammelt jeden Verweis daraus und sucht ihn in Vanillas items.xml und
    blocks.xml sowie in unseren eigenen items.xml. Ein Tippfehler in einer Zutat - der
    wahrscheinlichste Fehler in handgeschriebenen Rezepten - faellt damit auf, bevor das
    Spiel ihn still verschluckt.

    WAS ES NICHT PRUEFT, und das ist die groessere Haelfte: ob die Kette von T0 aus
    ERREICHBAR ist, ob ein Zyklus darin steckt, ob der XML-Patcher des Spiels unsere
    XPaths trifft, und ob ein Rezept, das wir entfernen, woanders gebraucht wird. Das
    kann erst ein Lauf gegen einen frischen ConfigsDump (WP3.6).

.NOTES
    ACHTUNG, Kodierung: UTF-8 MIT BOM, sonst liest Windows PowerShell 5.1 die Datei als
    ANSI.
#>
[CmdletBinding()]
param(
    # Ordner mit unseren Rezept-Patches; je Datei ein <config> mit <append>/<remove>.
    [string[]]$Rezepte,
    # Ordner mit unseren Gegenstands-Patches.
    [string[]]$Gegenstaende,
    # Ordner mit unseren Block-Patches.
    [string[]]$Bloecke,
    # Alle unsere Patch-Dateien, fuer die XPath-Pruefung. Ohne Angabe gefunden unter mod/.
    # Als Parameter, damit die Gegenproben dieselbe Pruefung an Testdaten fahren koennen:
    # ein Pruefer, der seine Dateien selbst sucht, laesst sich nicht gegenpruefen.
    [string[]]$Patches,
    # Vanilla Data/Config. Ohne Angabe aus SDTD_PATH.
    [string]$Vanilla,
    # Die NCalc.dll des Spiels, mit der die Bedingungen bedingter Bloecke gelesen werden
    # (seit 2026-11-22). Ohne Angabe <SDTD_PATH>\7DaysToDie_Data\Managed\NCalc.dll.
    # Gebraucht nur, wenn eine Patch-Datei einen <conditional> hat.
    [string]$NCalc
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

if (-not $Vanilla) {
    if (-not $env:SDTD_PATH) {
        # Ausgang 2 statt 0 (geaendert 2026-11-20 nach dem Review-Befund). Vorher stand hier
        # "uebersprungen, KEIN GRUEN" und dann 'exit 0' - der Text sagte das Richtige, der
        # Ausgang das Gegenteil, und check-all.ps1 liest den Ausgang. Ohne SDTD_PATH, aber
        # mit einem ConfigsDump, meldete der Prueflauf GRUEN, ohne einen einzigen XPath
        # geprueft zu haben.
        Write-Output 'kette-pruefen: SDTD_PATH ist nicht gesetzt und -Vanilla nicht angegeben - NICHT GEPRUEFT.'
        Write-Output ''
        Write-Output '== Ergebnis: nicht pruefbar -> RED =='
        exit 2
    }
    # [IO.Path]::Combine und nicht Join-Path (geaendert 2026-11-20, drittes Review):
    # Join-Path wirft in Windows PowerShell 5.1 eine Ausnahme, wenn das LAUFWERK im Pfad
    # nicht eingehaengt ist - noch vor jeder Pruefung hier, und check-all.ps1 endete damit
    # wieder ohne Ergebniszeile.
    #
    # Und selbst Combine wirft, wenn der Pfad Zeichen traegt, die kein Pfad haben darf -
    # etwa woertliche Anfuehrungszeichen, wie sie ein 'set SDTD_PATH="C:\..."' in cmd
    # hinterlaesst (viertes Review, 2026-11-21). Das ist "nicht pruefbar", keine Ausnahme.
    try { $Vanilla = [IO.Path]::Combine($env:SDTD_PATH, 'Data\Config') }
    catch {
        Write-Output "kette-pruefen: SDTD_PATH ist kein gueltiger Pfad ($($env:SDTD_PATH)) - NICHT GEPRUEFT."
        Write-Output ''
        Write-Output '== Ergebnis: nicht pruefbar -> RED =='
        exit 2
    }
}

function Stop-Unpruefbar {
    param([string]$Grund)
    Write-Output "kette-pruefen: $Grund - NICHT GEPRUEFT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

# EINE STELLE, AN DER XML GELESEN WIRD (2026-11-21, fuenftes Review). Vorher stand
# '[xml](Get-Content ...)' an acht Stellen, und nur eine davon fing kaputtes XML ab: dieselbe
# Datei als -Bloecke UND -Patches fiel an der frueheren Stelle mit einer Ausnahme heraus.
# Zwei Faelle, zwei Ausgaenge (Vertrag 04):
#   - die Datei laesst sich nicht LESEN (gesperrt, kein Zugriff)  -> .Unlesbar, der Aufrufer
#     beendet mit Exit 2. Ein Eingang, den es nicht gibt, ist "nicht pruefbar", kein Befund.
#   - die Datei ist kein gueltiges XML                            -> EINE rote Zeile, Exit 1.
#     Bei einer VANILLA-Datei ist auch das .Unlesbar: gegen sie laesst sich nichts pruefen.
# Die Funktion schreibt nichts und beendet nichts: sie wird in Zuweisungen aufgerufen, und
# dort ginge ein Write-Output im Rueckgabewert unter.
# Gelesen wird mit ReadAllText (UTF-8, BOM erkannt). '[xml](Get-Content -Raw)' las unter
# Windows PowerShell 5.1 eine Datei ohne BOM in der ANSI-Codepage.
#
# DER ZWISCHENSPEICHER HAELT, WAS GELESEN WURDE - NICHT, WAS ES BEDEUTET (sechstes Review).
# Zuerst lag hier das fertige Urteil je Pfad. Dieselbe kaputte Datei, erst als eigene
# Block-Datei gelesen und dann als Vanilla-Datei, bekam damit das Urteil der ERSTEN Rolle:
# "Befund, Exit 1" statt "nicht pruefbar, Exit 2". Jetzt steht im Speicher nur der Text,
# das Dokument und der Fehler; was daraus folgt, entscheidet jeder Aufruf fuer seine Rolle.
$unresolved = @()
$dateiGelesen = @{}

function Get-Innerste {
    param($Ausnahme)
    # Die aeussere Meldung nennt nur den Methodenaufruf; die innerste Zeile und Stelle.
    while ($Ausnahme.InnerException) { $Ausnahme = $Ausnahme.InnerException }
    return $Ausnahme.Message
}

function Read-Datei {
    # Liest den TEXT einer Datei, einmal. Gibt den Eintrag des Speichers zurueck:
    #   Voll, Text, Lesefehler  - sofort
    #   Doc, XmlFehler, Zerlegt - erst, wenn Read-XmlDatei das Dokument braucht
    #   Gemeldet                - ob die rote Zeile "kein gueltiges XML" schon steht
    param([string]$Pfad)
    try { $voll = (Resolve-Path -LiteralPath $Pfad).ProviderPath }
    catch { return @{ Voll = $Pfad; Text = $null; Lesefehler = "die Datei '$Pfad' laesst sich nicht finden ($(Get-Innerste $_.Exception))" } }
    if ($script:dateiGelesen.ContainsKey($voll)) { return $script:dateiGelesen[$voll] }
    $eintrag = @{ Voll = $voll; Text = $null; Lesefehler = $null; Doc = $null; XmlFehler = $null; Zerlegt = $false; Gemeldet = $false }
    try { $eintrag.Text = [IO.File]::ReadAllText($voll) }
    catch { $eintrag.Lesefehler = "die Datei '$voll' laesst sich nicht lesen ($(Get-Innerste $_.Exception))" }
    $script:dateiGelesen[$voll] = $eintrag
    return $eintrag
}

function Read-XmlDatei {
    param([string]$Pfad, [switch]$Vanilla)
    $eintrag = Read-Datei $Pfad
    if ($eintrag.Lesefehler) { return @{ Doc = $null; Unlesbar = $eintrag.Lesefehler } }
    if (-not $eintrag.Zerlegt) {
        $doc = New-Object System.Xml.XmlDocument
        try {
            $doc.LoadXml($eintrag.Text)
            $eintrag.Doc = $doc
        }
        catch { $eintrag.XmlFehler = Get-Innerste $_.Exception }
        $eintrag.Zerlegt = $true
    }
    if ($null -ne $eintrag.Doc) { return @{ Doc = $eintrag.Doc; Unlesbar = $null } }
    if ($Vanilla) {
        return @{ Doc = $null; Unlesbar = "die Vanilla-Datei '$($eintrag.Voll)' ist kein gueltiges XML ($($eintrag.XmlFehler))" }
    }
    if (-not $eintrag.Gemeldet) {
        # Die letzten drei Glieder des Pfads: 'blocks.xml' allein gibt es in fuenf Modlets.
        $kurz = ($eintrag.Voll.Split('\') | Select-Object -Last 3) -join '\'
        $script:unresolved += "Datei ist kein gueltiges XML: $kurz  ($($eintrag.XmlFehler))"
        $eintrag.Gemeldet = $true
    }
    return @{ Doc = $null; Unlesbar = $null }
}

function Get-Kennungen {
    # Die Kennungen einer Datei, aus ihrem TEXT gelesen (nicht als XML: Vanillas blocks.xml
    # traegt ueber 6.000 Bloecke, und fuer die Liste der Namen reicht das Muster). Bis zum
    # sechsten Review stand hier 'Select-String -Path' ohne Abfang: eine Vanilla-Datei, die
    # sich nicht lesen liess, warf mitten im Lauf. Jetzt geht auch dieser Leser durch
    # Read-Datei, und der Aufrufer beendet bei einem Lesefehler mit Exit 2.
    # Gross-/Kleinschreibung wie bei Select-String: nicht unterschieden.
    #
    # ZEILE FUER ZEILE, wie Select-String es tat (siebtes Review). Der erste Umbau liess das
    # Muster ueber den ganzen Text laufen, und '[^"]+' schliesst Zeilenumbrueche ein: ein
    # Kommentar mit einem angefangenen '<item name="' reichte dann bis zum Anfuehrungszeichen
    # der naechsten ECHTEN Definition und verschluckte sie - gueltige Verweise wurden rot.
    # Das Muster wird darum je Zeile angewandt; was es selbst enthaelt, kann die Grenze so
    # nicht mehr ueberschreiten.
    param([string]$Pfad, [string]$Muster, [int]$Gruppe)
    $eintrag = Read-Datei $Pfad
    if ($eintrag.Lesefehler) { return @{ Namen = @(); Unlesbar = $eintrag.Lesefehler } }
    $namen = New-Object System.Collections.Generic.List[string]
    $regel = New-Object System.Text.RegularExpressions.Regex($Muster, [Text.RegularExpressions.RegexOptions]::IgnoreCase)
    $leser = New-Object System.IO.StringReader($eintrag.Text)
    while ($null -ne ($zeile = $leser.ReadLine())) {
        foreach ($m in $regel.Matches($zeile)) { $namen.Add($m.Groups[$Gruppe].Value) }
    }
    return @{ Namen = $namen; Unlesbar = $null }
}

$vanillaDa = $false
try { $vanillaDa = Test-Path -LiteralPath $Vanilla -PathType Container } catch { $vanillaDa = $false }
if (-not $vanillaDa) {
    Stop-Unpruefbar "den Vanilla-Ordner '$Vanilla' gibt es nicht (zeigt SDTD_PATH auf eine Installation?)"
}

# Ein Pfad, den der Aufrufer NENNT und den es nicht gibt, ist ein Fehler des Aufrufs und
# kein leerer Ordner (geaendert 2026-11-20). Vorher uebersprang jede Schleife weiter unten
# eine fehlende Datei mit 'continue': "-Patches <Tippfehler>" meldete "0 XPaths, GREEN".
# Gefunden beim Bau von WP8.1 (Vertrag 04), damals nur aufgeschrieben. Dateien, die das
# Skript SELBST unter mod/ findet, gibt es immer; die Schleifen bleiben darum, wie sie sind.
foreach ($name in 'Rezepte', 'Gegenstaende', 'Bloecke', 'Patches') {
    if (-not $PSBoundParameters.ContainsKey($name)) { continue }
    foreach ($pfad in @($PSBoundParameters[$name])) {
        if (-not $pfad -or -not (Test-Path -LiteralPath $pfad)) { Stop-Unpruefbar "-$name nennt '$pfad', und das gibt es nicht" }
        # Eine DATEI, kein Ordner (drittes Review): ein Ordner bestand die Pruefung oben,
        # und die Schleifen lasen dann nichts daraus - wieder "0 XPaths, GREEN".
        if (-not (Test-Path -LiteralPath $pfad -PathType Leaf)) { Stop-Unpruefbar "-$name nennt '$pfad', und das ist keine Datei" }
    }
}

# Gefunden statt aufgezaehlt (geaendert 2026-11-08, WP5.1). Vorher standen hier zwei feste
# Pfade auf 700_20_Material. Als WP5.1 die Waffenrezepte in 700_30_Ausruestung anlegte, hat
# dieses Skript sie nicht gesehen und weiter gruen gemeldet - ein Pruefer, der nur die
# Dateien kennt, die man ihm beim Schreiben genannt hat, prueft das falsche Projekt.
# 700_10_Purge bleibt aussen vor: die Datei ist ERZEUGT und enthaelt nur Entfernungen.
if (-not $Rezepte) {
    $Rezepte = @(Get-ChildItem (Join-Path $repoRoot 'mod') -Recurse -Filter 'recipes.xml' |
        Where-Object { $_.FullName -notmatch '700_10_Purge' } |
        Select-Object -ExpandProperty FullName)
}
if (-not $Gegenstaende) {
    $Gegenstaende = @(Get-ChildItem (Join-Path $repoRoot 'mod') -Recurse -Filter 'items.xml' |
        Where-Object { $_.FullName -notmatch '700_10_Purge' } |
        Select-Object -ExpandProperty FullName)
}
# Eigene BLOECKE, hinzugefuegt 2026-11-08 (WP5.5b). Derselbe Fehler wie oben, eine Stufe
# spaeter bemerkt: das Skript las Vanillas blocks.xml, aber unsere nicht. Der Webstuhl ist
# der erste eigene Block des Projekts, und sein Bau-Rezept stand damit als 'nirgends
# definiert' da, obwohl die Definition zwei Dateien weiter liegt. Haette dieses Skript
# nicht EINEN eigenen Block gesehen, waere der Fehler umgekehrt gelaufen: ein Tippfehler
# im Blocknamen waere nie aufgefallen.
if (-not $Bloecke) {
    $Bloecke = @(Get-ChildItem (Join-Path $repoRoot 'mod') -Recurse -Filter 'blocks.xml' |
        Where-Object { $_.FullName -notmatch '700_10_Purge' } |
        Select-Object -ExpandProperty FullName)
}

# Jede eigene Eingangsdatei EINMAL lesen, bevor irgendetwas geprueft wird. Eine, die sich
# nicht lesen laesst, beendet den Lauf hier mit Exit 2; eine mit kaputtem XML steht danach
# als rote Zeile da, und jede Schleife weiter unten ueberspringt sie.
foreach ($pfad in @($Rezepte) + @($Gegenstaende) + @($Bloecke)) {
    if (-not $pfad -or -not (Test-Path -LiteralPath $pfad)) { continue }
    $gelesen = Read-XmlDatei $pfad
    if ($gelesen.Unlesbar) { Stop-Unpruefbar $gelesen.Unlesbar }
}

Write-Output '== kette-pruefen =='
Write-Output "  Vanilla: $Vanilla"

$defined = @{}
foreach ($file in @('items.xml', 'blocks.xml')) {
    $path = Join-Path $Vanilla $file
    # Ausgang 2 statt Ausnahme (geaendert 2026-11-20 nach dem Review): ein SDTD_PATH, der
    # auf einen Ordner OHNE Data\Config zeigt, brach den ganzen Prueflauf ab, bevor
    # check-all.ps1 seine Ergebniszeile schreiben konnte.
    if (-not (Test-Path -LiteralPath $path)) { Stop-Unpruefbar "$path fehlt (zeigt SDTD_PATH auf eine Installation?)" }
    $kennungen = Get-Kennungen $path '<(item|block) name="([^"]+)"' 2
    if ($kennungen.Unlesbar) { Stop-Unpruefbar $kennungen.Unlesbar }
    foreach ($n in $kennungen.Namen) { $defined[$n] = 'vanilla' }
}
$vanillaCount = $defined.Count

foreach ($path in $Gegenstaende) {
    if (-not (Test-Path $path)) { continue }
    $kennungen = Get-Kennungen $path '<item name="([^"]+)"' 1
    if ($kennungen.Unlesbar) { Stop-Unpruefbar $kennungen.Unlesbar }
    foreach ($n in $kennungen.Namen) { $defined[$n] = 'unser' }
}

foreach ($path in $Bloecke) {
    if (-not (Test-Path $path)) { continue }
    $kennungen = Get-Kennungen $path '<block name="([^"]+)"' 1
    if ($kennungen.Unlesbar) { Stop-Unpruefbar $kennungen.Unlesbar }
    foreach ($n in $kennungen.Namen) { $defined[$n] = 'unser' }
}

Write-Output ("  Definitionen: {0} aus Vanilla, {1} eigene" -f $vanillaCount, ($defined.Count - $vanillaCount))

$recipeCount = 0
$toolGated = 0
$appendedTotal = 0

foreach ($path in $Rezepte) {
    if (-not (Test-Path $path)) { continue }
    $xml = (Read-XmlDatei $path).Doc
    if ($null -eq $xml) { continue }
    foreach ($recipe in $xml.SelectNodes('//recipe')) {
        $recipeCount++
        $where = "$([IO.Path]::GetFileName($path)) / $($recipe.name)"

        if (-not $defined.ContainsKey($recipe.name)) {
            $unresolved += "Ergebnis '$($recipe.name)' ist nirgends definiert  ($where)"
        }

        if ($recipe.craft_tool) {
            $toolGated++
            if (-not $defined.ContainsKey($recipe.craft_tool)) {
                $unresolved += "Werkzeug '$($recipe.craft_tool)' ist nirgends definiert  ($where)"
            }
        }

        foreach ($ingredient in $recipe.SelectNodes('ingredient')) {
            if (-not $defined.ContainsKey($ingredient.name)) {
                $unresolved += "Zutat '$($ingredient.name)' ist nirgends definiert  ($where)"
            }
        }
    }

    # ZUTATEN, DIE IN EIN FREMDES REZEPT EINGEHAENGT WERDEN (ergaenzt 2026-11-08, WP6).
    # Die Schleife oben laeuft ueber <recipe>-Knoten. Wer eine Zutat an ein VANILLA-Rezept
    # anhaengt - <append xpath="/recipes/recipe[@name='forge']"><ingredient .../></append> -,
    # hat keinen <recipe>-Knoten in seiner Datei, und die Zutat wurde nie aufgeloest.
    # So ist resourceClay in WP5.5b durchgekommen: die Kennung heisst in Vanilla
    # resourceClayLump, und vier Werkstatt-Bau-Rezepte zeigten auf etwas, das es nicht gibt.
    # Der Lauf war gruen.
    $appended = 0
    foreach ($ingredient in $xml.SelectNodes('//ingredient')) {
        if ($ingredient.ParentNode.LocalName -eq 'recipe') { continue }
        $appended++
        $target = $ingredient.ParentNode.GetAttribute('xpath')
        if (-not $target) { $target = $ingredient.ParentNode.LocalName }
        $where = "$([IO.Path]::GetFileName($path)) / $target"
        if (-not $defined.ContainsKey($ingredient.name)) {
            $unresolved += "Eingehaengte Zutat '$($ingredient.name)' ist nirgends definiert  ($where)"
        }
    }
    $appendedTotal += $appended
}

# REPARATURWERKZEUGE (ergaenzt 2026-11-08, WP6). Dieselbe Luecke, andere Stelle: unsere
# <set>-Zeilen auf RepairTools tragen eine KOMMALISTE von Kennungen im Elementtext. Ein
# Tippfehler darin macht einen Gegenstand unreparierbar, und keine Pruefung haette ihn
# gesehen. Geprueft wird nur dieser eine Pfad - ein allgemeines "loese jeden set-Wert auf"
# wuerde ueber Zahlen, Marken und Pfade stolpern und waere ein Pruefer, der schreit.
$repairRefs = 0
foreach ($path in $Gegenstaende) {
    if (-not (Test-Path $path)) { continue }
    $xml = (Read-XmlDatei $path).Doc
    if ($null -eq $xml) { continue }
    foreach ($node in $xml.SelectNodes('//set')) {
        $xpath = $node.GetAttribute('xpath')
        if ($xpath -notmatch "RepairTools'\]/@value$") { continue }
        foreach ($name in ($node.InnerText -split ',')) {
            $name = $name.Trim()
            if ($name.Length -eq 0) { continue }
            $repairRefs++
            if (-not $defined.ContainsKey($name)) {
                $unresolved += "Reparaturwerkzeug '$name' ist nirgends definiert  ($([IO.Path]::GetFileName($path)) / $xpath)"
            }
        }
    }
}

# UMGEBOGENE BLOCK-VERWEISE (ergaenzt 2026-11-08, WP6.1). Die dritte Stelle derselben
# Lueche, gefunden beim Schreiben von WP6.1 und nicht durch einen Fehlschlag: der
# Ausbaupfad biegt mit <set>-Zeilen die Zutat einer Aufwertung, einen Reparaturstoff und
# den Namen eines Abwurfs um. Alle drei tragen eine Kennung - als Elementtext, nicht als
# Attribut -, und keine davon ist ein Rezept.
#
#   <set xpath="...[@class='UpgradeBlock']/property[@name='Item']/@value">resourceRockSmall</set>
#   <set xpath="...[@class='RepairItems']/property[@name='resourceConcreteMix']/@name">resourceRockSmall</set>
#   <set xpath=".../drop[@event='Harvest'][@name='resourceScrapIron']/@name">resourceRockSmall</set>
#
# Ein Tippfehler in der ersten Zeile macht eine Baustufe unerreichbar, in der zweiten
# einen Block unreparierbar, in der dritten einen Abbau ertraglos - und alle drei fallen
# erst im Spiel auf. 'ToBlock' kommt mit, weil ein umgebogenes Aufwertungsziel genauso
# eine Kennung ist. Aufgeloest wird gegen EINEN Topf aus Gegenstaenden UND Bloecken -
# dieser Lauf prueft also, dass die Kennung ueberhaupt existiert, nicht dass sie von der
# richtigen Art ist. Ein Block als Aufwertungs-Zutat bliebe hier gruen. Das ist bewusst
# die billigere Pruefung: die Art steht erst im gemergten Dump fest (WP3.6).
#
# Wie bei RepairTools wird nur die ABGEZAEHLTE Liste von Pfaden aufgeloest. Ein
# allgemeines "loese jeden set-Wert auf" wuerde ueber Zahlen (ItemCount, MaxDamage),
# Marken (damage_category) und Prefab-Pfade stolpern.
$rewiredRefs = 0
foreach ($path in @($Gegenstaende) + @($Bloecke)) {
    if (-not $path -or -not (Test-Path $path)) { continue }
    $xml = (Read-XmlDatei $path).Doc
    if ($null -eq $xml) { continue }
    foreach ($node in $xml.SelectNodes('//set')) {
        $xpath = $node.GetAttribute('xpath')
        $kind = $null
        if ($xpath -match "property\[@name='Item'\]/@value$")    { $kind = 'Aufwertungs-Zutat' }
        elseif ($xpath -match "property\[@name='ToBlock'\]/@value$") { $kind = 'Aufwertungs-Ziel' }
        elseif ($xpath -match "RepairItems'\].*/@name$")          { $kind = 'Reparaturstoff' }
        elseif ($xpath -match "/drop\[.*\]/@name$")               { $kind = 'Abwurf' }
        if (-not $kind) { continue }
        $name = $node.InnerText.Trim()
        if ($name.Length -eq 0) { continue }
        $rewiredRefs++
        if (-not $defined.ContainsKey($name)) {
            $unresolved += "$kind '$name' ist nirgends definiert  ($([IO.Path]::GetFileName($path)) / $xpath)"
        }
    }
}

# VERWEISE IN EIGENEN DEFINITIONEN (ergaenzt 2026-11-08, WP6.4). Die vierte Stelle, und die
# groesste: ein selbst geschriebener Block nennt Kennungen in Attributen, nicht im
# Elementtext - Next, ToBlock, Item, Extends, Abwuerfe, Reparaturstoffe. WP6.4 schreibt davon
# ueber dreissig in einem Commit. Bisher hat kette-pruefen GEPRUEFT, ob unsere Bloecke
# existieren, aber nicht, worauf sie zeigen.
#
# Ein Tippfehler in 'Next' ist dabei der teuerste: BlockPlantGrowing::LateInit WIRFT eine
# Exception, wenn der Zielblock nicht existiert ("Block with name ' … ' not found!"). Das
# nimmt beim Start die ganze blocks.xml mit, nicht nur den einen Block.
#
# Wieder eine ABGEZAEHLTE Liste von Stellen. Nicht dabei und mit Absicht: ActiveRadiusEffects
# und BuffsWhenWalkedOn (Buffs, stehen in buffs.xml), DescriptionKey und CustomIcon
# (Sprachschluessel und Symbole, pruefen 'localization' und das Auge), Material (materials.xml),
# Model (ein Prefab-Pfad, den nur das Spiel aufloesen kann), TraderStageTemplate.
$ownRefs = 0
$ownPaths = @(
    @{ XPath = "//property[@name='Next']";     Attr = 'value'; Art = 'Folgeblock' },
    @{ XPath = "//property[@name='ToBlock']";  Attr = 'value'; Art = 'Aufwertungs-Ziel' },
    @{ XPath = "//property[@name='Item']";     Attr = 'value'; Art = 'Aufwertungs-Zutat' },
    @{ XPath = "//property[@name='Extends']";  Attr = 'value'; Art = 'Grundlage' },
    @{ XPath = "//drop";                       Attr = 'name';  Art = 'Abwurf' },
    @{ XPath = "//property[@class='RepairItems']/property"; Attr = 'name'; Art = 'Reparaturstoff' }
)
foreach ($path in @($Gegenstaende) + @($Bloecke)) {
    if (-not $path -or -not (Test-Path $path)) { continue }
    $xml = (Read-XmlDatei $path).Doc
    if ($null -eq $xml) { continue }
    foreach ($spec in $ownPaths) {
        foreach ($node in $xml.SelectNodes($spec.XPath)) {
            $name = $node.GetAttribute($spec.Attr)
            if (-not $name) { continue }
            $name = $name.Trim()
            if ($name.Length -eq 0) { continue }
            $ownRefs++
            if (-not $defined.ContainsKey($name)) {
                $unresolved += "$($spec.Art) '$name' ist nirgends definiert  ($([IO.Path]::GetFileName($path)))"
            }
        }
    }
}

# DIE XPATHS SELBST (ergaenzt 2026-11-08, WP7.1). Bis hierher stand unter 'Grenzen'
# wortwoertlich: "Ob der XML-Patcher des Spiels unsere XPaths trifft, steht hier nicht."
# Das war die groesste Luecke, die das Projekt noch hatte. Ein Patch, dessen XPath nichts
# trifft, ist NICHT laut: XmlPatcher::PatchXml schreibt eine Zeile ins Protokoll
# ("XML patch for ... did not apply") und laedt weiter. Das Spiel startet, der Baum fehlt,
# und niemand erfaehrt es, bis jemand im Spiel nachsieht. Vier Verweisklassen pruefen den
# INHALT unserer Patches - diese prueft, ob der Patch ueberhaupt irgendwo landet.
#
# Geprueft wird gegen die Vanilla-Datei GLEICHEN NAMENS, denn genau so sucht
# XmlPatcher::LoadAndPatchConfig (<Modlet>/Config/<gleicher Name>, D53). Trifft der XPath
# dort nichts, kann der Knoten noch von einem FRUEHEREN Modlet stammen (Ladereihenfolge
# ueber das Zahlenpraefix): dann muss die Kennung im XPath eine sein, die wir selbst
# definieren. Trifft keines von beidem, ist der Patch toter Text.
$xpathChecked = 0
$xpathVanilla = 0
$xpathOwn = 0
$patchVerbs = @('set', 'setattribute', 'removeattribute', 'append', 'prepend',
                'insertAfter', 'insertBefore', 'remove', 'csv')
$vanillaDocs = @{}
$patchDateien = 0
$ohneGegenstueck = 0
$ungeprueftEbene = 0
# ContainsKey und nicht '-not $Patches': eine Gegenprobe, die ABSICHTLICH keine Patch-Datei
# prueft, uebergibt @() - und ein leeres Feld ist in PowerShell falsch, waere also wieder in
# die Suche unter mod/ gelaufen. Drei bestehende Gegenproben sind beim ersten Lauf genau
# daran rot geworden: sie haben die echten Mod-Dateien gegen das Test-Vanilla gehalten.
if (-not $PSBoundParameters.ContainsKey('Patches')) {
    $Patches = @(Get-ChildItem (Join-Path $repoRoot 'mod') -Recurse -Filter '*.xml' |
        Where-Object { $_.FullName -match '\\Config\\' -and $_.FullName -notmatch '700_10_Purge' } |
        Select-Object -ExpandProperty FullName)
}
# BEDINGTE BLOECKE (ergaenzt 2026-11-22, WP8.7). Bis dahin wurde <conditional> gezaehlt und
# nicht angesehen: jeder Patch darin war fuer diese Pruefung unsichtbar. Vertrag 03 §5
# verlangt aber gerade fuer XUi-Eingriffe einen solchen Block - die Pruefung haette also
# genau die Dateien verloren, fuer die sie zuletzt erweitert wurde.
#
# Was das Spiel tut, ist aus dem Code gelesen (V 3.4.0 b10, Finding WP1 §4):
#   - XmlPatchMethods::Conditional nimmt die Kinder des Blocks der Reihe nach. Das erste
#     <if>, dessen 'cond' wahr ist, gewinnt; ein <else> gewinnt, sobald es erreicht wird.
#     Jedes andere Kind ist eine Ausnahme ("Unexpected child element").
#   - Die Kinder des gewinnenden Zweigs laufen durch XmlPatcher::PatchXml, also durch
#     dieselbe Verarbeitung wie die oberste Ebene - auch ein weiterer <conditional>.
#   - 'cond' wird von NCalc ausgewertet und MUSS einen Wahrheitswert liefern. xpath(...)
#     liefert keinen (null, den Treffertext oder "More than one match"): allein als
#     Bedingung ist es eine Ausnahme, gebraucht wird ein Vergleich wie "!= null".
#   - Ein Attribut 'evaluator' am <conditional> eines Patches wird mit Warnung ignoriert.
#
# Geprueft wird JEDER Zweig, als waere er der gewinnende. Das ist strenger als das Spiel
# und so gewollt: ob eine Bedingung wahr wird, weiss diese Pruefung nicht.
$bekannteFunktionen = @('mod_loaded', 'mod_version', 'game_version', 'version', 'serverinfo', 'gamepref',
                        'event', 'time_minutes', 'game_loaded', 'xpath', 'has_entitlement')
$bedingteBloecke = 0
$zweige = 0
$bedingteXPaths = 0
$bedingungsXPaths = 0
$genannteMods = @()

# DIE BEDINGUNG WIRD MIT NCALC GELESEN (geaendert 2026-11-22, zweites Review zu WP8.7).
# Die erste Fassung hat den Ausdruck GROB zerlegt - Texte maskiert, Funktionsaufrufe gesucht,
# Klammern gezaehlt, nach einem Vergleich neben xpath(...) gesehen. Zwei Reviews in Folge
# haben darin Luecken gefunden (Klammern, vertauschte Seiten, not/or, geklammertes null),
# und jede Sonderregel hat eine Form geschlossen und die naechste geoeffnet. Der Grund war
# immer derselbe: die Pruefung hat an dem Text geraten, statt ihn zu lesen.
#
# Jetzt liest ihn die Bibliothek, die ihn auch im Spiel liest: NCalc.dll aus der
# Spielinstallation, mit denselben Optionen (1542). Geladen wird sie nur, wenn eine
# Patch-Datei einen bedingten Block hat; laesst sie sich dann nicht laden, ist der Lauf
# NICHT GEPRUEFT (Exit 2), nicht gruen. Im Repo liegt davon nichts (Projektregel 1).
#
# Was daraus folgt (Vertrag 04, Nachtrag zweites Review zu WP8.7):
#   - rot ist, was NCalc nicht lesen kann, was beim Auswerten eine Ausnahme wirft oder
#     keinen Wahrheitswert liefert - in IRGENDEINER Belegung der genannten Mods;
#   - xpath(...) laeuft gegen Vanilla und liefert, was das Spiel liefert: null ohne Treffer,
#     "More than one match" bei mehreren, sonst den Text des Treffers;
#   - jeder XPath in einer Bedingung muss in Vanilla etwas treffen (oder nur eigene
#     Kennungen nennen). Das ersetzt den "toten Zweig": ob ein Zweig laeuft, haengt an
#     Mods, die hier niemand kennt, aber ein Ziel, das es nicht gibt, ist ein Tippfehler.
$ncalcGeladen = $false
$ncalcOpt = $null
$ncalcHandler = $null
$ncalcBelegung = @{}
$ncalcXPath = @{}
$vanillaXDocs = @{}
$bedingungenGelesen = 0
$bedingungenWahr = 0
$bedingungenFalsch = 0
$bedingungenOffen = 0

function Initialize-NCalc {
    if ($script:ncalcGeladen) { return }
    $pfad = $NCalc
    if (-not $pfad) {
        if (-not $env:SDTD_PATH) {
            Stop-Unpruefbar "eine Patch-Datei hat einen bedingten Block, und SDTD_PATH ist nicht gesetzt: die NCalc.dll des Spiels wird gebraucht, um die Bedingung zu lesen (oder -NCalc <Pfad>)"
        }
        try { $pfad = [IO.Path]::Combine($env:SDTD_PATH, '7DaysToDie_Data\Managed\NCalc.dll') }
        catch { Stop-Unpruefbar "SDTD_PATH ist kein gueltiger Pfad: die NCalc.dll des Spiels laesst sich nicht suchen" }
    }
    $da = $false
    try { $da = Test-Path -LiteralPath $pfad -PathType Leaf } catch { $da = $false }
    if (-not $da) {
        Stop-Unpruefbar "eine Patch-Datei hat einen bedingten Block, aber die NCalc.dll des Spiels fehlt: $pfad"
    }
    try {
        Add-Type -AssemblyName System.Xml.Linq
        $asm = [Reflection.Assembly]::LoadFrom((Resolve-Path -LiteralPath $pfad).ProviderPath)
        $script:ncalcOpt = [Enum]::ToObject($asm.GetType('NCalc.EvaluateOptions', $true), 1542)
        # Die drei Funktionen, die hier nachgestellt werden koennen. Der Vergleich ohne
        # Gross/Klein ist der des Spiels (EqualsCaseInsensitive). Alles andere bekommt kein
        # Ergebnis - NCalc wirft dann "Function not found", genau wie im Spiel.
        $script:ncalcHandler = [NCalc.EvaluateFunctionHandler] {
            param($name, $fa, $ignoreCase)
            if ($name -eq 'mod_loaded') {
                $modName = ([string]$fa.Parameters[0].Evaluate()).Trim()
                $fa.Result = [bool]$script:ncalcBelegung[$modName]
            }
            elseif ($name -eq 'xpath') {
                $fa.Result = $script:ncalcXPath[[string]$fa.Parameters[0].Evaluate()]
            }
        }
    }
    catch {
        Stop-Unpruefbar "die NCalc.dll des Spiels laesst sich nicht laden ($pfad): $(Get-Innerste $_.Exception)"
    }
    $script:ncalcGeladen = $true
}

function Get-VanillaXDoc {
    # Das Spiel wertet xpath(...) ueber XDocument aus (Extensions::XPathEvaluate), nicht
    # ueber XmlDocument. Darum wird die Vanilla-Datei hier ein zweites Mal gelesen.
    param([string]$Datei)
    if (-not $script:vanillaXDocs.ContainsKey($Datei)) {
        try {
            $voll = (Resolve-Path -LiteralPath ([IO.Path]::Combine($Vanilla, $Datei))).ProviderPath
            $script:vanillaXDocs[$Datei] = [System.Xml.Linq.XDocument]::Load($voll)
        }
        catch {
            Stop-Unpruefbar "die Vanilla-Datei '$Datei' laesst sich fuer die Bedingung nicht lesen: $(Get-Innerste $_.Exception)"
        }
    }
    return $script:vanillaXDocs[$Datei]
}

function Get-BedingungsKnoten {
    # Alle Knoten des von NCalc gelesenen Ausdrucks, flach in eine Liste.
    param($Knoten, [System.Collections.ArrayList]$Liste)
    if ($null -eq $Knoten) { return }
    [void]$Liste.Add($Knoten)
    $typ = $Knoten.GetType()
    foreach ($p in 'LeftExpression', 'MiddleExpression', 'RightExpression', 'Expression') {
        $eigenschaft = $typ.GetProperty($p)
        if ($null -ne $eigenschaft) { Get-BedingungsKnoten ($eigenschaft.GetValue($Knoten, $null)) $Liste }
    }
    if ($typ.Name -ceq 'Function') {
        foreach ($argument in @($Knoten.Expressions)) { Get-BedingungsKnoten $argument $Liste }
    }
}

function Test-Bedingung {
    param([string]$Ausdruck, $VanillaDoc, [string]$Datei)
    Initialize-NCalc
    $script:bedingungenGelesen++

    # 1. Lesen. HasErrors() liest den Ausdruck und fuellt ParsedExpression.
    $gelesen = $null
    $lesefehler = $null
    try {
        $gelesen = New-Object NCalc.Expression -ArgumentList $Ausdruck, $script:ncalcOpt
        if ($gelesen.HasErrors()) { $lesefehler = [string]$gelesen.Error }
    }
    catch { $lesefehler = [string](Get-Innerste $_.Exception) }
    if ($lesefehler) {
        $script:unresolved += "NCalc kann die Bedingung nicht lesen ($(($lesefehler -replace '\s+', ' ').Trim())): $Ausdruck  ($Datei)"
        return
    }

    # 2. Die Funktionsaufrufe. Der Name muss einer der elf des Spiels sein; mod_loaded und
    #    xpath bekommen genau einen festen Text - sonst laesst sich hier nichts nachstellen.
    $knoten = New-Object System.Collections.ArrayList
    Get-BedingungsKnoten $gelesen.ParsedExpression $knoten
    $mods = New-Object System.Collections.ArrayList
    $xpaths = New-Object System.Collections.ArrayList
    $andereFunktion = $false
    $inOrdnung = $true
    foreach ($k in $knoten) {
        if ($k.GetType().Name -cne 'Function') { continue }
        $fn = [string]$k.Identifier.Name
        if ($bekannteFunktionen -notcontains $fn) {
            $script:unresolved += "Bedingung ruft '$fn(' auf; das Spiel kennt: $($bekannteFunktionen -join ', ')  ($Datei)"
            $inOrdnung = $false
            continue
        }
        if ($fn -ne 'mod_loaded' -and $fn -ne 'xpath') { $andereFunktion = $true; continue }
        $argumente = @($k.Expressions)
        if ($argumente.Count -ne 1 -or $argumente[0].GetType().Name -cne 'ValueExpression' -or $argumente[0].Value -isnot [string]) {
            $script:unresolved += "Bedingung: $fn(...) erwartet genau EINEN festen Text in einfachen Anfuehrungszeichen: $Ausdruck  ($Datei)"
            $inOrdnung = $false
            continue
        }
        $text = [string]$argumente[0].Value
        if ($fn -eq 'mod_loaded') {
            $script:genannteMods += $text.Trim()
            if (-not $mods.Contains($text.Trim())) { [void]$mods.Add($text.Trim()) }
            continue
        }
        $script:bedingungsXPaths++
        if (-not $xpaths.Contains($text)) { [void]$xpaths.Add($text) }
    }

    # 3. Jeder XPath gegen Vanilla, mit dem Ergebnis, das das Spiel daraus macht.
    $script:ncalcXPath = New-Object System.Collections.Hashtable ([System.StringComparer]::Ordinal)
    $xdoc = Get-VanillaXDoc $Datei
    foreach ($text in $xpaths) {
        $liste = $null
        try {
            $roh = [System.Xml.XPath.Extensions]::XPathEvaluate($xdoc, $text)
            if ($roh -is [string] -or $roh -is [double] -or $roh -is [bool]) {
                $script:unresolved += "XPath in der Bedingung liefert keine Knotenmenge: $text  ($Datei)"
                $inOrdnung = $false
                continue
            }
            $liste = @($roh)
        }
        catch {
            $script:unresolved += "XPath in der Bedingung ist kein gueltiger Ausdruck: $text  ($Datei)"
            $inOrdnung = $false
            continue
        }
        if ($liste.Count -eq 0) {
            $ownNames = @([regex]::Matches($text, "@name=['""]([^'""]+)['""]") | ForEach-Object { $_.Groups[1].Value })
            $eigen = @($ownNames | Where-Object { $defined[$_] -eq 'unser' })
            if ($ownNames.Count -gt 0 -and $eigen.Count -eq $ownNames.Count) {
                # Ein Knoten aus einem frueheren eigenen Modlet: im Spiel ein Treffer.
                $script:ncalcXPath[$text] = 'eigener Knoten'
                continue
            }
            $script:unresolved += "Bedingung nennt ein Ziel, das es in Vanilla nicht gibt: $text  ($Datei)"
            $inOrdnung = $false
            continue
        }
        if ($liste.Count -gt 1) { $script:ncalcXPath[$text] = 'More than one match' }
        else { $script:ncalcXPath[$text] = $liste[0].ToString() }
    }
    if (-not $inOrdnung) { return }

    # 4. Auswerten. Andere Funktionen als mod_loaded und xpath kennt nur das laufende Spiel.
    if ($andereFunktion) { $script:bedingungenOffen++; return }
    if ($mods.Count -gt 8) {
        Stop-Unpruefbar "eine Bedingung nennt $($mods.Count) Mods; durchgerechnet werden hoechstens acht (256 Belegungen): $Ausdruck  ($Datei)"
    }
    $belegungen = [int][math]::Pow(2, $mods.Count)
    $ohneMods = $false
    for ($b = 0; $b -lt $belegungen; $b++) {
        $script:ncalcBelegung = New-Object System.Collections.Hashtable ([System.StringComparer]::Ordinal)
        for ($j = 0; $j -lt $mods.Count; $j++) { $script:ncalcBelegung[$mods[$j]] = ((($b -shr $j) -band 1) -eq 1) }
        $ergebnis = $null
        try {
            $lauf = New-Object NCalc.Expression -ArgumentList $Ausdruck, $script:ncalcOpt
            $lauf.add_EvaluateFunction($script:ncalcHandler)
            $ergebnis = $lauf.Evaluate()
        }
        catch {
            $grund = (([string](Get-Innerste $_.Exception)) -replace '\s+', ' ').Trim()
            $script:unresolved += "Bedingung laesst sich nicht auswerten ($grund): $Ausdruck  ($Datei)"
            return
        }
        if ($ergebnis -isnot [bool]) {
            $art = if ($null -eq $ergebnis) { 'null' } else { $ergebnis.GetType().Name }
            $script:unresolved += "Bedingung liefert keinen Wahrheitswert, sondern $art. Das Spiel verlangt wahr oder falsch (xpath allein liefert den Treffer; gebraucht: xpath('...') != null): $Ausdruck  ($Datei)"
            return
        }
        # Belegung 0 ist "keine der genannten Mods geladen" - der Stand, den wir kennen.
        if ($b -eq 0) { $ohneMods = [bool]$ergebnis }
    }
    # Gezaehlt wird erst, wenn JEDE Belegung einen Wahrheitswert geliefert hat.
    if ($ohneMods) { $script:bedingungenWahr++ } else { $script:bedingungenFalsch++ }
}

function Test-Bedingt {
    param($Block, [string]$Datei, $VanillaDoc, [int]$Tiefe)
    $script:bedingteBloecke++
    if ($Block.HasAttribute('evaluator')) {
        $script:unresolved += "<conditional> traegt 'evaluator': in einem Patch ignoriert das Spiel das Attribut mit einer Warnung  ($Datei)"
    }
    $ifs = 0
    $nachElse = $false
    $operationen = 0
    foreach ($kind in $Block.ChildNodes) {
        if ($kind.NodeType -ne 'Element') { continue }
        $art = $kind.get_Name()
        if ($art -cne 'if' -and $art -cne 'else') {
            $script:unresolved += "unerwartetes Kind <$art> in <conditional>: erlaubt sind <if cond=...> und <else>  ($Datei)"
            continue
        }
        if ($nachElse) {
            $script:unresolved += "<$art> steht hinter <else> und wird nie erreicht  ($Datei)"
        }
        $script:zweige++
        if ($art -ceq 'if') {
            $ifs++
            $cond = $kind.GetAttribute('cond')
            if (-not $cond -or $cond.Trim().Length -eq 0) {
                $script:unresolved += "<if> ohne 'cond' in <conditional>  ($Datei)"
            }
            else { Test-Bedingung $cond $VanillaDoc $Datei }
        }
        else {
            $nachElse = $true
            if ($kind.HasAttribute('cond')) {
                $script:unresolved += "<else> traegt 'cond': das Spiel liest es nicht, der Zweig gilt immer  ($Datei)"
            }
        }
        $operationen += @($kind.ChildNodes | Where-Object { $_.NodeType -eq 'Element' }).Count
        Test-PatchEbene $kind $Datei $VanillaDoc ($Tiefe + 1)
    }
    if ($ifs -eq 0) {
        $script:unresolved += "<conditional> ohne ein einziges <if>  ($Datei)"
    }
    if ($operationen -eq 0) {
        $script:unresolved += "<conditional> ohne eine einzige Operation in seinen Zweigen  ($Datei)"
    }
}

function Test-PatchEbene {
    # Die Kinder von <config> und, seit WP8.7, die Kinder eines <if> oder <else>.
    param($Behaelter, [string]$Datei, $VanillaDoc, [int]$Tiefe)
    foreach ($node in $Behaelter.ChildNodes) {
        if ($node.NodeType -ne 'Element') { continue }
        # get_Name() UND NICHT .Name. PowerShells XML-Adapter legt die XML-Attribute als
        # Eigenschaften ueber das Objekt, und ein Attribut 'name' ueberdeckt dabei die
        # Eigenschaft 'Name' des Elements. Bei <setattribute name="hidden" xpath="...">
        # liefert $node.Name darum "hidden" statt "setattribute" - der Patch faellt durch
        # die Verb-Liste und die ganze Datei bleibt ungeprueft, ohne eine Zeile Ausgabe.
        # Genau so ist mod/700_50_Fortschritt/Config/progression.xml beim ersten Lauf mit
        # ihren 20 Patches unbemerkt uebersprungen worden (WP7.1). Ein Methodenaufruf geht
        # am Adapter vorbei.
        $verb = $node.get_Name()
        # <include> sieht diese Pruefung nicht von innen an (unter 'Grenzen' genannt). Es
        # wird gezaehlt, damit die Grenze eine Zahl hat und nicht nur ein Satz ist.
        if ($verb -ceq 'include') { $script:ungeprueftEbene++; continue }
        if ($verb -ceq 'conditional') { Test-Bedingt $node $Datei $VanillaDoc $Tiefe; continue }
        if ($patchVerbs -cnotcontains $verb) {
            $script:unresolved += "unbekannte Patch-Operation <$verb>: $Datei  (bekannt: $($patchVerbs -join ', '), conditional, include)"
            continue
        }
        $xp = $node.GetAttribute('xpath')
        if (-not $xp) {
            $script:unresolved += "Patch-Operation <$verb> ohne xpath: $Datei"
            continue
        }
        $script:xpathChecked++
        if ($Tiefe -gt 0) { $script:bedingteXPaths++ }
        $hits = 0
        try { $hits = @($VanillaDoc.SelectNodes($xp)).Count }
        catch {
            $script:unresolved += "XPath ist kein gueltiger Ausdruck: $xp  ($Datei)"
            continue
        }
        if ($hits -gt 0) { $script:xpathVanilla++; continue }
        # Kein Treffer in Vanilla: stammt das Ziel aus einem eigenen Modlet?
        $ownNames = @([regex]::Matches($xp, "@name='([^']+)'") | ForEach-Object { $_.Groups[1].Value })
        $eigen = @($ownNames | Where-Object { $defined[$_] -eq 'unser' })
        if ($ownNames.Count -gt 0 -and $eigen.Count -eq $ownNames.Count) { $script:xpathOwn++; continue }
        $script:unresolved += "XPath trifft nichts: $xp  ($Datei)"
    }
}

foreach ($path in $Patches) {
    if (-not $path -or -not (Test-Path $path)) { continue }
    # Das Gegenstueck liegt in Vanilla unter DEMSELBEN PFAD RELATIV ZU Config\ - nicht nur
    # unter demselben Dateinamen (geaendert 2026-11-20, erstes und drittes Review). Vorher
    # wurde nur der Dateiname im obersten Ordner gesucht: mod/.../Config/XUi_InGame/xui.xml
    # fand kein Gegenstueck und wurde mit 'continue' still uebersprungen, obwohl der
    # Kommentar hier "gezaehlt" versprach. Zwei unserer Dateien blieben so ungeprueft.
    # Liegt die Datei nicht unter einem Config-Ordner (Testdaten), zaehlt der Dateiname.
    $voll = (Resolve-Path -LiteralPath $path).ProviderPath
    $stelle = $voll.LastIndexOf('\Config\', [StringComparison]::OrdinalIgnoreCase)
    $name = if ($stelle -ge 0) { $voll.Substring($stelle + 8) } else { [IO.Path]::GetFileName($voll) }
    $vanillaPath = [IO.Path]::Combine($Vanilla, $name)
    # Kein Gegenstueck ist ROT, nicht "aussen vor": das Spiel laedt eine Patch-Datei nur zu
    # einer Config-Datei gleichen Pfads (D53). Fehlt die, landet kein Patch daraus.
    if (-not (Test-Path -LiteralPath $vanillaPath -PathType Leaf)) {
        $ohneGegenstueck++
        $unresolved += "Patch-Datei ohne Vanilla-Gegenstueck: $name  (gesucht: $vanillaPath)"
        continue
    }
    $patchDateien++
    if (-not $vanillaDocs.ContainsKey($name)) {
        $gelesen = Read-XmlDatei $vanillaPath -Vanilla
        if ($gelesen.Unlesbar) { Stop-Unpruefbar $gelesen.Unlesbar }
        $vanillaDocs[$name] = $gelesen.Doc
    }
    $vdoc = $vanillaDocs[$name]
    # EINE DATEI, DIE GEZAEHLT WIRD, MUSS AUCH GEPRUEFT WERDEN (ergaenzt 2026-11-21, viertes
    # Review). Drei Wege fuehrten zu "1 Patch-Datei, 0 XPaths, GREEN":
    #   - ein anderer Wurzelknoten als <config> (Vertrag 03 §7 verlangt ihn),
    #   - ein Kind, das keine der elf Operationen ist (Tippfehler: <sett xpath=...>),
    #   - eine Operation ohne xpath.
    # Jeder davon ist jetzt rot. Kaputtes XML ebenso (Read-XmlDatei schreibt die rote Zeile,
    # einmal je Datei); eine Patch-Datei, die sich nicht LESEN laesst, ist Exit 2.
    $gelesen = Read-XmlDatei $path
    if ($gelesen.Unlesbar) { Stop-Unpruefbar $gelesen.Unlesbar }
    $xml = $gelesen.Doc
    if ($null -eq $xml) { continue }
    if ($null -eq $xml.DocumentElement -or $xml.DocumentElement.get_Name() -cne 'config') {
        $wurzel = if ($null -eq $xml.DocumentElement) { '(keiner)' } else { $xml.DocumentElement.get_Name() }
        $unresolved += "Patch-Datei hat den Wurzelknoten <$wurzel> statt <config>: $name"
        continue
    }
    $elemente = @($xml.DocumentElement.ChildNodes | Where-Object { $_.NodeType -eq 'Element' })
    if ($elemente.Count -eq 0) {
        $unresolved += "Patch-Datei ohne eine einzige Operation: $name"
        continue
    }
    Test-PatchEbene $xml.DocumentElement $name $vdoc 0
}

# FORTSCHRITTS-VERWEISE (ergaenzt 2026-11-08, WP7.2). Die XPath-Pruefung oben sagt, ob ein
# Patch LANDET. Sie sagt nichts darueber, ob der WERT, den er schreibt, etwas bedeutet.
# Bei progression.xml ist das die gefaehrlichere Haelfte: ein <set .../@parent> mit
# 'attFortitud' trifft den XPath einwandfrei, haengt den Unterbereich aber an ein Attribut,
# das es nicht gibt - und er verschwindet aus dem Fertigkeitsfenster, ohne Fehlermeldung.
# Dasselbe fuer progression_name: ein Perk verlangt dann die Stufe eines Attributs, das
# nirgends existiert, und ist unerreichbar.
#
# Der Vorrat sind alle Fortschritts-Knoten aus Vanilla plus die, die wir selbst anlegen.
# Geprueft werden die Werte von @parent und @progression_name.
$progRefs = 0
$progPool = @{}
$progVanillaPfad = Join-Path $Vanilla 'progression.xml'
if (Test-Path $progVanillaPfad) {
    $gelesen = Read-XmlDatei $progVanillaPfad -Vanilla
    if ($gelesen.Unlesbar) { Stop-Unpruefbar $gelesen.Unlesbar }
    $pv = $gelesen.Doc
    foreach ($n in $pv.SelectNodes('//attribute | //skill | //perk | //crafting_skill | //book_group | //book')) {
        $nm = $n.GetAttribute('name')
        if ($nm) { $progPool[$nm] = 'vanilla' }
    }
    foreach ($path in $Patches) {
        if (-not $path -or -not (Test-Path $path)) { continue }
        if ([IO.Path]::GetFileName($path) -ne 'progression.xml') { continue }
        $xml = (Read-XmlDatei $path).Doc
        if ($null -eq $xml) { continue }
        # Erst unsere eigenen Fortschritts-Knoten einsammeln, falls wir welche anlegen.
        foreach ($n in $xml.SelectNodes('//attribute | //skill | //perk | //crafting_skill | //book_group | //book')) {
            $nm = $n.GetAttribute('name')
            if ($nm) { $progPool[$nm] = 'unser' }
        }
        foreach ($node in $xml.DocumentElement.ChildNodes) {
            if ($node.NodeType -ne 'Element') { continue }
            if ($node.get_Name() -ne 'set') { continue }
            $xp = $node.GetAttribute('xpath')
            $art = $null
            if ($xp -match '/@parent$')           { $art = 'Baum-Zuordnung' }
            elseif ($xp -match '/@progression_name$') { $art = 'Stufenbedingung' }
            if (-not $art) { continue }
            $wert = $node.InnerText.Trim()
            if ($wert.Length -eq 0) { continue }
            $progRefs++
            if (-not $progPool.ContainsKey($wert)) {
                $unresolved += "$art '$wert' ist kein Fortschritts-Knoten  ($([IO.Path]::GetFileName($path)) / $xp)"
            }
        }
    }
}

Write-Output ("  eigene Rezepte: {0}, davon werkzeuggebunden: {1}" -f $recipeCount, $toolGated)
Write-Output ("  eingehaengte Zutaten: {0}, Reparaturwerkzeuge: {1}, umgebogene Verweise: {2}" -f $appendedTotal, $repairRefs, $rewiredRefs)
Write-Output ("  Verweise in eigenen Definitionen: {0}" -f $ownRefs)
Write-Output ("  Patch-Dateien: {0} mit Vanilla-Gegenstueck, {1} ohne" -f $patchDateien, $ohneGegenstueck)
Write-Output ("  geprueefte XPaths: {0} ({1} in Vanilla, {2} auf eigene Knoten)" -f $xpathChecked, $xpathVanilla, $xpathOwn)
Write-Output ("  bedingte Bloecke: {0} (Zweige: {1}, XPaths darin: {2}, xpath-Bedingungen: {3})" -f $bedingteBloecke, $zweige, $bedingteXPaths, $bedingungsXPaths)
Write-Output ("  Bedingungen mit NCalc gelesen: {0} (ohne genannte Mods wahr: {1}, falsch: {2}, nicht ausgewertet: {3})" -f $bedingungenGelesen, $bedingungenWahr, $bedingungenFalsch, $bedingungenOffen)
$modListe = @($genannteMods | Sort-Object -Unique)
Write-Output ("  in Bedingungen genannte Mods: {0}" -f $(if ($modListe.Count -gt 0) { $modListe -join ', ' } else { 'keine' }))
Write-Output ("  nicht von innen geprueft (include): {0}" -f $ungeprueftEbene)
Write-Output ("  Fortschritts-Verweise: {0}" -f $progRefs)
Write-Output ("  unaufgeloeste Verweise: {0}" -f $unresolved.Count)

foreach ($problem in $unresolved) { Write-Output "  [ROT]  $problem" }

Write-Output ''
Write-Output '  Grenzen dieser Pruefung:'
Write-Output '    - Geprueft werden VERWEISE, nicht Erreichbarkeit. Ob die Kette von T0 aus'
Write-Output '      erreichbar ist und ob ein Zyklus darin steckt, sagt erst mod700check recipes'
Write-Output '      gegen einen ConfigsDump, in dem unsere Modlets geladen waren (WP3.6).'
Write-Output '    - XPaths werden gegen die Vanilla-Datei gleichen Pfads unter Config geprueft, nicht gegen'
Write-Output '      den fertig gepatchten Stand. Ein XPath, der NUR auf einen Knoten eines'
Write-Output '      FRUEHEREN eigenen Modlets zeigt, gilt als gruen, sobald jede Kennung darin'
Write-Output '      von uns definiert ist - dass das frueher laedt, prueft die Ladereihenfolge,'
Write-Output '      nicht dieses Skript.'
Write-Output '    - Ein <conditional> wird in JEDEM Zweig geprueft, als waere er der aktive. Die'
Write-Output '      Bedingung liest die NCalc.dll des Spiels; xpath laeuft gegen Vanilla, und fuer'
Write-Output '      mod_loaded wird jede Belegung durchgerechnet. Ob es eine genannte Mod gibt,'
Write-Output '      prueft niemand. Bedingungen mit anderen Funktionen (version, gamepref, event'
Write-Output '      ...) werden gelesen, aber nicht ausgewertet. Ein XPath in einer Bedingung, der'
Write-Output '      auf das Element einer ANDEREN Mod zielt, ist rot - das Ziel muss in Vanilla'
Write-Output '      stehen.'
Write-Output '    - Fortschritts-Verweise (parent, progression_name) werden nur auf der obersten'
Write-Output '      Ebene gelesen, nicht in einem <conditional>. <include> wird nur gezaehlt.'
Write-Output '    - Gelesen werden XML-Dateien. Localization.csv prueft mod700check localization.'

if ($unresolved.Count -gt 0) {
    Write-Output ''
    Write-Output "== Ergebnis: $($unresolved.Count) rot -> RED =="
    exit 1
}

Write-Output ''
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
