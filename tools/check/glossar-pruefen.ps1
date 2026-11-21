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

    3. ALLEINNAMEN (ergaenzt 2026-11-21, Review zu WP8.6). Ein Name, der in der ganzen
       Sprachdatei nur unter EINEM Schluessel stehen darf - der Name der Mod, damit ihre
       Umbenennung eine Zeile bleibt (D6). Die Zeile mit dem Schluessel muss genau den
       Namen tragen, und in keiner anderen Zeile darf er vorkommen, weder als ganzer Text
       noch mitten in einem Satz. Ein Festbegriff plus zwei Verbotsmuster leistete das
       nicht: eine zweite Zeile, die NUR aus dem Namen bestand, blieb gruen.
       Seit dem zweiten Review (2026-11-21): der Schluessel muss in der Sprachdatei genau
       EINMAL stehen, er wird zeichengenau gesucht ('700_modname' ist nicht
       '700_modName'), und gegen das echte Glossar ist '700_modName' PFLICHT - fehlt die
       Glossarzeile, ist das nicht pruefbar statt gruen (Parameter -PflichtAlleinname).

    WIE VERGLICHEN WIRD (seit dem zweiten Review): Kennungen und Texte Zeichen fuer Zeichen
    (ordinal). PowerShells -ceq/-cne uebergehen Zeichen ohne Sortiergewicht - ein weiches
    Trennzeichen im Namen galt als gleich -, und eine Hashtabelle @{} vergleicht ihre
    Schluessel ohne Gross-/Kleinschreibung.

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
    [string]$Sprachdatei,
    # Schluessel, die das Glossar als Alleinnamen fuehren MUSS, jeden genau einmal. Ohne
    # Angabe: gegen das echte Glossar (kein -Glossar) '700_modName', gegen ein genanntes
    # Glossar keiner. Fehlt ein Pflicht-Alleinname, ist das Ausgang 2.
    [string[]]$PflichtAlleinname
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)

# PFLICHT-ALLEINNAME (zweites Review zu WP8.6, 2026-11-21). Die Alleinnamen-Tabelle war
# freiwillig: wer die Zeile '700_modName' aus dem Glossar UND aus der Sprachdatei nahm,
# bekam "Alleinnamen: 0" und GREEN - die Pruefung fiel still aus. Gegen das echte Glossar
# ist der Schluessel darum Pflicht. Testglossare (mit -Glossar) bleiben frei, sonst
# braeuchte jede Gegenprobe eine Alleinnamen-Tabelle, die sie nichts angeht.
if (-not $PSBoundParameters.ContainsKey('PflichtAlleinname')) {
    if ($Glossar) { $PflichtAlleinname = @() } else { $PflichtAlleinname = @('700_modName') }
}

function Test-Gleich {
    # Zeichen fuer Zeichen. -ceq uebergeht Zeichen ohne Sortiergewicht (U+00AD).
    param([string]$Links, [string]$Rechts)
    return [string]::Equals($Links, $Rechts, [System.StringComparison]::Ordinal)
}

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
$allein = @()        # Kennung, Deutsch, Englisch, Zeile
$ohneKennung = 0

try {
    $zeilen = [IO.File]::ReadAllLines($Glossar, [Text.Encoding]::UTF8)
}
catch {
    Stop-Unpruefbar "Glossar nicht lesbar: $Glossar ($($_.Exception.Message))"
}
# TABELLEN OHNE RANDSTRICHE (ergaenzt 2026-11-20, drittes Review). Markdown erlaubt eine
# Tabelle auch so:
#       Verboten | Sprache | Stattdessen | Quelle
#       ---|---|---|---
#       `zombie` | beide | Seuchentote | Test
# Die Schleife unten erkennt eine Tabellenzeile am fuehrenden '|'. Ohne ihn war die ganze
# Tabelle Fliesstext - ihre Verbote galten nicht, und die Kopfzeilen-Pruefung sah sie nie.
# Darum zuerst jede Tabelle an ihrer TRENNZEILE finden und Kopf, Trennzeile und alle Zeilen
# bis zur naechsten Leerzeile mit Randstrichen versehen. Danach gilt fuer sie dieselbe
# Pruefung wie fuer jede andere.
$trennzeile = '^\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?$'
for ($i = 0; $i -lt $zeilen.Count; $i++) {
    $z = $zeilen[$i].Trim()
    if ($z.IndexOf('|') -lt 0 -or $z -notmatch $trennzeile) { continue }
    if ($i -eq 0 -or $zeilen[$i - 1].Trim().IndexOf('|') -lt 0) {
        Stop-Unpruefbar "Glossar Zeile $($i + 1): Trennzeile ohne Kopfzeile davor"
    }
    $j = $i - 1
    while ($j -lt $zeilen.Count -and $zeilen[$j].Trim().Length -gt 0) {
        $t = $zeilen[$j].Trim()
        if (-not $t.StartsWith('|')) { $t = '| ' + $t }
        if (-not $t.EndsWith('|')) { $t = $t + ' |' }
        $zeilen[$j] = $t
        $j++
    }
    $i = $j
}

$art = ''            # '', 'fest', 'verboten', 'allein'
$inTabelle = $false

for ($i = 0; $i -lt $zeilen.Count; $i++) {
    $roh = $zeilen[$i].Trim()
    $nr = $i + 1

    if (-not $roh.StartsWith('|')) {
        # VERWAISTE TABELLENZEILE (ergaenzt 2026-11-21, viertes Review). Die Vorstufe oben
        # erkennt eine Tabelle an ihrer Trennzeile. Ist die Trennzeile kaputt
        # ("---|---|---|oops") oder fehlt sie, bleiben Kopf und Zeilen ohne Randstrich hier
        # liegen und galten als Fliesstext: die Verbote der Tabelle fielen weg, und solange
        # eine ZWEITE Verbots-Tabelle heil war, blieb das Ergebnis GREEN.
        # Darum: eine Zeile ausserhalb jeder Tabelle, die nach dem Streichen aller
        # Backtick-Abschnitte noch zwei oder mehr '|' traegt, sieht aus wie eine
        # Tabellenzeile und ist nicht pruefbar. Backticks zuerst, weil der Fliesstext die
        # Kopfzeilen in Backticks ZITIERT - das ist Text ueber Tabellen, keine Tabelle.
        $ohneCode = [regex]::Replace($roh, '`[^`]*`', '')
        if (($ohneCode.Split('|').Count - 1) -ge 2) {
            Stop-Unpruefbar "Glossar Zeile ${nr}: sieht aus wie eine Tabellenzeile, gehoert aber zu keiner Tabelle (fehlt die Trennzeile darunter, oder ist sie kaputt?)"
        }
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
        elseif ($kopf -ceq 'Alleinname|Deutsch|Englisch|Quelle') { $art = 'allein' }
        else {
            Stop-Unpruefbar ("Glossar Zeile ${nr}: unbekannte Kopfzeile '| " + ($zellen -join ' | ') + " |'. Erlaubt sind genau '| Kennung | Deutsch | Englisch | Vanilla | Quelle |', '| Verboten | Sprache | Stattdessen | Quelle |' und '| Alleinname | Deutsch | Englisch | Quelle |'")
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

    if ($art -eq 'allein') {
        if ($zellen.Count -ne 4) { Stop-Unpruefbar "Glossar Zeile ${nr}: $($zellen.Count) Spalten statt 4 (steht ein '|' im Namen?)" }
        # Kein Gedankenstrich wie beim Festbegriff: ein Alleinname ohne Schluessel haette
        # keine Zeile, die ihn tragen darf.
        if ($zellen[0] -notmatch '^`([^`]+)`$') { Stop-Unpruefbar "Glossar Zeile ${nr}: ein Alleinname braucht seinen Schluessel in Backticks: '$($zellen[0])'" }
        $schluessel = $Matches[1]
        # Drei Zeichen Mindestlaenge: gesucht wird der Name als Zeichenfolge in JEDEM Text.
        # Ein leerer oder zwei Zeichen kurzer Name staende fast ueberall - Laerm statt Befund.
        if ($zellen[1].Length -lt 3 -or $zellen[2].Length -lt 3) { Stop-Unpruefbar "Glossar Zeile ${nr}: der Alleinname zu '$schluessel' fehlt oder ist kuerzer als drei Zeichen" }
        $allein += [pscustomobject]@{ Kennung = $schluessel; Deutsch = $zellen[1]; Englisch = $zellen[2]; Zeile = $nr }
        continue
    }
}

if ($fest.Count -eq 0) { Stop-Unpruefbar "im Glossar steht kein einziger Festbegriff mit Kennung (Kopfzeile '| Kennung | Deutsch | Englisch | Vanilla | Quelle |')" }
if ($verboten.Count -eq 0) { Stop-Unpruefbar "im Glossar steht kein einziger verbotener Begriff (Kopfzeile '| Verboten | Sprache | Stattdessen | Quelle |')" }
foreach ($verlangt in $PflichtAlleinname) {
    $vorhanden = @($allein | Where-Object { Test-Gleich $_.Kennung $verlangt })
    if ($vorhanden.Count -ne 1) {
        Stop-Unpruefbar "im Glossar steht der Pflicht-Alleinname '$verlangt' $($vorhanden.Count)-mal statt genau einmal (Kopfzeile '| Alleinname | Deutsch | Englisch | Quelle |')"
    }
}

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

# Ordinal, nicht @{}: eine PowerShell-Hashtabelle vergleicht Schluessel ohne
# Gross-/Kleinschreibung, und 'prueffeuer' haette als 'pruefFeuer' gegolten.
$nachSchluessel = New-Object System.Collections.Hashtable ([System.StringComparer]::Ordinal)
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
    if (-not (Test-Gleich $reihe.german $begriff.Deutsch)) {
        $abweichend += "Festbegriff '$($begriff.Kennung)' (Glossar Zeile $($begriff.Zeile)): deutsch steht '$($reihe.german)', das Glossar sagt '$($begriff.Deutsch)'"
    }
    if (-not (Test-Gleich $reihe.english $begriff.Englisch)) {
        $abweichend += "Festbegriff '$($begriff.Kennung)' (Glossar Zeile $($begriff.Zeile)): englisch steht '$($reihe.english)', das Glossar sagt '$($begriff.Englisch)'"
    }
}

# ------------------------------------------------------------------ 1b. Alleinnamen
# Zwei Fragen je Name: traegt die eine Zeile ihn (wie beim Festbegriff), und traegt ihn
# KEINE andere. "Andere" ist jede Zeile ausser der ERSTEN mit dem Schluessel - eine zweite
# Zeile mit demselben Schluessel zaehlt also mit. Gesucht wird die Zeichenfolge, nicht ein
# Muster: OrdinalIgnoreCase haengt nicht an der Kultur des Rechners (vgl. tr-TR oben).
#
# Zweites Review (2026-11-21), drei Aenderungen in diesem Block:
# - Der SCHLUESSEL wird zeichengenau gesucht. Mit -eq galt '700_modname' als '700_modName';
#   stand die klein geschriebene Zeile mit dem richtigen Namen zuerst, wurde sie geprueft
#   und die echte Zeile mit dem falschen Namen nie.
# - Der Schluessel wird GEZAEHLT. Eine zweite Zeile desselben Schluessels mit einem anderen
#   Titel fiel hier nicht auf, nur in der CSV-Formpruefung.
# - Soll und Ist werden ordinal verglichen (Test-Gleich), nicht mit -cne.
$alleinFehler = @()
foreach ($name in $allein) {
    $eigeneAlle = @()
    for ($r = 0; $r -lt $reihen.Count; $r++) {
        if (Test-Gleich $reihen[$r].Key $name.Kennung) { $eigeneAlle += $r }
    }
    $eigene = -1
    if ($eigeneAlle.Count -gt 0) { $eigene = $eigeneAlle[0] }
    if ($eigene -lt 0) {
        $alleinFehler += "Alleinname '$($name.Kennung)' (Glossar Zeile $($name.Zeile)): die Sprachdatei hat diesen Schluessel nicht"
    }
    else {
        if ($eigeneAlle.Count -gt 1) {
            $alleinFehler += "Alleinname '$($name.Kennung)' (Glossar Zeile $($name.Zeile)): der Schluessel steht $($eigeneAlle.Count)-mal in der Sprachdatei, erlaubt ist eine Zeile"
        }
        if (-not (Test-Gleich $reihen[$eigene].german $name.Deutsch)) {
            $alleinFehler += "Alleinname '$($name.Kennung)' (Glossar Zeile $($name.Zeile)): deutsch steht '$($reihen[$eigene].german)', das Glossar sagt '$($name.Deutsch)'"
        }
        if (-not (Test-Gleich $reihen[$eigene].english $name.Englisch)) {
            $alleinFehler += "Alleinname '$($name.Kennung)' (Glossar Zeile $($name.Zeile)): englisch steht '$($reihen[$eigene].english)', das Glossar sagt '$($name.Englisch)'"
        }
    }
    $namen = @($name.Deutsch)
    if (-not [string]::Equals($name.Englisch, $name.Deutsch, [System.StringComparison]::OrdinalIgnoreCase)) { $namen += $name.Englisch }
    for ($r = 0; $r -lt $reihen.Count; $r++) {
        if ($r -eq $eigene) { continue }
        foreach ($spalte in @(@('german', 'deutsch'), @('english', 'englisch'))) {
            $text = [string]$reihen[$r].($spalte[0])
            if (-not $text) { continue }
            foreach ($n in $namen) {
                if ($text.IndexOf($n, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    $alleinFehler += "Alleinname '$n' steht auch in '$($reihen[$r].Key)' ($($spalte[1])): nur '$($name.Kennung)' darf ihn tragen  [Glossar Zeile $($name.Zeile)]"
                }
            }
        }
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
Write-Output ("  Alleinnamen: {0}, Verstoesse: {1}" -f $allein.Count, $alleinFehler.Count)

foreach ($problem in $abweichend) { Write-Output "  [ROT]  $problem" }
foreach ($problem in $alleinFehler) { Write-Output "  [ROT]  $problem" }
foreach ($problem in $treffer) { Write-Output "  [ROT]  $problem" }

Write-Output ''
Write-Output '  Grenzen dieser Pruefung:'
Write-Output '    - Gelesen wird UNSERE Sprachdatei. Vanilla-Zeilen, die wir nicht ueberschreiben,'
Write-Output '      sieht diese Pruefung nicht - auch wenn der Spieler sie liest.'
Write-Output '    - Gefunden wird das Verbotene, nicht das Fehlende: ob ein Text "Seuchentote"'
Write-Output '      sagt, wo er es sollte, prueft niemand.'
Write-Output '    - Festbegriffe ohne Kennung werden gezaehlt, nicht verglichen.'
Write-Output '    - Ein Alleinname wird als Zeichenfolge gesucht, ohne Wortgrenzen: ein Name, der'
Write-Output '      auch Teil eines anderen Wortes ist, wird dort mitgefunden.'

$rot = $abweichend.Count + $treffer.Count + $alleinFehler.Count
if ($rot -gt 0) {
    Write-Output ''
    Write-Output "== Ergebnis: $rot rot -> RED =="
    exit 1
}

Write-Output ''
Write-Output '== Ergebnis: 0 rot -> GREEN =='
exit 0
