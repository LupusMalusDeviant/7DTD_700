<#
.SYNOPSIS
    Vergleicht docs/glossar.md mit unserer Localization.csv: Festbegriffe und verbotene
    Begriffe.

.DESCRIPTION
    WARUM ES DIESES SKRIPT GIBT. F-12 nennt das Glossar die verbindliche Begriffsquelle und
    verlangt als Abnahme "Glossar und Localization sind konsistent (Pruefskript)". Ein
    Glossar, das niemand gegen die Texte haelt, ist eine Absichtserklaerung: der zweite
    Text, der "Lagerfeuer" statt "Feuerstelle" schreibt, faellt erst im Spiel auf - oder nie.

    WAS ES PRUEFT, beides aus derselben Datei gelesen (docs/glossar.md):

    1. FESTBEGRIFFE. Jede Glossarzeile mit einer Kennung nennt einen deutschen und einen
       englischen Namen. Die Zeile der Sprachdatei mit diesem Schluessel muss genau diese
       beiden Texte tragen. Faellt auf: ein Name wurde in der Sprachdatei geaendert und im
       Glossar nicht (oder umgekehrt), oder der Schluessel ist verschwunden.

    2. VERBOTENE BEGRIFFE. Jedes Muster der Verbots-Tabellen wird in der deutschen und/oder
       englischen Spalte JEDER Zeile unserer Sprachdatei gesucht. Faellt auf: ein eigener
       Text, der "Zombie", "Blutmond" oder "Lagerfeuer" sagt.

    WAS ES NICHT PRUEFT:
    - Vanillas Sprachdatei. Die rund 500 sichtbaren Vanilla-Zeilen mit Weltbegriffen sieht
      dieses Skript nicht - es liest nur, was wir schreiben. Sie sind Arbeitsvorrat (WP8.5).
    - Ob ein Festbegriff OHNE Kennung (Seuchentote, Seuchennacht) im Fliesstext richtig
      geschrieben ist. Gefunden wird nur das Verbotene, nicht das Fehlende.
    - Vollstaendigkeit: eine Namenszeile der Sprachdatei, die im Glossar nicht steht, ist
      kein Fehler.

    AUSGANG: 0 gruen, 1 Befunde, 2 nicht pruefbar (Datei fehlt, keine Tabelle gelesen, Zeile
    nicht lesbar, Muster kein regulaerer Ausdruck). 2 ist KEIN Gruen: ein Pruefer, der nichts
    gelesen hat, hat nichts bestanden.

.NOTES
    ACHTUNG, Kodierung: UTF-8 MIT BOM, sonst liest Windows PowerShell 5.1 die Datei als
    ANSI. Der Quelltext ist mit Absicht reines ASCII.
#>
[CmdletBinding()]
param(
    # Das Glossar. Ohne Angabe docs/glossar.md.
    [string]$Glossar,
    # Unsere Sprachdatei. Ohne Angabe die des Sprach-Modlets.
    [string]$Sprachdatei
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

if (-not $Glossar) { $Glossar = Join-Path $repoRoot 'docs\glossar.md' }
if (-not $Sprachdatei) { $Sprachdatei = Join-Path $repoRoot 'mod\700_90_Sprache\Config\Localization.csv' }

function Stop-Unpruefbar {
    param([string]$Grund)
    Write-Output "  [NICHT PRUEFBAR]  $Grund"
    Write-Output ''
    Write-Output '== Ergebnis: nicht pruefbar -> RED =='
    exit 2
}

if (-not (Test-Path -LiteralPath $Glossar -PathType Leaf)) { Stop-Unpruefbar "Glossar fehlt: $Glossar" }
if (-not (Test-Path -LiteralPath $Sprachdatei -PathType Leaf)) { Stop-Unpruefbar "Sprachdatei fehlt: $Sprachdatei" }

# Auf den vollen Pfad bringen (geaendert 2026-11-20 nach dem Review). Test-Path rechnet
# einen relativen Pfad gegen den Ordner der PowerShell, [IO.File] gegen den Ordner des
# PROZESSES - nach einem Push-Location sind das zwei verschiedene. Die Datei wurde dann
# "gefunden" und beim Lesen nicht mehr.
$Glossar = (Resolve-Path -LiteralPath $Glossar).ProviderPath
$Sprachdatei = (Resolve-Path -LiteralPath $Sprachdatei).ProviderPath

# ------------------------------------------------------------------ Glossar lesen
$gedankenstrich = [string][char]0x2014
$fest = @()          # Kennung, Deutsch, Englisch, Zeile
$verboten = @()      # Muster (Regex), Text, Sprache, Stattdessen, Zeile
$ohneKennung = 0

try {
    $zeilen = [IO.File]::ReadAllLines($Glossar, [Text.Encoding]::UTF8)
}
catch {
    Stop-Unpruefbar "Glossar nicht lesbar: $Glossar ($($_.Exception.Message))"
}
$art = ''            # '', 'fest', 'verboten', 'andere'
$inTabelle = $false

for ($i = 0; $i -lt $zeilen.Count; $i++) {
    $roh = $zeilen[$i].Trim()
    $nr = $i + 1

    if (-not $roh.StartsWith('|')) {
        $inTabelle = $false
        $art = ''
        continue
    }

    # Trennzeile |---|---|
    if ($roh -match '^\|[\s:\-|]+\|?$') { continue }

    $innen = $roh.Trim('|')
    $zellen = @($innen.Split('|') | ForEach-Object { $_.Trim() })

    if (-not $inTabelle) {
        # Erste Zeile einer Tabelle ist ihre Kopfzeile; sie bestimmt die Art.
        $inTabelle = $true
        #
        # JEDE Tabelle des Glossars muss eine der beiden Formen haben (geaendert 2026-11-20
        # nach dem Review). Vorher galt eine Tabelle mit unbekannter Kopfzeile als "Text
        # fuer Menschen" und wurde uebersprungen - und damit schaltete ein Tippfehler in
        # der Kopfzeile ("Sprachen" statt "Sprache") eine ganze Verbots-Tabelle still ab:
        # zwoelf Regeln weg, Ergebnis GREEN. Eine Tabelle, die der Pruefer nicht versteht,
        # ist darum nicht pruefbar, nicht unwichtig.
        $kopf = $zellen -join '|'
        if ($kopf -ceq 'Kennung|Deutsch|Englisch|Vanilla|Quelle') { $art = 'fest' }
        elseif ($kopf -ceq 'Verboten|Sprache|Stattdessen|Quelle') { $art = 'verboten' }
        else {
            Stop-Unpruefbar ("Glossar Zeile ${nr}: unbekannte Kopfzeile '| " + ($zellen -join ' | ') + " |'. Erlaubt sind genau '| Kennung | Deutsch | Englisch | Vanilla | Quelle |' und '| Verboten | Sprache | Stattdessen | Quelle |'")
        }
        continue
    }

    if ($art -eq 'fest') {
        if ($zellen.Count -ne 5) { Stop-Unpruefbar "Glossar Zeile ${nr}: $($zellen.Count) Spalten statt 5 (steht ein '|' im Text?)" }
        $kennung = $zellen[0]
        if ($kennung -eq $gedankenstrich -or $kennung -eq '-') { $ohneKennung++; continue }
        if ($kennung -notmatch '^`([^`]+)`$') { Stop-Unpruefbar "Glossar Zeile ${nr}: erste Spalte ist weder eine Kennung in Backticks noch ein Gedankenstrich: '$kennung'" }
        $schluessel = $Matches[1]
        if ($zellen[1].Length -eq 0 -or $zellen[2].Length -eq 0) { Stop-Unpruefbar "Glossar Zeile ${nr}: '$schluessel' ohne deutschen oder englischen Namen" }
        $fest += [pscustomobject]@{ Kennung = $schluessel; Deutsch = $zellen[1]; Englisch = $zellen[2]; Zeile = $nr }
        continue
    }

    if ($art -eq 'verboten') {
        if ($zellen.Count -ne 4) { Stop-Unpruefbar "Glossar Zeile ${nr}: $($zellen.Count) Spalten statt 4 (ein Muster darf kein '|' enthalten)" }
        if ($zellen[0] -notmatch '^`([^`]+)`$') { Stop-Unpruefbar "Glossar Zeile ${nr}: das Muster steht nicht in Backticks: '$($zellen[0])'" }
        $muster = $Matches[1]
        $sprache = $zellen[1]
        if (@('DE', 'EN', 'beide') -cnotcontains $sprache) { Stop-Unpruefbar "Glossar Zeile ${nr}: Sprache '$sprache' ist weder DE noch EN noch beide" }
        try {
            # CultureInvariant: ohne das haengt "Gross-/Kleinschreibung egal" an der Sprache
            # des Rechners. Unter tr-TR ist das kleine Gegenstueck zu 'I' das punktlose i,
            # und 'zombie' trifft 'ZOMBIE' nicht mehr (Review vom 2026-11-20).
            $optionen = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
            $regex = New-Object System.Text.RegularExpressions.Regex($muster, $optionen)
        }
        catch {
            Stop-Unpruefbar "Glossar Zeile ${nr}: '$muster' ist kein regulaerer Ausdruck"
        }
        $verboten += [pscustomobject]@{ Regex = $regex; Text = $muster; Sprache = $sprache; Stattdessen = $zellen[2]; Zeile = $nr }
        continue
    }
}

if ($fest.Count -eq 0) { Stop-Unpruefbar "im Glossar steht kein einziger Festbegriff mit Kennung (Kopfzeile '| Kennung | Deutsch | Englisch | Vanilla | Quelle |')" }
if ($verboten.Count -eq 0) { Stop-Unpruefbar "im Glossar steht kein einziger verbotener Begriff (Kopfzeile '| Verboten | Sprache | Stattdessen | Quelle |')" }

# -------------------------------------------------------------- Sprachdatei lesen
try {
    $reihen = @(Import-Csv -LiteralPath $Sprachdatei -Encoding UTF8)
}
catch {
    Stop-Unpruefbar "Sprachdatei nicht lesbar: $Sprachdatei ($($_.Exception.Message))"
}
if ($reihen.Count -eq 0) { Stop-Unpruefbar "die Sprachdatei hat keine Zeile: $Sprachdatei" }
$spalten = @($reihen[0].PSObject.Properties.Name)
foreach ($pflicht in 'Key', 'english', 'german') {
    if ($spalten -notcontains $pflicht) { Stop-Unpruefbar "die Sprachdatei hat keine Spalte '$pflicht'" }
}

$nachSchluessel = @{}
foreach ($reihe in $reihen) {
    if ($reihe.Key -and -not $nachSchluessel.ContainsKey($reihe.Key)) { $nachSchluessel[$reihe.Key] = $reihe }
}

# ------------------------------------------------------------------ 1. Festbegriffe
$abweichend = @()
foreach ($begriff in $fest) {
    if (-not $nachSchluessel.ContainsKey($begriff.Kennung)) {
        $abweichend += "Festbegriff '$($begriff.Kennung)' (Glossar Zeile $($begriff.Zeile)): die Sprachdatei hat diesen Schluessel nicht"
        continue
    }
    $reihe = $nachSchluessel[$begriff.Kennung]
    if ($reihe.german -cne $begriff.Deutsch) {
        $abweichend += "Festbegriff '$($begriff.Kennung)' (Glossar Zeile $($begriff.Zeile)): deutsch steht '$($reihe.german)', das Glossar sagt '$($begriff.Deutsch)'"
    }
    if ($reihe.english -cne $begriff.Englisch) {
        $abweichend += "Festbegriff '$($begriff.Kennung)' (Glossar Zeile $($begriff.Zeile)): englisch steht '$($reihe.english)', das Glossar sagt '$($begriff.Englisch)'"
    }
}

# ------------------------------------------------------------ 2. Verbotene Begriffe
$treffer = @()
$betroffen = @{}
foreach ($reihe in $reihen) {
    foreach ($v in $verboten) {
        if ($v.Sprache -ne 'EN' -and $reihe.german) {
            $m = $v.Regex.Match($reihe.german)
            if ($m.Success) {
                $treffer += "verbotener Begriff in '$($reihe.Key)' (deutsch): '$($m.Value)'  [Muster $($v.Text), Glossar Zeile $($v.Zeile)]  -> $($v.Stattdessen)"
                $betroffen[$reihe.Key] = $true
            }
        }
        if ($v.Sprache -ne 'DE' -and $reihe.english) {
            $m = $v.Regex.Match($reihe.english)
            if ($m.Success) {
                $treffer += "verbotener Begriff in '$($reihe.Key)' (englisch): '$($m.Value)'  [Muster $($v.Text), Glossar Zeile $($v.Zeile)]  -> $($v.Stattdessen)"
                $betroffen[$reihe.Key] = $true
            }
        }
    }
}

# ------------------------------------------------------------------------ Bericht
Write-Output ("  Glossar: {0} Festbegriffe mit Kennung, {1} ohne Kennung, {2} verbotene Muster" -f $fest.Count, $ohneKennung, $verboten.Count)
Write-Output ("  Sprachdatei: {0} Zeilen, deutsch und englisch gelesen" -f $reihen.Count)
Write-Output ("  abweichende Festbegriffe: {0}" -f $abweichend.Count)
Write-Output ("  Zeilen mit verbotenem Begriff: {0}" -f $betroffen.Count)

foreach ($problem in $abweichend) { Write-Output "  [ROT]  $problem" }
foreach ($problem in $treffer) { Write-Output "  [ROT]  $problem" }

Write-Output ''
Write-Output '  Grenzen dieser Pruefung:'
Write-Output '    - Gelesen wird UNSERE Sprachdatei. Vanilla-Zeilen, die wir nicht ueberschreiben,'
Write-Output '      sieht diese Pruefung nicht - auch wenn der Spieler sie liest.'
Write-Output '    - Gefunden wird das Verbotene, nicht das Fehlende: ob ein Text "Seuchentote"'
Write-Output '      sagt, wo er es sollte, prueft niemand.'
Write-Output '    - Festbegriffe ohne Kennung werden gezaehlt, nicht verglichen.'

$rot = $abweichend.Count + $treffer.Count
if ($rot -gt 0) {
    Write-Output ''
    Write-Output "== Ergebnis: $rot rot -> RED =="
    exit 1
}

Write-Output ''
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
