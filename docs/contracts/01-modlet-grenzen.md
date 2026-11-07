# Vertrag 01 — Modlet-Grenzen und Ladereihenfolge

- **Status:** Entwurf, wartet auf Abnahme
- **Datum:** 2026-11-07
- **Gilt ab:** Phase 1 (Plan-0001 WP1)
- **Entscheidung:** D53
- **Beleg:** [WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md)

Ein Vertrag ist bindend. Weicht die Umsetzung ab, wird **zuerst dieser Vertrag geändert und
erneut abgenommen**, dann gebaut — nicht umgekehrt.

## 1. Warum überhaupt mehrere Modlets

`XmlPatcher::LoadAndPatchConfig` nimmt einen Dateinamen und sucht dazu in jedem Modlet genau
eine gleichnamige Datei unter `Config/`. **Ein Modlet kann also nur eine `items.xml` haben.**
Phase 1 ändert `items.xml` aus fünf Features (F-01 Purge, F-02 Waffen, F-03 Rüstung, F-04
Werkstätten, F-05 Ressourcen). In einem Modlet lägen die alle in einer Datei, und wenn das Spiel
nicht startet, lässt sich nichts einzeln wegnehmen.

Tragfähig ist die Aufteilung, weil `ModManager::loadModsFromFolder` die Ordner mit
`System.Array::Sort` **selbst sortiert**. Die Reihenfolge hängt nicht am Dateisystem und gilt
damit auch auf dem Linux-Server.

## 2. Die Modlets

| Ordner | Features | Inhalt | DLL |
|---|---|---|---|
| `700_00_Core` | F-00 | `Mod700.dll`: `IModApi`-Einstieg, Build-Guard, Versions-Handshake | **ja** |
| `700_10_Purge` | F-01 | Anachronismen sperren, Loot und Händlerware leeren | nein |
| `700_20_Material` | F-05, F-04 | Ressourcen, Rohstoffketten, Werkstätten, Brennstoff | nein |
| `700_30_Ausruestung` | F-02, F-03 | Waffen, Rüstung, Qualitätsachsen, Verschleiß | nein |
| `700_40_Bauen` | F-18, F-08 | Bauteile, Befestigung, Lichtquellen, Fallen | nein |
| `700_50_Fortschritt` | F-21 | Die sechs Fertigkeitsbäume, Perks, Abschriften | nein |
| `700_60_Welt` | F-17 | Nachtwerte, Nebel, sichere Orte, Klangzuordnung | nein |
| `700_90_Sprache` | F-12 | `Localization.csv`, XUi-Theming | nein |

**Acht Modlets.** Der Plan sprach von sechs; die Aufteilung ist beim Schreiben dieses Vertrags
auf acht gewachsen, weil Bauen und Fortschritt eigene Schichten verdienen — beide lassen sich
abschalten, ohne dass der Rest bricht.

### Die Nummern sind die Reihenfolge

Das Zahlenpräfix ist **Pflicht**, nicht Geschmack: es ist der einzige Hebel, den der Lader
anbietet (`LoadBefore`/`LoadAfter` gibt es nicht). Die Lücken zwischen den Zehnern sind
Absicht — eine neue Schicht kommt später dazwischen, ohne alles umzubenennen.

Die Reihenfolge folgt einer Regel: **wer wegnimmt, kommt vor dem, der hinzufügt; wer benennt,
kommt zuletzt.**

1. `00_Core` — zuerst, damit der Build-Guard warnt, bevor Inhalt greift
2. `10_Purge` — nimmt weg
3. `20` bis `60` — fügen hinzu, in der Reihenfolge ihrer Abhängigkeiten (Material vor Ausrüstung,
   weil Rezepte Rohstoffe brauchen)
4. `90_Sprache` — zuletzt, weil Texte auf alles zeigen, was vorher entstanden ist

## 3. Was in welches Modlet gehört

**Die Regel:** Ein Modlet trägt die Änderungen **seiner** Features, auch wenn mehrere Modlets
dieselbe Vanilla-Datei anfassen. `items.xml` existiert also in `10_Purge`, `20_Material`,
`30_Ausruestung` und `40_Bauen` — jeweils mit dem Teil, der zu diesem Feature gehört.

**Was nicht passieren darf:** ein Modlet ändert etwas, das einem anderen gehört. Wer in
`30_Ausruestung` eine Werkstatt anfasst, hat sich im Ordner geirrt. Beim Suchen eines Fehlers
muss gelten: *Modlet weg → genau dieses Feature weg.*

**Grenzfälle, verbindlich entschieden:**

| Fall | Gehört nach | Grund |
|---|---|---|
| Rezept für eine Waffe | `30_Ausruestung` | das Rezept gehört zum Gegenstand, nicht zur Werkbank |
| Die Werkbank, auf der sie entsteht | `20_Material` | Werkstätten sind Material-Infrastruktur |
| `BlockDamage` der Gegner (D29) | `40_Bauen` | es ist eine Bau-Balancing-Zahl, auch wenn sie in `entityclasses.xml` steht |
| Perk, der ein Rezept freischaltet | `50_Fortschritt` | die Bindung gehört zum Baum |
| Anzeigename eines neuen Gegenstands | `90_Sprache` | **jeder** sichtbare Text, ausnahmslos |
| Sperren eines Vanilla-Gegenstands | `10_Purge` | auch wenn F-02 ihn ersetzt |

## 4. ModInfo.xml: eine je Modlet

Belegt liest `Mod::parseModInfoV2` genau sieben Felder. Verbindlich für alle acht Modlets:

| Feld | Wert | Pflicht |
|---|---|---|
| `Name` | der Ordnername, z. B. `700_20_Material` | ja, und **muss** auf `^[0-9a-zA-Z_\-]+$` passen |
| `DisplayName` | `700 — Material und Werkstätten` | ja |
| `Version` | **bei allen acht gleich**, siehe unten | per `Version.TryParse` lesbar |
| `Description` | ein Satz, was das Modlet macht | nein, aber wir setzen sie |
| `Author` | `Lupus Malus Deviant` | nein, aber wir setzen sie |
| `Website` | leer bis zum Release | nein |
| `SkipWithAntiCheat` | `true` bei `00_Core`, `false` bei den XML-Modlets | — |

Ein achtes Feld gibt es nicht. `Mod::get_AntiCheatCompatible` existiert im Code, kommt aber
**nicht** aus der `ModInfo.xml`.

### Die Versionsnummer ist überall dieselbe

Acht Modlets mit acht Versionen wären eine Fehlerquelle ohne Gegenwert. Darum: **eine Fassung für
die ganze Mod**, gesetzt an einer Stelle (`Directory.Build.props`), vom Build-Skript in alle acht
`ModInfo.xml` geschrieben. Ein Nutzer, der nur ein Modlet aktualisiert, baut sich einen Zustand,
den wir nicht testen — dagegen hilft keine Technik, aber eine einheitliche Nummer macht es
sichtbar.

### EAC

Nur `00_Core` trägt eine DLL. Belegt sitzt die EAC-Prüfung ausschließlich in
`Mod::LoadAssemblies` und spricht von *custom code* — die reinen XML-Modlets sollten darum auch
mit **aktivem** EAC laden. **Das ist eine Folgerung, kein Nachweis**, und sie wird beim ersten
Spielstart geprüft. Fällt sie positiv aus, lassen sich XML-Inhalte ohne EAC-Abschaltung testen.

## 5. Was ein Modlet nicht darf

1. **Keine ganze Vanilla-Datei ersetzen.** Nur zielgenaue Patches, siehe
   [Vertrag 03](03-xpath-regeln.md).
2. **Keine Datei außerhalb von `Config/`** (bis Phase 2 Assets dazukommen, und das ändert dann
   diesen Vertrag).
3. **Keine zweite DLL.** Code lebt in `00_Core`, nirgends sonst.
4. **Kein Modlet hängt von einem späteren ab.** `20_Material` darf nichts erwarten, was erst
   `50_Fortschritt` anlegt. Wo eine solche Abhängigkeit unvermeidlich ist, wandert der Patch in
   das spätere Modlet.

## 6. Paket und Installation

Das Build-Skript (`tools/build/build.ps1`) packt nach `dist/Mods/` und erzeugt dort alle acht
Ordner. Installiert wird der **gesamte Inhalt** von `dist/Mods/` nach `<Spielpfad>/Mods/`.

Für die Fehlersuche gilt die Umkehrung: ein Modlet-Ordner aus `Mods/` entfernen, Spiel starten,
schauen. Das ist der Zweck der ganzen Aufteilung.

Die vorhandene Installation heißt noch `Mods/7DTD_700/` und wird beim nächsten `-Install` durch
`700_00_Core` ersetzt. **Der alte Ordner muss von Hand weg**, sonst lädt die Mod zweimal — der
Lader meldet dann *„Mod with same name … already loaded, ignoring"*, aber nur, wenn das
`Name`-Feld gleich ist; bei unterschiedlichen Namen laufen beide. Das Build-Skript bekommt
dafür eine Warnung.

## 7. Offene Punkte dieses Vertrags

- **Acht statt sechs Modlets** — Abweichung vom Plan, hier erstmals festgelegt. Abnahme nötig.
- Ob die reinen XML-Modlets mit aktivem EAC laden, ist Folgerung, nicht Nachweis (§4).
- Der Umgang mit dem alten `Mods/7DTD_700/` beim Aktualisieren ist noch nicht im Build-Skript.
