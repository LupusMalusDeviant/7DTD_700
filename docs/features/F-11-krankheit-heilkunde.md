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
- **Mehr Krankheiten** (D35):

  | Krankheit | Ursache | Verlauf | Heilung |
  |---|---|---|---|
  | **Seuchenbrand** | Treffer von Seuchentoten (Vanilla-Infektion) | stufenweise, tödlich unbehandelt | Theriak, Seuchenkunde (Heiler) |
  | **Ruhr** | schmutziges Wasser, verdorbene Nahrung (F-19) | Durst, Schwäche | Abkochen vorbeugend; Eichenrinden-Sud |
  | **Fieber** | Nässe bzw. Kälte (Vanilla-Temperatur), Wunden | Ausdauer- und Zielmalus | Weidenrinde, Bettruhe |
  | **Wundbrand** | unbehandelte Blutung bzw. tiefe Wunde | Gesundheitsverlust, fortschreitend | Wundarzt-Perk, Ausbrennen, Honigsalbe |

- Vanilla-Verletzungen (Brüche, Blutung, Gehirnerschütterung) bleiben mit Mittelalter-Heilmitteln
- Unverbrannte Leichen nach der Seuchennacht (F-09) erhöhen Ruhr- und Seuchenbrand-Risiko in der Siedlung

## Umsetzung
Weitgehend XML (`buffs.xml`, `items.xml`, `blocks.xml`). C# nur, falls Ansteckung
zwischen Spielern gewünscht ist (Q10).

Volksmagie (D9, F-15): Magische Tränke und Segen können Symptome lindern und den Verlauf
des Seuchenbrands verlangsamen, aber **nie heilen**. Heilung bleibt Heilkunde (Theriak,
T2-Wissen). So bleibt die Seuche die eigentliche Bedrohung.

## Akzeptanzkriterien
- [ ] Seuchenbrand ist heilbar, aber nur mit T2-Wissen (Abschrift Heilkunde)
