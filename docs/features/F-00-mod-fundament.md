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
| [`mod/700_00_Core/ModInfo.xml`](../../mod/700_00_Core/ModInfo.xml) | V2-Format, `SkipWithAntiCheat="true"`. Seit **D53** eines von acht Modlets; die sieben übrigen tragen XML und laden ohne DLL. Siehe [Vertrag 01](../contracts/01-modlet-grenzen.md). |
| [`tools/build/build.ps1`](../../tools/build/build.ps1) | bauen → packen → signieren → optional installieren |
| [`tools/build/smoke.ps1`](../../tools/build/smoke.ps1) | prüft das installierte Paket und das Spielprotokoll, Exit 1 bei rot |
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
- [x] In die Spielinstallation kopiert (`build.ps1 -Install`) und gegen die belegten
      Laderegeln geprüft: `smoke.ps1 -SkipLog` → **14 geprüft, 0 rot**. Darunter: Wurzel
      `<xml>`, keine `<ModInfo>`-Hülle, `Name` gegen `^[0-9a-zA-Z_\-]+$`, `Version` per
      `Version.TryParse`, keine Felder, die der Lader ignoriert.
- [x] **SP-Start:** `[700] loaded vX.Y.Z (game build …)` im Log, keine Fehler
      → **Erfüllt am 2026-11-22, 21:05** (Protokoll
      `output_log_client__2026-11-22__21-05-22.txt`, Start mit `-noeac`): „Not started with
      EAC, anticheat disabled", acht Modlets geladen, `[700] loaded v0.1.0 (game build
      V 3.4.0 (b10))`, „Spielfassung V 3.4.0 (b10) entspricht der geprüften Fassung",
      `Initialized code in mod '700_00_Core'`, Harmony 2.13.0.0 mit 0 Patch-Zielen,
      `[700] GameStartDone erreicht — Welt läuft`; 0 `EXC`, 2 fremde `ERR` (Discord, Xbox
      Live). `smoke.ps1 -LogPath <dieses Protokoll>`: **123 geprüft, 0 rot, Exit 0**;
      Gegenprobe am Lauf mit EAC von 20:45: 7 rot, Exit 1. Dabei gefunden und behoben:
      `smoke.ps1` las das Protokoll als ANSI und fand die Zeile des Build-Guards mit „ü"
      nicht (1 rot ohne Grund); es liest jetzt UTF-8. Was davor hier stand:
      → `smoke.ps1` (ohne `-SkipLog`) prüft das selbst und **findet jetzt auch Protokolle**:
      sie liegen unter `%APPDATA%\7DaysToDie\logs\`, nicht unter `LocalLow`. Der Lauf gegen das
      neueste vorhandene Protokoll (30. Juli 2026, V 3.1.0, ohne diese Mod) ist erwartungsgemäß
      **rot** — er beweist damit, dass der Protokollteil greift. Braucht einen Spielstart mit
      **abgeschaltetem EAC**; steht aus.
- [ ] **Dedicated Server** unter Windows und Linux lädt die Mod
      → auf diesem Rechner **kein Dedicated Server installiert**; nicht prüfbar
- [ ] **Client verbindet sich mit dem Server**, beide loggen die Version
      → hängt am Dedicated Server; nicht prüfbar

### Was der Smoke-Test im Protokoll finden muss

Wörtliche Zeichenketten aus `Mod::InitModCode` und `Mod::LoadAssemblies`, als Anker:

Modlet-Namen seit **D53**. Das Protokoll liegt unter
`%APPDATA%\7DaysToDie\logs\output_log_client__<datum>.txt` — **nicht** unter `LocalLow`, wie
hier ursprünglich angenommen.

```
[MODS] Start loading from: '…/Mods'
[MODS]   Trying to load from folder: '700_00_Core'
[MODS]   Trying to load from folder: '700_10_Purge'
…                                     (alle acht, in dieser Reihenfolge)
[MODS]   Initializing mod 700_00_Core
[MODS]     Found ModAPI in assembly …, creating instance
[MODS]     Initialized code in mod '700_00_Core' in assembly …
[700] loaded v0.1.0 (game build …)
[700] Spielfassung … entspricht der geprüften Fassung.
[700] Login-Handler registriert (nur Protokoll, keine Abweisung).
[700] Harmony 2.13.0.0 angebunden, 0 Patch-Ziele (Phase 0: erwartet 0).
```

Die acht `Trying to load from folder`-Zeilen sind der Nachweis, dass der Lader jedes Modlet
gesehen hat. Ein Tippfehler im Ordnernamen fällt sonst nicht auf: der Patcher schweigt, wenn er
eine Datei nicht findet.

`smoke.ps1` sucht genau diese Zeilen; es muss niemand das Protokoll von Hand durchlesen.

Fehlerfälle, an denen man es erkennt:

```
[MODS]     No ModAPI found in mod DLLs                                  ← Klasse nicht gefunden
[MODS]     Mod contains custom code, AntiCheat needs to be disabled …   ← EAC noch an
[MODS]     AntiCheat enabled, mod skipped because it is set not to load ← EAC an + SkipWithAntiCheat
```
