# F-07 — Zufallswelt und Orte: Händler, Siedlungen, Wege, Auftragsziele, Prefab-Format, Modell-Tausch

**Stand:** 23. November 2026 (Plan-0002, WP6.2)
**Fragen** (F-07 „Ausarbeitung für Phase 2", Punkte `[verifizieren]`, und Plan-0002 WP6.2):

1. Entstehen Händler nur mit Ortschaften, und schaltet `spawn_trader` sie ab?
2. Was tut `prefab_spawn_adjust`, und sperrt `max_count="0"` einen Ort?
3. Lassen sich die Verbindungsstraßen abschalten, und gibt es eine Siedlungsart ohne Straßen?
4. Wie weit reicht ein Auftrag, und woraus wählt er sein Ziel?
5. Kann ein Ort ohne den Editor des Spiels entstehen (Dateiformat der Prefabs)?
6. Trägt ein Modell-Block (`Shape="ModelEntity"`) nach einem Tausch von `Model` weiter, was er
   war (Weg C)?

**Antworten in einem Satz je Frage (Code statisch gelesen, Vanillas XML gezählt, nichts im Spiel
gesehen):**

1. **Nein und nein.** Händler sind gewöhnliche Orte (`trader_*`), die wie jeder andere Ort über
   Gewichte gewählt werden; das Feld hinter `spawn_trader` wird geladen, aber **an keiner Stelle
   der ganzen Assembly gelesen**.
2. Es setzt je Ort-Namensteil ein Gewicht, einen Zuschlag (`bias`), Mindest- und Höchstzahl und
   erlaubte Landschaften; was `max_count="0"` bewirkt, ist **statisch nicht belegt** (siehe §2).
3. **Teilweise.** Welche Siedlungen Fernstraßen und welche Feldwege bekommen, entscheidet ein
   Filter über `spawn_gateway` (Lesart: mit Gateway Fernstraße, ohne Feldweg —
   `[im Spiel bestätigen]`). Ganz ohne Wege bleibt eine Welt nur, wenn der Spieler beim Erzeugen
   „Ortschaften: keine" wählt.
4. Aus den Orten **um den Händler** (nach dessen bevorzugter Entfernungsstufe) oder **um einen
   Weltpunkt**, gefiltert nach Stufe, Auftragsmarke, Landschaft und Sperren.
5. Das Format ist lesbar beschrieben (Binärdatei plus Namenstabelle plus XML), ein Ort ohne Editor
   bleibt aber **unbelegt**; Empfehlung: Orte im Editor des Spiels bauen.
6. **Ja.** Prefabs speichern Blöcke **mit Namen**, nicht mit Nummern, und ein Modell-Block liest
   sein `Model` beim Laden des Blocks; ein `<set>` auf `Model` kleidet jeden Ort um, der den Block
   enthält.

**Kein Patch.** Kein Harmony-Eingriff, darum kein Eintrag im Patch-Manifest.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta members <dll> --type … --il [--callers]` über die Typen
`WorldGenerationEngineFinal.*` (83 Typen), `ObjectiveRandomPOIGoto`, `DynamicPrefabDecorator`,
`Prefab`, `BlockShapeModelEntity`; dazu ein Suchlauf über **alle 7 677 Typen** der Assembly nach
Feldlesern (Skript im Scratchpad, nicht im Repo). Zählungen an `rwgmixer.xml` und
`Data/Prefabs/**/*.xml` von V 3.40 b10.

**Gegenprobe des Suchlaufs (Regel 5):** Der erste Lauf meldete 0 Treffer — falsch, weil die
Muster als ein einziger Text ankamen. Nach der Korrektur findet derselbe Lauf **jeden bekannten
Leser**: 6 Leser von `TownshipData::SpawnGateway`, 3 von `WorldBuilder::TraderCenterPositions`,
2 von `PrefabManagerData::TraderTags`, 8 von `Prefab::bTraderArea` (40 Treffer insgesamt). Für
`TownshipData::SpawnTrader` findet er nur die zwei **Schreiber** (Konstruktor und Lader).

**Soll-Signaturen:** `tools/meta/expect/wp62.tsv` (15 Zeilen). `mod700meta verify`: Exit 0;
Gegenprobe mit einer verfälschten Zeile (`EntityPlayer` → `EntityAlive`): Exit 1.

## 1. Händler

- Die fünf Händlerorte `trader_bob|hugh|jen|joel|rekt` tragen `TraderArea="True"`,
  `Zoning="any"`, `AllowedTownships="city,town,rural,wilderness"` und `QuestTags="trader, …"`.
  Sie dürfen also **auch in der Wildnis** stehen.
- `rwgmixer.xml` setzt je Händler eine Landschaft und `bias="20" min_count="2" max_count="4"`
  (Zeilen 821–825). Das ist der einzige Hebel, der Händler gezielt verteilt.
- Der Lader schreibt `spawn_trader` in `TownshipData.SpawnTrader`; **gelesen wird das Feld
  nirgends**. Die beiden `spawn_trader="false"` in Vanillas `rwgmixer.xml` (Zeilen 522, 568)
  wirken in diesem Build nicht. Für F-07 heißt das: **Weg B** (moderne Siedlungsarten weglassen)
  nimmt die Händler nicht mit, solange ihre Orte erlaubt bleiben.
- Beim Setzen eines Ortes prüft `StreetTile::SpawnMarkerPartsAndPrefabs` den Namen (Texte
  `trader` und `trader_`) und trägt dann die Mitte in `WorldBuilder.TraderCenterPositions` ein.
  Diese Liste liest `WorldBuilder::CreatePlayerSpawn` (Startpunkte der Spieler) und
  `CalcClosestTraderDistance`. **Folgerung, ungeprüft:** ein eigener Händlerort muss mit
  `trader_` beginnen, sonst zählt er nicht als Händler für Startpunkt und Abstand. Ob
  `StartsWith` oder `Contains` — statisch nicht belegt, `[im Spiel bestätigen]` (S-29).
- Die Straßenkacheln `rwg_tile_gateway_straight3*` sind laut Vanillas Kommentar auf je 1
  begrenzt, „weil sie Händler blockieren" — Händler und Gateways teilen sich Plätze.

## 2. `prefab_spawn_adjust`

- Der Lader liest `partial_name`, `tags`, `biomeTags`, `weight`, `bias`, `min_count`,
  `max_count` (Zahlen als Gleitkomma bzw. Ganzzahl) und legt je Zeile ein `POIWeightData` an.
- `PrefabManager::getScoreForPrefab` vergleicht den Namensteil mit dem Ortsnamen, prüft
  Landschaft und Tags, und liest `Weight`, `Bias`, `MinCount`, `MaxCount` sowie die Zahl der
  schon gesetzten Orte gleichen Namens. Vanillas eigener Kommentar in `rwgmixer.xml` (Z. 695–700)
  nennt die Rechnung: Grundwert 1, plus `bias + Stufe/5`, geteilt durch die Anzahl in der Welt,
  mal `weight`.
- **Offen:** Welche Vorgabe gilt, wenn `max_count` fehlt, und ob `0` „nie" oder „unbegrenzt"
  heißt, zeigt der statische Befund nicht (die Vorgabewerte stehen in Ortsvariablen vor dem
  Lesen). **Darum baut WP6.5 nicht auf `max_count="0"`**, sondern auf zwei Wege, deren Wirkung
  aus Vanilla selbst folgt: `biomeTags` (Vanilla sperrt damit Trümmerorte auf eine Landschaft)
  und `weight` nahe null. Beides `[im Spiel bestätigen]` mit einer kleinen Testwelt (S-29).

## 3. Straßen und Siedlungsarten

- `WorldBuilder::GenerateTask` ruft nacheinander Siedlungsplanung, Wildnisplanung,
  `HighwayPlanner::Plan`, das Setzen der Orte, `WildernessPathPlanner::Plan`, `DrawRoads`,
  `SmoothRoadTerrain`. Die Wahl „Ortschaften" und „Wildnis" im Erzeugungsdialog liest es aus
  `Towns` und `Wilderness`.
- `HighwayPlanner::Plan` wählt die zu verbindenden Siedlungen mit einem Filter, der
  `spawn_gateway` liest (`ConnectClosest`, `ConnectSelf` für große, `CleanupHighwayConnections`);
  `RunTownshipDirtRoads` („countryTownships") filtert ebenfalls über `spawn_gateway`. **Lesart,
  Richtung der Filter statisch nicht belegt:** Arten mit Gateway bekommen Fernstraßen, Arten ohne
  Gateway Feldwege. In Vanilla trägt nur `oldwest` `spawn_gateway="false"`; alle anderen Arten
  lassen den Wert weg (Vorgabe aus dem Konstruktor, statisch nicht lesbar).
- Wildnisorte bekommen über `WildernessPathPlanner` Pfade zur nächsten Fernstraße.
- **Folgerung für F-07:** Eine Welt nur aus Siedlungsarten **ohne** `spawn_gateway` hätte keine
  Fernstraßen, nur Feldwege und Pfade — das passt zu „Wege statt Straßen". Ob dann Feldwege
  überhaupt entstehen (sie führen „zu den Fernstraßen"), `[im Spiel bestätigen]` (S-29).
- Eine eigene Siedlungsart braucht Straßenkacheln (`rwg_tile_*`), denn Siedlungen wachsen aus
  Kacheln (`TownPlanner::Grow`, `StreetTile`). Ein „Weiler" ohne jede Kachel ist mit XML nicht
  zu haben; mit eigenen Kacheln (Prefabs, §5) schon.

## 4. Auftragsziele

- `ObjectiveRandomPOIGoto::GetPosition` liest die Stufe des Auftrags (`POITier`) und ruft
  entweder `DynamicPrefabDecorator::GetRandomPOINearTrader` (Kandidaten aus
  `QuestEventManager::GetPrefabsForTrader` nach `EntityTrader.PreferredDistanceIndex`) oder
  `GetRandomPOINearWorldPos` (Kandidaten nach Stufe aus `GetPrefabsByDifficultyTier`, Abstand
  über die quadrierte Entfernung). Findet es nichts: Logzeile „No POI found".
- `ValidPrefabForQuest` filtert nach Auftragsmarke (`QuestTags`), Sperren laufender Aufträge
  (`CheckForPOILockouts`), Landschaft und belegten Volumen.
- **Folgerung:** Ein Auftrag findet einen Ort, wenn der Ort die passende Auftragsmarke **und**
  Stufe hat und im Umkreis des Händlers liegt. Fehlen Orte einer Stufe nahe einem Händler,
  scheitert der Auftrag dort. Die Bedarfsrechnung in F-07 (zehn Orte mit Auftragsmarke über fünf
  Stufen) muss darum **je Landschaft** gedacht werden, nicht für die ganze Welt.

## 5. Dateiformat eines Ortes

- `Prefab::Load` liest nacheinander: die Größe, die Blockdaten (Binärdatei mit Kacheldaten,
  Kistenhalter, Auslöser), eine Datei `.ins`, Schilder aus `_signs.xml`, Eigenschaften aus der
  `.xml`.
- Die Blocknummern übersetzt `Prefab::loadIdMapping` über die Datei `.blocks.nim` **per
  Blockname** in die Nummern des laufenden Spiels (`Block::GetBlockByName`); fehlt die Datei,
  bricht das Laden mit einer Fehlermeldung ab. Fehlende Namen gehen an einen Rückruf
  `MissingEntryCallbackDelegate`.
- `Prefab::ReadFromProperties` liest aus der `.xml` u. a. `DifficultyTier`, `TraderArea`,
  `TraderAreaProtect`, `Tags`, `ThemeTags`, `QuestTags`, `AllowedTownships`, `AllowedBiomes`,
  `Zoning`, `PrefabSize`, `YOffset` — **die XML eines Ortes ist Text und frei schreibbar**.
- **Unbelegt:** das Binärformat der Blockdaten im Einzelnen (Version, Reihenfolge). Ein Werkzeug,
  das Orte ohne Editor schreibt, wäre Rückwärtsarbeit an einem Format ohne Beschreibung.
  Empfehlung: Orte im Editor des Spiels bauen (Teil des Spiels, Nutzerarbeit, N-72), Text-Teile
  (`.xml`, Schilder) aus dem Repo pflegen.

## 6. Modell-Tausch an Blöcken (Weg C)

- `BlockShapeModelEntity::Init` liest beim Laden der Blockklasse `Model` (Pfad, `@` für
  Asset-Bündel; ohne Wert Logzeile „No model specified on block with name …"), dazu
  `ModelOffset`, `LODCullScale`, `SymType`.
- Da Prefabs Blöcke **per Name** speichern (§5), trägt jeder Ort den Block weiter, dessen
  Eigenschaften wir in `blocks.xml` ändern. Klasse, Kiste, Beute und Mehrfeld-Maß
  (`MultiBlockDim`) bleiben, wenn nur `Model` getauscht wird.
- **Grenze:** Das neue Modell muss in das Mehrfeld-Maß passen, sonst ragt es heraus oder
  schwebt; eigene Modelle brauchen ein Asset-Bündel (Unity, Nutzeraufgaben #8/#9). Bis dahin
  lassen sich nur **andere Vanilla-Modelle** einsetzen. `[im Spiel bestätigen]` mit drei Blöcken
  (S-29).
- **Nicht tun:** einen Block entfernen, den Orte benutzen — das ist genau der Fall des
  Rückrufs für fehlende Namen; Folge statisch nicht belegt.

## Was daraus folgt (für F-07 und Plan-0002)

| Punkt | Folge |
|---|---|
| Händler | Händlerorte über `prefab_spawn_adjust` steuern, nicht über `spawn_trader`. Eigener Händlerort: Name `trader_…` (Vertrag 02, Nachtrag WP6.2, Abnahme offen). |
| Weg B | Moderne Siedlungsarten können entfallen, Händler bleiben. |
| Sperre von Orten | WP6.5 sperrt über `biomeTags`/`weight`, nicht über `max_count="0"`, bis S-29 es zeigt. |
| Straßen | Siedlungsarten ohne `spawn_gateway` → keine Fernstraßen. |
| Aufträge | Orte je Stufe **je Landschaft** nahe den Händlern einplanen. |
| Eigene Orte | im Editor des Spiels; Text-Teile im Repo. |
| Weg C | `<set>` auf `Model` genügt; Maß beachten; eigene Modelle erst mit Unity. |
