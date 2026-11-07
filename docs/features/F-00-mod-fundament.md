# F-00 — Mod-Fundament

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X+H | S+C | ja |

## Ziel
Ein ladbares, leeres Mod-Gerüst, das auf SP, Dedicated Server und Client sauber lädt. Es
prüft seine eigene Version und bildet die Basis für alle weiteren Features.

## Umfang
- `ModInfo.xml` (Name, Version, Autor, Beschreibung) im Format der Zielversion
- C#-Projekt `src/Mod700` mit Referenzen auf lokale Spiel-DLLs (`SDTD_PATH`), Harmony-Bootstrap
- Build-Skript: kompilieren, nach `Mods/7DTD_700/` packen und optional in die lokale Installation kopieren
- Logging-Helfer mit Präfix `[700]`
- **Versions-Handshake:** Server und Client loggen die Mod-Version; ein Client mit falscher Version bekommt eine verständliche Meldung
- **Build-Guard:** Beim Start wird die Spielversion gegen die getestete Version geprüft; bei Abweichung kommt eine Warnung ins Log

## Nicht im Umfang
- Gameplay-Änderungen

## Umsetzung
### C# / Harmony
- `IModApi.InitMod` → `Harmony.PatchAll()`. Warum nicht XML? Der Einstiegspunkt ist zwingend C#.
- Handshake: zunächst nur Logging. Echte Abweisung erst, wenn REA einen passenden Hook im
  Connect- bzw. Auth-Ablauf zeigt.

### Stand 2026-11-07: gebaut

| Datei | Zweck |
|---|---|
| [`src/Mod700/ModApi.cs`](../../src/Mod700/ModApi.cs) | `IModApi`-Einstieg, `Harmony.PatchAll`, `GameStartDone`-Handler |
| [`src/Mod700/BuildGuard.cs`](../../src/Mod700/BuildGuard.cs) | geprüfte Fassung V 3.40 b10 gegen `CompareToRunningBuild()` |
| [`src/Mod700/VersionHandshake.cs`](../../src/Mod700/VersionHandshake.cs) | `ModEvents.PlayerLogin`-Handler, nur Protokoll |
| [`src/Mod700/Log700.cs`](../../src/Mod700/Log700.cs) | Präfix `[700]` über `Log` aus `LogLibrary.dll` |
| [`mod/ModInfo.xml`](../../mod/ModInfo.xml) | V2-Format, `SkipWithAntiCheat="true"` |
| [`tools/build/build.ps1`](../../tools/build/build.ps1) | bauen → packen → signieren → optional installieren |
| [`Directory.Build.props`](../../Directory.Build.props) | Spielpfad über `SDTD_PATH`, nie hart codiert |

**Kein einziger Harmony-Patch.** Handshake und Build-Guard laufen über die öffentliche
Mod-API; `PatchAll` bleibt trotzdem drin, weil der Aufruf belegt, dass das vorgeladene
HarmonyX zur Laufzeit auflösbar ist. Begründung und Signaturen:
[F-00-modloader-events-version.md](../rea/findings/F-00-modloader-events-version.md).

**Der Handshake weist bewusst niemanden ab.** `SPlayerLoginData.CompatibilityVersion`
existiert, aber wer das Feld füllt und was drinsteht, ist nicht belegt. Eine Abweisung auf
Verdacht könnte den eigenen Server aussperren. Erst mitschreiben, dann die Regel.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-00](../rea/hook-hypothesen.md#f-00) — **abgeschlossen**, alle
Prio-1-Fragen beantwortet. Soll-Signaturen: `tools/meta/expect/f00.tsv` (12 Zeilen, grün).

## Akzeptanzkriterien
- [x] `docs/rea/findings/00-build-baseline.md` existiert und ist gefüllt
- [x] Build läuft gegen die echten Spiel-DLLs durch: `dotnet build -c Release` → 0 Warnungen,
      0 Fehler. Damit ist `net48` nicht mehr nur abgeleitet, und der Compiler hat jede
      gelesene Signatur unabhängig bestätigt.
- [x] Paket enthält genau `ModInfo.xml` + `Mod700.dll`; das Build-Skript bricht ab, wenn eine
      fremde DLL hineingerät
- [x] `Mod700.dll` signiert (`CN=Lupus Malus Deviant`, Status `Valid`)
- [ ] **SP-Start:** `[700] loaded vX.Y.Z (game build …)` im Log, keine Fehler
      → braucht einen Spielstart mit **abgeschaltetem EAC**; steht aus
- [ ] **Dedicated Server** unter Windows und Linux lädt die Mod
      → auf diesem Rechner **kein Dedicated Server installiert**; nicht prüfbar
- [ ] **Client verbindet sich mit dem Server**, beide loggen die Version
      → hängt am Dedicated Server; nicht prüfbar

### Was der Smoke-Test im Protokoll finden muss

Wörtliche Zeichenketten aus `Mod::InitModCode` und `Mod::LoadAssemblies`, als Anker:

```
[MODS]   Initializing mod 7DTD_700
[MODS]     Found ModAPI in assembly …, creating instance
[MODS]     Initialized code in mod '7DTD_700' in assembly …
[700] loaded v0.1.0 (game build …)
[700] Spielfassung … entspricht der geprüften Fassung.
[700] Login-Handler registriert (nur Protokoll, keine Abweisung).
[700] Harmony 2.13.0.0 angebunden, 0 Patch-Ziele (Phase 0: erwartet 0).
```

Fehlerfälle, an denen man es erkennt:

```
[MODS]     No ModAPI found in mod DLLs                                  ← Klasse nicht gefunden
[MODS]     Mod contains custom code, AntiCheat needs to be disabled …   ← EAC noch an
[MODS]     AntiCheat enabled, mod skipped because it is set not to load ← EAC an + SkipWithAntiCheat
```
