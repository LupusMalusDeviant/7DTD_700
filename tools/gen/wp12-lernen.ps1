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
foreach ($m in [regex]::Matches((Get-Content $bindung -Raw -Encoding UTF8), $muster)) {
    $ding = $m.Groups[1].Value; $st = $m.Groups[2].Value; $ab = [int]$m.Groups[3].Value
    $gebunden++
    $treffer = @($zeilen | Where-Object Ding -eq $ding)
    if ($ab -gt $schwelleEnde) {
        if ($treffer.Count -gt 0) { $fehler += "'$ding' oeffnet erst bei $ab und kann nie zaehlen (Tun endet bei $schwelleEnde)" }
        continue
    }
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

Write-Output ("wp12-lernen: {0} Gegenstaende ({1} gebunden, {2} Vorstuecke), {3} Stufen, {4} Lehrblaetter; Bindung gelesen: {5} Rezepte" -f `
    $zeilen.Count, @($zeilen | Where-Object Art -eq 'gebunden').Count, @($zeilen | Where-Object Art -eq 'Vorstueck').Count, $hefte.Count, $hefte.Count, $gebunden)
exit 0
