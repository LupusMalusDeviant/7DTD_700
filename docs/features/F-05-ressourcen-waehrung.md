# F-05 — Ressourcen & Währung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1 | X | S | nein |

## Ziel
Rohstoffe fühlen sich nach 700 an und tragen die Handwerksketten (F-04). **Eisen ist der
Engpass der Epoche** (D31); Holz, Stein und Lehm gibt es reichlich. Bezahlt wird **nur mit
Silber** (D30).

## Ressourcen

| Vanilla | 700 | Häufigkeit | Quelle |
|---|---|---|---|
| Iron (Schrott) | Raseneisenerz → Luppe → Schmiedeeisen | **knapp** | Moor- und Sumpf-Ressourcenblöcke; Altmetall aus Römerruinen; Plünderer-Beute (F-20) |
| Lead, Brass | Kupfer, Bronze-Altmetall | selten | Ruinen |
| Oil Shale, Gas | entfällt; Pech bzw. Teer aus Holz | – | Kräuterküche |
| Coal | Holzkohle (Meiler) | normal | Feuerstelle bzw. Meiler |
| Nitrate | entfällt | – | – |
| Concrete | Kalkmörtel, Bruchstein | normal | Kalkofen, Steinbruch |
| Wood, Stone, Clay | Holz, Stein, Lehm | **reichlich** | überall |
| – (neu) | Bernstein | selten | Küste (Kulturzone), Handel; Magie (F-15), Wegsteine (F-13) |
| – (neu) | Salz | knapp | Handel, Salzquellen-POI; Konservieren (F-19) |

- Erzverteilung je Kulturzone (`biomes.xml` / `rwgmixer.xml`, F-07)

## Währung (D30)
- **Silber** (Sceattas bzw. Denare) als 1:1-Umdeutung der Vanilla-Dukes
- Kein Tauschhandel und keine Mehrfach-Währungen (Nicht-Ziel)

## Akzeptanzkriterien
- [ ] Jedes Rezept in F-02 bis F-04 ist aus diesen Ressourcen erfüllbar
- [ ] Eisen-Ausbeute liegt spürbar unter Vanilla-Eisen (Zielwert im Balancing)
- [ ] Händler akzeptieren Silber; kein „Dukes“-Text sichtbar

## Offene Fragen
- Ist das Currency-Item per XML umbenennbar und umstylbar? → kurzer Check (hook-hypothesen.md#f-05)
