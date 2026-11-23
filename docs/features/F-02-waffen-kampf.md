# F-02 — Waffen & Kampf

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1: Waffen, Qualität, Verschleiß · 2: Schild, Schadensarten, Werfen | X+H (+A) | S+C | ja |

> **Konzept (Nachtlauf 2026-11-22, zu prüfen durch den Nutzer, D126):**
> [`docs/konzept/waffen.md`](../konzept/waffen.md) arbeitet die Waffen vom Vorbild her aus — 34
> Steckbriefe (Vorbild, Erscheinung für den Modellbau, Namen, Texte DE/EN), ein eigener Abschnitt
> zu Schwertern (Sax-Familie, Spatha, wurmbunte Klinge, Scheide, Schwert als Statuszeichen), 29
> Brüche im heutigen Sortiment, eine Stückliste für F-16 und 22 Empfehlungen (E-01 bis E-22).
> Dieses Dokument ist dadurch **nicht** geändert; gebaut sind aus dem Konzept nur Texte für
> Gegenstände, die bisher Vanillas Namen oder keine Beschreibung trugen (D129).

## Ziel
**Vanilla+** (D20): Die vertraute Vanilla-Steuerung (Hieb, Power-Attack) bleibt, ergänzt um
Schild-Blocken, Schadensarten, Verschleiß und Wurfwaffen (D21). Nahkampf ist die Basis;
**Fernkampf (Jäger) und Kampfmagie (Runenkundiger) sind gleichwertige Spezialisierungen** (D22).

## Waffen
**Nahkampf:**
| Waffe | Schadensart | Rolle | Vanilla-Basis |
|---|---|---|---|
| Knüppel / Keule | Wucht | T0, Betäubung | Club |
| Handbeil / Bartaxt | Schnitt | T0–T2, Werkzeug + Waffe | Axe; die Bartaxt seit D88 auf der Fireaxe |
| Sax (Kurzschwert) | Schnitt/Stich | T1–T2, schnell | Machete/Knife |
| Speer / Ango | Stich | T1–T3, Reichweite | Spear |
| Spatha | Schnitt | T3–T4, Allrounder | Machete (Phase 1), neues Modell (Phase 2) |
| Breitaxt | Schnitt/Wucht | T3–T4, schwer, Rüstungsbrecher — ~~widerspricht den gemessenen Zahlen~~ seit D88 auf der stärkeren Basis, siehe unten | Steel Axe (D88; bis 2026-11-22 Fireaxe) |
| Streitkolben / Hammer | Wucht | T3–T4, gegen Rüstung (Kultisten, Plünderer) | Sledgehammer |

**Die Liste ist nicht abgeschlossen** (Grundsatz des Nutzers, 2026-11-22, D88): je Kategorie
können weitere Waffen dazukommen, auch ganz neue Waffentypen. Neue Modelle sind Phase 2 (D3,
D50); bis dahin entsteht eine weitere Waffe nur auf einer Vanilla-Basis.

**Breitaxt und Bartaxt tauschen ihre Vanilla-Basis** (D88, 2026-11-22): Breitaxt auf der
Stahlaxt (`meleeToolAxeT2SteelAxe`), Bartaxt auf der Feuerwehraxt
(`meleeToolAxeT1IronFireaxe`). **Gebaut am 2026-11-22:** Namen und Rezepte sind getauscht,
Werte und Freischaltstufen (Bartaxt ab Handwerksstufe 11, Breitaxt ab 26) bleiben Vanillas;
im Spiel gesehen ist es nicht. Die Messtabelle weiter unten zeigt den Stand **vor** dem
Tausch und bleibt als Begründung stehen.

**Fernkampf** (D87 und D91, 2026-11-22) — Namen gebaut, Werte sind Vanillas:

| 700-Waffe | Vanilla-Kennung | Vanilla-Name |
|---|---|---|
| Langbogen | `gunBowT3CompoundBow` | Compoundbogen |
| Armbrust | `gunBowT1IronCrossbow` | Eiserne Armbrust |
| Schwere Armbrust | `gunBowT3CompoundCrossbow` | Compoundarmbrust |
| Panzerbrecherpfeil | `ammoArrowSteelAP` | Stahlpfeil |
| Panzerbrecherbolzen | `ammoCrossbowBoltSteelAP` | Stahlbolzen |
| Feuertopfpfeil | `ammoArrowExploding` | Sprengpfeil |
| Feuertopfbolzen | `ammoCrossbowBoltExploding` | Sprengbolzen |

Dazu die zwei Lehrblatt-Texte, die diese Munition freischalten (`perkRangersAPAmmo*`,
`perkRangersExplodingBolts*`). **Offen in WP5.2:** (1) *Reparatur* — Holzbogen, Langbogen und
beide Armbrüste verlangen das gesperrte `resourceRepairKit` und sind damit nicht zu flicken;
der Nutzer will dafür ein eigenes Reparaturzeug für Bögen und Armbrüste. **Gebaut im
Nachtlauf vom 2026-11-22 als „Bogenzeug" (`itm700_bogenzeug`), Name, Rezept und Zahlen zu
prüfen durch den Nutzer** (Plan-0001, offene Punkte). (2) *Wirkung des Feuertopfs* — Vanilla lässt den Pfeil
explodieren; ob er stattdessen oder zusätzlich brennen soll, ist eine Balancing-Frage (WP9).
(3) Der einfache Bogen und der Holzbogen tragen weiter Vanillas Namen; die Tabelle unten
nennt „Selbstbogen". (4) Die Schleuder (T0) hat keine Vanilla-Grundlage.

**Die Vanilla-Basen, gemessen an V 3.40 (WP5, 8. November 2026).** Die Spalte oben nennt
Modellfamilien; das sind die wirklichen Kennungen, und zwei davon hatte WP3 gesperrt:

| 700-Waffe | Vanilla-Kennung | Stand nach WP3 |
|---|---|---|
| Keule | `meleeWpnClubT0WoodenClub` | frei |
| Streitkolben | `meleeWpnClubT3SteelClub` | frei (D55: Stahl als Werkstoff bleibt) |
| ~~Handbeil~~ **Breitaxt** (D88) | `meleeToolAxeT2SteelAxe` | frei |
| Sax | `meleeWpnBladeT1HuntingKnife` | frei |
| Knochenmesser (T0) | `meleeWpnBladeT0BoneKnife` | frei |
| Speer | `meleeWpnSpearT0/T1/T3*` | frei, drei Stufen |
| Vorschlaghammer | `meleeWpnSledgeT0/T1/T3*` | frei, drei Stufen |
| **Spatha** | `meleeWpnBladeT3Machete*` | **war gesperrt → freigegeben (D58)** |
| ~~Breitaxt~~ **Bartaxt** (D88) | `meleeToolAxeT1IronFireaxe` | **war gesperrt → freigegeben (D58)** |

**Die Zahlen dazu stehen in der Balancing-Tabelle (WP5.6, 8. November 2026):**
[0001-wp5-waffen-ruestung-und-kosten.md](../balancing/0001-wp5-waffen-ruestung-und-kosten.md) —
eine Zeile je Waffe mit Schaden, Block, Hieben pro Minute, Ausdauer, Reichweite, Haltbarkeit
und dem Erz, das sie kostet. Vanillas Staffelung trägt: Schaden je Sekunde geht von 10–15 (T0)
über 16–24 (T1) auf 27–32 (T3). **Mit einer Ausnahme, und die ist die Breitaxt:**

| | Breitaxt | Bartaxt | Spatha |
|---|---|---|---|
| Vanilla-Stufe | **T1** | T2 | T3 |
| Schaden (Qualität 1) | **15** | 29 | 25 |
| Schaden je Sekunde | **16,3** | 26,6 | 27,1 |
| Erz-Äquivalent des Rezepts | **400** | 100 | 50 |

Die Breitaxt soll „T3–T4, schwer, Rüstungsbrecher" sein und ist gemessen die **schwächste
Waffe des Satzes über T0** — bei der höchsten Erzrechnung nach Flügellanze und Streithammer.
Die Bartaxt, die hier bei T0–T2 steht, schlägt sie um fast das Doppelte. Drei Wege stehen in
der Balancing-Tabelle §2.1; die Empfehlung ist der **Tausch der beiden Vanilla-Basen** (Breitaxt
← Stahlaxt, Bartaxt ← Feuerwehraxt), weil er keine erfundene Zahl kostet. **Die Entscheidung
gehört dem Nutzer, weil sie an D58 und an der Tabelle oben hängt.**

Zweiter Befund derselben Messung: **beide Äxte sind in Vanillas Buchführung Werkzeuge**
(`tool`, `perkMiner69r`, `harvestingSkill`), keine Waffen. Wer mit der Breitaxt kämpft,
steigert seine Bergbau-Fertigkeit, und die Kampf-Perks greifen an ihr nicht. Das zu ändern
heißt `Tags` zu bearbeiten und gehört zu **F-21 in WP7**, wo der Fertigkeitsbaum entsteht.

Und: **T4 ist auch bei den Waffen eine Qualität, keine Stufe.** Vanillas höchste Nahkampfstufe
ist T3; „T3–T4" in der Tabelle oben kann nur denselben Gegenstand auf höherer
Handwerksqualität meinen (Streithammer auf Qualität 6: 82,5 statt 55 Schaden). Dieselbe
Einsicht wie **D61** bei der Rüstung.

Gemessen hat Vanilla **kein** weiteres Klingenmodell über Messerlänge und keine zweite lange
Axt: `meleeWpnBlade*` kennt nur Knochenmesser, Jagdmesser, Zuckerstangen-Messer (Event) und
Machete, `meleeToolAxe*` nur Feuerwehraxt, Stahlaxt und Kettensäge. Darum D58 — umdeuten statt
sperren, wie D54 bei den Bögen. Dauerhaft gesperrt bleiben Baseballschläger, die beiden
Event-Zuckerwaffen, Schlagstöcke und Kettensäge.

`meleeWpnBatonT3PlasmaBaton` ist **in Vanilla unerreichbar** (null Treffer in `recipes.xml`,
`loot.xml`, `traders.xml`, `quests.xml`, `entityclasses.xml`, `blocks.xml`) und darum weder in
den Fehlern noch in den Patches sichtbar. Über das Kreativmenü bleibt er erreichbar — wie bei
jedem unerreichbaren Gegenstand ist `CreativeMode` keine Sperre für den Spieler.

**Fernkampf:** Schleuder (T0), Selbstbogen (T1), Langbogen (T3), Armbrust (T4, selten, D8).
Munition: Pfeile (Feuerstein, Knochen, Eisen), Bolzen, Schleudersteine.

**Wurfwaffen (D21):** Wurfaxt, Wurfspeer, Wurfmesser. Sie werden geworfen und müssen
**aufgehoben** werden (bleiben im Ziel bzw. am Boden stecken).

## Mechaniken (D21)

| Mechanik | Beschreibung | Tiefe | Phase |
|---|---|---|---|
| **Qualität** (D23) | **Material** = Grundstufe (Knochen < Bronze < Schmiedeeisen < Stahl < Damast); **Handwerksqualität** = Feinstufe (Vanilla-Qualität 1–6 umbenannt: grob, einfach, solide, gut, meisterlich, legendär), steigt durch Learning by Doing (F-21) | X | 1 |
| **Verschleiß & Reparatur** | Vanilla-Haltbarkeit stärker gewichtet; Reparatur mit Schleifstein (einfach, ~~verliert Maximal-Haltbarkeit~~ repariert nur teilweise) oder beim Schmied bzw. an der Esse (voll) | X (+H) | 1 (Verlust an Maximal-Haltbarkeit: 2, **D60**) |
| **Schadensarten** | Schnitt (stark gegen ungeschützt, schwach gegen Kette), Stich (gegen Kette und Gambeson), Wucht (gegen schwere Rüstung, Betäubung). Gegner und Rüstungen tragen Schutzwerte je Art | X+H | 2 |
| **Schild blocken** | Rundschild als Offhand mit aktivem Blocken: Schaden und Stagger von vorn reduziert, Ausdauerkosten; Schild verschleißt | H | 2 |
| **Werfen** | Wurfwaffen als Projektil, das als aufhebbares Item liegen bleibt | X (+H) | 2 |

**Verschleiß, wie er in Phase 1 wirklich gebaut wird (D60, 8. November 2026).** Gemessen kennt
Vanilla an Reparatur nur `RepairTools` (welcher Gegenstand repariert), `RepairAmount` (wie viel
Haltbarkeit er zurückgibt), `RepairTime` und die `Degradation*`-Werte. **Einen Verlust an
Maximal-Haltbarkeit gibt es nicht** — Vanillas `resourceRepairKit` hat `RepairAmount="32000"`
und damit immer volle Reparatur. Daraus folgt für Phase 1, ohne Patch:

| Gegenstand | herstellbar | `RepairAmount` | Wirkung |
|---|---|---|---|
| **Schleifstein** | überall | klein | repariert nur teilweise, mehrere Steine je Instandsetzung |
| **Schmiedeflicken** | **nur an der Esse** | voll | volle Reparatur — „beim Schmied" ist das Rezept, nicht der Vorgang |
| **Nähzeug** (D62) | überall | voll | flickt, was nicht aus Eisen ist: T0, T1 und T2 der Rüstung. Vanillas `resourceSewingKit`, in WP5.5 um Rezept und `RepairAmount` ergänzt |

Alle drei ersetzen `resourceRepairKit`, das genau dafür zu WP5 aufgeschoben war
(`tools/check/aufschub.txt`). **Gezählt, nicht geschätzt:** 23 erlaubte Gegenstände zeigten auf
das Kit, 13 sind umgehängt (8 Waffen in WP5.4, 5 Rüstungsklassen in WP5.5), **10 sind offen** —
vier Bögen (WP5.2), fünf Werkzeuge (F-05, kein Paket der Phase 1) und `partsMaster` (WP7). Eine
Prüfung, die „erlaubter Gegenstand repariert mit gesperrtem Werkzeug" selbst findet, gibt es
**nicht**; die zehn sind von Hand gezählt und als offener Punkt in Vertrag 04 vermerkt.
**Stand nach dem Nachtlauf vom 2026-11-22 (zu prüfen durch den Nutzer): 23 von 23.** Die vier
Bögen flicken mit dem Bogenzeug, die fünf Werkzeuge mit Schleifstein oder Schmiedeflicken,
`partsMaster` mit dem Schmiedeflicken; das Reparatur-Kit selbst ist damit vom Purge gesperrt
(Plan-0001, offene Punkte; Vertrag 04, Nachtrag Leermeldung). Der Verlust an Maximal-Haltbarkeit wandert nach **Phase 2** und
bekommt dort Finding und Eintrag im Patch-Manifest; D21 bleibt gültig, D60 verfeinert es nur.

**Die Handwerksqualität ist eine Sprachdatei-Arbeit, kein Patch.** Vanilla liest die sieben
Stufennamen über `QualityInfo::GetQualityLevelName` aus den Schlüsseln `lblQualityBroken`,
`lblQualityDamaged`, `lblQualityPoor`, `lblQualityAverage`, `lblQualityGreat`,
`lblQualityFlawless`, `lblQualityLegendary`. `qualityinfo.xml` enthält nur Farben, die Namen
stehen dort als Kommentar. Beleg und Grenzen:
[WP5-qualitaetsnamen-sind-sprachschluessel.md](../rea/findings/WP5-qualitaetsnamen-sind-sprachschluessel.md).
Die **Materialstufe** aus D23 hat in Vanilla kein Gegenstück und entsteht über getrennte
Gegenstände und ihre Namen.

Furcht (F-17 B3, D14) wirkt vor allem auf Fernkampf (Zittern) und Zauber, kaum auf den Nahkampf.

## Ausarbeitung Phase 2 (Plan-0002 WP12.1, 2026-11-23, D192, zu prüfen N-136)

Alle Zahlen sind **Setzungen** für das Balancing (WP14.3), im Spiel ungesehen.

### 1. Schadensarten über Vanillas Marken (XML, WP12.4)

**Gemessen** an Vanillas `items.xml` und `entityclasses.xml` (V 3.40 b10):

- Vanilla kennt die vier Arten als Eigenschaft `Damage_type` (`Piercing`, `Slashing`, `Bashing`; im
  Code dazu `Crushing`, Kurz-Check Prio 9) — aber nur an Geschossen und Wurfsachen, nicht an
  Nahkampfwaffen. Einen **Schutz je Art** gibt es in XML nicht: Vanilla hat ihn selbst auskommentiert
  (`PiercingProtection`, Vermerk „Not supported at this time", `items.xml` am `ammo9mmBulletHP`).
- **Was trägt: Schutz je Marke der Waffe.** `PhysicalDamageResist` nimmt `tags`; Vanilla nutzt das am
  Insektenschwarm (`animalInsectSwarm`: 75 gegen alles außer `ranged`, 99 gegen `ranged`). Die Marken
  stehen schon an den Waffen: `bladeSkill` (5), `axe` (4), `knife` (3), `spearSkill` (4), `clubSkill`
  (5), `sledgeSkill` (4), `bowSkill` (6), `crossbow` (2) — und die **Hände der Seuchentoten** tragen
  `blunt,melee,light` (`meleeHandMaster`).

Daraus die Zuordnung, ohne neue Marke:

| Art | Marken der Quelle | Waffen bei uns |
|---|---|---|
| **Schnitt** | `bladeSkill`, `axe`, `knife` | Sax, Spatha, Beile, Messer |
| **Stich** | `spearSkill`, `bowSkill`, `crossbow` | Ger, Flügellanze, Pfeile, Bolzen |
| **Wucht** | `clubSkill`, `sledgeSkill`, `blunt` | Keulen, Hämmer, Faustwehr — **und jeder Schlag eines Seuchentoten** |

**Schutz je Art, zusätzlich zu Vanillas `PhysicalDamageResist`** (Prozentpunkte für die **ganze**
Garnitur, auf die Teile verteilt wie Vanillas Grundwert):

| Rüstung (F-03) | gegen Schnitt | gegen Stich | gegen Wucht | Gedanke |
|---|---|---|---|---|
| T0 Lumpen | 0 | 0 | 0 | — |
| T1 Wolle und Leder | +3 | 0 | +3 | gibt T1 endlich mehr als einen Set-Bonus (F-03, Balancing 0001 §4) |
| T2 Gambeson | +5 | +5 | **+12** | Stepparbeit fängt Schläge — gut gegen Seuchentote |
| T3 Kettenzeug | **+15** | −5 | +3 | Ringe halten die Schneide, nicht die Spitze |

| Gegner (F-06) | gegen Schnitt | gegen Stich | gegen Wucht | Gedanke |
|---|---|---|---|---|
| gewöhnliche Seuchentote | +0 | +0 | +0 | ungeschützt — Schnitt ist so gut wie alles |
| Seuchentoter Krieger (`zombieSoldier`) | +15 | −5 | 0 | trägt Kette wie T3 |
| Brecher (WP5.6: Büttel, Muhme, Hirte, Felswerfer, Moorleiche) | 0 | 0 | +10 | schwer, die Keule prallt ab |
| Kriecher | −10 | 0 | +10 | weich und am Boden: schneiden ja, schlagen kaum |

**Bauweg (WP12.4):** je Zeile ein `<append>` mit `passive_effect name="PhysicalDamageResist"
operation="base_add" tags="…"` an der Rüstungsklasse bzw. Wesenklasse. Kein C#.
**[verifizieren, Spieltest mit WP12.4]:** (1) ob Schutz an **getragener** Rüstung die Marken der
**angreifenden** Waffe sieht wie Vanillas Schwarm — sonst geht die Hälfte (Rüstung) nur per Patch, die
andere (Gegner) bleibt XML; (2) ob unsere Waffen die Marken über `Extends` erben.

### 2. Der Schild

**Werte** (für beide Wege unten gleich, wo sie greifen):

| Wert | Rundschild (Holz, T1) | Beschlagener Schild (T2) | Grund |
|---|---|---|---|
| Winkel | 120° von vorn (±60°) | 120° | wer flankiert, trifft |
| Minderung Nahkampf | 70 % | 80 % | der Schild fängt, nicht der Arm |
| Minderung Fernkampf | 50 % | 60 % | Pfeile treffen auch Kanten |
| Ausdauer je geblocktem Treffer | 12 | 10 | Vanilla-Ausdauer 100: acht bis zehn Treffer, dann sinkt der Arm |
| ohne Ausdauer | kein Block | kein Block | |
| Verschleiß | −1 Haltbarkeit je 10 abgefangene Punkte | dasselbe | |
| Haltbarkeit | 300 | 600 | Reparatur Nähzeug bzw. Schmiedeflicken (D60, D62) |
| erhoben | Gehen −30 %, kein Sprint, kein Schlag | dasselbe | Haltung, nicht Zauber |

**Zwei Wege — und ein Widerspruch, den du entscheiden musst (N-136 (1)):** das GDD (§5 Phase 2) und
P2-E22 legen den Schild in **Phase 2**, die Triage (D172, zu prüfen) legt den Patch nach **Phase 3**,
damit Phase 2 ohne Harmony bleibt. Beides gilt nicht zugleich.

| Weg | was | geht | Kosten |
|---|---|---|---|
| **A — XML, ohne Richtung** | der Schild ist ein **gehaltenes** Stück (eine zweite Hand gibt es im Code nicht, Finding WP9 §2): solange er in der Hand liegt, `PhysicalDamageResist` +25 gegen alles von **allen** Seiten, Gehen −10 %; geschlagen wird mit ihm wie mit einer schwachen Keule | Phase 2, sofort nach dem Modell (WP4) | kein Winkel, kein Erheben, keine Ausdauer je Treffer — ein „Schutzbrett", ehrlich benannt |
| **B — Patch** | Postfix auf `EntityAlive::DamageEntity` beim Besitzer des Getroffenen: Richtung gegen Blick, `cv700_schildErhoben`, Ausdauer, Verschleiß (Kurz-Check Prio 9, Finding WP9 §2) | Phase 2b (WP12.5) oder Phase 3 | der erste Harmony-Patch; Netz-Klasse S+C, Dedicated-Test |

**Empfehlung:** A in Phase 2 bauen — er ist zugleich das Verhalten bei **abgeschaltetem** Patch, das
Vertrag 06 für jeden Patch verlangt. B danach, sobald du den Patch freigibst; erst dann zählen Winkel und
Ausdauer. **[verifizieren]** für A: ob ein Buff „hält den Schild" über `HoldingItemHasTags` am Spieler
zuverlässig wirkt, auch für Fernkampfschaden.

### 3. Wurfwaffen (D21, waffen.md E-17)

| Stück | Stufe | Schaden | Reichweite | Art | liegt danach | Text-Gedanke |
|---|---|---|---|---|---|---|
| **Wurfspeer / Javelin** | T1 | 35 | 15 m | Stich | im Ziel bzw. am Boden, aufheben | der Speer des Jägers |
| **Wurfbeil / Throwing Axe** | T2 | 45 | 10 m | Schnitt | dasselbe | „das Beil der Franken" als Hörensagen; Erbstück *Franziska* nur als Fund |
| **Ango / Ango** | T3 | 70 | 12 m | Stich | dasselbe | schwerer Wurfspeer mit langem Eisenhals (E-02) |
| ~~Wurfmesser~~ | — | — | — | — | — | entfällt (E-17, P2-E22) |

Gebaut wird mit Vanillas `ItemActionThrownWeapon`, die nur am Steinspeer auskommentiert ist (Finding WP9
§3), **erst nach S-33 (4)** — trägt sie nicht, rutscht das Werfen (P2-E22). Je ein Stück im Gürtel, kein
Stapel; die Haltbarkeit sinkt je Wurf wie ein Schlag.

### 4. Verlust an Maximal-Haltbarkeit (D60, WP12.7)

Bleibt **Streichposten**: es gibt dafür in XML nichts (D60 gemessen), und ein Patch nur dafür lohnt
nicht. Der Schleifstein repariert weiter nur teilweise. **Empfehlung:** für Phase 2 streichen, in die
Rückschau (WP14.6).

## Umsetzung
### XML
Items, Rezepte, Qualitätsnamen, Haltbarkeit, Reparatur-Items, Perks (F-21 Krieger bzw. Jäger), Buffs (Blutung, Betäubt).
### C# / Harmony — Warum nicht XML?
- **Blocken:** Eingabe-Zustand + Schadensberechnung abhängig von Richtung → REA am Schadenspfad. Erst prüfen, ob ein Buff/CVar-Check im Schadenspfad reicht (P5).
- **Schadensarten:** Vanilla kennt Schadensklassen bzw. Tags [verifizieren]; falls die nicht frei erweiterbar sind, Postfix am Schadenspfad mit Tag-Tabelle.
- **Werfen und Aufheben:** prüfen, ob die Vanilla-Speer-Wurfmechanik (falls vorhanden) übertragbar ist.
- *Triage WP9.6 ([triage-phase-2.md](../rea/triage-phase-2.md) Nr. 18, 19; zu prüfen N-116):* **Werfen:
  XML reicht** — `ItemActionThrownWeapon` ist da, Vanilla hat die Zeile am Steinspeer nur
  auskommentiert (S-33 (4)). **Blocken: ein Patch, Phase 3** — Postfix auf `EntityAlive::DamageEntity`;
  warum nicht XML: die Richtung des Treffers gegen die Blickrichtung ist keine Buff-Bedingung.
### Assets
Phase 2 (D3, F-16): neue Modelle für Spatha, Sax, Rundschild, Langbogen, Armbrust, Wurfaxt; Retexturen für Keule, Beile, Speer.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-02](../rea/hook-hypothesen.md#f-02)

## Akzeptanzkriterien
- [ ] Jede Waffe ist herstellbar und hat einen klaren Zweck (Balancing-Tabelle in `docs/balancing/`)
- [ ] Material- und Handwerksqualität sind im Tooltip verständlich
- [ ] Blocken reduziert Schaden von vorn, nicht von hinten; auf Dedicated + 2 Clients
- [ ] Wurfaxt bleibt nach dem Wurf aufhebbar liegen (kein Item-Verlust durch Netz-Desync)
- [ ] Bogen-Build und Magie-Build schaffen T3-Inhalte gleich gut (Playtest)
