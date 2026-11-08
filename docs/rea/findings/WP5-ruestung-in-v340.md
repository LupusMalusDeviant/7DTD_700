# WP5 — Wie Rüstung in V 3.40 gebaut ist, und warum unsere fünf Stufen nicht hineinpassen

**Stand:** 8. November 2026
**Frage:** D59 sagt „eigene Rüstungsteile auf Vanillas drei Gewichtsklassen, Modelle aus den
gesperrten Garnituren geborgt". Drei Dinge waren davor zu messen: welche Modelle es gibt, wie
der Set-Bonus entsteht, und welche Zahlen gelten.
**Antwort:** Alle drei gemessen. Dabei kommt eine vierte Frage heraus, die niemand gestellt
hatte — und sie gehört dem Nutzer.

**Quelle:** `Data/Config/items.xml` und `buffs.xml` der Installation (V 3.40, Build 10). Reine
XML-Messung, keine Assembly gelesen. Der `ConfigsDump` vom 7. Juli taugt hier nicht: er ist
die gemergte Config eines Spielstands, und für Pfade in Prefabs zählt die Auslieferung.

## 1. Die Modelle kommen aus einem Prefab-Pfad, und vier Slots teilen sich einen

Ein Rüstungsteil trägt seinen Körper nicht als `Meshfile`, sondern in einem eigenen Block:

```xml
<property class="SDCS">
    <property name="Prefab" value="@:Entities/Player/{sex}/Gear/Fiber/gear{sex}FiberPrefab.prefab"/>
    <property name="TransformName" value="body"/>
</property>
```

`{sex}` füllt das Spiel. **Alle vier Teile einer Garnitur zeigen auf denselben Pfad** — der
Prefab enthält die ganze Ausrüstung, und `EquipSlot` entscheidet, welcher Teil davon
erscheint. Das heißt: ein geborgter Pfad bringt Rumpf, Kopf, Hände und Füße in einem.

**Nicht bei allen.** Elf Garnituren holen ihren Helm aus einer Kopf-Matrix statt aus dem
Gear-Prefab, mit zwei weiteren Platzhaltern:

```
@:Entities/Player/{sex}/Gear/Farmer/HeadgearMorphMatrix/{race}{variant}/gearFarmer{hair}Head.asset
```

`{race}`, `{variant}` und `{hair}` füllt das Spiel aus dem Aussehen des Spielers. Wer von dort
borgt, borgt eine Mechanik mit, die wir nicht geprüft haben.

**Fünf Garnituren des Grundspiels brauchen keine Kopf-Matrix** — bei ihnen steckt der Helm im
Gear-Prefab, alle vier Teile auf einem Pfad:

| Garnitur | Prefab-Ordner | Stand nach WP3 |
|---|---|---|
| `armorPrimitive*` | `Gear/Fiber/` | **erlaubt**, unser T0 |
| `armorAssassin*` | `Gear/Assassin/` | gesperrt |
| `armorNomad*` | `Gear/Nomad/` | gesperrt |
| `armorRaider*` | `Gear/Raider/` | gesperrt |
| `armorRogue*` | `Gear/Stealth/` | gesperrt |

Die übrigen Pfade liegen unter `@:DLC/…` oder `@:TwitchDrops/…`. **Davon borgen wir nicht:**
ein DLC-Bündel ist auf dem Rechner eines Spielers, der das DLC nicht hat, nicht vorhanden, und
ein fehlender Pfad ist ein unsichtbarer Spieler. Vier geborgte Garnituren des Grundspiels
reichen für T1 bis T4 genau.

**Was hier nicht gemessen ist:** ob ein Gear-Prefab lädt, wenn kein Vanilla-Gegenstand mehr
darauf zeigt. Der Purge nimmt den gesperrten Garnituren ihre **Wege**, nicht ihre Definition —
die Gegenstände stehen weiter in `items.xml`, und der Pfad bleibt damit referenziert. Das
spricht dafür; bewiesen ist es erst im Spiel (**WP3.6**).

## 2. Der Set-Bonus hängt an `ArmorGroup`, und er ist wiederverwendbar

Jedes Teil nennt seine Garnitur: `<property name="ArmorGroup" value="groupNomad"/>`. In
`buffs.xml` steht je Garnitur **ein** Paar Regeln, zentral und nicht im Gegenstand:

```xml
<triggered_effect trigger="onSelfBuffUpdate" action="RemoveBuff" buff="buffNomadSetBonus">
    <requirement name="ArmorGroupCount" group_name="groupNomad" operation="LTE" value="3"/>
    …
<triggered_effect trigger="onSelfBuffUpdate" action="AddBuff" buff="buffNomadSetBonus">
    <requirement name="ArmorGroupCount" group_name="groupNomad" operation="Equals" value="4"/>
```

Vier Teile derselben Gruppe → der Buff kommt. Der Buff selbst staffelt sich über
`ArmorGroupLowestQuality` in sechs Stufen; bei Nomad sind es 5 % bis 30 % weniger Nahrungs-
und Wasserverlust je Ausdauerpunkt, dazu eine CVar für die Anzeige im Tooltip.

**Daraus folgt der günstige Weg:** behalten unsere Teile die Gruppe der Garnitur, von der sie
den Prefab borgen, dann **wirkt Vanillas Bonus unverändert** und es ist nur ein
Sprachschlüssel zu setzen (`buffNomadSetBonusName`, `…Desc`, `…Tooltip`). Kein `buffs.xml`-
Patch, keine eigene Gruppe. Das ist genau „Set-Boni über die vorhandene Rüstungsset-Logik:
Zuordnung umdeuten" aus F-03 — und es geht nur, weil die Vanilla-Garnitur unerreichbar ist:
die Gruppe lässt sich nur noch mit **unseren** vier Teilen vollmachen.

Es gibt 58 solche Gruppen. Die vier, die wir brauchen, sind `groupAssassin`, `groupNomad`,
`groupRaider`, `groupRogue`.

## 3. Die Zahlen sind nicht zu erfinden — sie hängen an der Gewichtsklasse

Gemessen an neun Garnituren des Grundspiels, je das Rumpfteil:

| Garnitur | erbt von | `PhysicalDamageResist` (Stufe 1→6) | `DegradationMax` | `Mobility` |
|---|---|---|---|---|
| Primitive | `armorPrimitiveMaster` | 8 → 12,3 | 250 → 500 | — |
| Rogue, Preacher | `armorLightMaster` | 8 → 12,3 | 250 → 500 | — |
| Farmer, Assassin, Ranger, Scavenger | `armorMediumMaster` | 13 → 17,3 | 250 → 500 | −0,05 |
| Nomad, Raider | `armorHeavyMaster` | 18 → 21 | 250 → 500 | −0,075 |

**Die Werte sind je Gewichtsklasse identisch, über alle Garnituren hinweg.** Eine Garnitur
unterscheidet sich von der anderen derselben Klasse nur durch Modell, Set-Bonus und Preis.
Für uns heißt das: **nichts zu erfinden.** Unsere Teile nehmen die Zahlen ihrer Klasse, und
der Punkt „welche Zahlen gelten" ist damit erledigt, nicht nach WP9 verschoben.

Die Begleitwerte dazu, ebenfalls je Klasse: `Tags` tragen `lightArmor`/`mediumArmor`/
`heavyArmor` plus `…Penalty` (nicht bei leicht), `…Deg` und `armor…Skill`; `StaminaChangeOT`
−4,5 % beim Gehen und −9 % beim Laufen (schwer); `ModSlots` 2–5 (schwer) gegen 1–2
(primitiv). `EquipSlot` ist `Chest`, `Head`, `Hands`, `Feet`, und die `Tags` nennen den Slot
doppelt (`upperbody,chest,armor,armorChest`).

Vanillas Tag **`biomeChallenge`** steht an jedem Rüstungsteil außer den primitiven. Er bedeutet
„zählt für den Biom-Fortschritt" und ist genau der Tag, über den WP3 **keine** Regel gebaut
hat, weil er nur zufällig richtig läge (Kommentar in `denylist.txt`). Unsere Teile sollten ihn
tragen, sonst fehlt dem Spieler ein Stück Biom-Fortschritt — das ist eine Setzung, kein
Messergebnis.

## 4. Die vierte Frage, die dabei herauskommt: V 3.40 hat keine Rüstungsstufen

F-03 will **fünf** Stufen, T0 bis T4. V 3.40 hat **drei Gewichtsklassen** und sonst nichts:
die Stufe eines Rüstungsteils ist seine **Qualität 1–6**, und die ist keine Materialstufe,
sondern Handwerksqualität (D23, WP5.3). Ein Blick in die Tabelle oben zeigt es: zwei
Garnituren derselben Klasse haben dieselben Zahlen.

Fünf Stufen auf drei Klassen gehen also nicht auf. Drei Wege, und die Wahl gehört dem Nutzer
(Projektregel 4, weil die F-03-Tabelle daran hängt):

1. **Fünf Namen, drei Klassen.** T0 primitiv, T1 leicht, T2 mittel, T3 und T4 schwer. T3 und
   T4 unterscheiden sich dann in Name, Rezept, Preis und Set-Bonus — und **nicht im Schutz**.
   Ein langes Kettenhemd, das nicht besser schützt als ein kurzes, ist eine Enttäuschung,
   sobald jemand die Werte vergleicht.
2. **Drei Rüstungsstufen in Phase 1.** T0 primitiv (Lumpen), T1 leicht (Wolle und Leder),
   T2 mittel (Gambeson), T3 schwer (Kettenhemd). T4 fällt weg bzw. wird zur Qualitätsspitze
   des Kettenhemds. Das wäre eine Änderung an der F-03-Tabelle, keine stille Lücke.
3. **Eigene Zahlen je Stufe.** Fünf Stufen mit fünf Resist-Staffeln, über `armorHeavyMaster`
   hinaus. Das sind erfundene Zahlen ohne Balancing-Grundlage — nach den Projektregeln
   gehören sie nach WP9, und bis dahin stünde WP5.5 still.

Eine Empfehlung steht im Plan; eine Entscheidung steht hier nicht.

## Was dieser Befund nicht sagt

- **Nichts darüber, wie die Modelle aussehen.** Gemessen sind Pfade, nicht Bilder. Ob eine
  geborgte Garnitur in einem Frühmittelalter-Spiel erträglich aussieht, kann nur der Nutzer
  beurteilen — und Phase 2 richtet es mit Retexturen (D3, F-16).
- **Nichts über `resourceArmorCraftingKit`.** Vanillas Rüstungsrezepte verlangen es, es ist
  gesperrt und zu WP5 aufgeschoben. Dass unsere Rezepte es nicht brauchen, ist eine
  Entscheidung von WP5.5 und hier nicht getroffen.
- **Kein Patch-Zielpunkt.** Alles hier ist XML. Dieser Befund steht darum nicht im
  `patch-manifest.md`.
- **Kein Lauf.** Prefab-Pfade, Gruppen und Zahlen sind gelesen. Ob ein geborgter Pfad ohne
  seine Garnitur lädt und ob eine fremde `ArmorGroup` mit unseren vier Teilen auslöst,
  entscheidet **WP3.6**.
