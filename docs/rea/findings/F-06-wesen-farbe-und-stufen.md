# F-06 — Wesen: Farbe, Größe und was eine Stufe ausmacht

**Stand:** 23. November 2026 (Plan-0002, WP5.5)
**Fragen** (F-06 §2 „aus der Erinnerung, nicht nachgemessen"; §5 Spuk-Hund „dunkel getönt"):

1. Kann XML ein Wesen auf Vanillas Modell **tönen** oder sonst sichtbar abheben?
2. Woher kommt das Glimmen der Stufen, und lässt es sich in XML ändern?
3. Was unterscheidet die vier Stufen in diesem Build wirklich?

**Antworten in einem Satz je Frage (Code statisch gelesen, Werte an Vanillas XML gemessen, nichts
im Spiel gesehen):**

1. **Tönen nein, leuchten und skalieren ja.** `MatColor` setzt eine **Leuchtfarbe** auf die
   Materialien des Modells, `SizeScale` die Größe; eine Eigenschaft für die Grundfarbe gibt es
   nicht.
2. Aus drei `<color>`-Knoten am Anfang von `entityclasses.xml` — sie sind XML und damit
   patchbar; eigene Knoten lassen sich anhängen.
3. Lebenspunkte, Schaden, Tempo und bei `Radiated` eine Selbstheilung. **Kein Stromschlag, kein
   Brand:** `Charged` und `Infernal` schlagen nur härter.

**Kein Patch.** Kein Harmony-Eingriff, darum kein Eintrag im Patch-Manifest.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta find-string <dll> --text MatColor --text SizeScale`, `--text infernal
--text charged`; `mod700meta members <dll> --type EntityClass --type EntityClassesFromXml --type
'EntityClassesFromXml/<Load>d__5' --type EModelBase --il`; Zählungen an `entityclasses.xml` und
`items.xml` von V 3.40 b10.

**Soll-Signaturen:** `tools/meta/expect/wp55.tsv` (5 Zeilen). `mod700meta verify`: Exit 0;
Gegenprobe mit einer verfälschten Zeile: Exit 1.

## 1. Farben sind Knoten in `entityclasses.xml`

Der Leser der Klassen (`EntityClassesFromXml::Load(XmlFile, bool)`) liest neben `entity_class`
auch Elemente namens `color` mit den Attributen `name` und `value`. Der Wert geht durch
`StringParsers::ParseColor` und landet in einem statischen Wörterbuch der Klasse `EntityClass`
(`sColors`, Name → Farbe). Das Wörterbuch wird bei jedem Laden geleert und mit `Add` gefüllt —
**ein doppelter Name ist darum ein Ladefehler**, kein Überschreiben.

Vanilla führt drei Knoten, direkt unter `<entity_classes>`, mit Kommentar:

| Name | Wert | Vanillas Kommentar | benutzt von |
|---|---|---|---|
| `radiated` | `.295,1,0, 0` | Green | 32 Klassen |
| `charged` | `0,.8,3, .7` | Blue; „A + 1 is emissive power (.5 would be 150%)" | 24 Klassen |
| `infernal` | `2.7,.8,0, .55` | Red | 23 Klassen |

Darüber steht: Werte über 1 „überstrahlen" die Farbe. Der vierte Wert ist also keine
Durchsichtigkeit, sondern ein Zuschlag auf die Leuchtkraft.

## 2. Wie die Farbe ans Modell kommt

`EModelBase::createModel(World, EntityClass)` liest die Eigenschaft `MatColor` der Klasse als
Text, schlägt den Namen in `sColors` nach und setzt — wenn die Farbe nicht Schwarz ist — auf den
Materialien der Hautgitter des Modells einen Zahlenwert und eine Farbe; im selben Rumpf stehen die
Namen `_Emissive` und `_EmissiveColor`. Es ist also die **Leuchtfarbe** des Materials, nicht seine
Grundfarbe.

Drei Folgen:

- **Abdunkeln geht nicht.** Eine Leuchtfarbe addiert Licht; ein „schwarzer Hund" ist in XML nicht
  zu haben, nur über ein eigenes Material (`AltMats`/`SwapMats`, Finding F-16 Asset-Referenzen —
  braucht ein Bundle).
- **Der Nachschlag geschieht beim Bau des Modells, nicht beim Laden.** Das Wörterbuch wird direkt
  gefragt; nennt `MatColor` einen Namen, den es nicht gibt, bricht das Spiel **beim Erscheinen**
  des Wesens. Kein Start-Log zeigt das. Die Prüfung *wesen* hält es seit WP5.5 fest
  (`wesen-farbe-fehlt`, Vertrag 04).
- **Ob ein Material überhaupt leuchtet, hängt an seinem Shader.** Vanilla setzt `MatColor` nur an
  Klassen der Stufen `Radiated`, `Charged` und `Infernal` — deren Modelle bringen eigene
  Materialien mit (`AltMats` mit `…_Radiated2.mat`). Was die Farbe auf dem Material eines
  gewöhnlichen Modells tut (nichts, ein Schimmer, ein Überstrahlen), ist **nicht gelesen und nicht
  gesehen**.

`SizeScale` liest `EntityClass::Init` in ein Feld der Klasse. Vanilla benutzt es an 28 Klassen,
darunter ein Tier (`animalDireWolf`, 1.4) — der Weg ist also auch für Tiere begangen.

## 3. Die vier Stufen, gemessen

An `zombieBoe` und seinen vier Stufen, mit den Hand-Gegenständen aus `items.xml`:

| | Grund | `Feral` | `Radiated` | `Charged` | `Infernal` |
|---|---|---|---|---|---|
| erbt von | — | Grund | Feral | Radiated | Radiated |
| Lebenspunkte | 200 | 550 | 900 | 1100 | 1700 |
| Hand-Gegenstand | `meleeHandZombie01` | `…Feral` | `…Feral` (geerbt) | `…Charged` | `…Infernal` |
| Schaden an Wesen / Blöcken | 10 / 8 | 20 / 24 | 20 / 24 | **60** / 150 | 45 / **250** |
| eigenes Modell | — | `…Feral.prefab` | `…Radiated.prefab` + `AltMats` | wie Radiated | wie Radiated |
| Glimmen (`MatColor`) | — | — | `radiated` | `charged` | `infernal` |
| Besonderes | — | schneller im Angriff, härter zu zerlegen | **Selbstheilung** bei Treffer (`buffRadiatedRegen`) | Tempo-Muster `chargedMoveSpeedPattern` | Tempo-Muster `infernalMoveSpeedPattern`; widersteht dem Umwerfen zu 75 % |

Die drei Hand-Gegenstände der höheren Stufen lösen beim Treffer **dieselbe** Liste von Wirkungen
aus wie der gewöhnliche Schlag (Ermüdung, Verstauchung, Riss, Schürfung, Betäubung, Blutung) und
zählen die Ansteckung hoch. Ein eigener Zustand für „Stromschlag" oder „Brand" hängt an keinem von
ihnen. Die Namen „Charged" und „Infernal" beschreiben in diesem Build die **Farbe**, nicht eine
Wirkung.

## 4. Was daraus für das Projekt folgt

1. F-06 §2 ist berichtigt: die Spalte „Woran man sie erkennt" stand aus der Erinnerung da und war
   bei zwei von vier Stufen falsch.
2. **Name gegen Erscheinung:** die dritte Stufe heißt bei uns „Glutäugiger / Ember-Eyed" und
   glimmt **blau**; die vierte heißt „Verdammter / Damned" und glimmt rot. Das ist eine
   Entscheidung für den Nutzer (N-69) — die Farbe ist eine XML-Zeile, der Name eine Tabellenzeile.
3. Eine eigene Klasse auf Vanillas Modell kann sich durch **Größe** und — vielleicht — durch ein
   **Leuchten** abheben, mehr nicht. Der Spukhund (D150) ist so gebaut; sein Aussehen ist der
   erste Blick im Spiel, der das Leuchten auf einem gewöhnlichen Material zeigt (S-28).
4. Eigene Farbknoten bekommen das Präfix `col700_` (Vertrag 02, Nachtrag Phase 2).
5. **Der Anzeigename einer eigenen Klasse ist ihr Klassenname als Sprachschlüssel:**
   `Entity::get_LocalizedEntityName` liest `EntityClass::entityClassName` und ruft
   `Localization::Get`. `ent700_spukhund` braucht darum eine Zeile unter genau diesem Schlüssel;
   `sprachverweise-pruefen.ps1` kennt die Regel seit WP5.5.

## Offen

| Punkt | Stand |
|---|---|
| Wirkung von `MatColor` auf ein Material ohne Leucht-Vorbereitung | nicht gelesen, nicht gesehen — S-28 |
| Ob ein angehängter `<color>`-Knoten (am Ende der Datei statt am Anfang) gelesen wird | der Leser sucht Elemente nach Namen; die Stelle im Dokument ist nicht geprüft — S-28 zeigt es |
| Verhalten der Stufen im Spiel | nicht gesehen; die Werte stehen in XML |
