# 00 — Build-Baseline

Erhoben am **2026-11-07** auf Windows 11 Pro (26300) gegen die lokale Steam-Installation
`C:\Program Files (x86)\Steam\steamapps\common\7 Days To Die`.

| Feld | Wert |
|---|---|
| Spielversion | **Release-Typ `V`, Major 3, Minor 40, Build 10.** Aus dem Code gelesen, nicht aus dem Menü: `Constants::.cctor` schiebt genau vier Konstanten `1, 3, 40, 10` auf den Stapel, ruft `newobj VersionInformation::.ctor(EGameReleaseType, int, int, int)` und legt das Ergebnis per `stsfld` in `Constants::cVersionInformation` ab — der einzige solche Aufruf in der Methode. `EGameReleaseType.Alpha = 0`, **`EGameReleaseType.V = 1`** (Constant-Tabelle). Die Anzeigeform ist nach den Formatzeichenketten des Konstruktors (`"{0} {1}.{2} (b{3})"`, `"{0}{1}.{2}"`) **vermutlich** „V 3.40 (b10)“ bzw. kurz „V3.40“ — die Zahlen sind belegt, die Schreibweise ist abgeleitet. ⚠️ **Das widerspricht dem GDD und Spec 01, die „V2.x Stable“ als Zielplattform nennen.** Siehe unten. |
| `Player.log` | existiert nicht — das Spiel wurde auf diesem Rechner noch nicht gestartet, `…\AppData\LocalLow\The Fun Pimps\7 Days To Die\` ist leer |
| Steam-Branch | **public (Stable)** — `appmanifest_251570.acf`: `"BetaKey" "public"` |
| Steam-Build | **26309840** (`"buildid"`/`"TargetBuildID"`), `LastUpdated 1793777837` (≈ 3. November 2026) |
| `Assembly-CSharp.dll` SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| Dateigröße | 11 980 288 Byte |
| Module MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Runtime | **Mono/CIL bestätigt.** REA-Klassifikation: `status: managed`, `container: pe`, `runtime_family: unity-mono`, `implementation: cil`, CLI-Flag `il-only`, CLI-Runtime-Version 2.5, Metadaten-Version `v4.0.30319`. **Kein IL2CPP** — der ursprüngliche Plan trägt. |
| Managed-Architektur | `anycpu` (PE-Machine `0x014c`, PE32) |
| Target-Framework | `Assembly-CSharp.dll` trägt **kein** `TargetFrameworkAttribute` (`target_frameworks: []`). Abgeleitet aus den AssemblyRefs: `mscorlib 4.0.0.0` (Token `b77a5c561934e089`), `netstandard 2.1.0.0`, `System.Net.Http 4.2.0.0`, `System.Runtime.CompilerServices.Unsafe 6.0.0.0` → Unity-Mono-Profil .NET Framework 4.x. **Vorschlag für `src/Mod700`: `net48`**; abgeleitet, nicht belegt — gilt erst als geprüft, wenn der Build gegen die Spiel-DLLs durchläuft. |
| Harmony mitgeliefert? Version | **Ja, aber nicht in `Managed/`**, sondern als vorgeladener Mod `Mods\0_TFP_Harmony\`. `0Harmony.dll`: Assembly-Version **2.13.0.0**, Target `.NETFramework,Version=v4.5.2`, SHA-256 `c349e1a3fd13fa5a9facc9805a5e160161b14489f46f6bdd38202b8e124f78df`. Es ist **HarmonyX** (`Licenses\HarmonyX-MIT.txt`), mitsamt `MonoMod.*` und `Mono.Cecil*`. Mod-Version laut `ModInfo.xml`: 1.1.0.4, `SkipWithAntiCheat value="true"`. |
| Unity-Version | **2022.3.62f2** (`7670c08855a9`) — `UnityPlayer.dll` und `7DaysToDie.exe` melden FileVersion `2022.3.62.7762112`, ProductVersion `2022.3.62f2 (7670c08855a9)`. `7DaysToDie_Data\boot.config`: `build-guid=6ae286c5812b4680b06e6a76569ef564`. Kein `globalgamemanagers` (Daten liegen in `data.unity3d`). |
| Dedicated Server | **nicht installiert** — weder in der Steam-Bibliothek auf `C:` noch in `X:\SteamLibrary`. Die Server-/Client-Smoke-Tests aus F-00 sind damit vorerst nur einseitig durchführbar. |
| Datum | 2026-11-07 |

## Wie das erhoben wurde

| Wert | Befehl / Werkzeug |
|---|---|
| SHA-256 | `sha256sum` **und** REA `inspect_managed_artifact` — beide unabhängig derselbe Hash |
| Klassifikation, MVID, AssemblyRefs, Metadaten | REA 6.7.0 MCP `inspect_managed_artifact` (`detail: "summary"`), Evidence `ev_588a0b31…`; AssemblyRef-Liste über `inspect_analysis_view` (`kind: managed`, `collection: references`, 68 Zeilen, `exhausted: true`) |
| Harmony-Identität | REA `inspect_managed_artifact` auf `Mods\0_TFP_Harmony\0Harmony.dll`, Evidence `ev_e7fe26de…` |
| Unity-/Exe-Version | `Get-Item … .VersionInfo` auf `UnityPlayer.dll` und `7DaysToDie.exe` |
| Steam-Build | `appmanifest_251570.acf` |

## Werkzeug-Umgebung

| Punkt | Stand |
|---|---|
| REA-MCP | in dieser Session **bereits registriert**; `npx rea-agents setup` und der Neustart aus der Übergabe waren nicht nötig |
| REA-CLI | `rea` global installiert, **6.7.0**; neueste Fassung auf npm: **6.8.0** → Update offen |
| Node.js | **v26.8.1**. REA verlangt für die 26er-Linie `>= 26.12.1`. Der MCP-Server und die CLI laufen trotzdem; die Abweichung ist notiert, aber **nicht** eigenmächtig geändert. |
| .NET SDK | 10.0.111 / 10.0.400 / 10.0.402 vorhanden (relevant für den Build von `src/Mod700` und für Ersatzwerkzeug, siehe [00-rea-grenzen.md](00-rea-grenzen.md)) |

## Folgen für den Plan

1. **IL2CPP-Stopp entfällt** — der Ansatz „statische Analyse der `Assembly-CSharp.dll`“ trägt.
2. **Harmony wird nicht mitgeliefert, sondern vorgeladen.** Unsere Mod bringt **kein** eigenes
   `0Harmony.dll` mit, sondern nutzt das vom Spiel geladene HarmonyX 2.13. Zu prüfen ist, ob
   `ModInfo.xml` dafür eine Abhängigkeit deklarieren muss oder die Ordner-Sortierung
   (`0_TFP_Harmony` lädt durch die führende Null zuerst) genügt.
3. **`SkipWithAntiCheat`** ist ein belegtes `ModInfo.xml`-Feld. Das passt zu „EAC muss aus sein“
   aus Spec 01 und ist für F-00 vorzumerken.
4. ⚠️ **Die Zielplattform im GDD stimmt nicht mit der Installation überein.** GDD-Kopf und
   Spec 01 Abschnitt 1 nennen „V2.x Stable“; installiert ist nach der Code-Lesung
   **V 3.40 (Build 10)**, Steam-Branch `public`. Die Planung entstand in einer Cloud-Session
   ohne Zugriff auf die Spieldateien, „V2.x“ war dort eine Annahme. Das ist eine harte Vorgabe
   und wird nach `CLAUDE.md` Regel 4 **nicht still geändert** — dem Nutzer am 2026-11-07
   vorgelegt. Zwei Wege: Dokumente auf V3.x ziehen, oder über einen Steam-Beta-Zweig auf V2.x
   zurück.
5. Der **Build-Guard** aus F-00 braucht diese vier Zahlen als „getestete Fassung“. Bis die
   Frage aus Punkt 4 entschieden ist, wird der Wert nicht fest eingetragen.
