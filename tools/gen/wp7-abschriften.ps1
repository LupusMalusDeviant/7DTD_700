#Requires -Version 5.1
# wp7-abschriften.ps1 — erzeugt die Patch-, Sprach- und Denylist-Zeilen fuer WP7.4:
# Vanillas 19 Buchreihen werden zu Abschriften umgedeutet (D69).
#
# WAS DAS SKRIPT WEISS, WEIL ES GEMESSEN IST (Befund WP7-fertigkeitsbaeume §7):
#
#   1. Das Buchfenster liest 'hidden' an einem <book> NICHT. Es holt die Kinder der
#      Reihe (Progression::GetPerkList vergleicht nur den Elternnamen), nummeriert sie
#      nach ihrer Stelle und nennt den LETZTEN den Reihen-Abschluss. Ein toter Band
#      verschwindet also nur, wenn er die Reihe VERLAESST - darum wird er an eine tote,
#      verborgene Reihe umgehaengt ('Ablage') und nicht bloss verborgen.
#
#   2. Der Reihen-Abschluss haengt an 'PerksUnlocked >= 7', und diese Bedingung steht
#      ZWEIMAL in JEDEM Buch-Gegenstand der Reihe (266 Mal in items.xml). PerksUnlocked
#      zaehlt die Kinder der Reihe mit Stufe. Faellt ein Band weg, muss die Sieben an
#      jedem verbleibenden Gegenstand der Reihe auf die Zahl der lebenden Baende sinken -
#      sonst ist der Abschluss unerreichbar, ohne Fehlermeldung.
#
#   3. Die Blattnummer im Namen ('Blatt 2 von 5') muss dieselbe sein, die das Fenster
#      zeigt: Stelle unter den lebenden Baenden in der Reihenfolge der XML.
#
# Die Tabelle unten ist die Entscheidung (D69). Das Skript prueft sie gegen den Build
# und gegen die Purge-Patches und bricht ab, sobald etwas nicht passt: eine Reihe ohne
# Zeile, eine andere Zahl von Baenden, ein Band, der als tot gefuehrt wird und es
# gemessen nicht ist - oder einer, der als lebend gefuehrt wird und dessen Rezepte der
# Purge alle entfernt hat.
#
# Aufruf:
#   powershell -File tools/gen/wp7-abschriften.ps1 -Spiel <pfad>
# Schreibt nach tools/gen/out/:
#   wp7-abschriften-progression.xml   Zeilen fuer mod/700_50_Fortschritt/Config/progression.xml
#   wp7-abschriften-items.xml         Zeilen fuer mod/700_50_Fortschritt/Config/items.xml
#   wp7-abschriften-texte.csv         Localization-Zeilen ohne Kopfzeile
#   wp7-abschriften-denylist.txt      Freigaben fuer tools/check/denylist.txt
#   wp7-abschriften-keys.txt          Schluessel fuer tools/check/vanilla-keys.txt

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
    prog  = Join-Path $cfg 'progression.xml'
    items = Join-Path $cfg 'items.xml'
    mods  = Join-Path $cfg 'item_modifiers.xml'
    loc   = Join-Path $cfg 'Localization.csv'
    purgeItems   = Join-Path $Repo 'mod\700_10_Purge\Config\items.xml'
    purgeRezepte = Join-Path $Repo 'mod\700_10_Purge\Config\recipes.xml'
}
foreach ($f in $pfade.Values) { if (-not (Test-Path $f)) { throw "Nicht gefunden: $f" } }

# ===========================================================================
# 1  Die Ablage: eine tote, verborgene Reihe, an die tote Einzelbaende wandern.
# ===========================================================================
$ablage = 'skillTechJunkie'

# ===========================================================================
# 2  Die 19 Reihen. 'Tot' = die ganze Reihe faellt (Befund §3.3).
#    'ToteBaende' = einzelne Baende einer lebenden Reihe, mit dem Grund, den das
#    Skript nachmisst:
#      Rezept  alle Rezepte, die der Band freischaltet, hat der Purge entfernt
#      Marke   jeder Traeger der genannten Marke ist gesperrt
#      Buff    die Wirkung verlangt einen Buff, den nur gesperrte Gegenstaende geben
#    'ToterAbschluss' = der Abschluss-Bonus wirkt auf nichts mehr. Der Knoten bleibt
#    (das Fenster nennt den letzten Knoten den Abschluss), sein Text sagt es.
# ===========================================================================
$reihen = @(
    @{ Gruppe = 'skillArtOfMining'
       De = 'Bergmannskunde';   En = "The Miner's Craft"
       DeDesc = 'Wie man Erz findet, den Fels bricht und heil wieder aus dem Stollen kommt.'
       EnDesc = 'How to find ore, break the rock and come out of the gallery in one piece.'
       ToteBaende = @(
           @{ Name = 'perkArtOfMiningCoffee';     Grund = 'Buff';   Wert = 'buffCoffee,buffBlackStrapCoffee' }
           @{ Name = 'perkArtOfMiningBlackStrap'; Grund = 'Rezept' }
       ) }
    @{ Gruppe = 'skillBatterUp'
       De = 'Vom Keulenschlag'; En = 'On the Cudgel'
       DeDesc = 'Was eine Keule kann, wenn die Hand weiß, wohin sie schlägt.'
       EnDesc = 'What a cudgel can do when the hand knows where to strike.' }
    @{ Gruppe = 'skillBarBrawling'
       De = 'Vom Faustkampf';   En = 'On Fist-Fighting'
       DeDesc = 'Die Lehre der bloßen Hand, aufgeschrieben von einem, der oft genug am Boden lag.'
       EnDesc = 'The lore of the bare hand, set down by one who lay on the ground often enough.' }
    @{ Gruppe = 'skillFiremansAlmanac'
       De = 'Köhlerweisheit';   En = "Charcoal-Burner's Lore"
       DeDesc = 'Vom Feuer, von der Axt und von verbranntem Holz — was die Köhler wissen.'
       EnDesc = 'Of fire, of the axe and of burnt wood — what the charcoal-burners know.'
       ToteBaende = @(
           @{ Name = 'perkFiremansAlmanacAxes';      Grund = 'Rezept' }
           @{ Name = 'perkFiremansAlmanacEquipment'; Grund = 'Marke'; Wert = 'vehicle' }
       ) }
    @{ Gruppe = 'skillGreatHeist'
       De = 'Diebeshandwerk';   En = "The Thief's Trade"
       DeDesc = 'Schlösser, Truhen und fremdes Gut — und wie man mit allem davonkommt.'
       EnDesc = "Locks, chests and other men's goods — and how to get away with all of it." }
    @{ Gruppe = 'skillHuntingJournal'
       De = 'Vom Waidwerk';     En = 'Of the Chase'
       DeDesc = 'Wo das Tier verwundbar ist: Bär, Wolf und was sonst im Wald auf einen wartet.'
       EnDesc = 'Where the beast is weak: bear, wolf and whatever else waits in the wood.' }
    @{ Gruppe = 'skillLuckyLooter'
       De = 'Finderglück';      En = "Finder's Luck"
       DeDesc = 'Wer weiß, wo er suchen muss, findet mehr als der, der nur sucht.'
       EnDesc = 'He who knows where to look finds more than he who merely looks.' }
    @{ Gruppe = 'skillNightStalker'
       De = 'Der Nachtgänger';  En = 'The Night-Walker'
       DeDesc = 'Was die Dunkelheit dem gibt, der sich nicht vor ihr fürchtet.'
       EnDesc = 'What the dark gives to the one who does not fear it.' }
    @{ Gruppe = 'skillArchery'
       De = 'Bogenlehre';       En = "The Bowman's Lore"
       DeDesc = 'Vom Bogen, von der Sehne und vom Pfeil, der wiedergefunden werden will.'
       EnDesc = 'Of the bow, the string and the arrow that wants to be found again.' }
    @{ Gruppe = 'skillSledgeSaga'
       De = 'Vom Hammerschlag'; En = 'On the Hammer-Blow'
       DeDesc = 'Die schwere Lehre: ein Schlag, der sitzt, braucht keinen zweiten.'
       EnDesc = 'The heavy lesson: a blow that lands needs no second.' }
    @{ Gruppe = 'skillSpearHunter'
       De = 'Speerlehre';       En = "The Spearman's Lore"
       DeDesc = 'Die älteste Waffe, und was die Alten über Stoß und Wurf wussten.'
       EnDesc = 'The oldest weapon, and what the old ones knew of thrust and throw.' }
    @{ Gruppe = 'skillUrbanCombat'
       De = 'Kampf in Mauern';  En = 'Fighting Within Walls'
       DeDesc = 'Leise treten, tief fallen und im engen Raum bestehen.'
       EnDesc = 'Tread softly, fall far and hold your own in a narrow room.'
       ToteBaende = @(
           @{ Name = 'perkUrbanCombatCigar'; Grund = 'Rezept' }
       )
       ToterAbschluss = @{ Grund = 'ModTraeger'; Wert = 'gun' } }
    @{ Gruppe = 'skillWasteTreasures'
       De = 'Brachlandschätze'; En = 'Treasures of the Waste'
       DeDesc = 'Was sich aus dem holen lässt, was andere liegen ließen.'
       EnDesc = 'What can be had from the things others left lying.'
       ToteBaende = @(
           @{ Name = 'perkWasteTreasuresWater'; Grund = 'Rezept' }
       )
       ToterAbschluss = @{ Grund = 'Marke'; Wert = 'WasteTreasuresCompleteHarvest' } }

    @{ Gruppe = 'skillAutoWeapons'; Tot = $true }
    @{ Gruppe = 'skillEnforcer';    Tot = $true }
    @{ Gruppe = 'skillPistolPete';  Tot = $true }
    @{ Gruppe = 'skillShotguns';    Tot = $true }
    @{ Gruppe = 'skillSniper';      Tot = $true }
    @{ Gruppe = 'skillTechJunkie';  Tot = $true }
)

# Der eine Langtext, den Vanilla ALLEN 19 Reihen gibt (perkBookGroupLongDesc). Er wird
# einmal ueberschrieben, mit einem Text, der fuer jede Reihe stimmt - auch fuer die zwei
# ohne Abschluss-Lehre, darum 'manche Reihe'.
$gruppenLangKey = 'perkBookGroupLongDesc'
$gruppenLangDe  = 'Abschriften lehren Dauerhaftes: jedes gelesene Blatt bleibt. Wer alle Blätter einer Reihe gelesen hat, dem gibt manche Reihe noch eine letzte Lehre dazu.'
$gruppenLangEn  = 'Transcripts teach what lasts: every leaf you read stays with you. Read every leaf of a series, and some series grant one last lesson besides.'

$toterAbschlussDe = 'Diese Reihe schließt ohne eigene Lehre.'
$toterAbschlussEn = 'This series closes without a lesson of its own.'

# ===========================================================================
# Einlesen
# ===========================================================================
$prog  = [xml](Get-Content $pfade.prog  -Raw)
$items = [xml](Get-Content $pfade.items -Raw)
$mods  = [xml](Get-Content $pfade.mods  -Raw)
$itemsRoh = Get-Content $pfade.items -Raw

$loc = @{}
Import-Csv $pfade.loc -Encoding UTF8 | ForEach-Object { $loc[$_.Key] = 1 }

$gesperrt = @{}
foreach ($m in [regex]::Matches((Get-Content $pfade.purgeItems -Raw), "item\[@name='([^']+)'\]")) { $gesperrt[$m.Groups[1].Value] = 1 }
$rezeptWeg = @{}
foreach ($m in [regex]::Matches((Get-Content $pfade.purgeRezepte -Raw), "recipe\[@name='([^']+)'\]")) { $rezeptWeg[$m.Groups[1].Value] = 1 }

$keyNutzer = @{}
foreach ($n in $prog.SelectNodes('/progression/*/*')) {
    foreach ($a in 'name_key', 'desc_key', 'long_desc_key') {
        $k = $n.GetAttribute($a)
        if ($k) { if (-not $keyNutzer[$k]) { $keyNutzer[$k] = 0 }; $keyNutzer[$k]++ }
    }
}

function Traeger([string] $marke) {
    # Gegenstaende und Mods, die die Marke in ihrer Tags-Eigenschaft fuehren
    $namen = @()
    foreach ($doc in @($items, $mods)) {
        foreach ($p in $doc.SelectNodes("//property[@name='Tags']")) {
            if ((($p.value -split ',') | ForEach-Object { $_.Trim() }) -contains $marke) { $namen += $p.ParentNode.GetAttribute('name') }
        }
    }
    return , $namen
}

function AlleRezepteWeg($buch) {
    # $true nur, wenn der Band AUSSCHLIESSLICH Rezepte freischaltet und alle weg sind
    $alle = @($buch.SelectNodes('.//passive_effect'))
    $rez  = @($buch.SelectNodes(".//passive_effect[@name='RecipeTagUnlocked']"))
    if ($rez.Count -eq 0 -or $rez.Count -ne $alle.Count) { return $false }
    if (@($buch.SelectNodes('.//triggered_effect')).Count -gt 0) { return $false }
    foreach ($p in $rez) {
        foreach ($t in ($p.GetAttribute('tags') -split ',')) {
            $t = $t.Trim()
            if ($t -and -not $rezeptWeg[$t]) { return $false }
        }
    }
    return $true
}

function GrundStimmt($buch, $grund) {
    switch ($grund.Grund) {
        'Rezept' { return (AlleRezepteWeg $buch) }
        'Marke' {
            $tr = Traeger $grund.Wert
            if ($tr.Count -eq 0) { return $false }
            return (@($tr | Where-Object { -not $gesperrt[$_] }).Count -eq 0)
        }
        'Buff' {
            foreach ($b in ($grund.Wert -split ',')) {
                # jeder Gegenstand, der den Buff gibt, muss gesperrt sein - und es muss einen geben
                $geber = @()
                foreach ($t in $items.SelectNodes("//triggered_effect[@action='AddBuff']")) {
                    if ((($t.GetAttribute('buff') -split ',') | ForEach-Object { $_.Trim() }) -contains $b) {
                        $n = $t; while ($n -and $n.get_Name() -ne 'item') { $n = $n.ParentNode }
                        if ($n) { $geber += $n.GetAttribute('name') }
                    }
                }
                if ($geber.Count -eq 0) { return $false }
                if (@($geber | Where-Object { -not $gesperrt[$_] }).Count -gt 0) { return $false }
            }
            return $true
        }
        'ModTraeger' {
            # der Abschluss wird nur von Mods gelesen, die auf Traeger dieser Marke passen
            $tr = Traeger $grund.Wert
            if ($tr.Count -eq 0) { return $false }
            return (@($tr | Where-Object { -not $gesperrt[$_] }).Count -eq 0)
        }
    }
    return $false
}

# ===========================================================================
# Pruefen, dass die Tabelle zur Wirklichkeit passt
# ===========================================================================
$fehler = @()

$vanillaGruppen = @($prog.SelectNodes('//book_group') | ForEach-Object { $_.GetAttribute('name') })
$tabGruppen     = @($reihen | ForEach-Object { $_.Gruppe })
foreach ($g in $vanillaGruppen) { if ($tabGruppen -notcontains $g) { $fehler += "Reihe '$g' steht im Spiel, aber nicht in der Tabelle." } }
foreach ($g in $tabGruppen)     { if ($vanillaGruppen -notcontains $g) { $fehler += "Reihe '$g' steht in der Tabelle, aber nicht im Spiel." } }

$ablageZeile = $reihen | Where-Object { $_.Gruppe -eq $ablage }
if (-not $ablageZeile -or -not $ablageZeile.Tot) { $fehler += "Die Ablage '$ablage' ist keine tote Reihe." }

if ($keyNutzer[$gruppenLangKey] -ne $vanillaGruppen.Count) {
    $fehler += "$gruppenLangKey wird von $($keyNutzer[$gruppenLangKey]) Knoten benutzt, erwartet sind die $($vanillaGruppen.Count) Reihen. Wer teilt ihn noch?"
}

$plan = @()   # je Reihe: was lebt, was tot ist
foreach ($r in $reihen) {
    if ($vanillaGruppen -notcontains $r.Gruppe) { continue }
    $gKnoten = $prog.SelectSingleNode("//book_group[@name='$($r.Gruppe)']")
    $buecher = @($prog.SelectNodes("//book[@parent='$($r.Gruppe)']"))
    if ($buecher.Count -ne 8) { $fehler += "$($r.Gruppe): $($buecher.Count) Knoten statt 8 (7 Baende + Abschluss)."; continue }

    # Der Abschluss ist der Knoten ohne Gegenstand - und er muss der LETZTE sein,
    # weil das Fenster den letzten Knoten den Abschluss nennt.
    $baende = @(); $abschluss = $null
    foreach ($b in $buecher) {
        $bn = $b.GetAttribute('name')
        $it = @($items.SelectNodes("//item[property[@name='Unlocks' and @value='$bn']]"))
        if ($it.Count -eq 0) {
            if ($abschluss) { $fehler += "$($r.Gruppe): zwei Knoten ohne Gegenstand ($($abschluss.GetAttribute('name')), $bn)." }
            $abschluss = $b
        } elseif ($it.Count -eq 1) {
            $baende += @{ Knoten = $b; Name = $bn; Gegenstand = $it[0]; ItemName = $it[0].GetAttribute('name') }
        } else { $fehler += "$bn wird von $($it.Count) Gegenstaenden freigeschaltet, erwartet ist einer." }
    }
    if (-not $abschluss) { $fehler += "$($r.Gruppe): kein Abschluss-Knoten gefunden."; continue }
    if ($buecher[7].GetAttribute('name') -ne $abschluss.GetAttribute('name')) { $fehler += "$($r.Gruppe): der Abschluss ist nicht der letzte Knoten." }
    if ($baende.Count -ne 7) { $fehler += "$($r.Gruppe): $($baende.Count) Baende statt 7."; continue }

    foreach ($b in $baende) {
        # zwei PerksUnlocked-Bedingungen je Gegenstand, beide auf diese Reihe, beide '7'
        $req = @($b.Gegenstand.SelectNodes("effect_group/triggered_effect/requirement[@name='PerksUnlocked']"))
        if ($req.Count -ne 2) { $fehler += "$($b.ItemName): $($req.Count) PerksUnlocked-Bedingungen statt 2." }
        foreach ($q in $req) {
            if ($q.GetAttribute('skill_name') -ne $r.Gruppe) { $fehler += "$($b.ItemName): PerksUnlocked zeigt auf '$($q.GetAttribute('skill_name'))' statt '$($r.Gruppe)'." }
            if ($q.GetAttribute('value') -ne '7')            { $fehler += "$($b.ItemName): PerksUnlocked verlangt '$($q.GetAttribute('value'))' statt 7." }
        }
        if (-not $loc[$b.ItemName]) { $fehler += "$($b.ItemName): keine Namenszeile in Vanillas Localization.csv." }
    }

    $tote = @{}
    if ($r.Tot) {
        if ($r.ToteBaende -or $r.ToterAbschluss) { $fehler += "$($r.Gruppe): eine tote Reihe fuehrt keine toten Einzelbaende." }
    } else {
        foreach ($t in @($r.ToteBaende)) {
            if (-not $t) { continue }
            $b = $baende | Where-Object { $_.Name -eq $t.Name }
            if (-not $b) { $fehler += "$($r.Gruppe): der tote Band '$($t.Name)' gehoert nicht zu dieser Reihe."; continue }
            if (-not (GrundStimmt $b.Knoten $t)) { $fehler += "$($t.Name) wird als tot gefuehrt (Grund $($t.Grund) $($t.Wert)), ist es gemessen aber NICHT." }
            $tote[$t.Name] = $t
        }
        # Gegenrichtung: ein Band, der als lebend gilt und dessen Rezepte alle weg sind
        foreach ($b in $baende) {
            if (-not $tote[$b.Name] -and (AlleRezepteWeg $b.Knoten)) { $fehler += "$($b.Name) gilt als lebend, aber der Purge hat ALLE seine Rezepte entfernt. In die Tabelle eintragen." }
        }
        if ($r.ToterAbschluss -and -not (GrundStimmt $abschluss $r.ToterAbschluss)) {
            $fehler += "$($r.Gruppe): der Abschluss wird als tot gefuehrt (Grund $($r.ToterAbschluss.Grund) $($r.ToterAbschluss.Wert)), ist es gemessen aber NICHT."
        }
        foreach ($a in 'name_key', 'desc_key') {
            $k = $gKnoten.GetAttribute($a)
            if (-not $k) { $fehler += "$($r.Gruppe): kein $a." }
            elseif ($keyNutzer[$k] -ne 1) { $fehler += "$($r.Gruppe): $a '$k' wird von $($keyNutzer[$k]) Knoten geteilt." }
            elseif (-not $loc[$k]) { $fehler += "$($r.Gruppe): $a '$k' fehlt in Vanillas Localization.csv." }
        }
        if ($r.ToterAbschluss) {
            foreach ($a in 'desc_key', 'long_desc_key') {
                $k = $abschluss.GetAttribute($a)
                if (-not $k -or $keyNutzer[$k] -ne 1) { $fehler += "$($abschluss.GetAttribute('name')): $a '$k' fehlt oder ist geteilt." }
            }
        }
    }
    $plan += @{ Reihe = $r; Gruppe = $gKnoten; Baende = $baende; Abschluss = $abschluss; Tote = $tote }
}

# Kein lebender Band darf von einem toten ERBEN. Der Purge sperrt ueber die Eigenschaft
# CreativeMode, und 'Extends' vererbt Eigenschaften: ein gesperrter Vorfahr wuerde seine
# Sperre an jeden lebenden Band weitergeben, der sie nicht selbst ueberschreibt.
# Gemessen erben die Baende ZWEISTUFIG: sechs Baende je Reihe vom ersten Band ihrer
# Reihe, und die 18 ersten Baende (dazu die sechs Geschwister) von
# bookFiremansAlmanacHeat, der selbst von schematicMaster erbt. Tot darf also weder
# bookFiremansAlmanacHeat sein noch der erste Band einer lebenden Reihe.
$toteItems = @{}
foreach ($p in $plan) {
    foreach ($b in $p.Baende) { if ($p.Reihe.Tot -or $p.Tote[$b.Name]) { $toteItems[$b.ItemName] = 1 } }
}
foreach ($p in $plan) {
    foreach ($b in $p.Baende) {
        if ($toteItems[$b.ItemName]) { continue }
        $e = $b.Gegenstand.SelectSingleNode("property[@name='Extends']")
        if ($e -and $toteItems[$e.value]) { $fehler += "$($b.ItemName) lebt, erbt aber vom toten '$($e.value)' - die Sperre wuerde mitvererbt." }
    }
}

if ($fehler.Count -gt 0) {
    foreach ($f in $fehler) { Write-Output "FEHLER: $f" }
    throw "Die Tabelle passt nicht zum Build oder zum Purge. Nichts geschrieben."
}

# ===========================================================================
# Erzeugen
# ===========================================================================
function Zeile([string] $key, [string] $datei, [string] $typ, [string] $en, [string] $de) {
    $enQ = '"' + $en.Replace('"', '""') + '"'
    $deQ = '"' + $de.Replace('"', '""') + '"'
    return "$key,$datei,$typ,,,,$enQ,,$deQ,,,,,,,,,,,"
}

$pz = @(); $iz = @(); $cz = @(); $dz = @(); $kz = @()
$zahl = @{ ReihenTot = 0; KnotenVerborgen = 0; BaendeUmgehaengt = 0; Schwellen = 0; ItemsFrei = 0; ItemsGesperrt = 0; AbschlussTot = 0 }
$schluesselGesehen = @{}
function Text([string] $key, [string] $datei, [string] $typ, [string] $en, [string] $de) {
    if ($script:schluesselGesehen[$key]) { return }
    $script:schluesselGesehen[$key] = 1
    $script:cz += Zeile $key $datei $typ $en $de
    $script:kz += $key
}

$pz += "`t<!-- ===== WP7.4 Abschriften (D69) - ERZEUGT von tools/gen/wp7-abschriften.ps1, nicht von Hand aendern ===== -->"
$pz += ''
$pz += "`t<!-- Sechs tote Reihen: die Reihe verborgen, dazu jeder ihrer acht Knoten. Das Buchfenster"
$pz += "`t     liest 'hidden' an einem <book> gemessen NICHT - die Zeilen an den Baenden sind die"
$pz += "`t     Rueckversicherung fuer jede andere Liste, die es liest (XUiC_SkillList tut es). -->"
foreach ($p in $plan) {
    if (-not $p.Reihe.Tot) { continue }
    $zahl.ReihenTot++
    $pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/skills/book_group[@name='$($p.Reihe.Gruppe)']`">true</setattribute>"
    $zahl.KnotenVerborgen++
    foreach ($b in $p.Baende) {
        $pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/perks/book[@name='$($b.Name)']`">true</setattribute>"
        $zahl.KnotenVerborgen++
    }
    $pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/perks/book[@name='$($p.Abschluss.GetAttribute('name'))']`">true</setattribute>"
    $zahl.KnotenVerborgen++
}
$pz += ''
$pz += "`t<!-- Tote Einzelbaende lebender Reihen wandern in die Ablage ($ablage, tot und verborgen)."
$pz += "`t     Nur so verlassen sie das Fenster ihrer Reihe UND die Zaehlung von PerksUnlocked. -->"
foreach ($p in $plan) {
    if ($p.Reihe.Tot) { continue }
    foreach ($b in $p.Baende) {
        if (-not $p.Tote[$b.Name]) { continue }
        $t = $p.Tote[$b.Name]
        $pz += "`t<set xpath=`"/progression/perks/book[@name='$($b.Name)']/@parent`">$ablage</set>   <!-- $($p.Reihe.De): tot nach $($t.Grund) $($t.Wert) -->"
        $pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/perks/book[@name='$($b.Name)']`">true</setattribute>"
        $zahl.BaendeUmgehaengt++; $zahl.KnotenVerborgen++
    }
}

$iz += "`t<!-- ===== WP7.4 Abschriften (D69) - ERZEUGT von tools/gen/wp7-abschriften.ps1, nicht von Hand aendern ====="
$iz += "`t     Der Reihen-Abschluss verlangt in Vanilla 'PerksUnlocked >= 7', zweimal je Gegenstand."
$iz += "`t     Wo tote Baende die Reihe verlassen haben, sinkt die Sieben auf die Zahl der lebenden."
$iz += "`t     Jede Zeile trifft ZWEI Knoten (SetProgressionLevel und PlaySound). -->"

$dz += "# --- WP7.4 / D69: Abschriften ----------------------------------------------------"
$dz += "# ERZEUGT von tools/gen/wp7-abschriften.ps1. 'book*' bleibt verboten; freigegeben ist"
$dz += "# jeder Band einer lebenden Reihe, weil er umgedeutet ist (Vanilla-Name in der XML,"
$dz += "# 'Blatt n von N' auf dem Schirm). Reihen mit toten Einzelbaenden stehen Band fuer"
$dz += "# Band hier und NICHT als Muster: eine Freigabe schlaegt jedes Verbot, und ein Muster"
$dz += "# wuerde die toten Baende mit freigeben."

foreach ($p in $plan) {
    $r = $p.Reihe
    if ($r.Tot) { $zahl.ItemsGesperrt += $p.Baende.Count; continue }

    $lebend = @($p.Baende | Where-Object { -not $p.Tote[$_.Name] })
    $n = $lebend.Count
    $zahl.ItemsGesperrt += ($p.Baende.Count - $n)

    # Reihe: Name und Beschreibung
    Text $p.Gruppe.GetAttribute('name_key') 'progression' 'Perk' $r.En $r.De
    Text $p.Gruppe.GetAttribute('desc_key') 'progression' 'Perk' $r.EnDesc $r.DeDesc

    # Baende: 'Blatt i von n' in der Reihenfolge, in der das Fenster sie zaehlt
    $i = 0
    foreach ($b in $lebend) {
        $i++
        $en = "$($r.En), leaf $i of $n"
        $de = "$($r.De), Blatt $i von $n"
        Text $b.ItemName 'items' 'Item' $en $de
        $nk = $b.Knoten.GetAttribute('name_key')
        if ($nk -and $nk -ne $b.ItemName) {
            if ($keyNutzer[$nk] -ne 1) { throw "$($b.Name): name_key '$nk' ist geteilt." }
            if ($loc[$nk]) { Text $nk 'progression' 'Perk' $en $de }
        }
        $zahl.ItemsFrei++
        if ($n -ne 7) {
            $xp = "/items/item[@name='$($b.ItemName)']/effect_group/triggered_effect/requirement[@name='PerksUnlocked']/@value"
            $iz += "`t<set xpath=`"$xp`">$n</set>   <!-- $($r.De): $n lebende Baende -->"
            $zahl.Schwellen++
        }
    }

    # Abschluss: ein ausdruecklicher Namens-Schluessel bekommt unseren Namen
    $ank = $p.Abschluss.GetAttribute('name_key')
    if ($ank -and $loc[$ank]) {
        if ($keyNutzer[$ank] -ne 1) { throw "$($p.Abschluss.GetAttribute('name')): name_key '$ank' ist geteilt." }
        Text $ank 'progression' 'Perk' "$($r.En): completion" "$($r.De): Abschluss"
    }
    if ($r.ToterAbschluss) {
        Text $p.Abschluss.GetAttribute('desc_key')      'progression' 'Perk' $toterAbschlussEn $toterAbschlussDe
        Text $p.Abschluss.GetAttribute('long_desc_key') 'progression' 'Perk' $toterAbschlussEn $toterAbschlussDe
        $zahl.AbschlussTot++
    }

    # Denylist: Muster nur, wenn die ganze Reihe lebt
    if ($n -eq 7) {
        $praefix = $null
        $namen = @($p.Baende | ForEach-Object { $_.ItemName })
        # laengstes gemeinsames Praefix der sieben Gegenstaende
        $praefix = $namen[0]
        foreach ($x in $namen) { while (-not $x.StartsWith($praefix)) { $praefix = $praefix.Substring(0, $praefix.Length - 1) } }
        # das Muster darf keinen Band einer ANDEREN Reihe treffen
        $fremd = @($items.SelectNodes("//item[starts-with(@name,'$praefix')]") | ForEach-Object { $_.GetAttribute('name') } | Where-Object { $namen -notcontains $_ })
        if ($praefix.Length -lt 6 -or $fremd.Count -gt 0) {
            foreach ($x in $namen) { $dz += ("!{0,-36} # D69 -> {1}" -f $x, $r.De) }
        } else {
            $dz += ("!{0,-36} # D69 -> {1}, sieben Blaetter" -f ($praefix + '*'), $r.De)
        }
    } else {
        foreach ($b in $lebend) { $dz += ("!{0,-36} # D69 -> {1}, {2} von 7 Blaettern leben" -f $b.ItemName, $r.De, $n) }
    }
}
Text $gruppenLangKey 'progression' 'Perk' $gruppenLangEn $gruppenLangDe

# ===========================================================================
# Schreiben
# ===========================================================================
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-abschriften-progression.xml'), $pz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-abschriften-items.xml'),       $iz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-abschriften-texte.csv'),       $cz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-abschriften-denylist.txt'),    $dz, $utf8)
[IO.File]::WriteAllLines((Join-Path $AusOrdner 'wp7-abschriften-keys.txt'),        $kz, $utf8)

Write-Output "wp7-abschriften: geschrieben nach $AusOrdner"
Write-Output ("  Reihen: {0} im Spiel, {1} tot, {2} leben" -f $vanillaGruppen.Count, $zahl.ReihenTot, ($vanillaGruppen.Count - $zahl.ReihenTot))
Write-Output ("  tote Einzelbaende umgehaengt:   {0}" -f $zahl.BaendeUmgehaengt)
Write-Output ("  Knoten verborgen:               {0}" -f $zahl.KnotenVerborgen)
Write-Output ("  Schwellen-Zeilen (je 2 Treffer): {0}" -f $zahl.Schwellen)
Write-Output ("  Abschluesse ohne Wirkung:       {0}" -f $zahl.AbschlussTot)
Write-Output ("  Buch-Gegenstaende: {0} freigegeben, {1} bleiben gesperrt" -f $zahl.ItemsFrei, $zahl.ItemsGesperrt)
Write-Output ("  Localization-Zeilen:            {0}" -f $cz.Count)
Write-Output ("  Denylist-Zeilen (Freigaben):    {0}" -f @($dz | Where-Object { $_.StartsWith('!') }).Count)
foreach ($p in $plan) {
    if ($p.Reihe.Tot) { continue }
    $n = @($p.Baende | Where-Object { -not $p.Tote[$_.Name] }).Count
    Write-Output ("    {0,-22} {1,-20} {2} von 7" -f $p.Reihe.Gruppe, $p.Reihe.De, $n)
}
