# wp7-baumtexte.ps1 — erzeugt die Localization-Zeilen für die fuenf Fertigkeitsbaeume.
#
# WARUM EIN ERZEUGER UND NICHT VON HAND:
# Vanilla schreibt die Rangschlüssel NICHT einheitlich. Vier Attribute nennen sie
# attXRank01Desc bis attXRank10Desc, attIntellect aber attIntellectRank1Desc bis
# attIntellectRank9Desc und dann attIntellectRank10Desc — ohne führende Null bei den
# einstelligen. Von Hand getippt waeren neun Schlüssel still falsch gewesen und neun
# Rangnamen hätten im Spiel englisch dagestanden, ohne dass eine Pruefung meckert:
# ein Schlüssel, den niemand liest, fällt nicht auf.
#
# Darum liest dieses Skript die Schlüssel aus progression.xml des installierten Builds
# (desc_key und long_desc_key an jedem effect_description) und setzt nur den TEXT dazu.
# Ändert ein Spiel-Update die Schlüssel, erzeugt derselbe Lauf die neuen.
#
# Aufruf:
#   pwsh tools/gen/wp7-baumtexte.ps1 [-Spiel <pfad>] [-Aus <datei.csv>]
# Ohne -Aus schreibt es nach tools/gen/out/wp7-baumtexte.csv (ohne Kopfzeile, damit die
# Ausgabe an mod/700_90_Sprache/Config/Localization.csv angehaengt werden kann).

[CmdletBinding()]
param(
    [string] $Spiel = $env:SDTD_PATH,
    [string] $Aus
)

$ErrorActionPreference = 'Stop'

if (-not $Spiel) { throw "Kein Spielpfad: SDTD_PATH setzen oder -Spiel angeben." }
$progPfad = Join-Path $Spiel 'Data\Config\progression.xml'
if (-not (Test-Path $progPfad)) { throw "progression.xml nicht gefunden: $progPfad" }

if (-not $Aus) {
    $hier = Split-Path -Parent $MyInvocation.MyCommand.Path
    $ausOrdner = Join-Path $hier 'out'
    if (-not (Test-Path $ausOrdner)) { New-Item -ItemType Directory -Path $ausOrdner | Out-Null }
    $Aus = Join-Path $ausOrdner 'wp7-baumtexte.csv'
}

# ---------------------------------------------------------------------------
# Die Zuordnung. Jede Zeile ist eine Entscheidung (D66) und steht auf einer
# Messung: welche Gegenstaende tragen die Marke des Attributs und überleben
# den Purge. Siehe docs/rea/findings/WP7-fertigkeitsbaeume.md, Abschnitt 2.
# ---------------------------------------------------------------------------
$baeume = @(
    @{
        Attribut = 'attStrength'
        Kurz     = @{ en = 'Craftsman';  de = 'Handwerker' }
        Name     = @{ en = 'Attribute: Craftsman'; de = 'Attribut: Handwerker' }
        Desc     = @{
            en = 'The craftsman wields tools. Each rank sets axe, pick and shovel more surely on the head and takes a limb more often.'
            de = 'Der Handwerker führt Werkzeug. Mit jeder Stufe sitzen Axt, Hacke und Schaufel genauer auf dem Kopf und trennen öfter ein Glied ab.'
        }
        Lang     = @{
            en = 'Tools in a practised hand. The higher the craftsman stands, the heavier a headshot with axe, pick, shovel or hammer lands, and the more often a limb stays behind. What a rank brings in detail sits on the skills of this tree.'
            de = 'Werkzeug in geübter Hand. Je höher der Handwerker steht, desto schwerer wiegt ein Kopftreffer mit Axt, Hacke, Schaufel oder Hammer, und desto öfter bleibt ein Glied liegen. Was eine Stufe im Einzelnen bringt, steht an den Fertigkeiten dieses Baumes.'
        }
        Raenge   = @(
            @{ en = 'Helper';          de = 'Hilfshand' }
            @{ en = 'Apprentice';      de = 'Lehrjunge' }
            @{ en = 'Journeyman';      de = 'Geselle' }
            @{ en = 'Stone-breaker';   de = 'Steinklopfer' }
            @{ en = 'Ore-digger';      de = 'Erzgräber' }
            @{ en = 'Smith';           de = 'Schmied' }
            @{ en = 'Master carpenter'; de = 'Zimmermeister' }
            @{ en = 'Stonemason';      de = 'Steinmetz' }
            @{ en = 'Workmaster';      de = 'Werkmeister' }
            @{ en = 'Old master';      de = 'Altmeister' }
        )
    },
    @{
        Attribut = 'attFortitude'
        Kurz     = @{ en = 'Warrior';  de = 'Krieger' }
        Name     = @{ en = 'Attribute: Warrior'; de = 'Attribut: Krieger' }
        Desc     = @{
            en = 'The warrior stands and endures. Each rank makes fist and knuckles strike harder at the head, and what he takes knocks him down less often.'
            de = 'Der Krieger steht und hält aus. Mit jeder Stufe treffen Faust und Schlagring härter auf den Kopf, und was er einsteckt, wirft ihn seltener um.'
        }
        Lang     = @{
            en = 'Standing where it is decided. The higher the warrior stands, the heavier a headshot with fist or knuckles lands, and the more often a limb stays behind. What a rank brings in detail sits on the skills of this tree.'
            de = 'Stehen, wo es sich entscheidet. Je höher der Krieger steht, desto schwerer wiegt ein Kopftreffer mit Faust oder Schlagring, und desto öfter bleibt ein Glied liegen. Was eine Stufe im Einzelnen bringt, steht an den Fertigkeiten dieses Baumes.'
        }
        Raenge   = @(
            @{ en = 'Brawler';        de = 'Raufbold' }
            @{ en = 'Levyman';        de = 'Wehrmann' }
            @{ en = 'Shield-bearer';  de = 'Schildträger' }
            @{ en = 'Retainer';       de = 'Gefolgsmann' }
            @{ en = 'Warrior';        de = 'Recke' }
            @{ en = 'Vanguard';       de = 'Vorkämpfer' }
            @{ en = 'Veteran';        de = 'Veteran' }
            @{ en = 'Old blade';      de = 'Haudegen' }
            @{ en = 'Battle-leader';  de = 'Schlachtenlenker' }
            @{ en = 'War-leader';     de = 'Heerführer' }
        )
    },
    @{
        Attribut = 'attAgility'
        Kurz     = @{ en = 'Hunter';  de = 'Jäger' }
        Name     = @{ en = 'Attribute: Hunter'; de = 'Attribut: Jäger' }
        Desc     = @{
            en = 'The hunter strikes from afar and walks quietly. Each rank sets bow, crossbow and knife more surely on the head, and beast and man alike lose a limb more often.'
            de = 'Der Jäger trifft aus der Ferne und geht leise. Mit jeder Stufe sitzen Bogen, Armbrust und Messer genauer auf dem Kopf, und Wild wie Mensch verlieren öfter ein Glied.'
        }
        Lang     = @{
            en = 'Distance and quiet. The higher the hunter stands, the heavier a headshot with bow, crossbow or knife lands, and the more often a limb stays behind. What a rank brings in detail sits on the skills of this tree.'
            de = 'Abstand und Stille. Je höher der Jäger steht, desto schwerer wiegt ein Kopftreffer mit Bogen, Armbrust oder Messer, und desto öfter bleibt ein Glied liegen. Was eine Stufe im Einzelnen bringt, steht an den Fertigkeiten dieses Baumes.'
        }
        Raenge   = @(
            @{ en = 'Snare-setter';   de = 'Schlingensteller' }
            @{ en = 'Trapper';        de = 'Fallensteller' }
            @{ en = 'Track-reader';   de = 'Spurenleser' }
            @{ en = 'Stalker';        de = 'Pirschgänger' }
            @{ en = 'Bowman';         de = 'Bogenschütze' }
            @{ en = 'Spear-thrower';  de = 'Speerwerfer' }
            @{ en = 'Game-warden';    de = 'Wildmeister' }
            @{ en = 'Master tracker'; de = 'Fährtenmeister' }
            @{ en = 'Shadow-walker';  de = 'Schattengänger' }
            @{ en = 'Master hunter';  de = 'Waidmeister' }
        )
    },
    @{
        Attribut = 'attIntellect'
        Kurz     = @{ en = 'Healer';  de = 'Heiler' }
        Name     = @{ en = 'Attribute: Healer'; de = 'Attribut: Heiler' }
        Desc     = @{
            en = 'The healer knows herb, wound and plague. This tree carries no weapon mark: its rank changes no headshot, but what the body endures and how fast it returns.'
            de = 'Der Heiler kennt Kraut, Wunde und Seuche. Dieser Baum trägt keine Waffenmarke: seine Stufe ändert keinen Kopftreffer, sondern was der Körper aushält und wie schnell er zurückkommt.'
        }
        Lang     = @{
            en = 'Herb, wound and plague. This tree carries no weapon mark, so its rank raises no damage. It decides what the body endures and how fast it returns. What a rank brings in detail sits on the skills of this tree.'
            de = 'Kraut, Wunde und Seuche. Dieser Baum trägt keine Waffenmarke, seine Stufe hebt also keinen Schaden. Sie entscheidet, was der Körper aushält und wie schnell er zurückkommt. Was eine Stufe im Einzelnen bringt, steht an den Fertigkeiten dieses Baumes.'
        }
        Raenge   = @(
            @{ en = 'Wound-washer';    de = 'Wundwäscher' }
            @{ en = 'Herb-gatherer';   de = 'Krautsammler' }
            @{ en = 'Herbalist';       de = 'Kräuterkundiger' }
            @{ en = 'Salve-mixer';     de = 'Salbenmischer' }
            @{ en = 'Wound-surgeon';   de = 'Wundarzt' }
            @{ en = 'Bone-setter';     de = 'Beinrichter' }
            @{ en = 'Plague-reader';   de = 'Seuchenkundiger' }
            @{ en = 'Potion-master';   de = 'Trankmeister' }
            @{ en = 'Soul-comforter';  de = 'Seelentröster' }
            @{ en = 'Life-saver';      de = 'Lebensretter' }
        )
    },
    @{
        Attribut = 'attPerception'
        Kurz     = @{ en = 'Carter';  de = 'Fuhrmann' }
        Name     = @{ en = 'Attribute: Carter'; de = 'Attribut: Fuhrmann' }
        Desc     = @{
            en = 'The carter bears, hauls and arrives. Each rank makes the march last longer and the load a matter of habit rather than strength.'
            de = 'Der Fuhrmann trägt, zieht und kommt an. Mit jeder Stufe hält der Marsch länger, und die Last wird eine Sache der Gewöhnung statt der Kraft.'
        }
        Lang     = @{
            en = 'Bearing and arriving. The higher the carter stands, the longer the march lasts and the more the load becomes a matter of habit. What a rank brings in detail sits on the skills of this tree.'
            de = 'Tragen und Ankommen. Je höher der Fuhrmann steht, desto länger hält der Marsch und desto mehr wird die Last eine Sache der Gewöhnung. Was eine Stufe im Einzelnen bringt, steht an den Fertigkeiten dieses Baumes.'
        }
        Raenge   = @(
            @{ en = 'Load-bearer';   de = 'Lastträger' }
            @{ en = 'Pack-carrier';  de = 'Packträger' }
            @{ en = 'Cart-pusher';   de = 'Karrenschieber' }
            @{ en = 'Path-finder';   de = 'Wegfinder' }
            @{ en = 'Drover';        de = 'Treiber' }
            @{ en = 'Muleteer';      de = 'Säumer' }
            @{ en = 'Way-wise';      de = 'Wegkundiger' }
            @{ en = 'March-leader';  de = 'Marschführer' }
            @{ en = 'Train-master';  de = 'Zugmeister' }
            @{ en = 'Way-master';    de = 'Wegmeister' }
        )
    }
)

# ---------------------------------------------------------------------------
# Schlüssel aus dem Spiel lesen
# ---------------------------------------------------------------------------
$xml = [xml](Get-Content $progPfad -Raw)

function Zeile([string] $key, [string] $en, [string] $de) {
    # Spaltenlage der Vanilla-CSV: Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,
    # english,Context / Alternate Text,german, dann 11 weitere Sprachen.
    # 'Context / Alternate Text' steht ZWISCHEN english und german (D7-Falle).
    $enQ = '"' + $en.Replace('"', '""') + '"'
    $deQ = '"' + $de.Replace('"', '""') + '"'
    return "$key,progression,Attribute,,,,$enQ,,$deQ,,,,,,,,,,,"
}

$zeilen = @()
$fehlend = @()

foreach ($b in $baeume) {
    $a = $xml.SelectSingleNode("/progression/attributes/attribute[@name='$($b.Attribut)']")
    if (-not $a) { $fehlend += $b.Attribut; continue }

    # Der kleingeschriebene Kurzschluessel. Er steht NICHT in progression.xml, sondern
    # wird von Localization::Get(ProgressionClass::Name) gebildet - und
    # XUiC_CategoryList::SetupCategoriesByWorkstation zeigt ihn auf den
    # Kategorie-Knöpfen der Werkbank. Gemessen, nicht geraten.
    $zeilen += Zeile $b.Attribut.ToLower() $b.Kurz.en $b.Kurz.de

    $zeilen += Zeile $a.name_key $b.Name.en $b.Name.de
    $zeilen += Zeile $a.desc_key $b.Desc.en $b.Desc.de

    $raenge = @($a.SelectNodes('effect_group/effect_description'))
    if ($raenge.Count -ne $b.Raenge.Count) {
        throw ("$($b.Attribut): das Spiel führt $($raenge.Count) Raenge, die Zuordnung $($b.Raenge.Count). Tabelle anpassen, nicht raten.")
    }
    for ($i = 0; $i -lt $raenge.Count; $i++) {
        $ed = $raenge[$i]
        $r  = $b.Raenge[$i]
        if ($ed.desc_key)      { $zeilen += Zeile $ed.desc_key      $r.en      $r.de }
        if ($ed.long_desc_key) { $zeilen += Zeile $ed.long_desc_key $b.Lang.en $b.Lang.de }
    }
}

if ($fehlend.Count -gt 0) { throw ("Attribute im Build nicht gefunden: " + ($fehlend -join ', ')) }

# Doppelte Schlüssel sind ein Fehler, nicht ein Schönheitsfleck: der letzte gewinnt
# und der erste ist still verschwunden.
$doppelt = $zeilen | ForEach-Object { ($_ -split ',')[0] } | Group-Object | Where-Object { $_.Count -gt 1 }
if ($doppelt) { throw ("Doppelte Schlüssel: " + (($doppelt | ForEach-Object { $_.Name }) -join ', ')) }

$zeilen | Set-Content -Path $Aus -Encoding UTF8
Write-Output ("$($zeilen.Count) Zeilen geschrieben: $Aus")
Write-Output ("Bäume: " + (($baeume | ForEach-Object { "$($_.Attribut)=$($_.Kurz.de)" }) -join ', '))
