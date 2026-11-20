# Game Design Document — 7DTD_700

| | |
|---|---|
| **Version** | 0.1 (Entwurf) |
| **Stand** | 2026-11-07 |
| **Basisspiel** | 7 Days to Die **V 3.40, Build 10** (Steam-Branch `public`, Build 26309840) — aus dem Code gelesen, siehe [Baseline](rea/findings/00-build-baseline.md) und D52 |
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
| Bandits (falls in V 3.40 vorhanden) | Plünderer, Seuchenkult | F-20 |
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
- **Schnittstellen nicht raten:** Jeder Harmony-Patch-Zielpunkt wird vorher **statisch gegen
  die tatsächliche `Assembly-CSharp.dll` der Zielversion verifiziert** und in
  `docs/rea/findings/` dokumentiert. Werkzeuge (D51): **REA** für Artefakt-Identität,
  Klassifikation und Typ-Bestand, **`mod700meta`** für Member, Signaturen und Aufrufkanten —
  REA bricht bei dieser Assembly vor den Membern ab
  ([rea/findings/00-rea-grenzen.md](rea/findings/00-rea-grenzen.md)).
  Siehe [`rea/interface-discovery.md`](rea/interface-discovery.md) und
  [`../tools/meta/README.md`](../tools/meta/README.md).

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
| D51 | 2026-11-07 | Woher kommen Signaturen, nachdem REA an dieser Assembly keine Member liefert? | **Eigenes Werkzeug `mod700meta`** (`tools/meta/`, C#, nur `System.Reflection.Metadata`): liest Typen, Signaturen, Aufrufkanten und Zeichenketten statisch, ohne zu laden, auszuführen oder zu dekompilieren. REA bleibt für Artefakt-Identität und Klassifikation. `CLAUDE.md` Regel 2 gilt weiter, „REA-Finding“ heißt ab jetzt „Finding unter `docs/rea/findings/` mit nachprüfbarer Signatur“. Anlass: [00-rea-grenzen.md](rea/findings/00-rea-grenzen.md) | CLAUDE.md, Spec 01, alle REA-Features |
| D52 | 2026-11-07 | Die Planung nannte „V2.x Stable“ als Zielplattform, installiert ist **V 3.40 (Build 10)**. Welche Fassung gilt? | **Dokumente auf V 3.40 ziehen.** „V2.x“ war eine Annahme der Cloud-Session, die keinen Zugriff auf die Spieldateien hatte; kein Rückbau über einen Steam-Beta-Zweig. Zielplattform ist damit der installierte Build. Alle Hypothesen und `[verifizieren]`-Marken gelten gegen V 3.40, nicht gegen V2.x | GDD-Kopf, CLAUDE.md, Spec 01, README, hook-hypothesen, F-15/F-19/F-20/F-21 |
| D53 | 2026-11-07 | Spec 01 §2 legte **ein** Modlet fest (`Mods/7DTD_700/` mit einem `Config/`). Phase 1 ändert `items.xml` aus fünf Features. Ein Modlet oder mehrere? | **Mehrere Modlets**, eines je Feature-Gruppe, Ladereihenfolge über ein Zahlenpräfix im Ordnernamen (`700_00_Core`, `700_10_Purge`, …). Anlass: belegt kann ein Modlet nur **eine** Datei je Vanilla-Config tragen (`XmlPatcher::LoadAndPatchConfig` sucht `<Modlet>/Config/<gleicher Name>`), sonst lägen F-01 bis F-05 zusammen in einer `items.xml` und keine Schicht wäre einzeln abschaltbar. Tragfähig, weil `ModManager::loadModsFromFolder` die Ordner mit `System.Array::Sort` selbst sortiert — die Reihenfolge hängt **nicht** am Dateisystem und gilt auch auf dem Linux-Server. Es gibt kein `LoadBefore`/`LoadAfter`, der Ordnername ist der einzige Hebel. Beleg: [WP1-modlet-lader-und-xml-patcher.md](rea/findings/WP1-modlet-lader-und-xml-patcher.md) | Spec 01 §2, Verträge 01–03, Build-Skript, Plan-0001 WP1 |
| D54 | 2026-11-07 | Bögen, Armbrüste, Pfeile und Bolzen heißen in Vanilla `gunBow*` und `ammoArrow*`/`ammoCrossbowBolt*`. Die Denylist von F-01 nahm sie über `gun*` und `ammo*` mit — 27 Kennungen. Sperren und neu bauen, oder umdeuten? | **Vanilla-Items umdeuten, nicht sperren.** Sie bleiben in Phase 1 erreichbar; WP5 (F-02) gibt ihnen Namen, Werte und Rezepte als Schleuder (T0), Selbstbogen (T1), Langbogen (T3) und Armbrust (T4, D8). Anlass: Säule P3 nennt Fernkampf als **gleichwertige** Spezialisierung und D8 die Armbrust ausdrücklich — gesperrt hätte Phase 1 keine Fernkampfwaffe gehabt, und WP5 müsste Rezepte, Loot und Perk-Anbindung neu anlegen, was die Vanilla-Items schon mitbringen. Der Name ist ein Sprachproblem (F-12), kein Inhaltsproblem | F-01, F-02, F-12, `tools/check/denylist.txt`, Plan-0001 WP3/WP5 |
| D55 | 2026-11-07 | Die Denylist verbot `resourceForgedSteel` als „industrielles Stahlprodukt“ (F-01). D23 nennt Stahl aber als Materialstufe und das GDD die T3-Stufe „Stahl (Damaszierung)“. Was gilt? | **Schmiedestahl bleibt erreichbar**, die Verbotszeile entfällt. WP4 deutet ihn zum Schmiedestahl der Rennofen-Kette um. Gesperrt bleiben die industriellen Stahl**produkte** (`resourceSteel*`, `blockSteel*`, `blockRebar*`). Anlass: „Stahlprodukte industrieller Art“ in F-01 meinte Fertigteile und Stahlblöcke, nicht den Werkstoff, auf dem die Materialstufen von D23 und die T3-Stufe aufbauen | F-01, F-02 (D23), F-04, F-18, `tools/check/denylist.txt` |
| D56 | 2026-11-07 | `medical*` sperrte auch Wundauflage, Schiene und Salbe. Ihr Ersatz kommt mit F-11, das in Phase 2 liegt. Hat Phase 1 Heilung? | **Verband, Schiene und Salbe bleiben erreichbar** (`medicalBandage`, `medicalFirstAidBandage`, `medicalSplint`, `medicalAloeCream`) und werden in WP8 über die Sprachdatei zu Wundauflage, Schiene und Kräutersalbe. **F-11 bleibt Phase 2** — diese vier sind keine Vorwegnahme, sondern plausible Vanilla-Gegenstände, die stehen bleiben. Gesperrt bleiben Verbandskasten, Blutkonserve, Gipsverband (Gipsschienen sind erst ab dem 10. Jh. belegt, die Schiene deckt dieselbe Funktion), Fertigkeitsheft und die drei Drogen. Anlass: ohne sie hätte Phase 1 außer Essen und Schlaf keine Heilung, ein Beinbruch wäre bis Phase 2 nicht behandelbar | F-01, F-11, F-12, `tools/check/denylist.txt`, Plan-0001 WP3 |

### 7.3 Kampf & Waffen
| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D8 | 2026-11-07 | Armbrust | **Ja**, selten, T4/Endgame | F-02 |
| D20 | 2026-11-07 | Nahkampfgefühl | **Vanilla+**: Vanilla-Steuerung + Schild-Blocken + Waffeneigenschaften | F-02 |
| D21 | 2026-11-07 | Mechaniken | **Schild blocken, Verschleiß & Reparatur, Schadensarten (Schnitt/Stich/Wucht), Werfen von Nahkampfwaffen** | F-02, F-03 |
| D22 | 2026-11-07 | Fernkampf vs. Magie | **Gleichwertig**: zwei Spezialisierungen mit eigenen Stärken | F-02, F-15, F-21 |
| D23 | 2026-11-07 | Qualität | **Material als Grundstufe + Handwerksqualität als Feinstufe** | F-02, F-03, F-04 |
| D58 | 2026-11-08 | F-02 nennt die **Machete** als Vanilla-Basis für Sax und Spatha und die **Feuerwehraxt** für die Breitaxt. WP3 hat beide gesperrt (`meleeWpnBladeT3Machete*`, `meleeToolAxeT1IronFireaxe`), und Vanilla hat gemessen kein weiteres Klingenmodell über Messerlänge und keine zweite lange Axt. Sperren und auf Messer bauen, oder umdeuten? | **Umdeuten, nicht sperren** — derselbe Weg wie D54 (Bögen) und D55 (Schmiedestahl). Die Freigaben kommen in die Denylist, WP5 gibt beiden Namen, Werte und Rezepte: Machete → **Spatha** (T3/T4, Allrounder), Feuerwehraxt → **Breitaxt** (T3/T4, schwer). Anlass: eine Spatha, die vom Jagdmesser erbt, schlägt und sieht aus wie ein Messer; F-16 nennt Spatha und Breitaxt ohnehin bei den Phase-2-Modellen, bis dahin tragen sie das Vanilla-Modell. Der Name ist ein Sprachproblem (F-12), kein Inhaltsproblem | F-01, F-02, F-12, F-16, `tools/check/denylist.txt`, Plan-0001 WP5 |
| D59 | 2026-11-08 | F-03 baut auf fünf Vanilla-Rüstungsgarnituren (Primitive/Leather/Padded/Military/Steel). Die gibt es in V 3.40 nicht: gemessen 178 Rüstungsteile in ~40 Garnituren, davon **erreichbar sechs** — die vier `armorPrimitive`-Teile, `armorParts` und das Fertigkeitsheft (zu WP7 aufgeschoben). Alle übrigen sind DLC- und Event-Garnituren ohne Rezept, Loot oder Händler. Woraus entsteht T1 bis T4? | **Eigene Rüstungsteile auf Vanillas drei Gewichtsklassen.** `armorLightMaster`, `armorMediumMaster` und `armorHeavyMaster` sind die Basisklassen; wir erben davon: T1 Wolle/Leder leicht, T2 Gambeson mittel, T3 und T4 Kette schwer, je vier Slots (Rumpf, Kopf, Hände, Füße). `armorPrimitive*` bleibt T0 und wird nur umgedeutet. Modelle (`Meshfile`) borgen wir aus den gesperrten Garnituren — **der Purge nimmt Wege, keine Meshes** —, Retextur und eigene Modelle regelt Phase 2 (D3, F-16). Anlass: F-03s Tabelle beschreibt eine ältere Spielfassung; die 16 gesperrten Garnituren wieder freizugeben hieße Warnweste, Schutzhelm und Kevlar zurückholen (siehe Denylist-Kommentar) und vier D-Zeilen Rückbau an WP3 | F-03, F-16, Plan-0001 WP5.5 |
| D60 | 2026-11-08 | F-02 will Reparatur mit **Schleifstein, die Maximal-Haltbarkeit kostet**, und volle Reparatur an der Esse. Gemessen kennt Vanilla nur `RepairTools`, `RepairAmount`, `RepairTime` und die `Degradation*`-Werte — einen Verlust an Maximal-Haltbarkeit gibt es ohne C# nicht, und Phase 1 soll ohne Harmony-Patch bleiben. | **Zwei Reparatur-Gegenstände, reines XML.** **Schleifstein** überall herstellbar, kleiner `RepairAmount`, repariert also nur teilweise; **Schmiedeflicken** nur an der Esse herstellbar, voller `RepairAmount`. Die Esse wird damit über das **Rezept** zur Bedingung, nicht über den Reparaturvorgang. Der **Verlust an Maximal-Haltbarkeit wandert nach Phase 2** und bekommt dort Finding und Patch-Manifest-Eintrag — das verfeinert D21, hebt es nicht auf. Beide ersetzen Vanillas `resourceRepairKit`, der genau dafür zu WP5 aufgeschoben war. Anlass: der erste Harmony-Patch der Phase 1 wäre für eine Feinheit des Verschleißes zu teuer; ohne jede Reparatur wäre das Spiel die härtere Abweichung | F-02, F-03, D21, `tools/check/aufschub.txt`, Plan-0001 WP5.4 |
| D61 | 2026-11-08 | V 3.40 hat **keine Rüstungsstufen**: gemessen sind drei Gewichtsklassen plus Qualität 1–6, und `PhysicalDamageResist`, `DegradationMax` und `Mobility` hängen **allein an der Klasse** — zwei Garnituren derselben Klasse haben dieselben Zahlen. F-03s Tabelle will fünf Stufen T0–T4. Fünf auf drei geht nicht auf. | **Drei Rüstungsstufen plus T0.** T0 Lumpen (`armorPrimitive*`, nur umgedeutet), T1 Wolle und Leder (leicht), T2 Gambeson (mittel), T3 Kettenhemd (schwer). **T4 wird die Qualitätsspitze des Kettenhemds statt eines eigenen Gegenstands** — D23s zwei Achsen bleiben damit genau so, wie sie gedacht waren: Material als Grundstufe, Handwerksqualität als Feinstufe. Geborgt wird **zweierlei, und beides unabhängig voneinander**: der **Prefab-Pfad** bestimmt das Aussehen (T1 `Gear/Stealth/`, T2 `Gear/Assassin/`, T3 `Gear/Raider/`), die **`ArmorGroup`** den Set-Bonus (T1 `groupNomad` — weniger Nahrung und Wasser je Ausdauerpunkt; T2 `groupAssassin` — Gegner verlieren die Spur schneller, weil gesteppter Stoff leise ist; T3 `groupRaider` — 20 bis 45 % weniger kritische Verletzungen, Kette gegen Schnitt). Unsere Teile tragen die Zahlen ihrer Gewichtsklasse und **keine Slot-Vergünstigungen** (Vanillas Tragkraft, Laufgeschwindigkeit, Schleichbonus); die gehören in die Balancing-Tabelle WP5.6. Anlass: ein T4, das genauso schützt wie T3, ist eine Enttäuschung, sobald jemand die Werte vergleicht; eigene Resist-Staffeln wären erfundene Zahlen ohne Balancing-Grundlage und stünden bis WP9 still | F-03, F-16, D23, Plan-0001 WP5.5, `docs/rea/findings/WP5-ruestung-in-v340.md` |
| D62 | 2026-11-08 | D60 nennt **zwei** Reparatur-Gegenstände, und beide sind für Metall: der Schleifstein schärft eine Schneide, der Schmiedeflicken setzt Eisen ein. Die fünf Rüstungs-Basisklassen zeigen aber alle auf das gesperrte `resourceRepairKit` — ohne Zutun wäre die ganze Rüstung aus WP5.5 unreparierbar, und ein Wetzstein am Wollhemd liest sich falsch. | **Vanillas Nähzeug wird der dritte Reparatur-Gegenstand.** `resourceSewingKit` steht in der Denylist schon als **Freigabe** („Nadel und Faden") und trägt in Vanilla die Tags `armorLightSkill`, `armorMediumSkill`, `armorHeavySkill`. Es fehlen ihm gemessen zwei Dinge, und WP5.5 gibt beide: **ein Rezept** (in ganz `recipes.xml` kommt der Name nicht als Rezeptname vor — es gibt das Nähzeug nur aus Loot und beim Händler) und **einen `RepairAmount`** (ohne den gibt ein Gegenstand beim Reparieren keine Haltbarkeit zurück). T0, T1 und T2 flicken damit **voll**, das Kettenhemd mit dem **Schmiedeflicken** — D60s Teilung „teilweise überall, voll an der Esse" hängt an der **Schneide**, und Tuch näht man ganz. Die Esse bleibt also genau dort Bedingung, wo Eisen im Spiel ist. **D62 ergänzt D60, es hebt es nicht auf.** Anlass: ein vierter eigener Gegenstand hätte dasselbe getan und das vorhandene Nähzeug ungenutzt liegen lassen | F-02, F-03, D60, D21, `tools/check/aufschub.txt`, Plan-0001 WP5.5 |

| D63 | 2026-11-08 | Die oberste Baustufe (Mörtelstein) braucht eine Zutat, und `UpgradeBlock` nimmt **genau eine**. `resourceConcreteMix` und `resourceCement` stehen auf der Denylist (denylist.txt:73/74), ebenso die Sammelblöcke `concreteShapes*` und `steelShapes*`. Damit endet der Bauweg heute bei Pflasterstein — und der **Kalkofen aus WP4.3 hat kein Erzeugnis**, denn sein einziges Produkt war gesperrt. Dieselbe Art Loch wie die vier unbaubaren Werkstätten. | **Vier Kennungen werden umgedeutet statt ersetzt** (P5): `resourceCement` → **Branntkalk**, `resourceConcreteMix` → **Mörtel**, `concreteShapes` → **Bruchstein**, `steelShapes` → **Mörtelstein**. Historisch tragfähig und **ohne eine Zeile Rezeptarbeit**, weil Vanillas Ketten schon das Richtige tun: `resourceCement` entsteht am Ofen aus **10 geschmolzenem Stein** — genau Kalkbrennen; `resourceConcreteMix` entsteht am **Kalkofen** (`cementMixer`, nach WP4.3 schon so umgedeutet) aus **Sand + Stein + Branntkalk** — genau Kalkmörtel. Die Römer nannten den Zuschlag *caementum*, und im Kirchenbau um 700 war Kalkmörtel in Gebrauch. Ein eigener Gegenstand `itm700_moertel` wäre die Alternative gewesen und hätte denselben Weg nachgebaut. **Vom Nutzer entschieden am 2026-11-08** (AskUserQuestion, Projektregel 4) | F-01, F-18, D53, Plan-0001 WP6.1, `tools/check/denylist.txt` |
| D64 | 2026-11-08 | WP6.5 will Brenndauer per `Class="PlantGrowing"`. Gemessen (`docs/rea/findings/WP6-brenndauer-und-blockschaden.md`): `UpdateTick` ruft als zweites `CheckPlantAlive`, und das ersetzt den Block bei Nichterfüllung durch **Luft** — er geht dann nicht aus, er verschwindet. Dass die drei Tore (`FertileLevel`, `LightLevelStay`, `LightLevelGrow`) mit `0` offen sind, belegt Vanilla mit `plantedMushroom1`; dass es auch mit **Luft darunter** trägt, belegt es nicht, und eine Wandfackel hat Luft darunter. | **Alle vier Lichtquellen bekommen `PlantGrowing`, auch die Wandfackel** — das Risiko wird bewusst getragen und im Spieltest WP6.6 beantwortet. Fällt es falsch aus, verliert der Spieler die Fackel und die Wand bleibt leer, und es fällt erst nach der eingestellten Brenndauer auf; der Test muss also ausdrücklich eine **Wandfackel in einem geschlossenen Raum** abbrennen lassen, nicht nur eine im Freien. Die Gegenentwürfe waren „nur bodenständige Lichtquellen" (nichts kann verschwinden, F-08 hält sein Versprechen halb) und „gar keine Brenndauer". **Vom Nutzer entschieden am 2026-11-08** (AskUserQuestion, Projektregel 4). Bekannte Nebenwirkung, ebenfalls gemessen: `GetTickRate` multipliziert die Brenndauer mit einem spielweiten `CropGrowthModifier` — wer die Pflanzenwachstums-Einstellung des Servers dreht, dreht die Brenndauer mit | F-08, Plan-0001 WP6.4, WP6.5, WP6.6 |

| D65 | 2026-11-08 | D29 verlangt „weniger Blockschaden durch Seuchentote, damit Mörtelstein etwa so hält wie Vanilla-Stahl". Nach der Zuordnung aus WP6.1 (D63) **ist** Mörtelstein Vanilla-Stahl: derselbe Block `steelShapes`, dasselbe Material `Msteel_shapes`, dieselben **10 000** `MaxDamage`, unverändert. Die Schlagzahlen gelten damit Zeile für Zeile genauso für Vanilla — das Ziel von D29 steht, bevor eine Gegner-Zahl angefasst wird. Ein Abschlag würde unsere Basen also **stärker** machen als Vanillas, nicht gleich stark; dazu wirkt D64 im selben Paket in dieselbe Richtung (Fackeln ziehen keine Schreier mehr). | **Die erste Hälfte von D29 wird aufgehoben: der Blockschaden der Toten bleibt, wie Vanilla ihn setzt.** WP6.3 ändert keine Zahl. Die zweite Hälfte („mehr Gefahr für Spieler", `DamageEntity`) bleibt und gehört zu F-06/F-17. **Was offen bleibt und nur ein Spieltest zeigt:** unser T4 braucht Stein, Lehm und Sand — 146 Stein für die ganze Treppe von T0 bis T4 —, Vanillas Stahl braucht Erz, Tiegel und eine Fertigkeit. Ist T4 bei uns deutlich früher erreichbar, hält eine Basis früher 40 Schläge eines höllischen Toten aus, ohne dass eine Zahl falsch wäre. Dafür liegt ein **gemessener, ungenutzter Hebel** bereit: `MaterialBlock::MaxIncomingDamage` deckelt den Schaden **je Schlag** und steht in `GetDamageBlock` als `FastMin` am Ende der Rechnung; Vorgabe ist `int.MaxValue`, in ganz `materials.xml` ist er genau einmal gesetzt (`MtwitchHordeStone` auf 25). Drei Zeilen, nur unsere Baustufen, keine Nebenwirkung auf POIs oder Sprengkörper — **nach WP6.7, nicht vorher.** Der dritte Weg (die ~45 `DamageBlock`-Werte der Toten senken, wie der Plan es sagt) wurde verworfen: er trifft auch POI-Wände, Türen und Fahrzeuge, und es ist ungelöst, ob `Action0/DamageBlock` oder das geerbte `passive_effect BlockDamage` wirkt. **Vom Nutzer entschieden am 2026-11-08** (AskUserQuestion, Projektregel 4) | F-06, F-18, D29, D63, D64, Plan-0001 WP6.3, WP6.7, `docs/balancing/0002-wp6-bauen-licht-und-blockschaden.md` §3 |
| D66 | 2026-11-08 | F-21 verlangt **sechs** Fertigkeitsbäume, darunter den **Runenkundigen** (Magie, Odem, Runen). Magie ist aber F-15 und damit ausdrücklich Phase 2 (D50: Phasen strikt). Von den sechs Bäumen hätten fünf in Phase 1 Inhalt — Krieger, Jäger, Handwerker, Heiler und Transport lassen sich aus den **47 überlebenden Vanilla-Perks** füllen —, der Runenkundige hätte **keinen einzigen**: in ganz Vanilla gibt es keinen magischen Perk, und `attIntellect` trägt nur Elektrik, Geschütztürme und Fahrzeuge, alles gesperrt. Dazu die zweite Frage: eigene Attribute anlegen oder die fünf Vanilla-Attribute umdeuten? | **Fünf Bäume in Phase 1, und sie SIND die fünf Vanilla-Attribute (Umdeutung, nicht Ersatz).** Der Runenkundige kommt mit seinem Inhalt in Phase 2, genau wie D57 es mit den drei Werkstätten ohne Rezepte gemacht hat — ein Baum, in den man Punkte stecken kann, ohne dass etwas passiert, ist dieselbe Enttäuschung wie eine Werkstatt ohne Rezept. **Folge, die ausdrücklich getragen wird:** D22 („Fernkampf und Magie gleichwertig") ist in Phase 1 nicht erfüllt, weil es keinen magischen Fernkampfweg gibt; der Jäger steht allein. **Die Zuordnung steht auf den Gegenstands-Marken, nicht auf den Perk-Namen** (gemessen, `docs/rea/findings/WP7-fertigkeitsbaeume.md` §2.2): jedes Attribut wirkt nur auf Gegenstände, die seine Marke tragen, und nach dem Purge bleiben `attStrength` 18 Marken (Äxte, Hacken, Schaufeln, Hammer) → **Handwerker**, `attAgility` 17 (Bögen, Armbrüste, Pfeile, Messer) → **Jäger**, `attFortitude` 4 (Schlagringe, bloße Hand) → **Krieger**, `attPerception` 4 (Speere) → **Fuhrmann**, `attIntellect` 0 → **Heiler**. Darum ist `attAgility` der Jäger, obwohl die Fährtenlese-Perks in `attPerception` liegen: der Bogen hängt an `attAgility`, und Marken wandern nicht von allein. Umgedeutet statt angelegt, weil der Code gemessen an **zwei** Namen hängt (`attFortitude` in `EntityPlayerLocal::Update`, `attcrafting` in `XUiC_CategoryList::SetupCategoriesByWorkstation`, in 54 940 Methodenkörpern die einzigen beiden): ein umbenanntes Attribut nimmt keine Code-Zeile mit, ein gelöschtes schon. Sechs Bäume wären technisch gegangen — `XUiC_SkillList::updateFilteredList` zählt nichts ab —, es ist eine Inhalts-, keine Technikfrage. **Der Name des fünften Baumes ist „Fuhrmann", nicht „Transport & Logistik"**: alle fünf sind damit Personen (Handwerker, Krieger, Jäger, Heiler, Fuhrmann), und „Logistik" ist ein Wort des 19. Jahrhunderts. Die Rolle aus F-21 bleibt unverändert. **Vom Nutzer entschieden am 2026-11-08** (AskUserQuestion, Projektregel 4) | F-21, F-15, D22, D24, D36, D47, D50, D57, Plan-0001 WP7, `docs/rea/findings/WP7-fertigkeitsbaeume.md` |
| D67 | 2026-11-08 | Wie dicht werden die fünf Bäume? Vanilla führt 57 Perks auf fünf Attribute, also knapp zwölf je Attribut; zehn davon sind nach dem Purge ohne Gegenstände. Eine schlanke Fassung (~5 je Baum) wäre schneller fertig, erfüllt das F-21-Kriterium „tragfähiger Build bis T4" aber knapp; ein einzelner Musterbaum zuerst hätte einen zusätzlichen Spieltest gekostet. | **Vanilla-Dichte, rund neun Perks je Baum** (45–54 insgesamt), drei Unterbereiche je Baum wie Vanillas 16 `skill`-Knoten. Tragfähig ohne viel Erfindung, weil die Rechnung aufgeht: 57 Vanilla-Perks minus die zehn toten sind **47**, und 47 auf fünf Bäume ist genau diese Dichte — die Perks werden also überwiegend **umgehängt und umbenannt**, nicht neu erfunden (WP7.2). Preis: viele eigene Beschreibungstexte in DE und EN; allein die fünf Attribute kosten 115 Localization-Schlüssel. **Vom Nutzer entschieden am 2026-11-08** (AskUserQuestion, Projektregel 4) | F-21, D7, D66, Plan-0001 WP7.2 |
| D68 | 2026-11-08 | Nach WP7.2 tragen **Handwerker und Heiler nur vier Perks** statt der rund neun aus D67. Das ist das Ergebnis des Purge und keine Entscheidung: Vanillas `attIntellect` trug Elektrik, Geschütztürme und Fahrzeuge — alles gesperrt —, und von `attStrength` sind die Keulen mit ihren Perks zum Krieger gewandert. Krieger 9, Jäger 12, Fuhrmann 9. Vier Perks sind kein Baum. | **Die 14 überlebenden Handwerks-Stufen wandern von `attCrafting` an die Bäume** und werden damit deren Tiefe: Werkzeugschmiede, Flickwerk, Werkstattbau und Rüstungsbau zum **Handwerker**; Schlagringe, Keulenbau und Hammerbau zum **Krieger**; Klingenschmiede, Bogenbau und Speerbau zum **Jäger**; Wundversorgung, Küche und Kräutergarten zum **Heiler**; Sattlerei zum **Fuhrmann**. Je ein `<set>` auf `@parent`, **keine erfundene Zahl** — und sie tragen echten Inhalt: `craftingWorkstations` behält gemessen 15 von 20 Freischalt-Marken, `craftingHarvestingTools` 8 von 10, `craftingFood` 9 von 37, `craftingMedical` 1 von 8. Damit hat der Handwerker 4 Perks plus 4 Handwerks-Stufen, der Heiler 4 plus 3. **`attCrafting` bleibt bestehen** (die Zeichenkette `attcrafting` steht in `XUiC_CategoryList::SetupCategoriesByWorkstation`) und wird nur **verborgen**, weil es nach dem Umhängen ein leerer Behälter mit Vanilla-Namen wäre. **Risiko R8, bewusst getragen:** dass die genannte Methode die Handwerks-Stufen nicht braucht, ist ein Schluss aus ihrer Aufrufliste — sie filtert `get_IsAttribute` und nutzt nur `ProgressionClass::Name` und `::Icon`, und `Hidden` liest sie gemessen nicht —, aber beobachtet ist es nicht. Fällt es falsch aus, fehlen Kategorie-Knöpfe an den Werkbänken (Prüfliste 15). Der Gegenentwurf „vier bis fünf eigene Perks je Baum erfinden" wurde verworfen: er braucht Zahlen ohne Balancing-Grundlage, und D61 hat denselben Fall bei den Rüstungsstufen schon einmal so entschieden. **Zweite Hälfte derselben Frage:** die **Rang-Texte** der Perks (fünf Rangnamen und fünf Langtexte je Perk, rund 450 Schlüssel) bleiben vorerst Vanilla-Englisch und gehören zu **WP8.5** — sie beschreiben die Wirkung, und die ändern wir nicht, also sind sie englisch und nicht falsch. **Beides vom Nutzer entschieden am 2026-11-08** (AskUserQuestion, Projektregel 4) | F-21, F-04, D61, D66, D67, D7, Plan-0001 WP7.2, WP8.5, `docs/rea/findings/WP7-fertigkeitsbaeume.md` §6.4 |
| D69 | 2026-11-16 | Vanillas **Buchsystem** (133 Bücher in 19 Reihen) stand seit dem 2026-11-07 als Aufschub „fällt mit F-21 in WP7". Gemessen ist es kein Block: **sechs** Reihen sind tot (nicht acht, wie die Denylist schrieb), dreizehn leben — und in vier der lebenden stecken **sechs tote Einzelbände** (`perkArtOfMiningCoffee`, `perkArtOfMiningBlackStrap`, `perkFiremansAlmanacAxes`, `perkFiremansAlmanacEquipment`, `perkUrbanCombatCigar`, `perkWasteTreasuresWater`). Der Reihen-Abschluss verlangt aber alle sieben: `PerksUnlocked >= 7`, zweimal in jedem der 133 Buch-Gegenstände. Ein gesperrter Band macht den Abschluss seiner Reihe unerreichbar, ohne Fehlermeldung. | **Die Bücher werden Abschriften — umgedeutet, nicht ersetzt** (wie D66 die Attribute und WP4 die Währung). **13 Reihen bleiben** mit eigenem Namen (Bergmannskunde, Vom Keulenschlag, Vom Faustkampf, Köhlerweisheit, Diebeshandwerk, Vom Waidwerk, Finderglück, Der Nachtgänger, Bogenlehre, Vom Hammerschlag, Speerlehre, Kampf in Mauern, Brachlandschätze), ihre Bände heißen „‹Reihe›, Blatt *n* von *N*". **6 Reihen fallen** (AutoWeapons, Enforcer, PistolPete, Shotguns, Sniper, TechJunkie): Reihe und Knoten verborgen, 42 Gegenstände gesperrt. **Die sechs toten Einzelbände fallen ebenfalls, und die Schwelle sinkt auf die Zahl der lebenden Bände** — Bergmannskunde und Köhlerweisheit 5, Kampf in Mauern und Brachlandschätze 6. Die Zahl ist gemessen, nicht erfunden; **vom Nutzer entschieden am 2026-11-16** (AskUserQuestion, Projektregel 4) gegen „als leere Blätter behalten" und „vorerst nicht anfassen". **Wie ein toter Band verschwindet, hat die Messung entschieden, nicht der Plan:** das Buchfenster liest `hidden` an einem `<book>` nicht (`Progression::GetPerkList` vergleicht nur den Elternnamen), es nummeriert die Kinder der Reihe nach ihrer Stelle und nennt das letzte den Abschluss. Ein toter Band wird darum an eine tote, verborgene Reihe **umgehängt** (`skillTechJunkie` als Ablage) — nur so verlässt er das Fenster seiner Reihe und die Zählung von `PerksUnlocked`. **Zwei Abschlüsse wirken auf nichts mehr** (Kampf in Mauern: Schalldämpfer; Brachlandschätze: legendäre Teile). Ihr Knoten muss bleiben, weil das Fenster den letzten Knoten den Abschluss nennt; ihr Text sagt jetzt „Diese Reihe schließt ohne eigene Lehre." **Nicht gemacht, wie bei D68:** die Wirkungstexte der Bände (`desc_key`, `long_desc_key`, rund 200 Schlüssel) bleiben Vanilla und gehören zu WP8.5. **Berichtigung zu D68:** dort steht, die Rang-Texte blieben „Vanilla-Englisch". Gemessen führt Vanillas `Localization.csv` für sie eine deutsche Spalte (`perkDeepCutsRank1Desc` → „Stumpfe Klinge") — wer deutsch spielt, liest sie deutsch. Die Entscheidung bleibt, ihr Grund war ungenau. **Weiter aufgeschoben, mit neuer Adresse WP7.5:** die 26 Fertigkeitshefte (`*SkillMagazine`) und `resourcePaper` — die Hefte heben die Handwerks-Stufen, an die WP7.5 die Rezepte bindet. | F-21, F-01, D24, D47, D50, D66, D68, Plan-0001 WP7.4, `tools/gen/wp7-abschriften.ps1`, `docs/rea/findings/WP7-fertigkeitsbaeume.md` §7 |
| D70 | 2026-11-16 | D24 verlangt, dass ein Rezept ohne Grundfähigkeit gesperrt ist. Unsere **42 eigenen Rezepte** (WP4–WP6) trugen keine `tags` und waren damit von Anfang an bekannt. Gemessen ist das mehr als eine fehlende Sperre: der Lader (`RecipesFromXml.LoadRecipies`) hängt den Rezeptnamen nur dann an die Marken, wenn das Rezept **überhaupt** ein `tags`-Attribut hat — ohne `tags` trifft keine Zeile `RecipeTagUnlocked` oder `CraftingTier` das Rezept. Unsere elf Waffen und zwölf Rüstungsteile hatten also auch **keine Qualitätsleiter**. Woran wird gebunden, und was bleibt offen? | **„Vanillas Linie": jedes Rezept so, wie Vanilla sein Gegenstück behandelt** — **vom Nutzer entschieden am 2026-11-16** (AskUserQuestion, Projektregel 4) gegen „Alles außer T0 binden" und „Nur die 11 mit Vanilla-Daten". **24 gebunden, 18 offen.** *Gebunden:* die **elf** Waffen- und Werkzeugrezepte mit Vanilla-Namen bekommen Vanillas eigene Marken zurück und hängen an Vanillas eigener Stufe mit Vanillas Level (Sax, Speer, Eisenfaust, Hammer und Breitaxt ab **11**, Bartaxt ab **26**, die fünf T3-Fassungen ab **36**); die **zwölf** Rüstungsteile hängen an `craftingArmor` ab **11** mit der Qualitätsleiter 20/40/60/80/100, abgelesen von der Zeile, die ihre Basisklassen `armorLight/Medium/HeavyMaster` führt; der **Webstuhl** hängt an `craftingWorkstations` ab **14**. *Offen:* die Materialkette (Luppe, Schmiedeeisen, Tiegelstahl, Klinge — Vanilla macht Schmiedeeisen und Stahl nicht `learnable`, die Schranke ist das Werkzeug im Ofen), Schleifstein und Schmiedeflicken (D60), Nähzeug, Steppbahn, Holzfeuer und die neun Bauteile aus WP6.2 (Vanilla bindet keine Bauteile, eine Stufe fürs Bauen gibt es nicht). **Die Zahlen sind gelesen, nicht gesetzt — mit einer Ausnahme:** der Platz des Webstuhls. Er nimmt den ersten Platz, den der Purge **nach** der Werkbank freigemacht hat (`toolChickenCoopLamp`, Level 14), weil er an der Werkbank entsteht. **Die Bindung hat eine Quelle:** `mod/700_50_Fortschritt/Config/recipes.xml` setzt die `tags` per `<setattribute>`; die Rezepte in 700_20/30/40 tragen keine. Fehlt 700_50, sind alle Rezepte offen und nichts bricht. **Fertigkeitshefte werden Lehrblätter.** Eine Handwerks-Stufe steigt gemessen **nur** durch ihr Heft (`AddProgressionLevel` im Gegenstand; das Handwerksfenster hat keinen Kaufweg). Eine gebundene Stufe ohne Heft wäre eine Sackgasse — darum sind die Hefte der **14** lebenden Stufen als „Lehrblatt: ‹Stufe›" umgedeutet und freigegeben, die der **10** toten gesperrt. **Papier wird Pergament** (`resourcePaper`, nur umbenannt) — **vom Nutzer entschieden am 2026-11-16** gegen „sperren". Damit ist der Aufschub `*SkillMagazine` und `resourcePaper` eingelöst. **Vier Folgen, die diese Zeile nicht entscheidet:** (1) **D24s Weg „per Skill-Punkt" gibt es für Handwerks-Stufen in Phase 1 nicht** — nur den Weg über das Lehrblatt. D24 ist damit nicht geändert, aber nur zur Hälfte gebaut; ob die andere Hälfte in Phase 1 nachgebaut wird oder mit Learning by Doing in Phase 2 kommt, ist offen. (2) Alle drei Rüstungsstufen öffnen bei demselben Level 11, weil Vanilla eine Zeile für alle Garnituren führt; die Stufe trennt allein der Werkstoff. (3) Der Schmelztiegel öffnet erst bei Werkstattbau **75** — Tiegelstahl und damit jede T3-Waffe hängt an dieser Zahl, nicht an den 36 ihrer eigenen Stufe. (4) Qualität 6 kostet bei uns nur die Stufe: Vanilla verlangt dort ein legendäres Teil, unsere Rezepte führen es nicht (D23 lässt das offen). (2) bis (4) sind Vanillas Zahlen und gehören zu WP9. **Das Bündel `questRewardT1SkillMagazineBundle` bleibt gesperrt** (Regel `questReward*Bundle`); ob Lehrblätter Auftragslohn werden, entscheidet F-10. | F-21, F-04, F-02, F-03, D23, D24, D53, D59, D60, D61, D68, D69, Plan-0001 WP7.5, `tools/gen/wp7-bindung.ps1`, `docs/rea/findings/WP7-fertigkeitsbaeume.md` §8 |
| D71 | 2026-11-16 | D70 hat offen gelassen, ob D24s Weg „per Skill-Punkt" für Handwerks-Stufen schon in Phase 1 nachgebaut wird. Gemessen steigt eine Handwerks-Stufe nur durch ihr Heft; einen Kaufweg hat das Handwerksfenster nicht. Nachbauen ließe er sich in XML über einen Perk, der `RecipeTagUnlocked` führt — das wäre eine zweite Quelle der Bindung neben den Stufen. | **Nein, erst Phase 2.** In Phase 1 kommt die Grundfähigkeit für Handwerks-Stufen **allein über das Lehrblatt**. Der Skill-Punkt-Weg wird zusammen mit Learning by Doing gebaut (F-21, Phase 2), nicht vorher als Perk-Brücke. **Vom Nutzer entschieden am 2026-11-16** gegen „Ja, per Perk". **D24 bleibt gültig und ungestrichen:** es beschreibt das Ziel; diese Zeile legt fest, welche Hälfte Phase 1 baut. Folge für WP7.6 und WP9: ob genug Lehrblätter in Loot und Handel liegen, entscheidet jetzt allein über das Tempo des Handwerks — einen Ausweg über Skill-Punkte gibt es nicht. | F-21, D24, D50, D70, Plan-0001 WP7.5 |
| D72 | 2026-11-20 | F-17 B1 verlangt „Nächte deutlich dunkler, Neumond fast schwarz, Mondphasen mit Gewicht" und Nebel „in Wald, Moor und Flusstälern, abends dichter". Gemessen steuert `worldglobal.xml` das Umgebungslicht als Tag-/Nacht-Paare und `biomes.xml` den Nebel je Wetter und Biom. Gemessen ist aber auch, was XML **nicht** kann: der Code führt eine feste Untergrenze (`cBrightnessMin` = 0,2), der Helligkeitsregler des Spielers geht in dieselbe Rechnung ein, ein Flusstal ist kein Biom, und `fogPower` ist ein Exponent, dessen Wirkungsrichtung in keiner Aufrufliste steht. | **Gebaut wird, was Zahl an einer vorhandenen Zeile ist — zwölf Zeilen, alle Setzungen.** *Nacht:* nur der Nachtwert sinkt (`ambientEquatorScale` .45 → .25, `ambientGroundScale` .05 → .02, `ambientSkyScale` .7 → .4); der Tag bleibt Vanilla. *Mond:* `ambientMoon` .8, .4 → .5, .7 — der Sockel sinkt, der Mondanteil steigt, die Summe bei vollem Mond bleibt 1,2. Eine Vollmondnacht ist damit nur um die drei Nachtwerte dunkler, eine Neumondnacht noch einmal um gut ein Drittel. *Wald* (`pine_forest`, Klosterland): Nebelwetter doppelt so oft (7 → 14, zulasten von `default`) und dichter (17–27 → 20–32), dazu ein Rest Dunst bei klarem Wetter (0–2 → 1–5). *Moor* (`wasteland`, D43): die drei trockenen Wetter tragen 6–14 statt 0–5 — immer diesig, nie so dicht wie Waldnebel. **Nicht gebaut, und zwar begründet:** (1) **Flusstal-Nebel** — kein Biom, gehört zu F-07; (2) **„abends dichter"** — `fogPower` wird nicht geraten; (3) **das Licht unter einem Dach** (`ambientInside*`) bleibt Vanilla, obwohl ein dunkles Haus jetzt heller wirken kann als der Wald davor; (4) Brandland, Mittelgebirge und Küste bleiben Vanilla. **Zwei Grenzen bleiben stehen:** ganz schwarz wird es über XML nicht, und wer den Helligkeitsregler hochzieht, hellt sich die Nacht auf dem eigenen Bildschirm auf. Beides ließe sich nur mit C# ändern (Phase 2, Projektregel 2 und 6). **Die Zahlen sind nicht entschieden, sondern vorgelegt:** wie dunkel .25 aussieht, weiß niemand, bis jemand nachts im Wald steht — Prüfliste 18 nennt, welche Zeile man für „zu dunkel" oder „zu hell" ändert. | F-17, F-07, F-08, D12, D43, D53, Plan-0001 WP8.1 und WP8.2, `docs/rea/findings/WP8-nacht-und-nebel.md` |
| D73 | 2026-11-20 | F-17 B8: sichere Orte „senken das Grauen". Das Grauen (B3) gibt es in Phase 1 nicht. Was tut ein sicherer Ort bis dahin — und wo ist einer? Gemessen legt das Spiel eine Flächenwirkung nur um Blöcke mit **Kacheleinheit**, die gerade **aktiv** ist (`EntityPlayerLocal.BlockRadiusEffectsTick` geht die TileEntities der Chunks durch und fragt `IsActive`). | **„Kleine Erholung"** — **vom Nutzer entschieden am 2026-11-20** (AskUserQuestion) gegen „Nur benennen" und „Erholung und Heilung". An **brennender Feuerstelle, Esse und Kräuterküche** (`campfire`, `forge`, `chemistryStation`; Radius wie Vanilla 3, 5, 3) trägt der Spieler die sichtbare Wirkung **„Am Feuer"**: Kälteschutz +20 wie bisher, dazu **Ausdauer-Erholung +20 %** (Setzung für WP9; Vanillas Wert für Kaffee). Keine Heilung — die gehört zu F-11. **Welche Orte es sind, hat die Messung entschieden, nicht die Wahl:** nur Werkstätten haben eine Kacheleinheit, die „brennt" beantwortet. **Berichtigung an WP6.4:** unser **Holzfeuer** (`PlantGrowing`) hat keine Kacheleinheit; seine Wärme-Zeile wird nie gelesen. Es leuchtet und verbrennt, wärmt aber nicht und ist **kein** sicherer Ort — sein Text ist berichtigt. Das ist eine Folge von WP6.4s Bauform (Brenndauer über `PlantGrowing`); einen XML-Weg zu beidem — Brenndauer **und** Aura — kenne ich nicht. Der Schluss ist aus der Aufrufliste gezogen und im Spiel nicht gesehen (Prüfliste 19). **Wandfackeln** bleiben bei Vanilla und sind kein sicherer Ort; ob sie überhaupt wärmen, ist nicht gelesen. *Notiz für Phase 2:* wenn B3 kommt, senkt „Am Feuer" das Grauen — der Buff ist die Stelle, an die das angehängt wird. „Befestigtes Heim mit Schutzzeichen" und „geweihter Boden" aus B8 sind Phase 2 (F-15, F-07). | F-17, F-08, F-04, F-11, D53, D72, Plan-0001 WP8.3 und WP6.4, `docs/rea/findings/WP8-nacht-und-nebel.md` §8 |
| D74 | 2026-11-20 | F-17 B2, soweit XML: „Seuchentote sind leiser als Vanilla-Zombies; ihr erster Laut ist oft schon nah", dazu ferne Klänge (Glocke, Wolfsheulen, Rufe, Weinen, Raunen). Gemessen führt `sounds.xml` **kein** Element für den Pegel — Lautstärke und Reichweite liegen in Unity-Vorlagen. Und Vanilla hat an fernen Klängen einen Glockenschlag und Tierlaute, sonst nichts. | **Seuchentote werden nicht leiser, sondern seltener hörbar — sieben Zahlen, alle Setzungen.** `SoundRandomTime` (Laute ohne Ziel) 30 → 90: ein Drittel so oft. `SoundAlertTime` (Laute in der Verfolgung) 25 → 40. `SleeperNoiseToSenseSoundChance` .5 → .15: ein Schläfer, der etwas hört, stöhnt selten auf. Kriecher und Seuchenhund bekommen dieselben Verhältnisse. **Die Jagd bleibt hörbar, mit Absicht:** ein Verfolger, der schweigt, ist ein unfairer Tod von hinten, kein Grusel. **Nicht gebaut, und zwar begründet:** (1) **Der Pegel** — ein Asset, Phase 2 (F-16). (2) **Ferne Klänge** — ein Laut ohne Quelle ist nach F-17 selbst ein **Trugbild** (B4: Phase 2, erst ab „Verängstigt", nur beim Betroffenen); ein Wolfslaut ohne Wolf bräche die Regel „der Spieler darf zweifeln, aber nicht betrogen werden". Technisch ginge es in XML (`PlaySound` mit `RandomRoll`, `TimeOfDay`, `InBiome`), das Material fehlt. (3) **`SoundSense` streichen** — der kürzeste Weg zu „der erste Laut ist schon nah", aber was der Code mit einem leeren Klangnamen tut, ist nicht gelesen. (4) **Die Stille-Logik** (Tiere verstummen) — C#, Phase 2, wie im Plan. **„Umdeuten und zuordnen"** aus dem Plan findet in Phase 1 damit kein Material. **Dabei gefunden und nicht gelöst:** `subtitles.xml` führt 1336 Untertitel, alle für die gesprochenen Zeilen der fünf Vanilla-Händler — modernes Englisch als Ton. Das ist ein Anachronismus, den weder der Purge noch die Sprachdatei greift; er gehört zu F-10 und steht im Plan unter den offenen Punkten. | F-17, F-06, F-16, D12, D53, Plan-0001 WP8.4, `docs/rea/findings/WP8-nacht-und-nebel.md` §9 |
| D75 | 2026-11-20 | F-12 verlangt ein Glossar als „verbindliche Begriffsquelle" und als Abnahme „Glossar und Localization sind konsistent (Prüfskript)". Offen war, was „verbindlich" praktisch heißt, wie die Weltbegriffe englisch lauten und was aus Vanillas Startnotiz wird (`noteDuke01`, seit WP3 aufgeschoben). | **Das Glossar ist eine Datei, die geprüft wird, und kein Beiblatt.** `docs/glossar.md` führt zwei Tabellenformen, und `tools/check/glossar-pruefen.ps1` liest genau diese Datei: **Festbegriffe** (Kennung, Deutsch, Englisch — die Zeile der Sprachdatei muss genau so lauten) und **verbotene Begriffe** (Muster je Sprache — dürfen in keiner unserer Zeilen stehen). **Vom Nutzer entschieden am 2026-11-20:** Seuchentote = „the plague-dead", Seuchennacht = „Plague Night". **Verboten ist dreierlei, jeweils mit Quelle:** Vanillas Welt (Zombie, Blutmond, Dukes, Navezgane), ~~der alte Name jedes umgedeuteten Dings (Lagerfeuer, Werkbank, Zement, Machete …)~~ *(eingeengt durch D76)* und Modernes ohne Entsprechung in Phase 1. **Eine Setzung ohne Vorlage im GDD, Abnahme offen:** im Deutschen stehen keine englischen Spielwörter (Level, Skill, Perk, Buff, Loot, craften) — gemessen kamen unsere 603 Zeilen schon ohne aus. **Die Startnotiz wird umgedeutet, nicht ersetzt:** `noteDuke01` bleibt die Kennung, der Spieler liest einen „Pergamentfetzen" — ein Blatt von denen, die ihn am Weg fanden und ihm ließen, was in der Startausrüstung liegt. Der Text nennt keinen Namen (D1 wird in WP8.6 angewandt) und keine Ursache (GDD 2.1: bewusst offen; die Schreiber zitieren nur, was andere glauben). **Der Wortlaut ist eine Setzung und wartet auf den Nutzer.** Damit ist der Aufschub aus WP3 eingelöst. **Nicht entschieden, im Glossar unter „Offene Begriffe":** die englischen Namen für Verderbte, Moorleichen, Wanderhändler, Klostermarkt, Fürstenhof und die Baustufen; „Schlagringe" als Name einer Fertigkeit; „Scrap Bronze". **Was die Prüfung nicht sieht:** Vanilla-Zeilen, die wir nicht überschreiben — gemessen nach dieser Scheibe 686 mit einem Weltbegriff, davon 505 möglicherweise sichtbar. Die sind Arbeitsvorrat für die weiteren Scheiben von WP8.5, kein Befund dieser Prüfung. | F-12, D1, D7, D30, GDD 2.1/2.3, Plan-0001 WP8.5, `docs/glossar.md`, Vertrag 04 (Nachtrag WP8.5) |
| D76 | 2026-11-20 | D75 verbot „den alten Namen **jedes** umgedeuteten Dings". Das Review vor dem Push fand „Jagdmesser" (alter Name des Sax) ohne Verbot — und beim Nachtragen zeigte sich, dass der Satz so nicht haltbar ist: manche alten Namen sind zugleich unsere Wörter. | **Verboten ist der alte Name, wo er sich verbieten lässt; wo nicht, steht der Grund im Glossar.** 29 Muster sind nachgetragen (77 statt 48), darunter Jagdmesser, Eisenspeer, Stahlaxt, Vorschlaghammer, Geschmiedetes Eisen, Kohle, Blockwand. **Kein Verbot tragen können:** Wörter, die auch unsere sind oder in unseren Namen stecken (Eisen, Schmiede/Forge, Kerze, Fackel, Blei), Alltagswörter (Messing, leichte/schwere Rüstung, Buch, die fünf Attributnamen) und Trader, dessen englischer Ersatz offen ist. **Regel für die Zukunft:** wer einen Festbegriff mit Vanilla-Namen einträgt, trägt das Verbot dazu ein oder den Grund. **Die nachgetragenen Muster fanden sofort vier Abweichungen in unseren eigenen Texten** („forged iron" statt „wrought iron", „Vorschlaghammer" statt „Hammer") — berichtigt. *(Diese Einengung stand am 20. November zuerst als Einschub in D75; das zweite Review hat zu Recht verlangt, dass sie eine eigene Zeile bekommt — Projektregel 4.)* | D75, F-12, `docs/glossar.md` Abschnitt 9, Vertrag 04 (Nachtrag zweites Review) |
| D77 | 2026-11-20 | WP8.5, zweite Scheibe: 66 nicht überschriebene Vanilla-Zeilen aus Buffs, Blöcken, Gegenständen, Mods, Wesen und Tagebuch-Tipps tragen einen Weltbegriff. Welche davon sieht ein Spieler in Phase 1 — und was wird aus Vanillas „Der Zahnarzt"? | **Umgeschrieben wird, was in Phase 1 sichtbar ist; der Rest wird eingeteilt, nicht übersetzt.** Gemessen sind von den 66 Zeilen **vier** sichtbar und ohne offene Frage: die Beschreibung von Lager und Bett (`bedGroupDesc`), vom Gebietsschutzblock (`keystoneBlockDesc`), vom Holzzaun (`fencesGroupDesc`) und der Buff „Der Zahnarzt". **Die übrigen 62:** 17 hängen an gesperrten Kennungen, 3 Schlüssel haben keinen Nutzer, 8 sind unerreichbar (Hühnerstall-Rezept gesperrt; ein Buff, den Vanilla selbst „UNUSED" nennt; eine Maske ohne Fundort), 14 sind Prefab- und Entwicklerblöcke (F-07), 6 warten (Infektion: Balance-Frage; Bögen: WP5.2), 7 sind Wesen-Namen (F-06, Phase 2), und für die 7 Tagebuch-Tipps findet sich weder ein Verweis in den XML-Dateien noch eine Zeichenkette im Code — **vermutlich tot, nicht bewiesen**. **„Der Zahnarzt" wird zum „Totenpfennig"** (englisch „Dead Man's Penny"): Vanilla lässt Faustkämpfer ab Standhaftigkeit Stufe 3 mit 5 % einen Silber- oder Goldklumpen aus „Zahnfüllungen" schlagen. Die Wirkung bleibt, die Begründung wechselt — manchem Toten gab man Silber oder Gold mit. **Der Name ist eine Setzung und wartet auf den Nutzer**, ebenso der Vorschlag „Grenzstein" für den Gebietsschutzblock, der **nicht** umgesetzt ist. | F-12, D75, D76, Plan-0001 WP8.5, `docs/glossar.md` |
| D78 | 2026-11-20 | WP8.5, dritte Scheibe: der Ladebildschirm zeigt 40 Tipps aus `loadingscreen.xml` (ein 41. ist in Vanilla auskommentiert), bei jedem Laden. Etliche handeln von Dingen, die gesperrt sind (Hupe, Twitch, Schraubenschlüssel, Tausammler, Klebeband) oder nennen umgedeutete Dinge beim alten Namen. Streichen, ersetzen oder umschreiben — und auf welchem Weg? | **Umgeschrieben wird über die Sprachzeilen; `loadingscreen.xml` bleibt, wie sie ist.** Jeder Tipp behält seinen Schlüssel und seinen Platz in der Liste; wo das Ding dahinter nicht mehr existiert, trägt der Schlüssel einen **neuen Tipp** über etwas, das es gibt (Umdeutung, wie überall sonst). Das ist der Weg, der belegt ist: `GameManager::Awake` → `ModManager::LoadPatchStuff` → `LoadLocalizations` lädt die Sprachdateien der Modlets schon beim Programmstart, also vor dem ersten Ladebildschirm (Aufrufkanten gelesen, [Finding WP4](rea/findings/WP4-localization-ueberschreibt-vanilla.md)). Ob ein XML-Patch auf `loadingscreen.xml` rechtzeitig greift, ist dagegen nicht gelesen. **27 von 40 Tipps sind umgeschrieben, 13 bleiben Vanilla** (reine Bedienhilfe ohne Weltbegriff). **Acht tragen einen neuen Gegenstand:** Hupe → *Am Feuer*, Twitch → *Licht*, Schraubenschlüssel → *Schleifstein und Schmiedeflicken*, Tausammler → *Wasser*, Sammler → *Schlafstatt*, Zeitschriften → *Lehrblätter*, Beutebonus → *Die fünf Attribute*, Stahlschlagringe → *Die Stahlfaust*. **Jeder neue Tipp sagt nur, was schon in einem unserer Texte, in einer gemessenen Zeile oder in Vanillas eigenem Tipp steht** — keine Zahl und keine Mechanik, die erst der Spieltest zeigt. (Im Spiel gesehen ist davon nichts; „Fackel brennt ab" und „Am Feuer" sind so ungesehen wie die Pakete, aus denen sie stammen.) Dazu: **„Kleber" heißt deutsch „Leim"** (`resourceGlue`; englisch bleibt „Glue"); Vanillas Beschreibung nannte nur das gesperrte Klebeband. **Die Tipp-Titel und die neuen Themen sind Setzungen und warten auf den Nutzer** (Prüfliste 21). | F-12, D75, Plan-0001 WP8.5, `docs/glossar.md` |

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
| D29 | 2026-11-07 | Endgame-Basisschutz | ~~**Gegner angepasst**: weniger Blockschaden durch Seuchentote~~, dafür mehr Gefahr für Spieler — **erste Hälfte aufgehoben mit D65 (2026-11-08)**, zweite Hälfte steht weiter | F-06, F-18, D65 |
| D30 | 2026-11-07 | Währung | **Nur Silber** (Vanilla-Dukes umgedeutet) | F-05 |
| D31 | 2026-11-07 | Knappheit | **Eisen knapp**, Holz/Stein/Lehm normal | F-05 |
| D57 | 2026-11-08 | F-04 stellt neun Werkstätten auf, drei davon als XML-Klone (Runenritzer-Bank, Webstuhl, Räucherkammer/Trockengestell), und verlangt von jeder **mindestens fünf Rezepte**. Gemessen bleiben nach dem Purge in ganz Vanilla 252 Rezepte übrig, und darunter ist kein Satz von fünf, der auf eine dieser drei gehört: ihr Inhalt liegt in F-15 (Runen), F-19 (Konserven) und F-03 (Gambeson). Phase 1 kann das Kriterium also nur erfüllen, indem sie Phase-2-Inhalt vorzieht — was D50 verbietet. Was gilt? | **Die drei Klone wandern in die Pakete, die ihren Inhalt bringen** (WP4.4 wird verschoben, nicht gestrichen): Webstuhl zu **F-03/WP5** (Gambeson-Teile), Räucherkammer zu **F-19, Phase 2** (Konserven), Runenritzer-Bank zu **F-15, Phase 2** (Runen, Glutladungen). **Phase 1 endet mit sieben Werkstätten statt neun** — sechs Namen auf den fünf umgedeuteten Vanilla-Blöcken (`forge` trägt Rennofen und Esse) und dem Webstuhl aus WP5. Das Akzeptanzkriterium „mindestens 5 Rezepte" gilt in Phase 1 nur für diese; für die drei Klone wird es mit ihrem Inhalt abgenommen. Anlass: eine Werkstatt ohne Rezepte ist für den Spieler eine Enttäuschung und für den Prüfer ein dauerhaft offenes Kriterium; mit Inhalt gebaut, ist sie in einem Stück fertig. Kein Rückbau — nichts davon ist gebaut | F-04, F-03, F-15, F-19, Plan-0001 WP4.4/WP5 |

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
| Q19 | Plünderer und Kultisten: Gibt es in V 3.40 bereits menschliche Gegner (Banditen), auf denen wir aufbauen können? (REA) | F-20 |

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
