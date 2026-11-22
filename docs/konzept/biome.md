# Konzept — Biome und was sie verlangen

| | |
|---|---|
| **Stand** | 2026-11-22 |
| **Auftrag** | Messen, was V 3.40 an Biomen, Gefahren und Pflicht-Ausrüstung hat; prüfen, ob der Biom-Fortschritt mit unserer Mod noch lösbar ist; die fünf Biome ins Mischland übersetzen; die Ausrüstung und die Texte dazu vorschreiben. |
| **Status** | **Konzept. Gebaut ist nichts**, keine Datei außer dieser ist geändert. Jeder Welt-Begriff ist ein Vorschlag (Glossar-Regel 4), jede Entscheidung steht in §5 mit **[zu prüfen]**. Phasen strikt (D50): §4 sagt, was wohin gehört. |
| **Gilt mit** | D34, D43, D50, D72, D80, D87, D89, F-07, F-06, F-11, F-15, [ruestung.md](ruestung.md) |

**Marken** wie in [ruestung.md](ruestung.md):

- **[gemessen]** — aus einer Datei gelesen, Fundstelle steht dabei. „Vanilla" ist
  `…\7 Days To Die\Data\Config\` (V 3.40 b10), „Dump" ist der gemergte Stand
  `Saves\Pregen06k01\Z\ConfigsDump\` vom 2026-11-22 22:08, „Mod" ist `mod/`.
- **[gelesen, nicht gesehen]** — aus dem XML geschlossen, im Spiel von niemandem beobachtet.
- **[Wissen]** — historisches Allgemeinwissen, für dieses Dokument nicht nachgeschlagen.
- **[Vorschlag]** — Setzung dieses Dokuments, wartet auf den Nutzer.

---

## 0. Kurzfassung

1. **Der Biom-Fortschritt ist mit unserer Mod nicht lösbar** **[gemessen]**, und er war im
   letzten Testlauf **eingeschaltet** (Spielprotokoll vom 2026-11-22, Zeile 326 und 632:
   `BiomeProgression = True`). In jeder der vier Reihen nennen **4 von 7** Aufgaben gesperrte
   Kennungen; alle vier Gegenmittel sind gesperrt; die vier Rezepte der Biom-Ausrüstung hat unser
   eigenes Modlet entfernt. Beleg in §1.10.
2. **Die Folge im Spiel** **[gelesen, nicht gesehen]**: außerhalb des Startbioms läuft unter
   freiem Himmel eine Frist ab, danach verliert der Spieler Leben, bis er unter einem Dach
   steht. Es gibt kein Mittel, das die Frist verlängert, und keines, das sie aufhebt. Die Texte
   dazu sprechen von „Anthrakoseserum", „Fallout Flush" und „Radioaktiver Strahlung".
3. **Das ist kein Fehler einer Zeile, sondern eine fehlende Entscheidung**: Plan-0001 hält schon
   fest, dass „in keinem Dokument steht", ob die Gefahren in Phase 1 an sind. Dieses Dokument
   legt drei Wege vor (§1.10) und empfiehlt: **in Phase 1 abschalten, mit F-07 umgedeutet
   zurückholen.**
4. **F-07s Zuordnung der Biome trägt an zwei Stellen nicht** **[gemessen]**: die „Küste" liegt
   auf einem Biom ohne Meer mit Kakteen bei 35–41 °C, und die „Heide" auf einem Biom mit
   Dauerfrost und Schneefall. Das Brandland ist nicht „höchste Gefahr", sondern das zweitleichteste
   Biom. Vorschlag in §2.
5. **Eine Angabe im Bestand ist falsch** **[gemessen]**: die Biom-Ausrüstung trägt in Vanilla sehr
   wohl Namen („Rauchausrüstung", „Strahlungsausrüstung", §1.11).

---

## 1. Was V 3.40 hat

### 1.1 Die fünf Biome **[gemessen]**

Vanilla `biomes.xml`, Kopfzeilen der fünf `<biome>`-Knoten (Zeilen 137, 513, 810, 1141, 1426);
Biomkarten-Nummern aus `<biomemap>` (snow 01, pine_forest 03, desert 05, wasteland 08,
burnt_forest 09).

| Biom | `difficulty` | Beutestufe: Faktor / Zuschlag | Spielstufe: Faktor / Zuschlag | Gefahr-Buff |
|---|---|---|---|---|
| `pine_forest` | 1 | 0 / 0 | 0 / 0 | `buffForest_Hazard` (heilt nur) |
| `burnt_forest` | 2 | 0,5 / 5 | 0,5 / 10 | `buffBurnt_Hazard` |
| `desert` | 3 | 1 / 10 | 1 / 10 | `buffDesert_Hazard` |
| `snow` | 4 | 1,5 / 15 | 3 / 30 | `buffSnow_Hazard` |
| `wasteland` | 5 | 2 / 20 | 5 / 50 | `buffWasteland_Hazard` |

Die Reihenfolge ist fest und steil: Das Ödland hebt die Spielstufe um das Fünffache plus 50.
**Diese Staffel bleibt, egal ob der Biom-Fortschritt an oder aus ist** — sie hängt am Biom, nicht
an der Spieloption.

### 1.2 Wetter **[gemessen]**

Vanilla `biomes.xml`, `<weather>`-Knoten je Biom; ausgewertet mit einem PowerShell-Skript im
Scratchpad. Temperaturen in °F, wie die Datei sie führt; °C gerundet daneben.

| Biom | Wetter (Wahrscheinlichkeit) | Temperatur | Sturm: Dauer, Buff, Temperatur |
|---|---|---|---|
| `pine_forest` | klar 83, Nebel 7, Regen 6 + 4 | 76–80 °F (24–27 °C); Nebel 65–70 °F | 1,1 · **kein Buff** |
| `burnt_forest` | klar 83, Regen 10 + 7 | 75–85 °F (24–29 °C) | 1,2 · `buffBurnt_Storm` · 85–99 °F |
| `desert` | klar 90, Regen 5 + 5 | 95–105 °F (35–41 °C) | 1,3 · `buffDesert_Storm` · 100–110 °F |
| `snow` | klar 44, Nebel 8, Schnee 28 + 20 | 28–32 °F (−2–0 °C); Schnee 23–32 °F | 1,4 · `buffSnow_Storm` · 12–18 °F (−11 bis −8 °C) |
| `wasteland` | klar 40, kalt 20, heiß 23, Regen 10 + 7 | 60–90 °F; kalt 35–45 °F (2–7 °C); heiß 95–105 °F | 1,5 · `buffWasteland_Storm` · 33–99 °F |

Der Sturm steht in jedem Biom mit Wahrscheinlichkeit 0 im Wetter; ausgelöst wird er über die
Spieloption `StormFreq` (im Testlauf `GamePref.StormFreq = 100`, Protokoll Zeile 577).

### 1.3 Die Biom-Gefahr **[gemessen]**

Vanilla `buffs.xml`:11660–12940, `entityclasses.xml`:426–429 und 483–490.

- **Schalter:** die Spieloption `BiomeProgression`. `buffBiomeProgressionCheck` (11660) und die
  vier Gefahr-Buffs (`buffBurnt_Hazard` 11799, `buffDesert_Hazard` 12080, `buffSnow_Hazard`
  12381, `buffWasteland_Hazard` 12662) tragen `required_game_stat="BiomeProgression"`. Ist die
  Option aus, werden die Gefahr-Buffs beim Betreten des Spiels entfernt (`entityclasses.xml`:483–490).
  Optionstext: „Aktiviert oder deaktiviert Biomgefahren. Wetter und Stürme sind von dieser
  Einstellung nicht betroffen." (`goBiomeProgressionDesc`).
- **Frist:** je Biom ein Zähler `$BurntHazardTimer`, `$DesertHazardTimer`, `$SnowHazardTimer`,
  `$WastelandHazardTimer`; Höchstwert **180**, gesetzt beim ersten Erscheinen der Spielfigur
  (`entityclasses.xml`:426–429, `onSelfFirstSpawn`). Unter freiem Himmel −1 je Takt, unter Dach
  (`IsSheltered`) +3 je Takt. Die Länge des Takts ist nicht gemessen; bei einer Sekunde wären
  es drei Minuten.
- **Stufe 1** (`…Hazard01`): Warnung mit Zähler, solange die Frist läuft und kein Stück mit
  dem Tag `biomeBadgeN` getragen wird. Im Ödland spielt dazu der Ton `buff_geiger_counter`.
- **Stufe 2** (`…Hazard02`, Takt 2 Sekunden): Frist abgelaufen → `AddHealth -1` je Takt,
  Husten-Partikel (`p_weatherEffects_smokeCough`, `…DesertsmokeCough`, `…freezingBreath`,
  `…WastelandsmokeCough`), Ton `player#smoke`. Endet erst unter Dach.
- **Das Startbiom** heilt: `buffForest_Hazard` (11672) füllt alle vier Zähler mit +3 je Takt.

### 1.4 Was Vanilla dagegen verlangt **[gemessen]**

**a) Vier Getränke** (Vanilla `items.xml`, `recipes.xml`). Jedes legt 300 auf den Zähler seines
Bioms (Deckel 900) und halbiert den Schaden der zweiten Sturmstufe.

| Kennung | Vanilla-Name | Modell, Ton | Zutaten |
|---|---|---|---|
| `foodBurntSmoothie` | Anthrakoseserum / Black Lung Serum | **Spritze** (`syringeMedical_01Prefab`), `player_syringe` | `resourceCoal` 5, `resourceYuccaFibers` 20, `foodCropMushrooms` 5, `drinkJarBoiledWater` 1 |
| `foodOasisSmoothie` | Sonnenstich-Tonikum / Sunstroke Tonic | Glas, Trinkton | `resourceCropAloeLeaf` 5, `resourceOilShale` 5, `foodCropMushrooms` 5, `drinkJarBoiledWater` 1 |
| `foodFrostbiteSmoothie` | Feuereintopf / Scorcher Stew | **Topf** (`foodPotPrefab`), Trinkton | `foodCropBlueberries` 5, `foodGrilledMeat` 1, `foodCanChili` 1, `drinkJarBeer` 1 |
| `foodAtomicSmoothie` | Fallout Flush | **Spritze**, `player_syringe` | `foodCropYuccaFruit` 5, `foodCropGraceCorn` 1, `foodCropMushroomsRadiated` 5, `resourceAcid` 1 |

**b) Vier Stücke Biom-Ausrüstung** `biomeWeatherItem1–4` (Vanilla `items.xml` ab etwa Zeile
30326): eigener Platz `BiomeBadge` bis `BiomeBadge4`, Tag `biomeBadge1–4`, ohne Qualität, ohne
Aufsätze; das höhere ersetzt das niedrigere im Platz. Getragen heben sie die Biom-Gefahr auf —
**nicht** Temperatur und Sturm (Vanillas eigener Text). `UnlockedBy` ist die Reihe des Bioms.
Rezepte (alle `craft_time` 60, Tag `biomeProgression`):

| Stück | Vanilla-Name | Zutaten |
|---|---|---|
| 1 | Rauchausrüstung / Smoke Gear | `resourceArmorCraftingKit` 1, `resourceScrapPolymers` 20, `resourceLeather` 10, `resourceCloth` 20, `resourceCoal` 50 |
| 2 | Wüstenausrüstung / Desert Gear | Kit 1, Polymers 20, Leather 10, Cloth 20, `resourceScopeLens` 2 |
| 3 | Schneeausrüstung / Snow Gear | Kit 1, Polymers 20, Leather 10, `resourceCropCottonPlant` 50, `resourceScopeLens` 2 |
| 4 | Strahlungsausrüstung / Radiation Gear | Kit 1, Polymers 20, Leather 10, `resourceScrapLead` 100, `resourceForgedSteel` 10 |

Die älteren `biomeBadge1–4` sind in Vanilla als veraltet markiert; die Aufträge
`challengegroup_reward_*` (Vanilla `quests.xml`:596–655) tragen den Vermerk
„NO_LONGER_USED_BUT_KEEP_FOR_V2_0_SAVE_GAMES", nichts verweist auf sie.

**c) Vier Reihen von je sieben Aufgaben** (Vanilla `challenges.xml`: Kategorie „Biome
Progression" Zeile 20 mit `show_type="BiomeProgression"`; Gruppen 65–79 mit
`link_challenges="true"`; Aufgaben 860–1080). Lohn der vollen Reihe (`gameevents.xml`:981–1012):
das Rezept des Biom-Stücks wird freigeschaltet, dazu 10 000 Erfahrung und die Meldung
`challengeBiomeRewardTooltip`.

| Nr. | Aufgabe | Brandwald | Wüste | Schnee | Ödland |
|---|---|---|---|---|---|
| 1 | unter Dach stehen | ✓ | ✓ | ✓ | ✓ |
| 2 | 5 Pflanzen ernten | `foodCropMushrooms` ✓ | `resourceCropAloeLeaf` ✓ | `foodCropBlueberries` ✗ | `foodCropMushroomsRadiated` ✗ |
| 3 | Getränk herstellen | ✗ | ✗ | ✗ | ✗ |
| 4 | Getränk benutzen | ✗ | ✗ | ✗ | ✗ |
| 5 | Gegner des Bioms töten | ✓ | ✓ | ✓ | ✓ |
| 6 | 250 Erz abbauen | `resourcePotassiumNitratePowder` ✗ | `resourceOilShale` ✗ | `resourceCoal` ✓ | `resourceScrapLead` ✓ |
| 7 | Zutaten des Stücks sammeln | ✗ (Kit, Polymers) | ✗ (Kit, Polymers, Linse) | ✗ (Kit, Polymers, Linse) | ✗ (Kit, Polymers) |

✓ = mit unserer Mod erfüllbar, ✗ = nennt eine gesperrte Kennung (§1.9). **In jeder Reihe 4 von 7.**

### 1.5 Stürme **[gemessen]**

Vanilla `buffs.xml`:10560–11660. Unabhängig vom Biom-Fortschritt (kein `required_game_stat`).

| | Stufe 1 | Stufe 2 |
|---|---|---|
| Dauer der Stufe 1 | 30 Sekunden + 30 × `.insulationTotal` | — |
| Brandwald | höchste Ausdauer sinkt (25) | −2 Leben je Sekunde |
| Wüste | Wasser −0,1 je Takt; Gehen, Laufen, Springen, Nachladen −10 % | −2 |
| Schnee | Nahrung −0,1 je Takt; Bewegung langsamer (Buff −15 %, Vanillas Text sagt 10 %) | −2 |
| Ödland | höchstes Leben und höchste Ausdauer sinken (50), Abnutzung +2 je Benutzung | **−4** |

Stufe 2 endet unter Dach; das Getränk des Bioms halbiert ihren Schaden. Im Sturm steigt die
Beutewahrscheinlichkeit um 5 %. `.insulationTotal` kommt **allein aus der Unterkleidung**
(Vanilla `buffs.xml`:740–806): je getragenem Stück 0,5 · 0,75 · 1,0 (T1 · T2 · T3), also
höchstens 4 und damit höchstens 150 Sekunden.

### 1.6 Temperatur **[gemessen]**

Vanilla `buffs.xml`:488–512, eigene Spieloption `TemperatureSurvival`. Schwellen der
Körpertemperatur `_coretemp`: **heiß** über 85, **sengend** ab 100, **kalt** unter 50,
**eisig** ab 32 abwärts. Keine Stufe tötet: heiß und kalt kosten 10 % Tempo und mehr Wasser bzw.
Nahrung, sengend und eisig 20 % und das Doppelte. Nässe verschiebt beide Widerstände.

Dagegen helfen `HypothermalResist` und `HyperthermalResist`. **Bei uns tragen sie nur die
zwölf Stücke Unterkleidung und drei Futter-Aufsätze, beides nur aus Beute** — keines unserer 16
Rüstungsteile ([ruestung.md](ruestung.md) §2.0, §2.5, §4). Wie viel Widerstand eine Stufe
aufhebt, ist nicht gemessen.

### 1.7 Gegner und Tiere je Biom **[gemessen]**

Vanilla `spawning.xml`:18–112 mit `entitygroups.xml`.

| Biom | Eigene Seuchentote | Wild | Raubtiere |
|---|---|---|---|
| `pine_forest` | allgemeine Gruppen | Huhn, Kaninchen; nachts Hirschkuh, Hirsch | nachts Eber, Schlange |
| `burnt_forest` | `zombieBurnt`, `zombieBurntFeral`, `zombieSteveCrawler` | — | Eber, Schlange; nachts Kojote, Geier (`animalZombieVulture`) |
| `desert` | `zombieFatHawaiian`, `zombieMoe`, `zombieRancher`, `zombieSteveCrawler`; die Reihe nennt `zombiePlagueSpitter*` | — | Kojote, Schlange, Geier; nachts Eber, Berglöwe, Wolf |
| `snow` | `zombieChuck`, `zombieLumberjack`, `zombieMoe`; die Reihe nennt `zombieFrostclaw*` | nachts Hirsch | Bär, Jungbär, Berglöwe, Wolf; nachts `animalDireWolf`, `animalZombieDog` |
| `wasteland` | `zombieFatCop`, `zombieMaleHazmat`, `zombieMutated` (fünf Fassungen), `zombieWightFeral` | — | `animalDireWolf`, Schlange, `animalZombieBear`, `animalZombieDog`, Geier; nachts noch dichter |

Im Ödland sind die nächtlichen Wartezeiten bis zum Nachrücken um Größenordnungen kürzer als
anderswo (Werte um 0,003).

### 1.8 Bewuchs, Boden, Erz **[gemessen]**

Vanilla `biomes.xml`, Dekorations- und Schichtknoten; der Dump unterscheidet sich davon **nur
durch D72** (Nebel), der Bewuchs ist also bei uns derselbe.

| Biom | Was dort steht | Erz |
|---|---|---|
| `pine_forest` | Bergkiefer, Eiche, Wacholder (`treeJuniper4m`), Azalee, Sträucher; Flachs (`plantedCotton3Harvest`), Chrysantheme, Schneebeere, Goldrute | Salpeter, Blei, Eisen, Kohle |
| `burnt_forest` | verbrannter Boden, verkohlte Kiefern, Gluthaufen (`emberPileDeco1–8`), Pilze, tote Sträucher | dieselben vier |
| `desert` | Sandstein, **Kakteen** (`treeCactus01–06`), Wüstenstrauch, Yucca, Aloe, Treibholz, Rinderschädel, kleine Eichen, **Autos** (`carsRandomHelper`) | Salpeter, **Ölschiefer**, Blei, Eisen |
| `snow` | Schnee, Winterkiefern, tote Büsche; Schneebeere, Blaubeere | vier, mit Kohle |
| `wasteland` | verbrannter Ahorn, zerstörtes Gras, „verstrahlte" Pilze, **Radkappen- und Dosenminen**, **Autowracks**, **Schrotthaufen**, Betonsteine, Ziegelschutt, **Fässer** (`cntBarrel*`) | vier, mit Kohle |

Die fett gesetzten Dinge stehen im Dump weiter in der Biom-Dekoration (54 Treffer für Kakteen,
Autos, Fässer, Minen und Schrott in `ConfigsDump\biomes.xml`). Ob ein anderes Modlet die Blöcke
selbst ersetzt, ist hier nicht gemessen.

### 1.9 Was unsere Mod daran ändert und sperrt **[gemessen]**

| Wo | Was |
|---|---|
| `700_60_Welt/Config/biomes.xml` | nur Nebel (D72): Kiefernwald und Ödland nebliger. Kein Eingriff in Gefahr, Temperatur, Sturm, Bewuchs, Gegner. |
| `700_60_Welt` sonst | Feuerstellen-Aura, Tonabstände der Seuchentoten, dunklere Nacht. |
| `700_10_Purge` über `tools/check/denylist.txt` | gesperrt: `food*Smoothie*` (315), `food*Blueberr*` (319), `foodCropYuccaFruit` (321), `foodCropMushroomsRadiated` (322), `foodCan*` (43), `resourceScrapPolymers` (55), `resourceAcid` (57), `resourcePotassiumNitratePowder*` (58), `resourceScopeLens` (64), `resourceArmorCraftingKit` (344), `plantedGraceCorn*` (374), `plantedBlueberry*` (377), dazu `resourceOil*`. Der Purge nimmt auch die Block-Abwürfe gesperrter Dinge weg. |
| Denylist, freigegeben | `!biomeWeatherItem*` (463, „unsichtbare Fortschrittsmarke, kein Gegenstand"), `!clothing*`, die Zutaten Holzkohle, Nesselfaser, Pilze, abgekochtes Wasser, Aloe, Bier, gebratenes Fleisch, Blei. |
| `700_30_Ausruestung/Config/recipes.xml`:845–848 | **entfernt die vier Rezepte `biomeWeatherItem1–4`** (D89, Tabelle 4). |
| `challenges.xml`, `gameevents.xml`, `sandbox_overrides.xml` | **kein Eingriff** (D80 lässt die Herausforderungen ausdrücklich stehen). |
| `700_90_Sprache` | keine Zeile zu Biomnamen, Gefahr-Buffs, Stürmen, Biom-Reihen, Getränken oder Biom-Ausrüstung. Im Spiel steht dort Vanillas Text. |

### 1.10 Ist der Biom-Fortschritt mit unserer Mod lösbar?

**Nein.** Vier Belege, jeder für sich hinreichend:

1. **Die Reihen sind nicht abschließbar.** In jeder der vier Reihen nennen die Aufgaben 3, 4
   und 7 gesperrte Kennungen, dazu je eine weitere (Tabelle §1.4 c). Der Lohn hängt an der
   vollen Reihe. D80 kennt das als „je vier von sieben in allen vier Biom-Reihen".
2. **Die Getränke sind nicht herstellbar.** `food*Smoothie*` steht in der Denylist (Zeile 315);
   im Dump sind die vier Rezepte vom Purge entfernt (`recipes.xml` des Dumps, Zeilen 820–826),
   Beute und Händler führen sie nicht.
3. **Die Biom-Ausrüstung ist nicht herstellbar.** Unser Modlet entfernt die vier Rezepte
   (`700_30_Ausruestung/Config/recipes.xml`:845–848; im Dump Zeilen 537–540). Selbst mit Rezept
   fehlten drei Zutaten (Kit, Kunststoff, Linse).
4. **Es gibt keinen anderen Weg.** Im Dump nennt außer den stillgelegten Aufträgen aus §1.4 b
   nichts `biomeWeatherItem1–4` — keine Beute, kein Händler, kein Lohn.

**Und der Schalter stand auf An** **[gemessen]**: Spielprotokoll
`output_log_client__2026-11-22__22-07-19.txt`, Zeile 326 `GamePref.BiomeProgression = True`,
Zeile 632 `GameStat.BiomeProgression = True`, Voreinstellung `Adventurer` (Zeilen 549–550).

**Was das im Spiel heißt** **[gelesen, nicht gesehen]:**

- Im Kiefernwald geschieht nichts.
- In den vier anderen Biomen läuft unter freiem Himmel die Frist von 180 ab; danach kostet
  jeder Takt von zwei Sekunden ein Leben, bis der Spieler unter einem Dach steht. Unter Dach
  füllt sich die Frist dreimal so schnell, wie sie abläuft.
- Wohnen und Arbeiten unter Dach geht überall. Wandern, Jagen, Erz brechen und Bauen im Freien
  geht nur in Abschnitten von je einer Frist — für immer, weil nichts sie verlängert.
- Die Texte versprechen dabei drei Auswege („Ein Schuss Anthrakoseserum, das Suchen von
  Unterschlupf und das Fertigen von Überlebensausrüstung"), von denen zwei nicht existieren.
- Das Spiel ist nicht blockiert: Eisenerz liegt in jedem Biom (§1.8). Es ist in vier Fünfteln
  der Welt dauerhaft feindlich, ohne dass der Spieler etwas dagegen lernen kann — das Gegenteil
  eines Fortschritts.

**Was zum vollen Beleg fehlt:**

| Offen | Warum es zählt |
|---|---|
| Niemand hat es im Spiel gesehen. | Alles oben ist aus XML und Protokoll gelesen. Ein Lauf von wenigen Minuten im Brandwald zeigt Zähler, Text und Schaden. |
| Länge des Takts (Frist in Sekunden?) | bestimmt, ob „180" drei Minuten sind. |
| Bedeutung von `link_challenges="true"` | Sind die Aufgaben eine Kette, steht die Reihe schon bei Aufgabe 2 oder 3 still und die erfüllbaren späteren werden nie angeboten. |
| Voreinstellung von `BiomeProgression` auf dem Dedicated Server und in anderen Spielvoreinstellungen | Die XML nennt sie nicht; `serverconfig.xml` hat keinen Eintrag. |
| Ob die Kategorie der Reihen bei ausgeschalteter Option wirklich verschwindet | `show_type="BiomeProgression"` legt es nahe. |

**Drei Wege [Vorschlag]:**

| Weg | Was | Aufwand | Urteil |
|---|---|---|---|
| **A — abschalten** | In Phase 1 läuft die Welt ohne Biom-Gefahr. Stürme, Temperatur und die Staffel aus §1.1 bleiben. | Am wenigsten: die Spieloption beim Anlegen der Welt (ohne jede Datei, aber jeder Gastgeber muss es wissen) — oder fest über `sandbox_overrides.xml` (sperrt die Option auf ihrer Voreinstellung; **nur brauchbar, wenn die „aus" ist — ungemessen**) — oder über das XML der Buffs (ungebaut, ungeprüft; die Bedingungen von Stufe 2 müssen vorher gelesen werden). | **Empfohlen für Phase 1.** Ehrlich, klein, nichts verspricht mehr etwas Gesperrtes. |
| **B — umdeuten und zurückholen** | Getränke, Biom-Stücke und Reihen bekommen Namen, Zutaten und Ziele des Settings (§3). | Alles XML und Text, aber viel: vier Freigaben in der Denylist, vier bis acht Ersatz-Zutaten, zwei Modelle und Töne tauschen (Spritze), zwölf Aufgabenziele in `challenges.xml`, vier Rezepte zurück, rund 150 Sprachzeilen. | Gehört der Sache nach zu **F-07 (Phase 2)**. Vorziehen hieße: als Folgearbeit des Purge führen, wie D87 es für die Fernkampf-Namen tat. |
| **C — lassen** | Zustand heute. | keiner | **Nicht haltbar:** unlösbar und mit Vanillas modernsten Texten. |

### 1.11 Eine falsche Angabe im Bestand **[gemessen]**

`docs/balancing/0003…` (Tabelle 4) und der Kommentar in
`700_30_Ausruestung/Config/recipes.xml`:841 sagen, `biomeWeatherItem1–4` trügen „in Vanilla
keinen Namen (leere Zeile in der Sprachdatei)". Vanillas `Localization.csv` führt sie mit Namen
und Beschreibung: **Rauchausrüstung, Wüstenausrüstung, Schneeausrüstung, Strahlungsausrüstung**
(Zeilen 12691–12698). Vermutete Ursache: Die Datei hat eine Spalte mehr (`KeepLoaded`) als
unsere, Englisch ist das siebte Feld, Deutsch das neunte — wer mit den Spalten unserer Datei
liest, sieht leere Felder. Die Folge für D89 ist klein (die Rezepte zu entfernen bleibt
vertretbar, weil drei Zutaten gesperrt sind), aber die Begründung „kein Gegenstand" in der
Denylist (Zeile 463) stimmt nicht: Es ist ein benannter, tragbarer Gegenstand mit eigenem Platz.
Geändert ist hier nichts.

---

## 2. Setting-Entwurf: fünf Landschaften des Mischlands

### 2.1 F-07s Ansatz, und wo er nicht trägt

F-07 (D43) legt die Kulturzonen auf die Vanilla-Biome und behält die technischen Kennungen —
der richtige Weg: Biomnamen stehen an sieben Stellen fest im Code (F-07, Stand 2026-11-07),
änderbar sind Anzeigename, Bewuchs, Wetter, Gegner. **Darauf baut dieser Entwurf.** Drei
Zuordnungen widersprechen aber dem Gemessenen:

| F-07 | Gemessen | Urteil |
|---|---|---|
| **Küste** = `desert` (nordisch, Bernstein, Salz) | kein Meer im Biom; 35–41 °C, im Sturm bis 43 °C; Kakteen, Yucca, Aloe, Sandstein | Eine Küste ohne Wasser ist nicht erzählbar. Die Küste braucht die eigene Karte (Phase 4). |
| **Burgwall-Land** = `snow`, „Mittelgebirge/Heide" | Dauerfrost um 0 °C, Schneefall mit 48 %, Winterkiefern, Schneeboden | „Mittelgebirge" trägt, „Heide" nicht. |
| **Brandland** = „höchste Gefahr, Seuchenkult" | `difficulty` 2 von 5, kleinster Zuschlag nach dem Startbiom | Das Brandland ist das **erste** Biom nach dem Start. Die höchste Gefahr ist das Ödland (5; Spielstufe ×5 +50). |
| keine keltische Zone | GDD 2.1 nennt „keltische Randgebiete im Westen" | Lücke. |

### 2.2 Vorschlag **[Vorschlag]**

Die Reihenfolge folgt der gemessenen Staffel: Der Spieler geht vom Bewohnten ins Verlassene.

| Biom | Stufe | Landschaft | Kulturkreis | Deutsch | Englisch (offen) |
|---|---|---|---|---|---|
| `pine_forest` | 1 | Wald, Flusstal, Rodungsinseln | fränkisch-romanisch | **Klosterland** | Cloister Lands |
| `burnt_forest` | 2 | abgebrannter Wald, verkohlte Höfe | germanisch | **Brandland** | Burnt Lands |
| `desert` | 3 | Binnendünen, Sandheide, Kiefern und Wacholder | slawisch | **Sandheide** | Sand Heath |
| `snow` | 4 | Hochland, auf dem der Winter nicht weicht | nordisch | **Winterhöhen** | Winter Fells |
| `wasteland` | 5 | Moor | niemandes Land; keltische Spuren | **Moorland** | Mirelands |

„Klosterland", „Brandland" und „Moorland" stehen schon in F-07 und D72; neu sind „Sandheide" und
„Winterhöhen" sowie alle englischen Fassungen. **Jeder dieser Namen ist eine Entscheidung des
Nutzers** (Glossar-Regel 4); die Abweichung von D43 braucht eine neue D-Zeile.

**Was der Vorschlag kostet:** Das „Burgwall-Land" wandert vom Schnee auf den Sand — Burgwälle
aus Holz und Erde auf sandigem Grund sind für den slawischen Raum zwischen Elbe und Oder gut
belegt **[Wissen]**, das passt besser als zum Schnee. Die nordische Zone verliert die Küste und
bekommt das Hochland; ihr Bernstein und ihr Salz warten auf die eigene Karte. **Variante:**
germanisch auf die Winterhöhen, Brandland ohne eigenen Kulturkreis (es ist abgebrannt, wer immer
dort wohnte), nordisch erst mit der Küste.

**Das Moor und die Kelten — eine Warnung.** Bohlenwege, Opfer im Moor und Inselhäuser im See
(Crannogs, um 700 in Irland und Schottland bewohnt) sind gut belegt **[Wissen]** und machen das
Moor zum naheliegenden Ort für keltische Spuren. Aber das gefährlichste Biom einem lebenden
Kulturkreis zu geben, macht diesen Kulturkreis zum Schrecken. Deshalb: Das Moor gehört
**niemandem mehr**; was dort steht, ist älter als alle fünf Kreise oder verlassen. Ein lebendes
keltisches Gesicht bekommt die Welt mit dem Westrand der eigenen Karte.

### 2.3 Steckbriefe

Tiere und Gegner sind Vanillas (§1.7); ihre Umdeutung ist F-06, Phase 2, und hier nur notiert.
Die Ursache der Seuche bleibt in jedem Text offen (Glossar-Regel 5).

#### Klosterland — `pine_forest`

- **Stimmung:** das letzte bewohnte Land. Glocken, die niemand mehr läutet; Felder, die noch
  bestellt aussehen. Der Schrecken ist das Vertraute, das leer steht.
- **Wetter:** mild, 24–27 °C; Morgennebel (D72 hat ihn verdoppelt).
- **Pflanzen:** Kiefer, Eiche, Wacholder; Flachs, Goldrute. Vanillas Azalee und Chrysantheme
  sind Gartenpflanzen späterer Zeit — für Phase 2 notiert.
- **Tiere:** Hirsch, Eber, Schlange (Kreuzotter). „Huhn" und „Kaninchen" als Wild sind schief:
  das Kaninchen war um 700 nördlich der Alpen nicht heimisch **[Wissen]** — Hase und Rebhuhn
  wären die Lesart.
- **Orte:** Kloster, Steinkirche, Römerruine, Meierhof, Mühle, Furt.
- **Gefahr:** keine eigene. Hier erholt man sich von den anderen.
- **Was man trägt und tut:** was man hat. Lumpen, dann Wolle und Leder.

#### Brandland — `burnt_forest`

- **Stimmung:** Man hat hier Feuer gelegt — gegen die Seuche, heißt es. Es hat nicht geholfen,
  und es ist nicht ausgegangen. Der Boden schwelt, die Pfosten der Langhäuser stehen schwarz.
- **Wetter:** warm, 24–29 °C; im Sturm treibt Glut.
- **Pflanzen:** verkohlte Kiefern, tote Sträucher, Pilze auf der Asche; Gluthaufen.
- **Tiere und Gegner:** Eber, Schlange, nachts Geier und ein kleiner Hundeartiger (Vanillas
  Kojote — der Fuchs oder der Goldschakal wäre die Lesart). Die Seuchentoten hier sind
  **Verbrannte** (`zombieBurnt`) — die einzige Vanilla-Gestalt, die ohne Umdeutung ins Setting
  passt.
- **Orte:** abgebrannte Höfe und Langhäuser, Meilerplätze, ein Thingplatz, Brandgräber.
- **Gefahr statt „Rauch":** **Schwelrauch** — Vanillas „Rauch" ist schon richtig.
- **Was man trägt und tut:** ein nasses Tuch vor dem Mund; Holzkohle liegt hier im Boden.

#### Sandheide — `desert`

- **Stimmung:** offenes Land, in dem man weit sieht und weit gesehen wird. Wälle aus Holz und
  Erde, deren Tore offen stehen. Der Wind trägt den Sand über die Äcker, die niemand mehr hält.
- **Wetter:** heiß und trocken. **Vanillas 35–41 °C sind für Mitteleuropa nicht erzählbar**;
  solange D34 („Wetter wie Vanilla") gilt, bleibt nur „ein Sommer, der nicht endet". Die Zahl
  zu senken ist XML, aber eine Abweichung von D34 und Balancing.
- **Pflanzen:** heute Kakteen, Yucca, Aloe — der härteste Bruch des Bewuchses. Zielbild: Kiefer,
  Wacholder, Ginster, Heidekraut, Sandgras. Vanilla hat Wacholder, Sträucher und Treibholz als
  Blöcke; der Tausch ist XML und gehört zu F-07. Für die Aloe gäbe es eine heimische Lesart:
  die **Hauswurz**, ein Dickblattgewächs und altes Brandmittel **[Wissen; Vorschlag]**.
- **Tiere und Gegner:** Schlange, Geier, nachts Wolf und Eber. Kojote und Berglöwe sind
  Amerikaner — Fuchs und Luchs wären die Lesart.
- **Orte:** Burgwall mit Vorburg, Grubenhäuser, ein hölzerner Kultplatz, Flussübergang,
  Bienenbäume (Waldbienenzucht ist für den slawischen Raum belegt **[Wissen]**).
- **Gefahr statt „Wehender Sand":** **Flugsand** — auch hier ist Vanillas Name brauchbar.
- **Was man trägt und tut:** ein Schleiertuch vor Mund und Augen; viel Wasser; Leinen statt Wolle.

#### Winterhöhen — `snow`

- **Stimmung:** das Hochland, auf dem der Schnee liegen geblieben ist. Die Leute hier sagen,
  es sei der dritte Winter ohne Sommer. Hallen mit eingeschneiten Dächern, Rauch aus keiner.
- **Wetter:** um 0 °C, fast jeder zweite Tag Schnee, im Sturm −10 °C.
- **Pflanzen:** Winterkiefern, kahle Büsche; Beeren unter dem Schnee. Vanillas „Blaubeere"
  heißt im deutschen Vanilla-Text schon Heidelbeere; die europäische Heidelbeere ist heimisch
  **[Wissen]**. Die Denylist sperrt sie als amerikanisch (Zeile 319) — das träfe die
  Kulturheidelbeere, nicht diese.
- **Tiere und Gegner:** Bär, Wolf, Hirsch; der Berglöwe als Luchs. `animalDireWolf` ist ein
  ausgestorbener Amerikaner — im Setting der **große Wolf**, vor dem die Geschichten warnen.
  Unter den Seuchentoten der Holzfäller (`zombieLumberjack`), der passt.
- **Orte:** Halle eines Herrn, Bootshaus an einem zugefrorenen See, Grabhügel, Steinsetzung,
  Eisenhütte am Hang.
- **Gefahr statt „Eisige Luft":** **Eisige Luft** — bleibt.
- **Was man trägt und tut:** Pelz vor Mund und Hals; die Wärmeschicht aus
  [ruestung.md](ruestung.md) §2.5; Feuerstelle unter Dach (die Aura der Feuerstelle gibt es schon).

#### Moorland — `wasteland`

- **Stimmung:** Hierhin hat man die Toten gebracht, als es zu viele wurden. Bohlenwege, die im
  Wasser enden. Lichter über dem Moor, denen man nicht folgt. Was im Torf liegt, verwest nicht.
- **Wetter:** unstet — an einem Tag kalt (2–7 °C), am nächsten drückend; Nebel (D72).
- **Pflanzen:** tote Bäume, fahles Gras, Pilze. Zielbild: Birke, Erle, Wollgras, Torfmoos, Schilf.
- **Tiere und Gegner:** der große Wolf, Schlange, Geier; tote Hunde und ein toter Bär
  (`animalZombieDog`, `animalZombieBear`) — die tragen. Unter den Seuchentoten stehen heute ein
  Polizist und ein Mann im Schutzanzug (`zombieFatCop`, `zombieMaleHazmat`) — der härteste Bruch
  der Gegner, Sache von F-06. Die „Radiated"-Fassungen sind laut GDD 2.3 die **Moorleichen**.
- **Orte:** Pestgruben, Bohlenweg, Opferplatz mit Pfählen, Inselhaus im See, ein alter Stein
  mit Kerben, Torfstich, Raseneisenerz im Sumpf.
- **Heute im Bild** **[gemessen]**: Autowracks, Fässer, Radkappenminen, Schrott und Betonsteine
  in der Dekoration (§1.8). Solange die stehen, ist das Moor ein Schrottplatz.
- **Gefahr statt „Radioaktive Strahlung":** **Moordunst.** Dass schlechte Luft aus Sumpf und
  Fäulnis krank macht, ist die Krankheitslehre der Antike und des ganzen Mittelalters
  **[Wissen]** — es ist das, was ein Mensch um 700 über ein Moor *glaubt*, und sagt nichts über
  die Ursache der Seuche. Der Geigerzähler-Ton (`buff_geiger_counter`) muss weg oder ersetzt werden.
- **Was man trägt und tut:** ein Bündel bitterer Kräuter vor der Nase; nicht bleiben.
  **Keine Schnabelmaske** — die ist 17. Jahrhundert.

---

## 3. Was jedes Biom verlangt

### 3.1 Technik und Erzählung nebeneinander

| Vanilla verlangt technisch | Platz | Im Setting **[Vorschlag]** | Phase |
|---|---|---|---|
| Unterkleidung `clothing*` gegen Hitze, Kälte, Sturmstufe 1 | vier eigene | Hemd, Unterhaube, Fußlappen — [ruestung.md](ruestung.md) §2.5 | Namen: 1 |
| Futter `modArmorInsulatedLinerT1–3` gegen Hitze und Kälte | Aufsatz | Werg-, Woll-, Pelzfutter — [ruestung.md](ruestung.md) §4.2 | Namen: 1 |
| Getränk je Biom gegen die Frist und Sturmstufe 2 | Verbrauch | vier Sude (§3.3) | mit Weg B |
| Biom-Stück `biomeWeatherItem1–4` gegen die Biom-Gefahr | `BiomeBadge` | vier Schutzstücke (§3.2) | mit Weg B |
| Dach über dem Kopf | — | Dach, Feuerstelle | da |
| — | — | Amulette und Segen gegen dieselben Gefahren (F-15) | **erst Phase 2** |

### 3.2 Die vier Schutzstücke — `biomeWeatherItem1–4` **[Vorschlag]**

Weltlich, klein, vor Mund und Nase getragen — das erklärt, warum sie einen eigenen Platz haben
und die Rüstung nicht berühren. Der Schlusssatz jeder Beschreibung ist Vanillas eigene
Einschränkung.

| Nr. | Deutsch | Englisch | Beschreibung DE | Beschreibung EN |
|---|---|---|---|---|
| 1 | Rauchtuch | Smoke Cloth | „Ein dichtes Tuch, nass vor Mund und Nase gebunden. Der Schwelrauch kommt nicht mehr durch.\n\nSchützt nicht vor Hitze, Kälte oder Sturm." | "A close-woven cloth, tied wet over mouth and nose. The smoulder smoke no longer gets through.\n\nNo protection against heat, cold or storm." |
| 2 | Sandschleier | Sand Veil | „Dünnes Leinen vor Mund und Augen. Man sieht hindurch, der Sand bleibt draußen.\n\nSchützt nicht vor Hitze, Kälte oder Sturm." | "Thin linen over mouth and eyes. One sees through it; the sand stays out.\n\nNo protection against heat, cold or storm." |
| 3 | Pelzkragen | Fur Collar | „Ein Kragen aus Pelz, das Haar nach innen, bis über die Nase gezogen. Der Atem wird warm, bevor er die Brust erreicht.\n\nSchützt nicht vor Hitze, Kälte oder Sturm." | "A collar of fur, hair inward, drawn up over the nose. The breath is warm before it reaches the chest.\n\nNo protection against heat, cold or storm." |
| 4 | Riechbündel | Herb Bundle | „Raute, Wermut und Wacholder, in Leinen gebunden und vor der Nase getragen. Die Alten sagen, der Dunst aus dem Moor gehe an Bitterem nicht vorbei.\n\nSchützt nicht vor Hitze, Kälte oder Sturm." | "Rue, wormwood and juniper, bound in linen and worn before the nose. The old ones say the reek of the mire will not pass anything bitter.\n\nNo protection against heat, cold or storm." |

**Offen:** (a) Ob das höhere Stück die Gefahr der niedrigeren Biome mit aufhebt, ist nicht
gemessen; es ersetzt das niedrigere im Platz. Hebt es alle auf, muss die Reihe als *ein* Stück
erzählt werden, das wächst (Tuch → Tuch mit Schleier → mit Pelz → mit Kräutern), nicht als vier.
(b) Dass „Pelzkragen" gegen die Biom-Gefahr hilft, aber laut Text nicht gegen Kälte, ist
Vanillas Mechanik und klingt schief; der Text nennt deshalb den Atem, nicht die Wärme.
(c) Zutaten: Kit, Kunststoff und Linse brauchen Ersatz — das ist Balancing, hier nicht gesetzt.
(d) Symbole: vier neue (Vanillas zeigen vermutlich Masken und Brillen — nicht gesehen).

### 3.3 Die vier Sude — `food*Smoothie` **[Vorschlag]**

| Biom | Deutsch | Englisch | Vorbild **[Wissen]** | Was an Vanilla stört |
|---|---|---|---|---|
| Brandland | Hustensud | Cough Brew | Sude gegen Husten sind Hausmittel jeder Zeit; Huflattich trägt den Husten im lateinischen Namen | **Spritze** als Modell und Ton. Zutaten (Holzkohle, Nesselfaser, Pilze, abgekochtes Wasser) sind bei uns schon alle frei |
| Sandheide | Honigwasser | Honey Water | Honig in Wasser gegen die raue Kehle, seit der Antike | Zutat Ölschiefer gesperrt; `foodHoney` gibt es und ist frei |
| Winterhöhen | Biersuppe | Ale Broth | heißes Bier mit Brühe; als Gericht erst später schriftlich, für 700 plausibel | Zutaten Blaubeere und Dosen-Chili gesperrt; Fleisch und Bier frei. Modell ist ein Topf — passt |
| Moorland | Wermutsud | Wormwood Brew | Wermut (ahd. *wermuota*) als Bitterkraut gegen „schlechte Luft" und Würmer; steht in den Kräuterlisten des 9. Jh. | **Spritze**; alle vier Zutaten gesperrt, das Rezept ist ganz neu zu setzen |

**Texte:**

- Hustensud — „Ein dunkler Sud, durch Nesseltuch geseiht. Er löst, was der Rauch in der Brust
  festgesetzt hat.\n\nIm Brandland hältst du es länger unter freiem Himmel aus." / "A dark brew,
  strained through nettle cloth. It loosens what the smoke has lodged in the chest.\n\nIn the
  burnt woods you can stay longer under the open sky."
- Honigwasser — „Honig in abgekochtem Wasser. Es spült den Sand aus der Kehle und hält sie
  feucht.\n\nAuf der Heide hältst du es länger unter freiem Himmel aus." / "Honey in boiled
  water. It rinses the sand from the throat and keeps it moist.\n\nOn the heath you can stay
  longer under the open sky."
- Biersuppe — „Bier, heiß gemacht, mit Fleisch darin. Wer das im Leib hat, den findet die Kälte
  später.\n\nAuf den Höhen hältst du es länger unter freiem Himmel aus." / "Ale made hot, with
  meat in it. Whoever has this inside him, the cold finds later.\n\nOn the heights you can stay
  longer under the open sky."
- Wermutsud — „Bitter, dass es die Zunge zusammenzieht. Man sagt, was so schmeckt, halte den
  Dunst aus der Brust.\n\nIm Moor hältst du es länger unter freiem Himmel aus." / "Bitter enough
  to draw the tongue together. They say that what tastes like this keeps the reek out of the
  chest.\n\nIn the mire you can stay longer under the open sky."

**Offen:** Der Name darf nichts versprechen, was nicht in den Topf kommt — „Wermutsud" braucht
eine Zutat Wermut, die es nicht gibt. Zutaten und Mengen sind Balancing. Ob der Trinkton eines
Glases an die Stelle des Spritzentons gesetzt werden kann, ist reines XML (`Sound_start`), aber
ungeprüft. „Theriak" ist bewusst nicht vergeben — das gehört F-11.

### 3.4 Texte zur Biom-Gefahr **[Vorschlag]**

Grundsatz des kleinsten Eingriffs: **Was an Vanilla nicht modern ist, bleibt.** Schlüssel je
Biom: `buff<Biom>01Name/Desc/ToolTip`, `…02…`, `…Over…`, `…Recover…`.

| Schlüssel | Vanilla DE / EN | Vorschlag DE / EN |
|---|---|---|
| `buffBurnt01Name` | Rauch / Smoke | **bleibt** (oder: Schwelrauch / Smoulder Smoke) |
| `buffDesert01Name` | Wehender Sand / Blowing Sands | **bleibt** (oder: Flugsand / Blown Sand) |
| `buffSnow01Name` | Eisige Luft / Freezing Air | **bleibt** |
| `buffWasteland01Name` | Radioaktive Strahlung / Blowing Fallout | **Moordunst / Mire Reek** |
| `buff<Biom>02Name` | Erstickend, Ersticken / Suffocating | **bleibt**; Vanilla schreibt es deutsch uneinheitlich — einheitlich „Atemnot / Short of Breath" wäre sauberer |
| `buff<Biom>OverName` | Hustenstiller / Cough Suppressant | **Freie Brust / Clear Chest** |
| `buff<Biom>RecoverName` | Frische Luft / Fresh Air | **bleibt** |

Neu zu schreiben sind die Beschreibungen, die Getränk und „Überlebensausrüstung" nennen:

| Schlüssel | Deutsch | Englisch |
|---|---|---|
| `buffBurnt01Desc` | „Der Boden schwelt noch, und der Rauch steht zwischen den Stämmen.\n\nEin Schluck [DECEA3]Hustensud[-], ein Dach über dem Kopf oder ein Rauchtuch vor dem Mund lassen dich länger aushalten." | "The ground still smoulders, and the smoke stands between the trunks.\n\nA draught of [DECEA3]Cough Brew[-], a roof overhead or a smoke cloth over the mouth will let you last longer." |
| `buffBurnt01ToolTip` | „Der Rauch beißt in der Brust." | "The smoke bites in the chest." |
| `buffDesert01Desc` | „Der Wind treibt den Sand in Augen, Mund und Brust.\n\nEin Schluck [DECEA3]Honigwasser[-], ein Dach über dem Kopf oder ein Sandschleier lassen dich länger aushalten." | "The wind drives the sand into eyes, mouth and chest.\n\nA draught of [DECEA3]Honey Water[-], a roof overhead or a sand veil will let you last longer." |
| `buffDesert01ToolTip` | „Sand und Staub füllen dir die Brust." | "Sand and dust fill your chest." |
| `buffSnow01Desc` | „Die Luft ist so kalt, dass jeder Atemzug schneidet.\n\nEine Schale [DECEA3]Biersuppe[-], ein Dach über dem Kopf oder ein Pelzkragen lassen dich länger aushalten." | "The air is so cold that every breath cuts.\n\nA bowl of [DECEA3]Ale Broth[-], a roof overhead or a fur collar will let you last longer." |
| `buffSnow01ToolTip` | „Die Kälte schneidet in der Brust." | "The cold cuts in the chest." |
| `buffWasteland01Desc` | „Über dem Moor steht ein Dunst, der nach Fäulnis riecht und schwer in der Brust liegt.\n\nEin Schluck [DECEA3]Wermutsud[-], ein Dach über dem Kopf oder ein Riechbündel lassen dich länger aushalten." | "A reek stands over the mire that smells of rot and lies heavy in the chest.\n\nA draught of [DECEA3]Wormwood Brew[-], a roof overhead or a herb bundle will let you last longer." |
| `buffWasteland01ToolTip` | „Der Dunst liegt dir schwer in der Brust." | "The reek lies heavy in your chest." |
| `buff<Biom>02Desc` | „Du bekommst keine Luft mehr.\n\nGeh unter ein Dach — jetzt." | "You cannot get your breath.\n\nGet under a roof — now." |
| `buffBurntOverDesc` | „Der Sud hat den Husten gelöst. Im Brandland hältst du länger aus und läufst leichter." | "The brew has loosened the cough. In the burnt woods you last longer and run more easily." |
| `buffDesertOverDesc` | „Die Kehle ist feucht. Auf der Heide hältst du länger aus und läufst leichter." | "The throat is moist. On the heath you last longer and run more easily." |
| `buffSnowOverDesc` | „Die Wärme sitzt im Leib. Auf den Höhen hältst du länger aus und läufst leichter." | "The warmth sits in the body. On the heights you last longer and run more easily." |
| `buffWastelandOverDesc` | „Der Mund ist bitter, die Brust ist frei. Im Moor hältst du länger aus und läufst leichter." | "The mouth is bitter, the chest is clear. In the mire you last longer and run more easily." |

**Gilt nur mit Weg B.** Mit Weg A (abschalten) erscheint keine dieser Zeilen.

### 3.5 Texte zu den Stürmen **[Vorschlag]** — gilt in jedem Fall

Stürme laufen unabhängig vom Biom-Fortschritt (§1.5). **Diese Zeilen stehen also heute schon im
Spiel**, und fünf davon sind modern.

| Schlüssel | Vanilla DE / EN | Vorschlag DE / EN |
|---|---|---|
| `buffBurnt_StormName`, `buffDesert_StormName`, `buffSnow_StormName` | Aschesturm, Sandsturm, Schneesturm | **bleiben** |
| `buffWasteland_StormName` | Radioaktiver Sturm / Radiation Storm | **Fauler Wind / Foul Wind** |
| `…_Storm_Stage01Name`, `…Stage02Name`, `…Recover01Name` | „Aschesturm: Stadium 1" … | „…: Anfang", „…: Höhe", „…: Abklingen" / "…: Onset", "…: Height", "…: Easing" — „Stadium" ist Arztsprache der Neuzeit; nachrangig |
| `buffWasteland_StormDesc` | „Du bist in einem schweren radioaktiven Sturm!\n\nSuche Schutz!" | „Ein fauler Wind kommt über das Moor!\n\nSuche ein Dach!" / "A foul wind is coming over the mire!\n\nFind a roof!" |
| `buffWasteland_Storm_Stage01Desc` | „Radioaktive Strahlung hat deine maximale Gesundheit und Ausdauer um 50 % verringert. …" | „Der faule Wind nimmt dir Kraft: Leben und Ausdauer reichen um 50 weniger weit.\nRüstung und Werkzeug nutzen sich um 300 % schneller ab.\nSuche ein Dach, um dich zu erholen." / "The foul wind takes your strength: health and stamina reach 50 less far.\nArmour and tools wear 300% faster.\nFind a roof to recover." |
| `buffWasteland_Storm_Stage02Desc` | „Du bist verstrahlt und du verlierst 4 Gesundheit pro Sekunde. … Fallout Flush …" | „Der Wind sitzt dir in der Brust: du verlierst 4 Leben je Sekunde.\nSuche ein Dach, um dich zu erholen." / "The wind sits in your chest: you lose 4 health each second.\nFind a roof to recover." |
| `buffWasteland_Storm_Recover01Desc` | „Du erholst dich vom radioaktiven Sturm." | „Du erholst dich vom faulen Wind." / "You are recovering from the foul wind." |
| `buffBurnt_Storm_Stage02Desc`, `buffDesert_…`, `buffSnow_…` | „… Verringere mit einem Anthrakoseserum / Sonnenstich-Tonikum / Feuereintopf den Schaden um 50 %. …" | **der mittlere Satz entfällt** (Weg A) oder nennt den Sud (Weg B): „Ein Hustensud halbiert den Schaden." / "A Cough Brew halves the harm." |

„Fauler Wind" und nicht „Seuchenwind": kein Text benennt die Ursache der Seuche (Glossar-Regel 5).
Vanillas deutscher Text zu `buffWasteland_Storm_Stage01Desc` sagt „um 50 %", der englische „by
50" — der Buff setzt 50 Punkte (§1.5); der Vorschlag folgt dem Englischen.

### 3.6 Texte zu den Biom-Reihen **[Vorschlag]** — gilt nur mit Weg B

Schlüssel: `challenge<Biom>{Shelter, HarvestCrop, CraftReducer, UseReducer, KillZombie,
HarvestOre, GatherGear}`, dazu `…Short` und `…Desc`. Vanillas Zeilen nennen in jeder Reihe
„Zombies" und „Biom" — beides Muster, die unser Glossar in eigenen Zeilen verbietet.

**Titel aller 28 Aufgaben.** Kursiv: braucht ein neues Ziel in `challenges.xml`; die Kennung in
Klammern ist ein gemessen vorhandener, nicht gesperrter Kandidat, keine Setzung.

| Nr. | Brandland | Sandheide | Winterhöhen | Moorland |
|---|---|---|---|---|
| 1 | Ein Dach finden / Find a Roof | Ein Dach finden / Find a Roof | Ein Dach finden / Find a Roof | Ein Dach finden / Find a Roof |
| 2 | Pilze sammeln / Gather Mushrooms | Hauswurz schneiden / Cut Houseleek | *Heidelbeeren pflücken / Pick Bilberries* (Freigabe von `foodCropBlueberries`) | *Pilze im Moor sammeln / Gather Mire Mushrooms* (`foodCropMushrooms`, oder `…Radiated` umgedeutet) |
| 3 | Hustensud ansetzen / Brew a Cough Brew | Honigwasser ansetzen / Mix Honey Water | Biersuppe kochen / Cook Ale Broth | Wermutsud ansetzen / Brew a Wormwood Brew |
| 4 | Hustensud trinken / Drink a Cough Brew | Honigwasser trinken / Drink Honey Water | Biersuppe essen / Eat Ale Broth | Wermutsud trinken / Drink a Wormwood Brew |
| 5 | Die Verbrannten erschlagen / Slay the Burnt | Die Toten der Heide erschlagen / Slay the Dead of the Heath | Die Toten der Höhen erschlagen / Slay the Dead of the Heights | Die Toten im Moor erschlagen / Slay the Dead of the Mire |
| 6 | *Holzkohle aus der Asche brechen / Dig Charcoal from the Ash* (`resourceCoal`; Kohleerz liegt im Biom) | *Raseneisenerz brechen / Dig Bog Iron Ore* (`resourceScrapIron`; Eisenerz liegt im Biom) | Holzkohle brechen / Dig Charcoal | Blei brechen / Dig Lead |
| 7 | Zeug für das Rauchtuch / Makings of the Smoke Cloth | Zeug für den Sandschleier / Makings of the Sand Veil | Zeug für den Pelzkragen / Makings of the Fur Collar | Zeug für das Riechbündel / Makings of the Herb Bundle |

**Rahmenzeilen:**

| Schlüssel | Deutsch | Englisch |
|---|---|---|
| Gruppentitel (Vanilla „Überleben im Verbrannten Wald") | Durch das Brandland · Über die Sandheide · Auf die Winterhöhen · Ins Moorland | Through the Burnt Lands · Across the Sand Heath · Up the Winter Fells · Into the Mirelands |
| `challengeObjectiveBurnt` (und drei weitere) | „Lerne das Brandland kennen und verdiene dir das Rauchtuch." | "Learn the Burnt Lands and earn the Smoke Cloth." |
| `challengeBiomeRewardTooltip` | „[00FF00]Du weißt jetzt, wie man sich hier schützt.[-]" | "[00FF00]You now know how to guard yourself here.[-]" |

**Die Brandland-Reihe ausgeschrieben, als Muster:**

| Schlüssel | Deutsch | Englisch |
|---|---|---|
| `challengeBurntShelterShort` | „Finde oder baue im Brandland ein Dach." | "Find or build a roof in the Burnt Lands." |
| `challengeBurntShelterDesc` | „Suche ein Haus, das noch ein Dach hat, oder baue eines. Löcher, offene Türen und Fenster lassen den Rauch herein.\n\nUnter einem Dach erholst du dich vom Schwelrauch, und nur dort überstehst du einen Sturm." | "Find a house that still has a roof, or build one. Holes, open doors and windows let the smoke in.\n\nUnder a roof you recover from the smoulder smoke, and only there will you outlast a storm." |
| `challengeBurntHarvestCropShort` | „Sammle Pilze." | "Gather mushrooms." |
| `challengeBurntHarvestCropDesc` | „Wo es gebrannt hat, wächst zuerst der Pilz. Auf der Asche zwischen den Stämmen stehen sie dicht.\n\nSammle [DECEA3]Pilze[-] im [DECEA3]Brandland[-]." | "Where it has burnt, the mushroom grows first. On the ash between the trunks they stand thick.\n\nGather [DECEA3]mushrooms[-] in the [DECEA3]Burnt Lands[-]." |
| `challengeBurntCraftReducerShort` | „Setze einen Hustensud an." | "Brew a Cough Brew." |
| `challengeBurntCraftReducerDesc` | „Ein [DECEA3]Hustensud[-] löst den Rauch aus der Brust und lässt dich im [DECEA3]Brandland[-] länger aushalten.\n\nSetze einen [DECEA3]Hustensud[-] an." | "A [DECEA3]Cough Brew[-] loosens the smoke from the chest and lets you last longer in the [DECEA3]Burnt Lands[-].\n\nBrew a [DECEA3]Cough Brew[-]." |
| `challengeBurntUseReducerShort` | „Trink einen Hustensud." | "Drink a Cough Brew." |
| `challengeBurntUseReducerDesc` | „Trink den [DECEA3]Hustensud[-], bevor der Rauch dich einholt, nicht danach.\n\nTrink einen [DECEA3]Hustensud[-]." | "Drink the [DECEA3]Cough Brew[-] before the smoke catches up with you, not after.\n\nDrink a [DECEA3]Cough Brew[-]." |
| `challengeBurntKillZombieShort` | „Erschlage Seuchentote im Brandland." | "Slay the plague-dead in the Burnt Lands." |
| `challengeBurntKillZombieDesc` | „Sie sind im Feuer nicht liegen geblieben. Schwarz und rissig gehen sie zwischen den Pfosten ihrer Höfe um.\n\nErschlage [DECEA3]Verbrannte[-] und andere Seuchentote im [DECEA3]Brandland[-]." | "They did not stay down in the fire. Black and cracked, they walk between the posts of their farmsteads.\n\nSlay the [DECEA3]Burnt[-] and others of the plague-dead in the [DECEA3]Burnt Lands[-]." |
| `challengeBurntHarvestOreShort` | „Brich Holzkohle aus der Asche." | "Dig charcoal from the ash." |
| `challengeBurntHarvestOreDesc` | „Was hier gebrannt hat, liegt als [DECEA3]Holzkohle[-] im Boden — mehr, als ein Meiler in einem Jahr gibt.\n\nBrich [DECEA3]Holzkohle[-] im [DECEA3]Brandland[-]." | "What burnt here lies in the ground as [DECEA3]charcoal[-] — more than a kiln yields in a year.\n\nDig [DECEA3]charcoal[-] in the [DECEA3]Burnt Lands[-]." |
| `challengeBurntGatherGearShort` | „Sammle, was ein Rauchtuch braucht." | "Gather what a Smoke Cloth needs." |
| `challengeBurntGatherGearDesc` | „Ein [DECEA3]Rauchtuch[-] braucht dichtes Tuch und einen Riemen, der es hält.\nSammle das Zeug dafür und geh den ganzen Weg durch das Brandland, dann weißt du, wie man es bindet." | "A [DECEA3]Smoke Cloth[-] needs close-woven cloth and a strap to hold it.\nGather the makings and go the whole way through the Burnt Lands; then you will know how to tie it." |

**Nicht geschrieben** sind die je 14 Kurz- und Langtexte der drei anderen Reihen (42 Zeilen je
Sprache). Sie hängen an Entscheidungen aus §5 (Namen der Biome, Ersatzziele) und folgen dem
Muster oben. Das ist eine offene Lücke dieses Dokuments, kein Versehen.

### 3.7 Volksmagie — nur Notiz für Phase 2

Jede der vier Gefahren hat ein naheliegendes Gegenstück in F-15: Segen gegen den Rauch,
Amulett gegen den bösen Wind, Bernstein gegen die Kälte, Rautenkranz gegen den Moordunst. Ob
das magische Mittel das weltliche ersetzt, ergänzt oder nur anders erzählt, entscheidet F-15.
**Hier wird nichts davon geplant** (D50).

---

## 4. Phasen

| Phase | Was | Art |
|---|---|---|
| **1** (jetzt) | **Entscheidung über Weg A, B oder C** (§1.10) — das Einzige, das nicht warten kann | Entscheidung, danach höchstens eine Einstellung oder wenige XML-Zeilen |
| 1 | Sturmtexte des Ödlands („Radioaktiver Sturm", „verstrahlt", „Fallout Flush") und der Verweis auf die Getränke in drei weiteren Sturmtexten (§3.5) | Sprachzeilen |
| 1 | Namen der Unterkleidung und der Futter ([ruestung.md](ruestung.md)) | Sprachzeilen |
| 1 | Berichtigung der Angabe „kein Name" (§1.11) | Dokument und Kommentar |
| 1, **nur falls gewollt** | Anzeigenamen der fünf Biome (§2.2) — reine Sprachzeilen, aber F-07 ist Phase 2; ohne Umbenennung stört von Vanillas Namen nur „Wüste" | Sprachzeilen, Entscheidung |
| **2** (F-07, F-06, F-16) | Weg B ganz: Sude, Schutzstücke, Reihen, Gefahr-Texte (§3.2–3.6) | XML und Sprache |
| 2 | Bewuchs tauschen: Kakteen, Yucca, Azalee; Autos, Fässer, Minen, Schrott aus der Dekoration | XML (`biomes.xml`) |
| 2 | Ton des Geigerzählers, Modell und Ton der Spritze | XML, ggf. Asset |
| 2 | Gegner und Tiere je Biom umdeuten (Polizist, Schutzanzug, Kojote, Berglöwe) | F-06 |
| 2 | Symbole: 4 Schutzstücke, 4 Sude | F-16 |
| 2 | Temperatur der Sandheide, falls D34 fällt | Balancing |
| 2 | Volksmagie gegen die Gefahren (§3.7) | F-15 |
| **3–4** | Eigene Karte mit Küste und Westrand; das nordische und das keltische Gesicht bekommen ihr Land | GDD-Fahrplan (F-07 nennt Phase 3, die GDD-Tabelle Phase 4 — der Widerspruch steht dort, nicht hier) |

---

## 5. Entscheidungen für den Nutzer

| Nr. | Frage | Vorschlag | Marke |
|---|---|---|---|
| 1 | **Biom-Gefahr in Phase 1: abschalten (A), umdeuten (B) oder lassen (C)?** | **A.** Vorher messen, welche Voreinstellung `BiomeProgression` hat, dann den kleinsten Weg wählen. | **[zu prüfen]** |
| 2 | Wird **Weg B** als Folgearbeit des Purge vorgezogen oder bleibt er bei F-07 (Phase 2)? | Bleibt bei F-07. | **[zu prüfen]** |
| 3 | **Zuordnung der Biome** abweichend von D43 (§2.2): Sandheide statt Küste auf `desert`, Winterhöhen statt Heide auf `snow`, Brandland als zweites statt gefährlichstes Biom | Übernehmen, als neue D-Zeile; D43 durchstreichen. | **[zu prüfen]** |
| 4 | **Welcher Kulturkreis wohin** — slawisch auf den Sand, nordisch auf die Höhen, germanisch ins Brandland; oder die Variante aus §2.2 | Wie §2.2. | **[zu prüfen]** |
| 5 | **Moorland ohne lebenden Kulturkreis**, keltische Spuren nur als Altes | Ja; das keltische Gesicht kommt mit der eigenen Karte. | **[zu prüfen]** |
| 6 | **Namen der Biome** Deutsch und Englisch (Klosterland / Cloister Lands, Brandland / Burnt Lands, Sandheide / Sand Heath, Winterhöhen / Winter Fells, Moorland / Mirelands) | Deutsch wie genannt; Englisch offen. | **[zu prüfen]** |
| 7 | **Anzeigenamen der Biome schon in Phase 1?** | Nein — mit F-07. Nur „Wüste" stört bis dahin. | **[zu prüfen]** |
| 8 | **Die Gefahr des Moors heißt „Moordunst"**, der Sturm „Fauler Wind" — nicht „Seuchenwind" | Ja; hält Glossar-Regel 5. | **[zu prüfen]** |
| 9 | **Sturmtexte jetzt ändern** (§3.5), unabhängig von Nr. 1 | Ja — sie stehen heute im Spiel. | **[zu prüfen]** |
| 10 | **Namen der vier Schutzstücke und der vier Sude** (§3.2, §3.3) | Wie genannt; „Wermutsud" nur, wenn es Wermut als Zutat gibt. | **[zu prüfen]** |
| 11 | **Heidelbeere freigeben** (Denylist 319 sperrt sie als amerikanisch; die europäische ist heimisch) | Ja, als „Heidelbeere / Bilberry". Ändert die Denylist — Sache des Nutzers. | **[zu prüfen]** |
| 12 | **Aloe als Hauswurz** lesen | Ja, als Name; erst mit F-07. | **[zu prüfen]** |
| 13 | **D34 („Wetter wie Vanilla") für die Sandheide lockern** — 35–41 °C | Erst mit F-07 entscheiden; bis dahin stehen lassen. | **[zu prüfen]** |
| 14 | **Die Angabe „kein Name"** in Balancing 0003 und im Rezept-Kommentar berichtigen; Denylist-Kommentar Zeile 463 | Berichtigen. | **[zu prüfen]** |
| 15 | **Wärme nur aus Beute** — reicht das für Winterhöhen und Sandheide, solange `TemperatureSurvival` an ist? | Erst im Spiel ansehen (gebündelt mit Nr. 1, wenige Minuten je Biom). | **[zu prüfen]** |

---

## 6. Was nicht gemessen ist

- **Nichts hiervon ist im Spiel gesehen.** Zähler, Texte, Schaden, Partikel, Töne: gelesen.
- Länge des Takts der Gefahr-Buffs; Bedeutung von `link_challenges`; Voreinstellung von
  `BiomeProgression` außerhalb der Voreinstellung „Adventurer"; ob `sandbox_override` auf „an"
  oder „aus" sperrt; ob beide Tötungsziele einer Aufgabe verlangt sind.
- Ob das höhere Biom-Stück die niedrigeren Gefahren mit aufhebt.
- Wie viel Temperatur-Widerstand eine Kälte- oder Hitzestufe aufhebt.
- Ob ein anderes Modlet die Blöcke der modernen Biom-Dekoration ersetzt.
- Aussehen der Symbole von Getränken und Biom-Stücken.
- **Historisch aus dem Gedächtnis:** Crannogs und Bohlenwege um 700, slawische Burgwälle und
  Waldbienenzucht, Wermut in den Kräuterlisten des 9. Jh., die Lehre von der schlechten Luft,
  das Kaninchen nördlich der Alpen, die Hauswurz als Brandmittel. Die Richtung stimmt; vor einer
  Veröffentlichung nachschlagen. **Biersuppe** und **Honigwasser** als Mittel gegen Kälte und
  Staub sind plausible Setzungen, keine Belege.
