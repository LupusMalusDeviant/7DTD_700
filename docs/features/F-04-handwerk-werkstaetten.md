# F-04 — Handwerk & Werkstätten

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1: Ketten, Werkstätten, Brennstoff, Werkzeuge · 1/WP5: Webstuhl · 2: Runenbank, Räucherkammer · 3: Gesellen | X (+H) | S | optional |

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

> **Widerspruch, offen** — siehe Prüfung 0003, W-28 (Zeile „Kräuterküche“, Werkzeugslot „Destillierhelm“).

**Die drei Klone sind nicht Phase-1-Arbeit (D57, 8. November 2026).** Sie wandern in die Pakete,
die ihren Inhalt bringen, weil nach dem Purge in ganz Vanilla kein Satz von fünf Rezepten übrig
ist, der auf einen von ihnen gehört — ihr Inhalt liegt in anderen Features:

| Klon | wandert nach | weil der Inhalt dort entsteht |
|---|---|---|
| Webstuhl | **F-03 / Plan WP5** (noch Phase 1) | Gambeson-Teile; Tuch allein trägt keine Werkstatt |
| Räucherkammer / Trockengestell | **F-19, Phase 2** | Konserven |
| Runenritzer-Bank | **F-15, Phase 2** | Runen, Runensteine, Glutladungen |

Phase 1 endet damit mit den fünf umgedeuteten Vanilla-Blöcken, wobei `forge` Rennofen und Esse
in einem Block trägt — und, sobald WP5 steht, dem Webstuhl. Leer gebaut wären die drei Blöcke
eine Enttäuschung im Spiel und ein dauerhaft offenes Kriterium auf dem Papier.

**Der Webstuhl steht (WP5.5b, 8. November 2026).** `blk700_webstuhl` in
`mod/700_40_Bauen/Config/blocks.xml` ist der **erste eigene Block des Projekts**, mit
Fenstergruppe in `XUi_InGame/xui.xml`, Bau-Rezept an der Zimmermannsbank und **fünf Rezepten**
(Steppbahn plus die vier Gambeson-Teile). Zwei Punkte sind dabei nicht erledigt, sondern benannt:

- **Kein Werkzeugslot.** Die Tabelle oben gibt dem Webstuhl ein *Weberschiffchen*. Ein
  Werkzeugslot ist kein Blockeintrag, sondern ein eigenes XUi-Werkzeugfenster plus ein
  Gegenstand plus `Modules="output,tools"` — drei Dinge für eine Feinheit, die **kein Rezept der
  Phase 1 braucht**: alle fünf Webstuhl-Rezepte laufen ohne Werkzeug. Abweichung von dieser
  Tabelle, nicht still weggelassen.
- **Das Modell ist geborgt und sieht aus wie die Zimmermannsbank.** Vanilla hat keinen Webstuhl;
  von den Prefabs unter `Entities/Crafting` ist die Holzwerkbank das einzige Stück Holzmöbel, das
  nicht Sägeblatt, Kessel oder Getränkeautomat ist. Zwei Werkstätten mit demselben Körper sind im
  Spiel verwirrend — eigenes Modell in Phase 2 (D3, F-16).

**VIER VON FÜNF WERKSTÄTTEN WAREN NICHT ZU BAUEN (Berichtigung an WP4.3, 8. November 2026).**
Beim Bauen des Webstuhls gemessen: WP4.3 hat Namen, Brennstoff und Werkzeugslots umgedeutet und
nie nachgesehen, ob das **Bau-Rezept** nach dem Purge noch geht.

| Werkstatt | gesperrte Zutat im Bau-Rezept | Stand |
|---|---|---|
| Feuerstelle (`campfire`) | — | ging schon |
| Zimmermannsbank (`workbench`) | `resourceMechanicalParts`, `resourceDuctTape` | **berichtigt**, jetzt mit Leder |
| Rennofen + Esse (`forge`) | `resourceDuctTape`, `resourceMetalPipe` | **berichtigt**, jetzt mit Lehm |
| Kräuterküche (`chemistryStation`) | `toolBeaker`, `resourceMetalPipe`, `resourceAcid` | **berichtigt**, Lehm statt Rohr, Eisen von 100 auf 20 |
| Kalkofen (`cementMixer`) | `resourceSpring`, `smallEngine`, `resourceMechanicalParts` | **berichtigt**, Bruchstein und Lehm statt Motor |

Das war **kein Randfall, sondern der tragende Teil der Kette**: ohne Esse kein Schmiedeeisen,
ohne Schmiedeeisen keine Klinge, keine Spatha, kein Kettenhemd. Die ganze Rohstoffkette aus WP4.6
stand auf einem Block, den niemand bauen kann, und das Kriterium „jede Werkstatt hat ein
Bau-Rezept" war auf dem Papier abgehakt. Gefunden hat es die Zählung
`rezepte_mit_gesperrter_zutat` aus WP5.1 — die 94 toten Rezepte, von denen hier vier standen.
Die Patches stehen in `mod/700_40_Bauen/Config/recipes.xml`.

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
      — in Phase 1 geprüft an den fünf umgedeuteten Vanilla-Werkstätten; für die drei Klone wird
      das Kriterium mit ihrem Inhalt abgenommen (D57), nicht vorher
- [ ] Eisen ist der spürbare Engpass (D31), aber nie eine harte Blockade (Altmetall aus Ruinen als Ventil)
