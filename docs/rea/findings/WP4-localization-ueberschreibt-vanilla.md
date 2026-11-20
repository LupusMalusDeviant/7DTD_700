# WP4 — Localization: eine Modlet-Zeile überschreibt den Vanilla-Schlüssel

**Stand:** 7. November 2026
**Frage:** Darf ein Modlet in seiner `Localization.csv` einen Schlüssel setzen, den Vanilla
schon hat — und gewinnt dann unsere Zeile oder die von Vanilla?
**Antwort:** Unsere gewinnt. Die Modlet-Zeile überschreibt zellenweise.

Das ist die Voraussetzung für die ganze Umdeutung in WP4: `resourceScrapIron` heißt in der
XML weiter `resourceScrapIron`, der Spieler soll „Raseneisenerz" lesen. Trägt das Spiel
unsere Zeile nicht ein, ist die Umdeutung unsichtbar und der Purge sieht fertig aus, während
im Inventar „Scrap Iron" steht. Darum vor dem Bauen dieser Befund.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta members <dll> --type Localization --il`. REA bricht an dieser
Assembly mit *„Managed metadata exceeds the 67108864 byte representation budget"* ab und
liefert null Felder und null Methoden — genau der Grund, aus dem `mod700meta` existiert
(siehe `docs/rea/findings/00-rea-grenzen.md`). Gelesen werden nur Metadaten und IL-Bytes;
die Assembly wird nicht geladen und nicht ausgeführt.

## Die Kette, Glied für Glied

`Localization` hat **ein** Wörterbuch, nicht zwei:

```
mDictionary                 Dictionary<string, string[]>
mDictionaryCaseInsensitive  CaseInsensitiveStringDictionary<string[]>
patchedCells                Dictionary<string, bool[]>
```

Es gibt also keine getrennte „Patch-Tabelle", die bei der Abfrage vorgezogen würde. Beide
Ladewege füllen dasselbe Wörterbuch — die Entscheidung fällt an einem Schalter:

| Methode | Konstante vor dem Aufruf | bedeutet |
|---|---|---|
| `loadBaseDictionaries` | `ldc.i4.0` → `call Localization::loadCsv` | Vanilla lädt mit **false** |
| `LoadPatchDictionaries` | `ldc.i4.1` → `call Localization::loadCsv` | Modlets laden mit **true** |
| `loadCsv(byte[],bool,bool)` | `ldc.i4.1` → `call Localization::addCsv` | gibt den Schalter weiter |

`LoadPatchDictionaries` ist belegt der Modlet-Weg: es lädt `ldstr "/Localization.csv"` und
schreibt `ldstr "[MODS] Loading localization from mod: "` ins Protokoll.

Und `addCsv` hat zwei Zweige, die sich an genau diesem `bool` scheiden:

```
Zweig A (false, Vanilla):   Dictionary::TryAdd / Dictionary::Add
                            schlägt fehl -> String::Concat + Log::Warning
                            "Localization: Duplicate key \"" ... "\" found! ...
                             Please check Localization file. Skipping entry..."

Zweig B (true, Modlet):     Dictionary::TryGetValue   (bestehende Zeile holen)
                            Array::Resize             (auf die Spaltenzahl bringen)
                            patchedCells TryGetValue / set_Item / Add
                            Dictionary::set_Item       <-- Indexer-Zuweisung = ueberschreiben
```

`set_Item` auf einem `Dictionary` ersetzt einen vorhandenen Wert, wo `Add` wirft und `TryAdd`
aufgibt. Der Modlet-Zweig nimmt `set_Item`. Damit ist die Frage beantwortet.

## Was das für unsere Datei heißt

1. **Vanilla-Schlüssel ohne `700_`-Präfix sind in unserer `Localization.csv` erlaubt und
   wirksam.** Sie gehören in `tools/check/vanilla-keys.txt`, sonst meldet
   `mod700check localization` `schluessel-ohne-praefix` — die Liste ist die bewusste
   Ausnahme, nicht ein Loch in der Prüfung.
2. **`patchedCells` ist ein `bool[]` pro Schlüssel, nicht ein `bool`.** Gepatcht wird
   zellenweise, nicht zeilenweise. Zusammen mit den `String::IsNullOrEmpty`-Abfragen im
   Patch-Zweig heißt das: eine leere Zelle in unserer Zeile löscht Vanillas Wert
   voraussichtlich **nicht**, sondern lässt ihn stehen. Das ist der einzige Punkt dieses
   Befundes, der aus dem IL-Verlauf **abgeleitet** ist und nicht direkt dasteht: der Verlauf
   zeigt die Aufrufe, nicht den vollständigen Kontrollfluss. Für uns ist es ohne Folgen —
   D7 verlangt `english` und `german` gefüllt und die elf übrigen Sprachen leer, und beide
   Lesarten (Vanilla bleibt stehen / Zelle wird leer) ergeben dasselbe Spielerlebnis in
   einer Sprache, die wir nicht bedienen.
3. **Ein Schlüssel darf in unserer Datei nur einmal stehen.** Innerhalb einer Datei greift
   auch im Patch-Zweig die Doppel-Erkennung nicht: `set_Item` überschreibt still, die zweite
   Zeile gewinnt. `mod700check localization` prüft das mit `schluessel-doppelt`.

## Berichtigung an WP1 §6

`docs/rea/findings/WP1-modlet-lader-und-xml-patcher.md`, Abschnitt 6, schreibt:

> ein Modlet, das einen Schlüssel zweimal setzt, verliert den zweiten stillschweigend

Das ist für *eine Datei mit zwei gleichen Zeilen* richtig, liest sich aber wie „ein Modlet,
das einen Vanilla-Schlüssel setzt, verliert". Diese Lesart ist falsch, und sie hätte die
ganze Umdeutung verhindert. Der Satz wird dort um den Verweis auf diesen Befund ergänzt.

## Nachtrag 2026-11-20 (WP8.5, D78): wann die Modlet-Dateien geladen werden

Gefragt für den Ladebildschirm: seine Tipps (`loadingTip…`) tragen in Vanilla die Marke
`UsedInMainMenu = x`, unsere Zeilen nicht. Greifen unsere Zeilen, bevor der erste
Ladebildschirm steht?

Gelesen mit `mod700meta members … --type Localization --type ModManager --callers --il`,
derselbe Build wie oben (SHA-256 `cb54022c…`, MVID `0dfd4a8c-…`):

| Aufrufer | ruft | Bedeutung |
|---|---|---|
| `GameManager::Awake` | `ModManager::LoadPatchStuff` | beim Programmstart |
| `GameManager/<startGameCo>` | `ModManager::LoadPatchStuff` | beim Start eines Spiels |
| `ModManager/<LoadPatchStuff>` | `ModManager::LoadLocalizations` | |
| `ModManager/<LoadLocalizations>` | `Localization::LoadPatchDictionaries` | je Modlet mit `Config/` |
| `GameManager::SaveAndCleanupWorld` | `ModManager::GameEnded` | nach einem Spiel |
| `ModManager::GameEnded` | `Localization::ReloadBaseLocalization`, `UnloadUnusedLanguages`, dann wieder `LoadLocalizations` | Vanilla neu, Modlets wieder darüber |

**Folge:** die Sprachdateien der Modlets liegen schon im Hauptmenü über Vanilla und werden
nach jedem Spielende neu darübergelegt. Eine Modlet-Zeile für `loadingTipStoneAxe` ist
also geladen, bevor ein Ladebildschirm sie zeigt.

**Was `UsedInMainMenu` und `KeepLoaded` tun, ist nicht gelesen** — nur, wo sie vorkommen:
als Zeichenketten in `Localization::UnloadUnusedLanguages`, das `XUiC_MainMenu::OnOpen`
und `ModManager::GameEnded` aufrufen. Dem Namen nach wirft die Methode Sprachspalten weg,
die gerade nicht gebraucht werden, und nimmt markierte Zeilen aus. Ob das unsere Zeilen
trifft, hängt am Kontrollfluss, und den zeigt die Aufrufliste nicht. **Darum tragen unsere
Tipp-Zeilen dieselben Metaspalten wie Vanillas** (`UI, Loading Screen, x`; die zwei
Twitch-Zeilen ohne `x`, wie in Vanilla): so ändert die Überschreibung an diesen Spalten
nichts, gleich wie sie zellenweise gemischt werden.

**Nicht gelesen:** wann `XUiC_LoadingScreen` den Text holt und ob ein XML-Patch auf
`loadingscreen.xml` vor `XUiC_LoadingScreen/<LoadXml>` greift. D78 fasst die Datei deshalb
nicht an.

## Was das nicht beweist

Gelesen ist der ausgelieferte Code, nicht ein Lauf. Dass das Spiel unsere Datei **findet**
(`Mod::DetectContents`, Modlet-Reihenfolge, EAC) steht hier nicht zur Debatte und ist durch
diesen Befund nicht gezeigt. Der Nachweis bleibt derselbe wie für WP3.6: ein Spielstart mit
abgeschaltetem EAC, dann im `Player.log` die Zeile `[MODS] Loading localization from mod:`
für `700_90_Sprache` suchen und im Inventar nachsehen, ob „Raseneisenerz" dasteht.
