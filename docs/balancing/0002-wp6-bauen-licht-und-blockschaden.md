# Balancing WP6 — Bauen, Licht und der Blockschaden der Toten

Erhoben am **2026-11-08** gegen V 3.40 b10, `Data/Config` der lokalen Installation. Alles
hier ist **gemessen**, nicht geschätzt; wo eine Zahl von mir kommt, steht ihre Begründung
daneben. Was sich nur spielen lässt, steht in §5.

Vorgänger: [Balancing WP5](0001-wp5-waffen-ruestung-und-kosten.md).

---

## 1. Die fünf Baustufen und was sie kosten

| Stufe | Vanilla-Block | `MaxDamage` | Aufwertung kostet | in Grundstoffen |
|---|---|---|---|---|
| T0 Rahmen | `frameShapes` | 100 | 8 × Holz | 8 Holz |
| T1 Flechtwerk | `woodShapes` | 500 | 10 × Pflasterstein | 10 Lehm + 10 Stein |
| T2 Fachwerk | `cobblestoneShapes` | 1 500 | 25 × Stein | 25 Stein |
| T3 Bruchstein | `concreteShapes` | 5 000 | 10 × Mörtel | 10 Branntkalk + 10 Sand + 10 Stein |
| T4 Mörtelstein | `steelShapes` | 10 000 | — | — |

Der Mörtel in Grundstoffen weiter aufgelöst, weil er die einzige Stufe mit einer
Vorverarbeitung ist:

| Zutat | Vanilla-Rezept | in Grundstoffen |
|---|---|---|
| 1 × Branntkalk (`resourceCement`) | 10 × geschmolzener Stein, am Ofen | 10 Stein |
| 1 × Mörtel (`resourceConcreteMix`) | 1 Sand + 1 Stein + 1 Branntkalk, am Kalkofen | 10 Stein + 1 Stein + 1 Sand |

**10 Mörtel kosten also ≈ 110 Stein und 10 Sand**, dazu Brennstoff für Ofen und Kalkofen.
Die oberste Baustufe ist damit die erste im Spiel, die eine **zweistufige Kette** braucht
(Stein → Branntkalk → Mörtel) — genau die „2–3 Stufen", die D25 für Herstellungsketten
festlegt.

Die ganze Treppe von T0 bis T4 für **einen** Block: 8 Holz, 10 Lehm, 146 Stein, 10 Sand.
Zum Vergleich steht in [WP5 §4](0001-wp5-waffen-ruestung-und-kosten.md) ein Kettenhemd bei
550 Raseneisenerz. **Bauen ist billig, Rüstung ist teuer** — das ist Absicht und passt zu
P4 (Material ist Arbeit, nicht Zufall): Stein liegt überall, Erz muss man schmelzen.

---

## 2. Was ein Schlag an einem Block anrichtet

Der Hebel steht **nicht**, wo der Plan ihn vermutete. Dazu drei Messungen.

### 2.1 Es gibt zwei Schreibweisen, und die eine überschreibt die andere

```xml
<property class="Action0">
    <property name="DamageBlock" value="8"/>     <!-- der Grundwert -->
</property>
…
<passive_effect name="BlockDamage" operation="base_set" value="100"/>   <!-- setzt ihn neu -->
```

`ItemActionAttack::GetDamageBlock` übergibt `this.damageBlock` (den `Action0`-Wert) als
Grundwert an `EffectManager::GetValue` — die passiven Effekte rechnen also **darauf**, und
`base_set` **ersetzt** ihn. Danach folgt
`Utils::FastMin(ergebnis, block.blockMaterial.MaxIncomingDamage)`.

`passive_effect name="BlockDamage"` kommt in `entityclasses.xml` **null**-mal vor; dort steht
`BlockDamage` nur an Sprengkörpern und Fahrzeugen. Der Plan nannte diese Datei — berichtigt.

### 2.2 Die Leiter, vollständig (`Action0` / `DamageBlock`)

| Stufe | Wert | wer | Nutzer in `entityclasses.xml` |
|---|---|---|---|
| normal | **7–8** | `meleeHandZombie01/02`, `Short`, `Burning`, `HazMat` | wenige |
| zäh (*feral*) | **22–24** | `…Feral`, `BurningCrawler`, `PartyGirlFeral` | 13 + 8 |
| kräftig | 20 / 60 | `Strong`, `StrongFeral` | 2 + 2 |
| Arbeiter | 40 / 120 | `Worker`, `WorkerFeral` | 2 + 1 |
| aufgeladen | **150** | `Charged` | **27** |
| Sonderformen | 100 → 140/200 | `Cop`, `Rancher`, `Chuck`, `Mutated` + deren Stufen | 4–4 je |
| höllisch | **250** | `Infernal` | **27** |
| Brecher | **500** | `Demolition`, `BossGrace` | 1 + 1 |
| Tiere | 1–80 | Schwärme 1, Kojote 6, Wolf 16, Bär 40, Zombiebär 80 | — |

**Der Widerspruch:** `meleeHandZombieFeral` setzt `DamageBlock=24` in `Action0`, **erbt aber
von `meleeHandZombie01` das `passive_effect base_set 100`** — und `base_set` ersetzt den
Grundwert. Nach dem gemessenen Rechenweg täte eine zähe Hand damit 100 statt 24, eine
aufgeladene 100 statt 150, eine höllische 100 statt 250. Ob `Extends` die `effect_group`
wirklich mitnimmt und in welcher Reihenfolge, steht nicht im XML. **Das ist ein offener
Punkt, kein Befund** — und ein Grund mehr, die Zahlen der Gegner nicht anzufassen (§2.3).

### 2.3 `MaxIncomingDamage`: eine Obergrenze pro Material

`GetDamageBlock` endet mit `FastMin(…, MaterialBlock::MaxIncomingDamage)`. Die Vorgabe steht
im Konstruktor auf **2 147 483 647** (`int.MaxValue`), also kein Deckel. In ganz
`materials.xml` ist die Eigenschaft **genau einmal** gesetzt: `MtwitchHordeStone` auf 25.

Das ist der Hebel, den D29 braucht, und er liegt **auf unserer Seite**: eine Zeile je
Baumaterial statt rund 45 Werte an fremden Gegenständen, ohne Nebenwirkung auf POIs, Türen
oder die Sprengkörper (die über `entityclasses.xml` und `ExplosionData` laufen, nicht über
`GetDamageBlock`).

### 2.4 Wie lange eine Mauer hält, in Schlägen

`MaxDamage ÷ Schaden je Schlag`, nach der Leiter aus §2.2:

| | T1 Flechtwerk 500 | T2 Fachwerk 1 500 | T3 Bruchstein 5 000 | T4 Mörtelstein 10 000 |
|---|---|---|---|---|
| normal (8) | 63 | 188 | 625 | 1 250 |
| zäh (24) | 21 | 63 | 208 | 417 |
| aufgeladen (150) | 3 | 10 | 33 | **67** |
| höllisch (250) | 2 | 6 | 20 | **40** |
| Brecher (500) | 1 | 3 | 10 | **20** |

---

## 3. Der Befund zu D29 — und warum er unangenehm ist

D29 lautet: *„weniger Blockschaden durch Seuchentote, damit Mörtelstein etwa so hält wie
Vanilla-Stahl"*.

**Mörtelstein IST Vanilla-Stahl.** Nach der Zuordnung aus WP6.1 trägt die oberste Baustufe
den Block `steelShapes` mit dem Material `Msteel_shapes` und dessen `MaxDamage` von 10 000 —
unverändert. Die Tabelle in §2.4 gilt damit Zeile für Zeile **genauso für Vanilla**. Das Ziel
von D29 ist durch die Zuordnung schon erreicht, bevor eine Gegner-Zahl angefasst wird.

Ein Blockschadens-Abschlag würde unsere Basen also **stärker** machen als Vanillas, nicht
gleich stark. Dazu kommt, dass WP6.4 in dieselbe Richtung wirkt: Fackeln melden keine Hitze
mehr an den AI-Director und ziehen keine Schreier (D64, gemessen). Zwei Entlastungen des
Spielers aus einem Arbeitspaket, von denen nur eine beschlossen war.

**Was gegen „also nichts tun" spricht:** die Erreichbarkeit ist nicht dieselbe. Vanillas
Stahl braucht Schmiedestahl, also Eisenerz, Tiegel und eine Fertigkeit. Unser Mörtelstein
braucht **Stein, Lehm und Sand** — Stoffe, die überall liegen (§1: 146 Stein für die ganze
Treppe). Wenn T4 bei uns deutlich früher erreichbar ist als Vanillas Stahl, hält eine Basis
früher 40 Schläge eines höllischen Toten aus, und die Seuchennacht verliert ihre Zähne, ohne
dass eine Zahl geändert wurde. **Das kann nur ein Spieltest zeigen** (WP6.7).

### Drei Wege

| | was es tut | Kosten | Nebenwirkung |
|---|---|---|---|
| **A — D29 berichtigen, nichts senken** | neue D-Zeile: die Zuordnung aus WP6.1 erfüllt D29 bereits; der Abschlag entfällt | null | wenn T4 zu früh erreichbar ist, bleibt es zu leicht. Nachziehen in WP9 |
| **B — `MaxIncomingDamage` auf die drei Steinstufen** | ein Deckel je Schlag, z. B. T2 50 / T3 75 / T4 100: ein höllischer Schlag richtet an Mörtelstein dann 100 statt 250 an, also 100 Schläge statt 40 | drei Zeilen in `materials.xml` | **stärker als Vanilla** — bewusst. Trifft nur unsere Baustufen, nicht POIs, nicht Sprengkörper |
| **C — `DamageBlock` senken, wie der Plan sagt** | die Gegner-Zahlen selbst | ~45 Werte in `items.xml`, dazu der offene Punkt aus §2.2 | trifft **alles**, was Tote schlagen: POI-Wände, Türen, Fahrzeuge. Und solange §2.2 offen ist, weiß niemand, welcher der beiden Werte wirkt |

**Empfehlung: A, und B erst nach dem Spieltest.** Grund: D29s Ziel steht gemessen schon, und
jede Senkung jetzt wäre eine Zahl ohne Vergleichspunkt. B ist danach eine Sache von drei
Zeilen und braucht keine neue Messung — der Deckel ist gemessen, nur sein Wert ist eine
Balancing-Frage. C wäre die teuerste und unsicherste Änderung von dreien.

**„Mehr Gefahr für Spieler"**, die zweite Hälfte von D29, hängt an `DamageEntity`
(normal 10, zäh 20, höllisch 45, aufgeladen 60) und gehört zu F-06 und F-17, nicht zu WP6.3.
Sie wird von keinem der drei Wege berührt.

---

## 4. Licht: was es kostet und wie lange es hält

| Lichtquelle | Rezept | `GrowthRate` | wieder anzünden |
|---|---|---|---|
| Unschlittkerze | 1 Nesselfaser + 1 Tierfett | 15 | 1 Kerze |
| Fackel | 1 Tierfett + 5 Tuch + 1 Holz | 30 | 1 Fackel |
| Holzfeuer | 20 Holz + 5 Stein | 45 | 10 Holz |
| Öllampe | 5 Schmiedeeisen + 5 Nägel + 5 Tuch + 5 Tierfett | 60 | 2 Tierfett |

Die Reihenfolge ist Absicht: **billig und kurz bis teuer und lang.** Die Kerze kostet zwei
Dinge, die überall anfallen, und hält ein Viertel so lang wie die Lampe, die Schmiedeeisen
braucht. Das Wiederanzünden kostet durchweg **weniger** als das Bauen — der Körper bleibt
ganz, nur der Brennstoff ist weg.

**Die Zahlen sind unkalibriert.** `GrowthRate` ist nach Vanillas Kommentar an
`cropsGrowingMaster` eine Angabe in Minuten; ob real oder ingame, sagt erst WP6.6. Bei der
Vorgabe von 60 realen Minuten je 24-Stunden-Zyklus (`goDayNightLength`) wären 30 Minuten eine
halbe Spielnacht — was sich richtig anhört und noch nichts beweist. Dazu multipliziert
`GetTickRate` mit einem spielweiten `CropGrowthModifier`.

---

## 5. Wehrbauten: was sie kosten und was sie aushalten

| Bauteil | Rezept | `MaxDamage` | Schaden am Angreifer |
|---|---|---|---|
| Spitzpfähle | 20 Holz | 100 | **33** |
| Eisenspitzen | Aufwertung: 4 Schmiedeeisen | 200 | **33** |
| Palisadenabschnitt (3×4) | 50 Holz | 200 | — |
| Palisade gespitzt (3×5) | 65 Holz | 200 | **15** |
| Palisadenpfosten (1×4) | 20 Holz | 200 | — |
| Pfostenkappe | 10 Holz | 200 | — |
| Torhaus-Tor (5×5) | 100 Holz + 20 Nägel + 10 Schmiedeeisen | 250 | — |

**Die Palisade ist billiger als eine gebaute Wand und hält weniger.** Ein Abschnitt deckt
zwölf Zellen für 50 Holz; dieselbe Fläche als Flechtwerk über den Ausbaupfad kostet
**96 Holz** (8 je Zelle) und hält 500 statt 200. Das ist die Absicht: eine Palisade zieht man
am ersten Abend hoch, eine Wand baut man.

**Die 15 Schaden der gespitzten Palisade** liegen unter den 33 eines Spießes, und zwar
begründet: ein Spieß ist eine Falle, in die man hineinläuft, eine Mauer ist eine Mauer, an der
man hochklettert. `Damage_received 15` sorgt dafür, dass sie sich dabei abnutzt — bei
`MaxDamage` 200 also nach etwa 13 Begegnungen.

---

## 6. Was WP6 nicht entscheidet

- **D29** (§3) — drei Wege, Empfehlung A. Entscheidung beim Nutzer, weil D29 daran hängt
  (Projektregel 4).
- **Die Brenndauern** (§4) — unkalibriert bis WP6.6. Erst die Einheit messen, dann
  `GrowthDeviation` setzen.
- **Ob T4 zu früh erreichbar ist** (§3) — nur im Spiel sichtbar, WP6.7.
- **Der Widerspruch zwischen `DamageBlock` und `BlockDamage`** (§2.2) — ungelöst. Zu klären,
  bevor irgendwer Gegner-Zahlen anfasst.
- **Die 830 Sprachschlüssel der Blockformen** — die Baustoffnamen stehen an jeder einzelnen
  Form. Werkzeugarbeit, F-12 in WP8.
