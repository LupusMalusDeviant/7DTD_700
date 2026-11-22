# Konzept — Rüstung und Kleidung

| | |
|---|---|
| **Stand** | 2026-11-22 |
| **Auftrag** | „Arbeite Schwerter und Rüstungen jeweils vom Konzept. Es darf keine Lücken geben, weder in Text noch in Erscheinung." — hier: Rüstung und Kleidung. Waffen stehen in einem eigenen Dokument, Biome in [biome.md](biome.md). |
| **Status** | **Konzept. Gebaut ist nichts**, keine Datei außer dieser ist geändert. Jeder neue Name ist ein Vorschlag (Glossar-Regel 4), jede Entscheidung steht in §5.4 mit **[zu prüfen]**. |
| **Gilt mit** | D59, D61, D62, D87, D90, D91, F-03, F-16, Glossar §6 |

**Wie dieses Dokument Gemessenes von Angenommenem trennt.** Jede Aussage trägt eine von vier Marken:

- **[gemessen]** — aus einer Datei gelesen, Fundstelle steht dabei. Vanilla ist
  `…\7 Days To Die\Data\Config\` (V 3.40 b10), „Dump" ist der gemergte Stand
  `Saves\Pregen06k01\Z\ConfigsDump\` vom 2026-11-22 22:08, „Mod" ist `mod/`.
- **[Wissen]** — historisches Allgemeinwissen des Verfassers, **ohne dass eine Quelle für dieses
  Dokument nachgeschlagen wurde**. Funde und Texte sind aus dem Gedächtnis genannt; vor jeder
  Verwendung im Spiel oder in einer Veröffentlichung nachschlagen. Erfunden ist keine.
- **[nicht gesehen]** — betrifft das Aussehen im Spiel. Gemessen sind Pfade, keine Bilder (F-03).
- **[Vorschlag]** — Setzung dieses Dokuments, wartet auf den Nutzer.

---

## 0. Kurzfassung

1. **Das Sortiment hat drei Schichten, nicht eine** **[gemessen]**: 16 Rüstungsteile (4 Lumpen,
   12 eigene), dazu **12 Stücke Unterkleidung** (`clothing*`, eigene Plätze) und **22 Aufsätze**
   (`modArmor*`). F-03 zählt „sechs erreichbare Rüstungsteile" und meint nur `armor*`.
2. **Die Unterkleidung und die Aufsätze tragen Vanillas Namen** — „ThermaCore-Kampfschicht",
   „KI-betriebene Nervenschnittstelle", „Patronengurt-Mod". 34 erreichbare Stücke, keines
   umbenannt. Das ist die größte Textlücke und bricht F-03s Abnahme „Keine Vanilla-Rüstung mit
   modernem Namen bleibt erhältlich".
3. **Wärme kommt nicht aus unserer Rüstung.** Keines der 16 Rüstungsteile trägt einen Kälte- oder
   Hitzewert; den tragen allein die Unterkleidung und drei Futter-Aufsätze. Die Beschreibung der
   Wollhandschuhe („Warme Hände …") verspricht etwas, das das Teil nicht tut.
4. **Zwei Namen sind Wörter des Hochmittelalters:** *Gambeson* und *Wams* (beide 12./13. Jh.).
   Das zeitnahe Wort für das Kettenhemd wäre *Brünne*.
5. **Der Spangenhelm ist um 700 ein Altstück**, kein Neubau; die Beschreibung nennt ein
   Nasenband, das für den Typ unsicher ist.
6. **Aussehen:** alle zwölf eigenen Teile zeigen im Beutel das Bild der geborgten modernen
   Garnitur (`CustomIcon` = `armorRogue*`, `armorAssassin*`, `armorRaider*`), am Körper deren
   Modell. Im Spiel hat es niemand beurteilt (WP5.7).
7. **Es fehlt der halbe Mensch:** Schild (Hauptschutz der Zeit, F-02 Phase 2), Mantel mit Spange,
   jede Tracht für Frauen, jedes Gesicht je Kulturkreis.

---

## 1. Leitbild

### 1.1 Was Menschen um 700 trugen — Alltag **[Wissen]**

Die Kleidung der Zeit ist über fünf Kulturkreise hinweg im **Schnitt** ähnlich und im
**Zubehör** verschieden. Gemischt wird im Spiel die Herkunft, nicht die Epoche (D1).

**Der Grundbestand, Männer:**

| Stück | Beschreibung | Einordnung |
|---|---|---|
| **Hemd** | Leinen, knie- bis oberschenkellang, auf der Haut | belegt (Textilreste in Gräbern, Moorfunde) |
| **Rock** (Tunika) | Wolle, knielang, lange Ärmel, über den Kopf gezogen, gegürtet | belegt; Moorleiche von Bernuthsfeld (Ostfriesland, 7./8. Jh.) trug einen Kittel aus über 40 Flicken |
| **Hose** | Wolle oder Leinen, lang und eng oder weit | belegt (Bilddarstellungen, ältere Moorfunde wie Thorsberg) |
| **Wadenwickel** | Wollbänder von Knöchel bis Knie, mit Riemen oder Haken gehalten | belegt: Wadenbindengarnituren in merowingerzeitlichen Gräbern |
| **Mantel** | rechteckiges Wolltuch, auf der rechten Schulter mit einer **Spange** geschlossen | belegt; die Spange („Fibel" ist das Wort der Forschung) ist das wichtigste Zeichen der Herkunft |
| **Gürtel** | Leder mit Schnalle, bei Wohlhabenden vielteilig und beschlagen; daran Messer (Sax), Tasche, Feuerzeug | belegt, im 7. Jh. reich |
| **Schuhe** | wendegenähte Lederschuhe, knöchelhoch; daneben einteilige Bundschuhe | belegt |
| **Kopf** | Kappe aus Filz, Wolle oder Leder; Kapuze mit Schulterkragen | dünn belegt; die Kapuze von Orkney (Schottland, Radiokarbon 3.–7. Jh.) ist ein echter Fund dieser Form |
| **Hände** | Fäustlinge und Handschuhe | dünn belegt; Jonas von Bobbio nennt um 640 Handschuhe mit dem Volkswort *wanti* |

**Frauen:** langes Kleid über dem Hemd, gegürtet; Mantel oder Umhang mit einer Scheibenspange auf
der Brust (fränkisch-alamannisch, 7. Jh.); Perlenketten, Gehänge am Gürtel; Kopftuch oder Schleier;
Wadenbinden auch hier. Die ältere Tracht mit zwei Spangen an den Schultern läuft im fränkischen
Raum um 600 aus und lebt im Norden weiter.

**Je Kulturkreis — was den Unterschied macht** (für den Modellbau, §2 verweist hierher):

| Kulturkreis | Erkennungszeichen | Sicherheit |
|---|---|---|
| **fränkisch-romanisch** | vielteilige, silbertauschierte Gürtel; Scheibenspange; Borten an Hals und Saum als Nachleben spätrömischer Zierstreifen; Kreuz als Motiv | gut belegt |
| **germanisch** (alamannisch, bajuwarisch, sächsisch) | Tierstil II — Flechtbänder mit Tierköpfen auf Metall; Pressblech; brettchengewebte Borten | gut belegt |
| **slawisch** | schlicht, wenig Metall an der Kleidung, Leinen und grobe Wolle, gewebte Gürtel, Bast- und Lederschuhe | **unsicher**: die frühe slawische Sachkultur ist arm an Funden; Schläfenringe sind erst später sicher belegt und gehören hier nicht hin |
| **keltisch** (irisch, britisch) | Ringspange (offener Ring mit Dorn; die Tara-Spange datiert um 700), Mantel mit Fransen, Spiral- und Wirbelornament (Buch von Durrow, um 700), gestreifte oder karierte Stoffe | Spange und Ornament gut belegt, Stoffmuster für 700 nur plausibel |
| **nordisch** (Vendelzeit) | Wickelrock mit schräg übereinandergeschlagenen Borten (Pressbleche von Torslunda und Vendel), Tierstil des Nordens, Pelzbesatz, Kammhelm | Bilddarstellungen gut belegt, Stoff selbst kaum erhalten |

### 1.2 Arbeit **[Wissen]**

Arbeitskleidung ist Alltagskleidung in schlechterem Zustand: der Rock hochgegürtet, die Ärmel
aufgekrempelt, Flicken auf Flicken (Bernuthsfeld). Eigene Schutzkleidung des Handwerks ist kaum
belegt — der Lederschurz des Schmieds ist plausibel, nicht gesichert. Für das Spiel heißt das:
**T0 und T1 sind keine Rüstung, sondern Kleidung**, und so sollen sie aussehen.

### 1.3 Kampf **[Wissen]**

1. **Der Schild ist die Rüstung.** Rund, aus Lindenholz- oder Erlenbrettern, mit Rohhaut oder
   Leder bespannt, eiserner Buckel in der Mitte. Fast jeder Bewaffnete trägt einen; er ist
   billig und wird im Gefecht zerschlagen.
2. **Die meisten kämpfen in Wolle.** Rock, Mantel, vielleicht ein dickerer Lederrock. Ein
   fränkisches Recht des 7. Jh. (Lex Ribuaria, Wertliste der Waffen — Zahlen aus dem Gedächtnis:
   Brünne 12 Solidi, Helm 6, Beinbergen 6, Schwert mit Scheide 7, Schild mit Lanze 2) zeigt das
   Gefälle: **eine Brünne ist sechsmal so viel wert wie Schild und Lanze zusammen.**
3. **Der Helm ist selten.** Erhalten sind Stücke aus Fürstengräbern: Spangenhelme vom Typ
   Baldenheim (5. bis frühes 7. Jh.), Lamellenhelme (Niederstotzingen, um 600), die Kammhelme des
   Nordens (Vendel, Valsgärde) und die angelsächsischen Helme (Sutton Hoo um 625, Benty Grange um
   650, Coppergate um 750–775).
4. **Die Brünne ist Herrensache.** Ringpanzerhemden, kurzärmelig, bis über die Hüfte: Sutton Hoo,
   Gammertingen, Vendel. Karl der Große verbietet 779 (Kapitular von Herstal), Brünnen außer
   Landes zu verkaufen — sie sind Staatsgut.
5. **Der Lamellenpanzer ist der Sonderfall.** Eisenlamellen, mit Riemen verschnürt, awarisch
   beeinflusst: Niederstotzingen Grab 12 (um 600–620). Einzelstücke, keine Ausrüstung eines Heeres.
6. **Schienen an Arm und Bein** kennt der Fund von Valsgärde 8 (Schweden, 7. Jh.): Eisenstreifen
   auf Leder. Die Deutung als Arm- und Beinschutz ist verbreitet, nicht unumstritten. Das
   fränkische Recht nennt *bainbergae* — Beinbergen — als eigenes wertvolles Stück.
7. **Was es nicht gibt:** Plattenteile, Topfhelme, Kettenhandschuhe und Kettenbeinlinge
   (Hochmittelalter), beschlagenes „Nietenleder" (eine neuzeitliche Fehldeutung späterer
   Plattenröcke), Vollvisiere.

### 1.4 Was das für das Spiel heißt

**Die Plätze** **[gemessen]** (`EquipSlot` in Vanillas `items.xml`): vier Rüstungsplätze
(`Head`, `Chest`, `Hands`, `Feet`), **vier Plätze für Unterkleidung** (`ClothingHead`,
`ClothingChest`, `ClothingHands`, `ClothingFeet`) und der Platz für die Biom-Ausrüstung
(`BiomeBadge` bis `BiomeBadge4`, siehe [biome.md](biome.md)). Dass die Unterkleidung im
Charakterfenster eigene Felder hat, ist aus den Werten geschlossen, **[nicht gesehen]**.

**Die Stufen** (D61, unverändert): T0 Lumpen · T1 Wolle und Leder · T2 gesteppter Stoff ·
T3 Ringpanzer · T4 ist die Qualitätsspitze von T3.

**Die Übersetzung von Geschichte in vier Plätze:**

| Geschichte | Spiel | Folge |
|---|---|---|
| Der Schild trägt den Schutz | Schild ist F-02, Phase 2 | In Phase 1 hält der Rumpf allein, was historisch Schild **und** Rumpf hielten. Solange der Schild fehlt, ist jede Rüstung „zu gut" erzählt. |
| Helm selten, Brünne Herrensache | T3 ist herstellbar, sobald Rennofen und Esse stehen | Seltenheit entsteht nur über den Preis (D31 „Eisen knapp"). Die Balancing-Tabelle misst: eine volle T3-Garnitur kostet weniger Erz als ein Streithammer — die Reihenfolge der Geschichte ist umgedreht (Balancing 0001 §4). |
| Alltagskleidung wärmt, Rüstung schützt | Wärme sitzt in Vanilla auf der Unterkleidung, Schutz auf der Rüstung | **Passt.** Die Zweiteilung ist historisch richtig — sie muss nur benannt werden (§2.5). |
| Hände und Füße kaum gerüstet | zwei von vier Plätzen | T1/T2 füllen sie mit Kleidung (Handschuh, Schuh), T3 mit dem Einzelfund Valsgärde. Das ist die schwächste Stelle der Glaubwürdigkeit und trotzdem die beste verfügbare. |
| Fünf Kulturkreise | ein Modell je Stufe | Kein Gesicht je Kulturkreis in Phase 1. Phase 2: Zierwechsel über Texturen, nicht über Schnitte (§3). |

### 1.5 Wörter und ihre Zeit **[Wissen]**

Der Maßstab ist nicht „klingt alt", sondern: **Benennt das Wort ein Ding, das es um 700 gab, und
gab es das Wort?** Alltagsdeutsch von heute ist erlaubt; verdächtig ist ein Wort, das ein
**späteres** Ding aufruft. Kein Pseudo-Altdeutsch.

| Wort | Zeitstellung | Urteil |
|---|---|---|
| **Brünne** | ahd. *brunna*, lat. *brunia* in fränkischen Rechts- und Königstexten des 7./8. Jh. | **zeitnah — das richtige Wort für den Ringpanzer** |
| **Kettenhemd** | neuzeitliches Beschreibungswort | verständlich, unauffällig; bleibt möglich |
| **Helm**, **Haube**, **Kappe**, **Hemd**, **Rock**, **Hose**, **Mantel**, **Handschuh**, **Socke**, **Spange**, **Schiene** | alle althochdeutsch belegt | zeitnah |
| **Beinberge** | ahd. *beinberga*, im fränkischen Recht als *bainberga* | zeitnah; das Zeitwort für die Beinschiene |
| **Spangenhelm** | Fachwort der Archäologie (19./20. Jh.) aus zwei alten Wörtern | als Beschreibung tragbar |
| **Gambeson** | altfrz. *gambeson*, 12. Jh. | **später — Wort und Ding gehören ins Hochmittelalter** (§2.3) |
| **Wams** | mhd. *wambeis*, 12./13. Jh., dasselbe Wort wie Gambeson | **später**; ruft Spätmittelalter und Landsknecht auf |
| **Gugel** | Wort alt (ahd. *cugula* aus lat. *cuculla*, die Mönchskapuze); als Kleidungsstück mit langem Zipfel ein Stück des 13.–15. Jh. | **meiden**: der Name ruft das spätere Ding auf. Die Sache selbst — Kapuze mit Schulterkragen — ist zeitnah (Orkney) |
| **Kittel** | mhd., 13. Jh. | später, aber alltäglich und ohne Epochenbild — tragbar |
| **Kapuze** | 16. Jh., aus dem Italienischen | später, aber Alltagswort — tragbar |
| **Fibel** | Fachwort; das Zeitwort ist **Spange** | im Spieltext „Spange" |
| **Fäustling**, **Wadenwickel**, **Steppen** | jünger, beschreibend | tragbar |
| **Lamelle**, **Schuppe** | Schuppe alt, Lamelle Fachwort | „Schuppe" im Spieltext, „Lamelle" nur wo nötig |

### 1.6 Farben und Werkstoffe für den Modellbau **[Wissen]**

| Farbe | Woraus | Wer trägt sie |
|---|---|---|
| Naturweiß, Grau, Braun, Schwarzbraun | ungefärbte Wolle | alle; der Grundton jeder Garnitur |
| Gelb bis Gelbgrün | Färberwau, Birkenlaub | Bauer, Jäger |
| Braun, Rotbraun | Walnussschale, Rinden | alle |
| Ziegelrot bis Krapprot | Krapp | Wohlhabende; kräftiges Rot ist teuer |
| Blau, von Graublau bis Tiefblau | Waid | Wohlhabende; tiefes Blau ist teuer |
| Grün | Waid über Wau | selten, teuer |
| Grauschwarz | Eichengalle mit Eisen | selten |
| Violett | Flechten (Nord- und Westrand) | selten |
| Purpur, Seide | Einfuhr | nur der Herr, und nur als Borte |

**Regeln:** keine reinen, satten Farben; alles leicht vergraut, ausgewaschen, ungleich. Leinen
ist ungefärbt naturgrau bis gebleicht weiß. Leder ist pflanzlich gegerbt: hellbraun bis
rotbraun, nachgedunkelt, **nie schwarz**. Eisen ist grau mit braunem Anflug, nicht blank.
Verschlüsse: Spange, Riemen mit Schnalle, Schnürung, Knebel aus Holz oder Bein — **keine Knöpfe
in Knopflöchern, keine Reißverschlüsse, keine Nieten als Zier.**

---

## 2. Steckbriefe

### 2.0 Der Bestand, gemessen

| Schicht | Kennungen | Zahl | Weg zum Spieler | Name bei uns |
|---|---|---|---|---|
| T0 Lumpen | `armorPrimitiveHelmet/Outfit/Gloves/Boots` | 4 | Rezept (Dump `recipes.xml`:370–422) | umbenannt |
| T1–T3 | `itm700_*` (zwölf) | 12 | nur Rezept; in `loot.xml`, `traders.xml`, `quests.xml` des Dumps kein Treffer | eigen |
| Unterkleidung | `clothing{Head,Outfit,Hands,Feet}T{1,2,3}` | 12 | Beute: `groupAllClothing` in `groupArmorParts02` und `groupLaundry03` (Dump `loot.xml`:1550, 6843); Denylist gibt sie frei (`!clothing*`, Zeile 461) | **Vanilla** |
| Aufsätze | `modArmor*` | 22 | Rezept, Beute, Händler, Auftrag (§4) | **Vanilla** (einer umbenannt, und der ist unerreichbar) |
| Bauteil | `armorParts` | 1 | Beute, Händler | Vanilla „Rüstungsteile" |
| Lehrblatt | `armorSkillMagazine` | 1 | Beute, Händler | „Lehrblatt: Rüstungsbau" |

Alle übrigen der 178 `armor*`-Kennungen sind gesperrt oder weglos (D59). **Gemessen ist außerdem
für alle 16 Rüstungsteile:** kein `HypothermalResist`, kein `HyperthermalResist` (Mod
`700_30_Ausruestung/Config/items.xml`; bei den Lumpen stehen beide Zeilen in Vanilla
auskommentiert, Dump `items.xml`:14153–14154).

**Felder jedes Steckbriefs:** Vorbild und Einordnung · Erscheinung · Stufe und Rolle ·
Vanilla-Basis und was stört · Name · Text · Offen. Die Einordnung lautet **belegt um 700**,
**plausibel** oder **später — Konflikt mit P1**.

---

### 2.1 T0 — Lumpen (`armorPrimitive*`, Prefab `Gear/Fiber/`)

Gemeinsam: leichte Klasse, 8 → 12,3 Schutz, 1–2 Aufsatzplätze, kein Set-Bonus, Reparatur mit
Nähzeug (D62). Rezept je Teil: Nesselfaser 5, Holz 5 (Dump). **Rolle:** was der Spieler am
ersten Tag am Leib hat — der Flüchtling, der Bettler, der Überlebende.
**Vanilla-Basis:** die Faser-Garnitur. Nach Kenntnis der Vorgängerfassungen ein Geflecht aus
Pflanzenfasern und Tuchwickeln, zeitlos genug **[nicht gesehen]**. Stören können: zu
gleichmäßiges „Bastel"-Geflecht statt Tuch, und Holz als Zutat für ein Kleidungsstück.

#### Lumpenkittel — `armorPrimitiveOutfit`
- **Vorbild:** der Flickenkittel von Bernuthsfeld. **Belegt um 700.**
- **Erscheinung:** knielanger Kittel aus groben Woll- und Nesseltuchflicken in fünf, sechs
  Brauntönen, grob überwendlich vernäht, Halsloch ausgefranst, mit einem Strick gegürtet. Darunter
  bloße Unterarme. Verschleiß: Risse, Schlamm am Saum, ein Brandloch.
- **Name:** Lumpenkittel / Rag Tunic (besteht).
- **Text (besteht):** „Grobes Tuch, geflickt, wo es gerissen ist. Es hält den Wind ab und sonst
  nicht viel." / „Coarse cloth, patched where it tore. It keeps the wind out and little else."
- **Offen:** der Satz „hält den Wind ab" stimmt mechanisch nicht — das Teil hat keinen Kältewert.
  Unschädlich, solange niemand ihn als Zahl liest; siehe §5.1 Nr. 3.

#### Lumpenkapuze — `armorPrimitiveHelmet`
- **Vorbild:** Kapuze mit Schulterkragen, Typ Orkney. **Belegt** (Datierung 3.–7. Jh.), als
  Lumpenfassung **plausibel**.
- **Erscheinung:** Kapuze aus zwei, drei Lagen Tuch, kurzer Kragen über den Schultern, unten
  ausgefranst oder mit Fransen (Orkney hat lange Fransen), unter dem Kinn gebunden.
- **Name:** Lumpenkapuze / Rag Hood (besteht). „Lumpengugel" wäre das falsche Wort (§1.5).
- **Text (besteht):** „Eine Kapuze aus mehreren Lagen Tuch. Besser als ein bloßer Kopf, und das
  ist alles." / „A hood of layered cloth. Better than a bare head, and that is the whole of it."
- **Offen:** nichts.

#### Handlappen — `armorPrimitiveGloves`
- **Vorbild:** keins als Fund. **Plausibel** — Tuchstreifen um die Hand wickelt jeder, der
  keine Handschuhe hat.
- **Erscheinung:** schmutzige Tuchstreifen um Handfläche und Handgelenk, Finger frei, Enden
  eingesteckt.
- **Name:** Handlappen / Rag Wraps (besteht).
- **Text (besteht):** „Tuchstreifen um die Hände gewickelt. Sie schonen die Haut, nicht die
  Knochen." / „Strips of cloth wound around the hands. They spare the knuckles, not the bones."
- **Offen:** Deutsch sagt „Haut", Englisch „knuckles" — die beiden Fassungen sind nicht gleich
  gebaut. **[Vorschlag]** Englisch: „They spare the skin, not the bones."

#### Bastschuhe — `armorPrimitiveBoots`
- **Vorbild:** geflochtene Bastschuhe sind im slawischen, baltischen und finnischen Raum bis in
  die Neuzeit getragen worden. **Plausibel**; frühe Funde sind dünn, der Verfasser kennt keinen
  sicher auf 700 datierten.
- **Erscheinung:** aus Lindenbaststreifen diagonal geflochten, flach, mit Bastschnüren um den
  Knöchel gebunden, darunter Fußlappen. Die „Ledersohle" der Beschreibung ist eine Zutat — echte
  Bastschuhe haben meist keine.
- **Name:** Bastschuhe / Bast Shoes (besteht).
- **Text (besteht):** „Geflochtener Bast über einer Ledersohle. Billig, lautlos und mittags
  durchnässt." / „Plaited bast over a leather sole. Cheap, quiet and wet by noon."
- **Offen:** das einzige Stück mit einem klaren Kulturkreis (slawisch) — gewollt oder Zufall?

---

### 2.2 T1 — Wolle und Leder (`itm700_*`, Prefab `Gear/Stealth/`, Bonus `groupNomad` „Wanderkleidung")

Gemeinsam: leichte Klasse, 8 → 12,3 Schutz (**derselbe Wert wie T0**), 2–5 Aufsatzplätze,
von Hand herstellbar, Reparatur mit Nähzeug. **Rolle:** der freie Bauer, der Wanderer, der Jäger.
**Vanilla-Basis:** die „Rogue"-Garnitur (deutsch „Schurken-"). Nach Kenntnis der
Vorgängerfassungen: dunkle Lederjacke mit Kapuze, Halstuch vor dem Gesicht, moderne Hose mit
Taschen, Stiefel **[nicht gesehen]**. Stören werden: Schnitt (Jacke mit Verschluss vorn statt
Rock über den Kopf), Schwarz, Schnallen und Taschen, Stiefel mit Profilsohle. Das Symbol im
Beutel ist `armorRogue*` — das moderne Bild **[gemessen]**.

#### Lederwams — `itm700_lederwams`
- **Vorbild:** ein ärmelloser oder kurzärmeliger Rock aus weichem Leder über dem Wollrock.
  **Plausibel** — Lederkleidung ist für die Zeit kaum erhalten und kaum abgebildet; als Schutz
  für Jäger und Fuhrleute naheliegend, nicht belegt.
- **Erscheinung:** hüft- bis oberschenkellanger Lederrock, hellbraun, über den Kopf gezogen, am
  Hals mit einem Riemen geschlossen, an den Seiten geschnürt. Darunter sichtbar der Wollrock in
  Naturgrau oder Waugelb, knielang; breiter Ledergürtel mit einfacher Eisenschnalle, daran Messer
  und Tasche. Wollfutter am Halsausschnitt sichtbar. Verschleiß: speckige Stellen an Schulter
  und Ellbogen, eine aufgesetzte Flicknaht.
- **Kulturkreis-Zier (Phase 2):** Gürtelschnalle und Riemenzunge wechseln (§1.1).
- **Name:** heute Lederwams / Leather Jerkin. **„Wams" ist ein Wort des 12./13. Jh.**
  **[Vorschlag]** *Lederrock / Leather Coat* — „Rock" ist althochdeutsch und nennt genau dieses
  Stück.
- **Text (besteht, trägt):** „Weiches Leder über wollenem Futter. Was ein Wanderer trägt, der
  keinen Kampf erwartet und doch einen findet." / „Soft leather over a woollen lining. What a
  traveller wears who expects no battle and still meets one."
- **Offen:** der Name (§5.4 Nr. 2).

#### Lederkappe — `itm700_lederkappe`
- **Vorbild:** anliegende Kappe aus Leder oder Filz. **Plausibel**; „gekochtes", also gehärtetes
  Leder als Kopfschutz ist für 700 **nicht belegt**.
- **Erscheinung:** runde Kappe aus vier oder sechs Lederkeilen, Nähte außen wulstig, Ohren halb
  bedeckt, Kinnriemen. Kein Schirm, keine Krempe.
- **Name:** Lederkappe / Leather Cap (besteht; „Kappe" ist althochdeutsch).
- **Text:** heute „Eine anliegende Kappe aus gekochtem Leder. Sie lenkt einen **Streifschuss**
  ab, keinen Schlag." Ein Streifschuss ist das Wort für eine Kugel. **[Vorschlag]** „Eine
  anliegende Kappe aus hartem Leder. Sie lenkt einen Streifhieb ab, keinen Schlag." / „A close
  cap of hardened leather. It turns a glancing cut, not a blow."
- **Offen:** nichts.

#### Wollhandschuhe — `itm700_wollhandschuhe`
- **Vorbild:** Handschuhe sind um 640 schriftlich genannt (Jonas von Bobbio, *wanti*), Funde
  fehlen fast ganz. **Plausibel**, als Fäustling wahrscheinlicher denn als Fingerhandschuh.
- **Erscheinung:** Fäustlinge aus gewalkter Wolle, naturgrau, Daumen angesetzt, Handteller mit
  Leder besetzt, Stulpe bis über das Handgelenk.
- **Name:** Wollhandschuhe / Wool Gloves (besteht). Ein Fäustling ist kein „glove" —
  **[Vorschlag]** Englisch „Wool Mittens", sofern das Modell Fäustlinge zeigt.
- **Text:** heute „Gewalkte Wolle, am Handteller mit Leder. Warme Hände halten einen Schaft besser
  als kalte." / „… Warm hands hold a haft better than cold ones." **Das Teil wärmt gemessen
  nicht.** Der Satz bleibt richtig, wenn er als Lebensweisheit gelesen wird, und falsch, wenn
  der Spieler im Schnee steht. §5.1 Nr. 3.
- **Offen:** Wärme.

#### Wickelschuhe — `itm700_wickelschuhe`
- **Vorbild:** Wendeschuh plus Wadenwickel. **Belegt um 700**, beides.
- **Erscheinung:** knöchelhoher Lederschuh, einteiliges Oberleder, seitlich oder vorn mit einem
  Riemen geschlossen, flache Sohle ohne Absatz. Darüber Wollbänder (nicht Leinen) in Fischgrat-
  oder Köperbindung von Knöchel bis unters Knie, oben mit Riemen oder Bronzehaken gehalten —
  der Haken ist das Schmuckstück und wechselt je Kulturkreis.
- **Name:** Wickelschuhe / Wrapped Shoes (besteht).
- **Text:** heute „Lederschuhe mit **Leinen** bis zum Knie gewickelt. …" Wadenwickel sind in den
  Funden Wolle. **[Vorschlag]** „Lederschuhe, mit Wollbändern bis zum Knie gewickelt. Bleiben
  länger trocken als Bast und sind leiser als Eisen." / „Leather shoes with woollen bands wound
  to the knee. Dry longer than bast and quieter than iron."
- **Offen:** nichts.

---

### 2.3 T2 — gesteppter Stoff (`itm700_*`, Prefab `Gear/Assassin/`, Bonus `groupAssassin` „Gesteppte Tracht")

Gemeinsam: mittlere Klasse, 13 → 17,3 Schutz, −5 % Beweglichkeit, am Webstuhl herstellbar
(Steppbahn), Reparatur mit Nähzeug. **Rolle:** der Gefolgsmann ohne Eisen.
**Vanilla-Basis:** die „Assassin"-Garnitur. Nach Kenntnis der Vorgängerfassungen: schwarze,
eng anliegende Kleidung mit Kapuze und Gesichtsmaske **[nicht gesehen]**. Stören werden: Schwarz
(§1.6), Maske, der schmale Schnitt — ein gesteppter Rock ist das Gegenteil von eng: dick,
wulstig, steif. Symbol im Beutel: `armorAssassin*` **[gemessen]**.

**Der Streitfall dieser Stufe, ehrlich:** Gesteppte Textilrüstung als **eigenständiges** Stück
ist in Europa ab dem 12. Jh. belegt, mit dem Wort Gambeson. Für 700 gibt es **keinen Fund und
kein Bild.** Belegt ist etwas Benachbartes: ein gepolstertes Kleid **unter** der Rüstung — die
spätantike Schrift *De rebus bellicis* (4./5. Jh.) beschreibt es als *thoracomachus* —, und ohne
Polster trägt niemand ein Ringhemd. Einordnung: **die Sache plausibel, das Wort später —
Konflikt mit P1 beim Namen, nicht beim Ding.** P1 selbst sagt „plausibel vor belegt"; die Stufe
ist damit haltbar, der Name nicht.

#### Gambeson — `itm700_gambeson`
- **Vorbild:** siehe oben. **Plausibel**, als eigenes Rüststück **später**.
- **Erscheinung:** knielanger Rock aus zwei Lagen grobem Leinen oder Wolle, dazwischen Werg, in
  senkrechten Bahnen von zwei Fingern Breite durchgenäht; dadurch wulstig. Über den Kopf gezogen,
  am Hals seitlich geschlitzt und mit Knebel oder Riemen geschlossen; Ärmel bis zum Ellbogen oder
  Handgelenk, unter der Achsel offen. Farbe ungefärbt grauweiß bis hellbraun, am Saum und Hals
  eine Lederkante. Breiter Gürtel. Verschleiß: aufgeplatzte Naht, aus der Werg quillt;
  Schweißränder; ein alter, dunkel vernähter Schnitt.
- **Name:** heute Gambeson / Gambeson (Glossar §6, fest). **[Vorschlag]** *Polsterrock / Padded
  Coat* — beide Wortteile sind althochdeutsch, das Wort ruft keine Epoche auf. Die Stufe hieße
  dann „Polsterzeug" statt „Gambeson" (`armorT3`). Gegenargument: „Gambeson" versteht jeder
  Spieler sofort.
- **Text (besteht, trägt):** „Zwei Lagen Tuch mit Werg dazwischen, in engen Reihen durchnäht. Er
  erstickt einen Schlag, wie Wasser ein Feuer erstickt." / „Two layers of cloth with tow between
  them, stitched in close rows. It smothers a blow the way water smothers fire."
- **Offen:** der Name (§5.4 Nr. 1).

#### Stepphaube — `itm700_stepphaube`
- **Vorbild:** gepolsterte Haube unter dem Helm. **Plausibel** (jeder Helm braucht ein Futter);
  als eigenes Stück nicht belegt.
- **Erscheinung:** eng anliegende gesteppte Haube, Ohren und Nacken bedeckt, unter dem Kinn
  gebunden, Steppnähte strahlenförmig vom Scheitel. Ungefärbt. **Das Gesicht bleibt frei** — keine
  Maske.
- **Name:** Stepphaube / Quilted Coif (besteht; „Haube" althochdeutsch, „coif" im Englischen
  hochmittelalterlich, aber unauffällig).
- **Text (besteht, trägt):** „Eine gesteppte Haube, unter dem Kinn gebunden. Für sich getragen,
  oder unter Eisen, wo sie hingehört." / „A quilted coif, tied under the chin. Worn alone, or
  under iron where it belongs."
- **Offen:** der Text sagt „unter Eisen" — im Spiel belegt die Haube den Kopfplatz und schließt
  den Helm aus. Unschädlich, aber ein Spieler wird es versuchen.

#### Stepphandschuhe — `itm700_stepphandschuhe`
- **Vorbild:** keins. **Plausibel** als Fäustling mit Polster.
- **Erscheinung:** dicke gesteppte Fäustlinge, Handrücken mit einer Lederlasche („Lederschlag")
  gedeckt, lange Stulpe.
- **Name:** Stepphandschuhe / Quilted Mittens (besteht; Deutsch „-handschuhe", Englisch
  „Mittens", Text „Fäustlinge" — **[Vorschlag]** Deutsch „Steppfäustlinge", damit Name und Text
  dasselbe sagen).
- **Text (besteht, trägt):** „Dicke gesteppte Fäustlinge mit Lederschlag. Unbeholfen — und sie
  haben mehr Finger gerettet als alles Geschick." / „Thick quilted mittens with a leather face.
  Clumsy, and they have kept more fingers than skill has."
- **Offen:** nichts.

#### Steppschuhe — `itm700_steppschuhe`
- **Vorbild:** keins. **Plausibel** als gefütterter Winterschuh; als Rüststück eine Erfindung
  für den vierten Platz.
- **Erscheinung:** knöchelhoher Lederschuh mit gestepptem Schaft bis zur halben Wade, doppelte
  Sohle, mit Riemen umwickelt.
- **Name:** Steppschuhe / Quilted Shoes (besteht).
- **Text (besteht):** „Gesteppte Schäfte auf doppelter Sohle. Sie treten leise und nehmen dem
  Boden die Kälte." / „… take the cold out of the ground." Wie bei den Wollhandschuhen: Kälte
  ist versprochen, nicht gebaut.
- **Offen:** Wärme.

---

### 2.4 T3 — Ringpanzer und Eisen (`itm700_*`, Prefab `Gear/Raider/`, Bonus `groupRaider` „Kettengewand")

Gemeinsam: schwere Klasse, 18 → 21 Schutz, −7,5 % Beweglichkeit, +20 % Lärm, an der Esse mit
Amboss, Reparatur mit Schmiedeflicken. **Rolle:** der Herr und sein bester Mann.
**Vanilla-Basis:** die „Raider"-Garnitur. Nach Kenntnis der Vorgängerfassungen: Schrottpanzer
aus Blech, Reifenstücken und Polstern mit Stacheln, Helm als geschweißte Maske **[nicht
gesehen]**. Das ist der härteste Bruch des Sortiments: Stacheln, Blechplatten und eine
Vollmaske sind genau die drei Dinge, die §1.3 Nr. 7 ausschließt. F-16 sieht für diese Stufe
neue Modelle vor — zu Recht. Symbol im Beutel: `armorRaider*` **[gemessen]**.

#### Kettenhemd — `itm700_kettenhemd`
- **Vorbild:** Ringpanzerhemden aus Sutton Hoo, Gammertingen, Vendel. **Belegt um 700**, als
  Besitz der Oberschicht.
- **Erscheinung:** Hemd aus Eisenringen von etwa einem Fingerglied Durchmesser, je vier in einem;
  Reihen abwechselnd genietet und geschlossen. Kurze Ärmel bis zum halben Oberarm, Länge bis zum
  halben Oberschenkel, **kein Kragen, keine Kapuze aus Ringen**, Halsausschnitt mit Schlitz.
  Darunter schaut der Polsterrock an Ärmeln und Saum hervor. Gürtel rafft das Gewicht auf die
  Hüfte. Farbe dunkelgrau, an den Reibstellen heller, in den Falten Rostbraun. T4 (Qualität 5–6)
  könnte eine Zierreihe aus Buntmetallringen an Saum und Ärmeln tragen — das wäre der sichtbare
  Unterschied, den D61 offenlässt.
- **Name:** heute Kettenhemd / Mail Shirt (Glossar §6, fest). **[Vorschlag]** *Brünne / Byrnie* —
  das Wort der Zeit, im Deutschen wie im Englischen. Die Stufe (`armorT4`, heute „Kettenzeug /
  Mail") hieße „Brünne / Mail" oder bliebe.
- **Text (besteht, trägt):** „Tausende genietete Ringe über einem gepolsterten Hemd. Es fängt den
  Schnitt und lässt das Gewicht durch — und man hört es, lange bevor man es sieht." /
  „Thousands of riveted rings over a padded shirt. …"
- **Offen:** der Name (§5.4 Nr. 3); das T4-Erkennungszeichen.

#### Spangenhelm — `itm700_spangenhelm`
- **Vorbild:** Spangenhelme vom Typ Baldenheim: vier oder sechs Eisenplatten in einem Gerüst
  aus vergoldeten Bronzespangen, Stirnreif, Wangenklappen, Nackenschutz aus Ringgeflecht.
  **Belegt bis ins frühe 7. Jh. — um 700 ein Altstück**, das ein Herr geerbt haben kann.
  Zeitnäher wären der Lamellenhelm (Niederstotzingen), der Bandhelm oder der Kammhelm des
  Nordens (Vendel, Valsgärde) und der angelsächsische Typ Coppergate.
- **Erscheinung:** konische Kalotte aus vier Eisenplatten, darüber vier sich im Scheitel
  kreuzende Spangen; Stirnreif mit Pressblechzier; zwei bewegliche Wangenklappen an Scharnieren,
  unter dem Kinn gebunden; im Nacken ein handbreiter Behang aus Ringen. **Kein Visier, kein
  Topf, keine Hörner.** Beim Typ Baldenheim ist ein Nasenschutz unsicher; sicher ist er beim
  späteren Coppergate-Helm. Farbe: Eisen grau, Spangen aus Buntmetall stumpfgolden.
- **Kulturkreis-Zier (Phase 2):** der Helm ist das Stück, an dem der Kulturkreis am besten
  sichtbar wird: Eberfigur auf dem Scheitel (angelsächsisch, Benty Grange), Kamm mit
  Pressblechen (nordisch), Lamellen mit Rosshaarbusch (östlich).
- **Name:** Spangenhelm / Spangenhelm (besteht, Glossar §6).
- **Text:** heute „Eisenplatten in einem Spangengerüst, mit **Nasenband** und Wangenklappen. …"
  **[Vorschlag]** „Eisenplatten in einem Spangengerüst, mit Wangenklappen und einem Behang aus
  Ringen im Nacken. Das stolzeste Stück des Schmieds und die schwerste Stunde seiner Woche." /
  „Iron plates held in a banded frame, with cheek guards and a curtain of rings at the neck. The
  smith's proudest piece and the heaviest hour of his week."
- **Offen:** Altstück oder zeitnaher Typ (§5.4 Nr. 4). Und: „die schwerste Stunde seiner Woche"
  untertreibt — ein solcher Helm ist Wochenarbeit; ein Stilurteil, kein Fehler.

#### Armschienen — `itm700_armschienen`
- **Vorbild:** die Eisenschienen aus Valsgärde 8. **Belegt** als Einzelfund eines Fürstengrabs,
  Deutung verbreitet, nicht unumstritten. Für alle anderen Kulturkreise **plausibel**.
- **Erscheinung:** sechs bis acht schmale Eisenstreifen, längs auf einen Lederärmel genietet, vom
  Handgelenk bis zum Ellbogen, innen geschnürt. Die Hand selbst steckt in einem Lederfäustling
  oder bleibt frei — **keine Eisenfinger.** (Die Niete ist hier Befestigung, kein Schmuck.)
- **Name:** Armschienen / Splinted Bracers (besteht; „Schiene" althochdeutsch).
- **Text (besteht, trägt):** „Eisenstreifen auf Leder genietet, von Handgelenk bis Ellbogen
  geschnürt. Der Arm, der pariert, ist der Arm, der getroffen wird." / „Iron splints riveted
  onto leather, laced from wrist to elbow. The arm that parries is the arm that is struck."
- **Offen:** nichts.

#### Beinschienen — `itm700_beinschienen`
- **Vorbild:** Valsgärde 8 wie oben; dazu die *bainbergae* des fränkischen Rechts — das Stück
  ist als Begriff **belegt um 700**, sein Aussehen im Frankenreich nicht.
- **Erscheinung:** Eisenstreifen längs auf Leder, vom Knöchel bis unters Knie, über dem
  Wickelschuh mit zwei Riemen geschnallt; die Wade hinten offen oder nur mit Leder gedeckt.
- **Name:** Beinschienen / Splinted Greaves (besteht). **[Vorschlag, nachrangig]** *Beinbergen /
  Greaves* ist das Wort der Zeit — schöner, aber erklärungsbedürftig.
- **Text:** heute „Schienen über dem Schuh. Schwer auf dem Marsch, billig in dem Augenblick, in
  dem eine Klinge tief kommt." / „Splinted greaves over the boot. …" — „boot" ist ein Stiefel;
  es gibt keinen. **[Vorschlag]** Englisch: „Splinted greaves over the shoe. …"
- **Offen:** nichts.

---

### 2.5 Unterkleidung — `clothing*` (zwölf Stücke, vier eigene Plätze)

**Gemessen** (Vanilla `items.xml`:18683–18860, `buffs.xml`:757–806): je Platz drei Stufen;
jedes Stück gibt Kälte- **und** Hitzewiderstand (T1 1 → 2,5 · T2 2,8 → 4,3 · T3 4,6 → 6,
Qualität 1 → 6) und verlängert die erste Stufe eines Sturms (je Stück 15 · 22,5 · 30 Sekunden,
[biome.md](biome.md) §1.5). Keine Aufsatzplätze, kein Modell am Körper (`Meshfile` ist ein
Sack), kein Schutz gegen Hiebe. Eine Beschreibung je Stufe, nicht je Stück (`clothingT1Desc`
bis `clothingT3Desc`). Weg: nur Beute.

**Vanillas Namen heute im Spiel:** „Zerfledderte Socken", „Patchwork-Mützenfutter", „Lange
Patchwork-Unterwäsche", „ThermaCore-Handschuhfutter", „ThermaCore-Kampfschicht" / „ThermaCore
Combat Layer"; T3-Text: „Diese Unterwäsche aus fortschrittlichen Thermofasern …".

- **Vorbild:** Leinenhemd auf der Haut, Fußlappen, Unterhaube. **Belegt um 700** — das ist die
  Kleidungsschicht, die es wirklich gab und die im Sortiment sonst fehlt.
- **Rolle:** die Wärmeschicht. Sie löst F-03s Ziel „Kleidung schützt vor Kälte" ein, ohne dass
  eine Zahl erfunden werden muss — Vanilla hat die Zahlen schon.
- **Erscheinung:** nur Symbole (kein Modell am Körper). T1 grau, ausgefranst; T2 gebleichtes
  Leinen mit Flicken; T3 dichte gewalkte Wolle, naturweiß.

**Namen [Vorschlag]** — Stufe als Zustand und Werkstoff, Stück als Zeitwort:

| Kennung | Deutsch | Englisch |
|---|---|---|
| `clothingHeadT1` | Zerschlissene Unterhaube | Threadbare Under-cap |
| `clothingHeadT2` | Leinene Unterhaube | Linen Under-cap |
| `clothingHeadT3` | Gewalkte Unterhaube | Fulled Under-cap |
| `clothingOutfitT1` | Zerschlissenes Hemd | Threadbare Shirt |
| `clothingOutfitT2` | Leinenhemd | Linen Shirt |
| `clothingOutfitT3` | Gewalktes Wollhemd | Fulled Wool Shirt |
| `clothingHandsT1` | Zerschlissene Unterhandschuhe | Threadbare Under-gloves |
| `clothingHandsT2` | Leinene Unterhandschuhe | Linen Under-gloves |
| `clothingHandsT3` | Gewalkte Unterhandschuhe | Fulled Under-gloves |
| `clothingFeetT1` | Zerschlissene Fußlappen | Threadbare Foot-wraps |
| `clothingFeetT2` | Leinene Fußlappen | Linen Foot-wraps |
| `clothingFeetT3` | Gewalkte Socken | Fulled Socks |

**Texte [Vorschlag]** (die Sekunden sind Vanillas Zahlen, nicht neu):

- `clothingT1Desc` — „Was vom Hemd eines anderen übrig ist. Auf der Haut getragen, unter allem
  anderen.\n\nHält Hitze und Kälte ein wenig ab und lässt dich im Sturm 15 Sekunden länger
  stehen." / „What is left of another man's shirt. Worn on the skin, beneath everything
  else.\n\nKeeps off a little heat and cold and lets you stand 15 seconds longer in a storm."
- `clothingT2Desc` — „Gebleichtes Leinen, sauber gesäumt. Es nimmt den Schweiß und hält die Wolle
  von der Haut.\n\nHält Hitze und Kälte ab und lässt dich im Sturm 22,5 Sekunden länger stehen." /
  „Bleached linen, cleanly hemmed. It takes the sweat and keeps the wool off the skin.\n\nKeeps
  off heat and cold and lets you stand 22.5 seconds longer in a storm."
- `clothingT3Desc` — „Dichte Wolle, gewalkt, bis kein Wind mehr durchgeht. Wer so etwas unter dem
  Rock trägt, hat einen Winter vorausgedacht.\n\nHält Hitze und Kälte gut ab und lässt dich im
  Sturm 30 Sekunden länger stehen." / „Dense wool, fulled until no wind gets through. Whoever
  wears this beneath the coat has thought a winter ahead.\n\nKeeps off heat and cold well and
  lets you stand 30 seconds longer in a storm."

- **Offen:** (a) Wolle, die gegen **Hitze** hilft, ist eine Eigenheit von Vanillas Zahlen; der
  Text sagt es und erklärt es nicht. (b) Ein Rezept gibt es nicht — Leinen und Wolle findet man
  nur in Truhen. In einer Welt mit Webstuhl ist das ein Widerspruch (§5.2). (c) Ob die Symbole
  (`CustomIcon` = `clothingHeadT1` usw.) modern aussehen, ist **[nicht gesehen]**.

---

### 2.6 Zubehör

| Kennung | Heute | Befund | Vorschlag |
|---|---|---|---|
| `armorParts` | „Rüstungsteile / Armor Parts", Beschreibung ist Vanillas `gunPartsGroupDesc` („Zerlege fortgeschrittene Waffen …") | **erreichbar und nutzlos** **[gemessen]**: Beute und Händler führen es, **kein Rezept** des Dumps nennt es als Zutat (0 Treffer) | umdeuten und einbinden („Ringe und Schuppen" als Zutat für T3 oder die Besatz-Aufsätze) — oder sperren. Beides ist eine Entscheidung (§5.4 Nr. 9) |
| `armorSkillMagazine` | „Lehrblatt: Rüstungsbau" | in Ordnung (D70) | — |
| `itm700_steppbahn` | „Steppbahn / Quilted Panel" | in Ordnung | folgt dem Namen der Stufe, falls „Gambeson" fällt: der Text sagt „Vier davon machen einen Gambeson" |
| `resourceSewingKit` | „Nähzeug" | in Ordnung; der „Fingerhut aus Horn" ist plausibel, nicht belegt | — |

---

## 3. Garnituren

### 3.1 Was es geben soll **[Vorschlag]**

Vier Stände, und jeder muss in jedem der fünf Kulturkreise ein Gesicht haben können:

| Stand | Wer | Kopf | Rumpf | Hände | Füße | Dazu (kein Platz heute) |
|---|---|---|---|---|---|---|
| **Flüchtling** (T0) | wer alles verloren hat | Lumpenkapuze | Lumpenkittel | Handlappen | Bastschuhe | Strick als Gürtel |
| **Bauer / Wanderer** (T1) | der Freie auf dem Hof, der Fuhrmann | Kappe | Rock, Lederrock darüber | Fäustlinge | Wendeschuh, Wadenwickel | Mantel mit Spange, Gürtel mit Messer |
| **Jäger** (T1, zweite Fassung) | wer vom Wald lebt | Kapuze mit Schulterkragen | kurzer Rock in Wald- und Erdtönen | Armschutz des Bogenschützen | weiche Schuhe | Köcher |
| **Gefolgsmann** (T2) | der Bewaffnete im Dienst eines Herrn | gepolsterte Haube | Polsterrock | Polsterfäustlinge | gefütterte Schuhe | **Schild**, Speer, Sax |
| **Herr** (T3, T4) | wer Eisen besitzt | Helm | Brünne über Polsterrock | Armschienen | Beinbergen | Schild, Schwert, Mantel mit reicher Spange |

### 3.2 Deckt das heutige Sortiment sie ab?

| Garnitur | Abgedeckt? | Befund |
|---|---|---|
| Flüchtling | **ja** | vier Teile, vier Namen, vier Texte. Kein Set-Bonus (Vanilla hat keinen, F-03). |
| Bauer / Wanderer | **ja**, als „Wanderkleidung" | vier Teile. Der Bonus (weniger Nahrung und Wasser je Ausdauerpunkt) passt zum Wanderer. Schutzwert gleich T0 — der Aufstieg ist nur über den Bonus und die Aufsatzplätze spürbar. |
| Jäger | **nein** | kein eigenes Teil. Der Schleich-Bonus, der zum Jäger gehörte, sitzt auf dem **Polsterrock** (`groupAssassin`, „schneller verborgen") — erzählt als „gestepptes Tuch ist leise". Das trägt, aber der Jäger, der schleichen will, muss sich dafür als Gefolgsmann kleiden. |
| Gefolgsmann | **ja**, als „Gesteppte Tracht" | vier Teile. |
| Herr | **ja**, als „Kettengewand" | vier Teile. T4 ist dieselbe Garnitur in Qualität 5–6 und sieht gleich aus. |
| Mönch, Frau, Händler, Kind | **nein** | kein Stück. Die Mönchskutte wäre das Gesicht des Klosterlands. |

### 3.3 Was fehlt

1. **Der Schild.** Ohne ihn ist keine der drei Kampf-Garnituren vollständig (F-02, Phase 2).
2. **Der Mantel mit Spange.** Das Kleidungsstück, das die Zeit am deutlichsten zeigt, hat keinen
   Platz. Wege: als Teil des Rumpf-Modells jeder Garnitur (Phase 2, kostet nichts an Mechanik) —
   oder als kosmetisches Stück, falls V 3.40 einen Platz dafür hat (**ungemessen**).
3. **Je Kulturkreis ein Gesicht.** Machbar ohne neue Schnitte: Spange, Gürtelschnalle, Borte
   und Helmzier wechseln (§1.1). Das sind Texturvarianten derselben vier Prefabs. Offen ist, wie
   der Spieler die Variante wählt — eigener Gegenstand je Kulturkreis (5 × 16 Kennungen) oder ein
   Aufsatz „Zier" (§4.3). **Ungemessen**, ob ein Aufsatz das Aussehen eines Rüstungsteils
   ändern kann; Vanillas auskommentierte Hut-Aufsätze (`modArmorBallCap` und Verwandte: „lässt
   jeden Helm wie … aussehen") deuten darauf, dass es einmal ging.
4. **Die Frau.** Jeder Prefab-Pfad trägt `{sex}` — es gibt je Garnitur zwei Modelle. Ob das
   weibliche Modell derselben Garnitur ein Kleid sein darf (langer Rock statt Hose), ist eine
   Frage an F-16.
5. **Ein Jäger-Satz**, falls gewollt: vier weitere Teile in der leichten Klasse mit eigenem
   Bonus. Das ist neuer Inhalt, nicht Umdeutung.

---

## 4. Aufsätze (`modArmor*`)

### 4.1 Bestand, gemessen

Vanillas `item_modifiers.xml` definiert 26 aktive `modArmor*` (zwei weitere auskommentiert:
`modArmorInsulatedLiner`, `modArmorCoolingMesh`). Der Purge nimmt vieren die Wege (Helmlicht,
Zigarre, Nachtsicht, Wasserreiniger); `modArmorJumpJets` und der Entwickler-Aufsatz haben keinen
Weg. **Erreichbar sind 22** (Dump: Rezept / Beute / Händler / Auftrag gezählt). Unsere
Sprachdatei überschreibt **genau einen** — `modArmorCoolingMesh` → „Leinenfutter" (D91) —, und
der ist auskommentiert, also für niemanden erreichbar (D87 sagt das selbst).

### 4.2 Was sie heute heißen, was sie sind **[Vorschlag]**

| Kennung | Vanilla Deutsch | Wirkung (Vanillas Text) | Im Setting | Deutsch | Englisch | Einordnung |
|---|---|---|---|---|---|---|
| `modArmorInsulatedLinerT1` | Zerfledderte isolierende Rüstungs-Mod | Hitze- und Kältewiderstand | Futter aus Werg | Wergfutter | Tow Lining | plausibel |
| `modArmorInsulatedLinerT2` | Isolierende Patchwork-Rüstungs-Mod | wie oben, mehr | Futter aus Wolle | Wollfutter | Wool Lining | plausibel |
| `modArmorInsulatedLinerT3` | Isolierende ThermaCore-Rüstungs-Mod | wie oben, am meisten | Futter aus Pelz | Pelzfutter | Fur Lining | belegt (Pelzbesatz), als Futter plausibel |
| `modArmorStoragePocket` | Taschen-Mod für Rüstung | Überlast −1 | Tasche am Gürtel | Gürteltasche | Belt Pouch | **belegt um 700** (Taschen mit Bügel in Gräbern) |
| `modArmorDoubleStoragePocket` | Doppeltaschen-Mod | Überlast −2 | Tasche am Schulterriemen | Umhängetasche | Shoulder Bag | plausibel |
| `modArmorTripleStoragePocket` | Dreifachtaschen-Mod | Überlast −3 | Riemenzeug über beide Schultern | Tragriemen | Carrying Straps | plausibel |
| `modArmorQuadStoragePocket` | Vierfachtaschen-Mod | Überlast −4 | Traggestell auf dem Rücken | Rückentrage | Back Frame | plausibel |
| `modArmorBandolier` | Patronengurt-Mod | schneller nachladen | Riemen, der den Köcher greifbar hält | Köcherriemen | Quiver Strap | plausibel (D54 dachte schon an Pfeile) |
| `modArmorImprovedFittings` | Rüstung-Fittings-Mod | weniger Bewegungs- und Ausdauermalus | nachgeschnallte Riemen | Angepasste Riemen | Fitted Straps | plausibel |
| `modArmorCustomizedFittings` | Fortgeschrittene Rüstung-Fittings-Mod | wie oben, stark | auf den Leib geschnitten | Maßriemen | Tailored Straps | plausibel |
| `modArmorPlatingBasic` | Panzerplatten-Mod | mehr Rüstungswert (nicht schwer) | Schuppen aus Horn oder Eisen, aufgenäht | Schuppenbesatz | Scale Facing | plausibel (Schuppenpanzer ist spätrömisch belegt) |
| `modArmorPlatingReinforced` | Fortgeschrittene Panzerplatten-Mod | wie oben, stark | verschnürte Eisenlamellen | Lamellenbesatz | Lamellar Facing | **belegt** als Panzer (Niederstotzingen), als Besatz plausibel |
| `modArmorMuffledConnectors` | Gedämpfte Verbindungs-Mod | weniger Lärm | Filz zwischen Eisen und Eisen | Filzunterlage | Felt Padding | plausibel |
| `modArmorAdvancedMuffledConnectors` | Fortgeschrittene gedämpfte Verbindungs-Mod | wie oben, stark | doppelt gelegt | Doppelte Filzunterlage | Double Felt Padding | plausibel |
| `modArmorImpactBracing` | Schlag-Abwehr-Mod | weniger Fallschaden | Polster unter der Ferse | Fersenpolster | Heel Padding | plausibel |
| `modArmorStealthBoots` | Tarnstiefel-Mod | leisere, leichtere Schuhe | Sohle aus Filz | Filzsohlen | Felt Soles | plausibel |
| `modArmorFortitude` | Standhaftigkeit-Mod („KI-betriebene Nervenschnittstelle") | +1 Standhaftigkeit — bei uns **Krieger** | Eberfigur auf dem Helm | Eberzier | Boar Crest | **belegt um 700** (Benty Grange) |
| `modArmorAgility` | Beweglichkeit-Mod | +1 — bei uns **Jäger** | Feder am Kopfputz | Jagdfeder | Hunter's Feather | plausibel, schwach |
| `modArmorStrength` | Stärke-Mod („KI-Nervenchip") | +1 — bei uns **Handwerker** | Riemen um die Stirn | Stirnriemen | Brow Band | plausibel, schwach |
| `modArmorIntellect` | Intelligenz-Mod | +1 — bei uns **Heiler** | Rautenzweig an der Haube | Rautenzweig | Sprig of Rue | plausibel, schwach |
| `modArmorPerception` | Wahrnehmung-Mod („KI-betriebene Kontaktlinsen") | +1 — bei uns **Fuhrmann** | Krempe gegen Sonne und Regen | Krempe | Hat Brim | plausibel, schwach |
| `modArmorTreasureHunter` | Schatzsucher-Mod | mehr Beute und Schätze | eingenähte Münze | Glückspfennig | Lucky Penny | plausibel, schwach |

**Zu den sechs letzten, ehrlich:** ein Kopfputz, der einen Menschen zum besseren Krieger macht,
ist in dieser Welt ein **Amulett** — und das ist Volksmagie, also Phase 2 (F-15, D66). Die
weltlichen Deutungen oben folgen dem Grundsatz aus D87 („weltlich in Phase 1, magisch ab
Phase 2") und sind die schwächsten des Dokuments; nur die Eberzier hat ein echtes Vorbild. Die
Alternative ist, die sechs bis F-15 zu sperren (§5.4 Nr. 7).

**Texte [Vorschlag]** — je ein Satz, die Wirkung in Vanillas Worten dahinter:

| Kennung | Deutsch | Englisch |
|---|---|---|
| Wergfutter | „Werg, zwischen Tuch und Rüstung gestopft. Besser als nichts gegen das Wetter." | "Tow stuffed between cloth and armour. Better than nothing against the weather." |
| Wollfutter | „Eine Lage Wolle unter der Rüstung. Sie hält das Wetter vom Leib." | "A layer of wool beneath the armour. It keeps the weather off the body." |
| Pelzfutter | „Pelz, das Haar nach innen. Wer das trägt, hat den Winter nicht zu fürchten." | "Fur, the hair turned inward. Whoever wears it need not fear the winter." |
| Gürteltasche | „Eine Ledertasche am Gürtel. Was darin liegt, trägt die Hüfte, nicht die Hand." | "A leather pouch at the belt. What lies in it is carried by the hip, not the hand." |
| Umhängetasche | „Eine Tasche am Riemen über der Schulter." | "A bag on a strap across the shoulder." |
| Tragriemen | „Riemen über beide Schultern, die eine Last verteilen." | "Straps over both shoulders that spread a load." |
| Rückentrage | „Ein Gestell aus Haselruten für den Rücken. So trägt man, was man nicht tragen kann." | "A frame of hazel rods for the back. This is how one carries what cannot be carried." |
| Köcherriemen | „Ein Riemen, der den Köcher dorthin legt, wo die Hand ihn findet." | "A strap that sets the quiver where the hand will find it." |
| Angepasste Riemen | „Nachgeschnallt, bis nichts mehr scheuert und nichts mehr schlägt." | "Buckled again and again, until nothing chafes and nothing knocks." |
| Maßriemen | „Auf einen Leib geschnitten und auf keinen anderen." | "Cut for one body and for no other." |
| Schuppenbesatz | „Schuppen aus Horn oder Eisen, auf Leder genäht wie die Haut eines Fisches." | "Scales of horn or iron, sewn onto leather like the skin of a fish." |
| Lamellenbesatz | „Schmale Eisenplättchen, mit Riemen zu Reihen verschnürt. Man sagt, die Reiter aus dem Osten tragen ganze Panzer davon." | "Narrow iron leaves, laced into rows with thongs. They say the riders from the east wear whole coats of them." |
| Filzunterlage | „Filz, wo Eisen auf Eisen läge. Es klirrt weniger." | "Felt where iron would lie on iron. It rings less." |
| Doppelte Filzunterlage | „Zwei Lagen Filz. Jetzt klirrt fast nichts mehr." | "Two layers of felt. Now almost nothing rings." |
| Fersenpolster | „Filz und Leder unter der Ferse. Ein Sprung tut weniger weh." | "Felt and leather under the heel. A jump hurts less." |
| Filzsohlen | „Sohlen aus Filz unter schwerem Schuhwerk. Leiser, und leichter zu gehen." | "Soles of felt beneath heavy footwear. Quieter, and easier to walk in." |
| Eberzier | „Ein Eber aus Buntmetall für den Helm. Der Eber weicht nicht — so heißt es." | "A boar of bronze for the helmet. The boar does not yield — so they say." |

### 4.3 Lücken bei den Aufsätzen

1. **„Leinenfutter" sitzt auf der falschen Kennung.** D91 hat den Namen vergeben, aber an einen
   Aufsatz, den Vanilla auskommentiert hat. Die drei erreichbaren Futter heißen weiter
   „ThermaCore". Entweder wandert „Leinenfutter" auf `modArmorInsulatedLinerT1` (dann: Leinen-,
   Woll-, Pelzfutter — die schönere Reihe), oder die Reihe oben gilt und „Leinenfutter" bleibt
   eine tote Zeile.
2. **Die Futter haben kein Rezept** **[gemessen]** (Dump: 0 Rezepte, nur Beute und Händler). Ein
   Wollfutter, das man nicht nähen kann, ist in einer Welt mit Webstuhl und Nähzeug eine Lücke.
3. **Die Wirkungstexte der sechs Kopf-Aufsätze nennen Vanillas Attribute** („+1 Stärke"). Bei uns
   heißen die Bäume Handwerker, Krieger, Jäger, Heiler, Fuhrmann (Glossar §8).
4. **Vier Texte nennen gesperrte Garnituren:** „Kann nicht an leichter oder **Assassinen**rüstung
   angebracht werden" (Filzunterlagen). Gemeint ist bei uns der Polsterrock — der Ausschluss
   hängt am Tag `assassin`, den unsere Teile **nicht** tragen **[gemessen]** (Mod `items.xml`,
   Tags der T2-Teile). Der Satz ist bei uns also doppelt falsch: falscher Name, und der
   Ausschluss greift gar nicht.
5. **Kein Aufsatz für die Zier** (§3.3 Nr. 3) und **keiner für den Mantel.**
6. **Symbole** aller 22 sind Vanilla **[nicht gesehen]**.

---

## 5. Lücken, Brüche, Stückliste, Entscheidungen

### 5.1 Brüche im Text

| Nr. | Bruch | Wo | Art |
|---|---|---|---|
| 1 | 12 Stücke Unterkleidung mit Vanillas Namen und Texten („ThermaCore-Kampfschicht", „fortschrittliche Thermofasern") | Vanilla `Localization.csv`, `clothing*`; bei uns keine Zeile | Lücke, sichtbar in Phase 1 |
| 2 | 22 Aufsätze mit Vanillas Namen („KI-betriebene Nervenschnittstelle", „Patronengurt-Mod", „Panzerplatten-Mod") | `modArmor*` | Lücke, sichtbar in Phase 1 |
| 3 | Vier Texte versprechen Wärme oder Windschutz, die 16 Rüstungsteile haben keinen Wert dafür | Lumpenkittel, Wollhandschuhe, Steppschuhe; sinngemäß der Lederrock („wollenes Futter") | Text sagt mehr als das Ding tut |
| 4 | „Gambeson" und „Wams" sind Wörter des 12./13. Jh. | Glossar §6, `itm700_gambeson`, `itm700_lederwams`, `armorT3`, `craftingArmorDesc` | Konflikt mit P1 |
| 5 | „Streifschuss" bei der Lederkappe | `itm700_lederkappeDesc` | Wort der Feuerwaffe |
| 6 | „Nasenband" beim Spangenhelm | `itm700_spangenhelmDesc` | für den Typ unsicher |
| 7 | „Leinen" bei den Wadenwickeln | `itm700_wickelschuheDesc` | Funde sind Wolle |
| 8 | „boot" bei den Beinschienen, „knuckles" bei den Handlappen | englische Spalte | DE und EN nicht gleich gebaut |
| 9 | `armorParts` heißt „Rüstungsteile" und liest Vanillas Satz über „fortgeschrittene Waffen" | geerbter `DescriptionKey` (Plan-0001, offene Punkte, dort schon vermerkt) | Lücke |
| 10 | Die Fertigkeit „Mittlere Rüstung" verspricht im Rang-Text, man werde „Ritter" und „Gladiator" | unsere Zeilen `perkMediumArmorRank2–4LongDesc` (Sprachdatei 887–889) | **Ritter ist Hochmittelalter, Gladiator Antike** — beide stehen in *unserer* Datei |
| 11 | „Leinenfutter" benennt einen unerreichbaren Aufsatz | §4.3 Nr. 1 | tote Zeile |

### 5.2 Brüche in der Sache

| Nr. | Bruch | Beleg |
|---|---|---|
| 1 | **T0 und T1 schützen gleich** (8 → 12,3) | F-03, Balancing 0001 §3 — bekannt, hier nur der Vollständigkeit halber |
| 2 | **T1, T2 und T3 schalten auf derselben Handwerksstufe frei** (11, 20, 40, 60, 80, 100) | Dump `progression.xml`:696–716. Die Reihenfolge entsteht allein über die Werkstatt |
| 3 | **Wärme ist nur über Beute zu haben** (Unterkleidung und Futter ohne Rezept) | §2.5, §4.3 Nr. 2 |
| 4 | **Der Schleich-Bonus sitzt auf dem Polsterrock**, nicht beim Jäger | §3.2 |
| 5 | **Eine volle T3-Garnitur kostet weniger Erz als ein Streithammer** | Balancing 0001 §4 — bekannt |
| 6 | **Ein Bauteil ohne Zweck in der Beute** (`armorParts`) | §2.6 |

### 5.3 Brüche in der Erscheinung **[nicht gesehen]** und Stückliste für Phase 2 (F-16)

**Die Einheit der Arbeit ist der Prefab, nicht das Teil** **[gemessen]**: alle vier Teile einer
Garnitur zeigen auf einen Pfad `Gear/…/gear{sex}…Prefab.prefab`, `EquipSlot` wählt den Ausschnitt.
Je Garnitur gibt es also **zwei Modelle** (männlich, weiblich) und vier Symbole.

| Prio | Stück | Art | Zahl | Grund |
|---|---|---|---|---|
| 1 | **T3-Garnitur**: Brünne, Helm, Armschienen, Beinbergen | neues Modell | 2 Prefabs | „Raider" hat Stacheln, Blech, Vollmaske — unhaltbar; F-16 sieht es so vor |
| 1 | Symbole der zwölf eigenen Teile | neues Symbol | 12 | heute das Bild der modernen Garnitur im Beutel |
| 2 | **T2-Garnitur**: Polsterrock, Haube, Fäustlinge, Schuhe | **vermutlich neues Modell** | 2 Prefabs | F-16 plant eine Retextur; ein eng anliegender schwarzer Anzug mit Maske wird durch Farbe nicht wulstig. Erst ansehen (WP5.7), dann entscheiden |
| 2 | **T1-Garnitur**: Lederrock, Kappe, Fäustlinge, Wickelschuhe | Retextur, falls der Schnitt trägt; sonst neu | 2 Prefabs | Jacke mit Halstuch — Farbe allein macht daraus keinen Rock |
| 3 | **T0-Garnitur** | Retextur | 2 Prefabs | vermutlich das unauffälligste Stück |
| 3 | Symbole der Unterkleidung | neues Symbol | 12 | falls modern |
| 3 | Symbole der Aufsätze | neues Symbol | 22 | Vanillas Bilder zeigen vermutlich Schrauben, Platten, Elektronik |
| 4 | Zier je Kulturkreis | Texturvariante | 5 × 4 | §3.3 Nr. 3; erst wenn der Weg der Wahl feststeht |
| 4 | Mantel mit Spange | Teil der Rumpf-Modelle | in Prio 1–3 enthalten | §3.3 Nr. 2 |
| 4 | T4-Erkennungszeichen | Texturvariante der T3-Garnitur | 1 | D61 lässt T4 aussehen wie T3 |

Summe der Modelle: **8 Prefabs** (4 Garnituren × 2). Summe der Symbole: **46**, dazu die vier der
Biom-Ausrüstung ([biome.md](biome.md)). Quelle nach D84: Helm über Meshy mit Nacharbeit; Stoff
und Ringgeflecht sind keine „einfachen harten Formen" und in D84 keiner Zeile zugeordnet — **die
Kleidung am Körper hat in D84 keine Quelle.** Das ist eine Lücke in F-16, nicht in diesem Dokument.

### 5.4 Entscheidungen für den Nutzer

| Nr. | Frage | Vorschlag | Marke |
|---|---|---|---|
| 1 | Bleibt **„Gambeson"** als Name von Stück und Stufe, obwohl Wort und Ding ins 12. Jh. gehören? | „Polsterrock / Padded Coat", Stufe „Polsterzeug / Padding". Gegenargument: jeder versteht „Gambeson". | **[zu prüfen]** |
| 2 | Bleibt **„Lederwams"**? | „Lederrock / Leather Coat". | **[zu prüfen]** |
| 3 | **„Kettenhemd"** oder **„Brünne"**? | „Brünne / Byrnie" — das Wort der Zeit; „Kettenhemd" ist verständlicher. Betrifft Glossar §6, `armorT4`, den Set-Namen „Kettengewand". | **[zu prüfen]** |
| 4 | **Spangenhelm als Altstück** behalten, oder ein zeitnäherer Typ (Band-, Kamm-, Lamellenhelm)? | Behalten und im Text als Erbstück erzählen; der zeitnahe Typ wird die Zier je Kulturkreis (Phase 2). | **[zu prüfen]** |
| 5 | Sollen die **12 Stücke Unterkleidung** jetzt (Phase 1) Namen und Texte bekommen? | Ja — reine Sprachzeilen, 15 Stück, und sie schließen F-03s Abnahme. Namen nach §2.5. | **[zu prüfen]** |
| 6 | Sollen die **16 handwerklichen Aufsätze** jetzt Namen und Texte bekommen? | Ja, nach §4.2. Balancing 0003 ließ „ob die 29 Aufsätze dem Namen nach bleiben" ausdrücklich offen. | **[zu prüfen]** |
| 7 | Die **sechs Kopf-Aufsätze** (+1 auf einen Baum): weltlich umdeuten (Eberzier, Jagdfeder …) oder bis zur Volksmagie sperren? | Sperren bis F-15 und dort als Amulette zurückholen; nur die Eberzier hat ein Vorbild. D87s Grundsatz spricht für Umdeuten. | **[zu prüfen]** |
| 8 | Wohin mit **„Leinenfutter"**? | Auf `modArmorInsulatedLinerT1` verschieben: Leinen-, Woll-, Pelzfutter. Ändert D91 der Sache nach, also neue D-Zeile. | **[zu prüfen]** |
| 9 | **`armorParts`**: einbinden oder sperren? | Sperren, bis ein Rezept es braucht. | **[zu prüfen]** |
| 10 | Sollen **Unterkleidung und Futter herstellbar** werden (Webstuhl, Nähzeug)? | Ja, in Phase 2 mit F-19/F-11 (Kälte, Nässe, Fieber) — Zahlen sind Balancing, nicht dieses Dokument. | **[zu prüfen]** |
| 11 | Soll unsere **Rüstung selbst wärmen** (Wolle, Polster), oder bleibt Wärme allein Sache der Unterkleidung? | Bleibt bei der Unterkleidung; dafür die vier Texte aus §5.1 Nr. 3 ändern. Das erfindet keine Zahl. | **[zu prüfen]** |
| 12 | **Ritter und Gladiator** in den Rang-Texten von „Mittlere Rüstung" | Umschreiben (Gefolgsmann, Schildträger); D90 ließ den Namen der Fertigkeit stehen, nicht ihre Rang-Texte. | **[zu prüfen]** |
| 13 | Ein eigener **Jäger-Satz**? | Nicht in Phase 1. Als Notiz in F-03 für Phase 2. | **[zu prüfen]** |
| 14 | **Gesicht je Kulturkreis**: eigene Gegenstände oder Zier-Aufsatz? | Erst messen, ob ein Aufsatz das Aussehen ändern kann (§3.3 Nr. 3); dann entscheiden. | **[zu prüfen]** |
| 15 | Die kleinen Textänderungen aus §2 (Streifhieb, Wollbänder, Wangenklappen statt Nasenband, „shoe", „skin", „Steppfäustlinge", „Mittens") | Übernehmen — keine davon ändert einen Glossarbegriff. | **[zu prüfen]** |

### 5.5 Wo die historische Einordnung unsicher ist

- **Slawische Tracht um 700:** fast nur aus dem Fehlen von Funden erschlossen. Jede Zier, die
  dort „slawisch" heißt, ist eine Setzung.
- **Leder als Rüstung** (Lederrock, Lederkappe, „gekochtes Leder"): plausibel, für 700 nicht belegt.
- **Gesteppte Rüstung** als eigenes Stück: später; nur das Polster unter der Rüstung ist belegt,
  und das für die Spätantike.
- **Armschienen:** ein Fund (Valsgärde 8), dessen Deutung nicht einhellig ist.
- **Nasenschutz am Spangenhelm:** unsicher.
- **Bastschuhe:** kein dem Verfasser bekannter Fund um 700.
- **Zahlen der Lex Ribuaria, Wortlaut bei Jonas von Bobbio, Datierung von Bernuthsfeld und der
  Orkney-Kapuze:** aus dem Gedächtnis; die Größenordnung stimmt, die Stelle ist nachzuschlagen.
- **Aussehen der vier geborgten Garnituren in V 3.40:** nach Kenntnis älterer Fassungen
  beschrieben, im Spiel nicht gesehen — jede Aussage unter „was stört" ist eine Erwartung.
