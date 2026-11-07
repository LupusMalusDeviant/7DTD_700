# F-15 — Aberglaube & Reliquien

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+A) | S | nein |

## Ziel
Glaube und Aberglaube sind Teil des Überlebens (Entscheidung D2). Schutzzeichen und
Reliquien haben **kleine, spürbare Effekte**. Ob das „wirklich“ wirkt oder nur Zuversicht
ist, bleibt offen. Es gibt keine Zauber und keine sichtbaren Magie-Effekte.

## Umfang
| Objekt | Herkunft | Effekt (Beispiele, Balancing offen) |
|---|---|---|
| Amulett (Thorshammer, Kreuz, Donnerkeil, Bernstein) | Handwerk T1, Loot | +kleiner Malus-Schutz gegen Furcht/Stagger; Slot über Vanilla-Mod/Accessoire-Mechanik [verifizieren] |
| Reliquie (Knochensplitter, Stoffrest eines Heiligen) | seltener Loot in Klöstern, Aufträge (F-10) | Getragen: langsamerer Seuchenbrand-Verlauf (F-11) |
| Weihwasser / Segenswasser | Klostermarkt, Kräuterküche | Wurf- bzw. Klingenbeschichtung: kleiner Schadensbonus gegen Seuchentote (F-06) |
| Schutzzeichen am Haus (Runen, Kreuz, Schädel am Pfahl) | Bau-Blöcke | Kleiner Bonus im Umkreis (z. B. Ausdauer-Regeneration beim Schlafen), kein Gegner-Abwehrfeld |
| Opfergabe / Gebet am Schrein | POI-Block | Kurzzeit-Buff „Zuversicht“ (z. B. weniger Ausdauerverbrauch bis zum Morgen) |

**Leitplanken:**
- Jeder Effekt ist **klein** (Richtwert ≤ 10 % auf einen einzelnen Wert) und nie ein Ersatz für Rüstung, Heilkunde oder Befestigung.
- Keine Partikel- oder Leuchteffekte. Die Wirkung ist nur im Buff-Text und in Zahlen sichtbar.
- Christliche und heidnische Objekte sind **gleichwertig**. Die Mod wertet keinen Glauben.
- Respektvoller Umgang: keine Verspottung realer Religionen; Texte im Ton „Volksglaube“.

## Umsetzung
### XML
`items.xml` (Amulette, Reliquien, Weihwasser), `buffs.xml` (Effekte, Bedingungen),
`blocks.xml` (Schutzzeichen, Schrein), `loot.xml`, `traders.xml`.
### Assets
Phase 2: Icons für alle Objekte (Pflicht), kleine Modelle für Schrein und Schutzzeichen
(neu), Amulette nur als Icon (F-16).

## Akzeptanzkriterien
- [ ] Jedes Objekt hat DE/EN-Text mit Volksglauben-Ton und eine nachvollziehbare Buff-Beschreibung
- [ ] Kein Effekt übersteigt den vereinbarten Richtwert (Balancing-Tabelle)
- [ ] Funktioniert auf dem Dedicated Server (Buffs serverseitig)

## Offene Fragen
- Gibt es in V2.x einen Accessoire- bzw. Schmuck-Slot oder läuft das über Mods an der Rüstung? → kurzer XML- bzw. REA-Check
