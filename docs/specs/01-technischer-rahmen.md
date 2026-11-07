# Spec 01 — Technischer Rahmen

Status: Entwurf. Aussagen mit **[verifizieren]** beruhen auf allgemeinem Modding-Wissen und
werden per REA oder Ingame-Test an der echten Zielversion bestätigt, bevor Code darauf aufbaut.

## 1. Zielplattform

| Punkt | Festlegung |
|---|---|
| Spiel | 7 Days to Die, **V2.x Stable** (Steam) |
| Exakter Build | wird beim ersten REA-Lauf festgehalten (`docs/rea/findings/00-build-baseline.md`) |
| Runtime | Unity / **Mono** (managed .NET). Damit ist die Spiellogik als CIL in `7DaysToDie_Data/Managed/Assembly-CSharp.dll` statisch analysierbar. **[verifizieren]**: nicht IL2CPP. |
| Server | Dedicated Server (Windows + Linux), gleiche Mod-Dateien |
| EAC | Muss für Server und Clients **aus** sein, sobald die C#-DLL geladen wird |

## 2. Mod-Architektur

```
Mods/7DTD_700/
├── ModInfo.xml                 # Mod-Metadaten (V2-Format) [verifizieren: Schema der Zielversion]
├── Config/                     # XPath-Modlets: set/append/remove/insertAfter …
│   ├── items.xml
│   ├── recipes.xml
│   ├── blocks.xml
│   ├── loot.xml
│   ├── progression.xml
│   ├── entityclasses.xml
│   ├── traders.xml
│   ├── buffs.xml
│   ├── gamestages.xml
│   ├── rwgmixer.xml / biomes.xml
│   ├── Localization.txt
│   └── XUi/ …                  # UI-Layout (Windows/Controls)
├── 7DTD_700.dll                # C#: IModApi-Einstieg + Harmony-Patches
├── Resources/*.unity3d         # Phase 2: AssetBundles (neue Modelle, Retexturen, Sounds)
├── UIAtlases/ItemIconAtlas/    # Phase 2: Item-Icons (PNG) [verifizieren: Pfad in V2.x]
└── Prefabs/                    # Phase 2: eigene POIs
```

### 2.3 Asset-Pipeline (ab Phase 2, Entscheidung D3)

| Punkt | Festlegung |
|---|---|
| Arten | **Retexturen** vorhandener Vanilla-Modelle und **neue Modelle** (Waffen, Schild, Werkstätten, Rüstungsteile) |
| Werkzeug | Unity-Editor in **exakt der Unity-Version des Spiels** [verifizieren: Version aus `Player.log` bzw. REA-Baseline]; Bundles per Editor-Skript bauen |
| Referenzierung | In XML über `#@modfolder:Resources/<bundle>.unity3d?<asset>` [verifizieren: Syntax in V2.x] |
| Shader | Nur Shader, die im Spiel vorhanden sind bzw. mit dem Bundle kompatibel sind; Test im Dedicated-Client |
| Quellen & Lizenz | Jedes Asset steht in `assets/ASSETS.md` mit Quelle, Autor, Lizenz und Änderungen. **Keine** Assets aus anderen Spielen oder Mods ohne ausdrückliche Lizenz (Q9) |
| Repo | Quell-Assets (`.blend`, `.psd`, Texturen) über **Git LFS** in `assets/`; gebaute Bundles nur im Release-Paket |
| Budget | Texturen max. 2048², Standard 1024²; LODs für alles, was in Mengen spawnt (Gegner, Blöcke) |
| Netz | Assets müssen auf **Clients** liegen. Ein Server mit Asset-Mod erfordert die Mod beim Client (wie die C#-DLL). |

Details und Arbeitsablauf: [F-16 Asset-Pipeline](../features/F-16-asset-pipeline.md).

### 2.1 Schichtenregel

1. **XML zuerst.** Alles, was über Werte, Rezepte, Loot, Progression, Buffs, Entity-Klassen
   oder Localization geht, wird per XPath gemacht.
2. **C# nur mit Begründung.** Jeder Patch hat im Feature-Dokument eine Zeile „Warum nicht XML?“.
3. **Harmony-Patch-Policy:**
   - `Prefix`/`Postfix` vor `Transpiler`. Transpiler nur mit REA-belegter CIL-Sequenz.
   - Ein Patch pro Datei, mit einem Header, der auf den REA-Finding-Eintrag verweist
     (Typ, Methode, Signatur, Build-Hash).
   - Kein `Prefix` mit `return false` ohne dokumentierte Begründung (kollidiert mit anderen Mods).
4. **Einstiegspunkt:** Klasse, die `IModApi` implementiert (`InitMod(Mod)`), und dort
   `new Harmony("…").PatchAll()`. **[verifizieren]**: Interface-Name und Signatur in V2.x.

### 2.2 Projektstruktur (Repo)

```
/docs                  GDD, Specs, Features, REA-Findings
/src/Mod700/           C#-Projekt (net48 bzw. das Target der Spiel-Assemblies [verifizieren])
/mod/Config/           XML-Modlets (Quelle)
/tools/rea/            Skripte, die REA lokal gegen die Spielinstallation laufen lassen
/tools/build/          Build → Mods/7DTD_700 packen
GameRefs/  (ignored)   lokale Kopien der Spiel-DLLs als Compile-Referenz
```

Spiel-DLLs werden nur **lokal** referenziert (Pfad per `Directory.Build.props`/Umgebungsvariable
`SDTD_PATH`), nie committet.

## 3. Multiplayer & Netzwerk

| Klasse | Bedeutung | Beispiel |
|---|---|---|
| **S** (Server) | Logik läuft nur auf dem Server/Host | Spawn-Regeln der Seuchennacht, Loot-Generierung |
| **C** (Client) | nur Darstellung/Eingabe | UI-Theming, Licht-Shader-Parameter |
| **S+C** | beide Seiten müssen identisch gepatcht sein | Schild-Blocken (Treffer-Berechnung + Animation) |

Regeln:
- Jedes Feature-Dokument klassifiziert seine Patches als S, C oder S+C.
- **XML-Configs:** Nach unserem Kenntnisstand verteilt der Server seine XML-Configs seit A20/A21 an
  die Clients, sodass reine XML-Modlets serverseitig reichen. Ausnahmen sind XUi und Assets.
  **[verifizieren]** in V2.x per Test: Client ohne Mod verbindet sich mit dem Mod-Server.
- **C#:** Muss auf Server und Clients liegen. Ein Versions-Handshake (Mod-Version im
  Connect prüfen) ist Teil von F-00.
- Eigene NetPackages nur, wenn REA zeigt, dass vorhandene Sync-Wege (Buffs, CVars,
  Entity-Stats) nicht reichen.

## 4. Kompatibilität & Update-Festigkeit

- **Update-Prozess:** Nach jedem Spiel-Patch `compare-managed-members` (REA) zwischen altem und
  neuem Build für **alle gepatchten Typen** laufen lassen. Geänderte Signaturen blockieren
  das Release (siehe `docs/rea/interface-discovery.md`, Abschnitt 5).
- Ein **Patch-Manifest** (`docs/rea/findings/patch-manifest.md`) listet jeden Harmony-Patch
  mit Zieltyp, Methode, Signatur, Build und Klassifikation S/C/S+C.
- XPath immer über stabile Attribute (`@name`) adressieren, nie über Positionen.

### 4.1 Kompatibilität mit UI-Mods (Entscheidung D5)

Andere Overhauls sind kein Ziel; **verbreitete UI-Mods sollen mitlaufen.** Daraus folgt:

1. **XUi nur additiv und zielgenau:** keine `remove`- oder `set`-Operationen auf ganze
   Fenster bzw. Window-Groups. Änderungen nur an einzelnen Attributen oder Kindelementen, die
   wir wirklich brauchen.
2. **Eigene Fenster und Controller** bekommen das Präfix `700_` und kollidieren dadurch nicht mit Namen anderer Mods.
3. **Theming über Farben und Sprites**, nicht über Layout-Umbauten. Layout-Änderungen nur,
   wo ein Feature sie zwingend braucht; dann im Feature-Dokument begründen.
4. **Keine Harmony-Patches auf `XUiC_*`-Controller**, solange XML reicht. Falls doch nötig,
   dann nur `Postfix`, nie `Prefix` mit `return false`.
5. **Ladereihenfolge:** Die Mod wird so gebaut, dass UI-Mods *danach* laden können
   (Ordnername bzw. `ModInfo`-Abhängigkeiten [verifizieren]).
6. **Testmatrix:** Mod allein + Mod mit jeder Referenz-UI-Mod (Q8). Kriterium: keine
   XML-Fehler im Log, alle 700-Fenster erreichbar.

## 5. Qualität & Tests

| Ebene | Prüfung |
|---|---|
| XML | Spielstart ohne XML-Fehler im Log (`output_log`/Konsole). Automatisierbar: Log nach `ERR`/`XML` greppen. |
| C# | Build gegen Spiel-Referenzen; Unit-Tests für reine Logik ohne Unity-Abhängigkeit |
| Patch-Ziele | REA-Check: Jeder Patch-Zielpunkt existiert mit der erwarteten Signatur im Ziel-Build |
| Ingame | Smoke-Checkliste je Feature (SP + Dedicated + 2. Client) |
| Anachronismen | Skript: Item-, Block- und Recipe-Namen gegen eine Denylist (gun, ammo, battery, …) prüfen |

## 6. Recht & Lizenz

- Spiel-DLLs, Assets und dekompilierter Code werden **nicht** veröffentlicht oder committet.
  Ins Repo kommen nur eigene Notizen: Typnamen, Signaturen, Beschreibungen.
- REA arbeitet statisch und lokal; Ziel ist Interoperabilität (Mod-Schnittstelle), nicht das
  Klonen des Spiels.
- Die EULA bzw. Modding-Richtlinie von The Fun Pimps erlaubt nach unserem Kenntnisstand
  Modding. **[verifizieren]** vor öffentlichem Release.
- Mod-Lizenz: offen (Vorschlag: MIT für Code, CC BY-NC-SA für Texte und Konzepte).
- Fremd-Assets nur mit dokumentierter Lizenz (`assets/ASSETS.md`), siehe 2.3.
