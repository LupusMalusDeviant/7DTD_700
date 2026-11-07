# F-00 — Mod-Lader, Einstiegspunkt, ModEvents und Laufzeit-Version

| Build | Assembly SHA-256 | MVID | Datum |
|---|---|---|---|
| Steam 26309840 (public) | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` | 2026-11-07 |

Werkzeug: `mod700meta members` / `verify` (siehe [tools/meta](../../../tools/meta/README.md)), nicht REA —
REA liefert an dieser Assembly keine Member, siehe [00-rea-grenzen.md](00-rea-grenzen.md).
Alle Signaturen unten sind durch `mod700meta verify … --expect tools/meta/expect/f00.tsv`
gegengeprüft: 12 von 12 Zeilen grün.

## Frage

Prio 1 der Übergabe: Signatur des Einstiegspunkts, welche `ModEvents` es gibt, ob ein
Versions-Handshake möglich ist und wo die Spielversion zur Laufzeit steht.

## Ergebnis

### 1. Einstiegspunkt

| Typ | Member | Signatur | Netz | Evidenz |
|---|---|---|---|---|
| `IModApi` | `InitMod` | `void IModApi::InitMod(Mod)` | S+C | `mod700meta members --type IModApi --callers` |
| `Mod` | `InitModCode` | `bool Mod::InitModCode()` | S+C | einziger Aufrufer von `IModApi::InitMod` (54 940 Methodenkörper durchlaufen) |

Die Hypothese `IModApi` / `InitMod(Mod)` ist damit **bestätigt**. `IModApi` ist ein
`public interface` mit genau dieser einen Methode.

So findet der Lader unsere Klasse (`Mod::InitModCode`, Aufrufkette und Protokolltexte):

1. über alle in `Mod.AllAssemblies` geladenen Assemblies iterieren
2. `System.Reflection.Assembly::GetTypes()`
3. `System.Type::IsAssignableFrom` gegen `typeof(IModApi)`
4. `System.Activator::CreateInstance`
5. `callvirt IModApi::InitMod`

**Folge für uns:** Die Einstiegsklasse muss `public` und nicht abstrakt sein und einen
**öffentlichen parameterlosen Konstruktor** haben — `Activator.CreateInstance` wird ohne
Argumente aufgerufen.

Protokolltexte, an denen der Smoke-Test sich festmachen kann (wörtliche Zeichenketten
aus `InitModCode`):

```
[MODS]   Initializing mod <Name>
[MODS]     Found ModAPI in assembly <Assembly>, creating instance
[MODS]     Initialized code in mod '<Name>' in assembly <Assembly>
[MODS]     No ModAPI found in mod DLLs            ← Fehlerfall
[MODS]     Failed initializing ModAPI instance on mod '<Name>'
```

### 2. ModInfo.xml: welche Felder der Lader wirklich liest

Aus den Zeichenketten und Aufrufen von `Mod::parseModInfoV2`
(`static Mod Mod::parseModInfoV2(string, string, System.Xml.Linq.XElement)`) — jedes Feld
wird über `Mod::getElementAttributeValue(string, XElement, string, bool)` geholt, das das
Attribut **`value`** liest:

| Feld | Pflicht | Prüfung im Lader |
|---|---|---|
| `Name` | **ja** | nicht leer **und** gegen `Mod.nameValidationRegex`, Muster **`^[0-9a-zA-Z_\-]+$`** (aus `Mod::.cctor`: `ldc.i4.8` → `RegexOptions.Compiled`, dann `newobj Regex::.ctor`, `stsfld Mod::nameValidationRegex`). Also **keine Leerzeichen, Punkte oder Sonderzeichen** außer `_` und `-`. Sonst Fehler „does not define a valid non-empty Name ({1}), ignoring“ und der Mod lädt nicht. `7DTD_700` besteht die Prüfung. |
| `DisplayName` | **ja** | nicht leer; sonst „does not define a non-empty DisplayName, ignoring“ |
| `Version` | empfohlen | `System.Version::TryParse`; schlägt es fehl: Warnung „does not define a valid Version. Please consider updating it for future compatibility.“ — lädt aber |
| `Description` | nein | — |
| `Author` | nein | — |
| `Website` | nein | — |
| `SkipWithAntiCheat` | nein | `StringParsers::TryParseBool`; unlesbar → Warnung und `false` |

**Mehr liest V2 nicht.** `Mod` hat zwar die Eigenschaften `AntiCheatCompatible` und
`GameConfigMod`, aber `parseModInfoV2` setzt sie **nicht** — sie entstehen anderswo
(`Mod::DetectContents`). Eine Abhängigkeitsangabe für andere Mods gibt es in V2 nicht.

**Das Altformat lädt nicht mehr.** `Mod::parseModInfoV1(string, string, string, XmlFile)`
protokolliert nur noch `"/ModInfo.xml in legacy format. V2 required to load mod"` und bricht
ab. `Mod::LoadDefinitionFromFolder` holt `XDocument::get_Root`, sucht darin ein Element
`"ModInfo"` und verzweigt dann nach V2 oder V1.

Zusammen mit der mitgelieferten Originaldatei (siehe
[F-00-modinfo-und-harmony.md](F-00-modinfo-und-harmony.md)) heißt das: Wurzel `<xml>`, Felder
als **direkte** Kinder. Dass die Verzweigung genau so läuft — vorhandenes `<ModInfo>`-Kind →
Altformat, sonst V2 — ist aus der Aufrufreihenfolge **erschlossen**, nicht aus der
Verzweigungslogik gelesen; die Originaldatei belegt aber, welche Form lädt.

### 3. EAC-Verhalten ist belegt

`Mod::LoadAssemblies()` (`Mod/EModLoadState Mod::LoadAssemblies()`) sammelt alle `*.dll` im
Mod-Ordner und fragt dann
`GameManager::get_IsDedicatedServer`, `Platform.PlatformManager::get_MultiPlatform`,
`Platform.IPlatform::get_AntiCheatClient` und `Platform.IAntiCheatClient::ClientAntiCheatEnabled` ab:

| Lage | Protokoll |
|---|---|
| EAC an, `SkipWithAntiCheat=true` | `[MODS]     AntiCheat enabled, mod skipped because it is set not to load` |
| EAC an, `AntiCheatCompatible=false` | `[MODS]     Mod contains custom code, AntiCheat needs to be disabled to load it!` |
| sonst | `[MODS]     Loaded assembly <…>` |

Damit ist Spec 01 („EAC muss aus sein, sobald die C#-DLL geladen wird“) **belegt** und nicht
mehr nur angenommen.

### 4. ModEvents: 22 Events, neue Form in V 3.40

`ModEvents` ist eine `public static class` mit 22 statischen Feldern. Die Hypothese ging von
`RegisterHandler` mit Delegaten je Event aus; tatsächlich sind es **generische Event-Objekte
mit typisierten Nutzdaten-Strukturen**:

| Typ | Signatur |
|---|---|
| `ModEvents/ModEventAbs`1` | `void RegisterHandler(!0)` · `void UnregisterHandler(!0)` · `.ctor(string)` |
| `ModEvents/ModEvent`1` | erbt `ModEventAbs`1<ModEventHandlerDelegate`1<!0>>` · `void Invoke(!0&)` |
| `ModEvents/ModEventInterruptible`1` | erbt `ModEventAbs`1<ModEventInterruptibleHandlerDelegate`1<!0>>` · `System.ValueTuple`2<ModEvents/EModEventResult, Mod> Invoke(!0&)` |

`ModEvents/EModEventResult`: `Continue`, `StopHandlersRunVanilla`, `StopHandlersAndVanilla`.

Die 22 Events, jeweils mit ihrer Nutzdaten-Struktur `ModEvents/S…Data`:

| Event | Art |
|---|---|
| `GameFocus`, `GameAwake`, `GameStarting`, `MainMenuOpened`, `GameStartDone`, `CreateWorldDone`, `GameUpdate`, `WorldShuttingDown`, `GameShutdown`, `ServerRegistered`, `UnityUpdate` | `ModEvent` |
| `PlayerJoinedGame`, `PlayerSpawning`, `PlayerSpawnedInWorld`, `PlayerDisconnected`, `SavePlayerData`, `CalcChunkColorsDone`, `EntityKilled` | `ModEvent` |
| `MainMenuOpening`, `PlayerLogin`, `GameMessage`, `ChatMessage` | **`ModEventInterruptible`** |

### 5. Versions-Handshake braucht keinen Harmony-Patch

`PlayerLogin` ist **interruptible**: ein Handler kann `StopHandlersAndVanilla` zurückgeben und
damit den Login abbrechen. Die Hypothese „`ConnectionManager` / `NetPackage*` patchen“ ist
damit **gegenstandslos** — der Handshake geht über die öffentliche Mod-API. Das ist Säule P5
in Reinform.

### 6. Build-Guard braucht auch keinen Harmony-Patch

| Typ | Member | Signatur |
|---|---|---|
| `VersionInformation` | `CompareToRunningBuild` | `VersionInformation/EVersionComparisonResult VersionInformation::CompareToRunningBuild()` |
| `VersionInformation` | `TryParseSerializedString` | `static bool VersionInformation::TryParseSerializedString(string, VersionInformation&)` |
| `VersionInformation` | `.ctor` | `void VersionInformation::.ctor(VersionInformation/EGameReleaseType, int, int, int)` |

Felder von `VersionInformation`: `ReleaseType`, `Major`, `Minor`, `Build`, `IsValid`,
`NumericalRepresentation`, `ShortString`, `LongStringNoBuild`, `LongString`,
`SerializableString`, `Version` (`System.Version`).

`VersionInformation/EVersionComparisonResult`: `SameBuild`, `SameMinor`, `NewerMinor`,
`OlderMinor`, `DifferentMajor`.
`VersionInformation/EGameReleaseType`: `Alpha = 0`, `V = 1` (Werte aus der Constant-Tabelle) —
das „V“ in Versionsangaben wie „V 3.40“ ist dieser Release-Typ.

Die laufende Version steht in `Constants.cVersionInformation` (statisches Feld, in
`Constants::.cctor` per `newobj VersionInformation::.ctor` gesetzt), daneben
`Constants.cVersionMajor`, `cVersionMinor`, `cVersionBuild`, `cProductAbbrev`.

**Damit braucht der Build-Guard aus F-00 keinen Patch:** getestete Version als
`VersionInformation` bauen, `CompareToRunningBuild()` aufrufen und bei allem außer `SameBuild`
bzw. `SameMinor` eine Warnung ins Protokoll schreiben.

## Patch-Empfehlung

**Keine.** F-00 kommt vollständig ohne Harmony-Patch aus:

| F-00-Teil | Weg | statt |
|---|---|---|
| Einstiegspunkt | `IModApi.InitMod(Mod)` | — |
| Versions-Handshake | `ModEvents.PlayerLogin` (interruptible) | Patch auf `ConnectionManager` |
| Build-Guard | `VersionInformation.CompareToRunningBuild()` | Patch auf Versionsabfrage |
| Protokoll-Präfix `[700]` | `Log::Out` / `Log::Warning` / `Log::Error` | — |

Das Patch-Manifest bleibt für F-00 leer. Der erste echte Eintrag kommt mit F-08.

## Offene Punkte / Limitierungen

- **Die Spielversion ist gelesen und entschieden** (`mod700meta --il`, Werkzeug am selben Tag um
  Zahlenoperanden und die Constant-Tabelle erweitert): Release-Typ `V`, Major 3, Minor 40,
  Build 10. Das widersprach dem damaligen „V2.x Stable“ in GDD und Spec 01; mit **D52** ist
  dieser Build die Zielplattform. Der Build-Guard nimmt damit
  `new VersionInformation(EGameReleaseType.V, 3, 40, 10)` als getestete Fassung.
- **Die Nutzdaten-Strukturen `ModEvents/S…Data` sind nicht aufgeschlüsselt.** Für F-00 reicht
  `SPlayerLoginData`; dessen Felder sind noch zu lesen, bevor der Handshake gebaut wird.
- **`ModEventHandlerDelegate`1` und `ModEventInterruptibleHandlerDelegate`1`** sind in ihrer
  Signatur noch nicht gelesen (`Invoke`-Parameter).
- **Server/Client-Zuordnung** ist aus statischen Daten nur ein Indiz. `S+C` oben folgt daraus,
  dass der Lader auf beiden Seiten läuft; Bestätigung erst im Dedicated-Test — und ein
  Dedicated Server ist auf diesem Rechner **nicht installiert**.
- Aufrufer über Reflection, Unity-Messages und Delegaten erscheinen in der Aufrufer-Suche
  nicht. `IModApi::InitMod` wird selbst per `callvirt` nach `Activator.CreateInstance`
  aufgerufen, war also auffindbar; bei Event-Handlern wird das nicht so sein.
