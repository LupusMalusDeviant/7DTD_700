# F-13 — Transport & Mobilität

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 3: Karren, Packtier, Reitpferd, Wegsteine · 4: magische Fahrzeuge | X+H+A | S+C | ja |

## Ziel
Ersatz für Vanilla-Fahrzeuge (D16). **Langsames Reisen ist der Normalfall**; schnelle
Fortbewegung ist teuer, selten und erarbeitet (D17). Im Endgame erreicht sie Vanilla-Tempo,
aber nur über magische Fahrzeuge oder Wegsteine.

## Stufen

| Stufe | Fortbewegung | Ersetzt | Tempo | Beschaffung |
|---|---|---|---|---|
| T1 | **Handkarren** | Fahrrad | langsam (mehr Last, nicht schneller) | Zimmermannsbank, Wagnerei-Perk |
| T2 | **Packtier** (Esel/Packpferd) | Minibike (Stauraum) | Schritttempo, folgt dem Spieler | **finden und zähmen**, Futter nötig |
| T3 | **Reitpferd** | Motorrad | schnell | **finden** (selten, wilde Herden oder Kauf beim Fürstenhof), zähmen, Sattel; **kann sterben** |
| T3 | **Ochsenkarren / Planwagen** | Truck (Stauraum) | langsam, viel Last | Wagnerei + Zugtier |
| T4 | **Hexenbesen** | Gyrocopter | schnell, fliegend, kurze Dauer je Odem | Hochmagie, sehr teuer (F-15) |
| T4 | **Runenross** (magisches „Motorrad“) | Motorrad/Truck Endgame | Vanilla-Motorrad-Tempo | Hochmagie, **hoher Runenkunde-Wert** zwingend (D17) |
| T3–T4 | **Wegsteine** | – (Schnellreise) | sofort | siehe unten (D18) |

## Pferde & Tiere (D17)
- **Finden statt bauen:** wilde Herden in bestimmten Kulturzonen (Heide, Burgwall-Land), selten; Kauf beim Fürstenhof sehr teuer
- **Sterblich:** Pferde haben Gesundheit, Hunger und Angst; tote Pferde sind weg (keine Respawn-Pfeife)
- **Grusel-Verzahnung (F-17):** Pferde scheuen bei Sagengestalten und in der Seuchennacht und werfen den Reiter eventuell ab
- **Pflege:** Futter (Heu, Hafer aus F-19), Stall in der Siedlung senkt das Verletzungsrisiko

## Wegsteine (D18)
- **Selbst errichten:** teuer (Bruchstein, Bernstein, Runenkreide), braucht Runenkundiger- **und** Transport-Perk
- **Alte Steinkreise finden:** verfallene Steinkreise in der Welt (POI, F-07) per Ritual reaktivieren; oft bewacht (Sagengestalt, Kult)
- **Kosten pro Reise:** Odem + Bernstein; Reisen nur mit begrenzter Last (kein voller Karren)
- **Seuchennacht:** Alle Wegsteine schweigen, es gibt keine Flucht
- Optik: Nebel, Rauch, glimmende Runen (D38 erlaubt etwas mehr Sichtbarkeit)

## Fertigkeitsbaum „Transport & Logistik“ (D19, F-21)
Perks z. B.: Tragkraft, Wagnerei (Karren und Wagen bauen und verbessern), Tierkunde (zähmen,
pflegen, Pferde beruhigen), Sattlerei, Wegkunde (Wegsteine nutzen und bauen, Ausdauer
beim Marsch).

## Umsetzung
### XML
Karren und Wagen als Umdeutung der Vanilla-Fahrzeuge (Werte, Rezepte, Stauraum, Tempo),
Wegstein-Blöcke, Rezepte, Perks.
### C# / Harmony — Warum nicht XML?
- **Reitpferd:** Ein Tier als steuerbares Fahrzeug braucht eine Kopplung von Tier-Entity und
  Vehicle-Steuerung → REA (Q18). Fallback: das Pferd ist technisch ein Vanilla-Fahrzeug mit
  Pferdemodell und eigener Sterblichkeits- bzw. Hunger-Logik.
- **Packtier:** Folge-KI + Inventar → REA
- **Wegsteine:** Teleport zwischen registrierten Punkten, Seuchennacht-Sperre, Lastprüfung
- **Hexenbesen:** Gyrocopter-Logik mit Odem-Verbrauch statt Treibstoff
### Assets
Karren, Wagen, Sattel, Pferd (eventuell Vanilla-Pferd bzw. -Hirsch als Rig-Basis), Besen,
Runenross, Wegsteine, Steinkreise.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-13](../rea/hook-hypothesen.md#f-13)

## Akzeptanzkriterien
- [ ] Ohne Pferd und Wegstein dauert eine Reise über die halbe Karte spürbar lange (Zielwert festlegen)
- [ ] Ein Pferd stirbt endgültig; der Verlust ist spürbar, aber nicht spielzerstörend
- [ ] Wegsteine sind in der Seuchennacht nachweislich gesperrt (Dedicated + 2 Clients)
- [ ] Runenross nur mit dem geforderten Runenkunde-Level herstellbar bzw. nutzbar

## Offene Fragen
- Q18: Reitpferd ohne eigene Reit-Animationen machbar?
