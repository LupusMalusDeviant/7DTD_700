# Prüfung 0003 — Trägt das GDD das ganze Spiel im Setting von 700?

| | |
|---|---|
| **Datum** | 2026-11-22 |
| **Rolle** | unabhängiger Gegenleser; geändert wurde nichts außer dieser Datei |
| **Stand der Dokumente** | Commit `94b694a`, GDD mit D1–D91 |
| **Auftrag** | Vollständigkeit gegen Vanilla, Stimmigkeit im Setting, Widerspruchsfreiheit, Lücken im Plan |

## 1. Kurzfassung

1. **Nein, das GDD trägt noch nicht das ganze Spiel.** Es trägt Phase 1 gut und Phase 2 bis 4 in Umrissen.
2. Von **89 Vanilla-Systemen** sind **36 geplant**, **37 dünn** und **16 fehlen** ganz (keine Entsprechung, keine Entscheidung).
3. Die größten Löcher in Phase 1: **Wasser** (Tausammler gesperrt, Gefäße in Vanilla nicht füllbar), **Biom-Gefahren** (alle Gegenmittel gesperrt), **Infektion** (nur Honig), **Luftabwurf** (das Flugzeug fliegt weiter).
4. Die **MVP-Definition** (GDD:221–225) verspricht „ohne Anachronismus in … Texten" und „Gegner … mit neuen Namen". Der Plan liefert beides wissentlich nicht (Händler, Aufträge, Wesen-Namen).
5. **Abschnitt 8 ist nicht die Liste der offenen Fragen:** Q18 und Q19 sind beantwortet, mindestens 14 offene Entscheidungen stehen nur in Feature-Dokumenten und im Plan.
6. **Sechs Kernfragen hat niemand beantwortet:** Spielziel, Tod und Wiederkehr, was die Seuchennacht in der Welt ist, Leitplanke für reale Religion, Frauen- und Männerfiguren, Sprache der Händler.
7. **Setting:** Das meiste hält. Später als 700 sind Streithammer, Motte, Tiegelstahl, Hexenbesen, Kompass, Destillierhelm, „Geselle"; Gambeson, Fachwerk und Streitkolben sind als Sache plausibel, als Wort später.
8. **Widersprüche:** 33 Stellen, davon drei mit Folgen für den Bau (Runenkundiger auf dem Intellekt-Baum, Armbrust vor dem Langbogen, Wegsteine in Phase 3 oder 4).
9. **Dünn bis zur Unbaubarkeit** sind F-09, F-11, F-19, F-20, F-14, F-10 und F-06 (keine Zuordnungstabelle der 31 Zombie-Familien).
10. Am Ende stehen **33 Entscheidungsvorschläge** (D93–D125), alle mit **[zu prüfen]**.

## 2. Wie geprüft wurde

**Gelesen (vollständig):** `docs/GDD.md`, `docs/specs/01-technischer-rahmen.md`, `docs/features/README.md`, F-00 bis F-21, `docs/glossar.md`, `docs/contracts/README.md`.
**Gezielt durchsucht:** `docs/plans/0001-…` (Offene Punkte ab Zeile 2440 gelesen, sonst Suche), `docs/balancing/0001…0003`, `tools/check/denylist.txt`, `docs/rea/findings/02-10-schnittstellen-kurzcheck.md`.

**Gemessen an Vanilla** (Dateinamen, Knotennamen, Kennungen; nichts ins Repository kopiert):
45 XML-Dateien unter `Data/Config/`. Daraus stammen in diesem Bericht: die 298 `entity_class`-Namen (31 Zombie-Familien in fünf Stufen, die Tiere, `supplyPlane`, `npcSurvivor*`), sechs Biome und die Wetternamen (`storm`, `stormbuild`), die Buffs `buff*_Hazard`, `buff*_Storm` und `buffBiomeProgressionCheck`, die vier Herausforderungs-Kategorien (darunter „Biome Progression"), die Zieltypen in `quests.xml`, `trader_info` (offen 4:05–21:50, Automaten, Mietautomat), die Optionsschlüssel `go*` in `Localization.csv`, die auskommentierte Füll-Aktion an `drinkJarEmpty`, die Freischaltstufen der Bögen in `progression.xml`, `events.xml` (Ostern, Weihnachten, Halloween, Thanksgiving), vier Hintergrundbilder in `loadingscreen.xml`.

**Nicht gemessen, nur angenommen:** was eine Spieloption im Code tut; ob eine Mod Voreinstellungen setzen kann; ob DLC-Besitzer gesperrte Garnituren über ein Kosmetikfenster anlegen können; alles im Spiel Sichtbare (ich habe kein Spiel gestartet).

**Historische Einordnungen** stammen aus meinem Wissen, ohne Nachschlagen. Ich nenne je Zeile, wie sicher ich bin. Quellenangaben erfinde ich nicht; wo ich einen Namen nenne (Beda, Plinius), ist es Erinnerung und vor einer Entscheidung nachzuprüfen.

Marken im Text: **[G]** = gelesen oder gemessen, mit Fundstelle. **[A]** = angenommen.

## 3. Vanilla-System → 700-Entsprechung

Urteil: **geplant** = Entsprechung oder ausdrückliche Entscheidung mit Phase. **dünn** = erwähnt, aber nicht baubar oder nur in der Denylist entschieden. **FEHLT** = keine Entsprechung und keine Entscheidung in GDD oder Feature.

### 3.1 Welt und Bedrohung

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 1 | Blutmond, Hordennacht | Seuchennacht | F-09, GDD 2.3; Texte D79, D80 | 1 Texte · 2 | dünn |
| 2 | Spielstufe (`gamestages.xml`) | keine | nur als „Gamestage X" in F-06, F-09, F-18 | – | dünn |
| 3 | Beute: Tabellen, Beutestufe, Qualitätsvorlagen | Purge und Ersatz | F-01, D89; „Beutestufe" kommt in keinem Dokument vor | 1 | dünn |
| 4 | Fünf Biome | fünf Kulturzonen | F-07, D43, D72 | 2 | dünn |
| 5 | Biom-Gefahren, Biom-Fortschritt, Abzeichen | keine | nur Plan-0001:2552 als offene Frage | – | **FEHLT** |
| 6 | Stürme (`storm`, `buff*_Storm`, `goStormFreq`) | keine | – | – | **FEHLT** |
| 7 | Wetter und Temperatur | „wie Vanilla" | D34; Nebel D72 | 1 | dünn |
| 8 | Tag- und Nachtlicht, Nebel | dunklere Nächte | F-17 B1, D72 | 1 | geplant |
| 9 | Zufallswelt (Ortschaften, Bezirke, Straßen) | Weiler statt Städte | F-07 | 2 | dünn |
| 10 | Navezgane und fertige Karten | keine | D79 streicht nur den Namen; eigene Karte D4 | – | **FEHLT** |
| 11 | POIs, Dekoration, Ladenschilder | eigene POIs | F-07; F-01 „bekannte MVP-Lücke" | 2 | dünn |
| 12 | Schläfer | Totsteller | F-17 B6, D74 | 1 Klang · 2 | geplant |
| 13 | Biom-Spawns, Wanderhorden | Spawn-Gruppen je Zone, „Wanderzug" | F-06, F-17 B5 | 2 | dünn |
| 14 | Hitze-Karte und Schreier | „Schreiende" | F-06; D64 (Fackeln ohne Hitze) | 2 | dünn |

### 3.2 Gegner und Tiere

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 15 | 31 Zombie-Familien | Seuchentote (Bauern, Mönche, Krieger, Pilger) | F-06 | 2 | dünn |
| 16 | Stufen Feral, Radiated, Charged, Infernal | Verderbte, Moorleichen; zwei Stufen ohne Namen | GDD 2.3, Glossar §2, D80 | 2 | dünn |
| 17 | Sondergegner: Polizist, Demolisher (Sprengsatz), Soldat, Hazmat, `PlagueSpitter`, `Frostclaw`, `Chuck`, Wight, `Mutated`, Spinne | keine Zuordnung | F-06:19 nennt drei „entfernen" | 2 | **FEHLT** |
| 18 | Geier | nur als Basis für das Irrlicht | F-06:25 | 2 | dünn |
| 19 | Zombiehund, -bär, -eber, Direwolf | Spuk-Hund (selten); „Seuchenhund" in D74 | F-06:27 | 2 | dünn |
| 20 | Hirsch, Reh, Hase, Huhn, Schwein, Bär, Wolf, Eber | Wolf, Bär, Wildschwein, Hirsch | F-06:18 | 2 | geplant |
| 21 | Berglöwe, Kojote, Schlange, Insekten- und Bienenschwarm, Boss „Grace" | keine | – | – | **FEHLT** |
| 22 | Menschliche NPCs, Fraktionen (`bandits`, `whiteriver`, `duke`) | Plünderer, Seuchenkult | F-20, D39 | 3 | dünn |
| 23 | Blockschaden der Gegner | bleibt Vanilla | D65 | 1 | geplant |

### 3.3 Spieler

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 24 | Attribute und Perks | fünf Bäume, der sechste später | F-21, D66–D68, D90 | 1 · 2 | geplant |
| 25 | Buchreihen | Abschriften | D69 | 1 | geplant |
| 26 | Magazine, Handwerks-Stufen | Lehrblätter, Learning by Doing | D70, D71, F-21 | 1 · 2 | geplant |
| 27 | Spielerstufe, Erfahrung, Fertigkeitspunkte | bleibt (stillschweigend) | D66 und D71 setzen sie voraus | 1 | dünn |
| 28 | Tod, Wiederkehr, Schlafsack, Rucksack, Todesstrafe | „Schlafstatt" (Ladetipp D78) | D15 optional härter, Q17 offen | 2 | dünn |
| 29 | Landanspruchsblock | „Grenzstein" nur vorgeschlagen | D77, Glossar §10.6 | 1 | dünn |
| 30 | Karte, Kompass, Wegpunkte, Bildschirmmarken | keine | F-12:40 nennt nur „Kompass- und HUD-Begriffe" | – | **FEHLT** |
| 31 | Verletzungen (Abschürfung, Verstauchung, Bruch, Blutung, Platzwunde, Gehirnerschütterung) | bleiben mit Heilmitteln der Zeit | F-11:24, D56 | 1 · 2 | geplant |
| 32 | Infektion | Seuchenbrand | F-11, D35; Phase 1 nur Honig (Plan:2664) | 2 | dünn |
| 33 | Dysenterie | Ruhr | F-11 | 2 | geplant |
| 34 | Hunger, Durst, Kochen | Vanilla mit Verderb | F-19, D32, D89 | 1 · 2 | geplant |
| 35 | Wasser: Tausammler, Gefäße, Eimer, trübes Wasser | keine | nur Denylist:363 und Ladetipp D78 | – | **FEHLT** |
| 36 | Dosen, Gläser, Getränke | gesperrt; Bier und „Tee" bleiben | nur Denylist:43–45, 559–565 | 1 | dünn |
| 37 | Drogen, Booster, Süßigkeiten | Tränke, Salben | GDD 2.3, F-11, F-15, D56 | 2 | geplant |
| 38 | Schleichen | bleibt (Jäger: Pirsch) | F-21 | 1 | geplant |
| 39 | Spielerfigur, Charaktererstellung (`archetypes.xml`) | keine | – | – | **FEHLT** |
| 40 | Kosmetik, DLC- und Event-Rüstungen | „ohne jeden Weg" | F-03:39–42 | 1 | dünn |

### 3.4 Ausrüstung

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 41 | Nahkampfwaffen | Sax, Spatha, Ango, Äxte, Keulen | F-02, D58, D88 | 1 | geplant |
| 42 | Bögen, Armbrüste, Pfeile | Langbogen, Armbrust, Sonderpfeile | D54, D87, D91 | 1 | geplant |
| 43 | Schusswaffen, Munition | gesperrt | F-01, GDD 2.3 | 1 | geplant |
| 44 | Sprengstoff, Granaten, Molotow, Minen | Pechtopf, „Fluchtopf", Feuerzauber | GDD:119; F-08:91 schiebt auf | 2 | dünn |
| 45 | Rüstung (drei Gewichtsklassen) | T0 bis T3 | F-03, D59, D61 | 1 | geplant |
| 46 | Aufsätze (`item_modifiers.xml`) | Runen; 29 Aufsätze mit neuen Zutaten | D89, F-15 | 1 · 2 | dünn |
| 47 | Qualität 1–6, legendäre Teile | Handwerksqualität | D23, D70 | 1 | geplant |
| 48 | Verschleiß, Reparatur | Schleifstein, Schmiedeflicken, Nähzeug | D60, D62, D91 | 1 | geplant |
| 49 | Werkzeuge: Abbau, Ausschlachten, Motorwerkzeug | Äxte umgedeutet, Rest gesperrt | F-02:142 „fünf Werkzeuge … kein Paket der Phase 1" | 1 | dünn |
| 50 | Tragbares Licht (Fackel, Lampe, Helmlicht) | Fackel, Kerze, Öllampe, Holzfeuer | F-08, D64 | 1 | geplant |

### 3.5 Handwerk, Bauen, Versorgung

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 51 | Werkstätten | sieben, später neun | F-04, D57 | 1 · 2 | geplant |
| 52 | Rezepte | 73 mit neuen Zutaten, 7 entfallen | D89 | 1 | geplant |
| 53 | Rohstoffe und Erze | Raseneisenerz, Buntmetall, Blei | F-05, Glossar §3 | 1 | dünn |
| 54 | Schrott, Zerlegen | Raseneisenerz, Buntmetall | Glossar §3 | 1 | geplant |
| 55 | Währung | Silberpfennig | D30 | 1 | geplant |
| 56 | Blockstufen, Aufwerten | Rahmen bis Mörtelstein | F-18, D28, D63 | 1 | geplant |
| 57 | Farbe, Texturpinsel | gesperrt | nur Denylist:288, 347 | 1 | dünn |
| 58 | Türen, Luken, Schlösser, Dietriche, Tresore | Tor; Dietrich frei, Tresore gesperrt | nur Denylist:357, 588; D90 | 1 | dünn |
| 59 | Truhen, beschriftbare Kisten und Schilder | bleiben | nur Denylist:674 | 1 | dünn |
| 60 | Strom | Kraftsteine, Kraftlinien | D37, F-15 | 1 gesperrt · 2 | geplant |
| 61 | Elektrische Fallen, Geschütze, Drohne | Runenfallen, Runensteine, dienstbarer Geist | F-15, D87 | 2 | geplant |
| 62 | Mechanische Fallen | Spitzpfähle, Eisenspitzen, Palisade | F-18 | 1 | geplant |
| 63 | Ackerbau | Getreide, Rüben, Flachs; Feld-Rezept D89 | F-19, D33 | 1 Feld · 2 | geplant |
| 64 | Hühnerstall, Bienenstock | frei laut Denylist | Denylist:647–651; F-19 kennt beide nicht | 1 | dünn |
| 65 | Angeln (Vanilla hat keins) | F-19:13 nennt „Fisch" | F-19 | 2 | dünn |
| 66 | Jagd, Zerlegen | Jäger | F-21, D80 | 1 | geplant |

### 3.6 Händler, Aufträge, Transport

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 67 | Fünf Händler | Klostermarkt, Marktflecken, Fürstenhof, Schmiedehof | F-10, D41 | 2 | dünn |
| 68 | Händlerschutz, Öffnungszeiten | wie Vanilla | F-10:19 | 2 | geplant |
| 69 | Verkaufsautomaten | keine | – | – | **FEHLT** |
| 70 | Auftragsarten: Holen, Säubern, Befallen, Vergraben, Strom, Schatzkarte | Hof säubern, Reliquie bergen, Lieferung, Brunnen | F-10:26 | 2 | dünn |
| 71 | Händlerstufen, Einstiegsauftrag, Händler-zu-Händler | Startnotiz | D75, D80 | 1 · 2 | dünn |
| 72 | Dialoge, Händlerstimmen, 1336 Untertitel | keine | D74, D79, D83: „nicht entschieden" | 2 | **FEHLT** |
| 73 | 175 Herausforderungen | 37 Zeilen umgeschrieben | D80; Plan:2541 | 1 | dünn |
| 74 | Luftabwürfe (`supplyPlane`, `goAirDropFrequency`) | keine | – | – | **FEHLT** |
| 75 | Fahrzeuge | Karren, Packtier, Reitpferd, Hexenbesen, Runenross | F-13, D16, D17 | 3 · 4 | dünn |
| 76 | Treibstoff | entfällt; Futter und Odem | F-13 | 3 · 4 | geplant |

### 3.7 Rahmen

| Nr | Vanilla-System | 700-Entsprechung | Feature / Entscheidung | Phase | Urteil |
|---|---|---|---|---|---|
| 77 | Rund 100 Spieloptionen, Sandbox-Vorlagen | Texte umgeschrieben | D79 | 1 | dünn |
| 78 | Schwierigkeit | keine | – | – | **FEHLT** |
| 79 | Ladebildschirm (Tipps und vier Bilder) | Tipps | D78; Bilder nicht erwähnt | 1 | dünn |
| 80 | Musik (`music.xml`, `dmscontent.xml`) | keine | – | – | **FEHLT** |
| 81 | Klänge | seltener hörbar; eigene Klänge | F-17 B2, D74, F-16 | 1 · 2 | geplant |
| 82 | Oberfläche (XUi) | Farbtönung, Etikett | F-12, D85 | 1 | geplant |
| 83 | Sprachdatei | Deutsch und Englisch | F-12, D7, D75 | 1 | geplant |
| 84 | Twitch | keine Entscheidung; Zeilen bleiben liegen | D79, D80 | – | **FEHLT** |
| 85 | Saison-Ereignisse (`events.xml`) | Event-Waffen gesperrt | nur Denylist:291 | – | **FEHLT** |
| 86 | Gruppe, Verbündete | Vanilla; gemeinsame Siedlung | F-14, D44 | 3 | geplant |
| 87 | PvP | keine | – | – | **FEHLT** |
| 88 | Kreativmodus | „keine Sperre für den Spieler" | F-02:109 | 1 | geplant |
| 89 | Spielarten: Einzelspiel, vom Spieler gehostet, Dedicated | Einzelspiel, Dedicated | GDD:10 | – | dünn |

**Summe: 89 Systeme — 36 geplant, 37 dünn, 16 FEHLT.**

## 4. Befunde

Fundstellen als `Datei:Zeile`. `Plan` = `docs/plans/0001-phase-1-mvp-700-und-grauen.md`, `Denylist` = `tools/check/denylist.txt`.

### Schwere hoch

**B-01 — Die MVP-Definition verspricht mehr, als der Plan liefert.** [G]
`GDD.md:221–225`: „ohne Anachronismus in Items, Rezepten, Loot und Texten" und „Gegner, Waffen und POIs sind noch Vanilla-Modelle mit neuen Namen". Dagegen: Wesen-Namen bleiben Vanilla (`GDD.md:326`, sieben Namen „F-06, Phase 2"), die Händler heißen „Joel, Rekt, Jen, Bob, Hugh" und sprechen modernes Englisch (`GDD.md:332`, `Plan:2688`), 153 Zeilen aus Aufträgen und Herausforderungen bleiben liegen (`GDD.md:329`). F-01 nennt nur die POIs als „bekannte MVP-Lücke" (`F-01:28`).
*Empfehlung:* Die MVP-Definition um eine ausdrückliche Liste dessen ergänzen, was in Phase 1 modern bleiben darf. Sonst ist Z2 nie erfüllbar. → D93.

**B-02 — Phase 1 hat keinen geplanten Weg zu Wasser.** [G]
Der Tausammler ist gesperrt (`Denylist:363`, `mod/700_10_Purge/Config/blocks.xml:44`). In Vanillas `items.xml` ist die Aktion, die ein leeres Gefäß am Gewässer füllt, auskommentiert (`drinkJarEmpty`, `ExchangeItem`). Der neue Ladetipp sagt „Koch es im Kochtopf … ab" (`Localization.csv:701`), nennt aber keinen Weg, an trübes Wasser zu kommen. Kein GDD-Abschnitt und kein Feature plant Wasser.
[A] Es bleibt Beute und das Trinken direkt am Gewässer. Ob das für eine Woche reicht, weiß niemand.
*Empfehlung:* Nach dem Grundsatz aus D87 umdeuten statt sperren: Tausammler als Regentonne. → D98.

**B-03 — Biom-Gefahren und Biom-Fortschritt haben keine Entscheidung, und D34 stand auf einer falschen Annahme.** [G]
`GDD.md:362`: „Temperatur/Wetter | Wie Vanilla". Geschrieben am 2026-11-07 unter der V2.x-Annahme (D52). Vanilla V 3.40 führt Gefahren je Biom (`buffBurnt_Hazard`, `buffDesert_Hazard`, `buffSnow_Hazard`, `buffWasteland_Hazard`), eine Kategorie „Biome Progression" und die Option `goBiomeProgression`. Der Plan sagt selbst: „Ob die Gefahren in Phase 1 an sind und was dann gegen sie hilft, steht in keinem Dokument" (`Plan:2552–2555`); alle vier Gegenmittel sind gesperrt. F-03 trägt den Tag `biomeChallenge` an T1 (`F-03:80`), ohne dass jemand sagt, wofür.
*Empfehlung:* Für Phase 1 abschalten oder ausdrücklich tragen; für Phase 2 je Kulturzone umdeuten. → D94.

**B-04 — Das Versorgungsflugzeug fliegt weiter.** [G]
`supplyPlane` und `sc_General` stehen in Vanillas `entityclasses.xml`; kein Modlet fasst sie an (Suche in `mod/`: nur der Kisteninhalt in `700_20_Material/Config/loot.xml:38`). GDD, Features und Glossar erwähnen den Luftabwurf nicht. Die Option `goAirDropFrequency` gibt es.
*Empfehlung:* Entscheidung „entfällt", bis eine Deutung ohne Himmel gefunden ist. → D95.

**B-05 — Eine Infektion ist in Phase 1 kaum heilbar, und das ist unentschieden.** [G]
`Plan:2664–2672`: „Eine Infektion hat in Phase 1 nur noch Honig … ob Honig allein eine ernste Infektion noch aufhält, ist ungemessen." D56 hat Verband, Schiene und Salbe gerettet, die Infektion nicht. F-11 liegt in Phase 2 und verlangt dort „T2-Wissen" (`F-11:36`).
*Empfehlung:* Ein Kräutermittel so behandeln wie D56 die Wundauflage. `drugHerbalAntibiotics` nennt F-21 selbst als Kandidaten (`F-21:146`). → D99.

**B-06 — Abschnitt 8 ist nicht die Liste der offenen Fragen.** [G]
`GDD.md:395–396` führen Q18 und Q19 als offen. Beide sind beantwortet: Q18 „nein, nicht per XML" (`F-13:78`), Q19 „Ja, mehr als erwartet" (`docs/rea/findings/02-10-schnittstellen-kurzcheck.md:235`). Umgekehrt fehlen dort: Biomnamen gegen D43 (`F-07:57` „noch nicht entschieden"), Umfang von Learning by Doing (`F-21:162`), Händlerstimmen (`Plan:2694`), 35 unerfüllbare Herausforderungen (`Plan:2541`), Stromaufträge (`Plan:2566`), 15 Rang-Texte ohne Wirkung (`Plan:2628`), Kohlenerz (`Plan:2646`), ferne Klänge (`Plan:2682`), Infektion (`Plan:2664`), Sandbox-Vorlagen (`GDD.md:328`), Reparaturzeug für Bögen (`GDD.md:340`), sieben offene Begriffe (`glossar.md:313–334`), Lizenz der Meshy-Ergebnisse (`F-16:62`), Amulett-Slot (`F-15:122`).
*Empfehlung:* Regel festschreiben, dass jede offene Entscheidung eine Q-Zeile bekommt, und die 14 nachtragen. → D120.

**B-07 — F-06 hat keine Zuordnung der Gegner, und für den Sprengsatz gibt es keine Entscheidung.** [G]
`F-06:14`: „Jeder Vanilla-Zombie bekommt eine 700-Entsprechung". Eine Tabelle dazu fehlt; gemessen sind es 31 Familien in fünf Stufen. `F-06:19` nennt drei („Polizist, Soldat, Krankenschwester"). F-18 nennt zwei davon selbst „Sprengkörper" (`F-18:143`: `zombieFatCop` 500, `zombieDemolition` 5000). Säule P1 verbietet Schießpulver (`GDD.md:36`).
*Empfehlung:* Zuordnungstabelle zur Pflicht vor Phase 2 machen; die Mechanik behalten und anders deuten. → D100, D101.

**B-08 — Die Welt der Phase 2 ist nicht durchgerechnet.** [G]
`F-07:42`: „Mindestens 10 eigene POIs mit Quest-Markern". `F-07:34` lässt aus Vanilla nur „Höhlen, Hütten, Ruinen" zu. F-10 will in derselben Phase vier Handelsposten und Vanillas Auftragsarten. Niemand hat gezählt, wie viele POIs je Auftragsstufe nötig sind, wo ein Händler in einer Welt ohne Ortschaften steht, oder was aus Navezgane wird — der Nutzer hat am 21. November auf Navezgane gespielt (`Plan:2593`).
*Empfehlung:* Vor Phase 2 eine Bedarfsrechnung in F-07 (POIs je Stufe, Händlerplätze) und eine Zeile zu den fertigen Karten. → D110.

**B-09 — Niemand weiß, an welchem Attribut der Runenkundige hängt.** [G]
`F-15:22`: „Perkbaum **Runenkunde** (umgedeuteter Intellekt-Baum)". `GDD.md:315` (D66): „`attIntellect` 0 → **Heiler**". Der Intellekt-Baum ist vergeben. D66 sagt nur, sechs Bäume seien „technisch gegangen".
*Empfehlung:* Sechstes eigenes Attribut festlegen und F-15 berichtigen. → D111.

### Schwere mittel

**B-10 — Händler: Zuordnung, Namen und Stimmen sind offen.** [G]
Vanilla hat fünf Händler, F-10 vier Posten (`F-10:12–17`), einer davon „optional". GDD 2.3 nennt „Wanderhändler" (`GDD.md:110`), D41 „Feste Handelsposten" (`GDD.md:381`); der Wanderhändler kommt in F-10 nicht vor. Die Stimmen sind „nicht entschieden" (`Plan:2694`).
*Empfehlung:* → D102.

**B-11 — Die Händler bieten in Phase 1 Stromaufträge an.** [G] `Plan:2566–2570`. F-10 nennt als Umdeutung „Brunnen wiederherstellen" (`F-10:26`), aber erst in Phase 2. *Empfehlung:* → D103.

**B-12 — 35 Herausforderungen sind unerfüllbar.** [G] `Plan:2541–2555`, drei Fragen „alle beim Nutzer". *Empfehlung:* → D104.

**B-13 — Karte, Kompass und Bildschirmmarken haben keine Entscheidung.** [G] Kein Dokument sagt, ob sie bleiben. Vanilla hat die Schalter `goAllowMap`, `goAllowCompass`, `goAllowScreenMarkers`. Für Säule P4 („Ungewissheit") ist das eine Designfrage, und der Magnetkompass ist in Europa erst um 1190 bezeugt [A, sicher]. *Empfehlung:* → D96.

**B-14 — Stürme kommen in keinem Dokument vor.** [G] Suche nach „Sturm" in GDD und Features: ein Treffer, der „Runenstein des Sturms" (`F-15:41`). Vanilla hat Sturmwetter in allen fünf Biomen und je Biom eine Buff-Kette. *Empfehlung:* → D97.

**B-15 — Tod und Wiederkehr sind nicht gedeutet.** [G] D15 schließt nur aus (`GDD.md:276`: „kein Wiederaufstehen als Seuchentoter"), Q17 fragt nach härteren Folgen. Was der gewöhnliche Tod in der Welt ist, steht nirgends; Rucksack und Todesstrafe ebenso wenig. Die Startnotiz liefert die Deutung fast schon mit: „We found you by the road and took you for dead" (`Localization.csv:658`). *Empfehlung:* → D105.

**B-16 — Das Spiel hat kein benanntes Ziel.** [G] Die „lange Schleife" (`GDD.md:155–157`) endet bei Wegsteinen und Runenross; die Lore-Kette lässt „die Antwort offen" (`F-10:33`). Was ein Spieler nach T4 tut, steht nicht da. *Empfehlung:* → D106.

**B-17 — Was die Seuchennacht in der Welt ist, erzählt niemand.** [G] F-09 hat 29 Zeilen und beschreibt Inszenierung, keine Deutung. Warum alle sieben Tage, warum finden sie den Spieler? Die Ursache darf offen bleiben (`GDD.md:69`), die Erscheinung braucht trotzdem Worte, die Figuren benutzen. *Empfehlung:* → D107.

**B-18 — Die Leitplanke für reale Religion steht nur in zwei Feature-Dokumenten.** [G] `F-15:24`: „Die Mod wertet keinen Glauben." `F-20:23`: „keine Satanismus-Klischees". Das GDD sagt dazu nichts, D1 verbietet nur „reale Herrscher". Offen: reale Heilige, Orden, Gebetstexte (`F-17:84` „letzte Gebete"), Götternamen; und dass Kultisten „in Kutten" (`F-20:19`) wie Mönche aussehen. *Empfehlung:* → D108.

**B-19 — Frauen- und Männerfiguren sind nicht geplant.** [G] Die Welt der Dokumente ist männlich: „Bauern, Mönche, Krieger und Pilger" (`F-06:8`), „Bruder Cellerar, Kaufmann, Kämmerer, Schmied" (`F-10:14–17`), Baumnamen und Ränge („Raufbold, Recke, Heerführer", `F-21:69–73`). Weiblich sind nur die „Schreiende" als Klageweib (`F-06:28`) und der „Hexenbesen". Vanilla hat `playerFemale`. *Empfehlung:* → D109.

**B-20 — „Mehr Gefahr für Spieler" hat keinen Besitzer, und Schwierigkeit kein Dokument.** [G] D65 lässt die zweite Hälfte von D29 stehen und schiebt sie zu „F-06/F-17" (`GDD.md:314`). Keines der beiden nennt eine Zahl. Das Wort „Schwierigkeit" kommt in GDD und Features nicht vor. *Empfehlung:* → D112.

**B-21 — Die Spielart „vom Spieler gehostet" fehlt, und Dedicated ist nicht prüfbar.** [G] `GDD.md:10`: „Singleplayer, Dedicated Server". Gespielt wurde am 21. November mit zwei Mitspielern beim Nutzer als Host (`Plan:2593–2619`, „Protokoll des Hosts"). Ein Dedicated Server ist nicht installiert (`F-00:82–85`, Plan R3). Akzeptanzkriterien in neun Features verlangen einen Dedicated Server (F-00, F-02, F-10, F-13, F-14, F-15, F-16, F-17, F-19). *Empfehlung:* → D113.

**B-22 — Musik kommt in keinem Dokument vor.** [G] Suche nach „Musik", „music", `dmscontent`: kein Treffer in `docs/`. Vanilla führt eine dynamische Musik mit Bedrohungsstufen (`music.xml`: `threat_level`). F-16 plant Umgebungsklang, keine Musik. Säule P4 nennt Klang als Träger des Grauens. *Empfehlung:* → D114.

**B-23 — Zehn Tiere und Wesen haben keine Entsprechung, ein elftes eine unpassende.** [G] Berglöwe, Kojote, Schlange, Direwolf, Geier, Zombiebär, Zombieeber, Insektenschwarm, Bienenschwarm, Boss „Grace". Der Zombiehund ist als „selten" verplant (`F-06:27`); [A] in Vanilla ist er häufig. *Empfehlung:* → D101.

**B-24 — Pechtopf, Schwingbalken und „Fluchtopf" gehören zu keinem Feature.** [G] `GDD.md:119` verweist für den Pechtopf auf „F-02, F-15". F-02 nennt ihn nicht. F-08 schiebt Pechtopf und Schwingbalken nach „F-15, Phase 2" (`F-08:91–94`), F-15 führt keinen von beiden. „Fluchtopf" steht nur in `GDD.md:119`. *Empfehlung:* In F-15 einen Abschnitt „Mechanische Fallen mit Auslöser" aufnehmen oder ein eigenes Feature anlegen. → D115.

**B-25 — Reitpferd und Packtier stehen nach Q18 ohne Phase da.** [G] `F-13:78`: „nein, nicht per XML", dazu „Notiz für Phase 4". Roadmap, D16 und der Kopf von F-13 führen das Reitpferd weiter in Phase 3 (`GDD.md:191`, `GDD.md:218`). *Empfehlung:* → D116.

**B-26 — Kohlenerz liegt im Boden und heißt Holzkohle.** [G] `Plan:2646–2650`; das Glossar nennt `resourceCoal` „Holzkohle" (`glossar.md:76`). Holzkohle abzubauen ist im Setting falsch. [A] Torf wäre die zeitgemäße Deutung eines brennbaren Bodenschatzes. *Empfehlung:* → D117.

**B-27 — Furcht im Einzelspiel.** [G] `F-17:42`: das Grauen steigt durch „allein sein (kein Mitspieler in der Nähe)". Im Einzelspiel ist der Spieler immer allein. Kein Satz regelt das. *Empfehlung:* → D118.

**B-28 — Phasen 2 bis 4 haben keine Abschlusskriterien.** [G] Nur Phase 1 hat eine MVP-Definition (`GDD.md:221`). Phase 2 trägt elf Features (`GDD.md:217`), darunter alle ersten Harmony-Patches (Furcht, Direktor, Schild, Learning by Doing); die „ehrliche Einschätzung" warnt erst vor Phase 3 (`GDD.md:237–240`). *Empfehlung:* Je Phase drei bis fünf prüfbare Sätze „fertig heißt" ins GDD. Das ist Papier, kein Vorziehen (D50). → D119.

**B-29 — Was in einer Truhe liegt, plant niemand.** [G] Der Purge nimmt weg, D89 füllt Belohnungen. Die Vision sagt, Fortschritt komme „nicht mehr aus Industrie-Loot" (`GDD.md:25`). Welche Beute ein Hof, ein Kloster, eine Römerruine hergibt und ob Vanillas Beutestufe bleibt, steht in keinem Dokument. *Empfehlung:* In F-05 einen Abschnitt „Beute in 700" aufnehmen; die Entscheidung „Beutestufe bleibt Vanilla" als Zeile. → D121.

### Schwere niedrig

**B-30 — Twitch, Saison-Ereignisse und Kosmetik sind unentschieden.** [G] Das Glossar verbietet das Wort „twitch" (`glossar.md:297`), 58 Twitch-Zeilen bleiben liegen (D79, D80). `events.xml` führt vier Ereignisse; gesperrt sind nur zwei Zuckerwaffen (`Denylist:291–292`). *Empfehlung:* → D122.

**B-31 — Kleine Systeme sind nur in der Denylist entschieden.** [G] Farbe (`:288`, `:347`), Tresore (`:357`), Dietriche (`:588`), Hühnerstall und Bienenstock (`:647–651`), Gläser (`:561`: „dass es Glas ist, räumt F-05 in WP4" — F-05 erwähnt es nicht). Eine Denylist-Zeile ist keine D-Zeile (Projektregel 4). *Empfehlung:* → D122.

**B-32 — Verkaufsautomaten.** [G] Sechs Blöcke der Klasse `VendingMachine`, zwei `trader_info` mit `is_vending`, einer mietbar. Keine Regel der Denylist trifft sie dem Namen nach. Sie stehen in POIs und gehören damit zu F-07, das sie nicht nennt. *Empfehlung:* → D122.

**B-33 — Spielerfigur.** [G] `archetypes.xml` (34 Vorlagen mit Ausrüstung) und die Charaktererstellung kommen nirgends vor. [A] Frisuren und Vorlagen sind modern. *Empfehlung:* Als bekannte Lücke in D93 aufnehmen.

**B-34 — Ein Akzeptanzkriterium ist für ein Solo-Projekt nicht erfüllbar.** [G] `F-17:124`: „Mehrheit sagt Ja (5+ Tester)". D45 und D46 halten das Projekt solo und intern. *Empfehlung:* Zahl streichen oder an den öffentlichen Release binden.

**B-35 — Status der Verträge.** [G] `contracts/README.md:9–12` nennt alle vier „abgenommen 2026-11-22". In der Aufgabenliste dieser Sitzung steht die Abnahme samt drei Berichtigungen noch als offene Nutzeraufgabe. Eine der beiden Stellen ist veraltet; welche, kann ich nicht entscheiden.

## 5. Anachronismen in unseren eigenen Begriffen

Alle Einordnungen sind **[A]**. Säule P1 gilt: „plausibel vor belegt". „Später" heißt: die Sache selbst gab es um 700 in Europa nach meinem Wissen nicht.

### 5.1 Später — die Sache passt nicht

| Nr | Begriff | Fundstelle | Einordnung | Sicherheit | Empfehlung |
|---|---|---|---|---|---|
| A-01 | **Tiegelstahl** / Crucible Steel, „Schmelztiegel" | `glossar.md:73`, `GDD.md:319` | Tiegelstahl entstand in Indien und Mittelasien; in Europa erst im 18. Jahrhundert. Um 700 wird Eisen im Schmiedefeuer aufgekohlt — genau das sagt `F-04:83`. D55 nannte ihn selbst „Schmiedestahl" (`GDD.md:294`). | hoch | Umbenennen → D123 |
| A-02 | **Streithammer** / War Hammer | `glossar.md:109` | Als eigene Waffe spätmittelalterlich. Ein schwerer Schlägel als Werkzeug ist zeitlos. | hoch | „Eisenschlägel" oder „Schmiedehammer" |
| A-03 | **Motte** | `F-07:13`, `F-07:22` | Turmhügelburgen entstehen um 1000. Ringwälle und Wallburgen passen. | hoch | Streichen, „Wallburg" |
| A-04 | **Hexenbesen** | `GDD.md:121`, D16, D38, `F-13:20` | Der Besenflug ist ein Motiv des 15. Jahrhunderts. Für das Frühmittelalter kenne ich die Nachtfahrt auf Tieren und die „Zaunreiterin". | hoch für die Datierung des Besens | Fluggerät behalten, anders nennen („Zaunstecken"). Die Hexe als Feindbild meiden, sie gehört zur Verfolgung späterer Jahrhunderte |
| A-05 | **Kompass** | `F-12:40` | Magnetkompass in Europa um 1190. | hoch | HUD-Leiste „Richtungsweiser" oder namenlos lassen; siehe B-13 |
| A-06 | **Destillierhelm** | `F-04:22` | Destillation im lateinischen Westen ab dem 12. Jahrhundert. Die Denylist sagt es selbst: „Destillation ist spaeter" (`Denylist:338`). | mittel bis hoch | „Sudkessel", „Seihtuch" |
| A-07 | **Schwere Armbrust** (auf der Compoundarmbrust) | `GDD.md:336`, `glossar.md:112` | Eine einfache Jagdarmbrust ist seit der Spätantike bezeugt und damit plausibel. Eine schwere Kriegsarmbrust mit Spannhilfe ist hochmittelalterlich. | mittel | Name ohne „schwer", Rolle als seltenes Meisterstück (D8) |
| A-08 | **Feuertopfpfeil mit griechischem Feuer**, der explodiert | `GDD.md:336`, `F-02:51` | Griechisches Feuer gibt es seit etwa 672, als byzantinisches Staatsgeheimnis und aus Rohren verspritzt. Im Mischland ist es nicht zu haben, und ein explodierender Pfeil widerspricht P1 („Schießpulver"). Brandpfeile sind antik bezeugt. | hoch für Byzanz, mittel für den Rest | Wirkung Brand statt Explosion; Text ohne griechisches Feuer. → D124 |
| A-09 | **Weberschiffchen** | `F-04:25`, `F-03:97` | Gehört zum Trittwebstuhl, der um 1000 aufkommt. Um 700 steht der Gewichtswebstuhl im Grubenhaus. | mittel | „Webschwert" |
| A-10 | **„Tee"** in Goldrutentee, Honigtee, Rotem Tee | `Denylist:562–564`, in unserer Sprachdatei nicht überschrieben | Das Wort kommt im 17. Jahrhundert. | hoch | „Sud", „Aufguss" |
| A-11 | **Kraftlinien** | D37, `F-15:46–57` | Der Gedanke von Kraftlinien in der Landschaft ist von 1921. F-15 sieht das Problem selbst („wirkt technisch"). | hoch | Nach meiner Erinnerung nennt eine kirchliche Verbotsliste um 740 Zauberknoten und Bindungen (Sicherheit mittel). „Bannschnur" oder „Knotenband" trüge dieselbe Mechanik |

### 5.2 Plausibel als Sache, das Wort ist später

| Nr | Begriff | Fundstelle | Einordnung | Sicherheit | Empfehlung |
|---|---|---|---|---|---|
| A-12 | **Gambeson**, Steppwams | `glossar.md:129`, D59, D61 | Wort aus dem 12. Jahrhundert. Gepolsterte Unterkleidung kennt die spätrömische Armee; für den Westen um 700 kenne ich keinen Fund. | Wort hoch, Sache mittel | Sache behalten. Über den Namen entscheidet der Nutzer („Stepprock") |
| A-13 | **Streitkolben** / Mace | `glossar.md:108` | Eisenbeschlagene Keulen sind zeitlos, der geflanschte Kolben ist hochmittelalterlich. | mittel | „Eisenkeule" |
| A-14 | **Fachwerk** | `GDD.md:127`, D28, `F-18:21` | Um 700 baut man Pfostenhäuser mit Flechtwerk und Lehm. Fachwerk auf Schwellen kommt im Hochmittelalter. Der Unterschied ist für Spieler kaum sichtbar. | mittel | Kann bleiben; ehrlicher wäre „Ständerwand" oder „Bohlenwand" |
| A-15 | **Geselle** | D26, F-14, `GDD.md:155` | Zunftwort des Spätmittelalters. Knechte und Gehilfen gab es immer. | mittel bis hoch | „Knecht", „Gehilfe" |
| A-16 | **Breitaxt** als Kriegsaxt | `glossar.md:106` | Die große Kriegsaxt gehört ins 10. Jahrhundert. Die Wurfaxt der Franken (Franziska) wäre die Axt der Zeit und passte zur geplanten Wurfaxt (`F-02:115`). | mittel | Kann bleiben; Franziska als Name der Wurfaxt vormerken |
| A-17 | **Damast**, „Pattern-welded Klingen" | `GDD.md:166–167`, `F-02:122` | Die Technik (verschweißte Musterklingen) ist im 6. bis 8. Jahrhundert auf ihrem Höhepunkt. Das Wort „Damast" ist später; „Pattern-welded" ist Englisch in einem deutschen Dokument und steht doppelt (T3 und T4). | hoch | Ein Name, deutsch: „wurmbunte Klinge" |
| A-18 | **Nachzehrer, Irrlicht, Moorleiche** | `F-06:24–26` | Die Namen sind frühneuzeitlich bis modern, der Glaube an Wiedergänger ist alt. | mittel | Kann bleiben (P1: „wie es sich die Menschen erzählten") |
| A-19 | **Panzerbrecherpfeil** | D91 | Schmale Spitzen gegen Ringpanzer sind plausibel, das Wort ist modern. | niedrig | Kann bleiben |
| A-20 | **slawische Burgwälle** | `GDD.md:61–62` | Die meisten datieren ins 8. und 9. Jahrhundert; um 700 ist das knapp. | niedrig bis mittel | Kann bleiben |
| A-21 | **Lehrblatt und Abschrift für Handwerker** | D69, D70 | Handwerkswissen ging um 700 mündlich weiter; Schrift lag bei den Klöstern. | hoch | Als Spielabstraktion tragen. `F-04:87` („findet man in Klöstern") ist die richtige Begründung |

### 5.3 Belegt oder gut plausibel — hier trägt das GDD

Sax, Spatha, Ango, Flügellanze, Bartaxt, Rundschild, Spangenhelm, Kettenhemd, Schienen an Arm und Bein, Langbogen (Eibenbögen aus alamannischen Gräbern), Schleuder, einfache Armbrust (selten), Rennofen, Raseneisenerz, Luppe, Esse, Holzkohlemeiler, Kalkofen und Kalkmörtel, Grubenhaus, Langhaus, Flechtwerk, Reet, Palisade, Gewichtswebstuhl, Flachs, Hanf, Emmer, Gerste, Roggen, Bier, Met, Honig, Bienenhaltung, Hopfen (im 8. Jahrhundert), Wachs- und Talgkerzen, Pergament, Glas (Becher; Kirchenfenster ab dem späten 7. Jahrhundert), Silberdenar und Sceatta, Bernstein, Reliquien, Amulette, Weihwasser, Runen, Glocken, Theriak (als seltene Arznei), Justinianische Pest bis etwa 750, Pestgruben, Ochse als Zugtier, Sattel, Cellerar und Kämmerer. Sicherheit: hoch bis mittel.

**In den Dokumenten kommen nicht vor** und sind damit kein Befund: Steigbügel (um 700 bei den Awaren belegt, im Westen im Kommen), Kummet, Windmühle, Spinnrad, Hufeisen, Seife, Schubkarre. Zwei Hinweise für später: `F-07:13` und `F-19:26` nennen eine „Mühle" — gemeint sein muss die Wassermühle. `F-19:25` nennt „Bohnen" — gemeint sein muss die Ackerbohne.

### 5.4 Zu viel gesperrt

| Nr | Fundstelle | Was | Empfehlung |
|---|---|---|---|
| A-22 | `Denylist:312–319` | „Mais, Kartoffel, Kuerbis, Blaubeere, Yucca (alle aus Amerika)". Die Heidelbeere ist in Europa heimisch (Sicherheit hoch). | Nach dem Grundsatz aus D87 als Heidelbeere umdeuten statt sperren |

## 6. Widersprüche

Beide Seiten sind zitiert. „Jünger" nennt die Seite, die nach den Daten gilt.

### 6.1 Mit Folgen für den Bau

| Nr | Seite A | Seite B | Urteil |
|---|---|---|---|
| W-01 | `F-15:22` „Perkbaum **Runenkunde** (umgedeuteter Intellekt-Baum)" | `GDD.md:315` D66: „`attIntellect` 0 → **Heiler**" | D66 ist jünger. F-15 ist falsch, und der Ort des sechsten Baumes ist offen (B-09) |
| W-02 | `GDD.md:300` D8: „**Ja**, selten, T4/Endgame"; `GDD.md:113` „Armbrust (T4, selten, D8)" | `GDD.md:336` D87: die eiserne Armbrust bleibt als „Armbrust", Werte Vanilla. Gemessen: Vanilla schaltet sie bei Bogenbau **21** frei, den Langbogen bei **36** | Die Armbrust kommt vor dem Langbogen. D8 ist damit nicht erfüllt → D125 |
| W-03 | `GDD.md:191` „F-13 … 3: Karren, Packtier, Pferd, Wegsteine" | `F-15:59–62` „Hochmagie (Phase 4, D38): … **Wegsteine**"; `F-13:22` „T3–T4" | Phase der Wegsteine ungeklärt → D116 |
| W-04 | `GDD.md:191`, `GDD.md:218` Reitpferd in Phase 3 | `F-13:78–85` „Q18 ist beantwortet: nein … Notiz für Phase 4" | Siehe B-25 |
| W-05 | `GDD.md:225` „Gegner … mit neuen Namen" (Phase 1) | F-06 Kopf „P2"; `F-06:35` „MVP: Namen, Werte und Sounds per XML"; `GDD.md:326` „7 sind Wesen-Namen (F-06, Phase 2)" | Dreifach uneins. Gebaut wird nach D77 → Phase 2 |
| W-06 | `GDD.md:323` D74 folgt B4 | `F-17:30` „B2 — Klanglandschaft (MVP: Vanilla-Sounds umgedeutet …)" | D74 nennt den Widerspruch selbst; die Überschrift von B2 ist nicht nachgezogen |
| W-07 | `GDD.md:294` D55: „deutet ihn zum **Schmiedestahl** … um" | `glossar.md:73` „Tiegelstahl / Crucible Steel / D55" | Das Glossar weicht von seiner eigenen Quelle ab; siehe A-01 |

### 6.2 Sechs oder fünf Bäume, „Transport & Logistik" oder Fuhrmann

D66 (`GDD.md:315`) gilt: fünf Bäume in Phase 1, der fünfte heißt Fuhrmann. Nicht nachgezogen:

| Nr | Fundstelle | Wortlaut |
|---|---|---|
| W-08 | `GDD.md:120` | „**6 neue Bäume**: Krieger, Jäger, Handwerker, Runenkundiger, Heiler, Transport & Logistik" |
| W-09 | `GDD.md:199` | „1: sechs Bäume (XML) · 2: Learning by Doing" |
| W-10 | `GDD.md:224` | MVP-Definition: „die sechs neuen Fertigkeitsbäume" |
| W-11 | `GDD.md:349`, `GDD.md:374` | D47 „Komplett neu, 6 Bäume", D19 „Eigener Baum ‚Transport & Logistik'" — beide ohne Verweis auf D66 |
| W-12 | `features/README.md:40` | „F-21 (sechs Bäume als XML-Gerüst …)" |
| W-13 | `specs/01-technischer-rahmen.md:34` | „700_50_Fortschritt/ # F-21 die sechs Fertigkeitsbäume" |
| W-14 | `F-13:37`, `F-14:31` | „Fertigkeitsbaum ‚Transport & Logistik'" |
| W-15 | Plan Z6 (`Plan:53`) | durchgestrichen und berichtigt — **in Ordnung** |

### 6.3 Aufgehobene oder überholte Aussagen, die noch stehen

| Nr | Seite A | Seite B (gilt) |
|---|---|---|
| W-16 | `F-06:16` „**Blockschaden reduziert**, Spielerschaden erhöht (D29, siehe F-18)"; `F-18:9` „weil die **Gegner angepasst** werden (D29)"; `features/README.md:41` „F-18 (Bau-Pfad + Gegner-Blockschaden)" | `GDD.md:314` D65: „der Blockschaden der Toten bleibt, wie Vanilla ihn setzt" |
| W-17 | `features/README.md:42` „F-08 (Licht, Brenndauer = erster Harmony-Patch)"; README-Tabelle F-08 „X+H" | `F-08:108` „C# / Harmony — **nicht nötig**" |
| W-18 | `F-07:36` „**Phase 3: eigene handgebaute Karte (D4)**" | `GDD.md:282` D4: „eigene Karte in Phase 4"; `GDD.md:219` |
| W-19 | `F-07:12` „Wüste und Ödland entfallen oder werden zu Heide/Brandland" | `F-07:23–24` Tabelle: Desert → Küste, Wasteland → Moor; D72 baut auf der Tabelle |
| W-20 | `GDD.md:383` D43 „**Kulturzonen als Biome**" | `F-07:49–57` Biomnamen sind im Code verdrahtet; „weicht vom Wortlaut von D43 ab und ist **noch nicht entschieden**" |
| W-21 | `GDD.md:348` D27 „**5 Tiers**"; `GDD.md:161–167` Tabelle mit T4 „Kettenhemd, Steinbau", T3 „Stahl (Damaszierung)" | `GDD.md:308` D61: „T4 wird die Qualitätsspitze"; `F-02:96` „T4 ist auch bei den Waffen eine Qualität"; `F-03:16` Kettenhemd ist T3 |
| W-22 | `GDD.md:165–167` Werkstätten „Gerberei", „Waffenschmied", „Meisterwerkstatt" | F-04 führt neun Werkstätten, keine der drei ist darunter (`F-04:16–26`) |
| W-23 | `F-05:17` „Lead, Brass → **Kupfer, Bronze-Altmetall**" | `glossar.md:74–75` `resourceScrapBrass` „Buntmetall", `resourceScrapLead` „**Blei**" |
| W-24 | `GDD.md:110` „Wanderhändler, Klostermarkt, Fürstenhof" | `GDD.md:381` D41 „**Feste Handelsposten**"; `F-10:12–17` ohne Wanderhändler, mit Marktflecken und Schmiedehof |
| W-25 | `GDD.md:108` „Feral/Radiated → Verderbte / Moorleichen (Stärkestufen)"; `glossar.md:61` Moorleichen = Radiated | `F-06:26` „Moorgeist / Moorleiche … Zombie-Variante mit Spawn **nur im Moor**" — eine Stufe gibt es in jedem Biom |
| W-26 | `GDD.md:123` „Bücher/Magazine → Abschriften als Grundfähigkeit" | D69 und D70: Bücher sind Abschriften, Magazine sind Lehrblätter — zwei Dinge (`F-21:268–270`) |
| W-27 | `GDD.md:126` „Bandits (falls in V 3.40 vorhanden)"; `F-20:26` „Erst prüfen (Q19)" | Kurzcheck: „Ja, mehr als erwartet" |
| W-28 | `F-04:22` Werkzeugslot „Destillierhelm" | `Denylist:338` „Destillation ist spaeter" |
| W-29 | `F-03:8` „Kleidung schützt vor Kälte und Nässe" | `F-03:25` „Slot-Vergünstigungen … tragen unsere Teile nicht"; kein Satz zur Kälte; D34 |
| W-30 | `glossar.md:127–130` `armorT1` = Lumpen … `armorT4` = Kettenzeug | D61 und `F-03:13–16`: Lumpen sind **T0**, Kettenzeug **T3**. Die Zählung ist um eins versetzt |
| W-31 | `F-12:34` Glossar-Beispiele „(Sceatta, Sax, Spatha, Gambeson …)"; `GDD.md:111` „Silber (Sceattas / Denare)" | `glossar.md:64` führt nur „Silberpfennig / Silver Penny"; Sceatta und Denar kommen im Glossar nicht vor |

### 6.4 Verweise und Form

| Nr | Fundstelle | Was |
|---|---|---|
| W-32 | `CLAUDE.md:8` „Entscheidungen D1–D50"; `Plan:2744` „Entscheidungen D1–D64" | Es sind D1–D91 |
| W-33 | `F-17:207` „Gehört zu D18"; `F-21:154` „(D45 ist tragfähig)" | D18 ist die Schnellreise, D45 das Team. Gemeint sind wohl D13 oder D14 und D47 |
| W-34 | `GDD.md:297–340` | Der Abschnitt heißt „7.3 Kampf & Waffen" und trägt D63 bis D91 (Bauen, Licht, Fertigkeiten, Sprache, Assets, UI). Zwei Leerzeilen (`:310`, `:313`) zerreißen die Tabelle. D91 hat vier Zellen statt fünf („Wirkt auf" fehlt) |

Dazu ohne eigene Nummer, alle niedrig: GDD-Kopf „Version 0.1, Stand 2026-11-07" bei Entscheidungen bis zum 22. November (`GDD.md:5–6`). F-00 Kopf „MVP", README „0". `F-00:14` und `specs/01:122–125` nennen `Mods/7DTD_700/` und `/mod/Config/` trotz D53. `F-16:12` trägt `[verifizieren]` an der Unity-Version, `specs/01:87` nennt sie „belegt". `F-01:23` nennt `tools/check-anachronisms`, das Werkzeug heißt `mod700check`. `F-15:20–21` „Keine … Teleportation" gegen die Wegsteine im selben Dokument (`:62`). Die Akzeptanzkästchen in F-01 bis F-05, F-18 und F-21 sind alle leer, obwohl der Plan Teile davon am Spiel belegt hat (`Plan:2462`, `Plan:2604`).

## 7. Dünne Features

„Dünn" heißt: danach könnte man nicht bauen, weil Kriterien, Zahlen, Phase oder eine Entscheidung fehlen. F-00, F-02, F-03, F-04, F-08, F-12, F-17, F-18 und F-21 tragen — dort stehen Messungen und Stände.

| Feature | Zeilen | Kriterien | Was fehlt | Schwere |
|---|---|---|---|---|
| **F-09 Seuchennacht** | 29 | 2 | Deutung in der Welt (B-17). Größe und Staffelung der Wellen. Was Phase 1 hat (Vanillas Blutmond mit neuen Texten, roter Himmel) steht nicht da. Verhältnis zu Vanillas Optionen (Häufigkeit, Spanne, Warnung). Vorboten sind C#, der Befund dazu fehlt. | hoch |
| **F-11 Krankheit** | 36 | 1 | Q10 offen. „Ruhr" ist als neu geführt, Vanilla hat sie schon (`buffDysentery*`). Keine Zahl zu Ansteckung, Verlauf, Heilrate. „Nur mit T2-Wissen heilbar" trifft auf eine Infektion, die in Vanilla ab dem ersten Tag droht — der frühe Spieler stürbe daran. Kräuterliste ohne Kennungen. | hoch |
| **F-06 Seuchentote** | 45 | 2 | Zuordnungstabelle (B-07), Namen der vier Stufen, Tiere (B-23), Spawn-Mix, Zahl zu „mehr Gefahr". Kopf Phase 2, Text „MVP". | hoch |
| **F-19 Nahrung** | 38 | 3 | Für eine ältere Fassung geschrieben: kennt Vanillas Hühnerstall und Bienenstock nicht. „Fisch" ohne Angelsystem. Verderb ist C# mit offener REA-Frage. Mühle, Brot, Brauen je ein Wort. Wasser fehlt ganz (B-02). | hoch |
| **F-10 Händler** | 44 | 3 | Zuordnung der fünf Vanilla-Händler, Stimmen, Namen, Dialoge (B-10). Auftragsarten „Befallen", „Vergraben", „Schatzkarte" ohne Deutung. Stufen 1–6 und Händlerkette unerwähnt. `docs/lore.md` gibt es nicht. | hoch |
| **F-07 Welt** | 58 | 2 | Bedarfsrechnung (B-08). D43 offen. Schnee als „Mittelgebirge/Heide": was aus der Schneedecke wird, steht nicht da. Flusstal-Nebel ohne Ort. Fertige Karten. Automaten, Autos, Straßen als Blöcke. | hoch |
| **F-20 Kult und Plünderer** | 33 | 3 | Q19 ist beantwortet und nicht eingearbeitet. Keine Zahl zu Gruppen, Beute, Stufe. Abgrenzung Kultist gegen Mönch (B-18). | mittel |
| **F-14 Siedlung** | 36 | 3 | Gesellen: REA offen. Siedlungsrang „optional". Was Koop in Phase 1 und 2 ist (Vanillas Gruppe), steht nicht da. | mittel |
| **F-13 Transport** | 86 | 4 | Reitpferd und Packtier nach Q18 ohne Weg (B-25). „Zielwert festlegen" im ersten Kriterium. Die Bedingung „Seuchennacht läuft" für die Wegstein-Sperre ist unbelegt (`F-13:75`). | mittel |
| **F-15 Volksmagie** | 122 | 4 | Trägt im Kern. Offen: Attribut (B-09), Odem-Kosten per XML (`[verifizieren]`), Amulett-Slot, Bannkreis ohne Meide-KI, kein Kriterium für Segen, Tränke und Runen. Amulette und Reliquien stehen in GDD 2.3 und haben nirgends eine Mechanik. | mittel |
| **F-05 Rohstoffe** | 38 | 3 | Bernstein und Salz ohne Kennung und Phase. Kohlenerz (B-26). Beute (B-29). Glasgefäß. „Zielwert im Balancing" für Eisen. Widerspruch zum Glossar (W-23). | mittel |
| **F-01 Purge** | 42 | 3 | Der Umfang kennt nur Gegenstände. Auftragsarten, Herausforderungen, Flugzeug, Musik, Ereignisse und Optionen fallen durch (B-04, B-11, B-12, B-22, B-30). | mittel |
| **F-16 Assets** | 66 | 3 | Zwei Fragen vor dem ersten Stück offen (Meshy-Lizenz, was „Retextur" heißen darf). Musik fehlt in der Klangspur. | niedrig |
| **F-18, eine Zeile** | – | – | `F-18:72` „Dachformen: Reet, Schindeln, Grassoden" — ein Stichpunkt ohne Träger, Phase und Kriterium. `F-18:155` „Gamestage X" ohne Zahl. | niedrig |

## 8. Kernfragen, die niemand beantwortet hat

| Frage | Stand in den Dokumenten | Vorschlag |
|---|---|---|
| Was ist das Ziel, was das Endspiel? | nur „lange Schleife" (`GDD.md:155`) | D106 |
| Was geschieht in der Welt, wenn der Spieler stirbt? | nur Ausschluss in D15 | D105 |
| Was ist die Seuchennacht für die Menschen im Land? | nicht beschrieben | D107 |
| Wie geht die Mod mit Kirche und alten Göttern um? | zwei Sätze in F-15 und F-20 | D108 |
| Gibt es Frauen im Land? | praktisch nicht | D109 |
| Wie sprechen und heißen die Händler? | „nicht entschieden" | D102 |
| Wie schwer ist das Spiel? | kein Wort | D112 |
| Welche Regeln gelten im Koop vor Phase 3, und gibt es PvP? | F-14 erst Phase 3; PvP unerwähnt | D113 |
| Was darf in Phase 1 modern bleiben? | nur POIs benannt | D93 |
| Woher kommt Wasser? | nicht geplant | D98 |

## 9. Vorschlag für neue Entscheidungen

Fertige Zeilen im Format der GDD-Tabelle. **Keine davon ist entschieden.** Jede wartet auf den Nutzer (Projektregel 4). Wo eine Zeile eine spätere Phase betrifft, schlägt sie nur die Planung vor, nicht den Bau (D50). Was an einer Empfehlung auf einer Annahme steht, ist dort genannt.

| ID | Datum | Frage | Empfehlung |
|---|---|---|---|
| D93 | 2026-11-22 | Die MVP-Definition verlangt „ohne Anachronismus in … Texten" und „Gegner … mit neuen Namen". Der Plan lässt Händler, Wesen-Namen, Aufträge und die Welt wissentlich modern. Was darf in Phase 1 modern bleiben? | **[zu prüfen]** Die MVP-Definition nennt eine geschlossene Liste getragener Lücken: POIs und Welt, Aussehen und Namen der Gegner, Händler (Namen, Stimmen, Dialoge, Höfe), Musik, Ladebilder, Spielerfigur, Twitch-Fenster. Alles andere bleibt Pflicht. Z2 wird daran gemessen. |
| D94 | 2026-11-22 | Vanilla führt Gefahren je Biom und einen Biom-Fortschritt mit Abzeichen. Alle vier Gegenmittel sind gesperrt. D34 („wie Vanilla") wurde unter der V2.x-Annahme getroffen. An oder aus, und als was? | **[zu prüfen]** Phase 1: Biom-Fortschritt aus, wenn die Option `goBiomeProgression` das leistet (Wirkung ungemessen — erst messen). Phase 2 mit F-07 und F-11 planen: je Kulturzone eine Gefahr der Zeit (Rauch im Brandland, Kälte im Hochland, fauler Dunst im Moor), Abzeichen als Schutzamulett. D34 bekommt den Zusatz „ohne Biom-Gefahren". |
| D95 | 2026-11-22 | Das Versorgungsflugzeug (`supplyPlane`) fliegt unverändert; nur der Kisteninhalt ist bereinigt. | **[zu prüfen]** Der Luftabwurf entfällt. Phase 1: in der empfohlenen Voreinstellung aus (`goAirDropFrequency`). Ob er sich per XML ganz stilllegen lässt, ist ungemessen. Notiz für später: eine Deutung ohne Himmel wird gesucht, bevor er gesperrt bleibt (Grundsatz aus D87). |
| D96 | 2026-11-22 | Karte, Kompass, Wegpunkte und Bildschirmmarken: bleiben sie, und wie heißen sie? | **[zu prüfen]** Sie bleiben in Phase 1 als Bedienhilfe (P5). Das Wort „Kompass" fällt aus unseren Texten. Ob die Stufe „voll" des Grusel-Reglers (D13) Karte oder Marken abschaltet, wird in Phase 2 mit F-17 geplant; Vanilla hat die Schalter dafür. |
| D97 | 2026-11-22 | Stürme kommen in keinem Dokument vor. Vanilla hat sie in jedem Biom mit eigener Buff-Kette. | **[zu prüfen]** Stürme bleiben als Unwetter; Wetter ist zeitlos. Ihre Texte gehen in die nächste Scheibe von WP8.5. Der Sturm im Moor (Vanilla: Ödland) wird mit D94 gedeutet. |
| D98 | 2026-11-22 | Der Tausammler ist gesperrt, und ein leeres Gefäß lässt sich in Vanilla nicht am Gewässer füllen. Woher kommt Wasser? | **[zu prüfen]** Der Tausammler wird zur **Regentonne** umgedeutet statt gesperrt (Grundsatz aus D87); Fässer aus Dauben sind um 700 plausibel. Seine drei Bauteile bekommen zeitgemäße Zutaten wie in D89. Das Glasgefäß wird zum Tonkrug umbenannt. Vorher messen, ob das Rezept des Sammlers ohne gesperrte Teile geht. |
| D99 | 2026-11-22 | Eine Infektion hat in Phase 1 nur Honig. F-11 liegt in Phase 2. | **[zu prüfen]** `drugHerbalAntibiotics` bleibt erreichbar und heißt „Kräutersud" — derselbe Weg wie D56, keine Vorwegnahme von F-11. Ob sein Rezept nach dem Purge geht, ist ungemessen. Theriak bleibt Phase 2. |
| D100 | 2026-11-22 | Vanilla hat vier Stärkestufen, das GDD nennt zwei, und „Moorleiche" ist zugleich Stufe und Sagengestalt. Zwei Sondergegner tragen Sprengsatz. | **[zu prüfen]** „Moorleiche" ist nur noch die Sagengestalt im Moor. Die vier Stufen bekommen vier eigene Namen; Vorschlag: Verderbte, Schwärende, Glutäugige, Verdammte. Polizist und Demolisher behalten ihre Mechanik (P5) und werden als Fäulnis gedeutet, die platzt; kein Knall, kein Pulver. Die englischen Namen entscheidet der Nutzer mit. |
| D101 | 2026-11-22 | F-06 verspricht „jeder Vanilla-Zombie bekommt eine 700-Entsprechung", hat aber keine Tabelle; zehn Tiere und Wesen fehlen. | **[zu prüfen]** Vor Phase 2 trägt F-06 eine vollständige Tabelle: 31 Familien, alle Tiere. Vorschlag für die Tiere: Berglöwe → Luchs, Kojote → verwilderter Hund, Schlange → Kreuzotter, Direwolf → Altwolf, Geier bleibt Geier, Schwärme bleiben. Der Boss-Eber ist eine Entscheidung für D11 (wenige Sagengestalten). |
| D102 | 2026-11-22 | Fünf Vanilla-Händler, vier Posten, „Wanderhändler" im GDD, 1336 gesprochene Zeilen in modernem Englisch. | **[zu prüfen]** F-10 ordnet die fünf Händler den Posten zu; der „Wanderhändler" fällt aus GDD 2.3 (D41 gilt). Die Stimmen werden stumm geschaltet, sobald belegt ist, dass das ohne Fehler geht; gesprochen wird in Untertiteln. Sprache: schlichtes heutiges Deutsch und Englisch ohne Altertümelei. Namen nach Vertrag 02 §6. |
| D103 | 2026-11-22 | Die Händler bieten in Phase 1 Stromaufträge an. | **[zu prüfen]** Die Stromaufträge kommen aus den Händlerlisten (eine Purge-Regel für Auftragsarten, Vertrag 04 erweitern). Ihre Umdeutung als „Brunnen wiederherstellen" bleibt Phase 2 (F-10). |
| D104 | 2026-11-22 | 35 von 148 sichtbaren Herausforderungen sind unerfüllbar. | **[zu prüfen]** Ein Ziel mit lebendem Gegenstück wird ersetzt, ein Ziel ohne wird verborgen; die Biom-Reihen folgen D94. Vorher messen, was das Spiel mit einer Gruppe unter zehn macht. `mod700check` prüft die Ziele künftig als Verweise. |
| D105 | 2026-11-22 | Was ist der Tod des Spielers in der Welt? D15 schließt nur das Aufstehen als Seuchentoter aus. | **[zu prüfen]** Der Spieler stirbt nicht, er wird für tot liegen gelassen und kommt an seiner Schlafstatt zu sich — so, wie die Startnotiz ihn schon findet. Vanillas Schwächung nach dem Tod heißt entsprechend. Rucksack und Todesstrafe bleiben Vanilla-Optionen. Q17 baut darauf auf. |
| D106 | 2026-11-22 | Das Spiel hat kein benanntes Ziel und kein Endspiel. | **[zu prüfen]** Kein Sieg. Drei Ziele auf dem Papier: eine Siedlung, die die schwerste Seuchennacht hält; die Lore-Kette bis zu ihrem offenen Ende; die Artefakte der Hochmagie. Danach steigt der Seuchendruck (F-17 B5) weiter. Das GDD bekommt dafür einen Absatz in Abschnitt 3. |
| D107 | 2026-11-22 | Was erzählen sich die Menschen über die Seuchennacht? | **[zu prüfen]** Die Ursache bleibt offen (GDD 2.1). Fest steht nur die Erscheinung: in jeder siebten Nacht gehen die Toten um und finden die Lebenden. Drei Deutungen stehen nebeneinander in Notizen und Händlerrede, keine wird bestätigt. F-09 bekommt dazu einen Abschnitt und sagt, was Phase 1 davon hat. |
| D108 | 2026-11-22 | Wie geht die Mod mit realer Religion um? Die Leitplanke steht nur in F-15 und F-20. | **[zu prüfen]** Ins GDD, Abschnitt 2: Glaube ist Teil der Welt und wird nicht gewertet. Keine realen Heiligen, Orden, Gebetstexte oder Götternamen; „der Herr", „die alten Götter" und erfundene Ortsheilige genügen. Segen und Runen wirken gleich stark. Der Seuchenkult ist weder Kirche noch Heidentum und sieht nicht aus wie ein Mönch. |
| D109 | 2026-11-22 | Die Welt der Dokumente ist männlich. | **[zu prüfen]** Frauen und Männer kommen in allen Rollen vor: unter den Seuchentoten, den Händlern (eine Äbtissin ist um 700 plausibel), den Plünderern. Rang- und Baumnamen werden auf eine Form geprüft, die für beide Spielerfiguren stimmt. Die „Hexe" ist kein Feindbild. |
| D110 | 2026-11-22 | Navezgane und Vanillas fertige Karten bleiben wählbar und sind ganz modern. Die Zufallswelt der Phase 2 ist nicht durchgerechnet. | **[zu prüfen]** Fertige Vanilla-Karten werden nicht unterstützt; das steht in der Beschreibung der Mod. F-07 bekommt vor Phase 2 eine Bedarfsrechnung: POIs je Auftragsstufe, Plätze für Handelsposten, Ersatz für Ortschaften. |
| D111 | 2026-11-22 | F-15 hängt den Runenkundigen an den Intellekt-Baum; D66 hat ihn dem Heiler gegeben. | **[zu prüfen]** Der Runenkundige bekommt in Phase 2 ein sechstes, eigenes Attribut. F-15 wird berichtigt; D47 und D19 bekommen den Verweis auf D66. |
| D112 | 2026-11-22 | „Mehr Gefahr für Spieler" (D29, zweite Hälfte) hat keine Zahl und keinen Besitzer. Schwierigkeit kommt in keinem Dokument vor. | **[zu prüfen]** Die Mod liefert eine **empfohlene Voreinstellung „700"** als Dokument: Luftabwurf aus, Biom-Fortschritt aus, die übrigen Optionen mit Begründung. Ob sie sich als Sandbox-Vorlage ausliefern lässt, wird gemessen. D29s zweite Hälfte wird in WP9 an dieser Voreinstellung entschieden, nicht an Gegnerwerten. |
| D113 | 2026-11-22 | Das GDD nennt „Singleplayer, Dedicated Server". Gespielt wurde beim Nutzer als Host. PvP ist unerwähnt. | **[zu prüfen]** Spielarten: Einzelspiel, vom Spieler gehostet, Dedicated. Kriterien mit „Dedicated + 2 Clients" gelten bis zur Installation eines Servers als „Host + 1 Mitspieler" erfüllt und sind so markiert. PvP ist kein Ziel und nicht gesperrt. |
| D114 | 2026-11-22 | Vanillas dynamische Musik ist modern und kommt in keinem Dokument vor. | **[zu prüfen]** Phase 1: getragene Lücke (D93); die Voreinstellung empfiehlt, sie abzuschalten. Phase 2: F-16 nimmt Musik in die Klangspur auf (eigene Stücke oder CC0, wie D84). |
| D115 | 2026-11-22 | Pechtopf, Schwingbalken-Falle und „Fluchtopf" gehören zu keinem Feature. | **[zu prüfen]** F-15 bekommt einen Abschnitt „Fallen mit Auslöser" für Phase 2 und nimmt Pechtopf und Schwingbalken auf. „Fluchtopf" wird dort als Wurf-Fluch geführt oder aus GDD 2.3 gestrichen. |
| D116 | 2026-11-22 | Wegsteine stehen in Phase 3 (GDD, F-13) und in Phase 4 (F-15). Das Reitpferd ist nach Q18 nicht per XML möglich. | **[zu prüfen]** Wegsteine: Phase 3 (laut Kurz-Check reines XML). Reitpferd und Packtier: Phase 4, als eigene Asset-Aufgabe und vor Beginn neu bewertet. Phase 3 behält Karren und Wagen. D16 bekommt den Verweis. |
| D117 | 2026-11-22 | Kohlenerz liegt im Boden und gibt „Holzkohle". | **[zu prüfen]** Das Erz wird zum **Torflager** umgedeutet; Torf als Brennstoff ist für Nordwesteuropa seit der Antike plausibel. Offen und zu messen: ob der Abbau ohne neuen Gegenstand einen eigenen Namen tragen kann. |
| D118 | 2026-11-22 | Das Grauen steigt durch „allein sein". Im Einzelspiel ist der Spieler immer allein. | **[zu prüfen]** Im Einzelspiel zählt „allein" nicht. F-17 B3 bekommt den Satz. |
| D119 | 2026-11-22 | Nur Phase 1 hat eine Definition von „fertig". Phase 2 trägt elf Features. | **[zu prüfen]** Jede Phase bekommt im GDD drei bis fünf prüfbare Sätze. Phase 2 wird vor ihrem Beginn in zwei Abschnitte geteilt (erst Assets, Welt und Gegner; dann Magie, Furcht und die ersten Patches). |
| D120 | 2026-11-22 | Abschnitt 8 führt zwei beantwortete Fragen und verschweigt mindestens 14 offene. | **[zu prüfen]** Abschnitt 8 ist die einzige Liste offener Fragen. Jede Stelle „nicht entschieden" in einem Feature oder im Plan bekommt eine Q-Zeile mit dem, was sie blockiert. Q18 und Q19 werden als beantwortet durchgestrichen. Zugleich: Abschnitt 7.3 wird geteilt, die zerrissene Tabelle geflickt, D91 um „Wirkt auf" ergänzt. |
| D121 | 2026-11-22 | Was liegt in einer Truhe? Beute und Beutestufe plant kein Dokument. | **[zu prüfen]** Vanillas Beutestufe bleibt (P5). F-05 bekommt einen Abschnitt „Beute in 700" mit dem, was Hof, Kloster und Ruine hergeben; gefüllt wird er mit F-07 in Phase 2. |
| D122 | 2026-11-22 | Twitch, Saison-Ereignisse, Kosmetik, Verkaufsautomaten, Farbe, Tresore, Dietriche und Schilder sind nur in der Denylist oder gar nicht entschieden. | **[zu prüfen]** Eine Sammelzeile: Twitch und Saison-Ereignisse werden nicht unterstützt. Farbe bleibt gesperrt. Dietrich, Truhen und Schilder bleiben. Tresore und Automaten gehören zu F-07. Ob DLC-Besitzer gesperrte Garnituren anlegen können, wird einmal im Spiel geprüft. |

Drei weitere Vorschläge betreffen Namen und Stufen einzelner Dinge. Sie stehen getrennt, weil ein Name immer eine Entscheidung des Nutzers ist (Glossar Regel 4):

| ID | Datum | Frage | Empfehlung |
|---|---|---|---|
| D123 | 2026-11-22 | Elf unserer Begriffe sind später als 700 belegt (Abschnitt 5). Welche Regel gilt, und welche Namen ändern sich? | **[zu prüfen]** Regel: Ist die Sache um 700 plausibel, bleibt sie; der Name wechselt, wenn es ein zeitnäheres Wort gibt, das ebenso verständlich ist. Vorschläge: Tiegelstahl → Schmiedestahl (wie D55 es nannte), Streithammer → Eisenschlägel, Streitkolben → Eisenkeule, Motte → Wallburg, Geselle → Knecht, Destillierhelm → Sudkessel, Weberschiffchen → Webschwert, Tee → Sud, Hexenbesen → Zaunstecken, Kraftlinien → Bannschnur, Damast und „Pattern-welded" → wurmbunte Klinge. Gambeson, Fachwerk und Breitaxt bleiben, wenn der Nutzer nicht anders will. Die Heidelbeere wird freigegeben. |
| D124 | 2026-11-22 | Der Feuertopfpfeil explodiert (Vanillas Wirkung) und beruft sich auf griechisches Feuer. | **[zu prüfen]** Er brennt, statt zu explodieren (WP9), und sein Text nennt Pech statt griechischen Feuers. Das hält P1 („kein Schießpulver") und D10. |
| D125 | 2026-11-22 | D8 will die Armbrust „selten, T4/Endgame". Gemessen schaltet Vanilla sie bei Bogenbau 21 frei, den Langbogen bei 36. | **[zu prüfen]** D8 gilt für die zweite, große Armbrust. Die einfache Armbrust wird als Jagdwaffe der Mitte getragen — oder die Freischaltstufen von Armbrust und Langbogen werden getauscht, wie D88 es bei den Äxten tat. Der Nutzer wählt. |

**Zählung:** 33 Zeilen, D93 bis D125.
