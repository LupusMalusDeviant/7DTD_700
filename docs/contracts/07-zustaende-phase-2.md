# Vertrag 07 — Zustände der Phase 2

- **Status:** **Entwurf — Abnahme offen.** Geschrieben im autonomen Lauf (Plan-0002 WP9.2, D168); vor
  dem ersten CVar abzunehmen (WP9.8). Bis dahin trägt die Mod **keinen** eigenen CVar und genau zwei
  Buffs (`buff700_feuerstelle_aura`, `buff700_amfeuer`, beide `700_60_Welt`).
- **Datum:** 2026-11-23
- **Gilt ab:** Phase 2b, für jeden Zustand, der mehr als einen Augenblick lebt
- **Belege:** Vertrag 02 §2 (Präfixe `buff700_`, `cv700_`) und Klarstellung 1 (CVar-Namen, erstes
  Zeichen offen) · Vertrag 06 (C#-Kern, Schalter, Netz-Wachen) · F-15 (Odem), F-17 B3/B5/Einstellbarkeit
  (Grauen, Direktor, Regler), F-21 (Lernen durch Tun, D48), F-02 (Schild) · Spec 01 §3 (S/C/S+C) ·
  statische Lesung `EntityBuffs` in V 3.40 b10 (§2; Soll-Datei `tools/meta/expect/v07-zustaende.tsv`)

Dieser Vertrag sagt, **welche** Zustände es gibt, **wer** sie schreibt, **was** einen Neustart
überlebt und **wo** die Features sich berühren. Die Zahlen (Anstieg pro Sekunde, Schwellen) gehören
in die Feature-Dokumente und das Balancing (WP14), nicht hierher.

## 1. Grundregeln

1. **Zustand lebt in Buffs und CVars**, solange das reicht (P5). Das Spiel speichert und gleicht sie
   ohnehin ab. Eigene Dateien oder eigene Netzpakete nur mit Nachtrag (Vertrag 06 §6).
2. **Ein Zustand, ein Schreiber.** Jeder CVar hat in §3 genau eine Seite, die ihn setzt. Andere
   lesen nur. Zwei Schreiber sind ein Entwurfsfehler, auch wenn sie dasselbe schreiben würden.
3. **Namen nach Vertrag 02:** `cv700_<name>` in lowerCamelCase nach dem Präfix, `buff700_<name>`.
   Ein Zeichen **vor** dem Präfix ändert das Verhalten des Spiels (§2) und ist Teil des Namens.
4. **Abgeleitete Werte werden nicht gespeichert.** Was sich aus anderen Zuständen berechnen lässt
   (Stufe aus Wert, Seuchendruck aus Spieltag), steht als Buff oder als lokaler CVar, nicht als
   zweite Wahrheit.

## 2. Was das erste Zeichen eines CVar-Namens bewirkt (statisch, V 3.40 b10)

Klarstellung 1 aus Vertrag 02 ließ das offen. Gelesen an `EntityBuffs` (Typ, Felder, Aufrufe und
Vergleichswerte der Methoden; kein Code übernommen):

| Erstes Zeichen | Gelesen | Lesart | Vanilla nutzt es (`buffs.xml`, verschiedene Namen) |
|---|---|---|---|
| `.` | `SetCustomVar` vergleicht vor dem Netz-Aufruf mit `.`; `Write` vergleicht beim Sammeln der zu schreibenden CVars mit `.` | **lokal:** nicht gesendet, nicht gespeichert | 243 — fast nur Anzeigewerte (`.abrasionDurationDisplay`) |
| `_` | `SetCustomVar` vergleicht mit `_` | **vom Spiel gesetzt, nicht gesendet**; geschrieben wie jeder andere | 15 — Motorwerte (`_coretemp`, `_crouching`, `_biomeradiation`) |
| `%` | `SetCustomVar` vergleicht mit `%` | wie `_`, nicht gesendet | 2 |
| `$` oder Buchstabe | kein Vergleich | **normal:** gesendet und gespeichert | `$` 162, Buchstabe 38 |

Alle drei Vergleiche stehen vor dem einzigen Aufruf von `SetCustomVarNetwork`; dazu liest die Methode
`Entity::isEntityRemote` — gesendet wird also nur von der Seite, der das Wesen gehört. Die Richtung
der Sprünge ist aus der Lesung nicht sicher; **die Lesart ist ein Indiz** und wird im Dedicated-Test
bestätigt (S-32 (1)–(3), Projektregel 5).

**Folge für die Namen:** `cv700_…` beginnt mit einem Buchstaben → gesendet und gespeichert. Für reine
Anzeigewerte heißt es **`.cv700_…`** (lokal); `grep "cv700_"` findet beide. `_` und `%` benutzen wir
nicht — sie gehören dem Spiel.

## 3. Die Zustände

Spalten: **Schreiber** = einzige Seite, die setzt. **Neustart** = was nach Server-Neustart gilt.
**Phase** nach D50.

### 3.1 Grauen (F-17 B3)

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `cv700_grauen` | CVar je Spieler | 0–100 | Buffs des Spielers (läuft beim Besitzer, Client bzw. SP); Server-Anteil über §3.3 | **bleibt** | Stufen-Buffs, HUD |
| `buff700_grauenUnruhig` / `…Veraengstigt` / `…Grauen` | Buff | an/aus | aus `cv700_grauen` per `CVarCompare` | abgeleitet | Effekte, Trugbilder (F-17 B4, nur Client) |
| `.cv700_grauenAnzeige` | lokaler CVar | 0–100 | Client | weg | HUD-Leiste |

Steigt und sinkt nach F-17 B3. ~~Die **Messung** von Licht und Nähe zu Mitspielern ist offen (WP9.4,
Kurz-Check: keine XML-Bedingung dafür) — bis dahin die grobe XML-Fassung „Nacht + kein Dach + Zufall"
(F-17, W-33).~~ *Nach WP9.4 ([Finding](../rea/findings/WP9-licht-und-seuchennacht.md)):* Licht per
Buff-Bedingung `CompareLightLevel`, Nähe per Gesellschafts-Buff `buff700_gesellschaft`, den jeder
Spieler im Umkreis auf Verbündete legt (`selfAOE`/`selfOtherPlayers` + `IsAlly`). Beides XML, Indiz bis S-34.

### 3.2 Regler Grauen-Intensität (D13, F-17 Einstellbarkeit)

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `cv700_grauenDaempfung` | CVar je Spieler | **0 voll** · 1 mild · 2 aus | **Server**, bei jedem Betreten der Welt (C#-Kern, Vertrag 06), aus `700_00_Core/Schalter.xml` Zeile `grauen` | wird bei jedem Betreten neu gesetzt | jeder Effekt-Buff per `CVarCompare` |

- **Die Zählung läuft rückwärts, damit der Rückfall stimmt:** ein CVar, den niemand gesetzt hat,
  liest 0 — und 0 ist „voll", die Vorgabe (D13). Fehlt der C#-Teil oder die Datei, läuft alles.
  Hieße 0 „aus", schaltete ein fehlender Schreiber das Grauen still ab.
- Mechanik-Mali verlangen `cv700_grauenDaempfung` = 0; Trugbilder und Furcht-Effekte < 2.
- **aus:** keine Trugbilder, keine Furcht-Effekte; der Wert `cv700_grauen` läuft weiter (Direktor
  liest ihn). **mild:** nur Herzschlag und Sichtrand, keine Mechanik-Mali, Trugbilder selten.
- Warum nicht XML allein? Vanillas `SandboxOptionBool` liest nur Vanillas Optionen; eine eigene
  Server-Option gibt es ohne C# nicht (F-17:106 `[verifizieren]` — bleibt in WP9.4 zu prüfen; zeigt
  sie sich doch, entfällt der C#-Teil).

### 3.3 Bedrohungs-Direktor (F-17 B5, Server)

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| Phase | Feld im C#-Kern | Ruhe · Vorzeichen · Bedrohung · Erlösung | **Server** | **beginnt mit Ruhe** | Direktor |
| `cv700_direktorPhase` | CVar je Spieler | 0–3 | Server, bei Phasenwechsel an alle Spieler (Netz-Weg, §4) | wird nach Betreten neu gesetzt | Klang und Trugbilder auf dem Client |
| Seuchendruck | abgeleitet | aus Spieltag und Seuchennächten | — | abgeleitet | Direktor, Nebel |
| `cv700_grauenDruck` | CVar je Spieler | 0–30 | Server | weg (neu gesetzt) | Anteil am Grauen-Anstieg (F-09 Vorboten) |

**Warum keine Speicherung der Phase:** eine Spannungskurve, die nach einem Neustart in der Ruhe
beginnt, schadet nicht; eine eigene Speicherdatei kostet einen Nachtrag. Der Seuchendruck geht nicht
verloren, weil er aus dem Spieltag folgt.

### 3.4 Odem (F-15, D36)

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `cv700_odem` | CVar je Spieler | 0 bis `cv700_odemMax` | Buffs des Spielers (Regeneration, Kosten) | **bleibt** | Zauber-Requirements, HUD |
| `cv700_odemMax` | CVar je Spieler | Vorgabe aus Runenkundiger-Stufe | Buff aus Attribut (abgeleitet, jedes Mal neu) | abgeleitet | Regeneration |
| `buff700_odemRegen` | Buff | dauernd | beim Betreten gesetzt | neu gesetzt | — |

Ob eine Item-Aktion per XML einen CVar als Kosten prüfen und abziehen kann, klärt WP9.5. Fällt die
Antwort „nein", schreibt ein Patch — dann ist der Schreiber der Patch, und §1 Nr. 2 verlangt, dass die
Buffs dann **nicht** mehr abziehen.

### 3.5 Lernen durch Tun (F-21, D48)

| Name | Art | Schreiber | Neustart | Lesen |
|---|---|---|---|---|
| Fortschritt je Handwerk | Vanillas Handwerks-Fertigkeit (`progression.xml`), **kein** eigener CVar | ~~**Server** (Werkstätten laufen dort; F-21 Nr. 4) — per XML-Auslöser oder Patch nach WP9.3~~ **Buff des Spielers** per `AddProgressionLevel` (WP9.3) | **bleibt** (Vanillas Speicherung) | Rezepte, Qualität |
| `_craftCount_<Gegenstand>` | **Vanillas** Zähler je hergestelltem Stück | Vanilla, beim Spieler (`XUiC_RecipeStack::giveExp`, `EntityPlayerLocal::GiveExp`) | **bleibt** (Indiz: `_` wird gespeichert, S-33 (2)) | unser Lern-Buff per `CVarCompare` — nur lesen |

Kein CVar: die Datenstruktur gibt es (D48), sie wird nur anders gefüttert. ~~Ein Zähler `cv700_…` käme
nur dazu, wenn WP9.3 zeigt, dass der Fortschritt nicht direkt erhöht werden kann.~~ *Berichtigt nach
WP9.3 ([Finding](../rea/findings/WP9-herstellen-und-schaden.md)):* Vanilla zählt schon, beim Spieler,
nicht auf dem Server. Wir lesen Vanillas Zähler und schreiben keinen eigenen.

### 3.6 Schild erhoben (F-02, Phase 3 — hier nur der Name)

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `cv700_schildErhoben` | CVar je Spieler | 0/1 | Client des Spielers (Eingabe) | auf 0 beim Betreten | Server im Schadenspfad (F-02, Patch nach WP9.3) |

Gesendet werden muss er, weil der Server den Schaden rechnet — darum ohne Punkt. Gebaut wird er in
Phase 3 (patch-manifest „Künftige Patch-Ziele").

### 3.7 Am Feuer (besteht, F-17 B8)

| Name | Art | Schreiber | Neustart | Lesen |
|---|---|---|---|---|
| `buff700_feuerstelle_aura` | Flächen-Buff um Feuerstelle, Esse, Kräuterküche | Spiel (Kacheleinheit) | abgeleitet | setzt `buff700_amfeuer` |
| `buff700_amfeuer` | sichtbarer Buff | aus der Aura | abgeleitet | **Grauen sinkt** (§5) |

## 4. Wer schreibt — die drei Wege

| Weg | wann | belegt |
|---|---|---|
| **Buffs des Spielers** (XML: `ModifyCVar`, `CVarCompare`) | der Wert hängt am Spieler und an dem, was er tut oder wo er ist | Vanilla `buffs.xml`: 460 CVar-Namen, 1380× `ModifyCVar`, 637× `CVarCompare` |
| **Server setzt einen CVar am Spieler** (C#, `EntityBuffs::SetCustomVarNetwork(string, float, CVarOperation)`) | der Wert kommt aus Weltzustand (Direktor, Regler) | Signatur in `v07-zustaende.tsv`; Wirkung im Dedicated-Test (S-32 (4)) |
| **Vanillas eigene Daten** (Fertigkeit, Item-Werte) | es gibt die Struktur schon | F-21 D48; Verderb je Stapel (F-19) klärt WP9.5 |

Der Server schreibt **nie** mit `SetCustomVar` an einen Spieler, der ihm nicht gehört — die Lesung
in §2 zeigt, dass dann nichts gesendet wird. Für ihn gilt der Netz-Weg.

## 5. Nahtstellen zwischen den Features

| Von | Zu | Über | Richtung |
|---|---|---|---|
| F-17 B8 Am Feuer | F-17 B3 Grauen | `buff700_amfeuer` aktiv → `cv700_grauen` sinkt | **die Stelle, an der das Grauen sinkt** (F-17:171) |
| F-15 Segen, Bärenmut, Schutzzeichen | F-17 B3 | eigener Buff senkt `cv700_grauen` | ein Schreiber: die Buffs des Spielers |
| F-09 Seuchennacht, Vorboten | F-17 B3/B5 | Server setzt `cv700_grauenDruck`; Direktor wechselt nach Vorzeichen | Server → Spieler |
| F-17 B3 Stufen | F-02 Fernkampf | `buff700_grauenVeraengstigt` → Streuung des Bogens (P3: Nahkampf bleibt) | Buff → Effekt |
| F-17 Regler | alle Furcht-Effekte | `cv700_grauenDaempfung` sperrt per `CVarCompare` | Server → Buffs |
| F-21 Runenkundiger | F-15 Odem | Attributstufe → `cv700_odemMax` | abgeleitet |
| F-17 B5 Direktor | F-06 Wesen, F-17 B4 | `cv700_direktorPhase` → Klang, Trugbilder, Ereignisse | Server → Client |

~~Was „Mitspieler in der Nähe" (Gemeinschaft schützt) und „Licht am Spielerort" liefert, ist offen
(WP9.4). Bis dahin senkt nur das Feuer das Grauen — und das wirkt auf dem Client (F-17:173).~~
*Nach WP9.4:* dazu kommen `CompareLightLevel` (Licht) und `buff700_gesellschaft` (Mitspieler in der
Nähe, vom Nachbarn gelegt) als Senker — beide XML, Indiz bis S-34.

## 6. Neustart — Übersicht

| bleibt | wird neu gesetzt | geht verloren |
|---|---|---|
| `cv700_grauen`, `cv700_odem`, Handwerks-Fortschritt | `cv700_grauenDaempfung`, `cv700_direktorPhase`, `cv700_grauenDruck`, `cv700_odemMax`, `cv700_schildErhoben`, alle Buffs aus Aura und Stufe | Direktor-Phase (beginnt mit Ruhe), alle `.cv700_…` |

Akzeptanz F-21 („bleibt nach Server-Neustart") und F-08 hängen an „bleibt": geprüft in S-32 (5).

## 7. Was dieser Vertrag nicht regelt

- Zahlen: Anstieg, Abfall, Schwellen, Odem-Mengen — Feature-Dokumente, WP14.
- Wie Licht und Nähe gemessen werden — WP9.4.
- Verderb je Stapel — WP9.5 (F-19 ist Phase 2 nur, wenn XML reicht).
- HUD-Leisten (XUi) — eigener Nachtrag, additiv (D5).

## Offen

| Nr. | Frage | Vorschlag |
|---|---|---|
| a | Regler über `Schalter.xml` und C# (N-112) — oder drei Modlet-Fassungen ohne C#? | Schalter, weil Vertrag 06 ihn ohnehin liest |
| b | Direktor-Phase nach Neustart: Ruhe (N-112) | ja, keine eigene Speicherdatei |
| c | Lesart §2 (`.` lokal, `_`/`%` nicht gesendet) | S-32 (1)–(3) |
| d | Erreicht `SetCustomVarNetwork` vom Server einen Spieler auf einem anderen Rechner? | S-32 (4) |
