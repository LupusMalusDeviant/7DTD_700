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

## Künftige Patch-Ziele (noch kein Patch, noch keine Soll-Datei)

Aus dem Kurz-Check Prio 2–10
([02-10-schnittstellen-kurzcheck.md](02-10-schnittstellen-kurzcheck.md)) sind zwei Features
übrig, die **nicht** ohne C# gehen. Beide liegen hinter Phase 1; hier stehen sie, damit sie nicht
vergessen werden. Bevor einer davon gepatcht wird, braucht er ein eigenes Finding **und** eine
Soll-Datei unter `tools/meta/expect/` (Projektregel 2).

| Feature | Grund | Vermutetes Ziel | Phase |
|---|---|---|---|
| F-21 Learning by Doing | Es gibt keinen XML-Auslöser „Gegenstand fertig hergestellt“ | Abschluss des Craft-Vorgangs, serverseitig — Stelle noch nicht gesucht | 2 |
| F-02 Schild blockt von vorn | Richtungsprüfung ist keine XML-Bedingung | Postfix auf `int EntityAlive::DamageEntity(DamageSource, int, bool, float)`; `DamageSource` trägt `direction` und `ownerEntityId` | 3 |

Die acht übrigen geprüften Features (F-05, F-07, F-08, F-13-Teleport, F-15, F-17, F-18, F-20)
brauchen **keinen** Patch.
