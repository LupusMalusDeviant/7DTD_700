# F-21 — Fertigkeiten & Learning by Doing

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1: **fünf** Bäume (XML) · 2: Runenkundiger + Learning by Doing | X+H | S | ja |

## Ziel
Ein **komplett neues Fertigkeitssystem** (D47) mit sechs Bäumen, die zu den Rollen von 700
passen, und Fortschritt durch **Tun** statt Magazin-Lesen (D24).

## Die Bäume — fünf in Phase 1, der sechste in Phase 2 (D66)

Jeder Baum **ist** ein Vanilla-Attribut, umgedeutet (D66). Die Spalte „Attribut" ist
nicht beliebig: jedes Vanilla-Attribut wirkt nur auf Gegenstände, die seine Marke tragen,
und die Zuordnung folgt den Marken, die den Purge überleben — gemessen in
[WP7-fertigkeitsbaeume.md](../rea/findings/WP7-fertigkeitsbaeume.md) §2.2.

| Baum | Attribut | lebende Marken | Schwerpunkt | Beispiel-Perks | Koop-Synergie (D44) |
|---|---|---|---|---|---|
| **Krieger** | `attFortitude` | 4: Schlagringe, bloße Hand | Nahkampf, Schild, schwere Rüstung | Klingenkunde, Wuchtwaffen, Schildwall, Rüstungsgewöhnung | Schildwall-Bonus für Nachbarn |
| **Jäger** | `attAgility` | 17: Bögen, Armbrüste, Pfeile, Messer | Bogen, Armbrust, Wurfwaffen, Schleichen, Spuren, Tiere jagen | Bogenschießen, Wurfarm, Fährtenlesen, Leiser Tritt | Gegner bzw. Spuren für Gruppe markieren |
| **Handwerker** | `attStrength` | 18: Äxte, Hacken, Schaufeln, Hammer | Schmieden, Bauen, Werkstätten, Reparatur, Abbau | Schmiedekunst, Zimmerei, Steinmetz, Bergmann | Reparatur für andere, Gesellen anleiten |
| ~~**Runenkundiger**~~ **Phase 2 (D66)** | — | — | Magie, Odem, Runen, Runensteine, Flüche | Runenritzen, Odemtiefe, Glutzauber, Bannkunde, Hochmagie | Gruppen-Schutzzeichen |
| **Heiler** | `attIntellect` | 0 — keine Waffenmarke | Kräuter, Krankheiten, Tränke, Segen, Furcht | Kräuterkunde, Wundarzt, Seuchenkunde, Seelentrost | Heilt bzw. segnet Gruppe, Furcht-Aura senken |
| **Fuhrmann** (hieß „Transport & Logistik") | `attPerception` | 4: Speere, wandern in WP7.2 zum Jäger | Tragkraft, Karren, Tiere, Pferde, Wegsteine, Marsch | Tragkraft, Wagnerei, Tierkunde, Sattlerei, Wegkunde | Gruppenlast, Wegsteine für Gruppe |

- **Attributwerte:** Jeder Baum hat einen Stufenwert (wie Vanilla-Attribute), der Perks im Baum freischaltet. Der Wert *Runenkundiger* ist der **Magiewert** (D36), z. B. für das Runenross — in Phase 2.
- **Fernkampf und Magie gleichwertig** (D22): Jäger und Runenkundiger sind gleich mächtige Fernkampf-Wege. **In Phase 1 nicht erfüllt** — der Jäger steht allein, weil es keinen magischen Weg gibt (D66, ausdrücklich getragen).
- Das Vanilla-Attributsystem wird **umgedeutet, nicht ersetzt** (D66). Die `[verifizieren]`-Marke ist beantwortet: in 54 940 Methodenkörpern stehen genau **zwei** Attributnamen als Zeichenkette (`attFortitude` in `EntityPlayerLocal::Update`, `attcrafting` in `XUiC_CategoryList::SetupCategoriesByWorkstation`). Wenig hart — und trotzdem umgedeutet, weil ein umbenanntes Attribut diese zwei Zeilen heil lässt und ein gelöschtes nicht. Sichtbar bleibt kein Vanilla-Name: die 115 Attribut-Schlüssel tragen unseren Text, die zehn toten Perks und zehn toten Handwerks-Stufen `hidden="true"`.

## Learning by Doing (D24, D48)
**Regel:** Ein Rezept bzw. eine Fertigkeit wird nur nutzbar, wenn die **Grundfähigkeit**
vorhanden ist, per Skill-Punkt im Baum **oder** per gefundener bzw. gekaufter Abschrift.
Danach verbessert **Benutzen** die Fertigkeit: höhere Qualität, neue Varianten, weniger
Materialverbrauch.

**Technischer Vorschlag (D48, nach REA final):**
1. **Vanilla-Crafting-Skills weiterverwenden.** V1.x bis V3.x hat Crafting-Skills (Fortschritt pro
   Kategorie, bisher durch Magazine). Diese Struktur (Stufen, freigeschaltete Rezepte und
   Qualitäten) bleibt als Datenmodell in `progression.xml`.
2. **Fortschritt umleiten:** Statt Magazin-Lesen erhöht **Herstellen bzw. Benutzen** den
   Fortschritt. Bevorzugt per XML-Trigger (z. B. Buff-Event beim Herstellen, falls vorhanden),
   sonst per **Harmony-Postfix** am Abschluss eines Craft-Vorgangs bzw. am Treffer.
3. **Abschriften** sind die Grundfähigkeit (Stufe 1) bzw. Sprünge, kein Fortschritt durch Masse.
4. **Server-autoritativ:** Fortschritt wird auf dem Server gezählt (Werkstätten laufen serverseitig).

REA-Fragen → [hook-hypothesen.md#f-21](../rea/hook-hypothesen.md#f-21)

## Akzeptanzkriterien
- [ ] **Fünf** Bäume vollständig, keine Vanilla-Attribut- bzw. -Perknamen sichtbar (der sechste in Phase 2, D66)
- [ ] Ohne Grundfähigkeit ist ein Rezept gesperrt; mit Grundfähigkeit steigt die Qualität durch wiederholtes Herstellen
- [ ] Learning-by-Doing-Fortschritt bleibt nach Server-Neustart erhalten
- [ ] Jeder Baum bietet einen tragfähigen Build bis T4


## Stand 2026-11-08 — WP7.1 und WP7.3 stehen, drei Schritte fehlen

Alles hier ist **geschriebenes und auflösbar geprüftes XML, im Spiel hat es niemand
gesehen**. Messungen: [WP7-fertigkeitsbaeume.md](../rea/findings/WP7-fertigkeitsbaeume.md).

### Was gebaut ist

**WP7.1 — die fünf Bäume heißen so.** 115 Localization-Schlüssel, 23 je Attribut:
der kleingeschriebene Kurzname, `…Name`, `…Desc` und je zehn `RankNNDesc` plus
`RankNNLongDesc`. Jeder Baum hat zehn eigene Rangnamen:

| Baum | Rang 1 | Rang 5 | Rang 10 |
|---|---|---|---|
| Handwerker | Hilfshand | Erzgräber | Altmeister |
| Krieger | Raufbold | Recke | Heerführer |
| Jäger | Schlingensteller | Bogenschütze | Waidmeister |
| Heiler | Wundwäscher | Wundarzt | Lebensretter |
| Fuhrmann | Lastträger | Treiber | Wegmeister |

Erzeugt von `tools/gen/wp7-baumtexte.ps1`, und das ist kein Luxus: **Vanilla benennt die
Rangschlüssel nicht einheitlich.** Vier Attribute schreiben `attXRank01Desc` bis
`Rank10Desc`, `attIntellect` aber `attIntellectRank1Desc` bis `Rank9Desc` und dann
`Rank10Desc` — ohne führende Null. Von Hand getippt wären neun Schlüssel still falsch
gewesen, und neun Rangnamen hätten im Spiel englisch dagestanden, ohne dass eine Prüfung
etwas meldet. Das Skript liest die Schlüssel aus `progression.xml` des Builds.

**WP7.3, erster Teil — zwanzig tote Zweige verborgen.** Zehn Perks und zehn
Handwerks-Stufen, deren Gegenstände der Purge vollständig entfernt hat, tragen
`hidden="true"`. Gelöscht wird keiner: `perkJunkMiner` steht 792 Mal in `blocks.xml`,
`perkGunslinger` 149 Mal in `items.xml` — das sind Marken, und ein `<remove>` nimmt sie
nicht mit.

### WP7.2 — die Bäume sind besetzt (8. November 2026)

| Baum | Attribut | Unterbereiche | Perks |
|---|---|---|---|
| Krieger | `attFortitude` | Wuchtwaffen, Faustkampf, Zähigkeit | **9** |
| Jäger | `attAgility` | Bogen und Messer, Pirsch, Wurfwaffen, Fährte | **12** |
| Fuhrmann | `attPerception` | Marsch, Tragkraft, Handel und Wege | **9** |
| Handwerker | `attStrength` | Bergbau, Werkstattkunde | **4** |
| Heiler | `attIntellect` | Heilkunde | **4** |

13 Unterbereiche umgehängt (8 davon wechseln das Attribut), 38 Perks zugeordnet, **105**
`progression_name`-Zeilen berichtigt, 9 Gegenstands-Marken umgehängt. Marke und Perk
wandern in einem Stück: `perkFlurryOfStrength` geht mit den Keulen zum Krieger, obwohl es
„Strength" heißt, und `perkFlurryOfPerception` mit den Speeren zum Jäger.

**Zwei weitere Perks waren tot und niemand sah es am Namen.** `perkIntellectMastery` wirkt
ausschließlich auf Fahrzeuge (`VehicleFuelUsePer`, `VehicleSelfDamage`), und `vehicle*` ist
16 von 17 gesperrt; `perkFlurryOfIntellect` trägt seine Marke auf zwei gesperrten
Gegenständen. Verborgen sind damit **zwölf** Perks, nicht zehn.

**Der Handwerker und der Heiler verfehlen D67** („rund neun je Baum") mit vier Perks. Das
ist das Ergebnis des Purge, nicht eine Entscheidung: `attIntellect` trug Elektrik,
Geschütztürme und Fahrzeuge, und von `attStrength` sind die Keulen zum Krieger gewandert.
Zwei gemessene Wege zum Füllen stehen in
[WP7-fertigkeitsbaeume.md](../rea/findings/WP7-fertigkeitsbaeume.md) §6.4 — eigene Perks
(braucht erfundene Zahlen) oder die überlebenden Handwerks-Stufen an die Bäume hängen
(`craftingWorkstations` 15 von 20, `craftingMedical` 1 von 8; Risiko R8). **Entscheidung
offen.**

**Die Rang-Texte fehlen:** fünf Rangnamen und fünf Langtexte je Perk, rund **450**
Schlüssel. Sie beschreiben die Wirkung, und die ändern wir nicht — Vanillas „Deal 10% more
damage with knives" bleibt für „Tiefer Schnitt" sachlich richtig, nur englisch. Das ist
Übersetzung und gehört zu **WP8.5** (D7).

### Was noch fehlt

- **WP7.2** Perks und Unterbereiche umhängen, mit den Gegenstands-Marken **in einem
  Stück**: Keulen und Vorschlaghämmer tragen heute die Handwerker-Marke und gehören zum
  Krieger, die Speere tragen die Fuhrmann-Marke und gehören zum Jäger. Marke und Perk
  müssen zusammen wandern, sonst steht ein Perk unter einem Baum und sein Gegenstand unter
  einem anderen.
- **WP7.4** die 133 Abschriften (19 Reihen à 7 Bücher plus je ein `*Complete`-Eintrag).
  Sechs Reihen sind gemessen tot. Die Wirkung sitzt an den einzelnen `<book>`-Knoten, nicht
  an den Gruppen — deren `<effect_group/>` ist leer.
- ~~**WP7.5** Rezepte an Grundfähigkeiten binden. Der Weg ist gemessen: ein Rezept ist genau
  dann sperrbar, wenn seine `tags` die Marke `learnable` tragen. Unsere 42 eigenen Rezepte
  tragen **keine** `tags` und sind damit heute offen.~~ Erledigt am 2026-11-16 (D70),
  siehe unten „WP7.5 — die Rezepte hängen an Stufen".

### Was dabei aufgefallen ist und nicht zu F-21 gehört

- **Sechs Patches aus WP6.4 landeten nirgends.** `lanternOld_02/03/04_Player` führen
  `Class` und `DescriptionKey` nicht selbst, sie erben sie — drei `<set>` auf `Class` und
  drei auf `DescriptionKey` trafen nichts. Das Spiel hätte je eine Zeile ins Protokoll
  geschrieben und weitergeladen. Gefunden vom ersten Lauf der neuen XPath-Prüfung,
  berichtigt zu `<append>`.
- **Die Denylist sagt acht tote Buchreihen, gemessen sind es sechs.** Die Zahl „133 Bücher
  in 19 Serien" stimmt genau.
- `drugHerbalAntibiotics` ist gesperrt und wäre ein Umdeutungs-Kandidat für den Heiler —
  gehört aber zu F-11 und damit Phase 2 (D50).

## Stand 2026-11-07 — Kurz-Check, **Entscheidung offen**

**Die sechs eigenen Bäume sind XML-Arbeit.** `progression.xml` führt Attribute, Perks, Skills,
Handwerks-Stufen und Bücher als Daten. Von den fünf Vanilla-Attributnamen steht **einer** im Code
(`attFortitude`, einmal, in `EntityPlayerLocal::Update`), dazu `attcrafting` in der
Werkbank-UI. Der Code hängt also fast nicht an den Vanilla-Attributen (D45 ist tragfähig).

**Learning by Doing kostet C#.** Es gibt keinen XML-Auslöser „Gegenstand fertig hergestellt“.
`buffs.xml` hat viele `triggered_effect trigger="…"`, aber keinen dafür; Handwerks-Stufen steigen
in Vanilla ausschließlich über Magazine. Damit ist F-21 das **erste echte Patch-Ziel** des
Projekts — Phase 2, nicht Phase 1, und vorher braucht es ein Finding plus Soll-Signatur
(Projektregel 2).

Wie weit Learning by Doing gehen soll, wenn es C# kostet, ist **noch nicht entschieden**.
Befund: [02-10-schnittstellen-kurzcheck.md](../rea/findings/02-10-schnittstellen-kurzcheck.md#prio-2--f-21-lernen-und-fortschritt)

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

### WP7.4 — die Bücher sind Abschriften (D69, 16. November 2026)

Vanillas 19 Buchreihen bleiben in Phase 1 das Fortschrittsmittel, umgedeutet:

| Reihe | Vanilla-Kennung | Blätter |
|---|---|---|
| Bergmannskunde | `skillArtOfMining` | 5 von 7 |
| Vom Keulenschlag | `skillBatterUp` | 7 |
| Vom Faustkampf | `skillBarBrawling` | 7 |
| Köhlerweisheit | `skillFiremansAlmanac` | 5 von 7 |
| Diebeshandwerk | `skillGreatHeist` | 7 |
| Vom Waidwerk | `skillHuntingJournal` | 7 |
| Finderglück | `skillLuckyLooter` | 7 |
| Der Nachtgänger | `skillNightStalker` | 7 |
| Bogenlehre | `skillArchery` | 7 |
| Vom Hammerschlag | `skillSledgeSaga` | 7 |
| Speerlehre | `skillSpearHunter` | 7 |
| Kampf in Mauern | `skillUrbanCombat` | 6 von 7, Abschluss ohne Wirkung |
| Brachlandschätze | `skillWasteTreasures` | 6 von 7, Abschluss ohne Wirkung |

Sechs Reihen fallen ganz: AutoWeapons, Enforcer, PistolPete, Shotguns, Sniper, TechJunkie.

**Die Reihen hängen an keinem Baum.** Sie bleiben unter `attBooks`, wie in Vanilla — eine
Zuordnung zu den fünf Bäumen wäre möglich (Bogenlehre zum Jäger, Vom Hammerschlag zum
Krieger), ist aber nicht gemessen und nicht entschieden.

**Ein Band heißt „‹Reihe›, Blatt *n* von *N*"**, und *n* ist die Stelle, die auch das
Fenster zeigt. Wo tote Bände gefallen sind, zählt die Reihe lückenlos neu, und der
Abschluss kommt nach dem letzten **lebenden** Blatt (D69, vom Nutzer entschieden).

**Was ein Blatt lehrt, steht noch in Vanillas Worten da** — rund 200 Wirkungstexte,
WP8.5. Für wen deutsch spielt, sind sie deutsch: Vanilla übersetzt sie selbst.

**Nicht Teil von WP7.4:** die 26 Fertigkeitshefte, mit denen eine Handwerks-Stufe steigt.
Sie sind das, was F-21 oben „Abschrift als Grundfähigkeit" nennt, und gehören zu WP7.5.
Zwei verschiedene Dinge heißen damit vorläufig ähnlich; den Namen der Hefte legt WP7.5
fest.

Einzelheiten und Messungen: `docs/rea/findings/WP7-fertigkeitsbaeume.md` §7.
Im Spiel gesehen hat das niemand → Prüfliste 16 im Plan.

### WP7.5 — die Rezepte hängen an Stufen, die Hefte sind Lehrblätter (D70, 16. November 2026)

**Die Regel** (vom Nutzer entschieden): *Vanillas Linie* — jedes unserer Rezepte wird so
behandelt, wie Vanilla sein Gegenstück behandelt. Von 42 eigenen Rezepten sind **24
gebunden** und **18 bewusst offen**.

| Stufe (unser Name) | Rezept | ab Level |
|---|---|---|
| Klingenschmiede | Sax | 11 |
| | Spatha | 36 |
| Keulenbau | Streitkolben | 36 |
| Werkzeugschmiede | Breitaxt | 11 |
| | Bartaxt | 26 |
| Schlagringe, Hammerbau, Speerbau | je T1 | 11 |
| | je T3 | 36 |
| Rüstungsbau | Wolle und Leder, Gambeson, Kettenzeug (zwölf Teile) | 11 |
| Werkstattbau | Webstuhl | 14 |

**Offen bleiben:** Luppe, Schmiedeeisen, Tiegelstahl und Klinge (die Schranke ist das
Werkzeug im Ofen — Blasebalg, Amboss, Schmelztiegel — und die hängen an Werkstattbau),
Schleifstein und Schmiedeflicken (D60), Nähzeug, Steppbahn, Holzfeuer und die neun
Bauteile der Wehrbauten.

**Warum nicht XML-Marken an den Rezepten selbst?** Die Bindung steht in *einer* Datei,
`mod/700_50_Fortschritt/Config/recipes.xml`; die Rezepte in 700_20, 700_30 und 700_40
tragen keine `tags`. Fehlt das Fortschritts-Modlet, sind alle Rezepte offen und nichts
bricht — und wer die Bindung ändern will, sucht an einer Stelle.

**Die Bindung schaltet die Qualität mit ein.** Ohne `tags` trug ein Rezept nicht einmal
seinen eigenen Namen als Marke; keine Qualitätszeile traf unsere Waffen und Rüstungen.
Jetzt steigt die Qualität mit der Stufe, auf Vanillas Leiter.

**Ein Lehrblatt hebt eine Stufe um eins.** Das ist der einzige Weg, auf dem eine
Handwerks-Stufe steigt — darum gehören die Hefte zu diesem Paket. 14 Lehrblätter leben
(„Lehrblatt: Klingenschmiede", „Lehrblatt: Rüstungsbau" …), die Hefte der zehn toten
Stufen sind gesperrt. Papier heißt Pergament.

Damit heißen zwei Dinge verschieden, die verschieden sind: eine **Abschrift** ist ein
Blatt aus einer Reihe und lehrt eine Fähigkeit (WP7.4); ein **Lehrblatt** hebt eine
Handwerks-Stufe.

**Was das für „Learning by Doing" heißt (D24):** der Satz oben — Grundfähigkeit „per
Skill-Punkt **oder** Abschrift" — ist in Phase 1 nur zur Hälfte gebaut. Für
Handwerks-Stufen gibt es gemessen keinen Kaufweg; gebaut ist der Weg über das Lehrblatt.
Das ist **nicht entschieden**, sondern festgehalten (Plan, Offene Punkte). *Notiz für
Phase 2:* wenn Tun die Stufe hebt, ist das Lehrblatt der Sprung und nicht mehr der
einzige Weg — genau die Rolle, die Punkt 3 oben den Abschriften gibt.

**Drei Zahlen sind Vanillas und nicht geprüft** (WP9): alle Rüstungsstufen öffnen bei
Rüstungsbau 11; der Schmelztiegel erst bei Werkstattbau 75; die oberste Qualität kostet
nur die Stufe, keine Sonderzutat.

Einzelheiten und Messungen: `docs/rea/findings/WP7-fertigkeitsbaeume.md` §8.
Im Spiel gesehen hat das niemand → Prüfliste 17 im Plan.
