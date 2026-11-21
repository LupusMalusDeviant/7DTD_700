# Testglossar: eine kaputte Trennzeile, und daneben eine heile Verbots-Tabelle

Der Fall aus dem vierten Review. Die erste Verbots-Tabelle hat keine Randstriche und eine
Trennzeile mit Tippfehler ("oops"). Markdown liest sie dann nicht als Tabelle, und die
Pruefung tat es auch nicht - ihr Verbot `zombie` fiel weg. Weil darunter eine ZWEITE, heile
Verbots-Tabelle steht, war "kein einziger verbotener Begriff" nicht der Fall, und das
Ergebnis blieb GREEN.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `pruefFeuer` | Feuerstelle | Hearth | Lagerfeuer / Campfire | Test |
| `pruefErz` | Raseneisenerz | Bog Iron Ore | Eisen / Iron | Test |

Verboten | Sprache | Stattdessen | Quelle
---|---|---|oops
`zombie` | beide | Seuchentote / the plague-dead | Test

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `lagerfeuer` | DE | Feuerstelle | Test |
