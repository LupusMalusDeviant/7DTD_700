# Vertrag 04 — Prüfwerkzeuge

- **Status:** Entwurf, wartet auf Abnahme
- **Datum:** 2026-11-07
- **Gilt ab:** Phase 1 (Plan-0001 WP2)
- **Beleg:** [WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md)

Die drei Signale, an denen die Ziele Z2, Z3 und Z4 des Plans hängen. Ohne sie ist „keine
Anachronismen" eine Behauptung.

## 1. Woher die Daten kommen — das war die offene Frage

Geprüft werden muss die **gemergte** Config: Vanilla plus unsere Patches, so wie das Spiel sie
am Ende sieht. Ein Werkzeug, das nur unsere Patch-Dateien liest, sieht nicht, was davon
tatsächlich gegriffen hat.

**Das Spiel liefert diese Daten selbst.** `ConsoleCmdExportCurrentConfigs` sagt wörtlich:

> *„Patched XMLs are automatically dumped on game start to a ConfigsDump subdirectory of the
> save game."*

Es gibt also nach **jedem** Spielstart einen Ordner mit der fertig gemergten Config. Auf diesem
Rechner liegen bereits fünf davon, zum Beispiel:

```
%APPDATA%\7DaysToDie\Saves\<Welt>\<Spielstand>\ConfigsDump\
    43 Dateien, 15 MB, items.xml mit 32.052 Zeilen
```

Dazu der Konsolenbefehl `exportcurrentconfigs`, der auch im Hauptmenü läuft — dort allerdings
nur mit `rwgmixer`, `loadingscreen` und den `XUi_Menu`-Dateien („No game started, exporting XUi
menu and rwgmixer configs").

**Damit muss kein Werkzeug den XML-Patcher nachbauen.** Das war der teure Weg, und er ist nicht
nötig.

### Zwei Betriebsarten

| Art | Eingabe | Was sie beweist | Braucht Spielstart |
|---|---|---|---|
| **Vorlauf** | `Data/Config/` des Spiels + unsere Modlet-Dateien | Formfehler, Denylist-Treffer in unseren eigenen Patches, Localization-Form | nein |
| **Nachweis** | ein `ConfigsDump/` | den tatsächlichen Endzustand | **ja**, einmal pro Prüfung |

Der Vorlauf läuft bei jeder Änderung und ist billig. Der Nachweis zählt für die
Erfolgskriterien. **Nur der Nachweis darf „grün" heißen.** Der Vorlauf sagt „nichts gefunden",
was nicht dasselbe ist.

## 2. Ein Werkzeug, drei Befehle

Wie `mod700meta`: ein C#-Projekt, mehrere Unterbefehle. **Kein Python** (globale Regel).

```
tools/check/Mod700.Check/           → mod700check.exe
```

```
mod700check anachronisms <ordner> [--denylist <datei>] [--json]
mod700check recipes      <ordner> [--from <kennung>] [--json]
mod700check localization <datei>  [--sprachen english,german] [--json]
```

`<ordner>` ist entweder ein `ConfigsDump/` oder ein `Data/Config/`. Das Werkzeug erkennt am
Inhalt, welche Art es ist, und schreibt es in die Ausgabe — damit in keinem Bericht ein Vorlauf
als Nachweis durchgeht.

### Gemeinsame Regeln für alle drei

| Punkt | Festlegung |
|---|---|
| Ausgabe | JSON auf stdout, wie `mod700meta`: `tool`, `command`, `source`, `counts`, `findings`, `summary`, `limitations` |
| `summary.verdict` | `green` oder `red` |
| Exit-Code | **0** bei grün, **1** bei rot, **2** bei Benutzungsfehler |
| Lesbare Fassung | ohne `--json` eine kurze Tabelle für Menschen, mit demselben Exit-Code |
| Keine Schreibzugriffe | die Werkzeuge lesen, sie ändern nichts |
| Herkunft | jede Ausgabe nennt den geprüften Ordner, seinen Zeitstempel und ob es ein Dump oder Vanilla war |
| Grenzen | jede Ausgabe trägt `limitations`, wie `mod700meta` es tut |

## 3. `anachronisms` — Z2

**Prüft:** Kommt ein verbotener Gegenstand noch irgendwo vor, wo ein Spieler ihn erreichen kann?

Erreichbar heißt: in `loot.xml`, in `recipes.xml`, in einer Händlergruppe in `traders.xml`, in
der Startausrüstung, als Quest-Belohnung in `quests.xml`.

**Nicht** geprüft wird die bloße Existenz in `items.xml` — gesperrte Gegenstände bleiben
absichtlich stehen ([Vertrag 03](03-xpath-regeln.md) §4), weil Prefabs auf sie zeigen.

**Denylist** als eigene Datei (`tools/check/denylist.txt`), eine Regel pro Zeile, Kommentare mit
`#`:

```
# Schusswaffen und Munition
gun*
ammo*
# Fahrzeuge
vehicle*
# ... Elektronik, Konserven, Medikamente, Treibstoff, Beton, Industriestahl
```

**Ausnahmen sind Pflicht, nicht Kür.** D9 verlangt, dass Geschütztürme, Generator, Kabel,
Schalter, Sensoren und Sprengstoff als *Klassen* erhalten bleiben, weil F-15 sie in Phase 2
umdeutet. Die Denylist bekommt darum eine Freigabeliste, und jeder Eintrag darin trägt eine
Begründung:

```
!autoTurret        # D9: wird in Phase 2 der Runenstein der Glut (F-15)
!electricWire      # D9: wird die Odem-Leitung
```

**Gegenprobe (Projektregel 5):** Ein `gunPistol`-Eintrag wird in eine Loot-Gruppe des Prüfordners
eingeschmuggelt, das Werkzeug muss **rot** werden und genau diesen Eintrag nennen. Erst dann
zählt ein späteres Grün. Das Ergebnis gehört in `tools/check/README.md`.

## 4. `recipes` — Z3

**Prüft:** Ist jedes herstellbare Ergebnis aus Rohstoffen erreichbar, die es im Spiel gibt?

Das Werkzeug baut aus `recipes.xml` einen gerichteten Graphen (Zutat → Ergebnis), nimmt als
Wurzeln alles, was abgebaut, geerntet, geplündert oder gehandelt werden kann, und meldet:

| Befund | Bedeutung |
|---|---|
| **Sackgasse** | ein Rezept existiert, aber mindestens eine Zutat ist nirgends erreichbar |
| **Zyklus** | A braucht B, B braucht A |
| **Verwaiste Werkstatt** | ein Rezept verlangt eine Werkbank, für die es kein Bau-Rezept gibt |
| **Unerreichbares Tier** | ein T3-Rezept, zu dem kein Pfad von T0 führt |

`--from <kennung>` prüft einen einzelnen Pfad und erklärt ihn Schritt für Schritt — das ist das
Werkzeug für die Frage „warum kann ich die Spatha nicht bauen?".

**Gegenprobe:** Ein Rezept mit einer erfundenen Zutat (`itm700_gibtEsNicht`) muss **rot** werden.

**Grenze, die in die Ausgabe gehört:** Das Werkzeug prüft Erreichbarkeit, nicht Balance. Dass
ein Pfad existiert, heißt nicht, dass er sich gut anfühlt. Das entscheidet der Playtest.

## 5. `localization` — Z4

**Prüft:** `Config/Localization.csv` gegen die belegte Form.

Die Kopfzeile der ausgelieferten Datei:

```
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english,
Context / Alternate Text,german,spanish,french,italian,japanese,koreana,
polish,brazilian,russian,turkish,schinese,tchinese
```

**Das Werkzeug liest die Spaltennamen aus der Kopfzeile und verlässt sich auf keine Position.**
Der Grund steht im Finding: `Context / Alternate Text` sitzt **zwischen** `english` und `german`.
Ein Werkzeug, das „die Spalte nach english ist Deutsch" annimmt, prüft die Kommentarspalte und
meldet Grün für fehlende Übersetzungen. Dieser Fehler wäre ohne den Blick in die echte Datei
passiert — er ist der Grund, warum diese Regel hier so ausdrücklich steht.

**Befunde:**

| Befund | Regel |
|---|---|
| leere Pflichtspalte | `english` oder `german` leer → rot (D7) |
| doppelter Schlüssel | `Localization::addCsv` verwirft den zweiten stillschweigend → rot |
| Schlüssel ohne `700_` | außer in einer kommentierten Gruppe bewusster Vanilla-Überschreibungen → rot |
| Spaltenzahl weicht ab | eine Zeile mit anderer Spaltenzahl als die Kopfzeile → rot |
| Kopfzeile unbrauchbar | erste Zelle nicht `Key`, oder eine Spaltendefinition leer bzw. nicht lateinisch → rot |
| gefüllte Fremdsprache | eine der zwölf übrigen Sprachen gefüllt → **Hinweis**, nicht rot |

Der letzte Punkt ist bewusst nur ein Hinweis: D7 sagt „leer lassen, nicht mit EN füllen", aber
wenn später jemand wirklich übersetzt, darf das Werkzeug nicht im Weg stehen.

**Gegenprobe:** In einer Kopie der Datei wird eine `german`-Zelle geleert → **rot**; ein
Schlüssel verdoppelt → **rot**.

## 6. Ein Befehl für alles

`tools/check/check-all.ps1` ruft die drei Befehle, fasst zusammen und endet mit Exit 1, wenn
einer rot ist. Dieser Befehl kommt in `.claude/verify.json` und ist damit **der** Prüfbefehl des
Projekts — nach „Nachweis statt Status" darf ohne seinen Lauf keine Antwort „grün" sagen.

`tools/build/smoke.ps1` bleibt daneben: es prüft Paket und Protokoll, nicht die Inhalte.

## 7. Was die Werkzeuge nicht tun

1. **Nichts ändern.** Keine Reparatur, kein Formatieren, kein Sortieren.
2. **Keine Balance beurteilen.** Erreichbarkeit ja, Spielgefühl nein.
3. **Nicht raten.** Wo eine Prüfung unmöglich ist, steht das in `limitations`, nicht ein
   schweigendes Grün.
4. **Kein Spiel starten.** Für die Nachweis-Betriebsart liefert der Nutzer den `ConfigsDump`.

## 8. Offene Punkte dieses Vertrags

- **Der Inhalt der Denylist** ist noch nicht geschrieben; er entsteht in WP3.1 und wird dort
  gegen die echten Dateien aufgebaut.
- **Die Wurzeln des Rezeptgraphen** (was gilt als „von Anfang an erreichbar"?) brauchen eine
  Festlegung, sobald `20_Material` steht. Vorschlag: alles mit einem Abbau-, Ernte- oder
  Loot-Weg, plus Händlerware.
- Die vorhandenen `ConfigsDump`-Ordner auf diesem Rechner sind von **V 3.1.0**, nicht von
  V 3.40 — brauchbar, um die Werkzeuge zu bauen, **nicht** als Nachweis. Der erste echte Dump
  entsteht beim Spielstart des Nutzers.
