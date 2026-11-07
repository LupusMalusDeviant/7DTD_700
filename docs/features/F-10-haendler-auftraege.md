# F-10 — Händler & Aufträge

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 2: Handelsposten, Vanilla-Aufträge · 3: Bann, Lore, Eskorte | X+H | S | ja (Eskorte) |

## Ziel
**Feste Handelsposten** (D41) sind die wenigen Inseln der Ordnung in einer verlorenen Welt.
Aufträge führen hinaus in die Bedrohung und erzählen dabei die Geschichte der Seuche (D42).

## Handelsposten (D41)
| Posten | Händler-Typ | Sortiment-Schwerpunkt |
|---|---|---|
| **Klostermarkt** | Bruder Cellerar | Heilmittel, Abschriften, Segenswasser, Kerzen |
| **Marktflecken** | Kaufmann | Werkzeug, Salz, Stoffe, Nahrung, Bernstein |
| **Fürstenhof** | Kämmerer | Waffen, Rüstung, Pferde (teuer, F-13), Aufträge höherer Stufe |
| **Schmiedehof** (optional) | Schmied | Eisen (knapp!), Reparatur, Waffen |

- Schutzzone wie Vanilla-Trader, Öffnungszeiten (nachts geschlossen, F-17)
- **Lehrmeister** verkaufen Abschriften (Grundfähigkeiten, F-21)
- Bezahlt wird in Silber (D30)

## Aufträge (D42)
| Typ | Beispiel | Basis | Phase |
|---|---|---|---|
| **Vanilla umgedeutet** | Hof säubern, Reliquie bergen, Lieferung, Brunnen wiederherstellen | Vanilla-Questtypen | 2 |
| **Bann-Aufträge** | Sagengestalt jagen, Pestgrube verbrennen, Schutzzeichen erneuern, Steinkreis vom Kult befreien | Vanilla-Typen + eigene Ziele | 3 |
| **Lore-Ketten** | Lose Hauptgeschichte über die Herkunft der Seuche: Notizen → Auftragskette → Kultstätten (F-20) → Enthüllung | Quest-Ketten + Notizen | 3 |
| **Eskorte** | Pilger, Händler oder Überlebende sicher zu einem Ziel geleiten (eventuell als künftige Gesellen, F-14) | **C#** (Begleit-KI) | 3 |

## Lore-Rahmen (Entwurf)
Die Hauptgeschichte bleibt **mehrdeutig** (GDD 2.1): Ist die Seuche Strafe, Fluch oder
Krankheit? Die Lore-Kette liefert Hinweise aus allen drei Richtungen und lässt die Antwort
offen bzw. dem Spieler. Zuerst den Rahmen in `docs/lore.md` festhalten (Phase 2), dann die
Aufträge.

## Umsetzung
- XML: `traders.xml`, `quests.xml`, Localization, Notizen als Items
- C#: Eskorte (Begleit-KI, Ziel-Erkennung, Scheitern bei Tod) → REA

## Akzeptanzkriterien
- [ ] Jeder Posten hat ein eigenes Sortiment ohne Anachronismen
- [ ] Mindestens 3 Bann-Auftragstypen und eine Lore-Kette mit 5+ Schritten
- [ ] Eskorte funktioniert auf Dedicated mit 2 Clients (NPC folgt, Scheitern sauber)
