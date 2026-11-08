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
- Verteidigung: Palisade, Spitzpfähle, Graben, Wehrgang, Torhaus (Block-Shapes umdeutet), Fallen aus F-08 und F-15
- Blockformen: Vanilla-Shapes bleiben (P5), nur Materialien und Texturen neu (Retextur Phase 2, F-16)

## Gegner-Anpassung (D29)
- Seuchentote verursachen **deutlich weniger Blockschaden** — ~~Werte in `entityclasses.xml`~~
  **berichtigt 2026-11-08:** der normale Nahkampf-Blockschaden steht am Angriffs-*Gegenstand*
  `meleeHandZombie01` in `items.xml` (`passive_effect name="BlockDamage" base_set 100`). In
  `entityclasses.xml` steht `BlockDamage` nur an Sprengkörpern (`zombieFatCop` 500,
  `zombieDemolition` 5000) und an Fahrzeugen bzw. Geschützen;
  `passive_effect name="BlockDamage"` kommt dort **null**-mal vor. Nachweis:
  [WP6-Finding §1](../rea/findings/WP6-brenndauer-und-blockschaden.md). Angenehme Folge: die
  Sprengkörper-Werte hängen nicht daran und müssen **nicht** mitgesenkt werden — sie sind
  genau die „Brecher-Typen", die der nächste Punkt verlangt. Bei 100 Blockschaden je Schlag
  hält Mörtelstein (10 000) **100 Schläge**; das ist die Zahl, an der WP6.3 rechnet
- Ausgleich: **mehr Gefahr für Spieler** (höherer Schaden gegen Spieler, Grusel-Verhalten F-17, Sagengestalten)
- Ausnahmen: einzelne Brecher-Typen (z. B. „Rammer“) in der Seuchennacht, damit Befestigung nicht trivial wird
- Balancing-Ziel: Eine T3-Befestigung hält eine Seuchennacht der passenden Gamestage, wenn sie verteidigt wird

## Akzeptanzkriterien
- [ ] Kompletter Upgrade-Pfad T0–T4 baubar, kein Beton bzw. Stahl erhältlich
- [ ] Balancing-Test: T3-Basis übersteht verteidigt eine Seuchennacht der Gamestage X, unverteidigt nicht
