# F-07 — Welt, Kulturzonen & POIs

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+A) | S | optional |

> **Konzept und Prüfung (Nachtlauf 2026-11-22, zu prüfen durch den Nutzer, D128, D110):**
> [`docs/konzept/biome.md`](../konzept/biome.md) misst, was V 3.40 je Biom hat (Gefahr, Sturm,
> Temperatur, Gegner, Bewuchs), zeigt, dass der Biom-Fortschritt mit unserer Mod **nicht lösbar**
> ist, und entwirft fünf Landschaften samt Schutzstücken, Suden und Texten. Zwei Zuordnungen der
> Tabelle unten tragen danach nicht (die „Küste" liegt auf einem Biom ohne Meer bei 35–41 °C, die
> „Heide" auf Dauerfrost). [`docs/pruefung/0002-erscheinung.md`](../pruefung/0002-erscheinung.md)
> §4.5 misst die POIs: von 1 105 Vanilla-POIs ist kein Gebäude frei von Neuzeit — „Höhlen, Hütten,
> Ruinen" (Phase 2a unten) liefert danach keine Gebäude. Dieses Dokument ist dadurch nicht geändert.

## Ziel
Die Welt sieht aus wie Mitteleuropa um 700: Wald, Moor, Weiler, Klöster, Ringwälle,
Römerruinen. Keine Städte, Asphaltstraßen oder Hochhäuser.

## Umfang
- **RWG** (`rwgmixer.xml`): Städte, Straßen und Großtiles deaktivieren bzw. ersetzen; Biome auf Wald/Moor/Gebirge/Heide umdeuten (~~Wüste und Ödland entfallen oder werden zu Heide/Brandland~~ Wüste wird Küste, Ödland wird Moor — siehe Tabelle unten; D72 baut darauf)
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
- **~~Phase 3~~ Phase 4: eigene handgebaute Karte (D4).** Sie nutzt die Prefabs und Blöcke aus
  Phase 2 und erzählt das Setting über Orte (Hauptkloster, Fürstensitz, verlassene
  Römerstadt). Erst angehen, wenn die RWG-Inhalte stabil sind.

## Akzeptanzkriterien
- [ ] Neue RWG-Welt erzeugt keine Stadt- oder Straßenstrukturen
- [ ] Mindestens 10 eigene POIs mit Quest-Markern (für F-10)

## Offene Fragen
- keine (Q12 entschieden: D43)

## Stand 2026-11-07 — Kurz-Check, **D43 betroffen**

Die Biom-**Verteilung** ist XML (`biomes.xml`, `biomemap`). Die Biom-**Namen** sind es nicht: sie
stehen an sieben Stellen im Code, von `WorldBuilder::.ctor` bis zum Speicherformat
(`serializeDynamicProperties`). Umbenennen bricht die Weltgenerierung.

Empfohlener Weg: Vanilla-Kennungen (`pine_forest`, `burnt_forest`, …) als **technische** Namen
behalten und nur Anzeigenamen, Blöcke, Bepflanzung und Spawning umdeuten. Der Spieler sieht die
Mark, die Engine sieht `pine_forest`.

Das weicht vom Wortlaut von D43 ab und ist **noch nicht entschieden**.
Befund: [02-10-schnittstellen-kurzcheck.md](../rea/findings/02-10-schnittstellen-kurzcheck.md#prio-7--f-07-welt-und-kulturzonen--berührt-d43)

---

# Ausarbeitung für Phase 2 (Plan-0002 WP6.1, 2026-11-23)

**Stand:** im Loop ausgearbeitet, **jede Setzung zu prüfen durch den Nutzer** (N-97, D152; bis
2026-11-23 als N-71 geführt). Die Punkte `[verifizieren]` beantwortet das Finding
[`F-07-zufallswelt-und-orte.md`](../rea/findings/F-07-zufallswelt-und-orte.md) (WP6.2, D153). Der Text
oben bleibt stehen; wo die Ausarbeitung ihm widerspricht, steht es hier mit Grund. Gebaut ist von
F-07 bisher: Nebel und dunklere Nächte (`700_60_Welt`, D72), die Purge-Zeilen für Händlerware und
Aufträge, sonst nichts.

## A. Messung (V 3.40 b10, `Data/Prefabs`, `Data/Config`)

| Was | Zahl | Quelle |
|---|---|---|
| Orte mit Geometrie (`.tts`) | **1 105** | `Data/Prefabs/POIs` (dazu 470 `.xml` ohne `.tts`, 644 Teile, 68 Straßenkacheln) |
| davon mit Auftragsmarke (`QuestTags`) | **487** | Stufe 0: 10 · 1: 145 · 2: 136 · 3: 106 · 4: 65 · 5: 25 |
| Marken einzeln | clear 480 · infested 448 · fetch 439 · restore_power 117 · defense 4 · hidden_cache 1 | |
| Händlerorte (`TraderArea=True`) | **5** | `trader_bob`, `_hugh`, `_jen`, `_joel`, `_rekt` |
| Orte ohne jeden Neuzeit-Block | 61, **kein Haus, keine Hütte, keine Höhle mit Innenleben** | Prüfung 0002 §4.5 |
| neuzeitliche Deko-Blöcke (Fahrzeuge, Geräte, Automaten, Tresore, Lampen …) | **552**, davon **551 Modell-Blöcke** (`Shape=ModelEntity`) mit 121 verschiedenen Modellen; 249 mehrfeldrig (`MultiBlockDim`); Klassen: 438 Behälter, 25 Licht, 7 Automaten | Muster aus Prüfung 0002 §4.5 auf `blocks.xml` |

**Aufträge der Händler** (`quests.xml`, je Händler dieselbe Liste): vergraben (`*_buried_supplies`,
braucht **keinen** Ort), räumen (`clear`, `clear_infested`), holen (`fetch`, `fetch_clear`),
~~Strom wiederherstellen~~ (seit D103 gesperrt), „zum nächsten Händler" (`tierN_nexttrader`). Jede
Ortsaufgabe wählt ihr Ziel mit `RandomPOIGoto` — einen Ort mit passender Marke und Stufe. ~~**Wie weit
vom Händler und wie oft derselbe Ort, ist nicht gelesen** — WP6.2.~~ **Stand WP6.2:** das Ziel kommt
aus den Orten um den Händler (nach dessen bevorzugter Entfernungsstufe) oder um einen Weltpunkt,
gefiltert nach Stufe, Marke, Landschaft und laufenden Sperren (Finding §4). Orte je Stufe müssen
darum **je Landschaft nahe den Händlern** stehen.

~~**Händler entstehen mit Ortschaften.** `rwgmixer.xml` führt je Siedlungsart eine Eigenschaft
`spawn_trader`; abgeschaltet ist sie nur am Wegrand (`roadside`) und im Westernstädtchen
(`oldwest`). Eine Welt ohne Ortschaften hat danach **keinen Händler** und damit keinen Auftrag —
gelesen, nicht im Code nachgewiesen, **[verifizieren, WP6.2]**.~~ **Berichtigt (WP6.2, Finding §1):**
Händler sind gewöhnliche Orte (`trader_*`, erlaubt in `city, town, rural, wilderness`), die über
`prefab_spawn_adjust` verteilt werden (je Landschaft einer, `min_count 2`, `max_count 4`). Das Feld
hinter `spawn_trader` liest das Spiel **nirgends**. Eine Welt ohne Städte behält also ihre Händler.

## B. Die fünf Landschaften

Nach [`biome.md` §2.2](../konzept/biome.md) (P2-E13, Vorschlag, weicht von D43 ab): Vanillas
Kennungen bleiben, der Spieler liest neue Namen.

| Kennung | Stufe | Name | Kulturkreis | Gesehen in F-06 |
|---|---|---|---|---|
| `pine_forest` | 1 | Klosterland | fränkisch-romanisch | Knecht, Magd, Bäuerin; Wolf, Hirsch |
| `burnt_forest` | 2 | Brandland | germanisch | Verbrannter, Kriecher; nachts Wolf statt Kojote |
| `desert` | 3 | Sandheide | slawisch (Burgwälle) | Hirte, Köhler; Wolf statt Kojote |
| `snow` | 4 | Winterhöhen | nordisch | Wolf statt Berglöwe, Bär |
| `wasteland` | 5 | Moorland | niemandes Land | Moorleiche, Nachzehrer |

Die Tabelle „Kulturzonen" oben (D43) mit **Küste** auf `desert` und **Burgwall-Land** auf `snow`
trägt gemessen nicht (biome.md §2.1: kein Meer, 35–41 °C; Dauerfrost). Sie bleibt stehen, bis der
Nutzer P2-E13 entscheidet.

## C. Bedarfsrechnung (D110)

**Frage:** Wie viele eigene Orte braucht eine Zufallswelt, damit Aufträge, Händler und Erkundung
tragen — ohne ein einziges Vanilla-Gebäude?

**1. Aufträge.** Ein Händler bietet je Stufe Ortsaufgaben an. Damit sich eine Stufe nicht nach dem
dritten Auftrag wiederholt, braucht sie **mehrere verschiedene Orte in Reichweite**. Vanilla hat je
Stufe 25 bis 145 Ortsentwürfe, die die Weltgenerierung vielfach setzt. Ein Entwurf kann
mehrfach in der Welt stehen; die Zahl der **Entwürfe** bestimmt die Abwechslung, die Zahl der
**Platzierungen** die Reichweite.

| Stufe | Vanilla-Entwürfe | Vorschlag Phase 2 (Entwürfe) | Begründung |
|---|---|---|---|
| 1 | 145 | **4** | die ersten Spielstunden; Grubenhaus, Köhlerei, Hofstelle, Mühle |
| 2 | 136 | **3** | Weiler, Langhaus, Römerruine (Villa) |
| 3 | 106 | **2** | Kloster, Ringwall |
| 4 | 65 | **1** | Römerruine (Kastell) |
| 5 | 25 | **1** | Pestgrube im Moor (Brandland/Moorland) |
| — | — | **+1** | Steinkreis (Wegstein, F-13; keine Auftragsmarke) |

Das sind **elf Entwürfe, zehn davon mit Auftragsmarke** — genau die Untergrenze aus den
Akzeptanzkriterien unten und aus P2-E14. Jeder Entwurf trägt die Marken `clear` und `fetch`,
ab Stufe 2 auch `infested`. **Ehrlich gesagt:** zehn Entwürfe sind wenig; ab dem fünften Auftrag
derselben Stufe kennt der Spieler den Ort. Mehr Abwechslung kommt aus Weg C unten.

**2. Händler.** Fünf Händlerorte, Händler entstehen mit Ortschaften. Ohne Ortschaften braucht es
**einen eigenen Händlerort** (Handelsposten, F-10) und einen Weg, ihn zu setzen — entweder eine
Siedlungsart, die nur aus eigenen Orten besteht, oder Vanillas Händlerorte umgekleidet (Weg C).
~~**[verifizieren, WP6.2]**.~~ **Stand WP6.2:** Händler brauchen keine Ortschaft (oben, A). Ein eigener
Händlerort ist ein gewöhnlicher Ort mit `TraderArea`, verteilt über `prefab_spawn_adjust`; sein Name
muss mit `trader_` beginnen, damit die Welterzeugung ihn als Händler für Startpunkte zählt (Finding
§1, `[im Spiel bestätigen]`, S-29). Bis er steht, tragen Vanillas fünf Händlerorte, umgekleidet nach
Weg C.

**3. Ersatz für Ortschaften.** Eine Zufallswelt ohne Städte ist leer. Vorschlag: eine eigene
Siedlungsart „Weiler" (drei bis sechs Hofstellen um einen Platz), die in `rwgmixer.xml` an die
Stelle von `countrytown` tritt ~~und den Händler trägt~~. ~~Ob eine Siedlungsart ohne Straßen entstehen
kann, ist **[verifizieren, WP6.2]**.~~ **Stand WP6.2:** Siedlungen wachsen aus Straßenkacheln; ohne
Kacheln gibt es keine Siedlungsart. Der „Weiler" braucht also eigene Kacheln (Prefabs, im Editor des
Spiels) und `spawn_gateway="false"`, damit er Feldwege statt Fernstraßen bekommt (Finding §3).

## D. Die Welt von 2a — drei Wege (P2-E14)

Kein Vanilla-Gebäude ist frei von Neuzeit (Messung A). Drei Wege:

| Weg | Was | Folge | Aufwand |
|---|---|---|---|
| **A** Vanilla lassen | alle Orte, wie sie sind | moderne Welt mit Seuchentoten — verfehlt P1 | keiner |
| **B** leere Landschaft | `rwgmixer.xml` lässt nur Füller, Felsen, Höhlen und eigene Orte zu | Welt alt und leer; **ohne eigene Orte keine Aufträge, ohne Siedlung kein Händler** | eigene Orte (WP6.6) |
| **C** umkleiden | `blocks.xml` stellt das **Modell** der 551 neuzeitlichen Deko-Blöcke auf vorhandene, vormoderne Modelle um (Autowrack → Steinhaufen, Kühlschrank → Truhe, Waffenschrank → Kiste, Automat → Fass) | Vanillas Orte bleiben **als Grundriss**, ihr Inneres wird älter; Wände aus Beton und Asphalt bleiben modern | eine Tabelle von 121 Modellen; nur XML |

**Empfehlung: B + C.** B für die Ortsarten, die nur modern sind (Stadt, Tankstelle, Hochhaus, Fabrik
— `rwgmixer.xml` lässt sie weg), C für die, deren **Hülle** vormodern sein kann (Scheune, Blockhaus,
Hof, Höhle, Friedhof mit Kirche). C ist der einzige Weg, der ohne Editor und ohne Unity in Phase 2
Hunderte Orte bespielbar macht; seine Grenze sind Wände und Böden aus Neuzeit-Baustoff, die nur ein
eigener Ort oder eine Retextur (WP4.7) behebt.

**Was an C gelesen ist und was nicht:** gelesen ist, dass die Blöcke ihr Modell als Eigenschaft
`Model` tragen (160 direkt, der Rest geerbt) und dass ein Patch diese Eigenschaft setzen kann. **Nicht
gelesen:** ob ein Ersatzmodell in ein mehrfeldriges Feld (`MultiBlockDim`, 249 Blöcke) passt, ohne
zu schweben oder in Wände zu ragen; ob Behälter ihre Beute behalten; ob die Kollision mitwandert.
Das klärt das Finding WP6.2 und **ein Blick im Spiel (S-29)**. C braucht einen eigenen Vertrag
(Nachtrag zu Vertrag 03: „umkleiden ist kein Sperren") — WP6.2.

**Stand WP6.2 (Finding §5, §6):** Orte speichern Blöcke **per Name**; ein Modell-Block liest `Model`
beim Laden seiner Klasse. Ein `<set>` auf `Model` kleidet also jeden Ort um, der den Block enthält;
Klasse, Behälter, Beute und `MultiBlockDim` bleiben. Offen bleibt nur, was man sehen muss: ob das
Ersatzmodell im Maß sitzt und ob die Kollision mitwandert (S-29, drei Blöcke). Der Vertrags-Nachtrag
zu Vertrag 03 folgt mit WP6.5b, wenn S-29 den Weg trägt.

## E. Wege statt Straßen

Straßen sind Kacheln (`rwg_tile_*`, 68) und Verbindungen zwischen Siedlungen. Vorschlag: die
Kacheln bleiben (ohne sie keine Siedlung), ihr **Belag** wird über die Block-Retextur (WP4.7) zu
festgefahrener Erde, bis dahin bleiben sie Asphalt. ~~Ob die Verbindungsstraßen abschaltbar sind,
ohne Händlerwege zu brechen, ist **[verifizieren, WP6.2]**.~~ **Stand WP6.2 (Finding §3):** Fernstraßen
entstehen zwischen Siedlungen, deren Art `spawn_gateway` trägt; Arten ohne Gateway bekommen (Lesart)
Feldwege, Wildnisorte Pfade. Händler hängen nicht an Straßen. Eine Welt nur aus Siedlungsarten ohne
Gateway hätte keine Fernstraßen — ob dann noch Feldwege entstehen, zeigt S-29. Bis dahin gilt: Asphalt
ist die **sichtbarste Lücke** der Welt von 2a und steht so in der Prüfliste.

## F. Nebel im Flusstal (D72)

Ein Flusstal ist kein Biom; Nebel gibt es nur je Biom und Wetter. Gebaut ist Nebel im Klosterland
und im Moor (D72). Mehr geht in Phase 2 nicht ohne Code; **Phase-3-Notiz** (D50): Nebel an
Wassernähe bräuchte eine Abfrage am Spielerort.

## G. Automaten und Tresore (D122)

Automaten (7 Blöcke, Klasse `VendingMachine`) und Tresore/Waffenschränke (Behälter) gehören nach
Weg C: das **Modell** wird umgekleidet (Fass, Kiste mit Schloss), die **Mechanik** bleibt (P5).
Ein Automat, der verkauft, wird damit zu einem „Krämerfass" — ob das trägt, entscheidet der Nutzer
(N-97); die Alternative ist, Automaten über Weg B mit ihren Orten wegfallen zu lassen.

## H. Beute je Ort (D121)

Vanillas Beutestufe bleibt. Was in welcher Kiste liegt, steht in `loot.xml` je **Behälter**, nicht je
Ort; ein Ort bestimmt seine Beute über die Behälter, die in ihm stehen. Für eigene Orte heißt das:
Kloster mit Truhen und Schreibpulten, Hof mit Kornkisten, Ruine mit verschütteten Kisten. Die
Zuordnung kommt mit WP8.6 (F-05 „Beute in 700").

## I. Fertigkarten (D110)

Vanillas Fertigkarten (Navezgane, PREGEN) werden **nicht unterstützt**; die Spielvorlage „Jahr 700"
(D136) verweist auf die Zufallswelt. Eine eigene Karte ist Phase 4 (D4).

## J. Reihenfolge der Umsetzung

| Schritt | Was | hängt an |
|---|---|---|
| WP6.2 | Finding: Händler und Siedlungen, Auftragsreichweite, Prefab-Format, **Weg C** (Modell-Tausch, `MultiBlockDim`) | — |
| WP6.3 | Biom-Fortschritt Weg B (biome.md §3) | — |
| WP6.4 | Landschaften: Namen, Bewuchs, Sturmtexte | P2-E13 |
| WP6.5 | `rwgmixer.xml`: moderne Ortsarten heraus (Weg B) — **gebaut 2026-11-23** (D157, N-102): 7 Siedlungsarten auf 0, 17 Neuzeit-Orte selten, Stufe-5-Orte bleiben bis WP6.6 | WP6.2 |
| WP6.5b | Umkleide-Tabelle (Weg C), erst nach S-29 | WP6.2, S-29 |
| WP6.6 | eigene Orte nach Abschnitt C | WP6.2 (Bauweg) |

## K. Offen für den Nutzer (N-97, N-98)

1. **Weg B + C** für die Welt von 2a — oder nur B (leer, wenig Aufträge bis zu eigenen Orten)?
2. **Elf Entwürfe** als erste Reihe (Abschnitt C) — reicht das, oder lieber mehr kleine Orte?
3. **Asphalt** bleibt in Phase 2 sichtbar (bis zur Retextur) — hinnehmbar?
4. **Automaten** umkleiden (Krämerfass) oder wegfallen lassen?
5. P2-E13 (die fünf Landschaftsnamen) bleibt offen wie bisher.
6. **Eigene Orte im Editor des Spiels** (N-98): ein Ort ohne Editor ist unbelegt; wer baut sie?
7. **Name des eigenen Händlerorts** `trader_poi700_…` statt `poi700_…` (Vertrag 02, Nachtrag WP6.2).

## Akzeptanzkriterien der Ausarbeitung

- [x] Bedarfsrechnung (Aufträge, Händler, Ortschaften) — Abschnitt C, Zahlen gemessen
- [x] die Welt von 2a mit Wegen und Empfehlung — Abschnitt D
- [x] Wege, Nebel, Automaten, Beute, Fertigkarten — Abschnitte E bis I
- [x] die drei **[verifizieren]** aus A, C, E — WP6.2, statisch beantwortet (Finding
  `F-07-zufallswelt-und-orte.md`); was man sehen muss, steht in S-29
