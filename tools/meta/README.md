# mod700meta — statischer Metadaten-Leser

Ergänzt REA dort, wo REA an der `Assembly-CSharp.dll` von 7DTD V2.x abbricht. Begründung und
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
Feldzugriffe und geladene Zeichenketten. `--callers` durchläuft **jeden** Methodenkörper der
Assembly und meldet, wer die ausgewählten Methoden aufruft.

Verschachtelte Typen werden mit `/` adressiert: `ModEvents/ModEvent`1`. Der Name muss exakt
passen; was nicht passt, steht in `selection.unmatched_type_names`.

### verify — Soll-Signaturen prüfen (Update-Festigkeit)

```bash
"$EXE" verify "$DLL" --expect tools/meta/expect/f00.tsv
```

Liest Zeilen `Typ<TAB>Member<TAB>Signatur` und endet mit **Exit 1**, sobald eine Soll-Signatur
fehlt oder abweicht. Unterschieden werden `type-missing`, `member-missing` und
`signature-changed`; bei letzterem nennt die Ausgabe die tatsächlich vorhandenen Überladungen.

Das tritt an die Stelle von `tools/rea/discover.sh compare` nach einem Spiel-Update: Soll-Datei
gegen die neue DLL laufen lassen, rot heißt Release blockiert.

Die Signaturen in der Soll-Datei sind wörtlich die Zeilen, die `members` ausgibt — kopieren,
nicht abschreiben.

## Nachweis, dass die Prüfung greift

CLAUDE.md Regel 5 verlangt, dass ein Check einmal nachweislich an einem falschen Eingabewert
scheitert. Erbracht am 2026-11-07 gegen Build Steam 26309840:

| Lauf | Soll | Ergebnis |
|---|---|---|
| grün | `tools/meta/expect/f00.tsv`, 12 Zeilen | `verdict: green`, `failed: 0`, **Exit 0** |
| rot | drei gefälschte Zeilen | `verdict: red`, `failed: 3`, **Exit 1** |

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
- **Zahlenoperanden** (`ldc.i4` und Verwandte) werden nicht erfasst. Konstanten wie die
  Spielversion in `Constants::.cctor` sind damit nicht lesbar.
- Die **Server-/Client-Zuordnung** bleibt ein Indiz und braucht den Dedicated-Test.
- Metadaten-Tokens gelten nur für genau den gemeldeten SHA-256 und die gemeldete MVID.

## Rohdaten

Ausgaben gehören nach `.rea/` (per `.gitignore` ausgeschlossen). Ins Repo kommen nur die
kuratierten Findings unter `docs/rea/findings/` und die Soll-Dateien unter
`tools/meta/expect/`.
