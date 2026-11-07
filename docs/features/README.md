# Feature-Katalog

Legende:
- **Phase:** MVP / P2 (Phase 2) / Stretch
- **Tiefe:** X = nur XML · H = Harmony/C# · A = eigene Assets
- **Netz:** S = Server · C = Client · S+C = beide (siehe Spec 01, Abschnitt 3)
- **REA:** ob vor der Umsetzung eine Schnittstellen-Analyse nötig ist

| ID | Feature | Phase | Tiefe | Netz | REA | Abhängig von |
|---|---|---|---|---|---|---|
| [F-00](F-00-mod-fundament.md) | Mod-Fundament | MVP | X+H | S+C | ja | – |
| [F-01](F-01-anachronismen-purge.md) | Anachronismen-Purge | MVP | X | S | nein | F-00 |
| [F-02](F-02-waffen-kampf.md) | Waffen & Kampf | MVP | X+H (+A) | S+C | ja | F-01, F-04, F-05 |
| [F-03](F-03-ruestung-kleidung.md) | Rüstung & Kleidung | MVP | X (+A) | S | nein | F-01, F-04 |
| [F-04](F-04-handwerk-progression.md) | Handwerk & Tech-Progression | MVP | X (+H) | S | optional | F-01, F-05 |
| [F-05](F-05-ressourcen-waehrung.md) | Ressourcen & Währung | MVP | X | S | nein | F-01 |
| [F-06](F-06-seuchentote-bestiarium.md) | Seuchentote & Bestiarium | P2 | X (+A) | S | optional | F-01 |
| [F-07](F-07-welt-biome-pois.md) | Welt, Biome & POIs | P2 | X (+A) | S | optional | F-01 |
| [F-08](F-08-licht-feuer-verteidigung.md) | Licht, Feuer & Verteidigung | MVP | X+H | S+C | ja | F-01, F-04 |
| [F-09](F-09-seuchennacht.md) | Seuchennacht | P2 | X+H | S | ja | F-06 |
| [F-10](F-10-haendler-auftraege.md) | Händler & Aufträge | P2 | X (+H) | S | optional | F-05, F-07 |
| [F-11](F-11-krankheit-heilkunde.md) | Krankheit & Heilkunde | P2 | X (+H) | S | optional | F-04 |
| [F-12](F-12-lokalisierung-ui.md) | Lokalisierung & UI-Theming | MVP | X | C | nein | – |
| [F-13](F-13-packtiere-transport.md) | Packtiere & Transport | Stretch | H+A | S+C | ja | F-06 |
| [F-14](F-14-siedlung-gefolge.md) | Siedlung & Gefolge | Stretch | H (+A) | S+C | ja | F-10 |
| [F-15](F-15-aberglaube-reliquien.md) | Aberglaube & Reliquien | P2 | X (+A) | S | nein | F-04, F-11 |
| [F-16](F-16-asset-pipeline.md) | Asset-Pipeline | P2 | A | C | nein | F-00 |

## Umsetzungsreihenfolge (Vorschlag)

1. **F-00** Fundament. Danach REA-Baseline erstellen (`docs/rea/interface-discovery.md`, Schritte 1–3).
2. **F-01 + F-05 + F-12** (reines XML, schnelle sichtbare Wirkung)
3. **F-04 → F-03 → F-02** (Progression trägt Ausrüstung)
4. **F-08** (erster echter Harmony-Patch, durch REA abgesichert)
5. → **MVP-Playtest** → Phase 2
6. Phase 2: **F-16** zuerst (Pipeline steht, bevor Assets entstehen), danach F-06/F-07 parallel zu F-15, F-11, F-09, F-10

## Template für neue Features

```markdown
# F-xx — Name

| Phase | Tiefe | Netz | REA |
|---|---|---|---|

## Ziel
Ein Satz: welche Spielerfahrung?

## Umfang
- …

## Nicht im Umfang
- …

## Umsetzung
### XML
### C# / Harmony (Warum nicht XML?)
### Assets

## Schnittstellen (REA)
Hypothesen → Verweis auf docs/rea/hook-hypothesen.md#f-xx

## Akzeptanzkriterien
- [ ] …

## Offene Fragen
```
