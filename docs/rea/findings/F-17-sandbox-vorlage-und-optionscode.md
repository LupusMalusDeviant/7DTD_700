# F-17 — Sandbox-Vorlage und Optionscode: `sandbox_overrides.xml` gelesen, Code von Hand rechenbar

**Stand:** 23. November 2026 (Plan-0002, WP1.5; Bezug: D128, N-02, N-95)
**Frage:** Kann unsere Mod den Biom-Fortschritt (`BiomeProgression`) über
`Data\Config\sandbox_overrides.xml` ausschalten — und wenn ja: mit `sandbox_override` oder mit einer
eigenen Vorlage (`preset`), und wie sieht deren `code` aus?
**Antwort (statisch gelesen, im Spiel nicht gesehen):**

1. `BiomeProgression` ist eine Ja/Nein-Option mit der **Vorgabe „ein"**.
2. `sandbox_override option="X"` setzt **keinen Wert**. Es trägt die Option nur in eine Sperrliste
   ein; die einzige gelesene Wirkung ist, dass das Auswahlfeld im Optionsfenster ausgegraut wird.
   Für `BiomeProgression` hieße das: gesperrt auf dem, was die gewählte Vorlage liefert — ohne
   eigene Vorlage also gesperrt auf **„ein"**. Das ist das Gegenteil von dem, was wir wollen.
3. Der Weg ist eine **Vorlage** (`<preset … code="…" default="true" />`). Ihr Code ist rechenbar:
   ein Versionszeichen `A`, danach je geänderter Option drei Buchstaben (zwei für die Option, einer
   für den Wert).
4. Der Code für „alle Vorgaben, nur Biom-Fortschritt aus" ist **`ACDA`** — **berechnet, im Spiel
   nicht geprüft**. Auf Vanillas Standard-Schwierigkeit „Adventurer" aufgesetzt:
   **`AAAJABJACJADJARFBNCCDA`** — ebenfalls berechnet, nicht geprüft.

**Kein Patch.** Dieses Finding trägt keinen Harmony-Eingriff und steht darum nicht im
Patch-Manifest; es belegt einen Weg, den das Spiel selbst anbietet (reine XML-Vorlage).

**Gebaut darauf (D136, 2026-11-23):** `mod/700_60_Welt/Config/sandbox_overrides.xml` — eine
Vorlage mit dem Code aus Abschnitt 7 (Adventurer ohne Biom-Fortschritt). Stichprobe beim Einbau,
unabhängig nachgelesen: die Enum-Werte `BiomeProgression` = 55, `IncomingDamage` = 17,
`AISmellMode` = 39, `DropOnDeath` = 27, `MaxDegradationAmount` = 114, `TraderBuyLimit` = 135,
`Max` = 165 stimmen mit den Tabellen unten überein. Im Spiel weiter nicht gesehen (S-11).

## Gebunden an diesen Build

| | |
|---|---|
| Build | 7 Days to Die V 3.40 b10 (Stable) |
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta types <dll> --contains Sandbox` (50 Typen), `mod700meta members <dll>
--type … --il` und `--callers` für `SandboxOverridesFromXml`,
`SandboxOverridesFromXml/<CreateOverrides>d__0`, `SandboxOptions.SandboxOptionManager`,
`SandboxOptions.BaseSandboxOption`, `SandboxOptions.SandboxOptionBoolean/Int/Float`,
`SandboxOptions.SandboxOptionPreset`, `SandboxOptions.SandboxOptionValueSet*`,
`SandboxOptions.SandboxOptions`, `XUiC_SandBoxOptionEntry`, `XUiC_SandboxOptions`,
`XUiC_SandboxPresetSelector`, `XUiC_SandboxSettingsDisplay`, `XUiC_NewContinueGameSettings`,
`GameManager/<StartAsServer>d__167`, `EntityPlayerLocal`, `WorldStaticData`, `EnumGamePrefs`,
`EnumGameStats`. Gelesen werden Metadaten und IL-Bytes; die Assembly wird nicht geladen, nicht
ausgeführt und nicht dekompiliert.

**Daneben gelesene lose Dateien** (nichts davon liegt im Repository): `Data\Config\sandbox_overrides.xml`,
`serverconfig.xml`, `Data\Config\Localization.csv`, `Data\Config\XUi_Menu\templates.xml` und eine
vom Spiel geschriebene Nutzervorlage unter `%APPDATA%\7DaysToDie\Presets\`.

**Was der Auszug zeigt und was nicht:** `--il` gibt je Methode Aufrufe, Feldzuweisungen und
ganzzahlige Konstanten in ihrer Reihenfolge aus. Er zeigt **nicht**: Sprünge, Rechenoperationen,
das Laden von Argumenten und lokalen Variablen, Gleitkomma-Konstanten, `null` und die Stelle einer
Zeichenkette im Ablauf (Zeichenketten stehen je Methode in einer eigenen, entdoppelten Liste).
Inhalte von Feldern, die das Spiel aus einem Datenblock füllt (`RuntimeHelpers::InitializeArray`),
sind nicht lesbar. Jedes „wenn — sonst" und jede Rechnung unten ist deshalb aus Reihenfolge und
Konstanten **geschlossen** und so gekennzeichnet. Eine Eigenheit des Werkzeugs: Zeichenketten-
Konstanten von Feldern gibt es halbiert aus (`ModdedGroupName` als `Mod`, `IconCustomPresets` als
`Data/Sandbox/ic`); die vollständigen Texte stehen in den Methoden (`Modded`,
`Data/Sandbox/icons/user_custom`).

## Der Beleg

### 1. Wie das Spiel `sandbox_overrides.xml` liest

`WorldStaticData::.cctor` trägt die Zeichenkette `sandbox_overrides` und ruft
`SandboxOverridesFromXml::CreateOverrides(XmlFile)`; `SandboxOverridesFromXml::Reload(XmlFile)` ruft
dieselbe Methode synchron. Die Datei ist damit eine gewöhnliche Konfigurationsdatei — *geschlossen:*
ein Modlet ändert sie wie jede andere über `Config/sandbox_overrides.xml` (Finding WP1).

Die Zustandsmaschine `SandboxOverridesFromXml/<CreateOverrides>d__0::MoveNext` trägt die
Zeichenketten `preset`, `Modded`, `sandbox_override`, `option` und `Unrecognized xml element `. Ihre
Aufrufe in dieser Reihenfolge:

1. `XDocument::get_Root`, `SandboxOptionManager::get_Current`,
   `SandboxOptionManager::RemoveOverrides` — vor jedem Lesen wird aufgeräumt. `RemoveOverrides`
   geht die Liste `SandboxPresets` von hinten durch, liest `SandboxOptionPreset::IsModded`, ruft
   `List::RemoveAt` und weist das statische Feld `overrideList` neu zu. *Gelesen als:* alle
   Mod-Vorlagen fliegen raus, die Sperrliste wird geleert.
2. `XContainer::Elements`, je Element `XElement::get_Name` und ein Namensvergleich.
3. Element **`preset`**: `SandboxOptionManager::LoadPresetFromXml(XElement, string, bool)` —
   mit der Zeichenkette `Modded` und der Konstante 1 (wahr).
4. Element **`sandbox_override`**: `XmlExtensions::HasAttribute` (`option`),
   `XmlExtensions::GetAttribute`, `Enum::TryParse` (Startwert der Ausgabe ist 165 =
   `SandboxOptions.Max`), `SandboxOptionManager::AddOverride(SandboxOptions)`.
5. Sonst: `String::Concat` mit `Unrecognized xml element ` und `Exception::.ctor` — *gelesen als:*
   jedes andere Element wirft eine Ausnahme.

**Die Attribute einer Vorlage** stehen in `SandboxOptionManager::LoadPresetFromXml`
(Zeichenketten `name`, `code`, `description`, `description_key`, `localized_name`, `icon`,
`default`, `true`, `difficulty_rating`, `always_show`, `category`):

| Attribut | Was das Spiel damit tut |
|---|---|
| `name` | → `SandboxOptionPreset::Name` |
| `localized_name` | → `LocalizedName`; `get_DisplayName` nimmt diesen Schlüssel über `Localization::Get`, wenn er nicht leer ist, sonst `Name` |
| `description`, `description_key` | → `Description`, `DescriptionKey`; `get_DisplayDescription` nach demselben Muster |
| `icon` | → `Icon` |
| `code` | geht an `SandboxOptionManager::StoreOptionsInPresetFromCode(SandboxOptionPreset, string)` — siehe Abschnitt 5 |
| `default` | `HasAttribute`, `GetAttribute`, `Extensions::EqualsCaseInsensitive` gegen `true`, dann Konstante 1 nach `IsDefault` |
| `difficulty_rating`, `always_show`, `category` | werden ebenfalls gelesen (`DifficultyRating`, `AlwaysShow` als kommagetrennte Optionsnamen, `Group`); Vanillas eigene Vorlagen nutzen sie. Für uns nicht nötig, nicht weiter gelesen |

Am Anfang der Methode stehen vier `HasAttribute`-Aufrufe, bevor die Vorlage angelegt wird.
*Geschlossen:* `name` und `code` sind Pflicht, dazu `description` oder `description_key` (so sagt es
auch der Kommentar der Datei). Die Methode enthält **keinen** Protokoll-Aufruf und keine Ausnahme —
eine Vorlage, der etwas fehlt, verschwindet also vermutlich **ohne Meldung**.

Aus dem Aufruf in Schritt 3 folgt: die Vorlage bekommt `IsModded` = wahr und die Gruppe `Modded`
(statt des Attributs `category`). `Localization.csv` kennt `sandboxPresetGroupModded` („Gemoddet").
Am Ende steht `List<SandboxOptionPreset>::Add` auf `SandboxPresets`.

### 2. Was `sandbox_override` wirklich tut

`SandboxOptionManager::AddOverride(SandboxOptions)` legt bei Bedarf die statische Liste
`overrideList` an und hängt die Option an (`List::Contains`, `List::Add`). Mehr tut sie nicht: kein
Aufruf von `SetOptionToDefault`, kein Zugriff auf `SandboxOptionsDict`.

`SandboxOptionManager::IsOverriden(SandboxOptions)` fragt nur `overrideList` ab
(`List::Contains`). Ihre **einzigen Aufrufer** im ganzen Spielcode (54 940 Methodenrümpfe
durchsucht) sind `XUiC_SandBoxOptionEntry::get_Enabled` und
`XUiC_SandBoxOptionEntry::get_DisabledByMod`. `templates.xml` bindet daran das Auswahlfeld der
Option: `enabled="{% option_enabled }"` und als Hinweistext `xuiSandboxDisabledByMod` („Diese
Option wurde von einer Mod deaktiviert …").

`SandboxOptionManager::SetOptionToDefault` hat genau einen Aufrufer,
`XUiC_SandBoxOptionEntry::ResetToDefault`; den rufen `XUiC_SandboxOptions::BtnDefaults_OnOnPressed`
und `XUiC_SandboxOptions::updateOptionsToPreset` — für **alle** Einträge, ohne `IsOverriden` zu
fragen.

Keine der Methoden, die Werte setzen, fragt die Sperrliste ab: weder
`SandboxOptionManager::LoadOptionsFromCode` (beide Überladungen) noch
`StoreOptionsInPresetFromCode`, `SetValuesFromPreset`, `XUiC_SandboxOptions::updateOptionsToPreset`
oder `XUiC_SandBoxOptionEntry::ApplyChange`.

**Folgerung (geschlossen):** Der Kommentar der Datei („Sets the named option to the Default setting
and disables the option from being changed") stimmt nur zur Hälfte. Gelesen ist allein das
**Sperren des Bedienfelds**. Den Wert liefert weiter die gewählte Vorlage bzw. der Code — und der
ist die Vorgabe, solange keine Vorlage die Option anfasst. Auf einem Dedicated Server (kein
Optionsfenster) hat `sandbox_override` nach dieser Lesart **gar keine Wirkung**.

Zwei Kleinigkeiten zum Attribut `option`: Zwischen `GetAttribute` und `Enum::TryParse` steht keine
weitere Konstante — *gelesen als:* die Überladung ohne „Groß/Klein egal", der Name muss also genau
wie im Enum geschrieben sein. Und die Methode enthält keinen Protokoll-Aufruf für einen
unbekannten Namen: ein Tippfehler bleibt vermutlich **stumm**.

### 3. Was `default="true"` tut

`SandboxOptionManager::GetDefaultPreset` liest `SandboxPresets` und
`SandboxOptionPreset::IsDefault`; die Konstanten (Anzahl − 1, dann − 1, Vergleich mit 0) zeigen
einen Lauf **von hinten nach vorn**. *Gelesen als:* die zuletzt eingetragene Vorlage mit
`IsDefault` gewinnt — eine Mod-Vorlage (kommt nach Vanillas) schlägt Vanillas Standard.

Einziger Aufrufer ist `XUiC_SandboxPresetSelector::SelectPresetByName(string, string, bool)`: erst
`SandboxOptionManager::GetPreset`, dann `GetDefaultPreset` — *geschlossen:* der Rückfall, wenn kein
Name passt. Den wiederum ruft `XUiC_NewContinueGameSettings::ResetSandboxPresetToDefault`, und
dessen Aufrufer sind `XUiC_NewGame::OnOpen` und `XUiC_NewGame::gameModeChanged`.

**Folgerung:** `default="true"` wählt die Vorlage **vor**, sobald das Fenster „Neues Spiel"
aufgeht. Es erzwingt nichts — der Spieler kann eine andere Vorlage wählen.

Der Weg vom Vorwählen bis ins Spiel, gelesen:
`XUiC_NewContinueGameSettings::updateSandboxData` schreibt Name und Code der gewählten Vorlage nach
`GamePrefs` (`EnumGamePrefs.SandboxPreset` = 295, `SandboxCode` = 296) und ruft
`LoadOptionsFromCode`. Beim Spielstart liest `GameManager/<StartAsServer>d__167::MoveNext` den Code
wieder aus `GamePrefs` (296), ruft `LoadOptionsFromCode(string)` und danach
`UpdateInGameValuesWithSandboxOptions`. Dort wird Option 55 über `SandboxOptionManager::GetBool`
gelesen und nach `World::BiomeProgressionEnabled` sowie per `GameStats::Set` nach
`EnumGameStats.BiomeProgression` (66) geschrieben — das ist der Spielwert, auf den die Buffs mit
`required_game_stat="BiomeProgression"` schauen (`docs/konzept/biome.md`, §1.3). Der Client lädt den Code
in `EntityPlayerLocal::AfterPlayerRespawn` aus `GameStats` (`EnumGameStats.SandboxCode` = 71).

Für den Dedicated Server heißt das: es zählt die Zeile `SandboxCode` in `serverconfig.xml`, nicht
`default="true"`.

### 4. Vorgabewerte

`SandboxOptionManager::SetupOptions` legt zuerst 65 Wertemengen an
(`SandboxOptionValueSetFloat/Int/Bool`, je `Dictionary<string, SandboxOptionValueSet>::Add`) und
dann 165 Optionen (je `SandboxOptionManager::AddSandboxOption`). Vor jedem Konstruktor stehen die
ganzzahligen Argumente in ihrer Reihenfolge:

- `SandboxOptionBoolean::.ctor(SandboxOptions, string, string, string, bool, bool, DisabledOptionsOnValue)`
  — drei Konstanten: Enum-Wert, erster Wahrheitswert, zweiter Wahrheitswert.
- `SandboxOptionInt::.ctor(SandboxOptions, string, string, string, int, bool, DisabledOptionsOnValue)`
  — Enum-Wert, Vorgabe (der **Wert**, nicht der Index), Wahrheitswert.
- `SandboxOptionFloat::.ctor(SandboxOptions, string, string, string, float, bool, DisabledOptionsOnValue)`
  — Enum-Wert und Wahrheitswert; die Vorgabe ist eine Gleitkomma-Konstante und im Auszug
  **nicht lesbar**.

Für **`BiomeProgression`** (Enum-Wert 55) steht dort: 55, 1, 0, dann
`SandboxOptionBoolean::.ctor`. Typ also Ja/Nein, erster Wahrheitswert 1.

*Geschlossen, mit zwei Stützen:* Der erste Wahrheitswert ist die Vorgabe (`DefaultValue`), der
zweite geht an den Basiskonstruktor (`BaseSandboxOption::NewUISection`). (a) Bei `Int` und `Float`
steht an derselben Stelle die Vorgabe und dahinter derselbe Wahrheitswert. (b) Das Muster über alle
32 Ja/Nein-Optionen: die Spaß-Schalter (`SillyBigHeads`, `SillyTinyZombies`, `SillySounds`,
`SillyBlackandWhite`) und die Anzeigen `ShowHealthBars`, `ShowEnemyDamage` tragen 0, alle
„…Enabled"-Optionen 1; der zweite Wert ist nur bei `NewbieCoat` und `AirDropMarker` 1.
**Im Spiel gemessen** und dazu passend: das Protokoll vom 22. November zeigt
`GamePref.BiomeProgression = True` unter der Vorlage „Adventurer" (`docs/konzept/biome.md`, §1.10),
deren Code die Option nicht nennt (Abschnitt 6).

**Die beiden Ja/Nein-Wertemengen** (Nr. 44 und Nr. 58 in der Reihenfolge des Anlegens, den
Zeichenketten nach `YesNo` und `SmeltingType`) werden gleich gebaut: ein Feld
`SandboxOptionValueSetBool::BoolValues` der Länge 2, in dem nur Platz 1 auf 1 gesetzt wird. Also
`[falsch, wahr]`: **Index 0 = aus, Index 1 = ein**. `SandboxOptionValueSetBool::GetBoolIndex(bool)`
sucht den Wert in diesem Feld und gibt den Platz zurück (sonst −1).

| Option | Enum-Wert | Buchstaben | Typ | Vorgabe | Wertemenge |
|---|---|---|---|---|---|
| `BiomeProgression` | 55 | `CD` | Ja/Nein | **ein** | `[aus, ein]` → `A` = aus, `B` = ein |
| `TemperatureSurvival` | 56 | `CE` | Ja/Nein | ein | wie oben |
| `StormFreq` | 57 | `CF` | Kommazahl | nicht lesbar | *vermutet:* Menge `StormFrequency`, 8 Werte, Inhalt nicht lesbar |
| `StormWarning` | 58 | `CG` | Ja/Nein | ein | wie oben |
| `AirDropFrequency` | 52 | `CA` | Ganzzahl | Wert 3 | *vermutet:* Menge `AirDrops`, 7 Werte, Inhalt nicht lesbar |
| `AirDropMarker` | 53 | `CB` | Ja/Nein | ein | wie oben |
| `MaxTechType` | 74 | `CW` | Ganzzahl | Wert 4 | *vermutet:* Menge `MaxTechType`, 5 Werte, Inhalt nicht lesbar |
| `WorkstationsInTheWild` | 73 | `CV` | Kommazahl | nicht lesbar | nicht gelesen |
| `TradersEnabled` | 128 | `EY` | Ja/Nein | ein | wie oben |
| `VendingEnabled` | 129 | `EZ` | Ja/Nein | ein | wie oben |
| `ChallengesEnabled` | 139 | `FJ` | Ja/Nein | ein | wie oben |
| `IntroChallengesEnabled` | 140 | `FK` | Ja/Nein | ein | wie oben |
| `AllowMap` | 68 | `CQ` | Ja/Nein | ein | wie oben |
| `AllowCompass` | 69 | `CR` | Ja/Nein | ein | wie oben |

**Was hier nicht gelesen ist:** Welche Wertemenge zu welcher Option gehört — der Name steht als
Zeichenkette im Konstruktor, und Zeichenketten zeigt der Auszug nicht an ihrer Stelle. Die
Zuordnung der Mengen-Namen zu ihrer Größe ist aus der Reihenfolge der 65 Namen in der
Zeichenkettenliste geschlossen (sie geht ohne Rest auf). Bei Ganzzahl- und Kommazahl-Optionen ist
der Index eines Wertes sein Platz im Feld `IntValues` bzw. `FloatValues`
(`SandboxOptionValueSetInt::GetIntIndex`, `SandboxOptionValueSetFloat::GetFloatIndex`); diese Felder
kommen fast alle aus Datenblöcken und sind nicht lesbar. **Für alles außer Ja/Nein ist der Code
deshalb nicht von Hand rechenbar** — den liefert der Knopf „Code kopieren" im Optionsfenster.

### 5. Aufbau des Optionscodes

**Erzeugt** wird der Code in `SandboxOptionPreset::saveOptionsToCode` (aufgerufen von
`SandboxOptionPreset::get_SandboxCode`). Gelesen in dieser Reihenfolge: das statische Feld
`SandboxOptionManager::currentVersion` wird an einen `StringBuilder` gehängt; dann je Schlüssel von
`SandboxOptionPreset::PresetValues` (`Dictionary<SandboxOptions, int>`):
`SandboxOptionManager::IndexToAlpha2` mit dem Schlüssel, `SandboxOptionManager::IndexToAlpha` mit
dem Wert, `String::Format` mit `{0}{1}`.

`PresetValues` füllt `SandboxOptionManager::SaveCurrentToPreset`: über `OptionsByCategory`, je
Option `BaseSandboxOption::IsChanged`, dann `BaseSandboxOption::GetValueIndex` und
`Dictionary::Add`. `IsChanged` vergleicht `CurrentValue` mit `DefaultValue`.

**Gelesen** wird der Code in `SandboxOptionManager::LoadOptionsFromCode(string)` (setzt die
Optionen direkt, vorher `ResetAllToDefault`), in `LoadOptionsFromCode(string, SandboxOptionPreset)`
und in `StoreOptionsInPresetFromCode` (füllen `PresetValues`). Alle drei: `String::get_Chars` an
Stelle 0 und Zugriff auf `currentVersion`, `String::Substring` ab 1, `String::get_Length`, dann je
Gruppe `Substring` der Länge 2, `get_Chars` an Stelle + 2, `Alpha2ToIndex`, `AlphaToIndex`,
`Dictionary<SandboxOptions, BaseSandboxOption>::ContainsKey` und `get_Item`. Zwischen
`Alpha2ToIndex` und `ContainsKey` steht kein weiterer Aufruf: die Zahl aus den zwei Buchstaben
**ist** der Enum-Wert von `SandboxOptions.SandboxOptions`.

Das Format:

| Teil | Regel | Beleg |
|---|---|---|
| Kopf | ein Zeichen, in diesem Build **`A`** | `SandboxOptionManager::.cctor` weist `currentVersion` die Konstante 65 zu |
| Option | **zwei** Buchstaben: erster = Enum-Wert geteilt durch 26, zweiter = Rest; jeweils `A` + Zahl | `IndexToAlpha2(int)`: Grenzen 0 und 676, Konstanten 65 und 26, Format `{0}{1}`; `Alpha2ToIndex(string)`: „exactly 2 letters", erstes Zeichen − 65, mal 26, plus zweites − 65 |
| Wert | **ein** Buchstabe: `A` + Index des Wertes in der Wertemenge der Option | `IndexToAlpha(int)`: Grenzen 0 und 26, Konstante 65; `AlphaToIndex(char)`: `Char::ToUpper`, Grenzen 65 und 90 |
| Welche Optionen | nur die, die von der Vorgabe abweichen | `SaveCurrentToPreset` → `IsChanged` |
| Reihenfolge beim Erzeugen | nach Kategorie, darin in der Reihenfolge des Anlegens in `SetupOptions` | `SaveCurrentToPreset` läuft über `OptionsByCategory` |
| Reihenfolge beim Lesen | *geschlossen:* gleichgültig — jede Gruppe wird einzeln gesetzt | Schleife über Dreiergruppen |

*Geschlossen aus den Konstanten* (3, 0, 3, 2 vor `Substring`; am Ende zweimal 1): die Zahl der
Gruppen ist Länge durch 3, ein oder zwei überzählige Zeichen am Ende fielen damit unter den Tisch.
Kleinbuchstaben werden angenommen (`Char::ToUpper`, `String::ToUpperInvariant`).

*Gelesen, Folge geschlossen:* Die beiden Wege in eine Vorlage prüfen den Index
(`BaseSandboxOption::GetValueSet`, `SandboxOptionValueSet::IsValidIndex`) und tragen mit
`Dictionary::Add` ein — eine Option, die im Code **zweimal** steht, wirft dort vermutlich eine
Ausnahme. Was bei falschem Kopfzeichen, leerem Code oder ungültigem Index genau geschieht
(überspringen oder abbrechen), ist **nicht gelesen**.

### 6. Probe an echten Codes

**Probe 1 — eine vom Spiel geschriebene Nutzervorlage** (`%APPDATA%\7DaysToDie\Presets\Katze.xml`,
19. Juli 2026). `SandboxOptionManager::SavePresetToFile` schreibt neben dem Code einen Kommentar
mit Kategorie, Optionsname und Wert jeder geänderten Option
(`BaseSandboxOption::get_OptionNameText`, `GetValueTextFromIndex`) — Code und Klartext stehen also
in derselben Datei. Code: `ABBDEKBFFE`.

| Gruppe | Rechnung | Option laut Enum | Wert | Klartext des Spiels in der Datei |
|---|---|---|---|---|
| `A` | Kopf | | | |
| `BBD` | 1·26 + 1 = 27 | `DropOnDeath` | `D` = Index 3 | „Fallenlassen bei Tod: Nur Rucksack" |
| `EKB` | 4·26 + 10 = 114 | `MaxDegradationAmount` | `B` = Index 1 | „Reparaturabnutzung: 5 %" |
| `FFE` | 5·26 + 5 = 135 | `TraderBuyLimit` | `E` = Index 4 | „Händler-Kauflimit: 4" |

`Localization.csv` bestätigt die Namen: `goDropOnDeath` = „Fallenlassen bei Tod",
`goMaxDegradationAmount` = „Reparaturabnutzung", `goTraderBuyLimit` = „Händler-Kauflimit",
`goBackpack` = „Nur Rucksack". Drei Gruppen, drei geänderte Optionen, Reihenfolge wie die
Kategorien im Kommentar (General, Crafting, Traders). **Die Formatbeschreibung erklärt den Code
vollständig.**

**Probe 2 — der Code in `serverconfig.xml`** (liegt lose im Spielordner):
`AAAJABJACJADJARFBNC`, laut Kommentar dort „the default difficulty of Adventurer".

| Gruppe | Enum-Wert | Option | Wert-Index |
|---|---|---|---|
| `AAJ` | 0 | `RangedDamage` | 9 |
| `ABJ` | 1 | `MeleeDamage` | 9 |
| `ACJ` | 2 | `BlockDamage` | 9 |
| `ADJ` | 3 | `TerrainDamage` | 9 |
| `ARF` | 17 | `IncomingDamage` | 5 |
| `BNC` | 39 | `AISmellMode` | 2 |

Sechs Optionen, wie man sie von einer Schwierigkeitsstufe erwartet; welche Zahlen hinter den
Indizes stehen, ist nicht lesbar. `BiomeProgression` (`CD`) kommt nicht vor — unter „Adventurer"
gilt also die Vorgabe.

**Indiz, kein Beleg — Vanillas eingebaute Vorlagen.** `SandboxOptionManager::LoadInternalPresets`
lädt sie nicht aus einer losen Datei, sondern über `Resources::Load` aus dem Text-Asset
`Data/Sandbox/sandbox_presets`; einen Ordner `Data\Sandbox` gibt es auf der Platte nicht. Das
Asset liegt gepackt in `7DaysToDie_Data\data.unity3d`. Eine rohe Textsuche darin findet nur
Bruchstücke (die Packung zerreißt den Text): eine Vorlage mit `default="true"`, deren Code auf
`…ARFBNC` endet (passt zu „Adventurer"); bei „Nomad" ein `always_show`, das genau die sechs
Optionen aus Probe 2 nennt; und ein Code `ABEABTBGBBBWADFN`. Entpackt oder ins Repository
übernommen wurde nichts.

**Der Beispielcode im Kommentar der Datei** (`ABEABTBBWADFP`) ist formal erklärbar — Kopf `A`,
dann `BEA` (30 `EnemySpawnMode`, Index 0), `BTB` (45 `BiomeDayAnimalRespawn`, Index 1), `BWA`
(48 `BloodMoonFrequency`, Index 0), `DFP` (83 `ResourceLootCount`, Index 15). **Als Probe taugt er
nicht:** `ResourceLootCount` ist eine Kommazahl-Option, und die größte Kommazahl-Wertemenge dieses
Builds hat 15 Werte (Index höchstens 14). *Vermutet:* das Beispiel stammt aus einem älteren
Entwicklungsstand; das Bruchstück oben (`…DFN`, Index 13, dazu die neuere Nacht-Option `GBB`) sieht
wie die heutige Fassung derselben Vorlage aus.

### 7. Rechnung: „alle Vorgaben, nur Biom-Fortschritt aus"

- Kopf: `A`
- Option `BiomeProgression` = 55 = 2·26 + 3 → `C`, `D`
- Wert „aus" = Index 0 in `[aus, ein]` → `A`

**`ACDA`** — berechnet, im Spiel nicht geprüft.

Dass `A` hier „aus" heißt, ruht allein auf der Lesart von `BoolValues` in Abschnitt 4; keine der
beiden Proben enthält eine Ja/Nein-Option.

**Achtung, „alle Vorgaben" ist nicht Vanillas Standard.** Vanilla wählt „Adventurer" vor, und
dessen Code weicht in sechs Optionen von den Vorgaben ab (Probe 2). Eine Vorlage mit `ACDA` und
`default="true"` stellt also nebenbei Schaden und Geruchssinn auf die rohen Vorgaben. Wer
„Adventurer ohne Biom-Fortschritt" will, hängt die Gruppe an Vanillas Code an — in der Reihenfolge,
die das Spiel selbst schriebe (`BiomeProgression` liegt in der Kategorie „World", nach „Entities"):

**`AAAJABJACJADJARFBNCCDA`** — berechnet, im Spiel nicht geprüft.

Weitere Ja/Nein-Schalter nach derselben Rechnung (alle berechnet, nicht geprüft; „aus" = `A`):
`CEA` Temperatur, `CGA` Sturmwarnung, `CBA` Abwurf-Markierung, `EYA` Händler, `EZA` Automaten,
`FJA` Herausforderungen, `FKA` Einstiegs-Herausforderungen, `CQA` Karte, `CRA` Kompass.

## Was das für den Bau heißt

| Punkt | Folgerung |
|---|---|
| Weg | Eine Vorlage in `sandbox_overrides.xml` (per Modlet angehängt): `<preset name="…" description_key="…" code="…" default="true" />`. Reine XML, kein Code, kein Patch. |
| `sandbox_override option="BiomeProgression"` | **Nicht verwenden.** Es schaltet nichts aus; es sperrt nur das Bedienfeld. Wählt der Spieler dann eine Vanilla-Vorlage, stünde der Biom-Fortschritt auf „ein" und ließe sich nicht mehr abstellen. |
| Pflichtangaben | `name`, `code` und `description` oder `description_key` — sonst fällt die Vorlage vermutlich stumm weg. |
| Kein Zwang | `default="true"` wählt nur vor. Erzwingen lässt sich „aus" über diese Datei nicht; das bliebe Weg B (Plan-0002, WP6.3). |
| Dedicated Server | Die Vorlage wirkt dort nicht von selbst; der Betreiber trägt den Code in `serverconfig.xml` unter `SandboxCode` ein. Gehört in die Server-Anleitung. |
| Voreinstellung „700" (N-95) | Ja/Nein-Schalter sind von Hand rechenbar. Für Ganzzahl- und Kommazahl-Optionen braucht es weiter den kopierten Code aus dem Optionsfenster. |
| Namen in der Datei | Die Optionsliste im Kommentar von `sandbox_overrides.xml` ist veraltet: `BiomeZombieRespawn`, `BiomeAnimalRespawn`, `BiomeEnemyDensity` gibt es im Enum nicht (dort `BiomeDay…`/`BiomeNight…`), 18 Enum-Namen fehlen in der Liste. Maßgeblich ist das Enum `SandboxOptions.SandboxOptions`. |

## Offen — nur das Spiel zeigt es

Die ersten drei Punkte sind zusammen ein Test von wenigen Minuten im Hauptmenü, ohne eine Welt zu
laden: Optionsfenster öffnen, Code einfügen, ansehen.

1. **Stimmt `ACDA`?** Im Fenster der Sandbox-Optionen den Code einfügen
   (`XUiC_SandboxOptions::BtnPasteCode_OnPressed`): steht danach „Biomfortschritt" auf „Nein" und
   sonst alles auf Vorgabe? Gegenprobe: die Option von Hand umstellen, „Code kopieren", vergleichen.
2. **Erscheint eine Mod-Vorlage** in der Gruppe „Gemoddet", und ist sie mit `default="true"` beim
   Öffnen von „Neues Spiel" vorgewählt — auch dann, wenn zuletzt eine andere Vorlage benutzt wurde?
   Nicht gelesen ist außerdem die Reihenfolge beim Start: `SandboxOptionManager::LoadPresets` leert
   die Liste; liefe es **nach** dem Lesen der XML, wäre die Mod-Vorlage weg.
3. **Sperrt `sandbox_override` wirklich nur das Feld?** Ein Test-Override auf eine harmlose Option
   zeigt, ob der Wert dabei auf die Vorgabe springt (Kommentar der Datei) oder stehen bleibt
   (Lesart hier).
4. **Kommt der Wert im Spiel an?** Neue Welt mit der Vorlage: `GameStat.BiomeProgression = False`
   im Protokoll, keine Biom-Gefahr-Buffs (deckt sich mit S-05 der Prüfliste).
5. **Dedicated Server** (Regel 5): wirkt `SandboxCode` in `serverconfig.xml` wie gelesen, und
   bekommt der zweite Client denselben Stand?
6. **Bestehende Spielstände:** nicht gelesen, ob ein gespeicherter Code beim Fortsetzen erhalten
   bleibt oder die vorgewählte Vorlage ihn überschreibt.
7. **Fehlerfälle:** falsches Kopfzeichen, doppelte Option, ungültiger Index, fehlende
   Pflichtangabe — statisch nicht entscheidbar (Sprünge nicht lesbar); ein Blick ins Protokoll
   klärt es, falls es je nötig wird.
8. **Vorgaben der Kommazahl-Optionen** (`StormFreq`, `WorkstationsInTheWild`) und die Inhalte der
   Wertemengen: mit diesem Werkzeug nicht lesbar; das Optionsfenster zeigt sie.
