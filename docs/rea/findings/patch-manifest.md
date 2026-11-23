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
| F-00 | `tools/meta/expect/f00.tsv` | 12 | 2026-11-07, grün (0 Abweichungen), Build Steam 26309840; 2026-11-23 grün an V 3.40 b10 |
| F-16 Assets | `tools/meta/expect/wp41.tsv` | 13 | 2026-11-23, grün, V 3.40 b10 |
| F-06 Wesengruppen | `tools/meta/expect/wp54.tsv` | 10 | 2026-11-23, grün, V 3.40 b10 |
| F-06 Wesen, Farbe | `tools/meta/expect/wp55.tsv` | 5 | 2026-11-23, grün, V 3.40 b10 |
| F-07 Zufallswelt | `tools/meta/expect/wp62.tsv` | 15 | 2026-11-23, grün, V 3.40 b10 |
| F-10 Händlerstimmen | `tools/meta/expect/wp85.tsv` | 9 | 2026-11-23, grün, V 3.40 b10 (neu, WP9.7) |
| Vertrag 06 Kern | `tools/meta/expect/v06-kern.tsv` | 3 | 2026-11-23, grün, V 3.40 b10 (neu, WP9.1) |
| Vertrag 06 HarmonyX | `tools/meta/expect/v06-harmony.tsv` | 5 | 2026-11-23, grün, gegen `Mods/0_TFP_Harmony/0Harmony.dll` (neu, WP9.1) |

Für alle Patches gilt ab Phase 2b [Vertrag 06](../../contracts/06-csharp-kern-und-patches.md) (Entwurf).

**Gegenprobe des Signatur-Checks (WP9.7, 2026-11-23):** an `wp85.tsv` je eine absichtlich falsche
Fassung — Signatur geändert, Member-Spalte vertippt, Typ fehlt, Member fehlt — alle vier Exit 1.
Die vertippte Member-Spalte lief **vorher grün durch**; `verify` prüft das seit diesem Tag
(`member-mismatch`, [tools/meta/README.md](../../../tools/meta/README.md)). Erst damit zählt
`verify` als Nachweis im Sinne von Projektregel 5.

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
