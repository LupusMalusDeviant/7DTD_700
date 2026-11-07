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

Belegt sind die Methoden in `XmlPatchMethods`; die XML-Tag-Namen sind daraus **abgeleitet** und
beim ersten Modlet zu bestätigen (ein falscher Tag-Name erzeugt sofort eine Protokollzeile).

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

**D9 beachten:** Geschütztürme, Generator, Kabel, Schalter, Sensoren, elektrische Fallen und
Sprengstoff werden nur in ihrer modernen Erscheinung gesperrt. Ihre Klassen und ihre Logik
bleiben vollständig erhalten, weil F-15 sie in Phase 2 als Runensteine und Kraftsteine
weiterverwendet. Wer hier `remove` benutzt, zerstört ein ganzes Feature der nächsten Phase.

## 5. Bedingte Blöcke — der Weg zur Verträglichkeit

`XmlPatchConditionEvaluator` wertet Bedingungen über NCalc aus und bietet diese Funktionen:

| Funktion | Nutzen für uns |
|---|---|
| `mod_loaded` | **Patch nur anwenden, wenn (oder solange nicht) eine andere Mod da ist** |
| `mod_version` | deren Fassung prüfen |
| `game_version`, `version` | Spielfassung prüfen — ein Build-Guard in XML |
| `xpath` | **nur ändern, wenn das Ziel existiert** |
| `gamepref`, `serverinfo` | Server- und Spieleinstellungen |
| `eventActive`, `time_minutes`, `game_loaded` | Laufzeitzustand |
| `has_entitlement` | Besitzrechte |

**Verbindlich für XUi-Patches (D5):** Jeder Eingriff in `XUi_*` wird in einen `conditional`-Block
gelegt, der mit `mod_loaded` auf die bekannten UI-Mods prüft. Damit bleibt die Mod verträglich,
ohne dass wir Layout-Umbauten machen oder C# brauchen.

**Verbindlich für alles, was ein Vanilla-Element voraussetzt:** `xpath(…)` davor. Ein Patch, der
ein Element ändert, das eine andere Mod entfernt hat, bricht sonst die ganze Datei.

Die Funktionsnamen sind belegt, **die genaue Schreibweise der Ausdrücke nicht**. Der erste
`conditional`-Block in Phase 1 bestätigt sie.

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

- **Die XML-Tag-Namen der elf Operationen sind abgeleitet**, nicht belegt (nur `removeattribute`
  wörtlich). Bestätigung mit dem ersten Modlet.
- **Die Ausdruckssyntax der `conditional`-Bedingungen** ist nicht belegt.
- **Welche UI-Mods** in den `mod_loaded`-Bedingungen stehen, hängt an der offenen Frage Q8 —
  der Nutzer benennt die Referenz-UI-Mods (Plan-0001 WP8.9).
- Ob ein Modlet eine Datei patchen kann, die **nicht** in der Liste der 52 steht (etwa eine von
  einer anderen Mod eingebrachte), ist nicht geprüft.
