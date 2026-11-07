# 7DTD_700 — Frühmittelalter-Overhaul für 7 Days to Die

> Arbeitstitel. Ziel: 7 Days to Die (V 3.40 Stable) thematisch ins Frühmittelalter (~700 n. Chr.)
> verlegen — mit passenden Gameplay-Anpassungen, neuen Inhalten und Overhaul-Systemen.

**Status:** Phase 0. Build-Baseline steht, F-00-Schnittstellen sind belegt. Noch kein Mod-Code.

## Dokumente

| Dokument | Inhalt |
|---|---|
| [docs/GDD.md](docs/GDD.md) | Game Design Document: Vision, Säulen, Setting, Core Loop, Systeme |
| [docs/specs/01-technischer-rahmen.md](docs/specs/01-technischer-rahmen.md) | Technischer Rahmen: Version, Mod-Architektur, Multiplayer, Kompatibilität, Recht |
| [docs/features/README.md](docs/features/README.md) | Feature-Katalog (F-00 … F-21) mit Priorität, Tiefe, Abhängigkeiten |
| [docs/rea/interface-discovery.md](docs/rea/interface-discovery.md) | Schnittstellen-Analyse mit REA (Reverse Engineer Anything) |
| [docs/rea/hook-hypothesen.md](docs/rea/hook-hypothesen.md) | Hook-Kandidaten je Feature mit Prüfstand (F-00 abgeschlossen) |
| [docs/rea/findings/](docs/rea/findings/) | Kuratierte Befunde: Build-Baseline, Grenzen von REA, F-00, Patch-Manifest |
| [tools/meta/README.md](tools/meta/README.md) | `mod700meta`: statischer Metadaten-Leser für Signaturen (D51) |
| [docs/handoff/01-lokale-rea-session.md](docs/handoff/01-lokale-rea-session.md) | **Übergabeprompt** für die lokale Session (REA einrichten, Analyse, Phase 0) |

## Eckdaten

- **Zielversion:** 7 Days to Die **V 3.40, Build 10** (Steam-Branch `public`, Build 26309840), Unity 2022.3.62f2, Mono/CIL. Festgehalten in der [Build-Baseline](docs/rea/findings/00-build-baseline.md); Entscheidung D52.
- **Mod-Tiefe:** XML-Modlets (XPath) + C#-DLL mit Harmony-Patches; ab Phase 2 eigene Assets + Retexturen.
- **Setting:** fiktives Mischland um 700 mit dezenter Volksmagie (Runen, Segen, Tränke, einfache Zauber als Ersatz für anachronistische Technik) und wenigen Sagengestalten.
- **Welt:** zufällige Welten (RWG) mit fünf Kulturzonen, eigene Karte später.
- **Roadmap:** strikt phasenweise (0–4), MVP-Fokus „700 & Grauen“, Solo-Projekt mit Claude, erst intern, dann öffentlich.
- **Multiplayer:** Singleplayer + Dedicated Server.
- **Kompatibilität:** eigenständige Total Conversion, aber verträglich mit UI-Mods.
- **Sprachen:** Deutsch + Englisch.
- **Lizenz der Spieldateien:** Spiel-DLLs und -Assets werden **nie** ins Repo committet (siehe `.gitignore`).
