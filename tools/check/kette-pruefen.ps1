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
    [string]$Vanilla
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
    $Vanilla = Join-Path $env:SDTD_PATH 'Data\Config'
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

Write-Output '== kette-pruefen =='
Write-Output "  Vanilla: $Vanilla"

$defined = @{}
foreach ($file in @('items.xml', 'blocks.xml')) {
    $path = Join-Path $Vanilla $file
    if (-not (Test-Path $path)) { throw "kette-pruefen: $path fehlt." }
    $matched = Select-String -Path $path -Pattern '<(item|block) name="([^"]+)"' -AllMatches
    foreach ($m in $matched) {
        foreach ($g in $m.Matches) { $defined[$g.Groups[2].Value] = 'vanilla' }
    }
}
$vanillaCount = $defined.Count

foreach ($path in $Gegenstaende) {
    if (-not (Test-Path $path)) { continue }
    $matched = Select-String -Path $path -Pattern '<item name="([^"]+)"' -AllMatches
    foreach ($m in $matched) {
        foreach ($g in $m.Matches) { $defined[$g.Groups[1].Value] = 'unser' }
    }
}

foreach ($path in $Bloecke) {
    if (-not (Test-Path $path)) { continue }
    $matched = Select-String -Path $path -Pattern '<block name="([^"]+)"' -AllMatches
    foreach ($m in $matched) {
        foreach ($g in $m.Matches) { $defined[$g.Groups[1].Value] = 'unser' }
    }
}

Write-Output ("  Definitionen: {0} aus Vanilla, {1} eigene" -f $vanillaCount, ($defined.Count - $vanillaCount))

$unresolved = @()
$recipeCount = 0
$toolGated = 0
$appendedTotal = 0

foreach ($path in $Rezepte) {
    if (-not (Test-Path $path)) { continue }
    $xml = [xml](Get-Content $path -Raw)
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
    $xml = [xml](Get-Content $path -Raw)
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
    $xml = [xml](Get-Content $path -Raw)
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
    $xml = [xml](Get-Content $path -Raw)
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
# ContainsKey und nicht '-not $Patches': eine Gegenprobe, die ABSICHTLICH keine Patch-Datei
# prueft, uebergibt @() - und ein leeres Feld ist in PowerShell falsch, waere also wieder in
# die Suche unter mod/ gelaufen. Drei bestehende Gegenproben sind beim ersten Lauf genau
# daran rot geworden: sie haben die echten Mod-Dateien gegen das Test-Vanilla gehalten.
if (-not $PSBoundParameters.ContainsKey('Patches')) {
    $Patches = @(Get-ChildItem (Join-Path $repoRoot 'mod') -Recurse -Filter '*.xml' |
        Where-Object { $_.FullName -match '\\Config\\' -and $_.FullName -notmatch '700_10_Purge' } |
        Select-Object -ExpandProperty FullName)
}
foreach ($path in $Patches) {
    if (-not $path -or -not (Test-Path $path)) { continue }
    $name = [IO.Path]::GetFileName($path)
    $vanillaPath = Join-Path $Vanilla $name
    # XUi-Dateien liegen in Vanilla in Unterordnern (XUi_InGame) und tragen dort denselben
    # Namen wie andere; Localization.csv ist kein XML. Beides bleibt aussen vor und wird
    # gezaehlt, nicht stillschweigend uebersprungen.
    if (-not (Test-Path $vanillaPath)) { continue }
    if (-not $vanillaDocs.ContainsKey($name)) {
        $vanillaDocs[$name] = [xml](Get-Content $vanillaPath -Raw)
    }
    $vdoc = $vanillaDocs[$name]
    $xml = [xml](Get-Content $path -Raw)
    foreach ($node in $xml.DocumentElement.ChildNodes) {
        if ($node.NodeType -ne 'Element') { continue }
        # get_Name() UND NICHT .Name. PowerShells XML-Adapter legt die XML-Attribute als
        # Eigenschaften ueber das Objekt, und ein Attribut 'name' ueberdeckt dabei die
        # Eigenschaft 'Name' des Elements. Bei <setattribute name="hidden" xpath="...">
        # liefert $node.Name darum "hidden" statt "setattribute" - der Patch faellt durch
        # die Verb-Liste und die ganze Datei bleibt ungeprueft, ohne eine Zeile Ausgabe.
        # Genau so ist mod/700_50_Fortschritt/Config/progression.xml beim ersten Lauf mit
        # ihren 20 Patches unbemerkt uebersprungen worden (WP7.1). Ein Methodenaufruf geht
        # am Adapter vorbei.
        if ($patchVerbs -notcontains $node.get_Name()) { continue }
        $xp = $node.GetAttribute('xpath')
        if (-not $xp) { continue }
        $xpathChecked++
        $hits = 0
        try { $hits = @($vdoc.SelectNodes($xp)).Count }
        catch {
            $unresolved += "XPath ist kein gueltiger Ausdruck: $xp  ($name)"
            continue
        }
        if ($hits -gt 0) { $xpathVanilla++; continue }
        # Kein Treffer in Vanilla: stammt das Ziel aus einem eigenen Modlet?
        $ownNames = @([regex]::Matches($xp, "@name='([^']+)'") | ForEach-Object { $_.Groups[1].Value })
        $eigen = @($ownNames | Where-Object { $defined[$_] -eq 'unser' })
        if ($ownNames.Count -gt 0 -and $eigen.Count -eq $ownNames.Count) { $xpathOwn++; continue }
        $unresolved += "XPath trifft nichts: $xp  ($name)"
    }
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
    $pv = [xml](Get-Content $progVanillaPfad -Raw)
    foreach ($n in $pv.SelectNodes('//attribute | //skill | //perk | //crafting_skill | //book_group | //book')) {
        $nm = $n.GetAttribute('name')
        if ($nm) { $progPool[$nm] = 'vanilla' }
    }
    foreach ($path in $Patches) {
        if (-not $path -or -not (Test-Path $path)) { continue }
        if ([IO.Path]::GetFileName($path) -ne 'progression.xml') { continue }
        $xml = [xml](Get-Content $path -Raw)
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
Write-Output ("  geprueefte XPaths: {0} ({1} in Vanilla, {2} auf eigene Knoten)" -f $xpathChecked, $xpathVanilla, $xpathOwn)
Write-Output ("  Fortschritts-Verweise: {0}" -f $progRefs)
Write-Output ("  unaufgeloeste Verweise: {0}" -f $unresolved.Count)

foreach ($problem in $unresolved) { Write-Output "  [ROT]  $problem" }

Write-Output ''
Write-Output '  Grenzen dieser Pruefung:'
Write-Output '    - Geprueft werden VERWEISE, nicht Erreichbarkeit. Ob die Kette von T0 aus'
Write-Output '      erreichbar ist und ob ein Zyklus darin steckt, sagt erst mod700check recipes'
Write-Output '      gegen einen ConfigsDump, in dem unsere Modlets geladen waren (WP3.6).'
Write-Output '    - XPaths werden gegen die Vanilla-Datei gleichen Namens geprueft, nicht gegen'
Write-Output '      den fertig gepatchten Stand. Ein XPath, der NUR auf einen Knoten eines'
Write-Output '      FRUEHEREN eigenen Modlets zeigt, gilt als gruen, sobald jede Kennung darin'
Write-Output '      von uns definiert ist - dass das frueher laedt, prueft die Ladereihenfolge,'
Write-Output '      nicht dieses Skript.'
Write-Output '    - Geprueft wird der ERSTE Knoten unter <config>. Patches, die in einem'
Write-Output '      <conditional> stecken, sieht diese Pruefung nicht; das Projekt benutzt'
Write-Output '      bisher keines.'
Write-Output '    - Dateien, die Vanilla unter diesem Namen nicht hat (XUi_InGame, Localization.csv),'
Write-Output '      bleiben aussen vor.'

if ($unresolved.Count -gt 0) {
    Write-Output ''
    Write-Output "== Ergebnis: $($unresolved.Count) rot -> RED =="
    exit 1
}

Write-Output ''
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
