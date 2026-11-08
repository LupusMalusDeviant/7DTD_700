#Requires -Version 5.1
# wp7-perks.ps1 — erzeugt die Patch-Zeilen und Localization-Zeilen fuer WP7.2:
# die 16 Vanilla-Unterbereiche und 45 lebende Perks an die fuenf Baeume umhaengen.
#
# WARUM EIN ERZEUGER:
# Jeder umgehaengte Perk braucht SECHS Patch-Zeilen — eine fuer 'parent' und FUENF fuer
# die progression_name in seinen level_requirements. Gemessen hat jeder der 50
# Attribut-Perks genau fuenf davon, und jede nennt sein altes Attribut. Wird eine
# vergessen, haengt der Perk unter dem neuen Baum und verlangt die Stufe des alten:
# unerreichbar, ohne eine Fehlermeldung. 21 Perks wechseln das Attribut, das sind 105
# Zeilen, die von Hand stimmen muessten.
#
# Die Tabellen unten sind die Entscheidung (D66, D67). Das Skript liest die Struktur
# aus progression.xml des Builds und bricht ab, sobald die Wirklichkeit nicht zur
# Tabelle passt: unbekannter Perk, unbekannter Unterbereich, andere Zahl von
# level_requirements, ein Perk ohne Zuordnung.
#
# Aufruf:
#   powershell -File tools/gen/wp7-perks.ps1 -Spiel <pfad>
# Schreibt nach tools/gen/out/:
#   wp7-perks-progression.xml   Patch-Zeilen fuer mod/700_50_Fortschritt/Config/
#   wp7-perks-items.xml         Patch-Zeilen fuer die Gegenstands-Marken
#   wp7-perks-texte.csv         Localization-Zeilen ohne Kopfzeile

[CmdletBinding()]
param(
    [string] $Spiel = $env:SDTD_PATH,
    [string] $AusOrdner
)

$ErrorActionPreference = 'Stop'

if (-not $Spiel) { throw "Kein Spielpfad: SDTD_PATH setzen oder -Spiel angeben." }
$progPfad = Join-Path $Spiel 'Data\Config\progression.xml'
$itemPfad = Join-Path $Spiel 'Data\Config\items.xml'
foreach ($f in @($progPfad, $itemPfad)) { if (-not (Test-Path $f)) { throw "Nicht gefunden: $f" } }

if (-not $AusOrdner) {
    $AusOrdner = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'out'
}
if (-not (Test-Path $AusOrdner)) { New-Item -ItemType Directory -Path $AusOrdner | Out-Null }

# ===========================================================================
# 1  Die fuenf Baeume (D66). Reihenfolge wie im GDD.
# ===========================================================================
$baeume = [ordered]@{
    attStrength   = @{ de = 'Handwerker'; en = 'Craftsman' }
    attFortitude  = @{ de = 'Krieger';    en = 'Warrior' }
    attAgility    = @{ de = 'Jäger';      en = 'Hunter' }
    attIntellect  = @{ de = 'Heiler';     en = 'Healer' }
    attPerception = @{ de = 'Fuhrmann';   en = 'Carter' }
}

# ===========================================================================
# 2  Die 16 Unterbereiche. 'Attribut' ist das ZIEL, nicht der Vanilla-Stand.
#    'Verborgen' heisst: nach dem Umhaengen leer, darum hidden="true".
# ===========================================================================
$bereiche = @(
    @{ Name = 'skillStrengthCombat';        Attribut = 'attFortitude';
       De = 'Wuchtwaffen';        En = 'Heavy arms'
       DeDesc = 'Keule, Vorschlaghammer und Schlagstock: schwere Schläge, die durch Schild und Helm gehen.'
       EnDesc = 'Club, sledgehammer and baton: heavy blows that go through shield and helm.' }
    @{ Name = 'skillFortitudeCombat';       Attribut = 'attFortitude';
       De = 'Faustkampf';         En = 'Fist fighting'
       DeDesc = 'Die bloße Hand und der Schlagring. Was man immer dabei hat.'
       EnDesc = 'The bare hand and the knuckles. What you always carry.' }
    @{ Name = 'skillFortitudeSurvival';     Attribut = 'attFortitude';
       De = 'Zähigkeit';          En = 'Toughness'
       DeDesc = 'Mehr einstecken, länger stehen, aus dem Schlag etwas zurückholen.'
       EnDesc = 'Take more, stand longer, win something back from the blow.' }

    @{ Name = 'skillAgilityCombat';         Attribut = 'attAgility';
       De = 'Bogen und Messer';   En = 'Bow and knife'
       DeDesc = 'Der Schuss aus der Deckung und der Schnitt aus der Nähe.'
       EnDesc = 'The shot from cover and the cut up close.' }
    @{ Name = 'skillAgilityStealth';        Attribut = 'attAgility';
       De = 'Pirsch';             En = 'Stalking'
       DeDesc = 'Leise gehen, ungesehen bleiben, den ersten Schlag setzen.'
       EnDesc = 'Walk quietly, stay unseen, land the first blow.' }
    @{ Name = 'skillPerceptionCombat';      Attribut = 'attAgility';
       De = 'Wurfwaffen';         En = 'Thrown arms'
       DeDesc = 'Der Speer, geworfen und geführt.'
       EnDesc = 'The spear, thrown and wielded.' }
    @{ Name = 'skillPerceptionGeneral';     Attribut = 'attAgility';
       De = 'Fährte';             En = 'Tracking'
       DeDesc = 'Spuren lesen, Wild finden, das Erlegte verwerten.'
       EnDesc = 'Read tracks, find game, make use of the kill.' }

    @{ Name = 'skillStrengthConstruction';  Attribut = 'attStrength';
       De = 'Bergbau';            En = 'Mining'
       DeDesc = 'Stein brechen, Erz holen, Werkzeug führen, ohne es zu zerschlagen.'
       EnDesc = 'Break stone, win ore, wield tools without wrecking them.' }
    @{ Name = 'skillIntellectCraftsmanship'; Attribut = 'attStrength';
       De = 'Werkstattkunde';     En = 'Workshop lore'
       DeDesc = 'Die Werkstätten und was sie hergeben.'
       EnDesc = 'The workshops and what they yield.' }

    @{ Name = 'skillFortitudeRecovery';     Attribut = 'attIntellect';
       De = 'Heilkunde';          En = 'Leechcraft'
       DeDesc = 'Wunden versorgen, Krankheit lesen, den Körper wiederherstellen.'
       EnDesc = 'Dress wounds, read sickness, set the body right again.' }

    @{ Name = 'skillAgilityAthletics';      Attribut = 'attPerception';
       De = 'Marsch';             En = 'The march'
       DeDesc = 'Weiter kommen, schneller ausweichen, den Weg aushalten.'
       EnDesc = 'Get farther, dodge faster, endure the road.' }
    @{ Name = 'skillStrengthGeneral';       Attribut = 'attPerception';
       De = 'Tragkraft';          En = 'Load-bearing'
       DeDesc = 'Mehr auf dem Rücken, und es dennoch den Tag lang tragen.'
       EnDesc = 'More on the back, and still carrying it all day.' }
    @{ Name = 'skillIntellectInfluence';    Attribut = 'attPerception';
       De = 'Handel und Wege';    En = 'Trade and roads'
       DeDesc = 'Wissen, wo etwas liegt, und was es wert ist.'
       EnDesc = 'Know where something lies, and what it is worth.' }

    # Nach dem Umhaengen leer: beide Unterbereiche halten nur noch verborgene Perks.
    @{ Name = 'skillIntellectCombat';       Attribut = $null; Verborgen = $true
       De = '';                   En = ''; DeDesc = ''; EnDesc = '' }
    @{ Name = 'skillPerceptionScavenging';  Attribut = $null; Verborgen = $true
       De = '';                   En = ''; DeDesc = ''; EnDesc = '' }

    # Bleibt unveraendert unter attGeneralPerks (siehe Begruendung unten bei $bleiben).
    @{ Name = 'skillGeneralPerks';          Attribut = $null; Unberuehrt = $true
       De = '';                   En = ''; DeDesc = ''; EnDesc = '' }
)

# ===========================================================================
# 3  Die Perks. 'Bereich' ist der ZIEL-Unterbereich.
# ===========================================================================
$perks = @(
    # --- Krieger ----------------------------------------------------------
    @{ Name = 'perkPummelPete';      Bereich = 'skillStrengthCombat'
       De = 'Keulenschlag';     En = 'Club blow'
       DeDesc = 'Die Keule trifft härter und wirft den Getroffenen weiter zurück.'
       EnDesc = 'The club hits harder and throws the struck one farther back.' }
    @{ Name = 'perkSkullCrusher';    Bereich = 'skillStrengthCombat'
       De = 'Schädelbrecher';   En = 'Skull-breaker'
       DeDesc = 'Der Vorschlaghammer zerschlägt, was unter dem Helm sitzt.'
       EnDesc = 'The sledgehammer breaks what sits beneath the helm.' }
    @{ Name = 'perkGrandSlam';       Bereich = 'skillStrengthCombat'
       De = 'Rundschlag';       En = 'Round blow'
       DeDesc = 'Der Schlagstock holt weiter aus und nimmt mehr mit.'
       EnDesc = 'The baton swings wider and takes more with it.' }
    @{ Name = 'perkFlurryOfStrength'; Bereich = 'skillStrengthCombat'
       De = 'Schlagfolge';      En = 'Blow upon blow'
       DeDesc = 'Keule und Hammer kommen schneller hintereinander.'
       EnDesc = 'Club and hammer come faster one after another.' }
    @{ Name = 'perkBrawler';         Bereich = 'skillFortitudeCombat'
       De = 'Raufhandwerk';     En = 'Brawling'
       DeDesc = 'Faust und Schlagring treffen härter und öfter ins Gesicht.'
       EnDesc = 'Fist and knuckles hit harder and more often in the face.' }
    @{ Name = 'perkFlurryOfFortitude'; Bereich = 'skillFortitudeCombat'
       De = 'Schlaghagel';      En = 'Hail of blows'
       DeDesc = 'Die Fäuste kommen schneller hintereinander.'
       EnDesc = 'The fists come faster one after another.' }
    @{ Name = 'perkPainTolerance';   Bereich = 'skillFortitudeSurvival'
       De = 'Schmerzhärte';     En = 'Pain-hardened'
       DeDesc = 'Ein Treffer wirft seltener aus dem Stand.'
       EnDesc = 'A hit knocks you off your feet less often.' }
    @{ Name = 'perkFortitudeMastery'; Bereich = 'skillFortitudeSurvival'
       De = 'Standhaftigkeit';  En = 'Steadfastness'
       DeDesc = 'Mehr Leben, Stufe für Stufe.'
       EnDesc = 'More life, rank by rank.' }
    @{ Name = 'perkSiphoningStrikes'; Bereich = 'skillFortitudeSurvival'
       De = 'Blutzoll';         En = 'Blood-toll'
       DeDesc = 'Jeder Nahkampftreffer holt ein wenig Leben zurück.'
       EnDesc = 'Every melee hit wins a little life back.' }

    # --- Jäger ------------------------------------------------------------
    @{ Name = 'perkArchery';         Bereich = 'skillAgilityCombat'
       De = 'Bogenschießen';    En = 'Archery'
       DeDesc = 'Bogen und Armbrust schießen härter, schneller und ruhiger.'
       EnDesc = 'Bow and crossbow shoot harder, faster and steadier.' }
    @{ Name = 'perkDeepCuts';        Bereich = 'skillAgilityCombat'
       De = 'Tiefer Schnitt';   En = 'Deep cuts'
       DeDesc = 'Das Messer schneidet tiefer, und die Wunde blutet weiter.'
       EnDesc = 'The knife cuts deeper, and the wound keeps bleeding.' }
    @{ Name = 'perkFlurryOfAgility'; Bereich = 'skillAgilityCombat'
       De = 'Schnittfolge';     En = 'Cut upon cut'
       DeDesc = 'Das Messer kommt schneller hintereinander.'
       EnDesc = 'The knife comes faster one after another.' }
    @{ Name = 'perkAgilityMastery';  Bereich = 'skillAgilityCombat'
       De = 'Ruhige Hand';      En = 'Steady hand'
       DeDesc = 'Schneller nachgelegt, und Schaden prallt eher ab.'
       EnDesc = 'Faster to nock again, and damage glances off sooner.' }
    @{ Name = 'perkHiddenStrike';    Bereich = 'skillAgilityStealth'
       De = 'Hinterhalt';       En = 'Ambush'
       DeDesc = 'Der erste Schlag auf einen Unaufmerksamen wiegt schwerer.'
       EnDesc = 'The first blow on an unwary one weighs heavier.' }
    @{ Name = 'perkFromTheShadows';  Bereich = 'skillAgilityStealth'
       De = 'Aus dem Dunkel';   En = 'Out of the dark'
       DeDesc = 'Leiser gehen, später gesehen werden.'
       EnDesc = 'Walk quieter, be seen later.' }
    @{ Name = 'perkInfiltrator';     Bereich = 'skillAgilityStealth'
       De = 'Schleichgang';     En = 'Creeping'
       DeDesc = 'Schlösser, Riegel und wache Augen werden zum lösbaren Problem.'
       EnDesc = 'Locks, bolts and waking eyes become a solvable problem.' }
    @{ Name = 'perkJavelinMaster';   Bereich = 'skillPerceptionCombat'
       De = 'Speerkunde';       En = 'Spear lore'
       DeDesc = 'Der Speer trifft härter, geworfen wie geführt, und kommt zurück.'
       EnDesc = 'The spear hits harder, thrown or wielded, and comes back.' }
    @{ Name = 'perkFlurryOfPerception'; Bereich = 'skillPerceptionCombat'
       De = 'Stoßfolge';        En = 'Thrust upon thrust'
       DeDesc = 'Der Speer kommt schneller hintereinander.'
       EnDesc = 'The spear comes faster one after another.' }
    @{ Name = 'perkAnimalTracker';   Bereich = 'skillPerceptionGeneral'
       De = 'Fährtenlesen';     En = 'Track-reading'
       DeDesc = 'Wild zeigt sich auf der Karte, und man sieht, wohin es gegangen ist.'
       EnDesc = 'Game shows on the map, and you see where it went.' }
    @{ Name = 'perkPenetrator';      Bereich = 'skillPerceptionGeneral'
       De = 'Durchschlag';      En = 'Punch-through'
       DeDesc = 'Pfeil und Bolzen gehen durch Deckung und durch mehr als einen.'
       EnDesc = 'Arrow and bolt go through cover and through more than one.' }
    @{ Name = 'perkTheHuntsman';     Bereich = 'skillPerceptionGeneral'
       De = 'Waidwerk';         En = 'Huntsmanship'
       DeDesc = 'Aus einem Tier kommt mehr Fleisch, Fett, Knochen und Haut.'
       EnDesc = 'More meat, fat, bone and hide come out of an animal.' }

    # --- Handwerker -------------------------------------------------------
    @{ Name = 'perkMiner69r';        Bereich = 'skillStrengthConstruction'
       De = 'Steinmetz';        En = 'Stonemason'
       DeDesc = 'Werkzeug schlägt härter in Stein, Erz und Holz.'
       EnDesc = 'Tools bite harder into stone, ore and wood.' }
    @{ Name = 'perkMotherLode';      Bereich = 'skillStrengthConstruction'
       De = 'Reiche Ader';      En = 'Rich seam'
       DeDesc = 'Aus demselben Stein kommt mehr heraus.'
       EnDesc = 'More comes out of the same stone.' }
    @{ Name = 'perkStrengthMastery'; Bereich = 'skillStrengthConstruction'
       De = 'Geübte Faust';     En = 'Practised fist'
       DeDesc = 'Mehr Ausbeute aus Beschlägen, und das Werkzeug trifft genauer.'
       EnDesc = 'More yield from fittings, and the tool strikes truer.' }
    @{ Name = 'perkAdvancedEngineering'; Bereich = 'skillIntellectCraftsmanship'
       De = 'Werkstattkunst';   En = 'Workshop craft'
       DeDesc = 'Die Werkstätten arbeiten schneller und geben mehr her.'
       EnDesc = 'The workshops work faster and yield more.' }

    # --- Heiler -----------------------------------------------------------
    @{ Name = 'perkPhysician';       Bereich = 'skillFortitudeRecovery'
       De = 'Wundarznei';       En = 'Wound-leechcraft'
       DeDesc = 'Verbände wirken stärker und schneller, und man braucht weniger davon.'
       EnDesc = 'Dressings work stronger and faster, and fewer are needed.' }
    @{ Name = 'perkHealingFactor';   Bereich = 'skillFortitudeRecovery'
       De = 'Heilschlaf';       En = 'Healing sleep'
       DeDesc = 'Wunden schließen sich von selbst, auch ohne Verband.'
       EnDesc = 'Wounds close on their own, even without a dressing.' }
    @{ Name = 'perkSlowMetabolism';  Bereich = 'skillFortitudeRecovery'
       De = 'Karge Kost';       En = 'Sparing fare'
       DeDesc = 'Hunger und Durst kommen langsamer.'
       EnDesc = 'Hunger and thirst come slower.' }
    @{ Name = 'perkRuleOneCardio';   Bereich = 'skillFortitudeRecovery'
       De = 'Langer Atem';      En = 'Long breath'
       DeDesc = 'Mehr Ausdauer, und sie kommt schneller zurück.'
       EnDesc = 'More stamina, and it returns faster.' }

    # --- Fuhrmann ---------------------------------------------------------
    @{ Name = 'perkPackMule';        Bereich = 'skillStrengthGeneral'
       De = 'Saumlast';         En = 'Pack-load'
       DeDesc = 'Mehr Platz im Gepäck, und die Last wiegt weniger schwer.'
       EnDesc = 'More room in the pack, and the load weighs less.' }
    @{ Name = 'perkPerceptionMastery'; Bereich = 'skillStrengthGeneral'
       De = 'Geübtes Auge';     En = 'Practised eye'
       DeDesc = 'Mehr Ausbeute beim Zerlegen, und der Stoß sitzt genauer.'
       EnDesc = 'More yield when taking things apart, and the thrust sits truer.' }
    @{ Name = 'perkParkour';         Bereich = 'skillAgilityAthletics'
       De = 'Trittsicherheit';  En = 'Sure-footed'
       DeDesc = 'Höher springen, tiefer fallen, ohne sich etwas zu brechen.'
       EnDesc = 'Jump higher, fall farther, without breaking anything.' }
    @{ Name = 'perkRunAndGun';       Bereich = 'skillAgilityAthletics'
       De = 'Im Gehen';         En = 'On the move'
       DeDesc = 'Treffen, während man läuft.'
       EnDesc = 'Hit while you are running.' }
    @{ Name = 'perkHardTarget';      Bereich = 'skillAgilityAthletics'
       De = 'Schweres Ziel';    En = 'Hard target'
       DeDesc = 'Schwerer zu treffen, solange man sich bewegt.'
       EnDesc = 'Harder to hit while you keep moving.' }
    @{ Name = 'perkBetterBarter';    Bereich = 'skillIntellectInfluence'
       De = 'Feilschen';        En = 'Haggling'
       DeDesc = 'Billiger einkaufen, teurer verkaufen.'
       EnDesc = 'Buy cheaper, sell dearer.' }
    @{ Name = 'perkDaringAdventurer'; Bereich = 'skillIntellectInfluence'
       De = 'Wagemut';          En = 'Daring'
       DeDesc = 'Wer einen Auftrag erfüllt, bekommt mehr dafür.'
       EnDesc = 'Whoever fulfils a charge gets more for it.' }
    @{ Name = 'perkCharismaticNature'; Bereich = 'skillIntellectInfluence'
       De = 'Gutes Wort';       En = 'A good word'
       DeDesc = 'Wer mitzieht, zieht besser — der Trupp wird stärker.'
       EnDesc = 'Those who travel with you fare better.' }
    @{ Name = 'perkTreasureHunter';  Bereich = 'skillIntellectInfluence'
       De = 'Schatzwitterung';  En = 'Nose for hoards'
       DeDesc = 'Vergrabenes zeigt sich genauer und früher.'
       EnDesc = 'What is buried shows itself more precisely and sooner.' }
)

# ===========================================================================
# 4  Was ABSICHTLICH nicht angefasst wird
# ===========================================================================
# Die sieben Perks unter skillGeneralPerks (Rüstung leicht/mittel/schwer, Küchenmeister,
# Vom Land leben, Schlossknacken, Glückspilz) bleiben, wo sie sind. GEMESSEN haben sie
# NULL level_requirements - sie hängen an keinem Attribut, sondern am Spielerrang. Sie in
# einen Baum zu hängen hieße, fünf Freischaltstufen je Perk zu ERFINDEN, und das ist eine
# Balancing-Entscheidung und keine Strukturfrage. Gehört zu WP9 bzw. WP7.2b.
$bleiben = @('perkLightArmor','perkMediumArmor','perkHeavyArmor','perkMasterChef',
             'perkLivingOffTheLand','perkLockPicking','perkLuckyLooter')

# Zwölf Perks ohne Gegenstände. Zehn stehen schon in WP7.3; zwei kommen hier dazu, weil
# erst die Messung der Wirkung sie entlarvt hat:
#   perkIntellectMastery  wirkt NUR auf Fahrzeuge (VehicleFuelUsePer, VehicleSelfDamage
#                         mit der Marke 'vehicle') - und vehicle* ist 16 von 17 gesperrt.
#   perkFlurryOfIntellect traegt seine Marke gemessen auf 2 Gegenstaenden, beide gesperrt.
$neuVerborgen = @('perkIntellectMastery','perkFlurryOfIntellect')
$schonVerborgen = @('perkDeadEye','perkBoomstick','perkGunslinger','perkMachineGunner',
                    'perkDemolitionsExpert','perkElectrocutioner','perkTurrets',
                    'perkGreaseMonkey','perkJunkMiner','perkSalvageOperations')

# ===========================================================================
# 4b  Die 14 ueberlebenden Handwerks-Stufen an die Baeume (D68).
#
# Sie haengen in Vanilla alle an attCrafting und sind die TIEFE der Baeume, die der Purge
# duenn gemacht hat: craftingWorkstations behaelt 15 von 20 Marken, craftingHarvestingTools
# 8 von 10, craftingMedical 1 von 8. Vier Perks plus vier Handwerks-Stufen sind ein Baum,
# vier Perks allein sind keiner.
#
# RISIKO R8, vom Nutzer getragen: XUiC_CategoryList::SetupCategoriesByWorkstation liest die
# Zeichenkette "attcrafting". Gemessen filtert die Methode IsAttribute und nutzt nur
# ProgressionClass::Name und ::Icon - die Handwerks-Stufen also nicht, und Hidden liest sie
# auch nicht. Das ist ein Schluss aus der Aufrufliste, kein beobachtetes Verhalten
# (Pruefliste 15).
#
# attCrafting selbst bleibt BESTEHEN (die Zeichenkette im Code zeigt darauf) und wird nur
# verborgen, weil es nach dem Umhaengen ein leerer Behaelter mit Vanilla-Namen waere.
$handwerk = @(
    @{ Name = 'craftingHarvestingTools'; Attribut = 'attStrength'
       De = 'Werkzeugschmiede';  En = 'Toolsmithing'
       DeDesc = 'Axt, Hacke und Schaufel schmieden und in besserer Güte.'
       EnDesc = 'Forge axe, pick and shovel, and in better grade.' }
    @{ Name = 'craftingRepairTools';     Attribut = 'attStrength'
       De = 'Flickwerk';         En = 'Mending'
       DeDesc = 'Hammer und Flicken, mit denen man alles andere wieder herrichtet.'
       EnDesc = 'Hammer and patch, with which everything else is set right again.' }
    @{ Name = 'craftingWorkstations';    Attribut = 'attStrength'
       De = 'Werkstattbau';      En = 'Workshop building'
       DeDesc = 'Rennofen, Esse, Zimmermannsbank, Kalkofen und was dazugehört.'
       EnDesc = 'Bloomery, forge, carpenter''s bench, lime kiln and what belongs to them.' }
    @{ Name = 'craftingArmor';           Attribut = 'attStrength'
       De = 'Rüstungsbau';       En = 'Armouring'
       DeDesc = 'Wolle, Leder, Gambeson und Kette, genäht und genietet.'
       EnDesc = 'Wool, leather, gambeson and mail, sewn and riveted.' }

    @{ Name = 'craftingKnuckles';        Attribut = 'attFortitude'
       De = 'Schlagringe';       En = 'Knuckles'
       DeDesc = 'Was man um die Faust legt, wenn nichts anderes zur Hand ist.'
       EnDesc = 'What you wrap around the fist when nothing else is to hand.' }
    @{ Name = 'craftingClubs';           Attribut = 'attFortitude'
       De = 'Keulenbau';         En = 'Club-making'
       DeDesc = 'Holz, Beschlag und Griff: die einfachste Waffe und die zuverlässigste.'
       EnDesc = 'Wood, fitting and grip: the simplest weapon and the most reliable.' }
    @{ Name = 'craftingSledgehammers';   Attribut = 'attFortitude'
       De = 'Hammerbau';         En = 'Hammer-making'
       DeDesc = 'Der schwere Kopf auf dem langen Schaft.'
       EnDesc = 'The heavy head on the long shaft.' }

    @{ Name = 'craftingBlades';          Attribut = 'attAgility'
       De = 'Klingenschmiede';   En = 'Bladesmithing'
       DeDesc = 'Messer aus Knochen, Eisen und Stahl, geschärft und gehärtet.'
       EnDesc = 'Knives of bone, iron and steel, sharpened and hardened.' }
    @{ Name = 'craftingBows';            Attribut = 'attAgility'
       De = 'Bogenbau';          En = 'Bowyery'
       DeDesc = 'Bogen, Armbrust, Pfeil und Bolzen.'
       EnDesc = 'Bow, crossbow, arrow and bolt.' }
    @{ Name = 'craftingSpears';          Attribut = 'attAgility'
       De = 'Speerbau';          En = 'Spear-making'
       DeDesc = 'Spitze, Schaft und Bindung.'
       EnDesc = 'Head, shaft and binding.' }

    @{ Name = 'craftingMedical';         Attribut = 'attIntellect'
       De = 'Wundversorgung';    En = 'Wound-dressing'
       DeDesc = 'Verband, Salbe und was eine Wunde schließt.'
       EnDesc = 'Dressing, salve and what closes a wound.' }
    @{ Name = 'craftingFood';            Attribut = 'attIntellect'
       De = 'Küche';             En = 'Cookery'
       DeDesc = 'Kochen, braten, einlegen — und wissen, was gegessen werden kann.'
       EnDesc = 'Boil, roast, preserve — and know what can be eaten.' }
    @{ Name = 'craftingSeeds';           Attribut = 'attIntellect'
       De = 'Kräutergarten';     En = 'Herb garden'
       DeDesc = 'Saat ziehen und Kraut setzen.'
       EnDesc = 'Raise seed and set herbs.' }

    @{ Name = 'craftingBackpack';        Attribut = 'attPerception'
       De = 'Sattlerei';         En = 'Saddlery'
       DeDesc = 'Ranzen, Riemen und Traggestell.'
       EnDesc = 'Pack, strap and carrying frame.' }
)

# ===========================================================================
# 5  Gegenstands-Marken umhaengen. Marke und Perk wandern in EINEM Stueck.
# ===========================================================================
$marken = @(
    @{ Von = 'attStrength';   Nach = 'attFortitude'; Grund = 'Keulen und Vorschlaghaemmer gehoeren zum Krieger'
       Gegenstaende = @('meleeWpnClubT0WoodenClub','meleeWpnClubT1CandyClub','meleeWpnClubT3SteelClub',
                        'meleeWpnSledgeT0StoneSledgehammer','meleeWpnSledgeT1IronSledgehammer',
                        'meleeWpnSledgeT3SteelSledgehammer') }
    @{ Von = 'attPerception'; Nach = 'attAgility';   Grund = 'Speere gehoeren zum Jaeger'
       Gegenstaende = @('meleeWpnSpearT0StoneSpear','meleeWpnSpearT1IronSpear','meleeWpnSpearT3SteelSpear') }
)

# ===========================================================================
# Pruefen, dass die Tabellen zur Wirklichkeit passen
# ===========================================================================
$prog = [xml](Get-Content $progPfad -Raw)
$items = [xml](Get-Content $itemPfad -Raw)

$bereichNachAttribut = @{}
foreach ($b in $bereiche) { $bereichNachAttribut[$b.Name] = $b.Attribut }

$alleVanillaBereiche = @($prog.SelectNodes('//skill') | ForEach-Object { $_.name })
$alleVanillaPerks    = @($prog.SelectNodes('//perk')  | ForEach-Object { $_.name })

$fehler = @()

foreach ($n in $alleVanillaBereiche) {
    if (-not $bereichNachAttribut.ContainsKey($n)) { $fehler += "Unterbereich '$n' steht im Spiel, aber nicht in der Tabelle." }
}
foreach ($b in $bereiche) {
    if ($alleVanillaBereiche -notcontains $b.Name) { $fehler += "Unterbereich '$($b.Name)' steht in der Tabelle, aber nicht im Spiel." }
}

$zugeordnet = @{}
foreach ($k in $perks) { $zugeordnet[$k.Name] = $k }
$abgedeckt = @($perks | ForEach-Object { $_.Name }) + $bleiben + $neuVerborgen + $schonVerborgen
foreach ($n in $alleVanillaPerks) {
    if ($abgedeckt -notcontains $n) { $fehler += "Perk '$n' hat keine Zuordnung - weder Baum noch 'bleibt' noch 'verborgen'." }
}
foreach ($n in $abgedeckt) {
    if ($alleVanillaPerks -notcontains $n) { $fehler += "Perk '$n' steht in einer Tabelle, aber nicht im Spiel." }
}
foreach ($k in $perks) {
    if (-not $bereichNachAttribut.ContainsKey($k.Bereich)) { $fehler += "Perk '$($k.Name)' zeigt auf den unbekannten Unterbereich '$($k.Bereich)'." }
    elseif (-not $bereichNachAttribut[$k.Bereich]) { $fehler += "Perk '$($k.Name)' zeigt auf '$($k.Bereich)', und der ist verborgen bzw. unberuehrt." }
}
foreach ($m in $marken) {
    foreach ($g in $m.Gegenstaende) {
        $it = $items.SelectSingleNode("//item[@name='$g']")
        if (-not $it) { $fehler += "Gegenstand '$g' gibt es nicht."; continue }
        $t = $it.SelectSingleNode("property[@name='Tags']")
        if (-not $t) { $fehler += "Gegenstand '$g' fuehrt keine eigene Tags-Eigenschaft (geerbt?)."; continue }
        if (($t.value -split ',') -notcontains $m.Von) { $fehler += "Gegenstand '$g' traegt die Marke '$($m.Von)' nicht." }
    }
}

if ($fehler.Count -gt 0) {
    foreach ($f in $fehler) { Write-Output "FEHLER: $f" }
    throw "Die Tabellen passen nicht zum Build. Nichts geschrieben."
}

# ===========================================================================
# Patch-Zeilen fuer progression.xml
# ===========================================================================
$pz = @()
$pz += '<?xml version="1.0" encoding="UTF-8" ?>'
$pz += '<config>'
$pz += "`t<!-- ERZEUGT von tools/gen/wp7-perks.ps1 - nicht von Hand aendern."
$pz += "`t     Die Zuordnung steht in der Tabelle dieses Skripts (D66, D67). -->"
$pz += ''

$umgehaengteBereiche = 0
$pz += "`t<!-- Dreizehn Unterbereiche an ihren Baum -->"
foreach ($b in $bereiche) {
    if ($b.Unberuehrt -or $b.Verborgen) { continue }
    $ist = $prog.SelectSingleNode("//skill[@name='$($b.Name)']").parent
    if ($ist -ne $b.Attribut) {
        $pz += "`t<set xpath=`"/progression/skills/skill[@name='$($b.Name)']/@parent`">$($b.Attribut)</set>"
        $umgehaengteBereiche++
    } else {
        $pz += "`t<!-- $($b.Name) liegt schon an $($b.Attribut) ($($baeume[$b.Attribut].de)) -->"
    }
}
$pz += ''
$pz += "`t<!-- Zwei Unterbereiche sind nach dem Umhaengen leer -->"
foreach ($b in $bereiche) {
    if (-not $b.Verborgen) { continue }
    $pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/skills/skill[@name='$($b.Name)']`">true</setattribute>"
}
$pz += ''
$pz += "`t<!-- Zwei weitere Perks ohne Gegenstaende, erst durch die Wirkungsmessung erkannt -->"
foreach ($n in $neuVerborgen) {
    $pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/perks/perk[@name='$n']`">true</setattribute>"
}
$pz += ''

# D68: die 14 ueberlebenden Handwerks-Stufen an die Baeume.
$handwerkUmgehaengt = 0
$pz += "`t<!-- D68: die 14 ueberlebenden Handwerks-Stufen von attCrafting an die Baeume -->"
foreach ($h in $handwerk) {
    $c = $prog.SelectSingleNode("//crafting_skill[@name='$($h.Name)']")
    if (-not $c) { throw "Handwerks-Stufe '$($h.Name)' gibt es nicht." }
    if ($c.parent -eq $h.Attribut) { $pz += "`t<!-- $($h.Name) liegt schon an $($h.Attribut) -->"; continue }
    $pz += "`t<set xpath=`"/progression/crafting_skills/crafting_skill[@name='$($h.Name)']/@parent`">$($h.Attribut)</set>   <!-- $($baeume[$h.Attribut].de) / $($h.De) -->"
    $handwerkUmgehaengt++
}
$pz += ''
$pz += "`t<!-- attCrafting BLEIBT BESTEHEN - XUiC_CategoryList::SetupCategoriesByWorkstation liest"
$pz += "`t     die Zeichenkette 'attcrafting'. Es wird nur verborgen, weil es nach dem Umhaengen"
$pz += "`t     ein leerer Behaelter mit Vanilla-Namen waere. Gemessen liest die genannte Methode"
$pz += "`t     ProgressionClass::Hidden NICHT, der Kategorie-Knopf bleibt also. -->"
$pz += "`t<setattribute name=`"hidden`" xpath=`"/progression/attributes/attribute[@name='attCrafting']`">true</setattribute>"
$pz += ''

$umgehaengtePerks = 0
$reqZeilen = 0
foreach ($k in $perks) {
    $knoten = $prog.SelectSingleNode("//perk[@name='$($k.Name)']")
    $neuesAttribut = $bereichNachAttribut[$k.Bereich]
    $zeilen = @()

    if ($knoten.parent -ne $k.Bereich) {
        $zeilen += "`t<set xpath=`"/progression/perks/perk[@name='$($k.Name)']/@parent`">$($k.Bereich)</set>"
        $umgehaengtePerks++
    }

    # Die FUENF level_requirements. Jedes nennt sein Attribut einzeln.
    $reqs = @($knoten.SelectNodes("level_requirements/requirement[@name='ProgressionLevel']"))
    if ($reqs.Count -ne 5) { throw "$($k.Name): $($reqs.Count) level_requirements statt 5. Tabelle pruefen, nicht raten." }
    foreach ($r in $reqs) {
        if ($r.progression_name -eq $neuesAttribut) { continue }
        $lvl = $r.ParentNode.GetAttribute('level')
        $zeilen += "`t<set xpath=`"/progression/perks/perk[@name='$($k.Name)']/level_requirements[@level='$lvl']/requirement[@name='ProgressionLevel']/@progression_name`">$neuesAttribut</set>"
        $reqZeilen++
    }

    if ($zeilen.Count -gt 0) {
        $pz += "`t<!-- $($k.Name) -> $($baeume[$neuesAttribut].de) / $($k.De) -->"
        $pz += $zeilen
    }
}

# ===========================================================================
# Patch-Zeilen fuer items.xml
# ===========================================================================
$iz = @()
$iz += '<?xml version="1.0" encoding="UTF-8" ?>'
$iz += '<config>'
$iz += "`t<!-- ERZEUGT von tools/gen/wp7-perks.ps1 - nicht von Hand aendern."
$iz += "`t     Marke und Perk wandern in EINEM Stueck: ein Perk unter einem Baum und sein"
$iz += "`t     Gegenstand unter einem anderen waere ein Perk, den niemand nutzen kann. -->"
$markenZeilen = 0
foreach ($m in $marken) {
    $iz += ''
    $iz += "`t<!-- $($m.Von) -> $($m.Nach): $($m.Grund) -->"
    foreach ($g in $m.Gegenstaende) {
        $alt = ($items.SelectSingleNode("//item[@name='$g']/property[@name='Tags']")).value
        $neu = (($alt -split ',') | ForEach-Object { if ($_ -eq $m.Von) { $m.Nach } else { $_ } }) -join ','
        $iz += "`t<set xpath=`"/items/item[@name='$g']/property[@name='Tags']/@value`">$neu</set>"
        $markenZeilen++
    }
}
$iz += '</config>'
$iz | Set-Content (Join-Path $AusOrdner 'wp7-perks-items.xml') -Encoding UTF8

# ===========================================================================
# Localization-Zeilen: Name und Beschreibung je Unterbereich und je Perk
# ===========================================================================
function Zeile([string] $key, [string] $en, [string] $de) {
    $enQ = '"' + $en.Replace('"', '""') + '"'
    $deQ = '"' + $de.Replace('"', '""') + '"'
    return "$key,progression,Perk,,,,$enQ,,$deQ,,,,,,,,,,,"
}

# GETEILTE SCHLUESSEL ZUERST ZAEHLEN. Vanilla gibt ALLEN FUENF Nahkampf-Unterbereichen
# denselben Schluessel skillCombatPerksName/Desc ("Combat Perks"). Vier davon sind unsere -
# wer den Schluessel ueberschreibt, nennt alle vier gleich. Dieselbe Falle wie
# blockVariantHelperGroupDesc (50 Bloecke) und doorGroupDesc (55) in WP6.
# Darum: geteilter Schluessel -> eigener Schluessel per <set> auf name_key bzw. desc_key.
# Das Praefix prk700_ steht in der Praefixliste aus Vertrag 02 §2 und wird hier fuer die
# Unterbereiche mitbenutzt: ein Unterbereich ist ein Teil des Perk-Baumes.
$keyNutzer = @{}
foreach ($n in $prog.SelectNodes('//attribute | //skill | //perk | //crafting_skill | //book_group | //book')) {
    foreach ($a in @('name_key','desc_key','long_desc_key')) {
        $v = $n.GetAttribute($a)
        if ($v) { if (-not $keyNutzer.ContainsKey($v)) { $keyNutzer[$v] = 0 }; $keyNutzer[$v]++ }
    }
}

function Slug([string] $s) {
    $t = $s -replace '^skill', ''
    return ($t.Substring(0,1).ToLower() + $t.Substring(1))
}

$cz = @()
$eigeneSchluessel = 0
foreach ($b in $bereiche) {
    if ($b.Unberuehrt -or $b.Verborgen) { continue }
    $n = $prog.SelectSingleNode("//skill[@name='$($b.Name)']")
    $slug = Slug $b.Name
    foreach ($paar in @(
        @{ Attr = 'name_key'; Eigen = "prk700_$($slug)Name"; En = $b.En;     De = $b.De },
        @{ Attr = 'desc_key'; Eigen = "prk700_$($slug)Desc"; En = $b.EnDesc; De = $b.DeDesc })) {
        $vanilla = $n.GetAttribute($paar.Attr)
        if ($vanilla -and $keyNutzer[$vanilla] -eq 1) {
            # Eindeutig: Vanilla-Schluessel ueberschreiben, kein neuer Name.
            $cz += Zeile $vanilla $paar.En $paar.De
            continue
        }
        # Geteilt oder gar nicht vorhanden: eigener Schluessel.
        if ($vanilla) {
            $pz += "`t<set xpath=`"/progression/skills/skill[@name='$($b.Name)']/@$($paar.Attr)`">$($paar.Eigen)</set>"
        } else {
            $pz += "`t<setattribute name=`"$($paar.Attr)`" xpath=`"/progression/skills/skill[@name='$($b.Name)']`">$($paar.Eigen)</setattribute>"
        }
        $cz += Zeile $paar.Eigen $paar.En $paar.De
        $eigeneSchluessel++
    }
    if ($n.long_desc_key -and $keyNutzer[$n.long_desc_key] -eq 1) { $cz += Zeile $n.long_desc_key $b.EnDesc $b.DeDesc }
}
foreach ($k in $perks) {
    $n = $prog.SelectSingleNode("//perk[@name='$($k.Name)']")
    if ($n.name_key) { $cz += Zeile $n.name_key $k.En $k.De }
    if ($n.desc_key) { $cz += Zeile $n.desc_key $k.EnDesc $k.DeDesc }
    if ($n.long_desc_key) { $cz += Zeile $n.long_desc_key $k.EnDesc $k.DeDesc }
}

# D68: Namen und Beschreibungen der 14 Handwerks-Stufen. Alle 24 Vanilla-Schluessel sind
# gemessen EINDEUTIG (kein Fall wie skillCombatPerksName), darum keine eigenen Schluessel.
foreach ($h in $handwerk) {
    $c = $prog.SelectSingleNode("//crafting_skill[@name='$($h.Name)']")
    if ($c.name_key -and $keyNutzer[$c.name_key] -eq 1) { $cz += Zeile $c.name_key $h.En $h.De }
    if ($c.desc_key -and $keyNutzer[$c.desc_key] -eq 1) { $cz += Zeile $c.desc_key $h.EnDesc $h.DeDesc }
    if ($c.long_desc_key -and $keyNutzer[$c.long_desc_key] -eq 1) { $cz += Zeile $c.long_desc_key $h.EnDesc $h.DeDesc }
}

$doppelt = $cz | ForEach-Object { ($_ -split ',')[0] } | Group-Object | Where-Object { $_.Count -gt 1 }
if ($doppelt) { throw ("Doppelte Schluessel: " + (($doppelt | ForEach-Object { $_.Name }) -join ', ')) }

$cz | Set-Content (Join-Path $AusOrdner 'wp7-perks-texte.csv') -Encoding UTF8

# Erst JETZT schliessen und schreiben: der Localization-Block oben haengt noch
# <set>-Zeilen fuer eigene Schluessel an $pz.
$pz += '</config>'
$pz | Set-Content (Join-Path $AusOrdner 'wp7-perks-progression.xml') -Encoding UTF8

# ===========================================================================
Write-Output "== wp7-perks =="
Write-Output ("  Unterbereiche umgehaengt:      {0} von 13" -f $umgehaengteBereiche)
Write-Output ("  Unterbereiche verborgen:       {0}" -f @($bereiche | Where-Object { $_.Verborgen }).Count)
Write-Output ("  Perks umgehaengt:              {0} von {1}" -f $umgehaengtePerks, $perks.Count)
Write-Output ("  progression_name berichtigt:   {0} Zeilen" -f $reqZeilen)
Write-Output ("  Perks neu verborgen:           {0}" -f $neuVerborgen.Count)
Write-Output ("  Gegenstands-Marken umgehaengt: {0}" -f $markenZeilen)
Write-Output ("  Handwerks-Stufen umgehaengt:   {0} von {1} (D68)" -f $handwerkUmgehaengt, $handwerk.Count)
Write-Output ("  Perks unberuehrt (ohne Attributbedingung): {0}" -f $bleiben.Count)
Write-Output ("  Localization-Zeilen:           {0}" -f $cz.Count)
Write-Output ("  davon eigene Schluessel:       {0} (geteilte Vanilla-Schluessel umgebogen)" -f $eigeneSchluessel)
Write-Output ''
Write-Output "  Perks je Baum:"
foreach ($a in $baeume.Keys) {
    $z = @($perks | Where-Object { $bereichNachAttribut[$_.Bereich] -eq $a })
    Write-Output ("    {0,-12} ({1,-13}) {2}" -f $baeume[$a].de, $a, $z.Count)
}
Write-Output ''
Write-Output "  Geschrieben nach: $AusOrdner"
