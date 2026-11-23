# Vertrag 01 — Modlet-Grenzen und Ladereihenfolge

- **Status:** **Abgenommen vom Nutzer am 2026-11-22** (Entwurf vom 2026-11-07)
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
| `700_50_Fortschritt` | F-21 | Die ~~sechs~~ **fünf** Fertigkeitsbäume (D66, berichtigt bei der Abnahme am 2026-11-22), Perks, Abschriften | nein |
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

- ~~**Acht statt sechs Modlets** — Abweichung vom Plan, hier erstmals festgelegt. Abnahme nötig.~~ Abgenommen am 2026-11-22.
- Ob die reinen XML-Modlets mit aktivem EAC laden, ist Folgerung, nicht Nachweis (§4).
- Der Umgang mit dem alten `Mods/7DTD_700/` beim Aktualisieren ist noch nicht im Build-Skript.

## Nachtrag Phase 2, Teil 1 — Symbole im Modlet und die Test-Überlagerung, 2026-11-23, **Abnahme offen**

Geschrieben und gebaut im autonomen Lauf (Plan-0002 WP1.2, WP1.3, WP3.4), nach Claudes
Empfehlung; **zu prüfen durch den Nutzer** (N-19). Der abgenommene Text oben bleibt unverändert;
dieser Nachtrag ändert zwei seiner Sätze. Die übrigen Fragen der Phase 2 (wohin Wesen, Welt,
Händler, Magie gehören; wo Bundles liegen, wenn das Kern-Modlet mit EAC nicht lädt) folgen in
Teil 2 (Plan-0002 WP2.3).

### A. Ein Modlet darf Symbole tragen (ändert §5 Nr. 2)

§5 Nr. 2 sagt: „Keine Datei außerhalb von `Config/` (bis Phase 2 Assets dazukommen, und das
ändert dann diesen Vertrag)." **Neu:** ein Modlet darf zusätzlich
`UIAtlases/ItemIconAtlas/<Name>.png` tragen — eigene Symbole nach
[Vertrag 05](05-asset-pipeline.md), Teil A. Sonst weiter nichts außerhalb von `Config/`; die
Prüfung *Symbole* macht jede andere Datei unter `UIAtlases` rot.

**Reihenfolge, ehrlich:** die ersten vier Symbole liegen seit dem 2026-11-23 in
`700_20_Material` (Commits `f174d69`, `b98221c`) — gebaut auf Vertrag 05 (Entwurf), **bevor**
dieser Nachtrag geschrieben war. Der Widerspruch zu §5 Nr. 2 ist beim Schreiben dieses Nachtrags
aufgefallen, nicht vorher.

### B. Die Test-Überlagerung (ergänzt §2 und §6)

**Anlass.** Ein Spieltest, der eine halbe Stunde auf eine Fackel wartet, kostet mehr, als er
bringt (Vorgabe des Nutzers vom 2026-11-22: kurze Timer, gesammelt testen). Plan-0001 nannte die
Vorrichtung dafür „nicht entworfen".

**Was sie ist.** Ein neuntes Modlet `700_99_Test`, das **nur Zahlen verkürzt** — Brenndauern,
später Verderb, Odem, Grauen. Es gehört **nicht zur Mod**:

| | Mod (acht Modlets) | Test-Überlagerung |
|---|---|---|
| Ort im Repository | `mod/` | `test/700_99_Test/` |
| Im Paket `dist/Mods/` | ja | **nie** — `build.ps1` packt nur `mod/` und bricht ab, wenn ein Ordner `700_99*` im Paket liegt |
| Installation | `build.ps1 -Install` | nur `build.ps1 -Install -MitTest`; ein `-Install` **ohne** den Schalter entfernt sie |
| `smoke.ps1` | erwartet | eigener roter Punkt, wenn sie installiert ist; mit `smoke.ps1 -MitTest` erwartet |
| Ladereihenfolge | 00 bis 90 | 99 — zuletzt, damit sie jeden Wert der Mod überschreibt |

**Was sie darf.** Nur `ModInfo.xml` und XML unter `Config/`. Nur `<set>` — sie legt nichts an und
nimmt nichts weg; ohne sie fehlt der Mod nichts, mit ihr hat die Mod nichts, was sie sonst nicht
hätte. Jedes `<set>` muss einen Knoten treffen, den unsere Modlets hinterlassen, und seinen Wert
ändern. `-MitTest` ohne `-Install` ist ein Fehler.

**Die Prüfung** `tools/check/testueberlagerung-pruefen.ps1` (zehnte Prüfung in `check-all.ps1`;
Ausgänge 0 grün, 1 Befund, 2 nicht prüfbar) rechnet Vanillas Datei, darauf der Reihe nach die
gleichnamige Datei jedes Modlets, und wendet dann die Überlagerung an. Rot ist: eine Zeile trifft
nichts; eine Zeile ändert nichts; eine andere Operation als `<set>`; eine fremde Datei; ein Ordner
`700_99*` unter `mod/`; falscher Name oder fehlende `ModInfo.xml`. `kette-pruefen.ps1` kann das
nicht: es prüft XPaths gegen Vanilla, und die Ziele der Überlagerung legt erst die Mod an.

**Erste Fassung** (`test/700_99_Test/Config/blocks.xml`): die acht Lichtquellen aus F-08 brennen
`GrowthRate` 2 statt 30 (Wandfackel), 15 (Unschlittkerze Wand und Tisch), 60 (vier Öllampen), 45
(Holzfeuer). 2 ist Vanillas eigene Untergrenze („should be set no lower than 2"). Der Test
beantwortet damit drei Fragen in wenigen Minuten: geht jede Lichtquelle aus und wird zu ihrem
Ausgebrannt-Zustand; in welcher Einheit rechnet `GrowthRate`; was zeigt der Kerzenstumpf (N-03).

**Grenzen.**
- Ob ein Block, der unter der Überlagerung gesetzt wurde, seine kurze Uhr behält, wenn die
  Überlagerung wieder weg ist, ist **nicht gelesen**. Darum: nur für Test-Spielstände, nicht für
  einen, der bleiben soll.
- Die Prüfung rechnet bedingte Blöcke der Modlets nicht (heute betrifft das keine der Dateien, die
  die Überlagerung berührt: 0 übergangene Operationen).
- Im Spiel ist die Überlagerung nicht gelaufen. Dass ein neuntes Modlet mit `<set>` auf Knoten
  eines früheren greift, folgt aus der Ladereihenfolge (§2, Finding WP1) und ist dort belegt, aber
  für dieses Modlet nicht gesehen.

**Gegenproben** (Projektregel 5): 18 in `gegenproben.ps1`, Abschnitt „Test-Überlagerung" — 14
gegen die Prüfung (darunter: dieselbe Zeile trifft **ohne** das Modlet nichts — der Nachweis, dass
am Stand *nach* den Modlets gerechnet wird), 4 gegen `smoke.ps1` an einem nachgebauten
Spielordner. Lauf vom 2026-11-23: `powershell -File tools/check/check-all.ps1` — **270
Gegenproben, 0 fehlgeschlagen; 10 Prüfungen, 1 rot** (rot bleibt `resourceRepairKit` am Dump vom
22.11., N-01). `tools\build\build.ps1` ohne `-Install`: 8 Modlets, 42 Dateien, kein `700_99*` im
Paket, Signatur `Valid`; `build.ps1 -MitTest` ohne `-Install` bricht ab. **Nicht gelaufen:**
`-Install` und `-Install -MitTest` (keine Installation ohne Freigabe, N-11) — der
Installationszweig ist gelesen, nicht ausgeführt.

---

## Nachtrag Phase 2, Teil 1b — die Spielvorlage in `700_60_Welt`, 2026-11-23, **Abnahme offen**

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP1.5, D136). Abnahme: N-13.

1. `700_60_Welt` trägt `Config/sandbox_overrides.xml`. Die Datei gehört zur Welt, weil sie
   festlegt, unter welchen Regeln eine Welt angelegt wird; kein anderes Modlet fasst sie an.
2. Sie enthält **genau eine** Vorlage (`<preset name="700" … default="true" />`) und **kein**
   `<sandbox_override>` (Finding F-17: es sperrt nur das Bedienfeld und setzt keinen Wert).
3. Der Code der Vorlage besteht aus Vanillas Vorwahl und den Gruppen, die
   [`docs/konzept/voreinstellung-700.md`](../konzept/voreinstellung-700.md) §2 als gebaut führt.
   Eine weitere Gruppe kommt erst hinein, wenn sie dort steht und abgenommen ist.
4. Name und Beschreibung der Vorlage sind Sprachschlüssel im Sprach-Modlet (`700_vorlageName`,
   `700_vorlageDesc`); das Attribut `description` trägt denselben englischen Satz als Rückfall,
   weil eine Vorlage ohne Pflichtangabe nach F-17 vermutlich ohne Meldung wegfällt.

**Grenzen.** Die Vorlage wählt nur vor und wirkt auf einem Dedicated Server nicht (dort
`SandboxCode` in `serverconfig.xml`). Ob das Spiel sie anzeigt und vorwählt, ist nicht gesehen
(S-11). Der Code ist gerechnet; keine Prüfung im Repository kann ihn gegen das Spiel halten —
`kette-pruefen` sieht nur, dass der XPath `/sandbox_overrides` in Vanilla trifft.

## Nachtrag Phase 2, Teil 1c — Herausforderungen in `700_50_Fortschritt`, 2026-11-23, **Abnahme offen**

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP1.6, D137). Abnahme: N-12.

1. `700_50_Fortschritt` trägt `Config/challenges.xml`. Eine Herausforderung ist Fortschritt des
   Spielers, kein Gegenstand und kein Text; kein anderes Modlet fasst die Datei an. Der Purge
   (`700_10_Purge`) erzeugt sie **nicht**: ein Ziel ist kein Weg zu einem Gegenstand, und was an
   seine Stelle tritt, ist eine Entscheidung, keine Ableitung aus der Sperrliste.
2. Die Datei ist von Hand geschrieben (D53) und **biegt Ziele um**: `setattribute` und
   `removeattribute` an `challenge` und `objective`, `remove` nur an einem einzelnen `objective`.
   Sie entfernt **keinen** Knoten `challenge` und **keine** Gruppe, solange nicht gelesen ist,
   was ein alter Spielstand mit einer fehlenden Herausforderung tut (Finding F-18).
3. Die Kennung einer Herausforderung bleibt Vanillas Kennung, auch wenn das Ziel ein anderes
   ist (`craftPipeBomb` heißt im Spiel „Webstuhl bauen"). Das ist gewollt: Gruppe, Platz,
   Belohnung und der Fortschritt alter Spielstände hängen an der Kennung.
4. Titel, Kurztext und Beschreibung sind Vanillas Schlüssel, überschrieben im Sprach-Modlet;
   jeder überschriebene Schlüssel steht in `tools/check/vanilla-keys.txt`.
5. **Reihenfolge je Ziel:** erst alles, was das Ziel über seinen alten Gegenstand findet, zuletzt
   der Gegenstand selbst. Jede Zeile muss in Vanilla treffen (`kette-pruefen` rechnet jeden XPath
   einzeln gegen Vanilla) **und** nach den Zeilen davor.

**Grenzen.** Keine Prüfung im Repository weiß, ob ein Ziel erfüllbar ist — weder die neun neuen
noch die zehn, die stehen bleiben. Die Zahl „35" ist mit einem Skript außerhalb des Repositorys
gemessen. Ob das Spiel die neuen Ziele zählt, ist nicht gesehen (S-12).
