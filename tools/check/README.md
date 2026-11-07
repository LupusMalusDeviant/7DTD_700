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

Lauf vom 2026-11-07: **35 Gegenproben, 0 fehlgeschlagen.**

| Gegenprobe | Erwartung | Ergebnis |
|---|---|---|
| `anachronisms`, sauberer Satz | Exit 0 | grün |
| `recipes`, sauberer Satz | Exit 0 | grün |
| `localization`, sauberer Satz | Exit 0 | grün |
| `anachronisms` gegen `testdaten/rot` (Pistole in Loot **und** beim Händler) | Exit 1 | rot, nennt beide Wege |
| `recipes` gegen `testdaten/rot` (Zyklus + unbekannte Zutat) | Exit 1 | rot, drei Befundarten unterschieden |
| `localization` gegen `testdaten/rot` (Dublette, leeres Deutsch, fehlendes Präfix, falsche Spaltenzahl) | Exit 1 | rot |
| `recipes --no-world-roots` gegen den **sauberen** Satz | Exit 1 | rot — beweist, dass `world-roots.txt` wirklich etwas beiträgt |
| `anachronisms` mit **falsch geschriebener** Regel (`gunpruefpistole*`) gegen `testdaten/rot` | Exit 0 | grün — der Vergleich beachtet die Schreibung |
| `anachronisms` mit **richtig geschriebener** Regel (`gunPruefPistole*`) gegen `testdaten/rot` | Exit 1 | rot — ohne diesen Fall wäre der vorige auch grün, wenn gar nichts mehr trifft |
| `anachronisms` gegen `testdaten/eigenschaften` | `pruefFeuerrohr` rot, `pruefSelbstbogen` **nicht** | gleiche `Group`, nur `Tags` trennen — das Paar, das ein Namensmuster verwechseln muss |
| `--ohne-regel strom` | `pruefKraftstein` **fehlt** in der Ausgabe | fiele er weiter, hätte nicht die Regel entschieden |
| `--no-extends` | `pruefKraftsteinVariante` **fehlt** | sie erbt ihre Klasse — der Nachweis, dass die Vererbung etwas beiträgt |
| `anachronisms` gegen `testdaten/eigenschaften` | `unaufloesbare-kennung: pruefGeisterding` | eine Kennung ohne Definition ist kein Grün |
| `anachronisms` gegen `testdaten/eigenschaften` | `pruefModRohrAufsatz` rot, `pruefModBogenauflage` **nicht** | Mods fallen mit ihrem Träger, abgeleitet aus `installable_tags` |
| `anachronisms` gegen `testdaten/eigenschaften` | `pruefWurfglut` rot über `[sprengkoerper]` | der Prüfling trägt `explosivesSkill` **nicht** — die Klasse `ItemClassTimeBomb` allein muss reichen |
| `anachronisms` gegen `testdaten/eigenschaften` | `pruefDevKiste` rot über `[entwicklergegenstand]` | nur `CreativeMode=Dev`, kein Tag `admin`, keine Group `Special Items` — der Fall der `tier0xLoadout` |
| `anachronisms` gegen `testdaten/eigenschaften` | `pruefLadenkasse` rot über `[moderner_werkstoff]` | Klasse bewusst **nicht** in der Stromliste, damit sichtbar ist, welche Regel geurteilt hat |
| `anachronisms` gegen `testdaten/eigenschaften` | `pruefBauplanRohr` rot, `pruefBauplanBogen` **nicht** | die `Unlocks`-Ableitung gilt in beide Richtungen |
| `anachronisms` mit `denylist-tote-regel.txt` | `verbotsregel-trifft-nichts` nennt das Muster | so sah `magazine*` statt `*SkillMagazine` aus |
| `anachronisms` mit `denylist-tote-freigabe.txt` | `freigaberegel-trifft-nichts` nennt das Muster | der gefährlichere Tippfehler: eine Freigabe, die nicht greift, lässt etwas **fallen** |
| `anachronisms` mit `aufschub-pruef.txt` | Exit 1, Kennung als Hinweis statt als Fehler | ein Aufschub bucht um, er verschweigt nicht |
| derselbe Lauf mit `--ohne-aufschub` | Exit 1, Kennung wieder als Fehler | sonst wäre nicht zu sehen, dass der Aufschub nur umbucht |
| `anachronisms` mit `aufschub-ohne-wp.txt` | Exit 2 | ein Aufschub ohne Arbeitspaket ist ein Loch mit guter Presse |
| `purge-patch testdaten/purge --zeigen` | `set` für `pruefFeuerrohrEigen`, `append` für `pruefFeuerrohrGeerbt`, `pruefSelbstbogen` in **keiner** Zeile | die Form entscheiden die Daten; ein `set` auf eine fehlende Eigenschaft trifft nichts und schweigt |
| `purge-patch testdaten/purge` | `wege_uebrig 0` und `gesperrt_und_noch_erreichbar 0` | `pruefFeuerrohrEigen` hat **zwei** Rezepte — eine Zeile, die nur eines trifft, wäre hier rot |
| derselbe Lauf mit `--ohne-entfernen` | Exit 1, `weg-bleibt-offen` **und** `gesperrt-trotz-patch` | der Nachweis, dass beide Nachproben überhaupt etwas prüfen |
| `purge-patch testdaten/purge --zeigen` | gemischte Belohnungsliste wird **gekürzt**, nicht entfernt | wer hier `remove` nimmt, nimmt dem Spieler zwei erlaubte Belohnungen mit — Vanilla hat 256 solche Listen |
| `purge-patch testdaten/purge --zeigen` | Startausrüstung gekürzt, `pruefSelbstbogen=2` behält die Stückzahl | ohne die Eigenschaft startet der Spieler mit leeren Händen, ohne die Stückzahl mit einem Stück statt zwei |
| `purge-patch --vergleiche` gegen einen Ordner ohne die Dateien | Exit 1, `patchdatei-fehlt` | erzeugte Dateien und Denylist können auseinanderlaufen |
| `purge-patch` ohne `--out` und ohne `--trocken` | Exit 2 | Benutzungsfehler |
| `--ohne-regel gibtesnicht` | Exit 2 | Benutzungsfehler, kein Befund |
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
| `anachronisms` gegen Vanilla | **592 verbotene Kennungen** erreichbar: 123 nach Eigenschaft, 441 nach Name, 27 über die `Unlocks`-Ableitung, 1 über die Mod-Ableitung (Stände davor: 138, 254, 298, 335, 356) |

Die Stände sind kein neuer Inhalt im Spiel, sondern das Bild davon, wie weit die Liste
hingesehen hat. 1129 Kennungen sind überhaupt erreichbar; sie teilen sich restlos auf:

| | Zahl |
|---|---|
| verboten | 592 |
| aufgeschoben (mit Arbeitspaket) | 170 — WP7 157, WP4 10, WP5 2, WP8 1 |
| durch Freigabe erlaubt | 270 |
| Bauplan folgt Erlaubtem (`Unlocks`) | 24 |
| Loot-Gruppen (keine Gegenstände) | 73 |
| **ungeprüft** | **0** |

`ungeprueft` war der ehrlichste Wert im Bericht: nicht „harmlos", sondern „niemand hat
hingesehen". Er stand auf 844, dann 800, 763, 557, 537, 512 — und ist seit WP3.1c **0**.
Vier Eigenschaftsregeln (`sprengkoerper`, `robotik`, `moderner_werkstoff` und
`CreativeMode=Dev` in `entwicklergegenstand`) haben 69 davon beantwortet, die beidseitige
`Unlocks`-Ableitung 34 Baupläne, der Rest ist in `denylist.txt` und `aufschub.txt` einzeln
begründet. Nachzulesen in
[WP3-bestandsaufnahme-anachronismen.md](../../docs/rea/findings/WP3-bestandsaufnahme-anachronismen.md).

Dass der Lauf rot ist, ist richtig: Vanilla *ist* voller Anachronismen. `check-all.ps1` bleibt
rot, solange nicht alle Wege weg sind — ein Prüfbefehl, der vor der Arbeit grün ist, prüft
nichts. Grün wird er erst gegen einen `ConfigsDump` **mit** unseren Modlets, und auch dann mit
170 Aufschüben daneben.

### `purge-patch` — die Patches kommen aus derselben Liste

`mod700check purge-patch <quelle> --out <ordner>` erzeugt die XPath-Dateien des Modlets
`700_10_Purge` aus demselben Urteil, das `anachronisms` fällt. Der Grund ist nicht Bequemlichkeit:
592 Kennungen von Hand auf sieben Dateien zu verteilen heißt, dieselbe Liste zweimal zu führen,
und zwei Listen laufen auseinander. Die Prüfung würde den Unterschied nicht sehen, weil sie die
gemergte Config liest und nicht unsere Patch-Dateien.

Stand WP3.2 bis WP3.4 (gegen Vanilla V 3.40): **1780 Patchzeilen** — `items.xml` 437,
`blocks.xml` 106, `recipes.xml` 369, `loot.xml` 467, `traders.xml` 348, `quests.xml` 50,
`entityclasses.xml` 3. Alle Wächterzähler 0: `patches_ohne_treffer`, `wege_uebrig`,
`gesperrt_und_noch_erreichbar`, `remove_auf_definition`, `patchdateien_abweichend`.

Drei Eigenschaften, die nicht selbstverständlich sind:

- **Der XPath kommt aus den Daten.** Für jedes zu entfernende Element baut das Werkzeug den
  Pfad aus der tatsächlichen Elternkette im Quell-XML (`/recipes/recipe[@name='X']`). Ein Schema,
  das ich falsch erinnere, kann so nicht in die Patches geraten.
- **`set` oder `append` entscheidet die Quelle.** Trägt ein Gegenstand `CreativeMode` selbst,
  wird der Wert ersetzt; erbt er es, wird die Eigenschaft angehängt. Ein `set` auf eine
  Eigenschaft, die es nicht gibt, trifft nichts und schweigt — genau die Fehlerart, die in WP3.1
  dreimal zugeschlagen hat.
- **Listen werden gekürzt, nicht entfernt.** Vanilla hat 256 Quest-Belohnungen, deren `id` eine
  Liste ist (`groupQuestFood,groupQuestAmmo,groupQuestSchematics`), und die Startausrüstung ist
  ebenfalls eine. Steht nur Gesperrtes darin, fällt der Eintrag; steht auch Erlaubtes darin, wird
  die Liste gekürzt — mit Stückzahlen, aus `drinkJarBoiledWater=2,foodCanChili` wird
  `drinkJarBoiledWater=2`. Wer hier blind `remove` nimmt, nimmt dem Spieler die erlaubten
  Einträge derselben Liste mit.
- **`check-all.ps1` vergleicht.** Erzeugte und mitgelieferte Dateien laufen auseinander, sobald
  jemand die Denylist ändert und das Erzeugen vergisst. `purge-patch --vergleiche` meldet das als
  `patchdatei-veraltet`; nachgewiesen am 2026-11-07, indem eine Änderung am Kopftext die drei
  Dateien rot machte und die Neuerzeugung sie wieder grün.

**Die Gesamtprobe.** Jede Datei einzeln zu prüfen sagt nicht, ob der Satz *zusammen* alle fünf
Wegarten schließt: eine Kennung, die nur noch in der Startausrüstung steht, wäre in jeder
Einzelprobe grün. `gesperrt_und_noch_erreichbar` wendet darum alle 1780 Zeilen auf Kopien an und
rechnet die Erreichbarkeit auf dem Ergebnis neu — mit demselben `Reachability`, das die Prüfung
benutzt, nicht mit einer zweiten Fassung. Gemessen: **0**, mit `--ohne-entfernen` **592**.

**Ein Nebeneffekt, der benannt gehört:** 217 von 1016 Loot-Gruppen enthalten nach dem Patch
keinen Eintrag mehr. Sie bleiben absichtlich stehen — Behälter und Quest-Belohnungen zeigen auf
ihre Namen, und ein fehlender Name bricht hart. Umgebogen werden sie mit F-05 in WP4. Ob das
Spiel eine leere Gruppe stillschweigend hinnimmt, eine Protokollzeile schreibt oder beim Würfeln
abbricht, **weiß hier niemand** — das ist der erste Punkt, den der Protokolllauf in WP3.6
beantworten muss.

**Was das nicht beweist:** Patches und Prüfung stammen aus demselben Urteil, und die Gesamtprobe
rechnet mit meinem XPath, nicht mit dem XML-Patcher des Spiels. Ihre Übereinstimmung sagt nur,
dass sie zueinander passen. Der Nachweis ist der Weg über das Spiel — Patch, Spielstart,
`ConfigsDump`, `anachronisms` (WP3.6, braucht den Nutzer). Und `CreativeMode="None"` ist **keine**
Sperre für den Spieler: es nimmt den Gegenstand aus dem Kreativmenü, nicht aus dem Spiel.
Unerreichbar wird er allein durch die entfernten Wege.

Was dem Spieler *statt* der gesperrten Startausrüstung gegeben wird, steht nicht im Purge-Modlet,
sondern von Hand in `mod/700_30_Ausruestung/Config/entityclasses.xml` (WP3.4). Das ist die
Grenze: was aus der Denylist folgt, wird erzeugt; was eine Entscheidung ist, wird geschrieben.

## Grenzen

Jede Ausgabe trägt ihre Grenzen selbst mit (`limitations` im JSON). Die wichtigsten:

- **`freigaberegeln_ohne_treffer` kann an der Quelle liegen, nicht an der Regel.** Gegen
  Vanilla `Data/Config` (V 3.40) steht der Zähler auf 0, gegen den vorhandenen `ConfigsDump`
  vom 2026-07-07 auf 1: dort ist `backpack*` nicht erreichbar. Eine Freigabe ohne Treffer ist
  darum erst dann ein Tippfehler, wenn sie **in der aktuellen Quelle** keinen hat. Der
  Hinweis nennt das Muster, damit sich das in einem Blick entscheiden lässt.

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
| `Mod700.Check/AnachronismCheck.cs` | Erreichbarkeitswege: erst Eigenschaft, dann Name |
| `Mod700.Check/Definitions.cs` | items/blocks/item_modifiers laden, `Extends` auflösen (`Tags`, `Class`, `CreativeMode`) |
| `Mod700.Check/PropertyRules.cs` | die neun Eigenschaftsregeln, jede mit Begründung und gemessener Trefferzahl |
| `Mod700.Check/Judgement.cs` | das Urteil an einer Stelle: Freigabe, Eigenschaft, Name, Mod- und `Unlocks`-Ableitung, Aufschub |
| `Mod700.Check/Deferrals.cs` | `aufschub.txt` lesen; jede Zeile muss ein Arbeitspaket nennen |
| `Mod700.Check/UncheckedList.cs` | Befehl `ungeprueft`: die Sichtungsliste, aus demselben Urteil |
| `Mod700.Check/PurgePatch.cs` | Befehl `purge-patch`: erzeugt die XPath-Patches von `700_10_Purge` aus demselben Urteil |
| `aufschub.txt` | Kennungen, die verboten sind, aber erst in einem späteren Paket fallen |
| `Mod700.Check/RecipeCheck.cs` | Rezeptgraph, Sackgassen, Zyklen |
| `denylist.txt` | verbotene Muster; Freigaben nur für Vanilla-Namen, die kein Anachronismus sind (D54–D56) |
| `world-roots.txt` | Wurzeln, die das XML nicht ausdrückt |
| `gegenproben.ps1` | der Nachweis nach Projektregel 5 |
| `check-all.ps1` | der Prüfbefehl des Projekts |
| `testdaten/` | erfundene Prüfdaten, ein sauberer und ein roter Satz |
