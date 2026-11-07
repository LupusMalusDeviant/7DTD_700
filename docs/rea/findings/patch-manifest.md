# Patch-Manifest

Jeder Harmony-Patch der Mod steht hier.

Der Update-Diff läuft seit D51 über `mod700meta verify` gegen die Soll-Dateien unter
`tools/meta/expect/` (siehe [tools/meta/README.md](../../../tools/meta/README.md)). Jede
Signatur in diesem Manifest gehört zusätzlich in eine Soll-Datei; rot blockiert das Release.

| Feature | Typ | Member | Signatur | Patch-Art | Netz | Finding | Build |
|---|---|---|---|---|---|---|---|
| – | – | – | – | – | – | – | – |

**Stand 2026-11-07: noch leer, und das ist richtig.** F-00 braucht keinen Harmony-Patch —
Einstiegspunkt, Versions-Handshake und Build-Guard laufen vollständig über die öffentliche
Mod-API (`IModApi`, `ModEvents.PlayerLogin`, `VersionInformation.CompareToRunningBuild`).
Begründung: [F-00-modloader-events-version.md](F-00-modloader-events-version.md).
Der erste Eintrag kommt mit F-08 (Brenndauer der Fackeln).

## Geprüfte Schnittstellen ohne Patch

Signaturen, auf die sich Code der Mod verlässt, ohne sie zu patchen. Sie stehen in
`tools/meta/expect/` und werden beim Update mitgeprüft.

| Feature | Soll-Datei | Zeilen | Letzter Lauf |
|---|---|---|---|
| F-00 | `tools/meta/expect/f00.tsv` | 12 | 2026-11-07, grün (0 Abweichungen), Build Steam 26309840 |
