# Balancing WP5 — Waffen, Rüstung und was sie kosten

**Stand:** 8. November 2026 · **Arbeitspaket:** Plan-0001 WP5.6 · **Features:** F-02, F-03, F-04

**Was hier steht.** Eine Zeile je Waffe und je Rüstungsstufe mit den Zahlen, die im Spiel
wirklich gelten, daneben die Rolle, die F-02 und F-03 ihnen zuschreiben. Dazu die Kosten
unserer eigenen Rezepte — **das sind die einzigen Zahlen, die WP5 selbst gesetzt hat**, und
genau darum gehören sie in eine Tabelle, in der man sie nebeneinander sieht.

**Quelle.** `Data/Config/items.xml` und `buffs.xml` der Installation (V 3.40, Build 10) sowie
unsere eigenen Rezeptdateien unter `mod/`. Reine XML-Messung, kein Spielstart.

**Was hier nicht steht.** Kein Urteil darüber, wie sich eine Waffe *anfühlt* — das entscheidet
der Spieltest (WP5.7). Und keine geänderten Zahlen: WP5.1 bis WP5.5 haben an Schaden,
Reichweite, Haltbarkeit und Ausdauer **nichts** angefasst, die Waffen tragen Vanillas Werte.
Wo diese Werte der Rolle widersprechen, steht das in §2 als Frage, nicht als Änderung.

---

## 1. Nahkampfwaffen, gemessen

`Schaden` ist `EntityDamage` bei **Qualität 1**; Qualität 2–6 legt +10 % bis +50 % darauf
(`perc_add value=".1,.5" tier="2,6"`). `Block` ist `BlockDamage` (gegen Bauteile, nicht gegen
Gegner). `Hiebe/min` ist `AttacksPerMinute`, `Ausdauer` der `StaminaLoss` des normalen Hiebs
(die Power-Attack kostet mehr). `Schaden/s` und `Schaden je Ausdauer` sind daraus gerechnet,
nicht gemessen.

| 700-Waffe | Vanilla-Kennung | Vanilla-Stufe | Schaden | Block | Hiebe/min | Ausdauer | Reichweite | Haltbarkeit (Q1→Q6) | Schaden/s | Schaden je Ausdauer | Fertigkeit |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Keule | `meleeWpnClubT0WoodenClub` | T0 | 12 | 11 | 55 | 17,4 | 2,4 | 100→200 | 11,0 | 0,69 | Keule / Stärke |
| Knochenmesser | `meleeWpnBladeT0BoneKnife` | T0 | 5 | 4 | 120 | 7,3 | 2,0 | 250→500 | 10,0 | 0,68 | Klinge / Beweglichkeit |
| Jagdspeer | `meleeWpnSpearT0StoneSpear` | T0 | 12 | 5 | 55 | 18,5 | 2,6 (**3,6**) | 100→200 | 11,0 | 0,65 | Speer / Wahrnehmung |
| Steinhammer | `meleeWpnSledgeT0StoneSledgehammer` | T0 | 18 | 28 | 50 | 22,3 | 2,6 | 100→200 | 15,0 | 0,81 | Hammer / Stärke |
| Faustriemen | `meleeWpnKnucklesT0LeatherKnuckles` | T0 | 7 | 2,2 | 100 | 9,1 | 2,0 | 100→300 | 11,7 | 0,77 | Faust / Konstitution |
| Sax | `meleeWpnBladeT1HuntingKnife` | T1 | 12 | 6,5 | **120** | 10,5 | 2,0 | 500→1000 | **24,0** | 1,14 | Klinge |
| Ango | `meleeWpnSpearT1IronSpear` | T1 | 20 | 8 | 55 | 20,3 | 2,6 (**3,6**) | 200→400 | 18,3 | 0,99 | Speer |
| Eisenfaust | `meleeWpnKnucklesT1IronKnuckles` | T1 | 11,5 | 3,5 | 100 | 9,6 | 2,0 | 300→700 | 19,2 | 1,20 | Faust |
| Eisenhammer | `meleeWpnSledgeT1IronSledgehammer` | T1 | 32 | 52 | 34 | 36,7 | 2,6 | 200→400 | 18,1 | 0,87 | Hammer |
| **Breitaxt** | `meleeToolAxeT1IronFireaxe` | **T1** | **15** | 47 | 65 | 18,4 | 2,6 | 500→1000 | **16,3** | **0,82** | **Ernten (Werkzeug)** |
| Bartaxt | `meleeToolAxeT2SteelAxe` | T2 | 29 | **89** | 55 | 26,4 | 2,6 | 1000→2000 | 26,6 | 1,10 | **Ernten (Werkzeug)** |
| Spatha | `meleeWpnBladeT3Machete` | T3 | 25 | 21 | 65 | 16,0 | 2,3 | 1000→2000 | 27,1 | 1,56 | Klinge |
| Streitkolben | `meleeWpnClubT3SteelClub` | T3 | 32,5 | 30 | 52 | 23,7 | 2,4 | 500→1000 | 28,2 | 1,37 | Keule |
| Stahlfaust | `meleeWpnKnucklesT3SteelKnuckles` | T3 | 19 | 6 | 100 | 10,2 | 2,0 | 700→1400 | 31,7 | **1,86** | Faust |
| Flügellanze | `meleeWpnSpearT3SteelSpear` | T3 | 33 | 15 | 55 | 22,4 | 2,6 (**3,6**) | 400→800 | 30,3 | 1,47 | Speer |
| Streithammer | `meleeWpnSledgeT3SteelSledgehammer` | T3 | **55** | 85 | 34 | **40,5** | 2,6 | 400→800 | 31,9 | 1,36 | Hammer |

**Die Stufen tragen.** Schaden je Sekunde geht von 10–15 (T0) über 16–24 (T1) und 26,6 (T2) auf
27–32 (T3). Vanillas Staffelung ist in sich stimmig, und unsere Umdeutung hat sie nicht
verschoben — **mit einer Ausnahme, und die steht in §2.**

**Zur Reichweite.** Bei den drei Speeren steht sie als `Range` im Angriffsblock und ist **zwei
Zahlen**: 2,6 für den normalen Stich (`Action0`) und **3,6 für den Machtstoß** (`Action1`). Die
übrigen Waffen setzen `MaxRange` als `passive_effect`, der für beide Angriffe gilt — 2,0 bei
Messer, Fäusten und Sax, 2,3–2,6 sonst. Der Speer ist also im Machtstoß die einzige Waffe, die
über drei Meter reicht; im normalen Hieb liegt er mit Hammer und Axt gleich. **Nicht
gemessen:** ob `MaxRange` und `Range` dieselbe Strecke beschreiben — es sind zwei verschiedene
Mechanismen, und nur der Spieltest zeigt, ob sich der Speer länger anfühlt (WP5.7).

**Zwei Eigenheiten, die zur Rolle passen.** Ango und Flügellanze tragen
`EntityPenetrationCount 1`: der Stich geht durch einen Gegner hindurch. Und das Knochenmesser
hat `DamageBonus 4` und +400 % Schleichschaden — die billigste Waffe des Spiels ist seine
Schleichwaffe. Beides ist Vanilla und beides steht F-02 gut.

---

## 2. Was nicht zusammenpasst

### 2.1 Die Breitaxt ist gemessen die schwächste Waffe des Satzes — und die teuerste Axt

F-02 nennt sie **„T3–T4, schwer, Rüstungsbrecher"**. Gemessen:

| | Breitaxt | Bartaxt | Spatha | zum Vergleich |
|---|---|---|---|---|
| Vanilla-Stufe | **T1** | T2 | T3 | |
| Schaden (Q1) | **15** | 29 | 25 | Steinhammer (T0): 18 |
| Schaden/s | **16,3** | 26,6 | 27,1 | Sax (T1): 24,0 |
| Schaden je Ausdauer | **0,82** | 1,10 | 1,56 | schlechtester Wert über T0 |
| Rezept (WP5.1) | **8 Schmiedestahl** | 10 Schmiedeeisen | 1 Klinge | |
| Erz-Äquivalent | **400 Raseneisenerz** | 100 | 50 | Streithammer: 600 |

**Die Reihenfolge steht auf dem Kopf.** Die Bartaxt, die F-02 bei T0–T2 führt, schlägt die
Breitaxt um fast das Doppelte; die Spatha kostet ein Achtel des Erzes und macht mehr Schaden.
Wer in WP5.1 acht Barren Stahl in eine Breitaxt steckt, bekommt eine Waffe auf T1-Niveau.

Drei Wege, und die Wahl gehört dem Nutzer, weil sie an **D58** und an der F-02-Tabelle hängt:

1. **Tausch der beiden Vanilla-Basen.** Breitaxt ← `meleeToolAxeT2SteelAxe` (T2, 29 Schaden),
   Bartaxt ← `meleeToolAxeT1IronFireaxe` (T1, 15). Dann stimmen Stufe, Preis und Schaden
   zusammen, **ohne eine einzige erfundene Zahl**. Kosten: die Modelle tauschen mit. Welches von
   beiden wie aussieht, kann nur der Nutzer beurteilen (WP5.7) — und F-16 gibt beiden in Phase 2
   ohnehin ein eigenes Modell.
2. **Eigene Zahlen für die Breitaxt.** Sie bekommt das Profil ihrer Rolle, etwa 40 Schaden bei
   45 Hieben/min. Das sind unsere Zahlen ohne Spieltest — nach den Projektregeln gehören sie
   nach WP9.
3. **Die Rolle ändern statt der Zahlen.** Breitaxt wird T1–T2, und die F-02-Zeile wird
   berichtigt wie die F-03-Tabelle in D61.

**Empfehlung: Weg 1.** Er kostet zwei Zeilen Umdeutung und null erfundene Zahlen, und er lässt
D58s Grundgedanken — umdeuten statt sperren — unangetastet.

### 2.2 Beide Äxte sind in Vanillas Buchführung Werkzeuge, keine Waffen

`meleeToolAxeT1IronFireaxe` und `meleeToolAxeT2SteelAxe` tragen `tool`, `perkMiner69r`,
`perkMotherLode` und `harvestingSkill` — nicht `meleeWeapon`, nicht `clubSkill`/`bladeSkill`,
und nicht die Kampf-Perks (`perkFlurryOf…`). Daraus folgt dreierlei:

- Wer mit der Breitaxt kämpft, steigert seine **Bergbau**-Fertigkeit.
- Die Perks, die Keule, Klinge, Speer und Hammer stärker machen, greifen an den Äxten **nicht**.
- Ihr hoher `BlockDamage` (47 und 89) ist der Grund, warum sie trotzdem gut sind: sie sind zum
  Holzhacken und Abbauen gebaut.

Das zu ändern heißt, `Tags` zu bearbeiten — eine Inhaltsänderung mit Folgen für den
Fertigkeitsbaum. **Gehört zu F-21 in WP7**, wo der Baum ohnehin entsteht, und ist hier nur
vermerkt.

### 2.3 T4 ist auch bei den Waffen eine Qualität, keine Stufe

Vanillas höchste Nahkampfstufe ist **T3**. F-02 schreibt „T3–T4" als Spanne, und das trifft es:
derselbe Gegenstand, höhere Handwerksqualität. Ein Streithammer auf Qualität 6 macht 55 + 50 % =
**82,5** Schaden. Das ist dieselbe Einsicht wie **D61** bei der Rüstung, und sie braucht keine
eigene Entscheidung — nur den Hinweis, dass „T4" in F-02 nichts anderes bedeuten kann.

Was es **nicht** gibt: `resourceLegendaryParts` ist gesperrt, also ist Vanillas Weg zur
legendären Qualität über Zutaten zu. Wie Qualität 6 verdient wird, entscheidet F-21 in WP7.

---

## 3. Rüstung, gemessen

Die Werte hängen **allein an der Gewichtsklasse** und sind über alle Garnituren derselben Klasse
identisch (D61, Befund `WP5-ruestung-in-v340.md`). Unsere Teile tragen die Zahlen ihrer Klasse.

| Stufe | Teile | Klasse | Schutz (Q1→Q6) | Beweglichkeit | Ausdauer (gehen/laufen) | Haltbarkeit | Modplätze |
|---|---|---|---|---|---|---|---|
| T0 | Lumpenkittel, -kapuze, Handlappen, Bastschuhe | primitiv | 8 → 12,3 | — | — | 250→500 | 1–2 |
| T1 | Lederwams, Lederkappe, Wollhandschuhe, Wickelschuhe | leicht | 8 → 12,3 | — | — | 250→500 | 2–5 |
| T2 | Gambeson, Stepphaube, Stepphandschuhe, Steppschuhe | mittel | 13 → 17,3 | −5 % | −2,8 % / −5,6 % | 250→500 | 2–5 |
| T3 | Kettenhemd, Spangenhelm, Armschienen, Beinschienen | schwer | 18 → 21 | −7,5 % | −4,5 % / −9 % | 250→500 | 2–5 |

**T0 und T1 haben denselben `PhysicalDamageResist`.** Das ist Vanilla: `armorPrimitiveMaster`
trägt `DisplayType="armorLight"` und dieselbe Staffel 8 → 12,3 wie die leichte Klasse.
Unterschieden sind sie durch vier Dinge, und davon ist nur eines Schutz:

| | T0 Lumpen | T1 Wolle und Leder |
|---|---|---|
| `PhysicalDamageResist` | 8 → 12,3 | 8 → 12,3 |
| `BuffResistance` (kritische Verletzungen) | **keiner** | 4,1 % |
| Modplätze | 1–2 | 2–5 |
| Set-Bonus | **keiner** — `groupPrimitive` kommt in `buffs.xml` null mal vor | „Wanderkleidung" |
| `biomeChallenge` (Biom-Fortschritt) | nein | ja |

**Wer von T0 auf T1 wechselt, bekommt also kaum besseren Schutz, sondern einen Set-Bonus, mehr
Modplätze und Biom-Fortschritt.** Für ein Spiel, das T1 als „Wollkleidung und Lederwams"
verkauft, ist das wenig — ein Punkt für den Spieltest (WP5.7) und danach für WP9.

**Set-Boni**, geborgt und gestaffelt über die niedrigste Qualität der vier Teile:

| Stufe | Gruppe | Bonus bei Qualität 1 → 6 |
|---|---|---|
| T1 | `groupNomad` → „Wanderkleidung" | 5 % → 30 % weniger Nahrung und Wasser je Ausdauerpunkt |
| T2 | `groupAssassin` → „Gesteppte Tracht" | 15 % → 100 % schneller verborgen |
| T3 | `groupRaider` → „Kettengewand" | 20 % → 45 % Widerstand gegen Erschöpfung, Verstauchung, Abschürfung, Fleischwunde, Infektion, Betäubung und Blutung |

**Nicht gemessen:** ob `PhysicalDamageResist` abgezogen oder prozentual gerechnet wird. Ohne das
lässt sich nicht sagen, wie viele Hiebe ein Kettenhemd aushält — das ist eine Frage für den
Spieltest, nicht für diese Tabelle.

---

## 4. Unsere eigenen Zahlen: was ein Stück kostet

**Das sind die Zahlen, die WP5 wirklich gesetzt hat.** Die Kette darunter ist gemessen:

```
10 Raseneisenerz + 5 Holzkohle  → (Rennofen)        1 Luppe
 1 Luppe        + 2 Holzkohle   → (Esse + Amboss)   1 Schmiedeeisen   = 10 Erz, 7 Kohle
 5 Schmiedeeisen + 10 Holzkohle → (Esse + Tiegel)   1 Schmiedestahl   = 50 Erz, 45 Kohle
 5 Schmiedeeisen + 2 Holzkohle  → (Esse + Amboss)   1 Klinge          = 50 Erz, 37 Kohle
```

| Gegenstand | Werkstatt | Rezept | Erz-Äquivalent |
|---|---|---|---|
| Sax | Zimmermannsbank | 1 Klinge, 4 Holz, 2 Leder | 50 |
| Spatha | Zimmermannsbank | 1 Klinge, 10 Holz, 5 Leder | 50 |
| Eisenfaust | Esse + Amboss | 6 Schmiedeeisen, 4 Leder | 60 |
| Ango | Zimmermannsbank | 8 Schmiedeeisen, 10 Holz, 2 Leder | 80 |
| Bartaxt | Esse + Amboss | 10 Schmiedeeisen, 8 Holz, 2 Leder | 100 |
| Eisenhammer | Esse + Amboss | 20 Schmiedeeisen, 10 Holz, 2 Leder | 200 |
| Stahlfaust | Esse + Amboss | 6 Schmiedestahl, 4 Leder | 300 |
| **Breitaxt** | Esse + Amboss | 8 Schmiedestahl, 10 Holz, 3 Leder | **400** |
| Streitkolben | Esse + Amboss | 8 Schmiedestahl, 10 Holz, 2 Leder | 400 |
| Flügellanze | Esse + Amboss | 10 Schmiedestahl, 10 Holz, 3 Leder | 500 |
| Streithammer | Esse + Amboss | 12 Schmiedestahl, 10 Holz, 3 Leder | 600 |
| Armschienen | Esse + Amboss | 8 Schmiedeeisen, 3 Leder | 80 |
| Beinschienen | Esse + Amboss | 10 Schmiedeeisen, 4 Leder | 100 |
| Spangenhelm | Esse + Amboss | 12 Schmiedeeisen, 2 Leder | 120 |
| Kettenhemd | Esse + Amboss | 25 Schmiedeeisen, 5 Leder | 250 |
| **T3-Garnitur, alle vier Teile** | | 55 Schmiedeeisen, 14 Leder | **550** |
| T1-Garnitur, alle vier Teile | von Hand | 22 Leder, 19 Tuch | 0 |
| T2-Garnitur, alle vier Teile | Webstuhl | 8 Steppbahnen (48 Tuch, 80 Fasern), 9 Leder | 0 |
| Webstuhl (Bau) | Zimmermannsbank | 60 Holz, 30 Fasern, 5 Leder, 10 Nägel | — |

**Eine vollständige Kettengarnitur kostet weniger Erz als ein Streithammer** (550 gegen 600).
Ob das falsch ist, hängt daran, was das Spiel vom Spieler verlangt: D31 will Eisen als
spürbaren Engpass, und 550 Raseneisenerz plus 385 Holzkohle sind spürbar. Aber eine Rüstung,
die billiger ist als eine einzelne Waffe, dreht die Reihenfolge, in der man sich ausrüstet.
**Ein Punkt für WP9, hier nur benannt.**

**T1 und T2 kosten kein Erz.** Das ist Absicht: Wolle, Leder und gesteppter Stoff sind das, was
ein Hof hergibt. Der Sprung auf T3 ist damit der eigentliche Fortschritt, und er liegt hinter
Rennofen und Esse — genau wie F-03 es verlangt.

---

## 5. Reparatur

| Gegenstand | herstellbar | `RepairAmount` | repariert | Entscheidung |
|---|---|---|---|---|
| Schleifstein | überall (20 Stein, 2 Holz) | 400 | Waffen, teilweise | D60 |
| Schmiedeflicken | Esse + Amboss (2 Schmiedeeisen, 1 Kohle → 2 Stück) | 32000 | Waffen und Kettenhemd, voll | D60 |
| Nähzeug | überall (1 Knochen, 10 Fasern → 2 Stück) | 32000 | Rüstung T0, T1, T2, voll | D62 |

Zum Vergleich Vanillas Werkstoffe: Tuch 50, Holz 100, Leder 150, Knochen 270, Schmiedeeisen
270, Stein 300. Der Schleifstein mit 400 liegt also knapp über dem besten Werkstoff und weit
unter dem Flicken — „teilweise" heißt bei einer Waffe mit 1000 Haltbarkeit **zwei Fünftel**.

**Was offen bleibt:** zehn erlaubte Gegenstände reparieren weiter mit dem gesperrten
`resourceRepairKit` — vier Bögen (WP5.2), fünf Werkzeuge (F-05) und `partsMaster` (WP7). Von
Hand gezählt; eine Prüfung dafür gibt es nicht (Vertrag 04, offene Punkte).

---

## 6. Nebenbei in WP5 geändert, und darum hier

| Was | von | auf | Grund |
|---|---|---|---|
| Kräuterküche, Bau-Rezept | 100 Schmiedeeisen | 20 Schmiedeeisen + 40 Lehm | 100 Barren waren Vanillas Preis für eine Chemieanlage mit Destillationssäule; F-04 nennt Mörser und Destillierhelm |

Die übrigen drei Werkstatt-Berichtigungen (Zimmermannsbank, Esse, Kalkofen) haben nur gesperrte
Zutaten gegen zeitgemäße getauscht, ohne die Menge zu verschieben.

**Nachtrag 8. November 2026, WP6:** die drei Lehm-Mengen hießen zuerst 20/30/20 und standen auf
der falschen Kennung — `resourceClay` gibt es in Vanilla nicht, der Lehm heißt
**`resourceClayLump`**. Beim Berichtigen gleich auf 50/40/50 gesetzt: ein Lehmblock gibt beim
Abbauen 22 Klumpen, 20 wären für einen ganzen Ofen weniger als ein Block gewesen.

---

## 7. Was WP5.6 nicht entscheidet

- **Die Breitaxt** (§2.1) — drei Wege, Empfehlung Weg 1, Entscheidung beim Nutzer, weil D58 und
  die F-02-Tabelle daran hängen.
- **Die Äxte als Werkzeuge** (§2.2) — F-21 in WP7.
- **T1 schützt wie T0** (§3) — Spieltest WP5.7, danach WP9.
- **Garnitur billiger als Waffe** (§4) — WP9.
- **Alles, was sich nur spielen lässt:** ob eine Waffe ihren Zweck zeigt, ob der Gambeson sich
  nach Gambeson anfühlt, ob 550 Raseneisenerz eine Woche oder einen Abend sind. **WP5.7.**
