# Testglossar: eine Trennzeile, ueber der keine Kopfzeile steht

Die erste Tabelle ist in Ordnung. Darunter steht eine Trennzeile ohne Kopfzeile davor -
so sieht es aus, wenn beim Bearbeiten die Kopfzeile verloren geht. Die Zeilen darunter
sind dann kein Markdown mehr, und der Pruefer darf sie nicht still als Fliesstext lesen.

| Kennung | Deutsch | Englisch | Vanilla | Quelle |
|---|---|---|---|---|
| `pruefFeuer` | Feuerstelle | Hearth | Lagerfeuer / Campfire | Test |
| `pruefErz` | Raseneisenerz | Bog Iron Ore | Eisen / Iron | Test |

| Verboten | Sprache | Stattdessen | Quelle |
|---|---|---|---|
| `lagerfeuer` | DE | Feuerstelle | Test |

---|---|---|---
`zombie` | beide | Seuchentote / the plague-dead | Test
