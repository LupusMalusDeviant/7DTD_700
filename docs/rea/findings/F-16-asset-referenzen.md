# F-16 — Asset-Referenzen: wie XML ein Modell, ein Material oder ein Bundle nennt

**Stand:** 23. November 2026 (Plan-0002, WP4.1)
**Fragen** (F-16:23–24, Spec 01:88–89, Vertrag 05 §7 Nr. 1–3 und 6):

1. Wie nennt XML ein Stück aus einem Bundle, das ein Modlet mitbringt?
2. Kann XML einem Vanilla-Modell ein eigenes Material geben (Retextur ohne Vanilla-Mesh im Bundle)?
3. Wie sitzt ein gehaltener Gegenstand an der Hand?
4. Welche Shader braucht ein Bundle?

**Antworten in einem Satz je Frage (statisch gelesen, nichts davon im Spiel gesehen):**

1. `#<Bundle-Datei>?<Asset-Name>`; in einer Patch-Datei eines Modlets steht davor
   `@modfolder:` für den Ordner **dieses** Modlets oder `@modfolder(<Name>):` für den Ordner eines
   **anderen** geladenen Modlets. Eine Dateiendung schreibt der Code nicht vor.
2. **Bei Wesen ja, bei Gegenständen nein.** Wesen kennen `AltMats` und `SwapMats` (Listen von
   Materialien, über denselben Lader gelesen); für Gegenstände und Blöcke gibt es keine Eigenschaft,
   die ein Material lädt — nur ein anderes Modell oder eine Tönung.
3. Das Modell wird **ohne Versatz und ohne Drehung** unter das Handgelenk gehängt; Sitz und Haltung
   stecken also im Prefab selbst und in der Bewegung des `HoldType`.
4. **Nicht entschieden.** Die eingebaute Render-Pipeline ist belegt, mehr nicht; die Shader des
   Spiels heißen `Game/…` und werden vom Code beim Namen gesucht.

**Kein Patch.** Dieses Finding trägt keinen Harmony-Eingriff und steht darum nicht im
Patch-Manifest; es belegt Wege, die das Spiel selbst anbietet.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta find-string <dll> --text <Wort>` (54 940 Methodenrümpfe) für `modfolder`,
`unity3d`, `Bundles`, `Addressable`, `AltMats`, `SwapMats`, `StickyMaterial`, `Meshfile`,
`HoldType`, `Gunjoint`, `RightHand`, `Game/`; `mod700meta members <dll> --type DataLoader --type
AssetBundleManager --type LoadManager --type ModManager --type XmlPatcher --type ItemClass --type
ItemClassesFromXml --type EntityClass --type EModelBase --type BlockShapeModelEntity [--il]`; dazu
eine Zählung in Vanillas `Data/Config/*.xml`. Gelesen werden Metadaten und IL-Bytes; die Assembly
wird nicht geladen, nicht ausgeführt und nicht dekompiliert. Spieldateien außer den XML und den
Dateinamen unter `Data/Bundles` wurden nicht geöffnet.

**Soll-Signaturen:** `tools/meta/expect/wp41.tsv` — `mod700meta verify` am 2026-11-23: 13 Zeilen,
0 fehlgeschlagen (Exit 0); Gegenprobe mit einer falschen Signatur: Exit 1.

**Was der Auszug zeigt und was nicht:** `--il` gibt Aufrufe, Konstanten und Zeichenketten einer
Methode in ihrer Reihenfolge aus, nicht die Sprünge dazwischen. Jedes „wenn — sonst" unten ist aus
der Reihenfolge gelesen und so gekennzeichnet.

## 1. Die drei Formen eines Verweises

Gezählt in Vanillas XML (alle Werte, die mit `@:` oder `#` beginnen):

| Form | Zahl | wo | Bedeutung |
|---|---|---|---|
| `@:<Pfad>` | 6593 | `blocks.xml` 3257, `shapes.xml` 2265, `items.xml` 723, `entityclasses.xml` 293, `item_modifiers.xml` 43, `styles.xml` 10, `buffs.xml` 1, `music.xml` 1 | Addressables — der Katalog des Spiels |
| `#<Bundle>?<Asset>` | 48 | nur `blocks.xml`, alle `#Entities/Trees?…Prefab.prefab` | ein Asset aus einer Bundle-Datei |
| `#@modfolder:…` | 0 | — | Vanilla benutzt die Mod-Form nirgends |

(Die 352 Werte mit `#` in `twitch.xml` sind Chat-Befehle, keine Verweise.) Nach Eigenschaft:
`Model` 5568 (Blöcke und Formen), `Meshfile` 327, `DropMeshfile` 217, `Prefab` 201, `Mesh` 199,
`AltMats` 38, `ParticleOnSpawn` 28, `FlameEffect` 25, `HandMeshfile` 20, `StickyMaterial` 3. Endungen
hinter `@:`: `.prefab` 3898, `.fbx` 2621, `.mat` 42, `.asset` 18, `.wav` 10, `.tga` 3.

### Wer die Form liest — `DataLoader.ParseDataPathIdentifier`

Signatur: `static DataLoader/DataPathIdentifier DataLoader::ParseDataPathIdentifier(string)`. Die
Methode trägt die Zeichenkette `@:` und die Zeichen `#` und `?`; ihre Aufrufe: zuerst
`ModManager::PatchModPathString`, dann `String::IndexOf` (für `#`, für `?`), `String::Substring`
und dreimal der Konstruktor von `DataPathIdentifier`. Das Ergebnis hat vier Felder: `Location`
(`Resources` = 0, `Bundle` = 1, `Addressable` = 2), `BundlePath`, `AssetName`, `FromMod`.

*Gelesen als:* beginnt der Wert mit `#` und enthält ein `?`, ist der Teil dazwischen der Pfad des
Bundles und der Teil dahinter der Name des Assets; beginnt er mit `@:`, geht er an die Addressables;
sonst gilt er als Pfad in den eingebauten `Resources`. `DataLoader::IsInResources(string)` prüft
entsprechend nur, ob `#` und `@` **fehlen**.

### Der Mod-Ordner — `XmlPatcher.ReadPatchXmlWithFixedModFolders` und `ModManager.TryPatchModPathString`

- `static XmlFile XmlPatcher::ReadPatchXmlWithFixedModFolders(Mod, string)` liest die Patch-Datei
  als Text (`SdFile::ReadAllText`), ruft `Mod::get_Name` und `String::Replace` und trägt die
  Zeichenketten `@modfolder:`, `@modfolder(` und `):`. *Gelesen als:* in **jeder Patch-Datei** wird
  `@modfolder:` durch `@modfolder(<Name dieses Modlets>):` ersetzt, bevor XML daraus wird.
- `static bool ModManager::TryPatchModPathString(string, string&)` trägt `@modfolder(`, `):`, `/`
  und die Meldung `[MODS] Mod reference for a mod that is not loaded: '`; Aufrufe:
  `ModManager::GetMod`, `Mod::get_Path`, `String::Concat`, `Log::Error`. *Gelesen als:* aus
  `@modfolder(<Name>):<Rest>` wird `<Ordner des Modlets>/<Rest>`; ist das Modlet nicht geladen,
  steht ein Fehler im Log.

**Folgen für uns:**

- In unseren Patch-Dateien: `#@modfolder:Resources/<Datei>?<Asset>` — der Pfad hinter dem
  Doppelpunkt ist frei, `Resources/` ist nur Gewohnheit.
- **Ein Bundle darf in einem anderen Modlet liegen als die XML-Zeile, die es nennt:**
  `#@modfolder(<Name>):…`. Das beantwortet Vertrag 05 §7 Nr. 6 im Grundsatz: Bundles gehören in ein
  reines XML-Modlet, nicht ins Code-Modlet. `<Name>` ist der Name aus der `ModInfo.xml` (welches
  Feld `GetMod` genau vergleicht, ist nicht gelesen).
- Die Ersetzung geschieht im **Text der Patch-Datei**. Ein Wert, den erst C# zur Laufzeit setzt,
  braucht die ausgeschriebene Form mit Namen.

### Wie die Bundle-Datei gefunden wird — `AssetBundleManager.LoadAssetBundle`

Signatur: `void AssetBundleManager::LoadAssetBundle(string, bool)`. Zeichenketten:
`/Data/Bundles/Standalone`, `/`, `Loading AssetBundle "`, `" failed: Parent folder not found!`,
`" failed: File not found!`, `" failed!`. Aufrufe in dieser Reihenfolge: `Path::IsPathRooted`,
`GameIO::GetApplicationPath`, `BundleTags::get_Tag`, `Path::GetDirectoryName`, `Directory::Exists`,
`Path::GetFileName`, `Directory::EnumerateFiles`, `Extensions::EqualsCaseInsensitive`,
`AssetBundle::LoadFromFile`.

*Gelesen als:* ein Pfad ohne Laufwerk wird unter `<Spiel>/Data/Bundles/Standalone…/` gesucht (so
findet Vanilla `Entities/trees`, 650 MB); ein voller Pfad — also einer aus einem Modlet — wird
genommen, wie er ist. Der Ordner muss bestehen; die Datei wird **ohne Rücksicht auf Groß- und
Kleinschreibung** im Ordner gesucht. Die Zeichenkette `unity3d` kommt im ganzen Code nicht vor: **die
Endung ist frei**.

Den Namen des Assets kürzt `AssetBundleManager::_get` vor `AssetBundle::LoadAsset` über
`String::LastIndexOf`, `String::Substring` und `GameIO::RemoveFileExtension`. *Gelesen als:* gefragt
wird nach dem **bloßen Namen ohne Ordner und ohne Endung** — Vanillas
`…?StudioGimbal/MountainPineLrg01/MountainPineLrg01GimbalPrefab.prefab` lädt
`MountainPineLrg01GimbalPrefab`. Zwei Assets gleichen Namens in einem Bundle wären damit nicht zu
unterscheiden.

## 2. Wer ein Modell oder Material lädt

| Wo | Methode | lädt über |
|---|---|---|
| Gegenstand in der Hand, am Boden, im Vorschaubild | `ItemClass::CreateModelInstance(ItemValue, Transform, BlockShape/MeshPurpose)`; der Pfad kommt aus `ItemClass::GetMeshfilePath(BlockShape/MeshPurpose, ItemValue)` (`Meshfile`, `HandMeshfile`, `DropMeshFile`; ruft `ItemValue::GetPropertyOverride`) | `DataLoader::LoadAsset`, dann `Object::Instantiate` |
| Block mit eigenem Modell (`Shape` = `ModelEntity`, 714 Zeilen in `blocks.xml`) | `BlockShapeModelEntity::getPrefab()` | `DataLoader::LoadAsset` |
| Wesen | `EntityClass::Init()` (liest unter anderem `AltMats` und `SwapMats`); `EModelBase::createModel(World, EntityClass)` | `DataLoader::LoadAsset`, `DataLoader::PreloadBundle` |

Alle drei gehen durch `DataLoader` — **die Mod-Form gilt damit für Gegenstände, Blöcke und Wesen
gleichermaßen.** Fehlt einem Gegenstand das Modell, greift `ItemClass::GetModelHandle` auf
`@:Other/Items/Crafting/leather.fbx` zurück.

### Material auf einem Vanilla-Modell

- **Wesen:** `EntityClass` führt die Eigenschaften `AltMats` und `SwapMats` und die Felder
  `string[] AltMatNames` und `string[] MatSwap`. `EModelBase::createModel` liest `MatSwap`, ruft
  `DataLoader::LoadAsset`, `EModelInstanceAssets::get_AltMaterial`, `Renderer::get_sharedMaterials`
  und `Renderer::set_materials`. *Gelesen als:* XML kann einem Wesen andere Materialien auf sein
  vorhandenes Netz legen. Vanilla nutzt `AltMats` 38-mal (je zwei Materialien als Varianten einer
  Figur); `SwapMats` steht in Vanilla nur in einem Kommentar. **Wie** aus der Liste gewählt wird und
  welcher Eintrag auf welchen Material-Platz fällt, ist nicht gelesen.
- **Gegenstände:** `ItemClassesFromXml::parseItem` kennt an Namen mit Modell oder Material nur
  `Meshfile`, `DropMeshfile`, `HandMeshfile`, `HoldType`, `StickyMaterial` (das Material des
  steckenden Speers) und `Material` (der Werkstoff, kein Render-Material). In `ItemClass` ruft außer
  `CreateModelInstance` nichts `DataLoader::LoadAsset`. `ItemClass::InitializeModel` setzt eine
  Tönung (`UpdateLight::SetTintColorForItem`, Vorgabe `255,255,255`; `TintColor` steht 94-mal in
  `items.xml`). **Gefunden ist also keine Eigenschaft, die einem Gegenstand ein Material gibt** —
  nur ein anderes Modell oder eine Farbe.
- **Blöcke:** `BlockShapeModelEntity` lädt ein ganzes Prefab; die übrigen Formen nehmen ihr Bild aus
  dem Block-Atlas (`Texture`). Ein Material je Block aus XML ist nicht gefunden.

**Folge für P2-E07 und R4** (Retextur ohne Vanilla-Mesh im Bundle): Für die **Keule** führt kein
XML-Weg dorthin — sie bräuchte ein eigenes Netz. Für **Seuchentote** gibt es den Weg dem Code nach;
ob ein Material aus unserem Bundle auf Vanillas Figur richtig aussieht, hängt an Frage 4.

## 3. Der Sitz in der Hand

`bool ItemClass::InitializeModel(GameObject, ItemValue, Transform, BlockShape/MeshPurpose)` ruft in
dieser Reihenfolge `Transform::SetParent`, `Vector3::get_zero`, `Quaternion::get_identity`,
`Transform::SetLocalPositionAndRotation`, `GameObject::SetActive`, dann für alle Kinder
`Collider::set_enabled`. *Gelesen als:* das Modell hängt mit Versatz null und ohne Drehung unter dem
übergebenen Knoten, seine Collider werden abgeschaltet.

Der Knoten: `EntityClass` führt die Eigenschaft `RightHandJointName`;
`EntityAlive::CopyPropertiesFromEntityClass`, `FirstPersonAnimator` und zwei weitere Klassen tragen
die Zeichenkette `Gunjoint`. *Gelesen als:* das Handgelenk heißt `Gunjoint`, wenn die Klasse nichts
anderes sagt (Vanilla: dreimal etwas anderes, `Jaw` und `Boulder`).

Die Haltung kommt aus `HoldType` (`AvatarController::StaticInit` trägt `WeaponHoldType`, den Namen
des Animator-Parameters). `items.xml` nennt `HoldType` 304-mal mit 77 verschiedenen Werten; am
häufigsten 45 (118-mal) und 31 (41-mal).

**Folgen für uns:**

- Ein eigenes Prefab muss so gebaut sein wie das Vanilla-Prefab desselben `HoldType`: Griff im
  Ursprung, Achsen wie dort. **Welche Achse wohin zeigt, steht nicht im Code** — das zeigt erst ein
  Blick auf ein Vanilla-Prefab in Unity oder der erste Versuch im Spiel. Der Rundschild hat seinen
  Ursprung schon am Griff (Vertrag 05 §7.1 Nr. 6); die Drehung ist offen.
- Einen Platz für die **zweite Hand** kennt der Code hier nicht. Der Schild als Schaustück (WP4.5)
  liegt in der rechten Hand; der Schild am linken Arm ist Code (F-02, WP12).
- Zielfernrohre und Aufsätze suchen im Prefab Knoten namens `Attachments/…`
  (`ItemActionRanged`, `ItemActionZoom`) — für Nahkampfwaffen ohne Belang.

## 4. Shader

- Im Ordner `Managed` liegt **keine** `Unity.RenderPipelines.*.dll` — das Spiel läuft auf Unitys
  eingebauter Render-Pipeline. `Unity.Addressables.dll` ist vorhanden (die Form `@:`).
- Der Code sucht Shader beim Namen: `Game/Character` (`EModelBase::SetFade`,
  `AvatarZombieController::MakeDismemberedPart`), `Game/SDCS/Hair`, `Game/SDCS/Skin`,
  `Game/SDCS/Eye`, `Game/UI/Screen Overlay`, `Game/SignTech/UI` — 27 Methoden tragen `Game/`.
- **Nicht gelesen und statisch nicht lesbar:** welche Shader das Spiel sonst mitbringt, ob Unitys
  `Standard`-Shader aus einem fremden Bundle im Spiel richtig beleuchtet wird, und was mit einem
  Wesen geschieht, dessen Material **nicht** `Game/Character` trägt (Ausblenden und abgetrennte
  Glieder fragen nach diesem Namen). Den Shader des Spiels können wir nicht in unser Bundle legen —
  er ist eine Spieldatei.

## 5. Was offen bleibt — und wo es sich klärt

| Offen | klärt sich |
|---|---|
| Lädt ein Bundle aus dem Editor 2022.3.62f3 im Spiel (62f2)? | erster Durchstich, T1 Teil B (WP4.6) |
| Sieht ein Prefab mit `Standard`-Shader im Spiel richtig aus (Licht, Nebel, Nacht)? | T1 Teil B |
| Achsen und Drehung in der Hand je `HoldType` | Unity (WP4.4) oder T1 Teil B |
| `AltMats`/`SwapMats`: Auswahl, Zuordnung zu Material-Plätzen, Verhalten ohne `Game/Character` | ein Wesen mit einem Material aus unserem Bundle, T1 Teil B (WP5) |
| Lädt ein Dedicated Server Bundles, und stört es ihn, wenn eines fehlt? | Dedicated-Test (Projektregel 5) |
| Welches Feld `ModManager::GetMod` mit `<Name>` vergleicht | beim ersten Bundle in einem zweiten Modlet |

## 6. Was dieses Finding nicht enthält

Keinen dekompilierten Code und keinen IL-Auszug; keine Datei aus einem Bundle des Spiels. Die Namen,
Signaturen und kurzen Zeichenketten oben sind das, was `mod700meta` aus den Metadaten liest.
