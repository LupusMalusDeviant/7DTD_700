# 7DTD_700 — Frühmittelalter-Overhaul für 7 Days to Die

> Arbeitstitel. Ziel: 7 Days to Die (V2.x Stable) thematisch ins Frühmittelalter (~700 n. Chr.)
> verlegen — mit passenden Gameplay-Anpassungen, neuen Inhalten und Overhaul-Systemen.

**Status:** Konzeptphase (GDD + Specs). Noch kein Mod-Code.

## Dokumente

| Dokument | Inhalt |
|---|---|
| [docs/GDD.md](docs/GDD.md) | Game Design Document: Vision, Säulen, Setting, Core Loop, Systeme |
| [docs/specs/01-technischer-rahmen.md](docs/specs/01-technischer-rahmen.md) | Technischer Rahmen: Version, Mod-Architektur, Multiplayer, Kompatibilität, Recht |
| [docs/features/README.md](docs/features/README.md) | Feature-Katalog (F-00 … F-16) mit Priorität, Tiefe, Abhängigkeiten |
| [docs/rea/interface-discovery.md](docs/rea/interface-discovery.md) | Schnittstellen-Analyse mit REA (Reverse Engineer Anything) |
| [docs/rea/hook-hypothesen.md](docs/rea/hook-hypothesen.md) | Ungeprüfte Hook-Kandidaten je Feature, per REA zu verifizieren |

## Eckdaten

- **Zielversion:** 7 Days to Die V2.x (Stable). Die exakte Build-Nummer wird per REA festgehalten.
- **Mod-Tiefe:** XML-Modlets (XPath) + C#-DLL mit Harmony-Patches; ab Phase 2 eigene Assets + Retexturen.
- **Setting:** fiktives Mischland um 700, Aberglaube mit kleinen Spieleffekten, keine Zauber.
- **Welt:** zufällige Welten (RWG) zuerst, eigene Karte später.
- **Multiplayer:** Singleplayer + Dedicated Server.
- **Kompatibilität:** eigenständige Total Conversion, aber verträglich mit UI-Mods.
- **Sprachen:** Deutsch + Englisch.
- **Lizenz der Spieldateien:** Spiel-DLLs und -Assets werden **nie** ins Repo committet (siehe `.gitignore`).
