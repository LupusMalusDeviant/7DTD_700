# F-06 — Seuchentote & Bestiarium

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+A) | S | optional |

**Stand 2026-11-23:** ausgearbeitet im Loop (Plan-0002 WP5.1). **Jeder Name und jede Zuordnung in
diesem Dokument ist ein Vorschlag — zu prüfen durch den Nutzer (N-67).** Gebaut sind von F-06:
sieben Zahlen zur Lauthäufigkeit (`mod/700_60_Welt/Config/entityclasses.xml`, D74), die Namen
(176 Sprachzeilen, D148) und seit WP5.4 die **Gruppen der freien Landschaft** (D149, N-68): elf
Wesenregeln in der Sperrliste, daraus erzeugt `mod/700_10_Purge/Config/entitygroups.xml` (72
Zeilen), und das Modlet `mod/700_65_Wesen` mit den Nachrückern. Im Spiel gesehen ist nichts davon.

## Ziel
Die Gegnerwelt erzählt das Setting: Bäuerinnen und Knechte, Mägde, Pilger, Krieger und Hirten als
Seuchentote; dazu die Tiere des frühmittelalterlichen Waldes. Kein Gegner trägt im Spiel einen Namen
aus der Neuzeit.

## Was Phase 2 liefert — und was nicht

| | Phase 2 | später |
|---|---|---|
| Namen aller Wesen (DE/EN) | ja (WP5.3) | — |
| Gruppen in der freien Landschaft ohne neuzeitliche Klassen | ja (WP5.4) | — |
| Sagengestalten als XML-Varianten | Nachzehrer, Schreiende, Moorleiche, Spuk-Hund (WP5.5) | Irrlicht (braucht Licht am Wesen — WP7) |
| Gruppen für die Seuchennacht | vorbereitet (WP5.6), eingehängt von F-09 | — |
| Aussehen der Figuren | **bleibt Vanilla** — ein Material aus unserem Bundle auf Vanillas Figur ist ungetestet (D146, N-66, S-25) | eigene Materialien oder Netze, wenn S-25 es trägt |
| Varianten je Kulturzone über das Aussehen (D40, D43) | nein | Phase 3 (Notiz unten) |
| Menschliche Gegner | — | F-20 |

~~MVP: Namen, Werte und Sounds per XML; die Optik ist noch modern.~~ Der Kopf gilt: **Phase 2**
(D77; Prüfung 0003 W-05).

## 1. Gemessen an Vanilla (V 3.40 b10)

Quelle: `entityclasses.xml`, `entitygroups.xml`, `spawning.xml`, `Localization.csv` aus
`Data/Config`; gezählt am 2026-11-23.

| | Zahl |
|---|---|
| Klassen insgesamt | 293 |
| Klassen `zombie*` ohne die drei Vorlagen | **155** = 35 ohne Stufe + 35 `Feral` + 34 `Radiated` + 26 `Charged` + 25 `Infernal` |
| Grundnamen | **36** (35 mit einer Klasse ohne Stufe; `zombieWight` gibt es nur in Stufen) |
| Modell-Ordner / Prefabs | 32 / 98 |
| Gruppen | 1875, davon **29** in `spawning.xml` genannt („Landschaftsgruppen") |
| `zombie*` in Landschaftsgruppen | 63 Klassen aus 31 Grundnamen |
| Tiere `animal*` ohne die zwei Vorlagen | 21 Klassen (20 Grundnamen; der Geier hat eine Stufe `Radiated`), 15 davon in Landschaftsgruppen |
| Von uns überschriebene Namen | 0 |

**Zur Zahl „31 Familien" in D101:** gemeint waren die Modell-Familien. Gezählt sind es 36
Grundnamen in 32 Modell-Ordnern; `zombieFrostclaw` und `zombiePlagueSpitter` tragen in Vanillas
Sprachdatei die Namen von `zombieChuck` und `zombieRancher` („Keeping keys … for POI spawn
lookups") und benutzen deren Modelle. Die Tabelle unten führt alle 36.

**Jede Klasse hat ihren eigenen Sprachschlüssel** — der Schlüssel ist der Klassenname
(`zombieBoeFeral` → „Feral Boe" / „Wilder Boe"). Eine Stufe ist also kein Baustein, sondern steht in
jedem Namen ausgeschrieben: 155 Sprachzeilen für die Seuchentoten, 21 für die Tiere.

## 2. Die vier Stufen (D100)

~~Stärkestufen „Verderbt" bzw. „Moorleiche" statt Feral/Radiated~~ — „Moorleiche" ist nur noch die
Sagengestalt im Moor (D100; Prüfung 0003 W-25).

| Vanilla | Deutsch (m / w) | Englisch | Was die Stufe ausmacht — **gemessen mit WP5.5** an `zombieBoe…` und den Hand-Gegenständen (V 3.40 b10, unverändert) |
|---|---|---|---|
| — | — | — | die Grundfassung: 200 Lebenspunkte, Schlag 10 (Blöcke 8) |
| `Feral` | Verderbter / Verderbte | Blighted | eigenes Modell (`…Feral.prefab`), 550 Lebenspunkte, Schlag 20 (Blöcke 24), schneller im Angriff, härter zu zerlegen |
| `Radiated` | Schwärender / Schwärende | Festering | 900 Lebenspunkte; **heilt sich**, sobald er getroffen wird (`buffRadiatedRegen`); Schlag wie der Verderbte; glimmt **grün** |
| `Charged` | Glutäugiger / Glutäugige | Ember-Eyed | 1100 Lebenspunkte; **schlägt am härtesten** (60, Blöcke 150); wechselndes Tempo; glimmt **blau** |
| `Infernal` | Verdammter / Verdammte | Damned | 1700 Lebenspunkte; **bricht Blöcke am stärksten** (250, Schlag 45); fällt kaum um; Tempo mit Anläufen; glimmt **rot** |

**Zwei Dinge, die die Messung richtigstellt** (N-69): Ein Stromschlag und ein Brand stehen in
diesem Build **nicht** an den Stufen — die Hand-Gegenstände `meleeHandZombieCharged` und
`…Infernal` tragen dieselben Wirkungen wie der gewöhnliche Schlag, nur mehr Schaden. Es gibt also
keinen Effekt-Text umzudeuten. Und: das Glimmen kommt aus drei `<color>`-Knoten in
`entityclasses.xml` (`radiated` grün, `charged` blau, `infernal` rot) — **der „Glutäugige" glimmt
blau, der „Verdammte" rot.** Name und Erscheinung passen bei der dritten Stufe nicht zusammen; die
Farben sind eine XML-Zeile, die Namen eine Tabellenzeile (Finding
[`F-06-wesen-farbe-und-stufen`](../rea/findings/F-06-wesen-farbe-und-stufen.md)).

**So entsteht ein Name** (Vertrag 02, Nachtrag Phase 2, Teil B — WP5.2):

- Ein Seuchentoter nach **Stand oder Herkunft** trägt „Seuchentoter" bzw. „Seuchentote" davor:
  „Seuchentoter Knecht", „Seuchentote Magd" — englisch „Plague-dead Farmhand" („the plague-dead"
  ist der Begriff des Nutzers vom 2026-11-20).
- In einer Stufe tritt das Stufenwort an diese Stelle: „Verderbter Knecht", „Schwärende Magd".
- **Besondere Wesen und Rollennamen** stehen als ein Wort für sich: Moorleiche, Nachzehrer,
  Schreiende, Verbrannter, Felswerfer, Springer, Kriecher, Berstender — in einer Stufe
  „Verderbte Moorleiche".
- Tiere tragen den gewöhnlichen Namen.

Die Tabellen in §3 und §4 nennen den **Kern** des Namens; die 176 fertigen Namen erzeugt
`tools/gen/wp5-wesen-namen.ps1` aus `tools/gen/wp5-wesen-namen.tsv`. Die englischen Stufenwörter
sind offen (Glossar §2 und §10).

**Wo der Spieler den Namen überhaupt liest** (gelesen am Code, nicht im Spiel gesehen): der Name
eines Wesens wird von `GameManager::GameMessageServer` und `EntityPlayer::Kill` geholt — das sind
die Meldungen im Chat („… wurde von … getötet") —, dazu von Kartenobjekten und Twitch-Meldungen.
Über dem Kopf eines Seuchentoten steht kein Name. Die Namen sind also **selten sichtbar**; das
Aussehen wiegt schwerer (S-26). ~~**Zu prüfen im Spiel:** die Wirkung der dritten Stufe ist in Vanilla ein
Stromschlag — Name und Text des Effekts gehören zu WP5.5, die Mechanik bleibt (P5).~~ Gemessen mit
WP5.5: die dritte Stufe trägt in V 3.40 b10 keinen Stromschlag (siehe die Tabelle oben).

## 3. Zuordnung der 36 Grundnamen

Spalte **Stufen:** F = Feral, R = Radiated, C = Charged, I = Infernal. Spalte **Landschaft:** in
welchen Landschaftsgruppen die Klasse heute steht (W Klosterland/`pine_forest`, B Brandland, S
Sandheide/`desert`, H Winterhöhen/`snow`, M Moorland/`wasteland`; — = nur in Orten, Horden oder
Aufträgen). Spalte **freie Landschaft:** was WP5.4 mit der Klasse in den Landschaftsgruppen tut.
Das Aussehen ist **angenommen** (niemand hat die Figuren für dieses Dokument angesehen); die Namen
richten sich nach Vanillas Kennung, Körperbau und Rolle.

| Kennung | Vanilla DE | Stufen | Landschaft | 700 Deutsch (Kern) | 700 Englisch (Kern) | freie Landschaft |
|---|---|---|---|---|---|---|
| `zombieArlene` | Arlene | FRC | W B S H M | Magd | Maid | bleibt |
| `zombieBiker` | Biker | FRI | W B S H | Schmied | Smith | **heraus** |
| `zombieBoe` | Boe | FRCI | W B S H M | Knecht | Farmhand | bleibt |
| `zombieBowler` | Bowler | FRI | W B S H M | Müller | Miller | **heraus** |
| `zombieBurnt` | Brandopfer | FRCI | B M | Verbrannter | Burnt One | bleibt |
| `zombieBusinessMan` | Geschäftsmann | FRCI | W B S H M | Meier | Steward | **heraus** |
| `zombieChuck` | Chuck | FRCI | H | Felswerfer | Rock Hurler | bleibt (eigene Klasse der Winterhöhen) |
| `zombieDarlene` | Darlene | FRCI | W B S H M | Bäuerin | Farmwife | bleibt |
| `zombieDemolition` | Abbrucharbeiter | — | B S H M | Berstender | Burster | bleibt (Rolle: Brecher) |
| `zombieFatCop` | Polizist | FRI | W B S H M | Büttel | Bailiff | bleibt (Rolle: speit und birst) |
| `zombieFatHawaiian` | Tourist | FRI | W B S H M | Pilger | Pilgrim | **heraus** |
| `zombieFemaleFat` | Big Mama | FRI | M | Muhme | Gammer | bleibt |
| `zombieFrostclaw` | Chuck | FRCI | — | Felswerfer | Rock Hurler | — (wie `zombieChuck`) |
| `zombieInmate` | Insasse | FRCI | — | Gefangener | Captive | — |
| `zombieJanitor` | Hausmeister | FRCI | W B S H | Stallknecht | Stablehand | **heraus** |
| `zombieJoe` | Joe | FRC | W B S H M | Bauer | Peasant | bleibt |
| `zombieLab` | Laborant | FRC | — | Infirmar | Infirmarer | — |
| `zombieLumberjack` | Holzfäller | FRI | W B S H | Holzfäller | Woodcutter | bleibt (der Name trägt schon) |
| `zombieMaleHazmat` | Gefahrgutbeauftragter | FRCI | M | Aussätziger | Leper | bleibt (eigene Klasse des Moors) |
| `zombieMarlene` | Marlene | FRC | W B S H M | Weberin | Weaver | bleibt |
| `zombieMoe` | Moe | FRI | W B S H M | Köhler | Charcoal Burner | bleibt |
| `zombieMutated` | Mutierter | FRCI | M | **Moorleiche** | Bog Body | bleibt — Sagengestalt, §5 |
| `zombieNurse` | Krankenschwester | FRC | W B S H M | Siechenmagd | Infirmary Maid | **heraus** |
| `zombiePartyGirl` | Partymädchen | FRC | W B S H M | Schankmagd | Tavern Maid | **heraus** |
| `zombiePlagueSpitter` | Farmer | FRCI | — | Hirte | Herdsman | — (wie `zombieRancher`) |
| `zombieRancher` | Farmer | FRCI | S | Hirte | Herdsman | bleibt (eigene Klasse der Sandheide) |
| `zombieScreamer` | Schreier | FRC | — | **Schreiende** | Wailer | — Sagengestalt, §5 |
| `zombieSkateboarder` | Gangster | FRCI | W B S H | Strauchdieb | Footpad | **heraus** |
| `zombieSoldier` | Soldat | FRI | W B S H M | Krieger | Warrior | bleibt (Rolle: gerüstet) |
| `zombieSpider` | Spinnenzombie | FRCI | W B S H M | Springer | Leaper | bleibt |
| `zombieSteve` | Steve | FRC | W B S H M | Tagelöhner | Day Labourer | bleibt |
| `zombieSteveCrawler` | Kriecher | F | W B S H M | Kriecher | Crawler | bleibt |
| `zombieTomClark` | Tom Clark | FRC | W B S H M | Töpfer | Potter | bleibt |
| `zombieUtilityWorker` | Wartungstechniker | FRCI | W B S H | Erzgräber | Ore Digger | **heraus** |
| `zombieWight` | (Wildes) Wesen | FRCI, keine Grundklasse | B S H M | **Nachzehrer** | Shroud Eater | bleibt — Sagengestalt, §5 |
| `zombieYo` | Yo | FRCI | W B S H M | Bursche | Lad | bleibt |

### 3.1 „Heraus" — die neun Klassen, die die freie Landschaft verlassen

Prüfung 0002 §4.1 nennt 17 Grundnamen, die dem Namen nach Neuzeit tragen. Nach N-81 gehen sie aus
den Landschaftsgruppen, **Rollenträger bleiben**. Dieses Dokument legt die Trennung fest:

- **Neun gehen heraus:** PartyGirl, Nurse, BusinessMan, Janitor, UtilityWorker, Biker, FatHawaiian,
  Bowler, Skateboarder — gemessen **15 Klassen in 10 Landschaftsgruppen**. Sie bleiben in Orten,
  Horden und Aufträgen, bis WP6 und F-09 dort entscheiden, und tragen dort ihren 700-Namen.
- **Sechs bleiben als Rollenträger:** FatCop, Demolition (die beiden Sprenger, D100), Soldier
  (gerüstet), MaleHazmat (einzige eigene Klasse des Moors neben der Moorleiche), Rancher (einzige
  eigene Klasse der Sandheide), Lumberjack (der Name trägt) — 11 Klassen in 13 Gruppen.
- **Zwei stehen in keiner Landschaftsgruppe:** Inmate, Lab.

Was das mit den Gruppen macht (Einträge vorher → nachher): `ZombiesAll` 20 → 11, `ZombiesNight`
33 → 25, `ZombiesAllWasteland` 21 → 17, `ZombiesWastelandNight` 25 → 21, `ZombiesDesert` 4 → 3,
**`ZombiesDesertNight` 4 → 2**, die vier Ortsgruppen (`…Downtown…`) je minus 10. **Regel:** fällt
eine Gruppe unter drei Einträge, rückt eine Klasse derselben Landschaft nach (Sandheide bei Nacht:
`zombieMoe`, `zombieMoeFeral` — der Köhler).

Die Sperrliste bekommt dafür neun Wesenregeln (`wesen:zombiePartyGirl*` …); die Prüfung *wesen*
macht jede dieser Klassen in einer Landschaftsgruppe rot (Vertrag 04, Nachtrag Teil 2).

**Gebaut mit WP5.4 (D149):** die neun Regeln stehen in der Sperrliste, dazu zwei für Kojote und
Berglöwe (§4). Aus ihnen **erzeugt** `purge-patch` die Entfernungen nach
`mod/700_10_Purge/Config/entitygroups.xml` — 72 Zeilen, 17 Klassen, 14 Gruppen —, und rechnet vor
dem Schreiben nach, dass keine Landschaftsgruppe leer wird (das wäre ein Ladefehler, Finding
[`F-06-wesengruppen-laden`](../rea/findings/F-06-wesengruppen-laden.md)). Die Nachrücker stehen in
`mod/700_65_Wesen/Config/entitygroups.xml`. Nachgemessen am Vorlauf: `ZombiesAll` 11,
`ZombiesNight` 25, `ZombiesAllWasteland` 17, `ZombiesWastelandNight` 21, `ZombiesDesert` 3,
`ZombiesDesertNight` 4 (Hirte, Verderbter Hirte, Köhler, Verderbter Köhler), die vier
Stadt-Gruppen 31, 28, 28 und 39.

**Die Schwäche dieser Trennung, offen gesagt:** sie geht nach dem **Namen**, nicht nach dem
Aussehen. Ein „Knecht" in Jeans bleibt, eine „Siechenmagd" im Kittel geht. Solange keine Figur ein
eigenes Aussehen hat, ist das die einzige Trennung, die sich prüfen lässt (N-67).

## 4. Tiere (D101)

| Kennung | Vanilla DE | Landschaft | 700 Deutsch | 700 Englisch | Anmerkung |
|---|---|---|---|---|---|
| `animalRabbit` | Hase | W B S H M | Hase | Hare | belegt |
| `animalChicken` | Huhn | W B S H M | Huhn | Chicken | belegt |
| `animalDoe` | Reh | W B | Hirschkuh | Hind | belegt |
| `animalStag` | Hirsch | W B H M | Hirsch | Stag | belegt |
| `animalBoar` | Wildschwein | W B S | Wildschwein | Wild Boar | belegt |
| `animalWolf` | Wolf | W B S H M | Wolf | Wolf | belegt |
| `animalBear` | Bär | H | Bär | Bear | belegt |
| `animalBearSmall` | Kleiner Bär | H | Jungbär | Young Bear | belegt |
| `animalSnake` | Schlange | W B S M | Kreuzotter | Adder | plausibel; ob das Modell eine Rassel trägt, ist ungesehen |
| `animalCoyote` | Kojote | B S | Verwilderter Hund | Feral Dog | Tier der Neuen Welt — **in den Gruppen durch den Wolf ersetzt** (WP5.4) |
| `animalMountainLion` | Berglöwe | S H | Luchs | Lynx | Tier der Neuen Welt, als Luchs zu groß — **in den Gruppen durch den Wolf ersetzt** (WP5.4) |
| `animalDireWolf` | Schreckenswolf | W B S H M | Altwolf | Elder Wolf | plausibel |
| `animalZombieDog` | Zombie-Hund | W B S H M | Seuchenhund | Plague Hound | Wort aus D74 |
| `animalZombieBear` | Zombie-Bär | M | Seuchenbär | Plague Bear | — |
| `animalZombieBoar` | Zombie-Wildschwein | — | Seucheneber | Plague Boar | steht in einer Gruppe |
| `animalZombieVulture` | Zombie-Geier | B S M | Seuchengeier | Plague Vulture | Geier in Europa belegt; Stufe `Radiated` vorhanden |
| `animalBossGrace` | Grace | — | Die Alte Bache | The Old Sow | Boss-Eber, zwei Gruppen |
| `animalBeeSwarm` | Bienenschwarm | — | Bienenschwarm | Bee Swarm | in keiner Gruppe |
| `animalInsectSwarm` | Insektenschwarm | — | Mückenschwarm | Midge Swarm | in keiner Gruppe |
| `animalChickenHostile` | Mordhuhn | — | Tolles Huhn | Mad Hen | in keiner Gruppe; ein Scherz Vanillas — der Name muss nur nicht stören |

**Kojote und Berglöwe:** D101 gibt ihnen Namen, Prüfung 0002 §8 Nr. 7 nimmt sie aus den Gruppen.
Beides gilt nebeneinander: der Name steht, falls ein Ort oder Auftrag das Tier noch ruft; in den
vier Landschaftsgruppen (`EnemyAnimalsBurntForestNight`, `EnemyAnimalsDesert`,
`EnemyAnimalsDesertNight`, `EnemyAnimalsSnow`) steht an ihrer Stelle `animalWolf`.

Auerochse und andere neue Tiere: Phase 3, brauchen Assets.

## 5. Sagengestalten — mit gemessener Vanilla-Basis (D11: wenige, selten)

| Sagengestalt | Basis (gemessen) | Wo sie heute steht | Was Phase 2 daraus macht (WP5.5) |
|---|---|---|---|
| **Nachzehrer** — der Tote, der aus dem Grab heraus die Lebenden auszehrt | `zombieWight*` — nur in Stufen (F R C I), 835 Gruppeneinträge | in vier Landschaftsgruppen mit kleinem Gewicht (0,05 bis 2): Orte und Moorland | Name und Text; zäh, heilt sich (Stufe `Radiated` tut das schon). „Frisst Leichen" ist ohne Code nicht belegt — offen |
| **Schreiende** — Klageweib, ruft die Toten herbei | `zombieScreamer` (F R C), 7 Gruppen | in keiner Landschaftsgruppe — kommt über die Hitze-Karte (D64) | Name und Text. Ist unsere einzige weibliche Sagengestalt und **kein** Hexenbild (D109) |
| **Moorleiche** — Wiedergänger aus dem Sumpf | `zombieMutated` (F R C I), 346 Gruppeneinträge; Unterbau `EntityZombieCop` (speit) | **nur** im Moorland, in allen fünf Fassungen | Name und Text. Der Hinterhalt aus Wasser ist ohne Code nicht belegt — offen (Prüfung 0003 W-25 ist damit gelöst: eine Gestalt, ein Ort) |
| **Spuk-Hund** — der schwarze Hund als Todesbote | `animalZombieDog` ist **häufig** (88 Gruppen, alle fünf Landschaften) und heißt darum Seuchenhund | — | eine **eigene, seltene** Variante auf demselben Modell (~~dunkel getönt~~, nur nachts und in der Seuchennacht). **Gebaut mit WP5.5 (D150):** `ent700_spukhund` — „Spukhund" / „Phantom Hound", 400 Lebenspunkte, Größe 1,2, fahler Schimmer (`col700_spuk`); in `ZombiesNight` (0,03) und `ZombiesWastelandNight` (0,1). **Abdunkeln geht in XML nicht:** `MatColor` ist eine Leuchtfarbe, keine Tönung — der schwarze Hund der Sage braucht ein eigenes Material (WP4.7). Die Seuchennacht folgt mit WP5.6 |
| **Irrlicht** — Licht im Moor, das in die Irre führt | Flug-Logik von `animalZombieVulture` (`EntityVulture`, 133 Gruppen) | Brandland, Sandheide, Moorland | **nicht in WP5:** braucht ein Licht am Wesen (Asset oder Partikel) — WP7 |

Gegenmittel liefert F-15 (Bannrune, Lichtfunke, Totensegen) über Entity-Tags und Buff-Bedingungen.

## 6. Spawn-Mix je Landschaft

Gemessen an `spawning.xml` (57 Zeilen, 29 Gruppen). „Offen" = ohne Orts-Marke; „Ort" = Zeilen mit
`commercial`, `industrial` oder `downtown`. `max` ist die Zahl gleichzeitig lebender Wesen je Zeile.

| Landschaft | Offen, Tag | Offen, Nacht | Eigene Klassen | Wild | Raubtiere |
|---|---|---|---|---|---|
| **Klosterland** `pine_forest` | `ZombiesAll` (max 1) | `ZombiesNight` (max 1) | — | Hase, Huhn; nachts Hirschkuh, Hirsch | nachts Kreuzotter, Wildschwein |
| **Brandland** `burnt_forest` | `ZombiesBurntForest`, `ZombiesAll` (je max 1) | `ZombiesBurntForestNight`, `ZombiesNight` | Verbrannter, Kriecher | Hase, Huhn; nachts Hirschkuh, Hirsch | Kreuzotter, Wildschwein; nachts Kojote → **Wolf**, Seuchengeier |
| **Sandheide** `desert` | `ZombiesDesert`, `ZombiesAll` | `ZombiesDesertNight`, `ZombiesNight` (max 2) | Hirte, Köhler, Pilger, Kriecher → nach WP5.4 ohne den Pilger | Hase, Huhn | Kojote → **Wolf**, Kreuzotter, Seuchengeier; nachts Wildschwein, Wolf, Berglöwe → **Wolf** |
| **Winterhöhen** `snow` | `ZombiesSnow`, `ZombiesAll` | `ZombiesSnowNight`, `ZombiesNight` (max 2) | Felswerfer (alle fünf Fassungen bei Nacht), Köhler, Holzfäller | Hase, Huhn; nachts Hirsch | Berglöwe → **Wolf**, Wolf, Bär, Jungbär; nachts Altwolf, Seuchenhund |
| **Moorland** `wasteland` | `ZombiesWasteland`, `ZombiesAllWasteland` | `ZombiesWastelandNight` (max 2) | Moorleiche (alle fünf Fassungen), Büttel, Aussätziger, Nachzehrer | Hase, Huhn; nachts Hirsch | Kreuzotter, Seuchengeier, Seuchenhund, Seuchenbär, Altwolf |

Was WP5.4 **nicht** anfasst: `maxcount`, `respawndelay` und die Gewichte der verbleibenden Einträge
— der Takt der Welt bleibt Vanillas (im Moorland rücken die Toten nachts um Größenordnungen
schneller nach als anderswo, `konzept/biome.md` §1.7). Die Ortszeilen bleiben stehen; ob es nach
WP6 noch Orte mit diesen Marken gibt, entscheidet F-07.

**Spielstufe:** die Landschaftsgruppen kennen keine Spielstufe — sie mischen Grundklasse und
`Feral` fest. Die Staffel nach Spielstufe liegt in `gamestages.xml` (Horden, Schläfer in Orten) und
gehört zu F-09 und WP5.6.

## 7. Frauen und Männer (D109)

Sieben der 36 Grundnamen sind Frauen: Magd, Bäuerin, Weberin, Siechenmagd, Schankmagd, Muhme und
die Schreiende. Mehr lässt Vanillas Bestand nicht zu — das Geschlecht steckt im Modell. Nach WP5.4
stehen in `ZombiesAll` drei Frauen unter elf Einträgen (vorher fünf unter zwanzig). Neue Figuren
(Phase 3) werden paarweise geplant: zu jedem Stand eine Frau und ein Mann.

## 8. „Mehr Gefahr für Spieler" (D29, zweite Hälfte)

Besitzer ist die **Voreinstellung „700"** (D112, `konzept/voreinstellung-700.md`), nicht dieses
Dokument: F-06 ändert in Phase 2 **keinen** Schadens- und keinen Lebenswert. Der Blockschaden bleibt
Vanillas (D65). ~~Blockschaden reduziert, Spielerschaden erhöht (D29, siehe F-18)~~.

## 9. Seuchennacht (WP5.6, für F-09)

F-06 stellt Gruppen bereit, F-09 hängt sie ein: **Brecher** (Kandidaten: Berstender, Büttel,
~~Krieger~~ — wer wirklich am stärksten auf Blöcke wirkt, misst WP5.6 an den Klassen), **Anführer**
(Nachzehrer, Schreiende) und der **Spuk-Hund** als seltener Jäger. Nichts davon ändert in Phase 2 die Staffel
aus `gamestages.xml`.

**Gemessen mit WP5.6** (Schaden an Blöcken am Hand-Gegenstand, `DamageBlock`; alle Klassen der 322
Gruppen `feralHordeStageGS*` von Vanillas Horde): Berstender 500 (und er birst); jede Klasse der
Stufe `Infernal` 250; **Büttel und Muhme** 100, verderbt und schwärend 200; **Hirte** und
**Felswerfer** 100 / 200; **Moorleiche** 100 / 140 / 180 / 200. Der **Krieger** schlägt nur 40 —
er ist kein Brecher. Zum Vergleich: Knecht 8, Magd 7, Holzfäller 20.

**Gebaut (D151), von niemandem gerufen:** fünf Gruppen in `mod/700_65_Wesen/Config/entitygroups.xml`:

| Gruppe | Inhalt | für |
|---|---|---|
| `eg700_brecherFrueh` | Büttel, Muhme, Hirte, Moorleiche, Felswerfer (Grundfassung) | frühe Seuchennächte |
| `eg700_brecherMittel` | dieselben verderbt und schwärend, selten der Berstende | mittlere |
| `eg700_brecherSpaet` | dieselben verdammt, Moorleiche auch glutäugig, der Berstende häufiger | späte |
| `eg700_anfuehrerFrueh` | Verderbter Nachzehrer, Spukhund, Schreiende | frühe |
| `eg700_anfuehrerSpaet` | Nachzehrer schwärend, glutäugig, verdammt; Spukhund; Schreiende verderbt, schwärend | späte |

Hawaiihemd und Bowler schlagen wie der Büttel, stehen aber nicht darin — sie sind aus der freien
Landschaft genommen (D149). Die Gewichte sind Setzungen (N-96); **welche Gruppe ab welcher
Spielstufe ruft, entscheidet F-09 beim Einbau (WP11).**

## 10. Grusel-Verhalten (D12, Details in F-17 B6)

Totsteller (liegende Leichen in Orten, die aufstehen), Pirscher (folgt auf Abstand im Nebel),
Lauscher (reagiert stark auf Geräusche). Seuchentote sind leiser als Vanilla-Zombies (D74, gebaut).

## Umsetzung

Alles XML (P5) — kein C#, kein Asset:

| Schritt | Datei | Was |
|---|---|---|
| WP5.3 Namen | `mod/700_90_Sprache/Config/Localization.csv`; `tools/check/vanilla-keys.txt` | 155 + 21 Sprachzeilen unter Vanillas Schlüsseln (der Schlüssel ist die Klasse), DE und EN; jede Zeile mit Begründung in der Schlüsselliste |
| WP5.4 Gruppen — **gebaut** (D149) | `tools/check/denylist.txt` (elf Wesenregeln) → erzeugt `mod/700_10_Purge/Config/entitygroups.xml`; `mod/700_65_Wesen/Config/entitygroups.xml` (neues Modlet nach Vertrag 01, Nachtrag Phase 2: die Nachrücker) | die neun Klassen aus zehn Landschaftsgruppen; Kojote und Berglöwe durch den Wolf; elf Wesenregeln. Vanilla-Klassen werden nie entfernt, nur ihr Eintrag in einer Gruppe; keine Gruppe wird leer (Vertrag 03, Nachtrag Teil C) |
| WP5.5 Sagengestalten — **gebaut** (D150) | `mod/700_65_Wesen/Config/entityclasses.xml`, `entitygroups.xml`, eine Sprachzeile, eine Glossarzeile | Spukhund als eigene Klasse `ent700_spukhund` auf Vanillas Modell. Nachzehrer, Schreiende und Moorleiche haben ihre Namen seit WP5.3; mehr als den Namen gibt XML für sie nicht her, ohne Verhalten zu erfinden. Stufen an den Klassen gemessen (§2) |
| WP5.6 Seuchennacht — **gebaut** (D151) | `mod/700_65_Wesen/Config/entitygroups.xml` | fünf Gruppen `eg700_…` für Brecher und Anführer (§9), noch von niemandem gerufen |

**Warum kein C#?** Namen, Gruppen und Varianten sind in Vanilla Daten. Was Code bräuchte — Leichen
fressen, Hinterhalt aus dem Wasser, ein Licht, das lockt —, steht oben als offen und wird nicht in
Phase 2 gebaut.

**Aussehen:** ~~Retexturen der Vanilla-Zombies sind der Hauptweg (Kittel, Kutte, Wollmantel statt
Jeans und Uniform)~~ — ob ein eigenes Material auf Vanillas Figur trägt, zeigt erst S-25 (Finding
`F-16-asset-referenzen.md`: der Weg über `AltMats`/`SwapMats` ist gelesen, nicht gesehen). Bis dahin
gilt: Namen und Gruppen jetzt, Aussehen nach dem Durchstich.

## Notizen für spätere Phasen (D50 — nicht bauen)

- **Varianten je Kulturzone** (D40, D43): Mönche und Pilger im Klosterland, Krieger im Burgwall,
  Fischer und Seeleute an der Küste — über Materialien derselben Figuren oder eigene Netze.
- **Leitfiguren mit eigenem Netz:** Seuchenmönch, gefallener Krieger im Kettenhemd.
- **Auerochse**, Fischer, Mönch als neue Grundklassen.
- **Nachzehrer frisst Leichen; Moorleiche steigt aus dem Wasser; Irrlicht lockt** — brauchen Code
  oder Assets.

## Akzeptanzkriterien
- [ ] Keine Gegnerbezeichnung mit modernem Bezug im Spiel — geprüft: jede der 155 + 21 Klassen hat
      eine Zeile in unserer Sprachdatei (WP5.3)
- [ ] Keine der neun Klassen aus §3.1 und weder Kojote noch Berglöwe in einer Landschaftsgruppe —
      Prüfung *wesen* grün (WP5.4)
- [ ] Spawn-Mix je Landschaft dokumentiert (§6) und nach WP5.4 nachgemessen
- [ ] Keine Landschaftsgruppe mit weniger als drei Einträgen, die vorher drei oder mehr hatte
- [ ] Im Spiel gesehen: eine Stunde im Startgebiet bei Tag (T2, WP5.7)

## Offen — für den Nutzer (N-67)

1. Die 36 + 20 Namen, deutsch und englisch (§3, §4), und die vier Stufennamen (§2, D100).
2. Die Trennung „neun heraus, sechs bleiben" (§3.1) — oder alle fünfzehn heraus, dann werden
   `ZombiesWasteland` und `ZombiesSnow` dünn.
3. Kojote und Berglöwe: Name **und** Ersatz durch den Wolf (§4).
4. Der Nachzehrer auf `zombieWight`, die Moorleiche auf `zombieMutated` (§5).
5. Felswerfer, Springer, Berstender: reine Rollennamen statt Stand und Beruf — in Ordnung?
