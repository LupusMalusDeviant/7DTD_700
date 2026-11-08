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
    # Vanilla Data/Config. Ohne Angabe aus SDTD_PATH.
    [string]$Vanilla
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

if (-not $Vanilla) {
    if (-not $env:SDTD_PATH) {
        Write-Output 'kette-pruefen: SDTD_PATH ist nicht gesetzt - uebersprungen, KEIN GRUEN.'
        exit 0
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

Write-Output ("  eigene Rezepte: {0}, davon werkzeuggebunden: {1}" -f $recipeCount, $toolGated)
Write-Output ("  eingehaengte Zutaten: {0}, Reparaturwerkzeuge: {1}, umgebogene Verweise: {2}" -f $appendedTotal, $repairRefs, $rewiredRefs)
Write-Output ("  unaufgeloeste Verweise: {0}" -f $unresolved.Count)

foreach ($problem in $unresolved) { Write-Output "  [ROT]  $problem" }

Write-Output ''
Write-Output '  Grenzen dieser Pruefung:'
Write-Output '    - Geprueft werden VERWEISE, nicht Erreichbarkeit. Ob die Kette von T0 aus'
Write-Output '      erreichbar ist und ob ein Zyklus darin steckt, sagt erst mod700check recipes'
Write-Output '      gegen einen ConfigsDump, in dem unsere Modlets geladen waren (WP3.6).'
Write-Output '    - Ob der XML-Patcher des Spiels unsere XPaths trifft, steht hier nicht.'

if ($unresolved.Count -gt 0) {
    Write-Output ''
    Write-Output "== Ergebnis: $($unresolved.Count) rot -> RED =="
    exit 1
}

Write-Output ''
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
