# Prüfung 0002 — Erscheinung: was der Spieler sieht und hört, und ob es dafür einen Plan gibt

| | |
|---|---|
| **Datum** | 2026-11-22 |
| **Gegenstand** | Alles, was kein Text ist: Modelle, Symbole, Gegner, Tiere, Welt und POIs, Fahrzeuge, Luftabwurf, Oberfläche, Klang, Musik, Wetter, Biome |
| **Stand der Daten** | ConfigsDump `C:\Users\Anwender\Saves\Pregen06k01\Z\ConfigsDump`, Zeitstempel 2026-11-22 21:08:42Z, **mit** unseren Modlets (belegt: `worldglobal.xml` trägt „replaced by 700_60_Welt", `items.xml` führt `itm700_*`) |
| **Spiel** | 7 Days to Die V 3.40 b10, Welt `Pregen06k01` (mitgelieferte Fertigkarte, 6k) |
| **Art** | Nur Prüfung und Plan. Keine Umsetzung, keine andere Datei geändert, kein Commit. |

**Lesehilfe.** Drei Wörter trennen, was wie sicher ist:
**gemessen** = aus einer Datei gezählt, Befehl steht in Abschnitt 2 ·
**gesehen** = als Bild angesehen (nur Symbolbilder unter `Data\ItemIcons` und Vorschaubilder der POIs) ·
**angenommen** = aus dem Namen geschlossen oder aus Kenntnis von Vanilla, nicht geprüft.
Historische Marken: **belegt** (um 700 in Europa nachgewiesen) · **plausibel** · **später** (Konflikt mit Säule P1).

---

## 1. Kurzfassung

1. **Die Welt ist die größte Lücke und die früheste.** Von 1 590 POI-Platzierungen der Testkarte tragen 1 525 (95,9 %) mindestens einen eindeutig neuzeitlichen Block; die 65 übrigen sind leere Parzellen. Unter allen 1 105 Vanilla-POIs gibt es **kein einziges Gebäude** ohne Treffer.
2. **F-07 Phase 2a beruht auf einer Annahme, die die Messung nicht trägt:** „nur Vanilla-POIs ohne Anachronismen zulassen (Höhlen, Hütten, Ruinen)" — auch Höhlen, Hütten und Grabstellen führen Autos, Schilder, Lampen (gemessen und an Vorschaubildern gesehen).
3. **Kein Seuchentoter ist umbenannt oder entfernt.** 35 Grundklassen, 155 mit Stufen, 0 Sprachzeilen der Mod. In der Tagesgruppe des Startbioms stehen Krankenschwester, Geschäftsmann, Tourist, Biker, Hausmeister. Das GDD verspricht für Phase 1 „Gegner … mit neuen Namen" (GDD.md:225), F-06 liegt aber in Phase 2 — ein Widerspruch.
4. **Die Symbole der Kernwirtschaft sind neuzeitlich** (gesehen): der Silberpfennig ist ein Casino-Jeton mit englischer Umschrift, Raseneisenerz ein Haufen Schrauben und Blech, Leim eine Plastikflasche „TOUGH GLUE", Schmiedeeisen ein Barren mit „Fe 26". Dafür gibt es **keinen Plan** — und es ginge in Phase 1 per XML.
5. **100 Abschriften und Lehrblätter zeigen gedruckte Buch- und Magazintitel** mit englischer Schrift und Fotos (gesehen). Kein Plan. Per XML auf das Pergament-Symbol umzubiegen.
6. **Waffen, Rüstung, Werkstätten:** Feuerwehraxt, Machete mit Schlagring, Compoundbogen, Schrottpanzer mit Blecheimer-Helm, Betonmischer als Kalkofen, Labortisch als Kräuterküche (alles gesehen). Der Plan (Phase 2, F-16) deckt davon etwa die Hälfte.
7. **Ohne jeden Plan:** Luftabwurf mit Flugzeug (`prefabC46`), Stürme und Biom-Gefahren („Radioaktiver Sturm", Gasmasken erreichbar), Musik, Ladebilder und Menü-Hintergrund, Spielerfigur, Tiere und Pflanzen der Neuen Welt, Landminen im Ödland, Trinkglas, Händler-Erscheinung.
8. **XML-Hebel für Phase 1, bisher ungenutzt:** Symbol umbiegen (`CustomIcon`), Biom-Dekor streichen (`biomes.xml`), Spawn-Gruppen kürzen (`entitygroups.xml`), Denylist ergänzen, und eine Spielvorlage in `sandbox_overrides.xml` (Luftabwurf, Stürme, Händlerstimmen, Automaten aus).
9. **Stückliste für F-16** (Abschnitt 6): rund 150 Symbole, 12–14 Waffenmodelle, 3 Rüstungsgarnituren, 34 Zombie-Modellfamilien, 8–9 Werkstatt- und Blockmodelle, 6–7 Blocktexturen, 30–60 eigene POIs samt Wegekacheln, 5 Händler samt Posten.
10. **Grenze:** Angesehen sind 152 Symbolbilder und 20 POI-Vorschaubilder. Kein Modell im Spiel, keine Textur, kein Ladebild, kein Klang, keine Musik. Abschnitt 7 nennt 14 Stellen, an denen ein Mensch im Spiel nachsehen muss.

---

## 2. Methode

### 2.1 Befehle und Zahlen

| # | Was | Befehl bzw. Verfahren | Ergebnis |
|---|---|---|---|
| M1 | Urteil der Anachronismus-Prüfung | `tools\check\Mod700.Check\bin\Release\net10.0\mod700check.exe anachronisms "C:\Users\Anwender\Saves\Pregen06k01\Z\ConfigsDump" --denylist tools\check\denylist.txt --json` | Exit 0 · 543 geprüfte Kennungen · 0 verbotene · 1 aufgeschoben (`resourceRepairKit`) · 11 unauflösbar |
| M2 | Liste der erreichbaren Kennungen | `mod700check ungeprueft <Dump> --denylist <Datei mit einer Regel, die nichts trifft>` — so listet das Werkzeug alles Erreichbare mit Eigenschaften | 444 Kennungen in 68 Gruppen: 308 Gegenstände, 78 Blöcke, 47 Aufsätze, 11 unauflösbar |
| M3 | Modell und Symbol je erreichbarer Kennung | `items.ps1`: liest `items.xml`, `blocks.xml`, `item_modifiers.xml` des Dumps, löst `Meshfile`, `CustomIcon`, `Model`, `Shape` über `Extends` auf, deutscher Name aus Vanilla- plus Mod-Sprachdatei | 444 Zeilen |
| M4 | Wesen | `wesen.ps1`: `entityclasses.xml` (Klasse, `extends`, `Mesh`), Mitgliedschaft in `entitygroups.xml`, Gruppen aus `spawning.xml` und `gamestages.xml` | 293 Klassen · 1 875 Gruppen · 29 Gruppen in `spawning.xml` · 155 `zombie*`-Klassen, alle in mindestens einer Gruppe · 63 davon in Biomgruppen · **0 Wesen-Namen in der Mod-Sprachdatei** |
| M5 | POIs der Welt | `prefabs.ps1`: `Data\Worlds\Pregen06k01\prefabs.xml` (Platzierungen), je Prefab die `.xml` (Zoning, Tags) und die `.blocks.nim` (Blocknamen, Binärformat: int32, int32 Anzahl, dann je Eintrag int32 + Zeichenkette) | 3 469 Platzierungen · 966 verschiedene Prefabs (749 POIs / 1 590 Plätze, 169 Teile / 1 553, 48 Straßenkacheln / 326) · 9 869 Blocknamen |
| M6 | Neuzeit-Blöcke je POI | `poi-modern.ps1`: sieben Mustergruppen über die Blocknamen aller 1 105 POIs | 61 ohne jeden Treffer, 90 ohne Treffer außer Baustoff (Abschnitt 4.5) |
| M7 | Beute und Ernte von POI-Blöcken | `loot.ps1`: `LootList` (auch in `CompositeFeatures`) → `loot.xml` rekursiv bis zu den Gegenständen; `<drop>` mit Vererbung | 32 Blöcke aufgelöst (Abschnitt 4.6) |
| M8 | Biom-Dekor, Wetter | `grep`/`awk` über `biomes.xml` des Dumps | 691 Dekor-Zeilen · 63 eindeutig neuzeitlich · 28 ungeprüfte Beute-Platzhalter · 18 Kakteen · 55 Wetter-Einträge · 3 Sturm-Partikel |
| M9 | Klang und Musik | `<SoundDataNode name=…>` in `sounds.xml` gezählt und nach Wortmustern eingeteilt; `dmscontent.xml`, `music.xml` gelesen | 2 555 Klangknoten · 4 Musik-Sektionen + 2 Heim- + 5 Händler-Themen |
| M10 | Oberfläche | Symbolnamen in `progression.xml`, `buffs.xml`, `nav_objects.xml`; Texturen in `XUi_Menu\windows.xml`; `loadingscreen.xml`, `archetypes.xml`, `sandbox_overrides.xml` gelesen | 78 sichtbare Fertigkeits-Einträge · 178 Buff-Symbole · 73 Karten-Klassen · 4 Ladebilder · 34 Figuren-Vorlagen |
| M11 | Bilder | `bogen.ps1`: setzt Symbol- bzw. Vorschaubilder zu einem Kontaktbogen zusammen (nur im Scratchpad) | 4 Bögen mit 152 Symbolen, 1 Bogen mit 20 POI-Vorschauen |
| M12 | Plan-Suche | `grep` über `docs/GDD.md`, `docs/features/*.md`, `docs/plans/0001-…md` nach Luftabwurf, Flugzeug, Musik, Ladebild, Sturm, Strahlung, Kojote, Kaktus, Mine, Glas, Sandbox | Treffer bzw. Fehlanzeige je Kategorie in der Matrix |

Die Skripte und Zwischendateien liegen **nicht** im Repository, sondern im Scratchpad der Sitzung und
können nach einem Neustart weg sein:

```
C:\Users\Anwender\AppData\Local\Temp\claude\0d56731313e1516a\76220937-0def-4ad5-a85a-b4b270341b20\scratchpad\nacht\erscheinung\items.ps1
C:\Users\Anwender\AppData\Local\Temp\claude\0d56731313e1516a\76220937-0def-4ad5-a85a-b4b270341b20\scratchpad\nacht\erscheinung\wesen.ps1
C:\Users\Anwender\AppData\Local\Temp\claude\0d56731313e1516a\76220937-0def-4ad5-a85a-b4b270341b20\scratchpad\nacht\erscheinung\prefabs.ps1
C:\Users\Anwender\AppData\Local\Temp\claude\0d56731313e1516a\76220937-0def-4ad5-a85a-b4b270341b20\scratchpad\nacht\erscheinung\poi-modern.ps1
C:\Users\Anwender\AppData\Local\Temp\claude\0d56731313e1516a\76220937-0def-4ad5-a85a-b4b270341b20\scratchpad\nacht\erscheinung\loot.ps1
C:\Users\Anwender\AppData\Local\Temp\claude\0d56731313e1516a\76220937-0def-4ad5-a85a-b4b270341b20\scratchpad\nacht\erscheinung\bogen.ps1
```

Sollen die Zählungen wiederholbar werden, gehören M4 bis M6 als Befehle nach `tools/check` — das ist
eine Erweiterung von Vertrag 04 und damit eine Entscheidung des Nutzers.

### 2.2 Gegenproben (CLAUDE.md Regel 5)

| Prüfung | Bekannt falscher Eingang | Ergebnis |
|---|---|---|
| M6, Mustergruppen | `gas_station_01` muss anschlagen | 104 Treffer, davon 10 Fahrzeug — rot wie erwartet |
| M6, Mustergruppen | `oldwest_gallows` (Galgen aus Holz) muss frei sein | 0 Treffer |
| M6, **erster Lauf fehlerhaft** | `site_grave_01` zeigt auf dem Vorschaubild einen roten Pritschenwagen | Im ersten Lauf Fahrzeug = 0: der Block heißt `cntPickupTruck01AirRandomHelper`, mein Muster kannte `Pickup` nicht. Muster ergänzt, zweiter Lauf Fahrzeug = 1. Die Zahlen unten stammen aus dem zweiten Lauf. **Folge: die Muster zählen eher zu wenig als zu viel** — „ohne Treffer" ist eine Obergrenze. |
| M3, Symbol-Vererbung | `modArmorBandolier` meldete das Symbol `missingIcon` | Falsch gelesen: `Extends … param1="CustomIcon"` heißt „Symbol **nicht** erben". Die betroffenen Zeilen (47 Aufsätze, vier `armorPrimitive*`) führen ihr eigenes Symbol; in den Befunden so berichtigt. |

### 2.3 Was nicht gemessen ist

Der Wert `AirDropFrequency` des Spielstands (`gameOptions.sdf` ist binär und gab die Kennung nicht her),
jedes Modell im Spiel, jede Textur, jedes Ladebild, das Menü-Video, jeder Klang. Siehe Abschnitt 7.

---

## 3. Matrix je Kategorie

Spalten wie verlangt. „→ 4.x" verweist auf die Belege. Planstellen als Datei:Zeile; die Zeilen des
Plans 0001 wandern, weil die Datei heute mehrfach geändert wurde (Stand: 22.11.2026 abends).

| Kategorie | Was man in Phase 1 sieht | Gemessen an | Plan vorhanden? Wo | Lücke | In Phase 1 per XML möglich | Braucht Phase 2+ |
|---|---|---|---|---|---|---|
| **K1 Seuchentote** | 35 Grundklassen in 34 Modellfamilien (98 Prefabs mit Stufen), alle Vanilla: Krankenschwester, Polizist, Soldat, Geschäftsmann, Tourist, Bowler, Biker, Gefahrgut, Laborant, Insasse … Namen unverändert | M4 → 4.1 | Ja: F-06 (Phase 2), F-06:19 „Entfernen", F-06:36 Retextur; F-16:27 „häufigste 6 Zombies" | **Widerspruch** GDD.md:225 („Gegner … mit neuen Namen" in Phase 1) gegen F-06 Phase 2. **Zu klein:** 6 von 34 Familien in der Asset-Liste, F-06:14 will aber jede Klasse umgedeutet | Uniform-Klassen aus den 29 Biomgruppen nehmen; `Mesh` einer Klasse auf ein anderes Vanilla-Modell setzen (Vanilla tut das selbst: `zombiePlagueSpitter` trägt das Farmer-Modell) | Retextur von 34 Familien bzw. der Auswahl, die bleibt; neue Meshes für Leitfiguren (F-06:37) |
| **K2 Tiere** | Hirsch, Reh, Hase, Huhn, Bär, Wolf, Wildschwein — und Kojote, Berglöwe, Schlange, Schreckenswolf, Zombie-Geier, Zombie-Hund, Zombie-Bär | M4 → 4.1 | Teilweise: F-06:18 nennt nur die passenden vier; F-16:29 „Wildtiere" Retextur Prio 3 | **Ohne Plan:** Tiere der Neuen Welt (Kojote, Berglöwe = Puma: **später**, nach 1492) | Kojote und Berglöwe aus je 2 Biomgruppen nehmen oder durch Wolf ersetzen | Retextur Schreckenswolf zum Spukhund (F-06:27), Schlange zur Kreuzotter |
| **K3 Spielerfigur** | 34 Vorlagen mit Namen und Frisuren der Neuzeit (`buzzcut`, `dreads`, `comb_over`, „Ricky Bobby"); Körper, Unterkleid und Hände der Ich-Sicht Vanilla | M10 → 4.9 | **Nein** | **Ohne Plan** | Vorlagen in `archetypes.xml` kürzen oder umbenennen (ungeprüft, ob das Spiel eine Mindestzahl verlangt) | Unterkleid-Retextur, 2 Stück |
| **K4 Waffen, Werkzeug** | Feuerwehraxt als Bartaxt, Zahnrad-Axt als Breitaxt, Machete mit Schlagring als Spatha, Kampfmesser als Sax, Rohr-Speere, Compoundbogen als Langbogen, Compound-Armbrust | M3, M11 gesehen → 4.2 | Ja: F-02:167, F-16:27–29, GDD.md:233 | **Zu klein:** geplant sind 6 neue Modelle (Spatha, Sax, Rundschild, Langbogen, Armbrust, Wurfaxt). Ohne Plan: beide Äxte, Streitkolben, Streithammer, Eisenfaust, Feuertopfpfeil | Nur das Symbol, nicht das Modell in der Hand. Rollen tauschen wie in D88 | 12–14 Modelle |
| **K5 Rüstung, Kleidung** | T3 „Kettenhemd": Schrottpanzer, Helm aus gelochtem Blecheimer · T2 „Gambeson": Umhang mit Messertaschen, Kapuze mit Schweißerbrille · T1: ärmellose Lederweste · T0 Lumpen: passt | M3, M11 gesehen → 4.2 | Ja: F-03:72–73 („Aussehen ungeprüft"), F-03:105, Prüfliste 6 (Plan:1974) | Plan reicht als Auftrag; das Urteil des Nutzers steht aus | Anderer `Prefab`-Pfad ist „eine Zeile je Stufe" (F-03:73) — aber nur vier Grundspiel-Garnituren sind ohne Kopf-Matrix borgbar (F-03:57–60) | 3 Garnituren × 4 Teile, je Geschlecht |
| **K6 Rohstoffe, Währung, Verbrauch** | Casino-Jeton, Schrott, Barren „Fe 26", Plastikflasche Leim, Garnspule mit Maßband, Einmachglas mit Schraubdeckel (7 Getränke, Honig), Binde mit Kreuz | M11 gesehen → 4.3 | **Nein.** F-16:16 kennt Symbole nur als Format; F-16:28 nur Runen- und Trank-Symbole. Mod-Kommentar: das Glas „räumt F-05 in WP4 auf" — F-05 sagt dazu nichts | **Ohne Plan** | **Ja:** `CustomIcon` auf ein vorhandenes Vanilla-Symbol (`resourceSilverNugget`, `oreIronBoulder`, `medicalBandage`, `resourceAnimalFat`) | Eigene Symbole, Tonkrug-Modell |
| **K7 Abschriften, Lehrblätter, Bündel, Notiz** | 85 Abschriften + 15 Lehrblätter als gedruckte Bücher und Magazine („BATTER UP!", „HOME COOKING WEEKLY"); Bündel als Pappkarton; Pergamentfetzen als linierter Zettel „Challenge" | M3, M11 gesehen → 4.3 | **Nein** | **Ohne Plan** | **Ja:** `CustomIcon="resourcePaper"` mit Farbton je Reihe | 13 Reihen-Symbole, falls Unterscheidung gewollt |
| **K8 Aufsätze, Biom-Ausrüstung** | 47 Aufsätze erreichbar, darunter Patronengurt mit Patronen, Kunststoff-Knieschoner, Tarnstoff-Tasche, 9 Färbemittel als Plastikflasche „DYE"; vier Biom-Ausrüstungen = Gasmasken, Sonnenbrille, Skibrille | M3, M11 gesehen → 4.3 | **Nein** (D87 hat sieben Kennungen umgedeutet, diese nicht) | **Ohne Plan** | Denylist ergänzen (F-01) oder Symbol umbiegen | Symbole |
| **K9 Werkstätten, platzierbare Blöcke** | Kalkofen = Betonmischer auf Rädern · Kräuterküche = Labortisch mit Bildschirm · Zimmermannsbank und Webstuhl = Werkbank mit Schraubstock · Hühnerstall = buntes Kinderspielhaus · Gebietsschutzblock = Metallkiste mit Warnzeichen · Stahlrohrstuhl, Fahne mit Logo, Leinwandbild. Passend: Rennofen und Esse, Feuerstelle, Palisade, Tor, Kisten | M3, M11 gesehen → 4.4 | Teilweise: F-04:52–55 (Webstuhl), F-16:28–29 (Rennofen, Webstuhl, Schrein) | **Ohne Plan:** Kalkofen, Kräuterküche, Zimmermannsbank, Hühnerstall, Gebietsschutzblock | `Model` auf ein anderes Vanilla-Prefab (Vorbild: Webstuhl); Stuhl, Fahne, Bild über die Denylist sperren | 8–9 Modelle |
| **K10 Baublöcke** | Fünf Stufen mit Vanillas Texturen: Bruchstein sieht aus wie Gussbeton, Mörtelstein wie genieteter Stahl (angenommen) | F-18:17–23 | Ja: F-18:108, F-16:28, GDD.md:234 | Plan reicht; Liste nennt 4 Texturen, es sind 5 Stufen plus Dach | Nein | 6–7 Texturen |
| **K11 POIs** | 1 590 Platzierungen aus 749 Prefabs: Tankstellen (40), Hochhäuser (8), Trailer (48), moderne Häuser (57), Militärlager (18), Fast Food (15) … | M5, M6 → 4.5 | Ja: F-07:34–38, F-01:28, Plan:207 (bekannte MVP-Lücke) | **Annahme widerlegt** (F-07:34): kein Vanilla-Gebäude ist frei. **Widerspruch** F-07:36 (Karte Phase 3) gegen D4 und GDD.md:219 (Phase 4). **Ohne Plan:** Fertigkarten und Navezgane, auf die kein RWG-Filter wirkt | `prefab_spawn_adjust` in `rwgmixer.xml` kennt `max_count` — wirkt nur auf **neu erzeugte** RWG-Welten, ungeprüft ob 0 gilt | Eigene Prefabs: F-07 will 10, eine 6k-Karte braucht 30–60 |
| **K12 Straßen, Ortschaften** | 326 Straßenkacheln, `terrAsphalt` in 465 Prefabs, 11 Ortstypen | M5 → 4.5 | Ja: F-07:12 „deaktivieren bzw. ersetzen" | Nur erwähnt: kein Wort dazu, was Wege ersetzt | Ortstypen in `rwgmixer.xml` kürzen (nur neue Welten, ungeprüft) | Wegekacheln ohne Asphalt |
| **K13 Blöcke in POIs: plündern, abbauen** | Aus dem Polizeiwagen holt man Pfeile, aus dem Autowrack 70–180 „Raseneisenerz" und 3–6 „Tiegelstahl"; Automaten, Geldautomaten (leer), Kühlschränke, Fernseher, Leuchtreklame | M7 → 4.6 | Teilweise: F-01:28 und :42, F-05:16 „Altmetall aus Römerruinen" | **Ohne Plan** für die Zwischenzeit: was ein Auto in Phase 1 **ist** (Name, Ernte) | Blocknamen der Wracks umdeuten ist Text; Ernte ist Balancing (Plan:487) | Verschwindet mit eigenen POIs |
| **K14 Biom-Dekor außerhalb von POIs** | Autowracks, Reifen, Fässer, Schlackensteine, Schrotthaufen in der freien Landschaft; **Landminen** (Radkappe, Bonbondose) im Ödland; Kakteen in der Wüste | M8 → 4.7 | **Nein** | **Ohne Plan.** Landmine = Sprengstoff (**später**, P1 nennt Schießpulver ausdrücklich) | **Ja:** 63 Dekor-Zeilen in `biomes.xml` streichen; wirkt nur auf neu erzeugte Gebiete (angenommen) | Ersatz-Dekor (Grabkreuze, Pestgruben: F-07:30) |
| **K15 Händler** | 15 Posten auf der Karte (Joel 4, Jen 4, Hugh 3, Rekt 2, Bob 2), fünf NPC-Modelle, 1 336 gesprochene englische Zeilen, fünf Themen-Musikstücke, Getränke- und Imbissautomaten | M5, M9; Plan:2709 | Teilweise: F-10 (Phase 2) nennt Posten-Typen und Sortiment | **Nur erwähnt:** F-10 hat keinen Satz zu Modell, Posten-Prefab, Stimme, Musik. Stimmen „nicht entschieden" (Plan:2709), Namen offen (Plan:1442) | Spieloption `TraderDialog` aus, `VendingEnabled` aus — über eine Vorlage in `sandbox_overrides.xml` | 5 NPC, 3–5 Posten-Prefabs, Stimmen |
| **K16 Fahrzeuge** | Keines erreichbar (0 von 444). Sichtbar bleiben nur Wracks (K13) und fünf Karten-Symbole | M2, M10 | Ja: F-13 (Phase 3 und 4), D16 | Plan reicht | Erledigt | Karren, Wagen, Pferd (F-13:54) |
| **K17 Luftabwurf** | Flugzeug `prefabC46` (Curtiss C-46, 1940: **später**), Fallschirm, Kiste, Motorklang `Supply_Crate_Plane_lp`, Kartensymbol | M4 → 4.8 | **Nein.** Einziger Treffer im ganzen Repository: die Beutegruppe der Kiste (Balancing 0003:328) | **Ohne Plan**, fehlt auch in GDD 2.3 | Spieloption `AirDropFrequency` aus, über die Vorlage | Falls ein Ersatz gewollt ist: Entscheidung, dann 1 Modell |
| **K18 Auftrags-Requisiten, Beutesäcke** | Rally-Fahne (`questRallyMarker` in 394 Prefabs), Suchtasche, Generator der Stromaufträge; Beutesack der Zombies (`zpackPrefab` in vier Farben), fallen gelassener Rucksack | M4, M5 | Teilweise: Stromaufträge als offener Punkt (Plan:2587) | **Ohne Plan** für Fahne, Tasche, Beutesack | Stromaufträge aus den Händlerlisten nehmen (F-01) | 3–4 Modelle |
| **K19 Oberfläche im Spiel** | 78 sichtbare Fertigkeits-Einträge, Symbolnamen wie `marksmanship` (5×), `knunchuck` (4×), `run_and_gun`, `grand_slam`, `parkour`; Karten-Symbole für Luftabwurf, Automat, Drohne, Generator; Buff-Symbol `radiation` (13×) | M10 → 4.9 | Teilweise: F-12:40 Farben, Rahmen, Schriften; D85 acht Farben gebaut; D90 Vorbild (Einkaufswagen → Beutesack) | Rahmen und Sprites „ungelesen" (F-12:142); Symbole einzeln ohne Plan | `icon` umbiegen wie in D90 | Schrift, Rahmen-Sprites |
| **K20 Menü, Ladebilder** | 4 Ladebilder `GUI/loading_screen_1…4`, Titelbild `news_logo.png`, Menü-Hintergrund als Video `/Video/MenuBackground` — Inhalt ungesehen | M10 | **Nein** (F-12 regelt nur die Tipps und ein Etikett) | **Ohne Plan** | Ladebilder aus der Liste nehmen; Bilder ersetzen braucht eigene Dateien | 4 Bilder, 1 Titelbild, 1 Hintergrund |
| **K21 Klang** | 2 555 Klangknoten; unsere Mod ändert nur, **wie oft** Seuchentote Laut geben. Händlerstimmen, Flugzeug, Geigerzähler, Alarmanlagen (7 Knoten, in POIs) bleiben | M9; F-17:175–191 | Ja: F-17 B2, D74, F-16:31–35 | Plan reicht für Umgebung und Wesen; Händler siehe K15 | Erledigt, soweit XML (D74) | F-16-Klangliste |
| **K22 Musik** | Vier dynamische Sektionen (Erkundung 52 Clips, Spannung 33, Kampf 55, Blutmond 49; Summe der `num` in `dmscontent.xml`), Heim Tag und Nacht, fünf Händler-Themen — ungehört | M9 | **Nein.** `grep -i musik` trifft in GDD und Features nichts | **Ohne Plan** | Nichts Sinnvolles; der Spieler kann sie in den Optionen leiser stellen | Entscheidung: aus, behalten oder ersetzen |
| **K23 Wetter, Stürme, Biom-Gefahren** | Vier Stürme mit Namen und Blinksymbol: Aschesturm, Sandsturm, Schneesturm, **Radioaktiver Sturm**; vier Biom-Gefahren; Strahlung am Kartenrand mit Geigerzähler-Klang | M8, M10 → 4.8 | Teilweise: D34 „wie Vanilla" (GDD.md:362); Biom-Gefahren als offener Punkt (Plan:2574: „steht in keinem Dokument") | **Ohne Plan:** Stürme, Strahlung. D34 wurde vor den Stürmen von V 2+ gefasst | Spieloptionen `StormFreq` und `BiomeProgression` aus, über die Vorlage; Sturmnamen sind Text | Umdeutung (Moorhauch statt Strahlung) |
| **K24 Biome** | Fünf Vanilla-Biome unverändert im Bild: Kiefernwald, verbrannter Wald, Wüste, Schnee, Ödland. Gebaut: nur Nebelwerte und Nachtlicht | M8; F-17:133–145 | Ja: F-07:17–25 (Kulturzonen), D43; Stand F-07:47–57 „noch nicht entschieden" | Plan vorhanden, Entscheidung zu D43 offen; Pflanzen der Neuen Welt (Kaktus, Yucca, Mais- und Kartoffelfelder als POI: **später**) nirgends genannt | Kaktus-Dekor streichen (18 Zeilen) | Bodentexturen, Bepflanzung je Zone |
| **K25 Seuchennacht** | Vanillas Blutmond: roter Himmel, eigene Musik-Sektion | M8, M9 | Ja: F-09 (Phase 2), F-09:28 „mit eigener Optik" | Nur erwähnt: was „eigene Optik" ist, steht nirgends | Nein | Mit F-09 festlegen |

---

## 4. Befunde im Einzelnen

### 4.1 Wesen (M4)

- **Gegner:** 155 Klassen `zombie*` = 35 Grundklassen mal bis zu vier Stufen (Feral, Radiated, Charged,
  Infernal). 98 verschiedene Modell-Prefabs in 34 Familien. Alle 155 stehen in mindestens einer Gruppe,
  63 in einer der 29 Gruppen aus `spawning.xml` (30 Grundklassen).
- **Was unsere Modlets an Wesen ändern:** sieben Zahlen zur Lauthäufigkeit
  (`mod/700_60_Welt/Config/entityclasses.xml`) und die Startausrüstung. Kein Name, kein Modell, kein Spawn.
- **Tagesgruppe des Startbioms** (`ZombiesAll`, 20 Einträge; `spawning.xml`, Biom `pine_forest`,
  Regel `dz01`): `zombieBusinessMan`,
  `zombieSkateboarder` (deutsch „Gangster"), `zombieBiker`, `zombiePartyGirl`, `zombieUtilityWorker`,
  `zombieJanitor`, `zombieLumberjack`, `zombieNurse`, `zombieFatHawaiian` („Tourist"), `zombieBowler` —
  zehn von zwanzig tragen dem Namen nach Berufs- oder Freizeitkleidung der Neuzeit.
- **Dem Namen nach eindeutig neuzeitlich** (17 Grundklassen; das Aussehen selbst ist **angenommen**):
  PartyGirl, Nurse, BusinessMan, MaleHazmat, Janitor, Inmate, Lab, UtilityWorker, Biker, FatHawaiian,
  Bowler, FatCop, Skateboarder, Soldier, Demolition, Rancher, Lumberjack.
  **Dem Namen nach am wenigsten gebunden:** Burnt, Spider, Screamer, Mutated, SteveCrawler, Wight,
  Frostclaw, PlagueSpitter.
- **Tiere in Gruppen:** Hirsch, Reh, Hase, Huhn, Bär, Kleiner Bär, Wolf, Wildschwein (**belegt**) ·
  Zombie-Geier (Geier in Europa **belegt**, als Seuchentier **plausibel**) · Schlange (`snake_Prefab`;
  Kreuzotter **plausibel**, falls das Modell keine Rassel trägt — ungesehen) · Kojote, Berglöwe
  (**später**, Neue Welt) · Schreckenswolf (ausgestorbene amerikanische Art; als Sagengestalt umdeutbar).
  Kojote: `EnemyAnimalsDesert`; Berglöwe: `EnemyAnimalsSnow`.
- **Weitere Wesen:** `supplyPlane` (4.8), fünf Händler (`npcTrader*`), drei Roboter-Wesen ohne Gruppe
  (nicht erreichbar), neun Beutesack-Klassen.

### 4.2 Waffen, Werkzeug, Rüstung (M3, M11 — gesehen)

Angesehen ist das **Symbolbild**; bei Vanilla ist es ein Abbild des Modells, das in der Hand liegt.
Ob das für jedes Stück gilt, ist angenommen.

| Kennung | Unser Name | Im Bild | Historisch |
|---|---|---|---|
| `meleeToolAxeT1IronFireaxe` | Bartaxt | rote Feuerwehraxt | **später** |
| `meleeToolAxeT2SteelAxe` | Breitaxt | Axt aus Zahnrad und Blechen | **später** |
| `meleeWpnBladeT3Machete` | Spatha | Machete mit Schlagring-Griff, gezahnt | **später** |
| `meleeWpnBladeT1HuntingKnife` | Sax | Kampfmesser mit Sägerücken | **später** (der Sax selbst: belegt) |
| `meleeWpnClubT3SteelClub` | Streitkolben | Rohr mit Zahnradkopf | **später** |
| `meleeWpnKnucklesT1IronKnuckles` | Eisenfaust | Messing-Schlagring | **später**; Faustriemen (Caestus) plausibel |
| `meleeWpnKnucklesT0LeatherKnuckles` | Faustriemen | grünes Gurtband mit D-Ring | **später** |
| `meleeWpnSledgeT3SteelSledgehammer` | Streithammer | Vorschlaghammer mit Sechskantkopf | **später** |
| `meleeWpnSpearT1IronSpear`, `…T3SteelSpear` | Ango, Flügellanze | Rohr mit aufgestecktem Messer | **später** (beide Waffen selbst: belegt) |
| `gunBowT3CompoundBow` | Langbogen | Compoundbogen mit Umlenkrollen | **später** (1966) |
| `gunBowT3CompoundCrossbow` | Schwere Armbrust | Compound-Armbrust mit Pistolengriff | **später** |
| `gunBowT1WoodenBow` | Holzbogen | Recurve mit Anbauteilen | plausibel bis später |
| `ammoArrowExploding` | Feuertopfpfeil | Pfeil mit Sprengsatz, Funken | **später** (D87 hat ihn umgedeutet) |
| `bucketEmpty` | Eimer | verzinkter Blecheimer | **später**; Daubeneimer belegt |
| Passend im Bild | Steinwerkzeug, Knochenmesser, Keule, Eisenhammer, Spitzhacken, Schaufel, Klauenhammer, Fackel, Kerze, Primitiver Bogen, Armbrust (`…IronCrossbow`), Kochtopf, Blasebalg, Schmelztiegel | | Armbrust um 700 im Westen kaum belegt — D8 hat „selten" entschieden |

| Stufe | Teile | Symbol und Garnitur | Im Bild |
|---|---|---|---|
| T0 | Lumpenkittel usw. (`armorPrimitive*`) | eigene Symbole | Sackleinen mit Zweigen — passt |
| T1 | Lederwams, Lederkappe, Wickelschuhe, Wollhandschuhe | `armorRogue*` | ärmellose Lederweste, Kapuze mit Gesichtsmaske |
| T2 | Gambeson, Stepphaube, … | `armorAssassin*` | Stoffumhang mit Messern und Taschen, Kapuze mit Schweißerbrille |
| T3 | Kettenhemd, Spangenhelm, Arm- und Beinschienen | `armorRaider*` | Schrottpanzer aus Blechteilen; Helm ein gelochter Blecheimer mit Stacheln |

Beim Suchen nach Ersatz gesehen: `armorSamuraiOutfit` zeigt einen blauen Lamellenpanzer
(Lamellenpanzer um 700 **belegt**, awarisch und langobardisch — die japanische Machart des Modells ist
ungesehen), `armorRangerOutfit` Leder, `armorPreacherOutfit` ein Gewand mit Kreuz. Alle drei sind
DLC- oder Event-Garnituren; F-03:57–60 hat gemessen, dass nur Assassin, Nomad, Raider und Rogue ohne
Kopf-Matrix borgbar sind. Ob die anderen laden, ist **ungeprüft**.

### 4.3 Rohstoffe, Währung, Verbrauch, Schriften, Aufsätze (M3, M11 — gesehen)

| Kennung | Unser Name | Im Bild | Vorhandenes Vanilla-Symbol als Ersatz (gesehen) |
|---|---|---|---|
| `casinoCoin` | Silberpfennig | goldener Jeton, Umschrift „DUKE'S CASINO · NAVEZGANE, ARIZONA" | `resourceSilverNugget` (Silberbrocken) |
| `resourceScrapIron` (auch Symbol von `itm700_luppe`) | Raseneisenerz | Blechplatte, Schrauben, Muttern, Schlüssel | `oreIronBoulder` (Erzbrocken) |
| `resourceForgedIron` (auch `itm700_klinge`, `itm700_schmiedeflicken`) | Schmiedeeisen | Barren mit Prägung „Fe 26" | keiner gefunden |
| `resourceForgedSteel` | Tiegelstahl | geprägter Barren | keiner gefunden |
| `resourceGlue` | Leim | Plastikflasche „TOUGH GLUE" | `resourceAnimalFat` mit Farbton |
| `resourceSewingKit` | Nähzeug | blaue Garnspule mit gelbem Maßband | `resourceYuccaFibers` oder `resourceCloth` |
| `resourceRepairKit` (aufgeschoben) | Reparaturkit | roter Werkzeugkasten | entfällt mit dem Aufschub |
| `resourceLockPick`, `resourceNail`, `toolAnvil` | Dietrich, Nägel, Amboss | Dietrich-Satz, Drahtstifte, Amboss mit Horn | geringfügig |
| `drinkJar*` (7), `foodHoney` | Wasser, Bier, Tees, „Glas Honig" | Einmachglas mit Schraubdeckel (1858: **später**) | keiner; `bucketRiverWater` ist ein Blecheimer |
| `medicalFirstAidBandage` | (Vanilla-Name) | Binde mit Kreuzzeichen (1863: **später**) | `medicalBandage` (Leinenrolle) |
| 85 `book*`, 15 `*SkillMagazine` | Abschriften „Blatt x von y", Lehrblätter | gedruckte Bücher und Hochglanzmagazine, englische Titel, Fotos (Baseballspieler, Soldat, Virus) | `resourcePaper` |
| 20 Belohnungsbündel (13 Symbole) | Werkbündel, Aufsatz-Bündel | Pappkarton mit Aufdruck | `cntWoodWritableCrate` (ungeprüft als Gegenstands-Symbol) |
| `noteDuke01` (Symbol `challengeQuestMaster`) | Pergamentfetzen | linierter Notizzettel „Challenge" mit Häkchen | `resourcePaper` oder `treasureQuestMaster` |
| `modArmorBandolier` | (Vanilla: „Patronengurt-Mod") | Gurt mit Patronen | sperren |
| `modArmorPlatingBasic`, `modArmorStoragePocket`, `modMeleeErgonomicGrip`, `modGunBowArrowRest` | (Vanilla-Namen) | Kunststoff-Knieschoner, Tarnstoff-Tasche, Gummigriff, Kunststoffteil | Einzelentscheid |
| `modDye*` (9) | Färben | Plastikflasche „DYE" (Färben selbst: **belegt**) | Einzelentscheid |
| `biomeWeatherItem1…4` | (Vanilla: „Rauch-, Wüsten-, Schnee-, Strahlungsausrüstung") | Gasmaske · Hut mit Sonnenbrille · Fellmütze mit Skibrille · Gasmaske mit Kapuze | sperren; erreichbar über je eine Auftragsbelohnung |
| `backpackSmall/Medium/Large` | (Vanilla: Rucksack) | moderner Rucksack | Einzelentscheid |
| `ammoDartIron` | (Vanilla: „Eisendart") | Stahlbolzen; Modell unter `Entities/Electrical` | sperren: 2 Rezepte, 1 Beutegruppe, 1 Händlergruppe |

Passend im Bild: Holz, Holzkohle, Lehm, Leder, Stoff, Fasern, Tierfett, Bienenwachs, Silber- und
Goldbrocken, Fleisch, Ei, Schatzkarte, Branntkalk.

### 4.4 Werkstätten und platzierbare Blöcke (M3, M11 — gesehen)

| Kennung | Unser Name | Im Bild | Historisch |
|---|---|---|---|
| `cementMixer` | Kalkofen | orangefarbener Betonmischer auf Rädern | **später**; der Kalkofen selbst: belegt |
| `chemistryStation` | Kräuterküche | Labortisch mit Bildschirm, Fass, Flaschen | **später** |
| `workbench`, `blk700_webstuhl` | Zimmermannsbank, Webstuhl | Werkbank mit Schraubstock, Werkzeugwand, blauen Kisten | **später** |
| `cntChickenCoop` | Hühnerstall | Kinderspielhaus aus buntem Kunststoff | **später**; Hühnerhaltung: belegt |
| `keystoneBlock` | Gebietsschutzblock | Metallkiste mit Warn- und Totenkopfzeichen | **später** |
| `oldChair1VariantHelper` | Alter Stuhl | Stahlrohrstuhl mit Kunststoffsitz | **später** |
| `cntWoodFurnitureBlockVariantHelper2` | Unterschränke | Küchenunterschrank mit Steinplatte | **später** |
| `flagThick44BlockVariantHelper` | (Vanilla: „Thick44-Fahnen") | Fahne mit modernem Logo | **später** |
| `pictureVariantHelper` | Bilder und Gemälde | Leinwandbild, Bison in der Prärie | **später** |
| `glassBlockVariantHelper` | Glasblock | große plane Scheibe | kleine Fensterscheiben in Kirchen um 700 belegt, große plane Scheiben **später** |
| `hayBaleSquare` | Heuballen | gepresster Quaderballen | **später**; Heuschober belegt |
| `lanternOldBlockVariantHelper` | Alte Laterne | Laterne mit Glasscheiben | Hornlaterne plausibel, Glas **später** |
| `toolApiaryExtractor`, `cntApiary` | Honigschleuder, Bienenhaus | Blechtrommel; Bretterkasten auf Stelzen | Schleuder 1865: **später**; Klotzbeute und Korb belegt |
| Passend im Bild | Rennofen und Esse (`forge`), Feuerstelle, Holzfeuer, Palisadenteile, Torhaus-Tor, Spitzpfähle, Feld, Kisten, Standkerze, Schlafrolle, Holzschild, Eisentür | | |

### 4.5 POIs und Straßen (M5, M6)

- **Bestand:** 1 105 POI-Dateien, 606 Teile, 61 Straßenkacheln, 94 Testdateien.
- **Die Testkarte:** 1 590 POI-Platzierungen aus 749 Prefabs. Die häufigsten Namensstämme
  (Platzierungen): `lot_rural_filler` 118 · `farm` 108 · `house_old_ranch` 66 · `house_modern` 57 ·
  `remnant_downtown_filler` 48 · `trailer` 48 · `gas_station` 40 · `remnant_house` 40 · `cabin` 39 ·
  `downtown_filler` 37 · `lot_industrial` 35 · `cave` 27 · `army_camp` 18 · `fastfood` 15 ·
  `store_grocery` 16 · `skyscraper` 8 · Händler 15.
- **Neuzeit-Blöcke je POI der Karte** (verschiedene Prefabs / Platzierungen, von 749 / 1 590):

  | Gruppe | Muster (Auszug) | Prefabs | Platzierungen |
  |---|---|---|---|
  | Fahrzeug | `Sedan`, `PoliceCar`, `Truck`, `cntBus`, `carWrecks`, `CarTire`, `Trailer` | 558 | 1 238 |
  | Schild, Unrat | `sign*`, `Billboard`, `newspaperDecor`, `rubbishDecor`, `garbage_decor` | 694 | 1 442 |
  | Strom, Licht | `streetLight`, `light*`, `tv*`, `Computer`, `conduit`, `airConditioner`, `signNeon` | 643 | 1 365 |
  | Geräte | `Fridge`, `Stove`, `Microwave`, `Toilet`, `Sink`, `Washer` | 612 | 1 292 |
  | Handel | `Vending`, `ATM`, `CashRegister`, `GasPump`, `Mailbox`, `Dumpster` | 555 | 1 200 |
  | Waffenlager | `AmmoPile`, `GunSafe`, `WeaponsBag`, `cntMilitary` | 540 | 1 183 |
  | Industriebaustoff | `terrAsphalt`, `concreteShapes`, `corrugatedMetalShapes`, `steelShapes`, `chainLink` | 703 | 1 466 |
  | **ohne jeden Treffer** | | **23** | **65** |

  Die 23 freien sind 22 leere Landparzellen (`lot_rural_filler_*`) und ein Wildnis-Füller.
- **Alle 1 105 POIs:** 61 ohne Treffer — Erzadern und Felsformen (`deco_*`, `rock_form*`), leere
  Parzellen, fünf Felder (davon drei Maisfelder und ein Kartoffelfeld: **später**), ein Wasserfall, ein
  Galgen, eine Grabstätte (`indian_burial_grounds_01`). **Kein Haus, keine Hütte, keine Höhle mit
  Innenleben.** Die 14 Höhlen-Prefabs der Karte (27 Plätze) haben zwischen 3 und 87 Treffer.
- **An Vorschaubildern gesehen (20 Stück):** `site_grave_01` mit rotem Pritschenwagen,
  `wilderness_filler_01` mit Wohnwagen und Auto, `site_camp_01` mit Nylonzelten, `mine_01` als
  Industrieanlage, `trader_hugh` und `trader_jen` als befestigte Höfe aus Wellblech und Containern.
  Dem Bild nach am ehesten vormodern: `cabin_01` (Blockhaus, aber mit Ziegelkamin und Glasfenstern),
  `barn_01`, `cemetery_01` (gotische Steinkirche: **später**, aber nicht neuzeitlich).
- **Straßen:** 326 Kachel-Platzierungen; `terrAsphalt` steht in 465 der 966 Prefabs.
- **Der Hebel:** `rwgmixer.xml` führt 114 Zeilen `prefab_spawn_adjust` mit `partial_name`, `min_count`,
  `max_count`, `bias`, `biomeTags` (Kommentar rwgmixer.xml:578–579). Unser Modlet `700_60_Welt` hat keine
  `rwgmixer.xml`. Der Hebel wirkt **nur beim Erzeugen einer neuen RWG-Welt**; die Testkarte und
  Navezgane sind fertige Listen (`prefabs.xml`) und bleiben, wie sie sind.

### 4.6 Was beim Plündern und Abbauen geschieht (M7)

| Block | Beuteliste | Gegenstände nach dem Purge | Ernte |
|---|---|---|---|
| `cntSedan01Red` (Auto) | `cars` | 174, darunter Pfeile und Bolzen | 70–180 `resourceScrapIron`, 10–20 Stoff, 3–6 `resourceForgedSteel`; beim Zerstören 5–15 `casinoCoin` |
| `cntPoliceCar01` | `policeCars` | 96 | 35–90 `resourceScrapIron` |
| `cntArmyTruckClosed` | `armyTruck` | 102 | wie Auto |
| `cntAmmoPileSmall` (in 387 Prefabs) | `ammoPileSmall` | 50: Pfeile und Bolzen | — |
| `cntWallSafe`, `cntGunSafe` | `smallSafes`, `gunSafe` | 118, 76 | Eisen |
| `cntATMSecure` (in 47 Prefabs) | `atmLoot` | **0** — ein Geldautomat, der sich öffnen lässt und leer ist | — |
| `cntVendingMachine2` | Händlerklasse `VendingMachine` | verkauft weiter (Händlergruppen `drinkVending`, `foodVending`) | Eisen, Stahl |
| `cntRetroFridgeVer1Closed`, `cntCoolerClosed` | `refrigerator_retro`, `cooler` | 11, 12: Getränke und Eintöpfe | Eisen |
| `cntPostMailbox`, `cntTrashPile01` | `mailboxNoPop`, `junk` | 126, 159: vor allem Abschriften | Pergament |
| `streetLight01`, `airConditioner`, `tvSmallWall2x1` | — | — | Stahl, „Raseneisenerz" |

Die Zahl 585 aus dem Plan (Plan:487: so viele Zeilen in `blocks.xml` geben `resourceScrapIron`) ist die
andere Seite desselben Befunds: die Eisenwirtschaft der Phase 1 **ist** das Zerlegen von Autos und Geräten.

### 4.7 Biom-Dekor und Wetter (M8)

- **Dekor außerhalb von POIs**, je Biom (Zeilen in `biomes.xml`):
  Ödland 48 (`carWrecksRandomHelper` 6, `carsRandomHelper` 2, `cinderBlocks01–03` 12, `mineHubcap` 6,
  `mineCandyTin` 6, `hubcapNoMine` 4, `scrapMetalPile` 4, fünf Fass-Sorten 7, `decoCarTireSmallFlat` 1) ·
  Unterwasser 12 (Wracks 4, Reifen 3, Schlackensteine 2, Radkappe 1, `terrAsphalt` 2) · Wüste 1 Wrack ·
  verbrannter Wald 2 Müllhaufen. Zusammen **63** eindeutige Zeilen, davon 12 Minen.
  Dazu 18 Kaktus-Zeilen in der Wüste (`treeCactus01–06`) und 28 Zeilen `cnt…RandomLootHelper`
  (Wald 6, Schnee 6, Wüste 5, Ödland 5, verbrannt 3, Unterwasser 3), bei denen ungeprüft ist, was
  sie platzieren.
- **Wetter:** je Biom `storm` und `stormbuild` mit `prob="0"` — gesteuert über die Spieloption
  `StormFreq`. Sturm-Buffs: `buffBurnt_Storm` „Aschesturm", `buffDesert_Storm` „Sandsturm",
  `buffSnow_Storm` „Schneesturm", `buffWasteland_Storm` „Radioaktiver Sturm". Drei Partikel-Prefabs
  (`p_smokestorm`, `p_sandstorm`, `p_snowstorm1`). Biom-Gefahren `buff*_Hazard` hängen an
  `required_game_stat="BiomeProgression"`. In der Mod-Sprachdatei: 0 Zeilen dazu.

### 4.8 Luftabwurf und Spieloptionen (M4, M10)

- `supplyPlane`: Klasse `EntitySupplyPlane`, Modell `@:Entities/SupplyPlane/prefabC46.prefab`.
  `sc_General`: Kiste mit Fallschirm, Beuteliste `airDrop`, Klänge `Parachute_Opens`,
  `Supply_Crate_Land`, Kartensymbol `ui_game_symbol_airdrop` (3× in `nav_objects.xml`).
- **Wie oft:** nicht gemessen. Vanillas Voreinstellung ist nach meiner Kenntnis alle 72 Stunden
  (**angenommen**).
- **`sandbox_overrides.xml`** (im Dump, 5 KB, von keinem unserer Modlets berührt) nennt zwei Elemente:
  `<preset name code default="true" …>` — eine benannte Vorlage, die als erste angeboten wird — und
  `<sandbox_override option="…"/>`, das eine Option auf ihren **Standardwert** festsetzt und sperrt.
  Unter den aufgezählten Optionen: `AirDropFrequency`, `AirDropMarker`, `StormFreq`, `BiomeProgression`,
  `TraderDialog` („Toggles the trader voice lines"), `VendingEnabled`, `TradersEnabled`,
  `WorkstationsInTheWild`, `MaxTechType`. Der `code` einer Vorlage wird laut Kommentar aus dem
  Optionsfenster des Spiels kopiert — das kann nur ein Mensch. **Verhalten ungeprüft**, gelesen ist nur
  der Kommentar der Datei.

### 4.9 Oberfläche (M10)

- **Fertigkeiten:** 78 Einträge ohne `hidden="true"`. Symbolnamen, die nach Neuzeit klingen:
  `ui_game_symbol_marksmanship` (5 Zweig-Überschriften), `knunchuck` (4), `run_and_gun`, `grand_slam`,
  `parkour`, `cardio`, `paint_copy_block`, `spatula`. Die Sprites selbst sind ungesehen. Die Mod hat
  bisher fünf Symbole gesetzt (`mod/700_50_Fortschritt/Config/progression.xml:446–471`).
- **Karte und Kompass:** 73 Klassen in `nav_objects.xml`, darunter Symbole für Luftabwurf (3),
  Automat (3), Drohne (3), Generator (2), fünf Fahrzeuge (je 2), Geschützturm (2+2).
- **Buffs:** 178 verschiedene Symbole; `ui_game_symbol_radiation` 13×, `pills` 14×, vier Sturm- und
  vier Gefahren-Symbole je 4×.
- **Menü:** `XUi_Menu\windows.xml` führt `texture="@:Textures/UI/news_logo.png"` (Titelbild, 2×),
  `news_background.jpg` und `<video … uri="/Video/MenuBackground">`. Unser Etikett `700_modName` hängt
  daneben (D85).
- **Ladebilder:** `loadingscreen.xml` nennt `GUI/loading_screen_1` bis `_4`.
- **Figuren-Vorlagen:** 34 in `archetypes.xml`, mit Namen (Clark, Ricky Bobby, Hank …) und Frisuren.

---

## 5. Lücken ohne Plan

**Nichts geplant** — kein Satz in GDD, Feature-Dokument oder Plan:

1. **Luftabwurf** (Flugzeug, Fallschirm, Kiste, Klang, Kartensymbol). Fehlt in GDD 2.3.
2. **Stürme und Strahlung** („Radioaktiver Sturm", Geigerzähler, Strahlung am Kartenrand). D34 („wie
   Vanilla") deckt sie dem Wortlaut nach, ist aber offenkundig nicht für sie gedacht.
3. **Musik** (4 Sektionen, 2 Heim-Stücke, 5 Händler-Themen).
4. **Ladebilder, Titelbild, Menü-Hintergrund.**
5. **Spielerfigur** (Vorlagen, Frisuren, Unterkleid).
6. **Symbole der Kernwirtschaft** (Währung, Erz, Eisen, Stahl, Leim, Nähzeug).
7. **Symbole der Abschriften, Lehrblätter, Bündel und des Pergamentfetzens** (85 + 15 + 20 + 1 = 121
   Kennungen mit zusammen 41 verschiedenen Symbolen).
8. **Trinkgefäß** (Einmachglas in sieben Getränken, im Honig und in der Startausrüstung).
9. **Aufsätze und Biom-Ausrüstung mit Neuzeit-Bild** (Patronengurt, Gasmasken, Färbemittelflasche).
10. **Tiere der Neuen Welt** (Kojote, Berglöwe; Schreckenswolf und Schlange offen).
11. **Dekor in der freien Landschaft** (Wracks, Fässer, Landminen, Kakteen).
12. **Werkstatt-Modelle** für Kalkofen, Kräuterküche, Zimmermannsbank, Hühnerstall, Gebietsschutzblock.
13. **Waffenmodelle** für Bartaxt, Breitaxt, Streitkolben, Streithammer, Eisenfaust, Feuertopfpfeil.
14. **Auftrags-Requisiten und Beutesäcke** (Rally-Fahne, Suchtasche, Beutesack der Seuchentoten).
15. **Fertigkarten und Navezgane:** was gilt für Welten, auf die kein RWG-Filter wirkt?
16. **Der Zwischenzustand der Wracks:** was ein Auto in Phase 1 heißt und hergibt.

**Nur erwähnt** — ein Halbsatz, aber kein Umfang:

17. **Händler-Erscheinung** (F-10: Posten-Typen ja; Modell, Prefab, Stimme, Musik nein).
18. **Wege statt Straßen** (F-07:12 „deaktivieren bzw. ersetzen").
19. **„Eigene Optik" der Seuchennacht** (F-09:28).
20. **Pergament- und Holzoptik der Oberfläche** (F-12:40; F-12:140–143 sagt selbst: nicht gebaut).

**Widersprüchlich:**

21. GDD.md:225 („Gegner, Waffen und POIs sind noch Vanilla-Modelle **mit neuen Namen**") gegen F-06
    (Phase 2) und gegen die Messung: 0 Wesen-Namen in der Sprachdatei. F-12:160 nennt es selbst
    „nicht Phase 1".
22. F-07:36 („**Phase 3:** eigene handgebaute Karte (D4)") gegen D4 (GDD.md:282), GDD.md:219 und
    `docs/features/README.md:49` (Phase 4).
23. F-07:34 („Vanilla-POIs ohne Anachronismen … Höhlen, Hütten, Ruinen") gegen Abschnitt 4.5.
24. F-16:27 („häufigste 6 Zombies") gegen F-06:14 („**jeder** Vanilla-Zombie bekommt eine
    700-Entsprechung"): 34 Modellfamilien. Der Unterschied muss entweder retexturiert oder aus den
    Gruppen genommen werden (F-06:19).

---

## 6. Stückliste für die Asset-Pipeline (F-16)

Grobe Stückzahlen. „Geplant" heißt: steht in F-16:24–29, F-02:167, F-03:105 oder GDD.md:231–235.

| Bereich | Retextur | Neues Modell | Sonstiges | Davon geplant | Stückzahl grob |
|---|---|---|---|---|---|
| Seuchentote | 34 Modellfamilien, je bis zu 3 Stufen-Prefabs (98) | Leitfiguren: Seuchenmönch, gefallener Krieger | — | 6 Familien + Leitfiguren | 34 Retexturen, oder weniger nach Auslese; 2 Meshes |
| Tiere | Schreckenswolf, Schlange, Zombie-Tiere | — | — | „Wildtiere" Prio 3 | 4–6 |
| Waffen, Werkzeug | Keule, Speerschäfte, Holzbogen, Armbrust | Sax, Spatha, Bartaxt, Breitaxt, Streitkolben, Streithammer, Ango, Flügellanze, Langbogen, Schwere Armbrust, Rundschild, Wurfaxt, Faustriemen, Feuertopfpfeil | — | Sax, Spatha, Rundschild, Langbogen, Armbrust, Wurfaxt | 4 Retexturen, 12–14 Modelle |
| Rüstung | T1 Leder, T2 Gambeson | T3 Kettenhemd, Spangenhelm, Schienen | je Geschlecht ein Gear-Prefab (F-03:57) | Kettenhemd, Spangenhelm, Lederrüstung | 3 Garnituren × 4 Teile |
| Werkstätten, Blöcke | Truhen, Schlafrolle | Kalkofen, Kräuterküche, Zimmermannsbank, Webstuhl, Hühnerstall, Bienenkorb, Grenzzeichen statt Gebietsschutzblock, Stuhl bzw. Schemel, Tonkrug | — | Rennofen, Webstuhl, Schrein, Truhen | 8–9 Modelle |
| Baublöcke | Rahmen, Flechtwerk, Fachwerk, Bruchstein, Mörtelstein, Reet, Lehm | — | CC0-Texturen (D84) | Flechtwerk, Lehm, Reet, Bruchstein | 6–7 Texturen |
| Symbole | — | — | 2D-Bilder; bei neuen Modellen fallen sie als Abbild mit ab | Runen, Tränke, Amulette | rund 150: Währung 1, Rohstoffe 8, Gefäße 8, Schriften 13–27, Bündel 13, Aufsätze 38–47, Rüstung 12, Waffen 20, Blöcke 15 |
| POIs | — | — | Prefabs aus dem Editor, keine Unity-Assets (F-07:14) | „mindestens 10" | 30–60 für eine 6k-Karte, dazu Wegekacheln |
| Händler | 5 NPC | 3–5 Posten-Prefabs (Kloster, Markt, Fürstenhof) | Stimmen: 1 336 Zeilen stumm oder neu | — | 5 + 5 |
| Requisiten | Beutesack (4 Farben), fallen gelassenes Bündel | Wegzeichen statt Rally-Fahne, Suchbeutel | — | — | 4 |
| Oberfläche | — | — | 4 Ladebilder, 1 Titelbild, 1 Menü-Hintergrund, 1 Schrift, Rahmen-Sprites, 15–25 Karten- und Fertigkeits-Symbole | — | rund 30 |
| Klang | — | — | wie F-16:31–35 | ja | unverändert |
| Musik | — | — | 11 Stücke bzw. Sektionen | — | Entscheidung zuerst |
| Luftabwurf | — | falls Ersatz gewollt | — | — | 0 oder 1 |
| Fahrzeuge (Phase 3) | — | Handkarren, Wagen, Pferd, Sattel | — | F-13:54 | wie F-13 |

Zwei Fragen an den Durchstich von F-16, die diese Liste scharf macht: (1) geht eine Retextur ohne
Mesh-Duplikat (F-16:14, offen)? Bei 34 Zombie-Familien entscheidet das über Wochen. (2) Wie viele der
150 Symbole lassen sich durch Umbiegen auf Vorhandenes vermeiden (Abschnitt 8, Empfehlung 1)?

---

## 7. Grenzen der Prüfung — wo ein Mensch im Spiel nachsehen muss

Ich habe 152 Symbolbilder und 20 POI-Vorschaubilder angesehen und sonst nur Namen und Zahlen gelesen.

1. **Seuchentote:** eine Stunde im Startbiom bei Tag. Welche Gestalten fallen als neuzeitlich auf,
   welche gehen im Halbdunkel durch? Das entscheidet die Auslese (Empfehlung 4).
2. **Waffen in der Hand:** Bartaxt, Breitaxt, Sax, Spatha, Langbogen, beide Armbrüste in der Ich-Sicht.
   Das Symbol ist gesehen, das Modell in der Hand nicht.
3. **Rüstung am Körper:** alle drei Garnituren in der Außensicht (Prüfliste 6 des Plans steht dafür
   schon).
4. **Werkstätten in der Welt:** Kalkofen, Kräuterküche, Zimmermannsbank, Hühnerstall aufstellen.
5. **Baublöcke:** je eine Wand in den fünf Stufen — wie neuzeitlich wirken Beton und Stahl?
6. **Ladebilder und Hauptmenü:** die vier Ladebilder und das Menü-Video ansehen. Zeigen sie Feuerwaffen
   und Autos?
7. **Luftabwurf:** im Optionsmenü nachlesen, wie `Air Drops` steht; einen Abwurf abwarten oder im
   Debug-Modus auslösen; hören, wie weit der Motor trägt.
8. **Stürme:** einen Sturm im verbrannten Wald oder im Ödland abwarten. Was zeigt der Himmel, was die
   Anzeige?
9. **Kartenrand:** an die Weltgrenze gehen — Geigerzähler und Strahlungs-Symbol.
10. **Musik:** eine Stunde mit Musik auf Standard. Trägt sie Gitarren und Synthesizer, oder geht sie
    als düsterer Klangteppich durch?
11. **Händler:** einen Posten betreten. Lautsprecherdurchsage, Stimme, Themenmusik, Automaten.
12. **Fertigkeiten- und Kartensymbole:** die 78 Einträge durchsehen, dazu die Karte mit einem Auftrag.
13. **Figuren-Auswahl:** den Bildschirm „Neues Profil" ansehen.
14. **Schlange und Schreckenswolf:** je ein Tier suchen. Rassel am Schwanz? Wolf oder Ungeheuer?

Nicht geprüft und auch nicht prüfbar ohne Lauf: ob `sandbox_overrides.xml` eine Vorlage so anbietet,
wie der Kommentar sagt; ob `max_count="0"` in `rwgmixer.xml` gilt; ob ein Modelltausch bei Wesen oder
Werkstätten sauber lädt; ob gestrichenes Biom-Dekor in einem bestehenden Spielstand verschwindet.

---

## 8. Empfehlungen, nach Rang

Der Rang folgt zwei Fragen: wie früh sieht es der Spieler, und wie oft. Alles mit **[zu prüfen]**
braucht eine Entscheidung des Nutzers, bevor irgendetwas gebaut wird.

**Rang 1 — sofort, reines XML, Phase 1 (F-01, F-05, F-12).**

1. **Symbole umbiegen.** `casinoCoin` → `resourceSilverNugget`, `resourceScrapIron` → `oreIronBoulder`,
   `medicalFirstAidBandage` → `medicalBandage`, 100 Abschriften und Lehrblätter → `resourcePaper` mit
   Farbton je Reihe, `noteDuke01` → `resourcePaper`. Das Verfahren steht (D90; `itm700_*` tragen schon
   `CustomIcon`). Es ändert das Bild im Inventar, nicht das Modell in der Hand oder auf dem Boden.
   **[zu prüfen]**: die Zuordnung je Stück im Spiel ansehen; für Eisen, Stahl und das Trinkglas gibt es
   keinen brauchbaren Vanilla-Ersatz — dort bleibt die Lücke bis Phase 2.
2. **Denylist ergänzen** (F-01 ist Phase 1, das ist kein Vorgriff): `modArmorBandolier`,
   `ammoDartIron`, `biomeWeatherItem1`–`4`, `flagThick44*`, `oldChair1*`, `picture*`. Der Prüfbefehl
   meldet sie heute als erlaubt, weil keine Regel sie dem Namen nach trifft — derselbe Fall wie D87.
   **[zu prüfen]**: Färbemittel, Rucksäcke, Glasblock, Laterne, Heuballen einzeln — sperren, umdeuten
   oder stehen lassen.
3. **Dekor der freien Landschaft streichen:** die 63 Zeilen aus Abschnitt 4.7, zuerst die 12
   Minen-Zeilen (Sprengstoff, P1). **[zu prüfen]**: Kakteen jetzt oder mit F-07; die 28 ungeprüften
   `cnt…RandomLootHelper`-Zeilen vorher ansehen.

**Rang 2 — sofort möglich, braucht aber eine Entscheidung zur Phase (D50).**

4. **Seuchentote auslesen.** Die Uniform-Klassen aus den 29 Biomgruppen nehmen, oder ihr Modell auf
   eine unauffällige Gestalt setzen. Beides ist XML, beides zieht F-06 nach Phase 1 vor und ändert die
   Zusammensetzung der Horden. **[zu prüfen]**: (a) F-06 teilweise vorziehen? (b) entfernen oder
   Modell tauschen? (c) was mit den Rollenträgern der Seuchennacht — Polizist (spuckt), Soldat,
   Sprengmeister? Zuerst Punkt 1 aus Abschnitt 7.
5. **Den Widerspruch in GDD.md:225 auflösen** — entweder bekommen die Gegner in Phase 1 Namen (35
   Sprachzeilen, reiner Text), oder der Satz wird berichtigt. **[zu prüfen]**
6. **Eine Spielvorlage „700"** in `sandbox_overrides.xml`: Luftabwurf aus, Stürme aus, Biom-Gefahren
   aus, Händlerstimmen aus, Automaten aus. Sie erledigt K17 und K23 und die halbe K15 ohne ein Asset.
   **[zu prüfen]**: gewollt? Dann muss der Nutzer die Optionen im Spiel einstellen und den Code
   kopieren; dass die Datei tut, was ihr Kommentar sagt, ist ungeprüft. Eine Vorlage ist eine
   Voreinstellung, keine Sperre — wer sie ändert, bekommt das Flugzeug zurück.
7. **Kojote und Berglöwe aus den Gruppen nehmen**, Wolf an ihre Stelle. **[zu prüfen]** (F-06, wie 4).

**Rang 3 — Planlücken schließen, auf dem Papier (keine Umsetzung).**

8. **GDD 2.3 um die fehlenden Zeilen ergänzen:** Luftabwurf, Stürme und Strahlung, Musik, Trinkgefäß,
   Autowracks, Landminen, Beutesäcke, Auftrags-Requisiten, Tiere und Pflanzen der Neuen Welt,
   Händler-Erscheinung. Jede Zeile ist eine Entscheidung „entfällt / wird zu … / bleibt bis Phase n".
   **[zu prüfen]**: jede einzelne — hier ist bewusst nichts vorgeschlagen, was eine neue Idee wäre.
9. **F-07 berichtigen:** Phase 2a liefert keine Gebäude (Abschnitt 4.5). Entweder ist 2a „leere
   Landschaft mit Feldern und Felsen" und 2b beginnt sofort, oder der Filter lässt ausgewählte
   Holzbauten (`cabin`, `barn`) trotz Innenleben zu. Dazu F-07:36 auf Phase 4 berichtigen und sagen,
   was für Fertigkarten gilt. **[zu prüfen]**
10. **F-16 um die Stückliste aus Abschnitt 6 erweitern** und die Reihenfolge nach Sichtbarkeit
    ordnen: Symbole und Trinkgefäß vor Runenstein. **[zu prüfen]**: die Priorität; Runenstein und
    Glutpfeil stehen heute auf Prio 1, weil F-15 sie braucht.
11. **F-10 um einen Abschnitt „Erscheinung" ergänzen** (Posten-Prefab, NPC, Stimme, Musik). **[zu prüfen]**
12. **D34 nachschärfen:** gilt „wie Vanilla" auch für Stürme und Biom-Gefahren? **[zu prüfen]**
13. **Musik entscheiden:** aus, behalten, ersetzen. **[zu prüfen]**, nach Punkt 10 aus Abschnitt 7.

**Rang 4 — Modelltausch bei Werkstätten.**

14. Kalkofen und Kräuterküche auf ein anderes Vanilla-Prefab setzen, wie beim Webstuhl geschehen.
    Kandidaten habe ich nicht gesehen; der Tausch hätte zur Folge, dass noch mehr Werkstätten gleich
    aussehen (F-04:52–55 nennt das schon „verwirrend"). **[zu prüfen]**, eher bis Phase 2 liegen lassen.

---

## 9. Beifang: Textfunde, die bei der Suche auffielen

Nicht Gegenstand dieser Prüfung, aber gemessen (M3: deutscher Name aus Vanilla, **keine** Zeile in
`mod/700_90_Sprache/Config/Localization.csv`) und erreichbar. Für die Textprüfung:

- Alle Wesen: „Krankenschwester", „Polizist", „Soldat", „Geschäftsmann", „Tourist", „Gefahrgutbeauftragter",
  „Laborant", „Zombie-Bär", „Kojote" … (0 von 293 Klassen überschrieben).
- `medicalFirstAidBandage` „Erste-Hilfe-Verband", `medicalBandage` „Verband", `medicalAloeCream`
  „Aloe-Creme" — D56 hatte Wundauflage und Kräutersalbe angekündigt.
- `modArmorBandolier` „Patronengurt-Mod"; `clothing*T3` und `modArmorInsulatedLinerT3` „ThermaCore-…".
- `biomeWeatherItem4` „Strahlungsausrüstung"; `buffWasteland_StormName` „Radioaktiver Sturm".
- `flagThick44BlockVariantHelper` „Thick44-Fahnen"; `bedrollBlockVariantHelper` „Schlafsack";
  `toolApiaryExtractor` „Honigschleuder"; `resourceRepairKit` „Reparaturkit".
- `concreteShapes:VariantHelper` „Betonblock" und `steelShapes:VariantHelper` „Stahl-Block" — so
  gelesen unter genau diesen Schlüsseln; ob das Spiel den Namen der Formen-Auswahl von dort nimmt, ist
  ungeprüft.
- Figuren-Vorlagen in `archetypes.xml` mit Namen der Neuzeit (kein Sprachschlüssel, Name steht im XML).
