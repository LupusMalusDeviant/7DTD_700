#Requires -Version 5.1
# wp5-wesen-namen.ps1 - erzeugt die Sprachzeilen fuer die Namen aller Wesen (Plan-0002 WP5.3,
# F-06 Abschnitte 2 bis 4, D147).
#
# WARUM EIN ERZEUGER: Vanilla gibt jeder Klasse ihren eigenen Sprachschluessel - der Schluessel
# ist der Klassenname, die Stufe steht im Namen ausgeschrieben ("Feral Boe"). Das sind 176
# Zeilen aus 56 Namen und vier Stufenwoertern. Von Hand getippt waere jede Namensaenderung
# fuenf Zeilen, und eine vergessene Stufe fiele niemandem auf.
#
# Die Tabelle steht daneben in wp5-wesen-namen.tsv (UTF-8; dieses Skript enthaelt keine Umlaute
# und braucht darum keine BOM). Das Skript prueft sie gegen den Build und bricht ab, wenn
#   - eine Klasse 'zombie*' oder 'animal*' des Builds in der Tabelle fehlt (Vorlagen ausgenommen),
#   - eine Zeile der Tabelle im Build keine Klasse hat,
#   - Vanillas Sprachdatei fuer eine Klasse keinen Schluessel fuehrt (dann waere unsere Zeile tot),
#   - zwei Klassen denselben Namen bekaemen, ohne dass Vanilla ihnen selbst denselben gibt,
#   - eine Stufe vorkommt, fuer die kein Stufenwort in der Tabelle steht.
#
# Aufruf:
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/gen/wp5-wesen-namen.ps1 [-Spiel <pfad>]
# Schreibt nach tools/gen/out/:
#   wp5-wesen-namen-texte.csv     Localization-Zeilen ohne Kopfzeile
#   wp5-wesen-namen-keys.txt      Schluessel fuer tools/check/vanilla-keys.txt, mit dem englischen Namen als Grund
#   wp5-wesen-namen-glossar.md    Tabellenzeilen fuer docs/glossar.md (Festbegriffe)
# Die Ausgabe ist nicht das Erzeugnis - das Erzeugnis ist die Zeile in der Sprachdatei
# (Vertrag 04, Nachtrag WP7.1b).

[CmdletBinding()]
param(
    [string] $Spiel = $env:SDTD_PATH,
    [string] $Tabelle,
    [string] $AusOrdner
)

$ErrorActionPreference = 'Stop'
if (-not $Spiel) { throw 'Kein Spielpfad: SDTD_PATH setzen oder -Spiel angeben.' }
$hier = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Tabelle) { $Tabelle = Join-Path $hier 'wp5-wesen-namen.tsv' }
if (-not $AusOrdner) { $AusOrdner = Join-Path $hier 'out' }
if (-not (Test-Path $AusOrdner)) { New-Item -ItemType Directory -Path $AusOrdner | Out-Null }
$utf8 = New-Object System.Text.UTF8Encoding($false)
$config = Join-Path $Spiel 'Data\Config'
$stufen = 'Feral', 'Radiated', 'Charged', 'Infernal'

# ---------------------------------------------------------------- Tabelle lesen
$wort = @{}
$zeile = @{}
$nr = 0
foreach ($z in [IO.File]::ReadAllLines($Tabelle, $utf8)) {
    $nr++
    if (-not $z.Trim() -or $z.StartsWith('#')) { continue }
    $f = $z.Split("`t")
    if ($f.Count -ne 5) { throw "Tabelle Zeile ${nr}: $($f.Count) Spalten statt 5" }
    $k, $art, $g, $de, $en = $f
    if ($art -eq 'wort') {
        $p = $de.Split('/')
        if ($p.Count -ne 2) { throw "Tabelle Zeile ${nr}: ein Baustein braucht 'maennlich/weiblich'" }
        $wort[$k] = @{ m = $p[0]; w = $p[1]; en = $en }
        continue
    }
    if ($art -notin 'stand', 'eigen', 'tier') { throw "Tabelle Zeile ${nr}: Art '$art' gibt es nicht" }
    if ($g -notin 'm', 'w') { throw "Tabelle Zeile ${nr}: Geschlecht '$g' gibt es nicht" }
    if ($zeile.ContainsKey($k)) { throw "Tabelle Zeile ${nr}: '$k' steht zweimal" }
    foreach ($t in $de, $en) { if ($t.Contains('"') -or $t.Contains(',')) { throw "Tabelle Zeile ${nr}: Name mit Komma oder Anfuehrungszeichen" } }
    $zeile[$k] = @{ art = $art; g = $g; de = $de; en = $en; benutzt = $false }
}
if (-not $wort.ContainsKey('grund')) { throw "Der Tabelle fehlt der Baustein 'grund'" }

# ---------------------------------------------------------------- Build lesen
[xml]$ec = [IO.File]::ReadAllText((Join-Path $config 'entityclasses.xml'))
$klassen = @($ec.entity_classes.entity_class | ForEach-Object { $_.name } |
    Where-Object { $_ -match '^(zombie|animal)' -and $_ -notmatch 'Template' } | Sort-Object)
$vanilla = @{}
foreach ($z in [IO.File]::ReadAllLines((Join-Path $config 'Localization.csv'), $utf8)) {
    $i = $z.IndexOf(',')
    if ($i -gt 0) { $vanilla[$z.Substring(0, $i)] = $z }
}
function Get-VanillaEnglisch([string]$Schluessel) {
    # Spalte 'english' ist die siebte; Namen von Wesen tragen in Vanilla kein Komma.
    return ($vanilla[$Schluessel].Split(',')[6]).Trim('"')
}

# ---------------------------------------------------------------- Namen bilden
$fehler = New-Object System.Collections.Generic.List[string]
$ergebnis = New-Object System.Collections.Generic.List[object]
foreach ($k in $klassen) {
    $grund = $k; $stufe = ''
    foreach ($s in $stufen) { if ($k.EndsWith($s) -and $k.Length -gt $s.Length) { $grund = $k.Substring(0, $k.Length - $s.Length); $stufe = $s } }
    if (-not $zeile.ContainsKey($grund)) { $fehler.Add("Klasse '$k' (Grundname '$grund') steht nicht in der Tabelle"); continue }
    if (-not $vanilla.ContainsKey($k)) { $fehler.Add("Klasse '$k' hat in Vanillas Sprachdatei keinen Schluessel"); continue }
    $e = $zeile[$grund]; $e.benutzt = $true
    if ($stufe) {
        if (-not $wort.ContainsKey($stufe)) { $fehler.Add("Stufe '$stufe' ($k) hat kein Stufenwort"); continue }
        $de = $wort[$stufe][$e.g] + ' ' + $e.de
        $en = $wort[$stufe].en + ' ' + $e.en
    }
    elseif ($e.art -eq 'stand') {
        $de = $wort['grund'][$e.g] + ' ' + $e.de
        $en = $wort['grund'].en + ' ' + $e.en
    }
    else { $de = $e.de; $en = $e.en }
    $ergebnis.Add([pscustomobject]@{ Schluessel = $k; Grund = $grund; Stufe = $stufe; DE = $de; EN = $en; VanillaEN = (Get-VanillaEnglisch $k) })
}
foreach ($k in $zeile.Keys) { if (-not $zeile[$k].benutzt) { $fehler.Add("Tabellenzeile '$k' hat im Build keine Klasse") } }

# zwei Klassen, ein Name: nur erlaubt, wo Vanilla selbst denselben Namen vergibt
foreach ($gruppe in ($ergebnis | Group-Object DE | Where-Object { $_.Count -gt 1 })) {
    if (@($gruppe.Group | ForEach-Object { $_.VanillaEN } | Select-Object -Unique).Count -gt 1) {
        $fehler.Add("Derselbe Name '$($gruppe.Name)' fuer: " + (($gruppe.Group | ForEach-Object { $_.Schluessel }) -join ', '))
    }
}
if ($fehler.Count -gt 0) {
    $fehler | ForEach-Object { Write-Output "FEHLER: $_" }
    Write-Output "== Ergebnis: $($fehler.Count) Fehler - nichts geschrieben =="
    exit 1
}

# ---------------------------------------------------------------- schreiben
$texte = $ergebnis | ForEach-Object { '{0},entityclasses,Entity,,,,"{1}",,"{2}",,,,,,,,,,,' -f $_.Schluessel, $_.EN, $_.DE }
$keys = $ergebnis | ForEach-Object { '{0,-34}# {1}' -f $_.Schluessel, $_.EN }
$glossar = $ergebnis | Where-Object { -not $_.Stufe } | ForEach-Object { '| `{0}` | {1} | {2} | {3} | F-06, D147 (Vorschlag) |' -f $_.Schluessel, $_.DE, $_.EN, $_.VanillaEN }
[IO.File]::WriteAllText((Join-Path $AusOrdner 'wp5-wesen-namen-texte.csv'), (($texte -join "`n") + "`n"), $utf8)
[IO.File]::WriteAllText((Join-Path $AusOrdner 'wp5-wesen-namen-keys.txt'), (($keys -join "`n") + "`n"), $utf8)
[IO.File]::WriteAllText((Join-Path $AusOrdner 'wp5-wesen-namen-glossar.md'), (($glossar -join "`n") + "`n"), $utf8)

$z = @($ergebnis | Where-Object { $_.Schluessel -like 'zombie*' }).Count
$a = @($ergebnis | Where-Object { $_.Schluessel -like 'animal*' }).Count
Write-Output ("Klassen im Build: {0} (zombie {1}, animal {2}); Grundnamen in der Tabelle: {3}; Sprachzeilen: {4}; Glossarzeilen: {5}" -f $klassen.Count, $z, $a, $zeile.Count, @($texte).Count, @($glossar).Count)
Write-Output '== Ergebnis: 0 Fehler =='
exit 0
