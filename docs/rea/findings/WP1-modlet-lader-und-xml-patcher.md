# Modlet-Lader, XML-Patcher und Localization

**Stand:** 2026-11-07 · **Build:** V 3.40 b10, Steam 26309840 · **Werkzeug:** `mod700meta`
gegen `Assembly-CSharp.dll` (SHA-256 `cb54022c…56c58`)

Grundlage für die Verträge in [`docs/contracts/`](../../contracts/) und für die Entscheidung
**D53** (mehrere Modlets). Alles hier ist aus Metadaten und aus den ausgelieferten Dateien
gelesen, nicht im Spiel beobachtet — das steht bei jedem Punkt dabei, wo es zählt.

## 1. Die Ladereihenfolge ist zugesichert

`ModManager::loadModsFromFolder(string)` ruft in dieser Folge auf:

```
SdDirectory::Exists
SdDirectory::GetDirectories
System.Array::Sort          ← hier
System.IO.Path::GetFileName
Mod::LoadDefinitionFromFolder
Mod::LoadMod
```

**Der Lader sortiert die Mod-Ordner selbst.** Das ist der entscheidende Punkt für D53: die
Reihenfolge hängt **nicht** am Dateisystem. Auf einem Linux-Server gibt ein Verzeichnis seine
Einträge unsortiert zurück; ohne diesen `Array::Sort` wäre jede Aufteilung in mehrere Modlets
ein Glücksspiel gewesen, das auf dem Windows-Rechner funktioniert und auf dem Server nicht.

Ein Zahlenpräfix im Ordnernamen (`700_00_Core`, `700_10_Purge`, …) ergibt damit eine
**verlässliche, plattformunabhängige** Reihenfolge.

Was es **nicht** gibt: `LoadBefore`, `LoadAfter`, Abhängigkeits-Deklarationen oder eine
Zyklenprüfung. Gesucht nach `Dependenc`, `LoadBefore`, `LoadAfter`, `circular` — der einzige
Treffer liegt in `Platform.EOS.Api::initPlatform` und betrifft native Bibliotheken. Die
Reihenfolge wird also **allein über den Ordnernamen** gesteuert.

## 2. Ein Modlet trägt genau eine Datei je Vanilla-Config

`XmlPatcher::LoadAndPatchConfig(string, Action<XmlFile>)` nimmt **einen Dateinamen** und
arbeitet mit den Zeichenketten `Data/Config` und `/Config/`. Jede Vanilla-Config wird also
einmal verarbeitet, und jedes Modlet liefert dazu höchstens seine eine gleichnamige Datei unter
`<Modlet>/Config/`.

**Folge:** In einem einzigen Modlet müssten alle Änderungen an `items.xml` — Purge (F-01),
Waffen (F-02), Rüstung (F-03), Werkstätten (F-04), Ressourcen (F-05) — in **einer** Datei
liegen. Mehrere Modlets sind der einzige Weg, sie zu trennen und einzeln abzuschalten. Das ist
die Begründung für D53.

### Die patchbaren Dateien, namentlich

`StockFileHashes::.cctor` führt die Liste der Dateien, die das Spiel als Standard-Config kennt —
52 Einträge:

```
archetypes, biomes, blockplaceholders, blocks, buffs, challenges, devicesgameprefs, dialogs,
dmscontent, entityclasses, entitygroups, events, gameevents, gamestages, items, item_modifiers,
loadingscreen, loot, materials, misc, Music, nav_objects, npc, painting, physicsbodies,
progression, qualityinfo, quests, recipes, rwgmixer, sandbox_overrides, shapes, signs, sounds,
spawning, subtitles, toolbelt, traders, twitch, twitch_events, ui_display, utilityai, vehicles,
videos, weathersurvival, worldglobal            (alle als Data/Config/<name>.xml)

XUi_Common/styles.xml      XUi_Common/templates.xml
XUi_InGame/styles.xml      XUi_InGame/templates.xml
XUi_InGame/windows.xml     XUi_InGame/xui.xml
```

Zwei Dinge daran sind für uns wichtig:

1. **XUi ist auf `XUi_Common/` und `XUi_InGame/` aufgeteilt**, mit festen Dateinamen. Spec 01
   sprach pauschal von `Config/XUi/…` — der richtige Pfad hat einen Unterstrich und zwei Varianten.
2. `Mod::DetectContents` prüft zusätzlich auf **`XUi_Menu`** und `loadingscreen.xml`. Es gibt
   also eine dritte XUi-Ebene für das Hauptmenü, die in der Hash-Liste nicht auftaucht.

## 3. Die elf Patch-Operationen

`XmlPatchMethods` trägt genau diese Methoden:

| Methode | XML-Tag (abgeleitet) |
|---|---|
| `AppendByXPath` | `append` |
| `PrependByXPath` | `prepend` |
| `InsertAfterByXPath` | `insertAfter` |
| `InsertBeforeByXPath` | `insertBefore` |
| `RemoveByXPath` | `remove` |
| `SetByXPath` | `set` |
| `SetAttributeByXPath` | `setattribute` |
| `RemoveAttributeByXPath` | `removeattribute` |
| `CsvOperationsByXPath` | `csv` |
| `Conditional` | `conditional` |
| `Include` | `include` |

**Belegt sind die Methodennamen**, nicht die Tag-Namen: die Zuordnung steht in einem
`XmlPatchMethodAttribute`, dessen Wert im Attribut-Blob liegt und von `mod700meta` nicht gelesen
wird. Einer ist wörtlich bestätigt — `RemoveByXPath` meldet im Fehlerfall:
*„Can not remove matched Attribute (…), use **removeattribute** instead"*. Das stützt die
Kleinschreibung der übrigen. **Zu bestätigen beim ersten echten Modlet**: ein falscher Tag-Name
erzeugt sofort einen Fehler im Protokoll, die Prüfung kostet also nichts.

`csv` und `include` waren nicht erwartet. `include` erlaubt das Auslagern von XML in eigene
Dateien — ein Weg, eine große `items.xml` zu zerlegen, **ohne** mehrere Modlets. Er ersetzt D53
trotzdem nicht: eine eingebundene Datei lässt sich nicht abschalten, ein Modlet-Ordner schon.

## 4. Bedingte Blöcke — das war die Überraschung

`XmlPatchConditionEvaluator` wertet Bedingungen über **NCalc** aus und stellt dafür diese
Funktionen bereit:

| Funktion | wofür |
|---|---|
| `mod_loaded` | **Ist eine andere Mod geladen?** |
| `mod_version` | deren Fassung |
| `game_version` | Spielfassung |
| `version` | Fassungsvergleich |
| `gamepref` | Spieleinstellung |
| `serverinfo` | Server-Angabe |
| `eventActive` | läuft ein Ereignis |
| `time_minutes` | Zeit |
| `game_loaded` | Spielstand geladen |
| `xpath` | **existiert ein XPath-Treffer?** |
| `has_entitlement` | Besitzrecht |

Dazu `FindActiveConditionalBranchElement` und `XmlPatcher::ApplyConditionalXmlBlocks`, also
Verzweigungen im XML selbst.

**Das verändert zwei Dinge im Plan:**

- **Risiko R6 (UI-Mod-Kompatibilität, D5) ist entschärft.** Mit `mod_loaded('…')` lässt sich ein
  XUi-Patch nur dann anwenden, wenn eine bestimmte UI-Mod da ist — oder gerade nicht. Das war der
  Punkt, für den ich C# befürchtet hatte.
- `xpath(…)` erlaubt **defensive Patches**: nur ändern, wenn das Ziel existiert. Damit bricht ein
  Patch nicht, wenn eine andere Mod das Element vorher entfernt hat.

Nicht geprüft: die genaue Schreibweise der Bedingungsausdrücke. Die Funktionsnamen sind belegt,
die Syntax drumherum nicht.

## 5. EAC gilt nur für Code, nicht für XML

`Mod::LoadMod()` ruft `LoadAssemblies()` und `DetectContents()`. Die EAC-Prüfung sitzt
**ausschließlich** in `LoadAssemblies`:

```
SdDirectory::GetFiles                                   (sucht ".dll")
Platform.IPlatform::get_AntiCheatClient
Platform.IAntiCheatClient::ClientAntiCheatEnabled
Mod::get_SkipLoadingWithAntiCheat
Mod::get_AntiCheatCompatible
```

mit den Meldungen *„AntiCheat enabled, mod skipped because it is set not to load"* und
*„Mod contains custom code, AntiCheat needs to be disabled to load it!"*.

**Folgerung:** Ein Modlet ohne `.dll` kommt an dieser Prüfung nicht in Konflikt — die Meldung
spricht ausdrücklich von *custom code*. Da Phase 1 **reines XML** ist, sollten die
Inhalts-Modlets auch mit **aktivem** EAC laden; nur `700_00_Core` mit `Mod700.dll` braucht EAC
aus.

**Das ist eine Folgerung, kein Nachweis.** Belegt ist, wo die Prüfung steht und was sie meldet;
dass ein DLL-freies Modlet bei aktivem EAC tatsächlich lädt, zeigt erst ein Spielstart. Es wäre
aber ein billiger Weg, XML-Inhalte zu testen, ohne jedes Mal EAC abzuschalten — und damit ein
Teilausweg aus Risiko R2 des Plans. **Beim ersten Spielstart mitprüfen.**

Nebenbei: `Mod::get_AntiCheatCompatible` existiert, kommt aber **nicht** aus der `ModInfo.xml`.
`parseModInfoV2` liest nachweislich genau sieben Felder — `Name`, `Version`, `DisplayName`,
`Description`, `Author`, `Website`, `SkipWithAntiCheat` — und kein achtes. Die Feldliste im
[F-00-Finding](F-00-modloader-events-version.md) bleibt damit richtig.

## 6. Localization: Spec 01 nennt eine Datei, die es nicht gibt

**`Localization.txt` existiert im ganzen Spiel nicht.** Gesucht mit `find` über `Data/`, ein
einziger Treffer:

```
Data/Config/Localization.csv      16.858.559 Bytes, 25.932 Zeilen
```

`Localization::loadBaseDictionaries` und `Localization::LoadPatchDictionaries` benutzen beide
`/Localization.csv`; letztere meldet *„[MODS] Loading localization from mod:"*, lädt also die
Datei der Modlets. `Mod::DetectContents` prüft ebenfalls auf `Localization.csv`.

Spec 01 §2 und F-12 sprechen von `Localization.txt`. **Das ist falsch und beide Dokumente werden
berichtigt.**

### Die Kopfzeile, wörtlich aus der ausgelieferten Datei

```
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english,Context / Alternate Text,german,
spanish,french,italian,japanese,koreana,polish,brazilian,russian,turkish,schinese,tchinese
```

Daran sind drei Dinge für F-12 und für das Prüfwerkzeug wichtig:

1. **Vor den Sprachen stehen fünf Metadatenspalten** — `File`, `Type`, `UsedInMainMenu`,
   `NoTranslate`, `KeepLoaded`. Wer nur `Key,english,german` schreibt, trifft die falschen Spalten.
2. **Zwischen `english` und `german` steht `Context / Alternate Text`** — eine Spalte, die
   *keine* Sprache ist. Ein Prüfwerkzeug, das „die Spalte nach english ist deutsch" annimmt,
   prüft die Kommentarspalte. Genau dieser Fehler wäre ohne diesen Blick passiert.
3. **13 Sprachen** von 20 Spalten, `english` und `german` darunter. D7 („DE + EN Pflicht,
   weitere Sprachen leer lassen") heißt also: zwei füllen, **elf** leer lassen.
   *(Hier stand zuerst „14". Das Prüfwerkzeug zählte beim ersten Lauf 11 weitere
   Sprachspalten — die Zählung von Hand war falsch, und das Werkzeug hat sie berichtigt.)*

`Localization::loadCsv` verlangt in der ersten Zelle `KEY` und danach Spaltendefinitionen, die
*„non-empty string consisting of latin characters only"* sein müssen — die ausgelieferte Datei
schreibt `Key`, die Prüfung ist demnach nicht auf Großschreibung festgelegt.
`Localization::addCsv` überspringt Einträge ohne Schlüssel und meldet **doppelte Schlüssel**
(*„Duplicate key … found! … Skipping entry"*) — ein Modlet, das einen Schlüssel zweimal setzt,
verliert den zweiten stillschweigend bis auf diese Protokollzeile. Das Prüfwerkzeug aus WP2.3
sollte darauf achten.

> **Berichtigt am 7. November 2026, siehe
> [WP4-localization-ueberschreibt-vanilla.md](WP4-localization-ueberschreibt-vanilla.md).**
> Dieser Absatz gilt für *zwei gleiche Zeilen in einer Datei*. Er liest sich aber leicht als
> „ein Modlet, das einen **Vanilla**-Schlüssel setzt, verliert" — und das ist falsch.
> `addCsv` hat zwei Zweige: Vanilla lädt mit `false` und nimmt `Dictionary::Add` (Doppel →
> Warnung, Eintrag fällt), Modlets laden mit `true` und nehmen `Dictionary::set_Item`
> (Doppel → **überschreiben**, zellenweise in `patchedCells` vermerkt). Eine Modlet-Zeile
> gewinnt also gegen Vanilla. Darauf steht die ganze Umdeutung in WP4.

Eine Beispielzeile zur Form:

```
cntTestCashRegister,blocks,Block,,x,,Test Cash Register,Only used for testing perks and buffs,,,…
```

## 7. Was daraus für die Verträge folgt

1. **Mehrere Modlets sind tragfähig** (D53), weil der Lader sortiert — und sie sind nötig, weil
   ein Modlet nur eine Datei je Vanilla-Config tragen kann.
2. **Ordnername = Ladereihenfolge.** Zahlenpräfix ist Pflicht, nicht Geschmack.
3. **Elf Patch-Operationen**, Tag-Namen beim ersten Modlet zu bestätigen.
4. **Bedingte Blöcke mit `mod_loaded` und `xpath`** gehören in die XPath-Regeln — sie sind der
   Weg zu Verträglichkeit mit anderen Mods ohne C#.
5. **`Localization.csv`, nicht `.txt`**, mit Metadatenspalten und einer Kommentarspalte mitten
   zwischen den Sprachen.
6. **EAC-Prüfung betrifft nur Modlets mit DLL** — beim ersten Spielstart bestätigen.
