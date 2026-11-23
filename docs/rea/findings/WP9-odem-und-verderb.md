# WP9 — Odem als Kosten, Zauber-Projektil, Meide-Zone, Plätze, sechstes Attribut, Verderb

**Stand:** 23. November 2026 (Plan-0002 WP9.5; Bezug: F-15 D36, F-19 D32, D111, Q32, Vertrag 07 §3.4)
**Build:** V 3.40 b10, Assembly-CSharp SHA-256 `cb54022c…56c58` · Soll-Datei `tools/meta/expect/wp95.tsv`
**Frage:** Was von der Volksmagie (F-15) und vom Verderb (F-19) geht ohne C#?
**Methode:** `mod700meta types` / `members` (Felder, Aufrufe, Zeichenketten), Vanillas XML. Kein Code
übernommen. **Statisch gelesen, im Spiel nicht geprüft.**

## Kurz

| Frage | Antwort | Weg |
|---|---|---|
| Kann ein Zauber Odem als Kosten prüfen und abziehen? | **ja, sehr wahrscheinlich** | XML |
| Eigenes Projektil (Glutpfeil, Turm) | Klassen da (`ItemActionProjectile`, `Launcher` 4×, `Projectile` 13× in `items.xml`); eigener Partikel = Asset | XML + Asset |
| Meide-Zone (Bannkreis) | **nein** als Fläche; nur Flucht vor Wesen nach Merkmalen (`EAIRunawayFromEntity`) | Rückfall: Aura (F-15) |
| Plätze für Amulette (Q32) | vier Abzeichen-Plätze (`BiomeBadge` … `BiomeBadge4`) | XML, Konflikt mit Biom-Fortschritt prüfen |
| Sechstes Attribut im Fenster (D111) | Leiste hat **8** Felder, `progression.xml` **8** Attribute — ein neuntes braucht ein breiteres Raster | XML (XUi), additiv |
| Verderb je Stapel über Zeit | **nicht** in XML: es gibt Werte am Gegenstand, aber keine Uhrzeit und keinen Takt für Stapel im Rucksack | C# oder vereinfachter Verderb |

## 1. Odem als Kosten (F-15:88–90)

- `ItemAction` hat das Feld **`ExecutionRequirements`** (`RequirementGroup`), und
  `ItemAction::CanExecute(ItemActionData)` liest es.
- Gefüllt wird es in `ItemClassesFromXml::parseItem` über `RequirementBase::ParseRequirementGroup` —
  also aus `<requirement>`-Zeilen **innerhalb** einer `<action>` in `items.xml`.
- ~~Vanilla benutzt das nicht (0 Bedingungen in einer `<action>`), darum stand es nirgends.~~
  *Berichtigt mit WP10.5c (2026-11-23):* Vanilla benutzt es **einmal** — `thrownAmmoMolotovCocktail`,
  `Action1` (Anzünden), `<requirement name="CVarCompare" cvar="_underwater" operation="LT" value="1"/>`.
  Die erste Zählung suchte `<action>`; Vanilla schreibt Aktionen als `<property class="Action0">`. Das
  stützt die Bau-Skizze: dieselbe Form an derselben Stelle.

**Bau-Skizze:** Zauber-Gegenstand mit `<requirement name="CVarCompare" cvar="cv700_odem" operation="GTE" value="…"/>`
in der Aktion und einem `triggered_effect` beim Auslösen, der `cv700_odem` per `ModifyCVar` senkt.
Ein Schreiber (Vertrag 07 §1 Nr. 2): die Buffs und Effekte des Spielers. **Offen:** ob eine
Aktion ohne erfüllte Bedingung sichtbar verweigert (Ton, Meldung) oder still nichts tut — S-35 (1).

## 2. Zauber-Projektil

`ItemActionProjectile::ExecuteAction(ItemActionData, bool)` ist da; Vanilla nutzt Werfer- und
Projektil-Klassen für Armbrust, Bogen und Werfer. Ein Glutpfeil ist damit Gegenstand + Munition in
XML; das Aussehen (Flamme, Leuchtspur) braucht ein eigenes Partikel-Asset (F-16, Unity).

## 3. Meide-Zone

Unter den 31 `EAI*`-Klassen gibt es keine, die eine **Fläche** meidet. `EAIRunawayFromEntity`
(Felder `flags`, `safeFlags`, `safeDistance`, `dangerDistance`) lässt Wesen vor **Wesen** mit
bestimmten Merkmalen fliehen; Vanilla gibt es scheuen Tieren
(`flags=animal,bandit,player,zombie;safeFlags=timid`). Seuchentote damit vor einem Bannstein fliehen
zu lassen, hieße, den Bannstein als Wesen zu bauen — zu schief. **Bannkreis bleibt Aura** (Schaden bzw.
Verlangsamung im Umkreis), wie F-15 als Rückfall vorsieht. Die Triage (WP9.6) entscheidet, ob ein
Patch die Zielwahl dämpfen soll.

## 4. Plätze für Amulette (Q32)

`EquipmentSlots`: Kopf, Brust, Hände, Füße, **BiomeBadge, BiomeBadge2, BiomeBadge3, BiomeBadge4**,
vier Kleidungsplätze, Rucksack. Vanilla trägt auf den Abzeichen-Plätzen die Biom-Abzeichen
(`EquipSlot` 73× in `items.xml`). Ein Amulett kann einen dieser Plätze nehmen; dann muss geklärt
sein, welcher Platz dem Biom-Fortschritt (WP6.3, S-30 (4)) bleibt. Vorschlag: Amulett auf
`BiomeBadge4`.

## 5. Sechstes Attribut (D111, P2-E16)

`progression.xml` hat 8 `<attribute>` (5 echte, dazu Allgemein, Bücher, Handwerk). Das
Fertigkeitsfenster (`windowSkillList` in `XUi_InGame/windows.xml`) zeigt die Kategorien in einem
Raster mit `cols="8"`. Ein neunter Eintrag (Runenkundiger) braucht `cols="9"` und mehr Breite — ein
`set`-Patch in XUi, additiv (D5). `XUiC_SkillList` liest die Liste aus `Progression` (`ProgressionValue`,
`ProgressionClass`), nicht aus einer festen Zahl (Indiz). Test S-35 (3).

## 6. Verderb (F-19, D32)

- **Werte am Gegenstand gibt es:** `MinEventActionSetItemMetaFloat` (Felder `change`, `relative`,
  `metaKey`) und die Bedingung `CompareItemMetaFloat`; dahinter `ItemValue::SetMetadata(string, float)`
  und `TryGetMetadata`. Vanilla nutzt das 68× (z. B. Ladung einer Waffe, Schlüssel `charge`).
- **Was fehlt:** ein Zeitwert. `change` ist eine feste Zahl, kein „jetzt"; und ein Effekt erreicht
  nur den gehaltenen oder getragenen Gegenstand, nicht einen Stapel im Rucksack oder in einer Truhe.
  Verderb **nach Zeit** braucht daher C#: beim Aufnehmen die Weltzeit als Wert an den Stapel, beim
  Essen oder Öffnen vergleichen (F-19 „Zeitstempel je Stack").
- **XML-Rückfall ohne Uhr:** frische Lebensmittel tragen beim Essen ein Krankheitsrisiko
  (`RandomRoll`), Konserven nicht; Räuchern, Salzen, Trocknen machen aus frisch haltbar. Das
  trifft D32 („verderben nach Zeit") nur halb — Entscheidung N-115.

## Soll-Signaturen

`tools/meta/expect/wp95.tsv` (8 Zeilen): `CanExecute`, `parseItem`, `ParseRequirementGroup`,
`SetItemMetaFloat::Execute`, `CompareItemMetaFloat::IsValid`, `SetMetadata`, `TryGetMetadata`,
`ItemActionProjectile::ExecuteAction`.
