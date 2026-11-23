# Asset-Register

Jedes Stück, das nicht aus Vanilla kommt und im Paket landet, hat hier **eine Zeile** — mit Quelle,
Lizenz und Nennung. Die Regeln stehen in
[Vertrag 05 — Asset-Pipeline](../docs/contracts/05-asset-pipeline.md), Abschnitt 5. Ein Stück ohne
Zeile wird nicht ausgeliefert; `tools/assets/symbole.ps1 -Pruefen` macht das rot.

- Quellbilder der Symbole: `assets/quelle/symbole/<Name>.png`
- Fertige Symbole (erzeugt, nicht von Hand bearbeitet): `mod/<Modlet>/UIAtlases/ItemIconAtlas/<Name>.png`
- Erzeugen: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/assets/symbole.ps1`
- Quell-Modelle: das Blender-Skript unter `tools/assets/blender/<stueck>.py` ist die Quelle; Ansichten
  und Maße unter `assets/quelle/modelle/<stueck>/`; das erzeugte Modell (GLB, FBX, Texturen) unter
  `dist/modelle/<stueck>/` — nicht im Repository (Vertrag 05 §7.1). **Ausgeliefert wird noch keines.**

Die Tabelle wird von einem Werkzeug gelesen: eine Zeile je Stück, kein `|` in einer Zelle, ein
Strich (`—`) nur in `Beleg`, `Beschreibung` und `Kosten` und nur bei eigenen Stücken.

| Name | Art | Modlet | Benutzt von | Quelle | Beleg | Lizenz | Nennung | Beschreibung | Kosten | Stand |
|---|---|---|---|---|---|---|---|---|---|---|
| `ico700_silberpfennig` | symbol | `700_20_Material` | `casinoCoin` | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `ico700_schmiedeeisen` | symbol | `700_20_Material` | `resourceForgedIron`, `itm700_schmiedeflicken` (getönt) | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `ico700_tiegelstahl` | symbol | `700_20_Material` | `resourceForgedSteel` | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `ico700_klinge` | symbol | `700_20_Material` | `itm700_klinge` | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |
| `rundschild` | modell | `700_30_Ausruestung` | noch keiner (Rundschild, Konzept S-33; Kennung offen bis F-02 Phase 2) | eigen:blender | — | eigenes Werk des Projekts | keine nötig | — | — | zu prüfen |

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
- **`rundschild`** — erstes Quell-Modell (Plan-0002 WP4.2), gebaut 2026-11-23 mit
  `tools/assets/blender/rundschild.py` nach `docs/konzept/waffen.md` S-33: runder Brettschild, 86 cm,
  sieben Bretter unter heller Rohhaut (die Fugen zeichnen sich ab), Rand mit vernähtem
  Rohhautstreifen, hoher kegeliger Eisenbuckel mit fünf Nieten über dem Faustloch, innen die
  eiserne Fessel mit umwickeltem Griff, je zwei Nieten an den Enden (auch von vorn zu sehen).
  **Nicht dabei:** Tragriemen, Bemalung. 1994 Dreiecke, drei Texturen 1024² (Farbe,
  Rauheit/Metall, Normalen), Ursprung am Griff. Ansichten:
  `assets/quelle/modelle/rundschild/ansicht-vorn.png` und `ansicht-hinten.png`. **Nicht im Spiel,
  nicht in Unity gesehen** — es gibt noch kein Bundle (N-60) und keinen Gegenstand dazu (N-65).
