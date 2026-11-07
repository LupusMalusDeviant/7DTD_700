# F-08 — Licht, Feuer & Verteidigung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X (H entfällt, siehe unten) | S+C | ja |

## Ziel
Licht ist eine Ressource (Säule P4). Ohne Strom verteidigt man sich mit Feuer, Holz,
Gräben und Mechanik.

## Umfang
**Licht:**
- Fackel (Hand, Wand), Kienspan, Öllampe (Talg/Öl), Feuerkorb
- ~~**Brenndauer (C#):** Lichtquellen verbrauchen Brennstoff und erlöschen~~
- **Brenndauer (XML, berichtigt 2026-11-07):** Lichtquellen verbrauchen Brennstoff und
  erlöschen — über `Class="PlantGrowing"` mit `Next` und `GrowthRate`, wie eine wachsende
  Pflanze. **Kein C#**, siehe unten.
- Dunklere Nächte, Mondphasen und Nebel: siehe **F-17 B1** (Echte Dunkelheit). F-08 liefert die Lichtquellen, F-17 die Dunkelheit.
- Licht senkt Grauen (F-17 B3): Eine brennende Feuerstelle ist der wichtigste sichere Ort (B8).

**Verteidigung (XML):**
- Palisade, Spitzpfähle (Spikes-Umdeutung), Graben bzw. Fallgrube, Schwingbalken-Falle (mechanisch statt elektrisch), Pechtopf
- **Magische Verteidigung** kommt aus F-15: Runenstein der Glut (statt Geschützturm),
  Runenfallen (Glutzeichen statt Blade Trap, Bannkreis statt Elektrozaun), betrieben über
  Runenkraft (Kraftlinien, D37)
- Licht-Ergänzung aus F-15: **Lichtfunke** (Zauber) als seltene, teure Alternative zur Fackel. Licht bleibt eine Ressource (P4).

## Nicht im Umfang
- Feuerausbreitung auf Gebäude (Vanilla-Feuersystem prüfen; ggf. P2)

## Umsetzung
### XML
Lichtblöcke (Vanilla-Fackel/-Kerze als Basis), Fallen, Bau-Rezepte.
### C# / Harmony — **nicht nötig** (beantwortet 2026-11-07)

Die Frage war: gibt es ein Tick- oder Update-System für Blöcke, auf das man sich hängen kann,
statt jeden Lichtblock einzeln zu ticken? **Ja, und es ist per XML erreichbar.** `blocks.xml`
liefert das Vorbild selbst — `cropsGrowingMaster`:

| Eigenschaft | Bedeutung für die Fackel |
|---|---|
| `Class="PlantGrowing"` | Blockklasse mit Zeitlogik |
| `Next` | der erloschene Zustand |
| `GrowthRate` | Brenndauer in **Minuten** (Vanilla-Kommentar: nicht unter 2 setzen) |
| `IsRandom` | Streuung, damit nicht alle Fackeln gleichzeitig ausgehen |

Eine Fackel ist mechanisch eine wachsende Pflanze. Der Zustand liegt im Block, nicht in einem
eigenen Manager — Persistenz und Netzsynchronisierung erledigt damit das Spiel.

**Kein Harmony-Patch, kein TileEntity, keine eigene Blockklasse.**
Befund: [02-10-schnittstellen-kurzcheck.md](../rea/findings/02-10-schnittstellen-kurzcheck.md#prio-3--f-08-licht-und-feuer)

Offen geblieben: **Nachlegen** von Brennstoff (die Uhr zurücksetzen) ohne TileEntity. Für die
MVP-Fassung „brennt ab, muss neu gesetzt werden" ist das gleichgültig; das Akzeptanzkriterium
„nachfüllbar" unten gehört damit in Phase 2.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-08](../rea/hook-hypothesen.md#f-08)

## Akzeptanzkriterien
- [ ] Eine Wandfackel brennt N Ingame-Minuten, dann erlischt sie
- [ ] Zustand bleibt nach Server-Neustart erhalten
- [ ] Clients sehen synchron, ob die Fackel brennt oder aus ist
- [ ] Keine messbaren Server-Frame-Einbrüche bei 200 Fackeln (Performance-Check)
- [ ] *(Phase 2)* Brennstoff nachlegbar, ohne die Fackel neu zu setzen

Die ersten drei folgen aus `Class="PlantGrowing"`, wenn der Befund trägt — Zustand und Netz
erledigt das Spiel. Zu prüfen bleibt die Zahl (`GrowthRate` in Minuten gegen gewünschte
Ingame-Stunden) und die Last bei vielen Blöcken.
