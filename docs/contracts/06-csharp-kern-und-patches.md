# Vertrag 06 — C#-Kern und Harmony-Patches

- **Status:** **Entwurf — Abnahme offen.** Geschrieben im autonomen Lauf (Plan-0002 WP9.1, D167); vor
  dem ersten Patch abzunehmen (WP9.8). Bis dahin gibt es **keinen** Patch — das Patch-Manifest ist leer.
- **Datum:** 2026-11-23
- **Gilt ab:** Phase 2b (D140: erste Harmony-Patches nach 2a)
- **Belege:** Spec 01 §2.1 (Schichtenregel, Patch-Policy), §3 (Netz-Klassen), §4 (Update-Festigkeit),
  §5 (Tests) · GDD §8 („keine eigenen NetPackages, solange es sich vermeiden lässt") ·
  Vertrag 01 §2–§4 (`700_00_Core` trägt die einzige DLL; `SkipWithAntiCheat`) ·
  [F-00-modloader-events-version.md](../rea/findings/F-00-modloader-events-version.md) ·
  [F-00-modinfo-und-harmony.md](../rea/findings/F-00-modinfo-und-harmony.md) ·
  [patch-manifest.md](../rea/findings/patch-manifest.md) · `src/Mod700` (Stand Phase 1: fünf Dateien,
  kein Patch) · `tools/meta` (`verify`, seit WP9.7 mit Gegenprobe)

Dieser Vertrag legt fest, **wie** C# in der Mod aussieht. **Ob** ein Feature C# bekommt, entscheidet
je Kandidat die Triage (WP9.6) mit Finding und der Zeile „Warum nicht XML?" (Projektregel 3).

## 1. Grundregeln

1. **XML vor C# vor Assets** (P5). Ein Patch ist der letzte Weg, nicht der bequeme.
2. **Kein Patch ohne Finding** (Projektregel 2). Dazu, ohne Ausnahme, **vor** dem ersten Build des
   Patches: eine Zeile im Patch-Manifest, eine Zeile in einer Soll-Datei unter `tools/meta/expect/`,
   eine Netz-Klasse (§6), ein Schalter (§5), die Zeile „Warum nicht XML?" im Feature-Dokument.
3. **Eine DLL** (Vertrag 01 §3): `Mod700.dll` in `700_00_Core`. Kein zweites Assembly, auch nicht für
   Logik oder Tests im Paket.
4. **Kein eigenes Harmony.** Gebunden wird gegen das vom Spiel vorgeladene HarmonyX aus
   `Mods/0_TFP_Harmony/` (F-00). Die Mod liefert kein `0Harmony.dll` aus.
5. **Die Mod darf das Spiel nicht mitnehmen.** Keine Ausnahme verlässt einen Patch (§7); ein Patch,
   dessen Ziel fehlt, fällt weg und meldet sich (§8).

## 2. Modulgrenzen in `src/Mod700`

| Ordner | Inhalt | darf Spieltypen nennen | Unit-Tests |
|---|---|---|---|
| `Kern/` | Einstieg (`ModApi`), Protokoll (`Log700`), Build-Guard, Versions-Handshake, **Patch-Register** (§4), **Schalter** (§5), **Netz** (§6) | ja | nein (Smoke) |
| `Logik/` | reine Rechnung ohne Spiel und ohne Unity: Formeln, Zustandsübergänge, Tabellen (z. B. Lernfortschritt, Grauen-Stufen, Verderb) | **nein** — nur `System.*` | **ja** |
| `Systeme/<F-xx>/` | Kleber eines Features: liest Spielzustand, ruft `Logik/`, schreibt Buffs und CVars | ja | nein |
| `Patches/<F-xx>/` | genau ein Harmony-Patch je Datei (§3) | ja | nein |

**Abhängigkeitsrichtung:** `Patches` → `Systeme` → `Logik`; `Kern` wird von allen benutzt und benutzt
keinen von ihnen. `Logik/` kennt weder `Assembly-CSharp` noch `UnityEngine` noch `HarmonyLib` — die
Prüfung dafür ist der Test-Build (§9), der `Logik/` ohne diese Verweise übersetzt.

Die heutigen fünf Dateien wandern beim ersten Patch nach `Kern/`; das ist eine Verschiebung ohne
Verhaltensänderung und ein eigener Commit.

## 3. Ein Patch, eine Datei

Dateiname `Patches/<F-xx>/P700_<Feature>_<Ziel>.cs`, Klasse gleichen Namens, `internal static`.
Jede Datei beginnt mit diesem Kopf (Spec 01 §2.1):

```csharp
// Patch:     P700_F21_HerstellenFertig
// Feature:   F-21 Learning by Doing          Schalter: F21_HerstellenFertig (Vorgabe an)
// Finding:   docs/rea/findings/<datei>.md §<n>
// Ziel:      <Typ>::<Member>
// Signatur:  <genau die Zeile aus `mod700meta members`>   Soll-Datei: tools/meta/expect/<datei>.tsv
// Build:     V 3.40 b10, Assembly-CSharp SHA-256 <…>
// Art:       Postfix                          Netz: S
// Rückfall:  <was ohne den Patch gilt — der XML-Weg aus der Triage>
```

Das Ziel steht **mit Parametertypen** im Attribut (`[HarmonyPatch(typeof(X), nameof(X.Y), new[] { … })]`),
nie nur mit dem Namen — sonst trifft ein Spiel-Update still eine andere Überladung.

## 4. Patch-Arten und Reihenfolge

| Art | wann | Regel |
|---|---|---|
| **Postfix** | Vorgabe | liest Ergebnis und Zustand, ändert danach |
| **Prefix** ohne `return false` | wenn vorher gelesen oder ein Argument gesetzt werden muss | gibt immer `true` zurück |
| **Prefix mit `return false`** | nur mit Begründung im Kopf **und** im Finding | ersetzt Vanilla — kollidiert mit anderen Mods (Spec 01 §2.1, §4.1) |
| **Finalizer** | nicht vorgesehen | — |
| **Transpiler** | **nicht in Phase 2** | nur mit belegter CIL-Folge im Finding; eigener Vertragsnachtrag |

**Kein `PatchAll`.** Das Patch-Register (`Kern/PatchRegister.cs`) kennt jede Patch-Klasse beim Namen
und wendet sie einzeln an: `Harmony::CreateClassProcessor(System.Type)` → `PatchClassProcessor::Patch()`
(beide im vorgeladenen HarmonyX belegt, Soll-Datei `tools/meta/expect/v06-harmony.tsv`). Reihenfolge
= Reihenfolge der Liste im Register; Patches dürfen sich **nicht** auf die Reihenfolge verlassen.
Keine `HarmonyPriority`, solange zwei eigene Patches nicht dasselbe Ziel haben (das wäre ein
Entwurfsfehler, kein Fall für Prioritäten).

Ein Patch auf `XUiC_*` nur als Postfix (Spec 01 §4.1 Nr. 4).

## 5. Ein Schalter je Patch

- Datei `700_00_Core/Schalter.xml`, ausgeliefert mit der Mod, gelesen in `InitMod` über den Pfad des
  Modlets (`Mod::Path`). Form: `<schalter><patch name="F21_HerstellenFertig" an="true" /></schalter>`.
- **Vorgabe an.** Fehlt die Datei oder eine Zeile, gilt „an" und das Protokoll sagt es.
- Ein ausgeschalteter Patch wird **nicht angewendet** (nicht: angewendet und innen übersprungen).
- Der Schalter ist für Fehlersuche und für Spieler, die ein Feature nicht wollen — er ersetzt keinen
  Grusel-Regler (D13; der gehört in Vertrag 07).
- **S+C-Patches:** Server und Client müssen dieselbe Stellung haben. Der Versions-Handshake schreibt
  die Stellung aller S+C-Schalter ins Protokoll; abgewiesen wird nicht (wie heute, F-00).

## 6. Netz-Klasse je Patch (Spec 01 §3)

| Klasse | Pflicht im Patch-Rumpf | belegter Zugriff |
|---|---|---|
| **S** | erste Zeile: nur auf dem Server weiter | `ConnectionManager::get_IsServer` (gelesen in `EntityTrader::OnUpdateLive`, Finding WP8) |
| **C** | erste Zeile: nicht auf einem Dedicated Server | `GameManager::get_IsDedicatedServer` (ebenda) |
| **S+C** | keine Wache; beide Seiten müssen gleich rechnen | — |

Die Wache steht als Helfer in `Kern/Netz.cs`; ihre Signaturen stehen in `tools/meta/expect/v06-kern.tsv`.
Statische Netz-Zuordnung ist ein **Indiz**; jede gilt erst nach dem Dedicated-Test (Projektregel 5).

**Keine eigenen NetPackages** (GDD §8). Was zwischen Server und Client wandern muss, wandert über
Buffs, CVars und Entity-Werte, die das Spiel ohnehin abgleicht. Ein eigenes Paket braucht ein Finding,
das zeigt, dass diese Wege nicht reichen, **und** eine Entscheidung des Nutzers.

## 7. Fehler im Patch-Rumpf

- Jeder Rumpf steht in `try`/`catch (Exception)`. Im `catch`: **einmal je Patch** über
  `Log700.Exception` melden, danach still; ein Prefix gibt `true` zurück, damit Vanilla läuft.
- Kein Protokoll je Bild oder je Treffer. Heiße Ziele (`OnUpdateLive`, `DamageEntity`) bekommen keine
  Zuweisung neuer Objekte, kein LINQ, keine Zeichenketten im Normalfall.
- Ein Patch schreibt keinen Zustand außerhalb von Buffs, CVars und eigenen statischen Feldern; was
  einen Neustart überleben muss, regelt Vertrag 07.

## 8. Abweichende Signatur

Drei Riegel, von früh nach spät:

1. **Vor dem Release:** `mod700meta verify` gegen alle Soll-Dateien; rot blockiert das Release
   (Spec 01 §4). Gegenprobe belegt (WP9.7).
2. **Beim Start:** der Build-Guard warnt bei anderer Spielfassung (heute schon gebaut).
3. **Beim Anwenden:** das Register löst jedes Ziel mit Namen **und Parametertypen** auf
   (`AccessTools::DeclaredMethod(System.Type, string, System.Type[], System.Type[])`). Fehlt es, wird der
   Patch **nicht** angewendet, das Protokoll nennt Patch, Ziel und den Rückfall aus dem Kopf; die Mod
   lädt weiter. Am Ende eine Zeile: *n angewendet, m aus, k ohne Ziel*.

## 9. Tests und Build

| Was | Wie | Nachweis |
|---|---|---|
| `Logik/` | Testprojekt `tests/Mod700.Logik.Tests` (net10.0), das die Quelldateien aus `src/Mod700/Logik/` **mit übersetzt** — keine zweite DLL im Paket | `dotnet test`, Zahl der Tests im Bericht |
| Grenze von `Logik/` | dasselbe Testprojekt hat **keinen** Verweis auf Spiel, Unity oder Harmony; ein solcher Typ in `Logik/` bricht den Build | Build rot = Grenze verletzt (Gegenprobe beim Anlegen) |
| `Mod700.dll` | Build gegen die lokalen Spiel-Verweise (`SDTD_PATH`), `TreatWarningsAsErrors` | 0 Warnungen |
| Signatur | nach jedem Build mit dem Zertifikat „Lupus Malus Deviant" signieren (globale Regel) | `Get-AuthenticodeSignature` = `Valid` |
| Patch im Spiel | Smoke SP + Dedicated + 2. Client; Protokoll-Zeile des Registers | Testlauf |

Das Test-Framework ist **offen (N-111)**: Empfehlung xUnit über NuGet; `tools/meta` und
`tools/check` kommen bisher ohne NuGet aus.

## 10. Was dieser Vertrag nicht regelt

- **Welche** Features C# bekommen — Triage WP9.6.
- Zustände, CVars, Buffs, Regler und was einen Neustart überlebt — **Vertrag 07** (WP9.2).
- XUi-Fenster und eigene Controller — eigener Nachtrag, sobald ein Feature eines braucht.
- Transpiler — eigener Nachtrag mit Finding.

## 11. Abgleich mit dem Code (Stand 2026-11-23)

| Vertragspunkt | heutiger Code | Folge |
|---|---|---|
| §4 kein `PatchAll` | `ModApi.ApplyPatches` ruft `harmony.PatchAll(Assembly.GetExecutingAssembly())` — bei null Patches wirkungslos | wird mit dem ersten Patch durch das Register ersetzt, eigener Commit |
| §2 Ordner `Kern/` | fünf Dateien flach in `src/Mod700` | Verschiebung mit dem ersten Patch |
| §7 `Log700.Exception` | vorhanden: `Exception(string context, Exception)` | passt |
| §8 Riegel 2 Build-Guard | vorhanden (`BuildGuard.cs`, V 3.40 b10) | passt |
| §5 `Mod::Path` | `string Mod::get_Path()` belegt (`v06-kern.tsv`) | Lesart (Ordner des Modlets) im Smoke bestätigen |
| §4, §8 HarmonyX | `CreateClassProcessor(System.Type)`, `PatchClassProcessor::Patch()`, `AccessTools::DeclaredMethod(Type, string, Type[], Type[])` belegt (`v06-harmony.tsv`) | passt |

Beide neuen Soll-Dateien: `mod700meta verify` Exit 0. Gegenprobe: `get_IsServer` mit falschem
Rückgabetyp → Exit 1.

## Offen

| Nr. | Frage | Vorschlag |
|---|---|---|
| a | Test-Framework (N-111) | xUnit |
| b | Zeigt `Mod::Path` auf den Ordner des Modlets, sodass `Schalter.xml` neben `ModInfo.xml` gefunden wird? | Signatur belegt; Lesart im F-00-Smoke mit einer Protokollzeile bestätigen |
| c | Wirkt ein Prefix eines anderen Mods mit `return false` vor unserem Postfix? | Testmatrix Spec 01 §4.1 Nr. 6 |
| d | Server ohne Mod, Client mit (oder umgekehrt): was tut ein S+C-Patch? | Dedicated-Test, F-00-Smoke |
