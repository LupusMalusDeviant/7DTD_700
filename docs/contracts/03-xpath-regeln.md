# Vertrag 03 — XPath-Regeln

- **Status:** Entwurf, wartet auf Abnahme
- **Datum:** 2026-11-07
- **Gilt ab:** Phase 1 (Plan-0001 WP1)
- **Belege:** [WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md) ·
  Spec 01 [§4.1 UI-Kompatibilität (D5)](../specs/01-technischer-rahmen.md)

## 1. Die Grundregel

**Additiv und zielgenau. Niemals eine ganze Datei ersetzen.**

Eine Mod, die `items.xml` als Ganzes ersetzt, macht jede andere Mod unbrauchbar und bricht beim
nächsten Spiel-Update, weil sie eine Fassung von Vanilla einfriert. Ein Patch, der nur sein Ziel
anfasst, überlebt beides.

## 2. Die elf Operationen

Belegt sind die Methoden in `XmlPatchMethods`; ~~die XML-Tag-Namen sind daraus **abgeleitet** und
beim ersten Modlet zu bestätigen (ein falscher Tag-Name erzeugt sofort eine Protokollzeile).~~
**Seit dem 2026-11-22 sind auch die Tag-Namen belegt** — gelesen aus den Attributen der elf
Methoden (Finding WP1 §4, Nachtrag). Sie stimmen mit der Tabelle überein.

| Tag | Methode | Was es tut | Wann wir es nehmen |
|---|---|---|---|
| `append` | `AppendByXPath` | hängt Kinder an das Ziel an | **Standard** für neue Gegenstände, Blöcke, Rezepte |
| `prepend` | `PrependByXPath` | setzt Kinder an den Anfang | selten; wo Reihenfolge zählt |
| `insertAfter` | `InsertAfterByXPath` | fügt Geschwister dahinter ein | wo ein Eintrag neben einen bestimmten gehört |
| `insertBefore` | `InsertBeforeByXPath` | fügt Geschwister davor ein | dito |
| `remove` | `RemoveByXPath` | entfernt Elemente | **nur** wenn Sperren nicht reicht, siehe §4 |
| `set` | `SetByXPath` | ersetzt den Inhalt des Ziels | Werte ändern (Schaden, Haltbarkeit, Nachtwerte) |
| `setattribute` | `SetAttributeByXPath` | setzt ein Attribut | **Standard** zum Umdeuten einzelner Werte |
| `removeattribute` | `RemoveAttributeByXPath` | entfernt ein Attribut | wörtlich belegt in einer Fehlermeldung |
| `csv` | `CsvOperationsByXPath` | ändert kommagetrennte Listen | Tag-Listen, ohne die ganze Liste neu zu schreiben |
| `conditional` | `Conditional` | bedingter Block, siehe §5 | Verträglichkeit mit anderen Mods |
| `include` | `Include` | bindet eine weitere XML-Datei ein | große Dateien zerlegen, siehe §6 |

**`remove` entfernt keine Attribute.** Das sagt die Fehlermeldung des Spiels wörtlich: *„Can not
remove matched Attribute (…), use removeattribute instead"*. Wer ein Attribut loswerden will,
nimmt `removeattribute`.

## 3. Patchbar sind genau diese Dateien

`StockFileHashes::.cctor` führt 52 Dateien. Für Phase 1 relevant:

```
items.xml  item_modifiers.xml  recipes.xml  blocks.xml  shapes.xml  materials.xml
loot.xml   traders.xml         progression.xml  qualityinfo.xml  buffs.xml
entityclasses.xml  entitygroups.xml  spawning.xml  gamestages.xml
biomes.xml  rwgmixer.xml  worldglobal.xml  weathersurvival.xml  sounds.xml
gameevents.xml  misc.xml  toolbelt.xml  ui_display.xml  loadingscreen.xml
XUi_Common/styles.xml     XUi_Common/templates.xml
XUi_InGame/styles.xml     XUi_InGame/templates.xml
XUi_InGame/windows.xml    XUi_InGame/xui.xml
XUi_Menu/…                (vom Lader erkannt, nicht in der Hash-Liste)
```

**Der Dateiname im Modlet muss genau dem Vanilla-Namen entsprechen**, sonst findet der Patcher
die Datei nicht und schweigt. Das ist der am leichtesten zu machende und am schwersten zu
findende Fehler: ein `item.xml` statt `items.xml` erzeugt keine Fehlermeldung, es passiert
einfach nichts.

**XUi liegt unter `XUi_Common/`, `XUi_InGame/` und `XUi_Menu/`** — mit Unterstrich, nicht
`XUi/`. Spec 01 sagte ursprünglich `Config/XUi/…`; das ist berichtigt.

## 4. Sperren statt löschen

Für F-01 (Purge) verbindlich: **was es um 700 nicht gab, wird gesperrt, nicht entfernt.**

| statt | so |
|---|---|
| `<remove xpath="//item[@name='gunPistol']"/>` | `CreativeMode` auf `None`, Rezept weg, Loot weg |

Begründung: Vanilla-POIs, Quests und Händler-Tabellen referenzieren Gegenstände. Ein entfernter
Gegenstand, auf den ein Prefab zeigt, bricht beim Laden der Welt. Gesperrt bleibt er auflösbar,
ist aber nicht erreichbar.

`remove` ist erlaubt für: Loot-Einträge, Rezepte, Händler-Warengruppen, Perk-Einträge — also für
**Wege zu einem Gegenstand**, nicht für den Gegenstand selbst.

### Nachtrag WP3.2 (2026-11-07): die Purge-Patches sind erzeugt, nicht geschrieben

Die Dateien in `mod/700_10_Purge/Config/` entstehen aus `mod700check purge-patch` und damit aus
`tools/check/denylist.txt` und `tools/check/aufschub.txt`. Sie sagen das im Kopfkommentar und
dürfen nicht von Hand geändert werden; `check-all.ps1` meldet jede Handänderung als
`patchdatei-veraltet`.

Der Grund ist der Vertragsgedanke selbst: 592 gesperrte Kennungen von Hand auf sieben Dateien zu
verteilen heißt, dieselbe Liste zweimal zu führen — einmal in der Denylist, einmal im Modlet. Die
Prüfung sieht den Unterschied nicht, weil sie die gemergte Config liest und nicht unsere Patches.
In dieser Arbeit sind schon dreimal Zahlen auseinandergelaufen, weil dieselbe Frage an zwei
Stellen beantwortet wurde.

**Zwei Dinge, die das für diesen Vertrag heißt:**

1. **Der XPath wird aus den Daten gebaut, nicht aus dem Gedächtnis.** Das Werkzeug nimmt die
   tatsächliche Elternkette des gefundenen Elements im Quell-XML (`/recipes/recipe[@name='X']`).
   Alle erzeugten Pfade sind damit absolut und ohne `//`: §8.2 ist nicht nur eingehalten, er kann
   nicht verletzt werden. Dass ein Prädikat mehrere Elemente trifft, ist dabei Absicht — ein
   Gegenstand kann mehrere Rezepte haben, und alle sollen fallen. §8.2 verbietet den
   **unverankerten** `//`-Pfad, nicht den mehrfachen Treffer; eine Nachprobe zählt darum, wie
   viele Wege nach den Entfernungen noch offen sind, und die Zahl muss 0 sein.
2. **`CreativeMode` wird mit `set` oder `append` gesetzt, je nach Quelle.** Trägt der Gegenstand
   die Eigenschaft selbst, wird ihr Wert ersetzt. Erbt er sie über `Extends` oder hat er sie
   nicht, wird sie angehängt und überschreibt die geerbte. Ein `set` auf eine Eigenschaft, die es
   nicht gibt, trifft nichts und schweigt — dieselbe Fehlerart, die §3 über den Dateinamen
   beschreibt.

**Und eine Berichtigung am Plan, nicht an diesem Vertrag:** `CreativeMode="None"` ist **keine
Sperre für den Spieler.** Es nimmt den Gegenstand aus dem Kreativmenü und aus der
Entwicklerliste, nicht aus dem Spiel. Unerreichbar wird er allein durch die entfernten Wege.
Plan-0001 WP3.2 nennt `CreativeMode` als „sperren statt löschen"; das ist richtig als
Absichtserklärung in den Daten und falsch als Wirkung. Die Tabelle oben bleibt gültig — sie sagt
„Rezept weg, Loot weg" mit dazu.

**D9-Wächter:** der Bericht weist `remove_auf_definition` aus. Heute ist die Zahl 0, weil nur
`recipes.xml` Entfernungen bekommt; sie steht dort für WP3.3 und WP3.4, die `loot.xml`,
`traders.xml` und `quests.xml` dazunehmen. Ein Tippfehler in einem Elementnamen soll dann dort
auffallen und nicht erst beim Weltladen.

**D9 beachten:** Geschütztürme, Generator, Kabel, Schalter, Sensoren, elektrische Fallen und
Sprengstoff werden nur in ihrer modernen Erscheinung gesperrt. Ihre Klassen und ihre Logik
bleiben vollständig erhalten, weil F-15 sie in Phase 2 als Runensteine und Kraftsteine
weiterverwendet. Wer hier `remove` benutzt, zerstört ein ganzes Feature der nächsten Phase.

### Nachtrag WP4.1 (2026-11-07): Abwürfe, und eine Datei aus zwei Teilen

**Ein `<drop>` ist ein Weg, keine Definition.** `remove` auf
`/blocks/block/drop[@name='resourceScrapPolymers']` ist damit erlaubt (§4): der Block bleibt
vollständig stehen, er gibt nur das Gesperrte nicht mehr her. Diese Zeilen tragen **bewusst
kein Block-Prädikat** — der Gegenstand soll aus *jedem* Block verschwinden. Das ist derselbe
Fall wie bei den Rezepten: mehrfacher Treffer ist Absicht, `//` ohne Verankerung bleibt
verboten, und die Nachprobe zählt nach.

Warum das nachgetragen wurde, steht in Vertrag 04 §3d: bis dahin war der Block-Abwurf kein
Erreichbarkeitsweg, und 26 gesperrte Kennungen fielen weiter aus 869 Abwurfzeilen.

**Zwei Teile, eine Datei.** `blocks.xml` bekommt die `CreativeMode`-Zeilen *und* die
Abwurf-Entfernungen. Sie müssen in **eine** Datei, weil `Mod::DetectContents` und der Patcher
eine Modlet-Datei über den **Dateinamen** ihrer Vanilla-Datei zuordnen — eine
`blocks-abwuerfe.xml` würde geladen und nie angewandt. Dasselbe gilt für jede künftige
Aufteilung: **der Dateiname ist die Zuordnung, nicht der Inhalt.** Im Kopf der erzeugten Datei
steht darum je Teil eine eigene Begründung und die Zahl „n Zeilen aus 2 Teilen".

## 5. Bedingte Blöcke — der Weg zur Verträglichkeit

`XmlPatchConditionEvaluator` wertet Bedingungen über NCalc aus und bietet diese Funktionen:

| Funktion | Nutzen für uns |
|---|---|
| `mod_loaded` | **Patch nur anwenden, wenn (oder solange nicht) eine andere Mod da ist** |
| `mod_version` | deren Fassung prüfen |
| `game_version`, `version` | Spielfassung prüfen — ein Build-Guard in XML |
| `xpath` | **nur ändern, wenn das Ziel existiert** |
| `gamepref`, `serverinfo` | Server- und Spieleinstellungen |
| ~~`eventActive`~~ `event`, `time_minutes`, `game_loaded` | Laufzeitzustand *(Name berichtigt 2026-11-22)* |
| `has_entitlement` | Besitzrechte |

**Verbindlich für XUi-Patches (D5):** Jeder Eingriff in `XUi_*` wird in einen `conditional`-Block
gelegt, der mit `mod_loaded` auf die bekannten UI-Mods prüft. Damit bleibt die Mod verträglich,
ohne dass wir Layout-Umbauten machen oder C# brauchen.

**Verbindlich für alles, was ein Vanilla-Element voraussetzt:** `xpath(…)` davor. Ein Patch, der
ein Element ändert, das eine andere Mod entfernt hat, bricht sonst die ganze Datei.

Die Funktionsnamen sind belegt, **die genaue Schreibweise der Ausdrücke nicht**. Der erste
`conditional`-Block in Phase 1 bestätigt sie.

### Nachtrag WP8.7 (2026-11-22): Schreibweise belegt, Regel für XUi — **Abnahme offen**

Die Schreibweise ist jetzt aus dem Code gelesen und gegen die NCalc-Bibliothek des Spiels
gemessen ([Finding WP1 §4, Nachtrag](../rea/findings/WP1-modlet-lader-und-xml-patcher.md)).
Im Spiel hat noch kein bedingter Block von uns geladen.

**So wird ein bedingter Block geschrieben:**

```xml
<conditional>
  <if cond="xpath('/styles/global/style_entry[@name=&quot;darkGrey&quot;]') != null">
    <setattribute name="value" xpath="/styles/global/style_entry[@name='darkGrey']">70,62,52,255</setattribute>
  </if>
</conditional>
```

1. Kinder von `<conditional>` sind nur `<if cond="…">` und `<else>`, klein geschrieben. Kein
   `<elseif>` (mehrere `<if>` tun dasselbe), kein `<if>` hinter `<else>`, kein `evaluator`.
2. **Die Bedingung muss einen Wahrheitswert liefern.** `mod_loaded('Name')` tut das.
   **`xpath('…')` tut es nicht** — es liefert den Treffer oder `null`; allein als Bedingung
   wirft es eine Ausnahme. Geschrieben wird `xpath('…') != null`.
3. Der XPath in der Bedingung steht in einfachen Anführungszeichen, seine eigenen in `&quot;`.
4. Verknüpft wird mit `and`, `or`, `not`.
5. Die Funktion für Ereignisse heißt **`event`**, nicht `eventActive` (so heißt nur die Methode).
   Die Tabelle oben ist an dieser Stelle falsch.

**Was die Regel „jeder Eingriff in `XUi_*` in einen `conditional`-Block mit `mod_loaded`" heute
heißt.** Sie setzt eine Liste bekannter UI-Mods voraus, und die gibt es nicht: Q8 ist offen
(Plan-0001 WP8.9). *(Seit dem 2026-11-22 gibt es sie, D86 — siehe „Nachtrag WP8.9" unten;
die Tabelle hier gilt unverändert weiter.)* Bis der Nutzer sie nennt, gilt:

| Eingriff | Form |
|---|---|
| ändert ein Vanilla-Element oder hängt etwas **an** eines (`setattribute`, `set`, `append` auf ein Fenster, `insertBefore` …) | `<conditional><if cond="xpath('<dasselbe Ziel>') != null">` — der Patch läuft nur, wenn das Ziel noch da ist, und hinterlässt sonst keine Warnung im Protokoll |
| legt etwas Eigenes an der Wurzel an (`append xpath="/xui"`, `/windows`, `/styles`) | ohne Block — es gibt nichts, was eine andere Mod weggenommen haben könnte |

Die `mod_loaded`-Teile kommen mit WP8.9 dazu, **wo die Testmatrix einen Konflikt zeigt**, nicht
auf Vorrat (§7.4). Das ist enger als der Satz oben und ersetzt ihn, sobald es abgenommen ist.

**Eine bekannte Abweichung bleibt stehen:** die drei XUi-Patches in `700_40_Bauen`
(Werkzeugslots der Feuerstelle, Brennstoffkammer des Kalkofens, Fenstergruppe des Webstuhls)
stehen weiter ohne Block. Zwei davon müssten nach der Tabelle einen tragen. Sie werden erst
umgestellt, **wenn ein bedingter Block von uns im Spiel gelaufen ist** — bis dahin ist die
Schreibweise gemessen, nicht gesehen, und ein Fehler darin nähme dem Webstuhl sein Fenster
und der Feuerstelle ihre Slots. Die Theming-Patches aus WP8.7 sind die ersten Blöcke; an
ihnen kostet ein Fehler nur eine Farbe. → Prüfliste 22.

### Nachtrag WP8.9 (2026-11-22): die Referenz-UI-Mods sind benannt — **Abnahme offen**

Q8 ist entschieden (D86): **„AGF HUDPlus"** und **„E C H O // Hybrid UI"**. Damit gibt es die
Liste, die die Regel oben voraussetzt. An der Form der Patches ändert das heute nichts:

1. **Keine `mod_loaded`-Bedingung auf Vorrat.** Die Tabelle des Nachtrags WP8.7 gilt weiter.
   Eine Bedingung auf eine der beiden Mods kommt erst dazu, wenn die Testmatrix (Mod allein,
   Mod + AGF HUDPlus, Mod + E C H O) einen Konflikt zeigt — und dann genau an dem Patch, der
   ihn hat.
2. **Der Name in `mod_loaded('…')` wird nicht geraten.** Er wird aus der `ModInfo.xml` der
   Referenz-Mod abgeschrieben, sobald sie vorliegt, und im Spiel bestätigt. Ob die Funktion
   den `Name`, den Ordnernamen oder beides kennt, ist weiter nicht gelesen (§9).
3. **Die Dateien der Referenz-Mods gehören nicht ins Repository.** Sie liegen unter
   `GameRefs/ui-mods/` und werden nie committet; aus ihnen wird nichts übernommen
   (Projektregeln 1 und 7).
4. **Erwartete Ladereihenfolge:** unsere Ordner beginnen mit `700_` und stehen damit vor
   Ordnern, die mit einem Buchstaben beginnen — eine UI-Mod lädt nach uns (Spec 01 §4.1
   Punkt 5). Das ist aus den Namen geschlossen, nicht im Protokoll gesehen.
5. **Ein Lauf der Matrix zählt nur, wenn die Referenz-Mod in ihm geladen ist** (ergänzt am
   2026-11-22 nach dem Review von `ecffb1e`). Das Protokoll muss sie als geladen ausweisen
   und, wenn sie Code mitbringt, als initialisiert; ein Lade-, Initialisierungs- oder
   Laufzeitfehler der Referenz-Mod macht den Lauf ungültig — nicht bestanden und kein
   Konflikt. Ohne das gälte „keine Fehler zu unseren Modlets" auch dann als Verträglichkeit,
   wenn die andere Mod gar nicht lief. Die Zeilen dazu stehen in Plan-0001, Prüfliste 24 e.

## 6. `include` zerlegt Dateien, ersetzt aber keine Modlets

`Include` erlaubt, XML aus einer weiteren Datei einzubinden. Damit lässt sich eine große
`items.xml` in lesbare Stücke teilen.

**Das ersetzt die Modlet-Aufteilung aus [Vertrag 01](01-modlet-grenzen.md) nicht.** Eine
eingebundene Datei lässt sich zum Debuggen nicht wegnehmen, ein Modlet-Ordner schon. `include`
ist für Lesbarkeit innerhalb eines Modlets, nicht für Trennung von Features.

## 7. Form eines Patches

Jede Patch-Datei beginnt mit einem Kopf, der sagt, wohin sie gehört und warum:

```xml
<config>
  <!-- 700_30_Ausruestung / items.xml
       F-02 Waffen & Kampf, Plan-0001 WP5.1
       Nahkampfwaffen T0-T4 auf Vanilla-Basis. Kennungen nach Vertrag 02.
       Anzeigenamen in 700_90_Sprache/Config/Localization.csv. -->

  <append xpath="/items">
    <item name="itm700_spatha">
      …
    </item>
  </append>
</config>
```

**Verbindlich:**
1. Wurzelelement `<config>`.
2. Kopfkommentar mit Modlet, Datei, Feature und Planschritt. Wer in sechs Monaten eine Zeile
   sucht, soll wissen, warum sie da ist.
3. **Ein XPath so kurz wie nötig und so genau wie möglich.** `/items` als Ziel eines `append` ist
   richtig; `//item` als Ziel eines `set` ist ein Fehler, weil es alle Gegenstände trifft.
4. Keine Patches „auf Vorrat" für Dinge, die noch nicht gebraucht werden (D50, strikte Phasen).

## 8. Was verboten ist

1. **Ganze Dateien ersetzen** — der Grund für diesen Vertrag.
2. **XPath mit `//` in einem `set` oder `remove`**, ohne ein Prädikat, das genau ein Element
   trifft. `//item` trifft alles.
3. **Layout-Umbau in XUi.** Theming über Farben, Rahmen und vorhandene Atlas-Sprites (D5).
4. **Ein Vanilla-Element ändern, ohne es vorher mit `xpath(…)` zu prüfen**, wenn eine andere Mod
   es plausibel entfernt haben könnte.
5. **`remove` auf einen Gegenstand oder Block**, siehe §4.

## 9. Offene Punkte dieses Vertrags

- ~~**Die XML-Tag-Namen der elf Operationen sind abgeleitet**, nicht belegt (nur `removeattribute`
  wörtlich). Bestätigung mit dem ersten Modlet.~~ Belegt seit dem 2026-11-22 (§2).
- ~~**Die Ausdruckssyntax der `conditional`-Bedingungen** ist nicht belegt.~~ Gelesen und
  gemessen seit dem 2026-11-22 (§5, Nachtrag WP8.7). **Offen bleibt der Lauf im Spiel**
  (Prüfliste 22) und was `mod_loaded` als Namen erwartet — den `Name` aus `ModInfo.xml` oder
  den Ordnernamen, mit oder ohne Groß/Klein.
- ~~**Welche UI-Mods** in den `mod_loaded`-Bedingungen stehen, hängt an der offenen Frage Q8 —
  der Nutzer benennt die Referenz-UI-Mods (Plan-0001 WP8.9).~~ **Benannt am 2026-11-22 (D86):**
  „AGF HUDPlus" und „E C H O // Hybrid UI". **Offen bleibt**, unter welchem Namen `mod_loaded`
  sie kennt — das steht erst fest, wenn ihre `ModInfo.xml` vorliegt — und ob überhaupt eine
  Bedingung gebraucht wird: das zeigt die Testmatrix (§5, Nachtrag WP8.9).
- Ob ein Modlet eine Datei patchen kann, die **nicht** in der Liste der 52 steht (etwa eine von
  einer anderen Mod eingebrachte), ist nicht geprüft.
