# Asset-Register

Jedes Stück, das nicht aus Vanilla kommt und im Paket landet, hat hier **eine Zeile** — mit Quelle,
Lizenz und Nennung. Die Regeln stehen in
[Vertrag 05 — Asset-Pipeline](../docs/contracts/05-asset-pipeline.md), Abschnitt 5. Ein Stück ohne
Zeile wird nicht ausgeliefert; `tools/assets/symbole.ps1 -Pruefen` macht das rot.

- Quellbilder der Symbole: `assets/quelle/symbole/<Name>.png`
- Fertige Symbole (erzeugt, nicht von Hand bearbeitet): `mod/<Modlet>/UIAtlases/ItemIconAtlas/<Name>.png`
- Erzeugen: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/assets/symbole.ps1`

Die Tabelle wird von einem Werkzeug gelesen: eine Zeile je Stück, kein `|` in einer Zelle, ein
Strich (`—`) nur in `Beleg`, `Beschreibung` und `Kosten` und nur bei eigenen Stücken.

| Name | Art | Modlet | Benutzt von | Quelle | Beleg | Lizenz | Nennung | Beschreibung | Kosten | Stand |
|---|---|---|---|---|---|---|---|---|---|---|
| `ico700_silberpfennig` | symbol | `700_20_Material` | `casinoCoin` | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `ico700_schmiedeeisen` | symbol | `700_20_Material` | `resourceForgedIron`, `itm700_schmiedeflicken` (getönt) | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `ico700_tiegelstahl` | symbol | `700_20_Material` | `resourceForgedSteel` | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `ico700_klinge` | symbol | `700_20_Material` | `itm700_klinge` | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |

## Anmerkungen zu einzelnen Stücken

- **`ico700_silberpfennig`** — drei gehämmerte Silberscheiben mit Perlkreis, ohne Schrift und ohne
  Zeichen; in Blender aus Grundformen gebaut und gerendert (2026-11-23). Erstes eigenes Symbol,
  Durchstich für den Weg vom Quellbild ins Spiel (Plan-0002 WP3.4). **Im Spiel nicht gesehen** (S-09).
  Das Blender-Skript für alle vier Bilder liegt seit dem 2026-11-23 unter `tools/assets/blender/`
  (Freigabe des Nutzers, N-61).
- **`ico700_schmiedeeisen`**, **`ico700_tiegelstahl`** — ausgeschmiedete Stäbe, dunkel und rostfleckig
  (Eisen) bzw. bläulich und glatter (Stahl). Ersetzen Vanillas gegossenen Barren mit dem Stempel
  „Fe 26" (Schrift, Ordnungszahl). Gebaut 2026-11-23 in Blender (Plan-0002 WP3.6).
- **`ico700_klinge`** — rohe Klinge mit Angel, ohne Griff. Der Gegenstand zeigte vorher denselben
  gestempelten Barren. Gebaut 2026-11-23 in Blender.
