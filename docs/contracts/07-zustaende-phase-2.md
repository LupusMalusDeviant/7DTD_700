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

~~Ob eine Item-Aktion per XML einen CVar als Kosten prüfen und abziehen kann, klärt WP9.5. Fällt die
Antwort „nein", schreibt ein Patch — dann ist der Schreiber der Patch, und §1 Nr. 2 verlangt, dass die
Buffs dann **nicht** mehr abziehen.~~ *Nach WP9.5:* ja, per XML — Bedingung in der `<action>`
(`ExecutionRequirements`), Abzug per `ModifyCVar`. Schreiber bleiben die Effekte des Spielers.

### 3.5 Lernen durch Tun (F-21, D48)

| Name | Art | Schreiber | Neustart | Lesen |
|---|---|---|---|---|
| Fortschritt je Handwerk | Vanillas Handwerks-Fertigkeit (`progression.xml`), **kein** eigener CVar | ~~**Server** (Werkstätten laufen dort; F-21 Nr. 4) — per XML-Auslöser oder Patch nach WP9.3~~ **Buff des Spielers** per `AddProgressionLevel` (WP9.3) | **bleibt** (Vanillas Speicherung) | Rezepte, Qualität |
| `_craftCount_<Gegenstand>` | **Vanillas** Zähler je hergestelltem Stück | Vanilla, beim Spieler (`XUiC_RecipeStack::giveExp`, `EntityPlayerLocal::GiveExp`) | **bleibt** (Indiz: `_` wird gespeichert, S-33 (2)) | unser Lern-Buff per `CVarCompare` — nur lesen |

*Geändert durch Nachtrag 5 (WP12.3): ein gespeicherter Merkwert je Gegenstand kommt dazu.* Kein CVar: die Datenstruktur gibt es (D48), sie wird nur anders gefüttert. ~~Ein Zähler `cv700_…` käme
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

## Nachtrag 1 — Odem, Abklingzeiten, Schutz vor Grauen (Plan-0002 WP10.2), 2026-11-23, **Abnahme offen**

Entwurf im autonomen Lauf nach D174 (F-15 „Der Kern der Phase 2 in Zahlen"); **zu prüfen durch den
Nutzer** (N-119). Noch nichts davon ist gebaut. Der Nachtrag nennt nur Namen, Schreiber und Neustart;
die Zahlen stehen in F-15 (§7 dieses Vertrags).

### N1.1 Ergänzt §3.4 Odem

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `cv700_odemMax` | wie §3.4 | 0 unter Stufe 2 des Runenkundigen, sonst aus der Stufe | **ein** Buff `buff700_odemStufe`, der je Stufe per `ProgressionLevel`-Bedingung setzt | abgeleitet | Regeneration, HUD |
| `.cv700_odemRegen` | lokaler CVar | Odem je Sekunde | **allein** `buff700_odemStufe`: er liest `buff700_amfeuer` (`HasBuff`) und das Bernsteinamulett (Ausrüstungs-Bedingung) und setzt daraus den Wert | abgeleitet | `buff700_odemRegen` |
| `buff700_odemRegen` | Buff (§3.4) | dauernd | — | neu gesetzt | addiert `.cv700_odemRegen` auf `cv700_odem`, kappt bei `cv700_odemMax` |
| Abzug je Auslösen | — | — | der **Gegenstand** (Segen, Zauber, Fluchtopf): `<requirement>` in der `<action>` sperrt, `ModifyCVar` zieht ab | — | — |
| Lichtfunke | — | Abzug solange gehalten | Buff des gehaltenen Gegenstands `buff700_lichtfunke` | neu gesetzt | das Licht des Gegenstands per Bedingung `cv700_odem` > 0 **[verifizieren in WP10.9: ob eine Licht-Wirkung am Gegenstand eine Bedingung trägt]** |
| Quellsud | — | +20 einmal | der Trank (`ModifyCVar` beim Trinken) | — | — |

**Ein Schreiber trotz vieler Quellen:** `cv700_odem` hat zwei Arten Schreiber — die Regeneration und
die Abzüge. Das ist kein Verstoß gegen §1 Nr. 2, solange **alle** Schreiber Effekte des Spielers sind
(§4, erster Weg) und keiner vom Server kommt; der Wert ist ein Vorrat, der von einer Seite gefüllt und
geleert wird. Ein Patch oder der Server schreibt `cv700_odem` nie.

### N1.2 Abklingzeiten

| Name | Art | Schreiber | Neustart | Lesen |
|---|---|---|---|---|
| `buff700_<segen>Abklingen`, z. B. `buff700_segenWehrAbklingen` | Buff, Dauer = Abklingzeit aus F-15 | der Segen beim Auslösen | **bleibt** — Vanilla speichert laufende Buffs mit Restzeit **[verifizieren in WP10.5]** | Bedingung `NotHasBuff` in der `<action>` |
| `buff700_quellsudAbklingen` | ebenso | der Quellsud | ebenso | ebenso |

Abklingzeit als Buff, nicht als CVar mit Zeitstempel: das Spiel zählt die Zeit selbst herunter (P5),
und der Spieler sieht sie als Symbol.

### N1.3 Schutz vor Grauen (Naht F-15 → F-17)

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `.cv700_grauenSchutz` | lokaler CVar | Anteil, um den der **Zuwachs** sinkt; gekappt | **ein** Buff `buff700_grauenSchutz` (`700_75_Magie`), der die Quellen per `HasBuff` und Ausrüstungs-Bedingung zusammenzählt: Schutzzeichen-Aura, Bärenmut, Hammeramulett, Kreuzanhänger | abgeleitet | der Grauen-Buff (`700_60_Welt`, F-17 B3) beim Zuwachs |

Ändert §5, Zeile „F-15 Segen, Bärenmut, Schutzzeichen → F-17 B3": nicht jeder Buff senkt
`cv700_grauen` selbst, sondern **ein** Wert sagt, um wie viel der Zuwachs kleiner ist. Grund: §1 Nr. 2 —
sonst schrieben vier Magie-Buffs in den Grauen-Wert, und keiner wüsste von der Kappung. Die Obergrenze
ist eine Zahl und gehört nach F-17 (WP11.1).

**Der Punkt vor dem Namen** folgt §1 Nr. 4 (abgeleitet → lokal) und hängt an der Lesart aus §2. Zeigt
S-32 (1), dass `.` nicht lokal heißt, oder laufen die Buffs des Spielers auf dem Server, fällt der Punkt
weg — ein Wort, kein neuer Nachtrag.

### N1.4 Auf anderen Wesen

| Name | Art | Schreiber | Neustart | Lesen |
|---|---|---|---|---|
| `buff700_fluchSchwere` | Buff auf dem getroffenen Wesen | Wurf des Fluchtopfs (`Explosion.Buff`) bzw. Bannkreis-Aura | geht verloren (30 s) | Tempo des Wesens |
| `buff700_brand` | Buff auf dem Wesen | Glutrune, Glutpfeil, Glutzeichen | geht verloren | Schaden je Sekunde |

Ob ein Buff auf einem Seuchentoten vom Server oder vom Werfer gesetzt wird, ist nicht gelesen —
gleich, weil kein CVar daran hängt; der Dedicated-Test in WP10.10 zeigt, ob beide Clients ihn sehen.

### N1.5 Neustart — ergänzt §6

| bleibt | wird neu gesetzt | geht verloren |
|---|---|---|
| `cv700_odem`, laufende Abklingzeiten (Indiz) | `cv700_odemMax`, `.cv700_odemRegen`, `.cv700_grauenSchutz`, `buff700_odemStufe`, `buff700_grauenSchutz`, `buff700_lichtfunke` | `buff700_fluchSchwere`, `buff700_brand` |

## Nachtrag 2 — die Odem-Leiste (Plan-0002 WP10.6), 2026-11-23, **Abnahme offen**

Entwurf im autonomen Lauf (D182); **zu prüfen durch den Nutzer** (N-126). Füllt §7 „HUD-Leisten —
eigener Nachtrag".

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `.cv700_odemAnteil` | lokaler CVar | `cv700_odem` / `cv700_odemMax`, 0 ohne Odem | **allein** `buff700_odemRegen`, nach dem Zählen | abgeleitet | die Leiste (`{cvar(…)}`, Finding WP10.6) |
| `.cv700_odemZeigen` | lokaler CVar | 1, wenn `cv700_odemMax` > 0, sonst 0 | **allein** `buff700_odemRegen` | abgeleitet | die Leiste: jedes Bild füllt sich damit, ohne Odem bleibt der Platz leer |

**Wer setzt die zwei Odem-Buffs:** Vanillas `buffStatusCheck01` (läuft bei jedem Spieler, bleibt über den
Tod), per eigener `effect_group` mit `!HasBuff` — damit sind sie nach Betreten, Laden und Tod da. Ergänzt
§3.4 („`buff700_odemRegen` … beim Betreten gesetzt"): der Weg ist dieser.

**Warum die Oberfläche nicht rechnet:** die Bindung `{cvar(…)}` ist gelesen, die Rechen-Schreibweise
`{# … }` mit CVars nicht. Fertige Werte im Buff halten die Oberfläche auf das Gelesene beschränkt.

**Der Punkt** folgt §1 Nr. 4 (abgeleitet → lokal); die Leiste liest auf dem Rechner des Spielers, wo der
lokale Wert liegt. Ob der Buff dort läuft (S-32 (1)), entscheidet wie in N1.3, ob der Punkt bleibt.

## Nachtrag 3 — die drei Zauber (Plan-0002 WP10.9), 2026-11-23, **Abnahme offen**

Entwurf im autonomen Lauf (D183); **zu prüfen durch den Nutzer** (N-127). **Ändert N1.1, Zeile
„Lichtfunke"**: es gibt keinen Buff `buff700_lichtfunke`. Grund: das Licht kommt aus dem Fackel-Modell
(`ItemClassTorch`, Eigenschaft `LightValue`), und eine Eigenschaft trägt in XML keine Bedingung — das
Licht lässt sich nicht an `cv700_odem` > 0 binden. Statt eines eigenen Abzug-Buffs rechnet der eine
Schreiber der Erholung den Abzug mit; ohne Odem zehrt der Funke am Leben.

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `.cv700_odemRegen` (aus N1.1) | lokaler CVar | dazu −0,5, solange ein Gegenstand mit Tag `lichtfunke700` gehalten wird | weiter **allein** `buff700_odemStufe` (`HoldingItemHasTags`) | abgeleitet | `buff700_odemRegen` |
| `.cv700_glutKosten` | lokaler CVar | 10, ab Glutzauber Rang 2: 8 | **allein** `buff700_odemStufe` | abgeleitet | der Glutpfeil: Sperre in der Aktion (`CVarCompare … @.cv700_glutKosten`) und Abzug beim Schuss |
| `buff700_funkeZehrt` | Buff, 2 s, sichtbar | −0,5 Leben je s | `buff700_odemRegen`, jede Sekunde, solange der Lichtfunke ohne Odem gehalten wird | geht verloren | Leben |
| `buff700_bannkreis` | Buff, 20 s, sichtbar | Aura 5 m | der Bannkreis beim Schlag; Sperre `!HasBuff` in der Aktion | **bleibt** wie eine Abklingzeit (Indiz, N1.2) | setzt jede Sekunde `buff700_bannSchwere` (`selfAOE`) |
| `buff700_bannSchwere` | Buff auf anderen Wesen (N1.4), 2 s, verborgen | −25 % Tempo | `buff700_bannkreis` | geht verloren | Tempo des Wesens |

Ergänzt N1.4: der Bannkreis legt **nicht** `buff700_fluchSchwere` (−15 %, 30 s), sondern den kurzen
`buff700_bannSchwere` — wer den Kreis verlässt, ist gleich wieder schnell. Der Glutpfeil legt
`buff700_brand` wie die Glutrune.

## Nachtrag 4 — Grauen und Seuchennacht ausgearbeitet (Plan-0002 WP11.2), 2026-11-23, **Abnahme offen**

Entwurf im autonomen Lauf (D184); **zu prüfen durch den Nutzer** (N-128). Noch nichts davon ist gebaut.
Die Zahlen stehen in F-17 „B3 in Zahlen" und F-09 „Ausarbeitung" (§7 dieses Vertrags).

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `buff700_grauenZaehlen` | Buff, dauernd, verborgen | zählt alle 5 s | gesetzt wie die Odem-Buffs über Vanillas `buffStatusCheck01` (Nachtrag 2) | neu gesetzt | schreibt **allein** `cv700_grauen` (§3.1): Zuwachs × (1 − `.cv700_grauenSchutz`), Abbau, Kappung 0–100 |
| `buff700_grauenUnruhig` / `…Veraengstigt` / `…Grauen` (§3.1) | Buff | an ab 30/60/85, aus unter 25/55/80 | `buff700_grauenZaehlen` per `CVarCompare` | abgeleitet | Effekte nach `cv700_grauenDaempfung` (§3.2) |
| `buff700_grauenPanik` | Buff, 3 s | Lauftempo +10 %, Ausdauer-Erholung −50 % | Treffer (`onOtherDamagedSelf`) bei Stufe Grauen und Dämpfung 0 | geht verloren | — |
| `cv700_mitspielerDa` | CVar je Spieler | 1, wenn mehr als ein Spieler in der Welt ist, sonst 0 | **Server**, Direktor (C#, §3.3), bei Betreten und Verlassen eines Spielers | wird neu gesetzt | Zeile „allein" in `buff700_grauenZaehlen` (D118) |
| `buff700_seuchennachtBeginn` | Buff, ~~70 s~~ **60 s** *(berichtigt beim Bau, WP11.9: der Schlag kommt mit dem Ablauf, `onSelfBuffFinish`)*, verborgen | 60 s Stille, dann ein Glockenschlag und eine Meldung | jeder Spieler selbst (über Vanillas `buffStatusCheck01`), wenn `IsBloodMoon` wahr ist und `buff700_seuchennachtGelaeutet` fehlt | geht verloren | — |
| `buff700_seuchennachtGelaeutet` | Buff, ~~12 h Spielzeit~~ **bis `IsBloodMoon` falsch wird** *(berichtigt beim Bau: so hängt nichts an der Tageslänge)*, verborgen | Marke „heute schon geläutet" | `buff700_seuchennachtBeginn` beim Ende | **bleibt** (Indiz, N1.2) | Sperre gegen ein zweites Läuten |

**Rückfall ohne C#:** `cv700_mitspielerDa` liest 0, „allein" entfällt (Einzelspiel-Regel D118 gilt dann
überall); `cv700_grauenDruck` liest 0, keine Vorboten. Das Grauen selbst läuft ganz in XML.

**Ergänzt §3.1:** der Schreiber von `cv700_grauen` ist **ein** Buff. Treffer schreiben nicht selbst in den
Wert, sondern zählen über einen Auslöser in demselben Buff — sonst hätte `cv700_grauen` zwei Schreiber
derselben Art, und die Kappung wüsste nicht von beiden (§1 Nr. 2).

## Nachtrag 5 — Lernen durch Tun gebaut (Plan-0002 WP12.3), 2026-11-23, **Abnahme offen**

Entwurf im autonomen Lauf (D194); **zu prüfen durch den Nutzer** (N-138). **Ändert §3.5** („kein eigener
CVar"): Vanillas Zähler `_craftCount_<Gegenstand>` zählt weiter, aber was davon **schon gezahlt** ist,
muss ein eigener Wert merken — sonst hebt jeder Takt die Stufe von neuem. **Berichtigt F-21 §2 (D192):**
dort hieß der Merkwert `.cv700_lernGezahlt…` mit Punkt; ein Punkt heißt „nicht gespeichert" (§2), und
nach jedem Laden zahlte der Buff alles noch einmal aus. Der Merkwert trägt darum **keinen** Punkt; das
Ziel wird jeden Takt aus ihm gerechnet und braucht keinen eigenen Speicher.

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `buff700_lernen` | Buff, dauernd, verborgen, Takt 10 s | je Gegenstand der Tabelle `tools/gen/wp12-lernen.tsv` (26) | gesetzt über Vanillas `buffStatusCheck01` wie die Odem-Buffs (Nachtrag 2); **erzeugt** von `tools/gen/wp12-lernen.ps1` | neu gesetzt | — |
| `cv700_lernGezahlt<Kurzname>` | CVar je Spieler und Gegenstand, **gespeichert** | 0–10: so oft hat dieser Gegenstand die Stufe schon gehoben | **allein** `buff700_lernen` (+1 je Hebung) | **bleibt** (Indiz §2, S-49 (3)) | `buff700_lernen` |
| `.cv700_lernZiel` | lokaler Rechenwert, **einer** für alle | Gezahlt × 3 + 3 des gerade gerechneten Gegenstands | **allein** `buff700_lernen`, je Gegenstand neu | abgeleitet | Vergleich mit `_craftCount_…` |
| `.cv700_lernJetzt` | lokale Marke, **eine** für alle | 1 = dieser Gegenstand hebt jetzt | **allein** `buff700_lernen`, je Gegenstand zuerst 0 | abgeleitet | Hebung, Zähler, Meldung |
| `_craftCount_<Gegenstand>` (§3.5) | Vanillas Zähler | — | Vanilla | bleibt | `buff700_lernen` — nur lesen; `kette-pruefen` prüft, dass der Name ein Rezept nennt |

**Bedingung einer Hebung:** `_craftCount_` ≥ Ziel, Gezahlt < 10, Stufe ≥ 11 und < 35. Die Marke
`.cv700_lernJetzt` wird **einmal** je Gegenstand entschieden; Hebung (`AddProgressionLevel`, +1), Zähler
und Meldung fragen nur sie — sonst veränderte das Zählen die Bedingung des nächsten Effekts (Effekte
laufen der Reihe nach, wie in `buff700_odemStufe`; **Indiz**, S-49 (1)).

**Lehrblätter:** die Hefte der acht Stufen, die durch Tun lernen, heben um **3** (die erste
`effect_group`; der Zufallspunkt der Gelehrten-Kleidung bleibt 1). Die übrigen sechs Stufen bleiben bei 1.

**Ergänzt mit WP12.3b (D195, N-139) — Lehrzeit:**

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `prk700_lehrzeit<Baum>` | Perk je Baum (Handwerker, Krieger, Jaeger, Heiler, Fuhrmann), 3 Ränge | Rang 1 ab Attribut 1, Rang 2 ab 4, Rang 3 ab 7; wirkt **nicht selbst** | der Spieler, mit Skill-Punkten | bleibt (Vanilla) | `buff700_lernen` |
| `cv700_lehrzeitGezahlt<Baum>` | CVar je Spieler und Baum, **gespeichert** | 0–3: so viele Ränge sind ausgezahlt | **allein** `buff700_lernen`: ist der Perk ≥ r und Gezahlt = r − 1, hebt er jede Handwerks-Stufe des Baums (D68) einmal um 10 (r = 1) bzw. 3 (r = 2, 3) | **bleibt** (Indiz §2, S-50 (3)) | `buff700_lernen` |

Ausgezahlt wird im Takt des Lern-Buffs (höchstens 10 s nach dem Kauf), nicht beim Kauf: einen
Auslöser „Rang gekauft" kennt XML nicht sicher. **Folge:** wer seine Punkte zurücksetzt, behält die
gezahlten Stufen, und ein neuer Kauf zahlt nichts mehr (Gezahlt bleibt stehen) — kein Doppeln, aber auch
keine Rückgabe. Im Spiel geht Zurücksetzen nur über die Konsole: Vanillas Vergessenstrank
(`drinkJarGrandpasForgettingElixir`) ist gesperrt (Purge, kein Rezept, keine Beute, keine Ware).
