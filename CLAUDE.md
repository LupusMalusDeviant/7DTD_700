# CLAUDE.md — 7DTD_700

Frühmittelalter-Overhaul (~700 n. Chr.) für **7 Days to Die V2.x (Stable)**. Folk-Horror,
dezente Volksmagie, XML-Modlets + C#/Harmony, ab Phase 2 eigene Assets.
Solo-Projekt mit Claude, Sprache der Doku: **Deutsch**.

## Wo was steht
- `docs/GDD.md`: Vision, Säulen P1–P5, Setting, Roadmap (Phase 0–4), **Entscheidungen D1–D50**, offene Fragen, Nicht-Ziele
- `docs/specs/01-technischer-rahmen.md`: Mod-Architektur, Netz-Klassen S/C/S+C, UI-Kompatibilität, Assets, Recht
- `docs/features/`: F-00 … F-21 (Katalog + Reihenfolge in `README.md`)
- `docs/rea/`: REA-Workflow, Hook-Hypothesen (ungeprüft!), Findings, Patch-Manifest
- `tools/rea/discover.sh`: lokaler REA-Lauf (baseline / types / inventory / compare)

## Harte Regeln
1. **Spieldateien nie committen** (DLLs, Assets, dekompilierter Code, REA-Roh-JSON). Die `.gitignore` deckt `GameRefs/`, `.rea/` und `Assembly-CSharp*.dll` ab. Vor jedem Commit `git status` prüfen.
2. **Kein Harmony-Patch ohne REA-Finding.** Jeder Patch-Zielpunkt braucht ein Finding unter `docs/rea/findings/` und einen Eintrag im `patch-manifest.md` (Typ, Member, Signatur, Build, S/C/S+C).
3. **XML vor C# vor Assets** (Säule P5). Jeder C#-Teil begründet im Feature-Dokument „Warum nicht XML?“.
4. **Entscheidungen nicht still ändern.** Abweichungen vom GDD bzw. von D-Einträgen erst mit dem Nutzer klären (AskUserQuestion), dann als neue D-Zeile mit Datum eintragen; alte Zeile durchstreichen, nicht löschen.
5. **Prüfe mit einem Signal, das den Fehler finden könnte.** Ein neuer Check (z. B. REA-Compare, Denylist-Skript) muss einmal nachweislich an einem bekannt falschen Input scheitern, bevor er als Nachweis zählt. Statische REA-Befunde zu Server/Client im Dedicated-Test bestätigen.
6. **Phasen strikt** (D50): nur Features der aktuellen Phase umsetzen; Ideen für spätere Phasen als Notiz im Feature-Dokument.
7. Keine Inhalte, Namen oder Assets anderer Mods oder Spiele übernehmen.

## Build & Test (sobald F-00 steht)
- Spielpfad über Umgebungsvariable `SDTD_PATH` (nie hart codieren)
- Smoke: Spielstart ohne `ERR`/XML-Fehler im Log; SP + Dedicated Server + 2. Client
