# mod700check — die drei Prüfwerkzeuge

Umsetzung von [Vertrag 04](../../docs/contracts/04-pruefwerkzeuge.md), Arbeitspaket WP2 aus
[Plan-0001](../../docs/plans/0001-phase-1-mvp-700-und-grauen.md).

C#, net10.0, nur Standardbibliothek, kein NuGet-Paket — dasselbe Muster wie
[`tools/meta`](../meta/README.md). Kein Python (globale Regel).

## Bauen und laufen lassen

```bash
dotnet build tools/check/Mod700.Check/Mod700.Check.csproj -c Release
```

```bash
tools/check/check-all.ps1
```

`check-all.ps1` ist **der** Prüfbefehl des Projekts. Er lässt zuerst die Gegenproben laufen und
danach die Inhaltsprüfungen; ohne grüne Gegenproben bricht er ab, weil dann keine Aussage der
Werkzeuge belastbar ist.

## Die drei Befehle

```bash
mod700check anachronisms <ordner> [--denylist <datei>] [--json]
mod700check recipes      <ordner> [--from <kennung>] [--world-roots <datei>] [--no-world-roots] [--json]
mod700check localization <datei>  [--sprachen english,german] [--prefix 700_] [--vanilla-keys <datei>] [--json]
```

Exit-Code: **0** grün, **1** rot, **2** Benutzungsfehler. Der Unterschied zählt: Exit 2 heißt
*nicht geprüft*, und das darf nie als grün durchgehen. `check-all.ps1` behandelt Exit 2 darum
wie rot.

### Woher die Daten kommen

`<ordner>` ist entweder ein **ConfigsDump** des Spiels (die gemergte Config, gilt als Nachweis)
oder **`Data/Config`** der Installation (Vanilla, nur Vorlauf). Welches von beidem es ist,
erkennt das Werkzeug am Inhalt — `Localization.csv` liegt in `Data/Config`, aber **nicht** im
Dump — und schreibt es in jede Ausgabe.

Den Dump legt das Spiel bei **jedem Start** selbst an:

```
%APPDATA%\7DaysToDie\Saves\<Welt>\<Spielstand>\ConfigsDump\
```

Das ist der Grund, warum kein Werkzeug den XML-Patcher nachbauen muss.

## Zwei Dateien, in denen Annahmen offen liegen

Beide könnten im Code stehen. Sie stehen absichtlich daneben: eine Annahme, die man nachlesen
und ändern kann, ohne neu zu bauen, ist eine bessere Annahme.

### `denylist.txt`

Muster für verbotene Kennungen, dazu **Freigaben** mit `!` am Zeilenanfang. Die Freigaben sind
Pflicht: D9 verlangt, dass Geschütztürme, Generator, Kabel, Schalter, Sensoren und Sprengstoff
als Klassen erhalten bleiben, weil F-15 sie in Phase 2 umdeutet. Ohne Freigabe würde dieses
Werkzeug verlangen, ein ganzes Feature der nächsten Phase zu zerstören. Jede Freigabe trägt
ihre Begründung im Kommentar.

### `world-roots.txt`

Wurzeln des Rezeptgraphen, die das XML nicht ausdrückt. Der Graph kennt vier Wege aus den
Dateien — `<drop event="Harvest">`, Loot, Händlerware, Startausrüstung. Es gibt aber Dinge, die
über eine Handlung oder eine Sondermechanik kommen, und dafür steht nirgends ein lesbares
Attribut.

**Wie diese Datei entstanden ist, ist die Kalibrierung des Werkzeugs.** Der erste Lauf gegen das
unveränderte Vanilla-Config meldete **38 Sackgassen**. Nicht Vanilla war kaputt, sondern meine
Wurzelmenge unvollständig: alle 38 gingen auf genau **acht** Kennungen zurück — sechs
Schmelz-Einheiten der Esse (`unit_*`, entstehen beim Einschmelzen, nicht durch ein Rezept),
`bucketRiverWater` (Eimer an der Wasserquelle) und `domesticatedChicken` (lebendes Tier). Mit der
Datei ist Vanilla grün.

Ein Prüfer, der schon am unveränderten Spiel rot meldet, taugt nicht als Signal.

## Nachweis, dass die Prüfungen greifen

Projektregel 5: ein Check zählt erst, wenn er einmal nachweislich an einem falschen Eingabewert
scheitert. `tools/check/gegenproben.ps1` erbringt das und ist wiederholbar — die Prüfdaten unter
`testdaten/` bestehen aus **erfundenen** Kennungen, nicht aus Spielinhalt (Projektregeln 1 und 7).

Lauf vom 2026-11-07: **11 Gegenproben, 0 fehlgeschlagen.**

| Gegenprobe | Erwartung | Ergebnis |
|---|---|---|
| `anachronisms`, sauberer Satz | Exit 0 | grün |
| `recipes`, sauberer Satz | Exit 0 | grün |
| `localization`, sauberer Satz | Exit 0 | grün |
| `anachronisms` gegen `testdaten/rot` (Pistole in Loot **und** beim Händler) | Exit 1 | rot, nennt beide Wege |
| `recipes` gegen `testdaten/rot` (Zyklus + unbekannte Zutat) | Exit 1 | rot, drei Befundarten unterschieden |
| `localization` gegen `testdaten/rot` (Dublette, leeres Deutsch, fehlendes Präfix, falsche Spaltenzahl) | Exit 1 | rot |
| `recipes --no-world-roots` gegen den **sauberen** Satz | Exit 1 | rot — beweist, dass `world-roots.txt` wirklich etwas beiträgt |
| unbekannter Befehl | Exit 2 | Benutzungsfehler |
| fehlender Pfad | Exit 2 | Benutzungsfehler |
| Ordner ohne `items.xml` | Exit 2 | Benutzungsfehler |
| unbekannte Option | Exit 2 | Benutzungsfehler |

Die siebte Zeile ist die wichtigste: sie prüft nicht das Werkzeug, sondern **die Annahme**.

### Kalibrierung gegen das echte Spiel

| Lauf | Ergebnis |
|---|---|
| `recipes` gegen Vanilla V 3.40 `Data/Config` | 633 Rezepte, **0 Sackgassen, 0 Zyklen**, 8 Wurzeln aus `world-roots.txt` |
| `localization` gegen Vanilla `Localization.csv` | 20 Spalten, 25.930 Zeilen, **25.930 eindeutige Schlüssel** (keine Dublette) |
| `anachronisms` gegen Vanilla | **138 verbotene Kennungen** erreichbar, 101 Treffer durch Freigaben erlaubt |

Die letzte Zeile ist kein Mangel, sondern das Bild **vor** der Arbeit: Vanilla *ist* voller
Anachronismen, und WP3 hat noch nicht stattgefunden. `check-all.ps1` bleibt bis dahin rot, und
das ist richtig — ein Prüfbefehl, der vor der Arbeit grün ist, prüft nichts.

## Grenzen

Jede Ausgabe trägt ihre Grenzen selbst mit (`limitations` im JSON). Die wichtigsten:

- **Prefabs sieht niemand.** Gegenstände, die nur in einem POI liegen (platzierte Blöcke,
  Kisteninhalte), stehen in keiner Config-Datei. Das ist die bekannte MVP-Lücke von F-01 und
  gehört zu F-07.
- **Die Denylist ist eine Musterliste, kein Verständnis.** Ein Anachronismus mit unerwartetem
  Namen fällt durch, bis die Liste ihn kennt.
- **Erreichbarkeit ist nicht Balance.** Dass ein Pfad existiert, heißt nicht, dass er sich gut
  anfühlt. Das entscheidet der Playtest.
- **Ein Dump verrät seine Herkunft nicht.** Er sagt nicht, von welcher Spielfassung er stammt
  und welche Modlets geladen waren — ein alter sieht aus wie ein frischer. Auf den Zeitstempel
  achten; die Werkzeuge geben ihn aus.
- **`Localization.csv` liegt nicht im Dump.** Geprüft wird darum immer die Quelldatei, nie die
  gemergte Fassung. Ein Schlüssel, den zwei Modlets doppelt setzen, fällt nur auf, wenn beide
  Dateien zusammen geprüft werden.

## Dateien

| Datei | Zweck |
|---|---|
| `Mod700.Check/Program.cs` | Befehlsverteilung, Exit-Codes |
| `Mod700.Check/Report.cs` | Befunde sammeln, JSON und lesbare Ausgabe |
| `Mod700.Check/ConfigSource.cs` | Dump oder Vanilla erkennen, XML laden |
| `Mod700.Check/Csv.cs` | CSV-Leser (Felder in Anführungszeichen, Kommas darin) |
| `Mod700.Check/LocalizationCheck.cs` | Spalten **nach Namen**, nie nach Position |
| `Mod700.Check/AnachronismCheck.cs` | Erreichbarkeitswege gegen die Denylist |
| `Mod700.Check/RecipeCheck.cs` | Rezeptgraph, Sackgassen, Zyklen |
| `denylist.txt` | verbotene Muster und die D9-Freigaben |
| `world-roots.txt` | Wurzeln, die das XML nicht ausdrückt |
| `gegenproben.ps1` | der Nachweis nach Projektregel 5 |
| `check-all.ps1` | der Prüfbefehl des Projekts |
| `testdaten/` | erfundene Prüfdaten, ein sauberer und ein roter Satz |
