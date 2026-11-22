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

Lauf vom 2026-11-08: **40 Gegenproben, 0 fehlgeschlagen.**

Fünf davon sind jung. Drei gehören zu `vanilla-keys.txt`, der Liste bewusster
Vanilla-Überschreibungen in `Localization.csv` (Vertrag 04 §5, Nachtrag WP4.1). Sie ist eine
**Abschaltung** der Präfix-Prüfung, also wird geprüft, dass sie wirkt, dass sie einen
nachgestellten Grund verträgt — **das war ein echter Fehler, der Leser schnitt den Kommentar
nicht ab** — und dass ein Eintrag ohne zugehörige Zeile genannt wird.

Zwei halten eine Berichtigung an Vertrag 02 §5 fest: der Sprachschlüssel eines Gegenstands
**ist seine Kennung**, und Kennungen heißen `itm700_…`. Mit dem alten Rezept (ein einzelnes
`700_`) war jeder eigene Gegenstand rot. `--prefix` nimmt seit WP4.6 eine Liste; die
Gegenproben zeigen rot mit dem alten und grün mit dem neuen Rezept.

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
| `anachronisms` gegen Vanilla | **593 verbotene Kennungen** erreichbar: 123 nach Eigenschaft, 442 nach Name, 27 über die `Unlocks`-Ableitung, 1 über die Mod-Ableitung (Stände davor: 138, 254, 298, 335, 356, 592) |

Die Stände sind kein neuer Inhalt im Spiel, sondern das Bild davon, wie weit die Liste
hingesehen hat. 1140 Kennungen sind überhaupt erreichbar; sie teilen sich restlos auf:

| | Zahl |
|---|---|
| verboten | 593 |
| aufgeschoben (mit Arbeitspaket) | 160 — WP7 157, WP5 2, WP8 1 |
| durch Freigabe erlaubt | 290 |
| Bauplan folgt Erlaubtem (`Unlocks`) | 24 |
| Loot-Gruppen (keine Gegenstände) | 73 |
| **ungeprüft** | **0** |

**Der sechste Weg (7. November 2026).** Von den 8.535 Erreichbarkeitswegen dieses Laufs sind
**3.108 Block-Abwürfe** in 90 verschiedenen Namen, und die hat vorher niemand gezählt — nicht
weil eine Regel fehlte, sondern weil `Reachability` die Datei nicht ansah: `blocks.xml` trägt
`<drop event="Harvest|Destroy|Fall" name="…"/>`, und das war in `Reachability` kein
Erreichbarkeitsweg. `RecipeCheck` zählte es seit dem ersten Tag als Wurzel — zwei Stellen,
dieselbe Frage, verschiedene Antworten. Gemessen am sechsten Weg blieben **26 gesperrte
Kennungen in 869 Abwurfzeilen** zu haben (`resourceScrapPolymers` 163, `resourceMechanicalParts`
127, `resourceElectricParts` 115): ein zerschlagenes Sofa gab Kunststoff, während der Purge
`gesperrt_und_noch_erreichbar 0` meldete. Beide Stellen lesen jetzt dieselbe Zeile Code, und
`purge-patch` schreibt 41 Abwurf-Entfernungen. Vertrag 04 §3d hat die Einzelheiten — auch die,
dass damit kein **siebter** Weg ausgeschlossen ist.

`ungeprueft` war der ehrlichste Wert im Bericht: nicht „harmlos", sondern „niemand hat
hingesehen". Er stand auf 844, dann 800, 763, 557, 537, 512 — seit WP3.1c **0**, und als der
sechste Weg dazukam, sprang er auf 11 und ist seit zwei neuen Urteilen wieder 0. Der Bericht
nennt diese Kennungen seither **mit Namen**: eine Zahl ohne Namen lässt sich nicht abarbeiten.
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

Stand nach WP4.1 (gegen Vanilla V 3.40): **1818 Patchzeilen** — `items.xml` 438, `blocks.xml`
106 (`CreativeMode`) **+ 41 (Abwürfe)**, `recipes.xml` 367, `loot.xml` 467, `traders.xml` 346,
`quests.xml` 50, `entityclasses.xml` 3. Alle Wächterzähler 0: `patches_ohne_treffer`,
`wege_uebrig`, `gesperrt_und_noch_erreichbar`, `remove_auf_definition`,
`patchdateien_abweichend`. (Stand WP3.4 davor: 1780 Zeilen, **ohne** die Abwürfe.)

`blocks.xml` entsteht seither aus **zwei Teilen** in einer Datei. Das ist keine Kosmetik: der
Patcher ordnet eine Modlet-Datei ihrer Vanilla-Datei über den **Dateinamen** zu, eine
`blocks-abwuerfe.xml` würde nie angewandt. Im Werkzeug bleiben die Teile getrennt, weil jede
Einzelprobe nur ein Element kennt — zusammengelegt könnte `wege_uebrig` nur eines von beiden
prüfen. Beim Bau fiel dabei zweimal genau diese Falle auf: die Gesamtprobe legte ihre Kopien
unter dem Dateinamen ab und warf die erste weg, und `patchzeilen_blocks.xml` stand zweimal im
Bericht, sodass die Summe nicht mehr aufging. Beides behoben, beides in Vertrag 04 §3d.

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

**Die Gesamtprobe.** Jede Datei einzeln zu prüfen sagt nicht, ob der Satz *zusammen* alle
**sechs** Wegarten schließt: eine Kennung, die nur noch in der Startausrüstung steht, wäre in
jeder Einzelprobe grün. `gesperrt_und_noch_erreichbar` wendet darum alle 1818 Zeilen auf Kopien
an und rechnet die Erreichbarkeit auf dem Ergebnis neu — mit demselben `Reachability`, das die
Prüfung benutzt, nicht mit einer zweiten Fassung. Gemessen: **0**, mit `--ohne-entfernen`
**591**.

Dass die Gesamtprobe mit `Reachability` rechnet statt mit einer eigenen Fassung, ist am
7. November zum ersten Mal etwas wert gewesen: der sechste Weg wurde an **einer** Stelle
nachgetragen, und Prüfung, Gesamtprobe und Rezeptgraph wussten es im selben Build.

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

### `kette-pruefen.ps1` — unsere eigenen Rezepte

`recipes` prüft eine **Quelle**, und unsere Modlets stehen in keiner, die ohne Spielstart zu
haben ist. **„`recipes` grün" heißt heute „Vanilla hat keine Sackgasse"** und sagt über unsere
Kette nichts. Das gehört gesagt, weil ein grünes `recipes` sonst wie eine Aussage über unsere
Arbeit aussieht.

`kette-pruefen.ps1` schließt die kleinere Hälfte: es löst **jeden** Verweis unserer
Rezept-Patches auf — Ergebnis, Zutaten, `craft_tool` — gegen Vanillas `items.xml`/`blocks.xml`
und unsere eigenen `items.xml`. Gemessen am 2026-11-08: 8.092 Vanilla-Definitionen, 3 eigene,
**5 Rezepte, 4 werkzeuggebunden, 0 unaufgelöste Verweise.**

Rot vorgeführt an `testdaten/kette-rot.xml`: drei erfundene Namen, darunter `resourceCole`
statt `resourceCoal` — der Fall, der sich beim Durchsehen richtig liest und über den das Spiel
schweigt, weil ein Rezept mit unbekannter Zutat einfach nicht herstellbar ist. Der Lauf meldet
3 rot, Exit 1.

Ohne `SDTD_PATH` (und ohne `-Vanilla`) endet es mit **Exit 2, „NICHT GEPRUEFT"**, und
`check-all.ps1` zählt das als rot. *(Bis zum 2026-11-20 schrieb es „KEIN GRUEN" und ging mit
Exit 0 hinaus — der Prüflauf wurde damit grün, ohne etwas geprüft zu haben. Ebenso zählt
ein `purge-patch`-Vergleich, der mangels Vanilla nicht laufen kann, seither als rot.)* Was es nicht prüft, sagt es in
jeder Ausgabe: Erreichbarkeit von T0 und Zyklen.

**XPaths (seit WP7.1).** Jeder XPath unserer Patch-Dateien wird gegen die Vanilla-Datei
**gleichen Pfads unter `Config/`** gehalten — `Config/XUi_InGame/windows.xml` also gegen
`Data/Config/XUi_InGame/windows.xml`. *(Bis zum 2026-11-20 zählte nur der Dateiname im
obersten Ordner; Patches in Unterordnern wurden still übersprungen.)* Eine XML-Patch-Datei
ohne Vanilla-Gegenstück ist **rot**, ein mit `-Patches` genannter Ordner Exit 2. Gemessen am
2026-11-22: 20 Patch-Dateien, 427 XPaths (414 in Vanilla, 13 auf eigene Knoten), 0
unaufgelöst. Grenze: geprüft wird gegen Vanilla, nicht gegen den gepatchten Stand.

**Bedingte Blöcke (seit 2026-11-22, WP8.7).** Ein `<conditional>` wird von innen gelesen:
jeder Zweig (`<if cond="…">`, `<else>`) wird geprüft, als wäre er der aktive, auch ein Block
im Block. Rot sind ein falsch gebauter Block (`<elseif>`, `<if>` ohne `cond`, `evaluator`,
ein Zweig hinter `<else>`, kein `<if>`, keine Operation) und eine falsche Bedingung
(unbekannte Funktion, nicht lesbarer Ausdruck, **`xpath(…)` allein** — das Spiel verlangt
einen Wahrheitswert und `xpath` liefert keinen —, ein XPath, der in Vanilla nichts
trifft). Ausgabe: `bedingte Bloecke: N (Zweige: N, XPaths darin: N, xpath-Bedingungen: N)`
und `in Bedingungen genannte Mods: …`; heute 9 Blöcke, keine genannte Mod. Ob eine Bedingung
im Spiel wahr wird, prüft das Skript nicht.

**Die Bedingung liest NCalc (seit dem zweiten Review am 2026-11-22).** Die eigene Zerlegung
des Ausdrucks hatte in zwei Reviews hintereinander Lücken; jetzt liest ihn die Bibliothek,
die ihn auch im Spiel liest: `NCalc.dll` aus `<SDTD_PATH>\7DaysToDie_Data\Managed\` (oder
`-NCalc <Pfad>`), nur geladen, nie im Repo. Rot ist, was NCalc nicht lesen kann, was beim
Auswerten eine Ausnahme wirft oder keinen Wahrheitswert liefert — in irgendeiner Belegung
der genannten Mods. `xpath(…)` läuft gegen Vanilla wie im Spiel, und **jeder XPath einer
Bedingung muss in Vanilla etwas treffen**. Hat eine Patch-Datei einen bedingten Block und
fehlt die Bibliothek, ist der Lauf **nicht geprüft** (Exit 2). Ausgabe:
`Bedingungen mit NCalc gelesen: N (ohne genannte Mods wahr: N, falsch: N, nicht
ausgewertet: N)` — heute 9, alle wahr. Die Gegenproben zu bedingten Blöcken brauchen damit
die Spielinstallation.

Seit dem dritten Review (2026-11-22): die **Zahl der Argumente** wird für alle elf Funktionen
des Spiels geprüft, auch in Bedingungen, die sonst nur das laufende Spiel auswerten kann
(`event()` ist rot); die Art der Argumente nicht (`event(1)` bleibt grün). Mehr als acht
genannte Mods sind immer „nicht geprüft". Ein XPath in einer Bedingung muss in Vanilla
treffen — **ohne** die Ausnahme für eigene Kennungen, die bei den XPaths der Patches selbst
weiter gilt. Fehlt die Bibliothek, ist schon das erste `<conditional>` „nicht geprüft".

Seit dem vierten Review (2026-11-22): **der Aufbau eines XML-Knotens wird nur über Methoden
gelesen** (`get_NodeType()`, `get_ChildNodes()`, `get_InnerText()` …), nie über Eigenschaften.
PowerShells XML-Adapter legt Attribute und Kindelemente als Eigenschaften über den Knoten;
`<conditional NodeType="skip">` wurde sonst übersprungen wie ein Kommentar, und der Lauf war
grün. Wer das Skript erweitert: `$knoten.NodeType`, `.ChildNodes`, `.InnerText`, `.Name`,
`.ParentNode` sind dort Fallen. Mehr als acht genannte Mods sind Exit 2, auch wenn dieselbe
Bedingung einen zweiten Fehler trägt.

**Was eine Patch-Datei ist (seit 2026-11-21).** Der Wurzelknoten heißt `<config>`, jedes Kind
ist eine bekannte Operation und trägt ein `xpath` — sonst **rot**. *(Vorher zählte eine Datei
mit falschem Wurzelknoten oder einem Tippfehler wie `<sett>` als „geprüft, 0 XPaths, GREEN".)*
`<include>` bleibt ungeprüft, wird aber gezählt:
`nicht von innen geprueft (include): N` — heute 0 *(bis zum 2026-11-22 stand `<conditional>`
in derselben Zeile)*. Ein `SDTD_PATH`, der kein
gültiger Pfad ist (wörtliche Anführungszeichen), ist Exit 2 statt einer Ausnahme.

**Lesen ist nicht Zerlegen (seit dem fünften Review, 2026-11-21).** Jede XML-Datei geht durch
eine Funktion (`Read-XmlDatei`). Eine eigene Datei, die kein gültiges XML ist, ist **eine**
rote Zeile mit Pfad, Zeile und Stelle (Exit 1) — gleich, ob sie als Rezept-, Gegenstands-,
Block- oder Patch-Datei gebraucht wird. Eine Datei, die sich nicht **lesen** lässt, und eine
kaputte **Vanilla**-Datei sind „nicht geprüft" (Exit 2). *(Seit dem sechsten Review am selben
Tag gilt das auch für Vanillas `items.xml` und `blocks.xml`, deren Kennungen als Text gelesen
werden; das Skript hat nur noch **eine** Stelle, die eine Datei öffnet. Die vier
Gegenproben mit einer gesperrten Datei prüfen zuerst, ob die Sperre auf dem Dateisystem
greift — wo nicht, sind sie rot mit diesem Grund.)* Die Kennungen werden **Zeile für Zeile**
aus dem Text gelesen (siebtes Review: ein Muster über den ganzen Text ließ einen Kommentar
die nächste Definition verschlucken). Grenze: eine Definition, die ganz in einer
Kommentarzeile steht, zählt als definiert.

### `glossar-pruefen.ps1` — Glossar gegen Sprachdatei (WP8.5, D75)

[`docs/glossar.md`](../../docs/glossar.md) ist die Begriffsquelle (F-12), und dieses Skript
liest **genau diese Datei** — es gibt keine zweite Liste, die danebenlaufen könnte. Zwei
Tabellenformen zählen, erkannt an der Kopfzeile:

- **Festbegriffe** (`| Kennung | Deutsch | Englisch | Vanilla | Quelle |`): die Zeile unserer
  `Localization.csv` mit diesem Schlüssel muss genau diesen deutschen und englischen Text
  tragen.
- **Verbotene Begriffe** (`| Verboten | Sprache | Stattdessen | Quelle |`): ein regulärer
  Ausdruck je Zeile, gesucht in der deutschen und/oder englischen Spalte **jeder** unserer
  Zeilen.

Exit **0** grün, **1** Befunde, **2** nicht prüfbar (Datei fehlt, keine Tabelle gelesen, Muster
kaputt). Exit 2 zählt in `check-all.ps1` als rot. Gemessen am 2026-11-20: 50 Festbegriffe mit
Kennung, 13 ohne, 79 Muster, 617 Zeilen, 0 Abweichungen, 0 Treffer (nach der dritten Scheibe
von WP8.5 am selben Tag: 51, 13, 84 Muster, 710 Zeilen, 0 und 0; nach der vierten am
2026-11-21: 747 Zeilen, 0 und 0; nach der fünften am selben Tag: 836 und dann 872
Zeilen, 0 und 0; nach WP8.6 und dem Review dazu: 51 Festbegriffe mit Kennung, 88 Muster, 1 Alleinname, 887 Zeilen, 0 und 0).
Rot vorgeführt an
`testdaten/glossar/`: fünfzehn Gegenproben (seit dem 2026-11-21 neunzehn weitere: acht für den Alleinnamen, elf nach dem zweiten Review — Pflicht-Alleinname, Schlüssel und Texte zeichengenau), darunter ein leeres Glossar (Exit 2, nicht grün),
ein Begriff, der nur in **einer** Sprache verboten ist, und eine Kopfzeile mit Tippfehler.

**Jede Tabelle des Glossars muss eine der drei Formen haben** (Festbegriffe, Verbote, seit dem 2026-11-21 Alleinnamen: ein Name, der nur unter seinem einen Schlüssel stehen darf — der Mod-Name; gegen das echte Glossar ist die Zeile `700_modName` Pflicht, Parameter `-PflichtAlleinname`). Eine unbekannte Kopfzeile ist
Exit 2 — sonst schaltet ein Tippfehler („Sprachen") eine ganze Verbots-Tabelle still ab.
Dasselbe gilt seit dem 2026-11-21 für eine **kaputte Trennzeile**: eine Zeile außerhalb jeder
Tabelle, die (Code-Spannen abgezogen) zwei oder mehr `|` trägt, ist Exit 2.
Erkannt wird eine Tabelle an ihrer **Trennzeile**, mit oder ohne Randstriche (seit dem
2026-11-20; vorher war eine Tabelle ohne führendes `|` Fließtext). Eine Trennzeile ohne
Kopfzeile davor ist Exit 2.

**Es liest nur, was wir schreiben.** Vanilla-Zeilen, die wir nicht überschreiben, sieht es
nicht — auch wenn der Spieler sie liest.

### `sprachverweise-pruefen.ps1` — XML gegen Sprachdatei (WP8.8)

`mod700check localization` prüft die **Form** der Sprachdatei. Dieses Skript prüft, was
zwischen XML und Sprachdatei liegt, in beide Richtungen (Vertrag 04, „Nachtrag WP8.8" und
„Nachtrag Review zu WP8.8"):

- **Vorwärts:** jeder Schlüssel, den eine unserer XML-Dateien nennt (`…_key`-Attribute,
  `DescriptionKey`, die Namen eigener Gegenstände und Blöcke, die Beschreibung eigener
  Gegenstände), hat eine Zeile — bei uns oder in Vanilla.
- **Rückwärts:** jede Zeile, die Vanilla nicht hat, und jede Zeile `<Name>Desc` eines
  Gegenstands oder Blocks wird von etwas gelesen. Dazu rechnet das Skript je Gegenstand und
  Block den Schlüssel aus, den das Spiel wirklich liest: eigene Eigenschaft `DescriptionKey`,
  sonst geerbt über `Extends`, sonst `<Name>Desc`
  ([Finding](../../docs/rea/findings/WP8-beschreibungsschluessel-wird-vererbt.md)).

**Warum es das gibt:** sechs Beschreibungen der Bruchstücke aus dem Zerlegen standen seit WP5
in der Sprachdatei, und das Spiel las statt ihrer den geerbten Schlüssel `gunPartsGroupDesc`.
`localization` war grün.

Exit **0** grün, **1** Befunde, **2** nicht prüfbar. Braucht Vanillas `Localization.csv`,
`items.xml` und `blocks.xml` (`SDTD_PATH` oder `-Vanilla`). Gemessen am 2026-11-22: 27
Patch-Dateien, 7 davon angewandt, 729 Operationen angewandt und 0 ohne Treffer, 72 genannte
Schlüssel (alle in unserer Datei), 132 Zeilen rückwärts geprüft, 0 nicht gelesen; gegen den
Stand vor dem Fix 6 rot. Rot vorgeführt an `testdaten/sprache/`: 34 Gegenproben, dazu 35
Verfälschungen des Skripts über vier Reviews — 34 machen mindestens eine Gegenprobe rot,
eine (nur das Netz für unerwartete Fehler fehlt) keine; warum, steht im Vertrag.

**Es wendet die Patches an, statt sie zu erkennen** (seit dem Review zu WP8.8, Vertrag 04
„Nachtrag Review zu WP8.8"). Jede Patch-Datei, die `items.xml` oder `blocks.xml` heißt, wird
in der Reihenfolge der Dateien auf Vanillas Datei angewandt, mit allen neun Operationen des
Spiels; der Beschreibungsschlüssel wird am Ergebnis gerechnet. **Was sich nicht anwenden
lässt, ist rot:** ein XPath, der nichts trifft oder sich nicht auswerten lässt, ein bedingter
Block oder ein unbekanntes Element in einer dieser Dateien, ein Gegenstand, der danach
zwei Eigenschaften `DescriptionKey` trägt, und eine Operation, deren Treffer eine Knotenart
hat, die das Skript für sie nicht rechnet — allen voran `<remove>` auf ein Attribut, das
auch das Spiel ablehnt („Nachtrag zweites Review zu WP8.8"). In allen anderen Dateien zählt
weiter, was die Datei nennt.

**Eine Zeile `<Name>Desc` wird auch geprüft, wenn es `<Name>` nur in Vanilla gibt.** Entfernt
oder benennt ein Patch den Gegenstand um und liest nichts im gepatchten Stand den Schlüssel,
ist die Zeile rot.

**Blöcke haben einen dritten Schritt.** Hat der Schlüssel eines Blocks keine Zeile, liest das
Spiel die Gruppenbeschreibung (`defaultDescriptionKey` am Wurzelknoten von `blocks.xml`). Das
Skript zählt sie als gelesen, sobald ein Block so auf sie zurückfällt — am echten Stand tun
das 3 246 Blöcke —, und verlangt eine Zeile, wenn wir sie setzen („Nachtrag drittes Review
zu WP8.8"). Leert oder entfernt ein Patch sie, ist das rot („Nachtrag viertes Review zu
WP8.8").

**Es ist kein zweiter Patcher des Spiels.** `csv` und `append`/`prepend` auf ein Attribut
sind nachgebaut, nicht am Spiel gemessen; die Reihenfolge ist die der Dateinamen.

**Es sieht nur XML.** Schlüssel, die der Spielcode zusammensetzt, kennt es nicht; und ob eine
überschriebene Vanilla-Zeile, die weder Gegenstand noch Block beschreibt, noch gelesen wird,
prüft niemand.

Die neun Patch-Operationen stehen seit dem 2026-11-22 in `patch-operationen.ps1`; dieses
Skript und `vertraeglichkeit-pruefen.ps1` lesen die Datei ein. Fehlt sie, endet jedes der
beiden mit Exit 2.

### `vertraeglichkeit-pruefen.ps1` — unsere Modlets gegen eine fremde Mod (WP8.9)

**Läuft nicht in `check-all.ps1`:** die Eingabe liegt außerhalb des Repositorys, und ein
Befund hier ist eine Frage an die Testmatrix, kein Fehler in der Mod (Vertrag 04, „Nachtrag
WP8.9", Abnahme offen). Die Gegenproben laufen in `gegenproben.ps1` wie alle anderen.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check/vertraeglichkeit-pruefen.ps1
```

Ohne Parameter: unsere Modlets aus `mod\`, jede fremde Mod unmittelbar unter
`GameRefs\ui-mods\` (ein Ordner mit `ModInfo.xml` und `Config\`), Vanilla aus `SDTD_PATH`.
Mit `-Fremd`, `-Unsere`, `-Vanilla`, `-NCalc` lässt sich jede Seite angeben. Exit **0** grün,
**1** Befunde, **2** nicht prüfbar.

Je fremder Mod und je XML-Datei, die beide Seiten patchen, rechnet es vier Stände aus der
unveränderten Vanilla-Datei — wir allein, die fremde Mod allein, wir dann sie, sie dann wir —
und meldet:

- **Ziel verloren:** eine Operation trifft allein etwas und in der Kombination nichts.
- **Zweig wechselt:** eine Bedingung fällt in der Kombination anders aus.
- **Wirkung verändert:** was die zuerst geladene Seite geschrieben hat, ist nach der zweiten
  entfernt oder anders.
- **Nicht gerechnet:** eine Stelle, an der der Stand danach geraten wäre.
- **Gemeinsamer Sprachschlüssel.**

Beide Reihenfolgen laufen; welche erwartet ist, ergeben die Ordnernamen. Operationen der
fremden Mod, die schon allein nichts treffen, und Dateien ohne Vanilla-Gegenstück werden
genannt, sind aber kein Befund.

Gemessen am 2026-11-22 gegen die zwei Referenz-Mods aus D86 (10 Sekunden, Exit 1,
11 Befunde): AGF-1HUDPlus 3 „nicht gerechnet"; EchoHybridUI 6 „Wirkung verändert" (drei
Stil-Einträge, in beiden Reihenfolgen), 1 „nicht gerechnet", 1 gemeinsamer Sprachschlüssel.
**Kein verlorenes Ziel, kein gewechselter Zweig.** Rot vorgeführt an
`testdaten/vertraeglich/`: 36 Gegenproben, dazu 42 Verfälschungen des Skripts und der
gemeinsamen Datei — jede macht mindestens eine Gegenprobe rot. (Fünf der Gegenproben und
vier der Verfälschungen stammen aus dem Review vom selben Tag: die `NCalc.dll` wird für
jeden bedingten Block verlangt, `mod_loaded` und `xpath` bekommen genau ein Argument, und
eine nicht gerechnete Stelle zählt je Datei — Vertrag 04, „Nachtrag Review zu WP8.9".)

**Es ersetzt keinen Lauf.** Es sieht nur XML (keine DLL der fremden Mod), nur dieselbe Datei
(kein Stil, keine Vorlage aus einer anderen), nichts am Bildschirm; `game_version()` rechnet
es nicht, Operationsnamen vergleicht es Zeichen für Zeichen. Fremde Dateien sind Daten: XML
ohne DTD, nichts wird ausgeführt, nichts ins Repository geschrieben.

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
| `sprachverweise-pruefen.ps1` | genannte Sprachschlüssel haben eine Zeile, geschriebene Zeilen werden gelesen (WP8.8) |
| `patch-operationen.ps1` | die neun Patch-Operationen, eingelesen von den zwei Skripten darüber und darunter |
| `vertraeglichkeit-pruefen.ps1` | unsere Modlets gegen eine fremde Mod, vier Stände je gemeinsamer Datei (WP8.9); nicht in `check-all.ps1` |
| `gegenproben.ps1` | der Nachweis nach Projektregel 5 |
| `check-all.ps1` | der Prüfbefehl des Projekts |
| `testdaten/` | erfundene Prüfdaten, ein sauberer und ein roter Satz |
