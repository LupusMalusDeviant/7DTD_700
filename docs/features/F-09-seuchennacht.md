# F-09 — Seuchennacht

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X+H | S | ja |

## Ziel
Die Horde-Nacht wird zur **Seuchennacht**: Nebel, Glockenläuten in der Ferne, Wellen von
Seuchentoten. Mechanisch Vanilla-nah, atmosphärisch eigen.

## Umfang
- Umbenennung und Re-Theming (Texte, Himmel- bzw. Nebelfarbe statt Blutmond-Rot)
- Wellen-Zusammensetzung aus F-06-Gruppen (`gamestages.xml`)
- **Vorboten (C#):** Am Tag davor gibt es Ereignisse wie Krähenschwärme, fernes Läuten oder Nebel am Abend. Hook am Tageswechsel bzw. am Horde-Nacht-Planer. Die Vorboten sind der Höhepunkt der Phase „Vorzeichen“ des Bedrohungs-Direktors (F-17 B5) und erhöhen das Grauen aller Spieler (F-17 B3).
- **Grusel-Inszenierung (D12):** Die Nacht beginnt nicht mit einem Schlag, sondern mit Stille. Tiere verstummen, Nebel steigt, die Glocke schlägt, dann kommt das erste Geräusch im Nebel. Sagengestalten (F-06) können die Wellen anführen.
- Optional: Nach der Seuchennacht liegen „Seuchenleichen“ herum, die verbrannt werden müssen (sonst Krankheitsrisiko, F-11)

## Umsetzung
### C# — Warum nicht XML?
Die Farbe und Ankündigung der Horde-Nacht sowie Vorboten-Ereignisse am Vortag liegen nach
unserem Kenntnisstand im Code (Sky- bzw. Wetter-Manager, Horde-Night-Direktor). **[verifizieren]** per REA,
welche Teile doch per XML (Weather, Biome-Spectrum) gehen.

*Stand WP9.4 (2026-11-23, [Finding](../rea/findings/WP9-licht-und-seuchennacht.md), zu prüfen N-114):*
mehr als gedacht ist XML. „Seuchennacht läuft" ist die Buff-Bedingung `IsBloodMoon`; Nebel, Wolken
und Wind der Nacht stehen je Biom als Wetter `bloodMoon` in `biomes.xml`. Die rote Tönung hängt an
einem Spektrum ohne XML; ob ein `<spectrum name="Foggy"/>` im Wetter sie ersetzt, zeigt S-34 (3).
Den Vortag erkennen: Spieltag und Seuchennacht-Tag sind beide abfragbar, die Differenz in XML
nicht belegt. C# bleibt sicher nur für den Direktor (F-17 B5).

*Triage WP9.6 ([triage-phase-2.md](../rea/triage-phase-2.md) Nr. 8–11; zu prüfen N-116):* Abfrage und
Nebel **XML**; Farbe **XML vielleicht**, sonst Asset; **Vorboten: C# ohne Patch** als Teil des
Direktors — warum nicht XML: „morgen ist Seuchennacht" ist aus Spieltag und Seuchennacht-Tag nicht
als eine Bedingung belegt, der Direktor rechnet es ohnehin.

## Ausarbeitung (Plan-0002 WP11.1, 2026-11-23, D184, zu prüfen N-128)

Schließt die Lücken aus Prüfung 0003 (F-09 „hoch"): Deutung, Phase-1-Stand, Vanillas Optionen,
Wellen, stiller Beginn, Vorboten. Alle Zahlen sind **Setzungen**, im Spiel ungesehen.

### 1. Die Deutung in der Welt (D107, `docs/lore.md` §3)

**Fest steht die Erscheinung:** in jeder siebten Nacht gehen die Toten um und finden die Lebenden,
wo immer sie sich verbergen. Die Leute zählen die Tage wie früher die Feiertage. **Die Ursache bleibt
offen** — drei Deutungen stehen nebeneinander (Lore §3), jede hat in der Welt ein wenig recht:

| Deutung | spricht in der Seuchennacht durch | Beispielsatz (Ton, kein fertiger Text) |
|---|---|---|
| **Strafe** (Klöster) | die Glocke, Fundschriften von Mönchen, der Klostermarkt | „Sie läuten nicht, um zu warnen. Sie läuten, damit Er hört, dass wir noch beten." |
| **Fluch** (Höfe, Seuchenkult F-20) | Runen an Türen, Hausnotizen, alte Leute | „Die Alten haben es gesagt: wer die Steine vergisst, den holt die siebte Nacht." |
| **Krankheit** (Heilkundige, weitgereiste Händler) | Händlerrede, Kräuterküche, Pestgruben | „Am siebten Abend steigt das Moor. Koch dein Wasser und halt die Tür zu, dann trifft's den Nachbarn." |

**Regel für jeden Text:** er spricht aus einer Deutung und darf sich irren; kein Text erklärt die
Seuchennacht (Lore §1). Die Anzeige der Spielmechanik („Seuchennacht heute Nacht") bleibt nüchtern.

### 2. Was Phase 1 schon hat

- Vanillas Blutmond **unverändert in der Mechanik**: Planer, Wellen, Zielsuche der Horde.
- **Texte:** die Spieloptionen heißen „Seuchennacht" (`goBloodMoon…`, Frequenz, Spanne, Warnung,
  Anzahl), dazu die Herausforderung `challengeBloodMoonSurvive1`.
- **Wesen:** die Horden-Gruppen sind Vanillas `feralHordeStageGS…`, aber gefüllt mit unseren
  Seuchentoten (Purge, WP5.4).
- **Himmel:** Vanillas rote Tönung — sie ist in Phase 1 nicht ersetzt.

### 3. Vanillas Optionen bleiben (P5)

| Option | Vorgabe | Wir |
|---|---|---|
| Frequenz (`BloodMoonFrequency`) | 7 | bleibt; Lore sagt „jede siebte Nacht" als Sage. Stellt der Spieler sie um, irrt die Sage — das darf sie (Lore §1). |
| Spanne (`BloodMoonRange`) | 0 | bleibt; mit Spanne > 0 ist der Tag ungewiss, die Vorboten (§6) verraten ihn dann einen Tag vorher |
| Warnung (`BloodMoonWarning`) | 8 Uhr | bleibt; die nüchterne Ankündigung |
| Anzahl (`BloodMoonEnemyCount`) | 8 | bleibt |

Keine eigene Seuchennacht-Option. Wer sie ganz abschaltet (Frequenz 0), hat keine Vorboten.

### 4. Wellen: Größe und Staffelung

**Größe bleibt Vanilla:** 322 Stufen in `gamestages.xml` (`spawner BloodMoonHorde`), je Stufe Zeilen mit
`num`, `maxAlive`, `interval`. Daran rühren wir nicht — die Last auf Server und Palisade ist
erprobt.

**Staffelung: unsere Gruppen aus WP5.6 kommen dazu**, je eine Zeile in den Stufen ab einer Schwelle:

| Gruppe (WP5.6) | ab Spielstufe | Zeile | Wirkung |
|---|---|---|---|
| `eg700_brecherFrueh` | 30 | `num="2" maxAlive="1" interval="90"` | ein Brecher je anderthalb Minuten — die Palisade muss halten |
| `eg700_brecherMittel` | 100 | `num="4" maxAlive="2" interval="60"` | ersetzt die frühe Zeile |
| `eg700_brecherSpaet` | 250 | `num="6" maxAlive="2" interval="45"` | ersetzt die mittlere |
| `eg700_anfuehrerFrueh` | 60 | `num="1" maxAlive="1"` (einmal je Nacht) | eine Sagengestalt führt die Welle an (F-06) |
| `eg700_anfuehrerSpaet` | 200 | `num="2" maxAlive="1"` | ersetzt die frühe |

**Bauweise (WP11.9):** `<append>` per XPath auf die Stufen-Knoten mit Zahlvergleich
(`gamestage[@stage >= 30 and @stage < 100]`) — die Prüfung `kette-pruefen` muss solche XPaths treffen,
die Gegenprobe zeigt eine Schwelle, die nichts trifft. Anteil der Brecher an einer Welle höchstens
ein Zehntel (bei Vanillas 8 je Spieler und `maxAlive` 2 erfüllt).

### 5. Der stille Beginn (D12)

| Zeit | Was | Weg |
|---|---|---|
| Warnung (8 Uhr) | nüchterne Ansage wie Vanilla | Vanilla, Text aus Phase 1 |
| Abend des Tags, ab 18 Uhr | Nebel steigt: Wetter `bloodMoon` je Biom gilt ab Beginn; davor „Nebelabend" über den Direktor | Wetter (XML); Direktor (C#) |
| Beginn (`IsBloodMoon` wird wahr) | **Stille**: 60 s keine eigenen Umgebungslaute; dann **ein** Glockenschlag (`churchbellhit`, fern), Meldung „Die Glocke schlägt." | Buff am Spieler mit `IsBloodMoon` (XML) |
| danach | das erste Geräusch im Nebel ist ein echtes: Vanillas Horde | Vanilla |

Das Verstummen der **Tiere** ist B2 „Stille-Logik" und C# — Streichposten für Phase 2, wenn WP11.8 es
nicht billig findet.

### 6. Vorboten am Vortag (C# ohne Patch, Direktor F-17 B5)

Der Direktor kennt den Tag der nächsten Seuchennacht (Vanillas `BloodMoonDay`) und setzt am **Vortag**
die Phase „Vorzeichen" auf ihren Höhepunkt:

| Vorbote | Weg | Grauen |
|---|---|---|
| fernes Läuten am Abend | `churchbellhit` an einem Ort weit vom Spieler (eine Glocke ist echt — D74 erlaubt sie, ein Wolfslaut ohne Wolf nicht) | `cv700_grauenDruck` +10 |
| Vögel über dem Hof | ein Schwarm **Seuchengeier** (`animalZombieVulture`, Name D147) kreist; ob er sich zahm halten lässt, liest WP11.6 — sonst Streichposten, denn ein Vorbote darf nicht angreifen | +10 |
| Nebel am Abend | Wetter auf „Nebel" für den Abend | +10 |

`cv700_grauenDruck` (Vertrag 07 §3.3, 0–30) steigt so am Vortag auf 30 und fällt nach der Seuchennacht
auf 0. Ohne C#-Teil: keine Vorboten, die Seuchennacht kommt wie in Vanilla — nichts bricht.

### 7. Danach

„Seuchenleichen, die verbrannt werden müssen" (Umfang oben, „optional") ist **Phase 3** (Regel 6):
es braucht F-11 (Ansteckung) und eigene Blöcke. Notiz, kein Bau.

### Gebaut mit WP11.9 (D186, zu prüfen N-130, Spieltest S-44)

**Warum nicht C#?** Wellen und Beginn sind XML (Säule P5): fünf `insertBefore` in
`700_65_Wesen/Config/gamestages.xml` (Tabelle §4; die erste Stufe ab 30 ist Vanillas 31; Vanilla reicht
bis Stufe 5778) und zwei Buffs in `700_60_Welt` für den stillen Beginn (§5), gesetzt über Vanillas
`buffStatusCheck01`. Die Glocke ist Vanillas `churchbellhit`, die Meldung `buff700_seuchennachtGlocke`.
**Noch nicht:** eigene Farbe des Himmels (S-34 (3)), Nebelabend und Vorboten (Direktor, C#), Texte der
drei Deutungen in Fundschriften und Händlerrede (WP6.7/F-10 nachziehen). **Grenzen:** dass das Spiel die
Zeilen einer Stufe der Reihe nach abarbeitet, ist nicht gelesen — S-44 zeigt, ob die Brecher kommen;
wer erst spät in der Nacht ins Spiel kommt, hört die Glocke 60 s nach dem Betreten.

### 8. Netz

Alles Sichtbare der Seuchennacht kommt vom Server (Wetter, Wellen) oder läuft als Buff bei jedem Spieler
mit derselben Bedingung (`IsBloodMoon`) — also bei allen gleich. Die Vorboten setzt der Server; das
Läuten hört jeder, der nah genug ist.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-09](../rea/hook-hypothesen.md#f-09)

## Akzeptanzkriterien
- [ ] Seuchennacht startet zum konfigurierten Rhythmus, mit eigener Optik und eigenem Text
- [ ] Vorboten treten am Vortag auf (Server-seitig ausgelöst, für alle Clients sichtbar)
- [ ] *(WP11.1)* Mit Frequenz 7 beginnt jede Seuchennacht still und mit genau einem Glockenschlag
- [ ] *(WP11.1)* Ab Spielstufe 30 erscheint je Seuchennacht mindestens ein Brecher, ab 60 ein Anführer; unter 30 keiner
- [ ] *(WP11.1)* Ohne C#-Kern läuft die Seuchennacht wie in Vanilla, ohne Fehler im Protokoll
- [ ] *(WP11.1)* Kein Text bestätigt eine der drei Deutungen (Durchsicht der Sprachzeilen)
