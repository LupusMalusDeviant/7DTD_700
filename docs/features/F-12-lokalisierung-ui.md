# F-12 — Lokalisierung & UI-Theming

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X | C | nein |

## Ziel
Jeder Text und jedes UI-Element spricht die Sprache des Settings.

## Umfang
- `Localization.txt`: **DE + EN Pflicht** (D7) für alle neuen und umgedeuteten Einträge;
  weitere Sprachen später über die Community (Spalten leer lassen, nicht mit EN füllen)
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
