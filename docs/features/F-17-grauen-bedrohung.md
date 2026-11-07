# F-17 — Grauen & Bedrohung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP: Dunkelheit + Klang · P2: Furcht-System, Direktor, Trugbilder | X+H (+A) | S+C | ja |

## Ziel
Das Setting soll **spürbar bedrohlicher und unheimlicher** sein als Vanilla (Entscheidung D12).
Der Spieler soll sich in der Dunkelheit, im Wald und allein **unsicher fühlen**, nicht nur
in der Seuchennacht. Das Grauen kommt aus **Ungewissheit, Dunkelheit und Klang**, nicht aus
billigen Jumpscares.

## Grundsätze
1. **Andeuten statt zeigen:** Ein Geräusch, ein Schatten, eine offene Tür sind gruseliger als ein Monster im Licht.
2. **Spannung und Erlösung im Wechsel:** Nach Angst braucht es sichere Momente (Feuer, Gemeinschaft, Tageslicht), sonst stumpft der Spieler ab.
3. **Die Welt glaubt an das Böse:** Notizen, Grabkreuze, verbarrikadierte Türen und Bannzeichen erzählen, dass hier Menschen Angst hatten und meistens verloren haben.
4. **Jumpscares sparsam:** höchstens selten, immer an echte Bedrohung gekoppelt, nie reiner Lärm.
5. **Gemeinschaft schützt:** Wer allein geht, fürchtet sich mehr. Das stärkt den Koop (Dedicated Server).
6. **Dezent bleibt dezent (D10):** Auch Trugbilder sind leise, kurz und mehrdeutig.

## Bausteine

### B1 — Echte Dunkelheit (MVP, X + ggf. H)
- Nächte deutlich dunkler, Neumond-Nächte fast schwarz; Mondphasen haben Gewicht
- Nebel in Wald, Moor und Flusstälern, abends dichter (Weather/Biome per XML)
- Licht hat kleinen Radius und flackert; Fackeln blenden die Umgebung *außerhalb* des Lichtkreises stärker ab
- Verzahnt mit F-08 (Brenndauer): Wer kein Licht hat, ist blind
- [verifizieren] per REA bzw. Test: Was davon geht über Weather/Biome-XML, was braucht Sky-/Licht-Hooks?

### B2 — Klanglandschaft (MVP: Vanilla-Sounds umgedeutet · P2: eigene Sounds)
- Stille als Werkzeug: Tierlaute verstummen, wenn Seuchentote nahe sind
- Ferne Klänge: Glocke eines verlassenen Klosters, Wolfsheulen, Rufe, Weinen, Raunen, knackende Äste
- Positionsabhängig und selten wiederholt, damit sie nicht zur Tapete werden
- Seuchentote sind leiser als Vanilla-Zombies; ihr erster Laut ist oft schon nah

### B3 — Furcht-System „Grauen“ (P2, X + H)
Ein Wert pro Spieler (CVar `700_grauen`, 0–100):

| Steigt durch | Sinkt durch |
|---|---|
| Dunkelheit, Nebel, Nacht | Licht, Feuerstelle in der Nähe |
| allein sein (kein Mitspieler in der Nähe) | Mitspieler in der Nähe |
| Leichen, Pestgruben, Sagengestalten in Sichtweite | Schlaf in befestigtem Heim, Mahlzeiten |
| Treffer, niedrige Gesundheit | Segen, Bärenmut-Trank, Schutzzeichen (F-15) |
| Seuchennacht naht (F-09) | Tageslicht |

Wirkung in Stufen (alle dezent):

| Stufe | Effekte |
|---|---|
| Unruhig (30+) | Herzschlag-Sound, Ausdauer-Regeneration leicht reduziert |
| Verängstigt (60+) | Zittrige Fernkampf-Zielführung, Trugbilder (B4) beginnen |
| Grauen (85+) | Sichtrand dunkel, stärkere Trugbilder, kurze Panik (Sprint-Zwang beim Treffer) |

- Mechanische Effekte sind gewollt (D14). Säule P3 bleibt aber: Nahkampf wird **nicht** unbrauchbar, vor allem Bogen und Zauber leiden
- Umsetzung: Buffs und CVars per XML; Messung von Licht, Nähe zu Mitspielern und Sichtkontakt braucht wahrscheinlich C# → REA

### B4 — Trugbilder (P2, H, nur Client)
Ab Stufe „Verängstigt“, selten, immer mehrdeutig:
- Schritte hinter dem Spieler, Flüstern beim eigenen Namen, Klopfen an der Tür
- Eine Gestalt am Waldrand, die beim Hinsehen verschwindet
- Ein Irrlicht, das keins ist
- Eine Fackel, die kurz flackert, als ginge sie aus

**Regeln:** Trugbilder richten nie Schaden an und sind nur beim betroffenen Spieler sichtbar
(Client). Echte Gegner sehen **niemals** wie Trugbilder aus. Der Spieler darf zweifeln, aber
nicht betrogen werden.

### B5 — Bedrohungs-Direktor (P2, H, Server)
Steuert die Spannungskurve zwischen den Seuchennächten:
- **Phasen:** Ruhe → Vorzeichen → Bedrohung → Erlösung (adaptiv nach Aktivität, Grauen-Werten und Gamestage)
- **Ereignisse:** Pirscher (ein Seuchentoter folgt im Nebel auf Abstand), stilles Rudel, Wanderzug von Seuchentoten, Sagengestalt-Erscheinung, verstummende Tiere
- **Seuchendruck:** Die Welt wird mit der Zeit schlechter: mehr Nebel, mehr Sagengestalten, weniger sichere Orte
- Arbeitet **mit** dem Vanilla-AI-Director statt ihn zu ersetzen (P5) → REA-Pflicht

### B6 — Gruselige Gegner-Verhalten (P2, X + H, an F-06)
- **Totstellen:** Liegende Leichen, die aufstehen, wenn man vorbeigeht (wenige, gut lesbar in POIs)
- **Pirscher:** Seuchentoter, der Abstand hält, bis der Spieler allein oder verwundet ist
- **Lauscher:** reagiert stark auf Geräusche (Sprint, Kampf), schwach auf Sicht
- Sagengestalten (Irrlicht lockt, Nachzehrer frisst Leichen) nach F-06

### B7 — Erzählende Umgebung (P2, X/Prefabs, an F-07)
- Pestgruben, Leichenkarren, Grabkreuze mit Bannzeichen, verriegelte Türen *von außen*
- Kurze Notizen und Inschriften (DE/EN): letzte Gebete, Warnungen, Aufzeichnungen eines Mönchs
- Verlassene Schutzorte mit gebrochenen Bannzeichen: Was hier geschützt hat, hat versagt

### B8 — Sichere Orte (MVP, X)
- Feuerstelle, befestigtes Heim mit Schutzzeichen, geweihter Boden (Kloster) senken Grauen
- Keine absolute Sicherheit: Schutzzeichen schwächen Bedrohung, verhindern sie aber nicht

## Einstellbarkeit
- Servereinstellung bzw. Mod-Option **Grauen-Intensität** (D13):

  | Stufe | Wirkung |
  |---|---|
  | aus | keine Trugbilder, keine Furcht-Effekte; Dunkelheit, Klang und Direktor bleiben (gehören zum Setting) |
  | mild | Furcht nur atmosphärisch (Herzschlag, Sichtrand), keine Mechanik-Mali, Trugbilder selten |
  | voll (Standard) | alle Effekte inkl. Mechanik-Mali (D14) |

  Umsetzung bevorzugt über eine CVar bzw. Game-Option, die Buffs per Requirement prüfen (XML); [verifizieren], ob eigene Server-Optionen ohne C# möglich sind.

### Härtere Todesfolgen (D15)
- **Optional**, eigene Server-Option, standardmäßig **aus**
- **Ausgeschlossen:** Wiederaufstehen des Spielers bzw. seiner Leiche als Seuchentoter
- Welche Folgen es konkret gibt, wird später entworfen (Q17)
- Aus Barrierefreiheitsgründen: keine Bildschirmblitze, keine starken Kamera-Wackler

## Umsetzung (Zusammenfassung)
| Baustein | XML | C# | Assets |
|---|---|---|---|
| B1 Dunkelheit | Weather, Biome-Nebel, Licht-Werte | evtl. Sky/Licht-Hook | – |
| B2 Klang | Sound-Zuordnung, Spawn-Sounds | Stille-Logik (Tiere verstummen) | P2: eigene Sounds (F-16) |
| B3 Grauen | Buffs, CVars, Effekte | Messung Licht/Nähe/Sicht | Herzschlag, Atem |
| B4 Trugbilder | – | Client-Ereignisse | Sounds, Schattengestalt |
| B5 Direktor | Gamestages, Gruppen | Phasenlogik | – |
| B6 Verhalten | Entity-Werte | KI-Verhalten | – |
| B7 Umgebung | Notizen, Loot | – | Prefabs, Retexturen |
| B8 Sichere Orte | Buff-Auren | – | – |

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-17](../rea/hook-hypothesen.md#f-17)

## Akzeptanzkriterien
- [ ] Playtest-Frage „Hattest du nachts im Wald allein Angst?“: Mehrheit sagt Ja (5+ Tester)
- [ ] Keine Nacht fühlt sich wie die andere an (Direktor-Log zeigt Phasenwechsel)
- [ ] Trugbilder sind nur beim betroffenen Spieler sichtbar (Dedicated + 2 Clients)
- [ ] Grauen-Intensität „aus“ entfernt Trugbilder und Furcht-Effekte vollständig; „mild“ entfernt alle Mechanik-Mali
- [ ] Performance: Klang- und Nebel-Effekte senken die Client-FPS nicht spürbar

## Offene Fragen
- Q17: Welche härteren Todesfolgen konkret? (vertagt; Rahmen D15)
