# WP9 — Licht am Spielerort, Mitspieler in der Nähe, Seuchennacht, Direktor

**Stand:** 23. November 2026 (Plan-0002 WP9.4; Bezug: F-17 B3/B4/B5, F-09, D12, D18, W-33, Vertrag 07)
**Build:** V 3.40 b10, Assembly-CSharp SHA-256 `cb54022c…56c58` · Soll-Datei `tools/meta/expect/wp94.tsv`
**Frage:** Braucht das Grauen C# für „ist es hier dunkel?" und „ist ein Mitspieler nah?", wie der
Kurz-Check vom 2026-11-07 schloss? Wie lässt sich die Seuchennacht abfragen, umfärben und ankündigen?
**Methode:** alle Klassen, die von `RequirementBase` erben (also alles, was in einer Buff-Bedingung
stehen kann), aus der DLL gelistet statt aus Vanillas `buffs.xml` gesammelt; dazu Felder und Aufrufe
einzelner Klassen und Vanillas XML. Kein Code übernommen. **Statisch gelesen, im Spiel nicht geprüft.**

## Kurz

1. **Licht am Spielerort ist XML.** Die Bedingung `CompareLightLevel` vergleicht
   `Entity::GetLightBrightness()` (als Prozent) — Vanilla führt sie nur in seiner Kommentarliste in
   `buffs.xml` (Zeile 16467) und benutzt sie nirgends. **Der Kurz-Check hat sie übersehen,** weil er
   nur gesammelt hat, was Vanillas XML schon benutzt. Die DLL kennt **79** Buff-Bedingungen.
2. **Mitspieler in der Nähe ist sehr wahrscheinlich XML.** Ein Buff kann andere Spieler im Umkreis
   treffen (`target="selfAOE"` mit `range`, so in Vanilla `buffRingOfFireEffect`; dazu die Ziel-Art
   `selfOtherPlayers`), und `IsAlly` prüft `EntityPlayer::get_IsFriendOfLocalPlayer()`. Jeder Spieler
   „strahlt" also einen kleinen Buff „Gesellschaft" auf Verbündete in z. B. 10 m. Ob der Buff auf
   einem fremden Spieler ankommt, zeigt nur der Test (S-34 (2)).
3. **„Seuchennacht läuft" ist XML:** die Bedingung `IsBloodMoon` fragt `SkyManager::IsBloodMoonVisible()`.
   Dazu `GameStatInt`/`GameStatBool` mit Vanillas Spielwerten `BloodMoonDay` (58) und `BloodMoonWarning`
   (61), und `IsDayNumber` (Spieltag).
4. **Der Vortag** (Vorboten, F-09) ist **halb** belegt: Tag und Tag der Seuchennacht sind beide
   abfragbar; ob eine Bedingung „Tag = Seuchennacht-Tag − 1" in XML ausdrückbar ist, ist nicht gelesen.
   Sonst schreibt der Server einen CVar (Vertrag 07 §4, Weg 2).
5. **Himmel der Seuchennacht:** je Biom gibt es in `biomes.xml` ein Wetter `bloodMoon` (Nebel, Wolken,
   Wind — XML, 5×). Die rote Tönung hängt an einer eigenen Spektrum-Art `BloodMoon` (Enum 5), deren
   Farbkurven nicht in der XML stehen. Ein Wetter kann ein Spektrum nennen (`<spectrum name="Foggy"/>`,
   wie bei Regen und Sturm). **Ob das Spiel die Seuchennacht trotzdem auf `BloodMoon` zwingt, ist
   nicht gelesen** — Versuch S-34 (3).
6. **Klang nur beim lokalen Spieler:** die Bedingung `IsLocalPlayer` gibt es (für Trugbilder, F-17 B4).
7. **Direktor:** Vanillas Planer laufen in `AIDirectorBloodMoonComponent` (`Tick`, `CalcNextDay`,
   `StartBloodMoon`, `EndBloodMoon`; Felder `BloodMoonFrequency`, `BloodMoonRange`) und
   `AIDirectorWanderingHordeComponent` (`Tick`, `ChooseNextTime`; `HordeNextTime`, `BanditNextTime`).
   Ein eigener Direktor (F-17 B5) könnte als Postfix auf diese `Tick` hören oder einen eigenen Takt
   haben — Entscheidung in der Triage (WP9.6).
8. **Schläfer:** `SleeperVolume`, `BlockSleeper`, `NetPackageSleeperWakeup` — das Gerüst für
   „Totstellen" (F-17 B6) ist Vanillas Schläfer-Volumen in Orten (Prefab-Arbeit, F-07). Nicht vertieft.
9. **Tierlaute für die Stille** (Tiere verstummen): **nicht gelesen** — offen für die Triage.

## 1. Die 79 Buff-Bedingungen (Auszug, was für Grauen und Seuchennacht zählt)

| Bedingung | liest | Vanilla benutzt sie | für uns |
|---|---|---|---|
| `CompareLightLevel` | `Entity::GetLightBrightness()` | nein (nur Kommentar) | **Dunkelheit** (F-17 B3) |
| `IsAlly` | `EntityPlayer::get_IsFriendOfLocalPlayer()` | 2× | Gesellschaft (B3) |
| `IsBloodMoon` | `SkyManager::IsBloodMoonVisible()` | 2× | Seuchennacht läuft (F-09) |
| `IsDayNumber` | `GameUtils::WorldTimeToDays` | 2× | Vortag (F-09) |
| `GameStatBool` / `GameStatInt` | `GameStats` (z. B. `BloodMoonDay`, `BloodMoonWarning`) | 2× / 1× | Vortag, Warnung |
| `IsLocalPlayer` | Vergleich mit dem lokalen Spieler | — | Trugbilder nur beim Betroffenen (B4) |
| `IsIndoors`, `IsSheltered`, `IsNight`, `TimeOfDay`, `InBiome`, `RandomRoll`, `CVarCompare`, `HasBuff`, `SandboxOptionBool` | — | ja | wie bisher |

Vollständige Liste (alphabetisch): ArmorGroupCount, ArmorGroupLowestQuality, BlockHasTags,
BlockStandingOn, BurstRoundCount, CatapultStrainAmount, CompareItemMetaFloat, CompareLightLevel,
CVarCompare, EntityHasMovementTag, EntityHasStanceTag, EntityTagCompare, GameStatBool, GameStatFloat,
GameStatInt, HasAttachedPrefab, HasBuff, HasParticle, HasTrackedEntity, HitLocation, HoldingItemBroken,
HoldingItemHasTags, InBiome, InSafeZone, IsAlive, IsAlly, IsAttachedToEntity, IsBloodMoon, IsCorpse,
IsDay, IsDayNumber, IsEquipped, IsFPV, IsHeldItem, IsIndoors, IsInstigator, IsItemActive, IsLocalPlayer,
IsLookingAtBlock, IsLookingAtEntity, IsMale, IsNight, IsOnLadder, IsPrimaryAttack, IsSDCS,
IsSecondaryAttack, IsSheltered, IsSleeping, IsStatAtMax, ItemHasTags, NotHasBuff, NPCIsAlert,
PerksUnlocked, PlayerItemCount, PlayerItemCountByTags, PlayerLevel, ProgressionLevel, ProjectileHasTags,
RandomRoll, RecipeUnlocked, RequirementItemModTier, RequirementItemTier, RoundsInMagazine,
SandboxOptionBool, SandboxOptionFloat, SandboxOptionInt, StatCompareAbs, StatCompareCurrent,
StatCompareMax, StatCompareModMax, StatComparePercCurrentToMax, StatComparePercCurrentToModMax,
StatComparePercModMaxToMax, TargetRange, TimeOfDay, TriggerHasTags, WasAlive, WornItemMods, WornItems.

**Nebenbei für F-15 und F-19 (WP9.5):** `CompareItemMetaFloat` vergleicht einen Zahlenwert **am
Gegenstand** — ein Anhaltspunkt für Verderb je Stapel ohne C#.

## 2. Ziel-Arten eines Buff-Effekts

`MinEventActionTargetedBase/TargetTypes`: `self`, `other`, `selfAOE`, `otherAOE`, `positionAOE`,
`selfOtherPlayers`. In Vanillas XML: `selfAOE` 2×, `otherAOE` 11×.

## 3. Folgen

- **F-17 B3 (Grauen):** „Im Dunkeln, allein, draußen" lässt sich in XML schreiben —
  `CompareLightLevel` + Gesellschafts-Buff + `IsSheltered`/`IsIndoors`. Der Widerspruch W-33 (grobe
  XML-Fassung gegen C# für die Lichtabfrage) entfällt, wenn S-34 (1) und (2) bestehen. Vertrag 07
  §3.1 und §5 nennen die Messung bis dahin „offen" — jetzt: XML, Indiz.
- **F-09:** „Seuchennacht läuft" per `IsBloodMoon`; Nebel per Wetter `bloodMoon`; Farbe vielleicht per
  Spektrum im Wetter (S-34 (3)); Vortag offen (§ Kurz 4). Die Vorboten selbst (Krähen, Läuten) sind
  Klang und Partikel am Spieler — XML, sobald der Vortag erkennbar ist.
- **F-17 B5 (Direktor):** bleibt der einzige Teil aus F-17/F-09, der sicher C# braucht (Phasenlogik,
  Server). Ziel-Kandidaten oben; ein Patch erst nach der Triage (WP9.6) und mit Vertrag 06.
- **Hook-Hypothesen** F-17 (Licht ✗) und F-09 (Planer ?, `IsBloodMoonTime` ?) sind berichtigt.

## Soll-Signaturen

`tools/meta/expect/wp94.tsv` (14 Zeilen) — die Bedingungen, `GetLightBrightness`,
`IsBloodMoonVisible` und die `Tick`-/Planer-Methoden beider Direktor-Teile.
