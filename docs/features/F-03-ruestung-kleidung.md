# F-03 — Rüstung & Kleidung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X (+A) | S | nein |

## Ziel
Rüstung ist teuer, schwer und spürbar. Kleidung schützt vor Kälte und Nässe.

## Umfang
| Tier | Teile | Vanilla-Slot-Basis |
|---|---|---|
| T0 | Lumpen, Fellumhang, Wickelgamaschen | ~~Primitive Set~~ `armorPrimitive*` (umgedeutet) |
| T1 | Wollkleidung, Lederkappe, Lederwams | ~~Leather/Farmer-Sets~~ `armorLightMaster` (eigene Teile) |
| T2 | Gambeson (Steppwams), gesteppte Haube | ~~Padded~~ `armorMediumMaster` (eigene Teile) |
| T3 | Kettenhemd (kurz), Spangenhelm | ~~Military/Iron (umbenannt)~~ `armorHeavyMaster` (eigene Teile) |
| T4 | Langes Kettenhemd, Helm mit Brünne/Wangenklappen | ~~Steel (umbenannt)~~ `armorHeavyMaster` (eigene Teile) |

**Die rechte Spalte war berichtigt, nicht verfeinert (D59, 8. November 2026).** Die fünf
Garnituren Primitive/Leather/Padded/Military/Steel beschreiben eine ältere Spielfassung. In
V 3.40 ist gemessen:

| | Zahl |
|---|---|
| Rüstungsteile in `items.xml` | 178 |
| Garnituren (Rumpf/Kopf/Hände/Füße plus Einzelhüte und -masken) | ~40 |
| davon in WP3 gesperrt | 61 Teile (16 Garnituren) |
| **erreichbar** (Rezept, Loot, Händler, Quest oder Startausrüstung) | **6** |

Die sechs: die vier `armorPrimitive`-Teile, `armorParts` und `armorSkillMagazine` (zu WP7
aufgeschoben). **Alle übrigen Garnituren — Beach, Pirate, Samurai, Hellreaver, Winter, die
Hüte und Masken — sind DLC- und Event-Inhalt ohne jeden Weg** und darum für den Spieler
unerreichbar, ohne dass eine Regel sie nennen müsste. Über das Kreativmenü bleiben sie
sichtbar; `CreativeMode` ist keine Sperre.

Vanilla trägt die Rüstung stattdessen über **drei Gewichtsklassen** als Basisklassen —
`armorLightMaster`, `armorMediumMaster`, `armorHeavyMaster` (plus `armorPrimitiveMaster` und
`armorDLCMaster`) —, und jede Garnitur erbt davon. Darum erben **unsere** Teile ebenfalls
davon, vier Slots je Stufe. Die Modelle (`Meshfile`) borgen wir aus den gesperrten Garnituren:
**der Purge nimmt Wege, keine Meshes.** Retextur und eigene Modelle regelt Phase 2 (D3, F-16).

Die Alternative — vier der 16 gesperrten Garnituren wieder freigeben und umdeuten — wäre
billiger gewesen und holt laut Denylist-Kommentar Warnweste, Schutzhelm und Kevlar zurück,
dazu vier D-Zeilen Rückbau an WP3.

- Gewicht → Bewegungs- und Ausdauer-Malus über vorhandene Rüstungs-Mechanik
- Set-Boni über vorhandene Rüstungsset-Logik: Zuordnung umdeuten
- **Qualität** (D23): Material = Grundstufe, Handwerksqualität = Feinstufe (wie F-02)
- **Schutz je Schadensart** (D21): Gambeson gut gegen Wucht, Kette gut gegen Schnitt und schwächer gegen Stich (Phase 2)
- **Verschleiß & Reparatur** wie bei Waffen (F-02)
- **Der Webstuhl kommt mit diesem Feature (D57, 8. November 2026).** F-04 führt ihn in seiner
  Werkstatt-Tabelle, und der Plan hatte ihn in WP4.4 — aber mit `resourceCloth` allein hätte er
  ein Rezept und keinen Zweck. Erst die Gambeson-Teile aus T2 füllen ihn, darum wird er als
  **WP5.5b** zusammen mit der Rüstung gebaut: Klon-Block, XUi-Fenstergruppe, Bau-Rezept,
  Werkzeugslot Weberschiffchen. Segeltuch aus der F-04-Tabelle hängt an F-13 (Segel, Planen) und
  bleibt davon unberührt

## Nicht im Umfang
- Plattenrüstung (anachronistisch)

## Umsetzung
MVP: nur XML (Items, Rezepte, Localization) auf Vanilla-Modellen.
Phase 2 (D3, F-16): **Retexturen** für T0–T2 (Stoff, Leder, Gambeson); **neue Modelle** für
Kettenhemd und Spangenhelm (T3–T4).

## Akzeptanzkriterien
- [ ] Kettenhemd erst nach Rennofen und Esse (F-04) herstellbar
- [ ] Keine Vanilla-Rüstung mit modernem Namen bleibt erhältlich
