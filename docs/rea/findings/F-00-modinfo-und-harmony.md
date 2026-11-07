# F-00 — ModInfo-Format V2 und Harmony-Bereitstellung

| Build | Assembly SHA-256 | MVID | Datum |
|---|---|---|---|
| Steam 26309840 (public) | `cb54022c…56c58` | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` | 2026-11-07 |

## Frage

Prio 1 aus der Übergabe: Wie sieht `ModInfo.xml` in der Zielfassung aus, und bringt das Spiel
Harmony mit? (Die Übergabe sprach von „V2.x“; die Zielplattform ist nach D52 **V 3.40**. Das
Dateiformat heißt unabhängig davon weiterhin „V2“ — nicht verwechseln.)

## Ergebnis

Beides ließ sich **ohne** Member-Analyse belegen, weil The Fun Pimps einen eigenen Mod
mitliefern: `<Spielpfad>\Mods\0_TFP_Harmony\`. Dessen `ModInfo.xml` ist ein
Original-Beispiel des Zielformats aus derselben Spielfassung.

### ModInfo.xml, Format V2 (Originaldatei, vollständig)

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xml>
	<Name value="TFP_Harmony" />
	<DisplayName value="Harmony Wrapper" />
	<Description value="Sets up basic HarmonyX configuration to be used with 7 Days to Die" />
	<Author value="The Fun Pimps LLC" />
	<Version value="1.1.0.4" />
	<Website value="" />
	<SkipWithAntiCheat value="true" />
</xml>
```

Belegt damit:

| Punkt | Befund |
|---|---|
| Wurzelelement | `<xml>` — **nicht** `<ModInfo>` |
| Felder | `Name`, `DisplayName`, `Description`, `Author`, `Version`, `Website`, `SkipWithAntiCheat` |
| Schreibweise | jedes Feld als leeres Element mit `value="…"`-Attribut |
| `Name` | ohne Leerzeichen, entspricht hier nicht dem Ordnernamen (`0_TFP_Harmony` vs. `TFP_Harmony`) |
| `SkipWithAntiCheat` | vorhanden und auf `true` — der Mod wird mit aktivem EAC übersprungen |

Eine Datei zeigt, was funktioniert, nicht was erlaubt ist. **Nachgetragen am selben Tag:** der
Lader selbst ist inzwischen gelesen, und das vollständige Feld-Set steht in
[F-00-modloader-events-version.md](F-00-modloader-events-version.md), Abschnitt 2 — es gibt
genau ein weiteres Feld (`Website` ist hier leer, `Description`/`Author` sind belegt) und
**keine** Abhängigkeitsangabe. Pflichtfelder sind `Name` und `DisplayName`.

### Harmony

| Punkt | Befund |
|---|---|
| Ort | `Mods\0_TFP_Harmony\0Harmony.dll` — **nicht** in `7DaysToDie_Data\Managed\` |
| Variante | **HarmonyX** (`Licenses\HarmonyX-MIT.txt`) |
| Assembly-Version | `2.13.0.0`, Target `.NETFramework,Version=v4.5.2` |
| SHA-256 | `c349e1a3fd13fa5a9facc9805a5e160161b14489f46f6bdd38202b8e124f78df` |
| Beiwerk | `TfpHarmony.dll`, `MonoMod.{Backports,Core,ILHelpers,Iced,RuntimeDetour,Utils}.dll`, `Mono.Cecil{,.Mdb,.Pdb,.Rocks}.dll`, `System.ValueTuple.dll` |
| Ladereihenfolge | Die führende Null im Ordnernamen sortiert den Wrapper vor alle anderen Mods. |

Evidenz: REA `inspect_managed_artifact` auf `0Harmony.dll`, Evidence `ev_e7fe26de…`;
Dateiliste und `ModInfo.xml` direkt aus dem Spielordner.

## Patch-Empfehlung

Kein Patch. Für F-00 folgt daraus:

1. **Kein eigenes `0Harmony.dll` ausliefern.** Gegen das vorgeladene HarmonyX 2.13 bauen,
   die Referenz über `SDTD_PATH` auf `Mods\0_TFP_Harmony\0Harmony.dll` setzen, `Private=false`.
2. `mod/ModInfo.xml` nach dem Muster oben schreiben, mit `SkipWithAntiCheat value="true"`.
3. Ordnername `7DTD_700` sortiert nach `0_TFP_Harmony` — die Reihenfolge passt ohne Zutun.
   Ob eine ausdrückliche Abhängigkeit nötig ist, bleibt offen (siehe oben).

## Offene Punkte / Limitierungen

- Ob `ModInfo.xml` eine **Ladereihenfolge oder Abhängigkeit** ausdrücken kann: **nein**, siehe
  Abschnitt 2 des [Lader-Findings](F-00-modloader-events-version.md). Die Reihenfolge ergibt
  sich allein aus dem Ordnernamen.
- Die ursprünglich hier offenen Punkte zu `IModApi`, `ModEvents` und `Constants` sind im
  [Lader-Finding](F-00-modloader-events-version.md) beantwortet.
