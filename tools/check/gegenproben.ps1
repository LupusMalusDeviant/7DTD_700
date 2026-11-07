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

Write-Output ""
Write-Output "== Gegenproben: eine fehlende Annahme macht den sauberen Satz rot =="
# Ohne world-roots.txt ist pruefSchmelzEinheit unerreichbar - der Beweis, dass die
# Datei wirklich etwas beitraegt und nicht nur dekorativ dabeiliegt.
Test-Case 'recipes ohne world-roots wird rot' 1 @(
    'recipes', (Join-Path $data 'sauber'), '--no-world-roots')

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
Write-Output "== Gegenproben: Benutzungsfehler ist Exit 2, nicht rot und nicht gruen =="
Test-Case 'unbekannter Befehl' 2 @('gibtesnicht', $data)
Test-Case 'fehlender Pfad' 2 @('recipes')
Test-Case 'Ordner ohne items.xml' 2 @('recipes', $here)
Test-Case 'unbekannte Option' 2 @(
    'recipes', (Join-Path $data 'sauber'), '--quatsch')

Write-Output ""
Write-Output ("== Ergebnis: $checked Gegenproben, $failed fehlgeschlagen ==")
if ($failed -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
