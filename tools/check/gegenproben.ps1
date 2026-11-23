<#
.SYNOPSIS
    Weist nach, dass mod700check an falschen Eingaben scheitert (Projektregel 5).

.DESCRIPTION
    Ein Pruefwerkzeug, das nie rot wird, ist kein Signal. Dieses Skript laesst jeden der
    drei Befehle einmal gegen einen bekannt SAUBEREN und einmal gegen einen bekannt
    FALSCHEN Satz Pruefdaten laufen und vergleicht den Exit-Code mit der Erwartung.

    Die Pruefdaten unter testdaten/ bestehen aus erfundenen Kennungen, nicht aus
    Spielinhalt (Projektregel 1 und 7).

    Erst wenn dieses Skript gruen ist, zaehlt ein "0 rot" der Werkzeuge als Nachweis.

.NOTES
    ACHTUNG, Kodierung: UTF-8 MIT BOM, sonst liest Windows PowerShell 5.1 die Datei als
    ANSI. Wiederherstellen:

        $p = Resolve-Path tools\check\gegenproben.ps1
        $t = [IO.File]::ReadAllText($p, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($p, $t, [Text.UTF8Encoding]::new($true))
#>
[CmdletBinding()]
param(
    [ValidateSet('Release', 'Debug')]
    [string]$Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)
$exe = Join-Path $repoRoot "tools\check\Mod700.Check\bin\$Configuration\net10.0\mod700check.exe"
$data = Join-Path $here 'testdaten'

if (-not (Test-Path $exe)) {
    throw "mod700check nicht gebaut: $exe fehlt. Erst 'dotnet build tools/check/Mod700.Check/Mod700.Check.csproj -c $Configuration'."
}

$failed = 0
$checked = 0

function Test-Case {
    param(
        [string]$Name,
        [int]$Expected,
        [string[]]$Arguments
    )

    $script:checked++
    # Kein '2>&1' auf eine native Exe: Windows PowerShell 5.1 verpackt dann jede
    # stderr-Zeile in einen ErrorRecord (NativeCommandError), und mit
    # ErrorActionPreference='Stop' bricht das Skript mitten in der Gegenprobe ab -
    # genau bei den Faellen, die stderr benutzen (Exit 2). stderr darf also durchlaufen.
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $exe @Arguments
    }
    finally {
        $ErrorActionPreference = $previous
    }
    $actual = $LASTEXITCODE

    if ($actual -eq $Expected) {
        Write-Output ("  [ok]   " + $Name + "  (Exit $actual)")
    }
    else {
        $script:failed++
        Write-Output ("  [ROT]  " + $Name + "  -> Exit $actual erwartet $Expected")
        $output | Select-Object -First 6 | ForEach-Object { Write-Output ("         " + $_) }
    }
}

function Test-Output {
    <#
        Wie Test-Case, prueft aber zusaetzlich die Ausgabe. Gebraucht fuer die Gegenproben
        aus Vertrag 04 §3a: dass ein Lauf rot ist, sagt noch nicht, dass er das RICHTIGE
        gefunden hat. Das entscheidende Paar (Feuerwaffe faellt, Bogen bleibt) laesst sich
        nur an der Ausgabe pruefen, nicht am Exit-Code.
    #>
    param(
        [string]$Name,
        [int]$Expected,
        [string[]]$Arguments,
        [string[]]$MustContain = @(),
        [string[]]$MustNotContain = @()
    )

    $script:checked++
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $exe @Arguments
    }
    finally {
        $ErrorActionPreference = $previous
    }
    $actual = $LASTEXITCODE
    $text = ($output | Out-String)

    $problems = @()
    if ($actual -ne $Expected) { $problems += "Exit $actual erwartet $Expected" }
    foreach ($m in $MustContain) {
        if ($text -notmatch [regex]::Escape($m)) { $problems += "fehlt in der Ausgabe: $m" }
    }
    foreach ($m in $MustNotContain) {
        if ($text -match [regex]::Escape($m)) { $problems += "darf nicht in der Ausgabe stehen: $m" }
    }

    if ($problems.Count -eq 0) {
        Write-Output ("  [ok]   " + $Name + "  (Exit $actual)")
    }
    else {
        $script:failed++
        Write-Output ("  [ROT]  " + $Name)
        $problems | ForEach-Object { Write-Output ("         " + $_) }
    }
}

function Test-Script {
    <#
        Wie Test-Output, laeuft aber gegen ein PowerShell-Pruefskript statt gegen
        mod700check. Gebraucht seit WP5.5b fuer kette-pruefen.ps1: auch ein Skript ist ein
        Pruefwerkzeug, und ein Pruefwerkzeug ohne Gegenprobe ist kein Signal
        (Projektregel 5). Die Parameter kommen als Hashtable, weil das Skript benannte
        Parameter nimmt und keine Argumentliste.
    #>
    param(
        [string]$Name,
        [int]$Expected,
        [hashtable]$Parameters,
        [string[]]$MustContain = @(),
        [string[]]$MustNotContain = @(),
        # Seit WP8.5 gibt es ein zweites Pruefskript (glossar-pruefen.ps1). Der Vorgabewert
        # haelt die aelteren Aufrufe unveraendert.
        [string]$Skript = 'kette-pruefen.ps1',
        # Laesst das Skript OHNE SDTD_PATH laufen und stellt die Variable danach wieder
        # her. Gebraucht seit dem 2026-11-20: der gefaehrlichste Zustand eines Pruefers ist
        # der, in dem ihm seine Eingabe fehlt, und genau der liess sich bisher nicht
        # gegenpruefen.
        [switch]$OhneSpielpfad,
        # Dasselbe mit einem FALSCHEN Spielpfad: gesetzt, aber ohne Data\Config darunter.
        [string]$Spielpfad,
        # Setzt %APPDATA% fuer den einen Lauf um (seit 2026-11-21). check-all.ps1 sucht dort
        # nach einem ConfigsDump; auf einem Rechner, der einen hat, liesse sich der Fall
        # "keine Quelle" sonst nicht gegenpruefen.
        [string]$Appdata,
        # Voller Pfad zu einer KOPIE des Skripts ausserhalb von tools\check (seit dem
        # zweiten Review zu WP8.6). glossar-pruefen.ps1 rechnet das echte Glossar aus
        # seinem eigenen Ordner; wer pruefen will, was es OHNE Parameter gegen ein falsches
        # Glossar tut, muss es in einen nachgebauten Baum legen. Der Name darf nicht
        # "SkriptPfad" heissen - das waere dieselbe Variable wie $skriptPfad unten.
        [string]$FremdesSkript
    )

    $script:checked++
    $skriptPfad = Join-Path $here $Skript
    if ($FremdesSkript) { $skriptPfad = $FremdesSkript }
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    # Achtung: PowerShell unterscheidet bei Variablennamen keine Gross-/Kleinschreibung.
    # "$spielpfad" waere dieselbe Variable wie der Parameter $Spielpfad.
    $pfadVorher = $env:SDTD_PATH
    if ($OhneSpielpfad) { Remove-Item Env:SDTD_PATH -ErrorAction SilentlyContinue }
    if ($Spielpfad) { $env:SDTD_PATH = $Spielpfad }
    $appdataVorher = $env:APPDATA
    if ($Appdata) { $env:APPDATA = $Appdata }
    try {
        $output = & $skriptPfad @Parameters
        $actual = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
    }
    catch {
        $output = $_.Exception.Message
        $actual = -1
    }
    finally {
        $ErrorActionPreference = $previous
        if ($OhneSpielpfad -or $Spielpfad) {
            if ($pfadVorher) { $env:SDTD_PATH = $pfadVorher }
            else { Remove-Item Env:SDTD_PATH -ErrorAction SilentlyContinue }
        }
        if ($Appdata) { $env:APPDATA = $appdataVorher }
    }
    $text = ($output | Out-String)

    $problems = @()
    if ($actual -ne $Expected) { $problems += "Exit $actual erwartet $Expected" }
    foreach ($m in $MustContain) {
        if ($text -notmatch [regex]::Escape($m)) { $problems += "fehlt in der Ausgabe: $m" }
    }
    foreach ($m in $MustNotContain) {
        if ($text -match [regex]::Escape($m)) { $problems += "darf nicht in der Ausgabe stehen: $m" }
    }

    if ($problems.Count -eq 0) {
        Write-Output ("  [ok]   " + $Name + "  (Exit $actual)")
    }
    else {
        $script:failed++
        Write-Output ("  [ROT]  " + $Name)
        $problems | ForEach-Object { Write-Output ("         " + $_) }
    }
}

Write-Output "== Gegenproben: der saubere Satz muss gruen sein =="
Test-Case 'anachronisms, sauberer Satz' 0 @(
    'anachronisms', (Join-Path $data 'sauber'),
    '--denylist', (Join-Path $here 'denylist.txt'))
Test-Case 'recipes, sauberer Satz' 0 @(
    'recipes', (Join-Path $data 'sauber'),
    '--world-roots', (Join-Path $data 'world-roots.txt'))
Test-Case 'localization, sauberer Satz' 0 @(
    'localization', (Join-Path $data 'Localization-sauber.csv'), '--prefix', '700_')

Write-Output ""
Write-Output "== Gegenproben: der falsche Satz MUSS rot werden =="
Test-Case 'anachronisms findet die erreichbare Pistole' 1 @(
    'anachronisms', (Join-Path $data 'rot'),
    '--denylist', (Join-Path $here 'denylist.txt'))
Test-Case 'recipes findet Zyklus und unbekannte Zutat' 1 @(
    'recipes', (Join-Path $data 'rot'),
    '--world-roots', (Join-Path $data 'world-roots.txt'))
Test-Case 'localization findet Dubletten, Luecken, fehlendes Praefix' 1 @(
    'localization', (Join-Path $data 'Localization-rot.csv'), '--prefix', '700_')
# WP4.1 haengt daran, dass eine Modlet-Zeile einen Vanilla-Schluessel ueberschreiben darf
# (Befund WP4-localization-ueberschreibt-vanilla.md). Die Praefix-Pruefung muss trotzdem
# greifen, solange der Schluessel nicht ausdruecklich freigegeben ist - sonst ist sie keine
# Pruefung, sondern eine Formalie.
Test-Case 'localization: Vanilla-Schluessel ohne Freigabeliste ist rot' 1 @(
    'localization', (Join-Path $data 'Localization-vanilla.csv'), '--prefix', '700_')

Write-Output ""
Write-Output "== Gegenproben: eine fehlende Annahme macht den sauberen Satz rot =="
# Ohne world-roots.txt ist pruefSchmelzEinheit unerreichbar - der Beweis, dass die
# Datei wirklich etwas beitraegt und nicht nur dekorativ dabeiliegt.
Test-Case 'recipes ohne world-roots wird rot' 1 @(
    'recipes', (Join-Path $data 'sauber'), '--no-world-roots')

Write-Output ""
Write-Output "== Gegenproben: die Liste der bewussten Vanilla-Ueberschreibungen =="
# Diese drei haengen zusammen. Die Freigabeliste ist eine ABSCHALTUNG der
# Praefix-Pruefung, also muss sie (1) wirken, (2) einen nachgestellten Grund vertragen -
# wie denylist.txt, aufschub.txt und die Rezeptliste es tun - und (3) sagen, wenn ein
# Eintrag ins Leere zeigt. Fall (2) ist kein erfundener Fall: der Leser schnitt den
# Kommentar bis WP4.1 nicht ab, und die Pruefung blieb rot mit dem Hinweis auf eine Datei,
# in der der Schluessel sichtbar dastand.
Test-Case 'localization: freigegebener Vanilla-Schluessel ist gruen' 0 @(
    'localization', (Join-Path $data 'Localization-vanilla.csv'), '--prefix', '700_',
    '--vanilla-keys', (Join-Path $data 'vanilla-keys-mit-kommentar.txt'))
# Vertrag 02 §5 verlangte bis WP4.6 ein einzelnes Praefix '700_'. Der Sprachschluessel
# eines Gegenstands IST aber seine Kennung, und die heisst nach §2 'itm700_...'. Mit dem
# alten Rezept waere jeder eigene Gegenstand rot gewesen - und der naheliegende Ausweg
# (ihn in vanilla-keys.txt schreiben) eine Freigabe fuer etwas, das kein Vanilla ist.
# Diese beiden halten die Berichtigung fest: rot mit dem alten Rezept, gruen mit dem neuen.
Test-Case 'localization: Kennungsschluessel ist mit nur 700_ rot' 1 @(
    'localization', (Join-Path $data 'Localization-kennung.csv'), '--prefix', '700_')
Test-Case 'localization: Kennungsschluessel ist mit der Praefixliste gruen' 0 @(
    'localization', (Join-Path $data 'Localization-kennung.csv'),
    '--prefix', '700_,itm700_,blk700_')
Test-Output 'localization nennt den uebrigen Freigabe-Eintrag' 0 @(
    'localization', (Join-Path $data 'Localization-vanilla.csv'), '--prefix', '700_',
    '--vanilla-keys', (Join-Path $data 'vanilla-keys-uebrig.txt')) `
    -MustContain @('vanilla-schluessel-ohne-zeile', 'pruefNieGesetzt') `
    -MustNotContain @('pruefVanillaSchluessel'' steht als bewusste')

# Kaputte Anfuehrung (Review vom 2026-11-20). Der CSV-Leser nahm ein Anfuehrungszeichen
# mitten in einem Feld still hin. Die Testdatei ist so gebaut, dass die SPALTENZAHL stimmt:
# an 'spaltenzahl' faellt sie nicht auf, und vor der Aenderung war dieser Lauf gruen.
#   Zeile 2: Scrap of "Parchment"   - Anfuehrung mitten im Feld
#   Zeile 3: "Hearth"x              - Zeichen nach dem schliessenden Anfuehrungszeichen
#   Zeile 4: "A ""good"" word, ..." - gueltig: verdoppelt, in Anfuehrung, mit Komma
Test-Output 'localization: kaputte Anfuehrung wird rot, auch wenn die Spaltenzahl stimmt' 1 @(
    'localization', (Join-Path $data 'Localization-anfuehrung.csv'), '--prefix', '700_') `
    -MustContain @('csv-form', 'Localization-anfuehrung.csv:2', 'Anfuehrungszeichen mitten im Feld',
                   'Localization-anfuehrung.csv:3', 'nach dem schliessenden Anfuehrungszeichen') `
    -MustNotContain @('Localization-anfuehrung.csv:4', 'spaltenzahl')

# Ein nie geschlossenes Anfuehrungszeichen verschluckt alle Zeilen danach. Gemeldet wird
# die Zeile, in der es AUFGEHT - nicht das Dateiende, an dem es auffaellt.
Test-Output 'localization: offenes Anfuehrungszeichen nennt die Zeile, in der es aufgeht' 1 @(
    'localization', (Join-Path $data 'Localization-anfuehrung-offen.csv'), '--prefix', '700_') `
    -MustContain @('csv-form', 'Localization-anfuehrung-offen.csv:3', 'nicht geschlossen')

# Zwei Faelle aus dem dritten Review (2026-11-20).
#
# (1) Ein einzelner Wagenruecklauf (CR ohne LF) ausserhalb der Anfuehrung wurde still
#     verworfen: "Hearth"<CR>, las sich wie "Hearth", - Spaltenzahl richtig, Lauf gruen. Die
#     Testdatei traegt in Zeile 2 genau dieses eine Byte 0x0D; sie ist mit printf erzeugt,
#     weil ein Editor es nicht stehen laesst.
Test-Output 'localization: einzelner Wagenruecklauf ausserhalb der Anfuehrung wird rot' 1 @(
    'localization', (Join-Path $data 'Localization-einzelnes-cr.csv'), '--prefix', '700_') `
    -MustContain @('csv-form', 'Localization-einzelnes-cr.csv:2', 'Wagenruecklauf') `
    -MustNotContain @('spaltenzahl', 'Localization-einzelnes-cr.csv:3')

# (2) Eine Datei aus einem einzigen Anfuehrungszeichen hat keine Zeile. Gemeldet wurde nur
#     "leere-datei" - rot, aber mit dem falschen Grund; der richtige ging verloren.
Test-Output 'localization: Datei aus einem einzigen Anfuehrungszeichen nennt den Grund' 1 @(
    'localization', (Join-Path $data 'Localization-nur-anfuehrung.csv'), '--prefix', '700_') `
    -MustContain @('csv-form', 'Localization-nur-anfuehrung.csv:1', 'nicht geschlossen')

Write-Output ""
Write-Output "== Gegenproben: der Vergleich beachtet Gross- und Kleinschreibung =="
# WP3.1, Befund 3.3: solange RegexOptions.IgnoreCase gesetzt war, traf die Regel
# 'drugs*' drei Drogen, die sie nie meinte (drugSteroids und zwei weitere haben an
# fuenfter Stelle ein grosses S) und liess zwoelf andere durch. Die Regel sah aus,
# als arbeite sie. Diese zwei Faelle halten das fest: falsch geschrieben trifft
# nicht, richtig geschrieben trifft. Nur beide zusammen sind ein Signal - der erste
# allein bliebe auch gruen, wenn der Vergleich gar nichts mehr findet.
Test-Case 'falsch geschriebene Regel trifft nicht' 0 @(
    'anachronisms', (Join-Path $data 'rot'),
    '--denylist', (Join-Path $data 'denylist-schreibung-falsch.txt'))
Test-Case 'richtig geschriebene Regel trifft' 1 @(
    'anachronisms', (Join-Path $data 'rot'),
    '--denylist', (Join-Path $data 'denylist-schreibung-richtig.txt'))

Write-Output ""
Write-Output "== Gegenproben: Urteil nach Eigenschaften (Vertrag 04 §3a) =="
$eig = Join-Path $data 'eigenschaften'

# 1. Das Paar, das ein Namensmuster verwechseln MUSS: beide tragen dieselbe Group, und in
#    Vanilla heissen beide 'gun...'. Nur die Tags trennen sie.
Test-Output 'Feuerwaffe faellt, Bogen bleibt' 1 @('anachronisms', $eig) `
    -MustContain @('erreichbarer-anachronismus: pruefFeuerrohr', '[schusswaffe]') `
    -MustNotContain @('erreichbarer-anachronismus: pruefSelbstbogen')

# 2. Die Regel herausnehmen muss auffallen. Faellt der Block dann noch, hat nicht die Regel
#    entschieden, sondern irgendetwas anderes - und der Nachweis waere keiner.
Test-Output 'ohne die Strom-Regel faellt der Kraftstein nicht mehr' 1 `
    @('anachronisms', $eig, '--ohne-regel', 'strom') `
    -MustNotContain @('erreichbarer-anachronismus: pruefKraftstein')

# 3. Eine Kennung ohne Definition ist kein Gruen, sondern ein Hinweis.
Test-Output 'unaufloesbare Kennung wird genannt' 1 @('anachronisms', $eig) `
    -MustContain @('unaufloesbare-kennung: pruefGeisterding')

# 4. Wie --no-world-roots bei recipes: der Nachweis, dass die Vererbung wirklich etwas
#    beitraegt. Die Variante erbt ihre Klasse und darf ohne Vererbung nicht gefunden werden.
Test-Output 'ohne Vererbung faellt die geerbte Variante durch' 1 `
    @('anachronisms', $eig, '--no-extends') `
    -MustNotContain @('erreichbarer-anachronismus: pruefKraftsteinVariante')

# 5. Mods werden abgeleitet: der eine faellt mit seinem Traeger, der andere bleibt mit seinem.
Test-Output 'Mod faellt mit dem Traeger, nicht mit dem Namen' 1 @('anachronisms', $eig) `
    -MustContain @('erreichbarer-anachronismus: pruefModRohrAufsatz', 'mod-ohne-ueberlebenden-traeger') `
    -MustNotContain @('erreichbarer-anachronismus: pruefModBogenauflage')

# 6. Der Zuender entscheidet, nicht der Tag. 'explosivesSkill' waere das naheliegende
#    Signal und ist unbrauchbar: Vanilla haengt auch den Dietrich daran. Der Pruefling
#    traegt den Tag darum NICHT und muss trotzdem fallen.
Test-Output 'Sprengkoerper faellt ueber die Klasse' 1 @('anachronisms', $eig) `
    -MustContain @('erreichbarer-anachronismus: pruefWurfglut', '[sprengkoerper]')

# 7. CreativeMode 'Dev' ist Vanillas eigene Aussage "nur fuer Entwickler". Weder Tag
#    'admin' noch Group 'Special Items' trifft die tier0xLoadouts, die ueber Create_item
#    Schmerzmittel austeilen - dieser Pruefling ist genau dieser Fall.
Test-Output 'Entwicklerstand faellt ueber CreativeMode' 1 @('anachronisms', $eig) `
    -MustContain @('erreichbarer-anachronismus: pruefDevKiste', '[entwicklergegenstand]')

# 8. Die 'challenge_*'-Marke sagt, woraus ein Block besteht. Der Pruefling traegt
#    bewusst eine Klasse, die NICHT in der Stromliste steht - faellt er, hat die
#    Werkstoffregel geurteilt und nicht die Stromregel.
Test-Output 'moderner Werkstoff faellt ueber die challenge-Marke' 1 @('anachronisms', $eig) `
    -MustContain @('erreichbarer-anachronismus: pruefLadenkasse', '[moderner_werkstoff]')

# 9. Die Unlocks-Ableitung gilt in BEIDE Richtungen. Zwei Bauplaene, die sonst nichts
#    tragen: der auf die Waffe faellt, der auf den Bogen bleibt. Ohne die zweite
#    Haelfte waere der zweite 'ungeprueft' - und 37 Vanilla-Bauplaene mit ihm.
Test-Output 'Bauplan folgt dem, was er freischaltet' 1 @('anachronisms', $eig) `
    -MustContain @('erreichbarer-anachronismus: pruefBauplanRohr', 'schaltet-gesperrtes-frei') `
    -MustNotContain @('erreichbarer-anachronismus: pruefBauplanBogen')

# Benutzungsfehler bleibt Benutzungsfehler, auch bei den neuen Optionen.
Test-Case 'unbekannte Eigenschaftsregel' 2 @(
    'anachronisms', $eig, '--ohne-regel', 'gibtesnicht')

Write-Output ""
Write-Output "== Gegenproben: ein Aufschub ist eine Umbuchung, kein Bestanden =="

# Aufgeschobenes muss als Hinweis erscheinen und NICHT als Fehler - aber es muss
# erscheinen. Ein Aufschub, der die Kennung verschwinden laesst, waere ein Verstecken.
Test-Output 'Aufschub bucht um, statt zu verschweigen' 1 `
    @('anachronisms', $eig, '--aufschub', (Join-Path $data 'aufschub-pruef.txt')) `
    -MustContain @('aufgeschobener-anachronismus: pruefFeuerrohr', 'WP9') `
    -MustNotContain @('erreichbarer-anachronismus: pruefFeuerrohr')

# Und ohne Aufschub muss sie wieder als Fehler dastehen - sonst waere nicht zu sehen,
# dass der Aufschub etwas umbucht und nicht etwas entfernt.
Test-Output 'ohne Aufschub ist sie wieder ein Fehler' 1 `
    @('anachronisms', $eig, '--ohne-aufschub') `
    -MustContain @('erreichbarer-anachronismus: pruefFeuerrohr')

# Ein Aufschub ohne Arbeitspaket ist ein Loch mit guter Presse und wird abgelehnt.
Test-Case 'Aufschub ohne Arbeitspaket wird abgelehnt' 2 @(
    'anachronisms', $eig, '--aufschub', (Join-Path $data 'aufschub-ohne-wp.txt'))

# Die Leermeldung (2026-11-22). Sind alle Aufschuebe eingeloest, steht in aufschub.txt die
# Zeile '=kein-aufschub  # Grund'. Vier Gegenproben: (1) mit ihr laeuft die Pruefung, und
# die Kennung ist wieder ein Fehler - genau wie mit --ohne-aufschub; (2) eine Datei ganz
# ohne Zeile bleibt ein Benutzungsfehler, sie koennte versehentlich geleert sein; (3) die
# Leermeldung neben einer Regel ist ein Widerspruch; (4) ohne Grund wird sie abgelehnt.
Test-Output 'Leermeldung: nichts aufgeschoben, die Kennung ist ein Fehler' 1 `
    @('anachronisms', $eig, '--aufschub', (Join-Path $data 'aufschub-leermeldung.txt')) `
    -MustContain @('erreichbarer-anachronismus: pruefFeuerrohr') `
    -MustNotContain @('aufgeschobener-anachronismus')
# Die drei Ablehnungen pruefen nur den Ausgang: die Meldung eines Benutzungsfehlers geht
# auf die Fehlerausgabe, und die liest Test-Output nicht mit.
Test-Case 'Aufschub-Datei ohne jede Zeile bleibt ein Benutzungsfehler' 2 @(
    'anachronisms', $eig, '--aufschub', (Join-Path $data 'aufschub-leer.txt'))
Test-Case 'Leermeldung neben einer Regel ist ein Widerspruch' 2 @(
    'anachronisms', $eig, '--aufschub', (Join-Path $data 'aufschub-leermeldung-und-regel.txt'))
Test-Case 'Leermeldung ohne Grund wird abgelehnt' 2 @(
    'anachronisms', $eig, '--aufschub', (Join-Path $data 'aufschub-leermeldung-ohne-grund.txt'))

Write-Output ""
Write-Output "== Gegenprobe: eine Verbotsregel ohne Treffer faellt auf =="
Test-Output 'Regel ohne Treffer wird genannt' 1 `
    @('anachronisms', $eig, '--denylist', (Join-Path $data 'denylist-tote-regel.txt')) `
    -MustContain @('verbotsregel-trifft-nichts', 'pruefGibtEsGarantiertNicht*')

# Und dasselbe fuer die Freigabe - der gefaehrlichere Tippfehler von beiden. Eine
# Verbotsregel ohne Treffer laesst etwas durch und wird gemeldet; eine Freigabe ohne
# Treffer laesst etwas fallen, und ein Befund mehr sieht aus wie Arbeit.
Test-Output 'Freigabe ohne Treffer wird genannt' 1 `
    @('anachronisms', $eig, '--denylist', (Join-Path $data 'denylist-tote-freigabe.txt')) `
    -MustContain @('freigaberegel-trifft-nichts', 'pruefGibtEsGarantiertNicht')

Write-Output ""
Write-Output "== Gegenproben: purge-patch erzeugt, was die Pruefung findet =="
$purge = Join-Path $data 'purge'

# 1. Die Form entscheidet sich an den Daten, nicht an einer Annahme: wer CreativeMode selbst
#    traegt, bekommt 'set'; wer es erbt, bekommt 'append'. Ein 'set' auf eine Eigenschaft,
#    die es nicht gibt, trifft nichts und schweigt - das ist der Fehler, den diese Probe
#    ausschliesst. Und der Bogen darf in keiner Zeile ZIEL sein (D54); in einer gekuerzten
#    Belohnungsliste steht er dagegen zu Recht, als Ueberlebender.
Test-Output 'set fuer eigene Eigenschaft, append fuer geerbte' 0 `
    @('purge-patch', $purge, '--trocken', '--zeigen') `
    -MustContain @(
        "<set xpath=""/items/item[@name='pruefFeuerrohrEigen']/property[@name='CreativeMode']/@value"">None</set>",
        "<append xpath=""/items/item[@name='pruefFeuerrohrGeerbt']""><property name=""CreativeMode"" value=""None"" /></append>") `
    -MustNotContain @(
        "/items/item[@name='pruefSelbstbogen']",
        "/recipes/recipe[@name='pruefSelbstbogen']",
        "/lootcontainers/lootgroup/item[@name='pruefSelbstbogen']")

# 2. Die Nachprobe: nach den Entfernungen darf kein Weg zu einer gesperrten Kennung uebrig
#    sein. pruefFeuerrohrEigen hat ZWEI Rezepte - eine Zeile, die nur eines trifft, waere
#    nach der Treffer-Pruefung gruen und hier rot.
Test-Output 'nach den Entfernungen ist kein Weg mehr offen' 0 `
    @('purge-patch', $purge, '--trocken') `
    -MustContain @('wege_uebrig                        0',
                   'gesperrt_und_noch_erreichbar       0')

# 3. Und der Nachweis, dass diese Nachprobe ueberhaupt etwas prueft. Ohne die Entfernungen
#    MUSS sie rot werden; waere sie auch dann gruen, wuerde sie nur sich selbst bestaetigen.
Test-Output 'ohne die Entfernungen bleibt der Weg offen' 1 `
    @('purge-patch', $purge, '--trocken', '--ohne-entfernen') `
    -MustContain @('weg-bleibt-offen: recipes.xml',
                   'gesperrt-trotz-patch: pruefFeuerrohrEigen')

# 3b. Der Zaehler, der am 8. November 2026 dazukam: Rezepte, die den Purge UEBERLEBEN und
#     trotzdem nicht herstellbar sind, weil eine Zutat gesperrt ist. pruefKoecher ist so ein
#     Fall, pruefSehne nennt dieselbe gesperrte Zutat mit count="0" und darf NICHT mitzaehlen.
#     Steht hier "2 von", zaehlt der Zaehler Vanillas Qualitaetszutaten mit und meldet jedes
#     Waffenrezept als tot.
Test-Output 'tote Rezepte werden gezaehlt, eine Zutat mit count=0 nicht' 0 `
    @('purge-patch', $purge, '--trocken') `
    -MustContain @('rezept-mit-gesperrter-zutat: 1 von',
                   'pruefFeuerrohrGeerbt (1)')

# 3c. Und die Gegenrichtung: ein Satz ohne gesperrte Zutat MUSS null melden. Ohne diese
#     Probe koennte der Zaehler jedes Rezept melden und saehe wachsam aus.
Test-Output 'ohne gesperrte Zutat meldet der Zaehler nichts' 0 `
    @('purge-patch', (Join-Path $data 'sauber'), '--trocken') `
    -MustNotContain @('rezept-mit-gesperrter-zutat')

# 4. Erzeugte Dateien und die Denylist koennen auseinanderlaufen. --vergleiche findet das;
#    gegen einen Ordner ohne die Dateien muss es rot werden.
Test-Output 'fehlende Patchdatei faellt auf' 1 `
    @('purge-patch', $purge, '--vergleiche', '--out', (Join-Path $data 'gibtesnicht')) `
    -MustContain @('patchdatei-fehlt')

# 5. Der Fehler, der weh tut: eine Belohnung, deren 'id' eine Liste ist. Steht nur
#    Gesperrtes darin, faellt sie. Steht auch Erlaubtes darin, wird die Liste GEKUERZT -
#    wer hier 'remove' nimmt, nimmt dem Spieler zwei erlaubte Belohnungen mit. Vanilla hat
#    256 solche Listen.
Test-Output 'gemischte Belohnungsliste wird gekuerzt, nicht entfernt' 0 `
    @('purge-patch', $purge, '--trocken', '--zeigen') `
    -MustContain @(
        "<remove xpath=""/quests/quest/reward[@id='pruefFeuerrohrEigen,pruefFeuerrohrGeerbt']"" />",
        "name=""id"">pruefSelbstbogen,pruefRohstoff</setattribute>") `
    -MustNotContain @("<remove xpath=""/quests/quest/reward[@id='pruefFeuerrohrEigen,pruefSelbstbogen,pruefRohstoff']"" />")

# 6. Die Startausruestung wird gekuerzt und behaelt ihre Stueckzahl. Ohne die Eigenschaft
#    startet der Spieler mit leeren Haenden; ohne die Stueckzahl mit einem Stueck statt
#    zwei. Und der Elementpfad allein sagt hier nichts - der XPath braucht Praedikate bis
#    hinauf zur Entity-Klasse.
Test-Output 'Startausruestung gekuerzt, Stueckzahl bleibt' 0 `
    @('purge-patch', $purge, '--trocken', '--zeigen') `
    -MustContain @(
        "/entity_classes/entity_class[@name='pruefSpieler']/property[@class='ItemsOnEnterGame']/property[@name='GameModeSurvival']",
        "name=""value"">pruefSelbstbogen=2</setattribute>")

# Ohne --out und ohne --trocken weiss der Befehl nicht, wohin: Benutzungsfehler.
Test-Case 'purge-patch ohne Ziel' 2 @('purge-patch', $purge)

Write-Output ""
Write-Output "== Gegenproben: Auftragsregeln - ein Auftrag ist kein Gegenstand (D103) =="
# Vertrag 04, Nachtrag Auftragsregeln. "Strom wiederherstellen" stand in allen fuenf
# Haendlerlisten, waehrend 'anachronisms' gruen war: ein Auftrag gibt nichts in die Hand
# und steht in keinem der sechs Wege. Die Regel 'auftrag:<muster>' urteilt ueber die
# Eintraege der Auftragslisten - und NUR ueber die, nicht ueber die Definition gleichen
# Namens eine Ebene hoeher.
$auftraege = Join-Path $data 'auftraege'
$auftragsliste = Join-Path $data 'denylist-auftrag.txt'

# A1. Der gesperrte Auftrag in einer Liste MUSS rot werden, und zwar jeder, der passt, mit
#     den Listen, in denen er steht. Der erlaubte daneben bleibt ungenannt.
Test-Output 'gesperrter Auftrag in einer Haendlerliste faellt auf' 1 `
    @('anachronisms', $auftraege, '--denylist', $auftragsliste) `
    -MustContain @('gesperrter-auftrag: pruefStufe2_strom',
                   'gesperrter-auftrag: pruefStufe3_strom',
                   'pruefHaendlerA, pruefHaendlerB',
                   'gesperrte_auftraege_in_listen      2') `
    -MustNotContain @('gesperrter-auftrag: pruefStufe2_raeumen')

# A2. Rot wird es durch die REGEL, nicht durch die Daten: dieselbe Quelle, dieselbe Liste
#     ohne die Auftragszeile - gruen.
Test-Output 'ohne Auftragsregel ist dieselbe Quelle gruen' 0 `
    @('anachronisms', $auftraege, '--denylist', (Join-Path $data 'denylist-auftrag-keine.txt')) `
    -MustContain @('auftragsregeln                     0') `
    -MustNotContain @('gesperrter-auftrag')

# A3. Nach dem Patch stehen die Definitionen der Strom-Auftraege weiter da, nur die
#     Listeneintraege fehlen. Zaehlte die Pruefung die Definition als Angebot, waere sie
#     hier rot - fuer immer, weil Definitionen nie entfernt werden (Vertrag 03 Abschnitt 4).
Test-Output 'die Definition eines gesperrten Auftrags ist kein Angebot' 0 `
    @('anachronisms', (Join-Path $data 'auftraege-danach'), '--denylist', $auftragsliste) `
    -MustContain @('auftragsregeln                     1',
                   'gesperrte_auftraege_in_listen      0') `
    -MustNotContain @('gesperrter-auftrag')

# A4. Der Erzeuger schreibt eine Zeile je Auftrag, ohne Praedikat an der Liste (er faellt
#     aus jeder), und KEINE Zeile auf die Definition.
Test-Output 'purge-patch nimmt den Auftrag aus den Listen, nicht die Definition' 0 `
    @('purge-patch', $auftraege, '--trocken', '--zeigen', '--denylist', $auftragsliste) `
    -MustContain @(
        "<remove xpath=""/quests/quest_list/quest[@id='pruefStufe2_strom']"" />",
        "<remove xpath=""/quests/quest_list/quest[@id='pruefStufe3_strom']"" />",
        'gesperrte_auftraege_noch_in_listen 0',
        'remove_auf_definition              0') `
    -MustNotContain @("/quests/quest[@id=", "pruefStufe2_raeumen']")

# A5. Und der Nachweis, dass die Nachprobe etwas prueft: ohne die Entfernungen bleiben die
#     Auftraege in den Listen, und beide Proben muessen es sagen.
Test-Output 'ohne die Entfernungen bleibt der Auftrag in der Liste' 1 `
    @('purge-patch', $auftraege, '--trocken', '--ohne-entfernen', '--denylist', $auftragsliste) `
    -MustContain @('weg-bleibt-offen: quests.xml [quest]',
                   'auftrag-trotz-patch: pruefStufe2_strom')

# A6. Der stille Tippfehler. Eine Auftragsregel, die nichts trifft, laesst den Auftrag beim
#     Haendler - und 'anachronisms' kann das nicht melden, weil eine Regel ohne Treffer bei
#     einem gepatchten Stand das Ziel ist. Darum ist es beim Erzeugen ein FEHLER.
Test-Output 'falsch geschriebene Auftragsregel ist ein Fehler, kein Hinweis' 1 `
    @('purge-patch', $auftraege, '--trocken', '--denylist', (Join-Path $data 'denylist-auftrag-tippfehler.txt')) `
    -MustContain @('auftragsregel-trifft-nichts: pruefStuffe*_strom')

# A7. Eine Quelle ohne Auftragslisten kann ueber die Regel nichts sagen. Das ist kein
#     Fehler (sonst waeren alle kleinen Pruefsaetze rot) und kein Schweigen: es steht da.
Test-Output 'Quelle ohne Auftragslisten: gesagt, nicht rot' 0 `
    @('purge-patch', (Join-Path $data 'auftraege-ohne-listen'), '--trocken', '--denylist', $auftragsliste) `
    -MustContain @('hat keine Auftragslisten') `
    -MustNotContain @('auftragsregel-trifft-nichts')

# A8. 'auftrag:' ohne Muster ist ein Benutzungsfehler, keine Regel, die alles oder nichts trifft.
Test-Case 'Auftragsregel ohne Muster' 2 @(
    'anachronisms', $auftraege, '--denylist', (Join-Path $data 'denylist-auftrag-ohne-muster.txt'))

Write-Output ""
Write-Output "== Gegenproben: Ziele der Herausforderungen - ein Ziel ist kein Weg (D104, D137) =="
# Vertrag 04, Nachtrag Ziele der Herausforderungen. 35 von 148 sichtbaren Herausforderungen
# verlangten Gesperrtes, waehrend 'anachronisms' gruen war: eine Aufgabe gibt nichts in die
# Hand. Im Pruefsatz 'ziele' liegt das gesperrte Teil auf KEINEM Weg mehr - der Stand nach
# dem Purge. Ein Pruefer, der nur Erreichbares beurteilt, saehe hier nichts.
$ziele = Join-Path $data 'ziele'
$zielliste = Join-Path $data 'denylist-ziele.txt'
$ohneAufschub = Join-Path $data 'aufschub-leermeldung.txt'
function Format-Zahl([string]$Name, $Wert) { '  {0,-34} {1}' -f $Name, $Wert }

# Z1. Die zwei unerfuellbaren MUESSEN rot werden - auch die, deren Gegenstand lebt und nur
#     das verlangte Werkzeug gesperrt ist. Die fuenf erfuellbaren bleiben ungenannt; die
#     Liste mit einem lebenden Wert ist ein Hinweis, kein Fehler.
Test-Output 'Herausforderung mit gesperrtem Ziel faellt auf' 1 `
    @('anachronisms', $ziele, '--denylist', $zielliste, '--aufschub', $ohneAufschub) `
    -MustContain @('unerfuellbares-ziel: zielGesperrt',
                   'unerfuellbares-ziel: zielGehalten',
                   'ziel-nennt-gesperrtes: zielListe',
                   (Format-Zahl 'herausforderungen' 7),
                   (Format-Zahl 'unerfuellbar_gesperrt' 2),
                   (Format-Zahl 'unerfuellbar_ohne_weg' 0),
                   (Format-Zahl 'verweise_auf_fehlendes' 0),
                   (Format-Zahl 'gruppen_ohne_herausforderung' 0)) `
    -MustNotContain @('unerfuellbares-ziel: zielLebt',
                      'unerfuellbares-ziel: zielHandFrei',
                      'unerfuellbares-ziel: zielListe',
                      'unerfuellbares-ziel: zielLicht',
                      'unerfuellbares-ziel: zielVariante')

# Z2. Rot wird es durch die REGEL, nicht durch die Daten. Dafuer der Stand VOR dem Purge:
#     das Teil hat ein Rezept. Mit der Regel faellt beides auf - der erreichbare Gegenstand
#     und die Aufgaben, die ihn verlangen; ohne die Zeile ist dieselbe Quelle gruen, und
#     auch der Hinweis an der Liste faellt weg.
$zieleVorher = Join-Path $data 'ziele-vor-purge'
Test-Output 'vor dem Purge: Gegenstand und Ziel fallen beide auf' 1 `
    @('anachronisms', $zieleVorher, '--denylist', $zielliste, '--aufschub', $ohneAufschub) `
    -MustContain @('erreichbarer-anachronismus: pruefFeuerrohrTeil',
                   'unerfuellbares-ziel: zielGesperrt',
                   (Format-Zahl 'unerfuellbar_gesperrt' 2))
Test-Output 'ohne die Sperrregel ist dieselbe Quelle gruen' 0 `
    @('anachronisms', $zieleVorher, '--denylist', (Join-Path $data 'denylist-ziele-ohne.txt'), '--aufschub', $ohneAufschub) `
    -MustContain @((Format-Zahl 'unerfuellbare_herausforderungen' 0)) `
    -MustNotContain @('unerfuellbares-ziel', 'ziel-nennt-gesperrtes')

# Z3. Der Zielaufschub bucht um: aus den zwei Fehlern werden zwei Hinweise mit Adresse, und
#     die Zahl steht daneben. Die Herausforderungen verschwinden nicht.
Test-Output 'Zielaufschub bucht um, statt zu verschweigen' 0 `
    @('anachronisms', $ziele, '--denylist', $zielliste, '--aufschub', (Join-Path $data 'aufschub-ziel.txt')) `
    -MustContain @('aufgeschobenes-ziel: zielGesperrt',
                   'aufgeschobenes-ziel: zielGehalten',
                   'WP9',
                   (Format-Zahl 'unerfuellbare_herausforderungen' 2),
                   (Format-Zahl 'davon_aufgeschoben' 2)) `
    -MustNotContain @('unerfuellbares-ziel')

# Z4. Und ohne Aufschub stehen sie wieder als Fehler da.
Test-Output 'ohne Aufschub sind die Ziele wieder Fehler' 1 `
    @('anachronisms', $ziele, '--denylist', $zielliste, '--ohne-aufschub') `
    -MustContain @('unerfuellbares-ziel: zielGesperrt', 'unerfuellbares-ziel: zielGehalten')

# Z5. Ein Zielaufschub ueber eine erfuellbare Herausforderung schiebt nichts auf und muss
#     auffallen - sonst bliebe ein eingeloester Aufschub fuer immer stehen.
Test-Output 'Zielaufschub ohne Treffer wird genannt' 0 `
    @('anachronisms', $ziele, '--denylist', $zielliste, '--aufschub', (Join-Path $data 'aufschub-ziel-uebrig.txt')) `
    -MustContain @('zielaufschub-trifft-nichts: ziel:zielLebt',
                   (Format-Zahl 'zielaufschub_ohne_treffer' 1)) `
    -MustNotContain @('zielaufschub-trifft-nichts: ziel:zielGesperrt')

# Z6. Derselbe Name ohne den Vorsatz ist ein Aufschub fuer einen GEGENSTAND und schiebt
#     keine Herausforderung auf. Die Regelsaetze sind getrennt.
Test-Output 'ein Gegenstands-Aufschub schiebt keine Herausforderung auf' 1 `
    @('anachronisms', $ziele, '--denylist', $zielliste, '--aufschub', (Join-Path $data 'aufschub-ziel-als-gegenstand.txt')) `
    -MustContain @('unerfuellbares-ziel: zielGesperrt', (Format-Zahl 'zielaufschubregeln' 0))

# Z7. Das zweite Signal: nichts ist gesperrt, aber es fuehrt nichts zum Ziel - der
#     Tippfehler, das Herstellen ohne Rezept, der Block, den es nicht gibt. Das Spiel meldet
#     keinen davon (Finding F-18).
Test-Output 'Ziel ohne Weg, ohne Rezept, ohne Block faellt auf' 1 `
    @('anachronisms', (Join-Path $data 'ziele-tippfehler'), '--denylist', $zielliste, '--aufschub', $ohneAufschub) `
    -MustContain @('unerfuellbares-ziel: zielTippfehler',
                   'pruefSalbee (ohne Weg)',
                   'unerfuellbares-ziel: zielOhneRezept',
                   'pruefHolz (ohne Rezept)',
                   'unerfuellbares-ziel: zielBlockFehlt',
                   'pruefGibtEsNicht (nicht definiert)',
                   (Format-Zahl 'unerfuellbar_gesperrt' 0),
                   (Format-Zahl 'unerfuellbar_ohne_weg' 3)) `
    -MustNotContain @('unerfuellbares-ziel: zielLebt')

# Z8. Eine Quelle ohne challenges.xml kann ueber Ziele nichts sagen. Kein Fehler (sonst
#     waeren alle kleinen Pruefsaetze rot), aber gesagt.
Test-Output 'Quelle ohne challenges.xml: gesagt, nicht rot' 0 `
    @('anachronisms', $auftraege, '--denylist', (Join-Path $data 'denylist-auftrag-keine.txt')) `
    -MustContain @('keine challenges.xml') `
    -MustNotContain @('unerfuellbares-ziel')

# Z9 und Z10. 'ziel:' ohne Kennung und die Leermeldung neben einem Zielaufschub sind
#     Benutzungsfehler, keine Regeln, die alles oder nichts treffen.
Test-Case 'Zielaufschub ohne Kennung' 2 @(
    'anachronisms', $ziele, '--denylist', $zielliste, '--aufschub', (Join-Path $data 'aufschub-ziel-ohne-muster.txt'))
Test-Case 'Leermeldung neben einem Zielaufschub ist ein Widerspruch' 2 @(
    'anachronisms', $ziele, '--denylist', $zielliste, '--aufschub', (Join-Path $data 'aufschub-ziel-und-leermeldung.txt'))

# Z11. Verweise ins Leere (D139). Seit unser Modlet Herausforderungen entfernt, kann ein
#      Name zurueckbleiben, den niemand mehr traegt: die Gruppe einer Herausforderung, das
#      Ziel 'ChallengeComplete' (auf eine Herausforderung und auf eine Gruppe), die Liste der
#      Aktion 'CompleteChallenge' in gameevents.xml - und eine Gruppe, die leer geworden ist.
#      Das Spiel prueft keinen dieser Namen vorher (Finding F-18). Alle Ziele im Pruefsatz
#      sind erfuellbar: rot machen ihn allein die Verweise. Eine andere Aktion mit einer
#      Eigenschaft gleichen Namens zaehlt nicht.
Test-Output 'Verweise auf fehlende Herausforderung und Gruppe, leere Gruppe' 1 `
    @('anachronisms', (Join-Path $data 'ziele-verweise'), '--denylist', $zielliste, '--aufschub', $ohneAufschub) `
    -MustContain @('herausforderung-verweis-fehlt: zielOhneGruppe',
                   'herausforderung-verweis-fehlt: zielNenntFehlende',
                   "Herausforderung 'zielEntfernt'",
                   'herausforderung-verweis-fehlt: zielNenntFehlendeGruppe',
                   "Gruppe 'pruefGruppeFort'",
                   'herausforderung-verweis-fehlt: zielEntfernt',
                   'gruppe-ohne-herausforderung: pruefGruppeLeer',
                   (Format-Zahl 'verweise_auf_fehlendes' 4),
                   (Format-Zahl 'gruppen_ohne_herausforderung' 1)) `
    -MustNotContain @('unerfuellbares-ziel',
                      'zielGanzAnderes',
                      'herausforderung-verweis-fehlt: zielNenntVorhandene',
                      'herausforderung-verweis-fehlt: zielLebt',
                      'gruppe-ohne-herausforderung: pruefGruppe ')

Write-Output ""
Write-Output "== Gegenproben: Wesen - eine Klasse im Gelaende ist kein Gegenstand (D142) =="
# Vertrag 04, Nachtrag Pruefungen der Phase 2, Teil 2. Welche Klassen im Gelaende erscheinen,
# steht in entitygroups.xml, und wer eine Gruppe ruft, in spawning.xml und gamestages.xml.
# Keiner der sechs Wege fuehrt dorthin: 26 dem Namen nach neuzeitliche Klassen stehen in
# Vanillas Landschaftsgruppen, waehrend 'anachronisms' gruen ist.
$wesen = Join-Path $data 'wesen'
$wesenliste = Join-Path $data 'denylist-wesen.txt'
$wesenlisteOhne = Join-Path $data 'denylist-wesen-ohne.txt'

# W1. Die gesperrte Klasse in der Landschaftsgruppe MUSS rot werden, mit Gruppe und
#     Landschaft. Dieselbe Klasse steht auch in der Gruppe, die nur die Spielstufen rufen -
#     die wird nicht genannt, und 'pruefSchreiberWild', das NUR dort steht, auch nicht
#     (Rollentraeger der Seuchennacht, P2-E12). Die Regelsaetze sind getrennt: die Wesenregel
#     urteilt nicht ueber den herstellbaren Gegenstand gleichen Namensanfangs, die
#     Gegenstandsregel nicht ueber die Klasse 'pruefGanzAnderesWesen'.
Test-Output 'gesperrte Klasse in einer Landschaftsgruppe faellt auf' 1 `
    @('anachronisms', $wesen, '--denylist', $wesenliste, '--aufschub', $ohneAufschub) `
    -MustContain @('gesperrtes-wesen: pruefSchreiber',
                   '(pruefTagWald); gerufen in pruefWald',
                   (Format-Zahl 'wesenregeln' 1),
                   (Format-Zahl 'wesenklassen' 4),
                   (Format-Zahl 'wesengruppen' 3),
                   (Format-Zahl 'landschaftsgruppen' 2),
                   (Format-Zahl 'klassen_in_landschaftsgruppen' 3),
                   (Format-Zahl 'gesperrte_wesen_in_landschaftsgruppen' 1),
                   (Format-Zahl 'wesen_verweise_auf_fehlendes' 0),
                   (Format-Zahl 'leere_wesengruppen' 0)) `
    -MustNotContain @('gesperrtes-wesen: pruefSchreiberWild',
                      'gesperrtes-wesen: pruefGanzAnderesWesen',
                      'gesperrtes-wesen: pruefSeuchentoter',
                      'pruefSeuchennacht',
                      'pruefAuskommentiert',
                      'erreichbarer-anachronismus')

# W2. Rot wird es durch die REGEL, nicht durch die Daten: dieselbe Quelle ohne die Zeile.
Test-Output 'ohne die Wesenregel ist dieselbe Quelle gruen' 0 `
    @('anachronisms', $wesen, '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @((Format-Zahl 'wesenregeln' 0),
                   (Format-Zahl 'gesperrte_wesen_in_landschaftsgruppen' 0)) `
    -MustNotContain @('gesperrtes-wesen')

# W3. Verweise ins Leere, ohne jede Wesenregel: ein Eintrag ohne Klasse, eine fehlende Gruppe
#     in spawning.xml, eine in gamestages.xml, eine gerufene leere Gruppe - vier Fehler.
#     'none' ist kein Verweis, und die leere Gruppe, die niemand ruft, ist ein Hinweis.
Test-Output 'Eintrag ohne Klasse, fehlende Gruppen, gerufene leere Gruppe' 1 `
    @('anachronisms', (Join-Path $data 'wesen-verweise'), '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  wesen-verweis-fehlt: pruefFortgenommen',
                   "die Gruppe 'pruefTag' nennt diese Klasse",
                   '[ROT]  wesen-verweis-fehlt: pruefGruppeFort',
                   '[ROT]  wesen-verweis-fehlt: pruefStufeFort',
                   '[ROT]  wesengruppe-leer: pruefLeerGerufen',
                   '[Hinw] wesengruppe-leer: pruefLeerUngerufen',
                   (Format-Zahl 'wesen_verweise_auf_fehlendes' 3),
                   (Format-Zahl 'leere_wesengruppen' 2),
                   '== Ergebnis: 4 rot') `
    -MustNotContain @('wesen-verweis-fehlt: none',
                      'wesen-verweis-fehlt: pruefSeuchentoter',
                      'wesen-verweis-fehlt: pruefTag',
                      '[ROT]  wesengruppe-leer: pruefLeerUngerufen',
                      'gesperrtes-wesen')

# W4. 'wesen:' ohne Muster ist ein Benutzungsfehler, keine Regel, die alles oder nichts trifft.
Test-Case 'Wesenregel ohne Muster' 2 @(
    'anachronisms', $wesen, '--denylist', (Join-Path $data 'denylist-wesen-ohne-muster.txt'))

# W5. Eine Quelle ohne entitygroups.xml kann ueber Wesen nichts sagen. Kein Fehler (sonst
#     waeren alle kleinen Pruefsaetze rot), aber gesagt.
Test-Output 'Quelle ohne entitygroups.xml: gesagt, nicht rot' 0 `
    @('anachronisms', $zieleVorher, '--denylist', (Join-Path $data 'denylist-ziele-ohne.txt'), '--aufschub', $ohneAufschub) `
    -MustContain @('keine entitygroups.xml - Wesen nicht geprueft') `
    -MustNotContain @('wesen-verweis-fehlt', 'wesengruppe-leer')

# W6. Gruppen ohne entityclasses.xml: die Eintraege lassen sich gegen nichts halten. Der
#     Befehl erfindet daraus keinen Fehler - und schweigt nicht darueber.
Test-Output 'Quelle ohne entityclasses.xml: gesagt, nicht rot' 0 `
    @('anachronisms', (Join-Path $data 'wesen-ohne-klassen'), '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @('Die Quelle hat keine entityclasses.xml',
                   (Format-Zahl 'wesengruppen' 1)) `
    -MustNotContain @('wesen-verweis-fehlt')

# W6b. Farben der Wesen (Vertrag 04, Nachtrag WP5.5): MatColor nennt einen <color>-Knoten.
#      Fehlt er, bricht das Spiel erst beim Erscheinen - kein Start-Log zeigt es. Die Klasse
#      mit vorhandener Farbe und die Klasse, die nur erbt, sind kein Befund.
Test-Output 'MatColor ohne Farbknoten ist ein Fehler' 1 `
    @('anachronisms', (Join-Path $data 'wesen-farbe'), '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  wesen-farbe-fehlt: pruefOhneFarbe',
                   (Format-Zahl 'wesenfarben' 1),
                   (Format-Zahl 'wesen_farben_fehlend' 1)) `
    -MustNotContain @('wesen-farbe-fehlt: pruefMitFarbe', 'wesen-farbe-fehlt: pruefErbe')

# W6c. Die Gegenrichtung an einem Satz, der Farben richtig fuehrt: der Pruefsatz 'wesen' nennt
#      keine MatColor - null Fehlende, kein Befund.
Test-Output 'ohne MatColor meldet die Farbpruefung nichts' 0 `
    @('anachronisms', $wesen, '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @((Format-Zahl 'wesen_farben_fehlend' 0)) `
    -MustNotContain @('wesen-farbe-fehlt')

# --- Der Erzeuger: 'purge-patch' nimmt gesperrte Wesen aus den Landschaftsgruppen
#     (D149, Vertrag 04, Nachtrag WP5.4).

# W7. Eine Zeile je Gruppe und Klasse, MIT dem Namen der Gruppe. 'pruefSchreiber' steht auch
#     in der Stufengruppe 'pruefSeuchennacht' - dort bleibt er (P2-E12). Eine Zeile ohne das
#     Praedikat an der Gruppe naehme ihn auch dort heraus.
Test-Output 'purge-patch nimmt das Wesen aus der Landschaftsgruppe, nicht aus der Stufengruppe' 0 `
    @('purge-patch', $wesen, '--trocken', '--zeigen', '--denylist', $wesenliste, '--aufschub', $ohneAufschub) `
    -MustContain @(
        "<remove xpath=""/entitygroups/entitygroup[@name='pruefTagWald']/e[@n='pruefSchreiber']"" />",
        (Format-Zahl 'patchzeilen_entitygroups.xml' 1),
        'gesperrte_wesen_noch_in_landschaftsgruppen 0',
        (Format-Zahl 'landschaftsgruppen_leer_danach' 0)) `
    -MustNotContain @("pruefSeuchennacht']", "e[@n='pruefSchreiberWild']", "<remove xpath=""/entity_classes")

# W8. Der Nachweis, dass die Nachprobe etwas prueft: ohne die Entfernungen steht die Klasse
#     noch in der Landschaftsgruppe.
Test-Output 'ohne die Entfernungen bleibt das Wesen im Gelaende' 1 `
    @('purge-patch', $wesen, '--trocken', '--ohne-entfernen', '--denylist', $wesenliste, '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  wesen-trotz-patch: pruefSchreiber',
                   'gesperrte_wesen_noch_in_landschaftsgruppen 1')

# W9. Der stille Tippfehler: eine Wesenregel, die in keiner Landschaftsgruppe trifft. Die
#     Klasse gibt es - sie steht nur dort, wo keine Wesenregel urteilt.
Test-Output 'Wesenregel ohne Treffer im Gelaende ist ein Fehler' 1 `
    @('purge-patch', $wesen, '--trocken', '--denylist', (Join-Path $data 'denylist-wesen-tippfehler.txt'), '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  wesenregel-trifft-nichts: pruefSchreiberWild')

# W10. Eine Regel, die eine Landschaftsgruppe leert. Das Spiel bricht das Laden einer leeren
#      Gruppe ab (Finding WP5.4) - der Erzeuger sagt es, bevor es eine Datei gibt.
Test-Output 'Wesenregel, die eine Landschaftsgruppe leert, ist ein Fehler' 1 `
    @('purge-patch', $wesen, '--trocken', '--denylist', (Join-Path $data 'denylist-wesen-leert.txt'), '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  wesengruppe-leer-durch-patch: pruefNachtWald',
                   (Format-Zahl 'landschaftsgruppen_leer_danach' 1)) `
    -MustNotContain @('wesengruppe-leer-durch-patch: pruefTagWald')

# W11. Bleibt nur 'none', steht es vorn. Den ersten Eintrag liest das Spiel (Finding WP5.4).
Test-Output 'Landschaftsgruppe, die danach mit none beginnt, ist ein Fehler' 1 `
    @('purge-patch', $wesen, '--trocken', '--denylist', (Join-Path $data 'denylist-wesen-alles.txt'), '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  wesengruppe-beginnt-mit-none: pruefTagWald',
                   '[ROT]  wesengruppe-leer-durch-patch: pruefNachtWald')

# W12. Ohne Wesenregel entsteht KEIN Teil fuer entitygroups.xml - das Erzeugnis sieht aus wie
#      vor dem Nachtrag.
Test-Output 'ohne Wesenregel erzeugt purge-patch nichts fuer entitygroups.xml' 0 `
    @('purge-patch', $wesen, '--trocken', '--zeigen', '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @((Format-Zahl 'wesenregeln' 0)) `
    -MustNotContain @('entitygroups.xml', 'landschaftsgruppen')

# W13. --vergleiche: fehlt die erzeugte Datei im Modlet, faellt das auf.
Test-Output 'fehlende entitygroups.xml im Modlet faellt auf' 1 `
    @('purge-patch', $wesen, '--vergleiche', '--out', (Join-Path $data 'gibtesnicht'), '--denylist', $wesenliste, '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  patchdatei-fehlt: entitygroups.xml')

# W14. Die Gegenrichtung: eine entitygroups.xml im Modlet, und die Sperrliste fuehrt keine
#      Wesenregel mehr. Als "Modlet" dient hier der Pruefsatz selbst - er hat eine Datei
#      dieses Namens; die uebrigen Befunde des Laufs gehoeren nicht zur Probe.
Test-Output 'entitygroups.xml im Modlet ohne Wesenregel faellt auf' 1 `
    @('purge-patch', $wesen, '--vergleiche', '--out', $wesen, '--denylist', $wesenlisteOhne, '--aufschub', $ohneAufschub) `
    -MustContain @('[ROT]  patchdatei-ohne-regel: entitygroups.xml')

# W15. Eine Quelle ohne entitygroups.xml kann ueber die Regel nichts sagen: gesagt, nicht rot.
Test-Output 'purge-patch an einer Quelle ohne Gruppen: gesagt, nicht rot' 0 `
    @('purge-patch', $purge, '--trocken', '--denylist', $wesenliste, '--aufschub', $ohneAufschub) `
    -MustContain @('Diese Quelle hat keine entitygroups.xml oder keine spawning.xml') `
    -MustNotContain @('wesenregel-trifft-nichts')

Write-Output ""
Write-Output "== Gegenproben: Benutzungsfehler ist Exit 2, nicht rot und nicht gruen =="
Test-Case 'unbekannter Befehl' 2 @('gibtesnicht', $data)
Test-Case 'fehlender Pfad' 2 @('recipes')
Test-Case 'Ordner ohne items.xml' 2 @('recipes', $here)
Test-Case 'unbekannte Option' 2 @(
    'recipes', (Join-Path $data 'sauber'), '--quatsch')

Write-Output ""
Write-Output "== Gegenproben: kette-pruefen sieht auch eigene BLOECKE =="
# WARUM DIESE ZWEI PRUEFUNGEN EXISTIEREN (WP5.5b, 8. November 2026). kette-pruefen hat
# Vanillas blocks.xml gelesen, unsere aber nicht. Beim ersten eigenen Block des Projekts -
# dem Webstuhl - meldete es darum dessen Bau-Rezept als 'nirgends definiert'. Die
# Erweiterung liest jetzt auch unsere blocks.xml, und damit ist die Frage offen, ob sie
# das Signal geschaerft oder abgeschaltet hat. Projektregel 5 verlangt eine Antwort: der
# saubere Satz muss gruen sein UND der vertippte Blockname muss weiter rot werden.
Test-Script 'kette-pruefen: eigener Block wird aufgeloest' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @()   # diese Gegenprobe prueft keine XPaths
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('unaufgeloeste Verweise: 0')
Test-Script 'kette-pruefen: vertippter Blockname bleibt rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\falsch\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("'pruefBlockGibtesnicht' ist nirgends definiert")

# WP6: zwei Luecken derselben Bauart, beide nach einem echten Fehler geschlossen. Eine Zutat,
# die per <append> in ein VANILLA-Rezept gehaengt wird, steht in keinem <recipe>-Knoten - so
# ist resourceClay durchgekommen, obwohl der Lehm in Vanilla resourceClayLump heisst. Und ein
# Reparaturwerkzeug steht als Kommaliste im Elementtext eines <set>, also weder in einem
# Rezept noch in einem Attribut. Der saubere Satz muss beide Arten ZAEHLEN, nicht nur
# schweigen - sonst waere die Pruefung gruen, weil sie nichts ansieht.
Test-Script 'kette-pruefen: eingehaengte Zutat und Reparaturwerkzeug werden gezaehlt' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @()   # diese Gegenprobe prueft keine XPaths
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('eingehaengte Zutaten: 1, Reparaturwerkzeuge: 2', 'unaufgeloeste Verweise: 0')
Test-Script 'kette-pruefen: vertippte eingehaengte Zutat wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\falsch\recipes-angehaengt.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("Eingehaengte Zutat 'pruefLehmGibtesnicht' ist nirgends definiert")
Test-Script 'kette-pruefen: vertipptes Reparaturwerkzeug wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\falsch\items-repair.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("Reparaturwerkzeug 'pruefFlickenGibtesnicht' ist nirgends definiert")

# WP6.1: die dritte Stelle derselben Bauart, und diesmal VOR dem Fehler gefunden. Der
# Ausbaupfad biegt mit <set>-Zeilen die Zutat einer Aufwertung, deren Ziel, einen
# Reparaturstoff und den Namen eines Abwurfs um - vier Kennungen als Elementtext, keine
# davon in einem Rezept oder Attribut. Der saubere Satz muss GENAU VIER zaehlen: die
# fuenfte <set>-Zeile der Pruefdatei setzt eine Zahl (ItemCount), und die darf nicht
# mitgezaehlt werden, sonst waere der Beweis, dass der Pruefer schreit.
Test-Script 'kette-pruefen: umgebogene Verweise werden gezaehlt, Zahlen nicht' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks-umgebogen.xml')
    Patches      = @()   # diese Gegenprobe prueft keine XPaths
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('umgebogene Verweise: 4', 'unaufgeloeste Verweise: 0')
Test-Script 'kette-pruefen: vertippte Aufwertungs-Zutat wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\falsch\blocks-umgebogen.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "Aufwertungs-Zutat 'pruefSteinGibtesnicht' ist nirgends definiert",
    "Reparaturstoff 'pruefMoertelGibtesnicht' ist nirgends definiert",
    "Abwurf 'pruefSchuttGibtesnicht' ist nirgends definiert")

# WP6.4: die vierte Stelle, und die groesste. Ein selbst geschriebener Block nennt Kennungen
# in ATTRIBUTEN - Next, ToBlock, Item, Extends, Abwuerfe, Reparaturstoffe -, und bis hierher
# hat kette-pruefen geprueft, DASS unsere Bloecke existieren, aber nicht, worauf sie zeigen.
# WP6.4 schreibt davon ueber dreissig in einem Commit; der Lauf loest jetzt 46 auf.
#
# Der Folgeblock ist der teuerste Tippfehler: BlockPlantGrowing::LateInit wirft eine
# Exception, wenn der Zielblock fehlt, und nimmt beim Spielstart die ganze blocks.xml mit.
# Der saubere Satz steht in der Probe darueber (eigener Block wird aufgeloest, Exit 0) -
# hier muss jede der vier Arten einzeln rot werden.
Test-Script 'kette-pruefen: vertippte Verweise in eigener Definition werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\falsch\blocks-eigene-verweise.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "Folgeblock 'pruefStumpfGibtesnicht' ist nirgends definiert",
    "Grundlage 'pruefBasisGibtesnicht' ist nirgends definiert",
    "Reparaturstoff 'pruefWachsGibtesnicht' ist nirgends definiert",
    "Abwurf 'pruefAscheGibtesnicht' ist nirgends definiert")

Write-Output ""
Write-Output "== Gegenproben: kette-pruefen prueft die XPATHS selbst =="
# WARUM DIESE DREI PRUEFUNGEN EXISTIEREN (WP7.1, 8. November 2026). Unter 'Grenzen' stand
# in kette-pruefen.ps1 wortwoertlich: "Ob der XML-Patcher des Spiels unsere XPaths trifft,
# steht hier nicht." Das war die groesste Luecke des Projekts, denn ein XPath, der nichts
# trifft, ist STILL: XmlPatcher::PatchXml schreibt "XML patch for ... did not apply" ins
# Protokoll und laedt weiter. Das Spiel startet, der Patch fehlt.
#
# Beim ERSTEN Lauf der neuen Pruefung fielen sechs Patches aus dem schon committeten WP6.4
# durch: lanternOld_02/03/04_Player fuehren Class und DescriptionKey nicht selbst, sie
# erben sie. Vier Verweisklassen pruefen den INHALT unserer Patches; diese prueft, ob der
# Patch ueberhaupt irgendwo landet.
Test-Script 'kette-pruefen: treffende XPaths werden gezaehlt' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-gut\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('geprueefte XPaths: 3 (3 in Vanilla, 0 auf eigene Knoten)')

Test-Script 'kette-pruefen: XPath ohne Treffer wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-schlecht\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "XPath trifft nichts: /blocks/block[@name='pruefGibtesnicht']/property[@name='Class']/@value",
    "XPath trifft nichts: /blocks/block[@name='pruefWerkbank']/property[@name='PruefGibtEsNicht']/@value")

# Eigener Fall, weil er eine andere Sache beweist als die beiden oben: dass der Pruefer
# <setattribute> UEBERHAUPT ansieht. Mit $node.Name statt $node.get_Name() wird dieser
# Fall gruen, und die Pruefung ist fuer jede setattribute-Datei blind.
Test-Script 'kette-pruefen: setattribute ohne Treffer wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-schlecht\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("XPath trifft nichts: /blocks/block[@name='pruefAuchnicht']")

Write-Output ""
Write-Output "== Gegenproben: kette-pruefen prueft die FORTSCHRITTS-VERWEISE =="
# WARUM DIESE ZWEI PRUEFUNGEN EXISTIEREN (WP7.2, 8. November 2026). Die XPath-Pruefung sagt,
# ob ein Patch LANDET - nicht, ob der Wert, den er schreibt, etwas bedeutet. Bei
# progression.xml ist das die gefaehrlichere Haelfte: ein <set .../@parent> mit 'attFortitud'
# trifft den XPath einwandfrei und haengt den Unterbereich an ein Attribut, das es nicht
# gibt. Er verschwindet aus dem Fertigkeitsfenster, und nichts sagt es. Dasselbe bei
# progression_name: der Perk verlangt dann eine Stufe, die niemand erreichen kann.
# WP7.2 schreibt 105 solche Zeilen.
Test-Script 'kette-pruefen: Fortschritts-Verweise werden gezaehlt, Schluessel nicht' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\prog-gut\progression.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Fortschritts-Verweise: 3')

Test-Script 'kette-pruefen: vertippte Fortschritts-Verweise werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\prog-schlecht\progression.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "Baum-Zuordnung 'pruefAttGibtesnicht' ist kein Fortschritts-Knoten",
    "Stufenbedingung 'pruefAttAuchnicht' ist kein Fortschritts-Knoten")

# WP10.4 (2026-11-23): ANGELEGTE Knoten und Freischaltungen. Seit dem Runenkundigen legen wir
# Attribut, Gruppen und Perks selbst an; ihre Verweise stehen im Knoten, nicht in einem <set>.
# Und eine Freischaltung (RecipeTagUnlocked) mit vertipptem Rezeptnamen sperrt ein Rezept fuer
# immer. Vorher blieb 'blk700_runenritzerX' gruen.
Test-Script 'kette-pruefen: angelegte Fortschritts-Knoten und Freischaltungen, die aufgehen' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\prog-angelegt-gut\progression.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Verweise in angelegten Fortschritts-Knoten: 3, Freischaltungen: 1')

Test-Script 'kette-pruefen: vertippte Verweise in angelegten Knoten und Freischaltungen werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\prog-angelegt-schlecht\progression.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "Baum-Zuordnung 'pruefAttNeuTippfehler' im angelegten Knoten 'pruefBereichNeu'",
    "Baum-Zuordnung 'pruefBereichFehlt' im angelegten Knoten 'pruefPerkNeu'",
    "Stufenbedingung 'pruefAttFehlt' in einem angelegten Knoten",
    "Freischaltung 'pruefRezeptFehlt' trifft kein Rezept",
    '4 rot')

# WP10.5a (2026-11-23): ein Rezept darf einen eigenen AUFSATZ herstellen. Gruen nur, wenn die
# Aufsatz-Datei gelesen wird; das fehlende Ergebnis bleibt in beiden Laeufen rot.
Test-Script 'kette-pruefen: Rezept fuer einen eigenen Aufsatz ist definiert, ein fehlender nicht' 1 @{
    Rezepte        = @(Join-Path $data 'kette\aufsatz\recipes.xml')
    Gegenstaende   = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke        = @(Join-Path $data 'kette\eigen\blocks.xml')
    AufsatzDateien = @(Join-Path $data 'kette\aufsatz\item_modifiers.xml')
    Patches        = @(Join-Path $data 'kette\prog-gut\progression.xml')
    Vanilla        = (Join-Path $data 'kette\vanilla')
} -MustContain @("Ergebnis 'pruefAufsatzFehlt' ist nirgends definiert", '1 rot') -MustNotContain @("Ergebnis 'pruefAufsatzEigen'")

Test-Script 'kette-pruefen: ohne Aufsatz-Datei ist auch der eigene Aufsatz nicht definiert' 1 @{
    Rezepte      = @(Join-Path $data 'kette\aufsatz\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\prog-gut\progression.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("Ergebnis 'pruefAufsatzEigen' ist nirgends definiert", "Ergebnis 'pruefAufsatzFehlt' ist nirgends definiert", '2 rot')

# WP10.5d (2026-11-23): ein Name in Beute oder Haendlerware muss ein Gegenstand sein. Die
# vertippte Beute und die vertippte Ware werden rot, die bekannten und der Gruppen-Verweis nicht.
Test-Script 'kette-pruefen: vertippte Beute und Ware werden rot, bekannte nicht' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @((Join-Path $data 'kette\ware\loot.xml'), (Join-Path $data 'kette\ware\traders.xml'))
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("Beute oder Ware 'pruefBeuteFehlt' ist nirgends definiert", "Beute oder Ware 'pruefWareFehlt' ist nirgends definiert", 'Beute und Ware mit Namen: 4', '2 rot') -MustNotContain @("'pruefWerkzeug' ist nirgends", "'pruefRohstoff' ist nirgends", "'pruefGruppe' ist nirgends")

# WP10.6 (2026-11-23): ein Buff-Name muss ein Buff sein - in AddBuff/RemoveBuff/HasBuff, in
# Listen mit Komma und in der Explosion eines Wurfs. Vanilla-Buff und eigener Buff sind gruen.
Test-Script 'kette-pruefen: vertippte Buffs werden rot, Vanilla- und eigene nicht' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @((Join-Path $data 'kette\buff\buffs.xml'), (Join-Path $data 'kette\buff\items.xml'))
    Vanilla      = (Join-Path $data 'kette\buff\vanilla')
} -MustContain @("Buff 'pruefBuffFehlt' ist nirgends definiert", "Buff 'pruefBuffWurfFehlt' ist nirgends definiert", 'Buff-Verweise: 5', '2 rot') -MustNotContain @("Buff 'pruefBuffVanilla'", "Buff 'pruefBuffEigen'")

# Ohne Vanillas buffs.xml sagt die Pruefung, dass sie nicht prueft - und wird davon nicht rot.
Test-Script 'kette-pruefen: ohne buffs.xml im Vanilla-Ordner sind Buffs nicht geprueft, gesagt' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\buff\items.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Buff-Verweise: nicht geprueft', '0 rot')

# WP10.9 (2026-11-23): ein Tag in HoldingItemHasTags/WornItems muss an einem Gegenstand stehen -
# eigener Tag, Vanilla-Tag und der zweite Tag einer Vanilla-Liste sind gruen; der vertippte Tag in
# einer Liste und der in WornItems rot; EntityTagCompare zaehlt nicht mit.
Test-Script 'kette-pruefen: vertippte Tags in Bedingungen werden rot, bekannte nicht' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @((Join-Path $data 'kette\tag\buffs.xml'), (Join-Path $data 'kette\tag\items.xml'))
    Vanilla      = (Join-Path $data 'kette\tag\vanilla')
} -MustContain @("Tag 'pruefTagFehlt' in !HoldingItemHasTags steht an keinem Gegenstand", "Tag 'pruefTagGetragenFehlt' in WornItems steht an keinem Gegenstand", 'Tags in Bedingungen: 5', '2 rot') -MustNotContain @("'pruefTagEigen' in", "'pruefTagVanilla' in", "'pruefTagZweit' in", "'pruefWesenTag'")

# WP11.3 (2026-11-23): CVar-Namen. Nur gelesen nur mit Schreiber ausserhalb der XML im Vertrag
# (Server/C#), nur geschrieben nur, wenn der Vertrag den Namen nennt. Der Name mit "Server" im
# Wort darf sich nicht selbst freisprechen; Fliesstext im Vertrag zaehlt nicht; t700_ und $ nicht.
Test-Script 'kette-pruefen: CVar ohne Schreiber oder ohne Leser wird rot, Vertrag und Server nicht' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\cvar\buffs.xml')
    Vanilla      = (Join-Path $data 'kette\tag\vanilla')
    Zustaende    = (Join-Path $data 'kette\cvar\zustaende.md')
} -MustContain @("CVar 'cv700_pruefVertragOhneServer' wird gelesen, aber nirgends geschrieben", "CVar 'cv700_pruefLeseFehlt' wird gelesen, aber nirgends geschrieben", "CVar 'cv700_pruefSchreibFehlt' wird geschrieben, aber nirgends gelesen", 'CVar-Verweise: 8', '3 rot') -MustNotContain @("'cv700_pruefIntern'", "'cv700_pruefServer'", "'.cv700_pruefAnzeige'", 't700_pruefFremd', 'pruefVanilla')

# WP11.9 (2026-11-23): eine gerufene Wesen-Gruppe muss eine Gruppe sein, ein Wesen in unserer
# Gruppe ein Wesen. Vanilla-Gruppe, eigene Gruppe und Vanilla-Wesen sind gruen; dazu trifft der
# Zahlvergleich im XPath (gamestage[@stage >= 10]) die Stufe 50.
Test-Script 'kette-pruefen: vertippte Wesen-Gruppe und vertipptes Wesen werden rot, bekannte nicht' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @((Join-Path $data 'kette\gruppe\gamestages.xml'), (Join-Path $data 'kette\gruppe\entitygroups.xml'))
    Vanilla      = (Join-Path $data 'kette\gruppe\vanilla')
} -MustContain @("Wesen-Gruppe 'pruefGruppeFehlt' ist nirgends definiert", "Wesen 'pruefWesenFehlt' in einer Gruppe ist nirgends definiert", 'Wesen und Gruppen: 5', 'geprueefte XPaths: 2 (2 in Vanilla', '2 rot') -MustNotContain @("'pruefGruppeVanilla'", "'pruefGruppeEigen'", "'pruefWesenVanilla'", 'XPath trifft nichts')

# Ohne Vertrag in Pruefdaten sagt die Regel, dass sie nicht prueft - und wird davon nicht rot.
Test-Script 'kette-pruefen: ohne Vertrag der Zustaende sind CVars nicht geprueft, gesagt' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\tag\items.xml')
    Vanilla      = (Join-Path $data 'kette\tag\vanilla')
} -MustContain @('CVar-Verweise: nicht geprueft', '0 rot')

# ------------------------------------------------------------ glossar-pruefen.ps1 (WP8.5)
# Das Glossar ist die Begriffsquelle (F-12), und glossar-pruefen.ps1 haelt es gegen unsere
# Sprachdatei. Drei Dinge muss die Pruefung koennen, und jedes hat hier seinen falschen
# Eingang: einen verbotenen Begriff finden (und zwar nur in der Sprache, fuer die er
# verboten ist), einen abweichenden Festbegriff finden, und NICHT gruen werden, wenn sie
# nichts gelesen hat. Das Dritte ist das Wichtigste: kette-pruefen hatte genau diese
# Luecke (Vertrag 04, Codex-Befund vom 2026-11-20) - ein leeres Glossar waere sonst
# "0 Verbote, 0 Treffer, GREEN".
$glossarDaten = Join-Path $data 'glossar'

Test-Script 'glossar-pruefen: sauberes Glossar und saubere Sprachdatei' 0 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    '2 Festbegriffe mit Kennung, 1 ohne Kennung, 4 verbotene Muster',
    'Sprachdatei: 3 Zeilen')

# 'level' ist nur im Deutschen verboten, 'dukes' nur im Englischen und nur in der Mehrzahl.
# pruefText traegt englisch "level" und "duke" - beides erlaubt, darf also nicht auftauchen.
Test-Script 'glossar-pruefen: verbotener Begriff wird rot, aber nur in seiner Sprache' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-begriff.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    'Zeilen mit verbotenem Begriff: 2',
    "'pruefSchlecht1' (deutsch): 'Zombie'",
    "'pruefSchlecht1' (deutsch): 'Lagerfeuer'",
    "'pruefSchlecht2' (englisch): 'Dukes'") -MustNotContain @("'pruefText'")

Test-Script 'glossar-pruefen: abweichender und fehlender Festbegriff werden rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-abweichung.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    'abweichende Festbegriffe: 2',
    "deutsch steht 'Herdstelle', das Glossar sagt 'Feuerstelle'",
    "Festbegriff 'pruefErz'",
    'die Sprachdatei hat diesen Schluessel nicht')

Test-Script 'glossar-pruefen: Glossar ohne Tabelle ist nicht pruefbar, nicht gruen' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-leer.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('NICHT PRUEFBAR', 'kein einziger Festbegriff') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: Glossar ohne Verbote ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-ohne-verbote.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('kein einziger verbotener Begriff') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: kaputtes Muster ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-muster-kaputt.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('ist kein regulaerer Ausdruck') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: ein | im Muster zerreisst die Zeile und wird gemeldet' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-muster-pipe.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('Spalten statt 4') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: fehlende Sprachdatei ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei = (Join-Path $glossarDaten 'gibt-es-nicht.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('Sprachdatei fehlt') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: fehlendes Glossar ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'gibt-es-nicht.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('Glossar fehlt') -MustNotContain @('GREEN')

# Drei Faelle aus dem Review vom 2026-11-20, alle im neuen Skript.
#
# (1) Ein Tippfehler in der Kopfzeile ("Sprachen") machte die Tabelle zu "Text fuer
#     Menschen": ihre Verbote galten nicht mehr, der Lauf blieb gruen. Jetzt ist jede
#     Tabelle mit unbekannter Kopfzeile nicht pruefbar.
Test-Script 'glossar-pruefen: Tippfehler in einer Kopfzeile schaltet die Tabelle nicht still ab' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-kopf-kaputt.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-begriff.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('unbekannte Kopfzeile', 'Sprachen') -MustNotContain @('GREEN')

# (2) Relativer Pfad nach einem Ordnerwechsel: Test-Path rechnet gegen den Ordner der
#     PowerShell, [IO.File] gegen den des Prozesses. Die Datei wurde gefunden und dann
#     nicht gelesen.
Push-Location $here
try {
    Test-Script 'glossar-pruefen: relativer Pfad nach Ordnerwechsel wird gelesen' 0 @{
        Glossar     = 'testdaten\glossar\glossar-gut.md'
        Sprachdatei = 'testdaten\glossar\Localization-gut.csv'
    } -Skript 'glossar-pruefen.ps1' -MustContain @('2 Festbegriffe mit Kennung')
}
finally { Pop-Location }

# (3) Unter tuerkischer Kultur ist das kleine Gegenstueck zu 'I' das punktlose i. Ohne
#     CultureInvariant trifft das Muster 'zombie' den Text 'ZOMBIES' dort nicht.
$kulturVorher = [System.Threading.Thread]::CurrentThread.CurrentCulture
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('tr-TR')
try {
    Test-Script 'glossar-pruefen: Grossschreibung trifft auch unter tuerkischer Kultur' 1 @{
        Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
        Sprachdatei = (Join-Path $glossarDaten 'Localization-gross.csv')
    } -Skript 'glossar-pruefen.ps1' -MustContain @("'pruefGross' (deutsch): 'ZOMBIE'")
}
finally { [System.Threading.Thread]::CurrentThread.CurrentCulture = $kulturVorher }

# ------------------------------------------------- Ohne Spielpfad ist nichts gruen
# Review-Befund vom 2026-11-20, und er war richtig: ohne SDTD_PATH, aber mit einem
# ConfigsDump unter %APPDATA%, meldete check-all.ps1 "GRUEN". kette-pruefen schrieb
# "uebersprungen, KEIN GRUEN" und ging mit 0 hinaus, und der uebersprungene
# purge-patch-Vergleich wurde weder gezaehlt noch rot. Der Stop-Hook liest den Ausgang,
# nicht den Text.
#
# Zwei Gegenproben, beide ohne Spielpfad. Die zweite faehrt check-all.ps1 selbst gegen
# einen Testordner: vor der Aenderung hiess die letzte Zeile dort "5 Pruefungen" und
# nannte purge-patch und die Kette nicht als rot. (Dass 'recipes' gegen diesen Ordner rot
# ist, liegt am Ordner und ist hier gleichgueltig - geprueft werden die ZEILEN der beiden
# Pruefungen, die nicht laufen konnten, und die Zahl am Ende.)
Test-Script 'kette-pruefen: ohne Spielpfad ist es nicht geprueft, nicht gruen' 2 @{} `
    -OhneSpielpfad -MustContain @('NICHT GEPRUEFT', 'nicht pruefbar -> RED') -MustNotContain @('GREEN')

Test-Script 'check-all: ohne Spielpfad zaehlen purge-patch und Kette als rot' 1 @{
    SkipGegenproben = $true
    Source          = (Join-Path $data 'sauber')
    Configuration   = $Configuration
} -Skript 'check-all.ps1' -OhneSpielpfad -MustContain @(
    'purge-patch (sind die Patches aktuell?)',
    'kette-pruefen: SDTD_PATH ist nicht gesetzt',
    'sprachverweise-pruefen: SDTD_PATH ist nicht gesetzt',
    '-> nicht geprueft, zaehlt als rot',
    '10 Pruefungen, 6 rot')

# Der Nachbarfall aus dem zweiten Review (2026-11-20): SDTD_PATH ist GESETZT, zeigt aber auf
# einen Ordner ohne Data\Config. kette-pruefen warf dann eine Ausnahme, und check-all.ps1
# endete ohne seine Ergebniszeile. Als Spielpfad dient hier ein Testordner, den es gibt.
Test-Script 'kette-pruefen: Spielpfad ohne Data\Config ist nicht geprueft' 2 @{} `
    -Spielpfad $glossarDaten -MustContain @('den Vanilla-Ordner', 'gibt es nicht', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'check-all: falscher Spielpfad endet mit Ergebniszeile, nicht mit Abbruch' 1 @{
    SkipGegenproben = $true
    Source          = (Join-Path $data 'sauber')
    Configuration   = $Configuration
} -Skript 'check-all.ps1' -Spielpfad $glossarDaten -MustContain @(
    'den Vanilla-Ordner',
    '-> nicht geprueft, zaehlt als rot',
    '10 Pruefungen, 6 rot')

# Und der Fall, der seit WP8.1 nur aufgeschrieben war (Vertrag 04): ein GENANNTER Pfad,
# den es nicht gibt, meldete "0 XPaths, GREEN".
Test-Script 'kette-pruefen: genannter Patch-Pfad, den es nicht gibt, ist nicht geprueft' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\gibt-es-nicht\biomes.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('-Patches nennt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# ------------------------------------------------- Drittes Review (2026-11-20)
# Sieben Faelle, in denen ein Pruefer gruen war, ohne geprueft zu haben, oder abbrach, ohne
# es zu sagen. Jeder ist einmal gegen den Stand davor gelaufen und war dort rot.
#
# (1) -Patches nennt einen ORDNER. Den gibt es, also bestand er die Pruefung "gibt es den
#     Pfad"; gelesen wurde daraus nichts: "0 XPaths, GREEN".
Test-Script 'kette-pruefen: -Patches nennt einen Ordner statt einer Datei' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-gut')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('-Patches nennt', 'ist keine Datei', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (2) Eine Patch-Datei, zu der Vanilla keine Datei hat. Sie wurde uebersprungen, als waere
#     sie nicht da. Das Spiel laedt sie nicht (D53) - also rot, nicht "aussen vor".
Test-Script 'kette-pruefen: Patch-Datei ohne Vanilla-Gegenstueck wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\ohne-gegenstueck\biomes.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Patch-Datei ohne Vanilla-Gegenstueck: biomes.xml',
    'Patch-Dateien: 0 mit Vanilla-Gegenstueck, 1 ohne')

# (3) Eine Patch-Datei in einem UNTERORDNER von Config (bei uns: XUi_InGame). Gesucht wurde
#     nur der Dateiname im obersten Vanilla-Ordner; dort liegt keine windows.xml, also fiel
#     die Datei unter (2) und wurde uebersprungen. Der zweite XPath der Testdatei trifft
#     nichts - und war gruen. (Befund 2 des ERSTEN Reviews, seit WP8.1 nur aufgeschrieben.)
Test-Script 'kette-pruefen: Patch im Unterordner von Config wird gegen dasselbe Unterverzeichnis geprueft' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\unterordner\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Patch-Dateien: 1 mit Vanilla-Gegenstueck, 0 ohne',
    'geprueefte XPaths: 2 (1 in Vanilla, 0 auf eigene Knoten)',
    "XPath trifft nichts: /windows/window[@name='pruefGibtesnicht']/@name")

# (4) Tabellen OHNE Randstriche sind gueltiges Markdown. glossar-pruefen erkannte eine
#     Tabellenzeile am fuehrenden '|' - ohne ihn war die Tabelle Fliesstext, ihre Verbote
#     galten nicht. Hier stehen BEIDE Tabellen ohne Rand; vorher: "kein einziger Festbegriff".
Test-Script 'glossar-pruefen: Tabellen ohne Randstriche werden gelesen' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-ohne-rand.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gross.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    '2 Festbegriffe mit Kennung, 0 ohne Kennung, 1 verbotene Muster',
    "'pruefGross' (deutsch): 'ZOMBIE'")

# (5) Der Fall aus dem Review selbst: die zweite Verbots-Tabelle ohne Rand UND mit
#     "Sprachen" in der Kopfzeile. Sie wurde uebersprungen, bevor die Kopfzeilen-Pruefung
#     sie sah - mit Localization-gut.csv war das Ergebnis GREEN.
Test-Script 'glossar-pruefen: Tippfehler im Kopf einer Tabelle ohne Randstriche ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-ohne-rand-kopf-kaputt.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('unbekannte Kopfzeile', 'Sprachen') -MustNotContain @('GREEN')

# (6) Eine Trennzeile, ueber der keine Kopfzeile steht (Kopfzeile beim Bearbeiten verloren).
#     Die Zeilen darunter sind dann keine Tabelle mehr und waeren wieder Fliesstext.
Test-Script 'glossar-pruefen: Trennzeile ohne Kopfzeile ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-ohne-rand-ohne-kopf.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('Trennzeile ohne Kopfzeile') -MustNotContain @('GREEN')

# (7) SDTD_PATH zeigt auf ein Laufwerk, das nicht eingehaengt ist (USB-Platte ab, Netzlaufwerk
#     weg). Join-Path wirft dann "Cannot find drive" - in kette-pruefen vor jeder Pruefung, in
#     check-all.ps1 vor der Ergebniszeile. Der Buchstabe wird gesucht, nicht angenommen: auf
#     einem Rechner, der Q: hat, waere die Gegenprobe sonst eine andere.
$belegt = @([IO.DriveInfo]::GetDrives() | ForEach-Object { $_.Name.Substring(0, 1).ToUpperInvariant() })
$freierBuchstabe = @('Q', 'Y', 'W', 'V', 'U', 'T', 'R', 'P', 'O', 'N', 'M', 'L', 'K', 'J', 'I', 'H', 'G', 'B') |
    Where-Object { $belegt -notcontains $_ } | Select-Object -First 1
if (-not $freierBuchstabe) {
    # Eine Gegenprobe, die nicht laufen kann, ist nicht bestanden.
    $checked += 2
    $failed += 2
    Write-Output '  [ROT]  kein freier Laufwerksbuchstabe: die zwei Gegenproben zum fehlenden Laufwerk konnten nicht laufen'
}
else {
    $ohneLaufwerk = $freierBuchstabe + ':\gibt-es-nicht\7 Days To Die'

    Test-Script 'kette-pruefen: Spielpfad auf fehlendem Laufwerk ist nicht geprueft, kein Abbruch' 2 @{} `
        -Spielpfad $ohneLaufwerk -MustContain @('den Vanilla-Ordner', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    Test-Script 'check-all: Spielpfad auf fehlendem Laufwerk endet mit Ergebniszeile' 1 @{
        SkipGegenproben = $true
        Source          = (Join-Path $data 'sauber')
        Configuration   = $Configuration
    } -Skript 'check-all.ps1' -Spielpfad $ohneLaufwerk -MustContain @(
        'purge-patch (sind die Patches aktuell?)',
        'den Vanilla-Ordner',
        '-> nicht geprueft, zaehlt als rot',
        '10 Pruefungen, 6 rot')
}

# ------------------------------------------------- Viertes Review (2026-11-21)
# Wieder dieselbe Art Fehler: gruen, ohne geprueft zu haben, oder Abbruch ohne Ergebniszeile.
#
# (1) Der Wurzelknoten. Vertrag 03 §7 verlangt <config>. Die Testdatei traegt <configs> und
#     einen XPath, der TRIFFT - sie war gruen, weil niemand den Wurzelknoten ansah.
Test-Script 'kette-pruefen: falscher Wurzelknoten wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\wurzel-falsch\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Wurzelknoten <configs> statt <config>')

# (2) Ein Tippfehler im Namen der Operation (<sett>) und eine Operation ohne xpath wurden
#     uebersprungen: "1 Patch-Datei, 0 XPaths, GREEN". <conditional> blieb damals eine
#     Grenze und wurde nur gezaehlt ("nicht von innen geprueft (conditional, include): 1").
#     Seit WP8.7 (2026-11-22) wird hineingesehen: der Patch IM Block dieser Testdatei
#     trifft nichts und ist jetzt die dritte rote Zeile.
Test-Script 'kette-pruefen: unbekannte Operation und fehlender xpath werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\operation-falsch\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'unbekannte Patch-Operation <sett>',
    'Patch-Operation <set> ohne xpath',
    'bedingte Bloecke: 1 (Zweige: 1, XPaths darin: 1, xpath-Bedingungen: 0)',
    "XPath trifft nichts: /blocks/block[@name='pruefGibtesnicht']/@name",
    'nicht von innen geprueft (include): 0')

# WP8.7 (2026-11-22): BEDINGTE BLOECKE. Vertrag 03 §5 verlangt sie fuer XUi-Eingriffe, und
# bis hierher war jeder Patch in einem <conditional> fuer kette-pruefen unsichtbar - die
# Pruefung haette also gerade die Dateien verloren, die als naechste entstehen. Was das
# Spiel mit dem Block tut, ist aus dem Code gelesen (Finding WP1 §4, Nachtrag 2026-11-22).
#
# (a) An diesen Bloecken ist nichts falsch: xpath(...) != null mit &quot; und mit \',
#     mod_loaded, <else>, ein Block im Block. Vorher: "0 XPaths", und trotzdem GREEN.
Test-Script 'kette-pruefen: Patches in bedingten Bloecken werden geprueft und gezaehlt' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'geprueefte XPaths: 4 (4 in Vanilla, 0 auf eigene Knoten)',
    'bedingte Bloecke: 3 (Zweige: 4, XPaths darin: 4, xpath-Bedingungen: 3)',
    'in Bedingungen genannte Mods: pruefUiMod')

# (b) Die Bedingungen stimmen, die Patches darin nicht - im <if>, im <else> und im inneren
#     Block je einer. Vorher: GREEN.
Test-Script 'kette-pruefen: falsche Patches in bedingten Bloecken werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-innen-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "XPath trifft nichts: /windows/window[@name='pruefGibtesnicht']",
    'Patch-Operation <set> ohne xpath',
    'unbekannte Patch-Operation <sett>',
    'in Bedingungen genannte Mods: pruefUiMod, pruefZweiteMod',
    '3 rot')

# (c) Die Patches stimmen, die Bedingungen nicht. Der erste Fall ist der, den ich selbst
#     geschrieben haette: xpath(...) allein. Das Spiel verlangt einen Wahrheitswert und
#     xpath liefert keinen - die Datei wuerde mit einer Ausnahme nicht angewandt. Der
#     zweite stand so in unserem eigenen Finding (eventActive heisst die Methode, die
#     Funktion heisst event).
Test-Script 'kette-pruefen: falsche Bedingungen werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-bedingung-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Bedingung liefert keinen Wahrheitswert, sondern String',
    "Bedingung ruft 'eventActive(' auf",
    'Bedingung nennt ein Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefGibtesnicht"]',
    "NCalc kann die Bedingung nicht lesen",
    'XPath in der Bedingung ist kein gueltiger Ausdruck',
    'mod_loaded(...) erwartet genau EINEN festen Text',
    'Bedingungen mit NCalc gelesen: 6 (ohne genannte Mods wahr: 0, falsch: 0, nicht ausgewertet: 0)',
    '6 rot')

# (d) Der Aufbau des Blocks: evaluator, <elseif>, <if> ohne cond, <if> hinter <else>,
#     <else> mit cond, kein <if>, keine Operation. Zwei davon sind im Spiel Ausnahmen, eine
#     ist eine Warnung, vier sind stiller toter Text.
Test-Script 'kette-pruefen: falsch gebaute bedingte Bloecke werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-aufbau-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "<conditional> traegt 'evaluator'",
    'unerwartetes Kind <elseif> in <conditional>',
    "<if> ohne 'cond' in <conditional>",
    '<if> steht hinter <else> und wird nie erreicht',
    "<else> traegt 'cond'",
    '<conditional> ohne ein einziges <if>',
    '<conditional> ohne eine einzige Operation',
    '7 rot')

# Review zu WP8.7 (2026-11-22): drei Befunde an der Zerlegung der Bedingung.
#
# (e) Gueltige Formen, die gruen sein muessen. Die erste - "(xpath(...)) != null" - war
#     ROT: gesucht wurde der Vergleich direkt neben dem Aufruf, und dazwischen stand eine
#     Gruppierungsklammer. Eine Pruefung, die Richtiges abweist, wird abgeschaltet.
Test-Script 'kette-pruefen: Gruppierungsklammern und vertauschte Seiten sind gueltig' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-klammern-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'bedingte Bloecke: 6 (Zweige: 6, XPaths darin: 6, xpath-Bedingungen: 6)',
    'Bedingungen mit NCalc gelesen: 6 (ohne genannte Mods wahr: 6, falsch: 0, nicht ausgewertet: 0)',
    'in Bedingungen genannte Mods: pruefUiMod') -MustNotContain @('keinen Wahrheitswert')

# (f) Falsche Formen, die GRUEN waren: Klammern, die nicht aufgehen (offen am Ende, eine zu
#     viel, falsche Reihenfolge), und ein toter Zweig, wenn 'null' links steht. Dazu zwei,
#     die mit der neuen Klammer-Behandlung rot bleiben muessen: toter Zweig hinter einer
#     Gruppierungsklammer, und ein geklammerter Aufruf ohne Vergleich.
Test-Script 'kette-pruefen: falsche Klammern und tote Zweige mit vertauschten Seiten werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-klammern-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "): (mod_loaded('pruefUiMod')  (",
    "): mod_loaded('pruefUiMod'))  (",
    "): )mod_loaded('pruefUiMod')(  (",
    'Bedingung nennt ein Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefGibtesnicht"]',
    'Bedingung nennt ein Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefAuchNicht"]',
    'Bedingung liefert keinen Wahrheitswert, sondern String',
    '6 rot')

# Zweites Review zu WP8.7 (2026-11-22): DIE BEDINGUNG LIEST JETZT NCALC. Zwei Reviews in
# Folge haben Luecken in der eigenen Zerlegung gefunden; seitdem liest den Ausdruck die
# Bibliothek, die ihn auch im Spiel liest (NCalc.dll aus der Spielinstallation). Die Proben
# (a) bis (f) oben pruefen dieselben Testdateien weiter - ihre erwarteten Zeilen heissen
# jetzt anders, die Urteile sind dieselben. Diese Proben brauchen die Spielinstallation:
# ohne SDTD_PATH enden sie mit Exit 2 und zaehlen als fehlgeschlagen.
#
# (g) Fuenf Schreibweisen fuer "das Ziel der Bedingung gibt es in Vanilla nicht". Die alte
#     Zerlegung hat zwei davon gruen gelassen (geklammertes null) und eine mit der falschen
#     Begruendung rot gemacht ("toter Zweig" bei not(...), obwohl er laeuft). Jetzt gilt
#     eine Regel fuer alle fuenf.
Test-Script 'kette-pruefen: ein Bedingungs-XPath ohne Ziel in Vanilla ist rot, gleich wie geschrieben' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-ziel-fehlt\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefErstes"]',
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefZweites"]',
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefDrittes"]',
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefViertes"]',
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefFuenftes"]',
    '5 rot') -MustNotContain @('toter Text')

# (h) Bedingungen, die in Vanilla FALSCH ergeben, sind kein Fehler - der Zweig ist fuer den
#     Fall gedacht, dass eine andere Mod das Ziel entfernt hat. Dazu drei Mods (acht
#     Belegungen) und eine Funktion, die nur das laufende Spiel auswerten kann.
Test-Script 'kette-pruefen: Bedingungen werden ausgewertet; falsch in Vanilla ist kein Fehler' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-auswertung-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Bedingungen mit NCalc gelesen: 4 (ohne genannte Mods wahr: 2, falsch: 1, nicht ausgewertet: 1)',
    'in Bedingungen genannte Mods: pruefDritteMod, pruefErsteMod, pruefZweiteMod')

# (i) Bedingungen, die NCalc LESEN kann und die erst beim AUSWERTEN scheitern. Die erste
#     zeigt, warum jede Belegung durchgerechnet wird: ohne die Mod ergibt sie "falsch" und
#     sieht gesund aus; mit der Mod steht ein Text, wo ein Wahrheitswert gebraucht wird.
Test-Script 'kette-pruefen: Bedingungen, die beim Auswerten scheitern, werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-auswertung-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    "): mod_loaded('pruefUiMod') and xpath(",
    "): mod_loaded('pruefUiMod') + 1  (",
    '): pruefUnbekannt = 1  (',
    'Bedingung liefert keinen Wahrheitswert, sondern Int32',
    'Bedingungen mit NCalc gelesen: 4 (ohne genannte Mods wahr: 0, falsch: 0, nicht ausgewertet: 0)',
    '4 rot')

# (j) OHNE NCALC IST ES NICHT GEPRUEFT. Der gefaehrlichste Zustand eines Pruefers ist der,
#     in dem ihm sein Werkzeug fehlt: dann darf er nicht gruen sagen. Drei Wege dorthin -
#     der Pfad fuehrt ins Leere, die Datei ist keine Bibliothek, der Spielpfad fehlt.
Test-Script 'kette-pruefen: bedingter Block, NCalc-Pfad fuehrt ins Leere - nicht geprueft' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
    NCalc        = (Join-Path $data 'kette\gibtesnicht\NCalc.dll')
} -MustContain @('die NCalc.dll des Spiels fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'kette-pruefen: bedingter Block, NCalc-Datei ist keine Bibliothek - nicht geprueft' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
    NCalc        = (Join-Path $data 'kette\vanilla\blocks.xml')
} -MustContain @('laesst sich nicht laden', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'kette-pruefen: bedingter Block ohne Spielpfad - nicht geprueft' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -OhneSpielpfad -MustContain @('SDTD_PATH ist nicht gesetzt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (k) Die Kehrseite: eine Patch-Datei OHNE bedingten Block braucht die Bibliothek nicht und
#     darf an ihrem Fehlen nicht scheitern - sonst haengt jede Probe dieser Datei am Spiel.
Test-Script 'kette-pruefen: ohne bedingten Block wird NCalc nicht gebraucht' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-gut\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
    NCalc        = (Join-Path $data 'kette\gibtesnicht\NCalc.dll')
} -MustContain @(
    'geprueefte XPaths: 3 (3 in Vanilla, 0 auf eigene Knoten)',
    'Bedingungen mit NCalc gelesen: 0 (ohne genannte Mods wahr: 0, falsch: 0, nicht ausgewertet: 0)')

# Drittes Review zu WP8.7 (2026-11-22): fuenf Befunde an der Auswertung mit NCalc.
#
# (l) Funktionen und Ziele, die GRUEN waren: event() ohne Argument (im Spiel eine
#     Ausnahme), ein weiches Trennzeichen im Funktionsnamen (PowerShells -contains
#     vergleicht nach Kultur), und zwei Ziele, die die Ausnahme "nur eigene Kennungen"
#     durchliess - eines davon ein FREMDES Fenster mit einem eigenen Namen im zweiten
#     Praedikat. Die Ausnahme ist fuer Bedingungen gestrichen.
Test-Script 'kette-pruefen: falsche Argumentzahl, Trennzeichen im Namen und Ziele mit eigenem Namen werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-funktion-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'event(...) bekommt 0 Argumente, das Spiel verlangt genau 1',
    'game_version(...) bekommt 1 Argumente, das Spiel verlangt genau 0',
    'version(...) bekommt 1 Argumente, das Spiel verlangt mindestens 2',
    "Bedingung ruft 'mod_lo",
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name = "pruefFremd"]/label[@name="pruefBlockEigen"]',
    'Ziel, das es in Vanilla nicht gibt: /windows/window[@name="pruefBlockEigen"]',
    '6 rot')

# (m) Die Kehrseite: 'xml' ist im Spiel ein belegter Name (war rot), Funktionen des
#     laufenden Spiels mit richtiger Argumentzahl werden gelesen und nicht ausgewertet,
#     und Funktionsnamen gelten ohne Gross/Klein wie im Spiel.
Test-Script 'kette-pruefen: xml ist belegt, richtige Argumentzahl ist gruen, Namen ohne Gross/Klein' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-funktion-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Bedingungen mit NCalc gelesen: 4 (ohne genannte Mods wahr: 2, falsch: 0, nicht ausgewertet: 2)',
    'in Bedingungen genannte Mods: pruefUiMod')

# (n) Neun Mods UND eine Funktion des laufenden Spiels: die Grenze von acht Mods griff
#     nicht, weil die Bedingung vorher als "nicht ausgewertet" uebersprungen wurde. Exit 0.
Test-Script 'kette-pruefen: neun Mods sind nicht pruefbar, auch neben einer Spiel-Funktion' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-neun-mods\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('eine Bedingung nennt 9 Mods', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (o) Ein Block, dessen <if> kein 'cond' traegt: mit der Bibliothek ein Befund, OHNE sie
#     "nicht geprueft". Vorher wurde die Bibliothek erst bei der ersten Bedingung gesucht -
#     ohne Bedingung fiel ihr Fehlen nicht auf, und es blieb bei Exit 1.
Test-Script 'kette-pruefen: Block ohne cond ist mit NCalc ein Befund' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-ohne-cond\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @("<if> ohne 'cond' in <conditional>", '1 rot')

Test-Script 'kette-pruefen: Block ohne cond ist ohne NCalc nicht geprueft' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-ohne-cond\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
    NCalc        = (Join-Path $data 'kette\gibtesnicht\NCalc.dll')
} -MustContain @('die NCalc.dll des Spiels fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN', "<if> ohne 'cond'")

# Viertes Review zu WP8.7 (2026-11-22): vier Befunde.
#
# (p) DER XML-ADAPTER VERDECKT EIGENSCHAFTEN. In Windows PowerShell 5.1 liefert
#     $knoten.NodeType den Wert eines ATTRIBUTS namens NodeType, wenn der Knoten eines
#     traegt. <conditional NodeType="skip"> wurde uebersprungen wie ein Kommentar: 0 bedingte
#     Bloecke, GRUEN - mit und ohne Bibliothek. Gelesen wird der Aufbau jetzt ueber Methoden.
Test-Script 'kette-pruefen: ein Block mit Attribut NodeType wird gelesen' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-nodetype\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('bedingte Bloecke: 1 (', "<if> ohne 'cond' in <conditional>", '1 rot')

Test-Script 'kette-pruefen: ein Block mit Attribut NodeType ist ohne NCalc nicht geprueft' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-nodetype\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
    NCalc        = (Join-Path $data 'kette\gibtesnicht\NCalc.dll')
} -MustContain @('die NCalc.dll des Spiels fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (q) Dieselbe Bauart an drei anderen Stellen: ein Kind <ChildNodes/> verdeckt die
#     Kinderliste eines Zweigs, eine Operation und ein <if> tragen NodeType. Alles GRUEN.
Test-Script 'kette-pruefen: verdeckte Kinderliste, Operation und <if> mit NodeType werden gelesen' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-adapter-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'unbekannte Patch-Operation <ChildNodes>',
    "XPath trifft nichts: /windows/window[@name='pruefGibtEsNichtA']",
    "XPath trifft nichts: /windows/window[@name='pruefGibtEsNichtB']",
    'event(...) bekommt 0 Argumente, das Spiel verlangt genau 1',
    '4 rot')

# (r) Und bei den Fortschritts-Verweisen: NodeType versteckte die Zeile, ein Attribut
#     InnerText ihren Text (gelesen wurde das Attribut, ein gueltiger Knoten).
Test-Script 'kette-pruefen: Fortschritts-Verweise hinter NodeType und InnerText werden rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\prog-adapter\progression.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Fortschritts-Verweise: 2',
    "Baum-Zuordnung 'pruefAttGibtesnicht' ist kein Fortschritts-Knoten",
    "Stufenbedingung 'pruefAttAuchnicht' ist kein Fortschritts-Knoten",
    '2 rot')

# (s) Neun Mods UND ein zweiter Fehler in derselben Bedingung: der Befund zur Argumentzahl
#     kam der Grenze von acht Mods zuvor. Exit 1 statt Exit 2.
Test-Script 'kette-pruefen: neun Mods sind nicht pruefbar, auch neben einem zweiten Fehler' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-neun-mods-und-fehler\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('eine Bedingung nennt 9 Mods', 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'bekommt 0 Argumente')

# (t) DIE TABELLE DER ARGUMENTZAHLEN, alle elf Funktionen. Diese zwei Laeufe sind gegen das
#     Skript des Stands 75a10dd GRUEN - die Tabelle stimmte. Bewiesen sind sie an einer
#     absichtlich verfaelschten Tabelle (Vertrag 04, Nachtrag viertes Review zu WP8.7):
#     dort scheitern beide, und jede Zeile unten fehlt einzeln in der Ausgabe.
Test-Script 'kette-pruefen: jede der elf Funktionen ist mit richtiger Argumentzahl gruen' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-argumente-gut\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'Bedingungen mit NCalc gelesen: 12 (ohne genannte Mods wahr: 1, falsch: 1, nicht ausgewertet: 10)',
    'in Bedingungen genannte Mods: pruefUiMod')

Test-Script 'kette-pruefen: jede der elf Funktionen ist mit falscher Argumentzahl rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\bedingt-argumente-falsch\Config\XUi_InGame\windows.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @(
    'mod_loaded(...) erwartet genau EINEN festen Text',
    'xpath(...) erwartet genau EINEN festen Text',
    'mod_version(...) bekommt 0 Argumente, das Spiel verlangt genau 1',
    'game_version(...) bekommt 1 Argumente, das Spiel verlangt genau 0',
    'version(...) bekommt 0 Argumente, das Spiel verlangt mindestens 2',
    'serverinfo(...) bekommt 0 Argumente, das Spiel verlangt genau 1',
    'gamepref(...) bekommt 2 Argumente, das Spiel verlangt genau 1',
    'event(...) bekommt 2 Argumente, das Spiel verlangt genau 1',
    'time_minutes(...) bekommt 1 Argumente, das Spiel verlangt genau 0',
    'game_loaded(...) bekommt 1 Argumente, das Spiel verlangt genau 0',
    'has_entitlement(...) bekommt 0 Argumente, das Spiel verlangt genau 1',
    '11 rot')

# (3) Der Fall, an dem das Review es gezeigt hat: eine VANILLA-Datei als Patch. Ihr
#     Wurzelknoten ist <blocks>, ihre Kinder sind keine Operationen.
Test-Script 'kette-pruefen: eine Datei, die kein Patch ist, wird rot' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\vanilla\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Wurzelknoten <blocks> statt <config>') -MustNotContain @('GREEN')

# (3b) Eine Patch-Datei, die kein gueltiges XML ist: eine rote Zeile, keine Ausnahme.
Test-Script 'kette-pruefen: kaputtes XML ist rot, kein Abbruch' 1 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xml-kaputt\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Datei ist kein gueltiges XML: kette\xml-kaputt\blocks.xml', '== Ergebnis: 1 rot -> RED ==')

# ------------------------------------------------- Fuenftes Review (2026-11-21)
# (3c) Dieselbe kaputte Datei an JEDER Stelle, an der das Skript XML liest: als Rezept-,
#      Gegenstands-, Block- und Patch-Datei zugleich. Vorher fing nur die Patch-Schleife den
#      Fehler ab; die drei frueheren Leser fielen mit einer Ausnahme heraus, ohne
#      Ergebniszeile. Jetzt: EINE rote Zeile (nicht vier), Exit 1.
Test-Script 'kette-pruefen: kaputtes XML ist an jeder Lesestelle rot, und nur einmal' 1 @{
    Rezepte      = @(Join-Path $data 'kette\xml-kaputt\blocks.xml')
    Gegenstaende = @(Join-Path $data 'kette\xml-kaputt\blocks.xml')
    Bloecke      = @(Join-Path $data 'kette\xml-kaputt\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xml-kaputt\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla')
} -MustContain @('Datei ist kein gueltiges XML: kette\xml-kaputt\blocks.xml', '== Ergebnis: 1 rot -> RED ==')

# (3d) Eine VANILLA-Datei, die kein gueltiges XML ist. Das ist kein Befund an unserer Datei:
#      gegen sie laesst sich nichts pruefen - Exit 2.
Test-Script 'kette-pruefen: kaputtes Vanilla-XML ist nicht pruefbar' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-gut\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla-kaputt')
} -MustContain @('Vanilla-Datei', 'ist kein gueltiges XML', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (3e) Eine Datei, die sich nicht LESEN laesst. Die Gegenprobe haelt sie fuer die Dauer des
#      Laufs exklusiv offen (FileShare.None). Vorher: "kein gueltiges XML", Exit 1 - ein
#      Befund, wo es ein fehlender Eingang ist. Jetzt Exit 2. Einmal als Patch-Datei, einmal
#      als Rezept-Datei (die fruehe Lesestelle).
#      Seit dem sechsten Review auch die zwei VANILLA-Dateien, deren Kennungen als Text
#      gelesen werden: dort stand ein 'Select-String' ohne Abfang.
#      DIE SPERRE WIRD ERST GEPRUEFT. Auf manchen Dateisystemen (so in der Umgebung des
#      sechsten Reviews) laesst sich eine mit FileShare.None geoeffnete Datei trotzdem lesen.
#      Dann laesst sich die Gegenprobe dort nicht fuehren - das steht dann da, als ROT mit
#      diesem Grund, nicht als raetselhaftes "Exit 0 erwartet 2" und nicht als uebersprungen.
foreach ($fall in @(
        @{ Art = 'Patch-Datei'; Datei = 'kette\xpath-gut\blocks.xml' },
        @{ Art = 'Rezept-Datei'; Datei = 'kette\eigen\recipes.xml' },
        @{ Art = 'Vanilla-items.xml'; Datei = 'kette\vanilla\items.xml' },
        @{ Art = 'Vanilla-blocks.xml'; Datei = 'kette\vanilla\blocks.xml' })) {
    $gesperrtePfad = Join-Path $data $fall.Datei
    $titel = "kette-pruefen: gesperrte $($fall.Art) ist nicht pruefbar, kein Befund"
    $sperre = [IO.File]::Open($gesperrtePfad, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
    try {
        $sperreGreift = $false
        try {
            $zweite = [IO.File]::OpenRead($gesperrtePfad)
            $zweite.Close()
        }
        catch { $sperreGreift = $true }
        if (-not $sperreGreift) {
            $script:checked++
            $script:failed++
            Write-Output ("  [ROT]  " + $titel)
            Write-Output '         die Sperre (FileShare.None) greift auf diesem Dateisystem nicht - die Gegenprobe laesst sich hier nicht fuehren'
            continue
        }
        $p = @{
            Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
            Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
            Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
            Patches      = @(Join-Path $data 'kette\xpath-gut\blocks.xml')
            Vanilla      = (Join-Path $data 'kette\vanilla')
        }
        Test-Script $titel 2 $p `
            -MustContain @('laesst sich nicht lesen', 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'kein gueltiges XML')
    }
    finally { $sperre.Close() }
}

# (3f) Dieselbe kaputte Datei in ZWEI ROLLEN: als eigene Block-Datei und als Vanillas
#      blocks.xml. Der Zwischenspeicher hielt das Urteil der ersten Rolle fest ("Befund"),
#      und die Vanilla-Rolle bekam es zurueck: Exit 1 mit falschen XPath-Befunden statt
#      "nicht pruefbar". Jetzt entscheidet jeder Aufruf fuer seine Rolle.
Test-Script 'kette-pruefen: kaputte Datei als Block- UND Vanilla-Datei ist nicht pruefbar' 2 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\vanilla-kaputt\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-gut\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\vanilla-kaputt')
} -MustContain @('Vanilla-Datei', 'ist kein gueltiges XML', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# ------------------------------------------------- Siebtes Review (2026-11-21)
# (3g) Diese Gegenprobe muss GRUEN sein - sie faengt ein falsches Rot. Vanillas items.xml
#      traegt einen Kommentar mit einem angefangenen '<item name="', und in der Zeile danach
#      steht die echte Definition von pruefRohstoff. Als das Muster ueber den ganzen Text
#      lief, verschluckte der Treffer die Definition: "2 aus Vanilla" statt 3, und die drei
#      Verweise auf pruefRohstoff standen als unaufgeloest da.
Test-Script 'kette-pruefen: Kommentar mit angefangenem Attribut verschluckt keine Definition' 0 @{
    Rezepte      = @(Join-Path $data 'kette\eigen\recipes.xml')
    Gegenstaende = @(Join-Path $data 'kette\eigen\items.xml')
    Bloecke      = @(Join-Path $data 'kette\eigen\blocks.xml')
    Patches      = @(Join-Path $data 'kette\xpath-gut\blocks.xml')
    Vanilla      = (Join-Path $data 'kette\kommentar-vor-definition')
} -MustContain @('Definitionen: 3 aus Vanilla, 2 eigene', 'unaufgeloeste Verweise: 0') -MustNotContain @('ist nirgends definiert')

# (4) Eine kaputte Trennzeile ("---|---|---|oops") unter einer Tabelle ohne Randstriche.
#     Markdown liest das nicht als Tabelle; ihr Verbot 'zombie' fiel weg, und weil eine
#     zweite Verbots-Tabelle heil war, blieb der Lauf GREEN - mit "ZOMBIE" in der Sprachdatei.
Test-Script 'glossar-pruefen: kaputte Trennzeile schaltet die Tabelle nicht still ab' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-trennzeile-kaputt.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gross.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('sieht aus wie eine Tabellenzeile') -MustNotContain @('GREEN')

# (5) SDTD_PATH mit WOERTLICHEN Anfuehrungszeichen, wie 'set SDTD_PATH="C:\..."' in cmd sie
#     hinterlaesst. Unter Windows PowerShell 5.1 wirft dann auch [IO.Path]::Combine.
$inAnfuehrung = '"' + $glossarDaten + '"'

Test-Script 'kette-pruefen: Spielpfad in Anfuehrungszeichen ist nicht geprueft, kein Abbruch' 2 @{} `
    -Spielpfad $inAnfuehrung -MustContain @('NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'check-all: Spielpfad in Anfuehrungszeichen endet mit Ergebniszeile' 1 @{
    SkipGegenproben = $true
    Source          = (Join-Path $data 'sauber')
    Configuration   = $Configuration
} -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -MustContain @(
    '-> nicht geprueft, zaehlt als rot',
    '10 Pruefungen, 6 rot')

# (6) Dasselbe OHNE -Source und ohne ConfigsDump: %APPDATA% zeigt fuer diesen Lauf auf einen
#     Testordner, in dem kein Spielstand liegt. Vorher: 'throw', keine Ergebniszeile.
#     anachronisms, recipes, purge-patch, die Kette und (seit WP8.8) die Sprachschluessel
#     koennen nicht laufen = 5 rot.
#     Seit dem 2026-11-22 sucht check-all.ps1 auch unter SDTD_USERDATA. Die Variable wird
#     darum ab hier bis zum Ende der Dump-Suche-Gegenproben weggenommen - sonst faende der
#     Lauf auf einem Rechner, der sie gesetzt hat, einen echten Dump.
$userdataVorher = $env:SDTD_USERDATA
Remove-Item Env:SDTD_USERDATA -ErrorAction SilentlyContinue
Test-Script 'check-all: ohne jede Quelle zaehlen anachronisms und recipes als rot' 1 @{
    SkipGegenproben = $true
    Configuration   = $Configuration
} -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -Appdata $glossarDaten -MustContain @(
    'Quelle: KEINE',
    'NICHT GEPRUEFT: keine Quelle',
    '10 Pruefungen, 7 rot')

# ------------------------------------------------- Dump-Suche kennt -UserDataFolder (2026-11-22)
# Mit '-UserDataFolder=<Ordner>' legt das Spiel Spielstaende unter <Ordner>\Saves ab, nicht
# unter %APPDATA%. check-all.ps1 suchte nur unter %APPDATA% und las am 2026-11-22 nach einem
# Start mit dem neuen Stand weiter den Dump vom Vortag: 80 Sackgassen, obwohl der neue 0
# hatte. Vier Gegenproben, alle in einem nachgebauten Baum und mit kaputtem Spielpfad - der
# macht vier Pruefungen rot (wie Fall 5 oben), die fuenfte Zahl haengt allein an der Quelle:
# "4 rot" heisst Dump gefunden, "5 rot" heisst keiner.
$dumpBaum = Join-Path ([IO.Path]::GetTempPath()) ('mod700-dumpsuche-' + [Guid]::NewGuid().ToString('N'))
try {
    function New-ProbeDump {
        # Legt <Wurzel>\Saves\Welt\Stand\ConfigsDump mit dem sauberen Satz an und stellt
        # seine Aenderungszeit; gibt den Ordner zurueck.
        param([string]$Wurzel, [datetime]$Zeit)
        $ziel = Join-Path $Wurzel 'Saves\Welt\Stand\ConfigsDump'
        New-Item -ItemType Directory -Force -Path $ziel | Out-Null
        Copy-Item -Path (Join-Path $data 'sauber\*') -Destination $ziel -Recurse -Force
        (Get-Item -LiteralPath $ziel).LastWriteTime = $Zeit
        return $ziel
    }
    function New-ProbeAppdata {
        # Legt <Wurzel>\7DaysToDie\launchersettings.json mit dem gegebenen Inhalt an.
        param([string]$Wurzel, [string]$Inhalt)
        New-Item -ItemType Directory -Force -Path (Join-Path $Wurzel '7DaysToDie') | Out-Null
        [IO.File]::WriteAllText((Join-Path $Wurzel '7DaysToDie\launchersettings.json'), $Inhalt, [Text.UTF8Encoding]::new($false))
    }
    function Get-LauncherJson {
        param([string]$Ordner)
        $wert = '-UserDataFolder="' + $Ordner + '"'
        return (@{ DefaultRunConfig = @{ UseEAC = $true; AdditionalParameters = $wert } } | ConvertTo-Json)
    }
    $alt = (Get-Date).AddDays(-2)
    $neu = (Get-Date).AddDays(-1)

    # (a) Der Dump liegt NUR unter dem Ordner, den das Startprogramm nennt.
    $aAppdata = Join-Path $dumpBaum 'a\appdata'
    $aNutzer = Join-Path $dumpBaum 'a\nutzerdaten'
    $aDump = New-ProbeDump $aNutzer $neu
    New-ProbeAppdata $aAppdata (Get-LauncherJson $aNutzer)
    Test-Script 'check-all: Dump unter dem UserDataFolder des Startprogramms wird gefunden' 1 @{
        SkipGegenproben = $true
        Configuration   = $Configuration
    } -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -Appdata $aAppdata -MustContain @(
        "Quelle: $aDump",
        '10 Pruefungen, 6 rot') -MustNotContain @('Quelle: KEINE')

    # (b) Zwei Dumps, der unter %APPDATA% ist JUENGER: er gewinnt, nicht der Ort.
    $bAppdata = Join-Path $dumpBaum 'b\appdata'
    $bNutzer = Join-Path $dumpBaum 'b\nutzerdaten'
    $bDumpNutzer = New-ProbeDump $bNutzer $alt
    $bDumpAppdata = New-ProbeDump (Join-Path $bAppdata '7DaysToDie') $neu
    New-ProbeAppdata $bAppdata (Get-LauncherJson $bNutzer)
    Test-Script 'check-all: ueber alle Suchorte gewinnt der juengste Dump' 1 @{
        SkipGegenproben = $true
        Configuration   = $Configuration
    } -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -Appdata $bAppdata -MustContain @(
        "Quelle: $bDumpAppdata",
        '10 Pruefungen, 6 rot') -MustNotContain @("Quelle: $bDumpNutzer")

    # (c) launchersettings.json ist kaputt: Hinweis, kein Abbruch, und ohne anderen Dump
    #     bleibt es bei "keine Quelle" mit Ergebniszeile.
    $cAppdata = Join-Path $dumpBaum 'c\appdata'
    New-ProbeAppdata $cAppdata '{ "DefaultRunConfig" : { "AdditionalParameters" : '
    Test-Script 'check-all: kaputte launchersettings.json ist ein Hinweis, kein Abbruch' 1 @{
        SkipGegenproben = $true
        Configuration   = $Configuration
    } -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -Appdata $cAppdata -MustContain @(
        'launchersettings.json ist nicht lesbar',
        'Quelle: KEINE',
        '10 Pruefungen, 7 rot')

    # (d) Kein Startprogramm, aber SDTD_USERDATA zeigt auf den Ordner.
    $dAppdata = Join-Path $dumpBaum 'd\appdata'
    $dNutzer = Join-Path $dumpBaum 'd\nutzerdaten'
    New-Item -ItemType Directory -Force -Path $dAppdata | Out-Null
    $dDump = New-ProbeDump $dNutzer $neu
    $env:SDTD_USERDATA = $dNutzer
    Test-Script 'check-all: Dump unter SDTD_USERDATA wird gefunden' 1 @{
        SkipGegenproben = $true
        Configuration   = $Configuration
    } -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -Appdata $dAppdata -MustContain @(
        "Quelle: $dDump",
        '10 Pruefungen, 6 rot') -MustNotContain @('Quelle: KEINE')
}
finally {
    if ($userdataVorher) { $env:SDTD_USERDATA = $userdataVorher }
    else { Remove-Item Env:SDTD_USERDATA -ErrorAction SilentlyContinue }
    if (Test-Path -LiteralPath $dumpBaum) { Remove-Item -LiteralPath $dumpBaum -Recurse -Force }
}

# ------------------------------------------------- Review zu WP8.6 (2026-11-21)
# Der Name der Mod steht in EINER Zeile der Sprachdatei (D6). Abgesichert war das mit einem
# Festbegriff und zwei Verbotsmustern, die den Namen nur IN einem laengeren Text trafen:
# eine zweite Zeile, die nur aus dem Namen bestand, blieb gruen. Jetzt gibt es dafuer eine
# dritte Tabellenform, den Alleinnamen. Acht Faelle - der erste muss gruen sein, sonst
# bewiese ein Rot der anderen nichts.
Test-Script 'glossar-pruefen: Alleinname unter seinem Schluessel und sonst nirgends ist gruen' 0 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('Alleinnamen: 1, Verstoesse: 0', 'GREEN')

# Der Fall aus dem Review: anderer Schluessel, der Text ist NUR der Name.
Test-Script 'glossar-pruefen: zweite Zeile nur mit dem Alleinnamen wird rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-doppelt.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Alleinname 'Testland' steht auch in '700_zweiterName' (deutsch)",
    "Alleinname 'Testland' steht auch in '700_zweiterName' (englisch)",
    'Alleinnamen: 1, Verstoesse: 2') -MustNotContain @('GREEN')

# Mitten im Satz und in anderer Schreibung ("TESTLAND"), nur im Englischen.
Test-Script 'glossar-pruefen: Alleinname mitten im Text wird rot, auch gross geschrieben' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-im-text.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Alleinname 'Testland' steht auch in 'pruefTipp' (englisch)",
    'Alleinnamen: 1, Verstoesse: 1') -MustNotContain @('GREEN', "'pruefTipp' (deutsch)")

Test-Script 'glossar-pruefen: fehlt die Zeile des Alleinnamens, wird es rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Alleinname '700_modName'", 'die Sprachdatei hat diesen Schluessel nicht') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: traegt die Zeile einen anderen Namen, wird es rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-anders.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "deutsch steht 'Anderland', das Glossar sagt 'Testland'") -MustNotContain @('GREEN')

# Derselbe Schluessel zweimal: die zweite Zeile ist eine "andere" Zeile.
Test-Script 'glossar-pruefen: derselbe Schluessel zweimal ist auch eine zweite Zeile' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-zweimal.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Alleinname 'Testland' steht auch in '700_modName'") -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: Alleinname ohne Schluessel ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname-ohne-schluessel.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('braucht seinen Schluessel in Backticks') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: Alleinname mit zwei Zeichen ist nicht pruefbar' 2 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname-kurz.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-gut.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @('kuerzer als drei Zeichen') -MustNotContain @('GREEN')

# ------------------------------------------ Zweites Review zu WP8.6 (2026-11-21)
# Fuenf Befunde am Alleinnamen, vier davon im Skript. Jede Probe unten war gegen das
# Skript des Stands be1e58b gruen, wo sie rot sein muss (ausser den zwei, die es dazusagen).

# Befund 2: der Schluessel wurde ohne Gross/Klein gesucht. '700_modname' mit dem richtigen
# Namen steht ZUERST, '700_modName' mit dem falschen danach - geprueft wurde die erste.
Test-Script 'glossar-pruefen: klein geschriebener Schluessel zuerst - geprueft wird die echte Zeile' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-kleinschreibung.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "deutsch steht 'Anderland', das Glossar sagt 'Testland'",
    "Alleinname 'Testland' steht auch in '700_modname'") -MustNotContain @('GREEN')

# Dieselben zwei Schreibweisen in der anderen Reihenfolge. War schon vorher rot (die klein
# geschriebene Zeile ist eine "andere"); steht hier, damit die Reihenfolge nichts entscheidet.
Test-Script 'glossar-pruefen: klein geschriebener Schluessel danach traegt den Namen unerlaubt' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-kleinschreibung-danach.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Alleinname 'Testland' steht auch in '700_modname'", 'Verstoesse: 2') -MustNotContain @('GREEN')

# Befund 3: derselbe Schluessel zweimal, die zweite Zeile mit ANDEREM Titel.
Test-Script 'glossar-pruefen: Schluessel des Alleinnamens zweimal mit anderem Titel wird rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-doppelt-anders.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    'der Schluessel steht 2-mal in der Sprachdatei') -MustNotContain @('GREEN')

# Befund 4: ein weiches Trennzeichen (U+00AD) im Namen. -cne sah darin keinen Unterschied.
Test-Script 'glossar-pruefen: weiches Trennzeichen im Alleinnamen wird rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-alleinname-trennzeichen.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Alleinname '700_modName'", "das Glossar sagt 'Testland'") -MustNotContain @('GREEN')

# Derselbe Fehler beim Festbegriff (stand nicht im Review): Kennung in anderer
# Schreibweise, und ein weiches Trennzeichen im Namen.
Test-Script 'glossar-pruefen: Kennung eines Festbegriffs in anderer Schreibweise gilt nicht' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-kennung-kleinschreibung.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Festbegriff 'pruefFeuer'", 'die Sprachdatei hat diesen Schluessel nicht') -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: weiches Trennzeichen im Festbegriff wird rot' 1 @{
    Glossar     = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei = (Join-Path $glossarDaten 'Localization-festbegriff-trennzeichen.csv')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Festbegriff 'pruefFeuer'", "das Glossar sagt 'Feuerstelle'") -MustNotContain @('GREEN')

# Befund 1: die Alleinnamen-Tabelle war freiwillig. Mit -PflichtAlleinname ist ein fehlender
# Name nicht pruefbar; vorhanden ist er gruen; zweimal im Glossar ist er nicht pruefbar.
Test-Script 'glossar-pruefen: Pflicht-Alleinname fehlt im Glossar - nicht pruefbar' 2 @{
    Glossar           = (Join-Path $glossarDaten 'glossar-gut.md')
    Sprachdatei       = (Join-Path $glossarDaten 'Localization-gut.csv')
    PflichtAlleinname = @('700_modName')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Pflicht-Alleinname '700_modName' 0-mal statt genau einmal") -MustNotContain @('GREEN')

Test-Script 'glossar-pruefen: Pflicht-Alleinname vorhanden ist gruen' 0 @{
    Glossar           = (Join-Path $glossarDaten 'glossar-alleinname.md')
    Sprachdatei       = (Join-Path $glossarDaten 'Localization-alleinname-gut.csv')
    PflichtAlleinname = @('700_modName')
} -Skript 'glossar-pruefen.ps1' -MustContain @('Alleinnamen: 1, Verstoesse: 0', 'GREEN')

Test-Script 'glossar-pruefen: Pflicht-Alleinname zweimal im Glossar - nicht pruefbar' 2 @{
    Glossar           = (Join-Path $glossarDaten 'glossar-alleinname-zweimal.md')
    Sprachdatei       = (Join-Path $glossarDaten 'Localization-alleinname-gut.csv')
    PflichtAlleinname = @('700_modName')
} -Skript 'glossar-pruefen.ps1' -MustContain @(
    "Pflicht-Alleinname '700_modName' 2-mal statt genau einmal") -MustNotContain @('GREEN')

# Befund 1, der eigentliche Fall: das Skript OHNE Parameter, so wie check-all.ps1 es ruft,
# gegen ein echtes Glossar, dem die Zeile fehlt. Das Skript rechnet Glossar und Sprachdatei
# aus seinem eigenen Ordner, darum ein nachgebauter Baum im Temp-Ordner: einmal mit
# unveraenderten Kopien (muss gruen sein, sonst bewiese das Rot nichts), einmal ohne die
# Zeile '700_modName' in Glossar UND Sprachdatei.
$probeBaum = Join-Path ([IO.Path]::GetTempPath()) ('mod700-glossarprobe-' + [Guid]::NewGuid().ToString('N'))
$ohneBom = New-Object System.Text.UTF8Encoding($false)
try {
    foreach ($probeFall in 'mit', 'ohne') {
        $probeWurzel = Join-Path $probeBaum $probeFall
        foreach ($ordner in 'tools\check', 'docs', 'mod\700_90_Sprache\Config') {
            New-Item -ItemType Directory -Force -Path (Join-Path $probeWurzel $ordner) | Out-Null
        }
        Copy-Item -LiteralPath (Join-Path $here 'glossar-pruefen.ps1') -Destination (Join-Path $probeWurzel 'tools\check\glossar-pruefen.ps1')
        $probeGlossar = [IO.File]::ReadAllLines((Join-Path $repoRoot 'docs\glossar.md'), [Text.Encoding]::UTF8)
        $probeCsv = [IO.File]::ReadAllLines((Join-Path $repoRoot 'mod\700_90_Sprache\Config\Localization.csv'), [Text.Encoding]::UTF8)
        if ($probeFall -eq 'ohne') {
            $probeGlossar = @($probeGlossar | Where-Object { $_ -notmatch '^\|\s*`700_modName`' })
            $probeCsv = @($probeCsv | Where-Object { $_ -notmatch '^700_modName,' })
        }
        [IO.File]::WriteAllLines((Join-Path $probeWurzel 'docs\glossar.md'), $probeGlossar, $ohneBom)
        [IO.File]::WriteAllLines((Join-Path $probeWurzel 'mod\700_90_Sprache\Config\Localization.csv'), $probeCsv, $ohneBom)
    }

    Test-Script 'glossar-pruefen ohne Parameter: echtes Glossar und echte Sprachdatei sind gruen' 0 @{
    } -FremdesSkript (Join-Path $probeBaum 'mit\tools\check\glossar-pruefen.ps1') -MustContain @(
        'Alleinnamen: 1, Verstoesse: 0', 'GREEN')

    Test-Script 'glossar-pruefen ohne Parameter: 700_modName fehlt in Glossar und Sprachdatei - nicht pruefbar' 2 @{
    } -FremdesSkript (Join-Path $probeBaum 'ohne\tools\check\glossar-pruefen.ps1') -MustContain @(
        "Pflicht-Alleinname '700_modName' 0-mal statt genau einmal") -MustNotContain @('GREEN')
}
finally {
    if (Test-Path -LiteralPath $probeBaum) { Remove-Item -LiteralPath $probeBaum -Recurse -Force }
}

# ------------------------------------------ sprachverweise-pruefen.ps1 (WP8.8, 2026-11-22)
# 'mod700check localization' prueft die FORM der Sprachdatei. Dass eine genannte Zeile fehlt
# oder eine geschriebene Zeile nie gelesen wird, sah bis WP8.8 niemand - sechs
# Beschreibungen standen in der Datei, und das Spiel las statt ihrer einen geerbten
# Schluessel. Jede Regel aus Vertrag 04 "Nachtrag WP8.8" hat hier ihren falschen Eingang.
# Alle Laeufe nehmen -Vanilla aus den Testdaten und brauchen keine Spielinstallation.
Write-Output ""
Write-Output "== Gegenproben: sprachverweise-pruefen haelt XML und Sprachdatei gegeneinander =="
$spracheDaten = Join-Path $data 'sprache'
$spracheVanilla = Join-Path $spracheDaten 'vanilla'
$spracheGutPatches = @(
    (Join-Path $spracheDaten 'gut\items.xml'),
    (Join-Path $spracheDaten 'gut\buffs.xml'),
    (Join-Path $spracheDaten 'gut\windows.xml'))

# (a) Der saubere Satz. Er traegt jede Form, die gruen sein MUSS: eigene Eigenschaft,
#     Vorgabe <Name>Desc, geerbter Schluessel mit Zeile in Vanilla, ein Patch, der den
#     Schluessel umsetzt, eine Zeile, die ueber eine ANDERE Eigenschaft gelesen wird
#     (pruefNotizDesc), ein leeres Attribut, eine Kommaliste, ein bedingter Block.
Test-Script 'sprachverweise: jeder Verweis hat eine Zeile, jede Zeile wird gelesen' 0 @{
    Patches     = $spracheGutPatches
    Sprachdatei = (Join-Path $spracheDaten 'gut\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'Patch-Dateien: 3, davon auf items.xml und blocks.xml angewandt: 1',
    'Patch-Operationen angewandt: 3, ohne Treffer: 0',
    'Definitionen: 5 Gegenstaende und 2 Bloecke in Vanilla; nach den Patches 8 und 2, davon eigene 3 und 0',
    'Beschreibungsschluessel von uns gesetzt: 3',
    'genannte Schluessel: 15 (in unserer Datei: 12, nur in Vanilla: 3, ohne Zeile: 0)',
    'Zeilen rueckwaerts geprueft: 15 (neu gegenueber Vanilla: 10, Beschreibungen von Gegenstaenden und Bloecken: 5), nicht gelesen: 0',
    'GREEN')

# (b) Regel 1. Dieselben Patch-Dateien, sieben Zeilen weniger - je eine fuer jede Art,
#     einen Schluessel zu nennen. Der Schluessel, den nur Vanilla hat, darf nicht auftauchen.
Test-Script 'sprachverweise: sieben genannte Schluessel ohne Zeile, jeder einzeln' 1 @{
    Patches     = $spracheGutPatches
    Sprachdatei = (Join-Path $spracheDaten 'ohne-zeile\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruef700_ding' hat keine Zeile",
    "Schluessel 'pruef700_dingText' hat keine Zeile",
    "Schluessel 'pruef700_lies' hat keine Zeile",
    "Schluessel 'pruef700_buffName' hat keine Zeile",
    "Schluessel 'pruef700_tipp' hat keine Zeile",
    "Schluessel 'pruef700_stufe' hat keine Zeile",
    "Schluessel 'pruef700_rohDesc' hat keine Zeile",
    "Beschreibung des eigenen Gegenstands 'pruef700_roh'",
    'ohne Zeile: 7',
    '== Ergebnis: 7 rot -> RED ==') -MustNotContain @("Schluessel 'pruefVanillaName'", "Schluessel 'pruefGruppeDesc'")

# (c) Regeln 2 bis 4. Vier tote Zeilen: der Gegenstand nennt einen anderen Schluessel, er
#     ERBT einen (das ist der Fall der sechs Bruchstuecke), ein Block erbt einen, und ein
#     neuer Schluessel, den nichts nennt. Zwei Zeilen daneben LEBEN und duerfen nicht rot
#     sein: die ueber PromptDescription gelesene und der Vorgabeschluessel.
Test-Script 'sprachverweise: vier Zeilen, die niemand liest - geerbter Schluessel inklusive' 1 @{
    Patches     = @(Join-Path $spracheDaten 'tot\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'tot\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Zeile 'pruef700_dingDesc' wird nicht gelesen: Gegenstand 'pruef700_ding' liest 'pruef700_dingText' (eigene Eigenschaft)",
    "Zeile 'pruefTeilDesc' wird nicht gelesen: Gegenstand 'pruefTeil' liest 'pruefGruppeDesc' (geerbt von 'pruefTeilEltern')",
    "Zeile 'pruefBlockKindDesc' wird nicht gelesen: Block 'pruefBlockKind' liest 'pruefBlockAltDesc' (geerbt von 'pruefBlock')",
    "Zeile 'pruefNirgendsName' wird nicht gelesen: Vanilla hat den Schluessel nicht",
    'nicht gelesen: 4',
    '== Ergebnis: 4 rot -> RED ==') -MustNotContain @("Zeile 'pruefNotizDesc'", "Zeile 'pruefDingDesc'")

# (d) Regel 5 (seit dem Review zu WP8.8): was sich nicht anwenden laesst, ist rot. Ein
#     bedingter Block, ein unbekanntes Element, ein XPath, der sich nicht auswerten laesst,
#     einer, der nichts trifft, und ein Gegenstand, der danach zwei Eigenschaften
#     DescriptionKey traegt. Ohne diese Regel waere der gerechnete Stand geraten.
Test-Script 'sprachverweise: was sich nicht anwenden laesst, ist rot - fuenf Faelle' 1 @{
    Patches     = @(Join-Path $spracheDaten 'nicht-anwendbar\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'nicht-anwendbar\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'bedingter Block in einer Datei, die diese Pruefung anwendet: <conditional>',
    'unbekannte Patch-Operation <verschiebe>',
    "XPath laesst sich nicht auswerten: <set xpath=""/items/item[@name='pruefDing'/property"">",
    "Patch trifft nichts: <setattribute xpath=""/items/item[@name='pruefGibtEsNicht']"">",
    "Gegenstand 'pruefNotiz' traegt nach den Patches 2 Eigenschaften DescriptionKey",
    'Patch-Operationen angewandt: 2, ohne Treffer: 1',
    '== Ergebnis: 5 rot -> RED ==')

# (e) Der XML-Adapter (Vertrag 04, viertes Review zu WP8.7). Attribute und Kindelemente
#     namens NodeType, LocalName, ChildNodes, Attributes, InnerText: wer den Aufbau ueber
#     Eigenschaften liest, ueberspringt die Definition und den <set> und sieht nichts.
Test-Script 'sprachverweise: Attribute und Kinder, die Knoten-Eigenschaften verdecken' 1 @{
    Patches     = @(Join-Path $spracheDaten 'adapter\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'adapter\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'Patch-Operationen angewandt: 2, ohne Treffer: 0',
    'Definitionen: 5 Gegenstaende und 2 Bloecke in Vanilla; nach den Patches 6 und 2, davon eigene 1 und 0',
    'Beschreibungsschluessel von uns gesetzt: 2',
    "Schluessel 'pruef700_adapter' hat keine Zeile",
    "Schluessel 'pruef700_adapterText' hat keine Zeile",
    "Schluessel 'pruef700_adapterLies' hat keine Zeile",
    '== Ergebnis: 3 rot -> RED ==')

# (e2) Seit dem 2026-11-23 (Plan-0002 WP1.5): eine Sandbox-Vorlage nennt ihren Anzeigenamen
#      in 'localized_name', und das endet nicht auf '_key'. Ohne die Regel dafuer stand die
#      Zeile des Namens als "wird nicht gelesen" da (so fiel es am echten Stand auf); mit
#      ihr ist sie gelesen, und fehlt sie, ist es ein genannter Schluessel ohne Zeile. Die
#      zweite Vorlage im Satz traegt das Attribut leer und darf nichts nennen.
Test-Script 'sprachverweise: der Anzeigename einer Sandbox-Vorlage ist ein gelesener Schluessel' 0 @{
    Patches     = @(Join-Path $spracheDaten 'vorlage\sandbox_overrides.xml')
    Sprachdatei = (Join-Path $spracheDaten 'vorlage\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'genannte Schluessel: 2 (in unserer Datei: 2, nur in Vanilla: 0, ohne Zeile: 0)',
    'nicht gelesen: 0',
    'GREEN') -MustNotContain @("Zeile 'pruef700_vorlage' wird nicht gelesen")

Test-Script 'sprachverweise: Anzeigename einer Sandbox-Vorlage ohne Zeile ist rot' 1 @{
    Patches     = @(Join-Path $spracheDaten 'vorlage\sandbox_overrides.xml')
    Sprachdatei = (Join-Path $spracheDaten 'vorlage\Localization-ohne-name.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruef700_vorlage' hat keine Zeile",
    'ohne Zeile: 1',
    '== Ergebnis: 1 rot -> RED ==')

# (e3) Seit dem 2026-11-23 (Plan-0002 WP5.5): der Anzeigename eines Wesens ist der Name seiner
#      Klasse (Entity::get_LocalizedEntityName). Ohne die Regel stand die Zeile der ersten
#      eigenen Klasse (ent700_spukhund) als "wird nicht gelesen" da. Mit ihr ist sie gelesen;
#      fehlt sie, ist es ein genannter Schluessel ohne Zeile - und eine Zeile fuer eine Klasse,
#      die es nicht mehr gibt, bleibt "nicht gelesen". Die Farbe nennt keinen Schluessel.
Test-Script 'sprachverweise: der Name einer eigenen Wesen-Klasse ist ein gelesener Schluessel' 0 @{
    Patches     = @(Join-Path $spracheDaten 'wesen\entityclasses.xml')
    Sprachdatei = (Join-Path $spracheDaten 'wesen\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'genannte Schluessel: 1 (in unserer Datei: 1, nur in Vanilla: 0, ohne Zeile: 0)',
    'nicht gelesen: 0',
    'GREEN') -MustNotContain @("Zeile 'pruef700_wesen' wird nicht gelesen", 'col700_pruef')

Test-Script 'sprachverweise: eigene Wesen-Klasse ohne Zeile ist rot, Zeile ohne Klasse auch' 1 @{
    Patches     = @(Join-Path $spracheDaten 'wesen\entityclasses.xml')
    Sprachdatei = (Join-Path $spracheDaten 'wesen\Localization-ohne-name.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruef700_wesen' hat keine Zeile",
    "Zeile 'pruef700_wesenAlt' wird nicht gelesen",
    '== Ergebnis: 2 rot -> RED ==')

# (e4) Seit dem 2026-11-23 (Plan-0002 WP10.5a): ein Aufsatz (<item_modifier>) heisst im Spiel,
#      wie sein Name als Schluessel nachgeschlagen wird - wie ein Gegenstand. Ohne die Regel
#      standen die Zeilen der Runen als "wird nicht gelesen" da.
Test-Script 'sprachverweise: der Name eines eigenen Aufsatzes ist ein gelesener Schluessel' 0 @{
    Patches     = @(Join-Path $spracheDaten 'aufsatz\item_modifiers.xml')
    Sprachdatei = (Join-Path $spracheDaten 'aufsatz\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'genannte Schluessel: 1 (in unserer Datei: 1, nur in Vanilla: 0, ohne Zeile: 0)',
    'nicht gelesen: 0',
    'GREEN') -MustNotContain @("Zeile 'pruef700_aufsatz' wird nicht gelesen")

Test-Script 'sprachverweise: eigener Aufsatz ohne Zeile ist rot, Zeile ohne Aufsatz auch' 1 @{
    Patches     = @(Join-Path $spracheDaten 'aufsatz\item_modifiers.xml')
    Sprachdatei = (Join-Path $spracheDaten 'aufsatz\Localization-ohne-name.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruef700_aufsatz' hat keine Zeile",
    "Zeile 'pruef700_aufsatzAlt' wird nicht gelesen",
    '== Ergebnis: 2 rot -> RED ==')

# (f) Regel 6: nichts gelesen ist nicht gruen. Sieben Eingaenge, jeder Ausgang 2.
Test-Script 'sprachverweise: Sprachdatei ohne Spalte Key ist nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'nicht-anwendbar\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'ohne-key\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @("hat keine Spalte 'Key'", 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: kein Schluessel genannt, keine Zeile unter den Regeln - nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'leer\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'adapter\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('keine Patch-Datei nennt einen Schluessel', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: Patch-Datei mit kaputtem XML ist nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'kaputt\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'nicht-anwendbar\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('laesst sich nicht als XML lesen', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: Vanilla-Ordner ohne Localization.csv ist nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'nicht-anwendbar\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'nicht-anwendbar\Localization.csv')
    Vanilla     = (Join-Path $data 'kette\vanilla')
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('Localization.csv fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: genannte Sprachdatei fehlt - nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'nicht-anwendbar\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'gibtesnicht.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('gibt es nicht', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: genannte Patch-Datei fehlt - nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'gibtesnicht.xml')
    Sprachdatei = (Join-Path $spracheDaten 'nicht-anwendbar\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('das ist keine Datei', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: ohne Spielpfad und ohne -Vanilla nicht pruefbar' 2 @{
    Patches     = @(Join-Path $spracheDaten 'nicht-anwendbar\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'nicht-anwendbar\Localization.csv')
} -Skript 'sprachverweise-pruefen.ps1' -OhneSpielpfad -MustContain @('SDTD_PATH ist nicht gesetzt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# ------------------------------------------ Review zu WP8.8 (2026-11-22), sechs Befunde
# Die erste Fassung ERKANNTE zwei Patch-Formen an ihrem Text; jetzt wendet das Skript die
# Patches fuer items.xml und blocks.xml an und liest das Ergebnis. Jeder der sechs Befunde
# hat hier seinen Eingang, und jeder war gegen die erste Fassung gruen oder Ausgang 1.

# (g) Befund 1: <prepend> und ein <remove>, dessen XPath das Wort DescriptionKey nicht
#     traegt. Der Prepend macht 'pruefTeilDesc' lebendig (darf nicht rot sein), der Remove
#     nimmt dem eigenen Erben die geerbte Beschreibung - seine Vorgabezeile fehlt.
Test-Script 'sprachverweise: prepend und remove ohne das Wort DescriptionKey werden gerechnet' 1 @{
    Patches     = @(Join-Path $spracheDaten 'verben\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'verben\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'Patch-Operationen angewandt: 3, ohne Treffer: 0',
    "Schluessel 'pruef700_erbeDesc' hat keine Zeile",
    "Beschreibung des eigenen Gegenstands 'pruef700_erbe'",
    'nicht gelesen: 0',
    '== Ergebnis: 1 rot -> RED ==') -MustNotContain @("Zeile 'pruefTeilDesc'")

# (h) Befund 2: ein <set> auf DescriptionKey/@value an einem Gegenstand, der die
#     Eigenschaft nur ERBT. Der XPath trifft nichts, und die Zeile liest niemand.
Test-Script 'sprachverweise: set auf einen geerbten DescriptionKey trifft nichts' 1 @{
    Patches     = @(Join-Path $spracheDaten 'set-ohne-treffer\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'set-ohne-treffer\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Patch trifft nichts: <set xpath=""/items/item[@name='pruef700_erbe']/property[@name='DescriptionKey']/@value"">",
    "Zeile 'pruef700_lies' wird nicht gelesen",
    'Beschreibungsschluessel von uns gesetzt: 0',
    '== Ergebnis: 2 rot -> RED ==')

# (i) Befund 3: ein Schluessel, den ein Patch nennt und der naechste ueberschreibt, und eine
#     Eigenschaft gleichen Werts in einer ANDEREN Datei. Beides liest nichts.
Test-Script 'sprachverweise: genannt ist nicht gelesen - ueberschrieben, und fremde Eigenschaft' 1 @{
    Patches     = @((Join-Path $spracheDaten 'ueberschrieben\items.xml'), (Join-Path $spracheDaten 'ueberschrieben\buffs.xml'))
    Sprachdatei = (Join-Path $spracheDaten 'ueberschrieben\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Zeile 'pruef700_lies' wird nicht gelesen: Vanilla hat den Schluessel nicht",
    "Zeile 'pruefTeilDesc' wird nicht gelesen: Gegenstand 'pruefTeil' liest 'pruefGruppeDesc' (geerbt von 'pruefTeilEltern')",
    'Patch-Operationen angewandt: 2, ohne Treffer: 0',
    '== Ergebnis: 2 rot -> RED ==')

# (j) Befund 4: der Wert eines DescriptionKey ist EIN Schluessel - im gepatchten Stand und
#     in einer Datei, in der die Nennung zaehlt. Beide Teile haben je eine Zeile in Vanilla.
Test-Script 'sprachverweise: DescriptionKey mit Komma ist ein Schluessel, nicht zwei' 1 @{
    Patches     = @((Join-Path $spracheDaten 'komma\items.xml'), (Join-Path $spracheDaten 'komma\buffs.xml'))
    Sprachdatei = (Join-Path $spracheDaten 'adapter\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruefLies,pruefGruppeDesc' hat keine Zeile",
    "Schluessel 'pruefLies,pruefDingDesc' hat keine Zeile",
    # Seit WP10.5a (Regel fuer <item_modifier> @name) nennt der Aufsatz in komma/buffs.xml
    # auch seinen eigenen Namen; die Pruefdaten haben fuer ihn keine Zeile - ein dritter,
    # richtiger Befund.
    "Schluessel 'pruef700_mod' hat keine Zeile",
    '== Ergebnis: 3 rot -> RED ==')

# (k) Befund 5: jede Vanilla-Datei fuer sich. Eine leere blocks.xml und eine mit falscher
#     Wurzel - mit dem sauberen Satz, der gegen die echte Testvorlage gruen ist.
Test-Script 'sprachverweise: Vanillas blocks.xml ohne Block ist nicht pruefbar' 2 @{
    Patches     = $spracheGutPatches
    Sprachdatei = (Join-Path $spracheDaten 'gut\Localization.csv')
    Vanilla     = (Join-Path $spracheDaten 'vanilla-leer')
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('steht kein einziges <block> mit Namen', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'sprachverweise: Vanillas blocks.xml mit falscher Wurzel ist nicht pruefbar' 2 @{
    Patches     = $spracheGutPatches
    Sprachdatei = (Join-Path $spracheDaten 'gut\Localization.csv')
    Vanilla     = (Join-Path $spracheDaten 'vanilla-falsch')
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @('hat die Wurzel <items>, erwartet ist <blocks>', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (l) Befund 6: ein Pfad mit Zeichen, die kein Pfad haben darf. Test-Path wirft dabei; das
#     ist "gibt es nicht" und Ausgang 2, nicht Ausgang 1. Die Laeufe verlangen die Meldung
#     der Stelle, die den Pfad prueft: Ausgang 2 allein gaebe auch das Netz dahinter (der
#     trap fuer jeden unerwarteten Fehler), und dann stuende in der Ausgabe eine Ausnahme
#     statt des Pfads. Der Vanilla-Lauf war schon gegen die erste Fassung Ausgang 2; er
#     haelt den Stand.
Test-Script 'sprachverweise: Sprachdatei-Pfad mit unzulaessigem Zeichen ist nicht pruefbar' 2 @{
    Patches     = $spracheGutPatches
    Sprachdatei = 'C:\invalid<file>'
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @("die Sprachdatei 'C:\invalid<file>' gibt es nicht", 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'unerwarteter Fehler')

Test-Script 'sprachverweise: Patch-Pfad mit unzulaessigem Zeichen ist nicht pruefbar' 2 @{
    Patches     = @('C:\invalid<file>')
    Sprachdatei = (Join-Path $spracheDaten 'gut\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @("-Patches nennt 'C:\invalid<file>', und das ist keine Datei", 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'unerwarteter Fehler')

Test-Script 'sprachverweise: Vanilla-Pfad mit unzulaessigem Zeichen ist nicht pruefbar' 2 @{
    Patches     = $spracheGutPatches
    Sprachdatei = (Join-Path $spracheDaten 'gut\Localization.csv')
    Vanilla     = 'C:\invalid<ordner>'
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @("den Vanilla-Ordner 'C:\invalid<ordner>' gibt es nicht", 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'unerwarteter Fehler')

# --------------------------------- zweites Review zu WP8.8 (2026-11-22), zwei Befunde
# Beide Luecken hat der Umbau oben geoeffnet; gegen a60fe9b sind alle drei Laeufe gruen.

# (m) Befund 1: ein <remove>, dessen XPath ein Attribut trifft. Das Spiel lehnt das ab; das
#     Skript entfernte das Attribut und zaehlte die Operation als angewandt.
Test-Script 'sprachverweise: remove auf ein Attribut wird nicht gerechnet' 1 @{
    Patches     = @(Join-Path $spracheDaten 'remove-attribut\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'remove-attribut\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Patch laesst sich nicht rechnen: <remove xpath=""/items/item[@name='pruefNotiz']/property[@name='DescriptionKey']/@value""> trifft ein Attribut; das Spiel lehnt das ab",
    'Patch-Operationen angewandt: 0, ohne Treffer: 0, nicht gerechnet: 1',
    '== Ergebnis: 1 rot -> RED ==')

# (n) Dieselbe Klasse: fuenf weitere Paare aus Operation und Knotenart, an denen das Skript
#     nichts tat und "angewandt" zaehlte, ein Treffer auf einen Kommentar, und ein XPath
#     mit zwei Treffern, von denen nur der zweite nicht rechenbar ist: die ganze Operation
#     bleibt weg, der Gegenstand pruefTeil also da (5 Gegenstaende nach den Patches).
Test-Script 'sprachverweise: Treffer der falschen Knotenart sind rot - sieben Faelle' 1 @{
    Patches     = @(Join-Path $spracheDaten 'knotenart\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'remove-attribut\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    '<setattribute> rechnet diese Pruefung nur auf einem Element',
    '<removeattribute> rechnet diese Pruefung nur auf einem Element',
    '<insertAfter> rechnet diese Pruefung nur auf einem Element',
    '<insertBefore> rechnet diese Pruefung nur auf einem Element',
    '<csv> rechnet diese Pruefung nur auf einem Attribut',
    'trifft einen Knoten der Art Comment',
    "<remove xpath=""/items/item[@name='pruefTeil'] | /items/item[@name='pruefDing']/@name""> trifft ein Attribut",
    'nach den Patches 5 und 2, davon eigene 0 und 0',
    'Patch-Operationen angewandt: 0, ohne Treffer: 0, nicht gerechnet: 7',
    '== Ergebnis: 7 rot -> RED ==')

# (o) Befund 2: drei Vanilla-Gegenstaende verschwinden - entfernt, umbenannt, und entfernt
#     mit einem anderen Leser. Die ersten zwei Zeilen <Name>Desc sind tot; die dritte liest
#     ein eigener Gegenstand und darf nicht rot sein.
Test-Script 'sprachverweise: Beschreibung eines entfernten oder umbenannten Gegenstands ist rot' 1 @{
    Patches     = @(Join-Path $spracheDaten 'entfernt\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'entfernt\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Zeile 'pruefTeilDesc' wird nicht gelesen: Gegenstand 'pruefTeil' steht in Vanilla und nach den Patches nicht mehr",
    "Zeile 'pruefDingDesc' wird nicht gelesen: Gegenstand 'pruefDing' steht in Vanilla und nach den Patches nicht mehr",
    'nach den Patches 4 und 2, davon eigene 2 und 0',
    'Beschreibungen von Gegenstaenden und Bloecken: 4), nicht gelesen: 2',
    '== Ergebnis: 2 rot -> RED ==') -MustNotContain @("Zeile 'pruefNotizDesc'")

# --------------------------------- drittes Review zu WP8.8 (2026-11-22), drei Befunde
# Eine zweite Vanilla-Vorlage: die Gruppenbeschreibung der Bloecke heisst dort wie die
# Vorgabezeile eines Gegenstands, und ein Block hat keine Zeile fuer seinen Schluessel.
$spracheGruppe = Join-Path $spracheDaten 'vanilla-gruppe'

# (p) Befund 1: der Gegenstand verschwindet, seine Zeile liest weiter ein Block - als
#     Gruppenbeschreibung. Gegen 387761b ist dieser Lauf Ausgang 1 (falsches Rot).
Test-Script 'sprachverweise: die Gruppenbeschreibung der Bloecke zaehlt als gelesen' 0 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'gruppe\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Gruppenbeschreibung der Bloecke: 'pruefNotizDesc'; Bloecke ohne eigene Zeile, die sie lesen: 1",
    'Beschreibungen von Gegenstaenden und Bloecken: 1), nicht gelesen: 0',
    '== Ergebnis: 0 rot -> GREEN ==')

# (q) ... aber nur, solange ein Block auf sie zurueckfaellt. Ist der einzige solche Block
#     weg, liest die Zeile niemand.
Test-Script 'sprachverweise: Gruppenbeschreibung ohne einen Block, der sie liest, ist nicht gelesen' 1 @{
    Patches     = @((Join-Path $spracheDaten 'gruppe\items.xml'), (Join-Path $spracheDaten 'gruppe\ungelesen\blocks.xml'))
    Sprachdatei = (Join-Path $spracheDaten 'gruppe\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Gruppenbeschreibung der Bloecke: 'pruefNotizDesc'; Bloecke ohne eigene Zeile, die sie lesen: 0",
    "Zeile 'pruefNotizDesc' wird nicht gelesen: Gegenstand 'pruefNotiz' steht in Vanilla und nach den Patches nicht mehr",
    '== Ergebnis: 1 rot -> RED ==')

# (r) Regel 1: setzen WIR die Gruppenbeschreibung, braucht ihr Schluessel eine Zeile - mit
#     Zeile gruen (und gelesen), ohne Zeile rot.
Test-Script 'sprachverweise: eine von uns gesetzte Gruppenbeschreibung mit Zeile ist gruen' 0 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe-gesetzt\blocks.xml')
    Sprachdatei = (Join-Path $spracheDaten 'gruppe-gesetzt\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Gruppenbeschreibung der Bloecke: 'pruef700_gruppe'; Bloecke ohne eigene Zeile, die sie lesen: 1",
    'genannte Schluessel: 1 (in unserer Datei: 1, nur in Vanilla: 0, ohne Zeile: 0)',
    'Zeilen rueckwaerts geprueft: 1 (neu gegenueber Vanilla: 1, Beschreibungen von Gegenstaenden und Bloecken: 0), nicht gelesen: 0',
    '== Ergebnis: 0 rot -> GREEN ==')

Test-Script 'sprachverweise: eine von uns gesetzte Gruppenbeschreibung ohne Zeile ist rot' 1 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe-gesetzt\blocks.xml')
    Sprachdatei = (Join-Path $spracheDaten 'block-entfernt\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruef700_gruppe' hat keine Zeile, weder in unserer Sprachdatei noch in Vanilla  (defaultDescriptionKey an <blocks>, gepatchter Stand)",
    '== Ergebnis: 1 rot -> RED ==')

# (s) Befund 3: ein entfernter Vanilla-BLOCK. Der Lauf (o) oben prueft nur Gegenstaende;
#     der Zweig fuer Bloecke konnte wegfallen, ohne dass ein Lauf rot wurde.
Test-Script 'sprachverweise: Beschreibung eines entfernten Blocks ist rot' 1 @{
    Patches     = @(Join-Path $spracheDaten 'block-entfernt\blocks.xml')
    Sprachdatei = (Join-Path $spracheDaten 'block-entfernt\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Zeile 'pruefBlockWegDesc' wird nicht gelesen: Block 'pruefBlockWeg' steht in Vanilla und nach den Patches nicht mehr",
    'nach den Patches 2 und 2, davon eigene 0 und 0',
    '== Ergebnis: 1 rot -> RED ==')

# (t) Befund 2: die Namespace-Achse liefert ein Attribut ohne Element. Die Operation
#     zaehlte als angewandt und aenderte nichts.
Test-Script 'sprachverweise: Attributtreffer ohne Element (Namespace-Achse) wird nicht gerechnet' 1 @{
    Patches     = @(Join-Path $spracheDaten 'namespace\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'remove-attribut\Localization.csv')
    Vanilla     = $spracheVanilla
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    'Patch laesst sich nicht rechnen: <set xpath="/items/namespace::xml"> trifft ein Attribut, das zu keinem Element gehoert',
    'Patch-Operationen angewandt: 0, ohne Treffer: 0, nicht gerechnet: 1',
    '== Ergebnis: 1 rot -> RED ==')

# --------------------------------- viertes Review zu WP8.8 (2026-11-22), vier Befunde

# (u) Befund 1: die Gruppenbeschreibung wird geleert - einmal bleibt das Attribut leer
#     stehen, einmal wird es entfernt. Gegen c353996 sind beide Laeufe Ausgang 0: die
#     Pruefung dazu hing an "Wert nicht leer".
Test-Script 'sprachverweise: eine geleerte Gruppenbeschreibung ist rot' 1 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe-leer\blocks.xml')
    Sprachdatei = (Join-Path $spracheDaten 'block-entfernt\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "die Gruppenbeschreibung der Bloecke (defaultDescriptionKey an <blocks>) ist nach den Patches leer, in Vanilla heisst sie 'pruefNotizDesc'; Bloecke ohne eigene Zeile, die auf sie zurueckfielen: 1",
    '== Ergebnis: 1 rot -> RED ==')

Test-Script 'sprachverweise: eine entfernte Gruppenbeschreibung ist rot' 1 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe-leer\entfernt\blocks.xml')
    Sprachdatei = (Join-Path $spracheDaten 'block-entfernt\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "ist nach den Patches leer, in Vanilla heisst sie 'pruefNotizDesc'; Bloecke ohne eigene Zeile, die auf sie zurueckfielen: 1",
    '== Ergebnis: 1 rot -> RED ==')

# (v) Befund 3: eine Blockzeile, die nur UNSERE Sprachdatei hat. Der Block faellt dann
#     nicht auf die Gruppenbeschreibung zurueck, und deren Zeile liest niemand. Ohne die
#     Abfrage unserer Datei blieben vorher alle Gegenproben gruen.
Test-Script 'sprachverweise: eine Blockzeile nur in unserer Datei verhindert den Rueckfall' 1 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe\items.xml')
    Sprachdatei = (Join-Path $spracheDaten 'gruppe\eigene-zeile\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Gruppenbeschreibung der Bloecke: 'pruefNotizDesc'; Bloecke ohne eigene Zeile, die sie lesen: 0",
    "Zeile 'pruefNotizDesc' wird nicht gelesen",
    'Beschreibungen von Gegenstaenden und Bloecken: 2), nicht gelesen: 1',
    '== Ergebnis: 1 rot -> RED ==')

# (w) Befund 2: die Meldung zu einer ungelesenen Blockzeile nennt, was der Block wirklich
#     liest - die Gruppenbeschreibung, wenn sein Schluessel keine Zeile hat.
Test-Script 'sprachverweise: die Meldung nennt die Gruppenbeschreibung, wenn der Block auf sie zurueckfaellt' 1 @{
    Patches     = @(Join-Path $spracheDaten 'gruppe-meldung\blocks.xml')
    Sprachdatei = (Join-Path $spracheDaten 'block-entfernt\Localization.csv')
    Vanilla     = $spracheGruppe
} -Skript 'sprachverweise-pruefen.ps1' -MustContain @(
    "Schluessel 'pruef700_fehlt' hat keine Zeile",
    "Zeile 'pruefBlockWegDesc' wird nicht gelesen: Block 'pruefBlockWeg' liest die Gruppenbeschreibung 'pruefNotizDesc' - sein Schluessel 'pruef700_fehlt' (eigene Eigenschaft) hat keine Zeile",
    "Gruppenbeschreibung der Bloecke: 'pruefNotizDesc'; Bloecke ohne eigene Zeile, die sie lesen: 2",
    '== Ergebnis: 2 rot -> RED ==')

# ------------------------------------------ vertraeglichkeit-pruefen.ps1 (WP8.9, 2026-11-22)
# Rechnet unsere Modlets und EINE fremde Mod in vier Staenden durch (wir allein, die fremde
# allein, wir dann fremd, fremd dann wir) und meldet, wo sie einander in derselben Datei
# treffen. Jede Befundklasse aus Vertrag 04 "Nachtrag WP8.9" hat hier ihren Eingang, und
# jeder Ausfall seinen. Die Testdaten sind erfundene Fenster und erfundene Mods.
# -Vanilla kommt aus den Testdaten; die Laeufe mit einem bedingten Block brauchen die
# NCalc.dll des Spiels und damit SDTD_PATH - wie die bedingten Laeufe von kette-pruefen.
Write-Output ""
Write-Output "== Gegenproben: vertraeglichkeit-pruefen rechnet unsere Modlets gegen eine fremde Mod =="
$vertDaten = Join-Path $data 'vertraeglich'
$vertVanilla = Join-Path $vertDaten 'vanilla'
$vertUnsere = @((Join-Path $vertDaten 'unsere\700_10_Pruef'), (Join-Path $vertDaten 'unsere\700_20_Pruef'))
$vertSkript = 'vertraeglichkeit-pruefen.ps1'

# (a) Der saubere Satz: dieselben zwei Dateien, andere Knoten. Die fremde Datei traegt einen
#     anderen Wurzelknoten als <config>, Attribute, die wie Eigenschaften des XML-Adapters
#     heissen, und einen Zweig, dessen Bedingung falsch ist - nichts davon ist ein Befund.
Test-Script 'vertraeglichkeit: dieselben Dateien, andere Knoten - gruen' 0 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sauber')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "unsere 2 Modlets und 'PruefSauber' (Ordner fremd-sauber)",
    'XML-Dateien der fremden Mod unter Config: 2 (mit Vanilla-Gegenstueck: 2, ohne: 0)',
    'gemeinsame Dateien: 2',
    'erwartete Reihenfolge: wir, dann die fremde Mod',
    'Operationen der fremden Mod allein: 2, davon ohne Treffer: 0',
    'unsere Operationen allein, in den gemeinsamen Dateien: 3, davon ohne Treffer: 0',
    'unsere Schluessel: 2 aus 1 Dateien, die der fremden Mod: 1, gemeinsam: 0',
    "'PruefSauber': 0 Befunde (Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 0, nicht gerechnet 0, gemeinsamer Sprachschluessel 0) -> GREEN",
    '== Ergebnis: 0 Befunde -> GREEN ==')

# (b) Ziel verloren, erwartete Reihenfolge: unser Modlet entfernt das Etikett, das die
#     fremde Mod danach setzen will. Umgekehrt ist es dieselbe Stelle als veraenderte Wirkung.
Test-Script 'vertraeglichkeit: wir nehmen der fremden Mod ihr Ziel' 1 @{
    Unsere  = @((Join-Path $vertDaten 'unsere\700_10_Pruef'), (Join-Path $vertDaten 'unsere-entfernt\700_30_Pruef'))
    Fremd   = @(Join-Path $vertDaten 'fremd-sauber')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "[wir, dann die fremde Mod, erwartet] PruefSauber <setattribute xpath=""/windows/window[@name='pruefFensterC']/label[@name='titel']"" name=""text""> trifft allein 1 Knoten, hier keinen  (XUi_InGame\windows.xml)",
    "[die fremde Mod, dann wir, umgekehrt] PruefSauber <setattribute",
    "Attribut 'text' an <label name=""titel""> ist entfernt - zuerst nach 700_30_Pruef <remove xpath=""/windows/window[@name='pruefFensterC']/label[@name='titel']"">",
    'Ziel verloren 1, Zweig wechselt 0, Wirkung veraendert 1, nicht gerechnet 0',
    '== Ergebnis: 2 Befunde -> RED ==')

# (c) Dasselbe von der anderen Seite: die fremde Mod entfernt das Fenster, an dem wir ein
#     Attribut setzen. Erwartet: unsere Wirkung ist weg. Umgekehrt: unser Patch trifft nichts.
Test-Script 'vertraeglichkeit: die fremde Mod nimmt uns das Ziel' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-ziel')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "[die fremde Mod, dann wir, umgekehrt] 700_10_Pruef <setattribute xpath=""/windows/window[@name='pruefFensterA']/rect[@name='content']/grid[@name='inventory']"" name=""cols""> trifft allein 1 Knoten, hier keinen",
    "[wir, dann die fremde Mod, erwartet] 700_10_Pruef <setattribute",
    "Attribut 'cols' an <grid name=""inventory""> ist entfernt - zuerst nach PruefZiel <remove xpath=""/windows/window[@name='pruefFensterA']"">",
    'Ziel verloren 1, Zweig wechselt 0, Wirkung veraendert 1, nicht gerechnet 0',
    '== Ergebnis: 2 Befunde -> RED ==')

# (d) Wirkung veraendert: derselbe Stil-Eintrag (beide Reihenfolgen) und ein breiter Pfad,
#     der auch das von uns eingefuegte Element trifft (nur, wenn die fremde Mod nach uns laedt).
Test-Script 'vertraeglichkeit: derselbe Wert und ein Pfad, der unser Element mittrifft' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-wert')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "[wir, dann die fremde Mod, erwartet] 700_20_Pruef <setattribute xpath=""/styles/global/style_entry[@name='pruefFarbeEins']"" name=""value"">: Attribut 'value' an <style_entry name=""pruefFarbeEins"">: gesetzt '7,7,7', jetzt '9,9,9' - zuerst nach PruefWert",
    "[die fremde Mod, dann wir, umgekehrt] PruefWert <setattribute xpath=""/styles/global/style_entry[@name='pruefFarbeEins']"" name=""value"">: Attribut 'value' an <style_entry name=""pruefFarbeEins"">: gesetzt '9,9,9', jetzt '7,7,7' - zuerst nach 700_20_Pruef",
    "[wir, dann die fremde Mod, erwartet] 700_10_Pruef <append xpath=""/windows/window[@name='pruefFensterB']"">: eingefuegtes Element <label name=""700_pruefZusatz""> ist geaendert - zuerst nach PruefWert <setattribute xpath=""//window[@name='pruefFensterB']//label[@color='[white]']"" name=""color"">",
    'Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 3, nicht gerechnet 0',
    '== Ergebnis: 3 Befunde -> RED ==')

# (e) Zweig wechselt: die fremde Mod fragt mod_loaded nach unserem Modlet (beide Zweige
#     wechseln, in beiden Reihenfolgen), und sie entfernt den Eintrag, nach dem unsere
#     Bedingung mit xpath(...) fragt (unser Zweig laeuft dann nicht mehr).
Test-Script 'vertraeglichkeit: Bedingungen fallen in der Kombination anders aus' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-zweig')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "[die fremde Mod, dann wir, umgekehrt] 700_20_Pruef <if cond=""xpath('/styles/global/style_entry[@name=""pruefFarbeEins""]') != null""> mit 1 Operationen laeuft allein, hier nicht  (XUi_Common\styles.xml)",
    "[wir, dann die fremde Mod, erwartet] PruefZweig <if cond=""mod_loaded('700_10_Pruef')""> mit 1 Operationen laeuft allein nicht, hier schon",
    "[wir, dann die fremde Mod, erwartet] PruefZweig <else> mit 1 Operationen laeuft allein, hier nicht",
    "[die fremde Mod, dann wir, umgekehrt] PruefZweig <else> mit 1 Operationen laeuft allein, hier nicht",
    "Attribut 'value' an <style_entry name=""pruefFarbeEins""> ist entfernt - zuerst nach PruefZweig <remove",
    'Ziel verloren 0, Zweig wechselt 5, Wirkung veraendert 1, nicht gerechnet 0',
    '== Ergebnis: 6 Befunde -> RED ==')

# (f) Nicht gerechnet: zehn Stellen, jede einmal gemeldet, mit den drei Staenden, in denen
#     die fremde Datei laeuft. Keine der zehn darf den Stand aendern - die letzte Operation
#     der Datei trifft nur, wenn das Fenster noch da ist.
Test-Script 'vertraeglichkeit: zehn Stellen, die nicht gerechnet werden' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-nicht')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'trifft ein Attribut; das Spiel lehnt das ab ("use removeattribute instead")',
    'unbekannte Patch-Operation <sett>',
    '<include> wird nicht gerechnet',
    'XPath laesst sich nicht auswerten: <set xpath="/windows/window[">',
    '<set> ohne xpath',
    'Bedingung "game_version() != null": sie laesst sich nicht auswerten',
    'sie liefert keinen Wahrheitswert, sondern String',
    'bedingter Block mit dem Kind <elseif>; erlaubt sind <if cond=...> und <else>',
    "bedingter Block mit einem <if> ohne 'cond'",
    "Bedingung ""mod_loaded('PruefNichtDa') and"": NCalc kann sie nicht lesen",
    'Stand: die fremde Mod allein; wir, dann die fremde Mod; die fremde Mod, dann wir',
    'Operationen der fremden Mod allein: 1, davon ohne Treffer: 0',
    'Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 0, nicht gerechnet 10, gemeinsamer Sprachschluessel 0',
    '== Ergebnis: 10 Befunde -> RED ==') -MustNotContain @('GREEN')

# (g) Kein Befund, aber genannt: eine Datei ohne Vanilla-Gegenstueck und eine Operation, die
#     schon allein nichts trifft. Von zwei wahren <if> gewinnt das erste.
Test-Script 'vertraeglichkeit: allein ohne Treffer und ohne Gegenstueck ist genannt, kein Befund' 0 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-ohne')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'XML-Dateien der fremden Mod unter Config: 2 (mit Vanilla-Gegenstueck: 1, ohne: 1)',
    'ohne Vanilla-Gegenstueck, das Spiel laedt daraus nichts: XUi\windows.xml',
    'Operationen der fremden Mod allein: 3, davon ohne Treffer: 2',
    "trifft allein nichts: <setattribute xpath=""/windows/window[@name='pruefGibtEsAuchNicht']"" name=""pos"">  (XUi_InGame\windows.xml)",
    "trifft allein nichts: <setattribute xpath=""/windows/window[@name='pruefGibtEsNicht']"" name=""pos"">  (XUi_InGame\windows.xml)",
    '== Ergebnis: 0 Befunde -> GREEN ==')

# (h) Gemeinsamer Sprachschluessel - und keine gemeinsame XML-Datei. Die Spalte heisst in der
#     fremden Datei 'KEY'.
Test-Script 'vertraeglichkeit: ein Sprachschluessel steht in beiden Sprachdateien' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sprache')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'gemeinsame Dateien: 0',
    'unsere Schluessel: 2 aus 1 Dateien, die der fremden Mod: 2, gemeinsam: 1',
    'Keine gemeinsame XML-Datei',
    "'pruefGemeinsam' steht in unserer Sprachdatei und in der von PruefSprache",
    'nicht gerechnet 0, gemeinsamer Sprachschluessel 1) -> RED',
    '== Ergebnis: 1 Befunde -> RED ==') -MustNotContain @("'pruefNurFremd' steht")

# (i) Eine fremde Sprachdatei ohne Spalte 'Key' ist "nicht gerechnet", nicht "kein gemeinsamer".
Test-Script 'vertraeglichkeit: fremde Sprachdatei ohne Schluesselspalte ist nicht gerechnet' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sprache-kaputt')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "PruefSpracheKaputt: die Sprachdatei laesst sich nicht lesen (keine Spalte 'Key'); gemeinsame Schluessel sind nicht verglichen",
    'nicht gerechnet 1, gemeinsamer Sprachschluessel 0) -> RED') -MustNotContain @('GREEN')

# (i2) Zweites Review der Vorpruefung, Befund 1 (behoben im Nachtlauf vom 2026-11-22): eine
#      fremde Sprachdatei, aus der Import-Csv keine einzige Zeile liest - hier nur ein
#      Anfuehrungszeichen -, galt als "0 Schluessel" und ging gruen durch. Ohne Kopfzeile
#      mit 'Key' ist sie nicht gerechnet.
Test-Script 'vertraeglichkeit: fremde Sprachdatei aus einem Anfuehrungszeichen ist nicht gerechnet' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sprache-zeichen')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "PruefSpracheZeichen: die Sprachdatei laesst sich nicht lesen (keine Datenzeile und keine Spalte 'Key' in der Kopfzeile)",
    'nicht gerechnet 1, gemeinsamer Sprachschluessel 0) -> RED') -MustNotContain @('GREEN')

# (i3) Die Gegenrichtung: nur die Kopfzeile, mit 'Key'. Das ist eine leere, aber heile
#      Sprachdatei - 0 Schluessel, kein Befund.
Test-Script 'vertraeglichkeit: fremde Sprachdatei nur mit Kopfzeile ist leer und gruen' 0 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sprache-kopf')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'die der fremden Mod: 0, gemeinsam: 0',
    '== Ergebnis: 0 Befunde -> GREEN ==') -MustNotContain @('laesst sich nicht lesen')

# (i4) Zweites Review der Vorpruefung, Befund 2 (behoben im Nachtlauf vom 2026-11-22): alle
#      Operationen der fremden Mod stehen in einem Block, der nur mit uns zusammen laeuft.
#      Allein laeuft keine - das war "keine einzige Patch-Operation", Exit 2, und die
#      Befunde der Kombination gingen verloren.
Test-Script 'vertraeglichkeit: fremde Mod laeuft nur mit uns - die Befunde der Kombination bleiben' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-nur-mit-uns')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'Operationen der fremden Mod allein: 0, davon ohne Treffer: 0',
    'allein laeuft keine Operation der fremden Mod, in der Kombination laufen 1',
    "PruefNurMitUns <if cond=""mod_loaded('700_10_Pruef')""> mit 1 Operationen laeuft allein nicht, hier schon",
    'Zweig wechselt 2,') -MustNotContain @('NICHT GEPRUEFT', 'GREEN')

# (j) Keine gemeinsame Datei ist ein Ergebnis, kein Ausfall (Regel 7).
Test-Script 'vertraeglichkeit: keine gemeinsame Datei ist gruen und sagt es' 0 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-getrennt')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'gemeinsame Dateien: 0',
    'Keine gemeinsame XML-Datei: die Patches der beiden Seiten koennen einander in keiner Datei treffen.',
    'die fremde Mod hat keine Config\Localization.csv',
    '== Ergebnis: 0 Befunde -> GREEN ==')

# (k) bis (m) Regel 3: die erwartete Reihenfolge kommt aus den Ordnernamen.
Test-Script 'vertraeglichkeit: ein Ordner, der vor unseren sortiert, laedt zuerst' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten '000_fremd-davor')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'erwartete Reihenfolge: die fremde Mod, dann wir',
    '[die fremde Mod, dann wir, erwartet] PruefDavor <setattribute',
    '[wir, dann die fremde Mod, umgekehrt] 700_20_Pruef <setattribute',
    '== Ergebnis: 2 Befunde -> RED ==')

Test-Script 'vertraeglichkeit: ein Ordner zwischen unseren Modlets - keine Reihenfolge erwartet' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten '700_15_fremd-zwischen')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'erwartete Reihenfolge: keine - die fremde Mod laege zwischen unseren Modlets',
    '[wir, dann die fremde Mod] 700_20_Pruef <setattribute',
    '[die fremde Mod, dann wir] PruefZwischen <setattribute') -MustNotContain @('erwartet]', 'umgekehrt]')

Test-Script 'vertraeglichkeit: Zeichen- und Sprachvergleich sortieren verschieden - keine Reihenfolge erwartet' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten '_fremd-unklar')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'erwartete Reihenfolge: keine - die Ordnernamen sortieren nicht eindeutig',
    '[wir, dann die fremde Mod] 700_20_Pruef <setattribute') -MustNotContain @('erwartet]', 'umgekehrt]')

# (n) Zwei fremde Mods in einem Aufruf: jede fuer sich gerechnet, der schlechteste Ausgang gilt.
Test-Script 'vertraeglichkeit: zwei fremde Mods, jede fuer sich' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @((Join-Path $vertDaten 'fremd-wert'), (Join-Path $vertDaten 'fremd-sauber'))
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    "'PruefSauber': 0 Befunde (Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 0, nicht gerechnet 0, gemeinsamer Sprachschluessel 0) -> GREEN",
    "'PruefWert': 3 Befunde (Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 3, nicht gerechnet 0, gemeinsamer Sprachschluessel 0) -> RED",
    '== Ergebnis: 3 Befunde -> RED ==')

# (n2) Jede Schreibart, die verfolgt wird: set und append auf ein Attribut, csv, set auf den
#      Text eines Elements, prepend, insertAfter, insertBefore. Dieselbe Stelle zweimal
#      geschrieben zaehlt einmal, mit der letzten Operation; was wir selbst wieder entfernen,
#      ist keine Spur. Der breite Pfad der fremden Mod trifft allein nichts - das ist genannt
#      und kein "Ziel verloren". Umgekehrt nimmt ihr removeattribute unserem append das Ziel.
Test-Script 'vertraeglichkeit: jede verfolgte Schreibart, jede einmal veraendert' 1 @{
    Unsere  = @((Join-Path $vertDaten 'unsere\700_10_Pruef'), (Join-Path $vertDaten 'unsere-arten\700_40_Pruef'))
    Fremd   = @(Join-Path $vertDaten 'fremd-arten')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'Operationen der fremden Mod allein: 5, davon ohne Treffer: 1',
    'unsere Operationen allein, in den gemeinsamen Dateien: 12, davon ohne Treffer: 0',
    "[wir, dann die fremde Mod, erwartet] 700_40_Pruef <set xpath=""/windows/window[@name='pruefFensterD']/@pos"">: Attribut 'pos' an <window name=""pruefFensterD"">: gesetzt '7,7', jetzt '9,9' - zuerst nach PruefArten <setattribute",
    "700_40_Pruef <csv xpath=""/windows/window[@name='pruefFensterD']/@tags"">: Attribut 'tags' an <window name=""pruefFensterD"">: gesetzt 'a,b,c', jetzt 'a,b'",
    "700_40_Pruef <append xpath=""/windows/window[@name='pruefFensterD']/@art"">: Attribut 'art' an <window name=""pruefFensterD""> ist entfernt - zuerst nach PruefArten <removeattribute",
    "700_40_Pruef <set xpath=""/windows/window[@name='pruefFensterD']/note[@name='hinweis']"">: Text von <note name=""hinweis"">: gesetzt 'unser Text', jetzt 'fremder Text'",
    "700_40_Pruef <prepend xpath=""/windows/window[@name='pruefFensterD']"">: eingefuegtes Element <label name=""700_pruefVorn""> ist geaendert",
    "eingefuegtes Element <label name=""700_pruefDanach""> ist geaendert",
    "eingefuegtes Element <label name=""700_pruefDavor""> ist geaendert",
    "[die fremde Mod, dann wir, umgekehrt] PruefArten <setattribute xpath=""/windows/window[@name='pruefFensterD']"" name=""pos"">: Attribut 'pos' an <window name=""pruefFensterD"">: gesetzt '9,9', jetzt 'erst' - zuerst nach 700_40_Pruef <set",
    "[die fremde Mod, dann wir, umgekehrt] 700_40_Pruef <append xpath=""/windows/window[@name='pruefFensterD']/@art""> trifft allein 1 Knoten, hier keinen",
    'Ziel verloren 1, Zweig wechselt 0, Wirkung veraendert 10, nicht gerechnet 0',
    '== Ergebnis: 11 Befunde -> RED ==') -MustNotContain @('700_pruefWegwerf')

# (o) Regel 7 und 8: nichts gerechnet ist nicht gruen. Zwoelf Ausfaelle, jeder Ausgang 2.
$vertAusfaelle = @(
    @{ Name = 'fremder Ordner ohne ModInfo.xml'; Fremd = 'fremd-ohne-modinfo'; Text = 'hat keine ModInfo.xml direkt im Ordner' },
    @{ Name = 'ModInfo.xml ohne Namen'; Fremd = 'fremd-ohne-name'; Text = 'nennt keinen Namen (<Name value=...>)' },
    @{ Name = 'fremde Mod nur mit Dateien ohne Vanilla-Gegenstueck'; Fremd = 'fremd-leer'; Text = "die fremde Mod 'PruefLeer'" },
    @{ Name = 'fremde Patch-Datei ist kein XML'; Fremd = 'fremd-kaputt'; Text = 'laesst sich nicht als XML lesen' },
    @{ Name = 'fremde Patch-Datei mit DOCTYPE'; Fremd = 'fremd-doctype'; Text = 'laesst sich nicht als XML lesen' },
    @{ Name = 'fremde Mod ohne eine einzige Operation'; Fremd = 'fremd-ohne-operation'; Text = 'hat in 1 Dateien keine einzige Patch-Operation' },
    @{ Name = 'fremder Ordner fehlt'; Fremd = 'gibt-es-nicht'; Text = 'ist kein Ordner' })
foreach ($ausfall in $vertAusfaelle) {
    Test-Script "vertraeglichkeit: $($ausfall.Name) - nicht pruefbar" 2 @{
        Unsere  = $vertUnsere
        Fremd   = @(Join-Path $vertDaten $ausfall.Fremd)
        Vanilla = $vertVanilla
    } -Skript $vertSkript -MustContain @($ausfall.Text, 'NICHT GEPRUEFT', '== Ergebnis: nicht pruefbar -> RED ==') -MustNotContain @('GREEN')
}

Test-Script 'vertraeglichkeit: unsere Seite ohne Datei mit Vanilla-Gegenstueck - nicht pruefbar' 2 @{
    Unsere  = @(Join-Path $vertDaten 'unsere-ohne\700_10_Pruef')
    Fremd   = @(Join-Path $vertDaten 'fremd-sauber')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @('unsere Modlets haben keine einzige XML-Patch-Datei mit Vanilla-Gegenstueck', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'vertraeglichkeit: Vanilla-Ordner fehlt - nicht pruefbar' 2 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sauber')
    Vanilla = (Join-Path $vertDaten 'gibt-es-nicht')
} -Skript $vertSkript -MustContain @('den Vanilla-Ordner', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'vertraeglichkeit: kein Spielpfad und kein -Vanilla - nicht pruefbar' 2 @{
    Unsere = $vertUnsere
    Fremd  = @(Join-Path $vertDaten 'fremd-sauber')
} -Skript $vertSkript -OhneSpielpfad -MustContain @('vertraeglichkeit-pruefen: SDTD_PATH ist nicht gesetzt und -Vanilla nicht angegeben', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'vertraeglichkeit: bedingter Block, die angegebene NCalc.dll fehlt - nicht pruefbar' 2 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sauber')
    Vanilla = $vertVanilla
    NCalc   = (Join-Path $vertDaten 'gibt-es-nicht.dll')
} -Skript $vertSkript -MustContain @('eine Patch-Datei hat einen bedingten Block, aber die NCalc.dll des Spiels fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

Test-Script 'vertraeglichkeit: bedingter Block ohne Spielpfad - nicht pruefbar' 2 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-sauber')
    Vanilla = $vertVanilla
} -Skript $vertSkript -OhneSpielpfad -MustContain @('eine Patch-Datei hat einen bedingten Block, und SDTD_PATH ist nicht gesetzt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

# (o2) Review zu WP8.9 (Vertrag 04, "Nachtrag Review zu WP8.9"), drei Befunde.
#      Unsere Seite ist in den Laeufen zur Bibliothek NUR das Modlet ohne bedingten Block:
#      mit dem zweiten lueden unsere eigenen Bedingungen die Bibliothek, und der Lauf waere
#      auch ohne den Fix rot.
$vertNurFenster = @(Join-Path $vertDaten 'unsere\700_10_Pruef')

#      Regel 1: die NCalc.dll wird fuer JEDEN bedingten Block gebraucht. Ein Block nur mit
#      <else> lief ohne sie gruen durch, ein <if> ohne cond endete mit Ausgang 1.
Test-Script 'vertraeglichkeit: Block nur mit <else>, die NCalc.dll fehlt - nicht pruefbar' 2 @{
    Unsere  = $vertNurFenster
    Fremd   = @(Join-Path $vertDaten 'fremd-nur-else')
    Vanilla = $vertVanilla
    NCalc   = (Join-Path $vertDaten 'gibt-es-nicht.dll')
} -Skript $vertSkript -MustContain @('eine Patch-Datei hat einen bedingten Block, aber die NCalc.dll des Spiels fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'Befunde')

Test-Script 'vertraeglichkeit: <if> ohne cond, die NCalc.dll fehlt - nicht pruefbar' 2 @{
    Unsere  = $vertNurFenster
    Fremd   = @(Join-Path $vertDaten 'fremd-if-ohne-cond')
    Vanilla = $vertVanilla
    NCalc   = (Join-Path $vertDaten 'gibt-es-nicht.dll')
} -Skript $vertSkript -MustContain @('eine Patch-Datei hat einen bedingten Block, aber die NCalc.dll des Spiels fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN', 'Befunde')

#      Dieselbe Mod MIT der Bibliothek: der <else>-Zweig laeuft, nichts ist rot. Damit ist
#      der Ausgang 2 oben die fehlende Bibliothek und nicht die Pruef-Mod.
Test-Script 'vertraeglichkeit: Block nur mit <else>, mit der NCalc.dll - gruen' 0 @{
    Unsere  = $vertNurFenster
    Fremd   = @(Join-Path $vertDaten 'fremd-nur-else')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'Operationen der fremden Mod allein: 1, davon ohne Treffer: 0',
    "'PruefNurElse': 0 Befunde (Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 0, nicht gerechnet 0, gemeinsamer Sprachschluessel 0) -> GREEN",
    '== Ergebnis: 0 Befunde -> GREEN ==')

#      Regel 2: mod_loaded und xpath bekommen genau ein Argument. Zwei und keines sind
#      "nicht gerechnet", kein Zweig laeuft - die eine Operation danach trifft ihr Fenster
#      noch. Wer nur das erste Argument liest, entfernt es.
Test-Script 'vertraeglichkeit: mod_loaded und xpath mit falscher Argumentzahl sind nicht gerechnet' 1 @{
    Unsere  = $vertNurFenster
    Fremd   = @(Join-Path $vertDaten 'fremd-argumente')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    'Operationen der fremden Mod allein: 1, davon ohne Treffer: 0',
    '-- nicht gerechnet (3) --',
    "Bedingung ""not mod_loaded('PruefNichtDa', 'zuviel')"": sie laesst sich nicht auswerten (mod_loaded(...) bekommt 2 Argumente, das Spiel verlangt genau eines)",
    'sie laesst sich nicht auswerten (xpath(...) bekommt 2 Argumente, das Spiel verlangt genau eines)',
    'Bedingung "not mod_loaded()": sie laesst sich nicht auswerten (mod_loaded(...) bekommt 0 Argumente, das Spiel verlangt genau eines)',
    "'PruefArgumente': 3 Befunde (Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 0, nicht gerechnet 3, gemeinsamer Sprachschluessel 0) -> RED",
    '== Ergebnis: 3 Befunde -> RED ==') -MustNotContain @('trifft allein nichts', 'GREEN')

#      Regel 3: eine Zeile je Stelle, und die Datei gehoert zur Stelle. Dieselbe unbekannte
#      Operation am selben Platz zweier Dateien sind zwei Zeilen.
Test-Script 'vertraeglichkeit: dieselbe Meldung in zwei Dateien sind zwei Stellen' 1 @{
    Unsere  = $vertUnsere
    Fremd   = @(Join-Path $vertDaten 'fremd-zwei-dateien')
    Vanilla = $vertVanilla
} -Skript $vertSkript -MustContain @(
    '-- nicht gerechnet (2) --',
    'PruefZweiDateien: unbekannte Patch-Operation <pruefunbekannt>  (XUi_Common\styles.xml) - Stand: die fremde Mod allein; wir, dann die fremde Mod; die fremde Mod, dann wir',
    'PruefZweiDateien: unbekannte Patch-Operation <pruefunbekannt>  (XUi_InGame\windows.xml) - Stand: die fremde Mod allein; wir, dann die fremde Mod; die fremde Mod, dann wir',
    "'PruefZweiDateien': 2 Befunde (Ziel verloren 0, Zweig wechselt 0, Wirkung veraendert 0, nicht gerechnet 2, gemeinsamer Sprachschluessel 0) -> RED",
    '== Ergebnis: 2 Befunde -> RED ==')

# (p) Ohne Parameter sucht das Skript unsere Modlets unter mod\ und die fremden Mods unter
#     GameRefs\ui-mods, beides neben tools\check. Das laesst sich nur in einem nachgebauten
#     Baum pruefen: einmal vollstaendig (muss gruen sein und die Ordner ohne ModInfo.xml
#     uebergehen), einmal ohne GameRefs, einmal ohne patch-operationen.ps1. Im dritten Baum
#     liegt auch sprachverweise-pruefen.ps1: es liest dieselbe Datei ein.
$vertBaum = Join-Path ([IO.Path]::GetTempPath()) ('mod700-vertraeglichprobe-' + [Guid]::NewGuid().ToString('N'))
try {
    foreach ($vertFall in 'ganz', 'ohne-fremd', 'ohne-bibliothek') {
        $vertWurzel = Join-Path $vertBaum $vertFall
        New-Item -ItemType Directory -Force -Path (Join-Path $vertWurzel 'tools\check') | Out-Null
        New-Item -ItemType Directory -Force -Path (Join-Path $vertWurzel 'mod') | Out-Null
        Copy-Item -LiteralPath (Join-Path $here 'vertraeglichkeit-pruefen.ps1') -Destination (Join-Path $vertWurzel 'tools\check')
        Copy-Item -LiteralPath (Join-Path $here 'sprachverweise-pruefen.ps1') -Destination (Join-Path $vertWurzel 'tools\check')
        if ($vertFall -ne 'ohne-bibliothek') {
            Copy-Item -LiteralPath (Join-Path $here 'patch-operationen.ps1') -Destination (Join-Path $vertWurzel 'tools\check')
        }
        Copy-Item -LiteralPath (Join-Path $vertDaten 'unsere\700_10_Pruef') -Destination (Join-Path $vertWurzel 'mod') -Recurse
        Copy-Item -LiteralPath (Join-Path $vertDaten 'unsere\700_20_Pruef') -Destination (Join-Path $vertWurzel 'mod') -Recurse
        if ($vertFall -ne 'ohne-fremd') {
            New-Item -ItemType Directory -Force -Path (Join-Path $vertWurzel 'GameRefs\ui-mods\_zip') | Out-Null
            Copy-Item -LiteralPath (Join-Path $vertDaten 'fremd-sauber') -Destination (Join-Path $vertWurzel 'GameRefs\ui-mods') -Recurse
        }
    }

    Test-Script 'vertraeglichkeit: ohne Parameter - Modlets unter mod, fremde Mods unter GameRefs\ui-mods' 0 @{
        Vanilla = $vertVanilla
    } -FremdesSkript (Join-Path $vertBaum 'ganz\tools\check\vertraeglichkeit-pruefen.ps1') -MustContain @(
        "unsere 2 Modlets und 'PruefSauber' (Ordner fremd-sauber)",
        'gemeinsame Dateien: 2',
        '== Ergebnis: 0 Befunde -> GREEN ==')

    Test-Script 'vertraeglichkeit: ohne Parameter und ohne GameRefs\ui-mods - nicht pruefbar' 2 @{
        Vanilla = $vertVanilla
    } -FremdesSkript (Join-Path $vertBaum 'ohne-fremd\tools\check\vertraeglichkeit-pruefen.ps1') -MustContain @(
        'GameRefs\ui-mods', 'gibt es nicht', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    Test-Script 'vertraeglichkeit: patch-operationen.ps1 fehlt - nicht pruefbar' 2 @{
        Vanilla = $vertVanilla
    } -FremdesSkript (Join-Path $vertBaum 'ohne-bibliothek\tools\check\vertraeglichkeit-pruefen.ps1') -MustContain @(
        'vertraeglichkeit-pruefen: patch-operationen.ps1 fehlt neben dem Skript', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    Test-Script 'sprachverweise: patch-operationen.ps1 fehlt - nicht pruefbar' 2 @{
        Patches     = $spracheGutPatches
        Sprachdatei = (Join-Path $spracheDaten 'gut\Localization.csv')
        Vanilla     = $spracheVanilla
    } -FremdesSkript (Join-Path $vertBaum 'ohne-bibliothek\tools\check\sprachverweise-pruefen.ps1') -MustContain @(
        'sprachverweise-pruefen: patch-operationen.ps1 fehlt neben dem Skript', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')
}
finally {
    if (Test-Path -LiteralPath $vertBaum) { Remove-Item -LiteralPath $vertBaum -Recurse -Force }
}

# ------------------------------------------ Symbole und Asset-Register (2026-11-23)
# Zwei Werkzeuge, beide neu mit Plan-0002 (WP2.5, WP3.4) und Vertrag 05:
#   tools\assets\symbole.ps1        erzeugt die Bilder aus dem Register und prueft sie (-Pruefen)
#   tools\check\symbole-pruefen.ps1 haelt jedes genannte CustomIcon gegen die Bilder
# Die Pruefbilder werden HIER gezeichnet (eine Ellipse) und liegen nicht im Repository: so
# gibt es keine Binaerdatei in den Testdaten, und kein Bild stammt aus dem Spiel.
Write-Output ""
Write-Output "== Gegenproben: Symbole - Register, Zuschnitt, genannte Bilder =="
Add-Type -AssemblyName System.Drawing
$symboleSkript = Join-Path $repoRoot 'tools\assets\symbole.ps1'
$symPruefSkript = Join-Path $here 'symbole-pruefen.ps1'
$symBaum = Join-Path ([IO.Path]::GetTempPath()) ('mod700-symbolprobe-' + [Guid]::NewGuid().ToString('N'))

function New-PruefBild {
    # Ein Bild der Kante $Kante mit einer Ellipse, deren Breite $Inhalt ist.
    param([string]$Pfad, [int]$Kante = 240, [int]$Inhalt = 200, [switch]$OhneAlpha, [string]$Farbe = 'SteelBlue')
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Pfad))
    $format = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    if ($OhneAlpha) { $format = [System.Drawing.Imaging.PixelFormat]::Format24bppRgb }
    $bild = New-Object System.Drawing.Bitmap $Kante, $Kante, $format
    try {
        $g = [System.Drawing.Graphics]::FromImage($bild)
        try {
            if ($OhneAlpha) { $g.Clear([System.Drawing.Color]::White) } else { $g.Clear([System.Drawing.Color]::Transparent) }
            $pinsel = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromName($Farbe))
            try {
                $rand = [int](($Kante - $Inhalt) / 2)
                $g.FillEllipse($pinsel, $rand, $rand, $Inhalt, [int]($Inhalt * 0.7))
            }
            finally { $pinsel.Dispose() }
        }
        finally { $g.Dispose() }
        $bild.Save($Pfad, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally { $bild.Dispose() }
}

$symKopf = @(
    '# Pruefregister',
    '',
    '| Name | Art | Modlet | Benutzt von | Quelle | Beleg | Lizenz | Nennung | Beschreibung | Kosten | Stand |',
    '|---|---|---|---|---|---|---|---|---|---|---|')
$symZeileGut = '| `ico700_pruefding` | symbol | `700_20_Pruef` | `pruefDing` | eigen:blender | - | eigenes Werk | keine noetig | - | - | bleibt |'
$symXmlGut = @(
    '<configs>',
    '  <append xpath="/items">',
    '    <item name="pruefDing"><property name="CustomIcon" value="ico700_pruefding" /></item>',
    '    <item name="pruefZwei"><property name="CustomIcon" value="pruefVanillaBild" /></item>',
    '  </append>',
    "  <set xpath=""/items/item[@name='pruefDrei']/property[@name='CustomIcon']/@value"">pruefVanillaBild</set>",
    '</configs>')

function New-SymbolBaum {
    # Legt unter $symBaum\<Name> einen vollstaendigen, sauberen Baum an und gibt ihn zurueck.
    # -Fertig erzeugt auch das fertige Bild (mit dem echten Werkzeug).
    param([string]$Name, [string[]]$Zeilen = @($symZeileGut), [string[]]$Xml = $symXmlGut, [switch]$Fertig)
    $wurzel = Join-Path $symBaum $Name
    [void][IO.Directory]::CreateDirectory((Join-Path $wurzel 'assets'))
    [void][IO.Directory]::CreateDirectory((Join-Path $wurzel 'mod\700_20_Pruef\Config'))
    [IO.File]::WriteAllLines((Join-Path $wurzel 'assets\ASSETS.md'), [string[]]($symKopf + $Zeilen), [Text.UTF8Encoding]::new($false))
    [IO.File]::WriteAllLines((Join-Path $wurzel 'mod\700_20_Pruef\Config\items.xml'), [string[]]$Xml, [Text.UTF8Encoding]::new($false))
    New-PruefBild (Join-Path $wurzel 'assets\quelle\symbole\ico700_pruefding.png')
    New-PruefBild (Join-Path $wurzel 'vanilla\pruefVanillaBild.png') -Kante 160 -Inhalt 140 -Farbe 'Peru'
    if ($Fertig) { $null = & $symboleSkript -Wurzel $wurzel }
    return $wurzel
}

try {
    # (a) Der saubere Baum: erzeugen, noch einmal erzeugen (nichts aendert sich), pruefen.
    $symGut = New-SymbolBaum 'gut'
    Test-Script 'symbole: erzeugt das fertige Bild aus dem Quellbild' 0 @{ Wurzel = $symGut } `
        -FremdesSkript $symboleSkript -MustContain @('Zeilen: 1, davon Symbole: 1', 'geschrieben: 1, unveraendert: 0', 'GREEN')
    Test-Script 'symbole: ein zweiter Lauf schreibt nichts' 0 @{ Wurzel = $symGut } `
        -FremdesSkript $symboleSkript -MustContain @('geschrieben: 0, unveraendert: 1', 'GREEN')
    Test-Script 'symbole -Pruefen: Register, Quellbild und fertiges Bild passen zusammen' 0 @{ Wurzel = $symGut; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('fertige Bilder gleich ihrem Quellbild: 1; Dateien ohne Zeile: 0', '0 Befunde -> GREEN')
    Test-Script 'symbole-pruefen: jedes genannte Bild ist da, eigenes Bild 160x160 mit Alpha' 0 @{
        ModOrdner = (Join-Path $symGut 'mod'); VanillaBilder = (Join-Path $symGut 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @(
        'Vanilla-Bilder: 1; eigene Bilder: 1',
        'CustomIcon genannt: 3 (aus Vanilla: 2, aus einem Modlet: 1)',
        '0 Befunde -> GREEN')

    # (b) Das Werkzeug: jeder falsche Eingang einzeln.
    $w = New-SymbolBaum 'abweichend' -Fertig
    New-PruefBild (Join-Path $w 'assets\quelle\symbole\ico700_pruefding.png') -Farbe 'Firebrick'
    Test-Script 'symbole -Pruefen: fertiges Bild stammt nicht aus dem Quellbild' 1 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('ico700_pruefding: das fertige Bild entspricht nicht seinem Quellbild', '1 Befunde -> RED') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'ohne-zeile' -Fertig
    New-PruefBild (Join-Path $w 'mod\700_20_Pruef\UIAtlases\ItemIconAtlas\ico700_fremd.png') -Kante 160 -Inhalt 140
    Test-Script 'symbole -Pruefen: Bild im Modlet ohne Registerzeile' 1 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('Datei ohne Registerzeile: mod\700_20_Pruef\UIAtlases\ItemIconAtlas\ico700_fremd.png', 'Dateien ohne Zeile: 1') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'fertig-fehlt'
    Test-Script 'symbole -Pruefen: das fertige Bild fehlt' 1 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('ico700_pruefding: das fertige Bild fehlt') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'pflichtfeld' -Fertig -Zeilen @(
        '| `ico700_pruefding` | symbol | `700_20_Pruef` | `pruefDing` | eigen:blender | - |  | keine noetig | - | - | bleibt |',
        '| `pruefmodell` | modell | `700_20_Pruef` | `pruefDing` | meshy:pruef-1 | - | CC BY 4.0 | Erstellt mit Meshy | ein Ding | 20 | fertig |',
        '| `pruefklang` | geruch | `700_20_Pruef` | `pruefDing` | gefunden | x | y | z | a | b | bleibt |')
    Test-Script 'symbole -Pruefen: leeres Pflichtfeld, Strich bei fremder Quelle, falsche Art, Quelle, Stand' 1 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @(
        "(ico700_pruefding): Pflichtfeld 'Lizenz' ist leer",
        "(pruefmodell): Pflichtfeld 'Beleg' traegt nur einen Strich",
        "(pruefmodell): Stand 'fertig' gibt es nicht",
        "(pruefklang): Art 'geruch' gibt es nicht",
        "(pruefklang): Quelle 'gefunden' hat keine der vier Formen",
        '5 Befunde -> RED') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'doppelt-und-name' -Fertig -Zeilen @(
        $symZeileGut,
        '| `ico700_pruefding` | symbol | `700_20_Pruef` | `pruefZwei` | eigen:hand | - | eigenes Werk | keine noetig | - | - | bleibt |')
    Test-Script 'symbole -Pruefen: derselbe Name in zwei Zeilen' 1 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('der Name steht schon in Zeile 5') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'name-falsch' -Zeilen @(
        '| `PruefDing` | symbol | `700_20_Pruef` | `pruefDing` | eigen:blender | - | eigenes Werk | keine noetig | - | - | bleibt |')
    Test-Script 'symbole: ein Symbol ohne ico700_ im Namen' 1 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('ein Symbol heisst ico700_<wort> in Kleinbuchstaben') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'quelle-fehlt'
    Remove-Item -LiteralPath (Join-Path $w 'assets\quelle\symbole\ico700_pruefding.png')
    Test-Script 'symbole: das Quellbild fehlt' 1 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('ico700_pruefding: das Quellbild fehlt', 'geschrieben: 0') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'kein-alpha'
    New-PruefBild (Join-Path $w 'assets\quelle\symbole\ico700_pruefding.png') -OhneAlpha
    Test-Script 'symbole: Quellbild ohne Alphakanal' 1 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('das Quellbild hat keinen Alphakanal') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'zu-klein'
    New-PruefBild (Join-Path $w 'assets\quelle\symbole\ico700_pruefding.png') -Kante 100 -Inhalt 90
    Test-Script 'symbole: Quellbild kleiner als 160x160' 1 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('das Quellbild ist kleiner als 160x160 (100x100)') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'inhalt-klein'
    New-PruefBild (Join-Path $w 'assets\quelle\symbole\ico700_pruefding.png') -Kante 400 -Inhalt 60
    Test-Script 'symbole: grosses Quellbild mit winzigem Inhalt - Vergroessern gibt es nicht' 1 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('sichtbare Bildpunkte, gebraucht werden 148') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'kein-png'
    [IO.File]::WriteAllText((Join-Path $w 'assets\quelle\symbole\ico700_pruefding.png'), 'kein Bild')
    Test-Script 'symbole: Quellbild ist keine Bilddatei' 1 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('das Quellbild laesst sich nicht als Bild lesen') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'kein-register'
    Remove-Item -LiteralPath (Join-Path $w 'assets\ASSETS.md')
    Test-Script 'symbole -Pruefen: ohne Register ist nichts geprueft' 2 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('das Register fehlt', 'NICHT AUSGEFUEHRT') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'register-leer' -Zeilen @()
    Test-Script 'symbole -Pruefen: Register ohne Zeile ist nichts geprueft' 2 @{ Wurzel = $w; Pruefen = $true } `
        -FremdesSkript $symboleSkript -MustContain @('das Register hat keine Zeile', 'NICHT AUSGEFUEHRT') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'spalte-fehlt'
    [IO.File]::WriteAllLines((Join-Path $w 'assets\ASSETS.md'), [string[]]@(
            '| Name | Art | Modlet | Benutzt von | Quelle | Beleg | Nennung | Beschreibung | Kosten | Stand |',
            '|---|---|---|---|---|---|---|---|---|---|',
            '| `ico700_pruefding` | symbol | `700_20_Pruef` | `pruefDing` | eigen:blender | - | keine noetig | - | - | bleibt |'))
    Test-Script 'symbole: Register ohne die Spalte Lizenz ist unlesbar' 2 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @('dem Register fehlen die Spalten: Lizenz', 'NICHT AUSGEFUEHRT') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'modlet-unbekannt' -Zeilen @(
        '| `ico700_pruefding` | symbol | `700_99_GibtEsNicht` | `pruefDing` | eigen:blender | - | eigenes Werk | keine noetig | - | - | bleibt |')
    Test-Script 'symbole: Zeile nennt ein Modlet, das es nicht gibt' 2 @{ Wurzel = $w } `
        -FremdesSkript $symboleSkript -MustContain @("nennt das Modlet '700_99_GibtEsNicht'", 'NICHT AUSGEFUEHRT') -MustNotContain @('GREEN')

    # (c) Die Pruefung der genannten Bilder: jede Regel einzeln.
    $w = New-SymbolBaum 'verweis-fehlt' -Fertig -Xml @(
        '<configs>',
        '  <append xpath="/items"><item name="pruefDing"><property name="CustomIcon" value="ico700_pruefding" /></item>',
        '    <item name="pruefVier"><property name="CustomIcon" value="ico700_gibtesnicht" /></item></append>',
        "  <set xpath=""/items/item[@name='pruefDrei']/property[@name='CustomIcon']/@value"">ico700_auchnicht</set>",
        '  <append xpath="/items/item[@name=''pruefFuenf'']"><property name="CustomIcon" value="PruefVanillaBild" /></append>',
        '  <append xpath="/items/item[@name=''pruefSechs'']"><property name="CustomIcon" value="" /></append>',
        '</configs>')
    Test-Script 'symbole-pruefen: genanntes Bild fehlt (property und set), falsche Schreibung, leerer Wert' 1 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @(
        "CustomIcon 'ico700_gibtesnicht' nennt ein Bild, das es weder in Vanilla noch in einem unserer Modlets gibt",
        "CustomIcon 'ico700_auchnicht' nennt ein Bild, das es weder in Vanilla noch in einem unserer Modlets gibt",
        "CustomIcon 'PruefVanillaBild' - das Bild heisst 'pruefVanillaBild' (Gross- und Kleinschreibung)",
        'CustomIcon ohne Wert',
        '4 Befunde -> RED') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'falsche-form' -Fertig
    New-PruefBild (Join-Path $w 'mod\700_20_Pruef\UIAtlases\ItemIconAtlas\ico700_pruefding.png') -Kante 128 -Inhalt 100 -OhneAlpha
    Test-Script 'symbole-pruefen: eigenes Bild 128x128 und ohne Alpha' 1 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @('hat keinen Alphakanal', 'ist 128x128 statt 160x160', '2 Befunde -> RED') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'doppelt' -Fertig
    [void][IO.Directory]::CreateDirectory((Join-Path $w 'mod\700_30_Pruef\UIAtlases\ItemIconAtlas'))
    Copy-Item -LiteralPath (Join-Path $w 'mod\700_20_Pruef\UIAtlases\ItemIconAtlas\ico700_pruefding.png') -Destination (Join-Path $w 'mod\700_30_Pruef\UIAtlases\ItemIconAtlas\ico700_pruefding.png')
    Test-Script 'symbole-pruefen: zwei Modlets tragen ein Bild gleichen Namens' 1 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @(
        '700_30_Pruef\UIAtlases\ItemIconAtlas\ico700_pruefding.png: denselben Bildnamen traegt schon 700_20_Pruef\UIAtlases\ItemIconAtlas\ico700_pruefding.png') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'name-und-ort' -Fertig
    New-PruefBild (Join-Path $w 'mod\700_20_Pruef\UIAtlases\ItemIconAtlas\pruefVanillaBild.png') -Kante 160 -Inhalt 140
    New-PruefBild (Join-Path $w 'mod\700_20_Pruef\UIAtlases\ItemIconAtlas\ico700_niemand.png') -Kante 160 -Inhalt 140
    New-PruefBild (Join-Path $w 'mod\700_20_Pruef\UIAtlases\AndererAtlas\ico700_woanders.png') -Kante 160 -Inhalt 140
    Test-Script 'symbole-pruefen: Name eines Vanilla-Bildes, ungenutztes Bild, fremder Atlas' 1 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @(
        "pruefVanillaBild.png: traegt den Namen des Vanilla-Bildes 'pruefVanillaBild'",
        'pruefVanillaBild.png: ein eigenes Bild heisst ico700_<wort> in Kleinbuchstaben',
        'ico700_niemand.png: kein CustomIcon nennt dieses Bild',
        'ico700_woanders.png: unter UIAtlases ist nur ItemIconAtlas\<Name>.png geregelt') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'ohne-vanilla' -Fertig
    Test-Script 'symbole-pruefen: Vanillas Bilderordner fehlt - nicht pruefbar' 2 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'gibt-es-nicht')
    } -FremdesSkript $symPruefSkript -MustContain @('Vanillas Bilderordner fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    Test-Script 'symbole-pruefen: ohne Spielpfad und ohne -VanillaBilder - nicht pruefbar' 2 @{
        ModOrdner = (Join-Path $w 'mod')
    } -FremdesSkript $symPruefSkript -OhneSpielpfad -MustContain @('SDTD_PATH ist nicht gesetzt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'kein-customicon' -Xml @('<configs>', '  <append xpath="/items"><item name="pruefDing" /></append>', '</configs>')
    Test-Script 'symbole-pruefen: keine Datei nennt ein CustomIcon - nicht pruefbar' 2 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @('nennt ein CustomIcon', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    $w = New-SymbolBaum 'xml-kaputt' -Xml @('<configs>', '  <append xpath="/items">', '</configs>')
    Test-Script 'symbole-pruefen: XML-Datei laesst sich nicht lesen - nicht pruefbar' 2 @{
        ModOrdner = (Join-Path $w 'mod'); VanillaBilder = (Join-Path $w 'vanilla')
    } -FremdesSkript $symPruefSkript -MustContain @('laesst sich nicht als XML lesen', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')
}
finally {
    if (Test-Path -LiteralPath $symBaum) { Remove-Item -LiteralPath $symBaum -Recurse -Force }
}

# ------------------------------------------ Test-Ueberlagerung (2026-11-23)
# test\700_99_Test verkuerzt Uhren fuer einen Spieltest (Vertrag 01, Nachtrag
# "Test-Ueberlagerung"). Zwei Dinge koennen schiefgehen, und beide sieht man im Spiel erst
# nach einer halben Stunde: eine Zeile trifft nichts (der Test laeuft mit langen Uhren), oder
# die Ueberlagerung bleibt liegen bzw. geraet ins Paket (die Mod laeuft mit kurzen).
Write-Output ""
Write-Output "== Gegenproben: Test-Ueberlagerung - trifft sie, und bleibt sie draussen? =="
$ueberSkript = Join-Path $here 'testueberlagerung-pruefen.ps1'
$smokeSkript = Join-Path $repoRoot 'tools\build\smoke.ps1'
$ueberBaum = Join-Path ([IO.Path]::GetTempPath()) ('mod700-ueberlagerungsprobe-' + [Guid]::NewGuid().ToString('N'))
$ueberXPath = "/blocks/block[@name='pruefLicht']/property[@class='PlantGrowing']/property[@name='GrowthRate']/@value"

function Write-Pruefdatei {
    param([string]$Pfad, [string[]]$Zeilen)
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Pfad))
    [IO.File]::WriteAllLines($Pfad, [string[]]$Zeilen, [Text.UTF8Encoding]::new($false))
}

function New-UeberBaum {
    # Vanilla mit einem Block, ein Modlet, das ihm eine Uhr gibt (30), eine Ueberlagerung.
    # -Zeilen: die Patch-Zeilen der Ueberlagerung. -Ordner: wie die Ueberlagerung heisst.
    param([string]$Name, [string[]]$Zeilen = @("  <set xpath=""$ueberXPath"">2</set>"), [string]$Ordner = '700_99_Test', [switch]$OhneModInfo)
    $wurzel = Join-Path $ueberBaum $Name
    Write-Pruefdatei (Join-Path $wurzel 'vanilla\blocks.xml') @(
        '<blocks>', '  <block name="pruefLicht"><property name="Class" value="PruefKlasse" /></block>', '</blocks>')
    Write-Pruefdatei (Join-Path $wurzel 'mod\700_40_Pruef\Config\blocks.xml') @(
        '<config>',
        '  <append xpath="/blocks/block[@name=''pruefLicht'']">',
        '    <property class="PlantGrowing"><property name="GrowthRate" value="30" /></property>',
        '  </append>',
        '</config>')
    if (-not $OhneModInfo) {
        Write-Pruefdatei (Join-Path $wurzel "test\$Ordner\ModInfo.xml") @('<xml>', "  <Name value=""$Ordner"" />", '</xml>')
    }
    Write-Pruefdatei (Join-Path $wurzel "test\$Ordner\Config\blocks.xml") ([string[]](@('<config>') + $Zeilen + @('</config>')))
    return $wurzel
}

function Get-UeberParameter {
    param([string]$Wurzel)
    return @{ ModOrdner = (Join-Path $Wurzel 'mod'); TestOrdner = (Join-Path $Wurzel 'test'); Vanilla = (Join-Path $Wurzel 'vanilla') }
}

try {
    $w = New-UeberBaum 'gut'
    Test-Script 'testueberlagerung: die Zeile trifft den Knoten des Modlets und aendert ihn' 0 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('Ueberlagerungen: 1; Dateien: 1; Zeilen: 1; geaenderte Werte: 1', "30 -> 2   $ueberXPath", '0 Befunde -> GREEN')

    $w = New-UeberBaum 'trifft-nichts' -Zeilen @("  <set xpath=""/blocks/block[@name='pruefAnderes']/property[@class='PlantGrowing']/property[@name='GrowthRate']/@value"">2</set>")
    Test-Script 'testueberlagerung: eine Zeile trifft nichts' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('<set> trifft nichts am Stand nach unseren Modlets', "pruefAnderes", '1 Befunde -> RED') -MustNotContain @('GREEN')

    # Der Knoten, den NUR das Modlet anlegt: ohne das Modlet darf dieselbe Zeile nicht treffen.
    # Das ist der Nachweis, dass wirklich am Stand NACH den Modlets gerechnet wird.
    $w = New-UeberBaum 'ohne-modlet'
    Remove-Item -LiteralPath (Join-Path $w 'mod\700_40_Pruef') -Recurse -Force
    Test-Script 'testueberlagerung: ohne das Modlet trifft dieselbe Zeile nichts' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('<set> trifft nichts am Stand nach unseren Modlets') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'kein-set' -Zeilen @(
        '  <append xpath="/blocks/block[@name=''pruefLicht'']"><property name="Neu" value="1" /></append>',
        '  <remove xpath="/blocks/block[@name=''pruefLicht'']/property[@name=''Class'']" />')
    Test-Script 'testueberlagerung: <append> ohne Probe-Namen und <remove> sind nicht erlaubt' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @("<append> legt 'Neu' an - eine Ueberlagerung legt nur Proben an, deren Name mit t700_ beginnt", '<remove> - eine Ueberlagerung benutzt nur <set>', '2 Befunde -> RED') -MustNotContain @('GREEN')

    # Nachtrag Teil 1d (WP9.10): Proben t700_* duerfen angehaengt werden - aber nur so.
    $w = New-UeberBaum 'probe-gut' -Zeilen @(
        "  <set xpath=""$ueberXPath"">2</set>",
        '  <append xpath="/blocks"><block name="t700_pruefProbe"><property name="Class" value="PruefKlasse" /></block></append>')
    Test-Script 'testueberlagerung: eine Probe t700_ wird angehaengt' 0 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('Proben: 1', "+ Probe block 't700_pruefProbe'", '0 Befunde -> GREEN')

    $w = New-UeberBaum 'probe-trifft-nichts' -Zeilen @(
        '  <append xpath="/gibtesnicht"><block name="t700_pruefProbe" /></append>')
    Test-Script 'testueberlagerung: eine Probe, deren Ziel nichts trifft' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('<append> trifft nichts am Stand nach unseren Modlets: /gibtesnicht') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'probe-doppelt' -Zeilen @(
        '  <append xpath="/blocks"><block name="t700_pruefProbe" /></append>',
        '  <append xpath="/blocks"><block name="t700_pruefProbe" /></append>')
    Test-Script 'testueberlagerung: eine Probe, die es schon gibt' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @("Probe 't700_pruefProbe' gibt es am Stand nach unseren Modlets schon") -MustNotContain @('GREEN')

    $w = New-UeberBaum 'mod-nennt-probe'
    Write-Pruefdatei (Join-Path $w 'mod\700_40_Pruef\Config\items.xml') @('<config>', '  <append xpath="/items"><item name="t700_versehen" /></append>', '</config>')
    Test-Script 'testueberlagerung: die Mod nennt eine Probe' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('items.xml: nennt eine Probe (t700_)') -MustNotContain @('GREEN')

    # Der Fehlalarm vom ersten echten Lauf: 'ent700_' enthaelt 't700_', ist aber ein Wesen-Name.
    $w = New-UeberBaum 'mod-nennt-wesen'
    Write-Pruefdatei (Join-Path $w 'mod\700_40_Pruef\Config\entityclasses.xml') @('<config>', '  <append xpath="/entity_classes"><entity_class name="ent700_wolf" /></append>', '</config>')
    Test-Script 'testueberlagerung: ent700_ in der Mod ist keine Probe' 0 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('0 Befunde -> GREEN') -MustNotContain @('nennt eine Probe')

    $w = New-UeberBaum 'gleicher-wert' -Zeilen @("  <set xpath=""$ueberXPath"">30</set>")
    Test-Script 'testueberlagerung: eine Zeile, die nichts aendert, ist ueberholt' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @("<set> aendert nichts, der Wert ist schon '30'") -MustNotContain @('GREEN')

    $w = New-UeberBaum 'unter-mod'
    Write-Pruefdatei (Join-Path $w 'mod\700_99_Test\ModInfo.xml') @('<xml />')
    Test-Script 'testueberlagerung: ein Ordner 700_99_* unter mod landet im Paket' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @("unter dem Modlet-Ordner liegt '700_99_Test'", 'sonst landet sie im Paket') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'fremde-datei'
    Write-Pruefdatei (Join-Path $w 'test\700_99_Test\Pruef.dll') @('kein Code')
    Write-Pruefdatei (Join-Path $w 'test\700_99_Test\Config\notiz.txt') @('keine Patch-Datei')
    Test-Script 'testueberlagerung: DLL und Textdatei in der Ueberlagerung' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @(
        '700_99_Test\Pruef.dll: eine Ueberlagerung traegt nur ModInfo.xml und XML unter Config',
        '700_99_Test\Config\notiz.txt: eine Ueberlagerung traegt nur ModInfo.xml und XML unter Config',
        '2 Befunde -> RED') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'name-und-modinfo' -Ordner '700_50_Test' -OhneModInfo
    Test-Script 'testueberlagerung: falscher Ordnername, ModInfo.xml fehlt' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('700_50_Test: eine Ueberlagerung heisst 700_99_<Wort>', '700_50_Test: ModInfo.xml fehlt') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'datei-ohne-vanilla'
    Write-Pruefdatei (Join-Path $w 'test\700_99_Test\Config\gibtesnicht.xml') @('<config>', '  <set xpath="/a/@b">1</set>', '</config>')
    Test-Script 'testueberlagerung: Datei, die es in Vanilla nicht gibt' 1 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('gibtesnicht.xml: Vanilla hat keine Datei dieses Namens') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'leer' -Zeilen @()
    Test-Script 'testueberlagerung: Ueberlagerung ohne Zeile - nicht pruefbar' 2 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('traegt eine Patch-Zeile', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'keine-ueberlagerung'
    Remove-Item -LiteralPath (Join-Path $w 'test\700_99_Test') -Recurse -Force
    Test-Script 'testueberlagerung: Test-Ordner ohne Ueberlagerung - nicht pruefbar' 2 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('liegt keine Ueberlagerung', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'ohne-vanilla'
    $p = Get-UeberParameter $w
    $p.Vanilla = (Join-Path $w 'gibt-es-nicht')
    Test-Script 'testueberlagerung: Vanilla-Ordner fehlt - nicht pruefbar' 2 $p `
        -FremdesSkript $ueberSkript -MustContain @('Vanillas Config-Ordner fehlt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    $p = Get-UeberParameter $w
    $p.Remove('Vanilla')
    Test-Script 'testueberlagerung: ohne Spielpfad und ohne -Vanilla - nicht pruefbar' 2 $p `
        -FremdesSkript $ueberSkript -OhneSpielpfad -MustContain @('SDTD_PATH ist nicht gesetzt', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    $w = New-UeberBaum 'xml-kaputt' -Zeilen @('  <set xpath="/blocks">')
    Test-Script 'testueberlagerung: kaputtes XML in der Ueberlagerung - nicht pruefbar' 2 (Get-UeberParameter $w) `
        -FremdesSkript $ueberSkript -MustContain @('laesst sich nicht als XML lesen', 'NICHT GEPRUEFT') -MustNotContain @('GREEN')

    # smoke.ps1 gegen einen nachgebauten Spielordner. Der Lauf ist in jedem Fall rot (es
    # fehlen DLL und Modlets) - geprueft wird die EINE Zeile zur Ueberlagerung.
    $spielMit = Join-Path $ueberBaum 'spiel-mit'
    Write-Pruefdatei (Join-Path $spielMit 'Mods\700_99_Test\ModInfo.xml') @('<xml />')
    $spielOhne = Join-Path $ueberBaum 'spiel-ohne'
    Write-Pruefdatei (Join-Path $spielOhne 'Mods\700_60_Welt\ModInfo.xml') @('<xml />')

    Test-Script 'smoke: liegengebliebene Test-Ueberlagerung ist ein eigener roter Punkt' 1 @{ SkipLog = $true } `
        -FremdesSkript $smokeSkript -Spielpfad $spielMit -MustContain @(
        '[ROT]  keine Test-Ueberlagerung installiert (kurze Uhren)  -> gefunden: 700_99_Test',
        '[ok]   keine unbekannten 700er-Modlets')
    Test-Script 'smoke -MitTest: die Ueberlagerung ist erwartet' 1 @{ SkipLog = $true; MitTest = $true } `
        -FremdesSkript $smokeSkript -Spielpfad $spielMit -MustContain @('[ok]   Test-Ueberlagerung installiert (-MitTest)') `
        -MustNotContain @('keine Test-Ueberlagerung installiert (kurze Uhren)')
    Test-Script 'smoke: ohne Ueberlagerung ist der Punkt gruen' 1 @{ SkipLog = $true } `
        -FremdesSkript $smokeSkript -Spielpfad $spielOhne -MustContain @('[ok]   keine Test-Ueberlagerung installiert (kurze Uhren)')
    Test-Script 'smoke -MitTest: fehlt die Ueberlagerung, ist das rot' 1 @{ SkipLog = $true; MitTest = $true } `
        -FremdesSkript $smokeSkript -Spielpfad $spielOhne -MustContain @('[ROT]  Test-Ueberlagerung installiert (-MitTest)')
}
finally {
    if (Test-Path -LiteralPath $ueberBaum) { Remove-Item -LiteralPath $ueberBaum -Recurse -Force }
}

Write-Output ""
Write-Output ("== Ergebnis: $checked Gegenproben, $failed fehlgeschlagen ==")
if ($failed -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
