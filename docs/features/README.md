# Feature-Katalog

Legende:
- **Phase:** 0 Fundament · 1 MVP „700 & Grauen“ · 2 Leben in der Welt · 3 Tiefe · 4 Hochmagie & Karte (Roadmap: [GDD Abschnitt 5](../GDD.md#5-roadmap-strikt-phasenweise-d50))
- **Tiefe:** X = nur XML · H = Harmony/C# · A = eigene Assets
- **Netz:** S = Server · C = Client · S+C = beide (siehe Spec 01, Abschnitt 3)
- **REA:** ob vor der Umsetzung eine Schnittstellen-Analyse nötig ist

| ID | Feature | Phase | Tiefe | Netz | REA | Abhängig von |
|---|---|---|---|---|---|---|
| [F-00](F-00-mod-fundament.md) | Mod-Fundament | 0 | X+H | S+C | ja | – |
| [F-01](F-01-anachronismen-purge.md) | Anachronismen-Purge | 1 | X | S | nein | F-00 |
| [F-02](F-02-waffen-kampf.md) | Waffen & Kampf | 1 · 2 | X+H (+A) | S+C | ja | F-04, F-05, F-21 |
| [F-03](F-03-ruestung-kleidung.md) | Rüstung & Kleidung | 1 | X (+A) | S | nein | F-04 |
| [F-04](F-04-handwerk-werkstaetten.md) | Handwerk & Werkstätten | 1 · 3 (Gesellen) | X (+H) | S | optional | F-05, F-21 |
| [F-05](F-05-ressourcen-waehrung.md) | Ressourcen & Währung | 1 | X | S | nein | F-01 |
| [F-06](F-06-seuchentote-bestiarium.md) | Seuchentote & Bestiarium | 2 | X (+A) | S | optional | F-07, F-18 |
| [F-07](F-07-welt-kulturzonen-pois.md) | Welt, Kulturzonen & POIs | 2 · 4 (Karte) | X (+A) | S | ja (Biome) | F-01 |
| [F-08](F-08-licht-feuer-verteidigung.md) | Licht, Feuer & Verteidigung | 1 | X+H | S+C | ja | F-04 |
| [F-09](F-09-seuchennacht.md) | Seuchennacht | 2 | X+H | S | ja | F-06, F-17 |
| [F-10](F-10-haendler-auftraege.md) | Händler & Aufträge | 2 · 3 | X+H | S | ja (Eskorte) | F-05, F-07, F-20 |
| [F-11](F-11-krankheit-heilkunde.md) | Krankheit & Heilkunde | 2 | X (+H) | S | optional | F-19 |
| [F-12](F-12-lokalisierung-ui.md) | Lokalisierung & UI-Theming | 1 | X | C | nein | – |
| [F-13](F-13-transport-mobilitaet.md) | Transport & Mobilität | 3 · 4 (magisch) | X+H+A | S+C | ja | F-15, F-19, F-21 |
| [F-14](F-14-siedlung-gesellen-koop.md) | Siedlung, Gesellen & Koop | 3 | X+H (+A) | S+C | ja | F-04, F-10, F-21 |
| [F-15](F-15-volksmagie.md) | Volksmagie (Runen, Segen, Tränke, Zauber, Odem) | 2 · 4 (Hochmagie) | X+H (+A) | S+C | ja | F-04, F-08, F-21 |
| [F-16](F-16-asset-pipeline.md) | Asset-Pipeline | 2 (Start) | A | C | nein | F-00 |
| [F-17](F-17-grauen-bedrohung.md) | Grauen & Bedrohung | 1 · 2 | X+H (+A) | S+C | ja | F-06, F-08, F-09 |
| [F-18](F-18-bauen-befestigung.md) | Bauen & Befestigung | 1 | X | S | nein | F-04, F-05 |
| [F-19](F-19-nahrung-ackerbau-vieh.md) | Nahrung, Ackerbau & Viehhaltung | 2 · 3 (Vieh) | X+H (+A) | S | ja | F-04 |
| [F-20](F-20-seuchenkult-pluenderer.md) | Seuchenkult & Plünderer | 3 | X+H+A | S | ja | F-06, F-07 |
| [F-21](F-21-fertigkeiten-learning-by-doing.md) | Fertigkeiten & Learning by Doing | 1 · 2 (LbD) | X+H | S | ja | F-00 |

## Umsetzungsreihenfolge

**Phase 0:** F-00, danach REA-Baseline (`docs/rea/interface-discovery.md`, Schritte 1–3).

**Phase 1, MVP „700 & Grauen“** (D49):
1. F-01 + F-05 + F-12 (reines XML, schnelle sichtbare Wirkung)
2. F-21 (sechs Bäume als XML-Gerüst, noch ohne Learning by Doing) → F-04 → F-03 → F-02 (Basis)
3. F-18 (Bau-Pfad + Gegner-Blockschaden)
4. F-17 B1/B2/B8 (Dunkelheit, Nebel, Klang, sichere Orte) + F-08 (Licht, Brenndauer = erster Harmony-Patch)
5. → **interner Playtest Phase 1** → Entscheidung über öffentlichen Release (D46)

**Phase 2:** F-16 zuerst → F-06, F-07, F-09 → F-15 (Kern), F-17 (Rest) → F-02 (Schild, Schadensarten, Werfen), F-21 (Learning by Doing), F-11, F-19 (Verderb, Ackerbau), F-10 (Basis) → Playtest

**Phase 3:** F-13 (Karren, Packtier, Pferd, Wegsteine), F-14, F-19 (Vieh), F-20, F-10 (Bann, Lore, Eskorte), F-04 (Gesellen) → Playtest. Vor Beginn jedes Phase-3-Features eine Aufwandsprüfung (Solo-Projekt, D45).

**Phase 4:** Hochmagie (F-15/F-13: Hexenbesen, Runenross), eigene Karte (F-07).

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
