# Glossar — die verbindliche Begriffsquelle

Angelegt am 20. November 2026 mit WP8.5 (F-12, D75). Hier steht, **wie ein Ding im Spiel
heißt** — auf Deutsch und auf Englisch (D7). Wer einen Text schreibt, schlägt hier nach und
erfindet nichts daneben.

Das Glossar wird **geprüft**, nicht nur gelesen: `tools/check/glossar-pruefen.ps1` liest
genau diese Datei und vergleicht sie mit `mod/700_90_Sprache/Config/Localization.csv`. Es
läuft in `check-all.ps1` mit.

## 1. Regeln

1. **Erst das Glossar, dann der Text.** Ein Name ändert sich hier zuerst. Stimmt eine Zeile
   der Sprachdatei nicht mit ihrer Glossarzeile überein, ist die Prüfung rot.
2. **Die Kennung bleibt, der Name wechselt** (Umdeutung statt Ersatz). `resourceScrapIron`
   heißt im XML weiter so; der Spieler liest „Raseneisenerz".
3. **Deutsch und Englisch sind Pflicht** (D7), elf weitere Sprachspalten bleiben leer.
4. **Ein neuer Weltbegriff ist eine Entscheidung des Nutzers.** Was unter „Welt" steht,
   kommt aus dem GDD oder aus einer D-Zeile. Fehlt ein englischer Begriff, steht dort
   *offen* — dann wird gefragt, nicht geraten.
5. **Die Ursache der Seuche bleibt offen** (GDD 2.1). Kein Text nennt sie als Tatsache;
   Figuren dürfen etwas glauben.
6. **Namen von Orten und Menschen** folgen D1: erfunden, im Lautbild frühmittelalterlich
   (Orte auf -heim, -feld, -wik, -grad, -dun, -ing), keine realen Orte oder Herrscher.
   Angewandt wird das in WP8.6.

### So liest die Prüfung diese Datei

**Jede Tabelle dieser Datei hat eine von drei Formen**, erkannt an ihrer Kopfzeile. Eine
Tabelle mit einer anderen Kopfzeile macht die Prüfung rot („nicht prüfbar") — sonst würde
ein Tippfehler in der Kopfzeile eine ganze Tabelle still abschalten. Fließtext ist frei.

- **Festbegriffe** — Kopfzeile `| Kennung | Deutsch | Englisch | Vanilla | Quelle |`.
  Steht in der ersten Spalte eine Kennung in Backticks, muss die Zeile der Sprachdatei mit
  diesem Schlüssel **genau** diesen deutschen und diesen englischen Text tragen. Steht dort
  `—`, gibt es noch keinen Schlüssel (der Begriff gilt trotzdem für jeden Fließtext).
- **Verbotene Begriffe** — Kopfzeile `| Verboten | Sprache | Stattdessen | Quelle |`.
  Die erste Spalte ist ein Muster in Backticks (regulärer Ausdruck, Groß- und
  Kleinschreibung egal). Es darf in keiner Zeile unserer Sprachdatei vorkommen — in der
  deutschen Spalte (`DE`), der englischen (`EN`) oder in beiden (`beide`). Ein Muster
  enthält kein `|`; zwei Schreibweisen sind zwei Zeilen.
- **Alleinnamen** — Kopfzeile `| Alleinname | Deutsch | Englisch | Quelle |`. Die erste
  Spalte ist ein Schlüssel in Backticks. Die Zeile der Sprachdatei mit diesem Schlüssel muss
  genau diesen deutschen und englischen Namen tragen, und **keine andere Zeile** darf einen
  der beiden Namen enthalten (§11). Gesucht wird die Zeichenfolge, ohne Wortgrenzen.
  Der Schlüssel steht in der Sprachdatei genau einmal und wird zeichengenau gesucht
  (`700_modname` ist ein anderer Schlüssel). Die Zeile `700_modName` ist in diesem
  Glossar **Pflicht**: fehlt sie, ist das Glossar nicht prüfbar.

Kennungen und Texte vergleicht die Prüfung Zeichen für Zeichen, auch bei den
Festbegriffen: andere Groß- und Kleinschreibung oder ein unsichtbares Zeichen im Namen ist
eine Abweichung.

## 2. Welt

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Seuchentote (Einzahl: der Seuchentote) | the plague-dead | Zombies | GDD 2.3; EN vom Nutzer am 2026-11-20 |
| — | Seuchennacht | Plague Night | Blood Moon, Horde Night | GDD 2.3; EN vom Nutzer am 2026-11-20 |
| — | Verderbte | *offen* | Feral | GDD 2.3, F-06 (Phase 2) |
| — | Moorleichen | *offen* | Radiated | GDD 2.3, F-06 (Phase 2) |
| — | Wanderhändler, Klostermarkt, Fürstenhof | *offen* (Klostermarkt / Cloister Market und Fürstenhof / Lord's Hall stehen seit D163 unten unter „Die fünf Posten") | Trader | GDD 2.3, F-10 (Phase 2) |
| — | das Grauen | *offen* | — | F-17 (B3, Phase 2) |
| `casinoCoin` | Silberpfennig | Silver Penny | Jeton aus Dukes Kasino / Duke's Casino Token; als Währung: Dukes | D30, WP4.2 |
| `quest_WhiteRiverCitizen` | Der Weg zum Händler | The Way to the Trader | Bürger von White River / White River Citizen | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `buffChickenFullStress_EnrageName` | Aufgescheuchte Seuchentote | Roused Plague-dead | Wütende Zombies / Enraged Zombies | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `buffChickenFullStress_ZombieHordeName` | Rotte Seuchentoter | Pack of the Plague-dead | Zombiehorde / Zombie Horde | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `buffWasteland_StormName` | Fauler Wind | Foul Wind | Radioaktiver Sturm / Radiation Storm | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Biome §3.5) |
| — | Anfang, Höhe, Abklingen (die Stufen eines Sturms, hinter seinem Namen: „Fauler Wind: Anfang“; zwölf Zeilen `buff…_Storm_…Name`) | Onset, Height, Easing | Stadium 1, Stadium 2, Erholung / Stage 1, Stage 2, Recovery | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Biome §3.5) |
| `biome_pine_forest` | Klosterland | Cloister Lands | Kiefernwald / Pine Forest | biome.md §2.2, P2-E13, D156 (Vorschlag, N-101) |
| `biome_pineforest` | Klosterland | Cloister Lands | Kiefernwald / Pine Forest | zweiter Schlüssel desselben Biomes in Vanilla; D156 |
| `biome_burnt_forest` | Brandland | Burnt Lands | Verbrannter Wald / Burnt Forest | biome.md §2.2, P2-E13, D156 (Vorschlag, N-101) |
| `biome_desert` | Sandheide | Sand Heath | Wüste / Desert | biome.md §2.2, P2-E13, D156 (Vorschlag, N-101) |
| `biome_snow` | Winterhöhen | Winter Fells | Schnee / Snow | biome.md §2.2, P2-E13, D156 (Vorschlag, N-101) |
| `biome_wasteland` | Moorland | Mirelands | Ödland / Wasteland | biome.md §2.2, P2-E13, D156 (Vorschlag, N-101) |
| `biomeWeatherItem1` | Rauchtuch | Smoke Cloth | Rauchausrüstung / Smoke Gear | biome.md §3.2, D155 (Vorschlag, N-100) |
| `biomeWeatherItem2` | Sandschleier | Sand Veil | Wüstenausrüstung / Desert Gear | biome.md §3.2, D155 (Vorschlag, N-100) |
| `biomeWeatherItem3` | Pelzkragen | Fur Collar | Schneeausrüstung / Snow Gear | biome.md §3.2, D155 (Vorschlag, N-100) |
| `biomeWeatherItem4` | Riechbündel | Herb Bundle | Strahlungsausrüstung / Radiation Gear | biome.md §3.2, D155 (Vorschlag, N-100) |
| `foodBurntSmoothie` | Hustensud | Cough Brew | Anthrakoseserum / Black Lung Serum | biome.md §3.3, D155 (Vorschlag, N-100) |
| `foodOasisSmoothie` | Honigwasser | Honey Water | Sonnenstich-Tonikum / Sunstroke Tonic | biome.md §3.3, D155 (Vorschlag, N-100) |
| `foodFrostbiteSmoothie` | Biersuppe | Ale Broth | Feuereintopf / Scorcher Stew | biome.md §3.3, D155 (Vorschlag, N-100) |
| `foodAtomicSmoothie` | Bittersud | Bitter Brew | Fallout Flush | D154 statt „Wermutsud“ (Vorschlag, N-99) |
| `foodCropBlueberries` | Heidelbeeren | Bilberries | Heidelbeeren / Blueberries | D154 (Freigabe, N-99) |
| `foodCropMushroomsRadiated` | Moorpilze | Mire Mushrooms | Verstrahlte Pilze / Radiated Mushrooms | D154 (Freigabe, N-99) |

### Wesen — Vorschlag, nicht abgenommen (N-67)

Die Namen der Seuchentoten und Tiere aus F-06 §2 bis §4 (D147), erzeugt mit
`tools/gen/wp5-wesen-namen.ps1` aus der Tabelle `tools/gen/wp5-wesen-namen.tsv`. **Jeder Name ist
ein Vorschlag aus dem Loop** — ein Name ändert sich in der Tabelle, dann hier, dann in der
Sprachdatei (Regel 1). Die Tabelle führt die Grundklassen; die Stufen entstehen aus vier Wörtern
davor, die den Platz von „Seuchentoter" einnehmen:

- `Feral` — **Verderbter / Verderbte** — Blighted
- `Radiated` — **Schwärender / Schwärende** — Festering
- `Charged` — **Glutäugiger / Glutäugige** — Ember-Eyed
- `Infernal` — **Verdammter / Verdammte** — Damned

„Verderbter Knecht", „Schwärende Magd", „Verdammte Moorleiche". Der **Nachzehrer**
(`zombieWight…`, englisch Shroud Eater) hat keine Grundklasse und steht darum nicht in der
Tabelle; ihn gibt es nur in den vier Stufen. Die Zeile „Moorleichen = Radiated" weiter oben ist
mit D100 überholt (die Moorleiche ist die Gestalt im Moor, keine Stufe) und bleibt stehen, bis der
Nutzer D100 abnimmt.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `animalBear` | Bär | Bear | Bear | F-06, D147 (Vorschlag) |
| `animalBearSmall` | Jungbär | Young Bear | Little Bear | F-06, D147 (Vorschlag) |
| `animalBeeSwarm` | Bienenschwarm | Bee Swarm | Bee Swarm | F-06, D147 (Vorschlag) |
| `animalBoar` | Wildschwein | Wild Boar | Boar | F-06, D147 (Vorschlag) |
| `animalBossGrace` | Die Alte Bache | The Old Sow | Grace | F-06, D147 (Vorschlag) |
| `animalChicken` | Huhn | Chicken | Chicken | F-06, D147 (Vorschlag) |
| `animalChickenHostile` | Tolles Huhn | Mad Hen | Murder Chicken | F-06, D147 (Vorschlag) |
| `animalCoyote` | Verwilderter Hund | Feral Dog | Coyote | F-06, D147 (Vorschlag) |
| `animalDireWolf` | Altwolf | Elder Wolf | Dire Wolf | F-06, D147 (Vorschlag) |
| `animalDoe` | Hirschkuh | Hind | Doe | F-06, D147 (Vorschlag) |
| `animalInsectSwarm` | Mückenschwarm | Midge Swarm | Insect Swarm | F-06, D147 (Vorschlag) |
| `animalMountainLion` | Luchs | Lynx | Mountain Lion | F-06, D147 (Vorschlag) |
| `animalRabbit` | Hase | Hare | Rabbit | F-06, D147 (Vorschlag) |
| `animalSnake` | Kreuzotter | Adder | Snake | F-06, D147 (Vorschlag) |
| `animalStag` | Hirsch | Stag | Stag | F-06, D147 (Vorschlag) |
| `animalWolf` | Wolf | Wolf | Wolf | F-06, D147 (Vorschlag) |
| `animalZombieBear` | Seuchenbär | Plague Bear | Zombie Bear | F-06, D147 (Vorschlag) |
| `animalZombieBoar` | Seucheneber | Plague Boar | Zombie Boar | F-06, D147 (Vorschlag) |
| `animalZombieDog` | Seuchenhund | Plague Hound | Zombie Dog | F-06, D147 (Vorschlag) |
| `animalZombieVulture` | Seuchengeier | Plague Vulture | Zombie Vulture | F-06, D147 (Vorschlag) |
| `ent700_spukhund` | Spukhund | Phantom Hound | — (eigene Klasse auf dem Modell des Seuchenhunds) | F-06 §5, D150 (Vorschlag, N-69) |
| `zombieArlene` | Seuchentote Magd | Plague-dead Maid | Arlene | F-06, D147 (Vorschlag) |
| `zombieBiker` | Seuchentoter Schmied | Plague-dead Smith | Biker | F-06, D147 (Vorschlag) |
| `zombieBoe` | Seuchentoter Knecht | Plague-dead Farmhand | Boe | F-06, D147 (Vorschlag) |
| `zombieBowler` | Seuchentoter Müller | Plague-dead Miller | Bowler | F-06, D147 (Vorschlag) |
| `zombieBurnt` | Verbrannter | Burnt One | Burnt | F-06, D147 (Vorschlag) |
| `zombieBusinessMan` | Seuchentoter Meier | Plague-dead Steward | Businessman | F-06, D147 (Vorschlag) |
| `zombieChuck` | Felswerfer | Rock Hurler | Chuck | F-06, D147 (Vorschlag) |
| `zombieDarlene` | Seuchentote Bäuerin | Plague-dead Farmwife | Darlene | F-06, D147 (Vorschlag) |
| `zombieDemolition` | Berstender | Burster | Demolition | F-06, D147 (Vorschlag) |
| `zombieFatCop` | Seuchentoter Büttel | Plague-dead Bailiff | Cop | F-06, D147 (Vorschlag) |
| `zombieFatHawaiian` | Seuchentoter Pilger | Plague-dead Pilgrim | Tourist | F-06, D147 (Vorschlag) |
| `zombieFemaleFat` | Seuchentote Muhme | Plague-dead Gammer | Big Mama | F-06, D147 (Vorschlag) |
| `zombieFrostclaw` | Felswerfer | Rock Hurler | Chuck | F-06, D147 (Vorschlag) |
| `zombieInmate` | Seuchentoter Gefangener | Plague-dead Captive | Inmate | F-06, D147 (Vorschlag) |
| `zombieJanitor` | Seuchentoter Stallknecht | Plague-dead Stablehand | Janitor | F-06, D147 (Vorschlag) |
| `zombieJoe` | Seuchentoter Bauer | Plague-dead Peasant | Joe | F-06, D147 (Vorschlag) |
| `zombieLab` | Seuchentoter Infirmar | Plague-dead Infirmarer | Lab Worker | F-06, D147 (Vorschlag) |
| `zombieLumberjack` | Seuchentoter Holzfäller | Plague-dead Woodcutter | Lumberjack | F-06, D147 (Vorschlag) |
| `zombieMaleHazmat` | Seuchentoter Aussätziger | Plague-dead Leper | Hazmat | F-06, D147 (Vorschlag) |
| `zombieMarlene` | Seuchentote Weberin | Plague-dead Weaver | Marlene | F-06, D147 (Vorschlag) |
| `zombieMoe` | Seuchentoter Köhler | Plague-dead Charcoal Burner | Moe | F-06, D147 (Vorschlag) |
| `zombieMutated` | Moorleiche | Bog Body | Mutated | F-06, D147 (Vorschlag) |
| `zombieNurse` | Seuchentote Siechenmagd | Plague-dead Infirmary Maid | Nurse | F-06, D147 (Vorschlag) |
| `zombiePartyGirl` | Seuchentote Schankmagd | Plague-dead Tavern Maid | Party Girl | F-06, D147 (Vorschlag) |
| `zombiePlagueSpitter` | Seuchentoter Hirte | Plague-dead Herdsman | Rancher | F-06, D147 (Vorschlag) |
| `zombieRancher` | Seuchentoter Hirte | Plague-dead Herdsman | Rancher | F-06, D147 (Vorschlag) |
| `zombieScreamer` | Schreiende | Wailer | Screamer | F-06, D147 (Vorschlag) |
| `zombieSkateboarder` | Seuchentoter Strauchdieb | Plague-dead Footpad | Thug | F-06, D147 (Vorschlag) |
| `zombieSoldier` | Seuchentoter Krieger | Plague-dead Warrior | Soldier | F-06, D147 (Vorschlag) |
| `zombieSpider` | Springer | Leaper | Spider | F-06, D147 (Vorschlag) |
| `zombieSteve` | Seuchentoter Tagelöhner | Plague-dead Day Labourer | Steve | F-06, D147 (Vorschlag) |
| `zombieSteveCrawler` | Kriecher | Crawler | Crawler | F-06, D147 (Vorschlag) |
| `zombieTomClark` | Seuchentoter Töpfer | Plague-dead Potter | Tom Clark | F-06, D147 (Vorschlag) |
| `zombieUtilityWorker` | Seuchentoter Erzgräber | Plague-dead Ore Digger | Utility Worker | F-06, D147 (Vorschlag) |
| `zombieYo` | Seuchentoter Bursche | Plague-dead Lad | Yo | F-06, D147 (Vorschlag) |

## 3. Stoffe

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `resourceScrapIron` | Raseneisenerz | Bog Iron Ore | Eisen / Iron (aus Schrott) | WP4.1 |
| `itm700_luppe` | Luppe | Iron Bloom | — | WP4 |
| `resourceForgedIron` | Schmiedeeisen | Wrought Iron | Geschmiedetes Eisen / Forged Iron | WP4.1 |
| `resourceForgedSteel` | Tiegelstahl | Crucible Steel | Geschmiedeter Stahl / Forged Steel | D55 |
| `resourceScrapBrass` | Buntmetall | Scrap Bronze | Messing / Brass | WP4.1 |
| `resourceScrapLead` | Blei | Lead | Blei / Lead | WP4.1 |
| `resourceCoal` | Holzkohle | Charcoal | Kohle / Coal | WP4 |
| `resourceYuccaFibers` | Nesselfaser | Nettle Fiber | Pflanzenfasern / Plant Fibers | WP4.1 |
| `resourceCropCottonPlant` | Flachs | Flax | Baumwolle / Cotton | WP4.1 |
| `resourceCement` | Branntkalk | Quicklime | Zement / Cement | D63 |
| `resourceConcreteMix` | Mörtel | Mortar | Betonmischung / Concrete Mix | D63 |
| `resourcePaper` | Pergament | Parchment | Papier / Paper | WP7.5 |
| `resourceSewingKit` | Nähzeug | Sewing Kit | Nähset / Sewing Kit | WP5.5 |
| `resourceGlue` | Leim | Glue | Kleber / Glue | D78 |
| `itm700_runenkreide` | Runenkreide | Rune Chalk | — | F-15, D177 — zu prüfen (N-121) |
| `itm700_glutstein` | Glutstein | Ember Stone | — | F-15, D177 — zu prüfen (N-121) |
| `itm700_bernstein` | Bernstein | Amber | — | F-05, D181 — zu prüfen (N-125) |
| `medicalFirstAidBandage` | Salbenverband | Salved Bandage | Erste-Hilfe-Verband / First Aid Bandage | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `drugHerbalAntibiotics` | Kräutersud | Herb Decoction | Natürliche Antibiotika / Herbal Antibiotics | Loop 2026-11-23 — Name zu prüfen (D99, D133) |
| `itm700_eulenauge` | Eulenauge | Owl's Eye | — (Trank) | F-15, D174, D179 — zu prüfen (N-123) |
| `itm700_baerenmut` | Bärenmut | Bear's Courage | — (Trank) | F-15, D174, D179 — zu prüfen (N-123) |
| `itm700_wolfsbalsam` | Wolfsbalsam | Wolf's Balm | — (Salbe) | F-15, D174, D179 — zu prüfen (N-123) |
| `itm700_quellsud` | Quellsud | Spring Brew | — (Trank, Odem) | F-15, D174, D179 — zu prüfen (N-123) |
| `buff700_baerenmutNach` | Verbrauchter Mut | Spent Courage | — (Nachwirkung) | D179 — zu prüfen (N-123) |
| `buff700_quellsudAbklingen` | Quellsud: Nachklang | Spring Brew: Fading | — (Abklingzeit) | D179 — zu prüfen (N-123) |
| `itm700_weihwasser` | Geweihtes Wasser | Holy Water | — (Grundstoff der Segen) | F-15, D180 — zu prüfen (N-124) |
| `itm700_segenWehr` | Segen der Wehr | Blessing of Warding | — (Segen) | F-15, D174, D180 — zu prüfen (N-124) |
| `itm700_totensegen` | Totensegen | Blessing of the Dead | — (Segen) | F-15, D174, D180 — zu prüfen (N-124) |
| `itm700_fluchtopf` | Fluchtopf | Curse Pot | — (Wurf, Fluch der Schwere) | F-15, D115, D174, D180 — zu prüfen (N-124) |
| `buff700_segenWehrAbklingen` | Wehr: Ruhe | Warding: Resting | — (Abklingzeit) | D180 — zu prüfen (N-124) |
| `buff700_totensegenAbklingen` | Totensegen: Ruhe | Blessing of the Dead: Resting | — (Abklingzeit) | D180 — zu prüfen (N-124) |
| `itm700_bernsteinamulett` | Bernsteinamulett | Amber Amulet | — (Amulett, `BiomeBadge4`) | F-15, D174, D181 — zu prüfen (N-125) |
| `itm700_hammeramulett` | Hammeramulett | Hammer Amulet | — (Amulett) | F-15, D174, D181 — zu prüfen (N-125) |
| `itm700_kreuzanhaenger` | Kreuzanhänger | Cross Pendant | — (Amulett, Klostermarkt) | F-15, D174, D181 — zu prüfen (N-125) |
| `itm700_reliquienkapsel` | Reliquienkapsel | Reliquary | — (Amulett, nur Beute) | F-15, D174, D181 — zu prüfen (N-125) |
| `itm700_glutpfeil` | Glutpfeil | Ember Bolt | — (Zauber, Fernkampf ohne Munition) | F-15, D174, D183 — zu prüfen (N-127) |
| `itm700_lichtfunke` | Lichtfunke | Light Spark | — (Zauber, gehaltenes Licht) | F-15, D174, D183 — zu prüfen (N-127) |
| `itm700_bannkreis` | Bannkreis | Ban Circle | — (Zauber, Aura) | F-15, D171, D183 — zu prüfen (N-127) |
| `buff700_bannkreis` | Bannkreis | Ban Circle | — (Aura auf dem Zaubernden) | D183 — zu prüfen (N-127) |
| `buff700_funkeZehrt` | Der Funke zehrt | The Spark Feeds | — (Lichtfunke ohne Odem) | D183 — zu prüfen (N-127) |

## 4. Werkstätten und Feuer

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `campfire` | Feuerstelle | Hearth | Lagerfeuer / Campfire | WP4.3 |
| `workbench` | Zimmermannsbank | Carpenter's Bench | Werkbank / Workbench | GDD 2.3, WP4.3 |
| `forge` | Rennofen und Esse | Bloomery and Forge | Schmiede / Forge | GDD 2.3, WP4.3 |
| `chemistryStation` | Kräuterküche | Herbalist's Kitchen | Chemiestation / Chemistry Station | GDD 2.3, WP4.3 |
| `cementMixer` | Kalkofen | Lime Kiln | Zementmischer / Cement Mixer | GDD 2.3, WP4.3 |
| `blk700_webstuhl` | Webstuhl | Loom | — | D57 |
| `blk700_holzfeuer` | Holzfeuer | Wood Fire | — | D64 |
| `blk700_runenritzer` | Runenritzer-Stock | Rune-Carver's Stump | — (F-15: „Runenritzer-Bank") | D57, D177 — Name zu prüfen (N-121) |
| `buff700_amfeuerName` | Am Feuer | By the Fire | — | D73 |

## 5. Waffen und Werkzeug

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `meleeWpnBladeT1HuntingKnife` | Sax | Sax | Jagdmesser / Hunting Knife | D58 |
| `itm700_ritzmesser` | Ritzmesser | Carving Knife | — (Werkzeugplatz) | F-15, D177 — zu prüfen (N-121) |
| `itm700_meissel` | Meißel | Chisel | — (Werkzeugplatz) | F-15, D177 — zu prüfen (N-121) |
| `itm700_glutrune` | Glutrune | Ember Rune | — (Aufsatz, Nahkampf) | F-15, D174, D178 — zu prüfen (N-122) |
| `itm700_bannrune` | Bannrune | Ward Rune | — (Aufsatz, Waffe) | F-15, D174, D178 — zu prüfen (N-122) |
| `itm700_schutzrune` | Schutzrune | Shield Rune | — (Aufsatz, Rumpf) | F-15, D174, D178 — zu prüfen (N-122) |
| `itm700_wetterrune` | Wetterrune | Weather Rune | — (Aufsatz, Kopf) | F-15, D174, D178 — zu prüfen (N-122) |
| `itm700_wanderrune` | Wanderrune | Wayfarer's Rune | — (Aufsatz, Füße) | F-15, D174, D178 — zu prüfen (N-122) |
| `meleeWpnBladeT3Machete` | Spatha | Spatha | Machete | D58 |
| `meleeWpnSpearT1IronSpear` | Ango | Ango | Eisenspeer / Iron Spear | WP5.1 |
| `meleeWpnSpearT3SteelSpear` | Flügellanze | Winged Lance | Stahlspeer / Steel Spear | WP5.1 |
| `meleeToolAxeT2SteelAxe` | Breitaxt | Broad Axe | Stahlaxt / Steel Axe | D88 (bis 2026-11-22: Bartaxt) |
| `meleeToolAxeT1IronFireaxe` | Bartaxt | Bearded Axe | Eiserne Feueraxt / Iron Fireaxe | D58, D88 (bis 2026-11-22: Breitaxt) |
| `meleeWpnClubT3SteelClub` | Streitkolben | Mace | Stahlknüppel / Steel Club | WP5.1 |
| `meleeWpnSledgeT3SteelSledgehammer` | Streithammer | War Hammer | Stahlvorschlaghammer / Steel Sledgehammer | WP5.1 |
| `gunBowT3CompoundBow` | Langbogen | Longbow | Compoundbogen / Compound Bow | D87 |
| `gunBowT1IronCrossbow` | Armbrust | Crossbow | Eiserne Armbrust / Iron Crossbow | D87 |
| `gunBowT3CompoundCrossbow` | Schwere Armbrust | Heavy Crossbow | Compoundarmbrust / Compound Crossbow | D87 |
| `ammoArrowSteelAP` | Panzerbrecherpfeil | Armour-piercer Arrow | Stahlpfeil / Steel Arrow | D87 |
| `ammoCrossbowBoltSteelAP` | Panzerbrecherbolzen | Armour-piercer Bolt | Stahlbolzen / Steel Crossbow Bolt | D87 |
| `ammoArrowExploding` | Feuertopfpfeil | Fire-pot Arrow | Sprengpfeil / Exploding Arrow | D87 |
| `ammoCrossbowBoltExploding` | Feuertopfbolzen | Fire-pot Bolt | Sprengbolzen / Exploding Crossbow Bolts | D87 |
| `tableSaw` | Schreinerbank | Joiner's Bench | Tischkreissäge / Table Saw | D87 |
| `modArmorCoolingMesh` | Leinenfutter | Linen Lining | Kühlmaschen-Mod / Cooling Mesh Mod | D87 |
| `itm700_schleifstein` | Schleifstein | Whetstone | (statt Reparaturkit / Repair Kit) | D60 |
| `itm700_schmiedeflicken` | Schmiedeflicken | Forge Patch | (statt Reparaturkit / Repair Kit) | D60, D62 |
| `itm700_bogenzeug` | Bogenzeug | Bowyer's Kit | (statt Reparaturkit / Repair Kit, für Bögen und Armbrüste) | D91 — Name zu prüfen |
| `meleeToolTorch` | Fackel | Torch | Fackel / Torch | WP6 |
| `ammoArrowStone` | Steinpfeil | Stone Arrow | Steinpfeil (Munition) / Stone Arrow (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoArrowIron` | Eisenpfeil | Iron Arrow | Eisenpfeil (Munition) / Iron Arrow (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoArrowFlaming` | Brandpfeil | Flaming Arrow | Feuerpfeil (Munition) / Flaming Arrow (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoCrossbowBoltStone` | Steinbolzen | Stone Bolt | Steinbolzen für Armbrüste (Munition) / Stone Crossbow Bolt (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoCrossbowBoltIron` | Eisenbolzen | Iron Bolt | Eisenbolzen für Armbrüste (Munition) / Iron Crossbow Bolt (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoCrossbowBoltFlaming` | Brandbolzen | Flaming Bolt | Feuerbolzen für Armbrüste (Munition) / Flaming Crossbow Bolt (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoDartIron` | Eisendorn | Iron Dart | Eisendart (Munition) / Iron Dart (Ammo) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoBundleArrowSteelAP` | Panzerbrecherpfeil-Bündel (100) | Bundle of Armour-piercer Arrows (100) | Kiste mit Stahlpfeilen (100) / Box of Steel Arrows (100) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoBundleArrowExploding` | Feuertopfpfeil-Bündel (75) | Bundle of Fire-pot Arrows (75) | Kiste mit Sprengpfeilen (75) / Box of Exploding Arrows (75) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoBundleCrossbowBoltIron` | Eisenbolzen-Bündel (100) | Bundle of Iron Bolts (100) | Kiste mit Eisenbolzen für Armbrüste (100) / Box of Iron Crossbow Bolts (100) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoBundleCrossbowBoltSteelAP` | Panzerbrecherbolzen-Bündel (100) | Bundle of Armour-piercer Bolts (100) | Kiste mit Stahlbolzen für Armbrüste (100) / Box of Steel Crossbow Bolts (100) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `ammoBundleCrossbowBoltExploding` | Feuertopfbolzen-Bündel (75) | Bundle of Fire-pot Bolts (75) | Kiste mit Sprengbolzen für Armbrüste (75) / Box of Exploding Crossbow Bolts (75) | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `resourceArrowHeadSteelAP` | Panzerbrecherspitze | Armour-piercer Head | Pfeilspitze aus Stahl / Steel Arrowhead | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `gunBowT0PrimitiveBow` | Haselbogen | Hazel Bow | Primitiver Bogen / Primitive Bow | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `gunBowT1WoodenBow` | Jagdbogen | Hunting Bow | Holzbogen / Wooden Bow | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `gunBowT1WoodenBowParts` | Bogenteile | Bow Parts | Bogen-/Armbrustteile / Bow / Crossbow Parts | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeClubBurningShaft` | Pechwicklung | Pitch Wrapping | Brennender-Schaft-Mod / Burning Shaft Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeClubMetalChain` | Kettenwicklung | Chain Wrapping | Metallketten-Mod / Metal Chain Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeClubMetalSpikes` | Nagelbeschlag | Nail Studding | Metallstachel-Mod / Metal Spikes Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeDiamondTip` | Stahlschneide | Steel Edge | Diamantenspitzenklinge-Mod / Diamond Blade Tip Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeTemperedBlade` | Gehärtete Klinge | Hardened Blade | Temperierte-Klinge-Mod / Tempered Blade Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeSerratedBlade` | Gezähnte Schneide | Toothed Edge | Gezähnte-Klinge-Mod / Serrated Blade Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeErgonomicGrip` | Geschnitzter Griff | Carved Grip | Ergonomischer-Griff-Mod / Ergonomic Grip Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeFortifyingGrip` | Lederwicklung | Leather Binding | Bekräftigender-Griff-Mod / Fortifying Grip Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeStructuralBrace` | Eisenband | Iron Band | Strukturelle-Klammer-Mod / Structural Brace Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeWeightedHead` | Bleifüllung | Lead Filling | Beschwerter-Kopf-Mod / Weighted Head Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeWoodSplitter` | Spaltkeil | Splitting Wedge | Holzsplitter-Mod / Wood Splitter Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeIronBreaker` | Eisenbrecher | Iron Breaker | Eisenbrecher-Mod / Iron Breaker Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modMeleeGraveDigger` | Totengräber | Grave Digger | Totengräber-Mod / Grave Digger Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modGunMeleeTheHunter` | Jägerschliff | Hunter's Edge | Die Jäger-Mod / The Hunter Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |
| `modGunBowArrowRest` | Pfeilkerbe | Arrow Notch | Pfeilauflage-Mod / Arrow Rest Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Waffen) |

## 6. Rüstung

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `armorT1` | Lumpen | Rags | Primitive Rüstung / Primitive Armor | D59, D61 |
| `armorT2` | Wolle und Leder | Wool and leather | Leichte Rüstungen / Light Armors | D59, D61 |
| `armorT3` | Gambeson | Gambeson | Mittlere Rüstungen / Medium Armors | D59, D61 |
| `armorT4` | Kettenzeug | Mail | Schwere Rüstungen / Heavy Armors | D59, D61 |
| `itm700_gambeson` | Gambeson | Gambeson | — | WP5.5 |
| `itm700_kettenhemd` | Kettenhemd | Mail Shirt | — | WP5.5 |
| `itm700_spangenhelm` | Spangenhelm | Spangenhelm | — | WP5.5 |
| `clothingHeadT1` | Zerschlissene Unterhaube | Threadbare Under-cap | Zerfleddertes Mützenfutter / Tattered Cap Liner | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingHeadT2` | Leinene Unterhaube | Linen Under-cap | Patchwork-Mützenfutter / Patchwork Cap Liner | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingHeadT3` | Gewalkte Unterhaube | Fulled Under-cap | ThermaCore-Mützenfutter / ThermaCore Cap Liner | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingOutfitT1` | Zerschlissenes Hemd | Threadbare Shirt | Zerfledderte Unterwäsche / Tattered Undergarments | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingOutfitT2` | Leinenhemd | Linen Shirt | Lange Patchwork-Unterwäsche / Patchwork Long Underwear | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingOutfitT3` | Gewalktes Wollhemd | Fulled Wool Shirt | ThermaCore-Kampfschicht / ThermaCore Combat Layer | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingHandsT1` | Zerschlissene Unterhandschuhe | Threadbare Under-gloves | Zerfleddertes Handschuhfutter / Tattered Glove Liners | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingHandsT2` | Leinene Unterhandschuhe | Linen Under-gloves | Patchwork-Handschuhfutter / Patchwork Glove Liners | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingHandsT3` | Gewalkte Unterhandschuhe | Fulled Under-gloves | ThermaCore-Handschuhfutter / ThermaCore Glove Liners | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingFeetT1` | Zerschlissene Fußlappen | Threadbare Foot-wraps | Zerfledderte Socken / Tattered Socks | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingFeetT2` | Leinene Fußlappen | Linen Foot-wraps | Patchwork-Socken / Patchwork Socks | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `clothingFeetT3` | Gewalkte Socken | Fulled Socks | ThermaCore-Socken / ThermaCore Socks | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorInsulatedLinerT1` | Wergfutter | Tow Lining | Zerfledderte isolierende Rüstungs-Mod / Tattered Insulated Armor Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorInsulatedLinerT2` | Wollfutter | Wool Lining | Isolierende Patchwork-Rüstungs-Mod / Patchwork Insulated Armor Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorInsulatedLinerT3` | Pelzfutter | Fur Lining | Isolierende ThermaCore-Rüstungs-Mod / ThermaCore Insulated Armor Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorStoragePocket` | Gürteltasche | Belt Pouch | Taschen-Mod für Rüstung / Armor Pocket Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorDoubleStoragePocket` | Umhängetasche | Shoulder Bag | Doppeltaschen-Mod für Rüstung / Armor Double Pocket Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorTripleStoragePocket` | Tragriemen | Carrying Straps | Dreifachtaschen-Mod für Rüstung / Armor Triple Pocket Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorQuadStoragePocket` | Rückentrage | Back Frame | Vierfachtaschen-Mod für Rüstung / Armor Quad Pocket Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorBandolier` | Köcherriemen | Quiver Strap | Patronengurt-Mod / Bandolier Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorImprovedFittings` | Angepasste Riemen | Fitted Straps | Rüstung-Fittings-Mod / Armor Fittings Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorCustomizedFittings` | Maßriemen | Tailored Straps | Fortgeschrittene Rüstung-Fittings-Mod / Advanced Armor Fittings Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorPlatingBasic` | Schuppenbesatz | Scale Facing | Panzerplatten-Mod / Armor Plating Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorPlatingReinforced` | Lamellenbesatz | Lamellar Facing | Fortgeschrittene Panzerplatten-Mod / Advanced Armor Plating Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorMuffledConnectors` | Filzunterlage | Felt Padding | Gedämpfte Verbindungs-Mod / Muffled Connectors Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorAdvancedMuffledConnectors` | Doppelte Filzunterlage | Double Felt Padding | Fortgeschrittene gedämpfte Verbindungs-Mod / Advanced Muffled Connectors Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorImpactBracing` | Fersenpolster | Heel Padding | Schlag-Abwehr-Mod / Impact Bracing Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorStealthBoots` | Filzsohlen | Felt Soles | Tarnstiefel-Mod / Stealth Boots Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorFortitude` | Eberzier | Boar Crest | Standhaftigkeit-Mod / Fortitude Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorAgility` | Jagdfeder | Hunter's Feather | Beweglichkeit-Mod / Agility Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorStrength` | Stirnriemen | Brow Band | Stärke-Mod / Strength Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorIntellect` | Rautenzweig | Sprig of Rue | Intelligenz-Mod / Intellect Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorPerception` | Krempe | Hat Brim | Wahrnehmung-Mod / Perception Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |
| `modArmorTreasureHunter` | Glückspfennig | Lucky Penny | Schatzsucher-Mod / Treasure Hunter's Mod | Nachtlauf 2026-11-22 — Name zu prüfen (Konzept Rüstung) |

## 7. Bauen und Licht

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Fachwerk, Bruchstein, Mörtelstein (Baustufen) | *offen* | Beton, Stahlblöcke | GDD 2.3, D63 |
| `logWallLeft` | Palisadenabschnitt | Palisade Section | Blockwand / Log Wall | WP6 |
| `candle` | Unschlittkerze | Tallow Candle | Kerze / Candle | WP6 |
| `lanternOld_01_Player` | Öllampe | Oil Lamp | Alte Laterne / Old Lantern | WP6 |
| `trapSpikesWoodDmg0` | Spitzpfähle | Sharpened Stakes | Holzstachelfalle / Wood Spikes Trap | WP6 |

## 8. Fortschritt

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `attstrength` | Handwerker | Craftsman | Stärke / Strength | D66, WP7 |
| `attfortitude` | Krieger | Warrior | Standhaftigkeit / Fortitude | D66, WP7 |
| `attagility` | Jäger | Hunter | Beweglichkeit / Agility | D66, WP7 |
| `attintellect` | Heiler | Healer | Intelligenz / Intellect | D66, WP7 |
| `attperception` | Fuhrmann | Carter | Wahrnehmung / Perception | D66, WP7 |
| `att700_runenkundigerName` | Attribut: Runenkunde | Attribute: Rune Lore | — (neu, sechstes Attribut `att700_runenkundiger`) | D111, D176 — Name zu prüfen (N-120) |
| `skl700_runenUndZeichenName` | Runen und Zeichen | Runes and signs | — | D176 — zu prüfen (N-120) |
| `skl700_odemUndZauberName` | Odem und Zauber | Odem and spells | — | D176 — zu prüfen (N-120) |
| `prk700_runenritzenName` | Runenritzen | Rune-carving | — | F-21, D176 — zu prüfen (N-120) |
| `prk700_bannkundeName` | Bannkunde | Ban-lore | — | F-21, D176 — zu prüfen (N-120) |
| `prk700_odemtiefeName` | Odemtiefe | Depth of odem | — | F-21, D176 — zu prüfen (N-120) |
| `prk700_glutzauberName` | Glutzauber | Ember-craft | — | F-21, D176 — zu prüfen (N-120) |
| `buffPerkTheDentistName` | Totenpfennig | Dead Man's Penny | Der Zahnarzt / The Dentist | D77 |
| `perkMasterChefName` | Herdmeister | Hearth-master | Chefkoch / Master Chef | D90 |
| `perkLuckyLooterName` | Finderglück | Finder's Luck | Der glückliche Sammler / Lucky Looter | D90 |
| — | Lehrblatt | Lesson | Magazin / Magazine | D70 |
| — | Blatt (einer Abschrift) | leaf | Buch / Book | D69 |
| — | Abschrift | transcript | Buchreihe | D24, D69 |
| `challengeRedeemChallenge` | Erste Herausforderung | First Challenge | Tutorial-Herausforderung / Tutorial Challenge | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `buffInfectionCureDisplayName` | Heilmittel wirkt | Remedy at Work | Antibiotische Medizin / Antibiotic Medicine | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `buffPackMuleDisplayName` | Saumlast-Schutz | Pack-load Protection | Packesel-Schutz / Pack Mule Protection | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |

### Wörter der Spielmechanik

Gemessen an unseren 603 Zeilen (20. November 2026): das Deutsche kommt ohne ein einziges
englisches Spielwort aus. Das bleibt so.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Stufe | level (einer Fertigkeit), tier (eines Dings), rank (eines Perks) | Level, Stufe, Rang | WP7 |
| — | Fertigkeit | skill | Skill, Perk, Fertigkeit | WP7 |
| — | Ausdauer | stamina | Ausdauer | D73 |
| — | Odem | odem (Lehnwort, klein im Satz) | — (neu: Kraftvorrat der Volksmagie) | D36, D176 — englische Form zu prüfen (N-120) |
| `lblCategoryAmmoWeapons` | Geschosse/Waffen | Missiles/Weapons | Munition/Waffen / Ammo/Weapons | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `lblCategoryChemicals` | Gebräue | Brews | Chemikalien / Chemicals | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |
| `xuiAmmo` | Geschosse | Missiles | Munition / Ammo | Nachtlauf 2026-11-22 — Name zu prüfen (Prüfung 0001) |

## 9. Verbotene Begriffe

Kein Text von uns benutzt sie. **Das gilt für unsere Zeilen** — die rund 500 sichtbaren
Vanilla-Zeilen, die noch „Zombie" sagen, findet diese Prüfung nicht; sie stehen als
Arbeitsvorrat im Plan (WP8.5).

### Vanillas Welt

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `zombie` | beide | Seuchentote / the plague-dead | GDD 2.3 |
| `blood ?moon` | EN | Plague Night | GDD 2.3 |
| `blutmond` | DE | Seuchennacht | GDD 2.3 |
| `horde night` | EN | Plague Night | GDD 2.3 |
| `hordennacht` | DE | Seuchennacht | GDD 2.3 |
| `\bBM\b` | beide | Plague Night / Seuchennacht, ausgeschrieben (Vanillas Kürzel für „Blood Moon" in den Spieloptionen) | D79 |
| `navezgane` | beide | (kein Ersatz — Vanillas Land; das Mischland bleibt namenlos, D1) | D1 |
| `\bdukes?\b` | DE | Silber, Silberpfennig; als Person: Fürst | D30 |
| `\bdukes\b` | EN | silver, Silver Penny (ein „duke" als Titel ist erlaubt) | D30 |
| `casino` | beide | Silberpfennig / Silver Penny | D30 |
| `kasino` | DE | Silberpfennig | D30 |
| `radiated` | EN | (EN offen, siehe Welt) | GDD 2.3 |
| `verstrahl` | DE | Moorleichen | GDD 2.3 |
| `white.?river` | beide | (keine Händler-Fraktion; der einzelne Händler spricht für sich, lore.md §4) | D159, WP8.4 |
| `cassadore` | beide | Räuber / robbers | D159, WP8.4 |

### Umgedeutete Dinge: der alte Name ist nicht mehr der Name

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `campfire` | EN | Hearth | WP4.3 |
| `lagerfeuer` | DE | Feuerstelle (das Holzfeuer ist ein anderes Ding) | WP4.3 |
| `workbench` | EN | Carpenter's Bench | GDD 2.3 |
| `werkbank` | DE | Zimmermannsbank | GDD 2.3 |
| `chemistry station` | EN | Herbalist's Kitchen | GDD 2.3 |
| `chemiestation` | DE | Kräuterküche | GDD 2.3 |
| `cement` | EN | Quicklime, Lime Kiln | D63 |
| `zement` | DE | Branntkalk, Kalkofen | D63 |
| `concrete` | EN | Mortar | D63 |
| `beton(?![teu])` | DE | Mörtel, Bruchstein („betont" und „Betonung" bleiben erlaubt) | D63 |
| `scrap iron` | EN | Bog Iron Ore | WP4.1 |
| `schrott` | DE | Raseneisenerz, Buntmetall | WP4.1 |
| `repair kit` | EN | Whetstone, Forge Patch | D60, D62 |
| `reparaturkit` | DE | Schleifstein, Schmiedeflicken | D60, D62 |
| `magazin` | beide | Lehrblatt / Lesson | D70 |
| `cotton` | EN | Flax | WP4.1 |
| `baumwoll` | DE | Flachs | WP4.1 |
| `yucca` | beide | Nesselfaser / Nettle Fiber | WP4.1 |
| `machete` | beide | Spatha | D58 |
| `fire ?axe` | EN | Bearded Axe | D58, D88 |
| `feueraxt` | DE | Bartaxt | D58, D88 |
| `\bpaper` | EN | Parchment | WP7.5 |
| `papier` | DE | Pergament | WP7.5 |
| `hunting knife` | EN | Sax | D58 |
| `jagdmesser` | DE | Sax | D58 |
| `iron spear` | EN | Ango | WP5.1 |
| `eisenspeer` | DE | Ango | WP5.1 |
| `steel spear` | EN | Winged Lance | WP5.1 |
| `stahlspeer` | DE | Flügellanze | WP5.1 |
| `steel axe` | EN | Broad Axe | WP5.1, D88 |
| `stahlaxt` | DE | Breitaxt | WP5.1, D88 |
| `compound` | beide | Langbogen / Longbow, Schwere Armbrust / Heavy Crossbow | D87 |
| `iron crossbow` | EN | Crossbow | D87 |
| `eiserne armbrust` | DE | Armbrust | D87 |
| `steel arrow` | EN | Armour-piercer Arrow | D87 |
| `stahlpfeil` | DE | Panzerbrecherpfeil | D87 |
| `stahlbolzen` | DE | Panzerbrecherbolzen | D87 |
| `exploding` | EN | Fire-pot Arrow, Fire-pot Bolt | D87 |
| `sprengpfeil` | DE | Feuertopfpfeil | D87 |
| `sprengbolzen` | DE | Feuertopfbolzen | D87 |
| `table saw` | EN | Joiner's Bench | D87 |
| `tischkreiss` | DE | Schreinerbank | D87 |
| `cooling mesh` | EN | Linen Lining | D87 |
| `kühlmaschen` | DE | Leinenfutter | D87 |
| `steel club` | EN | Mace | WP5.1 |
| `stahlknüppel` | DE | Streitkolben | WP5.1 |
| `sledgehammer` | EN | Stone Maul, Iron Maul, War Hammer; die Gattung: hammer | WP5.1 |
| `vorschlaghammer` | DE | Steinhammer, Eisenhammer, Streithammer; die Gattung: Hammer | WP5.1 |
| `forged iron` | EN | Wrought Iron | WP4.1 |
| `\bgeschmiedetes eisen` | DE | Schmiedeeisen („ausgeschmiedetes Eisen" bleibt erlaubt) | WP4.1 |
| `forged steel` | EN | Crucible Steel | D55 |
| `\bgeschmiedeter stahl` | DE | Tiegelstahl | D55 |
| `\bcoal\b` | EN | Charcoal | WP4 |
| `\bkohle\b` | DE | Holzkohle | WP4 |
| `plant fiber` | EN | Nettle Fiber | WP4.1 |
| `pflanzenfaser` | DE | Nesselfaser | WP4.1 |
| `nähset` | DE | Nähzeug | WP5.5 |
| `\bkleber` | DE | Leim | D78 |
| `log wall` | EN | Palisade Section | WP6 |
| `blockwand` | DE | Palisadenabschnitt | WP6 |
| `old lantern` | EN | Oil Lamp | WP6 |
| `alte laterne` | DE | Öllampe | WP6 |
| `spikes trap` | EN | Sharpened Stakes | WP6 |
| `holzstachel` | DE | Spitzpfähle | WP6 |
| `primitive armor` | EN | Rags | D59 |
| `primitive rüstung` | DE | Lumpen | D59 |
| `dentist` | EN | Dead Man's Penny | D77 |
| `zahnarzt` | DE | Totenpfennig | D77 |

**Alte Namen ohne Verbot, mit Grund** (ergänzt am 2026-11-20 nach dem Review, das „Jagdmesser"
als Lücke fand). Nicht jeder Vanilla-Name aus den Tabellen oben lässt sich verbieten:

- *Das Wort ist auch unser Wort oder steckt in unserem Namen:* Eisen / Iron, Forge und
  Schmiede („Bloomery and Forge", „Werkzeugschmiede"), Kerze / Candle, Fackel / Torch,
  Blei / Lead, Sewing Kit, Glue (englisch unverändert; nur das deutsche „Kleber" ist
  verboten).
- *Das Wort ist Alltagssprache:* Messing / Brass (unsere Beschreibung des Buntmetalls nennt
  es), Leichte/Mittlere/Schwere Rüstung, Feral („wild"), Buch / Book, und die fünf
  Attributnamen (Stärke, Standhaftigkeit, Beweglichkeit, Intelligenz, Wahrnehmung).
- *Der englische Ersatz ist noch offen:* Trader.
- *Der neue Name ist noch nicht abgenommen:* alle Zeilen mit dem Vermerk „Nachtlauf
  2026-11-22 — Name zu prüfen" (Verband, Geschosse, Bögen, Aufsätze, Unterkleidung, der
  Sturm des Ödlands). Ihre Vanilla-Namen tragen noch kein Verbot; das Verbot kommt mit der
  Abnahme des Namens, nicht vorher.

Wer einen Festbegriff mit einem neuen Vanilla-Namen einträgt, trägt das Verbot dazu ein —
oder den Grund hier.

### Moderne Dinge ohne Entsprechung in Phase 1

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `antibioti` | beide | (Phase 2: Kräuter, Theriak — F-11) | GDD 2.3 |
| `\bpills?\b` | EN | (Phase 2: Tränke, Salben — F-11) | GDD 2.3 |
| `pille` | DE | (Phase 2: Tränke, Salben — F-11) | GDD 2.3 |
| `electri` | EN | (Phase 2: Kraftsteine — F-15) | GDD 2.3 |
| `elektri` | DE | (Phase 2: Kraftsteine — F-15) | GDD 2.3 |
| `\bguns?\b` | EN | Bogen, Schleuder, Wurfspeer, Armbrust | GDD 2.3 |
| `schusswaffe` | DE | Bogen, Schleuder, Wurfspeer, Armbrust | GDD 2.3 |
| `duct tape` | EN | (kein Ersatz — gesperrt; Leim bindet) | D78 |
| `klebeband` | DE | (kein Ersatz — gesperrt; Leim bindet) | D78 |
| `twitch` | beide | (kein Ersatz) | D78 |

### Spielerdeutsch

Eine Setzung aus WP8.5, keine Vorgabe aus dem GDD: im Deutschen stehen deutsche Wörter. Im
Englischen sind dieselben Wörter Alltagssprache und darum erlaubt.

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `\blevel` | DE | Stufe | D75 (Setzung) |
| `\bskill` | DE | Fertigkeit | D75 (Setzung) |
| `\bperk` | DE | Fertigkeit | D75 (Setzung) |
| `\bbuff` | DE | Wirkung | D75 (Setzung) |
| `\bloot` | DE | Beute | D75 (Setzung) |
| `\bcraft` | DE | herstellen, fertigen, bauen | D75 (Setzung) |

## 10. Offene Begriffe

Das entscheidet der Nutzer; bis dahin schreibt kein Text sie englisch aus.

1. **Verderbte, Moorleichen** — englisch offen. Gebraucht ab F-06 (Phase 2), aber schon
   jetzt in sieben sichtbaren Wesen-Namen (`zombieSpiderFeral` und Verwandte).
2. **Wanderhändler, Klostermarkt, Fürstenhof** — englisch offen (F-10, Phase 2).
3. **Fachwerk, Bruchstein, Mörtelstein** — die Baustufen haben in Vanilla keinen eigenen
   Sprachschlüssel (`concreteShapes`, `steelShapes` tragen keinen); wo der Name erscheint,
   ist ungemessen.
4. **„Schlagringe"** heißt die Handwerks-Fertigkeit (`craftingKnucklesName`, englisch
   „Knuckles"), die Waffen darunter heißen aber Faustriemen, Eisenfaust und Stahlfaust. Ein
   Schlagring ist kein Ding um 700. Vorschlag: „Faustwehr" / „Fist-gear" — nicht geändert,
   weil ein Name eine Entscheidung ist.
5. **„Scrap Bronze"** für Buntmetall trägt das englische „scrap" weiter. Gemeint ist
   Altmetall aus Ruinen; ob „Old Bronze" besser trifft, ist offen.
6. **„Gebietsschutzblock" / „Land Claim Block"** (`keystoneBlock`) heißt weiter wie in
   Vanilla; nur seine Beschreibung ist umgeschrieben (D77). Vorschlag: „Grenzstein" /
   „Boundary Stone" — nicht geändert, weil ein Name eine Entscheidung ist.
7. **„Totenpfennig" / „Dead Man's Penny"** ist eine Setzung aus D77 für Vanillas „Der
   Zahnarzt" und wartet auf die Abnahme: gemeint ist das Silber oder Gold, das man manchem
   Toten mitgab — der Text sagt nicht, wohin.

## 11. Namen (D1, D6)

Angelegt am 21. November 2026 mit WP8.6 (D83). Die Regeln stehen in
[Vertrag 02 §4 und §6](contracts/02-namensraum.md); hier steht, **welche Namen es gibt**.
Jeder Name, der im Spiel auftaucht, steht vorher hier.

### Der Name der Mod

Der Arbeitstitel bleibt bis zum Release (D6). Er steht in **einer** Zeile der Sprachdatei,
unter `700_modName`. Wer ihn zeigen will — ein Etikett im Menü, eine Meldung aus dem Code —,
liest diesen Schlüssel. **Kein Fließtext schreibt den Namen aus:** die Sprachdatei kann in
einem Text keinen anderen Schlüssel einsetzen, also wäre jede ausgeschriebene Stelle eine
zweite Zeile, die bei der Umbenennung jemand finden muss.

| Alleinname | Deutsch | Englisch | Quelle |
|---|---|---|---|
| `700_modName` | 7DTD_700 | 7DTD_700 | D6, Vertrag 02 §4 |

Ein **Alleinname** steht in der ganzen Sprachdatei nur unter seinem Schlüssel: die Zeile
`700_modName` muss genau diesen Namen tragen, und keine andere Zeile darf ihn enthalten —
weder als ganzen Text noch mitten in einem Satz, Groß- und Kleinschreibung egal.
*(Bis zum Review vom 2026-11-21 stand hier ein Festbegriff mit zwei Verbotsmustern; eine
zweite Zeile, die nur aus dem Namen bestand, ließen sie durch.)*

### Orte und Personen

~~**Stand: Das Mischland hat keinen Ortsnamen und keine benannte Person.** Kein Text von uns
nennt einen Ort oder einen Menschen beim Namen — der Zettel am Anfang (`noteDuke01Desc`) ist
ohne Unterschrift, die Händler heißen weiter wie in Vanilla (F-10, Phase 2).~~ Der erste Name,
der gebraucht wird, kommt zuerst in diese Liste, gebildet nach Vertrag 02 §6: Orte erfunden,
auf `-heim`, `-feld`, `-wik`, `-grad`, `-dun`, `-ing`; Personen aus dem germanischen,
romanischen, slawischen und keltischen Namensschatz der Zeit.

**Stand 2026-11-23 (WP6.7, WP8.1, WP8.4; D158–D160, zu prüfen N-103 bis N-105):** das Mischland hat
weiter **keinen Ortsnamen**. Personen gibt es jetzt — Schreiber von Fundschriften und Hortbriefen,
dazu die fünf Händler als Vorschlag. Der Name „Wido" stand mit WP6.7 im Spiel, bevor er hier stand;
das ist mit dieser Zeile nachgeholt.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Bruder Wido | Brother Wido | — | Klosterbuch, `itm700_schriftMoench1Desc`/`2Desc`, D158 |
| — | Hrodo | Hrodo | Claude | Hortbrief, `treasure_claude`, D160 |
| — | Gerlind | Gerlind | Jennifer | Hortbrief, `treasure_jennifer`, D160 |
| — | Odila | Odila | Nickole | Hortbrief, `treasure_nickole`, D160 |
| — | Ratbod, sein Sohn Ebbo | Ratbod, his son Ebbo | Raphael, Joey | Hortbrief, `treasure_raphael`, D160 |
| — | Swanhild | Swanhild | Sarah | Hortbrief, `treasure_sarah`, D160 |
| — | Stephanus | Stephanus | Stephan | Hortbrief, `treasure_stephan`, D160 |
| — | Theudo | Theudo | Taylor | Hortbrief, `treasure_taylor`, D160 |
| `npcTraderRekt` | Bruder Gerwin | Brother Gerwin | Trader Rekt | Cellerar am Klostermarkt; F-10 B, D159, D163, D166 — zu prüfen (N-108) |
| `npcTraderBob` | Kaufmann Reginhart | Merchant Reginhart | Trader Bob | im Marktflecken; F-10 B, D159, D163, D166 — zu prüfen (N-108) |
| `npcTraderHugh` | Kämmerer Waldo | Chamberlain Waldo | Trader Hugh | am Fürstenhof; F-10 B, D159, D163, D166 — zu prüfen (N-108) |
| `npcTraderJen` | Köhlerin Gisla | Charcoal-Burner Gisla | Trader Jen | am Köhlerhof; F-10 B, D159, D163, D166 — zu prüfen (N-108) |
| `npcTraderJoel` | Fährmann Haduwin | Ferryman Haduwin | Trader Joel | am Fährhof; F-10 B, D159, D163, D166 — zu prüfen (N-108) |
| `subtitleSpeaker_Trader_Rekt` | Bruder Gerwin | Brother Gerwin | Trader Rekt | Sprecher im Untertitel; D163, D166 |
| `subtitleSpeaker_Trader_Bob` | Kaufmann Reginhart | Merchant Reginhart | Trader Bob | Sprecher im Untertitel; D163, D166 |
| `subtitleSpeaker_Trader_Hugh` | Kämmerer Waldo | Chamberlain Waldo | Trader Hugh | Sprecher im Untertitel; D163, D166 |
| `subtitleSpeaker_Trader_Jen` | Köhlerin Gisla | Charcoal-Burner Gisla | Trader Jen | Sprecher im Untertitel; D163, D166 |
| `subtitleSpeaker_Trader_Joel` | Fährmann Haduwin | Ferryman Haduwin | Trader Joel | Sprecher im Untertitel; D163, D166 |

*Seit D166 (WP8.2, Vertragsbezug):* das Namensschild trägt **Amt und Namen** — so verlangt es
Vertrag 02 Nachtrag Teil B („Händler: Posten, dazu ein Personenname", Beispiel „Schmied Radulf").
D163 hatte den Namen allein gesetzt.

**Die fünf Posten** (Name auf Karte und Kompass, `trader_*` und `trader_*2`; D163, zu prüfen N-108).
Ein Ortsname im Sinne von Vertrag 02 §6 ist das nicht — es sind Gattungsnamen, wie man einen Hof
nach seinem Gewerbe nennt; das Mischland bleibt ohne eigenen Ortsnamen.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `trader_rekt` | Klostermarkt | Cloister Market | Trader Rekt | F-10 B, D41, D159, D163 |
| `trader_rekt2` | Klostermarkt | Cloister Market | Trader Rekt | zweiter Ort desselben Händlers |
| `trader_bob` | Marktflecken | Market Town | Trader Bob | F-10 B, D41, D159, D163 |
| `trader_bob2` | Marktflecken | Market Town | Trader Bob | zweiter Ort desselben Händlers |
| `trader_hugh` | Fürstenhof | Lord's Hall | Trader Hugh | F-10 B, D41, D159, D163 |
| `trader_hugh2` | Fürstenhof | Lord's Hall | Trader Hugh | zweiter Ort desselben Händlers |
| `trader_jen` | Köhlerhof | Charcoal-Burner's Croft | Trader Jen | F-10 B, D159, D163 |
| `trader_jen2` | Köhlerhof | Charcoal-Burner's Croft | Trader Jen | zweiter Ort desselben Händlers |
| `trader_joel` | Fährhof | Ferry Croft | Trader Joel | F-10 B, D159, D163 |
| `trader_joel2` | Fährhof | Ferry Croft | Trader Joel | zweiter Ort desselben Händlers |
| `challengeGroupTradersQuests` | Posten und Aufträge | Posts and Errands | Händler/Quests / Traders / Quests | D163 |

**Erlaubt und in Gebrauch — Völker der Zeit als Herkunft, nie als Gegner:** „Römer" /
„Romans" (`resourceConcreteMixDesc`, `meleeWpnBladeT3MacheteDesc`), „fränkisch" /
„Frankish" und „englisch" / „English" (`casinoCoinDesc`). Das ist die Leitplanke aus D1:
gemischt wird die Herkunft, nicht die Epoche.

**Vanillas Namen, die bei uns nicht mehr vorkommen.** Sie standen in Rang-Titeln und
Rang-Texten lebender Fertigkeiten; die Muster halten sie draußen.

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `pummel.pete` | EN | (keine Person; die Fertigkeit heißt Club blow, ihr letzter Rang Club Master) | D83 |
| `pr.gel.peter` | DE | (keine Person; die Fertigkeit heißt Keulenschlag, ihr letzter Rang Keulenmeister) | D83 |
| `johnny` | beide | mine hand / Bergknecht | D83 |
| `wall.street` | beide | (kein realer Ort; der Rang heißt Merchant Prince / Handelsherr) | D83, Vertrag 02 §6 |
| `\brekt\b` | beide | Bruder Gerwin (Händler) / Klostermarkt (Posten) | D163 |
| `\bhugh\b` | beide | Waldo (Händler) / Fürstenhof (Posten) | D163 |
| `\bjoel\b` | beide | Haduwin (Händler) / Fährhof (Posten) | D163 |
| `trader.bob\b` | EN | Reginhart / Market Town | D163 |
| `trader.jen\b` | EN | Gisla / Charcoal-Burner's Croft | D163 |
| `ndler.bob\b` | DE | Reginhart / Marktflecken | D163 |
| `ndlerin.jen\b` | DE | Gisla / Köhlerhof | D163 |
