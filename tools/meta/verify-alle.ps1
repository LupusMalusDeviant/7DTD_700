<#
.SYNOPSIS
    Prueft alle Soll-Signaturen unter tools/meta/expect gegen die DLLs des Spiels
    (mod700meta verify). Teil des Pruefbefehls seit Review 35 (2026-11-24).

.DESCRIPTION
    Vorher liefen die Soll-Dateien nur von Hand. Ein Spiel-Update, das eine Methode
    aendert, an der unser C# haengt (etwa die 13 Signaturen der Odem-Leiste in wp106.tsv),
    machte keine Pruefung rot.

    Welche DLL eine Soll-Datei meint, steht in ihrer Zeile
        # Aufruf:  mod700meta verify "<ziel>" --expect ...
    "<Assembly-CSharp.dll>"  -> <Spiel>\7DaysToDie_Data\Managed\Assembly-CSharp.dll
    "<SDTD_PATH>/a/b.dll"    -> <Spiel>\a\b.dll
    Eine Datei ohne diese Zeile oder mit einem anderen Ziel ist nicht pruefbar, nicht gruen.

    Ausgang: 0 alles gruen; 1 mindestens eine Zeile weicht ab; 2 nicht pruefbar (kein
    Spielpfad, DLL fehlt, Werkzeug fehlt, keine Soll-Datei, Datei ohne Aufruf-Zeile) und
    sonst nichts rot.

    Pfade mit [IO.Path]::Combine und [IO.File]::Exists, nicht Join-Path/Test-Path: ein
    Spielpfad auf einem nicht eingehaengten Laufwerk liess Join-Path werfen (check-all,
    drittes Review 2026-11-20).

.PARAMETER Spiel
    Installationsordner des Spiels. Vorgabe: SDTD_PATH.
.PARAMETER Soll
    Ordner mit den Soll-Dateien (*.tsv). Vorgabe: tools/meta/expect.
.PARAMETER Exe
    mod700meta.exe. Vorgabe: der Release-Bau unter tools/meta/Mod700.Meta/bin.
#>
[CmdletBinding()]
param(
    [string]$Spiel = $env:SDTD_PATH,
    [string]$Soll,
    [string]$Exe
)

$ErrorActionPreference = 'Stop'
if (-not $Soll) { $Soll = [IO.Path]::Combine($PSScriptRoot, 'expect') }
if (-not $Exe) { $Exe = [IO.Path]::Combine($PSScriptRoot, 'Mod700.Meta\bin\Release\net10.0\mod700meta.exe') }

function Stop-Unpruefbar([string]$Grund) {
    Write-Output "  NICHT GEPRUEFT: $Grund"
    Write-Output "== Signaturen: nicht pruefbar -> RED =="
    exit 2
}

if (-not [IO.File]::Exists($Exe)) {
    Stop-Unpruefbar "mod700meta fehlt: $Exe (bauen: dotnet build -c Release tools/meta/Mod700.Meta/Mod700.Meta.csproj)"
}
$Spiel = "$Spiel".Trim().Trim('"')
if (-not $Spiel) { Stop-Unpruefbar 'SDTD_PATH ist nicht gesetzt - ohne Spiel keine DLL.' }
if (-not [IO.Directory]::Exists($Soll)) { Stop-Unpruefbar "Ordner der Soll-Dateien fehlt: $Soll" }
$dateien = @([IO.Directory]::GetFiles($Soll, '*.tsv') | Sort-Object)
if ($dateien.Count -eq 0) { Stop-Unpruefbar "keine Soll-Datei (*.tsv) in $Soll" }

$gruen = 0
$zeilen = 0
$rot = @()
$offen = @()

foreach ($datei in $dateien) {
    $name = [IO.Path]::GetFileName($datei)
    $aufruf = $null
    foreach ($z in [IO.File]::ReadAllLines($datei)) {
        if ($z -match '^#\s*Aufruf:.*\bverify\s+"([^"]+)"') { $aufruf = $Matches[1]; break }
    }
    if (-not $aufruf) { $offen += "${name}: keine Zeile '# Aufruf: mod700meta verify ""<dll>"" ...'"; continue }

    try {
        if ($aufruf -ceq '<Assembly-CSharp.dll>') {
            $dll = [IO.Path]::Combine($Spiel, '7DaysToDie_Data\Managed\Assembly-CSharp.dll')
        }
        elseif ($aufruf.StartsWith('<SDTD_PATH>/', [StringComparison]::Ordinal)) {
            $dll = [IO.Path]::Combine($Spiel, $aufruf.Substring('<SDTD_PATH>/'.Length).Replace('/', '\'))
        }
        else { $offen += "${name}: unbekanntes Ziel '$aufruf'"; continue }
    }
    catch { $offen += "${name}: kein gueltiger Pfad aus '$Spiel'"; continue }
    if (-not [IO.File]::Exists($dll)) { $offen += "${name}: DLL fehlt: $dll"; continue }

    $vorher = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { $ausgabe = & $Exe verify $dll --expect $datei 2>$null } finally { $ErrorActionPreference = $vorher }
    $kode = $LASTEXITCODE

    $json = $null
    try { $json = ($ausgabe -join "`n") | ConvertFrom-Json } catch { $json = $null }
    if ($null -eq $json -or ($kode -ne 0 -and $kode -ne 1)) {
        $offen += "${name}: mod700meta endete mit Exit $kode ohne lesbares Ergebnis"
        continue
    }
    $zeilen += [int]$json.summary.checked_rows
    if ($kode -eq 0) { $gruen++; continue }
    foreach ($r in @($json.results | Where-Object { $_.verdict -ne 'ok' })) {
        $was = if ($r.expected) { $r.expected } else { $r.line }
        $rot += "${name}: $($r.verdict) $was - $($r.detail)"
    }
}

Write-Output ("  Signaturen: {0} Soll-Dateien, {1} gruen, {2} Zeilen gelesen, {3} Abweichungen, {4} nicht pruefbar" -f `
    $dateien.Count, $gruen, $zeilen, $rot.Count, $offen.Count)
foreach ($r in $rot) { Write-Output "  [ROT]  $r" }
foreach ($o in $offen) { Write-Output "  [NICHT GEPRUEFT]  $o" }

if ($rot.Count -gt 0) { Write-Output "== Signaturen: $($rot.Count) rot -> RED =="; exit 1 }
if ($offen.Count -gt 0) { Write-Output "== Signaturen: nicht pruefbar -> RED =="; exit 2 }
Write-Output "== Signaturen: gruen -> GREEN =="
exit 0
