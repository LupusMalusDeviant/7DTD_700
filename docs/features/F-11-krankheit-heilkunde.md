# F-11 — Krankheit & Heilkunde

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| P2 | X (+H) | S | optional |

## Ziel
Krankheit ist im Jahr 700 der eigentliche Feind. Die Vanilla-Infektion wird zur
**Seuche**; Heilung kommt aus Kräuterkunde, nicht aus Antibiotika.

## Umfang
- Infektion → „Seuchenbrand“ (Buff-Kette umbenennen und umbalancieren)
- Heilmittel: Schafgarbe/Wundkraut-Auflage, Honig-Wundsalbe, Weidenrinden-Sud (Schmerz), Theriak (selten, gegen Seuche)
- Kräuter als Erntepflanzen (Vanilla-Farming-Blöcke umgedeutet)
- **Mehr Krankheiten** (D35):

  | Krankheit | Ursache | Verlauf | Heilung |
  |---|---|---|---|
  | **Seuchenbrand** | Treffer von Seuchentoten (Vanilla-Infektion) | stufenweise, tödlich unbehandelt | Theriak, Seuchenkunde (Heiler) |
  | **Ruhr** | schmutziges Wasser, verdorbene Nahrung (F-19) | Durst, Schwäche | Abkochen vorbeugend; Eichenrinden-Sud |
  | **Fieber** | Nässe bzw. Kälte (Vanilla-Temperatur), Wunden | Ausdauer- und Zielmalus | Weidenrinde, Bettruhe |
  | **Wundbrand** | unbehandelte Blutung bzw. tiefe Wunde | Gesundheitsverlust, fortschreitend | Wundarzt-Perk, Ausbrennen, Honigsalbe |

- Vanilla-Verletzungen (Brüche, Blutung, Gehirnerschütterung) bleiben mit Mittelalter-Heilmitteln
- Unverbrannte Leichen nach der Seuchennacht (F-09) erhöhen Ruhr- und Seuchenbrand-Risiko in der Siedlung

## Umsetzung
Weitgehend XML (`buffs.xml`, `items.xml`, `blocks.xml`). C# nur, falls Ansteckung
zwischen Spielern gewünscht ist (Q10).

Volksmagie (D9, F-15): Magische Tränke und Segen können Symptome lindern und den Verlauf
des Seuchenbrands verlangsamen, aber **nie heilen**. Heilung bleibt Heilkunde (Theriak,
T2-Wissen). So bleibt die Seuche die eigentliche Bedrohung.

## Ausarbeitung Phase 2 (Plan-0002 WP13.1, 2026-11-23, D196, zu prüfen N-140)

Grundlage: Vanillas `buffs.xml` und `items.xml` des Builds V 3.40 b10, im autonomen Lauf gelesen; nichts
davon ist im Spiel gesehen. **Zahlen, die Vanilla setzt, stehen mit „V"**, unsere Setzungen mit „S".

### 1. Was Vanilla schon hat (gemessen)

| Kette | Zähler | Verlauf | Heilung |
|---|---|---|---|
| **Infektion** (`buffInfectionMain`) | `infectionCounter`, Höchstwert `$infectionMaxDuration` = **25 200** (V); ein Treffer setzt 25, jeder weitere Treffer +250 (V, `buffInfectionCatch`) | wächst je Sekunde um `_InfectionRate` (vom Spiel gesetzt, hängt an der Weltoption), sinkt um ein Viertel der natürlichen Heilrate; **Stufe 2 ab 14 %, Stufe 3 ab 57 %** (V), bei 100 % Tod (`buffInfection04`) | ein Mittel setzt `$buffInfectionAddCurePerc` (Anteil am Höchstwert) → `$infectionCureCounter`; solange er > 0 ist, wirkt `_InfectionCureRate` je Sekunde, der Heilzähler sinkt um 2 je Sekunde |
| **Ruhr** (`buffDysenteryMain`) | `$dysenteryCounter`, Höchstwert **3 600** (V); verdorbenes Essen oder schmutziges Wasser +1 080 (V) | −1 je Sekunde, mit Mittel −2 (V): unbehandelt **18 min** je Ansteckung; Durchfall-Anfälle in Abständen | `$buffDysenteryAddCurePerc` |
| Verletzungen | Blutung, Platzwunde, Abschürfung, Verstauchung, Gehirnerschütterung | — | bleiben (D56) |
| Kälte, Nässe | `buffElementCold`, `buffElementFreezing`, `buffElementWet` | — | Wärme |

**Heilmittel in Vanilla** (Anteil am Höchstwert, V) und ihr Stand bei uns:

| Mittel | Seuchenbrand | Ruhr | bei uns |
|---|---|---|---|
| `foodHoney` (Honig) | 5 % | — | frei (Phase 1) |
| `drinkJarHoneyTea` | 5 % | 20 % | frei |
| `drinkJarGoldenRodTea` (Goldrute) | — | 20 % | frei |
| `drugHerbalAntibiotics` → **Kräutersud** | **10 %** | — | frei, Wundversorgung Stufe 2 |
| `drugAntibiotics` | 25 % | — | **gesperrt** (Purge) |
| `drinkJarPureMineralWater`, `foodHoneyGlazedSham`, `foodHoneyBrisket` | | | gesperrt |

**Befund:** ein Kräutersud kauft 10 % von 25 200 = 2 520 Heilzähler, also 1 260 s Wirkung. Ob das
eine Stufe-3-Infektion noch zurückholt, hängt an `_InfectionCureRate` — **ungemessen** (Motorwert,
`_`-Name). Die 0003-Sorge „der frühe Spieler stürbe" ist damit nicht gelöst, nur benannt.

### 2. Seuchenbrand — die Vanilla-Infektion, umbenannt und mit einer Leiter

Die Kette **bleibt** Vanillas (keine eigene Rechnung, P5). Was sich ändert (S):

| Stufe | Name | ab | Wirkung (V) | was hilft |
|---|---|---|---|---|
| 1 | **Schwärende Wunde** (Name seit WP13.1; vorher stand im Spiel noch Vanillas „Leichte Infektion" — nur die Beschreibungen waren seit Phase 1 umgeschrieben) | Treffer | — | Honig, Honigtrank, Kräutersud |
| 2 | **Seuchenbrand** | 14 % | Ausdauer −25 % | Kräutersud; Honig hält nur noch auf |
| 3 | **Seuchenfieber** | 57 % | Ausdauer −35 %, alle Attribute −1 | **Theriak**; Kräutersud verzögert |

**Neu: Theriak** (`itm700_theriak`, S): 25 % — der Platz, den Vanillas gesperrtes Antibiotikum frei
gemacht hat. Rezept am Kochtopf: Honig 2, Kräutersud 2, Goldrute 2. Gebunden an **Wundversorgung 30** (Vanillas Anzeigezeile 20/30/40, die zweite Stufe:
„T2-Wissen", D35). So heilt der frühe Spieler Stufe 1 und 2 mit dem, was er hat, und Stufe 3 braucht
Wissen — das löst „nur mit T2-Wissen heilbar" auf, ohne den ersten Tag tödlich zu machen.
*Geschichte:* Theriak ist Galens Mittel und im Frühmittelalter in Klöstern bekannt, im Norden selten —
passt als seltenes, teures Gut (auch beim Händler, F-08).

### 3. Ruhr — Vanillas Dysenterie, wie sie ist

Umbenannt (Texte), Zahlen bleiben (V). Vorbeugen: abgekochtes Wasser (gibt es). Heilen: **Goldrutentee**
und Honigtrank (V). Der **Eichenrinden-Sud** aus dem Umfang oben **entfällt** (S): ein zweites Mittel
mit derselben Wirkung brächte nichts als einen neuen Gegenstand.

### 4. Fieber — neu, aus Kälte und Nässe

Vanilla hat keine Erkältung. **Bau per XML (S):** ein verborgener Zähler-Buff am Spieler (über
`buffStatusCheck01`, wie Odem und Lernen) zählt `cv700_fieberZaehler` je 10 s **+1**, solange
`buffElementFreezing` **oder** (`buffElementCold` **und** `buffElementWet`) anliegt, und **−1** am Feuer
(`buff700_amfeuer`) oder sonst −1 je 30 s. Ab **30** (also 5 min durchnässt in der Kälte) kommt
`buff700_fieber`: Ausdauer-Erholung −20 %, Lauftempo −10 %, ein Schüttelfrost-Laut. Unter **10**
geht es. **Heilen:** ~~`itm700_weidenrindensud`~~ **`itm700_eichenrindensud`** (Rinde und abgekochtes Wasser, Kochtopf) setzt den
Zähler auf 0. ~~Die **Weidenrinde** (`itm700_weidenrinde`) fällt beim Fällen von Laubbäumen mit 10 %
(S; welche Baum-Blöcke, liest WP13.3).~~ *Geändert beim Bau (WP13.3, D197):* Vanilla hat **keine Weide**
— nur Eichen sind Laubbäume mit Holz. Die **Eichenrinde** (`itm700_eichenrinde`) war bis zur
Chinarinde das Fiebermittel des Volkes („Fieberrinde"); sie fällt beim Fällen jeder Eiche mit 25 %,
1–2 Stück.
*Brücke zu WP13.6:* Unterkleidung und Futter senken die Kälte und damit das Fieber.

### 5. Wundbrand — neu, aus unbehandelter Blutung

**Bau per XML (S):** solange `buffInjuryBleeding` oder `buffLaceration` anliegt, zählt
`cv700_wundbrandZaehler` je 10 s +1. Ab **18** (3 min unbehandelt) kommt `buff700_wundbrand`: −1 Leben
je 10 s, wachsend um 1 je weitere Minute, höchstens −5. **Heilen:** `itm700_honigsalbe` (Honig 1,
Tierfett 1) oder der **Salbenverband** (`medicalFirstAidBandage`, gibt es) setzt den Zähler auf 0 und
nimmt den Buff. *Ausbrennen* (Fackel an die Wunde) **entfällt** in Phase 2 (S): XML kennt kein „mit
der Fackel auf sich selbst" — Notiz Phase 3.

### 6. Volksmagie lindert, heilt nie (D9)

Kein Gegenstand aus `700_75_Magie` setzt `$buffInfectionAddCurePerc`, `$buffDysenteryAddCurePerc` oder
die neuen Zähler auf 0. Lindern darf er (Wolfsbalsam: Leben über Zeit). **Vorschlag (S):** diese Regel
wird beim Bau eine Prüfung in `kette-pruefen` — dann kann sie nicht still brechen.

### 7. Was nicht kommt

- **Ansteckung zwischen Spielern (Q10):** nein in Phase 2 — braucht C# (Nähe, Netz); Notiz Phase 3.
- **Leichen erhöhen das Risiko** (Umfang oben, F-09): XML sieht keine Leichen in der Siedlung;
  Notiz Phase 3 (mit dem Direktor, WP11.6).

### 8. Neue Kennungen (für WP13.3 — gebaut, siehe §9)

| Kennung | Deutsch | Englisch | Art |
|---|---|---|---|
| `itm700_theriak` | Theriak | Theriac | Mittel, gebunden Wundversorgung 30 |
| ~~`itm700_weidenrinde`~~ `itm700_eichenrinde` | Eichenrinde | Oak Bark | Rohstoff (D197) |
| ~~`itm700_weidenrindensud`~~ `itm700_eichenrindensud` | Eichenrinden-Sud | Oak-bark Brew | Mittel (D197) |
| `itm700_honigsalbe` | Honigsalbe | Honey salve | Mittel |
| `buff700_fieber` | Fieber | Fever | Zustand |
| `buff700_wundbrand` | Wundbrand | Wound-rot | Zustand |
| `cv700_fieberZaehler`, `cv700_wundbrandZaehler` | — | — | gespeicherte Zähler (Vertrag 07, Nachtrag mit WP13.3) |

**[verifizieren beim Bau, WP13.3]:** `_InfectionCureRate` (wie schnell heilt ein Mittel wirklich), ob
`buffElementWet` neben `buffElementCold` gleichzeitig anliegen kann, welche Baum-Blöcke Laubbäume sind,
ob `buffLaceration` ohne Behandlung bleibt.

### 9. Gebaut (WP13.3, 2026-11-23, D197, zu prüfen N-141)

Neues Modlet **`700_45_Leben`** (das zwölfte, Vertrag 01 Teil 2 A): `items.xml` (Theriak, Eichenrinde,
Eichenrinden-Sud, Honigsalbe; der Salbenverband hilft zusätzlich gegen Wundbrand), `recipes.xml`,
`blocks.xml` (Eichenrinde an sieben Eichen), `buffs.xml` (`buff700_krankZaehlen`, `buff700_fieber`,
`buff700_wundbrand`). Theriak gebunden in `700_50_Fortschritt` (Wundversorgung 30, im Fenster neben dem
Kräutersud). **Warum nicht C#?** Alles sind Zustände und Zähler an Vanillas Buffs (Kälte, Nässe,
Blutung, Feuer) — XML trägt es ganz.

**Texte nachgezogen:** die Beschreibungen der drei Stufen nennen jetzt die Leiter (Stufe 1 Honig oder
Kräutersud, Stufe 2 Kräutersud, Stufe 3 nur Theriak). Ob die Zahlen tragen, zeigt S-52.

## Akzeptanzkriterien
- [ ] Seuchenbrand ist heilbar, aber nur mit T2-Wissen (Abschrift Heilkunde) — *nach der Ausarbeitung
  (D196): Stufe 1 und 2 heilt der frühe Spieler mit Honig und Kräutersud, Stufe 3 (Seuchenfieber)
  braucht Theriak und damit Wundversorgung 30*
