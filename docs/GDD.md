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

### 1.1 Design-Säulen

| # | Säule | Bedeutung für Entscheidungen |
|---|---|---|
| P1 | **Glaubwürdig um 700, nicht Museum** | Nichts klar Anachronistisches (Schießpulver, Plattenrüstung, Strom). Bei Spielspaß-Konflikt gilt „plausibel“ vor „belegt“. |
| P2 | **Handwerk ist Fortschritt** | Tech-Progression läuft über Werkstätten, Rohstoffketten und Wissen, nicht über Loot-Glück mit Hightech. |
| P3 | **Nahkampf mit Gewicht** | Kampf ist nah, riskant und positionsabhängig: Schild, Reichweite, Ausdauer. Fernkampf ist knapp und handgemacht. |
| P4 | **Die Nacht gehört der Seuche** | Licht ist eine Ressource. Dunkelheit, Feuer und Befestigung tragen den Horror. |
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
- **Aberglaube mit Wirkung** (Entscheidung D2): Amulette, Reliquien, Weihwasser, Schutzzeichen
  und Rituale haben **kleine, messbare Spieleffekte** (Buffs). Es gibt **keine Zauber**,
  keine sichtbaren Magie-Effekte und keine Fantasy-Kreaturen. Der Spieler soll nie sicher
  sein, ob die Wirkung „echt“ ist oder nur Glaube (siehe F-15).

### 2.2 Ton

Dreckig, kalt, abergläubisch. Kein Ritterromantik-Hochglanz. Humor sparsam und trocken,
zum Beispiel in Notizen und Händlerdialogen.

### 2.3 Übersetzungstabelle Vanilla → 700

Das Herzstück der Umdeutung. Jede Vanilla-Komponente bekommt eine Entsprechung oder wird
entfernt.

| Vanilla | 700-Entsprechung | Feature |
|---|---|---|
| Zombies | Seuchentote (Bauern, Mönche, Krieger, Pilger …) | F-06 |
| Feral/Radiated | „Verderbte“ / „Moorleichen“ (Stärkestufen) | F-06 |
| Blood Moon / Horde Night | **Seuchennacht** | F-09 |
| Trader | Wanderhändler, Klostermarkt, Fürstenhof | F-10 |
| Dukes (Währung) | Silber (Sceattas / Denare), Hacksilber | F-05 |
| Workbench / Forge / Chem Station / Cement Mixer | Zimmermannsbank, Rennofen + Esse, Kräuterküche, Kalkofen | F-04 |
| Schusswaffen | Bögen, Schleuder, Wurfspeere, Armbrust (T4, selten, D8) | F-02 |
| Buffs/Boosts aus Pillen und Magazinen | Amulette, Reliquien, Schutzzeichen | F-15 |
| Elektrizität, Fallen mit Strom | Mechanische Fallen: Spieße, Fallgruben, Schwingbalken | F-08 |
| Fahrzeuge | entfallen; Stretch: Packpferd/Karren | F-13 |
| Bücher/Magazine | Abschriften, Schriftrollen, Lehrmeister | F-04 |
| Städte, Straßen, Wolkenkratzer | Weiler, Höfe, Klöster, Ringwälle, Römerruinen | F-07 |
| Medizin (Pillen, Antibiotika) | Kräuter, Wundauflagen, Theriak | F-11 |

---

## 3. Core Loop

Der Vanilla-Loop bleibt strukturell erhalten (P5), wird aber thematisch neu belegt:

```
   Tag: Erkunden ─► Sammeln (Holz, Lehm, Erz, Kräuter) ─► Handwerk in Werkstätten
     ▲                                                          │
     │                                                          ▼
  Wiederaufbau ◄── Seuchennacht (alle 7 Tage) ◄── Befestigen (Palisade, Graben, Fallen)
```

**Mittlere Schleife:** Aufträge von Händlern und Klöstern annehmen, Ruinen und Höfe plündern,
Wissen (Abschriften) sammeln, neue Werkstätten freischalten.

**Lange Schleife:** vom Grubenhaus zur befestigten Siedlung mit Rennofen und Esse, vom
Holzknüppel zu Spatha und Kettenhemd.

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

Detaillierte Specs je Feature liegen unter [`docs/features/`](features/README.md). Hier nur
die Zuordnung zu den Säulen:

| Feature | Säulen | Phase |
|---|---|---|
| F-00 Mod-Fundament | P5 | MVP |
| F-01 Anachronismen-Purge | P1 | MVP |
| F-02 Waffen & Kampf | P1, P3 | MVP |
| F-03 Rüstung & Kleidung | P1, P3 | MVP |
| F-04 Handwerk & Tech-Progression | P2 | MVP |
| F-05 Ressourcen & Währung | P1, P2 | MVP |
| F-06 Seuchentote & Bestiarium | P1, P4 | Phase 2 |
| F-07 Welt, Biome & POIs | P1 | Phase 2 |
| F-08 Licht, Feuer & Verteidigung | P4 | MVP |
| F-09 Seuchennacht | P4 | Phase 2 |
| F-10 Händler & Aufträge | P1, P2 | Phase 2 |
| F-11 Krankheit & Heilkunde | P1, P4 | Phase 2 |
| F-12 Lokalisierung & UI-Theming | P1 | MVP |
| F-13 Packtiere & Transport | P1 | Stretch |
| F-14 Siedlung & Gefolge | P2 | Stretch |
| F-15 Aberglaube & Reliquien | P1, P4 | Phase 2 |
| F-16 Asset-Pipeline | P1 | Phase 2 |

**MVP-Definition:** Eine RWG-Welt ist von Tag 1 bis zur ersten Seuchennacht ohne
Anachronismus in Items, Rezepten, Loot und Texten spielbar: mittelalterliche Waffen,
Rüstung, Werkstätten, Währung und Beleuchtung. Gegner, Waffen und POIs sind in dieser Phase
noch Vanilla-Modelle mit neuen Namen.

**Phase-2-Definition:** Der optische Bruch wird geschlossen, über eine Mischung aus
**Retexturen** vorhandener Modelle (schnell, breit) und **neuen Assets** dort, wo Vanilla
kein passendes Modell hat (Entscheidung D3; siehe F-16). Grobe Faustregel:

| Retextur genügt (Beispiele) | Neues Asset nötig (Beispiele) |
|---|---|
| Kleidung der Seuchentoten, Lederrüstung, Fackel | Spatha, Rundschild, Spangenhelm, Kettenhemd |
| Blöcke: Flechtwerk, Lehm, Reet, Bruchstein | Rennofen, Webstuhl, Langbogen |
| Truhen, Möbel, Wildtiere | Amulette/Reliquien (Icons + kleine Modelle) |

---

## 5. Technischer Rahmen (Kurzfassung)

Siehe [`specs/01-technischer-rahmen.md`](specs/01-technischer-rahmen.md). Die wichtigsten
Punkte:

- Datenänderungen per **XPath-Modlet** (`Config/*.xml`), Logik per **Harmony-Patch** in einer C#-DLL.
- **Server-autoritativ denken:** Jeder C#-Patch wird als Server-, Client- oder beidseitig
  klassifiziert. Die C#-DLL muss auf Server **und** Clients liegen, und **EAC muss aus** sein.
- **Schnittstellen nicht raten:** Jeder Harmony-Patch-Zielpunkt wird vorher per **REA**
  gegen die tatsächliche `Assembly-CSharp.dll` der Zielversion verifiziert und in
  `docs/rea/findings/` dokumentiert. Siehe [`rea/interface-discovery.md`](rea/interface-discovery.md).

---

## 6. Entscheidungen

| ID | Datum | Frage | Entscheidung | Wirkt auf |
|---|---|---|---|---|
| D1 | 2026-11-07 | Region (Q1) | **Fiktives Mischland** mit Leitplanke „gemischt wird die Herkunft, nicht die Epoche“ | GDD 2.1, F-07, F-12 |
| D2 | 2026-11-07 | Übernatürliches (Q2) | **Aberglaube mit Wirkung**: kleine Buff-Effekte, keine Zauber | F-11, F-15 |
| D3 | 2026-11-07 | Assets (Q3) | **Mix aus neuen Assets und Retexturen** ab Phase 2; MVP mit Vanilla-Modellen | F-02, F-03, F-06, F-07, F-16 |
| D4 | 2026-11-07 | Karte (Q4) | **RWG zuerst**, eigene handgebaute Karte als späteres Ziel | F-07 |
| D5 | 2026-11-07 | Kompatibilität (Q5) | **Kompatibel mit UI-Mods**: XUi-Änderungen nur additiv und zielgenau | Spec 01, F-12 |
| D6 | 2026-11-07 | Name (Q6) | **Später**: bis zum Release Arbeitstitel `7DTD_700` | F-12 |
| D7 | 2026-11-07 | Sprachen (Q7) | **DE + EN Pflicht**, weitere über die Community | F-12 |
| D8 | 2026-11-07 | Armbrust | **Ja**, selten, T4/Endgame | F-02 |

## 7. Offene Fragen

| ID | Frage | Blockiert |
|---|---|---|
| Q6 | Mod-Name / Branding (vertagt, D6) | Release, Ladebildschirm |
| Q8 | Welche UI-Mods dienen als Kompatibilitäts-Referenz für Tests? | F-12 |
| Q9 | Asset-Quellen: selbst modellieren, beauftragen oder lizenzierte Packs (CC0/kommerziell)? | F-16 |
| Q10 | Ansteckung (Seuchenbrand) zwischen Spielern ja/nein? | F-11 |
| Q11 | Bücher/Magazine: Rezeptfreischaltung wie Vanilla beibehalten oder auf Perks umstellen? | F-04 |
| Q12 | Kulturzonen: sollen die Biome kulturell geprägt sein (z. B. Klosterland, Burgwall-Land, Küste)? | F-07, F-06 |

---

## 8. Nicht-Ziele (v1)

- Keine Zauber, keine sichtbare Magie und keine Fantasy-Kreaturen. Aberglaube wirkt nur über kleine Buffs (D2).
- Keine historisch-akademische Simulation (kein Lehnswesen-Management, keine Fruchtfolge-Sim).
- Kein Eingriff in Netcode-Grundlagen (keine eigenen NetPackages, solange es sich vermeiden lässt).
- Keine EAC-Kompatibilität für den C#-Teil; das ist bei DLL-Mods technisch nicht möglich.
- Keine Übernahme von Inhalten, Namen oder Assets anderer Mods oder Spiele.
