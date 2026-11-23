# F-15 — Volksmagie (Runen, Segen, Tränke, Zauber)

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 2: Runen, Tränke, Segen, Runensteine, Odem · 4: Hochmagie | X+H (+A) | S+C | ja |

## Ziel
Magie ist im Jahr 700 real, aber bodenständig (Entscheidungen D9, D10). Sie ist erlernt, an
Material gebunden, dezent sichtbar und vor allem **der Ersatz für Vanilla-Technik, die nicht
in die Zeit passt**: Geschütztürme, Strom, Elektrofallen, Sprengstoff.

## Leitplanken
1. **Magie ersetzt Technik, nicht den Nahkampf** (Säule P3). Der Spieler kämpft weiterhin
   selbst; Magie verteidigt, unterstützt und schwächt.
2. **Odem + Material** (D36): Zauber verbrauchen **Odem**, einen eigenen, langsam
   regenerierenden Kraftvorrat (wie Ausdauer, eigene Leiste). Stärkere Effekte kosten
   zusätzlich Material (Runenkreide, Bernstein, Kräuter). Die Größe des Odem-Vorrats und der
   Zugang zu Zaubern hängen am Baum **Runenkundiger** (F-21); sein Stufenwert ist der
   **Magiewert**.
3. **Dezent** (D10), Ausnahme Endgame-Hochmagie (D38): Glimmen, Funken, Rauch, Glutpfeile, Geräusche. Keine Feuerbälle,
   Blitze, Teleportation oder Schockwellen.
4. **Erlernt:** Die Magie hängt am ~~Perkbaum **Runenkunde** (umgedeuteter Intellekt-Baum)~~
   **sechsten, eigenen Attribut Runenkundiger** (D111, D171; `attIntellect` bleibt der Heiler, D66)
   und an Abschriften (F-04). Sie ist kein Loot-Glück.
   ~~(**Widerspruch, offen** — siehe Prüfung 0003, W-01)~~ *W-01 berichtigt mit WP10.1 (D174, zu prüfen N-118).*
   *Gebaut mit WP10.3 (D176, N-120):* `att700_runenkundiger`, im Spiel **Runenkunde**, mit zwei Gruppen
   und vier Perks (Runenritzen, Bannkunde, Odemtiefe, Glutzauber) in `700_50_Fortschritt`; ihre
   Wirkungen kommen mit WP10.5–10.9.
5. **Christlich und heidnisch gleichwertig:** Runen und Segen sind zwei Traditionen mit
   unterschiedlichem Stil, aber gleicher Stärke. Die Mod wertet keinen Glauben.
6. **Vanilla zuerst (P5):** Jede Magieform wird auf ein bestehendes Vanilla-System
   abgebildet (siehe Tabelle). C# nur, wo das nicht reicht.

## Die vier Formen

| Form | Beispiele | Vanilla-System als Basis | Tiefe |
|---|---|---|---|
| **Runen & Zeichen** (passiv) | Runen in Waffen (Glutrune: Brandschaden; Bannrune: + Schaden gegen Seuchentote), in Rüstung (Schutzrune), am Haus (Schutzzeichen: Bonus im Umkreis) | **Item-Mods** (Waffen- und Rüstungs-Mods), Block mit Buff-Aura | X |
| **Segen & Flüche** (Zeit) | Segen der Wehr (weniger Schaden), Fluch der Schwere (Gegner verlangsamt), Totensegen (Seuchentote meiden dich kurz) | Verbrauchs-Item → **Buff** auf sich oder Ziel; Fluch als Wurf- oder Nahkampf-Treffer-Buff | X |
| **Tränke & Salben** | Eulenauge (Nachtsicht), Bärenmut (Furchtlos, + Stärke kurz), Wolfsbalsam (Regeneration) | **Konsumgüter + Buffs** (wie Vanilla-Drogen und -Getränke) | X |
| **Einfache Zauber** (aktiv) | Glutpfeil (kleines Feuerprojektil), Lichtfunke (schwebendes Licht, ersetzt Taschenlampe), Bannkreis (Gegner meiden kurz einen Bereich) | **Fernkampf-Item mit Projektil** (ItemActionRanged/Launcher-Prinzip, Projektil-Entity, Partikel); Lichtfunke als gehaltene Lichtquelle | X (+H) |

### Runensteine statt Geschütztürmen (Kern-Feature)
- **Runenstein der Glut:** stationär, schießt kleine Feuerpfeile auf Gegner in Reichweite.
  Ersetzt den Auto-Turret. Munition: **Glutladungen** (Kohle + Harz + Runenkreide).
- **Runenstein des Sturms** (später): kurze Salve aus mehreren Glutsplittern, geringe
  Reichweite. Ersetzt den Shotgun-Turret.
- **Tragbarer Runenstein** (Phase 3–4, optional): ersetzt Junk Turret bzw. Drohne.
- Optik: behauener Stein mit glimmenden Runen; Projektil als Glutpfeil mit Rauchspur (F-16).

### Runenkraft statt Strom (entschieden: D37 = Variante A)
Vanilla-Türme und Elektrofallen brauchen Strom. Zwei Wege:

| | **Variante A: Kraftlinien** | **Variante B: selbstversorgend** |
|---|---|---|
| Idee | Das **Vanilla-Stromnetz wird umgedeutet**: Generator → *Kraftstein* (verbraucht Bernstein bzw. Glutsteine statt Benzin), Solarzelle → *Sonnenstein*, Batterie → *Speicherstein*, Kabel → *Kraftfaden*, Schalter und Sensoren → *Runenschalter* | Runensteine brauchen **kein Netz** und arbeiten mit Munition bzw. Brennstoff im eigenen Inventar |
| Technik | Reines **XML** (Umbenennen, Rezepte, Modelle), Vanilla-Logik bleibt | **C#/Harmony**: Turm-Logik von der Strom-Abhängigkeit lösen |
| Vorteil | Säule P5, updatefest, Vanilla-Komplexität (Logik-Schaltungen) bleibt erhalten | Intuitiver, keine „Kabel“ im Jahr 700 |
| Nachteil | „Kraftfäden ziehen“ wirkt technisch; braucht gutes Theming | Eingriff in Power- bzw. TileEntity-System, REA-Pflicht, Netz-Sync |

**Entscheidung (D37): Variante A, Kraftlinien.** Variante B bleibt nur als spätere Option,
falls REA einen kleinen, sauberen Eingriff zeigt.

## Der Kern der Phase 2 in Zahlen (WP10.1, 2026-11-23)

**Alle Zahlen und Namen dieses Abschnitts sind Vorschläge — zu prüfen (D174, N-118).** Sie stecken den
Rahmen ab, gegen den WP10.3 bis WP10.9 bauen; das Spiel kann jede Zahl verschieben, der Rahmen
(Leitplanken, Balancing-Grundsätze) bleibt. Namen kommen ins Glossar, wenn ihr Gegenstand gebaut wird
(WP10.5), nicht vorher. Umfang ist der Kern aus GDD.md:197 — Hochmagie bleibt unten Notiz.

### Was ist was — die Abgrenzung

Vier Formen sind nur dann vier, wenn jede eine eigene Antwort auf „was kostet es, wer darf es, wie
lange hält es" hat. Diese Tabelle ist das Kriterium: ein neuer Einfall gehört in die Zeile, deren
Spalten er erfüllt, sonst ist er keine Volksmagie der Phase 2.

| | **Rune** | **Segen, Fluch** | **Trank, Salbe** | **Zauber** |
|---|---|---|---|---|
| Was es ist | Aufsatz in Waffe oder Rüstung, Zeichen am Haus | Verbrauchsgegenstand, gesprochen bzw. geworfen | Verbrauchsgegenstand, getrunken bzw. aufgetragen | Werkzeug, das bleibt |
| Kostet | Material, **einmal** beim Ritzen | **Odem** und der Gegenstand | nur Material (Kräuter, F-11) | nur **Odem**, je Auslösen |
| Wer herstellt | Runenkundiger ab Stufe 2, Runenritzer-Bank | Runenkundiger ab Stufe 2 | Heiler (`attIntellect`, D66) bzw. Abschrift, Kräuterküche | Runenkundiger ab Stufe 3 |
| Wer benutzt | jeder, der den Gegenstand trägt | nur mit Odem, also Runenkundiger ab Stufe 2 | **jeder** | nur mit Odem |
| Dauer | solange eingesetzt | **30–120 s**, dazu Abklingzeit | **3–10 min** | ein Schuss bzw. solange gehalten |
| Stärke | **10–15 %** auf **einen** Wert | stärker als ein Trank, kürzer | schwächer als ein Segen, länger | wie eine Waffe derselben Stufe |
| Stapeln | eine Rune je Gegenstand | derselbe Segen verlängert nicht, er setzt die Zeit neu | ebenso | — |
| Tradition (Leitplanke 5) | heidnisch | christlich (Segen); beide (Fluch) | keine — Hauswissen | beide |

*Warum Tränke ohne Odem:* sonst wären sie Segen mit anderem Namen. So hat der, der keine Punkte in den
Runenkundigen steckt, trotzdem Zugang zur Volksmagie — er kauft oder braut sie (P3: Magie unterstützt).

### Odem

| Wert | Vorschlag | Bemerkung |
|---|---|---|
| `cv700_odemMax` | **10 je Stufe** des Runenkundigen ab Stufe 2; Stufe 1 = 0 | Stufe 10 → 100; ohne Punkt kein Odem, also kein Segen, kein Zauber (D36) |
| Regeneration | **0,25 je Sekunde**; am Feuer (`buff700_amfeuer`, Vertrag 07) **0,5** | 20 Odem in 80 s, 100 Odem in 400 s; die Naht zu F-17 ist gewollt: Rast am Feuer |
| Anzeige | eigene Leiste unter der Ausdauer, additiv (D5) | WP10.6 |
| Wenn er fehlt | die Aktion geht nicht; eine Meldung sagt, warum | `ExecutionRequirements` (Finding WP9.5) sperrt; die Meldung **[verifizieren in WP10.6]** |

### Runen (Aufsätze, F-04 Runenritzer-Bank)

| Rune (DE / EN, Vorschlag) | Sitzt in | Wirkung | Material | Vorbild in Vanilla |
|---|---|---|---|---|
| **Glutrune** / Ember Rune | Nahkampfwaffe | 12 % Chance auf Brand (3 s) | Runenkreide 2, Glutstein 1 | `modMeleeClubBurningShaft` |
| **Bannrune** / Ward Rune | Waffe | +15 % Schaden gegen Seuchentote | Runenkreide 2, Bernstein 1 | Schaden mit `tags` |
| **Schutzrune** / Shield Rune | Rüstung, Rumpf | +10 % Rüstwert des Teils | Runenkreide 2, Eisen 1 | `modArmorPlatingBasic` (+1) |
| **Wetterrune** / Weather Rune | Rüstung, Kopf | +10 % Schutz vor Kälte und Hitze | Runenkreide 2, Fell 1 | `modArmorInsulatedLiner*` |
| **Wanderrune** / Wayfarer's Rune | Rüstung, Füße | −12 % Ausdauer beim Laufen | Runenkreide 2, Leder 1 | — |
| **Schutzzeichen** / Warding Sign | Block am Haus | im Umkreis 8 m: −15 % Grauen-Zuwachs | Runenkreide 4, Stein | Block mit Aura-Buff; Naht zu WP11 (`cv700_grauenDaempfung`) |

*Gebaut mit WP10.5a (D178, zu prüfen N-122)* in `700_75_Magie/Config/item_modifiers.xml`: die fünf
Runen der Tabelle (ohne Schutzzeichen — das ist ein Block mit Aura und hängt am Grauen, WP11). Eine
Rune je Gegenstand über `modifier_tags="rune700"`; Brand als `buff700_brand` (3 s, 4 Leben je Sekunde,
ohne Flammenbild). **Ersatzstoffe:** Bannrune mit Knochen statt Bernstein (es gibt noch keinen),
Wetterrune mit Nesselfaser statt Fell. Die Wanderrune folgt Vanillas Laufausdauer-Perk: Ausdauer kommt
beim Laufen um 12 % besser zurück. **[verifizieren, S-37]:** ob `perc_add` eines Aufsatzes auf den Wert
des Teils rechnet (Schutz-, Wetterrune) und ob Runenritzen Rang 2 die Kreide wirklich mindert.

### Segen und Flüche (Odem + Gegenstand)

| Name (DE / EN, Vorschlag) | Wirkung | Dauer | Odem | Gegenstand | Abklingzeit |
|---|---|---|---|---|---|
| **Segen der Wehr** / Blessing of Warding | −12 % erlittener Schaden | 90 s | 20 | geweihtes Wasser | 180 s |
| **Totensegen** / Blessing of the Dead | Seuchentote nehmen dich schlechter wahr (−15 %) **[verifizieren in WP10.5: welcher Wert die Wahrnehmung senkt]**; ohne Meide-Zone (Finding WP9.5) | 60 s | 25 | Kerze, geweihtes Wasser | 240 s |
| **Fluch der Schwere** / Curse of Heaviness | Gegner im Umkreis 3 m −15 % Tempo | 30 s | 10 | **Fluchtopf** (geworfen, siehe Fallen) | — |

### Tränke und Salben (Kräuterküche, kein Odem)

| Name (DE / EN, Vorschlag) | Wirkung | Dauer | Danach |
|---|---|---|---|
| **Eulenauge** / Owl's Eye | sieht im Dunkeln etwas besser **[verifizieren in WP10.5: welcher Wert, ohne grünes Nachtsichtbild]** | 5 min | — |
| **Bärenmut** / Bear's Courage | +10 % Nahkampfschaden, −15 % Grauen-Zuwachs | 3 min | 2 min −10 % Ausdauer-Erholung |
| **Wolfsbalsam** / Wolf's Balm (Salbe) | +1 Leben je 5 s | 2 min (24 Leben) | — |
| **Quellsud** / Spring Brew | +20 Odem sofort | — | 10 min kein zweiter (Abklingzeit) |

*Quellsud* ist neu: der einzige Weg, Odem mit Material statt Zeit zu kaufen. Ohne ihn hinge jeder
Runenkundige in der Seuchennacht allein an der Regeneration. *Sud* statt *Tee* nach D123.

*Gebaut mit WP10.5b (D179, zu prüfen N-123)* in `700_75_Magie`: die vier Tränke der Tabelle,
gebraut in der Kräuterküche, freigeschaltet beim Heiler über die Wundversorgung (`craftingMedical`
Stufen 10, 20, 40, 50 — sie zeigten nur noch auf gesperrte Rezepte). Feste Buff-Dauer,
`stack_type replace`. **Eulenauge** nimmt Vanillas Nachtsicht-Bild mit einem Drittel der Stärke
**[verifizieren, S-38: ob es grün ist]**. **Bärenmut** schreibt den Grauen-Teil nicht selbst:
`buff700_grauenSchutz` (WP11) zählt ihn per `HasBuff` (Vertrag 07 N1.3); die Nachwirkung kommt
nur, wenn die Zeit abläuft. **Quellsud** trägt zwei Bedingungen in der Aktion — Abklingzeit und
`cv700_odemMax` > 0 —, geschrieben in Vanillas Form `!HasBuff` (der Vertrag sagt „NotHasBuff" als
Beschreibung). Bis WP10.6 `cv700_odemMax` setzt, ist er darum für alle gesperrt.

### Zauber (nur Odem)

| Name (DE / EN, Vorschlag) | Wirkung | Odem | Bemerkung |
|---|---|---|---|
| **Glutpfeil** / Ember Bolt | ein Pfeil wie vom Holzbogen mit Steinspitze, dazu Brand 3 s; Reichweite 25 m | 10 | Fernkampf-Item; ob die Aktion ohne Munition schießt, **[verifizieren in WP10.9]**, sonst ein billiger „Glutspan" als Munition |
| **Lichtfunke** / Light Spark | Licht wie eine Fackel, solange gehalten | 0,5 je s | netto −0,25 je s: mit 100 Odem knapp 7 min; Licht bleibt Ressource (P4) |
| **Bannkreis** / Ban Circle | Aura 5 m um den Zaubernden: Gegner −25 % Tempo | 30 | 20 s; Aura statt Meide-Zone (D171) |

### Runenstein der Glut (Rahmen für WP10.8)

1 Schuss je 2 s, Reichweite 12 m, Schaden je Schuss 60 % eines Glutpfeils, **eine Glutladung = 10
Schuss**; Kraft über die Kraftlinien (`RequiredPower` wird Odem-Bedarf, Kurz-Check:185–198). Damit
verteidigt ein Stein eine Palisade sichtbar, aber nicht allein (Kriterium unten).

### Amulette und Reliquien (Q32)

**Platz:** der vierte Abzeichen-Platz `BiomeBadge4` (Finding WP9.5, D171). Vanilla legt dort schon
`biomeWeatherItem4` ab — ob sich beide verdrängen, zeigt S-35 (2). Verdrängen sie sich, kommt das
Amulett auf einen anderen der vier Plätze; welcher frei bleibt, sagt derselbe Test. **Ein Amulett
zugleich.** Stärke wie eine Rune (10–15 %).

| Name (DE / EN, Vorschlag) | Wirkung | Woher |
|---|---|---|
| **Bernsteinamulett** / Amber Amulet | +15 % Odem-Regeneration | Runenritzer-Bank |
| **Hammeramulett** / Hammer Amulet | −15 % Grauen-Zuwachs | Runenritzer-Bank (heidnisch) |
| **Kreuzanhänger** / Cross Pendant | −15 % Grauen-Zuwachs | Händler am Klostermarkt (christlich) |
| **Reliquienkapsel** / Reliquary | −10 % Schaden von Seuchentoten | nur Beute in Klöstern und Kirchen (F-07), nicht herstellbar |

Hammer und Kreuz sind absichtlich **gleich**: Leitplanke 5. Die Reliquie ist die einzige, die man
nicht herstellen kann — so hat GDD 2.3 („Amulette, Reliquien") eine Mechanik.

### Fallen mit Auslöser (D115)

F-08 hat Schwingbalken und Pechtopf in Phase 1 aufgeschoben, weil Vanillas einzige mechanische
Fallenklasse (`BladeTrap`) am Strom hängt. Mit den Kraftlinien (D37, WP10.7) hängt sie an der
Runenkraft — damit geht sie per XML.

| Name (DE / EN, Vorschlag) | Was | Grundlage | Kraft / Odem | Bemerkung |
|---|---|---|---|---|
| **Schwingbalken** / Swing Beam | Falle, schlägt zu, wenn ausgelöst | Klasse `BladeTrap` (Klon von `bladeTrap`, Kennung bleibt gesperrt) | Kraftlinie | braucht ein eigenes Modell (WP7) — **ohne Modell kein Rezept**, Vanillas Sägeblatt bleibt unsichtbar |
| **Trittbrett** / Tread Board | Auslöser | Klon von `pressureplate` | — | mit WP10.7 |
| **Stolperschnur** / Trip Cord | Auslöser | Klon von `tripwirepost` | — | mit WP10.7 |
| **Pechtopf** / Pitch Pot | Wurf: brennender Fleck, 5 s | Klon von `thrownAmmoMolotovCocktail` | — | **mechanisch, keine Magie**; jeder kann ihn herstellen |
| **Fluchtopf** / Curse Pot | Wurf: Fluch der Schwere im Umkreis 3 m | Wurf wie der Pechtopf, `Explosion.Buff` statt Feuer **[verifizieren in WP10.5: ohne Schaden und ohne Feuerbild]** | 10 Odem | D115 „als Wurf-Fluch geführt" — damit ist er der Träger des Fluchs, kein eigener Effekt |
| **Glutzeichen** / Ember Sign | Bodenzeichen: wer darauf tritt, brennt 3 s | wie die Spitzpfähle (Block mit Schaden), dazu Brand **[verifizieren in WP10.5]** | — | ersetzt die Blade Trap aus F-08 im Wortsinn „Runenfalle" |

Der Bannkreis als **Falle** (statt Elektrozaun, F-08) rutscht: ohne Meide-Zone wäre er nur ein
zweites Glutzeichen.

## Hochmagie (Phase 4, D38)
Seltene Endgame-Artefakte dürfen sichtbarer sein (kein Neon, keine Blitze):
- **Hexenbesen** und **Runenross** (Fahrzeuge, F-13)
- **Wegsteine** (Schnellreise, F-13, D18)
- **Runenschmiede:** Runen dauerhaft in Waffen schmieden (T4)
Alle verlangen einen hohen Magiewert (Runenkundiger-Stufe) und viel Odem.

## Fluch-Gegner & Sagengestalten
Die Sagengestalten (D11) kommen aus F-06, Kultpriester mit Flüchen aus F-20. F-15 liefert die **Gegenmittel**: Bannrune gegen
Nachzehrer, Lichtfunke gegen Irrlicht-Täuschung usw.

## Ressourcen & Werkstatt
- **Runenkreide** (Kalk + Ocker + Asche), **Bernstein** (Küste, selten), **Glutstein**
  (Holzkohle + Harz, Rennofen-Nebenprodukt), **geweihtes bzw. Quellwasser**, Kräuter (F-11)
- **Runenritzer-Bank** (neue Werkstatt, Klon einer Vanilla-Station per XML): Runen, Steine, Ladungen
  — **gebaut wird sie hier, nicht in Phase 1 (D57, 8. November 2026).** F-04 führt sie in seiner
  Werkstatt-Tabelle, und der Plan hatte sie in WP4.4; gemessen gibt es in Phase 1 aber kein
  einziges Rezept, das auf sie gehört, weil ihr Inhalt dieses Feature ist. Zu bauen sind dann:
  Klon-Block, XUi-Fenstergruppe, Bau-Rezept, Werkzeugslots Ritzmesser und Meißel — zusammen mit
  den ersten Runen, damit sie nicht leer in der Welt steht. Das Muster dafür liegt vor
  (`mod/700_40_Bauen/Config/XUi_InGame/`, WP4.5)
  *Gebaut mit WP10.4 (D177, zu prüfen N-121)* in `700_75_Magie`: im Spiel **Runenritzer-Stock** (das
  geborgte Modell ist Vanillas Baumstumpf), Werkzeugfenster mit **Ritzmesser** und **Meißel**, Bau an der
  Zimmermannsbank, Werkzeuge an der Esse — alle drei frei mit Runenritzen Rang 1. An der Bank selbst,
  ohne Sperre: **Runenkreide** (Branntkalk, Lehm, Holzkohle — Lehm statt Ocker, Holzkohle statt Asche)
  und **Glutstein** (Holzkohle, Tierfett — Fett statt Harz; erbt das Brennen der Holzkohle).
- Tränke und Salben: Kräuterküche (F-04)

## Umsetzung
### XML (Hauptteil)
`items.xml` (Zauber-Items, Runen-Mods, Tränke, Ladungen), `item_modifiers.xml` (Runen),
`buffs.xml`, `blocks.xml` (Runensteine, Kraftsteine, Schutzzeichen), `recipes.xml`,
`progression.xml` (Baum Runenkundiger, F-21), `loot.xml`, `traders.xml`, Localization.
**Odem:** CVar ~~`700_odem` + `700_odemMax`~~ `cv700_odem` + `cv700_odemMax` (Vertrag 02/07; Regeneration per Buff), eigene HUD-Leiste per
XUi (additiv, D5). ~~[verifizieren], ob Item-Aktionen per XML einen CVar als Kosten prüfen und
abziehen können; sonst kleiner Harmony-Hook.~~ *Belegt WP9.5 ([Finding](../rea/findings/WP9-odem-und-verderb.md),
zu prüfen N-115):* eine `<requirement>` **in** der `<action>` landet in `ItemAction.ExecutionRequirements`
und wird vor dem Auslösen geprüft — `CVarCompare` auf `cv700_odem` als Sperre, `ModifyCVar` beim
Auslösen als Abzug. Kein Hook. Bannkreis als Fläche geht nicht (keine Meide-Zone in der KI) → Aura.
Amulett-Platz: einer der vier Abzeichen-Plätze. Sechstes Attribut: Fertigkeitsfenster von 8 auf 9 Felder (XUi).
### C# / Harmony — Warum nicht XML?
- Variante B (selbstversorgende Runensteine), falls gewählt
- **Bannkreis** (Gegner meiden Bereich): Vanilla-KI hat nach unserem Kenntnisstand keine
  „Meide-Zone“ per XML → REA prüfen; Fallback: Bannkreis als Schadens- bzw. Verlangsamungs-Aura (XML)
- Lichtfunke als schwebende Lichtquelle, falls eine gehaltene Lichtquelle nicht reicht
- *Triage WP9.6 ([triage-phase-2.md](../rea/triage-phase-2.md) Nr. 12–16; zu prüfen N-116):* **kein C# in
  Phase 2.** Odem-Kosten, Projektil, Amulett-Platz, sechstes Attribut: XML. Bannkreis: XML als Aura;
  die echte Meide-Zone rutscht (keine KI-Grundlage, ein Patch an der Zielwahl wäre groß).
### Assets (D10, F-16)
Runensteine (neu), Partikel-Effekte (Glimmen, Glutpfeil, Rauch), Icons für alle Runen,
Tränke und Zauber.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-15](../rea/hook-hypothesen.md#f-15)

## Balancing-Grundsätze
- Ein Runenstein ersetzt keinen Spieler: geringer Schaden, langsame Feuerrate, teure Ladungen
- Passive Runen höchstens etwa 10–15 % auf einen Wert; Segen und Flüche kurz (30–120 s)
- Magie-Perks konkurrieren mit Kampf-Perks um dieselben Punkte

## Akzeptanzkriterien
- [ ] Runenstein der Glut verteidigt eine Palisade in der Seuchennacht sichtbar, aber nicht allein
- [ ] Kein Vanilla-Turm, -Generator oder -Kabel ist mit modernem Namen bzw. Modell erhältlich
- [ ] Alle Effekte sind dezent (Review gegen D10: keine Explosion, kein Blitz, kein Leuchtstrahl)
- [ ] Runensteine und Zauber funktionieren auf dem Dedicated Server mit 2 Clients (Projektile und Effekte synchron)
- [ ] *(seit WP10.1)* Jeder Wert im XML stimmt mit der Zahlentabelle oben; keine Rune und kein Amulett über
  15 %, kein Segen oder Fluch über 120 s, kein Trank über 10 min — eine Prüfung liest beides (WP10.5)
- [ ] Ohne Runenkundiger-Stufe 2 geht kein Segen und kein Zauber; einen Trank trinkt jeder
- [ ] Ein Segen oder Zauber bei zu wenig Odem geht nicht, und der Spieler sieht, warum
- [ ] Eine Rune je Gegenstand; ein Amulett zugleich, und das Wetter-Abzeichen bleibt, wo es war (S-35 (2))
- [ ] Der Schwingbalken schlägt nur mit Kraft und nur über Trittbrett oder Stolperschnur zu

## Notizen für diese Phase (nicht vorziehen, D50)
- **Die Drohne als kleiner dienstbarer Geist** (Idee des Nutzers, 2026-11-22, D87: „Die Drohne
  könnte ein Mini-Dämon sein"). Vanillas Robotik-Drohne und ihre Mods (`modRoboticDrone*`)
  sind in Phase 1 gesperrt. Statt sie gesperrt zu lassen, bekäme sie hier eine magische
  Deutung als Begleiter. Offen: was sie kann, was sie kostet, wie sie zu den Leitplanken oben
  passt (dezente Volksmagie). Grundsatz des Nutzers dazu: für alles Moderne wird eine
  mittelalterliche Deutung gesucht, bevor es gesperrt bleibt — Magie ist dafür eine Option.

- **Hochmagie** (Phase 4, D38) und die **Runenschmiede** bleiben Notiz; der **Runenstein des Sturms**
  und der **tragbare Runenstein** ebenso (Phase 3–4). Der **Bannkreis als Falle** wartet auf eine
  Meide-Zone (rutscht, D171).

## Offene Fragen
- ~~Gibt es in V 3.40 einen Accessoire-Slot für Amulette, oder laufen sie über Rüstungs-Mods?~~
  Beantwortet (WP9.5, D171): vier Abzeichen-Plätze, das Amulett nimmt `BiomeBadge4` — siehe „Amulette und
  Reliquien"; ob es das Wetter-Abzeichen verdrängt, zeigt S-35 (2).
- Die sechs Stellen **[verifizieren in WP10.x]** oben (Meldung bei fehlendem Odem, Wahrnehmung,
  Nachtsicht, Glutpfeil ohne Munition, Fluchtopf ohne Feuerbild, Glutzeichen mit Brand) — je eine
  Probe in der Test-Überlagerung, bevor gebaut wird.
