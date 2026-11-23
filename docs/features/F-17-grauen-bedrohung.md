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

### B2 — Klanglandschaft (MVP: Seuchentote seltener hörbar · P2: ferne Klänge nur als Trugbild, eigene Sounds)
> ~~**Widerspruch, offen** — siehe Prüfung 0003, W-06~~ *Aufgelöst mit WP11.1 (2026-11-23):* die
> Überschrift folgt D74 — ferne Klänge ohne Quelle sind Trugbilder (B4), echte ferne Klänge (die
> Glocke eines Klosters, F-09 §6) gehören zum Direktor.

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

#### B3 in Zahlen (Plan-0002 WP11.1, 2026-11-23, D184, zu prüfen N-128)

Alle Zahlen sind **Setzungen**; der Testlauf WP11.10 stellt sie mit verkürzten Werten nach. Ein Buff
am Spieler zählt **alle 5 Sekunden**; hier je Minute angegeben. Jede Zeile ist eine Bedingung, die es
gibt (Kurz-Check, Finding WP9.4).

| Steigt | je Minute | Bedingung |
|---|---|---|
| Nacht, draußen | +1 | `TimeOfDay` 21–5 und `!IsSheltered` |
| dunkel | +2 | `CompareLightLevel` unter der Schwelle aus S-34 (1) |
| allein *(nur Mehrspiel, s. u.)* | +1 | kein `buff700_gesellschaft` und `cv700_mitspielerDa` = 1 |
| Gesundheit unter 30 % | +2 | `StatComparePercCurrentToMax` |
| Seuchennacht läuft | +4 | `IsBloodMoon` |
| Seuchennacht naht | + `cv700_grauenDruck` / 10 (bis +3) | vom Direktor (F-09 §6) |
| Treffer | +3 je Treffer | Auslöser `onOtherDamagedSelf` |

| Sinkt | je Minute | Bedingung |
|---|---|---|
| Tag, draußen oder drinnen | −3 | `TimeOfDay` 6–20 |
| unter Dach, nicht dunkel | −1 | `IsSheltered` und Licht über der Schwelle |
| Am Feuer | −4 | `HasBuff buff700_amfeuer` |
| in Gesellschaft | −1 | `HasBuff buff700_gesellschaft` |

**Schutz** senkt nur den **Zuwachs**: `.cv700_grauenSchutz` (Vertrag 07 N1.3) — Bärenmut 25 %,
Hammeramulett bzw. Kreuzanhänger 15 %, Schutzzeichen-Aura 25 %; zusammen **höchstens 50 %**.
Schlaf und Mahlzeit (Tabelle oben) senken erst, wenn ein Auslöser dafür gelesen ist **[verifizieren
in WP11.3]** — sonst Streichposten, Tageslicht und Feuer tragen die Erlösung allein.

**Was das heißt:** allein, nachts, im dunklen Wald: +4/min → **Unruhig nach 7½ min, Verängstigt nach
15 min**; eine Spielnacht (22–4 Uhr bei 60-Minuten-Tagen) dauert 15 min. **Grauen (85)** erreicht nur, wer
dazu getroffen wird, verwundet ist oder in der Seuchennacht draußen steht. Mit Fackel (nicht dunkel):
+1/min, Unruhig erst nach 30 min. Am Feuer fällt es um 4/min, am Tag um 3/min — nach einer Nacht ist
der Morgen die Erlösung (Grundsatz 2).

**Stufen mit Abstand:** eine Stufe kommt bei 30/60/85 und geht erst bei 25/55/80 — kein Flackern an der
Schwelle.

| Stufe | Wirkung in Zahlen | Weg | „mild" |
|---|---|---|---|
| Unruhig (30+) | Ausdauer-Erholung −10 %; Herzschlag-Laut, sobald F-16 einen liefert (Vanilla hat keinen) | Buff | nur der Laut |
| Verängstigt (60+) | Streuung Fernkampf und Zauber +25 %; Trugbilder (B4) beginnen | Buff, Tags `ranged`/`itm700_zauber` | Trugbilder selten, keine Streuung |
| Grauen (85+) | Sichtrand dunkel (`ModifyScreenEffect Dark`, schwach); beim Treffer 3 s Lauftempo +10 % und Ausdauer-Erholung −50 % („Panik") | Buff | nur der Sichtrand |

„Sprint-Zwang beim Treffer" (Tabelle oben) gibt es in XML nicht; die „Panik" oben ist die Fassung
ohne Zwang. Nahkampf-Schaden und -Tempo bleiben in jeder Stufe unberührt (P3).

**Einzelspiel (D118):** im Einzelspiel ist der Spieler immer allein — **„allein" zählt dort nicht**. Den
Unterschied kennt XML nicht; der Direktor (C#, Server) setzt `cv700_mitspielerDa` = 1, solange mehr als
ein Spieler in der Welt ist (Vertrag 07 Nachtrag 4). Fehlt der C#-Teil, liest der Wert 0 und „allein"
entfällt überall — der sichere Rückfall.

**Karte und Marken (D96):** die Stufe „voll" schaltet Karte, Kompass-Leiste und Marken **nicht** ab. Sie
sind Bedienhilfe (P5); Furcht kommt aus Dunkelheit und Klang, nicht aus Orientierungsverlust.

- Mechanische Effekte sind gewollt (D14). Säule P3 bleibt aber: Nahkampf wird **nicht** unbrauchbar, vor allem Bogen und Zauber leiden
- Umsetzung: Buffs und CVars per XML; Messung von Licht, Nähe zu Mitspielern und Sichtkontakt braucht wahrscheinlich C# → REA
- *Triage WP9.6 ([triage-phase-2.md](../rea/triage-phase-2.md) Nr. 3–7; zu prüfen N-116):* B3 und B4 **XML**
  (Licht, Gesellschaft, `IsLocalPlayer`). **C# ohne Patch** für Regler und Direktor (B5) — warum nicht
  XML: der Regler ist eine Server-Einstellung, die XML nicht lesen kann; der Direktor rechnet
  Phasen über Tage und alle Spieler, das kann kein Buff am einzelnen Spieler.

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
- **Stand 2026-11-23 (Plan-0002 WP6.7, D158, zu prüfen N-103):** zwölf Fundschriften gebaut
  (`700_70_Handel`, `itm700_schrift…`), als Beute in Pult, Bücherbord, Sarg, Truhe und Totenbeutel.
  Im Text heißt das Zeichen **Schutzzeichen** / ward sign (wie F-15). Pestgruben, Leichenkarren,
  Grabkreuze und verriegelte Türen brauchen eigene Orte (WP6.6, N-98).

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
- [ ] ~~Playtest-Frage „Hattest du nachts im Wald allein Angst?“: Mehrheit sagt Ja (5+ Tester)~~ *Ersetzt mit WP11.1 (Prüfung 0003 B-34, D45/D46 — solo und intern):* im Testlauf WP11.10 erreicht, wer eine Nacht allein ohne Licht draußen im Wald steht, **mindestens „Verängstigt"**; wer mit Fackel am Feuer sitzt, kommt **nicht über „Unruhig"**. Die Frage an Spieler bleibt für einen öffentlichen Release.
- [ ] Keine Nacht fühlt sich wie die andere an (Direktor-Log zeigt Phasenwechsel)
- [ ] Trugbilder sind nur beim betroffenen Spieler sichtbar (Dedicated + 2 Clients)
- [ ] Grauen-Intensität „aus“ entfernt Trugbilder und Furcht-Effekte vollständig; „mild“ entfernt alle Mechanik-Mali
- [ ] Performance: Klang- und Nebel-Effekte senken die Client-FPS nicht spürbar

## Offene Fragen
- Q17: Welche härteren Todesfolgen konkret? (vertagt; Rahmen D15)

## Stand 2026-11-20 — B1 ist gebaut, soweit es eine Zahl ist (WP8.1, WP8.2, D72)

**Warum nicht C#?** Weil es XML ist (Säule P5): zwölf `<set>` in `700_60_Welt`, kein Patch.

| B1 verlangt | Stand |
|---|---|
| Nächte deutlich dunkler | gebaut: drei Nachtwerte gesenkt, der Tag bleibt |
| Neumond fast schwarz, Mondphasen mit Gewicht | gebaut: Sockel runter, Mondanteil rauf — **aber „fast schwarz" hat eine feste Untergrenze im Code** |
| Nebel in Wald und Moor | gebaut: Wald öfter und dichter, Moor dauerhaft diesig |
| Nebel in Flusstälern | **nicht gebaut** — ein Flusstal ist kein Biom (F-07) |
| abends dichter | **nicht gebaut** — `fogPower` ist ein Exponent mit ungelesener Richtung |
| Licht mit kleinem Radius, flackernd | F-08, WP6.4 |
| Fackeln blenden die Umgebung stärker ab | nicht gebaut, kein XML-Hebel gefunden |

**Zwei Grenzen, die für B3 zählen werden.** Der Helligkeitsregler des Spielers geht in die
Lichtrechnung ein, und der Code führt eine Untergrenze von 0,2. Wer nicht im Dunkeln
stehen will, muss es auf seinem Bildschirm nicht. *Notiz für Phase 2 (Regel 6):* ein
Furcht-System, das an Dunkelheit hängt, darf sich nicht auf das Bild verlassen, sondern
braucht einen eigenen Wert für „dunkel" — und dann stellt sich die Frage, ob der Regler
gedeckelt wird. Beides ist C# und braucht ein REA-Finding.

**Alle zwölf Zahlen sind Setzungen und im Spiel ungesehen** → Prüfliste 18 im Plan.
Messungen: [WP8-nacht-und-nebel.md](../rea/findings/WP8-nacht-und-nebel.md).

### B8 — sichere Orte (WP8.3, D73)

**Warum nicht C#?** Zwei Buffs und drei Blockzeilen in `700_60_Welt`, kein Patch.

- **Wo:** an brennender **Feuerstelle, Esse und Kräuterküche**. Das hat die Messung
  entschieden: das Spiel legt eine Flächenwirkung nur um Blöcke mit aktiver Kacheleinheit.
- **Was:** die sichtbare Wirkung **„Am Feuer"** — Kälteschutz wie bisher und
  Ausdauer-Erholung +20 % (vom Nutzer entschieden: „Kleine Erholung"). Keine Heilung.
- **Nicht:** das Holzfeuer (keine Kacheleinheit — Berichtigung an WP6.4) und Wandfackeln.
- **Aus B8 nicht gebaut:** „befestigtes Heim mit Schutzzeichen" und „geweihter Boden" —
  Phase 2 (F-15, F-07). „Senkt das Grauen" ebenfalls: es gibt noch kein Grauen.

*Notiz für Phase 2 (Regel 6):* `buff700_amfeuer` ist die Stelle, an der B3 das Grauen
senken lässt. Die Wirkung entsteht auf dem Client — für „Gemeinschaft schützt" (Grundsatz
5) reicht sie also nicht, dafür braucht es die Abfrage „Mitspieler in der Nähe".

Im Spiel ungesehen → Prüfliste 19 im Plan. Messungen: Befund §8.

### B2 — Klang, soweit XML (WP8.4, D74)

| B2 verlangt | Stand |
|---|---|
| Seuchentote leiser | **nicht als Pegel** — der liegt in Unity-Vorlagen. Gebaut: sie geben **seltener** Laut (ohne Ziel ein Drittel so oft, in der Verfolgung gut halb so oft) |
| ihr erster Laut ist oft schon nah | zur Hälfte: Schläfer stöhnen selten auf; der Laut beim Bemerken (`SoundSense`) ist nicht angefasst |
| ferne Klänge | **nicht gebaut** — siehe unten |
| Stille als Werkzeug (Tiere verstummen) | Phase 2, C# |

**B2 und B4 widersprechen sich, und D74 folgt B4.** B2 nennt ferne Klänge „MVP", B4 nennt
einen Laut ohne Quelle ein Trugbild: Phase 2, erst ab „Verängstigt", nur beim Betroffenen,
und nie so, dass ein echter Gegner vorgetäuscht wird. Vanillas Material sind ein
Glockenschlag und Tierlaute. Ein Wolfslaut ohne Wolf bräche die Regel. *Notiz für Phase 2
(Regel 6):* der XML-Weg steht (`PlaySound` mit `RandomRoll`, `TimeOfDay`, `InBiome`,
`IsSheltered`); was fehlt, sind eigene Klänge (F-16) und der Grauen-Wert, der sie auslöst.

Im Spiel ungehört → Prüfliste 20 im Plan. Messungen: Befund §9.

## Stand 2026-11-07 — Kurz-Check

**Dunklere, nebligere Nächte sind XML.** `worldglobal.xml` führt die Himmelswerte als
Tag-/Nacht-Paare (`ambientEquatorScale .7,.45`, `ambientGroundScale .3,.05`, `ambientSkyScale
1,.7`, `ambientMoon .8,.4`, `fogPower`). ~~D16~~ **D12** ist damit eine Zahl, kein Patch
(*berichtigt am 2026-11-20: D16 ist die Mobilität*). Nebel pro Biom (`<Fog range prob>`)
ebenfalls XML.

**Das Grauen-System ist nicht so billig wie gehofft.** Als Buff-Bedingung vorhanden sind
`TimeOfDay`, `IsSheltered`, `RandomRoll`, `CVarCompare`, `SandboxOptionBool`. **Nicht** gefunden:
eine Abfrage der Lichtstärke am Spielerort und eine Abfrage „Mitspieler in der Nähe“.
„Im Dunkeln, allein, draußen“ lässt sich damit nicht vollständig in XML schreiben.

*Notiz für Phase 2 (Regel 6):* Entweder gröbere Definition (Nacht + kein Dach + Zufall, rein XML)
oder C# für die Lichtabfrage. Gehört zu D18 und ist hier nicht entschieden.
(**Widerspruch, offen** — siehe Prüfung 0003, W-33)
*Stand WP9.4 (2026-11-23, zu prüfen N-114):* die Lichtabfrage **gibt es** als Buff-Bedingung
`CompareLightLevel` — Vanilla benutzt sie nur nicht, darum fehlte sie hier. „Mitspieler in der Nähe"
geht über einen Buff, den jeder Spieler im Umkreis auf Verbündete legt (`IsAlly`). W-33 löst sich
damit zugunsten von XML, wenn S-34 (1) und (2) bestehen.
[Finding](../rea/findings/WP9-licht-und-seuchennacht.md)
Befund: [02-10-schnittstellen-kurzcheck.md](../rea/findings/02-10-schnittstellen-kurzcheck.md#prio-4--f-17-grauen-und-atmosphäre)
