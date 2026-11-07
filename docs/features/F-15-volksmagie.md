# F-15 — Volksmagie (Runen, Segen, Tränke, Zauber)

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP: Runensteine · P2: Rest | X+H (+A) | S+C | ja |

## Ziel
Magie ist im Jahr 700 real, aber bodenständig (Entscheidungen D9, D10). Sie ist erlernt, an
Material gebunden, dezent sichtbar und vor allem **der Ersatz für Vanilla-Technik, die nicht
in die Zeit passt**: Geschütztürme, Strom, Elektrofallen, Sprengstoff.

## Leitplanken
1. **Magie ersetzt Technik, nicht den Nahkampf** (Säule P3). Der Spieler kämpft weiterhin
   selbst; Magie verteidigt, unterstützt und schwächt.
2. **Material statt Mana-Spam:** Jeder Effekt kostet etwas Greifbares (Runenkreide,
   Bernstein, Kräuter, Silber, Blut bzw. Gesundheit). Ob es zusätzlich einen Kraftwert gibt, ist Q14.
3. **Dezent** (D10): Glimmen, Funken, Rauch, Glutpfeile, Geräusche. Keine Feuerbälle,
   Blitze, Teleportation oder Schockwellen.
4. **Erlernt:** Die Magie hängt am Perkbaum **Runenkunde** (umgedeuteter Intellekt-Baum) und an
   Abschriften (F-04). Sie ist kein Loot-Glück.
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
- **Tragbarer Runenstein** (Stretch): ersetzt Junk Turret bzw. Drohne.
- Optik: behauener Stein mit glimmenden Runen; Projektil als Glutpfeil mit Rauchspur (F-16).

### Runenkraft statt Strom (Q13, Entscheidung nach REA)
Vanilla-Türme und Elektrofallen brauchen Strom. Zwei Wege:

| | **Variante A: Kraftlinien** | **Variante B: selbstversorgend** |
|---|---|---|
| Idee | Das **Vanilla-Stromnetz wird umgedeutet**: Generator → *Kraftstein* (verbraucht Bernstein bzw. Glutsteine statt Benzin), Solarzelle → *Sonnenstein*, Batterie → *Speicherstein*, Kabel → *Kraftfaden*, Schalter und Sensoren → *Runenschalter* | Runensteine brauchen **kein Netz** und arbeiten mit Munition bzw. Brennstoff im eigenen Inventar |
| Technik | Reines **XML** (Umbenennen, Rezepte, Modelle), Vanilla-Logik bleibt | **C#/Harmony**: Turm-Logik von der Strom-Abhängigkeit lösen |
| Vorteil | Säule P5, updatefest, Vanilla-Komplexität (Logik-Schaltungen) bleibt erhalten | Intuitiver, keine „Kabel“ im Jahr 700 |
| Nachteil | „Kraftfäden ziehen“ wirkt technisch; braucht gutes Theming | Eingriff in Power- bzw. TileEntity-System, REA-Pflicht, Netz-Sync |

**Empfehlung:** Mit **Variante A** starten (MVP-tauglich, nur XML). Variante B per REA
prüfen; umsteigen nur, wenn der Eingriff klein und sauber ist.

## Fluch-Gegner & Sagengestalten
Die Sagengestalten (D11) kommen aus F-06. F-15 liefert die **Gegenmittel**: Bannrune gegen
Nachzehrer, Lichtfunke gegen Irrlicht-Täuschung usw.

## Ressourcen & Werkstatt
- **Runenkreide** (Kalk + Ocker + Asche), **Bernstein** (Küste, selten), **Glutstein**
  (Holzkohle + Harz, Rennofen-Nebenprodukt), **geweihtes bzw. Quellwasser**, Kräuter (F-11)
- **Runenritzer-Bank** (neue Werkstatt, Klon einer Vanilla-Station per XML): Runen, Steine, Ladungen
- Tränke und Salben: Kräuterküche (F-04)

## Umsetzung
### XML (Hauptteil)
`items.xml` (Zauber-Items, Runen-Mods, Tränke, Ladungen), `item_modifiers.xml` (Runen),
`buffs.xml`, `blocks.xml` (Runensteine, Kraftsteine, Schutzzeichen), `recipes.xml`,
`progression.xml` (Runenkunde), `loot.xml`, `traders.xml`, Localization.
### C# / Harmony — Warum nicht XML?
- Variante B (selbstversorgende Runensteine), falls gewählt
- **Bannkreis** (Gegner meiden Bereich): Vanilla-KI hat nach unserem Kenntnisstand keine
  „Meide-Zone“ per XML → REA prüfen; Fallback: Bannkreis als Schadens- bzw. Verlangsamungs-Aura (XML)
- Lichtfunke als schwebende Lichtquelle, falls eine gehaltene Lichtquelle nicht reicht
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

## Offene Fragen
- Q13: Variante A oder B für Runenkraft?
- Q14: Nur Material oder zusätzlich eigener Kraftwert („Odem“)?
- Gibt es in V2.x einen Accessoire-Slot für Amulette, oder laufen sie über Rüstungs-Mods?
