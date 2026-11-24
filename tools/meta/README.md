# mod700meta — statischer Metadaten-Leser

Ergänzt REA dort, wo REA an der `Assembly-CSharp.dll` von 7DTD V 3.40 abbricht. Begründung und
Zahlen: [docs/rea/findings/00-rea-grenzen.md](../../docs/rea/findings/00-rea-grenzen.md).
Entscheidung: **D51** in [docs/GDD.md](../../docs/GDD.md).

## Was es tut — und was nicht

Es liest ausschließlich Metadaten über `System.Reflection.Metadata` und läuft die IL-Bytes
nach Aufruf-, Feldzugriff- und `ldstr`-Tokens ab. Die Assembly wird **nicht geladen, nicht
ausgeführt und nicht dekompiliert**. Kein C#-Quelltext wird rekonstruiert. Damit ist die
Haltung dieselbe wie bei REA und deckt sich mit Spec 01, Abschnitt 6.

Jede Ausgabe nennt SHA-256 und MVID des Artefakts, damit ein Befund an genau einen Build
gebunden bleibt.

## Bauen

```bash
dotnet build -c Release tools/meta/Mod700.Meta/Mod700.Meta.csproj
```

Ergebnis: `tools/meta/Mod700.Meta/bin/Release/net10.0/mod700meta.exe` (net10.0, keine
NuGet-Abhängigkeiten — `System.Reflection.Metadata` ist im Framework enthalten).

## Befehle

```bash
EXE=tools/meta/Mod700.Meta/bin/Release/net10.0/mod700meta.exe
DLL="$SDTD_PATH/7DaysToDie_Data/Managed/Assembly-CSharp.dll"
```

### types — Typ finden, wenn der Name nur geraten ist

```bash
"$EXE" types "$DLL" --contains Turret --max 50
```

Liefert je Typ: `full_name`, Token, Attribute, Basistyp, Schnittstellen und die Anzahl der
Methoden, Felder und Eigenschaften. `--contains` sucht ohne Rücksicht auf Groß- und
Kleinschreibung. Das ist der Ersatz für das Raten aus `hook-hypothesen.md`.

### members — Signaturen, Aufrufe, Aufrufer

```bash
"$EXE" members "$DLL" --type IModApi --type 'ModEvents/ModEventAbs`1' --callers
```

Je Methode: kanonische Signatur, Token, Attribute, Rückgabe, Parameter, ausgehende Aufrufe,
Feldzugriffe und geladene Zeichenketten. Je Feld zusätzlich `constant_value` aus der
Constant-Tabelle — damit kommen auch die **Zahlenwerte von Enum-Mitgliedern** mit.

`--callers` durchläuft **jeden** Methodenkörper der Assembly und meldet, wer die ausgewählten
Methoden aufruft.

`--il` gibt je Methode eine knappe Spur aus: nur Zahlenkonstanten, Aufrufe und
Feldschreibzugriffe, in Befehlsreihenfolge. Damit lassen sich Konstanten ablesen, die einem
Aufruf als Argumente vorausgehen:

```
5: ldc.i4.1   1
6: ldc.i4.3   3
7: ldc.i4.s  40
8: ldc.i4.s  10
9: newobj VersionInformation::.ctor
10: stsfld Constants::cVersionInformation
```

Verschachtelte Typen werden mit `/` adressiert: `ModEvents/ModEvent`1`. Der Name muss exakt
passen; was nicht passt, steht in `selection.unmatched_type_names`.

### verify — Soll-Signaturen prüfen (Update-Festigkeit)

```bash
"$EXE" verify "$DLL" --expect tools/meta/expect/f00.tsv
```

Liest Zeilen `Typ<TAB>Member<TAB>Signatur` und endet mit **Exit 1**, sobald eine Soll-Signatur
fehlt oder abweicht. Unterschieden werden `type-missing`, `member-missing` und
`signature-changed`; bei letzterem nennt die Ausgabe die tatsächlich vorhandenen Überladungen.
Dazu `member-mismatch` (seit 2026-11-23, Plan-0002 WP9.7): Typ- und Member-Spalte müssen in der
Signatur als `Typ::Member(` stehen. Vorher entschied allein die Signatur, und eine Zeile mit
vertipptem Member lief grün durch — gefunden mit der Gegenprobe, die WP9.7 verlangt.

**Gegenprobe (Projektregel 5), 2026-11-23, an `expect/wp85.tsv`:** je eine absichtlich falsche
Fassung — Signatur geändert (`signature-changed`, Exit 1), Member-Spalte passt nicht
(`member-mismatch`, Exit 1), Typ fehlt (`type-missing`, Exit 1), Member fehlt (`member-missing`,
Exit 1). Die echten Soll-Dateien: 6 Dateien, 64 Zeilen, Exit 0.

**Felder (seit 2026-11-23, Plan-0002 WP9.9).** Vorher prüfte `verify` nur Methoden — die Ereignisse
der Mod-API (`ModEvents::GameUpdate`, `PlayerSpawnedInWorld`, `GameStartDone`, `PlayerLogin`) sind
aber **Felder**, ihr Verschwinden fiele nicht auf. Eine Feldzeile hat keine Klammern:
`[static ]Typ Deklarierer::Name`; `members` gibt sie je Feld als `signature` aus.
`member-mismatch` gilt für Felder, wenn die Zeile nicht auf ` Typ::Member` endet.
**Gegenprobe an `expect/v06-kern.tsv`:** Feldtyp geändert (`signature-changed`), `static` fehlt
(`signature-changed`), Feld fehlt (`member-missing`), Spalte vertippt (`member-mismatch`) — je Exit 1;
die drei Methoden-Gegenproben aus WP9.3–9.5 weiter Exit 1. Die echten Soll-Dateien: **12 Dateien,
114 Zeilen, Exit 0** (davon 4 Feldzeilen).

**Generische Methoden (Review 34, 2026-11-24).** `members` schreibt sie als ``Typ::Name`1(…)``;
`member-mismatch` verlangte aber `Typ::Member(` und meldete eine richtige Zeile darum als
Abweichung. Seither gilt auch ``Typ::Member`n(``. **Gegenprobe** an
``!!0 XUiController::GetChildByType`1()`` (V 3.40 b10): vorher Exit 1 (`member-mismatch`),
jetzt Exit 0; dieselbe Zeile mit vertippter Member-Spalte (`GetChildByTyp`) vorher und jetzt
Exit 1. Die echten Soll-Dateien am 2026-11-24: **14 Dateien, Exit 0** (13 gegen
`Assembly-CSharp.dll`, `v06-harmony.tsv` gegen `0Harmony.dll`).

Das tritt an die Stelle von `tools/rea/discover.sh compare` nach einem Spiel-Update: Soll-Datei
gegen die neue DLL laufen lassen, rot heißt Release blockiert.

**Alle auf einmal, im Prüfbefehl (seit Review 35, 2026-11-24).** `tools/meta/verify-alle.ps1` prüft
jede `expect/*.tsv` gegen die DLL aus ihrer Zeile `# Aufruf:` (`"<Assembly-CSharp.dll>"` oder
`"<SDTD_PATH>/…"`); `check-all.ps1` führt es als eigene Prüfung. Exit 0 grün, 1 Abweichung, 2 nicht
prüfbar (kein Spielpfad, DLL fehlt, Datei ohne `# Aufruf:` oder ohne Datenzeile). Eine neue Soll-Datei
braucht darum diese Zeile. Am 2026-11-24: 14 Dateien, 138 Zeilen, Exit 0. Gegenproben und Regeln: Vertrag 04, Nachtrag
Review 34/35.

Die Signaturen in der Soll-Datei sind wörtlich die Zeilen, die `members` ausgibt — kopieren,
nicht abschreiben.

### find-string — wo wird ein Konfigurationsschlüssel verarbeitet?

```bash
"$EXE" find-string "$DLL" --text "currency_item" --max 20
```

Sucht Zeichenketten, die irgendeine Methode per `ldstr` lädt, und nennt die Methode dazu. Das ist
der Befehl, der die Frage „ist das per XML änderbar oder im Code verdrahtet?" beantwortet: taucht
ein XML-Attributname nur im Parser auf, ist er Daten; taucht ein Wert (`casinoCoin`,
`pine_forest`) in der Spiellogik auf, ist er verdrahtet. Mehrere `--text` pro Lauf sind erlaubt.

So sind die Befunde zu Prio 2–10 entstanden
([02-10-schnittstellen-kurzcheck.md](../../docs/rea/findings/02-10-schnittstellen-kurzcheck.md)).

## Nachweis, dass die Prüfung greift

CLAUDE.md Regel 5 verlangt, dass ein Check einmal nachweislich an einem falschen Eingabewert
scheitert. Erbracht am 2026-11-07 gegen Build Steam 26309840:

| Lauf | Soll | Ergebnis |
|---|---|---|
| grün | `tools/meta/expect/f00.tsv`, 12 Zeilen | `verdict: green`, `failed: 0`, **Exit 0** |
| rot | drei gefälschte Zeilen | `verdict: red`, `failed: 3`, **Exit 1** |

Für `find-string` dasselbe, damit ein „0 Treffer" als Aussage zählt und nicht als Panne:

| Lauf | Eingabe | Ergebnis |
|---|---|---|
| Treffer | `"No ModAPI found in mod DLLs"` (wörtlich aus dem Modlader) | 1 Treffer, `Mod::InitModCode` |
| kein Treffer | `"zzz_dieseZeichenketteGibtEsNicht_700"` | 0 Treffer |

Erst damit ist belegt, dass Sätze wie „`casinoCoin` steht an keiner Stelle im Code" etwas heißen.

Die drei Fehlerarten wurden dabei einzeln getroffen:

```
signature-changed: void IModApi::InitMod(Mod, bool)
    -> Signatur abweichend; vorhanden: void IModApi::InitMod(Mod)
member-missing:    void IModApi::InitModulXY(Mod)
    -> kein Member namens InitModulXY in IModApi
type-missing:      void GibtEsNichtKlasse::Foo()
    -> Typ existiert in diesem Build nicht
```

## Grenzen

- Aufrufer über **Reflection**, **Unity-Messages** (`Update`, `Awake`) und **Delegaten** erscheinen
  nicht in der Aufrufer-Suche. Solche Pfade weiter per Ingame-Protokoll gegenprüfen
  (`interface-discovery.md`, Abschnitt 4).
- Die Spur aus `--il` ist **keine Datenflussanalyse**. Sie zeigt die Reihenfolge der Befehle;
  dass die Konstanten direkt davor die Argumente des Aufrufs sind, muss man selbst prüfen
  (Anzahl der Parameter gegen Anzahl der Konstanten, keine Verzweigung dazwischen).
  Gleitkommakonstanten (`ldc.r4`/`ldc.r8`) werden noch nicht erfasst.
- Die **Server-/Client-Zuordnung** bleibt ein Indiz und braucht den Dedicated-Test.
- Metadaten-Tokens gelten nur für genau den gemeldeten SHA-256 und die gemeldete MVID.

## Rohdaten

Ausgaben gehören nach `.rea/` (per `.gitignore` ausgeschlossen). Ins Repo kommen nur die
kuratierten Findings unter `docs/rea/findings/` und die Soll-Dateien unter
`tools/meta/expect/`.
