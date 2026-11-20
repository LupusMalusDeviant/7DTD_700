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

- [`docs/glossar.md`](../glossar.md): 49 Festbegriffe mit Kennung, 13 ohne, 48 verbotene Muster.
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

**Notiz für später (nicht Phase 1):** die sieben Wesen-Namen mit „Zombie" (`animalZombieBear`,
`zombieSpiderFeral` …) gehören zu F-06 und brauchen die englischen Begriffe für Verderbte und
Moorleichen.
