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
    '-> nicht geprueft, zaehlt als rot',
    '6 Pruefungen, 3 rot')

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
    '6 Pruefungen, 3 rot')

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
        '6 Pruefungen, 3 rot')
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
    'xpath(...) steht ohne Vergleich',
    "Bedingung ruft 'eventActive(' auf",
    'Bedingung trifft in Vanilla nichts, der Zweig ist toter Text: /windows/window[@name="pruefGibtesnicht"]',
    'Bedingung mit offenem Anfuehrungszeichen',
    'XPath in der Bedingung ist kein gueltiger Ausdruck',
    'mod_loaded(...) erwartet EINEN Text',
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
    'in Bedingungen genannte Mods: pruefUiMod') -MustNotContain @('steht ohne Vergleich')

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
    "die Klammern gehen nicht auf: (mod_loaded('pruefUiMod')  (",
    "die Klammern gehen nicht auf: mod_loaded('pruefUiMod'))",
    "die Klammern gehen nicht auf: )mod_loaded('pruefUiMod')(",
    'der Zweig ist toter Text: /windows/window[@name="pruefGibtesnicht"]',
    'der Zweig ist toter Text: /windows/window[@name="pruefAuchNicht"]',
    'xpath(...) steht ohne Vergleich',
    '6 rot')

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
    '6 Pruefungen, 3 rot')

# (6) Dasselbe OHNE -Source und ohne ConfigsDump: %APPDATA% zeigt fuer diesen Lauf auf einen
#     Testordner, in dem kein Spielstand liegt. Vorher: 'throw', keine Ergebniszeile.
#     anachronisms, recipes, purge-patch und die Kette koennen nicht laufen = 4 rot.
Test-Script 'check-all: ohne jede Quelle zaehlen anachronisms und recipes als rot' 1 @{
    SkipGegenproben = $true
    Configuration   = $Configuration
} -Skript 'check-all.ps1' -Spielpfad $inAnfuehrung -Appdata $glossarDaten -MustContain @(
    'Quelle: KEINE',
    'NICHT GEPRUEFT: keine Quelle',
    '6 Pruefungen, 4 rot')

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

Write-Output ""
Write-Output ("== Ergebnis: $checked Gegenproben, $failed fehlgeschlagen ==")
if ($failed -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
