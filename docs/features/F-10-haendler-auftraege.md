# F-10 — Händler & Aufträge

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 2: Handelsposten, Vanilla-Aufträge · 3: Bann, Lore, Eskorte | X+H | S | ja (Eskorte) |

## Ziel
**Feste Handelsposten** (D41) sind die wenigen Inseln der Ordnung in einer verlorenen Welt.
Aufträge führen hinaus in die Bedrohung und erzählen dabei die Geschichte der Seuche (D42).

## Handelsposten (D41)
| Posten | Händler-Typ | Sortiment-Schwerpunkt |
|---|---|---|
| **Klostermarkt** | Bruder Cellerar | Heilmittel, Abschriften, Segenswasser, Kerzen |
| **Marktflecken** | Kaufmann | Werkzeug, Salz, Stoffe, Nahrung, Bernstein |
| **Fürstenhof** | Kämmerer | Waffen, Rüstung, Pferde (teuer, F-13), Aufträge höherer Stufe |
| **Schmiedehof** (optional) | Schmied | Eisen (knapp!), Reparatur, Waffen |

> **Widerspruch, offen** — siehe Prüfung 0003, W-24

- Schutzzone wie Vanilla-Trader, Öffnungszeiten (nachts geschlossen, F-17)
- **Lehrmeister** verkaufen Abschriften (Grundfähigkeiten, F-21)
- Bezahlt wird in Silber (D30)

## Aufträge (D42)
| Typ | Beispiel | Basis | Phase |
|---|---|---|---|
| **Vanilla umgedeutet** | Hof säubern, Reliquie bergen, Lieferung, Brunnen wiederherstellen | Vanilla-Questtypen | 2 |
| **Bann-Aufträge** | Sagengestalt jagen, Pestgrube verbrennen, Schutzzeichen erneuern, Steinkreis vom Kult befreien | Vanilla-Typen + eigene Ziele | 3 |
| **Lore-Ketten** | Lose Hauptgeschichte über die Herkunft der Seuche: Notizen → Auftragskette → Kultstätten (F-20) → Enthüllung | Quest-Ketten + Notizen | 3 |
| **Eskorte** | Pilger, Händler oder Überlebende sicher zu einem Ziel geleiten (eventuell als künftige Gesellen, F-14) | **C#** (Begleit-KI) | 3 |

## Lore-Rahmen (Entwurf)
Die Hauptgeschichte bleibt **mehrdeutig** (GDD 2.1): Ist die Seuche Strafe, Fluch oder
Krankheit? Die Lore-Kette liefert Hinweise aus allen drei Richtungen und lässt die Antwort
offen bzw. dem Spieler. Zuerst den Rahmen in `docs/lore.md` festhalten (Phase 2), dann die
Aufträge.

## Umsetzung
- XML: `traders.xml`, `quests.xml`, Localization, Notizen als Items
- C#: Eskorte (Begleit-KI, Ziel-Erkennung, Scheitern bei Tod) → REA

## Akzeptanzkriterien
- [ ] Jeder Posten hat ein eigenes Sortiment ohne Anachronismen
- [ ] Mindestens 3 Bann-Auftragstypen und eine Lore-Kette mit 5+ Schritten
- [ ] Eskorte funktioniert auf Dedicated mit 2 Clients (NPC folgt, Scheitern sauber)

---

## Ausarbeitung für Phase 2 (Plan-0002 WP8.1, 2026-11-23, D159) — **zu prüfen (N-104)**

Nichts gebaut; dieser Teil macht F-10 baubar für WP8.3 bis WP8.6. Der Lore-Rahmen steht in
[`docs/lore.md`](../lore.md).

### A. Messung (V 3.40 b10, `traders.xml`, `npc.xml`, `quests.xml`, `entityclasses.xml`, Sprachdatei)

- **Fünf Händler**, je eine Figur und ein Ort: `trader_info` 1 Joel, 2 Jen, 6 Bob, 7 Hugh, 8 Rekt
  (dazu 3, 5: Spielerkisten, 4, 10: Automaten, 9: Test). Alle fünf öffnen **4:05** und schließen
  **21:50**, Ware neu alle **3 Tage**. Fraktion `whiteriver`. Je Händler eine Stimme
  (`voice_set`) und eine Auftragsliste.
- **Landschaft je Händler** (aus `rwgmixer.xml`, D153): Rekt Wald (Klosterland), Jen Brandwald
  (Brandland), Bob Wüste (Sandheide), Hugh Schnee (Winterhöhen), Joel Ödland (Moorland); je
  Landschaft 2–4 Posten.
- **Figuren:** fünf eigene Modelle (`@:Entities/Traders/Prefabs/Trader…`) — Neuzeit-Kleidung.
  Vier Männer, eine Frau (Jen).
- **Auftragsarten** (99 `quest`, davon für Händler):

  | Vanilla | Stufen | Ziel im Ort |
  |---|---|---|
  | `fetch` | 1–6 | Kiste holen |
  | `clear` | 1–6 | alle Schläfer töten |
  | `clear_infested` („Befallen") | 2–6 | dasselbe, mehr und stärkere |
  | `fetch_clear` | 2–6 | holen und säubern |
  | `buried_supplies` („Vergraben") | 1–3 | Truhe ausgraben |
  | `treasure_*` („Schatzkarte", 7 Karten) | — | Schatz nach Karte ausgraben |
  | `nexttrader` | 2–5 | zum nächsten Händler gehen |
  | `restore_power` | 2–4 | Generator anwerfen — **heraus seit D135** |
  | `quest_tierNcomplete` | 1–6 | Stufenaufstieg beim Händler |

- **Texte:** Datei-Gruppe `Quest` 347 Zeilen (davon bei uns 10), `quests` 55 (3), `npc` 22 (0),
  `subtitles` 170 (0); 72 Schlüssel `quest_tier…`, davon 30 Angebotstexte (`_offer`). 51
  Auftragstexte nennen White River, Duke, Cassadore, Zombies oder Strom. **Jeder Auftrag, den ein
  Händler anbietet, spricht heute in Neuzeit** — die größte Textlücke der Phase 2 (WP8.4).

### B. Posten und Händler

D41 nennt Kloster, Markt, Fürstenhof; F-10 oben dazu einen Schmiedehof (optional). Fünf Händler
brauchen fünf Posten. **Vorschlag:** die drei aus D41, der Schmiedehof wird zum **Köhlerhof** (er
passt in den Brandwald und trägt Eisen und Holzkohle), dazu ein **Fährhof** im Moor. Kein Händler
wechselt die Landschaft — `rwgmixer.xml` bleibt, wie es ist.

| Vanilla | Landschaft | Posten | Händler (DE / EN) | Schwerpunkt der Ware (WP8.3) |
|---|---|---|---|---|
| Rekt | Klosterland | **Klostermarkt** | Bruder Gerwin, Cellerar / Brother Gerwin, Cellarer | Heilmittel, Kräuter, Abschriften, Kerzen, Wachs |
| Bob | Sandheide | **Marktflecken** | Reginhart, Kaufmann / Reginhart the Merchant | Salz, Stoffe, Werkzeug, Nahrung, Bernstein |
| Hugh | Winterhöhen | **Fürstenhof** | Waldo, Kämmerer / Waldo the Chamberlain | Waffen, Rüstung, Pelz; höhere Stufen |
| Jen | Brandland | **Köhlerhof** | Gisla, Köhlerin / Gisla the Charcoal-Burner | Holzkohle, Pech, Eisen (knapp), Schmiedeware |
| Joel | Moorland | **Fährhof** | Haduwin, Fährmann / Haduwin the Ferryman | Torf, Fisch, Moorkräuter, Seil, Pfeile |

Namen nach Vertrag 02 §6 (germanisch, keine realen Heiligen, D108); sie kommen mit WP8.5 ins
Glossar und in die Sprachdatei (`npcTrader…`). Der Fährhof weicht von D41 ab — **zu prüfen**.
*Stand 2026-11-23:* Sortimente gebaut (WP8.3, D162, N-107), Namen und Postennamen in der Sprachdatei
(WP8.5 Teil 1, D163, N-108); das Schild zeigt ~~nur den Namen~~ seit D166 Amt und Namen (Vertrag 02 Teil B).
Alternative: der Moor-Händler wird ein zweiter Marktflecken.

**Marktfrieden:** die Schutzzone heißt im Text so (lore.md §4). Die Posten bilden keinen Bund; aus
„White River" wird in jedem Text der einzelne Händler („ich", „mein Hof").

### C. Öffnungszeiten

Vanilla 4:05–21:50. **Vorschlag:** **5:00–20:00** an allen Posten („solange es hell ist"); der
Händler sagt nachts nichts, die Pforte ist zu (F-17: Nacht gehört den Toten). Eine Änderung je
`trader_info` in `traders.xml`, `700_70_Handel`. Folge: rund drei Stunden weniger Handel je Tag —
**zu prüfen**, sonst bleibt Vanilla.

### D. Stimmen und Rede (D102)

1 336 gesprochene Zeilen in moderner Sprache; Übersetzen ist ausgeschlossen. **Stumm schalten** über
die Spieloption `TraderDialog` in der Vorlage „Jahr 700", **sobald belegt ist**, dass sie die Stimme
nimmt und nichts bricht (Finding in WP8.5). Gesprochen wird dann nur im Text: Begrüßung, Abschied,
„geschlossen", je Händler drei bis fünf kurze Zeilen im schlichten Ton (WP8.5).

*Stand 2026-11-23 (WP8.5 Teil 2, D164, zu prüfen N-109):* belegt im
[Finding WP8](../rea/findings/WP8-haendlerstimmen-traderdialog.md) — `TraderDialog` ist Ja/Nein,
Vorgabe ein, und schaltet die **Figur** stumm (`EntityTrader::PlayVoiceSetEntry`). Gebaut: `EWA` im
Code der Vorlage. **Nicht** stumm werden die Ansagen am Lautsprecher (Öffnen, Warnung, Schließen);
die ersetzt ein eigener Klang über die Block-Eigenschaften `OpenSound`/`CloseSound`/`WarningSound`
(Vorschlag N-109) oder das Umkleiden der Orte (WP6.5b). Eigene gesprochene oder geschriebene
Händlerzeilen über Begrüßung und Gespräch hinaus (D161) gibt es nicht: ein Textfeld ohne Klang
bietet Vanilla für die Figur nicht — Notiz für Phase 3 (eigene Stimmen, D50).

### E. Auftragsarten, gedeutet

| Vanilla | DE | EN | Deutung im Angebotstext |
|---|---|---|---|
| `fetch` | **Bergen** | Salvage | Ein Bote ließ seine Last im Ort zurück; hol sie. |
| `clear` | **Säubern** | Cleanse | Der Hof soll wieder bewohnbar werden; die Toten müssen fort. |
| `clear_infested` („Befallen") | **Seuchennest** | Plague Nest | Dort sind viele gestorben, und alle sind wieder auf. |
| `fetch_clear` | **Bergen und säubern** | Salvage and Cleanse | beides |
| `buried_supplies` („Vergraben") | **Vergrabenes Gut** | Buried Goods | Ein Händler grub seine Ware ein, ehe er floh. |
| `treasure_*` („Schatzkarte") | **Hortbrief** | Hoard Letter | Ein Brief, wo jemand Silber vergrub — Hortfunde sind für die Zeit typisch. |
| `nexttrader` | **Den Weg öffnen** | Open the Road | Bring Nachricht zum nächsten Posten. |
| `quest_tierNcomplete` | **Ruf am Posten, Stufe N** | Standing at the Post, Rank N | |
| `restore_power` | — | — | bleibt heraus (D135); „Brunnen wiederherstellen" braucht einen eigenen Block im Ort und wartet auf eigene Orte (WP6.6) |

**Stufen 1 bis 6** bleiben Vanillas Stufen (Schwierigkeit und Ort der Stufe). Ohne Städte gibt es
nach D157 im Dorf und in der Wildnis Auftragsorte der Stufe 1–5: 69 / 38 / 20 / 10 / 4; Stufe 6
nutzt in Vanilla Orte der Stufe 5 (nicht gemessen, **[verifizieren]** in WP8.4).

**Belohnungen:** nach D89 (Silber, zeitgemäße Bündel) — steht seit Phase 1.

### F. Erscheinung (0002 §8 Nr. 11, K15)

| Was | Stand | Weg |
|---|---|---|
| Händlerfiguren (5 Modelle) | Neuzeit-Kleidung | eigene Modelle brauchen Unity (Nutzeraufgaben #8/#9, WP7); bis dahin **sichtbare Lücke** |
| Händlerorte `trader_*` | Zäune, Beton, Automaten | Weg C (Umkleiden, WP6.5b nach S-29); Automaten nach N-97 |
| Musik (5 Händler-Themen) | ungehört | offen (K22) |
| Sammelfahne, Suchtasche | moderne Modelle | WP7; Text heißt „Sammelzeichen" |

### G. Reihenfolge der Umsetzung

| Schritt | Was | hängt an |
|---|---|---|
| WP8.2 | Vertragsbezug: `700_70_Handel` trägt Händler, Ware, Aufträge (Vertrag 01, steht) | — |
| WP8.3 | Sortimente je Posten (`traders.xml`), Lehrmeister mit Abschriften | B |
| WP8.4 | 347 + 55 Auftragstexte nach E, Angebote im Ton von lore.md | E, lore.md |
| WP8.5 | Händlernamen, Stimmen aus (Finding), kurze Rede | B, D |
| WP8.6 | Beute in 700 (F-05) | WP6.7 |

### G2. Vertragsbezug (WP8.2, 2026-11-23, D166)

Das in WP8.3 bis WP8.6 Gebaute gegen Vertrag 01 bis 03 gelesen:

| Was | Vertrag | Ergebnis |
|---|---|---|
| `traders.xml`, `loot.xml`, Fundschriften in `700_70_Handel` | 01 (Tabelle „Händler und ihre Ware … Beute-Tabellen"; „Truhen, Fundorte, Beute allgemein → `70_Handel`") | passt |
| Spielvorlage (`EWA`) in `700_60_Welt` | 01 Nachtrag 1b, 03 B (`sandbox_overrides.xml` → `60_Welt`) | passt |
| Sprachzeilen in `700_90_Sprache`, vorher im Glossar | 02 §5, Glossar-Regel | passt |
| `remove` auf `trader_items[1]/item` | 03 §4: `remove` erlaubt für Einträge von Händler-Warengruppen, nicht für Definitionen | passt |
| XPath absolut, ohne `//` | 03 Regel 2 | passt |
| neue Gruppen | keine angelegt; Präfixe `lg700_` (besteht) und `tg700_` (Nachtrag 02 A, für eigene Warengruppen) stünden bereit | passt |
| **Namensschild der Händler** | 02 Nachtrag Teil B: „Händler: **Posten**, dazu ein Personenname" (Beispiel „Schmied Radulf") | **wich ab** — D163 setzte den Namen allein. **Berichtigt (D166):** Bruder Gerwin, Kaufmann Reginhart, Kämmerer Waldo, Köhlerin Gisla, Fährmann Haduwin |
| `subtitles.xml` „Untertitel statt Stimmen" | 03 Nachtrag B | trägt nach dem Finding zu `TraderDialog` vermutlich nicht (Untertitel hängen am Klang); als Hinweis in Vertrag 03 eingetragen, Abnahme offen |

### H. Offen für den Nutzer (N-104)

1. **Fünf Posten** — Köhlerhof statt Schmiedehof, Fährhof neu (weicht von D41 ab)?
2. **Namen** der fünf Händler.
3. **Öffnungszeiten** 5:00–20:00 oder Vanilla.
4. **Lore-Rahmen** (`docs/lore.md`) — drei Deutungen, Marktfrieden, keine Händler-Fraktion.

Phase 3 (Notiz, D50): Bann-Aufträge, Lore-Kette, Eskorte — unverändert oben.
