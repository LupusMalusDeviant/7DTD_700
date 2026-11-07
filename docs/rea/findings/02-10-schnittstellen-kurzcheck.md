# Kurz-Check der Schnittstellen, Prio 2–10

**Stand:** 2026-11-07 · **Build:** V 3.40 b10 (D52) · **Quellen:** `Data/Config/*.xml` der
Installation und `mod700meta` gegen `Assembly-CSharp.dll`
([00-build-baseline.md](00-build-baseline.md), [tools/meta](../../../tools/meta/README.md))

## Was dieser Befund ist und was nicht

Der Handoff verlangt für Prio 2–10 einen **Kurz-Check, ob die Annahme grundsätzlich trägt** —
keine fertige Umsetzung. Entsprechend steht hier pro Feature eine Antwort auf die Leitfrage und
die Stelle, an der sie hängt. Was offen bleibt, steht ausdrücklich als offen da.

**Nichts hiervon ist im Spiel getestet.** Es sind gelesene Konfigurationsdateien und gelesene
Metadaten. Jede Aussage „geht per XML“ heißt: *die Vanilla-Dateien benutzen diesen Weg selbst* —
nicht: *wir haben es laufen sehen*. Der Beweis kommt mit dem Modlet in Phase 1.

Kein einziger Punkt hier begründet einen Harmony-Patch. Das Patch-Manifest bleibt leer.

---

## Ergebnis in einer Tabelle

| Prio | Feature | Antwort | Weg |
|---|---|---|---|
| 2 | F-21 Lernen | Attributbäume per XML, **Learning by Doing braucht C#** | kein Craft-Abschluss-Trigger in XML |
| 3 | F-08 Licht | **reines XML** | `PlantGrowing` als Vorbild |
| 4 | F-17 Grauen | Nacht/Nebel XML, **Lichtabfrage fehlt** | `worldglobal.xml`, Buff-Requirements |
| 5 | F-05 Handel | **reines XML** | `currency_item` |
| 6 | F-18 Belagerung | **reines XML** | `BlockDamage` pro Entity |
| 7 | F-07 Welt | **nicht reines XML** (D43 betroffen) | Biomnamen an 7 Stellen im Code |
| 8 | F-15 Wehr | **reines XML** (Variante A, D37) | Stromnetz umdeuten |
| 9 | F-02 Kampf | Schadensarten **vorhanden**, Richtung vorhanden | `DamageSource` |
| 10 | F-20 Wegsteine | **reines XML** | GameEvent-Block + `action class="Teleport"` |
| 10 | F-20 Banditen | Entity-Klasse **vorhanden** | `EntitySurvivor` + Fraktion `bandits` |
| 10 | F-13 Reittier | **nein, nicht in Phase 1** (Q18) | Fahrzeug ≠ Tier im Klassenbaum |

---

## Prio 2 — F-21 Lernen und Fortschritt

### Was in `progression.xml` steht

Acht `<attribute>`-Einträge, aber nur fünf davon sind echte Attribute. `attGeneralPerks`,
`attBooks` und `attCrafting` haben `min_level="0" max_level="0"` und sind reine Behälter, in denen
die Perks, Bücher und Handwerks-Stufen einsortiert sind. Dazu 59 `<perk>`, 16 `<skill>`,
24 `<crafting_skill>` und 152 `<book>`.

Das ist die gute Nachricht für D45: **die Struktur ist Daten, nicht Code.** Wer Attribute
umbenennt, hinzufügt oder entfernt, ändert eine XML-Datei.

### Wie hart hängt der Code an den fünf Vanilla-Attributen?

Fast gar nicht. Von den fünf Attributnamen kommt **ein einziger** im Code vor:

| Zeichenkette | Fundort | Bedeutung |
|---|---|---|
| `attFortitude` | `EntityPlayerLocal::Update` | eine Stelle, rein lokal |
| `attcrafting` (klein) | `XUiC_CategoryList::SetupCategoriesByWorkstation` | UI-Sortierung der Werkbank |
| `crafting_skill`, `crafting_skills` | nur `ProgressionFromXml::parseProgressionItem(s)` | das ist der Parser selbst |

`attPerception`, `attStrength`, `attAgility`, `attIntellect` tauchen **nirgends** im Code auf.
Die 2+1 Treffer sind Sonderfälle, nicht das Fundament. Eigene Attributbäume sind damit XML-Arbeit.

### Learning by Doing — hier reißt es

Gesucht war ein Auslöser, der beim **Abschluss eines Craft-Vorgangs** feuert und per XML
erreichbar ist. Den gibt es nicht. `buffs.xml` kennt reichlich `triggered_effect trigger="…"`,
aber keinen, der „Gegenstand fertig hergestellt“ bedeutet. Die Handwerks-Stufen werden
ausschließlich über Magazine (`<book>`) erhöht — das ist das Vanilla-Modell, und es ist das
Gegenteil von Learning by Doing.

**Folge:** F-21 ist der erste Kandidat für einen echten Harmony-Patch. Vorher muss das Ziel
belegt sein (Regel 2), und der Patch muss serverseitig sitzen. Das ist **nicht** Phase 1.

---

## Prio 3 — F-08 Licht und Feuer

`blocks.xml` liefert das Vorbild selbst. `cropsGrowingMaster`:

| Eigenschaft | Wert | Bedeutung |
|---|---|---|
| `Class` | `PlantGrowing` | Blockklasse mit Zeitlogik |
| `Next` | Zielblock | wohin gewechselt wird |
| `GrowthRate` | `63.0` | **Minuten**, laut Kommentar in der Datei nicht unter 2 setzen |
| `FertileLevel` | — | Bedingung am Untergrund |
| `IsRandom` | — | Streuung, damit nicht alles gleichzeitig umschlägt |

Eine Fackel, die nach N Minuten zu „Fackel, erloschen“ wird, ist damit genau dieselbe Mechanik
wie eine wachsende Pflanze: ein Block mit `Class="PlantGrowing"`, `Next` auf den erloschenen
Zustand und `GrowthRate` als Brenndauer. **Kein Patch, kein TileEntity, keine eigene Blockklasse.**

Offen: ob ein Nachlegen von Brennstoff (Zurücksetzen der Uhr) ohne TileEntity geht. Für die
MVP-Fassung „brennt ab, muss neu gesetzt werden“ ist das gleichgültig.

---

## Prio 4 — F-17 Grauen und Atmosphäre

### Die Nacht dunkler machen: XML

`worldglobal.xml` führt die Himmelswerte als **Tag-/Nacht-Paare**:

| Eigenschaft | Tag, Nacht |
|---|---|
| `ambientEquatorScale` | `.7, .45` |
| `ambientGroundScale` | `.3, .05` |
| `ambientSkyScale` | `1, .7` |
| `ambientMoon` | `.8, .4` |
| `fogPower` | `1, 1` |

Das ist der Hebel für D16 (dunklere Nächte) — eine Zahl, kein Patch. Nebel pro Biom (`<Fog>` mit
`range` und `prob`) ist ebenfalls XML. **Aber:** die Wetter-`Spectrum`-Einträge (`foggy`, `rainy`)
zeigen auf Unity-Assets. Ein *eigenes* Spektrum ist Phase-2-Arbeit, das Verschieben der
vorhandenen Werte nicht.

### Das Grauen-System: hier fehlt etwas

Die Bedingungen, die Buffs in `buffs.xml` auswerten können, decken einen Teil ab:

| vorhanden | fehlt |
|---|---|
| `TimeOfDay` — Nacht | **Lichtstärke am Spielerort** |
| `IsSheltered` — unter Dach | **Mitspieler in der Nähe** (nicht gefunden) |
| `RandomRoll` — Zufall | |
| `CVarCompare` — eigener Zähler | |
| `SandboxOptionBool` — Serveroption | |

„Im Dunkeln, allein, draußen" lässt sich also **nicht vollständig** als Buff-Bedingung schreiben.
Nacht + kein Dach + Zufall geht; „wie hell ist es hier" und „ist jemand bei mir" nicht.

**Folge für D18:** Das Grauen-System braucht entweder eine gröbere Definition (Nacht statt
Dunkelheit) oder C#. Die Entscheidung gehört in Phase 2, nicht hierher. Als Notiz im
Feature-Dokument vermerkt.

---

## Prio 5 — F-05 Handel

`traders.xml`: `currency_item="casinoCoin"`. Im Code kommt `casinoCoin` **an keiner Stelle** vor;
die einzige Fundstelle für `currency_item` ist `TradersFromXml::ParseNode`, also der Parser.

Die Währung ist damit vollständig austauschbar. Silberpfennige als Handelsgeld (D25) sind eine
Zeile XML. **Kein Patch.**

---

## Prio 6 — F-18 Belagerung

`BlockDamage` ist eine Eigenschaft in `entityclasses.xml`, pro Gegner gesetzt (Vanilla-Werte u. a.
750, 650, 5000). Wie viel Schaden ein Angreifer an Bauwerken anrichtet, ist damit pro Entity per
XML einstellbar — die Grundlage dafür, dass Seuchentote an einer Palisade anders arbeiten als an
einer Steinmauer. **Kein Patch.**

---

## Prio 7 — F-07 Welt und Kulturzonen · **berührt D43**

Die Biom-**Verteilung** ist XML (`biomes.xml`, `biomemap`-Grafik). Die Biom-**Namen** sind es
nicht. `mod700meta` findet die Vanilla-Biomnamen an sieben Stellen im Code:

| Fundort | Was dort passiert |
|---|---|
| `BiomeDefinition::.cctor` | statische Liste |
| `WeatherManager::.ctor` | Wetter pro Biomname |
| `WorldBuilder::.ctor` (zwei Stellen) | Weltgenerierung |
| `WorldBuilder::serializeDynamicProperties` | Speichern |
| `XUiC_WorldGenerationWindow::.cctor` | UI der Weltgenerierung |
| `DynamicMusic.ThreatLevelUtility::IsPlayerInSpookyBiome` | Musik |

**D43 sagt „Kulturzonen als Biome".** Das ist umsetzbar, aber nicht als Umbenennung: Wer
`pine_forest` in `Mark` umbenennt, bricht sieben Stellen, von der Weltgenerierung bis zum
Speicherformat.

**Empfehlung:** Die Vanilla-Biom-Kennungen als *technische* Namen behalten und nur die
angezeigten Namen, die Blöcke, die Bepflanzung und das Spawning umdeuten. Der Spieler sieht die
Mark, die Engine sieht `pine_forest`. Das ist reines XML und kostet nichts außer Disziplin in der
Doku. — **Diese Abweichung von D43 ist dem Nutzer vorzulegen, nicht still zu entscheiden**
(Projektregel 4).

---

## Prio 8 — F-15 Wehr und Volksmagie

D37 nennt zwei Varianten; **Variante A (das Stromnetz umdeuten) trägt.**

| Baustein | Vanilla | umgedeutet |
|---|---|---|
| `Class="Ranged"` am `autoTurret` | Geschützturm | Bannpfeil-Werfer |
| `RequiredPower="15"` | Strombedarf | Odem-Bedarf |
| `AmmoItem="ammo9mmBulletBall+tags(ammo9mm)"` | Munition per Tag | Glutpfeil |
| `FuelValue` am Item | Benzin | Bernstein, Glutstein |
| `OutputPerFuel` am Block | Generator-Ausbeute | Glutstein-Ausbeute |
| Klassen `Powered`, `PoweredLight`, `PoweredDoor`, `ElectricWire`, `BladeTrap` | Stromnetz | Odem-Leitung |

Das Netz ist also ein fertiges Leitungs-, Verbrauchs- und Reichweitensystem, das nur andere Namen
und andere Brennstoffe braucht. **Kein Patch.** Was nicht geprüft ist: ob ein eigenes Projektil
mit eigenem Partikel rein per XML geht — das hängt an Assets und gehört in Phase 2.

---

## Prio 9 — F-02 Kampf

### Schadensarten sind schon da

`EnumDamageTypes` enthält bereits `Piercing = 1`, `Slashing = 2`, `Bashing = 3`, `Crushing = 4`.
Stich, Schnitt und Wucht müssen nicht erfunden werden. Dazu trägt `DamageSource` ein
`FastTags<TagGroup/Global> DamageTypeTag` — der Tag-Weg für eigene Schadensarten steht offen.

### Der zentrale Schadenseingang

```
int EntityAlive::DamageEntity(DamageSource, int, bool, float)
```

`DamageSource` trägt alles, was „von vorn blocken" braucht:

| Mitglied | wofür |
|---|---|
| `UnityEngine.Vector3 direction`, `getDirection()` | **Richtung des Schlags** → Winkel zum Schild |
| `int ownerEntityId`, `CreatorEntityId`, `getEntityId()` | wer schlägt |
| `ItemValue AttackingItem` | womit |
| `FastTags<TagGroup/Global> DamageTypeTag` | Schadensart |
| `EnumBodyPartHit bodyParts`, `getHitTransformPosition()` | wohin |

**Die Hypothese trägt.** Ein Postfix auf `DamageEntity`, das die Richtung gegen die Blickrichtung
rechnet und einen CVar `shieldRaised` prüft, ist der ganze Mechanismus (Säule P5: so wenig C# wie
möglich). Damit ist F-02 das **zweite** Patch-Ziel — nach F-21, und ebenfalls nicht in Phase 1.
Ein Finding mit Soll-Signatur in `tools/meta/expect/` kommt, wenn der Patch ansteht.

---

## Prio 10 — F-20 und F-13

### Q19: Gibt es menschliche Gegner? **Ja, mehr als erwartet.**

`entityclasses.xml` liefert zwei fertige menschliche NPC-Klassen:

```
npcSurvivorTemplate   Class=EntitySurvivor · Faction=whiteriver
                      Mesh=Player/Male/player_maleRagdoll · Parent=Players
                      AIPackages="Human Basic, Human Melee"

npcSurvivorRanged     extends npcSurvivorTemplate
                      ItemsOnEnterGame=gunHandgunT1Pistol,ammo9mmBulletBall
                      AIPackages="Human Basic, Human Ranged"
```

Drei Dinge daran sind wichtig:

1. **`Mesh` zeigt auf das Spielermodell.** Ein menschlicher Gegner braucht also **kein neues
   Asset** — er benutzt, was das Spiel für den Spieler ohnehin lädt. Das war die große Unbekannte
   bei F-20 und sie ist weg.
2. **Die KI-Pakete `Human Basic`, `Human Melee`, `Human Ranged` sind in XML definiert**, nicht im
   Code. Nahkämpfer und Schütze gibt es fertig.
3. **`ItemsOnEnterGame` bestimmt die Bewaffnung per XML.** Ein Gegner mit Speer statt Pistole ist
   eine Zeile.

Die Fraktionsseite passt dazu. `npc.xml` definiert eine Fraktion `bandits` mit
`<relationship name="*" value="hate"/>`, und `whiteriver`, `duke` und `trader` erklären
ihrerseits ihr Verhältnis dazu. Im Code steht ein vollständiger `FactionManager`:

```
FactionManager/Relationship FactionManager::GetRelationshipTier(EntityAlive, EntityAlive)
float  FactionManager::GetRelationshipValue(EntityAlive, EntityAlive)
Faction FactionManager::GetFactionByName(string)
Faction FactionManager::CreateFaction(string, bool, string)
void   FactionManager::SetRelationship(byte, byte, sbyte)
```

**Fazit für F-20:** Räuber und Kultisten sind XML-Arbeit — Entity-Klassen von
`npcSurvivorTemplate` ableiten, `Faction` setzen, Ausrüstung über `ItemsOnEnterGame`, Feindschaft
über die Fraktionsbeziehung. Kein Patch. Dass im Vanilla-Stand *keine* Banditen-Entity ausgeliefert
wird, ändert daran nichts: die Klasse, die KI und die Fraktion sind da.

Nicht geprüft: wie die Spawnseite aussieht (`spawning.xml`, `entitygroups.xml` enthalten kein
`bandit`) und ob `EntitySurvivor` serverseitig sauber läuft. Das ist Phase-3-Arbeit (F-20 liegt
dort), hier zählt nur: die Annahme trägt.

### Teleport für Wegsteine: **reines XML, mit einem mitgelieferten Beispiel**

Zuerst das, was der Code anbietet:

```
void EntityPlayer::Teleport(UnityEngine.Vector3, float)
     EntityPlayer/OnPlayerTeleportDelegate   (add_/remove_PlayerTeleportedDelegates)
void EntityPlayer::InvokeTeleportDelegates()
     NetPackageEntityTeleport, NetPackageTeleportPlayer
```

Es gibt also einen Teleport samt Netzpaket **und** einen Delegaten, in den man sich einhängen
könnte, ohne zu patchen. Gebraucht wird beides nicht, denn:

`gameevents.xml` kennt Teleport als **deklarierbare Aktion**:

| Aktion | |
|---|---|
| `<action class="Teleport">` | an eine Stelle |
| `<action class="TeleportNearby">` | in die Nähe |
| `<action class="RandomTeleport">` | zufällig |
| `<action class="TeleportToTarget">` | zu einem Ziel |
| `<action class="TeleportToSpecial">` | an besondere Punkte |

Und `blocks.xml` kennt die Gegenseite: Blöcke mit `Class="GameEvent"` und
`ActivateEvent` / `TriggeredEvent` / `DamageEvent` lösen eine solche Abfolge aus. Das Spiel liefert
dafür sogar einen Testblock mit — `TriggeredEvent="test_action_teleport_up"`.

**Ein Wegstein ist damit:** ein Block mit `Class="GameEvent"`, `ActivateEvent="wegstein_reise"`,
dazu eine `action_sequence` mit `<action class="Teleport">`. Dass `buffs.xml` dasselbe über
`action="CallGameEvent"` anstoßen kann, gibt einen zweiten Weg, falls der Block-Weg klemmt.

Dazu kommen Bedingungen, die in den Abfolgen schon benutzt werden: `CVar`, `EventActive`,
`Gamestage`, `GroupLiveCount`, `HasBuff`, `HasBuffByTag`, `HasHeld`, `HasParty`, `HasSequenceLink`,
`HasSpawnedEntities`, `InQuestZone` und weitere. Die Lastprüfung („nur mit leichtem Gepäck") und
die Kosten sind damit abbildbar.

**Offen:** ob eine Bedingung „Seuchennacht läuft" existiert, um Wegsteine in der Horde-Nacht zu
sperren. Die Liste der Bedingungen ist nicht vollständig gelesen. Ohne eine solche Bedingung bleibt
der Umweg über ein CVar, das die Nacht setzt.

### Q18: Tier als Reittier? **Nein — und das ist kein XML-Problem.**

Der Klassenbaum trennt beides sauber:

```
EntityAlive ─┬─ EntityAnimal ──┬─ EntityAnimalRabbit
             │                 └─ EntityAnimalStag
             └─ EntityVehicle ─── EntityDriveable ─── EntityBicycle, …
```

Ein Tier ist **kein** Fahrzeug, und ein Fahrzeug ist kein Tier. Dazu braucht eine
Fahrzeug-Entity in `entityclasses.xml` ein `Prefab`, und `vehicles.xml` beschreibt dazu Chassis,
Räder (`steerAngleMax`, `motorTorque_turbo`, `brakeTorque`, `tiltAngleMax`) und Sitze
(`seat0`…`seat5`). Verknüpft wird über den **gleichen Namen** in beiden Dateien.

Ein Reitpferd wäre also ein Fahrzeug mit Pferdemodell, dessen Beine sich nicht bewegen, weil die
Physik Räder dreht. Das ist eine Asset- und Animationsaufgabe, keine XML-Aufgabe.

**Empfehlung:** Q18 für Phase 1 und 2 mit „nein" beantworten und als Notiz in F-13 führen. Falls
Reittiere später gewollt sind, ist der Weg ein `EntityDriveable`-Abkömmling mit eigenem Prefab —
Phase 4, mit Assets.

---

## Was daraus für den Plan folgt

1. **Phase 1 bleibt ohne Harmony-Patch.** Von zehn geprüften Annahmen brauchen acht keinen Patch.
   Die beiden, die einen brauchen (F-21 Learning by Doing, F-02 Schild), liegen in Phase 2 und 3.
2. **Zwei Entscheidungen gehören dem Nutzer vorgelegt**, bevor geplant wird: die Biom-Frage
   (D43, Prio 7) und wie weit Learning by Doing in F-21 gehen soll, wenn es C# kostet.
3. **Drei Hypothesen waren zu pessimistisch** und sparen Arbeit: Fackeln sind Pflanzen (F-08),
   das Stromnetz ist eine Odem-Leitung (F-15), Wegsteine sind ein GameEvent-Block (F-20).
4. **Eine Lücke bleibt offen:** es gibt keine Buff-Bedingung für Lichtstärke am Spielerort
   (F-17). Das Grauen-System ist damit nicht so billig wie gehofft.
5. **Das Patch-Manifest bleibt leer** und das ist richtig.
