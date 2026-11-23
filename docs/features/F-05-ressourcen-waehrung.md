# F-05 — Ressourcen & Währung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1 | X | S | nein |

## Ziel
Rohstoffe fühlen sich nach 700 an und tragen die Handwerksketten (F-04). **Eisen ist der
Engpass der Epoche** (D31); Holz, Stein und Lehm gibt es reichlich. Bezahlt wird **nur mit
Silber** (D30).

## Ressourcen

| Vanilla | 700 | Häufigkeit | Quelle |
|---|---|---|---|
| Iron (Schrott) | Raseneisenerz → Luppe → Schmiedeeisen | **knapp** | Moor- und Sumpf-Ressourcenblöcke; Altmetall aus Römerruinen; Plünderer-Beute (F-20) |
| Lead, Brass | ~~Kupfer, Bronze-Altmetall~~ Blei (`resourceScrapLead`), Buntmetall (`resourceScrapBrass`) — laut [Glossar](../glossar.md) | selten | Ruinen |
| Oil Shale, Gas | entfällt; Pech bzw. Teer aus Holz | – | Kräuterküche |
| Coal | Holzkohle (Meiler) | normal | Feuerstelle bzw. Meiler |
| Nitrate | entfällt | – | – |
| Concrete | Kalkmörtel, Bruchstein | normal | Kalkofen, Steinbruch |
| Wood, Stone, Clay | Holz, Stein, Lehm | **reichlich** | überall |
| – (neu) | Bernstein | selten | Küste (Kulturzone), Handel; Magie (F-15), Wegsteine (F-13) |
| – (neu) | Salz | knapp | Handel, Salzquellen-POI; Konservieren (F-19) |

- Erzverteilung je Kulturzone (`biomes.xml` / `rwgmixer.xml`, F-07)

## Währung (D30)
- **Silber** (Sceattas bzw. Denare) als 1:1-Umdeutung der Vanilla-Dukes
- Kein Tauschhandel und keine Mehrfach-Währungen (Nicht-Ziel)

## Beute in 700 (D121; Plan-0002 WP8.6, D165) — **zu prüfen (N-110)**

Vanillas **Beutestufe** bleibt (P5): Menge und Güte wachsen mit der Spielstufe wie in Vanilla.
Was sich ändert, ist **was** in den Behältern liegt.

### Messung (Vorlauf, V 3.40 b10, alle zehn Modlets)

| | Vanilla | nach dem Purge | nach WP8.6 |
|---|---|---|---|
| Behälter (`lootcontainer`) | 339 | 339 | 339 |
| davon ohne jede Beute | 9 | 89 | 89 |
| Beutegruppen ohne jeden Gegenstand | — | 240 von 1017 | 227 |
| Behälter mit unserer Rüstung | — | 0 | 26 |

Die 89 leeren Behälter sind fast alle **modern oder Twitch**: Geldautomat, Zapfsäule, Benzinfass,
Elektro- und Werkstattkisten (`mopower…`), Twitch-Kisten, die `…NOPOP`-Fassungen und die
Spielerkisten (bei beiden trägt Vanilla nur Spinnweben als Platzhalter, und die nimmt der Purge). Was ein Spieler in einem Hof oder Dorf öffnet —
Schrank, Truhe, Kiste, Fass, Grab, Beutel —, gibt weiter etwas her. Die Behälter selbst sehen
modern aus; das ist F-07/WP6.5b (Erscheinung), nicht Beute.

### Gebaut (`700_70_Handel/Config/loot.xml`, Vertrag 01: Beutetabellen)

Sechs leere Vanilla-Gruppen, auf die viele Behälter zeigen, bekommen Dinge der Zeit; die Gruppe
bleibt, Einträge kommen dazu:

| Gruppe | Verweise | Vanilla | jetzt |
|---|---|---|---|
| `groupMedicalRare` | 23 | Verbandskasten, Pillen | Salbenverband, Kräutersud (selten), Schiene |
| `groupFoodUncommon` | 21 | Konserven | Honig, Wildbret- und Gemüseeintopf, gekochtes Fleisch |
| `groupAmmoLarge` | 20 | Patronen | Stein- und Eisenpfeile, -bolzen; sehr selten ein Pfeilbündel |
| `groupDrinksRare` | 10 | Kaffee, Limonade, Schnaps | Bier, Goldrutentee, roter Tee |
| `groupAllArmor` | 5 | 60 moderne Rüstungsteile | unsere zwölf: Leder gewöhnlich, Stepp selten, Kette sehr selten |
| `groupScrapRare` | 3 | Kühler | Buntmetall |

Bewusst leer: `foodCandy` (Süßigkeiten mit Wirkung, kein Gegenstück der Zeit), `groupToolsT3`
(Motorsäge, Bohrer). Fundschriften liegen seit WP6.7 in Schreibpulten, Büchern, Särgen, Truhen
und Beuteln der Toten (D158).

### Beute je Ort — Plan, nicht gebaut

Eigene Orte (Hof, Kloster, Ruine) gibt es erst mit WP6.6 (wartet auf N-98). Dann bekommen ihre
Behälter eigene Gruppen mit Präfix `lg700_`:

| Ort | was dort liegt | was nicht |
|---|---|---|
| **Hof** (Bauernhof, Köhlerhof) | Saatgut, Vorrat, Werkzeug der Stufe 1, Wolle, Leder, Holzkohle | Waffen höher als Stufe 1, Silber in Mengen |
| **Kloster** | Abschriften, Lehrblätter, Kräuter, Salben, Wachs, Fundschriften des Mönchs | Rüstung, Kette |
| **Ruine** (römisch) | Altmetall (Buntmetall, Blei), Ziegel, ab und zu ein Silberpfennig, Stepp- und Kettenteile von Toten | frische Nahrung |
| **Grab / Hügel** | Beigaben: Fibeln, Silber, selten eine Klinge | Alltagsware |

Ideen für Phase 3 (D50): Beigaben mit Fluch (F-15), Hortfunde nach Karte (heute Hortbriefe, D160).

## Akzeptanzkriterien
- [ ] Jedes Rezept in F-02 bis F-04 ist aus diesen Ressourcen erfüllbar
- [ ] Eisen-Ausbeute liegt spürbar unter Vanilla-Eisen (Zielwert im Balancing)
- [ ] Händler akzeptieren Silber; kein „Dukes“-Text sichtbar

## Offene Fragen
- Ist das Currency-Item per XML umbenennbar und umstylbar? → kurzer Check (hook-hypothesen.md#f-05)
