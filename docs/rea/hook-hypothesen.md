# Hook-Hypothesen (UNGEPRÜFT)

> ⚠️ Alle Typ- und Methodennamen hier sind **Hypothesen** aus allgemeinem 7DTD-Modding-Wissen.
> Sie können in V 3.40 umbenannt, verschoben oder anders aufgebaut sein. **Nichts davon darf
> ungeprüft in einen Harmony-Patch.** Status wird nach dem REA-Lauf gepflegt:
> `?` ungeprüft · `◐` Typ existiert, Signatur offen · `✓` bestätigt (Finding-Link) · `✗` existiert nicht/anders

> **Stand 2026-11-07:** REA liefert an dieser `Assembly-CSharp.dll` **keine Member und keine
> Signaturen** — die Metadaten sprengen das Darstellungsbudget
> ([findings/00-rea-grenzen.md](findings/00-rea-grenzen.md)). Signaturen kommen seit D51 aus
> `mod700meta` ([tools/meta](../../tools/meta/README.md)); `✓` setzt voraus, dass die Signatur
> in einer Soll-Datei unter `tools/meta/expect/` steht und der `verify`-Lauf grün ist.

> **Prio 2–10 durchgelaufen (2026-11-07).** Elf Leitfragen beantwortet, Befund:
> [findings/02-10-schnittstellen-kurzcheck.md](findings/02-10-schnittstellen-kurzcheck.md).
> Acht von zehn Features brauchen **keinen** Harmony-Patch. Für die Kurz-Checks gilt `✓` ohne
> Soll-Datei: belegt sind dort gelesene Vanilla-XML-Dateien und gelesene Metadaten, **nicht**
> ein Lauf im Spiel. Soll-Signaturen kommen, wenn ein Patch wirklich ansteht.
> Zwei Punkte warten auf eine Entscheidung des Nutzers: **F-07** (D43, Biomnamen) und
> **F-21** (Learning by Doing kostet C#).

## F-00 — abgeschlossen

Alle Prio-1-Fragen beantwortet. Befunde:
[F-00-modloader-events-version.md](findings/F-00-modloader-events-version.md) ·
[F-00-modinfo-und-harmony.md](findings/F-00-modinfo-und-harmony.md).
Soll-Datei: `tools/meta/expect/f00.tsv` (12 Zeilen, grün).

| Status | Kandidat | Ergebnis |
|---|---|---|
| ✓ | `IModApi` / `InitMod(Mod)` | **Bestätigt**: `void IModApi::InitMod(Mod)`, einziger Aufrufer `Mod::InitModCode`. Einstiegsklasse braucht `public` + öffentlichen parameterlosen Konstruktor (`Activator.CreateInstance`). |
| ✓ | `ModEvents` | **Anders als vermutet**: 22 generische Event-Objekte mit Nutzdaten-Strukturen. Registrierung über `ModEvents/ModEventAbs`1::RegisterHandler(!0)`. Vier Events sind interruptible: `MainMenuOpening`, `PlayerLogin`, `GameMessage`, `ChatMessage`. |
| ✗ | `ConnectionManager`, `NetPackage*` (Auth/Login) | **Nicht nötig.** `ModEvents.PlayerLogin` ist interruptible (`EModEventResult.StopHandlersAndVanilla`) und trägt den Versions-Handshake ohne Patch. |
| ✓ | `Constants` / Versionsinfo-Klasse | `Constants.cVersionInformation` (Typ `VersionInformation`), dazu `cVersionMajor/Minor/Build`. Build-Guard über `VersionInformation::CompareToRunningBuild()` → `SameBuild`/`SameMinor`/`NewerMinor`/`OlderMinor`/`DifferentMajor`. **Kein Patch nötig.** Der Zahlenwert der Version ist noch nicht gelesen. |
| ✓ | `ModInfo.xml`-Format V2 | Wurzel `<xml>`, Felder als direkte Kinder mit `value="…"`. Gelesen werden genau: `Name` (Pflicht, Regex), `DisplayName` (Pflicht), `Version`, `Description`, `Author`, `Website`, `SkipWithAntiCheat`. **Das Altformat lädt nicht mehr** („V2 required to load mod“). |
| ✓ | Harmony-Bereitstellung | HarmonyX **2.13.0.0** vorgeladen in `Mods\0_TFP_Harmony\`, nicht in `Managed\`. Wir liefern kein eigenes `0Harmony.dll`. |
| ✓ | EAC-Verhalten | `Mod::LoadAssemblies` fragt `IAntiCheatClient::ClientAntiCheatEnabled`; mit aktivem EAC wird ein Mod mit eigenem Code nicht geladen. Spec 01 damit belegt. |

## F-02
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-9--f-02-kampf](findings/02-10-schnittstellen-kurzcheck.md#prio-9--f-02-kampf)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | `EntityAlive.DamageEntity(...)` | **`int EntityAlive::DamageEntity(DamageSource, int, bool, float)`** — der zentrale Eingang, wie vermutet. Server/Client noch offen. |
| ✓ | `DamageSource`, `DamageResponse` | **Ja.** `Vector3 direction` + `getDirection()`, `ownerEntityId`, `CreatorEntityId`, `ItemValue AttackingItem`, `EnumBodyPartHit bodyParts`, `getHitTransformPosition()`. Blocken von vorn ist rechenbar. |
| ? | `ItemActionMelee` / `ItemActionDynamicMelee` | Nahkampf-Aktionen; Hook für „Schild erhoben“-Zustand |
| ? | `ItemActionRanged` / `ItemActionLauncher` | Bogen-Basis; Pfeil-Projektil-Verhalten |
| ◐ | Buff/CVar-Check im Schadenspfad | Der Weg steht: Postfix auf `DamageEntity`, Richtung gegen Blickrichtung, CVar `shieldRaised`. Soll-Signatur fehlt noch (Phase 3). |
| ✓ | Schadens-Tags / `EnumDamageTypes` o. ä. | **Schon vorhanden:** `Piercing=1, Slashing=2, Bashing=3, Crushing=4`. Dazu trägt `DamageSource` ein `FastTags<TagGroup/Global> DamageTypeTag` — der Tag-Weg ist offen. |
| ? | Wurfspeer-Mechanik (Projektil, das als Item liegen bleibt) | Übertragbar auf Wurfaxt und Wurfmesser? |
| ? | Item-Qualität und Haltbarkeit (`ItemValue.Quality`, `UseTimes`) | Grenzen für Material- + Handwerksqualität (D23) |
| ◐ | **WP9.3 (2026-11-23)** Schadenspfad, zweite Hand, Wurf, Qualität | `DamageEntity` rechnet beim **Besitzer** des Getroffenen (`isEntityRemote` → sonst `NetPackageDamageEntity`) — für Spieler ist das ihr eigener Rechner. **Keine zweite Hand** im Typnamen. `ItemActionThrownWeapon` vorhanden, in `items.xml` nur auskommentiert am Steinspeer. `quality` `ushort`, `useTimes` `float`; Stufennamen in `QualityInfo`. Alles statisch; [Finding](findings/WP9-herstellen-und-schaden.md), Test S-33. |

## F-05 — abgeschlossen, reines XML
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-5--f-05-handel](findings/02-10-schnittstellen-kurzcheck.md#prio-5--f-05-handel)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | Currency-Item-Referenz (z. B. `casinoCoin`/`TraderInfo`) | **Per XML.** `traders.xml` setzt `currency_item="casinoCoin"`; `casinoCoin` steht an keiner Stelle im Code, `currency_item` nur in `TradersFromXml::ParseNode`. Silberpfennige (D25) sind eine Zeile. Kein Patch. |

## F-08 — abgeschlossen, reines XML
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-3--f-08-licht-und-feuer](findings/02-10-schnittstellen-kurzcheck.md#prio-3--f-08-licht-und-feuer)

| Status | Kandidat | Frage |
|---|---|---|
| ✗ | `BlockLight` / Lichtblock-Klassen | **Nicht nötig.** Der Zustandswechsel läuft über den Blockwechsel, nicht über einen Schalter am Block. |
| ✗ | `Block.UpdateTick(...)` / `WorldBlockTicker` | **Nicht nötig**, siehe nächste Zeile. |
| ◐ | `TileEntity*` | Für „brennt ab, muss neu gesetzt werden“ nicht nötig. Nur falls Brennstoff **nachgelegt** werden soll (Uhr zurücksetzen) — offen, nicht MVP. |
| ✓ | Pflanzen-Wachstumsblock (`BlockPlantGrowing`) | **Reines XML, Vorbild liegt in `blocks.xml`:** `cropsGrowingMaster` mit `Class="PlantGrowing"`, `Next`, `GrowthRate` (in **Minuten**), `FertileLevel`, `IsRandom`. Eine Fackel ist mechanisch eine Pflanze. Kein Patch. |

## F-09
| Status | Kandidat | Frage |
|---|---|---|
| ? | `SkyManager` / `WeatherManager` | Blutmond-Farbe und Himmel: Code oder Config? |
| ? | `AIDirector` + Horde-Night-Komponente | Wo wird die Horde-Nacht geplant (Vortags-Hook für Vorboten)? |
| ? | `GameUtils.IsBloodMoonTime(...)` o. ä. | Zentrale Abfrage für Seuchennacht-Logik |
| ◐ | **WP9.4 (2026-11-23)** Planer, Abfrage, Himmel | Planer: `AIDirectorBloodMoonComponent` (`Tick`, `CalcNextDay`, `StartBloodMoon`, `EndBloodMoon`). Abfrage **per XML:** Buff-Bedingung `IsBloodMoon` (→ `SkyManager::IsBloodMoonVisible`), dazu `GameStatInt` `BloodMoonDay`, `IsDayNumber`. Nebel je Biom: Wetter `bloodMoon` in `biomes.xml`. Rote Tönung: Spektrum `BloodMoon` (nicht in XML); ob ein Spektrum im Wetter sie ersetzt, zeigt S-34. [Finding](findings/WP9-licht-und-seuchennacht.md) |

## F-15
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-8--f-15-wehr-und-volksmagie](findings/02-10-schnittstellen-kurzcheck.md#prio-8--f-15-wehr-und-volksmagie)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | Turret-Blöcke / `TileEntityPoweredRangedTrap` o. ä. | **Variante A trägt (D37).** `autoTurret` hat `Class="Ranged"`, `RequiredPower="15"`, `AmmoItem="ammo9mmBulletBall+tags(ammo9mm)"`. Die Klassen `Powered`, `PoweredLight`, `PoweredDoor`, `ElectricWire`, `BladeTrap` sind ein fertiges Leitungs- und Verbrauchssystem. Kein Patch. |
| ✓ | `PowerManager`, `PowerItem`/`PowerSource`/`PowerGenerator` o. ä. | **Per XML:** `FuelValue` am Item, `OutputPerFuel` am Block. Bernstein und Glutstein als Brennstoff sind Zahlen in XML. |
| ◐ | Turret-Munition / Projektil-Definition | Munition per Tag ist belegt (`AmmoItem` mit `+tags(…)`). Ein **eigenes** Projektil mit eigenem Partikel hängt an Assets — Phase 2, nicht geprüft. |
| ? | `ItemActionLauncher` / `ItemActionProjectile` | Basis für Zauber-Items (Glutpfeil): Projektil, Partikel, Schaden per XML |
| ? | KI-Zielwahl / Pfadfindung (`EAI*`) | Gibt es eine Möglichkeit, eine „Meide-Zone“ für Bannkreis zu setzen? Sonst Fallback-Aura |
| ◐ | **WP9.5 (2026-11-23)** Odem-Kosten, Projektil, Meide-Zone, Plätze, Attribut | **Kosten per XML:** `<requirement>` in `<action>` → `ItemAction.ExecutionRequirements`, geprüft in `CanExecute`. Projektil-Klassen da (Partikel = Asset). **Keine Meide-Zone** (31 `EAI*`, nur `EAIRunawayFromEntity` vor Wesen) → Aura. Amulett: vier `BiomeBadge`-Plätze. Fenster: 8 Kategorie-Felder, 9. per XUi. [Finding](findings/WP9-odem-und-verderb.md) |
| ? | Item-Modifier-Slots (`ItemClassModifier`) | Grenzen für Runen als Waffen- bzw. Rüstungs-Mods; Accessoire-Slot vorhanden? |

## F-07 — **berührt D43, Nutzerentscheidung offen**
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-7--f-07-welt-und-kulturzonen--berührt-d43](findings/02-10-schnittstellen-kurzcheck.md#prio-7--f-07-welt-und-kulturzonen--berührt-d43)

| Status | Kandidat | Frage |
|---|---|---|
| ✗ | RWG-Biomverteilung (`WorldBuilder`, Biom-Definitionen) | **Verteilung ja, Namen nein.** Die Vanilla-Biomnamen stehen an sieben Stellen im Code: `BiomeDefinition::.cctor`, `WeatherManager::.ctor`, `WorldBuilder::.ctor` (2×), `WorldBuilder::serializeDynamicProperties`, `XUiC_WorldGenerationWindow::.cctor`, `DynamicMusic.ThreatLevelUtility::IsPlayerInSpookyBiome`. Umbenennen bricht Weltgenerierung und Speicherformat. Empfehlung: Kennungen behalten, nur umdeuten — **weicht von D43 ab, muss der Nutzer entscheiden**. |

## F-13
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#q18-tier-als-reittier-nein--und-das-ist-kein-xml-problem](findings/02-10-schnittstellen-kurzcheck.md#prio-10--f-20-und-f-13)

| Status | Kandidat | Frage |
|---|---|---|
| ✗ | `EntityVehicle` / `Vehicle` | **Q18: nein, nicht per XML.** Der Klassenbaum trennt beides: `EntityAlive` → `EntityAnimal` (Rabbit, Stag) gegen `EntityAlive` → `EntityVehicle` → `EntityDriveable` → `EntityBicycle` … Ein Fahrzeug braucht ein `Prefab` mit Chassis, Rädern und Sitzen (`seat0`…`seat5` in `vehicles.xml`, verknüpft über den gleichen Namen). Ein Reitpferd wäre ein Fahrzeug mit Pferdemodell und Radphysik: Asset- und Animationsarbeit, Phase 4. |
| ? | `EntityAnimal*`, Folge-KI (`EAI*`) | Folgen-Verhalten für Packtier |
| ? | Gyrocopter-Treibstofflogik | Ersetzbar durch Odem-Verbrauch (Hexenbesen)? |
| ✓ | Teleport-Mechanik (z. B. Admin-Teleport, `TeleportPlayer`) | **Reines XML, Beispiel liegt im Spiel.** `gameevents.xml` kennt `<action class="Teleport">` (dazu `TeleportNearby`, `RandomTeleport`, `TeleportToTarget`, `TeleportToSpecial`); `blocks.xml` kennt Blöcke mit `Class="GameEvent"` und `ActivateEvent`/`TriggeredEvent` — Vanilla liefert einen Testblock mit `TriggeredEvent="test_action_teleport_up"`. Im Code vorhanden, aber nicht gebraucht: `EntityPlayer::Teleport(Vector3, float)`, `PlayerTeleportedDelegates`, `NetPackageTeleportPlayer`. Lastprüfung über die Bedingungen (`CVar`, `HasHeld`, `HasBuff`, …). **Offen:** eine Bedingung „Seuchennacht läuft“ ist nicht belegt; Umweg wäre ein CVar. |

## F-14
| Status | Kandidat | Frage |
|---|---|---|
| ? | `EntityNPC`, `EntityTrader` | NPC-Basis, Persistenz, Netz |

## F-17
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-4--f-17-grauen-und-atmosphäre](findings/02-10-schnittstellen-kurzcheck.md#prio-4--f-17-grauen-und-atmosphäre)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | `SkyManager`, `WeatherManager`, Biome-Weather-Definitionen | **Per XML.** `worldglobal.xml` führt Tag-/Nacht-Paare: `ambientEquatorScale .7,.45`, `ambientGroundScale .3,.05`, `ambientSkyScale 1,.7`, `ambientMoon .8,.4`, `fogPower 1,1`. Nebel pro Biom (`<Fog range prob>`) ebenfalls XML. D16 ist eine Zahl, kein Patch. Ein **eigenes** `Spectrum` (`foggy`, `rainy` zeigen auf Assets) ist Phase 2. |
| ~~✗~~ ✓ | Licht-Abfrage am Spielerort (z. B. `LightManager`, Block-Lichtwerte) | ~~**Keine Buff-Bedingung für Lichtstärke gefunden.** Das Grauen-System kann „dunkel“ nicht als Bedingung prüfen, nur „Nacht“.~~ **Berichtigt WP9.4 (2026-11-23):** die Buff-Bedingung **`CompareLightLevel`** gibt es (liest `Entity::GetLightBrightness()`); Vanilla benutzt sie nur nicht, darum fehlte sie in der Sammlung aus `buffs.xml`. „Mitspieler in der Nähe" über einen Buff mit `target="selfAOE"`/`selfOtherPlayers` und `IsAlly`. Beides XML, im Spiel S-34. [Finding](findings/WP9-licht-und-seuchennacht.md) |
| ◐ | Buff-Requirements (`Requirements`-Klassen) | **Teilweise.** Vorhanden: `TimeOfDay`, `IsSheltered`, `RandomRoll`, `CVarCompare`, `SandboxOptionBool`. Nicht gefunden: Lichtstärke, „Mitspieler in der Nähe“. „Im Dunkeln, allein, draußen“ geht damit **nicht** vollständig per XML — Entscheidung zu D18 gehört in Phase 2. |

## F-18 — abgeschlossen, reines XML
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-6--f-18-belagerung](findings/02-10-schnittstellen-kurzcheck.md#prio-6--f-18-belagerung)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | Schaden an Bauwerken pro Gegner | **Per XML.** `BlockDamage` ist eine Eigenschaft in `entityclasses.xml`, pro Gegner gesetzt (Vanilla u. a. 750, 650, 5000). Dass Seuchentote an einer Palisade anders arbeiten als an einer Steinmauer, ist eine Zahl. Kein Patch. |
| ? | `AIDirector` + Wandering-Horde-Komponente | Hook für Bedrohungs-Direktor (Pirscher, Wanderzug) ohne den Vanilla-Director zu ersetzen |
| ? | Client-seitiges Sound-Abspielen (`Manager.Play…`/Audio-Manager) | Trugbild-Sounds nur auf dem lokalen Client abspielen |
| ? | Zombie-Sleeper-/Schlafverhalten in POIs | Basis für „Totsteller“ (liegende Leichen, die aufstehen) |

## F-19
| Status | Kandidat | Frage |
|---|---|---|
| ? | Item-Verfall / Zeitstempel an `ItemValue` | Gibt es einen Verderb-Mechanismus, oder braucht es eigene Metadaten am Stack? |
| ✓ | **WP9.5 (2026-11-23)** Verderb | **Kein** Verderb-Mechanismus. Metadaten am Stapel gibt es (`ItemValue::SetMetadata(string, float)`, XML `SetItemMetaFloat`/`CompareItemMetaFloat`), aber keinen Zeitwert in XML und keinen Takt für Stapel im Rucksack. Verderb nach Zeit braucht C#. [Finding](findings/WP9-odem-und-verderb.md) |
| ? | Tier-KI friedlich + Bindung an Bereich | Grundlage für Pferch-Haltung |

## F-20
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#q19-gibt-es-menschliche-gegner-ja-mehr-als-erwartet](findings/02-10-schnittstellen-kurzcheck.md#prio-10--f-20-und-f-13)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | Banditen / menschliche Gegner in V 3.40 (Q19) | **Ja, zwei fertige Klassen in `entityclasses.xml`:** `npcSurvivorTemplate` (`Class="EntitySurvivor"`, `AIPackages="Human Basic, Human Melee"`, **`Mesh="Player/Male/player_maleRagdoll"` — kein neues Asset nötig**) und `npcSurvivorRanged` (`AIPackages="Human Basic, Human Ranged"`, Bewaffnung über `ItemsOnEnterGame`). Die KI-Pakete sind in XML definiert. Räuber sind XML-Arbeit, kein Patch. Nicht geprüft: Spawning (`spawning.xml`/`entitygroups.xml` kennen kein `bandit`) und Server-Verhalten. |
| ✓ | Fraktionen (`FactionManager`) | **Vorhanden und vollständig.** `npc.xml` definiert eine Fraktion `bandits` mit `<relationship name="*" value="hate"/>`; `whiteriver`, `duke`, `trader` erklären ihr Verhältnis dazu. Im Code: `GetRelationshipTier(EntityAlive, EntityAlive)`, `GetRelationshipValue`, `GetFactionByName(string)`, `CreateFaction(string, bool, string)`, `SetRelationship(byte, byte, sbyte)`. Kultisten als eigene Fraktion gehen per XML. |

## F-21 — **Nutzerentscheidung offen**
Kurz-Check: [02-10-schnittstellen-kurzcheck.md#prio-2--f-21-lernen-und-fortschritt](findings/02-10-schnittstellen-kurzcheck.md#prio-2--f-21-lernen-und-fortschritt)

| Status | Kandidat | Frage |
|---|---|---|
| ✓ | `Progression`, `ProgressionClass`, Attribute/Perks | **Fast gar nicht.** `progression.xml` führt 8 `<attribute>` (5 echte + `attGeneralPerks`/`attBooks`/`attCrafting` als Behälter mit `min_level="0" max_level="0"`), 59 Perks, 16 Skills, 24 `crafting_skill`, 152 Bücher. Im Code steht von den fünf Attributnamen **nur `attFortitude`**, einmal, in `EntityPlayerLocal::Update`; dazu `attcrafting` in `XUiC_CategoryList::SetupCategoriesByWorkstation`. Eigene Bäume (D45) sind XML-Arbeit. |
| ✓ | Crafting-Skills (Magazin-Fortschritt) | Datenmodell ist XML; `crafting_skill(s)` kommt im Code nur im Parser vor (`ProgressionFromXml::parseProgressionItem(s)`). Erhöht wird ausschließlich über Magazine (`<book>`). |
| ✗ | Abschluss eines Craft-Vorgangs (`XUiC_RecipeStack`/Workstation-Abschluss, Trigger-Events wie `onSelfItemCrafted`) | **Es gibt keinen XML-Auslöser „Gegenstand fertig hergestellt“.** `buffs.xml` hat viele `triggered_effect trigger="…"`, aber keinen dafür. **Learning by Doing kostet damit C#** — erstes Patch-Ziel des Projekts, Phase 2, nicht Phase 1. Wie weit es gehen soll, muss der Nutzer entscheiden. |
| ✓ | **Berichtigung WP9.3 (2026-11-23):** Herstell-Zähler | Kein Auslöser, aber ein **Zähler**: Vanilla setzt beim Spieler `_craftCount_<Gegenstand>` (`XUiC_RecipeStack::giveExp`, `EntityPlayerLocal::GiveExp`). Ein Buff liest ihn per `CVarCompare` und hebt per `AddProgressionLevel`. `onSelfItemCrafted` (Enum 84) existiert, wird aber nicht ausgelöst (*Hook Up*). Learning by Doing beim Herstellen kostet damit **sehr wahrscheinlich kein C#**. [Finding](findings/WP9-herstellen-und-schaden.md) |
