# Übergabe: lokale Session — REA einrichten, Schnittstellen analysieren, Phase 0 starten

> **Verwendung:** Repo lokal klonen, Branch `ccr-da9f2bb1-utwrjz` auschecken, Claude Code im
> Repo-Ordner starten und den Block unten als erste Nachricht einfügen.
> Den Pfad zur Spielinstallation vorher in die erste Zeile eintragen.

---

```text
Spielinstallation: <PFAD ZU "7 Days To Die", z. B. C:/Program Files (x86)/Steam/steamapps/common/7 Days To Die>
Dedicated Server (falls installiert): <PFAD oder "keiner">

Du übernimmst das Projekt 7DTD_700, einen Frühmittelalter-Overhaul für 7 Days to Die V2.x.
Die Planung ist in einer Cloud-Session entstanden; dort gab es keinen Zugriff auf die
Spieldateien. Deine Aufgabe ist der lokale Teil: REA (Reverse Engineer Anything) einrichten,
die Schnittstellen des Spiels belegen, Rückfragen stellen, wo die Befunde das Design
berühren, und danach Phase 0 (F-00 Mod-Fundament) umsetzen.

## 0. Einlesen (vor jeder Aktion)
Lies CLAUDE.md (harte Regeln!), docs/GDD.md (vor allem Abschnitt 5 Roadmap, 7 Entscheidungen,
8 Offene Fragen), docs/specs/01-technischer-rahmen.md, docs/features/README.md,
docs/rea/interface-discovery.md und docs/rea/hook-hypothesen.md.
Arbeite auf Branch ccr-da9f2bb1-utwrjz. Committe in kleinen Schritten, pushe erst nach
meiner Freigabe.

## 1. REA einrichten
REA: https://github.com/morluto/rea (npm-Paket: rea-agents). Nur aus diesen offiziellen
Quellen installieren.
1. Node-Version prüfen: REA braucht 22.x (>= 22.23.4), 24.x (>= 24.22.1) oder >= 26.12.1.
   Wenn nicht passend: mir sagen, nicht selbst systemweit umbauen.
2. `npx rea-agents setup` ausführen: als Agent Claude Code wählen; die vorgeschlagenen
   Änderungen zeigen und mich bestätigen lassen. Danach muss Claude Code neu gestartet
   werden. Sag mir Bescheid; ich starte neu und schicke dir „weiter“.
3. Nach dem Neustart prüfen, ob die REA-MCP-Tools verfügbar sind (u. a.
   inspect_managed_artifact, inspect_managed_members, compare_managed_members).
   Fallback ohne MCP: CLI über `npx -y rea-agents@latest <befehl>`.
4. Unter Linux: Für einige Werkzeuge muss ein procps-kompatibles `ps` im PATH sein (REA-Doku
   installation.md). Für die .NET-Analyse ist kein Hopper, Ghidra oder IDA nötig.
5. Flags von tools/rea/discover.sh gegen `rea <befehl> --help` prüfen (REA ändert sich
   schnell) und das Skript bei Abweichungen anpassen. Unter Windows das Skript über Git Bash
   ausführen oder die Befehle direkt nutzen.

## 2. Baseline (Phase 0)
1. SDTD_PATH setzen und `tools/rea/discover.sh baseline` ausführen (bzw. die MCP-Tools mit
   detail "summary" auf <Spielpfad>/7DaysToDie_Data/Managed/Assembly-CSharp.dll).
2. Ausfüllen: docs/rea/findings/00-build-baseline.md: Spielversion, SHA-256, MVID,
   Runtime (Mono/CIL bestätigt? Falls keine CLI-Metadaten: IL2CPP. Dann STOPP und mich
   fragen, denn dann ändert sich der ganze Ansatz), Target-Framework, Harmony mitgeliefert
   und welche Version, Unity-Version (aus Player.log bzw. Output-Log).
3. Rohdaten bleiben in .rea/ (gitignored). Ins Repo kommen nur kuratierte Findings in
   eigenen Worten, ohne dekompilierten Code.

## 3. Schnittstellen-Analyse (priorisiert nach Roadmap)
Arbeite docs/rea/hook-hypothesen.md in dieser Reihenfolge ab. Phase 0/1 hat Vorrang; den Rest
nur als Kurz-Check, ob die Annahme grundsätzlich trägt:

| Prio | Feature | Kernfrage |
|---|---|---|
| 1 | F-00 | IModApi/InitMod-Signatur, ModEvents, ModInfo.xml-Format V2.x, Spielversion zur Laufzeit |
| 2 | F-21 | Hängt Code hart an den 5 Vanilla-Attributen? Sind 6 neue Bäume per progression.xml möglich? Wo wird Crafting-Skill-Fortschritt erhöht (Hook für Learning by Doing)? |
| 3 | F-08 | Block-Tick-System für die Brenndauer von Fackeln (eventuell reines XML über Wachstumsblock-Prinzip) |
| 4 | F-17 | Nacht-Dunkelheit und Nebel per Weather/Biome-XML? Buff-Requirements für dunkel, Nacht, Mitspieler in der Nähe? |
| 5 | F-05 / F-01 | Ist die Währung per XML umdeutbar? Welche Item-Referenzen brechen beim Sperren? |
| 6 | F-18 | Blockschaden je Entity per XML steuerbar? |
| 7 | F-07 | Biom-Anzahl, -Namen und -Verteilung im RWG per XML änderbar (Kulturzonen)? |
| 8 | F-15 | Turret ↔ Strom-Kopplung (Variante A Kraftlinien, D37), Generator-Brennstoff per XML, CVar als Zauberkosten |
| 9 | F-02 | Schadenspfad (Blocken), Schadensarten-Tags, Wurfspeer-Mechanik |
| 10 | F-20 / F-13 | Q19: Gibt es Banditen bzw. menschliche NPC-Gegner? Q18: Tier als Fahrzeug? Teleport-Basis für Wegsteine |

Für jede Frage:
- ein Finding nach der Vorlage in docs/rea/interface-discovery.md (Abschnitt 3) schreiben,
- den Status in hook-hypothesen.md setzen (✓ mit Link, ✗ mit kurzer Begründung),
- im Feature-Dokument die Zeilen mit [verifizieren] auflösen,
- Server/Client-Zuordnung nur als Indiz werten; Bestätigung kommt im Dedicated-Test.
Wenn ein Typ nicht existiert: per Inventar bzw. Namensmuster nach dem tatsächlichen Typ suchen,
nicht raten.

## 4. Rückfragen stellen
Wenn ein Befund eine Entscheidung berührt (D-Eintrag im GDD) oder eine offene Frage
beantwortet bzw. verändert (Q18, Q19 usw.): Fasse den Befund kurz zusammen und frage mich mit
AskUserQuestion. Biete dabei konkrete Optionen mit Aufwand an. Typische Fälle:
- Ein Feature, das als „nur XML“ geplant war, braucht C# (oder umgekehrt).
- Ein Phase-1-Feature wird deutlich teurer als gedacht → verschieben?
- Q18/Q19 sind beantwortet → Pferd bzw. Kult realistisch?
- IL2CPP statt Mono, oder Harmony fehlt.
Antworten trägst du als neue D-Zeilen (mit Datum) in docs/GDD.md ein, offene Fragen räumst du
auf. Ändere Entscheidungen nie still.

## 5. Umsetzung Phase 0: F-00 Mod-Fundament
Erst nach Abschluss von Prio 1 (und Rückfragen, falls nötig). Ziel siehe
docs/features/F-00-mod-fundament.md:
1. src/Mod700/: C#-Projekt mit dem Target-Framework aus der Baseline; Referenzen auf die Spiel-DLLs
   über SDTD_PATH (Directory.Build.props), Private=false. Keine DLL ins Repo.
2. IModApi-Einstieg → Harmony.PatchAll(); Logging mit Präfix [700]; Build-Guard (getestete
   Spielversion gegen Laufzeit-Version, bei Abweichung Warnung im Log).
3. mod/ModInfo.xml (V2-Format laut Baseline), mod/Config/ (vorerst leer bzw. Platzhalter).
4. tools/build/: ein Befehl baut und packt nach dist/Mods/7DTD_700/ und kopiert optional
   nach <Spielpfad>/Mods/.
5. Smoke-Test: SP-Start → Log enthält „[700] loaded vX.Y.Z (game build …)“ und keine
   Fehler. Dedicated Server + Client, falls vorhanden. Ergebnis mit Log-Ausschnitt melden.
6. Den ersten Eintrag im Patch-Manifest gibt es erst mit dem ersten echten Patch (F-08). F-00
   selbst patcht nichts, außer REA belegt einen Handshake-Hook.

## 6. Danach
Den Phase-1-Plan aus docs/features/README.md vorschlagen (Reihenfolge F-01+F-05+F-12 →
F-21 → F-04 → F-03 → F-02 → F-18 → F-17 B1/B2/B8 + F-08) und auf meine Freigabe warten.

## Abschlussbericht dieser Session
Kurz: was eingerichtet ist, welche Hypothesen bestätigt bzw. widerlegt sind (Tabelle), welche
Entscheidungen neu oder geändert sind, Stand F-00 inklusive Smoke-Ergebnis, was offen bleibt.
Benenne ehrlich, was nicht geprüft werden konnte.
```
