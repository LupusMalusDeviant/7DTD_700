# F-03 — Rüstung & Kleidung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X (+A) | S | nein |

## Ziel
Rüstung ist teuer, schwer und spürbar. Kleidung schützt vor Kälte und Nässe.

## Umfang
| Tier | Teile | Vanilla-Basis (D59, D61) |
|---|---|---|
| T0 | Lumpen (Rumpf, Kopf, Hände, Füße) | ~~Primitive Set~~ `armorPrimitive*` (umgedeutet), Prefab `Gear/Fiber/`, `groupPrimitive` — **ohne Set-Bonus, Vanilla hat dafür keinen** |
| T1 | Lederwams, Lederkappe, Wollhandschuhe, Wickelschuhe | ~~Leather/Farmer-Sets~~ `armorLightMaster` (eigene Teile), Prefab `Gear/Stealth/`, `groupNomad` |
| T2 | Gambeson, Stepphaube, Stepphandschuhe, Steppschuhe | ~~Padded~~ `armorMediumMaster` (eigene Teile), Prefab `Gear/Assassin/`, `groupAssassin` |
| T3 | Kettenhemd, Spangenhelm, Armschienen, Beinschienen | ~~Military/Iron (umbenannt)~~ `armorHeavyMaster` (eigene Teile), Prefab `Gear/Raider/`, `groupRaider` |
| ~~T4~~ | ~~Langes Kettenhemd, Helm mit Brünne/Wangenklappen~~ | ~~Steel (umbenannt)~~ **entfällt als eigene Stufe (D61, 8. November 2026): T4 ist die Qualitätsspitze des Kettenhemds** |

**Drei Stufen plus T0, nicht fünf (D61).** V 3.40 kennt keine Rüstungsstufen — drei Gewichtsklassen,
und die Stufe eines Teils ist seine Qualität 1–6. Fünf Namen auf drei Klassen hätten bedeutet, dass
T3 und T4 gleich gut schützen. **Prefab und `ArmorGroup` sind zwei unabhängige Anleihen:** der Pfad
bestimmt das Aussehen, die Gruppe den Set-Bonus, und jede ist nach ihrem eigenen Maßstab gewählt.
Darum trägt T1 das Aussehen der Rogue-Garnitur und den Bonus der Nomad-Garnitur. **Slot-Vergünstigungen
(Vanillas Tragkraft am Rumpf, Laufgeschwindigkeit an den Schuhen, Schleichbonus) tragen unsere Teile
nicht**; sie gehören in die Balancing-Tabelle WP5.6.

**Die rechte Spalte war berichtigt, nicht verfeinert (D59, 8. November 2026).** Die fünf
Garnituren Primitive/Leather/Padded/Military/Steel beschreiben eine ältere Spielfassung. In
V 3.40 ist gemessen:

| | Zahl |
|---|---|
| Rüstungsteile in `items.xml` | 178 |
| Garnituren (Rumpf/Kopf/Hände/Füße plus Einzelhüte und -masken) | ~40 |
| davon in WP3 gesperrt | 61 Teile (16 Garnituren) |
| **erreichbar** (Rezept, Loot, Händler, Quest oder Startausrüstung) | **6** |

Die sechs: die vier `armorPrimitive`-Teile, `armorParts` und `armorSkillMagazine` (zu WP7
aufgeschoben). **Alle übrigen Garnituren — Beach, Pirate, Samurai, Hellreaver, Winter, die
Hüte und Masken — sind DLC- und Event-Inhalt ohne jeden Weg** und darum für den Spieler
unerreichbar, ohne dass eine Regel sie nennen müsste. Über das Kreativmenü bleiben sie
sichtbar; `CreativeMode` ist keine Sperre.

Vanilla trägt die Rüstung stattdessen über **drei Gewichtsklassen** als Basisklassen —
`armorLightMaster`, `armorMediumMaster`, `armorHeavyMaster` (plus `armorPrimitiveMaster` und
`armorDLCMaster`) —, und jede Garnitur erbt davon. Darum erben **unsere** Teile ebenfalls
davon, vier Slots je Stufe. Die Modelle (`Meshfile`) borgen wir aus den gesperrten Garnituren:
**der Purge nimmt Wege, keine Meshes.** Retextur und eigene Modelle regelt Phase 2 (D3, F-16).

Die Alternative — vier der 16 gesperrten Garnituren wieder freigeben und umdeuten — wäre
billiger gewesen und holt laut Denylist-Kommentar Warnweste, Schutzhelm und Kevlar zurück,
dazu vier D-Zeilen Rückbau an WP3.

**Gemessen für WP5.5 (8. November 2026).** Vollständig in
[WP5-ruestung-in-v340.md](../rea/findings/WP5-ruestung-in-v340.md), kurz:

- **Modell:** kein `Meshfile`, sondern `<property class="SDCS">` mit einem `Prefab` unter
  `Entities/Player/{sex}/Gear/…`. **Alle vier Teile einer Garnitur teilen einen Pfad**;
  `EquipSlot` entscheidet, was erscheint. Borgen lassen sich die vier gesperrten Garnituren
  des Grundspiels ohne Kopf-Matrix: Assassin, Nomad, Raider, Rogue (`Gear/Stealth/`).
  `armorPrimitive` liegt auf `Gear/Fiber/` und bleibt T0.
- **Set-Bonus:** `ArmorGroup` am Teil, die Regel zentral in `buffs.xml` (vier Teile → Buff,
  gestaffelt über `ArmorGroupLowestQuality`). Behalten unsere Teile die geborgte Gruppe, wirkt
  Vanillas Bonus unverändert und es sind nur drei Sprachschlüssel zu setzen.
- **Zahlen:** hängen allein an der Gewichtsklasse, über alle Garnituren identisch — leicht
  8→12,3 ohne Malus, mittel 13→17,3 bei −5 % Mobilität, schwer 18→21 bei −7,5 %. Nichts zu
  erfinden.
- **Entschieden (D61, 8. November 2026):** V 3.40 kennt **keine Rüstungsstufen**, nur drei
  Gewichtsklassen plus Qualität 1–6. Die fünf Stufen der alten Tabelle gehen darauf nicht auf,
  darum hat Phase 1 **drei Rüstungsstufen plus T0** — T4 ist die Qualitätsspitze des
  Kettenhemds statt eines Gegenstands, der genauso gut schützt wie T3.
- **Noch nicht geprüft ist das Aussehen.** Gemessen sind Pfade, nicht Bilder. Ob die geborgten
  Garnituren in einem Frühmittelalter-Spiel erträglich aussehen, entscheidet der Nutzer im
  Spiel (WP5.7); ein anderer Pfad ist eine Zeile je Stufe.
- **Die Zahlen und Kosten stehen in der Balancing-Tabelle** (WP5.6, 8. November 2026):
  [0001-wp5-waffen-ruestung-und-kosten.md](../balancing/0001-wp5-waffen-ruestung-und-kosten.md),
  §3 und §4. Zwei Punkte daraus gehören hierher. **T0 und T1 haben denselben
  `PhysicalDamageResist`** (8 → 12,3): `armorPrimitiveMaster` trägt Vanillas leichte Klasse,
  also bekommt T1 keinen besseren Schutz, sondern einen Set-Bonus, mehr Modplätze, 4,1 %
  Widerstand gegen kritische Verletzungen und den Tag `biomeChallenge`. Für eine Stufe, die als
  „Wollkleidung und Lederwams" verkauft wird, ist das wenig — Spieltest, dann WP9. Und: **eine
  vollständige T3-Garnitur kostet 550 Raseneisenerz, ein Streithammer 600.** Eine Rüstung, die
  billiger ist als eine einzelne Waffe, dreht die Reihenfolge, in der man sich ausrüstet.

- Gewicht → Bewegungs- und Ausdauer-Malus über vorhandene Rüstungs-Mechanik
- Set-Boni über vorhandene Rüstungsset-Logik: Zuordnung umdeuten
- **Qualität** (D23): Material = Grundstufe, Handwerksqualität = Feinstufe (wie F-02)
- **Schutz je Schadensart** (D21): Gambeson gut gegen Wucht, Kette gut gegen Schnitt und schwächer gegen Stich (Phase 2)
- **Verschleiß & Reparatur** wie bei Waffen (F-02) — mit einem dritten Gegenstand (D62,
  8. November 2026): **Nähzeug** (Vanillas `resourceSewingKit`, in WP5.5 um Rezept und
  `RepairAmount` ergänzt) flickt T0, T1 und T2 voll, das **Kettenhemd** flickt der
  Schmiedeflicken an der Esse. D60s Teilung hängt an der Schneide, und Tuch näht man ganz
- **Der Webstuhl kommt mit diesem Feature (D57, 8. November 2026).** F-04 führt ihn in seiner
  Werkstatt-Tabelle, und der Plan hatte ihn in WP4.4 — aber mit `resourceCloth` allein hätte er
  ein Rezept und keinen Zweck. Erst die Gambeson-Teile aus T2 füllen ihn, darum wird er als
  **WP5.5b** zusammen mit der Rüstung gebaut: Klon-Block, XUi-Fenstergruppe, Bau-Rezept,
  Werkzeugslot Weberschiffchen. Segeltuch aus der F-04-Tabelle hängt an F-13 (Segel, Planen) und
  bleibt davon unberührt

## Nicht im Umfang
- Plattenrüstung (anachronistisch)

## Umsetzung
MVP: nur XML (Items, Rezepte, Localization) auf Vanilla-Modellen.
Phase 2 (D3, F-16): **Retexturen** für T0–T2 (Stoff, Leder, Gambeson); **neue Modelle** für
Kettenhemd und Spangenhelm (T3–T4).

## Akzeptanzkriterien
- [ ] Kettenhemd erst nach Rennofen und Esse (F-04) herstellbar
- [ ] Keine Vanilla-Rüstung mit modernem Namen bleibt erhältlich
