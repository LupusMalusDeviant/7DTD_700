# F-21 — Fertigkeiten & Learning by Doing

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1: sechs Bäume (XML) · 2: Learning by Doing | X+H | S | ja |

## Ziel
Ein **komplett neues Fertigkeitssystem** (D47) mit sechs Bäumen, die zu den Rollen von 700
passen, und Fortschritt durch **Tun** statt Magazin-Lesen (D24).

## Die sechs Bäume

| Baum | Schwerpunkt | Beispiel-Perks | Koop-Synergie (D44) |
|---|---|---|---|
| **Krieger** | Nahkampf, Schild, schwere Rüstung | Klingenkunde, Wuchtwaffen, Schildwall, Rüstungsgewöhnung | Schildwall-Bonus für Nachbarn |
| **Jäger** | Bogen, Armbrust, Wurfwaffen, Schleichen, Spuren, Tiere jagen | Bogenschießen, Wurfarm, Fährtenlesen, Leiser Tritt | Gegner bzw. Spuren für Gruppe markieren |
| **Handwerker** | Schmieden, Bauen, Werkstätten, Reparatur, Abbau | Schmiedekunst, Zimmerei, Steinmetz, Bergmann | Reparatur für andere, Gesellen anleiten |
| **Runenkundiger** | Magie, Odem, Runen, Runensteine, Flüche | Runenritzen, Odemtiefe, Glutzauber, Bannkunde, Hochmagie | Gruppen-Schutzzeichen |
| **Heiler** | Kräuter, Krankheiten, Tränke, Segen, Furcht | Kräuterkunde, Wundarzt, Seuchenkunde, Seelentrost | Heilt bzw. segnet Gruppe, Furcht-Aura senken |
| **Transport & Logistik** | Tragkraft, Karren, Tiere, Pferde, Wegsteine, Marsch | Tragkraft, Wagnerei, Tierkunde, Sattlerei, Wegkunde | Gruppenlast, Wegsteine für Gruppe |

- **Attributwerte:** Jeder Baum hat einen Stufenwert (wie Vanilla-Attribute), der Perks im Baum freischaltet. Der Wert *Runenkundiger* ist der **Magiewert** (D36), z. B. für das Runenross.
- **Fernkampf und Magie gleichwertig** (D22): Jäger und Runenkundiger sind gleich mächtige Fernkampf-Wege.
- Das Vanilla-Attributsystem wird **vollständig ersetzt**; Vanilla-Perks werden gesperrt bzw. umgebaut. [verifizieren], wie hart Vanilla-Code an den fünf Attributnamen hängt → REA (wenig hart = XML; hart = Umdeuten statt Ersetzen).

## Learning by Doing (D24, D48)
**Regel:** Ein Rezept bzw. eine Fertigkeit wird nur nutzbar, wenn die **Grundfähigkeit**
vorhanden ist, per Skill-Punkt im Baum **oder** per gefundener bzw. gekaufter Abschrift.
Danach verbessert **Benutzen** die Fertigkeit: höhere Qualität, neue Varianten, weniger
Materialverbrauch.

**Technischer Vorschlag (D48, nach REA final):**
1. **Vanilla-Crafting-Skills weiterverwenden.** V1.x/V2.x hat Crafting-Skills (Fortschritt pro
   Kategorie, bisher durch Magazine). Diese Struktur (Stufen, freigeschaltete Rezepte und
   Qualitäten) bleibt als Datenmodell in `progression.xml`.
2. **Fortschritt umleiten:** Statt Magazin-Lesen erhöht **Herstellen bzw. Benutzen** den
   Fortschritt. Bevorzugt per XML-Trigger (z. B. Buff-Event beim Herstellen, falls vorhanden),
   sonst per **Harmony-Postfix** am Abschluss eines Craft-Vorgangs bzw. am Treffer.
3. **Abschriften** sind die Grundfähigkeit (Stufe 1) bzw. Sprünge, kein Fortschritt durch Masse.
4. **Server-autoritativ:** Fortschritt wird auf dem Server gezählt (Werkstätten laufen serverseitig).

REA-Fragen → [hook-hypothesen.md#f-21](../rea/hook-hypothesen.md#f-21)

## Akzeptanzkriterien
- [ ] Sechs Bäume vollständig, keine Vanilla-Attribut- bzw. -Perknamen sichtbar
- [ ] Ohne Grundfähigkeit ist ein Rezept gesperrt; mit Grundfähigkeit steigt die Qualität durch wiederholtes Herstellen
- [ ] Learning-by-Doing-Fortschritt bleibt nach Server-Neustart erhalten
- [ ] Jeder Baum bietet einen tragfähigen Build bis T4
