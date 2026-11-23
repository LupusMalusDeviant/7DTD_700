# Vertrag 02 — Namensraum und Kennungen

- **Status:** **Abgenommen vom Nutzer am 2026-11-22** (Entwurf vom 2026-11-07)
- **Datum:** 2026-11-07
- **Gilt ab:** Phase 1 (Plan-0001 WP1)
- **Belege:** [F-00-modloader-events-version.md](../rea/findings/F-00-modloader-events-version.md) ·
  [WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md)

## 1. Die eine Regel, aus der alles folgt

**Eine Kennung ist technisch, ein Name ist sichtbar. Die zwei werden nie verwechselt.**

Eine Kennung (`itm700_spatha`) steht in XML, wird von XPath gefunden, von Rezepten referenziert
und ändert sich **nie** — auch dann nicht, wenn der Gegenstand im Spiel plötzlich anders heißt.
Ein Name (`Spatha`) steht ausschließlich in `Localization.csv` und darf sich jederzeit ändern.

Das klingt pedantisch, hat aber einen harten Grund: eine umbenannte Kennung bricht jeden
Spielstand, in dem der Gegenstand im Inventar einer Kiste liegt. Ein geänderter Anzeigename
bricht nichts.

## 2. Präfixe

| Art | Präfix | Beispiel |
|---|---|---|
| Gegenstand | `itm700_` | `itm700_spatha`, `itm700_schmiedeeisen` |
| Block | `blk700_` | `blk700_fachwerk`, `blk700_wandfackel` |
| Rezept | kein eigenes — Rezepte heißen wie ihr Ergebnis | `<recipe name="itm700_spatha">` |
| Buff | `buff700_` | `buff700_grauen`, `buff700_blutung` |
| CVar | `cv700_` | `cv700_grauen`, `cv700_schildErhoben` |
| Perk | `prk700_` | `prk700_klingenkunde` |
| Attribut (Baum) | `att700_` | `att700_krieger`, `att700_runenkundiger` |
| Loot-Gruppe | `lg700_` | `lg700_klosterTruhe` |
| Entity-Klasse | `ent700_` | `ent700_raeuberNahkampf` |
| Werkstatt-Block | `blk700_` wie andere Blöcke | `blk700_rennofen` |
| Localization-Schlüssel | `700_` | `700_itm_spatha`, `700_modName` |
| XUi-Element | `700_` | `700_WindowGrauen` |

**Warum unterschiedliche Präfixe je Art und nicht überall `700_`?** Weil XPath-Ausdrücke dadurch
lesbar werden und weil ein Suchlauf über alle Dateien sofort zeigt, womit man es zu tun hat. Ein
`grep "itm700_"` findet Gegenstände, nicht auch noch Buffs und CVars.

**Kleinschreibung nach dem Präfix, Binnengroßschreibung für mehrere Wörter:**
`itm700_langesKettenhemd`, nicht `itm700_langes_kettenhemd` und nicht `ITM700_LANGESKETTENHEMD`.
Das folgt dem Vanilla-Stil (`gunHandgunT1Pistol`, `cropsGrowingMaster`), und Vanilla-Stil zu
folgen heißt, weniger zu erklären.

## 3. Deutsch oder englisch in Kennungen?

**Deutsch.** `itm700_spatha`, `blk700_fachwerk`, `att700_runenkundiger`.

Begründung: Die Doku des Projekts ist deutsch, die Begriffe stehen im Glossar deutsch, und eine
Kennung ist kein Text für Spieler. Eine englische Kennung mit deutschem Anzeigenamen wäre eine
Übersetzungsschicht ohne Nutzen. Wo ein Begriff ohnehin lateinisch oder historisch ist (Spatha,
Sax, Gambeson, Sceatta), gibt es keine Frage.

**Ausnahme:** Technische Begriffe aus dem Spiel bleiben, wie sie sind. Ein `RequiredPower` heißt
nicht `BenoetigteKraft`, weil das Spiel das Attribut so liest.

## 4. Der Mod-Name läuft über einen Schlüssel

D6: der Arbeitstitel bleibt bis zum Release. Damit die Umbenennung später **eine Zeile** ist,
steht der sichtbare Mod-Name ausschließlich unter dem Localization-Schlüssel `700_modName` und
wird nirgends sonst ausgeschrieben.

Die `ModInfo.xml`-Felder `Name` und `DisplayName` sind davon ausgenommen — die liest der Lader,
bevor Localization existiert. `Name` ist überdies an die belegte Laderegel gebunden:

```
^[0-9a-zA-Z_\-]+$
```

aus `Mod::.cctor` (`nameValidationRegex`, `RegexOptions.Compiled`). Keine Leerzeichen, keine
Punkte, nichts außer Buchstaben, Ziffern, `_` und `-`. `700_20_Material` besteht sie,
`700 Material` nicht. Verstöße enden beim Spielstart mit *„does not define a valid non-empty
Name"*.

## 5. Localization

Die Datei heißt **`Config/Localization.csv`** — belegt, eine `Localization.txt` gibt es im Spiel
nicht. Kopfzeile der ausgelieferten Datei:

```
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english,
Context / Alternate Text,german,spanish,french,italian,japanese,koreana,
polish,brazilian,russian,turkish,schinese,tchinese
```

**Verbindlich:**

1. **Alle 20 Spalten schreiben**, auch die leeren. Eine Zeile mit drei Spalten trifft die
   falschen Felder.
2. **`english` und `german` füllen** (D7), die zwölf übrigen Sprachspalten **leer lassen** — nicht
   mit dem englischen Text auffüllen. Eine leere Spalte zeigt „nicht übersetzt", eine gefüllte
   lügt.
3. **`Context / Alternate Text` ist keine Sprache.** Sie steht zwischen `english` und `german`
   und nimmt Hinweise für Übersetzer. Wer sie als Deutsch behandelt, schreibt den deutschen Text
   in die Kommentarspalte.
4. **Schlüssel genau einmal.** Doppelte Schlüssel verwirft `Localization::addCsv` stillschweigend
   bis auf eine Protokollzeile. Das Prüfwerkzeug aus [Vertrag 04](04-pruefwerkzeuge.md) fängt das.
5. **Kein Schlüssel ohne `700_`-Präfix**, außer wenn ein Vanilla-Schlüssel absichtlich
   überschrieben wird — und das gehört in eine eigene, kommentierte Gruppe in der Datei.

### Schlüssel-Aufbau

> **BERICHTIGT am 8. November 2026 in WP4.6 — abgenommen am 2026-11-22.** Der Aufbau unten war
> **falsch und nicht umsetzbar.** Er stand da, bevor ein eigener Gegenstand existierte; beim
> ersten (`itm700_luppe`) ist er aufgefallen. Der neue Aufbau steht darunter.
>
> ```
> 700_<art>_<kennung ohne präfix>          700_itm_spatha      <-- funktioniert NICHT
> 700_<art>_<kennung>Desc                  700_itm_spathaDesc
> ```
>
> **Warum nicht:** In 7DTD ist der Sprachschlüssel eines Gegenstands **seine Kennung
> selbst**. Es gibt keine Eigenschaft, mit der ein Gegenstand auf einen anderen
> Namensschlüssel zeigen könnte — `ItemClass::GetLocalizedItemName` liest nur das Feld
> `localizedName`, das beim Laden aus der Kennung gefüllt wird, und in den ausgelieferten
> `items.xml` und `blocks.xml` gibt es **1124 `DescriptionKey`-Einträge und null**
> Eigenschaften für einen Namensschlüssel. Die Vanilla-`Localization.csv` bestätigt es von
> der anderen Seite: jeder Gegenstandsschlüssel ist wörtlich der Gegenstandsname.
>
> Ein Gegenstand `itm700_spatha` mit dem Schlüssel `700_itm_spatha` hätte also schlicht
> keinen Namen — im Inventar stünde die Kennung. Der alte Aufbau wäre mit §2 nur
> vereinbar, wenn Gegenstände `700_itm_spatha` **hießen**, und das widerspricht §2.
>
> **Der Schlüssel ist die Kennung.** Punkt 5 oben liest sich damit so: ein Schlüssel ist
> entweder ein bewusst überschriebener Vanilla-Schlüssel (Liste in
> `tools/check/vanilla-keys.txt`) oder er trägt **eines der Präfixe aus §2** —
> `itm700_`, `blk700_`, `buff700_`, `cv700_`, `prk700_`, `att700_`, `lg700_`, `ent700_` —
> oder `700_` selbst für alles, was keine Kennung ist (`700_modName`, XUi-Elemente).
> `mod700check localization --prefix` nimmt dafür seit WP4.6 eine Liste statt eines
> einzelnen Präfixes; `check-all.ps1` übergibt genau die Liste aus §2.

```
<kennung>                                itm700_spatha
<kennung>Desc                            itm700_spathaDesc
700_<name>                               700_modName, 700_WindowGrauen
```

Beschreibungstexte hängen `Desc` an. Das folgt dem Vanilla-Muster (`itemNameDesc`).

## 6. Ortsnamen und Personennamen (D1)

Das Mischland ist erfunden. Verbindlich:

- **Ortsnamen:** erfunden, aber frühmittelalterlich klingend, mit den Endungen `-heim`, `-feld`,
  `-wik`, `-grad`, `-dun`, `-ing`. Beispiele: *Ascheheim*, *Rabenwik*, *Steindun*.
- **Keine realen Orte**, keine realen Herrscher, keine realen Völkernamen als Gegnerfraktion.
- **Personennamen** aus dem germanischen, romanischen, slawischen und keltischen Namensschatz
  der Zeit — gemischt, weil das Land gemischt ist.
- **Keine Namen aus anderen Mods oder Spielen** (Projektregel 7). Das gilt auch für
  Gegenstandsnamen, die „typisch" klingen.

Jeder Name, der im Spiel auftaucht, steht vorher im Glossar (`docs/glossar.md`). Das Glossar ist
die Quelle, nicht die Nachdokumentation.

## 7. Dateinamen im Repo

| Was | Muster |
|---|---|
| Modlet-Ordner | `700_NN_Name` (Zahlenpräfix, siehe Vertrag 01) |
| Config-Datei im Modlet | **genau** der Vanilla-Name (`items.xml`), sonst findet der Patcher sie nicht |
| Finding | `docs/rea/findings/<Feature oder Thema>-<stichwort>.md` |
| Vertrag | `docs/contracts/NN-stichwort.md` |
| Plan | `docs/plans/NNNN-slug.md` |
| Balancing-Tabelle | `docs/balancing/<feature>.md` |

## 8. Offene Punkte dieses Vertrags

- Die Präfix-Liste in §2 deckt ab, was Phase 1 braucht. Quests, Dialoge und POIs kommen in
  Phase 2 bzw. 3 dazu und erweitern diesen Vertrag dann.
- Ob ein Vanilla-Localization-Schlüssel überschrieben werden **darf**, ohne andere Mods zu
  stören, ist nicht geprüft. Bis dahin: nur wo unvermeidlich, und kommentiert.

## Nachtrag Phase 2 — Namensraum für Wesen, Welt, Handel und Assets, 2026-11-23, **Abnahme offen**

Entwurf im autonomen Lauf (Plan-0002 WP2.4), nach Claudes Empfehlung; **zu prüfen durch den
Nutzer** (N-35). Der abgenommene Text oben bleibt unverändert. Kennungen dieser Arten gibt es
noch nicht — der Nachtrag steht, bevor die erste entsteht.

### A. Präfixe (ergänzt §2)

| Art | Datei | Präfix | Beispiel |
|---|---|---|---|
| Wesen-Klasse | `entityclasses.xml` | `ent700_` (besteht) | `ent700_seuchentoterKnecht` |
| Wesen-Gruppe | `entitygroups.xml` | `eg700_` | `eg700_waldNacht` |
| Spawner der Spielstufen | `gamestages.xml` | `gs700_` | `gs700_seuchennacht` |
| Klang | `sounds.xml` | `snd700_` | `snd700_seuchentoterRuf` |
| Spielereignis (Folge) | `gameevents.xml` | `ge700_` | `ge700_seuchennachtBeginn` |
| Auftrag | `quests.xml` | `q700_` | `q700_brunnenWeihen` |
| Auftragsliste | `quests.xml` | `ql700_` | `ql700_schmiedStufe1` |
| Warengruppe eines Händlers | `traders.xml` | `tg700_` | `tg700_heilkraeuter` |
| Dialog | `dialogs.xml` | `dlg700_` | `dlg700_schmied` |
| Figur | `npc.xml` | `npc700_` | `npc700_schmied` |
| Beute-Behälter | `loot.xml` | `lc700_` | `lc700_klosterTruhe` |
| Beute-Gruppe | `loot.xml` | `lg700_` (besteht) | |
| Herausforderung, neu | `challenges.xml` | `ch700_` | `ch700_runeRitzen` |
| Gruppe von Herausforderungen, neu | `challenges.xml` | `chg700_` | `chg700_runenkundiger` |
| Ort (Prefab) | `Prefabs/` | `poi700_` | `poi700_gehoeft_01` |
| Bundle | `Resources/` | `b700_` | `b700_wesen.unity3d` |
| Symbol | `UIAtlases/ItemIconAtlas/` | `ico700_` (Vertrag 05) | `ico700_silberpfennig` |
| Buff, CVar | `buffs.xml` | `buff700_`, `cv700_` (bestehen) | `buff700_grauen`, `cv700_grauen` |

Schreibweise wie §2: Kleinschreibung nach dem Präfix, Binnengroßschreibung, deutsch nach §3.

**Drei Klarstellungen:**

1. **CVars heißen `cv700_…`, nicht `700_…`.** F-15 und F-17 schreiben `700_odem`, `700_odemMax`,
   `700_grauen`; das sind Entwürfe von vor diesem Vertrag. Gebaut wird `cv700_odem`,
   `cv700_odemMax`, `cv700_grauen` (so steht `cv700_grauen` seit Phase 1 in §2). Die
   Feature-Dokumente werden beim Bau nachgezogen. **[verifizieren, WP9]** Ob das Spiel dem
   ersten Zeichen eines CVar-Namens eine Bedeutung gibt (gespeichert oder nicht, an Mitspieler
   gesendet oder nicht), ist nicht gelesen — vor dem ersten neuen CVar zu lesen.
2. **Was Vanillas Kennung behält, bekommt kein Präfix.** Ein umgedeuteter Vanilla-Gegenstand,
   ein Händler (`trader_info` trägt eine Zahl, keinen Namen), eine umgebogene Herausforderung
   (Vertrag 01, Teil 1c): die Kennung bleibt, der Anzeigename ändert sich. Ein Präfix steht nur
   an dem, was wir **anlegen**.
3. **Eine Kennung ist kein Anzeigename** (§1). `ent700_seuchentoterKnecht` sagt dem Bauenden,
   was es ist; was der Spieler liest, steht im Sprach-Modlet und vorher im Glossar.

### B. Namensmuster für Anzeigenamen (ergänzt §6)

Verbindlich ist die **Form**; jeder einzelne Name bleibt Vorschlag, bis er im Glossar abgenommen
ist (P2-E11).

| Was | Muster | Beispiel | Nicht |
|---|---|---|---|
| Seuchentote (Grundtypen) | Art + **Stand oder Herkunft**, kein Vorname | „Seuchentoter Knecht", „Seuchentote Magd" | „Zombie", ein Eigenname, eine Berufsbezeichnung der Neuzeit |
| Besondere Wesen | **ein** Wort aus dem Glossar, deutsch und englisch festgelegt | „Moorleiche", „Verderbter" | zusammengesetzte Kunstwörter, Namen aus anderen Spielen oder Mods (Projektregel 7) |
| Tiere | der gewöhnliche Name | „Wolf", „Keiler" | |
| Orte | §6: erfunden, mit `-heim`, `-feld`, `-wik`, `-grad`, `-dun`, `-ing` | „Rabenwik" | reale Orte |
| Ortstypen (wo kein Eigenname steht) | Gattung | „Gehöft", „Mühle", „Kapelle" | Neuzeit-Gattungen („Tankstelle") |
| Händler | **Posten**, dazu ein Personenname nach §6 | „Schmied Radulf" | Vanillas Namen und Stimmen (D102) |
| Aufträge | Tätigkeit im Infinitiv oder als Hauptwort | „Brunnen weihen" | Stufen-Jargon („Tier 2") |

Offen und beim Nutzer (Textlücken §8 Nr. 5): die **englischen** Wörter für Verderbte und
Moorleichen, und ob der Name eines Wesens im Spiel überhaupt erscheint — vor dem Schreiben zu
messen (WP5).
