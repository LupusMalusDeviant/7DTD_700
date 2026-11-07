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

- **Fiktives Mischland (D1):** Die Biome lassen sich als Kulturzonen lesen, etwa
  Klosterland mit Römerruinen (Wald), Burgwall-Land (Gebirge/Heide), Küste mit nordisch
  geprägten Höfen, Moorland. Die Prefab-Stile werden je Zone gewählt (Q12).

## Umsetzung
- Phase 2a: RWG-Filter. Nur Vanilla-POIs ohne Anachronismen zulassen (Höhlen, Hütten, Ruinen). Damit wird die Welt schnell „leer und alt“.
- Phase 2b: eigene Prefabs, schrittweise. Block-Optik über **Retexturen** (F-16).
- **Phase 3: eigene handgebaute Karte (D4).** Sie nutzt die Prefabs und Blöcke aus
  Phase 2 und erzählt das Setting über Orte (Hauptkloster, Fürstensitz, verlassene
  Römerstadt). Erst angehen, wenn die RWG-Inhalte stabil sind.

## Akzeptanzkriterien
- [ ] Neue RWG-Welt erzeugt keine Stadt- oder Straßenstrukturen
- [ ] Mindestens 10 eigene POIs mit Quest-Markern (für F-10)

## Offene Fragen
- Q12: Kulturzonen fest an Biome binden?
