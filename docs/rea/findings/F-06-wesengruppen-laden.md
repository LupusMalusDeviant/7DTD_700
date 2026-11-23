# F-06 — Wesen-Gruppen: was das Laden von `entitygroups.xml` verlangt

**Stand:** 23. November 2026 (Plan-0002, WP5.4)
**Fragen** (Vertrag 03, Nachtrag Phase 2 C, „[verifizieren, WP5 / WP9]"):

1. Bricht das Spiel, wenn eine Gruppe eine Klasse nennt, die es nicht gibt?
2. Was tut das Spiel mit einer leeren Gruppe?
3. Was geschieht, wenn eine Gruppe fehlt, die `spawning.xml` oder `gamestages.xml` ruft?
4. Welche Formen hat ein Eintrag, und was bedeutet seine Stelle in der Gruppe?

**Antworten in einem Satz je Frage (statisch gelesen, nichts davon im Spiel gesehen):**

1. **Ja, beim Laden.** Der Leser wirft eine Ausnahme mit dem Text `Entity with name '…' not found`.
   Einzige Ausnahme ist der Name `none`.
2. **Sie ist ein Ladefehler,** kein stilles Nichts: `Empty entity groups not allowed! Group name: …`.
3. **Auch ein Ladefehler,** an der Datei, die ruft: `Entity group '…' not existing!` (Landschaften)
   und `Spawner '…', gamestage …: EntityGroup '…' unknown!` (Spielstufen).
4. Drei Formen (`<e n p>`, `<entity name prob>`, Textliste); Vanilla benutzt nur die erste. Die
   Gewichte einer Gruppe werden beim Laden auf ihre Summe bezogen. Den **ersten** Eintrag liest das
   Spiel, um zu entscheiden, ob die Gruppe Feinde führt.

**Kein Patch.** Dieses Finding trägt keinen Harmony-Eingriff und steht darum nicht im
Patch-Manifest; es belegt, was ein XML-Patch an `entitygroups.xml` nicht tun darf.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta types <dll> --contains EntityGroup`, `mod700meta find-string <dll> --text
entitygroup` (54 940 Methodenrümpfe, 9 Treffer), `mod700meta members <dll> --type
EntityGroupsFromXml --type EntityGroups --type GameStagesFromXml --type
'BiomeSpawningFromXml/<Load>d__0' --type SEntityClassAndProb --type 'DictionarySave`2' --il
--callers`; dazu Zählungen an `Data/Config/entitygroups.xml`, `spawning.xml` und
`entityclasses.xml` von V 3.40 b10.

**Soll-Signaturen:** `tools/meta/expect/wp54.tsv` (10 Zeilen). `mod700meta verify`: Exit 0;
Gegenprobe mit einer verfälschten Zeile (`IsEnemyGroup(int)`): Exit 1.

## 1. Der Leser

`WorldStaticData` ruft `EntityGroupsFromXml::LoadEntityGroups(XmlFile)`. Der Leser verlangt ein
Wurzelelement mit Kindern (`No root element found!`) und geht jedes `<entitygroup>` mit
`parseGroup` durch:

- Das Attribut `name` muss da sein (`Attribute 'name' missing on entitygroup element`).
- Die Gruppe wird unter ihrem Namen in `EntityGroups.list` abgelegt — ein Wörterbuch, in dem ein
  zweiter Eintrag gleichen Namens den ersten ersetzt. Vanilla führt keinen Namen doppelt (1875
  Gruppen, 1875 Namen).
- Jeder Kindknoten wird nach seiner Art gelesen: **Text** als Liste (`parseTextBasedList`), ein
  **Element** namens `entity` oder `e` einzeln (`parseElementBased`). Andere Elemente werden
  übergangen.
- Danach werden die Gewichte der Gruppe normiert (`EntityGroups::Normalize`), und **zum Schluss**
  prüft der Leser die Zahl der Einträge: null ist die Ausnahme `Empty entity groups not allowed!`.

`parseElementBased` liest den Namen aus `name` oder `n` (fehlt beides oder ist er leer: Ausnahme
mit dem Namen der Gruppe) und das Gewicht aus `prob` oder `p`.

`addEntity` ist die Stelle, die Frage 1 beantwortet: ist der Name nicht `none`, wird er über
`EntityClass::FromString` in eine Kennzahl gewandelt und in der Liste der Klassen gesucht; fehlt
sie dort, wirft der Leser `Entity with name '…' not found`. `none` wird ohne diese Suche als
Eintrag aufgenommen (`SEntityClassAndProb` führt dafür eine eigene Konstante `cIdNone`).

**Doppelte Einträge prüft niemand.** Vanilla hat sie in 24 Gruppen (etwa `animalDireWolf` zweimal
in `ZombiesDowntown`); die Gewichte zählen dann einfach zusammen.

## 2. Wer eine Gruppe ruft

| Rufer | Datei | fehlt die Gruppe |
|---|---|---|
| `BiomeSpawningFromXml` (Landschaften) | `spawning.xml`, `<spawn entitygroup="…">` | Ausnahme `Entity group '…' not existing!` |
| `GameStagesFromXml::ParseSpawn` (Spielstufen, Schläfer, Seuchennacht) | `gamestages.xml`, `<spawn group="…">` | `XmlLoadException`: `Spawner '…', gamestage …: EntityGroup '…' unknown!` |

Beide suchen den Namen beim Laden in `EntityGroups.list`. Eine Gruppe, die gerufen wird, darf also
nie entfernt werden — auch nicht, wenn sie „eigentlich" durch eine eigene ersetzt ist; ersetzt wird
am Rufer, nicht an der Gruppe.

Zur Laufzeit ziehen aus einer Gruppe: `SpawnManagerBiomes::SpawnUpdate`, `SleeperVolume::UpdateSpawn`,
`EntitySpawner::SpawnManually`, die Spielereignisse (`ActionBaseSpawn`), zwei Auftrags-Wege
(`NetPackageQuestEntitySpawn`, `QuestActionSpawnGSEnemy`) über `GetRandomFromGroup`; die
Seuchennacht und die Horden (`AIDirectorBloodMoonParty::SpawnZombie`, `AIHordeSpawner::Tick`,
`AIWanderingHordeSpawner::UpdateSpawn`) über `GetRandomEntityFromGroupMaxTier`, das die Einträge
vorher nach der Stufe der Klasse siebt.

## 3. Der erste Eintrag

`EntityGroups::IsEnemyGroup(string)` liest den Eintrag an Stelle 0 der Gruppe, holt dessen Klasse
und gibt ihr Feld `bIsEnemyEntity` zurück. Gerufen wird das von `SpawnManagerBiomes::SpawnUpdate`
und von `ChunkAreaBiomeSpawnData` (`DelayAllEnemySpawningUntil`, `ResetRespawn`) — also dort, wo
das Spiel entscheidet, ob es in einer Landschaft Feinde nachrücken lässt.

Folgen für Patches:

- Wer den ersten Eintrag einer Gruppe entfernt, macht den zweiten zum Maßgebenden. In den
  Gruppen, die WP5.4 anfasst, bleibt an Stelle 0 ein Feind (gemessen am Vorlauf, siehe unten).
- **`none` an Stelle 0** kommt in Vanilla nicht vor (0 von 1875 Gruppen; `none` steht in 14
  Gruppen, immer hinter mindestens einer Klasse). Was `IsEnemyGroup` dann liefert oder ob es
  bricht, ist **nicht gelesen** — die Regel ist darum: `none` rückt nie nach vorn.

## 4. Was daraus für das Projekt folgt

1. Vertrag 03, Nachtrag Phase 2 C, Punkt 1 und 3 sind keine Übertragungen mehr, sondern belegt:
   eine fehlende Klasse und eine leere Gruppe brechen das Laden. Punkt 3 wird schärfer: es genügt
   nicht, dass eine Gruppe „mindestens einen eigenen" Eintrag bekommt — sie darf zu keinem
   Zeitpunkt der Patch-Kette leer geladen werden, und geladen wird erst nach allen Patches. Leer
   ist sie nur, wenn **nach** allen Modlets kein Eintrag bleibt.
2. `purge-patch` rechnet das seit WP5.4 nach, bevor es eine Datei schreibt: keine
   Landschaftsgruppe leer, keine beginnt mit `none` (Vertrag 04, Nachtrag WP5.4).
3. Die Prüfung *wesen* (`anachronisms`) hält dieselben drei Ladefehler am gemergten Stand fest:
   `wesen-verweis-fehlt` (Klasse oder Gruppe fehlt), `wesengruppe-leer`.
4. Ein `remove` trifft den **Eintrag** (`…/entitygroup[@name='G']/e[@n='X']`), nie
   `…/entitygroup[@name='G']` und nie die Klasse.

## Messung an V 3.40 b10

| | |
|---|---|
| Gruppen | 1875 |
| Einträge `<e>` | 26 734 |
| Einträge `<entity>` | 0 |
| Gruppen mit Textliste | 0 |
| Einträge `none` | 14, in 14 Gruppen, nie an erster Stelle, nie allein |
| Gruppen mit doppeltem Eintrag | 24 |
| Gruppen, die `spawning.xml` ruft (Landschaftsgruppen) | 29 |

## Offen

| Punkt | Stand |
|---|---|
| Was das Spiel aus der Ausnahme macht (Meldung, zurück ins Hauptmenü, Abbruch) | nicht gelesen; für das Projekt gleich: es ist ein Ladefehler und im Log ein `ERR` |
| `none` an erster Stelle | nicht gelesen; vermieden |
| Verhalten im Spiel | nicht gesehen — S-27 der Entscheidungsliste |
| Dedicated Server | die Dateien lädt der Server; ein Client bekommt die gemergte Config von ihm (Finding WP1). Nicht gesondert geprüft |
