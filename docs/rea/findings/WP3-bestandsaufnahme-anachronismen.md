# WP3.1 — Bestandsaufnahme der Anachronismen

- **Datum:** 2026-11-07
- **Planschritt:** [Plan-0001](../../plans/0001-phase-1-mvp-700-und-grauen.md) WP3.1
- **Feature:** [F-01 Anachronismen-Purge](../../features/F-01-anachronismen-purge.md)
- **Quelle:** `Data/Config` der installierten Fassung (45 XML-Dateien), gelesen mit
  `mod700check anachronisms`
- **Art:** **Vorlauf, kein Nachweis.** Unsere Modlets sind hier nicht angewandt; ein Nachweis
  braucht einen `ConfigsDump` nach einem Spielstart (WP3.6).

> **BERICHTIGUNG, 7. November 2026.** Jede Zahl in diesem Befund wurde über **fünf**
> Erreichbarkeitswege gerechnet (Rezept, Loot, Händler, Quest-Belohnung, Startausrüstung). Es
> sind **sechs**: der Block-Abwurf aus `blocks.xml` fehlte. Die Bestandsaufnahme war damit zu
> klein — 26 gesperrte Kennungen waren über 869 Abwurfzeilen weiter zu haben, und
> `ungeprueft 0` galt für eine zu kleine Menge. Nachgetragen in WP4.1; die berichtigten
> Zahlen stehen in Vertrag 04 §3d und in `tools/check/README.md`, die Wirkung auf den Purge
> im Plan unter WP3. **Die Methode dieses Befundes bleibt gültig, die Reichweite war es
> nicht.**

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

**Ergebnis: 1129 erreichbare Kennungen.** Davon

| | Zahl |
|---|---|
| von der Denylist verboten | **254** |
| durch eine Freigabe ausdrücklich erlaubt | 31 |
| **von keiner Regel berührt** | **844** |

> **Berichtigt am selben Tag.** Hier stand zuerst 1139 und 852. Die Zahl kam aus meinem
> eigenen Erkundungsskript, und das las die XML mit Mustervergleich, **ohne Kommentare zu
> entfernen** — zehn auskommentierte Einträge wie `<!-- <item name="modArmorCoolingMesh"/> -->`
> zählte es als erreichbar. `mod700check` liest mit `System.Xml.Linq` und sieht Kommentare
> nie; seine Zahl (1129) war die richtige, meine die falsche. Dasselbe Muster wie in §3.3:
> ein selbstgebautes Signal, das lockerer liest, als es aussieht. Die Lehre ist, die Zahl des
> Werkzeugs zu nehmen und nicht die eigene Nebenrechnung.

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

## 5. Die offene Lücke: 844 Kennungen

Die Denylist hat 844 der 1129 erreichbaren Kennungen **nie angesehen**. Darin steckt viel
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

## 5a. Die Lücke ist geschlossen (WP3.1c, 2026-11-07)

Die 844 sind durchgesehen. Der Weg dahin in Zahlen, jede aus `mod700check`:

| Stand | `ungeprueft` | verboten | aufgeschoben | durch Freigabe erlaubt |
|---|---|---|---|---|
| WP3.1 (erster Lauf) | 844 | 254 | — | 31 |
| nach `--no-extends`-Korrektur und Mod-Ableitung | 800 → 537 | 298 → 335 | — | 31 |
| WP3.1b (Aufschub, tote Regeln) | 512 | 356 | 157 | 31 |
| **WP3.1c (Sichtung)** | **0** | **592** | **170** | **270** |

Die 1129 erreichbaren Kennungen teilen sich jetzt restlos auf: 592 verboten, 170
aufgeschoben, 270 durch Freigabe erlaubt, 24 Baupläne folgen Erlaubtem, 73 sind Loot-Gruppen
und keine Gegenstände. 592 + 170 + 270 + 24 + 73 = 1129.

### Was die Daten beantwortet haben, ohne eine Namensregel

| Mittel | Kennungen |
|---|---|
| `sprengkoerper` (`Class = ItemClassTimeBomb`) | 6 |
| `robotik` (`Tags` enthält `roboticsSkill`) | 7 |
| `moderner_werkstoff` (`Tags` enthält `challenge_*`) | 15 |
| `CreativeMode = Dev` in `entwicklergegenstand` | 10 (3 → 13) |
| `Unlocks`-Ableitung, zweite Hälfte | 34 Baupläne |
| **Summe** | **72** |

Die 72 sind die Trefferzahlen der neuen Mittel, nicht alle aus den 512: vier davon hatte
vorher schon eine Namensregel erfasst, die die Eigenschaftsregel nun ablöst (`ungeprueft`
fiel von 512 auf 477, `verboten_nach_name` gleichzeitig von 251 auf 247). Aus den 512 hat
die Technik also rund 68 beantwortet.

Zwei Stellen, an denen das naheliegende Signal falsch war:

- **`explosivesSkill` ist unbrauchbar.** Vanilla hängt `resourceLockPick` daran, weil der
  Perk „Demolitions Expert" auch das Aufbrechen trägt. Ein Dietrich ist kein Sprengkörper.
  Die Klasse `ItemClassTimeBomb` trifft genau die sechs Wurfkörper und nichts sonst.
- **`biomeChallenge` hätte funktioniert und ist trotzdem nicht benutzt.** Der Tag trifft
  alle 62 Teile der 16 modernen Rüstungsgarnituren und keines der vier Primitiv-Teile —
  eine Zeile statt sechzehn. Er bedeutet aber „zählt für den Biom-Fortschritt", nicht
  „modern". Eine Regel, die nur zufällig richtig liegt, gehört nicht zu den
  Eigenschaftsregeln; sie würde beim nächsten Spiel-Update lautlos falsch werden. Die 16
  Garnituren stehen darum als 16 Namen in der Denylist.

### Was dabei an Vanilla-Inhalt entschieden wurde

Die Sichtung ist kein Messergebnis, sondern über vierhundert inhaltliche Urteile — jedes als
Zeile in `denylist.txt` oder `aufschub.txt`, jedes mit einem Grund daneben. Drei Gruppen
davon sind gross genug, dass sie der Nutzer sehen muss, bevor WP3.2 XPath schreibt:

1. **Rüstung.** Vanillas 16 Garnituren fallen alle (Biker, Commando, Nerd, Athletic, Santa
   sind offensichtlich; Farmer, Nomad, Raider, Ranger, Rogue, Scavenger, Preacher, Assassin,
   Miner, Lumberjack klingen zeitlos, tragen in Vanilla aber Warnweste, Schutzhelm und
   Kevlar). Bis WP5 (F-03) bleibt nur `armorPrimitive*`. F-01 sagt „Nicht im Umfang:
   Ersatzinhalte" — die Lücke ist eingeplant, aber sie ist spürbar.
2. **Ackerbau.** Mais, Kartoffel, Kürbis, Blaubeere und Yucca kommen aus Amerika, Kaffee aus
   Arabien, Chrysantheme aus Ostasien, Baumwolle wuchs nicht in Nordeuropa. Das nimmt
   Vanilla den halben Ackerbau. Yuccafaser und Baumwolle sind darum **nach WP4 aufgeschoben**
   statt gesperrt: sie sind der Anfang jeder Stoffkette, und ohne Faser gibt es am ersten Tag
   keinen Verband. Die Nahrung selbst ist gesperrt — Pilze, Fleisch, Ei, Eintopf und Honig
   bleiben.
3. **Währung.** `oldCash` und `casinoCoin` sind Anachronismen und gleichzeitig das einzige
   Zahlungsmittel, das Vanilla kennt. Aufgeschoben nach WP4 (F-05), sonst hört der Handel
   vor dem Ersatz auf.

### Was jetzt ehrlicher dasteht als vorher

`verboten_nach_name` ist von 251 auf **441** gestiegen. Das ist kein Rückschritt: vorher
ruhten 512 Kennungen auf **nichts**. Die Zahl sagt, wie viel Sperre auf meinem Urteil über
Vanilla-Inhalt ruht und nicht auf Daten — und das sind jetzt 441 von 592 statt 251 von 356
bei gleichzeitig 512 ungesehenen. Sie soll weiter fallen, aber nur dort, wo Vanilla
tatsächlich eine Eigenschaft führt.

Zwei Zähler sind dafür neu und müssen beide **0** sein: `verbotsregeln_ohne_treffer` (eine
Regel, die nichts trifft, ist meist ein Tippfehler) und `freigaberegeln_ohne_treffer`. Der
zweite ist der wichtigere. Eine Verbotsregel, die nicht greift, lässt etwas **durch**, und
das erscheint beim nächsten Lauf als Befund. Eine Freigabe, die nicht greift, lässt etwas
**fallen** — und ein Befund mehr sieht aus wie Arbeit, die getan wurde. Niemand sucht nach
einer Sperre, die zu viel sperrt. Beim ersten Lauf mit den neuen Freigaben stand der Zähler
auf 1: `!ironDoorDouble*` war von `!ironDoor*` verdeckt und damit überflüssig.

## 6. Was das für den Plan heißt

Der Plan schätzt WP3 auf 12 Tage und ging von einer im Wesentlichen fertigen Denylist aus.
Die Schätzung stand auf 138 Kennungen; sie steht jetzt auf 254 plus 844 zu sichtenden. Die
Zahl der zu schreibenden XPath-Zeilen wächst damit etwa um das Doppelte bis Dreifache, die
Sichtung der 844 kommt als eigener Posten dazu.

**Entschieden (Nutzer, 2026-11-07): Urteil nach Eigenschaften.** Festgelegt in
[Vertrag 04 §3a](../../contracts/04-pruefwerkzeuge.md) — Entwurf, wartet auf Abnahme.

Gemessen wurde vorher, ob Eigenschaften das überhaupt leisten:

| | |
|---|---|
| erreichbare Kennungen mit auswertbarer Eigenschaft | **945 von 1129** |
| davon mit `Group` (nach `Extends`-Auflösung) | 932 — **ohne** Auflösung nur 328 |
| mit `Tags` | 772 |
| mit Block-`Class` | 216 |
| aufgelöst, aber ganz ohne Eigenschaft | **6** (`cobweb`, `terrStone`, `treeAzalea`, drei Variant-Helper) |
| weder Gegenstand noch Block | 178 (73 Loot-Gruppen, 95 `item_modifier`, ~10 Sonderfälle) |

Und ob sie **trennen**, woran Namen scheitern:

| Gegenüberstellung | Ergebnis |
|---|---|
| Pistole gegen Bogen | `Tags` trennt sauber: `gun` gegen `bow,archery` |
| Schalter, Melder, Scheinwerfer, Generator | Block-`Class` trennt, eine Regel statt vier Namen |
| Admin- und Testgegenstände | `Tags` enthält `admin`, `Group` ist `Special Items` |
| Konserve gegen Rohfleisch | **`Group` und `Tags` identisch — nicht trennbar** |
| Verbandskasten gegen Wundauflage | **`Tags` identisch — nicht trennbar** |
| `airConditioner` | **keine `Group`, keine `Class`** |

Darum ist die Entscheidung nicht „Eigenschaften **statt** Namen", sondern *wo Vanilla eine
Eigenschaft führt, die etwas bedeutet, entscheidet die Eigenschaft; wo nicht, der Name — und
das Werkzeug sagt, welche Regel entschied.* Der Bericht weist `verboten_nach_name` getrennt
aus, damit sichtbar bleibt, wie viel noch auf meinem Gedächtnis ruht.

Die 95 Mods werden **abgeleitet**, nicht aufgezählt: ein `item_modifier` trägt
`installable_tags`, und er fällt, wenn jeder Gegenstand, auf den er passt, gesperrt ist.
`modGunSoundSuppressorSilencer` (`installable_tags="gun"`) fällt mit den Schusswaffen,
`modGunBowArrowRest` (`installable_tags="bow"`) bleibt mit dem Bogen.

## 6a. Zwei Nebenfunde

**`oilBarrel` hat ein Rezept, aber nirgends eine Definition.** Weder `items.xml` noch
`blocks.xml` noch `item_modifiers.xml` führen die Kennung; sie steht nur in `recipes.xml`,
einmal als Rezeptname und einmal als Zutat. Das ist eine Ungereimtheit in Vanilla, nicht in
unserer Mod. Bemerkenswert ist aber, dass `mod700check recipes` dazu `zutat_unbekannt: 0`
meldet: die bekannte Kennungsmenge enthält offenbar auch Rezept-**Ausgaben**, und damit deckt
ein Rezept seine eigene undefinierte Zutat. Das gehört beim Bau von §3a mitgeprüft — eine
Zutat, die es nicht gibt, soll auffallen.

**Die Startausrüstung ist T0 bis auf einen Eintrag.** Sie lautet `drinkJarBoiledWater=2`,
`foodCanChili`, `medicalFirstAidBandage`, `meleeToolTorch`, `noteDuke01`. Nach D56 bleibt die
Wundauflage; die Konserve muss weg (WP3.4), und `noteDuke01` ist ein Vanilla-Erzählstück, das
mit F-12 ersetzt oder entfernt wird.

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
