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
- **Vorboten (C#):** Am Tag davor gibt es Ereignisse wie Krähenschwärme, fernes Läuten oder Nebel am Abend. Hook am Tageswechsel bzw. am Horde-Nacht-Planer.
- Optional: Nach der Seuchennacht liegen „Seuchenleichen“ herum, die verbrannt werden müssen (sonst Krankheitsrisiko, F-11)

## Umsetzung
### C# — Warum nicht XML?
Die Farbe und Ankündigung der Horde-Nacht sowie Vorboten-Ereignisse am Vortag liegen nach
unserem Kenntnisstand im Code (Sky- bzw. Wetter-Manager, Horde-Night-Direktor). **[verifizieren]** per REA,
welche Teile doch per XML (Weather, Biome-Spectrum) gehen.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-09](../rea/hook-hypothesen.md#f-09)

## Akzeptanzkriterien
- [ ] Seuchennacht startet zum konfigurierten Rhythmus, mit eigener Optik und eigenem Text
- [ ] Vorboten treten am Vortag auf (Server-seitig ausgelöst, für alle Clients sichtbar)
