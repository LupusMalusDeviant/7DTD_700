# F-12 — Lokalisierung & UI-Theming

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X | C | nein |

## Ziel
Jeder Text und jedes UI-Element spricht die Sprache des Settings.

## Umfang
- ~~`Localization.txt`~~ **`Config/Localization.csv`** (berichtigt 2026-11-07 — eine Datei
  `Localization.txt` gibt es im Spiel **nicht**): **DE + EN Pflicht** (D7) für alle neuen und
  umgedeuteten Einträge; weitere Sprachen später über die Community (Spalten leer lassen, nicht
  mit EN füllen). Die ausgelieferte Datei hat 25.932 Zeilen und diese Kopfzeile:

  ```
  Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english,
  Context / Alternate Text,german,spanish,french,italian,japanese,koreana,
  polish,brazilian,russian,turkish,schinese,tchinese
  ```

  Drei Fallen darin, alle belegt
  ([Finding](../rea/findings/WP1-modlet-lader-und-xml-patcher.md#6-localization-spec-01-nennt-eine-datei-die-es-nicht-gibt)):
  1. **Fünf Metadatenspalten vor den Sprachen** (`File`, `Type`, `UsedInMainMenu`,
     `NoTranslate`, `KeepLoaded`). Wer `Key,english,german` schreibt, trifft die falschen Spalten.
  2. **Zwischen `english` und `german` steht `Context / Alternate Text`** — keine Sprache. Ein
     Prüfwerkzeug, das „die Spalte nach english ist Deutsch" annimmt, prüft die Kommentarspalte.
  3. **Doppelte Schlüssel werden stillschweigend verworfen**, nur `Localization::addCsv` meldet
     es im Protokoll (*„Duplicate key … Skipping entry"*). Das Prüfwerkzeug muss darauf achten.

  **13 Sprachen** insgesamt, von 20 Spalten; D7 heißt also: zwei füllen, elf leer lassen.
  *(Beim ersten Lauf des Prüfwerkzeugs stand hier „14" — es zählte 11 weitere Sprachspalten
  neben `english` und `german`, und die Zählung von Hand war falsch.)*
- **Glossar** (`docs/glossar.md`) als verbindliche Begriffsquelle (Sceatta, Sax, Spatha, Gambeson …)
- **Namensregeln für das fiktive Mischland (D1):** Ortsnamen erfunden, aber
  frühmittelalterlich klingend (-heim, -feld, -wik, -grad, -dun, -ing); keine realen Orte
  oder Herrscher; Personennamen aus dem germanischen, romanischen, slawischen und keltischen
  Namensschatz der Zeit
- Ladebildschirm-Tipps, Menü- und Spielstart-Texte
- XUi: Farben, Rahmen und Schriften (Pergament- bzw. Holz-Optik nur mit XML und vorhandenen Atlas-Sprites); Kompass- und HUD-Begriffe
- **Mod-Name** bleibt bis zum Release beim Arbeitstitel (D6). Alle sichtbaren Vorkommen
  laufen über *einen* Localization-Key (`700_modName`), damit die spätere Umbenennung nur eine Zeile ist.

## UI-Kompatibilität (D5)
Es gelten die Regeln aus [Spec 01, Abschnitt 4.1](../specs/01-technischer-rahmen.md#41-kompatibilität-mit-ui-mods-entscheidung-d5):
additive, zielgenaue XUi-Änderungen, Präfix `700_`, Theming über Farben und Sprites statt
Layout-Umbau, Testmatrix mit Referenz-UI-Mods (Q8).

## Hinweis Netz
XUi-Änderungen müssen nach unserem Kenntnisstand auf dem Client liegen. **[verifizieren]**

## Akzeptanzkriterien
- [ ] Kein englischer Vanilla-Text mit modernem Bezug in der DE-Version sichtbar
- [ ] Alle 700-Einträge haben DE **und** EN (Prüfskript: keine leere Pflichtspalte)
- [ ] Glossar und Localization sind konsistent (Prüfskript)
- [ ] Mod läuft zusammen mit jeder Referenz-UI-Mod ohne XML-Fehler im Log

## Stand 2026-11-20 — WP8.5, erste Scheibe (D75)

**Gebaut, im Spiel ungesehen:**

- [`docs/glossar.md`](../glossar.md): 49 Festbegriffe mit Kennung, 13 ohne, 77 verbotene Muster (48 beim Anlegen, 29 nach dem Review am selben Tag).
  Die englischen Weltbegriffe hat der Nutzer entschieden: Seuchentote = „the plague-dead",
  Seuchennacht = „Plague Night".
- `tools/check/glossar-pruefen.ps1` hält das Glossar gegen unsere Sprachdatei und läuft in
  `check-all.ps1` mit. Das ist das Prüfskript aus dem dritten Akzeptanzkriterium — **für unsere
  Zeilen**. Das Kriterium bleibt offen, solange Vanilla-Zeilen mit Weltbegriffen sichtbar sind.
- Die Startnotiz (`noteDuke01`) heißt „Pergamentfetzen" und trägt einen eigenen Text; drei
  Beschreibungen lebender Gegenstände sagen jetzt „Seuchentote".

**Was offen ist:** 505 möglicherweise sichtbare Vanilla-Zeilen mit einem Weltbegriff (Aufteilung
und weitere Scheiben im Plan unter WP8.5), fünf offene Begriffe (Glossar Abschnitt 10) und die
Abnahme des Glossars durch den Nutzer (Prüfliste 21).

## Stand 2026-11-20 — WP8.5, dritte Scheibe, erster Teil: der Ladebildschirm (D78)

**Gebaut, im Spiel ungesehen:** von den 40 Tipps des Ladebildschirms sind 27 umgeschrieben,
13 bleiben Vanilla (reine Bedienhilfe). Geschrieben wird über die Sprachzeilen, nicht über
`loadingscreen.xml`; acht Schlüssel tragen einen neuen Tipp, weil das Ding dahinter gesperrt
ist. „Kleber" heißt deutsch „Leim". Sprachdatei 657 Zeilen, Glossar 51 Festbegriffe mit
Kennung und 83 Muster.

**Zweiter Teil (D79), ebenfalls ungesehen:** 53 Menü- und Anzeigezeilen — die Optionen des
Spielstart-Menüs und drei Anzeigen — sprechen von Seuchentoten und Seuchennacht; Vanillas
Kürzel „BM" ist ausgeschrieben. Sprachdatei 710 Zeilen, Glossar 84 Muster.

**Vierte Scheibe (D80), ungesehen:** 37 Zeilen aus Herausforderungen und Aufträgen — die
Seuchennacht-Herausforderungen, die allgemeinen Tötungsziele, neun Zeilen der
Grundlagen-Seite, sechs neutrale Auftragszeilen. 153 Zeilen mit einem Weltbegriff bleiben
liegen und sind eingeteilt (Twitch, Wesen-Namen/F-06, Händler-Rede/F-10, Biome/F-07, tote
Schlüssel). Sprachdatei 747 Zeilen. **Gefunden, keine Textfrage:** 35 von 148 sichtbaren
Herausforderungen sind nach dem Purge unerfüllbar, Felder lassen sich nicht bauen, und die
Händler bieten weiter Stromaufträge an (Plan-0001, Offene Punkte).

**Fünfte Scheibe, erster Teil (D81), ungesehen:** 89 von 631 Rang-Texten und
Blatt-Wirkungen an lebenden Fertigkeiten und Abschriften — nach der Regel des kleinsten
Eingriffs: der gebrochene Begriff wird ersetzt, der Satzteil über ein gesperrtes Ding
gestrichen, Vanillas Zahlen bleiben. 22 gemessene Zeilen warten mit Grund (F-06, F-07,
offene Fragen; neun davon sind Ränge, deren ganze Wirkung an Gesperrtem hängt). Sprachdatei
836 Zeilen.

**Fünfte Scheibe, zweiter Teil (D82), ungesehen:** der Lesedurchgang — 36 Zeilen (22
Blatt-Wirkungen, 14 Rang-Texte), die ein Ding der Neuzeit nennen oder dem Namen unserer
Abschrift widersprechen (Köhler statt Feuerwehrmann, kein Baseball in „Vom Keulenschlag",
Buntmetall statt Messing). Die Blatt-Texte sind ganz gelesen, die Rang-Texte gegen eine
Schlagwortliste gefiltert. Stand: 125 von 631 Zeilen umgeschrieben, 506 tragen Vanillas
Wortlaut; 15 Zeilen versprechen eine Wirkung, die nur Gesperrtes trifft (Plan-0001, Offene
Punkte). Sprachdatei 872 Zeilen.

## Stand 2026-11-21 — WP8.6: Mod-Name und Namensregeln (D83)

Der Mod-Name steht in **einer** Zeile, `700_modName` = „7DTD_700"; das Glossar (§11) führt
ihn als **Alleinnamen**: diese eine Zeile trägt ihn, keine andere Zeile darf ihn enthalten,
der Schlüssel steht genau einmal, und die Glossarzeile ist Pflicht. Gelesen wird der
Schlüssel noch von nichts (erstes Etikett: WP8.7). Das Mischland hat keinen Ort und keine Person mit Namen;
Vanillas „Pummel Pete", „Johnny Newcome" und „Wall Street Tycoon" samt sieben Berufstiteln
der Neuzeit sind aus Rang-Titeln und -Texten entfernt (14 Zeilen neu, 3 berichtigt).
Sprachdatei 887 Zeilen, Glossar 51 Festbegriffe mit Kennung, 88 Muster, 1 Alleinname.
*(Am Tag des Baus stand der Name als Festbegriff mit zwei Verbotsmustern im Glossar; zwei
Reviews haben daraus die Alleinnamen-Regel in ihrer heutigen Form gemacht — Vertrag 04,
die beiden Nachträge zu WP8.6.)* **Offen:** die
Händlernamen (F-10) und ob der sichtbare Arbeitstitel „7DTD_700" oder „700" heißt.

**Offen aus „Ladebildschirm-Tipps, Menü- und Spielstart-Texte":** 158 Händler-Untertitel
(F-10, nicht entschieden), vier Optionszeilen mit „Feral" (englischer Begriff offen), die
zwei Sandbox-Vorlagen, und die Abnahme im Spiel — vor allem, ob das Menü die längeren
Optionsnamen abschneidet (Prüfliste 21 f und g).

**Notiz für später (nicht Phase 1):** die sieben Wesen-Namen mit „Zombie" (`animalZombieBear`,
`zombieSpiderFeral` …) gehören zu F-06 und brauchen die englischen Begriffe für Verderbte und
Moorleichen.
