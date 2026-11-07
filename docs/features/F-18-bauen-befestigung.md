# F-18 — Bauen & Befestigung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1 | X (+A in Phase 2) | S | nein |

## Ziel
Das Vanilla-Blocksystem trägt den Basenbau weiter (D28), nur in Materialien von 700. Ohne
Stahl und Beton bleibt die Basis verteidigbar, weil die **Gegner angepasst** werden (D29).

## Upgrade-Pfad (Umdeutung)

| Vanilla | 700 | Tier | Material |
|---|---|---|---|
| Frame (Holzrahmen) | Rahmen / Flechtwerk-Gerüst | T0 | Holz, Äste |
| Wood | Flechtwerk mit Lehm | T1 | Lehm, Ruten |
| Cobblestone | Fachwerk (Holz + Lehm-Gefache) | T2 | Balken, Lehm, Nägel (Eisen, knapp) |
| Concrete | Bruchstein | T3 | Stein, Kalkmörtel |
| Steel | Mörtelstein (gesetzter Quaderstein) | T4 | Quader, Kalkmörtel |

- Dachformen: Reet, Schindeln, Grassoden
- Verteidigung: Palisade, Spitzpfähle, Graben, Wehrgang, Torhaus (Block-Shapes umdeutet), Fallen aus F-08 und F-15
- Blockformen: Vanilla-Shapes bleiben (P5), nur Materialien und Texturen neu (Retextur Phase 2, F-16)

## Gegner-Anpassung (D29)
- Seuchentote verursachen **deutlich weniger Blockschaden** (Werte in `entityclasses.xml`), damit Mörtelstein ungefähr so standhält wie Vanilla-Stahl gegen Vanilla-Zombies
- Ausgleich: **mehr Gefahr für Spieler** (höherer Schaden gegen Spieler, Grusel-Verhalten F-17, Sagengestalten)
- Ausnahmen: einzelne Brecher-Typen (z. B. „Rammer“) in der Seuchennacht, damit Befestigung nicht trivial wird
- Balancing-Ziel: Eine T3-Befestigung hält eine Seuchennacht der passenden Gamestage, wenn sie verteidigt wird

## Akzeptanzkriterien
- [ ] Kompletter Upgrade-Pfad T0–T4 baubar, kein Beton bzw. Stahl erhältlich
- [ ] Balancing-Test: T3-Basis übersteht verteidigt eine Seuchennacht der Gamestage X, unverteidigt nicht
