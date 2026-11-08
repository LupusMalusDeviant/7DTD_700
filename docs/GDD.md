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
