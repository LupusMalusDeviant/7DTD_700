<#
.SYNOPSIS
    Der Pruefbefehl des Projekts: Gegenproben, dann die drei Inhaltspruefungen.

.DESCRIPTION
    Reihenfolge ist Absicht. Zuerst laufen die Gegenproben (gegenproben.ps1): sie weisen
    nach, dass die Werkzeuge an falschen Eingaben scheitern. Erst danach zaehlt ein "0 rot"
    der echten Pruefungen als Nachweis — ein Pruefer, der nie rot wird, ist kein Signal
    (Projektregel 5).

    Die Quelle ist entweder ein ConfigsDump des Spiels (gemergt, gilt als Nachweis) oder
    Data/Config der Installation (Vanilla, nur Vorlauf). Den Dump legt das Spiel bei jedem
    Start selbst an, unter
      %APPDATA%\7DaysToDie\Saves\<Welt>\<Spielstand>\ConfigsDump\

.PARAMETER Source
    Ordner mit Config-XML. Ohne Angabe wird der neueste ConfigsDump genommen, sonst
    Data/Config unter SDTD_PATH.

.PARAMETER SkipGegenproben
    Nur die Inhaltspruefungen laufen lassen. Das Ergebnis gilt dann NICHT als Nachweis.

.NOTES
    ACHTUNG, Kodierung: UTF-8 MIT BOM. Wiederherstellen:

        $p = Resolve-Path tools\check\check-all.ps1
        $t = [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($true))
#>
[CmdletBinding()]
param(
    [string]$Source,
    [switch]$SkipGegenproben,
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)
$exe = Join-Path $repoRoot "tools\check\Mod700.Check\bin\$Configuration\net10.0\mod700check.exe"

if (-not (Test-Path $exe)) {
    Write-Output "Baue mod700check ..."
    & dotnet build (Join-Path $repoRoot 'tools\check\Mod700.Check\Mod700.Check.csproj') -c $Configuration --nologo
    if ($LASTEXITCODE -ne 0) { throw "dotnet build fehlgeschlagen." }
}

$red = 0
$ran = 0

function Invoke-Check {
    param([string]$Name, [string[]]$Arguments)

    $script:ran++
    Write-Output ""
    Write-Output "---- $Name ----"

    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { & $exe @Arguments } finally { $ErrorActionPreference = $previous }
    $code = $LASTEXITCODE

    if ($code -eq 0) {
        Write-Output "  -> gruen"
    }
    elseif ($code -eq 2) {
        $script:red++
        Write-Output "  -> ABGEBROCHEN (Exit 2): nicht geprueft, zaehlt als rot"
    }
    else {
        $script:red++
        Write-Output "  -> rot"
    }
}

function Invoke-Pruefskript {
    <#
        Faehrt ein PowerShell-Pruefskript, reicht seine Ausgabe durch und legt den Ausgang
        in $script:pruefKode. Eine Ausnahme des Skripts wird gefangen und gilt als
        "nicht geprueft" (2) - genauso ein Skript, das ohne Ausgangscode endet. Seit dem
        2026-11-20: vorher riss eine Ausnahme in kette-pruefen den ganzen Lauf ab, und die
        Zeile "N Pruefungen, M rot" erschien nie.
    #>
    param([string]$Pfad)

    $global:LASTEXITCODE = $null
    try {
        & $Pfad
        $script:pruefKode = if ($null -ne $LASTEXITCODE) { $LASTEXITCODE } else { 2 }
    }
    catch {
        Write-Output "  ABGEBROCHEN: $($_.Exception.Message)"
        $script:pruefKode = 2
    }
}

# ---------------------------------------------------- Gegenproben zuerst
if (-not $SkipGegenproben) {
    Write-Output "==== Gegenproben (Projektregel 5) ===="
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try { & (Join-Path $here 'gegenproben.ps1') -Configuration $Configuration } finally { $ErrorActionPreference = $previous }
    if ($LASTEXITCODE -ne 0) {
        Write-Output ""
        Write-Output "Die Gegenproben sind rot. Damit ist keine Aussage der Werkzeuge belastbar."
        Write-Output "ROT"
        exit 1
    }
}
else {
    Write-Output "Gegenproben uebersprungen - dieses Ergebnis ist KEIN Nachweis."
}

# ---------------------------------------------------- Quelle bestimmen
if (-not $Source) {
    $dumps = @()
    $saves = Join-Path $env:APPDATA '7DaysToDie\Saves'
    if (Test-Path $saves) {
        $dumps = @(Get-ChildItem $saves -Recurse -Directory -Filter 'ConfigsDump' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending)
    }

    if ($dumps.Count -gt 0) {
        $Source = $dumps[0].FullName
    }
    elseif ($env:SDTD_PATH) {
        # [IO.Path]::Combine, nicht Join-Path: Join-Path wirft, wenn das Laufwerk nicht
        # eingehaengt ist, und reisst den Lauf ab, bevor eine Pruefung gezaehlt wurde
        # (drittes Review, 2026-11-20).
        $Source = [IO.Path]::Combine($env:SDTD_PATH, 'Data\Config')
    }
    else {
        throw "Keine Quelle gefunden und SDTD_PATH ist nicht gesetzt. -Source angeben."
    }
}

Write-Output ""
Write-Output "==== Inhaltspruefungen ===="
Write-Output "Quelle: $Source"

Invoke-Check 'anachronisms' @('anachronisms', $Source, '--denylist', (Join-Path $here 'denylist.txt'))
Invoke-Check 'recipes' @('recipes', $Source)

# ---------------------------------------------------- Purge-Patches aktuell?
# Die Patch-Dateien in 700_10_Purge sind ERZEUGT. Erzeugte und mitgelieferte Dateien
# laufen auseinander, sobald jemand die Denylist aendert und das Erzeugen vergisst -
# und niemand merkt es, weil die Pruefung die gemergte Config liest und nicht unsere
# Patches. Darum vergleicht dieser Lauf, was im Modlet liegt, mit dem, was aus der
# heutigen Denylist entstehen wuerde.
#
# Erzeugt wird immer gegen VANILLA, nicht gegen $Source: gegen einen Dump, in dem
# unsere Modlets schon geladen waren, waeren die Patches leer.
#
# Der Pfad wird mit [IO.Path]::Combine gebaut und mit [IO.File]::Exists geprueft, nicht mit
# Join-Path und Test-Path: zeigt SDTD_PATH auf ein Laufwerk, das nicht eingehaengt ist,
# wirft Join-Path ("Cannot find drive"), und der Lauf endete ohne Ergebniszeile (drittes
# Review, 2026-11-20). [IO.File]::Exists sagt in dem Fall schlicht nein.
$vanilla = if ($env:SDTD_PATH) { [IO.Path]::Combine($env:SDTD_PATH, 'Data\Config') } else { $null }
$purgeConfig = Join-Path $repoRoot 'mod\700_10_Purge\Config'
if ($vanilla -and [IO.File]::Exists([IO.Path]::Combine($vanilla, 'items.xml'))) {
    Invoke-Check 'purge-patch (sind die Patches aktuell?)' @(
        'purge-patch', $vanilla, '--vergleiche', '--out', $purgeConfig,
        '--denylist', (Join-Path $here 'denylist.txt'))
}
else {
    # Gezaehlt und rot (geaendert 2026-11-20 nach dem Review-Befund). Vorher stand hier
    # nur der Text "kein Gruen" - und weder $ran noch $red aenderten sich. Das Ergebnis
    # am Ende hiess dann "N Pruefungen, 0 rot, GRUEN", und der Stop-Hook nahm es als
    # Nachweis. Eine Pruefung, die nicht laufen konnte, ist nicht bestanden.
    $ran++
    $red++
    Write-Output ""
    Write-Output "---- purge-patch (sind die Patches aktuell?) ----"
    Write-Output "  NICHT GEPRUEFT: SDTD_PATH ist nicht gesetzt oder zeigt nicht auf eine"
    Write-Output "  Installation mit Data\Config. Ohne Vanilla laesst sich nicht vergleichen,"
    Write-Output "  ob die erzeugten Patches noch zur Denylist passen."
    Write-Output "  -> nicht geprueft, zaehlt als rot"
}

# ---------------------------------------------------- Unsere Localization
# Localization.csv liegt NICHT im ConfigsDump - geprueft wird darum immer die Quelldatei
# des Sprach-Modlets.
$ourCsv = Join-Path $repoRoot 'mod\700_90_Sprache\Config\Localization.csv'
if (Test-Path $ourCsv) {
    # Die Praefixliste ist woertlich die aus Vertrag 02 §2, plus '700_' fuer alles, was
    # keine Kennung ist (700_modName, XUi-Elemente). Der Sprachschluessel eines
    # Gegenstands IST seine Kennung - siehe die Berichtigung in Vertrag 02 §5 -, also
    # muss hier jedes Kennungspraefix stehen und nicht nur '700_'.
    $praefixe = '700_,itm700_,blk700_,buff700_,cv700_,prk700_,att700_,lg700_,ent700_'
    $arguments = @('localization', $ourCsv, '--prefix', $praefixe)
    $vanillaKeys = Join-Path $here 'vanilla-keys.txt'
    if (Test-Path $vanillaKeys) { $arguments += @('--vanilla-keys', $vanillaKeys) }
    Invoke-Check 'localization (unser Modlet)' $arguments
}
else {
    # Seit WP4 gibt es die Datei; fehlt sie, ist das ein Fehler und kein "kommt noch".
    $ran++
    $red++
    Write-Output ""
    Write-Output "---- localization (unser Modlet) ----"
    Write-Output "  NICHT GEPRUEFT: $ourCsv fehlt."
    Write-Output "  -> nicht geprueft, zaehlt als rot"
}

# ---------------------------------------------------- Glossar gegen Sprachdatei
# F-12: "Glossar und Localization sind konsistent (Pruefskript)". docs/glossar.md nennt die
# Festbegriffe und die verbotenen Begriffe; glossar-pruefen.ps1 liest genau diese Datei.
# Ausgang 2 heisst "nichts gelesen" und zaehlt hier als rot - ein Pruefer, der seine
# Eingabe nicht findet, hat nicht bestanden (WP8.5).
$glossarSkript = Join-Path $here 'glossar-pruefen.ps1'
$ran++
Write-Output ""
Write-Output "---- Glossar gegen Sprachdatei ----"
if (Test-Path $glossarSkript) {
    Invoke-Pruefskript $glossarSkript
    $kode = $script:pruefKode
    if ($kode -eq 0) { Write-Output "  -> gruen" }
    elseif ($kode -eq 2) { $red++; Write-Output "  -> nicht geprueft, zaehlt als rot" }
    else { $red++; Write-Output "  -> rot" }
}
else {
    $red++
    Write-Output "  glossar-pruefen.ps1 fehlt: $glossarSkript"
    Write-Output "  -> rot"
}

# ---------------------------------------------------- Unsere eigene Kette
# 'recipes' prueft eine QUELLE, und unsere Modlets sind in keiner, die ohne Spielstart zu
# haben ist (WP3.6). 'recipes gruen' heisst darum heute "Vanilla hat keine Sackgasse" und
# sagt nichts ueber unsere Kette. kette-pruefen.ps1 schliesst die kleinere Haelfte der
# Luecke: es loest jeden Verweis unserer eigenen Rezepte auf.
$ketteSkript = Join-Path $here 'kette-pruefen.ps1'
$ran++
Write-Output ""
Write-Output "---- eigene Kette (Verweise) ----"
if (Test-Path $ketteSkript) {
    # Ausgang 2 heisst seit dem 2026-11-20 "nicht geprueft" (kein SDTD_PATH). Vorher kam
    # dafuer 0 zurueck und wurde hier als gruen gezaehlt. Eine Ausnahme des Skripts wird
    # gefangen und zaehlt ebenso: sonst endet dieser Lauf ohne seine Ergebniszeile.
    Invoke-Pruefskript $ketteSkript
    $kode = $script:pruefKode
    if ($kode -eq 0) { Write-Output "  -> gruen" }
    elseif ($kode -eq 2) { $red++; Write-Output "  -> nicht geprueft, zaehlt als rot" }
    else { $red++; Write-Output "  -> rot" }
}
else {
    $red++
    Write-Output "  kette-pruefen.ps1 fehlt: $ketteSkript"
    Write-Output "  -> nicht geprueft, zaehlt als rot"
}

Write-Output ""
Write-Output "==== Ergebnis: $ran Pruefungen, $red rot ===="
if ($red -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
