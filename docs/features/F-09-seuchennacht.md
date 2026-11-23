# F-09 — Seuchennacht

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X+H | S | ja |

## Ziel
Die Horde-Nacht wird zur **Seuchennacht**: Nebel, Glockenläuten in der Ferne, Wellen von
Seuchentoten. Mechanisch Vanilla-nah, atmosphärisch eigen.

## Umfang
- Umbenennung und Re-Theming (Texte, Himmel- bzw. Nebelfarbe statt Blutmond-Rot)
- Wellen-Zusammensetzung aus F-06-Gruppen (`gamestages.xml`)
- **Vorboten (C#):** Am Tag davor gibt es Ereignisse wie Krähenschwärme, fernes Läuten oder Nebel am Abend. Hook am Tageswechsel bzw. am Horde-Nacht-Planer. Die Vorboten sind der Höhepunkt der Phase „Vorzeichen“ des Bedrohungs-Direktors (F-17 B5) und erhöhen das Grauen aller Spieler (F-17 B3).
- **Grusel-Inszenierung (D12):** Die Nacht beginnt nicht mit einem Schlag, sondern mit Stille. Tiere verstummen, Nebel steigt, die Glocke schlägt, dann kommt das erste Geräusch im Nebel. Sagengestalten (F-06) können die Wellen anführen.
- Optional: Nach der Seuchennacht liegen „Seuchenleichen“ herum, die verbrannt werden müssen (sonst Krankheitsrisiko, F-11)

## Umsetzung
### C# — Warum nicht XML?
Die Farbe und Ankündigung der Horde-Nacht sowie Vorboten-Ereignisse am Vortag liegen nach
unserem Kenntnisstand im Code (Sky- bzw. Wetter-Manager, Horde-Night-Direktor). **[verifizieren]** per REA,
welche Teile doch per XML (Weather, Biome-Spectrum) gehen.

*Stand WP9.4 (2026-11-23, [Finding](../rea/findings/WP9-licht-und-seuchennacht.md), zu prüfen N-114):*
mehr als gedacht ist XML. „Seuchennacht läuft" ist die Buff-Bedingung `IsBloodMoon`; Nebel, Wolken
und Wind der Nacht stehen je Biom als Wetter `bloodMoon` in `biomes.xml`. Die rote Tönung hängt an
einem Spektrum ohne XML; ob ein `<spectrum name="Foggy"/>` im Wetter sie ersetzt, zeigt S-34 (3).
Den Vortag erkennen: Spieltag und Seuchennacht-Tag sind beide abfragbar, die Differenz in XML
nicht belegt. C# bleibt sicher nur für den Direktor (F-17 B5).

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-09](../rea/hook-hypothesen.md#f-09)

## Akzeptanzkriterien
- [ ] Seuchennacht startet zum konfigurierten Rhythmus, mit eigener Optik und eigenem Text
- [ ] Vorboten treten am Vortag auf (Server-seitig ausgelöst, für alle Clients sichtbar)
