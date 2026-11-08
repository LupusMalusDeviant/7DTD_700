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
        [string[]]$MustNotContain = @()
    )

    $script:checked++
    $skript = Join-Path $here 'kette-pruefen.ps1'
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & $skript @Parameters
        $actual = if ($LASTEXITCODE -ne $null) { $LASTEXITCODE } else { 0 }
    }
    catch {
        $output = $_.Exception.Message
        $actual = -1
    }
    finally {
        $ErrorActionPreference = $previous
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
Write-Output ("== Ergebnis: $checked Gegenproben, $failed fehlgeschlagen ==")
if ($failed -gt 0) {
    Write-Output "ROT"
    exit 1
}
Write-Output "GRUEN"
exit 0
