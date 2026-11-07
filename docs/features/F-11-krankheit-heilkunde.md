# F-11 — Krankheit & Heilkunde

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+H) | S | optional |

## Ziel
Krankheit ist im Jahr 700 der eigentliche Feind. Die Vanilla-Infektion wird zur
**Seuche**; Heilung kommt aus Kräuterkunde, nicht aus Antibiotika.

## Umfang
- Infektion → „Seuchenbrand“ (Buff-Kette umbenennen und umbalancieren)
- Heilmittel: Schafgarbe/Wundkraut-Auflage, Honig-Wundsalbe, Weidenrinden-Sud (Schmerz), Theriak (selten, gegen Seuche)
- Kräuter als Erntepflanzen (Vanilla-Farming-Blöcke umgedeutet)
- Optional: Krankheit durch verdorbenes Wasser oder Fleisch, unverbrannte Leichen (F-09)

## Umsetzung
Weitgehend XML (`buffs.xml`, `items.xml`, `blocks.xml`). C# nur, falls Ansteckung
zwischen Spielern gewünscht ist (Q10).

Volksmagie (D9, F-15): Magische Tränke und Segen können Symptome lindern und den Verlauf
des Seuchenbrands verlangsamen, aber **nie heilen**. Heilung bleibt Heilkunde (Theriak,
T2-Wissen). So bleibt die Seuche die eigentliche Bedrohung.

## Akzeptanzkriterien
- [ ] Seuchenbrand ist heilbar, aber nur mit T2-Wissen (Abschrift Heilkunde)
