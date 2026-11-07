# Schnittstellen-Analyse mit REA

**Ziel:** Jede Stelle, an der die Mod per Harmony in das Spiel eingreift, wird vorher **belegt**
statt geraten. Belegt heißt: Typ, Methode, Signatur und Aufrufer bzw. Aufgerufene stammen aus
der echten `Assembly-CSharp.dll` des Ziel-Builds, inklusive Build-Hash.

**Werkzeug:** [REA — Reverse Engineer Anything](https://github.com/morluto/rea) (`rea-agents`
auf npm). Für dieses Projekt relevant sind die **Managed-Code-Tools**, denn 7DTD ist Unity/Mono:

| REA-Tool (MCP) | CLI | Wofür im Projekt |
|---|---|---|
| `inspect_managed_artifact` | `rea inspect-managed-artifact` | Assembly identifizieren: Version, MVID, Referenzen, Mono vs. IL2CPP |
| `inspect_managed_members` | `rea inspect-managed-members --type …` | Typen, Signaturen, CIL, **Call-Edges**, Feldzugriffe; findet Patch-Ziele |
| `compare_managed_members` | `rea compare-managed-members` | Diff alt/neu nach Spiel-Updates; prüft Update-Festigkeit |
| `project_managed_application_graph` | `rea project-managed-application-graph` | Aufruf-Graph rund um ein System (z. B. Schadenspfad) |

REA arbeitet **statisch** und lädt bzw. führt nichts aus.

## 0. Rahmenbedingungen

- **Läuft lokal bei dir**, nicht in der Cloud: Die Spieldateien liegen nur in deiner
  Steam-Installation und dürfen nicht hochgeladen oder committet werden.
- **Rohdaten bleiben lokal** (`.rea/`, per `.gitignore` ausgeschlossen): REA-JSON enthält
  dekodierte Spiel-Metadaten und CIL.
- **Ins Repo kommen nur kuratierte Findings** (`docs/rea/findings/*.md`): Typname, Methode,
  Signatur, Build, kurze Beschreibung in eigenen Worten, *kein* dekompilierter Code.
- Voraussetzung: Node.js 22.23.4+ / 24.22.1+ / 26.12.1+ (siehe REA-README).
- Optional: `npx rea-agents setup` registriert REA als MCP-Server in Claude Code. Dann kann
  eine lokale Claude-Code-Session die Analyse direkt im Dialog führen.

## 1. Baseline erstellen (einmal pro Spiel-Build)

```bash
export SDTD_PATH="/pfad/zu/steamapps/common/7 Days To Die"
tools/rea/discover.sh baseline
```

Ergebnis → `docs/rea/findings/00-build-baseline.md` von Hand ausfüllen:
- Spielversion (Hauptmenü bzw. Log), SHA-256 und MVID von `Assembly-CSharp.dll`
- Runtime bestätigt: Mono/CIL (wenn REA keine CLI-Metadaten findet → IL2CPP → Plan B: `il2cpp-metadata`-Tools)
- Target-Framework (bestimmt das TargetFramework unseres C#-Projekts)
- Harmony-Version, falls vom Spiel mitgeliefert (`0Harmony.dll`)

## 2. Feature-Schnittstellen untersuchen

Pro Feature mit `REA = ja`:

1. Hypothesen aus [`hook-hypothesen.md`](hook-hypothesen.md) nehmen.
2. Typen inspizieren:
   ```bash
   tools/rea/discover.sh types F-08 BlockLight TileEntity WorldBlockTicker
   ```
   Fehlt ein Typ, meldet REA ihn als `unmatched`. Dann den Typ über Namensmuster bzw.
   Referenzen suchen (Typ-Inventar: `tools/rea/discover.sh inventory`).
3. In den Ergebnissen gezielt suchen:
   - **Signatur** der Kandidatenmethode (Parameter, Rückgabe, virtual/override)
   - **Call-Edges:** Wer ruft sie auf? Läuft sie auf Server, Client oder beiden?
     Hinweise darauf geben Aufrufer wie `isServer`- oder `IsRemote`-Checks oder `NetPackage`-Klassen.
   - **Feldzugriffe:** Welche Zustände liest bzw. schreibt sie? (z. B. Schaden, Stamina, Buffs)
4. Finding schreiben: `docs/rea/findings/F-xx-<thema>.md` nach Vorlage unten.
5. Patch-Ziel ins [Patch-Manifest](findings/patch-manifest.md) eintragen.

### Arbeiten mit Claude Code + REA-MCP (empfohlen)

Lokal in diesem Repo, mit eingerichtetem REA-MCP, etwa so:

> „Untersuche mit REA in `$SDTD_PATH/7DaysToDie_Data/Managed/Assembly-CSharp.dll`, wo
> Nahkampfschaden auf ein `EntityAlive` angewendet wird. Gib Signatur, Aufrufer und die
> Server-/Client-Zuordnung mit Evidenz zurück und schreib das Finding nach
> `docs/rea/findings/F-02-schadenspfad.md`, ohne dekompilierten Code.“

Für große Typen REA mit `detail: "summary"` aufrufen und dann paginieren (siehe REA
`docs/managed-code-analysis.md`), sonst kommen Megabytes zurück.

## 3. Finding-Vorlage

```markdown
# F-xx — <Thema>

| Build | Assembly SHA-256 | MVID | Datum |
|---|---|---|---|

## Frage
Was wollten wir wissen?

## Ergebnis
| Typ | Member | Signatur | Netz (S/C/S+C) | Evidenz (REA-Tool + Auswahl) |
|---|---|---|---|---|

## Aufrufer / Kontext
Kurz in eigenen Worten.

## Patch-Empfehlung
Prefix/Postfix/Transpiler, Begründung, Risiken (andere Mods, Performance).

## Offene Punkte / Limitierungen
Was REA statisch nicht zeigen kann (z. B. Laufzeitwerte, Unity-Messages wie Update()).
```

## 4. Grenzen der statischen Analyse

- Unity-Messages (`Update`, `Awake` …) und Reflection-Aufrufe tauchen nicht als normale
  Call-Edges auf. Solche Pfade über Ingame-Logging (Harmony-Postfix mit Log) **gegenprüfen**.
- Server/Client-Zuordnung ist aus statischen Daten nur ein Indiz. Bestätigung immer im
  Dedicated-Server-Test (F-00-Smoke).
- Eine REA-Prüfung zählt erst als Nachweis, wenn sie den Fehler auch finden könnte: Den
  Patch-Check (Abschnitt 5) einmal bewusst mit einer falschen Signatur laufen lassen, damit
  er nachweislich rot wird.

## 5. Update-Prozess (nach jedem Spiel-Patch)

```bash
tools/rea/discover.sh compare "/alt/Assembly-CSharp.dll" "$SDTD_PATH/7DaysToDie_Data/Managed/Assembly-CSharp.dll"
```

Das Skript nimmt automatisch alle Typen aus dem Patch-Manifest. Jede geänderte Signatur
eines gepatchten Members blockiert das Release, bis das Finding aktualisiert ist.
