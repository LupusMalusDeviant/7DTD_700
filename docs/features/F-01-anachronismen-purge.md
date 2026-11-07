# F-01 — Anachronismen-Purge

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X | S | nein |

## Ziel
Nichts, was es um 700 nicht gab, taucht im Spiel auf, sei es als Loot, Rezept, Händlerware,
Quest-Belohnung oder Startausrüstung.

## Umfang
- Entfernen bzw. Sperren: Schusswaffen und Munition, Fahrzeuge, Elektronik, elektrische
  Lampen, Konserven, Medikamente, Treibstoff, Beton, Stahlprodukte industrieller Art
- **Nicht entfernen, sondern an F-15 übergeben** (D9): Geschütztürme, Generator, Solar,
  Batterien, Kabel, Schalter, Sensoren, elektrische Fallen, Junk Turret und Drohne, Sprengstoff.
  Diese Systeme werden zu Runensteinen, Kraftsteinen und Runenfallen umgedeutet. F-01 sperrt
  nur ihre modernen Varianten (Namen, Rezepte, Loot), die Logik bleibt erhalten.
- Loot-Tabellen (`loot.xml`): Gruppen leeren bzw. umbiegen
- Rezepte (`recipes.xml`): entfernen
- Händler (`traders.xml`): Warengruppen entfernen
- Progression/Skills, die nur Anachronismen tragen (z. B. Feuerwaffen-Perks): umwidmen (F-02) oder ausblenden
- Startausrüstung und Quest-Belohnungen prüfen
- **Denylist-Skript** (`tools/check-anachronisms`): durchsucht die *gemergte* Config (Export aus
  dem Spiel oder Merge-Tool) nach verbotenen Begriffen und Item-Gruppen

## Nicht im Umfang
- Ersatzinhalte (die kommen mit F-02 bis F-05)
- Blöcke in POIs (F-07). Bis dahin bleiben Vanilla-POIs mit Modern-Dekor bestehen; das ist eine bekannte MVP-Lücke.

## Umsetzung
### XML
Eher Sperren als Löschen (z. B. `CreativeMode=None`, keine Rezepte, kein Loot), weil das
Löschen von Items, die in POIs oder Quests referenziert werden, zu Fehlern führt. **[verifizieren]**: welche
Referenzen hart brechen.

## Akzeptanzkriterien
- [ ] Denylist-Skript meldet 0 Treffer in Loot, Rezepten, Händlern und Startausrüstung
- [ ] 3 Spieltage auf neuer RWG-Welt ohne modernes Item im Inventar oder Händlerangebot
- [ ] Keine XML-Fehler im Log

## Offene Fragen
- Was passiert mit Vanilla-Items, die noch in Prefabs (Kisten-Inhalte, platzierte Blöcke) stecken? → F-07
