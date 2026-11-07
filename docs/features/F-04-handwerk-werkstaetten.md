# F-04 — Handwerk & Werkstätten

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1: Ketten, Werkstätten, Brennstoff, Werkzeuge · 3: Gesellen | X (+H) | S | optional |

## Ziel
Fortschritt entsteht durch Werkstätten, Rohstoffketten und **eigenes Tun** (Säule P2, D24).
Ketten sind **mittel** tief (D25): Zwischenprodukte sind sichtbar, aber ohne Mikromanagement.

## Tech-Tiers (D27)
Fünf Tiers wie im GDD 3.1: Überleben → Hof → Werkstatt → Burg → Meister.

## Werkstätten

| 700-Werkstatt | Vanilla-Basis | Brennstoff | Werkzeugslots | Erzeugt |
|---|---|---|---|---|
| Feuerstelle | Campfire | Holz | Topf, Spieß | Nahrung, Holzkohle (klein), Leim |
| Zimmermannsbank | Workbench | – | Säge, Hobel, Bohrer | Holzwaffen, Bögen, Schilde, Karren, Möbel, Fallen |
| Rennofen | Forge (Teil 1) | Holzkohle | Blasebalg | Luppe aus Raseneisenerz |
| Esse + Amboss | Forge (Teil 2) | Holzkohle | Amboss, Zange, Hammer | Schmiedeeisen, Klingen, Ketten, Nägel |
| Kräuterküche | Chemistry Station | Holz | Mörser, Destillierhelm | Heilmittel, Tränke, Pech, Gerbstoffe |
| Kalkofen | Cement Mixer | Holz/Holzkohle | – | Branntkalk → Mörtel (T3-Bau) |
| Runenritzer-Bank | (Klon per XML) | – | Ritzmesser, Meißel | Runen, Runensteine, Glutladungen (F-15) |
| Webstuhl | (Klon per XML) | – | Weberschiffchen | Tuch, Gambeson-Teile, Segeltuch |
| Räucherkammer / Trockengestell | (Klon per XML) | Holz | – | Konserven (F-19) |

**Bedingungen (D26):**
- **Brennstoff:** Vanilla-Forge-Prinzip für Rennofen, Esse, Kalkofen, Kräuterküche, Räucherkammer
- **Werkzeuge:** Werkzeugslots schalten bessere Rezepte bzw. Qualitäten frei (Vanilla-Tool-Slots)
- **Gesellen (Phase 3, F-14):** NPC-Helfer beschleunigen die Werkstatt bzw. sparen Brennstoff

## Beispielkette (mittel, D25)
`Raseneisenerz + Holzkohle → (Rennofen) Luppe → (Esse) Schmiedeeisen → (Esse + Amboss) Klinge → (Zimmermannsbank) Spatha`
Stahl (T3): Schmiedeeisen + Holzkohle (Aufkohlen) an der Esse; Damast (T4) nur mit Meister-Abschrift.

## Wissen
Rezepte gehorchen **Learning by Doing** (D24, F-21): Die Grundfähigkeit kommt per Skill-Punkt
oder Abschrift; Herstellen verbessert Qualität und schaltet Varianten frei. Abschriften
findet man in Klöstern und Ruinen und kauft sie bei Lehrmeistern (F-10).

## Akzeptanzkriterien
- [ ] Vollständiger Pfad T0 → T4 ohne Sackgasse (Rezeptgraph-Prüfskript)
- [ ] Jede Werkstatt hat Bau-Rezept, Brennstoffregel bzw. Werkzeugslots und mindestens 5 Rezepte
- [ ] Eisen ist der spürbare Engpass (D31), aber nie eine harte Blockade (Altmetall aus Ruinen als Ventil)
