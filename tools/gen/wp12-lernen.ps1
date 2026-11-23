#Requires -Version 5.1
# wp12-lernen.ps1 - erzeugt den Lern-Buff fuer Lernen durch Tun (Plan-0002 WP12.3, F-21
# "Ausarbeitung Phase 2", D192, D194; zu pruefen N-138) und die Lehrblaetter mit +3.
#
# WAS DAS SKRIPT WEISS, WEIL ES GEMESSEN IST:
#   1. Vanilla zaehlt jedes hergestellte Stueck beim Spieler in _craftCount_<Gegenstand>
#      (Finding WP9-herstellen-und-schaden). Wir lesen den Zaehler, wir schreiben ihn nicht.
#   2. Eine Handwerks-Stufe steigt per AddProgressionLevel - so heben Vanillas Hefte sie
#      (items.xml, bladesSkillMagazine u. a.). Die erste effect_group traegt das Heben,
#      die dritte den Zufallspunkt der Gelehrten-Kleidung; nur die erste wird +3.
#   3. Ein CVar mit Punkt vorn wird nicht gespeichert (Vertrag 07 §2). Der Zaehler, was
#      schon gezahlt ist, traegt darum KEINEN Punkt - sonst zahlte jedes Laden neu aus.
#   4. Effekte eines Buffs laufen der Reihe nach, jede Bedingung wird beim eigenen Effekt
#      gelesen (Vanillas Muster: erst set 0, dann set 20 mit Bedingung; so rechnet auch
#      buff700_odemStufe). Darum die Marke .cv700_lernJetzt: sie wird EINMAL je Gegenstand
#      entschieden, und Heben, Zaehlen und Meldung fragen nur sie. Wuerden sie die
#      Bedingungen selbst lesen, veraenderte das Zaehlen die Bedingung des naechsten Effekts.
#
# DIE SETZUNGEN (D192, D194 - zu pruefen): alle 3 Stuecke +1, hoechstens 10-mal je
# Gegenstand, gezaehlt erst ab Stufe 11 (Grundfaehigkeit), nie ueber 35 (Tun traegt bis
# kurz vor T3). Lehrblatt +3 nur fuer die acht Stufen, die durch Tun lernen.
#
# Aufruf:
#   powershell -File tools/gen/wp12-lernen.ps1 [-Spiel <pfad>] [-Tabelle <tsv>]
# Schreibt nach tools/gen/out/:
#   wp12-lernen-buffs.xml   GANZE Datei mod/700_50_Fortschritt/Config/buffs.xml
#   wp12-lernen-items.xml   Block fuer mod/700_50_Fortschritt/Config/items.xml
# Exit 0 = erzeugt, 1 = Tabelle passt nicht zum Build oder zur Bindung (nichts geschrieben).

[CmdletBinding()]
param(
    [string] $Spiel = $env:SDTD_PATH,
    [string] $Repo,
    [string] $Tabelle,
    [string] $AusOrdner
)

$ErrorActionPreference = 'Stop'
if (-not $Spiel) { throw "Kein Spielpfad: SDTD_PATH setzen oder -Spiel angeben." }
$hier = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Repo) { $Repo = Split-Path -Parent (Split-Path -Parent $hier) }
if (-not $Tabelle) { $Tabelle = Join-Path $hier 'wp12-lernen.tsv' }
if (-not $AusOrdner) { $AusOrdner = Join-Path $hier 'out' }

$schwelleStart = 11   # Grundfaehigkeit (D24, F-21 §2)
$schwelleEnde  = 35   # Tun hebt nie ueber 35 (D194)
$jeStuecke     = 3
$hoechstens    = 10

$cfg = Join-Path $Spiel 'Data\Config'
$fehler = @()

# --- Vorraete aus dem Build und unseren Modlets -------------------------------------------
$stufen = @{}
[xml]$prog = Get-Content (Join-Path $cfg 'progression.xml') -Raw -Encoding UTF8
foreach ($n in $prog.SelectNodes('//crafting_skill')) { $stufen[$n.GetAttribute('name')] = [int]$n.GetAttribute('max_level') }

$rezepte = @{}
[xml]$vr = Get-Content (Join-Path $cfg 'recipes.xml') -Raw -Encoding UTF8
foreach ($r in $vr.SelectNodes('//recipe')) { $rezepte[$r.GetAttribute('name')] = 'vanilla' }
foreach ($d in Get-ChildItem (Join-Path $Repo 'mod') -Recurse -Filter 'recipes.xml') {
    [xml]$x = Get-Content $d.FullName -Raw -Encoding UTF8
    foreach ($r in $x.SelectNodes('//recipe')) { $rezepte[$r.GetAttribute('name')] = 'unser' }
}

# --- die Tabelle ---------------------------------------------------------------------------
$zeilen = @()
foreach ($z in Get-Content $Tabelle -Encoding UTF8) {
    if ($z -match '^\s*(#|$)') { continue }
    $s = $z -split "`t"
    if ($s.Count -ne 4) { $fehler += "Zeile mit $($s.Count) statt 4 Spalten: $z"; continue }
    $e = [pscustomobject]@{ Kurz = $s[0]; Ding = $s[1]; Stufe = $s[2]; Art = $s[3] }
    if ($e.Kurz -notmatch '^[A-Za-z]+$') { $fehler += "Kurzname '$($e.Kurz)' ist nicht nur Buchstaben" }
    if (-not $rezepte.ContainsKey($e.Ding)) { $fehler += "Gegenstand '$($e.Ding)' hat kein Rezept (weder Vanilla noch unser)" }
    if (-not $stufen.ContainsKey($e.Stufe)) { $fehler += "Stufe '$($e.Stufe)' ist keine Handwerks-Stufe des Builds" }
    elseif ($stufen[$e.Stufe] -lt $schwelleEnde) { $fehler += "Stufe '$($e.Stufe)' endet bei $($stufen[$e.Stufe]), unter $schwelleEnde" }
    if ($e.Art -notin 'gebunden', 'Vorstueck') { $fehler += "Art '$($e.Art)' bei $($e.Kurz): nur gebunden oder Vorstueck" }
    $zeilen += $e
}
foreach ($g in ($zeilen | Group-Object Kurz | Where-Object Count -gt 1)) { $fehler += "Kurzname '$($g.Name)' doppelt" }
foreach ($g in ($zeilen | Where-Object Art -eq 'Vorstueck' | Group-Object Stufe | Where-Object Count -gt 1)) { $fehler += "Stufe '$($g.Name)' hat mehr als ein Vorstueck" }

# --- gegen die Bindung (700_50/recipes.xml, D70): jedes gebundene Rezept unter 36 zaehlt -----
$bindung = Join-Path $Repo 'mod\700_50_Fortschritt\Config\recipes.xml'
$muster = "recipe\[@name='([^']+)'\]`">learnable[^<]*</setattribute>\s*<!--\s*(crafting\w+) ab (\d+)"
$gebunden = 0
$gebundenOhneTun = 0
foreach ($m in [regex]::Matches((Get-Content $bindung -Raw -Encoding UTF8), $muster)) {
    $ding = $m.Groups[1].Value; $st = $m.Groups[2].Value; $ab = [int]$m.Groups[3].Value
    $gebunden++
    $treffer = @($zeilen | Where-Object Ding -eq $ding)
    if ($ab -gt $schwelleEnde) {
        if ($treffer.Count -gt 0) { $fehler += "'$ding' oeffnet erst bei $ab und kann nie zaehlen (Tun endet bei $schwelleEnde)" }
        continue
    }
    # Nur Stufen, die durch Tun lernen (die der Tabelle), muessen jedes gebundene Rezept zaehlen.
    # Eine Stufe ohne Tun (Wundversorgung mit dem Theriak, D197) darf binden, ohne zu lernen.
    if ($treffer.Count -eq 0 -and -not @($zeilen | Where-Object Stufe -eq $st).Count) { $gebundenOhneTun++; continue }
    if ($treffer.Count -eq 0) { $fehler += "gebundenes Rezept '$ding' ($st ab $ab) fehlt in der Tabelle" }
    elseif ($treffer[0].Stufe -ne $st -or $treffer[0].Art -ne 'gebunden') { $fehler += "'$ding' steht als $($treffer[0].Stufe)/$($treffer[0].Art), gebunden ist es an $st" }
}
if ($gebunden -eq 0) { $fehler += "keine Bindung gelesen aus $bindung - Muster passt nicht mehr" }

# --- Lehrblaetter: das Heft je Stufe, deren erste effect_group die Stufe hebt ------------------
[xml]$items = Get-Content (Join-Path $cfg 'items.xml') -Raw -Encoding UTF8
$hefte = @{}
foreach ($st in ($zeilen | Select-Object -ExpandProperty Stufe -Unique)) {
    $h = @($items.SelectNodes("//item[substring(@name, string-length(@name) - 12) = 'SkillMagazine' and effect_group[1]/triggered_effect[@action='AddProgressionLevel' and @progression_name='$st' and @level='1']]"))
    if ($h.Count -ne 1) { $fehler += "Stufe '$st': $($h.Count) Hefte statt einem gefunden" } else { $hefte[$st] = $h[0].GetAttribute('name') }
}

# --- Lehrzeit (F-21 §4, D195): je Baum ein Perk mit drei Raengen ----------------------------
# Rang 1 hebt jede Handwerks-Stufe seines Baums einmal um 10 (die Grundfaehigkeit), Rang 2 und 3
# je um 3. Welche Stufen zu welchem Baum gehoeren, steht in UNSERER progression.xml (D68, @parent);
# hier steht nur, wo der Perk haengt. Ausgezahlt wird im Lern-Buff, nicht beim Kauf: einen Ausloeser
# "Rang gekauft" kennt XML nicht sicher, und der Buff merkt sich im gespeicherten
# cv700_lehrzeitGezahlt<Baum>, welcher Rang schon gezahlt ist - Neuladen zahlt nichts doppelt.
$baeume = @(
    [pscustomobject]@{ Att = 'attStrength';   Kurz = 'Handwerker'; De = 'Handwerkers'; En = "Craftsman's"; Gruppe = 'skillIntellectCraftsmanship'; Req = 'reqStrengthLevel' }
    [pscustomobject]@{ Att = 'attFortitude';  Kurz = 'Krieger';    De = 'Kriegers';    En = "Warrior's";   Gruppe = 'skillStrengthCombat';         Req = 'reqFortitudeLevel' }
    [pscustomobject]@{ Att = 'attAgility';    Kurz = 'Jaeger';     De = 'Jägers';      En = "Hunter's";    Gruppe = 'skillAgilityCombat';          Req = 'reqAgilityLevel' }
    [pscustomobject]@{ Att = 'attIntellect';  Kurz = 'Heiler';     De = 'Heilers';     En = "Healer's";    Gruppe = 'skillFortitudeRecovery';      Req = 'reqIntellectLevel' }
    [pscustomobject]@{ Att = 'attPerception'; Kurz = 'Fuhrmann';   De = 'Fuhrmanns';   En = "Carter's";    Gruppe = 'skillIntellectInfluence';     Req = 'reqPerceptionLevel' }
)
$raenge = @(@{ R = 1; Att = 1; Plus = 10 }, @{ R = 2; Att = 4; Plus = 3 }, @{ R = 3; Att = 7; Plus = 3 })
$unserProg = Get-Content (Join-Path $Repo 'mod\700_50_Fortschritt\Config\progression.xml') -Raw -Encoding UTF8
$locVanilla = @{}
foreach ($z in Get-Content (Join-Path $cfg 'Localization.csv') -Encoding UTF8) { $k = ($z -split ',', 2)[0]; if ($k) { $locVanilla[$k] = $true } }
$locUnser = @{}
foreach ($z in Get-Content (Join-Path $Repo 'mod\700_90_Sprache\Config\Localization.csv') -Encoding UTF8) {
    if ($z -match '^([^,]+),[^,]*,[^,]*,,,,"([^"]*)",,"([^"]*)"') { $locUnser[$Matches[1]] = @{ En = $Matches[2]; De = $Matches[3] } }
}
$gruppenVanilla = @{}
foreach ($n in $prog.SelectNodes('//skill')) { $gruppenVanilla[$n.GetAttribute('name')] = $n.GetAttribute('parent') }
foreach ($b in $baeume) {
    $b | Add-Member -NotePropertyName Stufen -NotePropertyValue @(
        [regex]::Matches($unserProg, "crafting_skill\[@name='(crafting\w+)'\]/@parent`">$($b.Att)<") | ForEach-Object { $_.Groups[1].Value })
    if ($b.Stufen.Count -eq 0) { $fehler += "Baum $($b.Kurz) ($($b.Att)): keine Handwerks-Stufe in unserer progression.xml" }
    foreach ($st in $b.Stufen) {
        if (-not $stufen.ContainsKey($st)) { $fehler += "Baum $($b.Kurz): '$st' ist keine Handwerks-Stufe des Builds" }
        if (-not $locUnser.ContainsKey("${st}Name")) { $fehler += "Baum $($b.Kurz): '$st' hat keinen Namen in unserer Localization.csv" }
    }
    if (-not $gruppenVanilla.ContainsKey($b.Gruppe)) { $fehler += "Baum $($b.Kurz): Gruppe '$($b.Gruppe)' gibt es im Build nicht" }
    elseif ($unserProg -notmatch "skill\[@name='$($b.Gruppe)'\]/@parent`">$($b.Att)<" -and $gruppenVanilla[$b.Gruppe] -ne $b.Att) {
        $fehler += "Baum $($b.Kurz): Gruppe '$($b.Gruppe)' haengt nicht an $($b.Att)"
    }
    if ($unserProg -match "skill\[@name='$($b.Gruppe)'\]`">true<") { $fehler += "Baum $($b.Kurz): Gruppe '$($b.Gruppe)' ist verborgen" }
    foreach ($r in $raenge) {
        $key = '{0}{1:00}' -f $b.Req, $r.Att
        if (-not $locVanilla.ContainsKey($key)) { $fehler += "Baum $($b.Kurz): Bedingungstext '$key' fehlt in Vanillas Localization.csv" }
    }
}

if ($fehler.Count -gt 0) {
    foreach ($f in $fehler) { Write-Output "  [ROT]  $f" }
    Write-Output "wp12-lernen: $($fehler.Count) Fehler, nichts geschrieben"
    exit 1
}

# --- schreiben ------------------------------------------------------------------------------
if (-not (Test-Path $AusOrdner)) { New-Item -ItemType Directory -Path $AusOrdner | Out-Null }
$sb = New-Object System.Text.StringBuilder
$null = $sb.AppendLine('<?xml version="1.0" encoding="UTF-8" ?>')
$null = $sb.AppendLine('<config>')
$null = $sb.AppendLine('	<!-- ERZEUGT von tools/gen/wp12-lernen.ps1 aus tools/gen/wp12-lernen.tsv - nicht von Hand aendern.')
$null = $sb.AppendLine('	     Lernen durch Tun (F-21, D192, D194; zu pruefen N-138). Alle 10 s je Gegenstand: hat der')
$null = $sb.AppendLine("	     Spieler $jeStuecke Stueck mehr gemacht, als schon gezahlt ist, und steht die Stufe zwischen $schwelleStart und")
$null = $sb.AppendLine("	     $($schwelleEnde - 1), hebt sie sich um 1. Hoechstens $hoechstens-mal je Gegenstand. cv700_lernGezahlt* wird gespeichert,")
$null = $sb.AppendLine('	     .cv700_lernZiel und .cv700_lernJetzt sind Rechenwerte (Vertrag 07 Nachtrag 5). -->')
$null = $sb.AppendLine('	<append xpath="/buffs">')
$null = $sb.AppendLine('		<buff name="buff700_lernen" hidden="true" remove_on_death="false">')
$null = $sb.AppendLine('			<stack_type value="ignore" />')
$null = $sb.AppendLine('			<duration value="0" />')
$null = $sb.AppendLine('			<update_rate value="10" />')
$null = $sb.AppendLine('			<effect_group>')
$t = '				<triggered_effect trigger="onSelfBuffUpdate"'
$jetzt = '<requirement name="CVarCompare" cvar=".cv700_lernJetzt" operation="EQ" value="1" />'
foreach ($e in $zeilen) {
    $zaehler = "cv700_lernGezahlt$($e.Kurz)"
    $null = $sb.AppendLine("				<!-- $($e.Kurz): $($e.Ding), $($e.Stufe), $($e.Art) -->")
    $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernJetzt`" operation=`"set`" value=`"0`" />")
    $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernZiel`" operation=`"set`" value=`"@$zaehler`" />")
    $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernZiel`" operation=`"multiply`" value=`"$jeStuecke`" />")
    $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernZiel`" operation=`"add`" value=`"$jeStuecke`" />")
    $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernJetzt`" operation=`"set`" value=`"1`">" +
        "<requirement name=`"CVarCompare`" cvar=`"_craftCount_$($e.Ding)`" operation=`"GTE`" value=`"@.cv700_lernZiel`" />" +
        "<requirement name=`"CVarCompare`" cvar=`"$zaehler`" operation=`"LT`" value=`"$hoechstens`" />" +
        "<requirement name=`"ProgressionLevel`" progression_name=`"$($e.Stufe)`" operation=`"GTE`" value=`"$schwelleStart`" />" +
        "<requirement name=`"ProgressionLevel`" progression_name=`"$($e.Stufe)`" operation=`"LT`" value=`"$schwelleEnde`" /></triggered_effect>")
    $null = $sb.AppendLine("$t action=`"AddProgressionLevel`" progression_name=`"$($e.Stufe)`" level=`"1`">$jetzt</triggered_effect>")
    $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`"$zaehler`" operation=`"add`" value=`"1`">$jetzt</triggered_effect>")
    $null = $sb.AppendLine("$t action=`"ShowToolbeltMessage`" message_key=`"buff700_lernenGeuebt`">$jetzt</triggered_effect>")
}
$null = $sb.AppendLine('				<!-- ===== Lehrzeit (F-21 §4, D195): jeder gekaufte Rang zahlt EINMAL, der Reihe nach ===== -->')
foreach ($b in $baeume) {
    $zaehler = "cv700_lehrzeitGezahlt$($b.Kurz)"
    $perk = "prk700_lehrzeit$($b.Kurz)"
    foreach ($r in $raenge) {
        $null = $sb.AppendLine("				<!-- $perk Rang $($r.R): $($b.Stufen -join ', ') je +$($r.Plus) -->")
        $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernJetzt`" operation=`"set`" value=`"0`" />")
        $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`".cv700_lernJetzt`" operation=`"set`" value=`"1`">" +
            "<requirement name=`"ProgressionLevel`" progression_name=`"$perk`" operation=`"GTE`" value=`"$($r.R)`" />" +
            "<requirement name=`"CVarCompare`" cvar=`"$zaehler`" operation=`"EQ`" value=`"$($r.R - 1)`" /></triggered_effect>")
        foreach ($st in $b.Stufen) {
            $null = $sb.AppendLine("$t action=`"AddProgressionLevel`" progression_name=`"$st`" level=`"$($r.Plus)`">$jetzt</triggered_effect>")
        }
        $null = $sb.AppendLine("$t action=`"ModifyCVar`" cvar=`"$zaehler`" operation=`"add`" value=`"1`">$jetzt</triggered_effect>")
        $null = $sb.AppendLine("$t action=`"ShowToolbeltMessage`" message_key=`"buff700_lehrzeitGelernt`">$jetzt</triggered_effect>")
    }
}
$null = $sb.AppendLine('			</effect_group>')
$null = $sb.AppendLine('		</buff>')
$null = $sb.AppendLine('	</append>')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('	<!-- Vanillas buffStatusCheck01 laeuft bei jedem Spieler immer; eine eigene effect_group setzt den')
$null = $sb.AppendLine('	     Lern-Buff, wenn er fehlt (wie die Odem-Buffs, 700_75_Magie, D182). -->')
$null = $sb.AppendLine("	<append xpath=`"/buffs/buff[@name='buffStatusCheck01']`">")
$null = $sb.AppendLine('		<effect_group>')
$null = $sb.AppendLine('			<triggered_effect trigger="onSelfBuffUpdate" action="AddBuff" buff="buff700_lernen"><requirement name="!HasBuff" buff="buff700_lernen" /></triggered_effect>')
$null = $sb.AppendLine('		</effect_group>')
$null = $sb.AppendLine('	</append>')
$null = $sb.AppendLine('</config>')
$buffsPfad = Join-Path $AusOrdner 'wp12-lernen-buffs.xml'
[IO.File]::WriteAllText($buffsPfad, $sb.ToString().Replace("`r`n", "`n"), (New-Object System.Text.UTF8Encoding $false))

$ib = New-Object System.Text.StringBuilder
$null = $ib.AppendLine('	<!-- ===== WP12.3 Lehrblaetter +3 (D194) - ERZEUGT von tools/gen/wp12-lernen.ps1, nicht von Hand aendern =====')
$null = $ib.AppendLine('	     Nur die acht Stufen, die durch Tun lernen; die uebrigen sechs heben weiter um 1.')
$null = $ib.AppendLine('	     effect_group[1] ist das Heben; die dritte (Zufallspunkt der Gelehrten-Kleidung) bleibt bei 1. -->')
foreach ($st in ($hefte.Keys | Sort-Object)) {
    $null = $ib.AppendLine("	<set xpath=`"/items/item[@name='$($hefte[$st])']/effect_group[1]/triggered_effect[@action='AddProgressionLevel']/@level`">3</set>   <!-- $st -->")
}
$itemsPfad = Join-Path $AusOrdner 'wp12-lernen-items.xml'
[IO.File]::WriteAllText($itemsPfad, $ib.ToString().Replace("`r`n", "`n"), (New-Object System.Text.UTF8Encoding $false))

# --- Lehrzeit: Perks fuer progression.xml und ihre Texte --------------------------------------
$pb = New-Object System.Text.StringBuilder
$null = $pb.AppendLine('	<!-- ===== WP12.3b Lehrzeit (F-21 §4, D195) - ERZEUGT von tools/gen/wp12-lernen.ps1, nicht von Hand aendern =====')
$null = $pb.AppendLine('	     Je Baum ein Perk, drei Raenge an den Stufen 1/4/7 seines Attributs. Der Perk selbst wirkt nicht:')
$null = $pb.AppendLine('	     buff700_lernen (700_50_Fortschritt/buffs.xml) zahlt jeden Rang einmal aus. -->')
$null = $pb.AppendLine('	<append xpath="/progression/perks">')
foreach ($b in $baeume) {
    $perk = "prk700_lehrzeit$($b.Kurz)"
    $null = $pb.AppendLine("		<perk name=`"$perk`" max_level=`"3`" parent=`"$($b.Gruppe)`" name_key=`"${perk}Name`" desc_key=`"${perk}Desc`" icon=`"ui_game_symbol_book`">")
    foreach ($r in $raenge) {
        $key = '{0}{1:00}' -f $b.Req, $r.Att
        $null = $pb.AppendLine("			<level_requirements level=`"$($r.R)`"><requirement name=`"ProgressionLevel`" progression_name=`"$($b.Att)`" operation=`"GTE`" value=`"$($r.Att)`" desc_key=`"$key`"/></level_requirements>")
    }
    $null = $pb.AppendLine('			<effect_group>')
    foreach ($r in $raenge) {
        $null = $pb.AppendLine("				<effect_description level=`"$($r.R)`" desc_key=`"${perk}Rank$($r.R)Desc`" long_desc_key=`"${perk}Rank$($r.R)LongDesc`"/>")
    }
    $null = $pb.AppendLine('			</effect_group>')
    $null = $pb.AppendLine('		</perk>')
}
$null = $pb.AppendLine('	</append>')
$perksPfad = Join-Path $AusOrdner 'wp12-lernen-perks.xml'
[IO.File]::WriteAllText($perksPfad, $pb.ToString().Replace("`r`n", "`n"), (New-Object System.Text.UTF8Encoding $false))

$rangDe = @{ 1 = 'Zur Hand gehen'; 2 = 'Dem Alten abgeschaut'; 3 = 'Mit eigener Hand' }
$rangEn = @{ 1 = 'Lending a hand'; 2 = 'Watched the old one'; 3 = 'By your own hand' }
$csv = New-Object System.Text.StringBuilder
function Add-Zeile([string]$k, [string]$en, [string]$de) { $null = $csv.Append("$k,progression,Perk,,,,`"$en`",,`"$de`",,,,,,,,,,,`r`n") }
foreach ($b in $baeume) {
    $perk = "prk700_lehrzeit$($b.Kurz)"
    $listeDe = ($b.Stufen | ForEach-Object { $locUnser["${_}Name"].De }) -join ', '
    $listeEn = ($b.Stufen | ForEach-Object { $locUnser["${_}Name"].En }) -join ', '
    Add-Zeile "${perk}Name" 'Apprenticeship' 'Lehrzeit'
    Add-Zeile "${perk}Desc" "A season at the side of one who knows the craft. What you watch, your hands learn.\n\nRaises the $($b.En) crafts: $listeEn." "Eine Zeit an der Seite eines, der das Handwerk kann. Was du siehst, lernen deine Hände.\n\nHebt die Handwerke des $($b.De): $listeDe."
    foreach ($r in $raenge) {
        Add-Zeile "${perk}Rank$($r.R)Desc" $rangEn[$r.R] $rangDe[$r.R]
        $mehr = if ($r.R -eq 1) { ' Enough for the first bound recipes.' } else { '' }
        $mehrDe = if ($r.R -eq 1) { ' Das reicht für die ersten gebundenen Rezepte.' } else { '' }
        Add-Zeile "${perk}Rank$($r.R)LongDesc" "Once: $listeEn rise by $($r.Plus).$mehr" "Einmal: $listeDe steigen um $($r.Plus).$mehrDe"
    }
}
Add-Zeile 'buff700_lehrzeitGelernt' 'What the old one showed you now sits in your hands.' 'Was der Alte dir zeigte, sitzt nun in deinen Händen.'
$textePfad = Join-Path $AusOrdner 'wp12-lernen-texte.csv'
[IO.File]::WriteAllText($textePfad, $csv.ToString(), (New-Object System.Text.UTF8Encoding $false))

Write-Output ("wp12-lernen: {0} Gegenstaende ({1} gebunden, {2} Vorstuecke), {3} Stufen, {4} Lehrblaetter; Bindung gelesen: {5} Rezepte, davon {6} in Stufen ohne Tun" -f `
    $zeilen.Count, @($zeilen | Where-Object Art -eq 'gebunden').Count, @($zeilen | Where-Object Art -eq 'Vorstueck').Count, $hefte.Count, $hefte.Count, $gebunden, $gebundenOhneTun)
Write-Output ("wp12-lernen: Lehrzeit in {0} Baeumen, {1} Handwerks-Stufen, {2} Sprachzeilen" -f `
    $baeume.Count, ($baeume | ForEach-Object { $_.Stufen.Count } | Measure-Object -Sum).Sum, (($csv.ToString() -split "`r`n").Count - 1))
exit 0
