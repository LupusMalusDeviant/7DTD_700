# 0003 — Sackgassen-Rezepte und leere Auftragsbelohnungen

**Stand:** 2026-11-22 · **Vom Nutzer abgenommen am 2026-11-22** („Abnehmen und bauen", D89).
**Gebaut am selben Tag:** die Rezepte (Tabellen 1 bis 5) und die Belohnungen — siehe „Stand
des Baus" am Ende, dort stehen auch die drei Stellen, an denen der Bau genauer wurde als die
Tabelle. **Nicht gesehen:** nichts davon im Spiel; der Nachweis ist ein neuer ConfigsDump.
**Gehört zu:** Plan 0001, Ziel Z3 („sackgassenfrei") und offener Punkt „erster Lauf im Spiel,
leere Belohnungen"; F-05, F-02, F-03.

Der Nutzer hat am 2026-11-22 vier Dinge entschieden (AskUserQuestion):

1. **Kernweg:** erst diese Tabelle, dann der Bau.
2. **Aufsätze für Waffen und Rüstung:** ersetzen wie den Kernweg.
3. **Gerichte mit Mais und Kartoffel:** mit Erlaubtem kochen.
4. **Belohnungen:** zeitgemäß füllen — Lehrblätter, Bauteile lebender Waffen, Feld und Nahrung
   wieder als Belohnung; was rein modern war, zahlt Silberpfennige nach Auftragsstufe.

Alle Zahlen sind vorläufig (WP9 zieht Balancing nach). Abgenommen wird die **Zuordnung**, nicht
jede Menge.

## Gemessen

Quelle: der ConfigsDump vom 2026-11-21 (`Saves\Navezgane\DND\ConfigsDump`, Stand
`17:11:30Z`, mit unseren Modlets geladen). Befehl:
`mod700check recipes <Dump> --json` — 278 Rezepte, 198 erreichbar, **80 Sackgassen**, 0 Zyklen.

Eine Sackgasse ist ein Rezept, das den Purge überlebt und eine gesperrte Zutat nennt. Die 80
verteilen sich so:

| Gruppe | Rezepte | Was hier steht |
|---|---|---|
| A — Kernweg | 28 | Tabelle 1 |
| B — Aufsätze | 29 | Tabelle 2 |
| C — Gerichte und Leim | 5 | Tabelle 3 |
| D — Sperren | 5 | Tabelle 4 |
| E — Langbogen, Armbrüste, Sonderpfeile | 13 | Tabelle 5 (seit D87 Teil dieser Abnahme) |

Gesperrte Zutaten nach Zahl der Rezepte: Kunststoff (`resourceScrapPolymers`) 31,
Mechanische Teile 31, Klebeband 30, Feder (`resourceSpring`) 17, legendäre Teile 11,
Schießpulver 8, Rohr 4, Rüstungssatz 4, Mais 4, Linse 2, Öl 2, Kartoffel 2, je 1: Salpeter,
Farbe, Chrysantheme, Supermais, Benzin.

**Eine Feinheit:** Zutaten mit Menge 0 (`resourceDuctTape x0`, `resourceLegendaryParts x0`)
kommen erst über die Qualitätsstufe dazu (`CraftingIngredientCount`). Solche Rezepte gehen
heute bis Qualität 3 oder 5 und brechen darüber ab. Die Prüfung zählt sie als Sackgasse —
zu Recht, der Weg zur vollen Qualität ist zu.

## Die Regel

Wie bei den Werkstätten in WP4 (Zimmermannsbank, Rennofen, Kalkofen):

| Gesperrt | wird | Bild dahinter |
|---|---|---|
| Klebeband `resourceDuctTape` | Leder `resourceLeather`, 1 : 1 | Riemen |
| Mechanische Teile `resourceMechanicalParts` | Schmiedeeisen `resourceForgedIron`, 1 : 1 | Beschläge, Niete |
| Feder `resourceSpring` | Schmiedeeisen, 1 : 1 | Spange, Klammer |
| Rohr `resourceMetalPipe` | je Stück: Lehm (Düse, Topf), Schmiedeeisen oder Holz | — |
| Kunststoff `resourceScrapPolymers` | je Stück: Federn, Leder, Holz oder Nesselfaser | — |
| legendäre Teile `resourceLegendaryParts` | entfallen, mit ihrer Qualitätszeile | wie in WP5.1 |
| Schießpulver am Brandpfeil | Talg `resourceAnimalFat` | getränktes Tuch |
| Öl, Benzin | Talg, Tuch | — |
| Mais, Kartoffel | Pilze, Goldrute | — |

Steht der Ersatz schon im Rezept, werden die Mengen **zusammengezählt** — ein Rezept nennt
keine Zutat zweimal. Die Qualitätszeilen (`CraftingIngredientCount`) ziehen mit: ihre Marke
wechselt auf den Ersatz, oder die Zeile entfällt, wenn die Zutat im Ersatz aufgeht.

## Tabelle 1 — Kernweg (28)

Mengen bei Qualität 1. „+" heißt: zur vorhandenen Menge gezählt.

| Rezept | heute gesperrt | Vorschlag |
|---|---|---|
| Eisenspitzhacke `meleeToolPickT1IronPickaxe` | Klebeband 2, leg. Teile | Leder 2 + 2 = 4; leg. Teile entfallen |
| Eisenschaufel `meleeToolShovelT1IronShovel` | Klebeband 2, leg. Teile | Leder 4; leg. Teile entfallen |
| Klauenhammer `meleeToolRepairT1ClawHammer` | Klebeband 2, leg. Teile | Leder 4; leg. Teile entfallen |
| Stahlspitzhacke `meleeToolPickT2SteelPickaxe` | Klebeband 3, leg. Teile | Leder 3 (neu); leg. Teile entfallen |
| Stahlschaufel `meleeToolShovelT2SteelShovel` | Klebeband 3, leg. Teile | Leder 3 (neu); leg. Teile entfallen |
| Helm, Kleid, Handschuhe, Stiefel `armorPrimitive*` (4) | Klebeband ab Qualität 5 | Leder ab Qualität 5, gleiche Mengen (1, 2) |
| Holzbogen `gunBowT1WoodenBow` | Klebeband 1, leg. Teile | Leder 1 + 1 = 2; leg. Teile entfallen |
| Brandpfeil `ammoArrowFlaming` | Kunststoff 2, Schießpulver 2 | Federn 2; Talg 1 + 2 = 3 |
| Brandpfeil-Bündel `ammoBundleArrowFlaming` | Kunststoff 160, Schießpulver 160 | Federn 160; Talg 80 + 160 = 240 |
| Schiene `medicalSplint` | Klebeband 1 | Leder 1 |
| Reparatursatz `resourceRepairKit` | Klebeband 1 | Leder 1 |
| Blasebalg `toolBellows` | Rohr 2, Klebeband 5 | Lehm 10 (Düse); Leder 20 + 5 = 25 |
| Schmelztiegel `toolForgeCrucible` | Mech. Teile 20, Öl 20 | Schmiedeeisen 100 + 20 = 120; Holzkohle 20 |
| Feld `farmPlotBlockVariantHelper` | Salpeter 25 | Knochen 5 (Knochenmehl) |
| Bienenstock `cntApiary` | Klebeband 8 | Leder 8 |
| Brutkasten `toolApiaryBroodBox` | Kunststoff 100 | Nesselfaser 50 (Strohkorb) |
| Honigschleuder `toolApiaryExtractor` | Mech. Teile 5, Rohr 2 | Schmiedeeisen 20 + 7 = 27 |
| Imkerpfeife `toolApiarySmoker` | Rohr 2 | Lehm 10 (Rauchtopf) |
| Hühnerstall `cntChickenCoop` | Kunststoff 200, Klebeband 8 | Holz 100 + 200 = 300; Leder 8 |
| Hühnerauslauf `toolChickenCoopRun` | Rohr 20 | Holz 20 + 20 = 40 |
| Hühnerfutter `resourceChickenFeed` | Mais 1 | Pilze 1 |
| Großer Rucksack `backpackLarge` | Kunststoff 20, leg. Teile | Leder 50 + 20 = 70 (Stufen zusammengezählt); leg. Teile entfallen |
| Zugbrücke `metalReinforcedWoodDrawBridge` | Feder 20, Mech. Teile 20 | Schmiedeeisen 20 + 40 = 60 |
| Dietrich `resourceLockPick` | Mech. Teile 1 | Schmiedeeisen 1 + 1 = 2 |
| Dietrich-Bündel `resourceLockPickBundle` | Mech. Teile 40 | Schmiedeeisen 40 + 40 = 80 |

## Tabelle 2 — Aufsätze (29)

**Rüstung (13).** Kunststoff → Leder, Klebeband → Leder, Mechanische Teile → Schmiedeeisen,
Feder → Schmiedeeisen; alles zusammengezählt.

| Rezept | Vanilla (gesperrt fett) | Vorschlag |
|---|---|---|
| `modArmorStoragePocket` | **Kunststoff 10**, Leder 6, **Klebeband 1**, **Mech. 4**, Nähzeug 1 | Leder 17, Schmiedeeisen 4, Nähzeug 1 |
| `modArmorDoubleStoragePocket` | **K 15**, Leder 8, **Kb 2**, **M 4**, Nähzeug 2 | Leder 25, Schmiedeeisen 4, Nähzeug 2 |
| `modArmorTripleStoragePocket` | **K 20**, Leder 10, **Kb 3**, **M 4**, Nähzeug 3 | Leder 33, Schmiedeeisen 4, Nähzeug 3 |
| `modArmorQuadStoragePocket` | **K 40**, Leder 20, **Kb 6**, Nähzeug 6, **leg. Teile 1** | Leder 66, Nähzeug 6 |
| `modArmorBandolier` | Tuch 100, **K 2**, Leder 15, Leim 3, Nähzeug 1 | Tuch 100, Leder 17, Leim 3, Nähzeug 1 |
| `modArmorImprovedFittings` | **K 10**, Leder 4, **Kb 1**, **M 4**, Nähzeug 1 | Leder 15, Schmiedeeisen 4, Nähzeug 1 |
| `modArmorCustomizedFittings` | **K 20**, Leder 8, **Kb 2**, **M 8**, Nähzeug 1 | Leder 30, Schmiedeeisen 8, Nähzeug 1 |
| `modArmorPlatingBasic` | Leder 2, **K 5**, **Kb 1**, **M 2**, Nähzeug 1 | Leder 8, Schmiedeeisen 2, Nähzeug 1 |
| `modArmorPlatingReinforced` | Schmiedeeisen 10, **K 10**, **Kb 2**, **M 4**, Nähzeug 1 | Schmiedeeisen 14, Leder 12, Nähzeug 1 |
| `modArmorMuffledConnectors` | Tiegelstahl 4, **K 30**, **Kb 1**, **M 4**, Nähzeug 1 | Tiegelstahl 4, Leder 31, Schmiedeeisen 4, Nähzeug 1 |
| `modArmorAdvancedMuffledConnectors` | Tiegelstahl 5, **K 60**, **Kb 2**, **M 5**, Nähzeug 1 | Tiegelstahl 5, Leder 62, Schmiedeeisen 5, Nähzeug 1 |
| `modArmorStealthBoots` | Tiegelstahl 5, **K 60**, **Kb 2**, **M 5**, Nähzeug 1 | Tiegelstahl 5, Leder 62, Schmiedeeisen 5, Nähzeug 1 |
| `modArmorImpactBracing` | Tiegelstahl 5, **Kb 2**, **M 20**, **Feder 20**, Nähzeug 1 | Tiegelstahl 5, Leder 2, Schmiedeeisen 40, Nähzeug 1 |

**Waffen (16).** Vierzehn haben dasselbe Muster: Metall 5, Leim 5, **Mech. Teile 5**,
**Feder 10**. Daraus wird: Metall 5, Leim 5, **Schmiedeeisen 15** — ist das Metall selbst
Schmiedeeisen, zusammen 20.

| Muster | Rezepte |
|---|---|
| Tiegelstahl 5, Leim 5, Schmiedeeisen 15 | `modGunBowArrowRest`, `modGunCrippleEm`, `modMeleeClubMetalSpikes`, `modMeleeClubMetalChain`, `modMeleeErgonomicGrip`, `modMeleeFortifyingGrip`, `modMeleeIronBreaker`, `modMeleeTemperedBlade` |
| Schmiedeeisen 20, Leim 5 | `modGunMeleeTheHunter`, `modMeleeGraveDigger`, `modMeleeSerratedBlade`, `modMeleeStructuralBrace`, `modMeleeWeightedHead`, `modMeleeWoodSplitter` |
| Tiegelstahl 5, Leim 5, Schmiedeeisen 5, Rohdiamant 3 | `modMeleeDiamondTip` (hatte keine Feder) |
| Tiegelstahl 5, Leim 5, **Talg 5** (statt Öl), **Tuch 10** (statt Benzin 50) | `modMeleeClubBurningShaft` |

Namen und Wirkung der Aufsätze bleiben unverändert. Welche davon dem Namen nach nicht ins
Jahr 700 passen („Customized Fittings", „Diamantspitze"), ist eine spätere Durchsicht der
Texte, keine Frage des Rezepts.

## Tabelle 3 — Gerichte und Leim (5)

Frei sind an Feldfrucht und Küche: Pilze, Goldrute, Hopfen, Aloe, Honig, Ei, Fleisch.

| Rezept | heute gesperrt | Vorschlag |
|---|---|---|
| Fleischeintopf `foodMeatStew` | Kartoffel 2, Mais 2 | Pilze 2, Goldrute 2 (Fleisch, Talg, Wasser bleiben) |
| Gemüseeintopf `foodVegetableStew` | Kartoffel 2, Mais 2 | Pilze 2 + 2 = 4, Goldrute 2 |
| Aschehuhn `foodAshChickenStew` | Mais 3 | Goldrute 3 (Huhn, Pilze 2, Holzkohle, Wasser bleiben) |
| Roter Tee `drinkJarRedTea` | Chrysantheme 1 | **Rezept entfällt.** Die Chrysantheme ist absichtlich gesperrt (`denylist.txt`: „Ostasien"), kein Versehen; Goldrutentee gibt es schon. |
| Leim aus Supermais `resourceGlue` (dritte Fassung) | Supermais 3 | **Diese Fassung entfällt.** Leim aus Knochen bleibt, an Feuerstelle und Kräuterküche. |

## Tabelle 4 — Sperren (5)

| Rezept | Grund |
|---|---|
| `biomeWeatherItem1` bis `biomeWeatherItem4` | Tragen in Vanilla keinen Namen (leere Zeile in der Sprachdatei), verlangen Rüstungssatz, Kunststoff und Linse. Rezept entfällt; die Gegenstände selbst bleiben, wie der Purge sie beurteilt. |
| Bild `pictureVariantHelper` | Verlangt Farbe (`resourcePaint`, gesperrt). Rezept entfällt. |

## Tabelle 5 — Langbogen, Armbrüste, Sonderpfeile (13)

Diese 13 hingen an Prüfliste 8 des Plans. **D87 (2026-11-22) hat sie entschieden:** alle
bleiben und werden umgedeutet — Compoundbogen → Langbogen, die beiden Armbrüste → Armbrust
und Schwere Armbrust, Stahlpfeil → panzerbrechender Pfeil (Namensvorschlag „Nadelpfeil"),
Sprengpfeil → **Feuertopfpfeil** (Tontopf mit griechischem Feuer). Damit brauchen ihre
Rezepte denselben Ersatz wie der Kernweg. Namen und Werte folgen in WP5.2; hier steht nur,
woraus sie gebaut werden.

| Rezept | heute gesperrt | Vorschlag |
|---|---|---|
| Langbogen `gunBowT3CompoundBow` | Klebeband 13, Feder 25, leg. Teile | Leder 25 + 13 = 38; **Holz 25** statt der Feder (Bogenstab — Ausnahme von der Regel, ein Langbogen hat keine Eisenspange); leg. Teile entfallen |
| Armbrust `gunBowT1IronCrossbow` | Klebeband 7, leg. Teile | Leder 7 (neu); leg. Teile entfallen |
| Schwere Armbrust `gunBowT3CompoundCrossbow` | Klebeband 13, leg. Teile | Leder 25 + 13 = 38; leg. Teile entfallen |
| Nadelpfeil `ammoArrowSteelAP` | Kunststoff 2 | Federn 2 |
| Nadelpfeil-Bündel `ammoBundleArrowSteelAP` | Kunststoff 160 | Federn 160 |
| Nadelbolzen `ammoCrossbowBoltSteelAP` | Kunststoff 2 | Federn 2 |
| Nadelbolzen-Bündel `ammoBundleCrossbowBoltSteelAP` | Kunststoff 160 | Federn 160 |
| Feuertopfpfeil `ammoArrowExploding` | Kunststoff 2, Schießpulver 6 | Federn 2; Lehm 2 (Topf), Talg 4 (Brandsatz). Pergament 1 und Nesselfaser 1 bleiben. |
| Feuertopfpfeil-Bündel `ammoBundleArrowExploding` | Kunststoff 120, Schießpulver 360 | Federn 120; Lehm 120, Talg 240 |
| Feuertopfbolzen `ammoCrossbowBoltExploding` | Kunststoff 2, Schießpulver 8 | Federn 2; Lehm 3, Talg 5 |
| Feuertopfbolzen-Bündel `ammoBundleCrossbowBoltExploding` | Kunststoff 120, Schießpulver 480 | Federn 120; Lehm 180, Talg 300 |
| Brandbolzen `ammoCrossbowBoltFlaming` | Kunststoff 2, Schießpulver 2 | wie der Brandpfeil: Federn 2; Talg 1 + 2 = 3 |
| Brandbolzen-Bündel `ammoBundleCrossbowBoltFlaming` | Kunststoff 160, Schießpulver 160 | Federn 160; Talg 80 + 160 = 240 |

Die Namen in der linken Spalte sind Arbeitsnamen bis WP5.2. **Eine Frage bleibt bei den
Feuertöpfen:** der Pfeil sprengt in Vanilla. Ob er als Feuertopf brennt statt sprengt, ist
eine Wertefrage für WP5.2 — das Rezept hier passt zu beidem.

## Belohnungen

Gemessen am selben Dump: **496** Belohnungen der Art `LootItem`, **115** zeigen auf mindestens
eine Loot-Gruppe, die nichts mehr hergibt, **66** nur auf solche. Betroffen sind 41 Gruppen.

**Ursache Nummer eins ist eine Zeile in `tools/check/denylist.txt`:**
`questReward*Bundle  # Belohnungsbuendel fuer Turm, Generator, Batterie, Solar`. Das Muster
trifft alle 92 Belohnungsbündel, auch die harmlosen — das Lehrblatt-Bündel allein steht hinter
48 der 115 Belohnungen. Sein Inhalt lebt vollständig: es öffnet drei Sorten Lehrblätter je
zweimal, aus den 14 lebenden.

### Wieder Belohnung — Bündel freigeben (57 Belohnungen)

Freigegeben wird je Bündel mit einer Zeile `!<Name>` in der Denylist; der Purge-Patch wird
danach neu erzeugt.

| Gruppe | Belohnungen | Was geschieht |
|---|---|---|
| `groupQuestT1SkillMagazineBundle` | 48 | `questRewardT1SkillMagazineBundle` frei. Inhalt unverändert. |
| `groupQuestMeleeCrafting` | 3 | Sechs von acht Bündeln frei: ~~Eisenfaust, Sax, Keule, Speer, Hammer~~ Stahlfaust, Spatha, Streitkolben, Flügellanze, Streithammer, Werkzeug — je Bruchstücke plus Lehrblatt. Schockstab und Motorwerkzeug bleiben gesperrt. *(Namen berichtigt am 2026-11-22: die Gruppe enthält nur die Bündel der Stahlstufe; gemeint und freigegeben waren immer diese sechs, siehe „Stand des Baus".)* |
| `groupQuestRangedCrafting` | 3 | Das Bogen-Bündel frei (Bogen-Bruchstücke, Eisenpfeile, Lehrblatt). Die sechs Schusswaffen-Bündel bleiben gesperrt. |
| `groupQuestFarmPlotsT1` bis `T3` | 3 | Bündel frei: Felder und Saat-Lehrblatt. Die Zufallspflanze wird auf Pilz und Goldrute gekürzt (vier der sechs sind gesperrt). Setzt das Feld-Rezept aus Tabelle 1 nicht voraus — das Bündel gibt fertige Felder. |

### Wieder Belohnung — Inhalt anpassen (14 Belohnungen)

Bündel frei, und ein Patch an `items.xml` nimmt das Gesperrte aus seiner Liste.

| Gruppe | Belohnungen | Was geschieht |
|---|---|---|
| `groupQuestT2Food`, `T3Food`, `T4Food` | 3 | Mineralwasser → abgekochtes Wasser; die Zufallsgerichte auf die lebenden gekürzt (nach Tabelle 3 Fleisch- und Gemüseeintopf). Bleibt in einer Stufe keines, zahlt die Gruppe Silber. |
| `groupQuestT1Books` | 1 | Zufallsliste auf Blätter der 13 lebenden Reihen gekürzt. |
| `groupQuestT1MeleeMods`, `T2`, `T3` | 6 | T1 und T3 unverändert frei (alle Aufsätze leben); T2 ohne Stacheldraht und Bunkerbrecher. |
| `groupQuestT1RangedMods`, `T2` | 2 | T1 gibt „Der Jäger", T2 Pfeilauflage und „Lähmschuss" — mehr lebt nicht; die Zahl der Zufallsstücke sinkt entsprechend. |
| `groupQuestT1Traps`, `T2Traps` | 2 | Nur die Spieße bleiben (Holz bzw. Eisen), dafür zehn statt fünf. Stacheldraht, Minen und das gesperrte Lehrblatt entfallen. |

### Silberpfennige — rein modern (44 Belohnungen)

Die Gruppe bekommt einen Eintrag Silberpfennige (`casinoCoin`). Die Menge richtet sich nach
der **niedrigsten** Auftragsstufe, die auf die Gruppe zeigt:

| Stufe | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Silberpfennige | 300 | 600 | 1000 | 1500 | 2000 | 3000 |

*(Zum Vergleich: Vanillas eigene Münzbelohnungen liegen zwischen 100 und 4000.)*

| Stufe | Gruppen (Belohnungen) |
|---|---|
| 1 → 300 | Fahrrad (1), Schraubenschlüssel (1), Helmlampen-Bauplan (1), Munitionsbündel (3) |
| 2 → 600 | Minibike-Teile (1), Nagelpistole (1), Grubenhelm (1) |
| 3 → 1000 | Generator (1), Sicherheitsanlage (1), Pfeilfalle (1), Zeitladungen (2), Motorradteile (1), Nachtsichtgerät (1), Fernkampf-Aufsätze T3 (4) |
| 4 → 1500 | Benzin (11), Batteriebank (1), Klingenfalle (1), Geländewagenteile (1) |
| 5 → 2000 | Selbstschussanlage (2), Schrotturm (2), Solarbank (2), Tragschrauberteile (2) |
| 6 → 3000 | legendäre Nahkampf-Bündel (1), legendäre Fernkampf-Bündel (1) |

57 + 14 + 44 = 115.

**Was offen bleibt und der Bau zeigt:** ob das Anachronismus-Urteil den Inhalt eines
freigegebenen Bündels mitprüft (`anachronisms` muss grün bleiben, sonst wird der Inhalt
gepatcht, nicht die Prüfung); ob eine Belohnung die Menge eines Loot-Eintrags übernimmt
(Vanilla schreibt `<item name="ammoGasCan" count="5000"/>`, das spricht dafür); und die
Texte der freigegebenen Bündel — „Zeitschriften-Bündel" muss „Lehrblatt-Bündel" werden.

## Wie geprüft wird

- `kette-pruefen.ps1`: jeder neue XPath trifft Vanilla, und die Verweise, die das Skript
  kennt (Zutaten und Werkstätten eigener Rezepte, eigene Gegenstände und Blöcke), lösen sich
  auf. **Nicht dazu gehört der Wert einer Bündelliste:** ein Tippfehler in `Random_item`
  oder `Create_item` ließe den XPath gültig und fiele hier nicht auf. Den Inhalt der Bündel
  zählt die eigene Zählung am Vorlauf nach („Stand des Baus"), sie meldet auch unbekannte
  Kennungen.
- `mod700check purge-patch`: die erzeugten Patches sind aktuell (nach den Denylist-Zeilen).
- `mod700check anachronisms`: bleibt grün.
- **`mod700check recipes` wird erst mit einem neuen ConfigsDump grün** — die Prüfung liest
  die gemergte Config des Spiels, und die entsteht nur bei einem Spielstart mit der Mod.
  Bis dahin rechne ich die Patches außerhalb des Repositorys auf Vanilla an und lasse
  `recipes` über das Ergebnis laufen: ein **Vorlauf**, kein Nachweis. Er zählt erst, wenn
  derselbe Weg am heutigen Stand die 80 Sackgassen des Dumps wiederfindet.
- Erwartet nach dem Bau: **0 Sackgassen**, 0 Belohnungen auf leere Gruppen.

## Stand des Baus

### Belohnungen — gebaut am 2026-11-22

| Was | Wo | Zahl |
|---|---|---|
| Bündel einzeln freigegeben (`!<Name>`) | `tools/check/denylist.txt`, neuer Abschnitt am Ende | 20 |
| Purge-Patch neu erzeugt (`mod700check purge-patch`) | `mod/700_10_Purge/Config/items.xml`, `loot.xml` | je 20 Zeilen weniger; 1931 Patchzeilen |
| Inhalt gekürzt | `mod/700_20_Material/Config/items.xml` | 10 Bündel, 26 Operationen (die anderen 10 freigegebenen bleiben, wie Vanilla sie schreibt) |
| Silber | `mod/700_20_Material/Config/loot.xml` (neu) | 26 Gruppen |
| Namen und Beschreibungen | `mod/700_90_Sprache/Config/Localization.csv`, `tools/check/vanilla-keys.txt` | 30 Zeilen |

**Drei Stellen, an denen der Bau genauer wurde als die Tabelle oben** — die Tabelle war aus
der Liste der leeren Gruppen geschrieben, der Bau hat jedes Bündel gelesen:

1. **Nahrung:** nur `groupQuestT2Food` bleibt Nahrung (Lehrblätter, abgekochtes Wasser,
   Gemüse- oder Fleischeintopf). In den Nahrungspaketen 02 und 03 lebt **keines** der je vier
   Gerichte — nach dem Satz der Tabelle („bleibt in einer Stufe keines, zahlt die Gruppe
   Silber") zahlen `groupQuestT3Food` 600 und `groupQuestT4Food` 1500. Damit **57 + 12 + 46 =
   115** statt 57 + 14 + 44; freigegeben sind 20 Bündel, nicht 22.
2. **Feld:** die Zufallspflanze ist je Stufe eine andere Liste. Es leben Pilz und Goldrute
   (Feldbündel 1), Aloe (2) und Hopfen (3). Jedes Bündel gibt weiter drei Setzlinge.
3. **Abschriften:** von den 126 Blättern des Bündels leben 78, nicht „13 Reihen".

**Und ein Fehler in den Namen, nicht im Bau:** die Tabelle nannte die sechs Werkbündel
„Eisenfaust, Sax, Keule, Speer, Hammer, Werkzeug". `groupQuestMeleeCrafting` enthält aber nur
die Bündel der Stahlstufe (`questRewardSteelKnuckleCraftingBundle`, `…Machete…`,
`…SteelClub…`, `…SteelSpear…`, `…SteelSledgehammer…`, `…SteelTools…`) — bei uns Stahlfaust,
Spatha, Streitkolben, Flügellanze, Streithammer und Werkzeug. Freigegeben sind diese sechs;
die Zeile oben und die Kommentare in `denylist.txt` sind berichtigt.

**Die Prüfwerkzeuge sehen den Inhalt eines Bündels nicht.** Die offene Frage von oben ist
beantwortet: `mod700check` kennt als Weg zu einem Gegenstand Rezept, Loot, Händler,
Auftragsbelohnung, Block-Abwurf und Startausrüstung — nicht `Create_item` und `Random_item`.
Ein freigegebenes Bündel mit Mineralwasser darin bleibt in `anachronisms` und `purge-patch`
grün. Gemessen ist der Inhalt darum am Vorlauf, mit einer eigenen Zählung außerhalb des
Repositorys:

| Stand | geprüfte `questReward*`-Bündel | Befunde |
|---|---|---|
| nach dem Bau | 20 | **2** — beide an `questRewardVehiclePartsBundle`, das ich nicht freigegeben habe und das nur in den gesperrten Fahrzeugbündeln steckt |
| Gegenprobe: derselbe Purge, Inhalts-Patches fehlen | 20 | **93** |
| Gegenprobe: ein Tippfehler in einer Liste (`plantedAloee1` im Feldbündel 2) | 20 | **3** — die zwei von oben und `UNBEKANNT: questRewardFarmT2Bundle nennt in Random_item 'plantedAloee1'` |

Die Zählung meldet drei Arten von Befund: eine **gesperrte** Kennung, eine **unbekannte** (in
`items.xml`, `blocks.xml` und `item_modifiers.xml` des Vorlaufs steht kein Knoten dieses
Namens) und **zu viele** (ohne Wiederholung wird öfter gewürfelt, als die Liste Einträge
hat). Nach dem Bau: 2 gesperrt, **0 unbekannt, 0 zu viele**. Die 20 geprüften sind die 19
freigegebenen Bündel mit eigener Liste und `questRewardVehiclePartsBundle`; das
Lehrblatt-Bündel nennt keine Liste, es öffnet eine Loot-Gruppe, und die sieht `mod700check`.

Dieselbe Zählung über alle 434 nicht gesperrten Bündel meldet 1362 Befunde (1358 gesperrt,
4 unbekannt — alle vier an `levelDesignToolsAdmin`, das Blockformen als `woodShapes:cube`
schreibt, eine Schreibweise, die die Zählung nicht auflöst) an rund 220
Bündeln (`tier0*`, `admin*`, `note*Admin`); stichprobenweise nachgesehen, stehen sie in
keiner Loot-Gruppe, keinem Auftrag, keiner Händlerliste und keinem Rezept — Vanillas
Testbündel. **Das ist eine Lücke der Prüfung, kein Befund am Spiel**, und sie steht als
Folgearbeit im Plan.

**Der Vorlauf nach beiden Schritten:** 2668 Operationen, 0 ohne Treffer; 271 Rezepte, 271
erreichbar, 0 Sackgassen; 496 Auftragsbelohnungen, **0** auf eine leere Gruppe (vorher 115,
66 davon nur auf leere).

**Eine Nebenwirkung:** fünf der 26 Silber-Gruppen liegen in Vanilla auch in den Bündelgruppen
der Abwurfkisten (`groupAirDropT1Bundles` bis `T5Bundles`). Eine Abwurfkiste kann darum statt
nichts jetzt 300 bis 1000 Silberpfennige enthalten.

**Nicht gesehen:** wie das Belohnungsfenster einen Münzstapel aus einer Loot-Gruppe zeigt;
ob ein Bündel mit gekürzter Zufallsliste sauber öffnet (`Random_count` ist überall höchstens
so groß wie die Liste); die neuen Namen im Spiel. Das steht in der Prüfliste des Plans.

### Rezepte — gebaut am 2026-11-22

264 Patch-Operationen in drei Dateien, von Hand geschrieben (D53):

| Datei | Rezepte | davon entfallen |
|---|---|---|
| `mod/700_30_Ausruestung/Config/recipes.xml`, Abschnitt 3 | 59 | 4 (Wettergegenstände) |
| `mod/700_20_Material/Config/recipes.xml` | 12 | 2 (Roter Tee, Leim aus Supermais) |
| `mod/700_40_Bauen/Config/recipes.xml` | 9 | 1 (Bild) |

Kein Rezept ist neu geschrieben: Vanillas Zeile bleibt samt `tags`, Werkstatt und Zeit, nur
die gesperrte Zutat geht — derselbe Griff wie bei den Werkstätten in WP4.3. Eine neue Zutat
steht vor `<effect_group>`, wo das Rezept eine hat (`insertAfter`), sonst am Ende (`append`).

**Der Vorlauf** (außerhalb des Repositorys: alle Modlets in Ladereihenfolge auf eine Kopie
von Vanillas `Data/Config` angerechnet, mit den Operationen aus `patch-operationen.ps1`,
danach `mod700check recipes` über das Ergebnis):

| Stand | Operationen | ohne Treffer | Rezepte | erreichbar | Sackgassen |
|---|---|---|---|---|---|
| vor dem Bau | 2392 | 0 | 278 | 198 | **80** |
| ConfigsDump des Spiels, 2026-11-21 | — | — | 278 | 198 | **80** |
| nach dem Bau | 2656 | 0 | 271 | 271 | **0** |

Der Vorlauf zählt, weil er am Stand vor dem Bau genau die Zahlen des Dumps trifft (auch
8100 bekannte Kennungen, 345 Wurzeln, 496 / 115 / 66 Belohnungen). Sieben Rezepte weniger:
die sieben, die entfallen. **Ein Nachweis ist er nicht** — den gibt erst ein neuer
ConfigsDump nach einem Spielstart mit der Mod. Bis dahin bleibt `recipes` in `check-all.ps1`
mit 80 rot, weil es den alten Dump liest.

**Form der 271 Rezepte** (auch am Vorlauf gemessen): keine Zutat doppelt, keine Zutat hinter
`<effect_group>`, jede Marke einer `CraftingIngredientCount`-Zeile nennt eine Zutat ihres
Rezepts — bis auf eine Zeile, die schon Vanilla so führt (`toolCookingPot` nennt
`unit_iron`). Die Prüfung findet etwas: an Vanilla meldet sie zwei solche Zeilen.

**Nicht gesehen:** ob das Spiel eine per `insertAfter` eingefügte Zutat und die geänderten
Qualitätszeilen so liest wie erwartet — das zeigt das Handwerksfenster (Prüfliste).

## Nicht entschieden

- Namen und Werte der Stücke aus Tabelle 5 (WP5.2, nach D87), darunter „Nadelpfeil" und ob
  der Feuertopf sprengt oder brennt.
- Ob die 29 Aufsätze dem Namen nach bleiben.
- Jede einzelne Menge — WP9.
