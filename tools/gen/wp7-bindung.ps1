#Requires -Version 5.1
# wp7-bindung.ps1 — erzeugt die Zeilen fuer WP7.5 (D70): unsere Rezepte an
# Handwerks-Stufen binden, die Fertigkeitshefte einsortieren, Papier umdeuten.
#
# WAS DAS SKRIPT WEISS, WEIL ES GEMESSEN IST (Befund WP7-fertigkeitsbaeume §8):
#
#   1. Ein Rezept ist bindbar, sobald seine tags 'learnable' enthalten. Der Lader
#      (RecipesFromXml.LoadRecipies) haengt den REZEPTNAMEN an die tags an - aber nur,
#      wenn das Rezept ueberhaupt ein tags-Attribut hat. Ohne tags traegt ein Rezept
#      also auch seinen eigenen Namen nicht, und keine Zeile RecipeTagUnlocked oder
#      CraftingTier trifft es: es ist offen und entsteht immer in der untersten
#      Qualitaet.
#
#   2. Eine Handwerks-Stufe steigt NUR durch ihr Fertigkeitsheft (AddProgressionLevel
#      im Gegenstand). Das Handwerksfenster hat keinen Kaufweg. Eine gebundene Stufe
#      ohne Heft waere eine Sackgasse.
#
#   3. 'learnable' ohne eine Zeile RecipeTagUnlocked, die das Rezept trifft, heisst:
#      nie herstellbar. Darum prueft das Skript fuer jedes gebundene Rezept, dass genau
#      eine lebende Stufe es freischaltet und dass der Level erreichbar ist.
#
# DIE REGEL (vom Nutzer entschieden, D70): 'Vanillas Linie' - jedes Rezept so, wie
# Vanilla sein Gegenstueck behandelt. Stufe und Level werden aus dem Build GELESEN,
# nicht hier getippt. Die einzige Setzung ist der Platz des Webstuhls.
#
# Aufruf:
#   powershell -File tools/gen/wp7-bindung.ps1 -Spiel <pfad>
# Schreibt nach tools/gen/out/:
#   wp7-bindung-recipes.xml       GANZE Datei mod/700_50_Fortschritt/Config/recipes.xml
#   wp7-bindung-progression.xml   Zeilen fuer mod/700_50_Fortschritt/Config/progression.xml
#   wp7-bindung-texte.csv         Localization-Zeilen ohne Kopfzeile
#   wp7-bindung-denylist.txt      Freigaben fuer tools/check/denylist.txt
#   wp7-bindung-keys.txt          Schluessel fuer tools/check/vanilla-keys.txt

[CmdletBinding()]
param(
    [string] $Spiel = $env:SDTD_PATH,
    [string] $Repo,
    [string] $AusOrdner
)

$ErrorActionPreference = 'Stop'

if (-not $Spiel) { throw "Kein Spielpfad: SDTD_PATH setzen oder -Spiel angeben." }
$hier = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Repo) { $Repo = Split-Path -Parent (Split-Path -Parent $hier) }
if (-not $AusOrdner) { $AusOrdner = Join-Path $hier 'out' }
if (-not (Test-Path $AusOrdner)) { New-Item -ItemType Directory -Path $AusOrdner | Out-Null }

$cfg = Join-Path $Spiel 'Data\Config'
$pfade = @{
    prog    = Join-Path $cfg 'progression.xml'
    rezepte = Join-Path $cfg 'recipes.xml'
    items   = Join-Path $cfg 'items.xml'
    loc     = Join-Path $cfg 'Localization.csv'
    purgeRezepte = Join-Path $Repo 'mod\700_10_Purge\Config\recipes.xml'
    unserProg    = Join-Path $Repo 'mod\700_50_Fortschritt\Config\progression.xml'
    unserItems   = Join-Path $Repo 'mod\700_30_Ausruestung\Config\items.xml'
    unserLoc     = Join-Path $Repo 'mod\700_90_Sprache\Config\Localization.csv'
}
foreach ($f in $pfade.Values) { if (-not (Test-Path $f)) { throw "Nicht gefunden: $f" } }
$unsereRezeptDateien = @(
    'mod\700_20_Material\Config\recipes.xml',
    'mod\700_30_Ausruestung\Config\recipes.xml',
    'mod\700_40_Bauen\Config\recipes.xml',
    'mod\700_45_Leben\Config\recipes.xml'   # seit D197 (2026-11-23); 45 laedt vor 50
)
# NICHT hier: 700_75_Magie. Es laedt NACH 700_50, ein setattribute aus dieser Datei traefe
# seine Rezepte noch nicht. Die Magie-Rezepte tragen ihre Marken darum selbst (Review 34,
# Befund 3 - siehe die D-Zeile dazu im GDD).

# ===========================================================================
# 1  Vanillas Linie: Rezepte mit Vanilla-Namen. Stufe, Level und Marken kommen aus
#    dem Build - hier steht nur, WELCHE Rezepte gemeint sind.
# ===========================================================================
$vanillaLinie = @(
    'meleeWpnBladeT1HuntingKnife', 'meleeWpnBladeT3Machete',
    'meleeWpnSpearT1IronSpear', 'meleeWpnSpearT3SteelSpear',
    'meleeWpnKnucklesT1IronKnuckles', 'meleeWpnKnucklesT3SteelKnuckles',
    'meleeWpnSledgeT1IronSledgehammer', 'meleeWpnSledgeT3SteelSledgehammer',
    'meleeWpnClubT3SteelClub',
    'meleeToolAxeT1IronFireaxe', 'meleeToolAxeT2SteelAxe'
)

# ===========================================================================
# 2  Ruestung (D59, D61): unsere drei Stufen sitzen auf Vanillas drei Gewichtsklassen.
#    'Anzeige' ist der name_key der Vanilla-Anzeigezeile, deren tote Garnituren wir
#    durch unsere Teile ersetzen. Freischalt-Level und Qualitaetsleiter werden von der
#    Vanilla-Zeile abgelesen, die den 'Meister' fuehrt.
# ===========================================================================
$stufe = 'craftingArmor'
$ruestung = @(
    @{ Anzeige = 'armorT2'; Meister = 'armorLightMaster';  De = 'Wolle und Leder'; En = 'Wool and leather'
       Symbol = 'itm700_lederkappe'
       Teile = @('itm700_lederwams', 'itm700_lederkappe', 'itm700_wollhandschuhe', 'itm700_wickelschuhe') }
    @{ Anzeige = 'armorT3'; Meister = 'armorMediumMaster'; De = 'Gambeson';        En = 'Gambeson'
       Symbol = 'itm700_stepphaube'
       Teile = @('itm700_gambeson', 'itm700_stepphaube', 'itm700_stepphandschuhe', 'itm700_steppschuhe') }
    @{ Anzeige = 'armorT4'; Meister = 'armorHeavyMaster';  De = 'Kettenzeug';      En = 'Mail'
       Symbol = 'itm700_spangenhelm'
       Teile = @('itm700_kettenhemd', 'itm700_spangenhelm', 'itm700_armschienen', 'itm700_beinschienen') }
)
# T0 bleibt Vanillas armorPrimitive* (D61), nur der Name der Anzeigezeile wird unserer.
$ruestungT0 = @{ Anzeige = 'armorT1'; De = 'Lumpen'; En = 'Rags' }

# ===========================================================================
# 3  Werkstatt: der Webstuhl nimmt den ERSTEN Platz, den der Purge NACH der Werkbank
#    freigemacht hat - der Webstuhl entsteht an der Werkbank und kann nicht vor ihr
#    kommen. Das ist die eine Setzung dieses Pakets. 'Symbol' ist die Werkbank, weil
#    der Webstuhl bis Phase 2 ihr Modell traegt und kein eigenes Bild hat.
# ===========================================================================
$werkstatt = @{
    Rezept = 'blk700_webstuhl'; Stufe = 'craftingWorkstations'; Platz = 'toolChickenCoopLamp'
    Symbol = 'workbench'; De = 'Stufe 1: Webstuhl'; En = 'Tier 1: Loom'
}

# ===========================================================================
# 4  Offen - mit dem Grund. Jedes unserer Rezepte steht in genau einer Tabelle;
#    ein neues ohne Zeile bricht den Lauf ab.
# ===========================================================================
$offen = [ordered]@{
    'itm700_luppe'           = 'Materialkette: Vanilla laesst Schmiedeeisen offen; die Schranke ist der Blasebalg'
    'resourceForgedIron'     = 'Materialkette: in Vanilla nicht learnable; die Schranke ist der Amboss'
    'resourceForgedSteel'    = 'Materialkette: in Vanilla nicht learnable; die Schranke ist der Schmelztiegel'
    'itm700_klinge'          = 'Materialkette: Zwischenstueck, die Schranke ist der Amboss'
    'itm700_schleifstein'    = 'D60: ueberall herstellbar; Vanillas resourceRepairKit ist nicht learnable'
    'itm700_schmiedeflicken' = 'D60: die Schranke ist die Esse; Vanillas resourceRepairKit ist nicht learnable'
    'resourceSewingKit'      = 'Werkstoff ohne Vanilla-Rezept'
    'itm700_bogenzeug'       = 'D91: ueberall herstellbar wie das Naehzeug; Vanillas resourceRepairKit ist nicht learnable'
    'itm700_steppbahn'       = 'Zwischenstueck; die Schranke ist der Webstuhl'
    'blk700_holzfeuer'       = 'T0-Feuerstelle; Vanillas campfire ist nicht learnable'
    'logWallLeft'            = 'Bauteil; Vanilla bindet keine Bauteile, und eine Stufe fuers Bauen gibt es nicht'
    'logWallRight'           = 'Bauteil'
    'logWallLeft2'           = 'Bauteil'
    'logWallRight2'          = 'Bauteil'
    'logWallLeftSpikes'      = 'Bauteil'
    'logWallRightSpikes'     = 'Bauteil'
    'logWallPillar'          = 'Bauteil'
    'logWallPillarCap'       = 'Bauteil'
    'doorWoodLargeGate'      = 'Bauteil'
    'itm700_eichenrindensud' = 'D197: frei, gegen Fieber braucht es keine Stufe'
    'itm700_honigsalbe'      = 'D197: frei wie Vanillas Salbenverband'
    'itm700_mehl'            = 'D202: frei wie Vanillas Maismehl (nicht learnable)'
}

# ===========================================================================
# 4b Eigene Linie: Rezepte ohne Vanilla-Gegenstueck, die an einer Vanilla-Stufe haengen,
#    weil WIR dort eine Zeile RecipeTagUnlocked anhaengen (700_50 progression.xml). Stufe
#    und Level werden aus dieser Zeile GELESEN; hier steht nur, welches Rezept und warum.
#    Seit Review 34 (2026-11-23): vorher stand der Theriak von Hand in der erzeugten Datei
#    und waere beim naechsten Lauf verschwunden.
# ===========================================================================
$eigeneLinie = [ordered]@{
    'itm700_theriak' = 'neben Vanillas Kraeutersud, der Platz des gesperrten Antibiotikums (D197)'
    'itm700_fladenbrot' = 'der Platz des gesperrten Maisbrots (D202)'
    'itm700_met'        = 'neben Vanillas Bier (D202)'
}
# Vorbild (Review 36, 2026-11-24): ein Rezept, das ein Vanilla-Rezept nachbildet, traegt dessen
# GANZE tags - mit 'learnable' auch die Marken fuer Perks und Werkbank (perkMasterChef,
# cookingPotFood, chemStationCrafting). Vorher bekam es nur 'learnable', und Meisterkoch und
# die Boni von Kochtopf und Kraeuterkueche griffen nicht (D202: "wie Vanilla sein Gegenstueck
# behandelt"). Geprueft wird: das Vorbild hat genau EIN Rezept, dieselbe Werkbank und dasselbe
# Werkzeug wie unseres, und seine tags enthalten 'learnable'. Ohne Vorbild: nur 'learnable'.
$eigeneLinieVorbild = @{
    'itm700_fladenbrot' = 'foodCornBread'
    'itm700_met'        = 'drinkJarBeer'
}

# ===========================================================================
# 5  Hefte und Papier
# ===========================================================================
$heftDe     = 'Lehrblatt: {0}'
$heftEn     = 'Lesson: {0}'
$heftDeDesc = 'Ein Blatt aus der Werkstatt eines anderen. Wer es liest, steigt in „{0}“ um eine Stufe.'
$heftEnDesc = 'A leaf from another man''s workshop. Reading it raises “{0}” by one level.'
$papier = @{
    Name = 'resourcePaper'; De = 'Pergament'; En = 'Parchment'
    DeDesc = 'Geschabte und gespannte Tierhaut. Trägt Abschriften und Lehrblätter — und bleibt übrig, wenn man eines zerlegt.'
    EnDesc = 'Scraped and stretched hide. It carries transcripts and lessons — and is what remains when one is taken apart.'
}

# ===========================================================================
# Einlesen
# ===========================================================================
$prog  = [xml](Get-Content $pfade.prog -Raw)
$vrec  = [xml](Get-Content $pfade.rezepte -Raw)
$vitem = [xml](Get-Content $pfade.items -Raw)
$uitem = [xml](Get-Content $pfade.unserItems -Raw)

$loc = @{}
Import-Csv $pfade.loc -Encoding UTF8 | ForEach-Object { $loc[$_.Key] = 1 }
$unserLoc = @{}
Import-Csv $pfade.unserLoc -Encoding UTF8 | ForEach-Object { $unserLoc[$_.Key] = $_ }

$rezeptWeg = @{}
foreach ($m in [regex]::Matches((Get-Content $pfade.purgeRezepte -Raw), "recipe\[@name='([^']+)'\]")) { $rezeptWeg[$m.Groups[1].Value] = 1 }

$unserProgRoh = Get-Content $pfade.unserProg -Raw
$stufeVerborgen = @{}
foreach ($m in [regex]::Matches($unserProgRoh, "name=`"hidden`" xpath=`"/progression/crafting_skills/crafting_skill\[@name='([^']+)'\]")) { $stufeVerborgen[$m.Groups[1].Value] = 1 }

$unsereRezepte = [ordered]@{}
foreach ($d in $unsereRezeptDateien) {
    $doc = [xml](Get-Content (Join-Path $Repo $d) -Raw)
    foreach ($r in $doc.SelectNodes('//recipe')) {
        $n = $r.GetAttribute('name')
        if ($unsereRezepte.Contains($n)) { throw "Rezept '$n' steht zweimal in unseren Dateien." }
        $unsereRezepte[$n] = @{ Datei = $d; Knoten = $r }
    }
}

# Marke -> Liste (Stufe, Level) ueber alle Handwerks-Stufen
$freischalter = @{}
foreach ($cs in $prog.SelectNodes('//crafting_skill')) {
    foreach ($p in $cs.SelectNodes("effect_group/passive_effect[@name='RecipeTagUnlocked']")) {
        $lvl = [int](($p.GetAttribute('level') -split ',')[0])
        foreach ($t in ($p.GetAttribute('tags') -split ',')) {
            $t = $t.Trim(); if (-not $t) { continue }
            if (-not $freischalter[$t]) { $freischalter[$t] = @() }
            $freischalter[$t] += @{ Stufe = $cs.GetAttribute('name'); Level = $lvl; Max = [int]$cs.GetAttribute('max_level') }
        }
    }
}

$keyNutzer = @{}
foreach ($n in $prog.SelectNodes('//*[@name_key]')) {
    foreach ($k in ($n.GetAttribute('name_key') -split ',')) { $k = $k.Trim(); if ($k) { $keyNutzer[$k] = 1 + [int]$keyNutzer[$k] } }
}

$fehler = @()

# ===========================================================================
# Pruefen: jedes unserer Rezepte steht in genau einer Tabelle
# ===========================================================================
$zuordnung = @{}
function Ordne([string] $name, [string] $wo) {
    if ($script:zuordnung[$name]) { $script:fehler += "Rezept '$name' steht in zwei Tabellen ($($script:zuordnung[$name]) und $wo)." }
    $script:zuordnung[$name] = $wo
}
foreach ($n in $vanillaLinie) { Ordne $n 'Vanillas Linie' }
foreach ($r in $ruestung) { foreach ($n in $r.Teile) { Ordne $n 'Ruestung' } }
Ordne $werkstatt.Rezept 'Werkstatt'
foreach ($n in $offen.Keys) { Ordne $n 'offen' }
foreach ($n in $eigeneLinie.Keys) { Ordne $n 'Eigene Linie' }
foreach ($n in $unsereRezepte.Keys) { if (-not $zuordnung[$n]) { $fehler += "Rezept '$n' ($($unsereRezepte[$n].Datei)) hat keine Entscheidung: weder gebunden noch offen." } }
foreach ($n in $zuordnung.Keys)     { if (-not $unsereRezepte.Contains($n)) { $fehler += "Rezept '$n' steht in der Tabelle '$($zuordnung[$n])', aber in keiner unserer Rezeptdateien." } }

# Die Bindung lebt in 700_50. Ein Rezept, das selbst schon tags traegt, haette zwei Quellen.
foreach ($n in $unsereRezepte.Keys) {
    if ($unsereRezepte[$n].Knoten.HasAttribute('tags')) { $fehler += "Rezept '$n' traegt schon ein tags-Attribut in $($unsereRezepte[$n].Datei). Die Bindung steht in 700_50_Fortschritt - eine Quelle, nicht zwei." }
}

# ===========================================================================
# Pruefen und sammeln: Vanillas Linie
# ===========================================================================
$bindungen = @()   # @{ Rezept; Marken; Stufe; Level; Quelle }
foreach ($n in $vanillaLinie) {
    $vr = @($vrec.SelectNodes("//recipe[@name='$n']"))
    if ($vr.Count -eq 0) { $fehler += "$n`: Vanilla hat kein Rezept dieses Namens - das ist nicht 'Vanillas Linie'."; continue }
    $tagSaetze = @($vr | ForEach-Object { $_.GetAttribute('tags') } | Select-Object -Unique)
    if ($tagSaetze.Count -ne 1) { $fehler += "$n`: Vanilla fuehrt $($vr.Count) Rezepte mit verschiedenen Marken ($($tagSaetze -join ' | '))."; continue }
    $tags = $tagSaetze[0]
    if ((($tags -split ',') | ForEach-Object { $_.Trim() }) -notcontains 'learnable') { $fehler += "$n`: Vanillas Rezept ist nicht learnable (tags='$tags')."; continue }
    $fr = @($freischalter[$n])
    if ($fr.Count -ne 1) { $fehler += "$n`: $($fr.Count) Handwerks-Stufen schalten diese Marke frei, erwartet ist genau eine."; continue }
    $bindungen += @{ Rezept = $n; Marken = $tags; Stufe = $fr[0].Stufe; Level = $fr[0].Level; Max = $fr[0].Max; Quelle = 'Vanillas Rezept und Vanillas Stufe' }
}

# ===========================================================================
# Pruefen und sammeln: Eigene Linie - genau EINE unserer Zeilen RecipeTagUnlocked nennt
# das Rezept, und sie haengt an einer lebenden Vanilla-Stufe.
# ===========================================================================
$unserProgXml = [xml]$unserProgRoh
foreach ($n in $eigeneLinie.Keys) {
    $treffer = @()
    foreach ($a in $unserProgXml.SelectNodes("//append[contains(@xpath, 'crafting_skill[@name=')]")) {
        $m = [regex]::Match($a.GetAttribute('xpath'), "crafting_skill\[@name='([^']+)'\]")
        if (-not $m.Success) { continue }
        foreach ($p in $a.SelectNodes("passive_effect[@name='RecipeTagUnlocked']")) {
            if ((($p.GetAttribute('tags') -split ',') | ForEach-Object { $_.Trim() }) -contains $n) {
                $treffer += @{ Stufe = $m.Groups[1].Value; Level = [int](($p.GetAttribute('level') -split ',')[0]) }
            }
        }
    }
    if ($treffer.Count -ne 1) { $fehler += "$n`: $($treffer.Count) unserer Zeilen RecipeTagUnlocked nennen das Rezept (700_50 progression.xml), erwartet ist genau eine."; continue }
    $sk = $prog.SelectSingleNode("//crafting_skill[@name='$($treffer[0].Stufe)']")
    if (-not $sk) { $fehler += "$n`: die Stufe '$($treffer[0].Stufe)' gibt es in Vanilla nicht."; continue }
    if ($stufeVerborgen[$treffer[0].Stufe]) { $fehler += "$n`: die Stufe '$($treffer[0].Stufe)' ist verborgen - das Rezept waere nie herstellbar."; continue }
    $max = [int]$sk.GetAttribute('max_level')
    if ($treffer[0].Level -gt $max) { $fehler += "$n`: Level $($treffer[0].Level) liegt ueber dem Hoechstwert $max der Stufe."; continue }
    $marken = 'learnable'
    $vorbild = $eigeneLinieVorbild[$n]
    if ($vorbild) {
        $vr = @($vrec.SelectNodes("/recipes/recipe[@name='$vorbild']"))
        if ($vr.Count -ne 1) { $fehler += "$n`: das Vorbild '$vorbild' hat $($vr.Count) Rezepte in Vanilla, erwartet ist genau eines."; continue }
        $unser = $unsereRezepte[$n].Knoten
        foreach ($attr in 'craft_area', 'craft_tool') {
            if ($vr[0].GetAttribute($attr) -cne $unser.GetAttribute($attr)) {
                $fehler += "$n`: $attr '$($unser.GetAttribute($attr))' passt nicht zum Vorbild '$vorbild' ('$($vr[0].GetAttribute($attr))') - seine Werkbank-Marken gaelten nicht."
            }
        }
        $marken = $vr[0].GetAttribute('tags')
        if ((($marken -split ',') | ForEach-Object { $_.Trim() }) -notcontains 'learnable') { $fehler += "$n`: die tags des Vorbilds '$vorbild' ('$marken') enthalten kein 'learnable'."; continue }
    }
    $quelle = if ($vorbild) { "$($eigeneLinie[$n]); tags wie $vorbild" } else { $eigeneLinie[$n] }
    $bindungen += @{ Rezept = $n; Marken = $marken; Stufe = $treffer[0].Stufe; Level = $treffer[0].Level; Max = $max; Quelle = $quelle }
}
foreach ($n in $eigeneLinieVorbild.Keys) { if (-not $eigeneLinie.Contains($n)) { $fehler += "Vorbild fuer '$n', aber '$n' steht nicht in der Eigenen Linie." } }

# ===========================================================================
# Pruefen und sammeln: Ruestung
# ===========================================================================
$stufeKnoten = $prog.SelectSingleNode("//crafting_skill[@name='$stufe']")
if (-not $stufeKnoten) { throw "Handwerks-Stufe '$stufe' gibt es nicht." }
$ruestungPlan = @()
foreach ($r in $ruestung) {
    $anz = @($stufeKnoten.SelectNodes("display_entry[@name_key='$($r.Anzeige)']"))
    if ($anz.Count -ne 1) { $fehler += "$stufe`: $($anz.Count) Anzeigezeilen mit name_key '$($r.Anzeige)', erwartet ist eine."; continue }
    $ue = @($anz[0].SelectNodes('unlock_entry'))
    if ($ue.Count -ne 1) { $fehler += "$($r.Anzeige): $($ue.Count) unlock_entry statt einem."; continue }
    $alt = @(($ue[0].GetAttribute('recipes') -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    if ($alt[0] -ne $r.Meister) { $fehler += "$($r.Anzeige): die Vanilla-Zeile beginnt mit '$($alt[0])', die Tabelle sagt '$($r.Meister)'." }
    # Wir ueberschreiben die Zeile. Das ist nur erlaubt, wenn nichts darin mehr lebt.
    $lebt = @($alt | Where-Object { $_ -ne $r.Meister -and @($vrec.SelectNodes("//recipe[@name='$_']")).Count -gt 0 -and -not $rezeptWeg[$_] })
    if ($lebt.Count) { $fehler += "$($r.Anzeige): die Zeile fuehrt noch lebende Rezepte ($($lebt -join ', ')) - sie zu ueberschreiben naehme sie aus der Anzeige." }

    $rtu = @($stufeKnoten.SelectNodes("effect_group/passive_effect[@name='RecipeTagUnlocked']") | Where-Object { (($_.GetAttribute('tags') -split ',') | ForEach-Object { $_.Trim() }) -contains $r.Meister })
    $ct  = @($stufeKnoten.SelectNodes("effect_group/passive_effect[@name='CraftingTier']")      | Where-Object { (($_.GetAttribute('tags') -split ',') | ForEach-Object { $_.Trim() }) -contains $r.Meister })
    if ($rtu.Count -ne 1 -or $ct.Count -ne 1) { $fehler += "$($r.Meister): $($rtu.Count) Freischalt- und $($ct.Count) Qualitaetszeilen statt je einer."; continue }

    foreach ($t in $r.Teile) {
        $it = $uitem.SelectSingleNode("//item[@name='$t']")
        if (-not $it) { $fehler += "$t`: kein Gegenstand dieses Namens in 700_30_Ausruestung."; continue }
        $e = $it.SelectSingleNode("property[@name='Extends']")
        if (-not $e -or $e.value -ne $r.Meister) { $fehler += "$t`: erbt von '$(if ($e) { $e.value })', die Tabelle stellt es unter '$($r.Meister)'." }
    }
    $sym = $uitem.SelectSingleNode("//item[@name='$($r.Symbol)']/property[@name='CustomIcon']")
    if (-not $sym) { $fehler += "$($r.Symbol): kein CustomIcon - die Anzeigezeile haette kein Bild."; continue }

    $lvl = [int](($rtu[0].GetAttribute('level') -split ',')[0])
    foreach ($t in $r.Teile) {
        $bindungen += @{ Rezept = $t; Marken = 'learnable'; Stufe = $stufe; Level = $lvl; Max = [int]$stufeKnoten.GetAttribute('max_level'); Quelle = "Vanillas Zeile fuer $($r.Meister)" }
    }
    $ruestungPlan += @{ Zeile = $r; Bild = $sym.value; Rtu = $rtu[0]; Ct = $ct[0] }
}
if (@($stufeKnoten.SelectNodes('effect_group')).Count -ne 1) { $fehler += "$stufe`: nicht genau ein effect_group - der append haette kein eindeutiges Ziel." }
foreach ($k in @($ruestungT0.Anzeige) + @($ruestung | ForEach-Object { $_.Anzeige })) {
    if (-not $loc[$k]) { $fehler += "Anzeige-Schluessel '$k' fehlt in Vanillas Localization.csv." }
    if ($keyNutzer[$k] -ne 1) { $fehler += "Anzeige-Schluessel '$k' wird $([int]$keyNutzer[$k]) Mal benutzt, erwartet ist einmal." }
}

# ===========================================================================
# Pruefen und sammeln: Werkstatt
# ===========================================================================
$w = $werkstatt
$wKnoten = $prog.SelectSingleNode("//crafting_skill[@name='$($w.Stufe)']")
$wPlan = $null
if (-not $wKnoten) { $fehler += "Handwerks-Stufe '$($w.Stufe)' gibt es nicht." }
elseif ($unsereRezepte.Contains($w.Rezept)) {
    $bereich = $unsereRezepte[$w.Rezept].Knoten.GetAttribute('craft_area')
    $leiter = @()
    foreach ($p in $wKnoten.SelectNodes("effect_group/passive_effect[@name='RecipeTagUnlocked']")) {
        $leiter += @{ Level = [int](($p.GetAttribute('level') -split ',')[0]); Marke = $p.GetAttribute('tags').Trim(); Zeile = $p }
    }
    $platz = @($leiter | Where-Object { $_.Marke -eq $w.Platz })
    $vor   = @($leiter | Where-Object { $_.Marke -eq $bereich })
    if ($platz.Count -ne 1) { $fehler += "$($w.Stufe): der Platz '$($w.Platz)' steht $($platz.Count) Mal in der Leiter." }
    elseif ($vor.Count -ne 1) { $fehler += "$($w.Stufe): die Werkbank des Rezepts ('$bereich') steht $($vor.Count) Mal in der Leiter." }
    else {
        if (-not $rezeptWeg[$w.Platz]) { $fehler += "$($w.Platz) lebt - sein Platz ist nicht frei." }
        if ($platz[0].Level -le $vor[0].Level) { $fehler += "$($w.Rezept) kaeme mit Level $($platz[0].Level) nicht NACH seiner Werkbank ($bereich, Level $($vor[0].Level))." }
        $frueher = @($leiter | Where-Object { $_.Level -gt $vor[0].Level -and $_.Level -lt $platz[0].Level -and $rezeptWeg[$_.Marke] })
        if ($frueher.Count) { $fehler += "Der erste freie Platz nach '$bereich' ist '$($frueher[0].Marke)' (Level $($frueher[0].Level)), nicht '$($w.Platz)'." }

        $ue = @($wKnoten.SelectNodes("display_entry/unlock_entry[@item='$($w.Platz)']"))
        if ($ue.Count -ne 1) { $fehler += "$($w.Platz): $($ue.Count) unlock_entry statt einem." }
        else {
            $anz = $ue[0].ParentNode
            $tier = [int]$ue[0].GetAttribute('unlock_tier')
            $bilder = @($anz.GetAttribute('icon') -split ',')
            $namen  = @($anz.GetAttribute('name_key') -split ',')
            if ($bilder[$tier - 1] -ne $w.Platz) { $fehler += "$($w.Platz): steht nicht an Stelle $tier der Bildliste ('$($anz.GetAttribute('icon'))')." }
            $nk = $namen[$tier - 1]
            if (-not $loc[$nk]) { $fehler += "Schluessel '$nk' fehlt in Vanillas Localization.csv." }
            if ($keyNutzer[$nk] -ne 1) { $fehler += "Schluessel '$nk' wird $([int]$keyNutzer[$nk]) Mal benutzt." }
            if (@($prog.SelectNodes("//display_entry[@name_key='$($anz.GetAttribute('name_key'))']")).Count -ne 1) { $fehler += "Die name_key-Liste der Anzeigezeile ist nicht eindeutig - sie ist der Anker des XPath." }
            $vr = @($vrec.SelectNodes("//recipe[@name='$($w.Platz)']"))
            $tagSaetze = @($vr | ForEach-Object { $_.GetAttribute('tags') } | Select-Object -Unique)
            if ($tagSaetze.Count -ne 1) { $fehler += "$($w.Platz): $($tagSaetze.Count) verschiedene Marken-Saetze in Vanilla." }
            elseif ($vr[0].GetAttribute('craft_area') -ne $bereich) { $fehler += "$($w.Platz) entsteht in Vanilla an '$($vr[0].GetAttribute('craft_area'))', unser Rezept an '$bereich' - die Marken waeren nicht uebertragbar." }
            else {
                $bilder[$tier - 1] = $w.Symbol
                $wPlan = @{ Anzeige = $anz; Tier = $tier; Bilder = ($bilder -join ','); NameKey = $nk; Level = $platz[0].Level; Zeile = $platz[0].Zeile }
                $bindungen += @{ Rezept = $w.Rezept; Marken = $tagSaetze[0]; Stufe = $w.Stufe; Level = $platz[0].Level; Max = [int]$wKnoten.GetAttribute('max_level'); Quelle = "Platz und Marken von $($w.Platz), der Purge hat ihn freigemacht" }
            }
        }
    }
}

# ===========================================================================
# Pruefen: keine Sackgasse
# ===========================================================================
foreach ($b in $bindungen) {
    if ($stufeVerborgen[$b.Stufe]) { $fehler += "$($b.Rezept) haengt an '$($b.Stufe)', und die ist verborgen (tot)." }
    if ($b.Level -gt $b.Max)       { $fehler += "$($b.Rezept) verlangt Level $($b.Level), '$($b.Stufe)' endet bei $($b.Max)." }
}

# ===========================================================================
# Pruefen und sammeln: Hefte
# ===========================================================================
$hefte = @()
foreach ($i in $vitem.SelectNodes("//item[substring(@name, string-length(@name) - 12) = 'SkillMagazine']")) {
    $u = $i.SelectSingleNode("property[@name='Unlocks']")
    if (-not $u) { continue }                              # masterSkillMagazine, adminSkillMagazine
    $n = $i.GetAttribute('name'); $ziel = $u.value
    if (-not $prog.SelectSingleNode("//crafting_skill[@name='$ziel']")) { $fehler += "$n hebt '$ziel', und das ist keine Handwerks-Stufe."; continue }
    $lv = @($i.SelectNodes("effect_group/triggered_effect[@action='AddProgressionLevel' and @progression_name='$ziel']"))
    if ($lv.Count -eq 0) { $fehler += "$n fuehrt kein AddProgressionLevel auf '$ziel'." }
    $dk = $i.SelectSingleNode("property[@name='DescriptionKey']")
    $hefte += @{ Name = $n; Ziel = $ziel; Tot = [bool]$stufeVerborgen[$ziel]; DescKey = $(if ($dk) { $dk.value } else { $n + 'Desc' }) }
}
foreach ($cs in $prog.SelectNodes('//crafting_skill')) {
    $n = $cs.GetAttribute('name')
    $h = @($hefte | Where-Object { $_.Ziel -eq $n })
    if ($stufeVerborgen[$n]) { continue }
    if ($h.Count -ne 1) { $fehler += "Die lebende Stufe '$n' hat $($h.Count) Hefte. Ohne Heft steigt sie nie - jedes gebundene Rezept darunter waere eine Sackgasse." ; continue }
    foreach ($k in @($h[0].Name, $h[0].DescKey)) { if (-not $loc[$k]) { $fehler += "$($h[0].Name): Schluessel '$k' fehlt in Vanillas Localization.csv." } }
    if (-not $unserLoc[$n + 'Name']) { $fehler += "Die Stufe '$n' hat in unserer Localization.csv keinen Namen ($($n)Name) - das Heft bekaeme keinen." }
}
foreach ($k in @($papier.Name, ($papier.Name + 'Desc'))) { if (-not $loc[$k]) { $fehler += "Papier: Schluessel '$k' fehlt in Vanillas Localization.csv." } }
if (-not $vitem.SelectSingleNode("//item[@name='$($papier.Name)']")) { $fehler += "Papier: Gegenstand '$($papier.Name)' gibt es nicht." }

if ($fehler.Count -gt 0) {
    foreach ($f in $fehler) { Write-Output "FEHLER: $f" }
    throw "Die Tabellen passen nicht zum Build, zum Purge oder zu unseren Dateien. Nichts geschrieben."
}

# ===========================================================================
# Erzeugen
# ===========================================================================
function Zeile([string] $key, [string] $datei, [string] $typ, [string] $en, [string] $de) {
    $enQ = '"' + $en.Replace('"', '""') + '"'
    $deQ = '"' + $de.Replace('"', '""') + '"'
    return "$key,$datei,$typ,,,,$enQ,,$deQ,,,,,,,,,,,"
}
$cz = @(); $kz = @(); $dz = @()
function Text([string] $key, [string] $datei, [string] $typ, [string] $en, [string] $de) {
    $script:cz += Zeile $key $datei $typ $en $de
    $script:kz += $key
}

# --- recipes.xml (ganze Datei) ---------------------------------------------
$rz = @()
$rz += '<?xml version="1.0" encoding="UTF-8" ?>'
$rz += '<config>'
$rz += "`t<!-- 700_50_Fortschritt / recipes.xml"
$rz += "`t     F-21 Rezeptbindung, Plan-0001 WP7.5, D70"
$rz += ''
$rz += "`t     ERZEUGT von tools/gen/wp7-bindung.ps1 - nicht von Hand aendern."
$rz += ''
$rz += "`t     Jede Zeile gibt einem unserer Rezepte ein tags-Attribut. Das ist die ganze"
$rz += "`t     Bindung: mit 'learnable' ist das Rezept gesperrt, bis eine Handwerks-Stufe"
$rz += "`t     seine Marke freischaltet - und der Lader haengt den Rezeptnamen von selbst an"
$rz += "`t     die tags, sobald es ein tags-Attribut gibt. Erst dadurch treffen auch die"
$rz += "`t     Qualitaetszeilen (CraftingTier) unsere Rezepte."
$rz += ''
$rz += "`t     Die Rezepte selbst stehen in 700_20, 700_30, 700_40 und 700_45 und tragen dort KEINE"
$rz += "`t     tags: fuer sie hat die Bindung eine Quelle, diese Datei. Fehlt dieses Modlet,"
$rz += "`t     sind sie offen - nichts bricht."
$rz += ''
$rz += "`t     Ausnahme (D201): 700_75_Magie laedt NACH diesem Modlet, ein setattribute"
$rz += "`t     von hier traefe seine Rezepte noch nicht. Es bindet sie darum selbst"
$rz += "`t     (tags=`"learnable`" im Rezept); fehlt dieses Modlet, bleiben sie gesperrt."
$rz += ''
$rz += "`t     $($bindungen.Count) gebunden, $($offen.Count) bewusst offen (Liste und Gruende im Erzeuger). -->"
$rz += ''
foreach ($b in ($bindungen | Sort-Object { $_.Stufe }, { $_.Level }, { $_.Rezept })) {
    $rz += "`t<setattribute name=`"tags`" xpath=`"/recipes/recipe[@name='$($b.Rezept)']`">$($b.Marken)</setattribute>   <!-- $($b.Stufe) ab $($b.Level): $($b.Quelle) -->"
}
$rz += '</config>'

# --- progression.xml (Bruchstueck) -----------------------------------------
$pz = @()
$pz += "`t<!-- ===== WP7.5 Bindung (D70) - ERZEUGT von tools/gen/wp7-bindung.ps1, nicht von Hand aendern ===== -->"
$pz += ''
$alleTeile = @($ruestung | ForEach-Object { $_.Teile }) -join ','
$rtu = $ruestungPlan[0].Rtu; $ct = $ruestungPlan[0].Ct
$pz += "`t<!-- Ruestung: unsere zwoelf Teile bekommen eigene Zeilen neben Vanillas. Level und"
$pz += "`t     Qualitaetsleiter sind von der Vanilla-Zeile abgelesen, die die drei Meister fuehrt. -->"
$pz += "`t<append xpath=`"/progression/crafting_skills/crafting_skill[@name='$stufe']/effect_group`">"
$pz += "`t`t<passive_effect name=`"RecipeTagUnlocked`" operation=`"$($rtu.GetAttribute('operation'))`" level=`"$($rtu.GetAttribute('level'))`" value=`"$($rtu.GetAttribute('value'))`" tags=`"$alleTeile`"/>"
$pz += "`t`t<passive_effect name=`"CraftingTier`" operation=`"$($ct.GetAttribute('operation'))`" level=`"$($ct.GetAttribute('level'))`" value=`"$($ct.GetAttribute('value'))`" tags=`"$alleTeile`"/>"
$pz += "`t</append>"
$pz += "`t<!-- Die drei Anzeigezeilen fuehrten nur noch gesperrte Garnituren. Sie zeigen jetzt unsere. -->"
foreach ($rp in $ruestungPlan) {
    $r = $rp.Zeile
    $xp = "/progression/crafting_skills/crafting_skill[@name='$stufe']/display_entry[@name_key='$($r.Anzeige)']"
    $pz += "`t<set xpath=`"$xp/@icon`">$($rp.Bild)</set>   <!-- $($r.De) -->"
    $pz += "`t<set xpath=`"$xp/unlock_entry/@item`">$($r.Teile -join ',')</set>"
    $pz += "`t<set xpath=`"$xp/unlock_entry/@recipes`">$($r.Teile -join ',')</set>"
    Text $r.Anzeige 'progression' 'Attribute' $r.En $r.De
}
Text $ruestungT0.Anzeige 'progression' 'Attribute' $ruestungT0.En $ruestungT0.De

$pz += ''
$pz += "`t<!-- Werkstatt: der Webstuhl nimmt den Platz von $($w.Platz) (Level $($wPlan.Level)), den der Purge"
$pz += "`t     freigemacht hat. Die Anzeigezeile wird ueber ihre name_key-Liste gefasst und der"
$pz += "`t     Eintrag ueber seine Stelle - beides aendern wir nicht, also haengt keine Zeile davon"
$pz += "`t     ab, dass eine andere schon gelaufen ist. -->"
$wxp = "/progression/crafting_skills/crafting_skill[@name='$($w.Stufe)']"
$axp = "$wxp/display_entry[@name_key='$($wPlan.Anzeige.GetAttribute('name_key'))']"
$z = $wPlan.Zeile
$pz += "`t<append xpath=`"$wxp/effect_group`">"
$pz += "`t`t<passive_effect name=`"RecipeTagUnlocked`" operation=`"$($z.GetAttribute('operation'))`" level=`"$($z.GetAttribute('level'))`" value=`"$($z.GetAttribute('value'))`" tags=`"$($w.Rezept)`"/>"
$pz += "`t</append>"
$pz += "`t<set xpath=`"$axp/@icon`">$($wPlan.Bilder)</set>"
$pz += "`t<set xpath=`"$axp/unlock_entry[@unlock_tier='$($wPlan.Tier)']/@item`">$($w.Rezept)</set>"
Text $wPlan.NameKey 'progression' 'Attribute' $w.En $w.De

# --- Hefte und Papier -------------------------------------------------------
$dz += "# --- WP7.5 / D70: Lehrblaetter und Pergament -----------------------------------"
$dz += "# ERZEUGT von tools/gen/wp7-bindung.ps1. '*SkillMagazine' bleibt verboten; freigegeben"
$dz += "# ist das Heft jeder LEBENDEN Handwerks-Stufe, weil es umgedeutet ist (Lehrblatt) und"
$dz += "# weil eine Stufe nur durch ihr Heft steigt: ohne Heft waere jedes daran gebundene"
$dz += "# Rezept eine Sackgasse. Die Hefte der zehn toten Stufen bleiben gesperrt."
$lebend = 0; $tot = 0
foreach ($h in $hefte) {
    if ($h.Tot) { $tot++; continue }
    $lebend++
    $zeile = $unserLoc[$h.Ziel + 'Name']
    Text $h.Name    'items' 'Item' ($heftEn -f $zeile.english)     ($heftDe -f $zeile.german)
    Text $h.DescKey 'items' 'Item' ($heftEnDesc -f $zeile.english) ($heftDeDesc -f $zeile.german)
    $dz += ("!{0,-30} # D70 -> Lehrblatt: {1}" -f $h.Name, $zeile.german)
}
$dz += ("!{0,-30} # D70 -> Pergament: traegt Abschriften und Lehrblaetter" -f $papier.Name)
Text $papier.Name            'items' 'Item' $papier.En     $papier.De
Text ($papier.Name + 'Desc') 'items' 'Item' $papier.EnDesc $papier.DeDesc

$doppelt = @($kz | Group-Object | Where-Object { $_.Count -gt 1 })
if ($doppelt.Count) { throw "Doppelte Schluessel: $(($doppelt | ForEach-Object { $_.Name }) -join ', ')" }

# ===========================================================================
# Schreiben
# ===========================================================================
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-bindung-recipes.xml'),     $rz, (New-Object System.Text.UTF8Encoding($true)))
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-bindung-progression.xml'), $pz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-bindung-texte.csv'),       $cz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-bindung-denylist.txt'),    $dz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-bindung-keys.txt'),        $kz, $utf8)

Write-Output "wp7-bindung: geschrieben nach $AusOrdner"
Write-Output ("  unsere Rezepte:        {0}" -f $unsereRezepte.Count)
Write-Output ("  gebunden:              {0}" -f $bindungen.Count)
Write-Output ("  bewusst offen:         {0}" -f $offen.Count)
Write-Output ("  Hefte: {0} lebend freigegeben, {1} tot und gesperrt" -f $lebend, $tot)
Write-Output ("  Localization-Zeilen:   {0}" -f $cz.Count)
Write-Output ("  Denylist-Freigaben:    {0}" -f @($dz | Where-Object { $_.StartsWith('!') }).Count)
foreach ($g in ($bindungen | Group-Object { $_.Stufe } | Sort-Object Name)) {
    $t = ($g.Group | Sort-Object { $_.Level }, { $_.Rezept } | ForEach-Object { "$($_.Rezept)@$($_.Level)" }) -join ' '
    Write-Output ("    {0,-24} {1}" -f $g.Name, $t)
}
