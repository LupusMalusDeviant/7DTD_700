# WP9 — Herstellen abgeschlossen, Schadenspfad, Schild, Wurf, Qualität

**Stand:** 23. November 2026 (Plan-0002 WP9.3; Bezug: F-21 D24/D48, F-02, D60, Vertrag 06, Vertrag 07)
**Build:** V 3.40 b10, Assembly-CSharp SHA-256 `cb54022c…56c58` · Soll-Datei `tools/meta/expect/wp93.tsv`
**Frage:** Braucht Lernen durch Tun (F-21) den ersten Harmony-Patch des Projekts, wie
`hook-hypothesen.md` F-21 und das Patch-Manifest annehmen? Und was gilt für Schild, zweite Hand,
Wurf und Qualität (F-02)?
**Methode:** `mod700meta types` / `members` (Typen, Felder, Aufrufe, Zeichenketten, Vergleichswerte)
und die Vanilla-XML. Kein Code übernommen. **Statisch gelesen, im Spiel nicht geprüft.**

## Kurz

1. **Vanilla zählt jedes fertig hergestellte Stück schon selbst** — in einem CVar je Gegenstand
   am Spieler, Name `_craftCount_` + Gegenstandsname, dazu `_xpFromCrafting`. Ein Buff kann diese
   Zahl mit `CVarCompare` lesen und mit `AddProgressionLevel` (71× in Vanillas XML) eine
   Fertigkeit heben. **Lernen durch Herstellen geht damit sehr wahrscheinlich ohne Patch.**
   Die Annahme „es gibt keinen XML-Auslöser, also C#" (Kurz-Check, Hook-Hypothesen F-21) ist
   **berichtigt**: es gibt keinen Auslöser, aber einen Zähler.
2. **Gezählt wird beim Spieler, nicht auf dem Server.** Der Abschluss läuft über die Oberfläche
   des Herstellens (`XUiC_RecipeStack`) bzw. — wenn der Spieler nicht an der Werkstatt stand —
   über `TileEntityWorkstation::CheckForCraftComplete(EntityPlayerLocal)` beim nächsten Besuch.
   Beides ist die Seite des Spielers. F-21 Nr. 4 („Server-autoritativ") passt nicht zu Vanilla.
3. **`onSelfItemCrafted` gibt es als Ereignis (Enum 84), es wird aber nicht ausgelöst** — weder
   in den 13 durchsuchten Typen gefunden, noch in Vanillas XML benutzt; Vanillas eigene Liste in
   `buffs.xml` und `item_modifiers.xml` führt es mit dem Vermerk *Hook Up* (noch anzuschließen).
4. **Schaden** wird auf der Seite gerechnet, der das getroffene Wesen gehört: `DamageEntity` liest
   `isEntityRemote` und schickt sonst ein `NetPackageDamageEntity`. Für einen getroffenen
   **Spieler** ist das sein eigener Rechner — dort, wo „Schild erhoben" ohnehin bekannt ist.
5. **Zweite Hand:** kein Typ mit `OffHand`, `SecondHand` oder `LeftHand` im Namen. Ein Schild
   neben einer Waffe ist im Code nicht vorgesehen (Indiz).
6. **Wurf:** `ItemActionThrownWeapon` (erbt von `ItemActionThrowAway`) ist im Code **vorhanden**;
   in `items.xml` ist er nur am Steinspeer gesetzt und dort **auskommentiert** (Zeile 4204). Aktiv
   werfen nur Sprengsachen (`ThrowAway`: Rohrbombe, Granate, Sprengladung, Dynamit).
7. **Qualität und Haltbarkeit:** `ItemValue.quality` ist `ushort`, `useTimes` ist `float`;
   Höchst-Haltbarkeit über `MaxUseTimes` (mit Mods). Farbe und Name einer Stufe kommen aus
   `QualityInfo` (`GetQualityColor(int)`, `GetQualityLevelName(int, bool)`). Welche Zahl die
   oberste sichtbare Stufe ist, ist hier **nicht** gelesen.

## 1. Der Abschluss eines Herstellvorgangs

| Stelle | gelesen | heißt |
|---|---|---|
| `XUiC_RecipeStack::outputStack()` | ruft `giveExp`, sonst `TileEntityWorkstation::AddCraftComplete`; Zeichenkette `craft_complete_item` | fertiges Stück geht in Inventar oder Ausgabe; wer nicht da ist, bekommt es gutgeschrieben |
| `XUiC_RecipeStack::giveExp(ItemValue, ItemClass)` | Zeichenketten `_craftCount_`, `_xpFromCrafting`; ruft `GetCustomVar`, `SetCustomVar`, `Progression::AddLevelExp` | **der Zähler je Gegenstand** und die Erfahrung |
| `TileEntityWorkstation::AddCraftComplete(int, ItemValue, string, string, int, int)` | legt `CraftCompleteData` ab (Ersteller, Stapel, Rezept, Erfahrung, Anzahl) | Werkstatt merkt sich Fertiges für Abwesende; wird mit der Werkstatt gespeichert (`writeCraftCompleteData`) |
| `TileEntityWorkstation::CheckForCraftComplete(EntityPlayerLocal)` | ruft `EntityPlayerLocal::GiveExp(CraftCompleteData)` | nachgereicht, wenn der Spieler wiederkommt |
| `EntityPlayerLocal::GiveExp(CraftCompleteData)` | dieselben zwei Zeichenketten, dieselben Aufrufe | auch der Nachtrag zählt |
| `QuestEventManager::CraftedItem(ItemStack)` | aus `outputStack`, `AddItemToInventory`, `Update`, `GiveExp` | Aufträge und Herausforderungen hören hier mit |

**Der Zähler ist ein `_`-CVar** (Vertrag 07 §2): nicht sofort gesendet, aber gespeichert —
er sollte einen Neustart überleben. Indiz, Test S-33 (2).

### Was das für F-21 heißt

Ein unsichtbarer Buff am Spieler mit einer Zeile je Schwelle, z. B. „`_craftCount_itm700_schwertEisen`
≥ 5 und Stufe Schmiedekunst < 2 → `AddProgressionLevel` Schmiedekunst". Die Abschriften bleiben die
Grundfähigkeit (F-21 Nr. 3). Offen und für den Bau zu klären:

- Kosten: eine Bedingung je Gegenstand und Schwelle. Bei vielen Rezepten wird der Buff lang; die
  `update_rate` des Buffs (Sekunden, nicht Bilder) hält das klein.
- Ob `CVarCompare` einen Namen mit `_` am Anfang liest wie jeden anderen (gelesen wird über
  `GetCustomVar` ohne Zeichenprüfung — Indiz ja).
- **Benutzen** statt Herstellen (Treffer, Abbau) läuft über bestehende Auslöser wie Vanillas
  Treffer- und Abbau-Ereignisse in `buffs.xml`; das ist nicht Teil dieses Findings.

## 2. Schaden, Schild, zweite Hand

| Stelle | gelesen | Indiz |
|---|---|---|
| `int EntityAlive::DamageEntity(DamageSource, int, bool, float)` | liest `Entity::isEntityRemote`, baut `NetPackageDamageEntity` über `World::entityDistributer` | ist das Wesen fremd, geht der Schaden als Paket an den Besitzer |
| `void EntityAlive::ProcessDamageResponse(DamageResponse)` | dasselbe Muster, ruft `ProcessDamageResponseLocal` | Antwort beim Besitzer |
| `void EntityAlive::ProcessDamageResponseLocal(DamageResponse)` | liest `GameManager::get_IsDedicatedServer`, löst Ereignisse aus (`FireEvent`) | Treffer-Ereignisse für Buffs |

**Für F-02 (Phase 3):** ein Postfix bzw. Prefix auf `DamageEntity` liefe beim Besitzer des
Getroffenen. Trifft ein Seuchentoter einen Spieler, ist das der Rechner des Spielers — dort ist
`cv700_schildErhoben` (Vertrag 07 §3.6) ohne Netzweg bekannt. Netz-Klasse daher vermutlich **S+C**
(jede Seite für ihre eigenen Wesen); Bestätigung im Dedicated-Test, Projektregel 5.

**Zweite Hand:** nicht gefunden. Der Schild ist in Phase 3 entweder das gehaltene Stück (dann ohne
Waffe) oder ein getragenes (Rüstungsplatz) — eine Entscheidung für F-02, kein Befund hier.

## 3. Wurf

Die Klasse für eine geworfene Waffe, die als Gegenstand liegen bleibt, ist **da**
(`ItemActionThrownWeapon::throwAway`, `instantiateProjectile`), Vanilla benutzt sie nicht. Ob sie
ohne Änderung trägt, zeigt nur ein Versuch: am Steinspeer die auskommentierte Zeile wieder setzen
(ein Test-Gegenstand in der Test-Überlagerung, nicht im Spiel-Modlet). Test S-33 (4).

## 4. Qualität und Haltbarkeit (D60)

`quality` `ushort` (0–65 535), `useTimes` `float`, Höchstwert `MaxUseTimes`. Für D60 (Material- und
Handwerksqualität) heißt das: der Datentyp setzt keine enge Grenze; eng sind Vanillas Farben und
Namen je Stufe in `QualityInfo`. Welche Stufen es sichtbar gibt und was oberhalb passiert, gehört
in die Triage (WP9.6) — dort mit Blick auf `QualityInfo` und `item_modifiers.xml`.

## Soll-Signaturen

`tools/meta/expect/wp93.tsv` (11 Zeilen): `giveExp`, `outputStack`, `AddCraftComplete`,
`CheckForCraftComplete`, `GiveExp`, `CraftedItem`, `DamageEntity`, `ProcessDamageResponse`,
`ProcessDamageResponseLocal`, `ItemActionThrownWeapon::throwAway`, `QualityInfo::GetQualityLevelName`.

## Folgen

- **Patch-Manifest:** F-21 steht nicht mehr als sicheres Patch-Ziel; Vermerk dort. Entschieden wird
  in der Triage (WP9.6) nach S-33.
- **F-21 Nr. 4** „Server-autoritativ" widerspricht Vanilla: Vanilla zählt beim Spieler. Der Zähler
  liegt im gespeicherten Spieler, nicht in einer Werkstatt-Datei auf dem Server. Notiert (N-113).
- **Vertrag 07 §3.5** sagte „Server schreibt"; berichtigt auf „Spieler (Vanilla zählt)".
