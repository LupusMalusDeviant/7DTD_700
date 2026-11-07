# F-06 — Seuchentote & Bestiarium

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+A) | S | optional |

## Ziel
Die Gegnerwelt erzählt das Setting: Bauern, Mönche, Krieger und Pilger als Seuchentote;
dazu Wildtiere des frühmittelalterlichen Waldes.

## Umfang
- **Seuchentote:** Umbenennung und Umbalancierung der Vanilla-Zombieklassen (`entityclasses.xml`);
  Stärkestufen „Verderbt“ bzw. „Moorleiche“ statt Feral/Radiated
- **Spawn-Gruppen** (`entitygroups.xml`) nach Biom und Gamestage
- **Wildtiere:** Wolf, Bär, Wildschwein, Hirsch (Vanilla vorhanden); Auerochse (Stretch, braucht Assets)
- **Entfernen:** moderne Sondergegner (z. B. Polizist, Soldat, Krankenschwester) → durch umbenannte Varianten ersetzen

## Umsetzung
- MVP/P2 ohne Assets: Namen, Werte und Sounds per XML; die **Optik bleibt modern** (Q3). Das ist der größte Kompromiss gegenüber Säule P1.
- Mit Assets (falls Q3 = ja): eigene Kleidungs-Texturen und -Meshes auf Vanilla-Rigs.

## Akzeptanzkriterien
- [ ] Keine Gegnerbezeichnung mit modernem Bezug im Spiel
- [ ] Spawn-Mix je Biom dokumentiert
