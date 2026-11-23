# test/ — die Test-Überlagerung

Hier liegt, was **nur zum Testen** neben die Mod gelegt wird und **nie im Paket** landet. Regeln:
[Vertrag 01, „Nachtrag Phase 2, Teil 1", Abschnitt B](../docs/contracts/01-modlet-grenzen.md).

| Ordner | Tut |
|---|---|
| `700_99_Test/` | verkürzt Uhren: die acht Lichtquellen aus F-08 brennen `GrowthRate` 2 statt 15 bis 60; seit WP9.10 dazu **11 Proben** (8 Buffs, 3 Gegenstände) für S-32 bis S-35, seit WP10.6 **12** (dazu `t700_odemVoll` für S-38 bis S-41), seit WP11.3 **14** (dazu `t700_grauen90`, `t700_grauenZeigen` für S-43) |

## Benutzen

```powershell
tools\build\build.ps1 -Install -MitTest
```

legt die Mod **und** die Überlagerung in den Spielordner.

```powershell
tools\build\build.ps1 -Install
```

legt die Mod hinein und **entfernt** die Überlagerung wieder.

`tools\build\smoke.ps1` meldet eine liegengebliebene Überlagerung als eigenen roten Punkt;
`smoke.ps1 -MitTest` erwartet sie.

## Der Fackel-Test (S-06), rund fünf Minuten

1. Mit `-MitTest` installieren, Test-Spielstand laden.
2. In einem **geschlossenen** Raum je eine Wandfackel, Unschlittkerze (Wand und Tisch), Öllampe und
   ein Holzfeuer setzen, Uhrzeit merken.
3. Warten, bis sie ausgehen — erwartet nach rund zwei Minuten. Die gemessene Zeit notieren: aus ihr
   folgt, wie lange die echten Werte (15, 30, 45, 60) brennen.
4. Ansehen: steht statt der Fackel der leere Halter, statt der Kerze der Stumpf, statt der Lampe die
   leere Lampe, statt des Feuers die kalte Glut? Verschwindet nichts?
5. Kerzenstumpf: Name, Aufnehmen mit E, Abschlagen (N-03).
6. Danach ohne `-MitTest` neu installieren.

## Proben (seit Nachtrag Teil 1d, 2026-11-23)

Neben `<set>` darf die Überlagerung **Proben** anhängen: Buffs oder Gegenstände, deren Name mit
`t700_` beginnt. Sie dienen nur dem Test (z. B. ein Buff, der einen CVar ins Protokoll schreibt),
liegen in keiner Beute und keinem Rezept und kommen per Konsole (`buff t700_…`, `giveself t700_…`).
Die Mod nennt `t700_` nie. Regeln: [Vertrag 01, Abschnitt B2](../docs/contracts/01-modlet-grenzen.md).

## Der Proben-Lauf (S-32 bis S-35), rund 20 Minuten, Dedicated Server + ein Client

Vorbereitung: mit `-MitTest` installieren — auf dem Server **und** beim Client. Konsole mit F1.
Danach die Protokolle beider Seiten aufheben; Claude liest die Zeilen `CVarLogValue:` und
`MinEventLogMessage: t700`.

| Schritt | Konsole | Ansehen |
|---|---|---|
| S-32 (1)–(3) | `buff t700_cvarSetzen` | nichts — die Antwort steht im Protokoll: welche der vier Werte stehen beim **Server**? |
| S-32 (5) | Server neu starten, wieder rein, `buff t700_cvarZeigen` | welche Werte sind nach dem Neustart noch da (Protokoll) |
| S-33 (1)–(3) | `buff t700_craftZaehler`, dann dreimal einen Steinspeer herstellen; einmal an einer Werkstatt herstellen lassen, weggehen, wiederkommen | Zähler im Protokoll: 1, 2, 3, dann +1 nach der Rückkehr |
| S-33 (2) | neu laden, `buff t700_craftZaehler` | steht die Zahl noch |
| S-33 (4) | `giveself t700_wurfspeer`, rechte Maustaste halten und loslassen | fliegt er, trifft er, bleibt er stecken oder liegen, lässt er sich aufheben |
| S-34 (1) | `buff t700_lichtAnzeige`; nachts ohne Licht, mit Fackel, am Feuer, im Haus | Meldung über der Schnellleiste wechselt das Band; zeigt sie immer „ab 60", vergleicht das Spiel als Bruch — sagen |
| S-34 (2) | beide: `buff t700_gesellschaftSender`; nebeneinander, dann 20 m auseinander | „TEST Gesellschaft" bei beiden nah, bei keinem fern; **allein**: erscheint es trotzdem? |
| S-34 Seuchennacht | `buff t700_seuchennacht`, dann auf den Abend einer Seuchennacht springen | „TEST Seuchennacht läuft" ab Beginn |
| S-35 (1) | `giveself t700_zauberstab`, `buff t700_odemFuellen`, viermal schlagen | Protokoll 20, 10, 0; der vierte Schlag geht nicht — und wie merkt man es? |
| S-35 (2) | `giveself t700_amulett`, anlegen; dazu ein `biomeWeatherItem4` | welchen Platz nimmt es, verdrängt es das Abzeichen |
| S-36 *(seit WP10.4)* | `giveself blk700_runenritzer`, `giveself itm700_ritzmesser`, `giveself itm700_meissel`, setzen und öffnen | Größe und Sitz des Stumpfs; zwei Werkzeugplätze nehmen nur Messer und Meißel; Runenkreide und Glutstein herstellbar; ohne Punkt in Runenritzen sind Stock und Werkzeuge im Rezeptfenster gesperrt |
| S-37 *(seit WP10.5a)* | `giveself itm700_glutrune` (und `bannrune`, `schutzrune`, `wetterrune`, `wanderrune`), in Waffe bzw. Rüstung setzen | passt jede nur dort, wo sie soll; keine zweite Rune daneben; Rüstwert mit Schutzrune +10 %; Glutrune: Seuchentoter brennt ab und zu nach |
| S-38 *(seit WP10.5b)* | `giveself itm700_eulenauge` (und `baerenmut`, `wolfsbalsam`, `quellsud`), je trinken bzw. auftragen | Eulenauge nachts: besser, grün?; Bärenmut 3 min, dann „Verbrauchter Mut"; Wolfsbalsam: Leben steigt langsam um rund 24; Quellsud ohne Runenkunde: lässt sich nicht trinken — sagt das Spiel etwas? |
| S-39 *(seit WP10.5c)* | `giveself itm700_segenWehr`, `itm700_totensegen`, `itm700_fluchtopf`; vorher Runenkunde auf Stufe 3 (`giveselfskillpoints 10`, Punkte setzen) und `buff t700_odemVoll` *(berichtigt mit WP10.6: `t700_odemFuellen` setzt nur den Testwert `t700_odem`)* | Segen ohne Odem: geht nicht; mit Odem: Symbol, Odem −20 bzw. −25, Abklingzeit sichtbar; Totensegen: kommt ein Seuchentoter näher heran, ehe er dich bemerkt?; Fluchtopf auf drei Seuchentote: langsamer, kein Schaden, wie groß das Bild, kostet der Wurf Odem? |
| S-40 *(seit WP10.5d)* | `giveself itm700_reliquienkapsel` (und `bernsteinamulett`, `hammeramulett`, `kreuzanhaenger`), anlegen; zum Vergleich `giveself biomeWeatherItem4` | welcher Platz; verdrängen sich Amulett und Abzeichen; nur ein Amulett zugleich; mit Reliquienkapsel: weniger Schaden von einem Seuchentoten, aber nicht von einem Wolf |
| S-41 *(seit WP10.6)* | ohne Punkt in Runenkunde ins Spiel; dann `giveselfskillpoints 10`, Runenkunde auf 2, später 5; `buff t700_odemVoll`; an ein Feuer stellen | ohne Runenkunde: keine Leiste über den Balken links unten; ab Stufe 2: Leiste erscheint, füllt sich langsam (20 Odem in rund 80 s), am Feuer doppelt so schnell; nach Segen sinkt sie; Protokoll `CVarLogValue: cv700_odemMax` 20 bzw. 50; nach Tod und nach Neustart: Odem noch da? |
| S-42 *(seit WP10.9)* | Runenkunde auf 6, Glutzauber 2, Bannkunde 2 (`giveselfskillpoints 20`), `buff t700_odemVoll`; `giveself itm700_glutpfeil`, `itm700_lichtfunke`, `itm700_bannkreis` | Glutpfeil: trifft in 10 m, nicht in 30 m; Brand; Leiste −8; leer: geht nicht. Lichtfunke: Licht wie Fackel, Leiste sinkt beim Halten; leer: „Der Funke zehrt", Leben sinkt, endet beim Weglegen. Bannkreis: ein Schlag, Symbol 20 s, Leiste −30; Seuchentote in 5 m langsamer, außerhalb nicht |
| S-43 *(seit WP11.3)* | `buff t700_grauenZeigen`; nachts allein ohne Licht im Wald stehen; dann ans Feuer; dann `buff t700_grauen90` | Protokoll: Wert steigt um rund 0,25 je 5 s (nachts draußen ohne Licht), am Feuer sinkt er; „Unruhig" erscheint bei 30; mit 90: alle drei Symbole, Sichtrand dunkler, ein Treffer gibt „Panik"; am Tag gehen die Stufen nacheinander (bei 80, 55, 25); mit Bärenmut: Schutz 0,25 im Protokoll; zu zweit (Dedicated): „Gesellschaft" bei beiden nah, bei keinem allein |
| S-44 *(seit WP11.9)* | `settime 7 21 50`, draußen warten; dann mit Spielstufe über 30 bzw. 60 (`gamestage`) | erst Stille, nach rund 1 min ein Glockenschlag und „Die Glocke schlägt.", kein zweiter; im Lauf der Nacht ein Brecher, ab 60 eine Sagengestalt; kein Fehler zu `gamestages` im Protokoll |
| S-45 *(seit WP11.5)* | `buff t700_grauen90`, draußen fünf Minuten stehen, dann im Haus; Dedicated mit zweitem Spieler daneben | Schritte im Laub, Rascheln, drinnen eine Tür — ohne Quelle; der zweite Spieler hört nichts; kommen Seuchentote auf die Laute zu, sagen |
| S-46 *(seit WP11.7)* | `spawnentity` Aussätziger in 20 m, still stehen; dann 10 m; Schuss in 20 m; schlafender Aussätziger im Ort | sieht dich erst unter rund 12 m, folgt dem Schuss, wacht beim Gehen früher auf als andere; kein Fehler zu `entityclasses` |
| S-48 *(seit WP12.4)* | Gambeson-Teile, `itm700_lederwams` und die drei anderen T1-Teile; `spawnentity` `zombieSoldier`, `zombieSoldierFeral`, `zombieSteveCrawler`; Sax, Ger, Keule | mit Gambeson verliert man unter Seuchentot-Schlägen langsamer Leben als mit T1; der Krieger braucht mit dem Sax mehr Schläge als mit dem Ger, der Feral-Krieger ebenso (dann erbt er); der Kriecher fällt unter dem Sax schneller als unter der Keule; kein Fehler zu `entityclasses`/`items` |
| S-49 *(seit WP12.3)* | `giveself bladesSkillMagazine 4`, Zutaten für drei bis sechs Saxe, `bowsSkillMagazine`, `workstationSkillMagazine 4`, Zutaten für drei Holzfeuer | Klingenschmiede 13 nach vier Lehrblättern; nach drei hergestellten Saxen binnen 10 s die Meldung und 14, nach sechs 15; nach Laden weiter 15 ohne neue Meldung; Bogenbau +1; Werkstattbau steigt nach drei Holzfeuern (sonst zählt Vanilla Blöcke nicht); kein Fehler zu `buffs`/`items` |
| S-50 *(seit WP12.3b)* | `giveselfskillpoints 3`, Perk „Lehrzeit" im Baum Jäger, Attribut Jäger auf 4 | nach Rang 1 binnen 10 s Meldung und Klingenschmiede, Bogenbau, Speerbau je +10; Rang 2 erst ab Jäger 4, dann je +3; nach Laden unverändert ohne neue Meldung; keine Stufe über 75; kein Fehler zu `progression`/`buffs` |
| S-51 *(seit WP13.1)* | `buff buffInfectionCatch`, `buff buffDysenteryCatchDrink`, `foodHoney` | „Schwärende Wunde", „Ruhr" mit Goldrutentee-Text, „Heilmittel wirkt" nach Honig; nirgends „Infektion" oder „Durchfall" |
| S-52 *(seit WP13.3)* | `buff buffInfectionCatch`, `itm700_theriak`, `itm700_eichenrindensud`, `itm700_honigsalbe`, `buff buffInjuryBleeding`, eine Eiche, Lehrblätter Wundversorgung | Theriak senkt den Seuchenbrand („Heilmittel wirkt"); Fieber nach rund 5 min nass und kalt, weg nach dem Sud; Wundbrand nach rund 3 min Blutung, weg nach Salbe oder Salbenverband; Eichen werfen Eichenrinde; Theriak im Fenster bei Wundversorgung 30; kein Fehler zu `buffs`/`items`/`blocks` |
| S-47 *(seit WP11.9)* | `giveself itm700_schriftGlockenseil` (und die fünf anderen Deutungs-Schriften), Info-Fenster | Name und Text DE/EN, Umlaute, Absätze, nicht abgeschnitten; kein Fehler zu `items`/`loot` |
| S-35 (3) *(seit WP10.3)* | Fertigkeitsfenster öffnen (K), Reihe der Symbole oben | sechs Bäume, „Runenkunde" mit Stern als sechster; passt die Reihe neben das Suchfeld; steht irgendwo ein Rohschlüssel wie `att700_runenkundiger`; einen Punkt hineinsetzen und Perks ansehen |

**Nicht in diesem Lauf** (kein Ersatz durch eine Probe): S-32 (4) „Server setzt einen Wert" braucht
den ersten C#-Code (Regler); S-34 (3) Farbe des Himmels braucht eine Wetter-Zeile ohne `t700_`-Namen
und wird mit F-09 im Modlet selbst geprüft; S-34 (4) Vortag braucht den Direktor. ~~S-35 (3) neuntes
Feld im Fertigkeitsfenster kommt mit dem Bau des Runenkundigen (WP10.3).~~ Seit WP10.3 im Lauf (Tabelle oben).

## Eine Zeile ergänzen

Nur `<set>`, nur auf Knoten, die unsere Modlets angelegt haben. Die Prüfung
`tools/check/testueberlagerung-pruefen.ps1` (Teil von `check-all.ps1`) zeigt je Zeile
„alt -> neu" und wird rot, wenn eine Zeile nichts trifft oder nichts ändert.
