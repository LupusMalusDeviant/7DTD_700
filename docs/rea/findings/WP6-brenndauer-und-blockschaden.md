# WP6 — Brenndauer per `PlantGrowing`, und wo der Blockschaden der Toten wirklich steht

Erhoben am **2026-11-08** gegen `Assembly-CSharp.dll`
SHA-256 `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58`,
MVID `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480`, 11 980 288 Byte — derselbe Build wie in
[00-build-baseline](00-build-baseline.md) (V 3.40 b10).

Werkzeug: `tools/meta/Mod700.Meta` (`mod700meta members <dll> --type … --il`). Nur Metadaten
und CIL-Spuren; die Assembly wurde **nicht geladen, nicht ausgeführt, nicht dekompiliert**.
Dazu `Data/Config/blocks.xml`, `items.xml`, `recipes.xml`, `entityclasses.xml` derselben
Installation.

**Kein Patch-Ziel.** Dieses Finding begründet keinen Harmony-Patch (Projektregel 2); es prüft
zwei Annahmen des Plans, bevor XML dagegen geschrieben wird. Darum steht es **nicht** im
[patch-manifest](patch-manifest.md).

---

## 1. Der Plan nannte für D29 die falsche Datei

Plan-0001 WP6.3 schreibt: „Das ist belegt XML — `BlockDamage` ist eine Eigenschaft in
`entityclasses.xml`." **Das trifft nur für Sprengkörper und Fahrzeuge zu.**

`BlockDamage` kommt in `entityclasses.xml` **zehnmal** vor, und zwar hier:

| Wert | Entity-Klasse | was es ist |
|---|---|---|
| 500 | `zombieFatCop` | Explosion beim Platzen |
| 650 / 750 / 1000 | (Varianten derselben Reihe) | Explosion |
| 5000 | `zombieDemolition` | Explosion |
| 20 / 50 / 100 / 30 | `vehicleMinibike` u. a. | Fahrzeug rammt Block |
| 25 | `junkTurretSledge` | Geschütz |

Der **normale Nahkampf-Blockschaden** der Toten steht nicht dort, sondern am Angriffs-
*Gegenstand* in `items.xml`:

```
<item name="meleeHandZombie01">
    <passive_effect name="BlockDamage" operation="base_set" value="100"/>
```

`passive_effect name="BlockDamage"` kommt in `entityclasses.xml` **null**-mal vor.

**Folge für WP6.3:** D29 bleibt umsetzbar und bleibt reines XML — aber in `items.xml` an
`meleeHandZombie01`, nicht in `entityclasses.xml`. Die Sprengkörper-Werte (500 bzw. 5000)
sind davon unabhängig und sind genau die „Brecher-Typen", die D29 als Ausgleich nennt: sie
müssen **nicht** mitgesenkt werden. D29 selbst (weniger Blockschaden, mehr Gefahr für den
Spieler) ist davon nicht berührt — nur der Satz im Plan, welche Datei das trägt.

---

## 2. `PlantGrowing` trägt die Brenndauer — mit mehr Schaltern als der Plan kannte

`BlockPlantGrowing` erbt von `BlockPlant` erbt von `Block`; 12 Methoden, 20 Felder.

### Die XML-Schlüssel, vollständig

`BlockPlantGrowing::LateInit` lädt genau diese Zeichenketten aus
`<property class="PlantGrowing">` (aus den `string_literals` der Methode, in dieser Reihenfolge):

| Schlüssel | gelesen als | Standard aus `.ctor` |
|---|---|---|
| `Next` | Blockname → `BlockValue`; **unbekannter Name wirft eine `Exception`** | — |
| `IsGrowOnTopEnabled` | `StringParsers::ParseBool` | — |
| `GrowOnTop` | Blockname → `BlockValue` | — |
| `GrowthRate` | `StringParsers::ParseFloat` | — |
| `GrowthDeviation` | `StringParsers::ParseFloat` | (im `.ctor` gesetzt) |
| `FertileLevel` | `Int32::Parse` | **5** |
| `LightLevelStay` | `Int32::Parse` | (aus `BlockPlant`) |
| `LightLevelGrow` | `Int32::Parse` | **8** |
| `GrowIfAnythinOnTop` | `ParseBool` | **true** |
| `IsRandom` | `ParseBool` | **true** |

Zwei Dinge daran sind für WP6.5 neu:

- **Die Streuung heißt `GrowthDeviation`, nicht `IsRandom`.** Der Plan schrieb „`IsRandom` für
  Streuung". `IsRandom` ist der **Schalter**, `GrowthDeviation` die **Breite**:
  `addScheduledTick` ruft bei `isPlantGrowingRandom` ein `GameRandom::get_RandomGaussian`,
  multipliziert mit `growthDeviation`, `RoundToInt`, dann `Utils::FastClamp`. Ohne
  `GrowthDeviation` gibt es keine Streuung, auch mit `IsRandom="true"` nicht.
- **`GrowIfAnythinOnTop`** — der Tippfehler ist im Spiel, nicht hier. Wer `GrowIfAnythingOnTop`
  schreibt, schreibt einen Schlüssel, den `LateInit` nie liest, und merkt nichts.

### Was `GetTickRate` daraus macht

```
ulong BlockPlantGrowing::GetTickRate()
  fields: ldfld BlockPlantGrowing::growthRate | ldsfld BlockPlantGrowing::CropGrowthModifier
```

Die Brenndauer wird also mit einem **spielweiten statischen Faktor** `CropGrowthModifier`
multipliziert. Praktische Folge, die man sonst erst im Spieltest merkt: **wer die
Pflanzenwachstums-Einstellung des Servers dreht, dreht auch die Brenndauer unserer
Fackeln.** Das gehört in F-08 als bekannte Nebenwirkung.

`GrowthRate` ist nach dem Vanilla-Kommentar an `cropsGrowingMaster` eine Angabe **in Minuten**
(„this rate (in minutes) should be set no lower than 2").

### Die Bedingungen, in der Reihenfolge von `UpdateTick`

Aus der CIL-Spur von `BlockPlantGrowing::UpdateTick`:

1. `nextPlant.isair` → nichts zu werden, Ende.
2. `BlockPlant::CheckPlantAlive` — und das ist der scharfe Punkt: diese Methode ruft
   `Block::CanPlantStay`, und wenn die `false` sagt, folgt
   `WorldBase::SetBlockRPC(pos, BlockValue::Air)`. **Der Block geht dann nicht aus, er
   verschwindet.**
3. `ChunkCache.GetLight(pos + up)` gegen `lightLevelGrow` → zu dunkel heißt **nicht wachsen**
   (neuer `addScheduledTick`), nicht sterben.
4. `isPlantGrowingIfAnythingOnTop` → wenn `false`, blockiert ein Block darüber das Wachsen.
5. `GetBlock(pos + down)` und `BlockPlant::CanGrowOn` → der Block **darunter** entscheidet.
6. Erst dann wird aus dem Block `nextPlant`: Biom-Ersetzung, `rotation` und `meta` werden
   übernommen, `damage` auf das `MaxDamage` des neuen Materials skaliert.

`BlockPlant::CanGrowOn` vergleicht `MaterialBlock::FertileLevel` des Blocks darunter gegen
`BlockPlant::fertileLevel`. Mit `FertileLevel="0"` ist die Bedingung immer erfüllt —
Fruchtbarkeitsstufen sind nicht negativ.

`BlockPlant::CanPlantStay` liest `GetBlockLightValue(pos)`, `GetBlockLightValue(pos + up)`,
`WorldBase::IsOpenSkyAbove` und `CanGrowOn(pos - up)`. **Wie diese vier verknüpft sind, sagt
die CIL-Spur nicht** — sie enthält die Aufrufe, nicht die Sprünge. Das ist die Grenze dieses
Findings.

### Vanilla beantwortet die offene Frage selbst — zum Teil

Statt die Sprungstruktur zu raten: `plantedMushroom1` ist ein **vom Spieler setzbarer**
(`CreativeMode="Player"`) `PlantGrowing`-Block mit

```xml
<property class="PlantGrowing">
    <property name="LightLevelGrow" value="0" />
    <property name="LightLevelStay" value="0" />
    <property name="FertileLevel" value="0" />
    <property name="Next" value="plantedMushroom2" />
```

Pilze, die Spieler in dunkle Höhlen setzen und die dort wachsen. Damit ist belegt: **alle drei
Tore lassen sich mit `0` abschalten, und das Spiel liefert diese Kombination selbst aus.**
Weder Himmel noch Licht sind dann nötig. Dieselbe Kombination tragen `mushroomBiome1/3` und
`mushroomRadiated01/03`.

**Was damit nicht belegt ist:** ein Pilz steht auf Boden. Eine **Wandfackel hat Luft unter
sich**, und `UpdateTick` fragt `GetBlock(pos + down).isair` ab, bevor es `CanGrowOn` ruft —
was bei `isair` passiert, steht in der Verzweigung, die die Spur nicht zeigt.

**Folge für WP6.5:** die abbrennende Lichtquelle wird **bodenständig** gebaut (Kienspan im
Ständer, Feuerkorb), wo ein Block darunter selbstverständlich ist. Für die **Wandfackel** ist
es offen; das ist eine Entscheidung und keine Messung, und sie liegt beim Nutzer.

---

## 2a. Nachtrag: `PlantGrowing` an der Wandfackel kostet drei Dinge, nicht eines

Gemessen **nach** D64, weil die Frage erst beim Bauen aufkam: `wallTorchLightPlayer` trägt
schon eine Klasse, `TorchHeatMap`. Ein Block hat **genau eine** `Class` — `PlantGrowing`
ersetzt sie also, und damit die ganze Vererbungskette:

```
BlockTorchHeatMap : BlockTorch : BlockParticle
```

Was an dieser Kette hängt, Methode für Methode:

| Methode | was sie tut | bei `PlantGrowing` |
|---|---|---|
| `BlockTorchHeatMap::UpdateTick` | `GetAIDirector().NotifyActivity(…)` mit `Block::HeatMapStrength` | **weg — und das bleibt so** |
| `BlockTorch::getParticleOffset` | setzt die Flamme je `BlockValue::rotation` an die richtige Stelle | weg, aber **wirkungslos**: diese Blöcke melden kein `ParticleName` an |
| `BlockTorch::OnBlockPickedUp` | gibt beim Aufnehmen den Gegenstand zurück, mit `UseTimes` aus `meta`/`meta2` | weg, aber **ersetzt**: `CanPickup` steht schon im Block |

**`HeatMapStrength` ist ein Feld auf `Block`** und wird für jeden Block aus dem XML gelesen —
aber **gemeldet** wird es nur von `BlockTorchHeatMap::UpdateTick`. Eine Fackel ohne diese
Klasse trägt die Zahl also weiter im XML und tut nichts damit.

**Berichtigt am 2026-11-08, noch am selben Tag: zwei der drei Verluste sind keine.** Beim
Nachsehen der Blöcke selbst, statt nur der Klassen:

- **Aufnehmen ist schon da.** `wallTorchLight` trägt
  `CanPickup value="true" param1="meleeToolTorch"` und einen `drop event="Destroy"` auf
  denselben Gegenstand — beides **Block-Eigenschaften**, die die Klasse nicht berührt.
  `BlockTorch::OnBlockPickedUp` ergänzt das nur um `UseTimes` aus `meta`/`meta2`, und das
  braucht eine Fackel ohne Abnutzung nicht. `candleWallLight` (`param1="candle"`) und
  `candleTableLightPlayer` ebenso.
- **Die Flamme ist im Prefab, nicht in der Klasse.** Weder `wallTorchLight` noch
  `wallTorchLightPlayer` deklariert ein `ParticleName` — `BlockTorch::getParticleOffset`
  berechnet also den Versatz für ein Partikel, das diese Blöcke nie anmelden. Der Verlust ist
  rechnerisch, nicht sichtbar. (`campfire` macht es anders und deklariert
  `ParticleName="campfire"` — dort wäre es ein echter Verlust, weshalb die Feuerstelle ohnehin
  nicht umgedeutet wird.)

**Und das Licht bleibt an.** Das war die naheliegende Sorge, und sie ist unbegründet:
`BlockLight` ist die Klasse, die `LightLOD::SwitchOnOff` ruft und Intensität, Farbe, Schatten
und Reichweite setzt — aber **Wandfackel und Kerze benutzen sie gar nicht.** Beide tragen
`Class="TorchHeatMap"`, also `BlockTorchHeatMap : BlockTorch : BlockParticle`, und leuchten
trotzdem. Das Licht steckt im Prefab (`MainLight`) und ist voreingestellt an; `BlockLight`
existiert für **schaltbare** Lampen und setzt den Zustand in `meta`. Vanillas eigener Kommentar
an `lanternOld_01_Player` sagt dasselbe von der anderen Seite: *„Needs to have a blank class to
allow the light to turn on automatically when placed."* `PlantGrowing` ist in dieser Frage wie
eine leere Klasse — es fasst Licht nicht an.

**Offen bleibt genau dieser Punkt bei der Öllampe:** sie hatte bisher die *leere* Klasse, und
Vanillas Kommentar warnt vor einer nicht-leeren. `PlantGrowing` berührt Licht nicht, aber das
ist ein Schluss und keine Messung. WP6.6 muss eine Öllampe **unmittelbar nach dem Setzen**
ansehen.

**Der dritte Verlust bleibt, und er ist eine Spielmechanik:** Fackeln ziehen keine Schreier
mehr an. Das macht Basen sicherer — **und D29 macht sie im selben Arbeitspaket schon
sicherer.** Zwei Entlastungen des Spielers aus einem Paket, von denen nur eine beabsichtigt
war. Das gehört in den Balancing-Test WP6.7, und die Zahl in WP6.3 sollte erst danach
festgezogen werden.

`campfire` ist davon nicht betroffen: es trägt `Class="Campfire"` und hätte dasselbe Problem,
weshalb der **Feuerkorb ein eigener Block** werden muss und nicht die Feuerstelle umdeuten darf.

## 3. Was dieses Finding nicht behauptet

- Die CIL-Spuren von `mod700meta` enthalten **Aufrufe, Feldzugriffe und Zeichenketten, keine
  Sprünge**. Jede Aussage über *Reihenfolge* oben ist die Reihenfolge in der Spur; jede Aussage
  über *Bedingungen* ist aus den verglichenen Feldern abgeleitet. Wo das nicht reicht, steht es
  oben ausdrücklich dabei.
- Dass `FertileLevel="0"`, `LightLevelStay="0"` und `LightLevelGrow="0"` die Tore öffnen, ist
  aus Vanillas Pilzen **abgeleitet**, nicht im Spiel nachgemessen. Der Nachweis ist der
  Spieltest (WP6.6).
- Ob eine Wandfackel mit `PlantGrowing` abbrennt, verschwindet oder gar nichts tut, ist
  **ungeprüft**.
- Alle Zahlen gelten für V 3.40 b10. Ein Spiel-Update kann `CropGrowthModifier`, die
  Schlüsselnamen und `meleeHandZombie01` ändern; `mod700meta verify` ist dafür da.
