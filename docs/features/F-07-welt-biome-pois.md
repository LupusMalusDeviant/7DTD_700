# F-07 — Welt, Biome & POIs

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+A) | S | optional |

## Ziel
Die Welt sieht aus wie Mitteleuropa um 700: Wald, Moor, Weiler, Klöster, Ringwälle,
Römerruinen. Keine Städte, Asphaltstraßen oder Hochhäuser.

## Umfang
- **RWG** (`rwgmixer.xml`): Städte, Straßen und Großtiles deaktivieren bzw. ersetzen; Biome auf Wald/Moor/Gebirge/Heide umdeuten (Wüste und Ödland entfallen oder werden zu Heide/Brandland)
- **POIs (eigene Prefabs):** Grubenhaus, Langhaus, Hofstelle, Weiler, Kloster, Motte/Ringwall, Römerruine (Villa, Kastell), Köhlerei, Mühle
- Prefabs entstehen im **Ingame-Prefab-Editor** mit Vanilla- und Mod-Blöcken. Das sind keine Unity-Assets, aber viel Handarbeit.
- **Blöcke:** Flechtwerk, Lehmwand, Palisade, Reetdach, Bruchstein (Umdeutung bzw. Retexturen über vorhandene Block-Shapes)

## Umsetzung
- Phase 2a: RWG-Filter. Nur Vanilla-POIs ohne Anachronismen zulassen (Höhlen, Hütten, Ruinen). Damit wird die Welt schnell „leer und alt“.
- Phase 2b: eigene Prefabs, schrittweise.

## Akzeptanzkriterien
- [ ] Neue RWG-Welt erzeugt keine Stadt- oder Straßenstrukturen
- [ ] Mindestens 10 eigene POIs mit Quest-Markern (für F-10)

## Offene Fragen
- Q4: RWG-only oder kuratierte Karte?
