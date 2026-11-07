# Game Design Document — 7DTD_700

| | |
|---|---|
| **Version** | 0.1 (Entwurf) |
| **Stand** | 2026-11-07 |
| **Basisspiel** | 7 Days to Die V2.x (Stable) |
| **Mod-Typ** | Total-Conversion-light: Setting-Wechsel + Overhaul + neue Inhalte |
| **Tiefe** | XML-Modlets + C#/Harmony; ab Phase 2 zusätzlich eigene Assets + Retexturen |
| **Spielmodi** | Singleplayer, Dedicated Server |
| **Sprachen** | Deutsch + Englisch (Pflicht) |
| **Name** | offen, Arbeitstitel `7DTD_700` |

---

## 1. Vision

> **Das Jahr 700. Eine Seuche, die die Toten nicht ruhen lässt, hat das Land entvölkert.
> Kein Fürst schützt dich, kein Kloster hat Antworten. Du hast eine Axt, ein paar Hände voll
> Saatgut und sieben Tage bis zur nächsten Seuchennacht.**

Die Mod verlegt die Survival-Horde-Formel von 7 Days to Die aus der Postapokalypse in ein
frühmittelalterliches Europa. Spielerisch heißt das: **kein Strom, keine Schusswaffen, keine
Fahrzeuge, kein Konservenvorrat.** Dafür gibt es Holz, Lehm und Eisen, Muskelkraft,
Nahkampf und Gemeinschaft. Der Fortschritt kommt nicht mehr aus Industrie-Loot, sondern aus
Handwerk und wiederentdecktem Wissen.

Wo Vanilla auf Technik setzt, die nicht in die Zeit passt (Geschütztürme, Strom, Drohnen,
Sprengstoff), übernimmt **Volksmagie** die Rolle: Runensteine, Segen, Flüche, Tränke und
einfache Zauber. Diese Magie ist erlernt, an Material gebunden und dezent (Entscheidung D9).

### 1.1 Design-Säulen

| # | Säule | Bedeutung für Entscheidungen |
|---|---|---|
| P1 | **Glaubwürdig um 700, wie es sich die Menschen damals erzählten** | Nichts technisch Anachronistisches (Schießpulver, Plattenrüstung, Strom). Magie ist erlaubt, aber nur in der Form, die Volksglaube und Sagen der Zeit kennen: Runen, Segen, Flüche, Kräuter, Sagengestalten. Bei Spielspaß-Konflikt gilt „plausibel“ vor „belegt“. |
| P2 | **Handwerk ist Fortschritt** | Tech-Progression läuft über Werkstätten, Rohstoffketten und Wissen, nicht über Loot-Glück mit Hightech. |
| P3 | **Nahkampf mit Gewicht** | Kampf ist nah, riskant und positionsabhängig: Schild, Reichweite, Ausdauer, Schadensarten. Fernkampf (Bogen) und Kampfmagie sind gleichwertige, teure Spezialisierungen (D22). |
| P4 | **Grauen vor dem Dunkel** (D12) | Das Spiel ist bedrohlicher und unheimlicher als Vanilla. Dunkelheit, Nebel, Klang und Ungewissheit tragen den Horror; Licht, Feuer, Gemeinschaft und Befestigung sind Zuflucht auf Zeit. Andeuten statt zeigen, keine billigen Jumpscares. Jedes Feature fragt: „Macht das die Welt unheimlicher oder sicherer, und ist das gewollt?“ |
| P5 | **Vanilla-Systeme umdeuten statt neu bauen** | Wo ein Vanilla-System die Fantasie schon trägt, wird es per XML umgedeutet. C# nur, wo XML nicht reicht. Das hält die Mod updatefest. |

P5 ist die wichtigste **technische** Säule. Jedes Feature muss begründen, warum es C# braucht.

### 1.2 Zielgruppe

- 7DTD-Spieler, die Overhauls wie Darkness Falls oder Undead Legacy mögen, aber ein anderes
  Setting suchen. (Diese Mods sind Genre-Referenz, nicht Vorlage; nichts wird übernommen.)
- Mittelalter-Survival-Fans (Kingdom-Come-, Valheim-, Medieval-Dynasty-Publikum).
- Kleine Koop-Gruppen auf Dedicated Servern (2–8 Spieler).

---

## 2. Setting

### 2.1 Zeit & Ort

- **Zeit:** um 700 n. Chr. Die letzten Wellen der *Justinianischen Pest* (541–~750) sind
  historisch belegt und liefern den Aufhänger: Diese Seuche hat die Toten wieder aufstehen lassen.
- **Ort:** Ein **fiktives Mischland** (Entscheidung D1). Kein realer Ort und keine realen
  Herrscher. Das Land vereint, was im Europa um 700 nebeneinander existierte:
  fränkisch-romanische Klöster und Römerruinen, germanische Langhäuser und Höfe, slawische
  Burgwälle, keltisch geprägte Randgebiete im Westen, nordische Einflüsse an der Küste.
  Dichter Wald, Moore, Flusstäler, Mittelgebirge, Heide.
  - **Leitplanke Mischland:** Jedes Element muss *für sich* um 700 in Europa plausibel sein
    (Säule P1). Gemischt wird die Herkunft, nicht die Epoche.
  - **Namen:** frei erfunden, aber im Lautbild frühmittelalterlich (z. B. Orte auf
    -heim/-feld/-wik/-grad/-dun). Regeln stehen im Glossar (F-12).
  - Kulturelle Zonen lassen sich auf Biome abbilden (siehe F-07).
- **Ursache der Untoten:** bewusst offen gelassen. Für die einen ist es Gottes Strafe, für
  andere ein Fluch der alten Götter oder einfach eine Seuche.
- **Volksmagie** (Entscheidung D9, ersetzt D2): Magie ist real, aber bodenständig. Es gibt
  vier Formen (Details in F-15):
  1. **Runen & Zeichen:** passive Effekte, eingeritzt in Waffen, Rüstung, Häuser und Steine
  2. **Segen & Flüche:** kurze Rituale bzw. Sprüche mit Zeitwirkung auf sich, Verbündete oder Gegner
  3. **Tränke & Salben:** Kräuterkunde mit magischer Wirkung
  4. **Einfache Zauber:** ausgelöste Fähigkeiten. Sie **ersetzen vor allem die Vanilla-Technik,
     die nicht in die Zeit passt**. Beispiel: Geschütztürme werden zu Runensteinen, die
     kleine Feuerpfeile schießen.
- **Sichtbarkeit dezent** (D10): Glimmen, Funken, Rauch, Glutpfeile, Geräusche. Keine
  Feuerbälle, Blitze oder Explosionen im Fantasy-Stil.
- **Sagengestalten** (D11): einige wenige folkloristische Gegner aus der Volksüberlieferung
  (z. B. Irrlicht, Nachzehrer, Moorgeist) als seltene Erscheinungen. Keine Dämonen-Heere,
  keine Drachen, keine High-Fantasy-Völker.

### 2.2 Ton

**Folk-Horror.** Dreckig, kalt, abergläubisch, und manchmal hat der Aberglaube recht.
Kein Ritterromantik-Hochglanz, keine Zauberschule.

- **Bedrohlich:** Die Welt ist nicht leer, sie wartet. Stille ist verdächtig. Wer allein und
  ohne Licht unterwegs ist, begeht einen Fehler.
- **Unheimlich:** Das Grauen kommt aus dem, was man *fast* sieht und *fast* hört: eine Gestalt
  im Nebel, eine Glocke, wo kein Kloster mehr steht, Kratzen an der Tür.
- **Menschlich:** Notizen und Orte erzählen von Menschen, die Angst hatten. Das macht das
  Grauen persönlich.
- Humor nur noch sehr sparsam und trocken (Händler), nie in Grusel-Situationen.

Details zu den Grusel-Mechaniken: [F-17 Grauen & Bedrohung](features/F-17-grauen-bedrohung.md).

### 2.3 Übersetzungstabelle Vanilla → 700

Das Herzstück der Umdeutung. Jede Vanilla-Komponente bekommt eine Entsprechung oder wird
entfernt.

| Vanilla | 700-Entsprechung | Feature |
|---|---|---|
| Zombies | Seuchentote (Bauern, Mönche, Krieger, Pilger …) | F-06 |
| Feral/Radiated | „Verderbte“ / „Moorleichen“ (Stärkestufen) | F-06 |
| Blood Moon / Horde Night | **Seuchennacht** | F-09 |
| Trader | Wanderhändler, Klostermarkt, Fürstenhof | F-10 |
| Dukes (Währung) | Silber (Sceattas / Denare) | F-05 |
| Workbench / Forge / Chem Station / Cement Mixer | Zimmermannsbank, Rennofen + Esse, Kräuterküche, Kalkofen | F-04 |
| Schusswaffen | Bögen, Schleuder, Wurfspeere, Armbrust (T4, selten, D8) | F-02 |
| Buffs/Boosts aus Pillen | Tränke, Salben, Amulette, Reliquien | F-11, F-15 |
| Geschütztürme (Auto-/Shotgun-Turret) | **Runensteine**, die Glut- bzw. Feuerpfeile schießen | F-15 |
| Junk Turret / Drohne (Begleiter) | Tragbarer Runenstein bzw. Schutzgeist-Zeichen (optional, Phase 3–4) | F-15 |
| Elektrizität (Generator, Kabel, Solar) | **Kraftsteine und Kraftlinien**: Runenkraft statt Strom (Variante A in F-15) | F-08, F-15 |
| Elektrische Fallen (Blade Trap, Elektrozaun) | Runenfallen (Glutzeichen, Bannkreis) + mechanische Fallen | F-08, F-15 |
| Sprengstoff, Granaten, Molotow | Pechtopf (mechanisch), Fluchtopf bzw. Feuerzauber (magisch) | F-02, F-15 |
| Attribute & Perkbäume (Perception, Strength, Fortitude, Agility, Intellect) | **6 neue Bäume**: Krieger, Jäger, Handwerker, Runenkundiger, Heiler, Transport & Logistik | F-21 |
| Fahrzeuge (Fahrrad, Minibike, Motorrad, Truck, Gyrocopter) | Handkarren, Packtier, Reitpferd; Endgame: Hexenbesen, Runenross (magisch) | F-13 |
| — (neu) | Magische Wegsteine (Schnellreise) | F-13, F-15 |
| Bücher/Magazine (Crafting-Skills) | Abschriften als Grundfähigkeit + **Learning by Doing** | F-04, F-21 |
| Städte, Straßen, Wolkenkratzer | Weiler, Höfe, Klöster, Ringwälle, Römerruinen | F-07 |
| Medizin (Pillen, Antibiotika) | Kräuter, Wundauflagen, Theriak | F-11 |
| Bandits (falls in V2.x vorhanden) | Plünderer, Seuchenkult | F-20 |
| Beton, Stahlblöcke | Fachwerk, Bruchstein, Mörtelstein | F-18 |
| Farming | Getreide, Rüben, Kohl, Erbsen, Flachs, Kräuter + Viehhaltung | F-19 |

---

## 3. Core Loop

Der Vanilla-Loop bleibt strukturell erhalten (P5), wird aber thematisch neu belegt:

```
   Tag: Erkunden ─► Sammeln (Holz, Lehm, Erz, Kräuter) ─► Handwerk in Werkstätten
     ▲                                                          │
     │                                                          ▼
  Wiederaufbau ◄── Seuchennacht (alle 7 Tage) ◄── Befestigen (Palisade, Graben, Fallen)
```

**Spannungsbogen über einen 7-Tage-Zyklus** (F-17, Bedrohungs-Direktor):

| Tage | Phase | Gefühl |
|---|---|---|
| 1–2 nach Seuchennacht | Erlösung | Aufräumen, Durchatmen, Tageslicht wirkt sicher |
| 3–4 | Ruhe mit Rissen | Erste Pirscher, Nebelabende, verstummende Tiere |
| 5–6 | Vorzeichen | Glocken, Krähen, Trugbilder häufen sich, Sagengestalten |
| 7 | Seuchennacht | offene Bedrohung, Höhepunkt |

**Mittlere Schleife:** Aufträge von Händlern und Klöstern annehmen, Ruinen und Höfe plündern,
Wissen (Abschriften) sammeln, neue Werkstätten freischalten.

**Lange Schleife:** vom Grubenhaus zur befestigten Siedlung mit Rennofen, Esse, Gesellen und
Vieh; vom Holzknüppel zu Spatha und Kettenhemd; vom Fußmarsch zum eigenen Pferd und
schließlich zu Wegsteinen und Runenross.

### 3.1 Progressionsstufen (Tech-Tiers)

| Tier | Name | Kernmaterialien | Typische Werkstätten |
|---|---|---|---|
| T0 | Überleben | Holz, Stein, Fasern, Knochen | keine (Handwerk aus der Hand) |
| T1 | Hof | Lehm, Flechtwerk, Leder, Wolle | Zimmermannsbank, Feuerstelle |
| T2 | Werkstatt | Raseneisenerz, Holzkohle, Schmiedeeisen | Rennofen, Esse, Gerberei |
| T3 | Burg | Stahl (Damaszierung), Kalkmörtel, Bruchstein | Kalkofen, Waffenschmied |
| T4 | Endgame | Pattern-welded Klingen, Kettenhemd, Steinbau | Meisterwerkstatt (Wissen nötig) |

---

## 4. Systeme (Überblick)

Detaillierte Specs je Feature liegen unter [`docs/features/`](features/README.md). Hier die
Zuordnung zu Säulen und Phasen (Roadmap siehe Abschnitt 5):

| Feature | Säulen | Phase |
|---|---|---|
| F-00 Mod-Fundament | P5 | 0 |
| F-01 Anachronismen-Purge | P1 | 1 (MVP) |
| F-02 Waffen & Kampf | P1, P3 | 1: Waffen, Verschleiß · 2: Schild, Schadensarten, Werfen |
| F-03 Rüstung & Kleidung | P1, P3 | 1 |
| F-04 Handwerk & Werkstätten | P2 | 1: Ketten, Brennstoff, Werkzeuge · 3: Gesellen |
| F-05 Ressourcen & Währung | P1, P2 | 1 |
| F-06 Seuchentote & Bestiarium | P1, P4 | 2 |
| F-07 Welt, Kulturzonen & POIs | P1, P4 | 2 · 4: eigene Karte |
| F-08 Licht, Feuer & Verteidigung | P4 | 1 |
| F-09 Seuchennacht | P4 | 2 |
| F-10 Händler & Aufträge | P1, P2 | 2: Handelsposten, Vanilla-Aufträge · 3: Bann, Lore, Eskorte |
| F-11 Krankheit & Heilkunde | P1, P4 | 2 |
| F-12 Lokalisierung & UI-Theming | P1 | 1 |
| F-13 Transport & Mobilität | P2 | 3: Karren, Packtier, Pferd, Wegsteine · 4: magische Fahrzeuge |
| F-14 Siedlung, Gesellen & Koop | P2 | 3 |
| F-15 Volksmagie | P1, P3, P4 | 2: Runen, Tränke, Runensteine, Odem · 4: Hochmagie |
| F-16 Asset-Pipeline | P1 | 2 (Start) |
| F-17 Grauen & Bedrohung | P4 | 1: Dunkelheit, Klang, sichere Orte · 2: Furcht, Trugbilder, Direktor |
| F-18 Bauen & Befestigung | P2, P4 | 1 |
| F-19 Nahrung, Ackerbau & Viehhaltung | P1, P2 | 2: Verderb, Ackerbau · 3: Viehhaltung |
| F-20 Seuchenkult & Plünderer | P1, P4 | 3 |
| F-21 Fertigkeiten & Learning by Doing | P2 | 1: sechs Bäume (XML) · 2: Learning by Doing |

---

## 5. Roadmap (strikt phasenweise, D50)

Das Projekt ist ein **Solo-Projekt mit Claude** (D45). Deshalb gilt:

- Jede Phase endet mit einem **internen Playtest** und einer kurzen Rückschau. Erst dann beginnt die nächste.
- Innerhalb einer Phase wird **XML vor C# vor Assets** umgesetzt (P5).
- Was in einer Phase nicht fertig wird, rutscht ehrlich in die nächste, statt die Phase aufzublähen.
- **Veröffentlichung** (D46): intern bis mindestens Phase 1 stabil ist. Über den ersten
  öffentlichen Release (Nexus bzw. Forum) wird nach dem Phase-1-Playtest entschieden.

| Phase | Name | Ziel | Kern-Features |
|---|---|---|---|
| **0** | Fundament | Mod lädt überall, REA-Baseline steht | F-00, REA-Baseline |
| **1** | **MVP: „700 & Grauen“** (D49) | Das Spiel fühlt sich nach 700 an **und** ist bedrohlicher. Komplett spielbar bis zur ersten Seuchennacht, noch mit Vanilla-Modellen | F-01, F-02 (Basis), F-03, F-04 (Basis), F-05, F-08, F-12, F-17 (B1, B2, B8), F-18, F-21 (Bäume) |
| **2** | Leben in der Welt | Optischer Bruch geschlossen, Magie und Furcht da, Welt erzählt | F-16 zuerst, dann F-06, F-07, F-09, F-11, F-15 (Kern), F-17 (Rest), F-02 (Rest), F-19 (Basis), F-21 (Learning by Doing), F-10 (Basis) |
| **3** | Tiefe | Transport, Siedlung, Kult, Geschichte | F-13 (Karren, Tiere, Wegsteine), F-14, F-19 (Vieh), F-20, F-10 (Bann, Lore, Eskorte), F-04 (Gesellen) |
| **4** | Hochmagie & Karte | Endgame-Spektakel und handgebaute Welt | F-15/F-13 magische Fahrzeuge, F-07 eigene Karte |

**MVP-Definition (Phase 1):** Eine RWG-Welt ist von Tag 1 bis nach der ersten Seuchennacht
spielbar, ohne Anachronismus in Items, Rezepten, Loot und Texten. Es gibt mittelalterliche
Waffen mit Verschleiß, Rüstung, Werkstätten mit Brennstoff, Silber, den umgedeuteten
Bau-Pfad, die sechs neuen Fertigkeitsbäume sowie spürbar dunklere, nebligere, unheimlich
klingende Nächte. Gegner, Waffen und POIs sind noch Vanilla-Modelle mit neuen Namen.
Geschütztürme und Strom sind in Phase 1 nur gesperrt; ihr magischer Ersatz kommt in Phase 2.

**Phase-2-Assets:** Mischung aus **Retexturen** (schnell, breit) und **neuen Assets** dort, wo
Vanilla kein passendes Modell hat (D3; F-16):

| Retextur genügt (Beispiele) | Neues Asset nötig (Beispiele) |
|---|---|
| Kleidung der Seuchentoten, Lederrüstung, Fackel | Spatha, Rundschild, Spangenhelm, Kettenhemd |
| Blöcke: Flechtwerk, Lehm, Reet, Bruchstein | Rennofen, Webstuhl, Langbogen, Runenstein |
| Truhen, Möbel, Wildtiere | Amulette/Reliquien (Icons + kleine Modelle) |

> **Ehrliche Einschätzung des Umfangs:** 22 Features sind für ein Solo-Projekt viel. Phase 1
> ist bewusst überwiegend XML und damit realistisch. Ab Phase 3 (Pferde, Viehhaltung,
> Kultisten-KI, Gesellen) steigt der Aufwand pro Feature stark, wegen Assets, Animationen,
> KI und Netz. Diese Features werden vor Beginn jeweils neu bewertet.

---

## 6. Technischer Rahmen (Kurzfassung)

Siehe [`specs/01-technischer-rahmen.md`](specs/01-technischer-rahmen.md). Die wichtigsten
Punkte:

- Datenänderungen per **XPath-Modlet** (`Config/*.xml`), Logik per **Harmony-Patch** in einer C#-DLL.
- **Server-autoritativ denken:** Jeder C#-Patch wird als Server-, Client- oder beidseitig
  klassifiziert. Die C#-DLL muss auf Server **und** Clients liegen, und **EAC muss aus** sein.
- **Schnittstellen nicht raten:** Jeder Harmony-Patch-Zielpunkt wird vorher per **REA**
  gegen die tatsächliche `Assembly-CSharp.dll` der Zielversion verifiziert und in
  `docs/rea/findings/` dokumentiert. Siehe [`rea/interface-discovery.md`](rea/interface-discovery.md).

---

## 7. Entscheidungen

### 7.1 Setting & Ton
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D1 | 2026-11-07 | Region (Q1) | **Fiktives Mischland** mit Leitplanke „gemischt wird die Herkunft, nicht die Epoche“ | GDD 2.1, F-07, F-12 |
| ~~D2~~ | 2026-11-07 | Übernatürliches (Q2) | ~~Aberglaube mit Wirkung, keine Zauber~~ → **ersetzt durch D9** | – |
| D9 | 2026-11-07 | Magie | **Einfache Volksmagie**: Runen & Zeichen, Segen & Flüche, Tränke & Salben, aktive Zauber. Zauber ersetzen vor allem anachronistische Technik (z. B. Geschütztürme → Runensteine mit Feuerpfeilen) | F-01, F-04, F-08, F-15 |
| D10 | 2026-11-07 | Sichtbarkeit der Magie | **Dezent**: Glimmen, Funken, Rauch, kleine Glutpfeile; keine Feuerbälle oder Blitze. Ausnahme: D38 | F-15, F-16 |
| D11 | 2026-11-07 | Fantasy-Kreaturen | **Wenige, folkloristisch** (Irrlicht, Nachzehrer, Moorgeist …), selten | F-06 |
| D12 | 2026-11-07 | Bedrohung & Grusel | **Deutlich stärker als Vanilla**: Folk-Horror-Ton, Säule P4 geschärft, neues Feature F-17 | GDD 1.1/2.2/3, F-06–F-09, F-17 |
| D13 | 2026-11-07 | Grusel-Intensitätsregler (Q15) | **Ja**: Server- bzw. Mod-Option aus / mild / voll | F-17 |
| D14 | 2026-11-07 | Furcht schwächt Mechanik (Q16) | **Ja**: Zittern beim Zielen, Panik usw.; Nahkampf bleibt nutzbar (P3) | F-17 |
| D15 | 2026-11-07 | Härtere Todesfolgen (Q17) | **Optional** (Server-Option, Standard aus); **kein Wiederaufstehen als Seuchentoter**; Details später | F-17 |

### 7.2 Technik & Projekt
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D3 | 2026-11-07 | Assets (Q3) | **Mix aus neuen Assets und Retexturen** ab Phase 2; MVP mit Vanilla-Modellen | F-16 u. a. |
| D4 | 2026-11-07 | Karte (Q4) | **RWG zuerst**, eigene Karte in Phase 4 | F-07 |
| D5 | 2026-11-07 | Kompatibilität (Q5) | **Kompatibel mit UI-Mods**: XUi-Änderungen nur additiv und zielgenau | Spec 01, F-12 |
| D6 | 2026-11-07 | Name (Q6) | **Später**; Arbeitstitel `7DTD_700` | F-12 |
| D7 | 2026-11-07 | Sprachen (Q7) | **DE + EN Pflicht** | F-12 |
| D45 | 2026-11-07 | Team | **Solo + Claude** → Umfang strikt begrenzen | Roadmap |
| D46 | 2026-11-07 | Veröffentlichung | **Erst intern, dann öffentlich** | Roadmap |
| D49 | 2026-11-07 | MVP-Fokus | **Setting-Umbau + Grusel** | Roadmap |
| D50 | 2026-11-07 | Umgang mit Umfang | **Strikt phasenweise**, jede Phase endet mit Playtest | Roadmap |

### 7.3 Kampf & Waffen
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D8 | 2026-11-07 | Armbrust | **Ja**, selten, T4/Endgame | F-02 |
| D20 | 2026-11-07 | Nahkampfgefühl | **Vanilla+**: Vanilla-Steuerung + Schild-Blocken + Waffeneigenschaften | F-02 |
| D21 | 2026-11-07 | Mechaniken | **Schild blocken, Verschleiß & Reparatur, Schadensarten (Schnitt/Stich/Wucht), Werfen von Nahkampfwaffen** | F-02, F-03 |
| D22 | 2026-11-07 | Fernkampf vs. Magie | **Gleichwertig**: zwei Spezialisierungen mit eigenen Stärken | F-02, F-15, F-21 |
| D23 | 2026-11-07 | Qualität | **Material als Grundstufe + Handwerksqualität als Feinstufe** | F-02, F-03, F-04 |

### 7.4 Handwerk, Fertigkeiten, Wirtschaft, Bauen
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D24 | 2026-11-07 | Rezept-Freischaltung (Q11) | **Learning by Doing**; die Grundfähigkeit muss per Skill-Punkt **oder** Abschrift vorhanden sein | F-04, F-21 |
| D25 | 2026-11-07 | Herstellungsketten | **Mittel**: 2–3 Stufen | F-04, F-05 |
| D26 | 2026-11-07 | Werkstatt-Bedingungen | **Brennstoff, Werkzeuge, Gesellen (NPC-Helfer)** | F-04, F-14 |
| D27 | 2026-11-07 | Tech-Tiers | **5 Tiers** (Überleben → Hof → Werkstatt → Burg → Meister) | GDD 3.1 |
| D47 | 2026-11-07 | Fertigkeitsbäume | **Komplett neu, 6 Bäume**: Krieger, Jäger, Handwerker, Runenkundiger, Heiler, Transport & Logistik | F-21 |
| D48 | 2026-11-07 | Technik Learning by Doing | **Claude entscheidet nach REA-Check**. Vorschlag in F-21: Vanilla-Crafting-Skill-System weiterverwenden, Fortschritt per Herstellen statt Lesen | F-21 |
| D28 | 2026-11-07 | Bauen | **Vanilla-Blocksystem umgedeutet** (Holz → Flechtwerk/Lehm → Fachwerk → Bruchstein → Mörtelstein) | F-18 |
| D29 | 2026-11-07 | Endgame-Basisschutz | **Gegner angepasst**: weniger Blockschaden durch Seuchentote, dafür mehr Gefahr für Spieler | F-06, F-18 |
| D30 | 2026-11-07 | Währung | **Nur Silber** (Vanilla-Dukes umgedeutet) | F-05 |
| D31 | 2026-11-07 | Knappheit | **Eisen knapp**, Holz/Stein/Lehm normal | F-05 |

### 7.5 Survival & Gesundheit
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D32 | 2026-11-07 | Nahrung | **Vanilla+ mit Verderb**; Konservieren durch Räuchern, Salzen, Trocknen | F-19 |
| D33 | 2026-11-07 | Landwirtschaft | **Ackerbau + Viehhaltung** | F-19 |
| D34 | 2026-11-07 | Temperatur/Wetter | **Wie Vanilla** | – |
| D35 | 2026-11-07 | Krankheiten | **Mehr Krankheiten**: Ruhr, Fieber, Wundbrand zusätzlich zum Seuchenbrand | F-11 |

### 7.6 Magie & Transport
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D36 | 2026-11-07 | Magiewert (Q14) | **Attribut + Kraftvorrat**: Baum *Runenkundiger* bestimmt den Zugang, **Odem** ist ein regenerierender Vorrat, den Zauber verbrauchen | F-15, F-21 |
| D37 | 2026-11-07 | Runenkraft (Q13) | **Kraftlinien** (Variante A): Vanilla-Stromnetz umgedeutet, nur XML | F-08, F-15 |
| D38 | 2026-11-07 | Hochmagie | **Endgame-Ausnahme von D10**: Seltene Endgame-Artefakte (Hexenbesen, Runenross, Wegsteine) dürfen sichtbarer sein, aber ohne Neon oder Blitze | F-13, F-15 |
| D16 | 2026-11-07 | Mobilität | **Karren, Packtier, Reitpferd** + **magische Fahrzeuge** (Hexenbesen, magisches Motorrad → „Runenross“) | F-13 |
| D17 | 2026-11-07 | Tempo | **Endgame-Tempo wie Vanilla**, aber teuer und selten, damit langsames Reisen der Normalfall bleibt. Pferde müssen gefunden werden und können sterben. Das magische Fahrzeug ist absolutes Endgame und braucht hohe Runenkunde | F-13 |
| D18 | 2026-11-07 | Schnellreise | **Magische Wegsteine**: selbst errichten **und** alte Steinkreise reaktivieren; Kosten pro Reise; in der Seuchennacht inaktiv | F-13, F-15 |
| D19 | 2026-11-07 | Fahrzeug-Perks | **Eigener Baum „Transport & Logistik“** | F-13, F-21 |

### 7.7 Gegner, Händler, Welt, Koop
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D39 | 2026-11-07 | Menschliche Gegner | **Plünderer + Seuchenkult** | F-20 |
| D40 | 2026-11-07 | Bestiarium | **Größer als Vanilla**: Varianten je Kulturzone | F-06 |
| D41 | 2026-11-07 | Händler | **Feste Handelsposten** (Kloster, Markt, Fürstenhof) mit Schutzzone wie Vanilla | F-10 |
| D42 | 2026-11-07 | Aufträge | **Vanilla umgedeutet + Bann-Aufträge + Lore-Ketten + Eskorte** | F-10 |
| D43 | 2026-11-07 | Biome (Q12) | **Kulturzonen als Biome** | F-06, F-07 |
| D44 | 2026-11-07 | Koop | **Gemeinsame Siedlung + Rollen-Synergien** | F-14, F-21 |

## 8. Offene Fragen

| ID | Frage | Blockiert |
|---|---|---|
| Q6 | Mod-Name / Branding (vertagt, D6) | öffentlicher Release |
| Q8 | Welche UI-Mods dienen als Kompatibilitäts-Referenz für Tests? | F-12 (Phase 1 Ende) |
| Q9 | Asset-Quellen: selbst modellieren, beauftragen oder lizenzierte Packs (CC0/kommerziell)? | F-16 (Phase 2) |
| Q10 | Ansteckung (Seuchenbrand) zwischen Spielern ja/nein? | F-11 (Phase 2) |
| Q17 | Härtere Todesfolgen: welche konkret? (Rahmen D15) | F-17 (Phase 2) |
| Q18 | Reitpferd: machbar ohne eigene Reit-Animationen? Klären per REA bzw. Prototyp vor Phase 3 | F-13 |
| Q19 | Plünderer und Kultisten: Gibt es in V2.x bereits menschliche Gegner (Banditen), auf denen wir aufbauen können? (REA) | F-20 |

---

## 9. Nicht-Ziele (v1)

- Keine High-Fantasy: keine Feuerbälle, Blitze, Zauberschulen, Fantasy-Völker oder
  Dämonen-Heere. Magie bleibt Volksmagie (D9/D10). Teleportation gibt es nur als seltene,
  teure Wegsteine (D18); sichtbarere Effekte nur bei Endgame-Artefakten (D38). Kreaturen
  bleiben wenige Sagengestalten (D11).
- Magie ersetzt **nicht** den Nahkampf als Kern (Säule P3). Fernkampf und Kampfmagie sind
  gleichwertige Spezialisierungen (D22), der Nahkampf bleibt die Basis aller Builds.
- Kein Splatter- oder Schock-Horror um seiner selbst willen: keine Dauer-Jumpscares,
  keine Bildschirmblitze, keine Gore-Eskalation über Vanilla hinaus.
- Keine Jahreszeiten- und keine Temperatur-Überarbeitung (D34).
- Keine mehreren Währungen und kein Tauschhandels-System (D30).
- Keine historisch-akademische Simulation (kein Lehnswesen-Management, keine Fruchtfolge-Sim).
- Kein Eingriff in Netcode-Grundlagen (keine eigenen NetPackages, solange es sich vermeiden lässt).
- Keine EAC-Kompatibilität für den C#-Teil; das ist bei DLL-Mods technisch nicht möglich.
- Keine Übernahme von Inhalten, Namen oder Assets anderer Mods oder Spiele.
