# F-08 — Licht, Feuer & Verteidigung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X+H | S+C | ja |

## Ziel
Licht ist eine Ressource (Säule P4). Ohne Strom verteidigt man sich mit Feuer, Holz,
Gräben und Mechanik.

## Umfang
**Licht:**
- Fackel (Hand, Wand), Kienspan, Öllampe (Talg/Öl), Feuerkorb
- **Brenndauer (C#):** Lichtquellen verbrauchen Brennstoff und erlöschen
- Dunklere Nächte, Mondphasen und Nebel: siehe **F-17 B1** (Echte Dunkelheit). F-08 liefert die Lichtquellen, F-17 die Dunkelheit.
- Licht senkt Grauen (F-17 B3): Eine brennende Feuerstelle ist der wichtigste sichere Ort (B8).

**Verteidigung (XML):**
- Palisade, Spitzpfähle (Spikes-Umdeutung), Graben bzw. Fallgrube, Schwingbalken-Falle (mechanisch statt elektrisch), Pechtopf
- **Magische Verteidigung** kommt aus F-15: Runenstein der Glut (statt Geschützturm),
  Runenfallen (Glutzeichen statt Blade Trap, Bannkreis statt Elektrozaun), betrieben über
  Runenkraft (Q13)
- Licht-Ergänzung aus F-15: **Lichtfunke** (Zauber) als seltene, teure Alternative zur Fackel. Licht bleibt eine Ressource (P4).

## Nicht im Umfang
- Feuerausbreitung auf Gebäude (Vanilla-Feuersystem prüfen; ggf. P2)

## Umsetzung
### XML
Lichtblöcke (Vanilla-Fackel/-Kerze als Basis), Fallen, Bau-Rezepte.
### C# / Harmony — Warum nicht XML?
Brenndauer bei platzierten Lichtblöcken: Nach unserem Kenntnisstand haben Lichtblöcke keinen
Verbrauch, der per XML konfigurierbar ist. **Erster REA-Prüfling:** Gibt es ein Tick-
oder Update-System für Blöcke (z. B. wie Kampagnenfeuer oder Ernte-Wachstum), auf das man
sich hängen kann, statt jeden Lichtblock einzeln zu ticken? Das Ergebnis bestimmt, ob das
Feature billig (Tick-Hook) oder teuer (eigener Manager mit Persistenz) wird.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-08](../rea/hook-hypothesen.md#f-08)

## Akzeptanzkriterien
- [ ] Eine Wandfackel brennt N Ingame-Stunden, dann erlischt sie; nachfüllbar
- [ ] Zustand bleibt nach Server-Neustart erhalten
- [ ] Clients sehen synchron, ob die Fackel brennt oder aus ist
- [ ] Keine messbaren Server-Frame-Einbrüche bei 200 Fackeln (Performance-Check)
