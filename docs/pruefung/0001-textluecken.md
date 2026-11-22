# Prüfung 0001 — Textlücken in Phase 1

Stand: 22. November 2026, abends. Geprüft gegen den ConfigsDump von 22:08 Uhr
(`C:\Users\Anwender\Saves\Pregen06k01\Z\ConfigsDump`, gemergt mit unserer Mod) und gegen
Vanillas `Localization.csv` (V 3.40 b10).

**Die Frage:** Welche Texte sieht ein Spieler von Tag 1 bis nach der ersten Seuchennacht noch
in Vanillas moderner Fassung, weil `mod/700_90_Sprache/Config/Localization.csv` sie nicht
überschreibt?

**Die Antwort in Zahlen (gemessen):** Von **5.719** Sprachschlüsseln, die sich aus den
XML-Dateien als sichtbar ableiten lassen, tragen **851** unseren Text, **4.723** Vanillas und
**145** gar keine Zeile. Von den 4.723 Vanilla-Zeilen treffen **944** ein verbotenes Muster des
Glossars oder ein modernes Wort — das sind die **sicheren Lücken**. Die übrigen 3.779 sind
„nicht modern nach Muster, aber ungeprüft“; das ist kein Freispruch (siehe §7).

**Vorgearbeitet:** 133 fertige Zeilen in `docs/pruefung/0001-textentwurf.csv`, davon 129 sichere
Lücken und 4 Zeilen ohne Mustertreffer, die mit ihnen zusammenhängen.

Geändert wurde nichts außer diesen zwei Dateien. Kein Text aus dem Entwurf ist im Spiel gesehen.

---

## 1. Methode

Alle Skripte sind PowerShell, liegen im Scratchpad der Sitzung
(`…\scratchpad\nacht\texte\`, nicht im Repository) und lesen nur.

| Schritt | Skript | Was es tut | Zahl (gemessen) |
|---|---|---|---|
| Sprachdateien | `lib.ps1` | `Import-Csv` beider Dateien, Schlüssel zeichengenau | Vanilla 25.930; unsere **941** (871 überschreiben Vanilla, 70 sind neu). Der Auftrag nannte 939 — gezählt sind 941. |
| Erreichbarkeit | `10-sammeln.ps1` | die sechs Wege aus `Reachability.cs` nachgebaut (Block-Abwurf, Rezept, Loot, Händler, Quest-Belohnung, Startausrüstung) | **543** Namen — dieselbe Zahl wie `mod700check anachronisms … --json` (`gepruefte_kennungen 543`). Davon 336 Gegenstände, 78 Blöcke, 47 Aufsätze, 84 ohne Definition (Loot-Gruppen, Formen). Zusatz über Tierabwürfe und `Create_item`: +2. |
| Welt | `10-sammeln.ps1` | die Blocklisten aller Prefabs gelesen (`Data\Prefabs\{POIs,Parts,RWGTiles}\*.blocks.nim`), Platzhalter über `blockplaceholders.xml` aufgelöst | 1.772 Prefabs, 0 Lesefehler, 4.887 Blocknamen; davon mit Bedienung (Behälter, Tür, Schild, Werkstatt) **1.724** Schlüssel |
| übrige Kategorien | `10-sammeln.ps1` | jedes Attribut und jede Eigenschaft im Dump, die einen Sprachschlüssel nennt (Karte in `02-karte.txt`) | 8.817 Nennungen |
| Urteil | `20-pruefen.ps1` | je Schlüssel: unsere Zeile, Vanillas Zeile oder keine; Vanillas EN und DE gegen drei Musterlisten | siehe §2 |
| Endzahlen | `50-zahlen.ps1` | Kern und Rand getrennt, jeder Schlüssel einmal | siehe §2 |
| Entwurf prüfen | `60-entwurf-pruefen.ps1`, dazu `mod700check localization` | Form, Schlüssel, Muster, Platzhalter | 133 Zeilen, 0 rot; `csv_form_fehler 0`, `spalten 20` |

Der Befehl aus dem Auftrag liefert die 543 Kennungen **nicht als Liste** — das JSON trägt nur
Zählwerte und 40 Hinweise. Die Liste ist darum nachgebaut und an der Zahl 543 abgeglichen.

### Die drei Musterlisten

1. **Glossar** — die 101 Zeilen der Tabellen „Verboten“ aus `docs/glossar.md`, so gelesen wie
   `glossar-pruefen.ps1` sie liest (95 Welt-, Umdeutungs- und Namensmuster, 6 „Spielerdeutsch“).
2. **Eigene Liste moderner Wörter** — 186 englische, 170 deutsche Muster, bewusst eng: nur, was
   es um 700 sicher nicht gibt oder was Vanillas Welt benennt. Vollständig in `20-pruefen.ps1`;
   die Gruppen:
   - Schusswaffen und Sprengstoff: rifle, pistol, shotgun, revolver, magnum, smg, machine gun,
     sniper, firearm, gunpowder, ammo, bullet, cartridge, caliber, `\d+mm`, grenade, dynamite,
     bomb, landmine, rocket, launcher, turret, explosive, molotov — Pistole, Gewehr, Flinte,
     Patrone, Kaliber, Granate, Dynamit, Bombe, Rakete, Geschütz, Sprengstoff …
   - Strom und Maschinen: battery, generator, solar, engine, motor, gasoline, gas, powered,
     restore power, relay, sensor, speaker, mechanical, machine, computer, tv, radio, phone,
     camera, flashlight, light bulb, spotlight, neon, led, laser, night vision, scope, silencer,
     robot, drone, nail gun, wrench, ratchet, impact driver, auger, chainsaw, jackhammer —
     Batterie, Motor, Benzin, Strom, Maschine, Kamera, Taschenlampe, Roboter, Drohne,
     Schraubenschlüssel, Kettensäge …
   - Fahrzeuge und Straße: car, truck, vehicle, minibike, motorcycle, bicycle, 4x4, gyrocopter,
     jeep, tire, bus, asphalt, highway, airplane, helicopter, air drop — Auto, Fahrzeug,
     Lastwagen, Geländewagen, Reifen, Flugzeug …
   - Stoffe: plastic, polymer, rubber, nylon, kevlar, fiberglass, aluminum, titanium, stainless
     — Plastik, Kunststoff, Gummi, Aluminium …
   - moderne Welt: military, police, cop, swat, hazmat, hospital, clinic, pharmacy, nurse,
     vitamin, steroid, painkiller, first aid, medkit, syringe, drug, beaker, chemical, acid,
     virus, bacteria, dna, radiation, radioactive, fallout, nuclear, atomic, canned, tin can,
     vending, safe, atm, cash register, dumpster, mailbox, refrigerator, microwave, toilet,
     cooler, coffee, soda, candy, chili, sandwich, taco, pizza, burger, cigar, goggles,
     sunglasses, cowboy, biker, cheerleader, football, businessman, tourist, janitor, scientist,
     lab, demolition, dollar, cash, credit, token, apocalypse, skyscraper, apartment, garage,
     factory, gas station, supermarket, dew collector — mit den deutschen Entsprechungen.
   - Vanillas Namen: Joel, Rekt, Jen, Bob, Hugh, White River, Noah, Cassador, the Duke.
   - **Nicht** auf der Liste, weil unsere eigenen Zeilen sie benutzen oder weil sie Alltag sind:
     steel/Stahl, schematic/Bauplan, surgeon, Schlagstock, supply crate, backpack/Rucksack,
     Trader, survivor, infection/Infektion, HUD, Quest.
3. **Alter Name eines umbenannten Dings** — 433 Muster, erzeugt: der Vanilla-Name jedes
   Schlüssels, den wir umbenannt haben („Primitive Outfit“ heißt bei uns „Rag Tunic“), soweit
   er aus zwei Wörtern oder neun Zeichen besteht und **keine** unserer Zeilen ihn noch benutzt.
   Alltagswörter (Intellect, Perception, Workstations …) sind ausgenommen, wie das Glossar es
   in §9 für die Attributnamen festlegt.

Tastenzeichen (`[action:local:ToggleFlashlight]`), Platzhalter (`{cvar(…)}`) und Farbmarken
zählen nicht als Text; sie werden vor dem Abgleich entfernt.

### Gegenproben (Regel 5)

- Die Muster scheitern an bekannt falschem Text: „Craft a Pipe Pistol at the Workbench during a
  Blood Moon“ → `blood moon; workbench; pistol`. „…Rohrpistole mit dem Schraubenschlüssel an der
  Werkbank … Zombies beim Blutmond … Level 3“ → `zombie; blutmond; werkbank; pistole;
  schraubenschlüssel; level`.
- Sie schweigen bei gutem Text: „`[action:local:ToggleFlashlight]` Lumpenkittel,
  Zimmermannsbank, Seuchennacht“ → kein Treffer.
- Fehlalarm-Maß: die eigene Liste trifft **4** unserer 941 Zeilen (siehe §6, Nebenbefund 3).
  Die erste Fassung traf 14 — „truck“ in „struck“, „Reifen“ in „Eisenreifen“, „Geschütz“ in
  „geschützt“; alle drei Muster sind berichtigt.
- Die Entwurfsprüfung scheitert an drei bekannt falschen Zeilen mit 6 Befunden (verbotenes
  Muster, Schlüssel schon bei uns, Festbegriff, 19 Spalten).

---

## 2. Zahlen je Kategorie

**Kern** = was ein Spieler in Phase 1 sehen kann. Ausgeschlossen sind Twitch, Test, verborgene
Fertigkeiten, Editor- und Mehrspielerfenster, Anzeigearten ohne erreichbaren Gegenstand und
die Untertitel (alle unter „Rand“). Jeder Schlüssel zählt je Kategorie einmal.

| Kategorie | sichtbar | von uns | Vanilla | ohne Zeile | davon sichere Lücke |
|---|---:|---:|---:|---:|---:|
| Gegenstände (erreichbar, Name und Beschreibung) | 608 | 314 | 294 | 0 | 59 |
| Blöcke (erreichbar 141; in der Welt mit Bedienung 1.724) | 1.854 | 34 | 1.816 | 4 | 411 |
| Aufsätze | 85 | 0 | 85 | 0 | 3 |
| Buffs (nicht verborgen, ohne Twitch/Test) | 511 | 19 | 458 | 34 | 82 |
| Fertigkeiten, Abschriften, Handwerksstufen (nicht verborgen) | 1.067 | 455 | 607 | 5 | 75 |
| Quests | 262 | 11 | 233 | 18 | 47 |
| Herausforderungen (ohne Twitch) | 540 | 26 | 512 | 2 | 179 |
| Händler: Dialog und Namen | 42 | 0 | 34 | 8 | 15 |
| Entitäten (in einer Spawngruppe) | 174 | 0 | 174 | 0 | 69 |
| UI: Spielfenster, Hauptmenü, Werte erreichbarer Dinge | 613 | 3 | 531 | 79 | 15 |
| Ladetipps | 80 | 38 | 42 | 0 | 0 |
| Biomnamen | 6 | 0 | 5 | 1 | 0 |
| **zusammen (Schlüssel einmal)** | **5.719** | **851** | **4.723** | **145** | **944** |

Die Summe der Spalten ist größer als die letzte Zeile, weil ein Schlüssel in zwei Kategorien
stehen kann. Von den 944 treffen 146 nur ein Glossar-Muster, 654 nur die eigene Liste oder einen
alten Namen, 144 beides. Weitere 56 Vanilla-Zeilen treffen **nur** „Spielerdeutsch“ (`Level`,
`Skill`, `Perk` im deutschen Text) — sie stehen nicht in den 944.

**Blöcke nach Herkunft:**

| | sichtbar | von uns | Vanilla | sichere Lücke |
|---|---:|---:|---:|---:|
| erreichbar (Rezept, Loot, Händler, Abwurf) | 141 | 34 | 103 | 10 |
| Welt: Behälter | 1.067 | 0 | 1.067 | 316 |
| Welt: Tür | 433 | 1 | 432 | 70 |
| Welt: Schild | 131 | 0 | 131 | 2 |
| Welt: Werkstatt, Gerät | 56 | 4 | 52 | 9 |
| Welt: sonstige Bedienung | 37 | 0 | 37 | 4 |

**Herausforderungen nach Gruppe** (sichtbar / von uns / sichere Lücke): Basics 43/4/8 ·
Homesteading 37/2/5 · AdvancedSurvival 37/5/13 · Workstations 37/0/25 · Traders 37/1/18 ·
Harvesting 35/1/16 · Gatherer 32/0/6 · Farmer 31/0/14 · Healer 33/0/9 · Survivor 35/9/4 ·
Hunter 32/0/0 · Zombies 36/4/28 · Burnt 25/1/3 · Desert 25/1/3 · Snow 25/1/6 · Wasteland 25/1/16.

**Rand** (gemessen, nicht im Kern):

| | Schlüssel | Vanilla | mit Treffer |
|---|---:|---:|---:|
| Untertitel der Händlerstimmen (`subtitles.xml`) | 1.341 | 1.315 | 468 |
| Fertigkeiten, verborgen (Perks, Abschriften, Handwerksstufen) | 386 | 380 | 234 |
| Buffs Twitch/Test | 161 | 154 | 94 |
| UI: Editor, Twitch, Mehrspieler, Schild-Editor | 647 | 610 | 32 |
| UI: Werte von Anzeigearten ohne erreichbaren Gegenstand | 142 | 139 | 5 |
| Herausforderungen Twitch | 98 | 98 | 60 |
| Dialoge `traderTest`, `junkDrone` | 33 | 32 | 11 |
| Quests `test_*` | 83 | 10 | 1 |
| Entitäten, in keiner Spawngruppe | 15 | 9 | 5 |

**Was sich aus XML nicht ableiten lässt** — Schlüssel, die der Spielcode nennt (HUD-Meldungen,
Tooltips, Optionsmenü). Obergrenze über Vanillas Typspalte, Treffer an der ganzen Klasse:
`UI|Menu` 1.095 Schlüssel (50 von uns, 97 Treffer) · `UI|XUI` 460 (3 / 18) · `UI|Tooltip` 247
(0 / 27) · `UI|Controls Dialog` 344 (0 / 26) · `ui_display|Item stat` 184 (0 / 6) ·
`Journal Tip` 99 (0 / 53) · `POI|POIName` 1.091 (0 / 148) · `XUi|Weather Alert` 4 (0 / 0).

---

## 3. Die sicheren Lücken

Die volle Liste mit Vanillas Text steht in `20-ergebnis.tsv` im Scratchpad (vergänglich; mit
`10-sammeln.ps1` und `20-pruefen.ps1` in rund drei Minuten wieder erzeugt). Hier: was
vorgearbeitet ist, und alles Übrige nach Schlüssel und Grund. In eckigen Klammern das erste
Trefferwort.

### 3.1 Vorgearbeitet (129 sichere Lücken, 133 Zeilen)

| Bereich | Zeilen | Beleg aus Vanilla (gekürzt) | Grund |
|---|---:|---|---|
| Startquest | 5 | `quest_white_river_completion`: „Noah sent you, eh? …“ | Noah, White River |
| Startausrüstung | 3 | `medicalFirstAidBandage`: „First Aid Bandage“; `drinkJarBoiledWaterDesc`: „…in the apocalypse“ | first aid, apocalypse |
| Herausforderungen Basics | 10 | `challengeWearClothesDesc`: „The Primitive Outfit might be a little itchy…“ | alter Name, plant fiber, ammo |
| Herausforderungen Homesteading | 9 | `challengePlaceCampfire`: „Place Campfire“ | campfire, spikes trap, blood moon |
| Herausforderungen AdvancedSurvival | 9 | `challengeReadMagazines`: „Read a Magazine“ | magazin, campfire, Iron Gut, beaker |
| Herausforderungen Workstations | 13 | `challengePlaceCementMixer`: „Place Cement Mixer“ | workbench, cement, chemistry station, forged iron, concrete |
| UI | 6 | `lblCategoryAmmoWeapons`: „Ammo/Weapons“; `ttScrapMetalIron`: „…to get scrap iron“ | ammo, cement, chemical, scrap iron, old lantern |
| Buffs | 27 | `buffInfection01UntreatedTooltip`: „…Take antibiotics…“ | antibioti, campfire, first aid, painkiller, vitamin, zombie, Pummel Pete |
| Gegenstände | 41 | `ammoArrowStone`: „Stone Arrow (Ammo)“; `gunBowT0PrimitiveBowDesc`: „…killing zombies…“ | ammo, zombie, campfire, repair kit, alter Name, apocalypse, nail gun |
| Aufsatz | 1 | `modMeleeWeightedHeadDesc`: „Knives and machetes…“ | machete |
| Blöcke | 9 | `cntApiaryDesc`: „…10 Cotton … Repair with Forged Iron“ | forged iron, forged steel, cotton, campfire |

Die vier Zeilen ohne Treffer: `medicalFirstAidBandageDesc` (gehört zum umbenannten Verband),
`challengeRedeemChallenge` und `…Short` („Tutorial Challenge“), `challengeCraftForgedIronDesc`
(Vanillas Text beschreibt Amboss und Blasebalg als Leistungssteigerung — bei uns entscheidet das
eingesetzte Werkzeug über die Arbeit, `forgeDesc`).

### 3.2 Nicht vorgearbeitet: 414 Schlüssel außerhalb der Welt-Blöcke

**Gegenstände und Aufsätze (19).** `biomeWeatherItem4`, `…Desc` [radiation] ·
`modArmorBandolier`, `…Schematic` [Patrone] · `modArmorIntellectDesc` [apocalypse; der Text
nennt ein „AI headgear“] · `resourceRepairKit`, `…Desc` [repair kit] ·
`resourceTestosteroneExtractDesc` [steroid] · `resourceChickenFeedDesc` [Rekt] · elf
Langtexte von Abschriften: `perkFiremansAlmanacHarvestLongDesc` [coal],
`perkGreatHeistGoldRushLongDesc` [dukes, ATM], `perkGreatHeistMotionDetectionLongDesc` [turret],
`perkGreatHeistSafesLongDesc` [Tresor], `perkLuckyLooterLeadLongDesc` [apocalypse],
`perkUrbanCombatLandMinesLongDesc` [land mine], `perkWasteTreasuresAcidLongDesc` [cars],
`…CoffinsLongDesc` [apocalypse], `…HoneyLongDesc` [antibioti], `…SinksLongDesc` [zombie].

**Buffs (55).** Strahlung und Ödland (20): `buffRadiation01*`, `buffRadiation03*`,
`buffWasteland01*`, `buffWasteland_Storm_*`, `buffAtomicSmoothieRunName` · Rüstungssätze (8):
`buffBikerSetBonus*`, `buffEnforcer*`, `buffRangerSetBonusDesc`, `buffRogueSetBonusDesc`,
`buffLumberjackSetBonusDesc` · Mittel und Getränke (20): `buffDrugPainkillers*`,
`drinkJarCoffee*`, `drinkJarBlackStrapCoffee*`, `drinkYuccaJuiceSmoothie`, `drugAtomJunkies*`,
`drugEyeKandy*`, `drugHealthBarDesc`, `drugNerdTatsDesc`, `drugSkullCrushersDesc`,
`drugSteroids*`, `drugSugarButtsDesc`, `drugVitamins*` · sonstige (7):
`buffPerkGunslinger*`, `buffRoadrunnerDesc`, `modRoboticDrone*` (4) · Kamera (5):
`buffShowDetachCamera*`, `buffShowToggleDC*`.

**Fertigkeiten (65).** Rangtexte lebender Perks (42), darunter `perkInfiltratorRank*` [land
mine, 7], `perkPenetratorRank*` [rifle, 5], `perkPerceptionMasteryRank*` [dukes, gun, rifle],
`perkArcheryRank3*` [Scharfschütze], `perkRunAndGunRank2*`, `perkMasterChefRank2Desc`
[dumpster], `perkLockPickingRank3Desc` [Tresor] und zwölf Rangtitel, die noch den alten
Perk-Namen tragen (`perkDeepCutsRank2Desc` „Knife Guy“, `perkLuckyLooterRank5Desc`,
`perkPackMuleRank5Desc`, `perkSlowMetabolismRank5Desc` „Iron Gut“, `perkTheHuntsmanRank*` …) ·
Abschriften (5) · Freischalt-Etiketten der Handwerksstufen (18): `foodT1-4`, `foodT1-5`,
`foodT3-1`, `foodT3-3`, `foodT3-4`, `harvestToolsMechanical`, `medicalT1-1`, `medicalT2-2`,
`medicalT3-1`, `medicalT3-2`, `medicalT3-3`, `seedsT1-1`, `seedsT1-3`, `seedsT1-4`,
`workstationsT1-4` [workbench], `workstationsT2-1`, `workstationsT3-4` [cement],
`workstationsT4-6` [chemistry station].

**Quests (42).** Händleraufträge (33): `quest_clear_completion`,
`quest_fetch_clear_completion`, `quest_tier1…6_*_offer` (17, alle [zombie], zwei dazu [White
River]), `quest_next_trader_*` (5, [dukes]), `quest_restore_power_*` und
`quest_tier2…4_restore_power*` (10, [generator]), `quest_tier1_buried_supplies_offer`
[Cassadore] · `questCassadoreSupplies`, `questWhiteRiverSupplies` ·
`zombie_slayer_*` (7; „Cop Slayer“, „Tourist Slayer“).

**Herausforderungen (140).** Traders (18): `challengeMeet{Bob,Hugh,Jen,Joel,Rekt}*` und drei
Beschreibungen · Harvesting (16): `challengeHarvest{CarParts,ElectricParts,ForgedSteel,
MechanicalParts,Polymers}*`, `challengeHarvestPipesDesc` · Workstations (7):
`challengeCraftGasCan*`, `challengeCraftPipeBomb*`, `challengeCraftConcreteMixDesc` ·
AdvancedSurvival (4): `challengePlaceDewCollector*`, `challengeSpendSkillPointDesc` ·
Homesteading (1): `challengeUpgradeBlocksDesc` · Gatherer (6) · Farmer (14) · Healer (9) ·
Survivor (4) · Zombies (28) · Burnt (3) · Desert (3) · Snow (6) · Wasteland (16) ·
gruppenübergreifend (5).

**Händler (15).** Zehn Dialogzeilen: `dialog_trader_response_{cassadores,navezgane,noah,
theduke,whiteriveroutposts,drone_commands}`, `dialog_trader_statement_{cassadores,navezgane,
noah,theduke}` — **gemessen: es führt kein Weg zu ihnen.** `<response_entry id="background" />`
ist in `dialogs.xml` auskommentiert, und die Drohne ist gesperrt. Dazu die fünf Namen
`npcTrader{Bob,Hugh,Jen,Joel,Rekt}`.

**Entitäten (69).** `animalZombie{Bear,Boar,Dog,Vulture}` [zombie] · 39 Namen mit „Radiated“ /
„Verstrahlt“ · 26 Berufe der Gegenwart: `zombieBiker*`, `zombieBusinessMan*`, `zombieFatCop*`,
`zombieFatHawaiian*` („Tourist“), `zombieJanitor*`, `zombieLab*`, `zombieMaleHazmat*`,
`zombieNurse*`, `zombieDemolition` · `zombieSpider*`.

**UI (9).** `xuiCameraControl`, `xuiCameraPreview`, `goCameraRestrictionModeDesc`,
`xuiRwgEditorPreviewResetCamera` [camera — eine Spieleinstellung, keine Welt] ·
`xuiDewCollector` · `xuiTwitchEnabled`, `xuiTwitchDisabled`, `xuiBtnOptionsTwitch` ·
`xuiCredits` [credit — Fehlalarm der eigenen Liste: gemeint ist der Abspann].

### 3.3 Welt-Blöcke: 401 sichere Lücken von 1.724 Schlüsseln

Kein einziger Behältername der Welt ist von uns. Die häufigsten Trefferwörter (gemessen):
truck 86, garage 47, mailbox 43, Toilette 25, Geländewagen 23, plastic 22, military 20,
cooler 19, gun 11, dumpster 10, ammo 10, machine 10, Automat 8, Tresor 8, Mülltonne 8, car 7,
bus 7, gun safe 6, vending 6. Belege: `cntPickupTruck01Orange` „Orange Pickup Truck“,
`cntMailBox03Pink` „Mailbox“, `cntToilet02` „Fancy Toilet“, `cntCoffeeMaker` „Coffee Maker“,
`cntWaterCoolerFull` „Water Cooler“, `cntDumpsterFlies` „Dumpster“, `cntLootCrateLabEquipment`
„Lab Equipment Box“.

**Angenommen, nicht gemessen:** dass der Bedienhinweis beim Ansehen eines Behälters dessen
Namen zeigt (Vanilla-Verhalten; der Schlüssel dafür steht nicht in XML).

---

## 4. Rangfolge

Was jeder Spieler zuerst sieht, zuerst.

| Rang | Was | Wann | sichere Lücken | vorgearbeitet |
|---|---|---|---:|---:|
| 1 | Startausrüstung (Wasser, Verband) | Minute 1 | 2 | 3 Zeilen |
| 1 | Herausforderungen „Basics“ (läuft als Einführung mit, `is_intro`) | Minute 1 bis 20 | 8 | 10 |
| 1 | Startquest und erster Satz des Händlers | nach der Einführung | 5 | 5 |
| 1 | Kälte, Wunden, Wundfieber (Buffs) | erste Nacht, erster Biss | rund 25 | 27 |
| 1 | Grund-UI: Kategorien der Fertigungsliste, Zerlege-Hinweis | erste Stunde | 6 | 5 |
| 1 | Ladetipps | jeder Start | 0 | — |
| 2 | erreichbare Gegenstände, Blöcke, Aufsätze | erste Stunden | 72 | 51 |
| 2 | Herausforderungen Homesteading, AdvancedSurvival, Workstations, Traders, Harvesting (sichtbar, sobald „Basics“ eingelöst ist) | ab Stunde 1 | 77 | 31 |
| 2 | Behälter, Türen und Geräte der Welt | erster Ort | 401 | 0 |
| 2 | Gegnernamen | **wo sie erscheinen, ist ungemessen** | 69 | 0 |
| 3 | Händleraufträge | ab dem ersten Händler | 42 | 0 |
| 3 | Rangtexte der Fertigkeiten, Freischalt-Etiketten | beim Blättern im Fertigkeiten-Fenster | 65 | 0 |
| 3 | übrige Herausforderungen (Farmer, Healer, Zombies, Biome) | ab Stunde 2 | 94 | 0 |
| 3 | übrige Buffs (Strahlung, Mittel, Rüstungssätze) | je nach Fund | 55 | 0 |
| 4 | Ortsnamen der POIs | bei jedem Auftrag (`{poi.name}`) | 148 nach Muster — **der Sache nach fast alle** | 0 |
| 4 | Untertitel der Händlerstimmen | nur mit eingeschalteten Untertiteln | 468 | 0 |

---

## 5. Zum Textentwurf

`docs/pruefung/0001-textentwurf.csv`: 133 Zeilen, 20 Spalten, UTF-8 ohne BOM, Kopfzeile ist
Vanillas Kopfzeile. Jeder Schlüssel steht in Vanilla und nicht in unserer Datei.

**Geprüft (gemessen):** `60-entwurf-pruefen.ps1` meldet 0 rot — keine Zeile trifft ein
Glossar-Muster (roh gelesen, einschließlich „Spielerdeutsch“), jede Zeile trägt dieselben
Tastenzeichen und `{cvar(…)}`-Platzhalter wie Vanillas Zeile, die Farbmarken sind bilanziert wie
dort. `mod700check localization` meldet `csv_form_fehler 0`, `spalten 20`,
`zeilen_mit_daten 133`, Ausgang 0.

**Wie geschrieben wurde.** Beschreibungen von Dingen sind neu geschrieben, im Ton der
vorhandenen Zeilen. Bedientexte (Herausforderungen, Hinweise) folgen dem Weg, den unsere Datei
schon geht (`challengeQuestCompleteDesc`): Vanillas Aufbau bleibt, die Begriffe wechseln.

**Vor der Übernahme zu beachten:**

1. Die 133 Schlüssel müssen in `tools/check/vanilla-keys.txt` (bewusste
   Vanilla-Überschreibungen), sonst ist `check-all.ps1` rot. Ich habe die Datei nicht angefasst.
2. **Sechs Werkzeug- und Bogenbeschreibungen stehen ohne Reparaturzeile da.** Gemessen: im Dump
   trägt jedes dieser Werkzeuge weiter `RepairTools=resourceRepairKit`. „Repair Kit“ ist
   verboten, „Schleifstein“ wäre heute falsch. Betroffen: `meleeToolPickT1IronPickaxeDesc`,
   `meleeToolPickT2SteelPickaxeDesc`, `meleeToolRepairT1ClawHammerDesc`,
   `meleeToolShovelT1IronShovelDesc`, `meleeToolShovelT2SteelShovelDesc`,
   `gunBowT1WoodenBowDesc`. Sobald WP5 entscheidet, kommt die Zeile dazu.
3. **Die Wundtexte nennen kein Heilmittel mehr, das es nicht gibt.** Gemessen: nicht erreichbar
   sind `drugAntibiotics`, `drugHerbalAntibiotics`, `drugPainkillers`, `drugVitamins`,
   `medicalFirstAidKit`; erreichbar sind `foodHoney`, `medicalBandage`,
   `medicalFirstAidBandage`, `resourceSewingKit`, `drinkJarGoldenRodTea`. Darum sagt der Entwurf
   „mit Honig“, „mit Nähzeug“ — und bei Gehirnerschütterung und Erschöpfung **gar nichts** zur
   Heilung.
4. `challengeCraftClothesHint1` schickt den Spieler in die Liste „Basics“ zum Lumpenkittel.
   **Angenommen:** dass er dort noch steht.
5. Deutsche Gegenstandsnamen im Fließtext (Kochtopf, Kochgrill, Wildbret, Goldrutentee,
   Schmelztiegel, Schlafsack, Gebietsschutzblock) sind gegen Vanillas deutsche Zeile
   nachgeschlagen; „Blasebalg“ steht im Text, der Gegenstand heißt in Vanilla „Fortgeschrittener
   Blasebalg“.

**Neue Namen im Entwurf — jeder ist eine Entscheidung** (Glossar-Regel 1 und 4):

| Schlüssel | Vanilla | Entwurf EN / DE |
|---|---|---|
| `medicalFirstAidBandage` | First Aid Bandage | Salved Bandage / Salbenverband |
| `ammoArrowStone`, `ammoArrowIron`, `ammoArrowFlaming` | … (Ammo) | Stone Arrow / Steinpfeil · Iron Arrow / Eisenpfeil · Flaming Arrow / Brandpfeil |
| `ammoCrossbowBoltStone`, `…Iron`, `…Flaming` | … Crossbow Bolt (Ammo) | Stone Bolt / Steinbolzen · Iron Bolt / Eisenbolzen · Flaming Bolt / Brandbolzen |
| `ammoDartIron` | Iron Dart (Ammo) | Iron Dart / Eisendorn |
| fünf Bündel `ammoBundle*` | Box of … | Bundle of … / …-Bündel (wie `resourceScrapIronBundle`) |
| `resourceArrowHeadSteelAP` | Steel Arrowhead | Armour-piercer Head / Panzerbrecherspitze |
| `lblCategoryAmmoWeapons`, `xuiAmmo` | Ammo/Weapons, Ammo | Missiles/Weapons, Missiles / Geschosse/Waffen, Geschosse |
| `lblCategoryChemicals` | Chemicals | Brews / Gebräue |
| `quest_WhiteRiverCitizen*` | White River Citizen | The Way to the Trader / Der Weg zum Händler |
| `buffInfectionCureDisplayName` | Antibiotic Medicine | Remedy at Work / Heilmittel wirkt |
| `buffChickenFullStress_ZombieHordeName` | Zombie Horde | Pack of the Plague-dead / Rotte Seuchentoter |
| `challengeRedeemChallenge` | Tutorial Challenge | First Challenge / Erste Herausforderung |

Die Wundtexte umschreiben „Infection“ mit „die Wunde schwärt“ / „the wound festers“ und prägen
damit keinen neuen Begriff. Die **Namen** der Wund-Buffs („Mild Infection“ / „Leichte
Infektion“) sind nicht angefasst.

---

## 6. Befunde

1. **Die Welt spricht vollständig Vanilla.** 1.724 Schlüssel von Behältern, Türen, Schildern
   und Geräten, die in Prefabs stehen: 5 von uns (die Werkstätten und eine Tür). 401 mit
   sicherem modernem Wort. Dazu die Ortsnamen: in der Welt Pregen06k01 stehen 966 verschiedene
   Prefabs, **760 davon haben einen Vanilla-Ortsnamen, keiner ist überschrieben** („The MeMaw
   Residence“, „Sal's Safehouse“). Das ist keine Textlücke allein — ein Briefkasten, der
   „Schrein“ heißt, sieht weiter aus wie ein Briefkasten.
2. **Die Herausforderungen sind ungepatcht, und viele sind nicht mehr lösbar.**
   `mod/` enthält keine `challenges.xml`. 512 von 540 Texten sind Vanilla, 179 sichere Lücken.
   Schwerer wiegt (gemessen): **53 Ziel-Angaben nennen eine Kennung, die nach den sechs Wegen
   nicht erreichbar ist** — `craftGasCan` (`ammoGasCan`), `craftPipeBomb`, `placeDewCollector`,
   `harvestCarParts` (`smallEngine`, `carBattery`), `harvestPolymers`,
   `harvestMechanicalParts`, `harvestElectricParts`, sieben Feldfrüchte, zehn Heilmittel der
   Gruppe Healer, die vier Biom-Tränke. Die Gruppen Workstations und Harvesting liegen in der
   Kategorie „Basics“ — sie erscheinen in der ersten Stunde und lassen sich nicht abschließen;
   ihre Gruppenbelohnung bleibt aus. Eine der 53 ist ein Fehlalarm: `placeTorch` verlangt
   `wallTorchLightPlayer`, und der wird über die Fackel gesetzt.
3. **Die Wundtexte verweisen auf gesperrte Heilmittel.** Zwölf Buff-Beschreibungen raten zu
   Antibiotika, Schmerzmitteln, Vitaminen oder dem Verbandskasten; keines davon ist erreichbar.
   Für Gehirnerschütterung (`buffInjuryConcussion`) und Erschöpfung (`buffFatigued`) nennt
   Vanilla **nur** gesperrte Mittel. Ob die beiden in Phase 1 von selbst vergehen, ist
   **unbelegt**.
4. **Die ersten Sätze des Spiels nennen Vanillas Welt.** Die Startquest heißt „White River
   Citizen“, ihr Fenstertext endet mit „Welcome Aboard, Noah“, der Händler grüßt mit „Noah sent
   you, eh?“. Der Zettel davor (`noteDuke01Desc`) ist schon unserer — der Bruch liegt genau
   zwischen den beiden Texten.
5. **174 Gegnernamen, keiner von uns.** 69 treffen ein Muster; der Rest sind Vornamen der
   Gegenwart ohne Treffer („Arlene“, „Steve“, „Tom Clark“, „Big Mama“, „Party Girl“). Die
   englischen Wörter für Verderbte und Moorleichen sind im Glossar §10 offen — darum ist hier
   **nichts vorgearbeitet**.
6. **Grund-UI und Ladetipps sind fast sauber.** 15 Treffer in 531 Vanilla-Zeilen der
   Spielfenster, davon 4 Kamera-Einstellungen und ein Fehlalarm; 0 in den Ladetipps. Aber: was
   der Code nennt, sieht diese Prüfung nicht (§7).
7. **Vom Händlerdialog ist wenig übrig.** Die zehn Treffer (Navezgane, Duke, Cassadores, Noah)
   sind definiert, aber nicht erreichbar. Sichtbar bleiben die fünf Namen (F-10, Phase 2) und
   neutrale Sätze ohne Treffer („Hello friend, how can I help you?“).

**Nebenbefunde an unseren eigenen Dateien** (nicht geändert):

1. Das Glossar-Muster `cement` trifft „pla**cement**“ und „repla**cement**“. Drei
   Vanilla-Kernzeilen fallen so auf (`challengeCraftBedrollDesc`, `challengeCraftLandclaimDesc`,
   `goGameNameDesc`); eine eigene englische Zeile mit „placement“ wäre rot. Im Entwurf steht
   darum „where building is restricted“.
2. Das Muster `\bskill` (DE) trifft das Tastenzeichen `[action:permanent:Skills]`.
   `glossar-pruefen.ps1` liest den Text roh; jede deutsche Zeile mit diesem Zeichen wäre rot.
   Darum fehlt `challengeSpendSkillPointDesc` im Entwurf, obwohl die Zeile geschrieben war.
3. Vier unserer Zeilen benutzen Wörter der eigenen Liste: `perkMasterChefRank2LongDesc`
   („dumpster“ / „Müllcontainer“) und `perkPhysicianRank1…3LongDesc` („first aid“ /
   „Erste-Hilfe“).
4. Erreichbar und der Sache nach modern, also eher ein Fall für den Purge als für einen Text:
   `modArmorBandolier` (Patronengurt, per Rezept), `modArmorIntellect` („AI headgear“, per
   Loot), `resourceTestosteroneExtract` (für Steroide, von Bären), `biomeWeatherItem4`
   („Radiation Gear“, Quest-Belohnung).

---

## 7. Grenzen — was nicht geprüft ist

- **Sichtbar heißt hier: in XML genannt.** Was der Spielcode nennt — HUD-Meldungen, Tooltips,
  das ganze Optionsmenü, der Bedienhinweis an Blöcken, Todesmeldungen — ist nur über Vanillas
  Typspalte als Obergrenze gezählt (§2), nicht als sichtbar belegt.
- **Muster finden Wörter, keinen Ton.** „Good Job Survivor“, „Welcome Aboard“, „HUD“,
  „Tutorial“, „Holy Shit!“ und jeder moderne Vorname gehen durch. Die 3.779 Vanilla-Zeilen ohne
  Treffer sind **ungeprüft**, nicht in Ordnung. Stichprobe: von den 39 Vanilla-Zeilen der
  Gruppe Basics treffen 8 ein Muster; gelesen habe ich alle 39, und weitere zwei
  („Tutorial Challenge“) gehören dazu.
- **Buffs:** gezählt ist jeder nicht verborgene Buff. Ob ein Spieler ihn in Phase 1 bekommen
  kann, ist nicht abgeleitet.
- **Entitäten:** wo der Name eines Gegners im Spiel erscheint, ist ungemessen.
- **Journal-Tipps:** 99 Schlüssel, 53 mit Treffer; im Dump steht kein Auslöser
  (`AddJournalEntry` 0 Fundstellen). Sichtbarkeit unbelegt.
- **Hauptmenü:** `XUi_Menu` steht nicht im Dump; gelesen ist Vanillas Fassung ohne unseren Patch.
- **Groß- und Kleinschreibung:** ein Schlüssel gilt als vorhanden, auch wenn er sich nur in der
  Schreibung unterscheidet (`quest_whiteRiverCitizen1_hint1`). Ob das Spiel das auch so sieht,
  ist angenommen.
- **Nicht angesehen:** `signs.xml` (45 Texte auf Schildern), gemalte Schilder der Prefabs,
  `gameevents.xml` (4 `text_key`), `dmscontent.xml`, Twitch (laut Auftrag egal), die
  gesprochene Sprache der Händler.
- **Kein Spielstart.** Keine Zeile des Entwurfs ist im Spiel gesehen; ob eine Zeile zu lang für
  ihr Feld ist, weiß niemand.
- **Die Prefab-Liste ist die der Installation**, nicht nur die der Welt Pregen06k01; ein Block
  zählt, wenn er in irgendeinem der 1.772 Prefabs steht.

---

## 8. Empfehlungen

1. **Den Entwurf übernehmen, soweit er keine neuen Namen trägt** — die Bedientexte der
   Herausforderungen, die Wund- und Kältetexte, die Tür- und Kistenbeschreibungen, die
   Koch- und Schmiedetexte. Die Namen aus der Tabelle in §5 **[zu prüfen]**, vor allem
   „Salbenverband“, „Geschosse“ für „Ammo“ und der Titel der Startquest.
2. **Herausforderungen: erst die Ziele, dann die Texte.** Eine `challenges.xml` im Purge, die
   unlösbare Herausforderungen entfernt oder ersetzt — sonst schreiben wir Texte für Aufgaben,
   die niemand abschließen kann. **[zu prüfen]** Entfernen, ersetzen oder die ganze Kategorie
   bis Phase 2 ausblenden? Die Texte der lösbaren (Homesteading, Werkstätten) liegen im Entwurf.
3. **Heilmittel für Gehirnerschütterung und Erschöpfung.** **[zu prüfen]** Vergehen sie in
   Phase 1 von selbst (dann genügt der Text), oder braucht es ein Kraut vor F-11?
4. **Die Welt (F-07) entscheidet über 401 + 760 Texte.** Solange Vanillas Orte stehen, ist
   jeder neue Name eine Umdeutung eines sichtbar modernen Dings. **[zu prüfen]** Behälter
   gattungsweise umbenennen („Truhe“, „Wagen“, „Abfallhaufen“ — rund 30 Gattungen decken die
   316 Behälter-Treffer), oder bis zu eigenen Orten warten? Ortsnamen: einen Sammelnamen je
   Gattung statt 760 Einzelnamen?
5. **Gegnernamen brauchen zwei Entscheidungen.** **[zu prüfen]** Die englischen Wörter für
   Verderbte und Moorleichen (Glossar §10.1), und ein Namensmuster für die Grundtypen
   (Herkunft und Stand statt Vorname: „Seuchentoter Knecht“, „Seuchentote Magd“). Vorher messen,
   wo der Name überhaupt erscheint.
6. **Händleraufträge „Restore Power“** (10 Texte, Generatoren). **[zu prüfen]** Den Auftragstyp
   in Phase 1 aus den Händlerlisten nehmen statt ihn umzuschreiben? Die 17 Angebote
   `quest_tier*_offer` sind danach Schreibarbeit im Händlerton — der nächste Stapel.
7. **Zwei Glossar-Muster schärfen:** `cement` am Wortanfang (`\bcement`), und
   `glossar-pruefen.ps1` sollte Tastenzeichen `[action:…]` vor dem Abgleich entfernen.
   **[zu prüfen]** — das Glossar ändert nur der Nutzer.
8. **Vier erreichbare moderne Dinge sperren statt beschreiben** (§6, Nebenbefund 4).
   **[zu prüfen]**
9. **Die Rangtitel mit altem Perk-Namen** (zwölf Zeilen, §3.2) fallen in WP7 an; sie sind
   Fleißarbeit ohne Entscheidung und der billigste nächste Schritt.
10. **Diese Prüfung wiederholbar machen.** Die Skripte liegen im Scratchpad und gehen verloren.
    **[zu prüfen]** Als `tools/check/textluecken-pruefen.ps1` übernehmen — als Bericht, nicht
    als Sperre, bis die Zahl klein genug ist?
