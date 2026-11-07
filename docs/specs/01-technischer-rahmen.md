# Spec 01 — Technischer Rahmen

Status: Entwurf. Aussagen mit **[verifizieren]** beruhen auf allgemeinem Modding-Wissen und
werden per REA oder Ingame-Test an der echten Zielversion bestätigt, bevor Code darauf aufbaut.

## 1. Zielplattform

| Punkt | Festlegung |
|---|---|
| Spiel | 7 Days to Die, **V 3.40 Stable** (Steam), Release-Typ `V`, Major 3, Minor 40, Build 10 — Entscheidung **D52** |
| Exakter Build | Steam-Build **26309840**, Branch `public`. `Assembly-CSharp.dll` SHA-256 `cb54022c…56c58`, MVID `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480`. Festgehalten in [`../rea/findings/00-build-baseline.md`](../rea/findings/00-build-baseline.md) |
| Runtime | Unity **2022.3.62f2** / **Mono** (managed .NET). **Belegt**: REA-Klassifikation `runtime_family: unity-mono`, `implementation: cil`, CLI-Flag `il-only` — **kein IL2CPP**. Die Spiellogik ist als CIL in `7DaysToDie_Data/Managed/Assembly-CSharp.dll` statisch analysierbar. |
| Target-Framework | `net48` — **abgeleitet** aus den AssemblyRefs (`mscorlib 4.0.0.0`, `netstandard 2.1.0.0`), nicht belegt. `Assembly-CSharp.dll` trägt kein `TargetFrameworkAttribute`. Gilt erst mit dem ersten durchlaufenden Build. |
| Server | Dedicated Server (Windows + Linux), gleiche Mod-Dateien |
| EAC | Muss für Server und Clients **aus** sein, sobald die C#-DLL geladen wird |

## 2. Mod-Architektur

> ~~Ursprünglich festgelegt: **ein** Modlet `Mods/7DTD_700/` mit einem `Config/`-Ordner.~~
> **Geändert am 2026-11-07 durch D53: mehrere Modlets.** Grund: belegt trägt ein Modlet nur
> **eine** Datei je Vanilla-Config, weil `XmlPatcher::LoadAndPatchConfig` je Dateiname genau
> `<Modlet>/Config/<gleicher Name>` sucht. In einem Modlet lägen die `items.xml`-Änderungen von
> F-01 bis F-05 zusammen in einer Datei, und keine Schicht wäre zum Debuggen abschaltbar.

```
Mods/
├── 700_00_Core/                # einziges Modlet mit Code — braucht EAC aus
│   ├── ModInfo.xml
│   └── Mod700.dll              # C#: IModApi-Einstieg, Build-Guard, Versions-Handshake
├── 700_10_Purge/               # F-01  Anachronismen sperren
├── 700_20_Material/            # F-05, F-04  Ressourcen, Ketten, Werkstätten
├── 700_30_Ausruestung/         # F-02, F-03  Waffen, Rüstung, Qualität, Verschleiß
├── 700_40_Bauen/               # F-18, F-08  Bauteile, Befestigung, Licht und Feuer
├── 700_50_Fortschritt/         # F-21  die sechs Fertigkeitsbäume
├── 700_60_Welt/                # F-17  Nachtwerte, Nebel, sichere Orte
└── 700_90_Sprache/             # F-12  Localization und XUi-Theming — zuletzt
```

Jedes Inhalts-Modlet hat denselben Aufbau:

```
700_NN_Name/
├── ModInfo.xml                 # V2-Format — BELEGT: Wurzel <xml>, Felder als direkte Kinder
│                               # mit value="…"; parseModInfoV2 liest genau sieben Felder:
│                               # Name (Pflicht, Regex ^[0-9a-zA-Z_\-]+$), DisplayName (Pflicht),
│                               # Version, Description, Author, Website, SkipWithAntiCheat.
│                               # Altformat lädt nicht mehr. Siehe F-00-Finding.
└── Config/                     # XPath-Patches, Dateiname = Name der Vanilla-Datei
    ├── items.xml               # 52 patchbare Dateien, namentlich belegt in
    ├── recipes.xml             # StockFileHashes::.cctor
    ├── blocks.xml
    ├── loot.xml
    ├── progression.xml
    ├── entityclasses.xml
    ├── traders.xml
    ├── buffs.xml
    ├── worldglobal.xml
    ├── biomes.xml / rwgmixer.xml
    ├── Localization.csv        # BELEGT: .csv, nicht .txt — Localization.txt gibt es im Spiel
    │                           # nicht. Kopfzeile mit fünf Metadatenspalten, dann die Sprachen.
    ├── XUi_Common/             # styles.xml, templates.xml
    ├── XUi_InGame/             # styles.xml, templates.xml, windows.xml, xui.xml
    └── XUi_Menu/               # vom Lader erkannt (Mod::DetectContents)
```

Phase 2 ergänzt im Core-Modlet: `Resources/*.unity3d` (AssetBundles),
`UIAtlases/ItemIconAtlas/` (Item-Icons, **[verifizieren]**: Pfad in V 3.40), `Prefabs/`
(eigene POIs).

**Ladereihenfolge:** allein über den Ordnernamen. `ModManager::loadModsFromFolder` ruft
`SdDirectory::GetDirectories` und danach `System.Array::Sort` — die Reihenfolge ist damit
zugesichert und plattformunabhängig. `LoadBefore`/`LoadAfter` oder Abhängigkeits-Deklarationen
gibt es **nicht**.

**EAC:** Die Prüfung sitzt ausschließlich in `Mod::LoadAssemblies` und spricht von *custom code*.
Nur `700_00_Core` trägt eine DLL und braucht EAC aus; die reinen XML-Modlets sollten mit aktivem
EAC laden. **Folgerung, kein Nachweis** — beim ersten Spielstart zu bestätigen.

Belege zu diesem Abschnitt:
[WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md).

### 2.3 Asset-Pipeline (ab Phase 2, Entscheidung D3)

| Punkt | Festlegung |
|---|---|
| Arten | **Retexturen** vorhandener Vanilla-Modelle und **neue Modelle** (Waffen, Schild, Werkstätten, Rüstungsteile) |
| Werkzeug | Unity-Editor in **exakt der Unity-Version des Spiels** Unity **2022.3.62f2**, belegt in der Baseline; Bundles per Editor-Skript bauen |
| Referenzierung | In XML über `#@modfolder:Resources/<bundle>.unity3d?<asset>` [verifizieren: Syntax in V 3.40] |
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
4. **Einstiegspunkt (belegt):** Klasse, die `IModApi` implementiert — `void IModApi::InitMod(Mod)`.
   Sie muss `public`, nicht abstrakt und mit **öffentlichem parameterlosem Konstruktor** sein,
   weil `Mod::InitModCode` sie per `Activator.CreateInstance` erzeugt. Dort dann
   `new Harmony("…").PatchAll()` — gegen das **vom Spiel vorgeladene** HarmonyX 2.13.0.0 aus
   `Mods/0_TFP_Harmony/`; die Mod liefert **kein** eigenes `0Harmony.dll` mit.
   Siehe [`../rea/findings/F-00-modloader-events-version.md`](../rea/findings/F-00-modloader-events-version.md).
5. **Mod-API vor Patch:** `ModEvents` bietet 22 Events, vier davon unterbrechbar
   (`MainMenuOpening`, `PlayerLogin`, `GameMessage`, `ChatMessage`). Versions-Handshake und
   Build-Guard laufen darüber bzw. über `VersionInformation.CompareToRunningBuild()` und
   brauchen **keinen** Harmony-Patch.

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
  **[verifizieren]** in V 3.40 per Test: Client ohne Mod verbindet sich mit dem Mod-Server.
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
