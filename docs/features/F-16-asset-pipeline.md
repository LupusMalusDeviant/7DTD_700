# F-16 — Asset-Pipeline

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 (Start) | A | C | nein |

> **Stücklisten (Nachtlauf 2026-11-22, zu prüfen durch den Nutzer, D126, D127, D130):** drei
> Papiere nennen, was Phase 2 an Bildern und Modellen braucht, je mit Rang und Begründung —
> Waffen: [`konzept/waffen.md`](../konzept/waffen.md) §5; Rüstung:
> [`konzept/ruestung.md`](../konzept/ruestung.md) §5.3; alles Übrige (Symbole, Wesen,
> Werkstätten, Trinkgefäß, Schriften): [`pruefung/0002-erscheinung.md`](../pruefung/0002-erscheinung.md)
> §6. Gemeinsame Empfehlung, abweichend von der Reihenfolge unten: **Symbole zuerst** (kein
> Modell nötig, sofort sichtbar), der Langbogen von Priorität 3 auf 1. Die Reihenfolge unten ist
> dadurch nicht geändert.

## Ziel
Ein reproduzierbarer Weg von Quell-Asset bis zum Spiel, für **Retexturen und neue
Modelle** (Entscheidung D3). Er steht, bevor die eigentliche Asset-Produktion beginnt.

## Umfang
1. **Unity-Projekt** `unity/` in der exakten Unity-Version des Spiels [verifizieren]
2. **Bundle-Build-Skript** (Editor-Skript): erzeugt `Resources/700_*.unity3d`; ein Bundle je Bereich (weapons, armor, entities, blocks, ui)
3. **Retextur-Workflow:** Vanilla-UV-Layout als Vorlage → neue Textur → Material im Bundle → Referenz in XML auf das Vanilla-Mesh mit neuem Material [verifizieren: ob Material-Override per XML möglich ist oder ein Mesh-Duplikat ins Bundle muss]
4. **Neues-Modell-Workflow:** Blender → FBX → Unity-Prefab (Collider, Hand-Halter bzw. Rig-Mapping) → Bundle → XML
5. **Icons:** 160×160 PNG [verifizieren], automatisch in den Mod-Ordner kopiert
6. **Asset-Register** `assets/ASSETS.md`: Name, Typ (Retextur/neu), Quelle, Autor, Lizenz, Status
7. **Git LFS** für Quell-Dateien (`*.blend`, `*.psd`, `*.png` > 1 MB, `*.fbx`)

## Durchstich (erstes Ziel)
Ein **retexturierter Knüppel** und ein **neues Rundschild-Modell** im Spiel, auf dem
Dedicated Server mit einem zweiten Client sichtbar. Erst danach wird in die Breite produziert.

## Asset-Liste (Priorität)
| Prio | Retextur | Neu |
|---|---|---|
| 1 | Seuchentote (häufigste 6 Zombies), Fackel, Lederrüstung | Rundschild, Spatha, Sax, **Runenstein der Glut + Glutpfeil-Effekt** |
| 2 | Blöcke Flechtwerk/Lehm/Reet/Bruchstein, Truhen, Kraftsteine (aus Generator/Solar/Batterie) | Rennofen, Kettenhemd, Spangenhelm, Runen-Icons, Trank-Icons |
| 3 | Wildtiere, Möbel, Sagengestalten (aus Vanilla-Sondergegnern) | Langbogen, Armbrust, Schrein, Webstuhl, Irrlicht-Partikel |

## Klang & Grusel-Assets (D12, F-17)
Sound ist für den Grusel wichtiger als jedes Modell. Deshalb bekommt Klang eine eigene Spur:
- **Prio 1:** Ambient-Loops (Wald nachts, Moor, Wind), ferne Glocke, Raunen und Flüstern, Herzschlag und Atem (Furcht), leisere Seuchentote-Laute
- **Prio 2:** Sagengestalten-Laute, Trugbild-Sounds (Schritte, Klopfen, Name flüstern), Schattengestalt (Trugbild-Modell)
- Audio-Format und Lautstärke-Normalisierung festlegen; 3D-Positionierung testen

## Magie-Effekte (D10: dezent)
- Erlaubt: Glimmen von Runen, Funken, Glutpfeil mit Rauchspur, Nebelhauch, Geräusche (Raunen, Knistern)
- Nicht erlaubt: Explosionen, Blitze, Leuchtstrahlen, große Lichtkugeln, Bildschirm-Flashes
- Partikel-Budget: kleine Partikelzahlen, damit 20 Runensteine in der Seuchennacht die Client-FPS nicht drücken
- Effekte laufen auf dem **Client**; die Auslösung muss serverseitig synchron sein (Test in F-15)

## Akzeptanzkriterien
- [ ] Durchstich funktioniert in SP und auf dem Dedicated Server mit 2 Clients
- [ ] Bundle-Build ist ein einziger Befehl und reproduzierbar
- [ ] Jedes Asset im Spiel steht im Asset-Register mit geklärter Lizenz

## Asset-Quellen (D84, 2026-11-22)

| Art des Stücks | Quelle |
|---|---|
| Einfache harte Formen: Rundschild, Sax, Spatha, Runenstein | selbst in Blender |
| Requisiten: Rennofen, Schrein, Webstuhl, Helm | Meshy, Nacharbeit in Blender |
| Block-Texturen: Lehm, Reet, Bruchstein, Holz | CC0-Bibliotheken (Poly Haven, ambientCG) |
| Klang | CC0 (Freesound nur CC0-Dateien, Sonniss-Pakete), eigene Aufnahmen |
| Gekaufte Packs | **nicht** — die Weitergabe in einer frei verteilten Mod ist oft verboten |

Die Lizenz wird je Datei gelesen und im Asset-Register eingetragen, nicht je Quelle angenommen.

## Offene Fragen
- ~~Q9: Asset-Quellen (selbst / beauftragt / lizenzierte Packs)?~~ Entschieden mit D84.
- **Lizenz der Meshy-Ergebnisse:** hängt nach Claudes Stand vom Tarif ab, ungelesen. Vor dem
  ersten Stück klären und im Register festhalten.
- **Was „Retextur" heißen darf:** nicht veränderte Vanilla-Texturen ausliefern (Spec 01 §6),
  sondern eine eigene Textur auf dem Vanilla-Modell. Ob das per XML geht oder ein eigenes
  Modell ins Bundle muss, ist die erste Frage an den Durchstich (Umfang, Punkt 3).
