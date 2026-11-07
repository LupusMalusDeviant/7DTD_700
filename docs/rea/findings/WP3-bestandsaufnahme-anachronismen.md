# WP3.1 — Bestandsaufnahme der Anachronismen

- **Datum:** 2026-11-07
- **Planschritt:** [Plan-0001](../../plans/0001-phase-1-mvp-700-und-grauen.md) WP3.1
- **Feature:** [F-01 Anachronismen-Purge](../../features/F-01-anachronismen-purge.md)
- **Quelle:** `Data/Config` der installierten Fassung (45 XML-Dateien), gelesen mit
  `mod700check anachronisms`
- **Art:** **Vorlauf, kein Nachweis.** Unsere Modlets sind hier nicht angewandt; ein Nachweis
  braucht einen `ConfigsDump` nach einem Spielstart (WP3.6).

> Dieser Befund hat drei Defekte in meiner eigenen Denylist aus WP2 gefunden und eine Lücke,
> die größer ist als alles, was die Liste bisher kannte. Das ist das Ergebnis des Schrittes,
> nicht ein Unfall auf dem Weg dorthin: WP3.1 heißt „Bestandsaufnahme", und sie hat
> bestanden, was sie leisten sollte.

## 1. Was gemessen wurde

Geprüft wird nicht, ob ein Gegenstand *existiert*, sondern ob ein Spieler ihn **erreichen**
kann. Fünf Wege:

| Weg | Woraus gelesen |
|---|---|
| Rezept | `recipes.xml`, `recipe/@name` |
| Loot | `loot.xml`, `item/@name` |
| Händler | `traders.xml`, `item/@name` |
| Quest-Belohnung | `quests.xml`, `reward/@id` (kommagetrennt) |
| Startausrüstung | `entityclasses.xml`, `property class="ItemsOnEnterGame"` → `@value` |

Die Startausrüstung steht **im `value`-Attribut**, nicht im `name`: `GameModeSurvival` heißt
die Zeile, der Inhalt ist `drinkJarBoiledWater=2,foodCanChili,medicalFirstAidBandage,`
`meleeToolTorch,noteDuke01`. Wer `@name` liest, findet die Startausrüstung nie und meldet
dafür Grün.

**Ergebnis: 1139 erreichbare Kennungen.** Davon

| | Zahl |
|---|---|
| von der Denylist verboten | **254** |
| durch eine Freigabe ausdrücklich erlaubt | 31 |
| **von keiner Regel berührt** | **852** |

## 2. Der erste Lauf: 138 Treffer, davon 32 falsche

Der Lauf gegen die Denylist, wie sie aus WP2 kam, meldete 138 Kennungen. 32 davon waren keine
Anachronismen des Spiels, sondern Fehltreffer der Liste:

| Was | Warum es durchfiel | Entscheidung |
|---|---|---|
| 27 × Bogen, Armbrust, Pfeil, Bolzen | heißen in Vanilla `gunBow*`, `ammoArrow*`, `ammoCrossbowBolt*` und fielen unter `gun*` bzw. `ammo*` | **D54**: bleiben erreichbar, WP5 deutet sie um |
| `resourceForgedSteel` | als „industrielles Stahlprodukt" verboten, ist aber die Materialstufe aus D23 | **D55**: Verbotszeile entfällt |
| 4 × Wundauflage, Schiene, Salbe | fielen unter `medical*`, sind für 700 plausibel | **D56**: bleiben erreichbar |

Säule P3 nennt Fernkampf als **gleichwertige** Spezialisierung und D8 die Armbrust
ausdrücklich. Gesperrt hätte Phase 1 keine einzige Fernkampfwaffe gehabt — und das wäre nicht
aufgefallen, weil die Prüfung dann Grün gemeldet hätte.

## 3. Drei Defekte, ein Muster

### 3.1 Zu weit: das Präfix trifft, was es nicht meint

`gun*` und `ammo*` sind richtig gedacht und greifen daneben, weil 7DTD den Bogen als Schusswaffe
führt. Das ist der harmlose Fall: er fällt beim ersten Lauf gegen echte Daten auf.

### 3.2 Kategorienfehler: eine Freigabe ist kein Klassenschutz

In der Liste aus WP2 standen die D9-Systeme als **Freigaben**: `!*Turret*`, `!generator*`,
`!solarCell*`, `!battery*`, `!bladeTrap*`, `!explosive*` und neun weitere. Begründung im
Kopf der Datei: F-15 deutet sie in Phase 2 um, wer sie sperrt, zerstört ein Feature.

Das ist falsch, und F-01 sagt es wörtlich: F-01 *„sperrt nur ihre modernen Varianten (Namen,
Rezepte, Loot), die Logik bleibt erhalten"*. Rezepte und Loot sind genau das, was dieses
Werkzeug messen kann — die Klasse sieht es nie. Die Freigaben haben also nicht die Klasse
geschützt, sondern den **Weg zum Gegenstand** erlaubt.

Was dadurch in Phase 1 herstellbar oder im Loot geblieben wäre, bei einer Prüfung mit dem
Urteil „0 rot":

```
autoTurret  shotgunTurret  m60Turret  gunBotT2JunkTurret  gunBotT3JunkDrone
generatorbank  solarbank  solarCell  batterybank  carBattery
electricwirerelay  electrictimerrelay  electricfencepost
bladeTrap  resourceGunPowder  + 6 questReward…Bundle
```

Ein Generator und ein Schrotflinten-Geschützturm im Frühmittelalter-Overhaul, abgesegnet von
der eigenen Prüfung. **D9 wird in [Vertrag 03 §4](../../contracts/03-xpath-regeln.md) gewahrt,
nicht in der Denylist:** kein `remove` auf die Definition in `items.xml` oder `blocks.xml`.
Die Klasse bleibt, der Weg verschwindet.

### 3.3 Der Vergleich war gross-/kleinschreibungsblind

Die Regel hieß `drugs*` — gemeint war `drug*`. Sie meldete trotzdem drei Treffer:
`drugSteroids`, `drugSkullCrushers`, `drugSugarButts`. Nicht weil sie stimmte, sondern weil
`RegexOptions.IgnoreCase` gesetzt war und `drugs` damit auf `drugS` passt. Alle drei tragen an
fünfter Stelle ein grosses S.

Zwölf weitere Drogen kamen durch: `drugAntibiotics`, `drugPainkillers`, `drugVitamins`,
`drugFortBites`, `drugRecog`, `drugAtomJunkies`, `drugCovertCats`, `drugEyeKandy`,
`drugHackers`, `drugHealthBar`, `drugJailBreakers`, `drugNerdTats`, `drugOhShitzDrops`,
`drugRockBusters`, `drugHerbalAntibiotics`.

Das ist der gefährlichste der drei Defekte, weil die Regel **aussah, als arbeite sie**. Eine
Regel ohne Treffer fällt auf. Eine Regel mit drei zufälligen Treffern nicht.

`IgnoreCase` ist jetzt entfernt. Kennungen in 7DTD sind gross-/kleinschreibungsgenau; eine
Regel, die lockerer passt als sie sich liest, täuscht Deckung vor. Nebenwirkung: `!*Dart*Trap*`
hat `dartTrap` nur case-insensitiv getroffen und wäre still ausgefallen — die Regel steht jetzt
als `dartTrap*` da.

### 3.4 Das Muster

Drei Defekte, drei verschiedene Mechanismen, eine Ursache: **eine Denylist ist eine Liste von
Mustern, kein Verständnis.** Sie weiß genau das, was ich beim Schreiben zu bedenken dachte. Das
Werkzeug sagt das in seinen eigenen Grenzen selbst — die Zeile stand schon da, bevor dieser
Befund sie belegte:

> „Die Denylist ist eine Liste von Mustern, kein Verständnis. Ein Anachronismus mit
> unerwartetem Namen fällt durch, bis die Liste ihn kennt."

## 4. Nach den Berichtigungen: 254 rot

| Gruppe | Zahl | Beispiele |
|---|---|---|
| Schusswaffen und Teile | 28 | `gunRifleT3SniperRifle`, `gunHandgunT1PistolParts` |
| Munition | 28 | `ammo762mmBulletAP`, `ammoShotgunSlug`, `ammoRocketHE` |
| Fahrzeuge und Teile | 17 | `vehicleTruck4x4Chassis`, `vehicleWheels` |
| Strom, Türme, Fallen, Drohne (D9) | 61 | `autoTurret`, `generatorbank`, `motionsensor`, `modRoboticDrone*` |
| Konserven und Getränke | 18 | `foodCanTuna`, `drinkCanMegaCrush`, `drinkJarCoffee` |
| Medizin und Drogen | 19 | `medicalFirstAidKit`, `drugAntibiotics`, `drugPainkillers` |
| Treibstoff, Öl, Beton, Zement | 5 | `resourceOil`, `resourceConcreteMix`, `resourceCement` |
| Sprengstoff und Schwarzpulver | 4 | `explosive*`, `resourceGunPowder` |
| sonstige Elektronik | 4 | `resourceElectricParts`, `speaker`, `spotlightPlayer` |

### Die Zutaten-Falle

34 der gesperrten Kennungen stehen in anderen Rezepten als **Zutat**. Wer den Weg zu ihnen
kappt, macht die Rezepte, die sie brauchen, zur Sackgasse. Die schwersten:

| Kennung | als Zutat verwendet |
|---|---|
| `resourceElectricParts` | **59×** |
| `resourceOil` | 18× |
| `ammoGasCan` | 8× |
| `resourceOilShale` | 6× |
| `vehicleWheels` | 5× |
| `gunHandgunT1PistolParts` | 5× |

Das ist kein Hindernis, sondern der Grund, warum `mod700check recipes` existiert: die Rezepte,
die diese Zutaten brauchen, sind selbst Anachronismen und fallen im selben Zug. Aber die
Reihenfolge muss stimmen, und der Nachweis dafür ist ein `recipes`-Lauf gegen den gemergten
Stand — nicht gegen Vanilla.

## 5. Die offene Lücke: 852 Kennungen

Die Denylist hat 852 der 1139 erreichbaren Kennungen **nie angesehen**. Darin steckt viel
harmloser Inhalt (Rüstung, Nahkampfwaffen, Nahrung, Rohstoffe), aber auch Anachronismen, die
kein Präfix der Liste kennt. Ein Auszug dessen, was beim Durchsehen von neun der rund
sechzig Gruppen auffiel:

```
airConditioner            cementMixer               chemistryStation
oilBarrel                 barbedFence               combineStation
tvBlockVariantHelper      appliancesVariantHelper   officeChair01VariantHelper
steelGarageDoor3x3_PoweredBlockVariantHelper (und zwei weitere)
ironGarageDoor_PoweredBlockVariantHelper   metalReinforcedWoodDrawBridgePowered
cntVendingMachine         cntCashRegister_Player    cntWaterCoolerFull
cntDeskSafe_Player        cntGunSafeVariantHelper   cntMailBox01..03VariantHelper
TEST_ITEM_00 … TEST_ITEM_09   (zehn Stück, über Händler erreichbar)
gunHandgunPistolAdmin  gunToolDiggerAdmin  pimpMiningHelmetAdmin  toughGuyShirtAdmin
machineGunsSkillMagazine  roboticsSkillMagazine  trapsSkillMagazine  blades…  handguns…
```

Dazu zwei große Blöcke, die nicht einzeln, sondern als System fallen:

- **133 × `book*`** — das vollständige Vanilla-Fertigkeitsbuch-System. Rund die Hälfte ist
  waffenbezogen (`bookAutoWeapons*`, `bookPistolPete*`, `bookShotgunMessiah*`, `bookSniper*`,
  `bookTechJunkie*`, `bookEnforcer*`). F-21 ersetzt das System in WP7 durch sechs Bäume.
- **166 × `mod*`** — Waffen- und Rüstungs-Mods. Viele sind an Schusswaffen gebunden
  (`modGunScopeLarge`, `modGunSoundSuppressorSilencer`, `modGunLaserSight`, `modGunDrumMagazineExtender`),
  andere sind neutral (`modDyeRed`) oder passen (`modGunBowArrowRest`).

## 6. Was das für den Plan heißt

Der Plan schätzt WP3 auf 12 Tage und ging von einer im Wesentlichen fertigen Denylist aus.
Die Schätzung stand auf 138 Kennungen; sie steht jetzt auf 254 plus 852 zu sichtenden. Die
Zahl der zu schreibenden XPath-Zeilen wächst damit etwa um das Doppelte bis Dreifache, die
Sichtung der 852 kommt als eigener Posten dazu.

**Offen und zu entscheiden:** mit welcher Methode die 852 geschlossen werden. Eine Denylist
nach Namen hat in diesem Befund dreimal auf drei Wegen versagt. Die Alternative ist, nach
**Eigenschaften** statt nach Namen zu urteilen — `items.xml` führt zu jedem Gegenstand eine
`Group` (Werkzeugleisten-Gruppe) und Blöcke eine `Class` (etwa `Powered`, `PoweredLight`).
Das urteilt über das, was ein Gegenstand *ist*, nicht über seinen Namen, und hätte
`motionsensor`, `switch` und `spotlightPlayer` ohne eine einzige Regel gefunden.

## 7. Grenzen dieses Befundes

1. **Vorlauf, kein Nachweis.** Gelesen ist `Data/Config` ohne unsere Modlets.
2. **Prefabs sind unsichtbar.** Was als platzierter Block oder Kisteninhalt in einem POI
   steckt, steht in keiner der fünf Wege-Dateien. Das ist die bekannte MVP-Lücke von F-01 und
   gehört zu F-07 (Phase 2).
3. **Die 852 sind gezählt, nicht gesichtet.** Durchgesehen wurden neun Gruppen; die Beispiele
   in §5 sind Funde daraus, keine vollständige Liste.
4. **Die Gruppenzahlen in §4 sind aus den Regelzeilen gezählt**, nicht aus einer inhaltlichen
   Einteilung — eine Kennung erscheint bei der Regel, die zuerst passte.
5. **Der gross-/kleinschreibungsgenaue Vergleich hat eine Gegenprobe** — zwei, weil eine
   allein nichts beweist: `denylist-schreibung-falsch.txt` enthält `gunpruefpistole*` gegen
   einen Pruefsatz mit `gunPruefPistole` und muss **grün** bleiben,
   `denylist-schreibung-richtig.txt` enthält `gunPruefPistole*` und muss **rot** werden. Die
   erste allein wäre auch grün, wenn der Vergleich gar nichts mehr findet. Lauf:
   13 Gegenproben, 0 fehlgeschlagen.
