# F-18 — Bauen & Befestigung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1 | X (+A in Phase 2) | S | nein |

## Ziel
Das Vanilla-Blocksystem trägt den Basenbau weiter (D28), nur in Materialien von 700. Ohne
Stahl und Beton bleibt die Basis verteidigbar, weil die **Gegner angepasst** werden (D29).

## Upgrade-Pfad (Umdeutung)

**Gebaut und geprüft am 2026-11-08 (WP6.1).** Die Tabelle trägt jetzt die gemessenen
Kennungen und die wirklichen Kosten; die Spalte „Material" ist Absicht, die Spalte
„Aufwertung kostet" ist das, was im Spiel abgezogen wird.

| Vanilla-Block | Material (MaxDamage) | 700 | Tier | Aufwertung kostet |
|---|---|---|---|---|
| `frameShapes` | `Mwood_weak_shapes` (100) | Rahmen | T0 | 8 × `resourceWood` → Flechtwerk *(unverändert)* |
| `woodShapes` | `Mwood_shapes` (500) | Flechtwerk | T1 | 10 × `resourceCobblestones` → Fachwerk *(unverändert)* |
| `cobblestoneShapes` | `Mcobblestone_shapes` (1500) | Fachwerk | T2 | ~~10 × `resourceConcreteMix`~~ → **25 × `resourceRockSmall`** → Bruchstein |
| `concreteShapes` | `Mconcrete_shapes` (5000) | Bruchstein | T3 | ~~10 × `resourceForgedSteel`~~ → **10 × `resourceConcreteMix` (Mörtel)** → Mörtelstein |
| `steelShapes` | `Msteel_shapes` (10000) | Mörtelstein | T4 | — (oberste Stufe) |

Dazu gemessen und geändert:

- **`resourceCobblestones` bleibt die Fachwerk-Zutat, und das liest sich richtig:** Vanillas
  Rezept dafür ist **1 Lehm + 1 Stein**, also genau die Ausfachung. Die Zuordnung „Fachwerk
  auf dem Pflasterstein" ist die schwächste Stelle der Reihe und trotzdem die beste: die
  Haltbarkeit liegt zwischen Flechtwand und Steinmauer, wo Fachwerk hingehört.
- **Bruchstein wird trocken gesetzt**, darum Stein und kein Mörtel. Die 25 sind nicht
  gewürfelt: so viele Steine gibt `concreteShapes` beim Abbau selbst her.
- **Reparatur folgt derselben Logik:** Bruchstein mit `resourceRockSmall` (Vanilla:
  Betonmischung), Mörtelstein mit `resourceConcreteMix` (Vanilla: Schmiedestahl).
- **`Msteel_shapes` bekommt `damage_category="stone"`** statt `metal`. Gemörtelten Stein
  schlägt man mit der Spitzhacke. Geprüft, dass das nichts anderes trifft: jedes der fünf
  Pfad-Materialien hat in ganz `blocks.xml` **genau einen** Block, der es benutzt.
- **Mörtelstein gibt beim Abbau 20 × `resourceRockSmall`** statt 15 × `resourceScrapIron` —
  das war die letzte Stelle im Pfad, an der der Abbau verriet, dass der Block einmal Stahl war.
- **`UpgradeBlock` nimmt genau EINE Zutat** (ein `Item`, ein `ItemCount`), gemessen an allen
  neun Pfad- und Spießblöcken. Mehrstoffige Stufen brauchen darum einen Zwischengegenstand;
  hier ist das der Mörtel.

### Mörtel und Branntkalk (D63) — und der Kalkofen, der kein Erzeugnis hatte

`resourceConcreteMix`, `resourceCement`, `concreteShapes*` und `steelShapes*` standen auf der
Denylist. Damit endete der Bauweg bei Pflasterstein — **und der Kalkofen aus WP4.3 hatte kein
Erzeugnis, weil sein einziges Produkt gesperrt war.** Dieselbe Art Loch wie die vier
unbaubaren Werkstätten aus WP5.5b, nur eine Stufe weiter.

D63 deutet die vier Kennungen um statt sie zu ersetzen, und **kostet dabei keine Zeile
Rezeptarbeit**, weil Vanillas Ketten schon das Richtige tun:

| Kennung | heißt bei uns | Vanillas Rezept | liest sich als |
|---|---|---|---|
| `resourceCement` | **Branntkalk** | 10 × geschmolzener Stein, am Ofen | Kalkbrennen |
| `resourceConcreteMix` | **Mörtel** | Sand + Stein + Branntkalk, am **Kalkofen** | Kalkmörtel |

Die Denylist sank dadurch von 591 auf **587** gesperrte Kennungen, die Patchzeilen von 1810
auf **1797**, und `rezepte_mit_gesperrter_zutat` von 93 auf **92**.

**Offener Punkt, gezählt:** die Baustoffnamen stehen im Spiel **nicht** an fünf Stellen,
sondern an jeder einzelnen Form. `cobblestoneArch`, `cobblestoneBlock`, `cobblestoneCNRFull`
— jede Form hat ihren eigenen Sprachschlüssel. Gemessen in Vanillas `Localization.csv`:
**830 Schlüssel** beginnen mit einem der vier Baustoffwörter, und bei **mindestens 200** davon
ist der Rest nachweislich ein Formname aus `shapes.xml`. WP6.1 hat die **fünf
Gruppenbeschreibungen** und die **zwei Baustoffnamen** umbenannt — die Beschreibung sagt also
„Bruchstein", der Gegenstandsname noch „Beton – Block". Das ist sichtbar und nicht
weggeschwiegen. Von Hand ist das keine Arbeit, sondern ein Werkzeug; es gehört zu F-12 in WP8,
wo die Sprache ohnehin durchgesehen wird.

- Dachformen: Reet, Schindeln, Grassoden

### Wehrbauten — gebaut am 2026-11-08 (WP6.2)

Sieben waren gefordert. Was davon mit XML geht, und was nicht:

| gefordert | Träger | Stand |
|---|---|---|
| **Spitzpfähle** | `trapSpikesWoodDmg0` | **stand schon fertig** — `Damage 33`, `MaxDamage 100`, Rezept 20 Holz. Nur umbenannt |
| **Eisenspitzen** | `trapSpikesIronDmg0` | dito, `MaxDamage 200`, Aufwertung 4 Schmiedeeisen |
| **Palisade** | `logWall*`, 8 Blöcke | **Dev-Requisite, jetzt baubar.** `Mwood` (200), Abschnitt 3×4, gespitzt 3×5 |
| **Torhaus-Tor** | `doorWoodLargeGate` | Block war fertig, **Rezept fehlte**. Jetzt 100 Holz + 20 Nägel + 10 Schmiedeeisen an der Zimmermannsbank |
| **Graben** | — | **kein Block.** Ein Graben ist abgetragenes Gelände; der Spieler hebt ihn mit der Schaufel aus. Gehört zur Bauweise, nicht zum Bausatz |
| **Wehrgang** | — | **kein Block.** Eine Platte mit Brüstung oben auf der Mauer, gebaut aus den Vanilla-Formen, die WP6.1 umgedeutet hat. P5 sagt ausdrücklich, dass die Formen bleiben |
| **Schwingbalken-Falle** | — | **aufgeschoben.** Ein Pendel braucht bewegte Physik und einen Auslöser; Vanillas einzige mechanische Fallenklasse ist `BladeTrap` und hängt am Strom (gesperrt). Keine der 50 Blockklassen in V 3.40 hat ein Pendel → C#, und Phase 1 steht ohne Harmony-Patch. **F-15, Phase 2** |
| **Pechtopf** | — | **aufgeschoben.** Braucht denselben Auslöser. Was XML gibt, ist ein *brennender Platz*, und den liefert WP6.4 schon als `blk700_holzfeuer` (`BuffsWhenWalkedOn="buffBurningEnvironment"`). Ein zweiter Block mit derselben Wirkung und anderem Namen wäre Verdopplung. **F-15, Phase 2** |

**Die acht Palisadenteile hat Vanilla modelliert und nie freigegeben.** Sie liegen unter
`Entities/BanditProps`, tragen `CreativeMode="Dev"` und haben kein Rezept — Requisiten für
Banditenlager. Material `Mwood` mit `MaxDamage` **200**, also zwischen Spieß (100) und gebauter
Holzwand (500): eine Palisade ist rauer als eine Wand und hält weniger. Preise nach Größe,
50 Holz je Abschnitt (zwölf Zellen) gegen 96 Holz für dieselbe Fläche als gebaute Holzwand.

**Der einzige Eingriff ins Verhalten: die gespitzten Abschnitte tun jetzt wirklich weh.**
Vanillas `logWallLeftSpikes` hat Spitzen am Modell und **keinen** Schaden — sie sehen
gefährlich aus und sind es nicht. Gemessen: `Damage` liest die Klasse `BlockDamage` (ihr `Init`
schreibt eine Fehlerzeile, wenn der Wert fehlt), und `BlockTrunkTip` — die Klasse der Spieße —
**erbt** von `BlockDamage` und legt nur `RotateVerticesOnCollisionCheck` darauf. Wir nehmen
deshalb `Class="Damage"` und nicht `TrunkTip`: die Drehbehandlung ist für Baumstumpf-Modelle,
unsere Palisade ist eine `ModelEntity`. **15** Schaden statt der 33 eines Spießes — eine Mauer
ist keine Falle —, dazu `Damage_received 15`, damit sie sich am Angreifer abnutzt.

**Eigener `DescriptionKey` für das Tor**, weil Vanillas `doorGroupDesc` gemessen von **55**
Blöcken geteilt wird: jede Tür im Spiel. Dieselbe Falle wie bei den Öllampen in WP6.4.

- Fallen aus F-08 und F-15
- Blockformen: Vanilla-Shapes bleiben (P5), nur Materialien und Texturen neu (Retextur Phase 2, F-16)

## Gegner-Anpassung (D29 — erste Hälfte aufgehoben mit D65)

**Beschlossen am 2026-11-08: hier wird keine Zahl geändert.** Mörtelstein **ist** Vanilla-Stahl
— derselbe Block `steelShapes`, dasselbe Material, dieselben 10 000 `MaxDamage`. D29s Ziel
(„hält etwa so wie Vanilla-Stahl") steht damit durch die Zuordnung aus WP6.1, und ein Abschlag
hätte unsere Basen *stärker* gemacht als Vanillas. Die zweite Hälfte von D29 („mehr Gefahr für
Spieler", `DamageEntity`) bleibt und gehört zu F-06/F-17.

**Wie lange eine Mauer hält, gemessen** (`MaxDamage ÷ Schaden je Schlag`; die Leiter hat neun
Stufen von 7 bis 500, nicht einen Wert):

| | Flechtwerk 500 | Fachwerk 1 500 | Bruchstein 5 000 | Mörtelstein 10 000 |
|---|---|---|---|---|
| normal (8) | 63 | 188 | 625 | 1 250 |
| zäh (24) | 21 | 63 | 208 | 417 |
| aufgeladen (150) | 3 | 10 | 33 | **67** |
| höllisch (250) | 2 | 6 | 20 | **40** |
| Brecher (500) | 1 | 3 | 10 | **20** |

**Der Hebel liegt bereit, falls der Spieltest ihn braucht.** `MaterialBlock::MaxIncomingDamage`
deckelt den Schaden **je Schlag** (`FastMin` am Ende von `ItemActionAttack::GetDamageBlock`);
Vorgabe `int.MaxValue`, in ganz Vanilla genau einmal gesetzt (`MtwitchHordeStone` auf 25). Drei
Zeilen in `materials.xml` würden T2/T3/T4 decken, ohne POIs, Türen oder Sprengkörper zu
berühren — **nach WP6.7, nicht vorher.** Zahlen und die verworfenen Wege:
[Balancing WP6 §2–§3](../balancing/0002-wp6-bauen-licht-und-blockschaden.md).

**Was offen bleibt:** unser T4 braucht Stein, Lehm und Sand (146 Stein für die ganze Treppe),
Vanillas Stahl braucht Erz und Tiegel. Ist T4 früher erreichbar, verliert die Seuchennacht ihre
Zähne, ohne dass eine Zahl falsch wäre. Das zeigt nur WP6.7.

### Ursprünglicher Stand, zum Abgleich
- ~~Seuchentote verursachen **deutlich weniger Blockschaden** (Werte in `entityclasses.xml`)~~
  — **zweimal berichtigt am 2026-11-08.** Erstens die Datei: `entityclasses.xml` trägt
  `BlockDamage` nur an Sprengkörpern (`zombieFatCop` 500, `zombieDemolition` 5000) und an
  Fahrzeugen bzw. Geschützen, und `passive_effect name="BlockDamage"` kommt dort **null**-mal
  vor. Der Nahkampf-Blockschaden steht als `Action0/DamageBlock` an den ~45 Hand-Gegenständen
  in `items.xml`. Zweitens die Sache selbst: aufgehoben mit **D65**, siehe oben. Nachweise:
  [WP6-Finding §1](../rea/findings/WP6-brenndauer-und-blockschaden.md) und
  [Balancing WP6 §2](../balancing/0002-wp6-bauen-licht-und-blockschaden.md)
- Ausgleich: **mehr Gefahr für Spieler** (höherer Schaden gegen Spieler, Grusel-Verhalten F-17, Sagengestalten)
- Ausnahmen: einzelne Brecher-Typen (z. B. „Rammer“) in der Seuchennacht, damit Befestigung nicht trivial wird
- Balancing-Ziel: Eine T3-Befestigung hält eine Seuchennacht der passenden Gamestage, wenn sie verteidigt wird

## Akzeptanzkriterien
- [ ] Kompletter Upgrade-Pfad T0–T4 baubar, kein Beton bzw. Stahl erhältlich
- [ ] Balancing-Test: T3-Basis übersteht verteidigt eine Seuchennacht der Gamestage X, unverteidigt nicht
