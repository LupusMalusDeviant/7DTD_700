<#
.SYNOPSIS
    Hat jede Spieltest-Zeile (S-NN) einen Platz im Drehbuch?

.DESCRIPTION
    Plan-0002 WP14.2, Vertrag 04 "Nachtrag WP14.2" (Abnahme offen), D191.

    Die Liste der Spieltests steht in docs\pruefung\0000-entscheidungen-fuer-den-nutzer.md
    (Abschnitt 6, je eine Tabellenzeile "| S-NN | ..."). Das Drehbuch
    docs\pruefung\0004-drehbuch-spieltests.md ordnet sie Sitzungen zu. Waechst die Liste und
    das Drehbuch nicht mit, faellt ein Test still heraus - darum diese Pruefung.

    Regeln:
      1. Jede S-Nummer der Liste steht im Drehbuch als eigene Nummer (S-3 ist nicht S-33;
         "S-32 bis S-35" nennt S-33 NICHT - Bereiche zaehlen nicht, sie verstecken Zeilen).
      2. Jede S-Nummer im Drehbuch steht in der Liste (kein Tippfehler, keine erfundene).
      3. Eine ganz gestrichene Zeile ("| ~~S-NN" ... ) braucht keinen Platz.

    Ausgang 0 = gruen, 1 = rot, 2 = nicht pruefbar (Datei fehlt, keine S-Zeile gefunden).

.PARAMETER Liste
    Datei mit den S-Zeilen. Vorgabe: docs\pruefung\0000-entscheidungen-fuer-den-nutzer.md
.PARAMETER Drehbuch
    Das Drehbuch. Vorgabe: docs\pruefung\0004-drehbuch-spieltests.md
#>
param(
    [string]$Liste,
    [string]$Drehbuch
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
if (-not $Liste) { $Liste = Join-Path $repoRoot 'docs\pruefung\0000-entscheidungen-fuer-den-nutzer.md' }
if (-not $Drehbuch) { $Drehbuch = Join-Path $repoRoot 'docs\pruefung\0004-drehbuch-spieltests.md' }

foreach ($datei in @($Liste, $Drehbuch)) {
    if (-not (Test-Path -LiteralPath $datei)) {
        Write-Output "  nicht pruefbar: Datei fehlt: $datei"
        exit 2
    }
}

$utf8 = New-Object System.Text.UTF8Encoding($false)
$listeText = [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $Liste).Path, $utf8)
$buchText = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $Drehbuch).Path, $utf8)

# Regel 3: eine Zeile, die mit "| ~~S-NN" beginnt, ist gestrichen.
$zeilen = @{}
$gestrichen = @{}
foreach ($z in $listeText) {
    $m = [regex]::Match($z, '^\|\s*(~~)?(S-\d+)(?!\d)')
    if (-not $m.Success) { continue }
    $id = $m.Groups[2].Value
    if ($m.Groups[1].Success) { $gestrichen[$id] = $true } else { $zeilen[$id] = $true }
}
foreach ($id in @($gestrichen.Keys)) { if ($zeilen.ContainsKey($id)) { $gestrichen.Remove($id) } }

if ($zeilen.Count -eq 0) {
    Write-Output "  nicht pruefbar: keine S-Zeile in der Liste gefunden: $Liste"
    exit 2
}

# Nummern im Drehbuch, als eigene Nummer: davor kein Buchstabe/Ziffer, danach keine Ziffer.
$imBuch = @{}
foreach ($m in [regex]::Matches($buchText, '(?<![\w-])(S-\d+)(?!\d)')) { $imBuch[$m.Groups[1].Value] = $true }

$ohnePlatz = @($zeilen.Keys | Where-Object { -not $imBuch.ContainsKey($_) } | Sort-Object)
$unbekannt = @($imBuch.Keys | Where-Object { -not $zeilen.ContainsKey($_) -and -not $gestrichen.ContainsKey($_) } | Sort-Object)

foreach ($id in $ohnePlatz) { Write-Output "  [ROT] $id hat keinen Platz im Drehbuch" }
foreach ($id in $unbekannt) { Write-Output "  [ROT] $id steht im Drehbuch, aber nicht in der Liste" }
Write-Output ("  Drehbuch: {0} S-Zeilen, {1} ohne Platz, {2} unbekannt, {3} gestrichen" -f $zeilen.Count, $ohnePlatz.Count, $unbekannt.Count, $gestrichen.Count)

if ($ohnePlatz.Count -gt 0 -or $unbekannt.Count -gt 0) { exit 1 }
exit 0
