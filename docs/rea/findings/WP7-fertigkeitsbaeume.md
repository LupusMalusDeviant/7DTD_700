# WP7 — Fertigkeitsbäume: was `progression.xml` trägt und was der Code davon liest

**Build:** V 3.40 (Build 10), `Assembly-CSharp.dll`
SHA-256 `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58`, MVID
`0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480`, 11.980.288 Byte.
**Werkzeug:** `tools/meta/Mod700.Meta` (`mod700meta types|members|find-string`), statische
Metadaten, kein Lauf des Spiels.
**Datum:** 8. November 2026. **Gehört zu:** F-21, Plan-0001 WP7, D66, D67.

---

## 1 Der Aufbau: vier Ebenen, 4305 Zeilen

`Data/Config/progression.xml` führt fünf Behälter unter `/progression`:

| Behälter | Knoten | Inhalt |
|---|---|---|
| `level` | 1 | `max_level="300"`, `exp_to_level`, `skill_points_per_level` |
| `attributes` | 8 | fünf echte, drei Behälter mit `max_level="0"` |
| `skills` | 16 + 19 | 16 Unterbereiche, 19 `book_group` |
| `crafting_skills` | 24 | die magazingetriebenen Handwerks-Stufen |
| `perks` | 57 + 152 | 57 Perks, 152 `book` (133 Bücher + 19 `*Complete`) |

Die Kette ist **Attribut → Unterbereich (`skill`) → Perk**, verknüpft über `parent`. Die
Bücher hängen über `parent` an einer `book_group`, alle 19 Gruppen an `attBooks`, und alle
19 tragen **8 Einträge** — 7 Bücher plus einen `*Complete`-Eintrag. Daher 133 echte Bücher.

Die drei Behälter-Attribute: `attGeneralPerks` (7 Perks: Rüstung, Küche, Schlossknacken,
Plündern), `attBooks` (die 19 Buchreihen), `attCrafting` (die 24 Handwerks-Stufen).

## 2 Was der Code von alldem liest

### 2.1 Zwei Namen stehen fest im Code — und nur zwei

`find-string` über **54.940 Methodenkörper**, gesucht nach allen acht Attributnamen:

| Methode | Zeichenkette |
|---|---|
| `EntityPlayerLocal::Update` | `attFortitude` |
| `XUiC_CategoryList::SetupCategoriesByWorkstation` | `attcrafting` (klein!) |

Mehr nicht. `EntityPlayerLocal::Update` ruft dazu `Progression::GetProgressionValue` und
liest `ProgressionValue::get_Level`; in derselben Methode liegen die Literale
`"_underwater"` und `"snow"`. **Was der Wert dort genau bewirkt, ist nicht belegt** — die
CIL-Spur führt Aufrufe und Feldzugriffe, aber **keine Verzweigungen** (dokumentierte Grenze
des Werkzeugs). Dass er etwas mit Wasser oder Kälte zu tun hat, ist eine Lesart, kein
Befund.

**Folge für die Bauweise:** ein *umbenanntes* Attribut nimmt keine Code-Zeile mit, ein
*gelöschtes* schon. Darum Umdeutung (D66).

### 2.2 Jedes Attribut hängt über Gegenstands-Marken an einer Waffenfamilie

Jedes der fünf echten Attribute trägt eine `effect_group` mit
`<requirement name="ItemHasTags" tags="attX"/>` und darin `HeadshotDamageModifier`
(Stufe 2–10, 0,1 → 1,0) und `DismemberChance` (0,05 → 0,45). Das Attribut wirkt also
**nur auf Gegenstände, die seine Marke tragen**.

Gemessen, welche Gegenstände die Marke tragen und den Purge überleben (382 gesperrte
Kennungen aus `items/blocks/recipes` des Purge-Patches):

| Attribut | Marken | gesperrt | bleiben | was bleibt |
|---|---|---|---|---|
| `attStrength` | 26 | 8 | **18** | Äxte, Hacken, Schaufeln, Klauenhammer, Keulen, Vorschlaghämmer, Nagel |
| `attAgility` | 22 | 5 | **17** | Messer, Bögen, Armbrüste, Pfeile, Bolzen |
| `attFortitude` | 8 | 4 | **4** | drei Schlagringe, `meleeHandPlayer` |
| `attPerception` | 18 | 14 | **4** | drei Speere, ein Dev-Gegenstand |
| `attIntellect` | 5 | 5 | **0** | — |

**Das ist der Boden der Zuordnung, nicht die Perk-Namen.** Die Fährtenlese-Perks liegen in
`attPerception`, aber der Bogen hängt an `attAgility` — also ist `attAgility` der Jäger. Die
Perks wandern (WP7.2), die Marken an den Waffen wandern nicht von allein.

### 2.3 Die Liste im Fertigkeitsfenster ist datengetrieben

`XUiC_SkillList::updateFilteredList` läuft über `Progression::ProgressionClasses`, fragt
`ProgressionClass::ValidDisplay`, `get_IsAttribute`, `get_IsSkill`, `get_IsPerk`,
`get_IsCrafting`, `get_IsBookGroup`, `get_IsBook`, liest die Felder
`ProgressionClass::Hidden`, `::Enabled`, `::Name`, `::NameKey` und sortiert mit
`ListSortOrderComparer`, dann `XUiC_Paging::SetLastPageByElementsAndPageLength`.
**Keine feste Zahl von fünf Attributen.** Sechs Bäume wären technisch gegangen; dass es
fünf sind, ist eine Inhalts-Entscheidung (D66), keine Grenze des Spiels.

`XUiC_SkillList::listSkills` kennt vier Fenster: `windowSkillAttributeInfo`,
`windowSkillPerkInfo`, `windowSkillBookInfo`, `windowSkillCraftingInfo`.

### 2.4 Die Kategorie-Knöpfe der Werkbank kommen von den ATTRIBUTEN

`XUiC_CategoryList::SetupCategoriesByWorkstation("skills")` läuft ebenfalls über
`Progression::ProgressionClasses`, filtert `get_IsAttribute` und benutzt
`ProgressionClass::Name` (über `Localization::Get`) und `::Icon`.

Zwei Folgen, beide gemessen:
- Die **kleingeschriebenen** Kurznamen (`attstrength`, `attagility`, …) stehen auf diesen
  Knöpfen. Sie müssen mit übersetzt werden, sonst heißt der Knopf weiter „Strength".
- Die Methode liest `Hidden` **nicht**. Die drei verborgenen Behälter-Attribute erscheinen
  als Kategorie-Knöpfe — das ist Vanilla-Verhalten und ändert sich durch uns nicht.

### 2.5 `hidden` ist das einzige XML-Werkzeug zum Verbergen — `enabled` nicht

`ProgressionFromXml::parseProgressionItem` lädt genau diese 30 Zeichenketten:

```
attribute  skill  perk  book  book_group  crafting_skill
min_level  max_level  max_level_ratio_to_parent  base_skill_point_cost  base_exp_cost
cost_multiplier_per_level  name  parent  name_key  desc_key  long_desc_key  icon
hidden  override_cost  level_requirements  level
display_entry  unlock_level  item  has_quality  icontint  unlock_entry  unlock_tier  recipes
```

`hidden` ist dabei, **`enabled` nicht** — das Feld `ProgressionClass::Enabled` existiert und
wird von der Liste gelesen, ist aber aus XML nicht erreichbar. Wer einen Zweig stilllegen
will, hat `hidden`.

**Gemessene Grenze von `hidden`:** es verbirgt **nur den Knoten, nicht seine Kinder**.
Vanilla setzt `hidden="true"` an `attGeneralPerks` und an `skillGeneralPerks`, und deren
Perks (Rüstung, Schlossknacken) stehen trotzdem im Fenster. Jeder tote Zweig braucht seine
eigene Zeile.

`ProgressionFromXml::parseProgressionItems` liest am Behälter: `min_level`, `max_level`,
`max_level_ratio_to_parent`, `base_skill_point_cost`, `base_exp_cost`,
`cost_multiplier_per_level`, `complete_sound`.

### 2.6 Wie ein Rezept gesperrt wird — die Grundlage von WP7.5

`Recipe::IsUnlocked(EntityPlayer)` liest in dieser Reihenfolge:
`XUiM_Recipes::CraftingProgression` (die Sandkasten-Einstellung), dann
`Recipe::get_IsLearnable`, dann `EntityAlive::GetCVar(Recipe::GetName())`, dann
`EffectManager::GetValue` mit Kennwert 73 und `Recipe::tags`.

`Recipe::.cctor` liest zwei Marken: `"materialbased"` und `"learnable"`. **Ein Rezept ist
also genau dann sperrbar, wenn seine `tags` die Marke `learnable` tragen.**

Gegenprobe an den Daten, 633 Vanilla-Rezepte:

| | Anzahl |
|---|---|
| mit Marke `learnable` | 391 |
| mit `always_unlocked="true"` | 39 |
| beides | **0** |
| weder noch | 203 |

Die 203 ohne beides sind von Anfang an verfügbar — darunter `campfire`, `candle`,
`bucketEmpty`, `ammoArrowStone`, die man in Vanilla am ersten Tag baut. Die 39
`always_unlocked` sind durchweg **Zerlege-Rezepte** (`resourceScrapIron`, `armorParts`,
`gunBowT1WoodenBowParts`).

**Folge für uns:** unsere 42 eigenen Rezepte tragen **keine** `tags` und sind damit heute
offen — kein Loch, aber auch keine Bindung. WP7.5 muss die Marke `learnable` plus ein
`RecipeTagUnlocked` setzen, sonst ist „ohne Grundfähigkeit ist ein Rezept gesperrt"
(F-21-Kriterium) nicht erfüllt.

Das Muster steht in Vanilla fertig da, an jeder `crafting_skill`:

```xml
<display_entry icon="…" has_quality="true" unlock_level="1,2,4,6,8,10">
    <unlock_entry item="…,…" unlock_tier="1"/>
</display_entry>
<effect_group>
    <passive_effect name="RecipeTagUnlocked" operation="base_set" level="1,100" value="1" tags="…"/>
    <passive_effect name="CraftingTier"      operation="base_add" level="2,4,6,8,10,100" value="1,2,3,4,5,5" tags="…"/>
</effect_group>
```

## 3 Was der Purge leergeräumt hat

### 3.1 Zehn von 24 Handwerks-Stufen sind tot

Gemessen gegen die **361** im Purge entfernten Rezepte, Marke für Marke:

| Handwerks-Stufe | Marken | weg | bleibt |
|---|---|---|---|
| `craftingSalvageTools` | 3 | 3 | **0** |
| `craftingHandguns` | 5 | 5 | **0** |
| `craftingShotguns` | 4 | 4 | **0** |
| `craftingRifles` | 4 | 4 | **0** |
| `craftingMachineGuns` | 4 | 4 | **0** |
| `craftingExplosives` | 14 | 14 | **0** |
| `craftingRobotics` | 5 | 5 | **0** |
| `craftingElectrician` | 27 | 27 | **0** |
| `craftingTraps` | 6 | 6 | **0** |
| `craftingVehicles` | 14 | 14 | **0** |
| `craftingArmor` | 68 | 60 | 8 |
| `craftingFood` | 37 | 28 | 9 |
| `craftingSeeds` | 12 | 8 | 4 |
| `craftingWorkstations` | 20 | 5 | 15 |
| `craftingHarvestingTools` | 10 | 2 | 8 |
| `craftingMedical` | 8 | 7 | **1** |
| `craftingRepairTools` | 2 | 1 | 1 |
| `craftingClubs` | 3 | 1 | 2 |
| `craftingKnuckles`, `craftingBlades`, `craftingSledgehammers`, `craftingBows`, `craftingSpears`, `craftingBackpack` | je 3–5 | 0 | alle |

`craftingTraps` ist vollständig elektrisch bzw. Geschützturm (`autoTurret`, `bladeTrap`,
`dartTrap`, `electricfencepost`, `m60Turret`, `shotgunTurret`) — **unsere Spitzpfähle und
Palisaden aus WP6.2 stehen nicht darin** und sind darum heute offen (siehe 2.6).

`craftingMedical` behält genau `medicalFirstAidBandage`. Gesperrt ist dabei auch
`drugHerbalAntibiotics` — ein Umdeutungs-Kandidat für den Heiler, der aber zu F-11 und damit
Phase 2 gehört (D50).

### 3.2 Zehn von 57 Perks haben keine Gegenstände mehr

`perkDeadEye`, `perkBoomstick`, `perkGunslinger`, `perkMachineGunner`,
`perkDemolitionsExpert`, `perkElectrocutioner`, `perkTurrets`, `perkGreaseMonkey`,
`perkJunkMiner`, `perkSalvageOperations`.

**Nichts davon darf gelöscht werden.** Querverweise in `Data/Config` gezählt:

| Perk | blocks | items | buffs | ui_display | shapes |
|---|---|---|---|---|---|
| `perkJunkMiner` | **792** | – | – | – | 55 |
| `perkGunslinger` | – | 149 | 20 | 55 | – |
| `perkMachineGunner` | – | 121 | 13 | 55 | – |
| `perkDeadEye` | – | 120 | 23 | 55 | – |
| `perkTurrets` | – | 100 | 11 | 61 | – |

Das sind größtenteils **Marken**, nicht Verweise auf den Perk-Knoten. Ein `<remove>` nimmt
sie nicht mit, aber jede Regel, die den Perk als `progression_name` verlangt, zeigt danach
ins Leere. Darum `hidden="true"`.

Ein zweiter Messversuch ist **fehlgeschlagen und das ist der Befund**: ich habe die
`passive_effect`-Marken aller 57 Perks gegen die 382 gesperrten Kennungen gehalten und
**null** Treffer bekommen. Perk-Marken sind Kategorien (`rifleSkill`, `ammo762mm`,
`riflesCSM`, `sniperProb`), keine Gegenstandsnamen. **Kein Perk bricht, wenn sein Gegenstand
verschwindet** — er wird nur wirkungslos. Nichts zeigt das von allein an.

### 3.3 Sechs von 19 Buchreihen sind tot

Marken der Bücher je Reihe gegen die gesperrten Kennungen:

| Buchreihe | Marken | weg |
|---|---|---|
| `skillShotguns` | 8 | 6 |
| `skillTechJunkie` | 11 | 6 |
| `skillEnforcer` | 6 | 5 |
| `skillPistolPete` | 6 | 5 |
| `skillSniper` | 6 | 5 |
| `skillAutoWeapons` | 2 | 1 |
| `skillArchery` | 17 | 0 |
| `skillLuckyLooter`, `skillGreatHeist`, `skillNightStalker`, `skillBatterUp`, `skillBarBrawling`, `skillHuntingJournal`, `skillSledgeSaga`, `skillSpearHunter` | 1–7 | 0 |
| `skillArtOfMining` | 14 | 3 |
| `skillFiremansAlmanac` | 11 | 1 |
| `skillUrbanCombat` | 3 | 1 |
| `skillWasteTreasures` | 8 | 1 |

**Berichtigung:** die Denylist sagt „Acht Serien tragen Perks für Schusswaffen und
Robotik". Gemessen sind es **sechs**, bei denen die Mehrheit der Marken gesperrt ist. Die
Zahl 133 Bücher in 19 Serien stimmt dagegen genau.

Die `book_group`-Knoten tragen alle ein **leeres** `<effect_group/>`; die Wirkung sitzt an
den einzelnen `<book>`-Knoten. WP7.4 muss also die Bücher anfassen, nicht die Gruppen.

## 4 Die Zuordnung (D66)

| Vanilla-Attribut | Baum | warum dieses Attribut |
|---|---|---|
| `attStrength` | **Handwerker** | 18 lebende Marken: Äxte, Hacken, Schaufeln, Hammer |
| `attFortitude` | **Krieger** | Schlagringe und die bloße Hand; `perkBrawler` liegt hier |
| `attAgility` | **Jäger** | 17 lebende Marken: Bögen, Armbrüste, Pfeile, Messer |
| `attIntellect` | **Heiler** | keine Waffenmarke übrig; `perkPhysician` liegt hier |
| `attPerception` | **Fuhrmann** | nur noch Speere, die in WP7.2 zum Jäger wechseln |

Offen und ausdrücklich noch nicht gebaut: Keulen und Vorschlaghämmer tragen heute
`attStrength` (Handwerker) und gehören zum Krieger; die Speere tragen `attPerception`
(Fuhrmann) und gehören zum Jäger. Beides ist ein Umhängen von Marken an neun Gegenständen
und steht in **WP7.2**, zusammen mit dem Umhängen der Perks — Marke und Perk müssen in
einem Stück wandern, sonst steht ein Perk unter einem Baum und sein Gegenstand unter einem
anderen.

## 5 Grenzen dieses Befundes

- **Keine Verzweigungen.** Die CIL-Spur von `mod700meta --il` führt Aufrufe, Feldzugriffe
  und Zeichenketten. Ob eine Prüfung `if (hidden)` oder `if (!hidden)` heißt, steht nicht
  darin. Alle Aussagen über Reihenfolge sind Aufrufreihenfolge, nicht Ablauf.
- **Keine Zeichenkette heißt nicht: keine Rolle.** Zusammengesetzte oder über Reflection
  gebildete Namen erscheinen in `find-string` nicht.
- **Nichts davon ist im Spiel gesehen.** Dass `hidden="true"` die zehn Perks aus dem
  Fenster nimmt, ist beidseitig belegt (gelesen aus XML, gelesen von der Liste), aber nicht
  beobachtet. Prüfliste WP7.6.
- Der Rechenweg hinter `attFortitude` in `EntityPlayerLocal::Update` ist **nicht**
  aufgeklärt (siehe 2.1).

---

## 6 WP7.2 — die Zuordnung, gemessen und gebaut (8. November 2026)

### 6.1 Flurry und Mastery gehören zu den Waffen, nicht zu ihrem alten Attribut

Zehn der 57 Perks sind Struktur: je Attribut ein `perkFlurryOfX` und ein `perkXMastery`.
Ihre Wirkung gemessen:

| Perk | Wirkung | Marke | lebende Träger |
|---|---|---|---|
| `perkFlurryOfStrength` | `AttacksPerMinute` | eigene | **6** Keulen und Vorschlaghämmer |
| `perkFlurryOfFortitude` | `AttacksPerMinute` | eigene | **5** Schlagringe, bloße Hand |
| `perkFlurryOfAgility` | `AttacksPerMinute` | eigene | **4** Messer |
| `perkFlurryOfPerception` | `AttacksPerMinute` | eigene | **3** Speere |
| `perkFlurryOfIntellect` | `AttacksPerMinute` | eigene | **0** — beide Träger gesperrt |
| `perkStrengthMastery` | `HarvestCount`, `EntityDamage [perkMiner69r]`, `DismemberChance [head]` | Blockmarken | Bergbau |
| `perkFortitudeMastery` | `HealthMax` | keine | wirkt immer |
| `perkAgilityMastery` | `ReloadSpeedMultiplier`, `GeneralDamageResist` | keine | Nachladen = Bogen |
| `perkPerceptionMastery` | 2× `HarvestCount`, `EntityDamage [perkDeadEye]`, `EntityDamage [perkJavelinMaster]` | Blockmarken | Zerlegen |
| `perkIntellectMastery` | `VehicleFuelUsePer`, `VehicleSelfDamage [vehicle]` | Fahrzeuge | **0** — `vehicle*` ist 16 von 17 gesperrt |

**Zwei neue Tote.** `perkIntellectMastery` wirkt ausschließlich auf Fahrzeuge und
`perkFlurryOfIntellect` auf zwei gesperrte Gegenstände. Beide sind in WP7.2 dazugekommen —
WP7.3 hatte zehn verborgen, jetzt sind es **zwölf**. Keiner der beiden war am Namen zu
erkennen; erst die Wirkung hat sie entlarvt.

**Folge für den Bau:** `perkFlurryOfStrength` wandert mit den Keulen zum Krieger, obwohl es
„Strength" heißt, und `perkFlurryOfPerception` mit den Speeren zum Jäger. Marke und Perk in
einem Stück — ein Perk unter einem Baum und sein Gegenstand unter einem anderen wäre ein
Perk, den niemand nutzen kann.

Die drei Ernte-Marken `perkStrengthMasteryBrassHarvest`, `PercMasteryDukeHarvest` und
`PercMasterySteelHarvest` tragen **keine Gegenstände**, sondern Blöcke: 5, 102 und 31
Nennungen in `blocks.xml`. Beide Mastery-Perks sind damit wirksam.

### 6.2 Jeder Attribut-Perk nennt sein Attribut fünfmal

Gemessen hat **jeder** der 50 Attribut-Perks genau **fünf** `level_requirements` mit
`<requirement name="ProgressionLevel" progression_name="attX">`. Wer ein Attribut wechselt,
braucht also sechs Patch-Zeilen: eine für `parent` und fünf für `progression_name`. Wird
eine vergessen, hängt der Perk unter dem neuen Baum und verlangt die Stufe des alten —
**unerreichbar, ohne eine Fehlermeldung**. 21 Perks wechseln, das sind 105 Zeilen. Darum
erzeugt `tools/gen/wp7-perks.ps1` sie.

Die **sieben** Perks unter `skillGeneralPerks` haben gemessen **null**
`level_requirements`. Sie hängen an keinem Attribut, sondern am Spielerrang, und bleiben
darum unberührt: sie in einen Baum zu hängen hieße, fünf Freischaltstufen je Perk zu
erfinden — Balancing, keine Struktur.

### 6.3 Vanilla gibt allen fünf Nahkampf-Bereichen denselben Schlüssel

`skillCombatPerksName` und `skillCombatPerksDesc` teilen **alle fünf** `*Combat`-Bereiche —
`skillPerceptionCombat`, `skillStrengthCombat`, `skillFortitudeCombat`,
`skillAgilityCombat`, `skillIntellectCombat`. Vier davon sind unsere. Wer den Schlüssel
überschreibt, nennt Wuchtwaffen, Faustkampf, Bogen und Messer und Wurfwaffen **alle gleich**
— dieselbe Falle wie `blockVariantHelperGroupDesc` (50 Blöcke) und `doorGroupDesc` (55) in
WP6. Sie tragen darum eigene `prk700_`-Schlüssel, gesetzt per `<set>` auf `name_key` und
`desc_key`. Der Doppel-Schlüssel-Wächter im Erzeuger hat das gefunden, nicht das Lesen.

Ebenfalls geteilt, aber nicht unser Problem: `perkBookGroupLongDesc` über alle **19**
Buchreihen (WP7.4).

`skillPerceptionGeneral` hat gemessen **kein** `desc_key`. Dort steht darum ein
`<setattribute>`, kein `<set>`.

### 6.4 Was dabei herauskommt — und wo es dünn ist

| Baum | Attribut | Unterbereiche | Perks |
|---|---|---|---|
| Krieger | `attFortitude` | Wuchtwaffen, Faustkampf, Zähigkeit | **9** |
| Jäger | `attAgility` | Bogen und Messer, Pirsch, Wurfwaffen, Fährte | **12** |
| Fuhrmann | `attPerception` | Marsch, Tragkraft, Handel und Wege | **9** |
| Handwerker | `attStrength` | Bergbau, Werkstattkunde | **4** |
| Heiler | `attIntellect` | Heilkunde | **4** |

**Der Handwerker und der Heiler verfehlen D67** („rund neun je Baum"), und das ist kein
Versehen, sondern das Ergebnis des Purge: Vanillas `attIntellect` trug Elektrik,
Geschütztürme und Fahrzeuge — alles gesperrt —, und von `attStrength` sind die Keulen zum
Krieger gewandert. Übrig bleiben in diesen beiden Bäumen vier Perks, die inhaltlich passen.
Weitere wären Erfindung; die Zahlen dafür gibt es nicht, und D61 hat denselben Fall schon
einmal gegen erfundene Staffeln entschieden.

Zwei gemessene Wege, das zu füllen, beide nicht gegangen:

1. **Eigene Perks.** Vier bis fünf je Baum, mit Vanillas `passive_effect`-Namen. Braucht
   Zahlen ohne Balancing-Grundlage.
2. **Die überlebenden Handwerks-Stufen an die Bäume hängen.** `craftingWorkstations`
   behält 15 von 20 Marken, `craftingHarvestingTools` 8 von 10 — das ist die Tiefe des
   Handwerkers, und `craftingMedical` (1 von 8) die des Heilers. Sie hängen heute an
   `attCrafting`. Ein `<set .../@parent>` würde sie umhängen. **Risiko R8:**
   `XUiC_CategoryList::SetupCategoriesByWorkstation` liest `attcrafting`; gemessen filtert
   die Methode `IsAttribute` und nutzt nur Attributnamen und -symbole, die
   Handwerks-Stufen also nicht — aber das ist ein Schluss aus der Aufrufliste, kein
   beobachtetes Verhalten.

### 6.5 Was WP7.2 nicht gemacht hat

Die **Rang-Texte**: fünf Rangnamen und fünf Langtexte je Perk, zusammen rund **450**
Schlüssel. Sie beschreiben die Wirkung, und die Wirkung ändern wir nicht — Vanillas
„Deal 10% more damage with knives" bleibt für einen Perk namens „Tiefer Schnitt" sachlich
richtig, nur englisch. Das ist eine Übersetzungsaufgabe und gehört zu **WP8.5** (D7), nicht
zu WP7.2. Gezählt sind 670 Schlüssel an allen 57 Perks; 102 davon trägt WP7.2.

### D68 — die Handwerks-Stufen sind jetzt die Tiefe der Bäume (8. November 2026)

Vom Nutzer entschieden: die **14 überlebenden** Handwerks-Stufen wandern von `attCrafting`
an die fünf Bäume. Je ein `<set>` auf `@parent`, keine erfundene Zahl.

| Baum | Handwerks-Stufen | lebende Freischalt-Marken |
|---|---|---|
| Handwerker | Werkzeugschmiede, Flickwerk, Werkstattbau, Rüstungsbau | 8/10, 1/2, 15/20, 8/68 |
| Krieger | Schlagringe, Keulenbau, Hammerbau | 3/3, 2/3, 3/3 |
| Jäger | Klingenschmiede, Bogenbau, Speerbau | 3/3, 5/5, 3/3 |
| Heiler | Wundversorgung, Küche, Kräutergarten | 1/8, 9/37, 4/12 |
| Fuhrmann | Sattlerei | 3/3 |

Damit hat der Handwerker 4 Perks plus 4 Stufen, der Heiler 4 plus 3 — D67 ist anders
erfüllt als gedacht, aber erfüllt.

`attCrafting` **bleibt bestehen** (`XUiC_CategoryList::SetupCategoriesByWorkstation` liest
die Zeichenkette `attcrafting`) und wird nur **verborgen**, weil es nach dem Umhängen ein
leerer Behälter mit Vanilla-Namen wäre.

**Risiko R8 ist der einzige Punkt in WP7, an dem ein Schluss aus einer Aufrufliste gegen
das Spiel steht.** Die Methode filtert gemessen `get_IsAttribute` und nutzt nur
`ProgressionClass::Name` und `::Icon`; `Hidden` liest sie nicht. Beobachtet ist das nicht →
**Prüfliste 15**. Fällt es falsch aus, fehlen Kategorie-Knöpfe an den Werkbänken.
