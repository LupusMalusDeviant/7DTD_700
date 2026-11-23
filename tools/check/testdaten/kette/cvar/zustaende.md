# Pruefdaten fuer kette-pruefen.ps1 (WP11.3): ein Vertrag der Zustaende im Kleinen

Erfundene Namen, kein Spielinhalt.

| Name | Art | Werte | Schreiber | Neustart | Lesen |
|---|---|---|---|---|---|
| `cv700_pruefServer` | CVar je Spieler | 0/1 | **Server**, beim Betreten | neu gesetzt | ein Buff |
| `cv700_pruefVertragOhneServer` | CVar je Spieler | 0/1 | ein Buff des Spielers | bleibt | ein Buff |
| `.cv700_pruefAnzeige` | lokaler CVar | 0/1 | ein Buff des Spielers | abgeleitet | die Oberflaeche |

Fliesstext, der `cv700_pruefLeseFehlt` nennt, gibt keinen Schreiber: die Regel liest nur Tabellenzeilen.
