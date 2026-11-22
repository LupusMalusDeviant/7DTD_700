# F-16 — Ein Modlet kann eigene Symbolbilder mitliefern: `UIAtlases/<Atlas>/<Name>.png`

**Stand:** 22. November 2026 (Plan-0002, WP3.2)
**Frage:** Kann unsere Mod eigene Bilder für den Beutel mitbringen — ohne Unity, ohne Bundle —, und
wenn ja: in welchem Ordner, in welchem Format, unter welchem Namen?
**Antwort (statisch gelesen, im Spiel nicht gesehen):** Ja. Beim Laden der Mods durchsucht das Spiel
je Mod den Ordner `<Mod>/UIAtlases`. Jeder **Unterordner** ist ein Atlas mit dem Namen des
Unterordners; gibt es einen Atlas dieses Namens schon, kommen die Bilder dazu, sonst wird er neu
angelegt. Im Unterordner zählt jede Datei mit der Endung `.png`; der Name des Bildes ist der
**Dateiname ohne Endung**. Für den Beutel heißt der Atlas `ItemIconAtlas`.

Unser Weg ist damit: `mod/<Modlet>/UIAtlases/ItemIconAtlas/<Name>.png`, und in XML
`<property name="CustomIcon" value="<Name>" />`.

**Kein Patch.** Dieses Finding trägt keinen Harmony-Eingriff und steht darum nicht im
Patch-Manifest; es belegt einen Weg, den das Spiel selbst anbietet.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta find-string <dll> --text UIAtlases --text ItemIcons --text "Creating new
atlas" --text ItemIconAtlas` (54 940 Methodenrümpfe durchsucht, 25 Treffer) und
`mod700meta members <dll> --type 'ModManager/<LoadUiAtlases>d__18' --il` sowie
`--type UIAtlasFromFolder --type 'UIAtlasFromFolder/<CreateUiAtlasFromFolder>d__0' --il`. Gelesen
werden Metadaten und IL-Bytes; die Assembly wird nicht geladen, nicht ausgeführt und nicht
dekompiliert.

**Was der Auszug zeigt und was nicht:** `--il` gibt Aufrufe und Zeichenketten einer Methode in ihrer
Reihenfolge aus, nicht die Sprünge dazwischen. Jedes „wenn — sonst" unten ist aus der Reihenfolge
gelesen und so gekennzeichnet.

## Der Beleg

### Wo das Spiel sucht — `ModManager.LoadUiAtlases`

Die Zustandsmaschine `ModManager/<LoadUiAtlases>d__18::MoveNext` trägt die Zeichenketten
`/UIAtlases` und `[MODS] Creating new atlas '`; ihre Aufrufe stehen in dieser Reihenfolge:

1. `GameManager::get_IsDedicatedServer`
2. `List<Mod>::get_Item`, `Mod::get_Path`, `String::Concat` — der Pfad der Mod plus `/UIAtlases`
3. `SdDirectory::Exists`, `SdDirectory::GetDirectories` — die Unterordner
4. `Path::GetFileName` — der Name des Unterordners
5. `Dictionary<string, AtlasManagerEntry>::TryGetValue` — gibt es einen Atlas dieses Namens?
6. `Mod::get_Name`, `Log::Out` (mit der Zeichenkette oben), `MultiSourceAtlasManager::Create`,
   `ModManager::RegisterAtlasManager` — *gelesen als:* nur wenn nicht, wird er angelegt
7. `UIAtlasFromFolder::CreateUiAtlasFromFolder` — der Unterordner wird zum Atlas

*Gelesen, nicht bewiesen:* der Aufruf `get_IsDedicatedServer` am Anfang legt nahe, dass ein
Dedicated Server keine Atlanten lädt (er hat keine Oberfläche). Für uns folgenlos — Bilder sind
Sache des Clients; die Kennung in `CustomIcon` ist reiner Text und bleibt auf dem Server gültig.

### Was im Unterordner zählt — `UIAtlasFromFolder.CreateUiAtlasFromFolder`

Signatur: `static IEnumerator UIAtlasFromFolder::CreateUiAtlasFromFolder(string, UnityEngine.Shader,
Action<UIAtlas>)`. Die Zustandsmaschine trägt die Zeichenkette `.png`; ihre Aufrufe:

1. `SdDirectory::GetFiles`
2. `String::EndsWith` — *gelesen als:* nur Dateien mit `.png`
3. `Texture2D::.ctor`, `ImageConversion::LoadImage` — die Datei wird als Bild geladen
4. `Path::GetFileNameWithoutExtension`, `Object::set_name`,
   `Dictionary<string, Texture2D>::set_Item` — das Bild heißt wie die Datei ohne Endung

`UIAtlasFromFolder::createUiAtlasFromTextures` packt die Bilder danach zu einem Atlas
(`Texture2D::PackTextures`, `Compress`, `Apply`) und trägt die Zeichenkette `_atlas.png`.
`UIAtlasFromFolder::loadSpriteSettings(string)` liest zusätzlich Einstellungen je Bild; welche Datei
das ist und was sie regeln kann, ist **nicht gelesen** — für ein schlichtes Symbol nicht nötig.

### Wie der Atlas für den Beutel heißt

`ItemIconAtlas` (und `ItemIconAtlasGreyscale`) stehen als Zeichenketten in den Methoden, die ein
Gegenstandsbild zeigen, darunter `ItemActionAttack::SetupRadial`, `RewardItem::SetupReward`,
`RewardLootItem::SetupReward`, `RewardTreasureItem::SetupReward` und
`ProgressionClass/DisplayData::GetUnlockItemIconAtlas`.

### Das Format der Bilder

Gemessen an Vanillas eigenen Symbolen: `Data\ItemIcons` enthält 5 261 lose PNG-Dateien;
`oreIronBoulder.png` ist **160×160 Pixel, 32 Bit mit Alpha** (`System.Drawing`, PixelFormat
`Format32bppArgb`). Die Zeichenketten `Data/ItemIcons` und `/ItemIcons` stehen im Spielcode nur im
Umfeld `[Web] IconHandler: Loaded {0} icons` — *gelesen als:* der Ordner `ItemIcons` einer Mod
bedient die Web-Oberfläche des Servers, nicht den Beutel.

## Was das für den Bau heißt

| Punkt | Folgerung |
|---|---|
| Ablage | `mod/<Modlet>/UIAtlases/ItemIconAtlas/<Name>.png` — in dem Modlet, das den Gegenstand trägt |
| Format | PNG, 160×160, 32 Bit mit Alpha, freigestellt wie Vanillas Bilder |
| Name | Dateiname ohne Endung; mit unserem Präfix `itm700_…` bzw. `ico700_…`, damit er kein Vanilla-Bild und kein Bild einer anderen Mod trifft (Vertrag 02) |
| Wahl in XML | `CustomIcon` mit dem Namen; `CustomIconTint` bleibt möglich |
| EAC | Reine Dateien und XML — kein Code; die XML-Modlets laden auch mit EAC |
| Prüfung | Jedes `CustomIcon` muss auf ein vorhandenes Bild zeigen: Vanillas `Data\ItemIcons` oder ein PNG eines unserer Modlets (Plan-0002, WP2.6 c) |

## Offen — nur das Spiel zeigt es (Testlauf T1)

1. Erscheint ein eigenes PNG im Beutel, im Handwerksfenster und beim Händler?
2. Was geschieht, wenn ein Bild **denselben Namen** trägt wie ein Vanilla-Bild — ersetzt es das
   Vanilla-Bild? (Nicht gelesen; wir vermeiden den Fall durch das Präfix.)
3. Verlangt der Atlas eine bestimmte Größe, oder werden andere Maße skaliert?
4. Gibt es eine Obergrenze für die Zahl der Bilder je Mod (Atlasgröße)?
5. Die graue Fassung (`ItemIconAtlasGreyscale`): entsteht sie aus unserem Bild von selbst?
