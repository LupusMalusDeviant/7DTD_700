# Glossar — die verbindliche Begriffsquelle

Angelegt am 20. November 2026 mit WP8.5 (F-12, D75). Hier steht, **wie ein Ding im Spiel
heißt** — auf Deutsch und auf Englisch (D7). Wer einen Text schreibt, schlägt hier nach und
erfindet nichts daneben.

Das Glossar wird **geprüft**, nicht nur gelesen: `tools/check/glossar-pruefen.ps1` liest
genau diese Datei und vergleicht sie mit `mod/700_90_Sprache/Config/Localization.csv`. Es
läuft in `check-all.ps1` mit.

## 1. Regeln

1. **Erst das Glossar, dann der Text.** Ein Name ändert sich hier zuerst. Stimmt eine Zeile
   der Sprachdatei nicht mit ihrer Glossarzeile überein, ist die Prüfung rot.
2. **Die Kennung bleibt, der Name wechselt** (Umdeutung statt Ersatz). `resourceScrapIron`
   heißt im XML weiter so; der Spieler liest „Raseneisenerz".
3. **Deutsch und Englisch sind Pflicht** (D7), elf weitere Sprachspalten bleiben leer.
4. **Ein neuer Weltbegriff ist eine Entscheidung des Nutzers.** Was unter „Welt" steht,
   kommt aus dem GDD oder aus einer D-Zeile. Fehlt ein englischer Begriff, steht dort
   *offen* — dann wird gefragt, nicht geraten.
5. **Die Ursache der Seuche bleibt offen** (GDD 2.1). Kein Text nennt sie als Tatsache;
   Figuren dürfen etwas glauben.
6. **Namen von Orten und Menschen** folgen D1: erfunden, im Lautbild frühmittelalterlich
   (Orte auf -heim, -feld, -wik, -grad, -dun, -ing), keine realen Orte oder Herrscher.
   Angewandt wird das in WP8.6.

### So liest die Prüfung diese Datei

**Jede Tabelle dieser Datei hat eine von zwei Formen**, erkannt an ihrer Kopfzeile. Eine
Tabelle mit einer anderen Kopfzeile macht die Prüfung rot („nicht prüfbar") — sonst würde
ein Tippfehler in der Kopfzeile eine ganze Tabelle still abschalten. Fließtext ist frei.

- **Festbegriffe** — Kopfzeile `| Kennung | Deutsch | Englisch | Vanilla | Quelle |`.
  Steht in der ersten Spalte eine Kennung in Backticks, muss die Zeile der Sprachdatei mit
  diesem Schlüssel **genau** diesen deutschen und diesen englischen Text tragen. Steht dort
  `—`, gibt es noch keinen Schlüssel (der Begriff gilt trotzdem für jeden Fließtext).
- **Verbotene Begriffe** — Kopfzeile `| Verboten | Sprache | Stattdessen | Quelle |`.
  Die erste Spalte ist ein Muster in Backticks (regulärer Ausdruck, Groß- und
  Kleinschreibung egal). Es darf in keiner Zeile unserer Sprachdatei vorkommen — in der
  deutschen Spalte (`DE`), der englischen (`EN`) oder in beiden (`beide`). Ein Muster
  enthält kein `|`; zwei Schreibweisen sind zwei Zeilen.

## 2. Welt

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Seuchentote (Einzahl: der Seuchentote) | the plague-dead | Zombies | GDD 2.3; EN vom Nutzer am 2026-11-20 |
| — | Seuchennacht | Plague Night | Blood Moon, Horde Night | GDD 2.3; EN vom Nutzer am 2026-11-20 |
| — | Verderbte | *offen* | Feral | GDD 2.3, F-06 (Phase 2) |
| — | Moorleichen | *offen* | Radiated | GDD 2.3, F-06 (Phase 2) |
| — | Wanderhändler, Klostermarkt, Fürstenhof | *offen* | Trader | GDD 2.3, F-10 (Phase 2) |
| — | das Grauen | *offen* | — | F-17 (B3, Phase 2) |
| `casinoCoin` | Silberpfennig | Silver Penny | Jeton aus Dukes Kasino / Duke's Casino Token; als Währung: Dukes | D30, WP4.2 |

## 3. Stoffe

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `resourceScrapIron` | Raseneisenerz | Bog Iron Ore | Eisen / Iron (aus Schrott) | WP4.1 |
| `itm700_luppe` | Luppe | Iron Bloom | — | WP4 |
| `resourceForgedIron` | Schmiedeeisen | Wrought Iron | Geschmiedetes Eisen / Forged Iron | WP4.1 |
| `resourceForgedSteel` | Tiegelstahl | Crucible Steel | Geschmiedeter Stahl / Forged Steel | D55 |
| `resourceScrapBrass` | Buntmetall | Scrap Bronze | Messing / Brass | WP4.1 |
| `resourceScrapLead` | Blei | Lead | Blei / Lead | WP4.1 |
| `resourceCoal` | Holzkohle | Charcoal | Kohle / Coal | WP4 |
| `resourceYuccaFibers` | Nesselfaser | Nettle Fiber | Pflanzenfasern / Plant Fibers | WP4.1 |
| `resourceCropCottonPlant` | Flachs | Flax | Baumwolle / Cotton | WP4.1 |
| `resourceCement` | Branntkalk | Quicklime | Zement / Cement | D63 |
| `resourceConcreteMix` | Mörtel | Mortar | Betonmischung / Concrete Mix | D63 |
| `resourcePaper` | Pergament | Parchment | Papier / Paper | WP7.5 |
| `resourceSewingKit` | Nähzeug | Sewing Kit | Nähset / Sewing Kit | WP5.5 |

## 4. Werkstätten und Feuer

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `campfire` | Feuerstelle | Hearth | Lagerfeuer / Campfire | WP4.3 |
| `workbench` | Zimmermannsbank | Carpenter's Bench | Werkbank / Workbench | GDD 2.3, WP4.3 |
| `forge` | Rennofen und Esse | Bloomery and Forge | Schmiede / Forge | GDD 2.3, WP4.3 |
| `chemistryStation` | Kräuterküche | Herbalist's Kitchen | Chemiestation / Chemistry Station | GDD 2.3, WP4.3 |
| `cementMixer` | Kalkofen | Lime Kiln | Zementmischer / Cement Mixer | GDD 2.3, WP4.3 |
| `blk700_webstuhl` | Webstuhl | Loom | — | D57 |
| `blk700_holzfeuer` | Holzfeuer | Wood Fire | — | D64 |
| `buff700_amfeuerName` | Am Feuer | By the Fire | — | D73 |

## 5. Waffen und Werkzeug

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `meleeWpnBladeT1HuntingKnife` | Sax | Sax | Jagdmesser / Hunting Knife | D58 |
| `meleeWpnBladeT3Machete` | Spatha | Spatha | Machete | D58 |
| `meleeWpnSpearT1IronSpear` | Ango | Ango | Eisenspeer / Iron Spear | WP5.1 |
| `meleeWpnSpearT3SteelSpear` | Flügellanze | Winged Lance | Stahlspeer / Steel Spear | WP5.1 |
| `meleeToolAxeT2SteelAxe` | Bartaxt | Bearded Axe | Stahlaxt / Steel Axe | WP5.1 |
| `meleeToolAxeT1IronFireaxe` | Breitaxt | Broad Axe | Eiserne Feueraxt / Iron Fireaxe | D58 |
| `meleeWpnClubT3SteelClub` | Streitkolben | Mace | Stahlknüppel / Steel Club | WP5.1 |
| `meleeWpnSledgeT3SteelSledgehammer` | Streithammer | War Hammer | Stahlvorschlaghammer / Steel Sledgehammer | WP5.1 |
| `itm700_schleifstein` | Schleifstein | Whetstone | (statt Reparaturkit / Repair Kit) | D60 |
| `itm700_schmiedeflicken` | Schmiedeflicken | Forge Patch | (statt Reparaturkit / Repair Kit) | D60, D62 |
| `meleeToolTorch` | Fackel | Torch | Fackel / Torch | WP6 |

## 6. Rüstung

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `armorT1` | Lumpen | Rags | Primitive Rüstung / Primitive Armor | D59, D61 |
| `armorT2` | Wolle und Leder | Wool and leather | Leichte Rüstungen / Light Armors | D59, D61 |
| `armorT3` | Gambeson | Gambeson | Mittlere Rüstungen / Medium Armors | D59, D61 |
| `armorT4` | Kettenzeug | Mail | Schwere Rüstungen / Heavy Armors | D59, D61 |
| `itm700_gambeson` | Gambeson | Gambeson | — | WP5.5 |
| `itm700_kettenhemd` | Kettenhemd | Mail Shirt | — | WP5.5 |
| `itm700_spangenhelm` | Spangenhelm | Spangenhelm | — | WP5.5 |

## 7. Bauen und Licht

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Fachwerk, Bruchstein, Mörtelstein (Baustufen) | *offen* | Beton, Stahlblöcke | GDD 2.3, D63 |
| `logWallLeft` | Palisadenabschnitt | Palisade Section | Blockwand / Log Wall | WP6 |
| `candle` | Unschlittkerze | Tallow Candle | Kerze / Candle | WP6 |
| `lanternOld_01_Player` | Öllampe | Oil Lamp | Alte Laterne / Old Lantern | WP6 |
| `trapSpikesWoodDmg0` | Spitzpfähle | Sharpened Stakes | Holzstachelfalle / Wood Spikes Trap | WP6 |

## 8. Fortschritt

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `attstrength` | Handwerker | Craftsman | Stärke / Strength | D66, WP7 |
| `attfortitude` | Krieger | Warrior | Standhaftigkeit / Fortitude | D66, WP7 |
| `attagility` | Jäger | Hunter | Beweglichkeit / Agility | D66, WP7 |
| `attintellect` | Heiler | Healer | Intelligenz / Intellect | D66, WP7 |
| `attperception` | Fuhrmann | Carter | Wahrnehmung / Perception | D66, WP7 |
| `buffPerkTheDentistName` | Totenpfennig | Dead Man's Penny | Der Zahnarzt / The Dentist | D77 |
| — | Lehrblatt | Lesson | Magazin / Magazine | D70 |
| — | Blatt (einer Abschrift) | leaf | Buch / Book | D69 |
| — | Abschrift | transcript | Buchreihe | D24, D69 |

### Wörter der Spielmechanik

Gemessen an unseren 603 Zeilen (20. November 2026): das Deutsche kommt ohne ein einziges
englisches Spielwort aus. Das bleibt so.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| — | Stufe | level (einer Fertigkeit), tier (eines Dings), rank (eines Perks) | Level, Stufe, Rang | WP7 |
| — | Fertigkeit | skill | Skill, Perk, Fertigkeit | WP7 |
| — | Ausdauer | stamina | Ausdauer | D73 |

## 9. Verbotene Begriffe

Kein Text von uns benutzt sie. **Das gilt für unsere Zeilen** — die rund 500 sichtbaren
Vanilla-Zeilen, die noch „Zombie" sagen, findet diese Prüfung nicht; sie stehen als
Arbeitsvorrat im Plan (WP8.5).

### Vanillas Welt

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `zombie` | beide | Seuchentote / the plague-dead | GDD 2.3 |
| `blood ?moon` | EN | Plague Night | GDD 2.3 |
| `blutmond` | DE | Seuchennacht | GDD 2.3 |
| `horde night` | EN | Plague Night | GDD 2.3 |
| `hordennacht` | DE | Seuchennacht | GDD 2.3 |
| `navezgane` | beide | (kein Ersatz — Vanillas Land; das Mischland bleibt namenlos, D1) | D1 |
| `\bdukes?\b` | DE | Silber, Silberpfennig; als Person: Fürst | D30 |
| `\bdukes\b` | EN | silver, Silver Penny (ein „duke" als Titel ist erlaubt) | D30 |
| `casino` | beide | Silberpfennig / Silver Penny | D30 |
| `kasino` | DE | Silberpfennig | D30 |
| `radiated` | EN | (EN offen, siehe Welt) | GDD 2.3 |
| `verstrahl` | DE | Moorleichen | GDD 2.3 |

### Umgedeutete Dinge: der alte Name ist nicht mehr der Name

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `campfire` | EN | Hearth | WP4.3 |
| `lagerfeuer` | DE | Feuerstelle (das Holzfeuer ist ein anderes Ding) | WP4.3 |
| `workbench` | EN | Carpenter's Bench | GDD 2.3 |
| `werkbank` | DE | Zimmermannsbank | GDD 2.3 |
| `chemistry station` | EN | Herbalist's Kitchen | GDD 2.3 |
| `chemiestation` | DE | Kräuterküche | GDD 2.3 |
| `cement` | EN | Quicklime, Lime Kiln | D63 |
| `zement` | DE | Branntkalk, Kalkofen | D63 |
| `concrete` | EN | Mortar | D63 |
| `beton(?![teu])` | DE | Mörtel, Bruchstein („betont" und „Betonung" bleiben erlaubt) | D63 |
| `scrap iron` | EN | Bog Iron Ore | WP4.1 |
| `schrott` | DE | Raseneisenerz, Buntmetall | WP4.1 |
| `repair kit` | EN | Whetstone, Forge Patch | D60, D62 |
| `reparaturkit` | DE | Schleifstein, Schmiedeflicken | D60, D62 |
| `magazin` | beide | Lehrblatt / Lesson | D70 |
| `cotton` | EN | Flax | WP4.1 |
| `baumwoll` | DE | Flachs | WP4.1 |
| `yucca` | beide | Nesselfaser / Nettle Fiber | WP4.1 |
| `machete` | beide | Spatha | D58 |
| `fire ?axe` | EN | Broad Axe | D58 |
| `feueraxt` | DE | Breitaxt | D58 |
| `\bpaper` | EN | Parchment | WP7.5 |
| `papier` | DE | Pergament | WP7.5 |
| `hunting knife` | EN | Sax | D58 |
| `jagdmesser` | DE | Sax | D58 |
| `iron spear` | EN | Ango | WP5.1 |
| `eisenspeer` | DE | Ango | WP5.1 |
| `steel spear` | EN | Winged Lance | WP5.1 |
| `stahlspeer` | DE | Flügellanze | WP5.1 |
| `steel axe` | EN | Bearded Axe | WP5.1 |
| `stahlaxt` | DE | Bartaxt | WP5.1 |
| `steel club` | EN | Mace | WP5.1 |
| `stahlknüppel` | DE | Streitkolben | WP5.1 |
| `sledgehammer` | EN | Stone Maul, Iron Maul, War Hammer; die Gattung: hammer | WP5.1 |
| `vorschlaghammer` | DE | Steinhammer, Eisenhammer, Streithammer; die Gattung: Hammer | WP5.1 |
| `forged iron` | EN | Wrought Iron | WP4.1 |
| `\bgeschmiedetes eisen` | DE | Schmiedeeisen („ausgeschmiedetes Eisen" bleibt erlaubt) | WP4.1 |
| `forged steel` | EN | Crucible Steel | D55 |
| `\bgeschmiedeter stahl` | DE | Tiegelstahl | D55 |
| `\bcoal\b` | EN | Charcoal | WP4 |
| `\bkohle\b` | DE | Holzkohle | WP4 |
| `plant fiber` | EN | Nettle Fiber | WP4.1 |
| `pflanzenfaser` | DE | Nesselfaser | WP4.1 |
| `nähset` | DE | Nähzeug | WP5.5 |
| `log wall` | EN | Palisade Section | WP6 |
| `blockwand` | DE | Palisadenabschnitt | WP6 |
| `old lantern` | EN | Oil Lamp | WP6 |
| `alte laterne` | DE | Öllampe | WP6 |
| `spikes trap` | EN | Sharpened Stakes | WP6 |
| `holzstachel` | DE | Spitzpfähle | WP6 |
| `primitive armor` | EN | Rags | D59 |
| `primitive rüstung` | DE | Lumpen | D59 |
| `dentist` | EN | Dead Man's Penny | D77 |
| `zahnarzt` | DE | Totenpfennig | D77 |

**Alte Namen ohne Verbot, mit Grund** (ergänzt am 2026-11-20 nach dem Review, das „Jagdmesser"
als Lücke fand). Nicht jeder Vanilla-Name aus den Tabellen oben lässt sich verbieten:

- *Das Wort ist auch unser Wort oder steckt in unserem Namen:* Eisen / Iron, Forge und
  Schmiede („Bloomery and Forge", „Werkzeugschmiede"), Kerze / Candle, Fackel / Torch,
  Blei / Lead, Sewing Kit.
- *Das Wort ist Alltagssprache:* Messing / Brass (unsere Beschreibung des Buntmetalls nennt
  es), Leichte/Mittlere/Schwere Rüstung, Feral („wild"), Buch / Book, und die fünf
  Attributnamen (Stärke, Standhaftigkeit, Beweglichkeit, Intelligenz, Wahrnehmung).
- *Der englische Ersatz ist noch offen:* Trader.

Wer einen Festbegriff mit einem neuen Vanilla-Namen einträgt, trägt das Verbot dazu ein —
oder den Grund hier.

### Moderne Dinge ohne Entsprechung in Phase 1

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `antibioti` | beide | (Phase 2: Kräuter, Theriak — F-11) | GDD 2.3 |
| `\bpills?\b` | EN | (Phase 2: Tränke, Salben — F-11) | GDD 2.3 |
| `pille` | DE | (Phase 2: Tränke, Salben — F-11) | GDD 2.3 |
| `electri` | EN | (Phase 2: Kraftsteine — F-15) | GDD 2.3 |
| `elektri` | DE | (Phase 2: Kraftsteine — F-15) | GDD 2.3 |
| `\bguns?\b` | EN | Bogen, Schleuder, Wurfspeer, Armbrust | GDD 2.3 |
| `schusswaffe` | DE | Bogen, Schleuder, Wurfspeer, Armbrust | GDD 2.3 |

### Spielerdeutsch

Eine Setzung aus WP8.5, keine Vorgabe aus dem GDD: im Deutschen stehen deutsche Wörter. Im
Englischen sind dieselben Wörter Alltagssprache und darum erlaubt.

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `\blevel` | DE | Stufe | D75 (Setzung) |
| `\bskill` | DE | Fertigkeit | D75 (Setzung) |
| `\bperk` | DE | Fertigkeit | D75 (Setzung) |
| `\bbuff` | DE | Wirkung | D75 (Setzung) |
| `\bloot` | DE | Beute | D75 (Setzung) |
| `\bcraft` | DE | herstellen, fertigen, bauen | D75 (Setzung) |

## 10. Offene Begriffe

Das entscheidet der Nutzer; bis dahin schreibt kein Text sie englisch aus.

1. **Verderbte, Moorleichen** — englisch offen. Gebraucht ab F-06 (Phase 2), aber schon
   jetzt in sieben sichtbaren Wesen-Namen (`zombieSpiderFeral` und Verwandte).
2. **Wanderhändler, Klostermarkt, Fürstenhof** — englisch offen (F-10, Phase 2).
3. **Fachwerk, Bruchstein, Mörtelstein** — die Baustufen haben in Vanilla keinen eigenen
   Sprachschlüssel (`concreteShapes`, `steelShapes` tragen keinen); wo der Name erscheint,
   ist ungemessen.
4. **„Schlagringe"** heißt die Handwerks-Fertigkeit (`craftingKnucklesName`, englisch
   „Knuckles"), die Waffen darunter heißen aber Faustriemen, Eisenfaust und Stahlfaust. Ein
   Schlagring ist kein Ding um 700. Vorschlag: „Faustwehr" / „Fist-gear" — nicht geändert,
   weil ein Name eine Entscheidung ist.
5. **„Scrap Bronze"** für Buntmetall trägt das englische „scrap" weiter. Gemeint ist
   Altmetall aus Ruinen; ob „Old Bronze" besser trifft, ist offen.
6. **„Gebietsschutzblock" / „Land Claim Block"** (`keystoneBlock`) heißt weiter wie in
   Vanilla; nur seine Beschreibung ist umgeschrieben (D77). Vorschlag: „Grenzstein" /
   „Boundary Stone" — nicht geändert, weil ein Name eine Entscheidung ist.
7. **„Totenpfennig" / „Dead Man's Penny"** ist eine Setzung aus D77 für Vanillas „Der
   Zahnarzt" und wartet auf die Abnahme: gemeint ist das Silber oder Gold, das man manchem
   Toten mitgab — der Text sagt nicht, wohin.
