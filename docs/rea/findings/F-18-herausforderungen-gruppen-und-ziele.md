# F-18 — Herausforderungen: Gruppen dürfen schrumpfen, entfernte Einträge fallen beim Laden weg

**Stand:** 23. November 2026 (Bezug: Sperrliste; Modlet `700_50_Fortschritt`, `challenges.xml`)
**Frage:** 35 von 148 sichtbaren Herausforderungen sind mit unserer Mod unerfüllbar, weil ihr Ziel
einen gesperrten Gegenstand nennt. Lassen sich Ziele per XML ersetzen und einzelne
Herausforderungen entfernen oder verbergen — und was tut das Spiel dann (Gruppe mit weniger als
zehn Einträgen, alter Spielstand, Verweise auf fehlende Namen)?
**Antwort (statisch gelesen, im Spiel nicht gesehen):**

1. **Kein Attribut verbirgt eine einzelne Herausforderung.** Verborgen wird nur eine ganze Gruppe
   (`hidden_by`) oder ein ganzer Reiter (`show_type`). Für eine einzelne bleibt: entfernen,
   Ziel ersetzen oder in eine andere Gruppe umhängen.
2. **Eine Gruppe darf schrumpfen, auch auf 3.** „Gruppe vollständig" ist keine Zahl, sondern
   „jede Herausforderung dieser Gruppe im Tagebuch ist eingelöst". Die Oberfläche hat **zehn feste
   Plätze je Gruppe, keine Seiten**; bei weniger bleiben Plätze leer (Vanilla selbst: `Silly` mit 7
   in einer Zehner-Zeile). **Mehr als zehn** passen nicht ins Fenster, zählen aber weiter für
   „vollständig" — eine solche Gruppe wäre nicht abschließbar.
3. **Ein alter Spielstand bricht nicht** (*geschlossen*): der gespeicherte Eintrag einer
   entfernten Herausforderung wird vollständig gelesen und dann verworfen. Gefährlich sind dagegen
   **Verweise in der XML**: eine Herausforderung mit `group="X"` ohne Gruppe X, ein
   `ChallengeComplete … is_group="true"` auf eine fehlende Gruppe und die Namensliste der Aktion
   `CompleteChallenge` in `gameevents.xml` greifen ohne Vorprüfung zu.
4. **`CureDebuff item="a,b,c"` ist ein Entweder-oder**; auch `debuff` ist eine Liste. Gezählt wird
   „ein gelisteter Gegenstand wurde benutzt, während einer der genannten Buffs anlag". Ein nicht
   gelisteter Gegenstand zählt nach dieser Lesart **nicht**.
5. **`Harvest` zählt Abbau-Ereignisse, `Gather` zählt Besitz.** `Craft`, `UseItem`, `CureDebuff`
   und `BlockPlace` vergleichen über den **Namen**, `Harvest`, `Gather` und `Wear` über die
   **Typnummer** des Gegenstands. Ein unbekannter Name gibt **keinen Ladefehler**, ist aber nicht
   überall harmlos (Abschnitt 7.8).
6. **Bestätigt:** der Reiter mit `show_type="BiomeProgression"` hängt am statischen Feld
   `World::BiomeProgressionEnabled`. Ist es aus, gilt die Gruppe auch als **nicht aktiv**: ihre
   Herausforderungen werden nicht gestartet, zählen nichts und blenden nichts ein.
7. `title_key`, `short_description_key`, `reward_text_key` werden **beim Laden** übersetzt;
   `description_key`, `hint`, `prerequisite_hint` bleiben Schlüssel und werden erst bei der Anzeige
   aufgelöst. `icon` ist ein Bildname, den der Code der Herausforderungen **nicht prüft**.

**Kein Patch.** Dieses Finding trägt keinen Harmony-Eingriff und steht darum nicht im
Patch-Manifest; es belegt, was das Spiel mit geänderter XML tut.

## Gebunden an diesen Build

| | |
|---|---|
| Build | 7 Days to Die V 3.40 b10 (Stable) |
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

Dieselbe Datei wie in F-17; das Werkzeug gibt SHA-256, MVID und Länge bei jedem Aufruf aus, die
Werte stimmen überein.

**Werkzeug:** `mod700meta types <dll> --contains Challenge` (82 Typen), `mod700meta members <dll>
--type … --il` für alle 82 und zusätzlich für `ItemClass`, `ItemActionEat`, `GameUtils`,
`QuestEventManager`, `RecipeUnlockData`, `XUiC_CategoryList`, `XUiC_QuestTrackerWindow`,
`WorldStaticData`, `SandboxOptions.SandboxOptionManager`; `--callers` für `ChallengeJournal`,
`Challenges.Challenge`, `Challenges.ChallengeGroup`, `Challenges.ChallengeCategory`,
`Challenges.ChallengeClass`, `Challenges.BaseChallengeObjective`, `ChallengesFromXml`,
`QuestEventManager`, `GameUtils`; `mod700meta find-string <dll> --text VariantHelper`
(54 940 Methodenrümpfe). Gelesen werden Metadaten und IL-Bytes; die Assembly wird nicht geladen,
nicht ausgeführt und nicht dekompiliert.

**Daneben gelesene lose Dateien** (nichts davon liegt im Repository): `Data\Config\challenges.xml`,
`gameevents.xml`, `blocks.xml`, `XUi_InGame\windows.xml`, `XUi_InGame\templates.xml`. Einen
Ordner `Data\Config\XUi` gibt es in diesem Build nicht; die Fenster der Herausforderungen stehen
in `XUi_InGame`.

**Vanillas Bestand** (XML ohne Kommentare gezählt): 4 Kategorien, 19 Gruppen, 175
Herausforderungen, 202 Ziele. 16 Gruppen haben 10 Einträge, die vier Biom-Gruppen und `Silly`
haben 7. Ohne die drei Twitch-Gruppen (27) bleiben die 148 sichtbaren.

**Was der Auszug zeigt und was nicht:** `--il` gibt je Methode Aufrufe, Feldzuweisungen und
ganzzahlige Konstanten in ihrer Reihenfolge aus, dazu je eine entdoppelte Liste der gelesenen
Felder und der Zeichenketten. Er zeigt **nicht**: Sprünge, Vergleiche, Rechenoperationen, das Laden
von Argumenten, Gleitkomma-Konstanten und `null`. Ob zwischen zwei Aufrufen ein „wenn" oder eine
Null-Prüfung steht, ist deshalb nie gelesen, sondern **geschlossen** — unten so gekennzeichnet.
Wo zwei Lesarten gleich gut passen, steht **nicht lesbar**.

## Der Beleg

### 1. Wie das Spiel `challenges.xml` liest

`WorldStaticData::.cctor` ruft `ChallengesFromXml::CreateChallenges(XmlFile)`. In der Liste der
Dateinamen dort steht `challenges` nach `blocks`, `buffs`, `items` und `recipes` und vor
`gameevents` — *geschlossen:* Gegenstände, Blöcke, Buffs und Rezepte sind bekannt, wenn die Ziele
ihre Namen nachschlagen.

`ChallengesFromXml/<CreateChallenges>d__1::MoveNext` leert zuerst die drei Verzeichnisse
(`ChallengeClass::s_Challenges`, `ChallengeGroup::s_ChallengeGroups`,
`ChallengeCategory::s_ChallengeCategories`), ruft `ChallengesFromXml::ParseNode` und zum Schluss
`ChallengeClass::InitChallenges`. `ParseNode` liest an der Wurzel `default_reward`,
`default_reward_text_key`, `default_reward_text` und verteilt die Kinder nach Namen auf
`ParseChallenge`, `ParseChallengeGroup`, `ParseChallengeCategory`; jedes andere Element wirft
(`Unrecognized xml element `).

Alle drei Verzeichnisse sind vom Typ `CaseInsensitiveStringDictionary` — Groß- und Kleinschreibung
der Namen ist beim Nachschlagen gleichgültig. Ein fehlendes `name` und ein doppelter Name werfen
(`… must have an name attribute`, `… already exists!`). **Folge für ein Modlet:** eine
Herausforderung unter einem vorhandenen Namen anhängen geht nicht; ändern heißt `set`/`remove`.

**Gelesene Attribute** (aus den Zeichenketten und Zuweisungen der jeweiligen `ParseElement`):

| Element | Attribut | Feld und Wirkung |
|---|---|---|
| `challenge_category` | `name` | Pflicht |
| | `title_key`, `title` | `Title`; der Schlüssel geht sofort durch `Localization::Get` |
| | `icon` | `Icon`. *Geschlossen:* ohne `icon` gibt es keinen Reiter (`XUiC_CategoryList::SetupCategoriesBasedOnChallengeCategories` vergleicht `Icon` vor `CanShow`) |
| | `show_type` | `showType` über `Enum::Parse`, Groß/Klein egal. Werte des Enums `ChallengeCategory/ShowTypes`: `Normal` 0, `CVar` 1, `Twitch` 2, `BiomeProgression` 3 |
| | `show_value` | `showValue`: Name der CVar für `show_type="cvar"` |
| | `display_key` | `DisplayKey`: wählt das Listen-Raster im Fenster (Abschnitt 4) |
| `challenge_group` | `name` | Pflicht |
| | `title_key`, `title` | `Title` |
| | `category` | `Category`: Name der Kategorie |
| | `reward_event` | `RewardEvent`: Name einer Aktionsfolge aus `gameevents.xml` (Abschnitt 3). Kein Vorgabewert |
| | `reward_text_key`, `reward_text` | `RewardText` (Anzeige rechts in der Gruppenzeile) |
| | `objective_text_key`, `objective_text` | `ObjectiveText` (nur das Biom-Raster zeigt ihn) |
| | `hidden_by` | `HiddenBy`: Name einer **Gruppe**, Abschnitt 2 |
| | `link_challenges` | `LinkChallenges`, siehe unten |
| | `is_intro` | `IsIntro`, Abschnitt 2 |
| | `is_random`, `active_challenge_count`, `day_reset` | Zufallsgruppen mit Tagesrücksetzung; Vanilla nutzt sie nur auskommentiert. `ActiveChallengeCount` hat die Vorgabe **10** |
| `challenge` | `name` | Pflicht |
| | `group` | sucht die Gruppe **ohne Vorprüfung** in `s_ChallengeGroups` und hängt die Herausforderung an `ChallengeGroup::ChallengeClasses` |
| | `icon`, `title_key`, `title`, `short_description_key`, `short_description`, `description_key`, `description`, `hint`, `prerequisite_hint` | Abschnitt 9 |
| | `reward_event` | `RewardEvent`; fehlt es, gilt `default_reward` der Wurzel |
| | `reward_text_key`, `reward_text` | `RewardText`; fehlt beides, gilt der Vorgabetext der Wurzel |
| | `redeem_always` | `RedeemAlways`, siehe unten |
| | `harvest_required` | Kommaliste aus `Resource`, `Ore`, `Seed`, `Crop` (`ChallengeClass/ResourceRequiredTypes`), siehe unten |
| | `tags` | `TagName`, `Tags`; einziger Leser ist `ChallengeGroup::GetChallengeClassesForCreate` (Auswahl in Zufallsgruppen). Vanilla setzt es an keiner aktiven Herausforderung |
| `objective` | `type` | Pflicht; Klasse `Challenges.ChallengeObjective<type>` über `ReflectionHelpers::GetTypeWithPrefix`, sonst Ausnahme `No objective class '…' found!` |
| | `count` | `MaxCount`, Vorgabe 1 |
| | `biome` | `Biome`, Abschnitt 7.1 |
| | `show_requirements` | `ShowRequirements`, Vorgabe wahr, Abschnitt 7.7 |
| | je Typ | Abschnitt 7 |

Als Kinder kennt `ParseChallenge` nur `property` und `objective`, dazu `effect_group` über
`MinEffectController::ParseXml`. Das `property`-Kind wird in ein `DynamicProperties`-Objekt gelesen,
das in kein Feld geschrieben wird — *gelesen als:* ohne Wirkung. **Unbekannte Attribute stören
nicht:** Vanilla selbst trägt `block_tag` an einem `ChallengeStatAwarded`-Ziel, dessen Klasse das
Attribut gar nicht liest.

**Die erfragten Schalter im Einzelnen:**

- **`link_challenges`** — `ChallengesFromXml::ParseChallenge` führt je Gruppe die zuletzt gelesene
  Herausforderung (`LastGroupChallenge`) und schreibt bei gesetztem `LinkChallenges` deren Feld
  `NextChallenge`. Es entsteht eine Kette **in der Reihenfolge der XML**. Leser:
  `ChallengeJournal::GetNextChallenge` (aus `Challenge::EndChallenge`, also die Verfolgung nach
  einem Abschluss) und `GetNextRedeemableChallenge`. Die Kette wird bei jedem Laden neu gebaut;
  *geschlossen:* fehlt ein Glied, schließt sie sich von selbst.
- **`redeem_always`** — einziger Leser ist `Challenge::get_ReadyToComplete`. *Geschlossen:* die
  Herausforderung ist schon einlösbar, solange sie noch aktiv ist (Vanilla: `redeemChallenge`).
- **`harvest_required`** — `ChallengeClass::HandleResourceRequirement` liest
  `XUiM_Recipes::HarvestingOutputModifier`, `MiningOutputModifier`, `SeedDropOutputModifier`,
  `CropOutputModifier` und `ItemActionAttack::BlockDamagePercent`. Einziger Aufrufer ist
  `Challenge::StartChallenge`; liefert die Methode wahr, laufen alle Ziele durch
  `HandleAutoComplete`, `AutoCompleted` wird wahr und der Zustand `Redeemed`. *Geschlossen:* eine
  Schutzklausel für Sandbox-Einstellungen, die den Ertrag auf null stellen — die Herausforderung
  erledigt sich dann selbst, **ohne** `Redeem` und damit ohne Belohnung. Für uns kein Hebel: die
  Bedingung hängt an Sandbox-Werten, nicht an der XML.
- **`hidden_by`, `is_intro`, `show_type`/`show_value`** — Abschnitt 2. **`tags`** — siehe Tabelle.

### 2. Sichtbarkeit: Reiter, Gruppe — und nichts für die einzelne Herausforderung

`ChallengeClass::ParseElement` liest die 16 Attribute der Tabelle, keines davon steuert die
Sichtbarkeit. `XUiC_ChallengeEntry` kennt nur `IsChallengeVisible`, und das kommt beide Male
(`set_Entry`, `Update`) aus `ChallengeGroup::IsVisible`. **Gelesen:** es gibt keinen Schalter je
Herausforderung.

**Reiter.** `ChallengeCategory::CanShow(EntityPlayer)` liest `showType` und dazu, in dieser
Reihenfolge, `EntityPlayer::get_TwitchEnabled` (Konstante 2), `EntityBuffs::GetCustomVar` mit
`showValue` (Konstante 1), `World::BiomeProgressionEnabled` (Konstante 3) und
`ChallengeJournal::AllowChallenges`. Aufrufer: `XUiC_CategoryList::
SetupCategoriesBasedOnChallengeCategories` (baut die Reiter) und `ChallengeGroup::IsVisible`.

**Aktiv.** `ChallengeCategory::get_IsActive` liest nur `showType` (Konstante 3),
`World::BiomeProgressionEnabled` und `ChallengeJournal::AllowChallenges`. *Geschlossen:* allein
der Typ `BiomeProgression` macht eine Kategorie inaktiv; `cvar` und `twitch` verbergen bloß den
Reiter. `ChallengeGroup::get_IsActive` liest davor `IsIntro` und
`ChallengeJournal::IntroChallengesEnabled` und fragt dann die Kategorie — über
`s_ChallengeCategories` **ohne Vorprüfung**; eine Gruppe mit unbekannter `category` wirft dort
vermutlich.

**Gruppe.** `ChallengeGroup::IsVisible(EntityPlayer)` liest `IntroChallengesEnabled`, `IsIntro`,
`HiddenBy`, ruft `ChallengeCategory::CanShow`, prüft `s_ChallengeGroups` mit `ContainsKey` auf den
Namen aus `HiddenBy`, ruft dessen `get_IsActive` und liest `IsComplete`. *Geschlossen:* eine Gruppe
mit `hidden_by="X"` bleibt verborgen, bis Gruppe X vollständig ist; gibt es X nicht oder ist X
nicht aktiv, ist sie sichtbar. Die genaue Verschachtelung ist **nicht lesbar**.
`ChallengeJournal/<unhideRowLater>d__27` markiert nach dem Abschluss einer Gruppe alle Gruppen, deren
`HiddenBy` ihren Namen trägt, zum Neuzeichnen (Ton `ui_challenge_unhide_row`).

Verborgen heißt dabei nicht „weg": `XUiC_ChallengeGroupList::updateChallengeEntries` ruft
`IsVisible` nicht — die Zeile der Gruppe bleibt, nur ihre Einträge werden anders gezeichnet
(`XUiC_ChallengeEntry::GetBindingValueInternal` trägt dafür den Bildnamen `ui_game_symbol_other`).

**`is_intro`** — bei abgeschaltetem `IntroChallengesEnabled` ist die Gruppe nicht aktiv; das
Raster legt eine Blende darüber (Bindung `intro_disabled`), und
`ChallengeJournal::CompleteIntroChallenges` schließt ihre Einträge ab.

### 3. „Gruppe vollständig" und die Gruppenbelohnung

**Gelesen.** `Challenge::Redeem` ruft `GameEventManager::HandleAction` mit
`ChallengeClass::RewardEvent`, dann `ChallengeJournal::HandleChallengeRedeemed` und
`ChallengeJournal::HandleChallengeGroupComplete(ChallengeGroup)`. Aufrufer von `Redeem`:
`XUiC_ChallengeEntryDescriptionWindow::CompleteCurrentChallenege` (der Knopf) und
`Challenge::CompleteChallenge` (Konsole, Spielereignis, Einstieg überspringen).

`HandleChallengeGroupComplete` läuft über `ChallengeJournal::Challenges`, liest je Eintrag
`Challenge::ChallengeGroup` und `Challenge::ChallengeState` (Konstante 2 = `Redeemed`). Im Rumpf
der Schleife stehen: `IsComplete` auf 0 und der Ton `ui_challenge_redeem`. Nach der Schleife:
`GameEventManager::HandleAction` mit `ChallengeGroup::RewardEvent`, der Ton
`ui_challenge_complete_row`, `IsComplete` auf 1, Eintrag in
`CompleteChallengeGroupsForMinEvents`, `unhideRowLater`.

*Geschlossen:* die Gruppe ist vollständig, wenn **jeder Tagebuch-Eintrag dieser Gruppe eingelöst**
ist; der erste nicht eingelöste beendet die Methode. In der ganzen Methode steht **keine Zahl**
außer dem Zustand 2 — weder 10 noch `ActiveChallengeCount`. Die Belohnung gibt es genau einmal, in
dem Augenblick, in dem die letzte Herausforderung eingelöst wird.

**Folgen für das Schrumpfen** (*geschlossen*):

- Eine Gruppe mit 3 Herausforderungen ist nach 3 Einlösungen vollständig und belohnt.
- `ChallengeJournal::StartChallenges` (beim Start und nach dem Laden) setzt `IsComplete` je Gruppe
  erst auf 1 und nimmt es zurück, sobald ein Eintrag nicht eingelöst ist — **ohne** die Belohnung
  auszulösen. Wer in einem alten Spielstand genau die verbleibenden Einträge schon eingelöst hat,
  findet die Gruppe als vollständig vor (Folgegruppen sichtbar, Gruppen-Effekte aktiv), bekommt
  die Gruppenbelohnung aber **nicht nachgereicht**.
- Eine **leere** Gruppe gilt aus demselben Grund sofort als vollständig; ihre Zeile bleibt im
  Fenster stehen, ihre Belohnung kommt nie. Leere Gruppen also mit entfernen.
- Das Ziel `ChallengeComplete … is_group="true"` rechnet seine Zielzahl aus der Gruppe selbst
  (Abschnitt 6) und passt sich an.

### 4. Die Oberfläche: feste Plätze, keine Seiten

**Gelesen aus `XUi_InGame\windows.xml`**, Fenster `windowChallengeList` (Controller
`ChallengeEntryListWindow`): ein Raster `categories` für die Reiter und zwei Raster mit Controller
`ChallengeGroupList` — `newList` mit `rows="6"` und `weatherList` mit `display_key="weather"` und
`rows="4"`. **Aus `templates.xml`:** die Zeile `challenge_list_entry` (Controller
`ChallengeGroupEntry`) enthält ein Raster mit `rows="1" cols="10"` (Controller
`ChallengeEntryList`), die Zeile `weather_challenge_list_entry` eines mit `cols="7"`. Alle Raster
tragen `repeat_content="true"`. An den Einträgen ist `visible="{hasentry}"` **auskommentiert**.

**Gelesen aus dem Code:**

- `XUiC_ChallengeEntryListWindow::CategoryList_CategoryChanged` holt den `DisplayKey` der
  gewählten Kategorie, `GetListFromKey` zeigt das Raster mit gleichem `display_key` und versteckt
  die anderen. Vanillas Biom-Kategorie trägt `display_key="weather"`, alle anderen keinen.
- `XUiC_ChallengeGroupList::Init` sammelt seine Kinder in `entryList`.
  `updateChallengeEntries` läuft über `ChallengeJournal::ChallengeGroups`, vergleicht
  `ChallengeGroup::Category` mit dem Namen des gewählten Reiters und belegt die Zeilen der Reihe
  nach; übrige Zeilen bekommen `set_Entry` ohne Gruppe.
- `XUiC_ChallengeGroupEntry::Update` filtert `ChallengeJournal::Challenges` auf die eigene Gruppe
  und gibt die Liste an `XUiC_ChallengeEntryList::SetChallengeEntryList`.
- `XUiC_ChallengeEntryList::Update` läuft über **seine Plätze** (`entryList`), nicht über die
  Herausforderungen: liegt der Platz innerhalb der Liste, bekommt er den Eintrag, sonst
  `set_Entry` ohne Eintrag.
- Keiner der vier Controller hat ein Feld oder einen Aufruf für Seiten oder Blättern.

*Geschlossen:*

| Fall | Was geschieht |
|---|---|
| weniger als 10 (z. B. 3) | 3 Plätze belegt, 7 leer. Weil `visible="{hasentry}"` auskommentiert ist, bleiben die leeren Rahmen vermutlich stehen. Vanilla hat den Fall: `Silly` mit 7 im Zehner-Raster |
| genau 10 | wie Vanilla |
| mehr als 10 | der elfte Eintrag hat keinen Platz, ist nicht anwählbar und nicht einlösbar — zählt aber in `HandleChallengeGroupComplete` weiter mit. Die Gruppe würde nie vollständig |
| mehr als 6 Gruppen in einem Reiter | die siebte Gruppe hat keine Zeile. `Basics` und `Advanced` haben schon je 6 |
| Biom-Raster | 4 Zeilen zu 7 Plätzen, in Vanilla voll belegt |

Die Reihenfolge in der Zeile folgt `ChallengeJournal::Challenges`; `ChallengeJournal::Read`
sortiert nach `ChallengeClass::get_OrderIndex`, einem Zähler, der im Konstruktor von
`ChallengeClass` hochläuft — also **Reihenfolge der XML**. Eine per Modlet angehängte
Herausforderung steht hinten in ihrer Gruppe.

**Nicht lesbar:** ob `ActiveChallengeCount` (Vorgabe 10) auch gewöhnliche Gruppen deckelt.
`ChallengeGroupEntry::AddAnyMissingChallenges` und `ResetChallenges` lesen das Feld unmittelbar
nach `IsRandom`; ob der Zugriff nur im Zufalls-Zweig liegt, zeigt der Auszug nicht. Ein Grund mehr,
bei höchstens zehn zu bleiben.

### 5. Spielstand: gelesen wird alles, behalten nur, was die XML noch kennt

**Schreiben.** `ChallengeJournal::Write` (aus `PlayerDataFile::Write`) schreibt die Version 2, die
Zahl der Einträge und je Eintrag `Challenge::Write`: Version, **Name der Herausforderung**
(`ChallengeClass::Name`), Zustand, `AutoCompleted`, Version und Zahl der Ziele und je Ziel
`BaseChallengeObjective::WriteObjective` — die Typnummer aus `get_ObjectiveType` und der
Zählerstand `current`. Danach je Gruppe Name und `LastUpdateDay`, zuletzt der Name der verfolgten
Herausforderung. Gespeichert ist also **nur Name, Zustand und je Ziel Typ und Zählerstand** —
kein Gegenstandsname, keine Zielzahl.

**Lesen.** `Challenge::Read` liest in dieser Reihenfolge: Version, Name, Zustand, `AutoCompleted`,
die Ziele über `BaseChallengeObjective::ReadObjective` (legt die Klasse allein nach der
gespeicherten Typnummer an) — und **erst danach** `s_Challenges` mit `ContainsKey` und
`get_Item`, dann die Zuweisung von `ChallengeClass` und `ChallengeGroup`. **Gelesen:** der
Datenstrom wird vollständig verbraucht, bevor der Name nachgeschlagen wird, und das Nachschlagen
ist mit `ContainsKey` abgesichert.

`ChallengeJournal::Read` (aus `PlayerDataFile::Read`) ruft je Eintrag `Challenge::Read`, dann
`Challenge::ResetToChallengeClass` und danach `Dictionary::Add` auf `ChallengeDictionary`.
`ResetToChallengeClass` liest `ChallengeClass`, trägt die Konstante 0 und ruft
`ChallengeClass::ResetObjectives`; ihr einziger Aufrufer ist `ChallengeJournal::Read`.

*Geschlossen:* fehlt die Herausforderung in der XML, bleibt `ChallengeClass` leer,
`ResetToChallengeClass` gibt falsch zurück und der Eintrag wird **übersprungen** — er kommt nicht
ins Tagebuch und wird beim nächsten Speichern nicht mehr geschrieben. Dafür spricht: der
Rückgabewert hat keinen anderen Zweck, und `ResetObjectives` endet mit der Konstante 1. Die
Gegenlesart — der Eintrag würde doch eingetragen — liefe auf einen Zugriff auf
`ChallengeClass::Name` an einem leeren Objekt hinaus, also einen Abbruch beim Laden. Welche der
beiden gilt, ist **nicht lesbar**; die Bauweise spricht deutlich für das Überspringen.

**Der Rest ist abgesichert** (*gelesen*): die Gruppeneinträge werden beim Lesen aus
`s_ChallengeGroups` **neu angelegt** und die gespeicherten Tage nur per Namensvergleich
zugeordnet — eine entfernte Gruppe fällt still weg. Der Name der verfolgten Herausforderung wird
mit `ContainsKey` geprüft.

**Abgleich mit geänderter XML.** `ChallengeClass::ResetObjectives(Challenge)` vergleicht die Zahl
der gespeicherten Ziele mit der der XML (`List::RemoveRange` für überzählige) und je Platz den
Laufzeittyp (`Object::GetType`, `Type::op_Inequality`). Aufgerufen werden
`BaseChallengeObjective::Clone` auf dem Ziel der XML, Zuweisungen von `Owner`, `MaxCount`,
`ShowRequirements`, `Biome`, dann `CopyValues`, `List::set_Item`, `Utils::FastMin` mit
`set_Current`; fehlende Ziele kommen mit `List::Add` dazu; ist die Herausforderung nicht mehr
aktiv, folgen `set_Current` und `set_Complete` mit 1. *Geschlossen:*

- **Gleicher Typ am gleichen Platz:** der alte Zählerstand bleibt und wird auf die neue Zielzahl
  gekappt; Gegenstand, Zahl und Biom kommen aus der XML. Wer in `harvestPolymers` nur den
  Gegenstand tauscht, erbt also den alten Stand („30 von 50").
- **Anderer Typ:** das Ziel wird frisch aus der XML angelegt.
- **Schon abgeschlossen oder eingelöst:** bleibt es, gleich was das Ziel jetzt verlangt — der
  Zustand hängt am **Namen**.
- Soll alles neu beginnen, braucht die Herausforderung einen **neuen Namen**.

**Neue Einträge.** `ChallengeJournal::StartChallenges` (aus `QuestJournal::StartQuests`) ruft je
Gruppe `ChallengeGroupEntry::AddAnyMissingChallenges`: was in `ChallengeGroup::ChallengeClasses`
steht und in `ChallengeDictionary` fehlt, wird mit `ChallengeClass::CreateChallenge` angelegt. Neue
oder umbenannte Herausforderungen erscheinen damit auch in alten Spielständen. Die Gruppe eines
Eintrags kommt beim Lesen aus der XML, nicht aus dem Spielstand — *geschlossen:* **Umhängen in
eine andere Gruppe** (`group="…"`) verträgt ein alter Spielstand.

**Eine Vanilla-Falle am Rand:** `ChallengeObjectiveHarvestByTag::get_ObjectiveType` liefert
dieselbe Nummer 9 wie `ChallengeObjectiveHarvest`. Ein gespeichertes `HarvestByTag`-Ziel wird
also als `Harvest` zurückgelesen, der Typvergleich schlägt an — *geschlossen:* sein Zählerstand
geht bei jedem Laden verloren. Vanilla benutzt den Typ nirgends. `GatherByTag` hat mit 26 eine
eigene Nummer.

### 6. Verweise auf Namen — was eine Vorprüfung hat und was nicht

| Stelle | Zugriff | Bei fehlendem Namen |
|---|---|---|
| `<challenge group="X">` (`ChallengeClass::ParseElement`) | `s_ChallengeGroups` mit `get_Item`, kein `ContainsKey` | *geschlossen:* Ausnahme **beim Laden der XML** |
| `ChallengeComplete … is_group="true"` (`ChallengeObjectiveChallengeComplete::UpdateMax`, über `BaseInit` aus `ChallengeClass::InitChallenges`) | `s_ChallengeGroups` mit `get_Item`, kein `ContainsKey` | *geschlossen:* Ausnahme **beim Laden der XML** |
| `ChallengeComplete challenge="X"` ohne `is_group` | `Current_ChallengeComplete` vergleicht den Namen mit `String::Compare`; `get_DescriptionText` ruft `ChallengeClass::GetChallenge` (mit `ContainsKey`) und liest danach `Title` | zählt nie; **nicht lesbar**, ob vor `Title` eine Null-Prüfung steht — sonst Fehler bei der Anzeige |
| `hidden_by="X"` (`ChallengeGroup::IsVisible`) | `ContainsKey` vor `get_Item` | *gelesen:* abgesichert |
| `category="X"` (`ChallengeGroup::get_IsActive`, `IsVisible`) | `s_ChallengeCategories` mit `get_Item` | *geschlossen:* Ausnahme zur Laufzeit |
| Aktion `CompleteChallenge` in `gameevents.xml` (`ActionCompleteChallenge::OnClientPerform`) | teilt die Liste am Komma und greift mit `get_Item` in `ChallengeDictionary`, kein `ContainsKey` | *geschlossen:* Ausnahme, wenn die Aktion läuft |
| Quest-Aktion `QuestActionTrackChallenge` | `ContainsKey` vor `get_Item` | *gelesen:* abgesichert |
| Freischaltung über Herausforderung (`RecipeUnlockData::Init`) | `ChallengeGroup::GetGroup`, `ChallengeClass::GetChallenge`, beide mit `ContainsKey` | *gelesen:* abgesichert |
| Konsolenbefehl `challenges` | `ContainsKey`, Meldung `Challenge '…' does not exist` | *gelesen:* abgesichert |

**Vanillas Verweise:** `challenges.xml` hat zwei `ChallengeComplete`-Ziele, beide in der Gruppe
`Basics` (`redeemChallenge` auf sich selbst, `groupCompleteChallenge` auf die Gruppe `Basics`).
`gameevents.xml` nennt in der Folge `game_player_skip_tutorial_challenges` die zehn Namen der
Gruppe `Basics`. Wer eine dieser zehn entfernt, muss die Liste dort mitkürzen.

Zur Zielzahl des Gruppen-Ziels: `UpdateMax` weist `MaxCount` die Länge von
`ChallengeGroup::ChallengeClasses` zu, liest danach `OwnerClass`, dessen Gruppe und `MaxCount`
und weist mit der Konstante 1 ein zweites Mal zu. *Geschlossen:* Zahl der Herausforderungen der
Gruppe, minus eins, wenn das Ziel selbst in dieser Gruppe steht — in jedem Fall aus der XML
berechnet, nicht fest.

### 7. Die Ziele im Einzelnen

Alle Ziele hängen sich in `HandleAddHooks` an ein Ereignis von `QuestEventManager` und beginnen
ihre Ereignismethode mit `BaseChallengeObjective::CheckBaseRequirements`.

#### 7.1 Gemeinsame Vorbedingung: Gruppe aktiv, Biom

`CheckBaseRequirements` ruft `ChallengeGroup::get_IsActive` auf der Gruppe der Herausforderung,
liest `Biome` und über `ChallengeJournal::Player` das Feld `EntityAlive::biomeStandingOn` mit
`BiomeDefinition::m_sBiomeName`; zwei Aufrufe von `String::op_Inequality`. *Geschlossen:* nichts
zählt, wenn die Gruppe nicht aktiv ist, und mit `biome="…"` nur, solange der Spieler in genau
diesem Biom steht (Vergleich mit Groß/Klein). Vanilla schreibt `burnt_forest`, `desert`, `snow`,
`wasteland`.

#### 7.2 `Harvest` — Abbau-Ereignis, Vergleich über die Typnummer

Attribute: `item`, `override_tracker_index`, `track_distance`, `disable_tracking` (Basisklasse
`ChallengeBaseTrackedItemObjective`) und `block_tag`, `held`, `is_block`, `required_held`.

**Ereignis (gelesen):** `QuestEventManager::HarvestedItem(ItemValue, ItemStack, BlockValue)` hat
genau einen Aufrufer, `GameUtils::collectHarvestedItem`, und der genau einen,
`GameUtils::HarvestOnAttack` (aus `ItemActionMelee::hitTheTarget`, `ItemActionRanged::fireShot`,
`ItemActionDynamic::hitTarget`). Es zählt also, was beim **Zuschlagen** aus einem Block oder
Kadaver in den Beutel fällt — nicht, was aus Kisten, vom Händler oder aus der Werkbank kommt.

**Prüfung** in `ChallengeObjectiveHarvest::Current_HarvestItem`, in dieser Reihenfolge:
`ItemValue::get_ItemClass` am gehaltenen Gegenstand (gelesen werden `expectedHeldClass`,
`requireHeld`), `isBlock` mit `BlockValue::get_isair`, `blockTag` mit `FastTags::get_IsEmpty` und
`Block::HasAnyFastTags`, zuletzt zweimal `ItemValue::get_type` (Beute gegen `expectedItem`), dann
`ItemStack::get_count` auf den Zählerstand. *Geschlossen:*

| Attribut | Bedeutung |
|---|---|
| `item` | genau ein Gegenstand; `Init` löst den Namen einmal über `ItemClass::GetItem` in eine Typnummer auf. Keine Liste, kein Tag |
| `block_tag` | nur Beute aus einem Block, der eines dieser Tags trägt. Vanilla: `challenge_farming`, `challenge_polymers` … als Tags in `blocks.xml`. Ohne das Attribut zählt jeder Block |
| `is_block` | Vorgabe **wahr** (Konstruktor): Beute ohne getroffenen Block zählt nicht. `is_block="false"` lässt auch Kadaver zu (Vanilla: `foodRawMeat`) |
| `held`, `required_held` | mit `required_held="true"` muss das in `held` genannte Werkzeug in der Hand sein. `held` allein speist nur die Vorbedingungs-Anzeige (`RequirementObjectiveGroupHold`) |
| `count` | summiert Stückzahlen, nicht Treffer |

#### 7.3 `Gather` — Besitz, Vergleich über die Typnummer

Attribute: nur die der Basisklasse (`item` …). `ChallengeObjectiveGather::HandleAddHooks` hängt
sich an `Bag::OnBackpackItemsChangedInternal`, `Inventory::OnToolbeltItemsChangedInternal` und
`EntityPlayerLocal::DragAndDropItemChanged` und prüft gleich einmal selbst.
`CheckForNeededItem` und `HandleUpdatingCurrent` rufen `Bag::GetItemCount` und
`Inventory::GetItemCount` mit `expectedItem`. *Geschlossen:* der Zählerstand **ist** der Bestand in
Rucksack und Gürtel; erfüllt ist das Ziel, sobald man `count` Stück **besitzt** — gleich woher.

**Der Unterschied:** `Gather` fragt „hast du es?", `Harvest` fragt „hast du es abgebaut?". Ein
`Gather`-Ziel erfüllt sich auch durch Kaufen, Plündern oder Herstellen.

#### 7.4 `Craft` — Herstell-Ereignis, Vergleich über den Namen

Attribut: `item`. `ChallengeObjectiveCraft::SetupItem` prüft auf ein Komma (`String::Contains`
mit 44) und teilt — **Kommaliste erlaubt**, der erste Name gilt für Anzeige und Rezept.
Ereignis: `QuestEventManager::CraftedItem(ItemStack)` aus `XUiC_RecipeStack`
(`AddItemToInventory`, `Update`, `outputStack`) und `EntityPlayerLocal::GiveExp`.
`Current_CraftItem` nimmt den Namen der Klasse (`ItemData::get_Name`), prüft ihn mit
`Extensions::ContainsCaseInsensitive` gegen die Liste und zählt `ItemStack::get_count` dazu.

**Die Schreibweise `name:VariantHelper`** ist keine Syntax der Herausforderungen. In keiner
Klasse des Namensraums `Challenges` steht ein Doppelpunkt oder `VariantHelper`; die Zeichenkette
kommt nur in `ShapesFromXml::.cctor` vor (und `frameShapes:VariantHelper` wörtlich in
`XUiC_RecipeStack::outputStack`). *Geschlossen:* `frameShapes:VariantHelper` ist schlicht der
**Name** des Sammelblocks, den das Spiel je Material aus `shapes.xml` erzeugt; `blocks.xml` enthält
keinen Block dieses Namens.

#### 7.5 `BlockPlace` — Setz-Ereignis, Vergleich über den Namen

Attribute: `block`, `alternate_item`. Ereignis: `QuestEventManager::BlockPlaced(string, Vector3i)`
aus `BlockToolSelection::PlaceBlock` und `ItemActionPlaceAsBlock::ExecuteAction`.
`Current_BlockPlace` vergleicht den gesetzten Namen mit `Extensions::EqualsCaseInsensitive` und
ruft sonst `Block::GetBlockByName` auf `block`, liest `Block::SelectAlternates` und ruft
`Block::ContainsAlternateBlock`. *Geschlossen:* es zählt der genannte Block **oder**, wenn er ein
Sammelblock ist, jede seiner Varianten. Darum funktioniert `block="frameShapes:VariantHelper"`.

`alternate_item` liest nur `CreateRequirements`: es ersetzt für die **Vorbedingungs-Anzeige**
den Blocknamen durch einen Gegenstand (Vanilla: Fackel in der Hand, `wallTorchLightPlayer` als
gesetzter Block). An dem, was zählt, ändert es nichts.

#### 7.6 `UseItem` und `CureDebuff` — nur über `ItemActionEat`

Beide hängen an `QuestEventManager::UsedItem(ItemValue)`. **Gelesen:** dessen einzige Aufrufer
sind `ItemActionEat::consume` und `ItemActionEat::ExecuteInstantAction`. Ein Gegenstand, dessen
Aktion eine andere Klasse hat, löst das Ereignis nie aus — er kann weder `UseItem` noch
`CureDebuff` erfüllen. In `consume` steht `UsedItem` **vor** `EntityAlive::FireEvent`; *geschlossen:*
das Ziel prüft, bevor die Wirkung des Gegenstands den Buff entfernt.

**`UseItem`** — Attribute `item`, `item_tags`, `override_text_key`, `override_text`. `Init` teilt
`item` am Komma. `Current_UseItem` prüft den Namen mit `ContainsCaseInsensitive` gegen die Liste
und danach `itemTags` mit `get_IsEmpty` und `FastTags::Test_AnySet` gegen `ItemClass::ItemTags`.
*Geschlossen:* Name aus der Liste **oder** eines der Tags.

**`CureDebuff`** — Attribute `debuff`, `item`. `Init` teilt **beide** am Komma (`buffNames`,
`itemNames`); der jeweils erste Name bleibt für die Anzeige. `Current_UseItem` ruft der Reihe nach
`ContainsCaseInsensitive` (Name des benutzten Gegenstands gegen `itemNames`) und `PlayerHasBuff`,
dann den Zähler plus 1. `PlayerHasBuff` läuft über `buffNames` und ruft `EntityBuffs::HasBuff`.

- **Gelesen:** die Gegenstände sind eine Liste, geprüft mit „enthält" — ein beliebiger zählt.
  Ebenso die Buffs: einer genügt (Vanilla: die vier Infektions-Stufen in einem Ziel).
- *Geschlossen:* beide Bedingungen müssen gelten — gelisteter Gegenstand **und** Buff vorhanden.
  Ob „und" oder „oder" verknüpft wird, ist **nicht lesbar**; „oder" hieße, dass jedes Essen
  während einer Blutung als Heilung zählte. Ein Gegenstand außerhalb der Liste zählt demnach
  nicht, auch wenn er den Buff tatsächlich entfernt.
- **Gelesen:** geprüft wird nicht, ob der Buff danach weg ist. „Heilen" heißt für das Spiel:
  gelisteten Gegenstand benutzt, während der Buff anlag.

#### 7.7 `Wear` und die Vorbedingungs-Anzeige

**`Wear`** — Attribute `item`, `tags`, `wear_name_key`, `wear_name`. Ereignis
`QuestEventManager::WoreItem` aus `XUiM_PlayerEquipment::EquipItem`,
`XUiC_EquipmentStackGrid::HandleSlotChangedEvent`, `XUiM_PlayerInventory::AddItem`.
`Current_WearItem` prüft `armorTags` (`Test_AnySet` gegen `ItemClass::ItemTags`), sonst die
Typnummer gegen `expectedItem`. `HandleAddHooks` ruft vorab `XUiM_PlayerEquipment::IsWearing` —
*geschlossen:* wer das Stück schon trägt, hat das Ziel sofort.

**`show_requirements`** — `Craft`, `BlockPlace`, `Harvest` und andere legen in `HandleOnCreated`
über `CreateRequirements` eine Vorbedingungs-Gruppe an und lesen dabei zuerst `ShowRequirements`.
`RequirementObjectiveGroupGatherIngredients` holt im Konstruktor `CraftingManager::GetRecipe` und
liest in `CreateRequirements` `Recipe::ingredients` und `Recipe::GetOutputItemClass`. **Nicht
lesbar**, ob ein fehlendes Rezept dort abgefangen wird. Vanilla setzt `show_requirements="false"`
genau einmal, am Ziel `Craft resourceForgedIron` — einem Gegenstand ohne gewöhnliches Rezept.
*Geschlossen:* das ist der vorgesehene Schalter für Ziele, deren Gegenstand kein Rezept hat.

#### 7.8 Ein Name, den es nicht gibt

**Gelesen:** `ItemClass::GetItemClass(string, bool)` schlägt mit `Dictionary::TryGetValue` nach,
`ItemClass::GetItem` ruft sie und sonst `ItemValue::get_None`. Keine `Init` eines Ziels enthält
eine Ausnahme oder einen Protokoll-Aufruf. **Ein unbekannter Name gibt beim Laden weder Fehler
noch Warnung.**

Was danach geschieht, hängt am Typ:

| Typ | Vergleich | Mit unbekanntem Namen |
|---|---|---|
| `Craft`, `UseItem`, `CureDebuff` (Gegenstände) | Name als Text | *geschlossen:* stilles Nie-Erfüllen; die Anzeige fragt `Localization::Get` mit dem Namen |
| `CureDebuff` (`debuff`) | `EntityBuffs::HasBuff` | zählt nie; `get_DescriptionText` ruft `BuffManager::GetBuff` und liest `BuffClass::LocalizedName` — **nicht lesbar**, ob ein fehlender Buff abgefangen wird |
| `Harvest`, `Gather`, `Wear` | Typnummer | zählt nie; `expectedItemClass` bleibt leer, und `get_DescriptionText` ruft darauf `ItemClass::GetLocalizedItemName`, `ChallengeBaseTrackedItemObjective::HandleAddHooks` liest `ItemClass::TrackerIndexName` — **nicht lesbar**, ob davor eine Null-Prüfung steht. Möglich ist ein Fehler bei Start oder Anzeige |
| `BlockPlace` | Name als Text, sonst `Block::GetBlockByName` und Zugriff auf `SelectAlternates` | **nicht lesbar**, ob ein unbekannter Block abgefangen wird; der Zugriff läge in jedem Setz-Ereignis |
| `Craft` ohne Rezept | `Init` holt `CraftingManager::GetRecipe`; `get_NavType` liest `Recipe::craftingArea` | **nicht lesbar**, siehe 7.7 |

Sicher ist nur die eine Hälfte: der Ladevorgang meldet nichts. Ein Ziel sollte deshalb **nie**
einen Namen nennen, den es nicht gibt.

### 8. Kategorie mit `show_type="BiomeProgression"`

**Gelesen:** `ChallengeCategory::CanShow` und `get_IsActive` lesen für den Typ 3 das statische Feld
`World::BiomeProgressionEnabled` — nicht `GameStats`. Geschrieben wird es in
`SandboxOptionManager::UpdateInGameValuesWithSandboxOptions` aus der Option 55
(`SandboxOptionManager::GetBool`); dieselbe Methode schreibt `ChallengeJournal::AllowChallenges`
aus Option 139 und `IntroChallengesEnabled` aus Option 140. Der Spielwert
`EnumGameStats.BiomeProgression` wird dort ebenfalls gesetzt (F-17, Abschnitt 3), die
Herausforderungen lesen ihn aber nicht.

**Der Reiter:** `SetupCategoriesBasedOnChallengeCategories` ruft `CanShow` je Kategorie und füllt
die übrigen Reiter mit `SetCategoryEmpty`. *Bestätigt (geschlossen aus der Reihenfolge):* ohne
Biom-Fortschritt gibt es den Reiter nicht.

**Laufen sie weiter?** Drei Stellen, alle an `ChallengeGroup::get_IsActive`:

1. `ChallengeJournal::StartChallenges` ruft `get_IsActive` unmittelbar vor
   `Challenge::StartChallenge`. *Geschlossen:* Herausforderungen einer nicht aktiven Gruppe werden
   nicht gestartet — keine Ereignis-Anmeldung, kein Fortschritt.
2. `BaseChallengeObjective::CheckBaseRequirements` (Abschnitt 7.1) fragt dasselbe noch einmal bei
   jedem Ereignis.
3. `Challenge::HandleComplete` ruft `ChallengeGroup::IsVisible`, bevor der Hinweis
   `challengeMessageComplete` mit dem Ton `ui_challenge_complete` kommt. *Geschlossen:* keine
   Einblendung für eine unsichtbare Gruppe.

Die Einträge **bestehen** trotzdem: `StartChallenges` legt für jede Gruppe aus `s_ChallengeGroups`
Einträge an, sie stehen im Tagebuch und im Spielstand. Sie ruhen nur. Für uns (D136, Vorlage ohne
Biom-Fortschritt) heißt das: die vier Biom-Gruppen brauchen keine Pflege, solange der Schalter aus
ist — und werden lebendig, sobald ein Spieler ihn einschaltet.

### 9. Texte und Symbole

| Attribut | Wo aufgelöst | Art |
|---|---|---|
| `title_key` | `ChallengeClass::ParseElement`, sofort `Localization::Get` | Sprachschlüssel; `title` ist Klartext; fehlt beides, gilt der Name |
| `short_description_key` | beim Laden, `Localization::Get` | Sprachschlüssel; `short_description` Klartext |
| `description_key`, `description` | **beide** unverändert nach `Description`; erst `ChallengeClass::GetDescription` ruft `Localization::Get` | Schlüssel; mit Gamepad wird zuerst `<Schlüssel>_alt` versucht (`Localization::Exists`) |
| `hint`, `prerequisite_hint` | unverändert gespeichert; `ChallengeClass::GetHint(bool)` löst auf, ebenfalls mit `_alt` | Schlüssel. Aufrufer ist `XUiC_QuestTrackerWindow::GetBindingValueInternal` mit `Challenge::get_NeedsPreRequisites`: *geschlossen:* `prerequisite_hint`, solange Vorbedingungen offen sind, sonst `hint` |
| `reward_text_key` | beim Laden, `Localization::Get` | Sprachschlüssel |
| `icon` | unverändert nach `Icon`; `XUiC_ChallengeEntry::GetBindingValueInternal` gibt ihn als `iconname` aus, die Vorlage bindet `sprite="{iconname}"` | Bildname |
| Zeilen der Ziele | `get_DescriptionText` je Typ | feste Schlüssel (`challengeObjectiveHarvest`, `challengeObjectiveGather`, `challengeObjectiveCure`, `challengeObjectiveUse`, `challengeObjectiveWear`, `lblContextActionCraft`, `xuiWorldPrefabsPlace`) plus der übersetzte Name des Gegenstands; Zählerstand als `{0}/{1}` aus `get_StatusText` |

**Wird `icon` geprüft?** Im Code der Herausforderungen nicht: zwischen dem Lesen des Attributs und
der Ausgabe an die Oberfläche steht kein Aufruf. Was das Bild-Element mit einem unbekannten Namen
tut, ist hier **nicht gelesen** (zum Mitliefern eigener Bilder siehe F-16). Ebenso **nicht
gelesen:** was `Localization::Get` für einen fehlenden Schlüssel liefert.

## Was das für den Bau heißt

| Punkt | Folgerung |
|---|---|
| Einzelne Herausforderung verbergen | Geht nicht. Entfernen, Ziel ersetzen oder umhängen. |
| Entfernen | `remove` auf das `<challenge>`. Der alte Spielstand verliert den Eintrag still (geschlossen). Vorher prüfen: steht der Name in `gameevents.xml` (`CompleteChallenge`, in Vanilla nur die zehn aus `Basics`) oder in einem `ChallengeComplete challenge="…"`? |
| Gruppe schrumpfen | Erlaubt, auch auf 3; die Belohnung kommt nach der letzten verbliebenen. Nicht auf 0 — dann die Gruppe mit entfernen und alle `group="…"` und `is_group`-Verweise darauf. `hidden_by` auf eine fehlende Gruppe ist harmlos. |
| Gruppe füllen | Höchstens 10 je Gruppe, höchstens 6 Gruppen je Reiter (4 im Biom-Reiter). Mehr hieße `windows.xml`/`templates.xml` mitändern. |
| Ziel ersetzen, Name bleibt | Wer die Herausforderung schon eingelöst hat, behält sie. Bei gleichem Zieltyp bleibt der alte Zählerstand stehen. Soll neu gezählt werden: neuer Name. |
| `Farmer`-Ziele | `Harvest` mit `block_tag="challenge_farming"` verlangt einen Block mit diesem Tag. Ein Ersatz-Gegenstand zählt nur, wenn sein Pflanzen-Block das Tag trägt — sonst `block_tag` am Ziel weglassen. |
| `harvestPolymers` | wie oben: `block_tag="challenge_polymers"` und `override_tracker_index` gehören zum alten Gegenstand; beim Tausch mitprüfen. |
| `craftPipeBomb` | `Craft` vergleicht den Namen und baut eine Zutaten-Anzeige aus dem Rezept. Ersatz mit Rezept: nur `item` tauschen. Ersatz ohne Rezept: `show_requirements="false"`. |
| `CureDebuff` für unsere Heilmittel | Namen in die Kommaliste `item` aufnehmen. Der Gegenstand muss über `ItemActionEat` benutzt werden, sonst gibt es kein Ereignis. |
| „Hast du es" statt „hast du es abgebaut" | `Gather` statt `Harvest` — zählt Besitz, gleich woher. |
| Nicht verwenden | `HarvestByTag` (verliert den Stand beim Laden) und jeden Namen, den es nicht gibt. |
| Biom-Gruppen | Ruhen ohne Biom-Fortschritt; keine Arbeit nötig, solange der Schalter aus bleibt. |

## Offen — nur das Spiel zeigt es

Die Punkte 1 bis 4 sind zusammen **ein** kurzer Test (etwa zehn Minuten, eine Testwelt): Spielstand
mit Vanilla-XML anlegen, im Konsolenfenster mit `challenges complete challenge <Name> r` ein paar
Einträge einlösen, speichern, das Modlet mit geänderter `challenges.xml` einschalten, laden.
`challenges list <Gruppe>` zeigt den Bestand.

1. **Bricht der alte Spielstand wirklich nicht?** Laden mit einer entfernten, im Spielstand
   vorhandenen Herausforderung: kein `ERR`/`EXC` im Protokoll, der Eintrag ist weg. Das ist die
   eine Stelle, an der die Gegenlesart ein Abbruch wäre (Abschnitt 5).
2. **Gruppe mit 3:** wie sehen die sieben leeren Plätze aus, und kommt die Gruppenbelohnung nach
   der dritten Einlösung?
3. **Ersetztes Ziel im alten Spielstand:** bleibt der Zählerstand bei gleichem Typ, beginnt er bei
   anderem Typ bei null, bleibt „eingelöst" eingelöst?
4. **Vorher eingelöste Reste:** Gruppe, deren verbleibende Einträge alle schon eingelöst sind —
   gilt sie nach dem Laden als vollständig, und bleibt die Belohnung wirklich aus?
5. **`CureDebuff`, „und" oder „oder":** mit anliegendem Buff einen nicht gelisteten Gegenstand
   essen — der Zähler darf nicht steigen. Dann einen gelisteten ohne Buff — ebenfalls nicht.
6. **Unbekannter Name** (falls je nötig): `Harvest` mit erfundenem `item` in einer Test-XML —
   Fehler beim Start der Herausforderung, bei der Anzeige oder gar nicht? Ebenso `Craft` auf einen
   Gegenstand ohne Rezept mit und ohne `show_requirements="false"`.
7. **Mehr als 10 in einer Gruppe** und die Frage, ob `active_challenge_count` gewöhnliche Gruppen
   deckelt: nur nötig, falls wir das je wollen.
8. **Fehlende Verweise:** dass `group="X"` ohne Gruppe und `is_group` auf eine fehlende Gruppe beim
   Laden werfen, ist aus dem fehlenden `ContainsKey` geschlossen. Unser Prüfwerkzeug sollte beide
   Fälle vor dem Spiel abfangen; ein Spieltest ist dafür nicht nötig.
9. **Dedicated Server** (Regel 5): das Tagebuch gehört dem lokalen Spieler (`EntityPlayerLocal`,
   `PlayerDataFile`), der Konsolenbefehl verweigert den Server. Nicht gelesen ist, ob der Client
   die `challenges.xml` des Servers bekommt und ob Einlösen und Gruppenbelohnung
   (`GameEventManager::HandleAction`) mit zweitem Client so laufen wie allein.
10. **Biom-Fortschritt nachträglich eingeschaltet:** nicht gelesen, ob `StartChallenges` vor oder
    nach `UpdateInGameValuesWithSandboxOptions` läuft — also ob die Biom-Herausforderungen beim
    ersten Laden mit eingeschaltetem Schalter sofort starten oder erst beim nächsten.

## Gebaut darauf (D137, D138)

- **Neun umgebogene Ziele** (`700_50_Fortschritt/Config/challenges.xml`, D137) — vor diesem
  Finding gebaut, danach dagegen gehalten: `block_tag` und die Wegmarken sind an den
  Ernte-Zielen entfernt, Knochen und Tierfett tragen `is_block="false"`, Federn fallen beim
  Zuschlagen aus `cntBirdnest` (zwei `Harvest`-Abwürfe im Vorlauf), alle fünf Ernte-Gegenstände
  haben `Harvest`-Abwürfe aus Blöcken, alle drei `Craft`-Ziele ein Rezept. Kein Widerspruch.
- **Die Zielprüfung im Werkzeug** (`anachronisms`, Regel `unerfuellbares-ziel`; Vertrag 04,
  Nachtrag Ziele der Herausforderungen, D138) liest eine Liste als Entweder-oder (hier §7,
  `CureDebuff`) und meldet einen unbekannten Namen, weil das Spiel es nicht tut (§7.8).
- **Zehn ohne Gegenstück entfernt** (D139): Sammler 8, Bauer 4, Heiler 8; kein Verweis zeigte
  auf eine der zehn. Dazu die Vorprüfung der Verweise aus §6 (`group`, `ChallengeComplete` mit
  und ohne `is_group`, `CompleteChallenge`) und der leeren Gruppe aus §3 im Werkzeug
  (`herausforderung-verweis-fehlt`, `gruppe-ohne-herausforderung`).
- **Offen bleibt der Beweis** aus „Offen" Nr. 1: Spieltest S-13 der Entscheidungsliste.
