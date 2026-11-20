# WP8 — Nacht und Nebel: was `worldglobal.xml` und `biomes.xml` wirklich steuern

| | |
|---|---|
| Datum | 20. November 2026 |
| Build | V 3.40 b10, `Assembly-CSharp.dll` SHA-256 `cb54022c…9656c58` |
| Werkzeug | `mod700meta find-string` und `members --il` — **Aufrufe, Feldzugriffe, Zeichenketten, keine Verzweigungen und keine Arithmetik** |
| Feature | F-17 Bausteine B1 (Dunkelheit, Nebel) |
| Harmony-Patch | **keiner** — reines XML, das Patch-Manifest bleibt leer |

## 1 Wer die Himmelswerte liest

Genau **eine** Methode lädt die Namen aus `worldglobal.xml`: `WorldEnvironment::OnXMLChanged`
(gefunden über die Zeichenketten `ambientEquatorScale`, `ambientGroundScale`, `ambientMoon`,
`ambientInsideThreshold`, `fogPower`). Sie ruft elfmal `DynamicProperties::ParseVec` und
dreimal `ParseFloat` und füllt statische Felder `dataAmbient…`, `dataFogPow`, `dataFogWater`.

Beide Dateien stehen in der Liste der patchbaren Configs
([WP1-Befund](WP1-modlet-lader-und-xml-patcher.md)) und im ConfigsDump.

## 2 Wie das Umgebungslicht entsteht

`WorldEnvironment::AmbientSpectrumFrameUpdate` setzt dreimal `RenderSettings.ambient…Color`
— Himmel, Äquator, Boden — und liest dafür in dieser Reihenfolge:

1. `PlayerEntityStats::LightInsidePer`, `dataAmbientInsideThreshold`, `dataAmbientInsideSpeed`
   → `insideCurrent` (wie sehr der Spieler „drinnen" ist, mit `MoveTowards` geglättet).
2. `GamePrefs::GetFloat(195)`, dann `FastLerpUnclamped`, `FastMax`, `LerpUnclamped`,
   `FastLerp` → `brightnessInOutDayNight`. **195 ist `OptionsGfxBrightness`**, der
   Helligkeitsregler des Spielers.
3. `SkyManager::GetMoonAmbientScale` mit `dataAmbientMoon.x` und `.y`.
4. Je Farbe ein Paar aus `dataAmbient…Scale` und `dataAmbientInside…Scale`, über
   `LerpUnclamped` gemischt.

**Zwei Dinge daran sind hart:**

- `WorldEnvironment::cBrightnessMin` ist eine **Konstante mit dem Wert 0,2**. Zusammen mit
  dem `FastMax` in Schritt 2 liest sich das als Untergrenze der Helligkeit. *Schluss, nicht
  Messung:* die Konstante ist in den IL-Befehl eingebettet und in der Aufrufliste nicht zu
  sehen; dass genau sie im `FastMax` steht, ist die naheliegende Lesart.
- **Der Helligkeitsregler geht in dieselbe Rechnung ein.** Ein Spieler kann sich die Nacht
  aufhellen — auf seinem Bildschirm, unabhängig vom Server. XML ändert das nicht.

## 3 Der Mond

`SkyManager::GetMoonAmbientScale(float, float)` liest `moonBright` und `dayPercent` und ruft
`FastLerp`. `moonBright` wird in `SkyManager::Update` gesetzt, aus den statischen Tabellen
`sMoonPhases` und `sMoonBrights`.

`worldglobal.xml` kommentiert `ambientMoon` selbst mit `add, scale`.

*Schluss:* Mondanteil = Sockel + Mondhelle × Anteil, zum Tag hin ausgeblendet. Vanilla
`.8, .4` gäbe bei Neumond 0,8 und bei vollem Mond 1,2 — **wenn** `sMoonBrights` von 0 bis 1
läuft. Die Werte der Tabelle sind nicht gelesen (statische Feldinitialisierung).

## 4 Der Nebel

`WorldEnvironment::SpectrumsFrameUpdate` liest `dataFogPow` (`.y`, dann `.x`) zusammen mit
`dayPercent`, ruft `FastLerpUnclamped` und `Mathf::Pow`, danach
`WeatherManager/BiomeWeather::FogPercent`, und endet in `SkyManager::SetFogDensity`.

- `fogPower` ist damit ein **Exponent**, getrennt für Tag und Nacht.
- **Worauf** er wirkt, ist nicht zu lesen: der `Pow`-Aufruf steht *vor* `FogPercent`, die
  Basis kommt aus einer lokalen Variablen. Ob ein Wert unter 1 den Nebel nachts verdichtet
  oder ausdünnt, hängt davon ab, ob die Basis unter oder über 1 liegt. **Darum ist
  `fogPower` nicht angefasst.**
- Die Nebelstärke eines Wetters ist ein Prozentwert (`FogPercent`).

`biomes.xml`, Wurzel `/worldgeneration/biomes`. Fünf Land-Biome und `underwater`:

| Biom | Kulturzone (D43) | Nebel in Vanilla |
|---|---|---|
| `pine_forest` | Klosterland (Wald) | `default` 0–2 (prob 83), **`fog` 17–27 (prob 7)**, Regen 1–3 und 3–7 |
| `wasteland` | Moorland | `default`, `cold`, `hot` je 0–5; **kein Nebelwetter** |
| `burnt_forest` | Brandland | `default` 0–5; kein Nebelwetter |
| `snow` | Burgwall-Land | `default` 0–2, `fog` 9–18 (prob 8) |
| `desert` | Küste | `default` 0–3; kein Nebelwetter |

Vanillas dichtester Wert ist `twitch_fog` mit 35–45. Die Datei führt zwei Schreibweisen
nebeneinander: `range="a,b"` und die alte `min`/`max` (ihr eigener Kommentar nennt sie
„OLD format"). Die Summe der `prob` über die Wetter mit `prob > 0` ist in Wald und Moor
je 100; laut Dateikommentar wird ohnehin normalisiert.

**Ein Flusstal ist kein Biom.** F-17 und F-07 nennen „Moor und Flusstäler"; Vanilla hat
dafür keinen Knoten.

## 5 Was gebaut ist

`mod/700_60_Welt/Config/worldglobal.xml` — vier `<set>`, nur der Nachtwert:

| Eigenschaft | Vanilla | neu |
|---|---|---|
| `ambientEquatorScale` | `.7, .45` | `.7, .25` |
| `ambientGroundScale` | `.3, .05` | `.3, .02` |
| `ambientSkyScale` | `1, .7` | `1, .4` |
| `ambientMoon` | `.8, .4` | `.5, .7` |

`mod/700_60_Welt/Config/biomes.xml` — acht `<set>`:

| Biom | Wetter | Vanilla | neu |
|---|---|---|---|
| Wald | `default` Nebel | 0–2 | 1–5 |
| Wald | `default` prob | 83 | 76 |
| Wald | `fog` prob | 7 | 14 |
| Wald | `fog` Nebel | 17–27 | 20–32 |
| Moor | `default`, `cold`, `hot` Nebel | 0–5 | 6–14 |

**Alle zwölf Zahlen sind Setzungen.** Gemessen ist, *dass* sie wirken und *wo*; wie es
aussieht, nicht.

## 6 Nachweis

- Jeder der zwölf XPaths trifft in Vanilla **genau einen** Knoten (gezählt mit
  `SelectNodes` gegen `Data/Config`), und der alte Wert ist der erwartete.
- `kette-pruefen`: 392 → **404** XPaths, 0 unaufgelöst.
- **Gegenprobe (Projektregel 5):** dieselben zwei Dateien mit je einem falschen XPath
  (`biome[@name='moorland']`, `property[@name='ambientMond']`) → `kette-pruefen` meldet
  „XPath trifft nichts" zweimal, 2 rot, Exit 1. Mit den echten Dateien: 12 geprüft, 0 rot,
  Exit 0. Von Hand gelaufen am 20. November 2026, nicht in `gegenproben.ps1`.
- **Dabei aufgefallen:** übergibt man `-Patches` einen Pfad, den es nicht gibt (bei mir:
  zwei Pfade versehentlich als *eine* Zeichenkette), meldet `kette-pruefen`
  „0 XPaths … 0 rot → GREEN". Im normalen Lauf sucht das Skript seine Dateien selbst und
  ist davon nicht betroffen; als Lücke in Vertrag 04 vermerkt.

## 7 Grenzen

- **Im Spiel hat das niemand gesehen.** Für Licht gilt das schärfer als für jede Zahl
  bisher: ein Rezept ist gesperrt oder nicht, eine Nacht ist „zu dunkel" erst, wenn jemand
  hinsieht → Prüfliste 18.
- **Keine Arithmetik.** Die Formeln in §2 bis §4 sind aus der Reihenfolge von Aufrufen und
  Feldern erschlossen.
- **`ambientInside*` ist nicht angefasst.** Vanilla hebt das Licht unter einem Dach nachts
  an (`ambientInsideEquatorScale .55, 1.5`). Nach dem Absenken draußen kann ein dunkles Haus
  heller wirken als der Wald davor.
- **`fogPower`, und damit „abends dichter", ist nicht gebaut** (§4).
- **Der frühere Befund nennt die falsche Entscheidung.**
  [02-10-schnittstellen-kurzcheck.md](02-10-schnittstellen-kurzcheck.md) und F-17 schreiben
  „der Hebel für D16 (dunklere Nächte)". D16 ist die Mobilität; dunklere Nächte gehören zu
  D12. In F-17 berichtigt, der alte Befund bleibt als Stand seines Tages stehen.

## 8 WP8.3 — sichere Orte: die Wirkung hängt an der Kacheleinheit, nicht am Block

Gemessen am 20. November 2026, dieselben Werkzeuge, dieselbe Grenze.

### 8.1 Der Weg

`ActiveRadiusEffects` steht als Zeichenkette nur in `Block::.cctor`; der Wert landet im Feld
`Block::RadiusEffects` (ein `BlockRadiusEffect` mit `variable` und `radiusSq`). In den
durchsuchten Klassen (`Block`, `EntityAlive`, `EntityPlayerLocal`, `EntityBuffs`, `Chunk`)
wird das Feld an zwei Stellen gelesen, beide in `EntityPlayerLocal` — **das ganze Assembly
ist nicht durchsucht**, ein zweiter Leser anderswo ist nicht ausgeschlossen:

- `BlockRadiusEffectsTick` — aufgerufen aus `OnUpdateLive`. Ruft `Entity::GetBlockPosition`,
  `World::toChunkXZ`, `WorldBase::GetChunkSync`, **`Chunk::GetTileEntities`**, dann je
  Eintrag **`TileEntity::IsActive`**, `TileEntity::get_block`, `TileEntity::ToWorldPos` und
  schließlich `BlockRadiusEffectsApply`.
- `BlockRadiusEffectsApply(Block, Vector3)` — `Entity::GetDistanceSq` gegen `radiusSq`,
  dann `EntityBuffs::HasBuff` und `EntityBuffs::AddBuff` mit `variable`.

*Schluss:* die Wirkung entsteht nur an Blöcken, die eine **Kacheleinheit** haben, und nur,
wenn diese **aktiv** ist. Sie entsteht auf dem **Client** des Spielers.

### 8.2 Wer eine Kacheleinheit hat

| Klasse | Kacheleinheit | `IsActive` |
|---|---|---|
| `BlockWorkstation` (`Campfire`, `Forge` erben) | ja — nennt `TileEntity` 49-mal, `AddTileEntity` zweimal | `TileEntityWorkstation` beantwortet es selbst |
| `BlockLight` | ja (`TileEntityLight`) | **nicht selbst** — es gilt die Grundfassung, deren Antwort nicht gelesen ist |
| `BlockPlantGrowing`, `BlockPlant` | **nein** — 0 Nennungen von `TileEntity` | — |

Zehn Vanilla-Blöcke führen `ActiveRadiusEffects`: `campfire` (3), `forge` (5),
`chemistryStation` (3), `wallTorchLight` und `wallTorchLightPlayer` (2), zwei brennende
Fässer (3), `candleWallLight` und die Kürbislaterne (`buffCandleAOE`, 2) und ein
verstrahltes Fass.

### 8.3 Was daraus folgt — eine Berichtigung an WP6.4

Unser **Holzfeuer** (`blk700_holzfeuer`) ist `Class="PlantGrowing"`, weil das in V 3.40 der
einzige Weg ist, einen Block nach Zeit zu ersetzen (WP6.4). Es führt
`ActiveRadiusEffects="buffCampfireAOE,3"` — und hat keine Kacheleinheit. **Die Zeile wird
nie gelesen.** Das Holzfeuer leuchtet und verbrennt, wer hineintritt; es wärmt nicht.

Sein Text versprach „wärmt, wer nahe steht". Der Text ist berichtigt, die Zeile bleibt mit
einem Vermerk stehen, bis Prüfliste 19 den Schluss bestätigt.

### 8.4 Vanillas Bauform der Aura

`buffCampfireAOE` ist `hidden`, `stack_type ignore`, Dauer 1, und stößt mit
`onSelfBuffStart` `buffCampfireAOEEffect` an (sichtbar, `stack_type replace`, Dauer 2,
`HypothermalResist +20`). Vanillas eigener Kommentar: ohne den zweiten Buff flackert die
Anzeige. Das passt zu §8.1: angelegt wird nur, wenn der Spieler den Buff **nicht** trägt.

### 8.5 Was gebaut ist

- `mod/700_60_Welt/Config/buffs.xml`: `buff700_feuerstelle_aura` (unsichtbar, Bauform wie
  Vanilla) und `buff700_amfeuer` („Am Feuer": Kälteschutz +20 wie Vanilla, dazu
  `StaminaChangeOT perc_add .2` — Vanillas Wert für `buffCoffee`).
- `mod/700_60_Welt/Config/blocks.xml`: drei `<set>` — `campfire`, `forge`,
  `chemistryStation` zeigen auf unsere Aura, Radius wie Vanilla (3, 5, 3).
- Zwei Sprachzeilen, und die berichtigte Beschreibung des Holzfeuers.

### 8.6 Nachweis und Grenzen

- Drei XPaths mit je genau einem Treffer und dem erwarteten alten Wert; `kette-pruefen`
  404 → **408**.
- **Buff-Verweise prüft kein Werkzeug.** `kette-pruefen` kennt Gegenstände und Blöcke
  (weiter „23 eigene" Definitionen), keine Buffs. Die vier Verweise dieses Pakets sind von
  Hand aufgelöst (alle „eigen"), ein vertippter Name fiel als „UNBEKANNT" auf. Als Lücke
  in Vertrag 04 vermerkt.
- **`IsActive` heißt „brennt"** ist der naheliegende Schluss für eine Werkstatt, nicht
  gelesen → Prüfliste 19 (a).
- **Ob Wandfackeln wärmen**, ist offen (§8.2). Sie sind nicht angefasst.
- **+20 % ist eine Setzung** für WP9.

## 9 WP8.4 — Klang: die Lautstärke steht in keiner XML

Gemessen am 20. November 2026.

### 9.1 Was `sounds.xml` führt

2555 Klangknoten (`SoundDataNode`), jeder mit `AudioSource` (eine Unity-Vorlage, etwa
`@:Sounds/Prefabs/AudioSource_Creatures.prefab`), `AudioClip`-Einträgen und einer festen
Zeile aus `LocalCrouchVolumeScale`, `CrouchNoiseScale`, `NoiseScale`, `MaxVoices`,
`MaxRepeatRate`. Der Dateikopf erklärt alle Elemente.

**Ein Element für den Pegel gibt es nicht.** `NoiseScale` und `Noise` sind die Lautstärke
*für die KI* (Schleichanzeige, Wärmekarte), `LocalCrouchVolumeScale` gilt nur für den
eigenen, geduckten Spieler. Pegel und Reichweite eines Lauts liegen in der Vorlage, also in
einem Asset.

### 9.2 Wie oft ein Gegner Laut gibt

`entityclasses.xml` führt 27 verschiedene `Sound…`-Eigenschaften. Zwei sind Zeiten:

- `SoundRandomTime` → `EntityAlive::soundRandomTicks`. `GetSoundRandomTicks` würfelt daraus
  mit `GameRandom::RandomRange`; `OnUpdateEntity` zählt `soundDelayTicks` herunter und ruft
  danach `GetSoundAlert` oder `GetSoundRandom`. Vanillas Kommentar: „every 30/15 seconds".
- `SoundAlertTime` → `soundAlertTicks`, derselbe Weg; „x/2 to x seconds".

`SleeperNoiseToSenseSoundChance` wird in `CopyPropertiesFromEntityClass` in ein Feld
gleichen Namens kopiert.

Eigene Werte führen nur `zombieTemplateMale` (30 / 25 / .5), `zombieSteveCrawler` (20 / 15),
`animalZombieDog` (20 / 10) und die Händler-Vorlage. 22 Klassen erben unmittelbar von
`zombieTemplateMale`, neun weitere über `zombieTemplateShort`.

### 9.3 Was Vanilla an fernen Klängen hergibt

Gesucht in den Namen der 2555 Knoten nach Glocke, Wolf, Vogel, Wind, Schrei, Flüstern,
Ast: gefunden sind die 14 Wolfslaute (alle an ein Tier gebunden: `wolfroam`, `wolfalert` …)
und **ein** Glockenschlag (`churchbellhit`). Weinen, Raunen, Rufe, knackende Äste: nichts.

Abspielen ließe sich ein Klang aus XML: `buffs.xml` führt 184-mal `action="PlaySound"`,
dazu die Bedingungen `RandomRoll` (45), `IsSheltered` (32), `InBiome` (13), `TimeOfDay` (1).

### 9.4 Was gebaut ist

`mod/700_60_Welt/Config/entityclasses.xml`, sieben `<set>`:

| Klasse | `SoundRandomTime` | `SoundAlertTime` | Schläfer-Laut |
|---|---|---|---|
| `zombieTemplateMale` | 30 → 90 | 25 → 40 | .5 → .15 |
| `zombieSteveCrawler` | 20 → 60 | 15 → 24 | — |
| `animalZombieDog` | 20 → 60 | 10 → 16 | — |

Sieben XPaths mit je genau einem Treffer und dem erwarteten alten Wert; `kette-pruefen`
408 → **415**.

### 9.5 Grenzen

- **„Leiser" ist nicht gebaut, „seltener" ist es.** Der Pegel ist ein Asset.
- **Die Einheit der Zeiten ist Vanillas Kommentar entnommen**, nicht gelesen: der Code
  rechnet in Ticks, die Umrechnung ist nicht gelesen.
- **`subtitles.xml` führt 1336 Untertitel, alle für die fünf Vanilla-Händler.** Jede Zeile
  hat einen gesprochenen Klang dazu (`trader_hugh_greeting_01` …). Gegner-Untertitel gibt
  es nicht. Nicht Teil von WP8.4; im Plan als offener Punkt.
- **`SoundSense` ist nicht angefasst.** Was der Code mit einem leeren oder fehlenden
  Klangnamen tut, ist nicht gelesen.
- **Ferne Klänge sind nicht gebaut** — aus zwei Gründen, die beide im Entwurf stehen:
  ein Laut ohne Quelle ist nach F-17 ein Trugbild (B4, Phase 2, erst ab „Verängstigt"),
  und das Material sind ein Glockenschlag und Tierlaute, die ein Tier versprechen.
- **Zahlen sind Setzungen** → Prüfliste 20.
