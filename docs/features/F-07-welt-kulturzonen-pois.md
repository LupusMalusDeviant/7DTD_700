# F-07 — Welt, Kulturzonen & POIs

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

- **Kulturzonen als Biome** (D43, auf Basis von D1). Die Vanilla-Biome werden umgedeutet:

  | Kulturzone | Vanilla-Biom | Landschaft | Kultur & POIs | Besonderheiten |
  |---|---|---|---|---|
  | **Klosterland** | Pine Forest | Mischwald, Rodungsinseln | fränkisch-romanisch: Klöster, Römerruinen, Weiler | Start-Zone, Klostermarkt |
  | **Burgwall-Land** | Snow → Mittelgebirge/Heide | Hügel, Heide, Fels | slawisch-germanisch: Burgwälle, Ringwälle, Motten | Wildpferde (F-13), Fürstenhof |
  | **Küste** | Desert → Küste/Dünen | Strand, Dünen, Fjordartige Buchten | nordisch geprägt: Langhäuser, Bootshäuser | Bernstein, Salz |
  | **Moorland** | Wasteland → Moor | Sumpf, Bodennebel, tote Bäume | verlassen: Pestgruben, Bohlenwege, Opferplätze | Raseneisenerz (Eisen!), Irrlichter, Moorleichen |
  | **Brandland** | Burnt Forest | verbrannter Wald | abgebrannte Höfe, Kultstätten (F-20) | höchste Gefahr, Seuchenkult |

  [verifizieren], ob Biom-Austausch und -Umbenennung per `biomes.xml`/`rwgmixer.xml` reicht oder ob die RWG-Biomverteilung hart verdrahtet ist (REA).
- **Steinkreise** als POI für Wegsteine (F-13)

- **Erzählende Umgebung (D12, F-17 B7):** Pestgruben, Leichenkarren, Grabkreuze mit Bannzeichen, von außen verriegelte Türen, Notizen und Inschriften. Jeder eigene POI erzählt mindestens eine kleine Geschichte davon, wie die Bewohner untergingen.
- **Nebel-Biome:** Moor und Flusstäler mit dauerhaftem Bodennebel (F-17 B1)

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
- keine (Q12 entschieden: D43)
