# WP5 — Die Handwerksqualität hat sieben Sprachschlüssel, und sie liegen nicht in der XML

**Stand:** 8. November 2026
**Frage:** F-02 und D23 wollen Vanillas Qualitätsstufen 1–6 umbenennen (grob, einfach, solide,
gut, meisterlich, legendär). `qualityinfo.xml` enthält aber nur Farben. Wo stehen die Namen —
und kommt man per XML an sie heran, oder braucht es C#?
**Antwort:** Es sind sieben gewöhnliche Sprachschlüssel. Reine `Localization.csv`, kein Patch.

Das ist der Unterschied zwischen einer Zeile pro Stufe und einem Harmony-Patch am Tooltip —
und damit zwischen „WP5.3 ist XML" und „Phase 1 braucht doch einen Patch". Darum vor dem
Bauen dieser Befund.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta types <dll> --contains Quality` und
`mod700meta members <dll> --type QualityInfo --il`. Gelesen werden nur Metadaten und
IL-Bytes; die Assembly wird nicht geladen, nicht ausgeführt und nicht dekompiliert. REA
bricht an dieser Assembly ab, siehe [00-rea-grenzen.md](00-rea-grenzen.md).

## Was die falsche Spur war

`Data/Config/qualityinfo.xml` sieht wie der richtige Ort aus und ist es nicht:

```xml
<quality key="0" color="808080"/>   <!--Broken-->
<quality key="1" color="9C8867"/>   <!--Junk -->
```

Sieben Einträge, je **nur** `key` und `color`. „Broken", „Junk", „Common" stehen als
**XML-Kommentar** daneben — Kommentare sind kein Datenfeld, und der Lader liest sie nicht.
Wer diese Datei patcht, kann Farben ändern und keine Namen. Auch `Localization.csv` hilft bei
einer Textsuche nicht weiter: kein Schlüssel beginnt mit `quality` oder `tier`, und im
englischen Feld steht „Junk" oder „Legendary" an keiner Stelle als Stufenname.

## Der Beleg

`QualityInfo` hat zehn Methoden; eine davon heißt, was wir suchen:

```
static string QualityInfo::GetQualityLevelName(int, bool)
```

Ihre Zeichenketten und ihre Aufrufe, aus dem IL gelesen:

| string_literals | calls |
|---|---|
| `lblQualityBroken` | `Localization::Get` (8×) |
| `lblQualityDamaged` | `QualityInfo::GetQualityColorHex` |
| `lblQualityPoor` | `System.String::Format` |
| `lblQualityAverage` | |
| `lblQualityGreat` | |
| `lblQualityFlawless` | |
| `lblQualityLegendary` | |
| `[{0}]{1}[-]` | |

Sieben Schlüssel, sieben `Localization::Get`-Aufrufe (der achte holt den Rahmen), und zum
Schluss ein `String.Format` mit `[{0}]{1}[-]` — das ist die NGUI-Farbklammer: Farbe aus
`GetQualityColorHex`, Text aus `Localization::Get`. Die Farbe kommt aus der XML, **der Name
aus der Sprachdatei.**

Die Vanilla-Zeilen bestätigen es von der anderen Seite. `Data/Config/Localization.csv`,
Zeilen 20199–20206, englisches und deutsches Feld:

| Schlüssel | englisch | deutsch |
|---|---|---|
| `lblQualityBroken` | `Broken {0}` | `{0} (beschädigt)` |
| `lblQualityDamaged` | `Faulty {0}` | `{0} (fehlerhaft)` |
| `lblQualityPoor` | `Poor {0}` | `{0} (schlecht)` |
| `lblQualityAverage` | `Good {0}` | `{0} (gut)` |
| `lblQualityGreat` | `Fine {0}` | `{0} (ausgezeichnet)` |
| `lblQualityFlawless` | `Great {0}` | `{0} (großartig)` |
| `lblQualityLegendary` | `Flawless {0}` | `{0} (makellos)` |

**Das `{0}` ist Pflicht.** Es nimmt den Gegenstandsnamen auf; eine Zeile ohne `{0}` liefert
einen Tooltip ohne den Namen der Waffe. Unsere Zeilen übernehmen darum die deutsche Bauform
`{0} (…)` wörtlich und tauschen nur das Wort in der Klammer.

Dass eine Modlet-Zeile den Vanilla-Schlüssel überschreibt, ist in
[WP4-localization-ueberschreibt-vanilla.md](WP4-localization-ueberschreibt-vanilla.md)
belegt — ohne diesen zweiten Befund wäre der hier wertlos.

## Die Zuordnung Stufe → Schlüssel, und warum sie noch nicht bewiesen ist

Die sieben Namen stehen im IL in dieser Reihenfolge, und die Farben in `qualityinfo.xml`
laufen von `key="0"` (grau, zerbrochen) bis `key="6"` (violett, legendär). Daraus folgt die
naheliegende Zuordnung 0 → `lblQualityBroken` … 6 → `lblQualityLegendary`.

**Naheliegend ist nicht gemessen.** Was hier wirklich belegt ist: diese sieben Schlüssel
werden von dieser Methode gelesen, und es sind genau so viele wie Qualitätsstufen. Welcher
Schlüssel zu welcher Zahl gehört, folgt aus der Reihenfolge der Zeichenketten im IL — bei
einem `switch` ist das in der Praxis die Fallreihenfolge, aber `mod700meta` gibt die Literale
in Metadatenreihenfolge zurück und nicht als Sprungtabelle. Ein vertauschtes Paar in der
Mitte („gut" und „solide") würde man beim Lesen des IL nicht sehen.

Geprüft wird das im Spiel, mit einem Gegenstand je Stufe
(`giveselfquality` oder `ConsoleCmdGiveQualityItem`), und es gehört in den Protokolllauf von
**WP3.6**. Bis dahin gilt für diese Zuordnung dasselbe wie für alles andere in diesem Paket:
gelesener Code, kein Lauf.

## Was dieser Befund nicht sagt

- **Nichts über die Materialstufe.** D23 will zwei Achsen: Material (Knochen < Bronze <
  Schmiedeeisen < Stahl < Damast) und Handwerksqualität. Hier geht es allein um die zweite.
  Die Materialstufe hat in Vanilla kein Gegenstück und wird in WP5 über getrennte
  Gegenstände und ihre Namen gebaut, nicht über diese sieben Schlüssel.
- **Nichts über die Farben.** Wer die Stufenfarben ändern will, patcht `qualityinfo.xml`.
  In WP5 bleibt sie unberührt: eine violette „legendäre" Spatha ist kein Anachronismus.
- **Nichts über `ShowQuality`.** Ob ein Gegenstand überhaupt eine Qualität zeigt, hängt an
  seiner Eigenschaft `ShowQuality` und nicht an dieser Methode.
- **Kein Patch-Zielpunkt.** Dieser Befund begründet ausdrücklich *keinen* Harmony-Patch; er
  nimmt einen weg. Darum steht er nicht im `patch-manifest.md`.
