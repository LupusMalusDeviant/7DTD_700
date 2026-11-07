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
- **Bestiarium größer als Vanilla** (D40): Jeder Vanilla-Zombie bekommt eine 700-Entsprechung, dazu **Varianten je Kulturzone** (D43), etwa Mönche und Pilger im Klosterland, Krieger im Burgwall-Land, Fischer und Seeleute an der Küste, Moorleichen im Moor
- **Spawn-Gruppen** (`entitygroups.xml`) nach Kulturzone und Gamestage
- **Blockschaden reduziert, Spielerschaden erhöht** (D29, siehe F-18); einzelne Brecher-Typen (Rammer) für die Seuchennacht
- Menschliche Gegner (Plünderer, Seuchenkult): siehe **F-20**
- **Wildtiere:** Wolf, Bär, Wildschwein, Hirsch (Vanilla vorhanden); Auerochse (optional ab Phase 3, braucht Assets)
- **Entfernen:** moderne Sondergegner (z. B. Polizist, Soldat, Krankenschwester) → durch umbenannte Varianten ersetzen
- **Sagengestalten** (D11, wenige und selten), möglichst auf Vanilla-Sondergegner abgebildet:

  | Sagengestalt | Folklore-Bezug | Spielrolle | Mögliche Vanilla-Basis |
  |---|---|---|---|
  | **Nachzehrer** | Toter, der aus dem Grab heraus Lebende auszehrt | zäher Seuchentoter, „frisst“ Leichen und heilt sich | gepanzerter/zäher Zombie |
  | **Irrlicht** | Licht im Moor, das Wanderer in die Irre führt | lockt in Fallen bzw. Moor, schwer zu treffen, nur nachts | fliegender Gegner (Geier-Logik) mit Lichtpartikel |
  | **Moorgeist / Moorleiche** | Moorleichen, Wiedergänger aus dem Sumpf | Hinterhalt aus Wasser bzw. Schlamm | Zombie-Variante mit Spawn nur im Moor |
  | **Spuk-Hund (Schwarzer Hund)** | Gespensterhund als Todesbote | schneller Jäger in der Seuchennacht | Zombie-Hund |
  | **Schreiende** | Klageweib bzw. Unheilsbotin | ruft andere Seuchentote herbei | Screamer |

  Gegenmittel liefert F-15 (Bannrune, Lichtfunke, Totensegen).

- **Grusel-Verhalten (D12, Details in F-17 B6):** Totsteller (liegende Leichen in POIs, die aufstehen), Pirscher (folgt auf Abstand im Nebel), Lauscher (reagiert stark auf Geräusche). Seuchentote sind leiser als Vanilla-Zombies.

## Umsetzung
- MVP: Namen, Werte und Sounds per XML; die Optik ist noch modern (temporärer Kompromiss).
- Phase 2 (D3, F-16): **Retexturen** der Vanilla-Zombies sind der Hauptweg (Kittel, Kutte,
  Wollmantel statt Jeans und Uniform). **Neue Meshes** auf Vanilla-Rigs nur für Leitfiguren
  (z. B. Seuchenmönch, gefallener Krieger mit Kettenhemd).
- Volksmagie (F-15): Bannrunen, Segenswasser und Totensegen wirken gezielt gegen Seuchentote
  und Sagengestalten. Umgesetzt wird das über Entity-Tags und Buff-Bedingungen (XML).
- Kulturzonen (D43): Variantenpflege über Retexturen derselben Rigs (F-16), nicht über neue Modelle

## Akzeptanzkriterien
- [ ] Keine Gegnerbezeichnung mit modernem Bezug im Spiel
- [ ] Spawn-Mix je Biom dokumentiert
