# F-03 — Rüstung & Kleidung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X (+A) | S | nein |

## Ziel
Rüstung ist teuer, schwer und spürbar. Kleidung schützt vor Kälte und Nässe.

## Umfang
| Tier | Teile | Vanilla-Slot-Basis |
|---|---|---|
| T0 | Lumpen, Fellumhang, Wickelgamaschen | Primitive Set |
| T1 | Wollkleidung, Lederkappe, Lederwams | Leather/Farmer-Sets |
| T2 | Gambeson (Steppwams), gesteppte Haube | Padded |
| T3 | Kettenhemd (kurz), Spangenhelm | Military/Iron (umbenannt) |
| T4 | Langes Kettenhemd, Helm mit Brünne/Wangenklappen | Steel (umbenannt) |

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
