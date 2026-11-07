# F-05 — Ressourcen & Währung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X | S | nein |

## Ziel
Rohstoffe und Geld fühlen sich nach 700 an und tragen die Handwerksketten (F-04).

## Umfang
| Vanilla | 700 | Quelle |
|---|---|---|
| Iron (Schrott) | Raseneisenerz → Luppe → Schmiedeeisen | Moor/Sumpf-Ressourcenblöcke, Altmetall aus Römerruinen |
| Lead, Brass | Bronze-Altmetall, Kupfer | Ruinen, selten |
| Oil Shale, Gas | entfällt; Pech/Teer aus Holz (Kräuterküche) | – |
| Coal | Holzkohle (Meiler) | Feuerstelle/Meiler |
| Nitrate | entfällt | – |
| Concrete | Kalkmörtel, Bruchstein | Kalkofen |
| Dukes | **Silber**: Sceattas (Münze), Hacksilber (Material) | Loot, Handel |

- Erzverteilung in Biomen umstellen (`biomes.xml` / `rwgmixer.xml`)

## Akzeptanzkriterien
- [ ] Jedes Rezept in F-02 bis F-04 ist aus diesen Ressourcen erfüllbar
- [ ] Händler (Vanilla) akzeptieren Silber als Währung (Umdeutung des Currency-Items)

## Offene Fragen
- Lässt sich das Currency-Item per XML umbenennen und umstylen, oder ist die Währung hart codiert? → leichter REA-Check (Hypothese in hook-hypothesen.md#f-05)
