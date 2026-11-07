# F-04 — Handwerk & Tech-Progression

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X (+H) | S | optional |

## Ziel
Fortschritt entsteht durch Werkstätten, Rohstoffketten und Wissen (Säule P2), nicht
durch Hightech-Loot.

## Umfang
**Werkstätten** (Umdeutung der Vanilla-Stationen):
| 700-Werkstatt | Vanilla-Basis | Erzeugt |
|---|---|---|
| Feuerstelle | Campfire | Nahrung, Holzkohle (klein), Leim |
| Zimmermannsbank | Workbench | Holzwaffen, Bögen, Schilde, Möbel, Fallen |
| Rennofen | Forge (Teil 1) | Luppe aus Raseneisenerz und Holzkohle |
| Esse + Amboss | Forge (Teil 2) / Workbench-Tool | Schmiedeeisen, Klingen, Ketten |
| Kräuterküche | Chemistry Station | Heilmittel (F-11), Pech, Gerbstoffe |
| Kalkofen | Cement Mixer | Branntkalk → Mörtel (T3-Bau) |
| Webstuhl (optional) | – (neue Station) | Tuch, Gambeson-Teile |

**Wissen:** Vanilla-Magazine und -Bücher werden zu **Abschriften** (Schmiedekunst,
Bogenbau, Heilkunde, Baukunst). Gefunden werden sie in Klöstern und Ruinen; Lehrmeister bei
Händlern verkaufen sie (F-10).

**Perks:** Vanilla-Attribute umbenennen bzw. umdeuten (z. B. Stärke → „Kraft“). Der
**Intellekt-Baum wird zu „Runenkunde“** (D9): Seine Technik-Perks (Türme, Strom, Roboter)
werden zu Runensteinen, Kraftsteinen, Zaubern und Tränken (F-15).

**Runenritzer-Bank:** zusätzliche Werkstatt für Runen, Runensteine und Glutladungen
(Klon einer Vanilla-Station per XML, siehe F-15).

## Umsetzung
### XML
Alles oben Genannte. Ein Rennofen mit zwei Stufen (Luppe → Schmiedeeisen) ist über
Rezeptketten abbildbar.
### C# (optional) — Warum nicht XML?
Nur falls eine **neue** Werkstatt (Webstuhl) ein Verhalten braucht, das Vanilla-Stationen
nicht haben. Erst prüfen, ob ein Klon einer vorhandenen Station per XML reicht.

## Akzeptanzkriterien
- [ ] Vollständiger Pfad T0 → T4 ohne Sackgasse (Rezeptgraph-Prüfskript)
- [ ] Jede Werkstatt hat Bau-Rezept, Werkzeugslot und mindestens 5 Rezepte

## Offene Fragen
- Bleibt das Vanilla-System „Magazine schalten Rezepte frei“ oder wird es auf Perk-Freischaltung umgestellt?
