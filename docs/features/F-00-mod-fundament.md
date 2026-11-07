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

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-00](../rea/hook-hypothesen.md#f-00)

## Akzeptanzkriterien
- [ ] SP-Start: `[700] loaded vX.Y.Z (game build …)` im Log, keine Fehler
- [ ] Dedicated Server unter Windows und Linux lädt die Mod
- [ ] Client verbindet sich mit dem Server, beide loggen die Version
- [ ] `docs/rea/findings/00-build-baseline.md` existiert
