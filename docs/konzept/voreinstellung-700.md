# Voreinstellung „Jahr 700" — die empfohlenen Spieloptionen

**Stand:** 2026-11-23, autonomer Lauf (Plan-0002 WP1.5). **Alles hier ist Vorschlag und zu prüfen**
(D112, D136; Entscheidungsliste N-02, N-32, N-95). Beleg für die Technik:
[Finding F-17](../rea/findings/F-17-sandbox-vorlage-und-optionscode.md) — statisch gelesen, **im
Spiel nicht gesehen**.

## 1. Wozu

Das Spiel fragt beim Anlegen einer Welt nach einer Vorlage (Schwierigkeit und rund 165
Einzeloptionen). Mit Vanillas Vorwahl „Adventurer" ist der **Biom-Fortschritt an**, und der ist mit
unserer Mod nicht lösbar (D128): außerhalb des Kiefernwalds verliert der Spieler unter freiem
Himmel Leben, und alle Gegenmittel sind gesperrt. Bisher musste jeder Gastgeber wissen, dass er die
Option von Hand abstellt.

Die Mod bringt darum **eine eigene Vorlage** mit. Sie ist beim Öffnen von „Neues Spiel"
vorgewählt, steht in der Gruppe „Gemoddet" und heißt „Jahr 700" (englisch „Year 700").

> **Stand 2026-11-23, später (WP6.3, D155, zu prüfen):** Der Biom-Fortschritt ist mit Weg B lösbar
> (D154): Sude, Schutzstücke und die vier Reihen gehen mit Zutaten des Settings, die Texte stehen.
> Die Vorlage schaltet ihn darum **nicht mehr ab**; ihr Code ist jetzt **`AAAJABJACJADJARFBNC`**
> (Vanillas „Adventurer" ohne die Gruppe `CDA`). Sie bleibt als Ort für die übrigen Empfehlungen
> aus Abschnitt 3. Wer den Fortschritt doch aus haben will, hängt `CDA` an. Der Text unten
> beschreibt den Stand davor und bleibt als Beleg stehen.

## 2. Was gebaut ist — genau eine Einstellung

Datei: `mod/700_60_Welt/Config/sandbox_overrides.xml`, eine Zeile `<preset … default="true" />`.

| Teil des Codes | Bedeutung |
|---|---|
| `A` | Kopf: Version des Formats in V 3.40 b10 |
| `AAJ ABJ ACJ ADJ ARF BNC` | Vanillas Vorwahl „Adventurer", **unverändert** — derselbe Code steht in `serverconfig.xml` |
| `CDA` | `BiomeProgression` (Wert 55 → `C`,`D`) auf Index 0 = **aus** |

Der ganze Code: **`AAAJABJACJADJARFBNCCDA`**. Er ist **gerechnet**, nicht aus dem Optionsfenster
kopiert. Das Format ist an zwei echten Codes geprüft (einer vom Spiel geschriebenen Nutzervorlage
und dem Code in `serverconfig.xml`); dass bei einer Ja/Nein-Option `A` „aus" heißt, ruht allein auf
der gelesenen Wertemenge. Wäre es umgekehrt, entspräche die Vorlage Vanillas „Adventurer" — sie
schadete nicht, aber sie nützte auch nichts. Das zeigt S-11 in zwei Minuten.

**Was die Vorlage nicht leistet:**

- Sie **wählt nur vor**. Wer eine andere Vorlage nimmt, hat den Biom-Fortschritt wieder an.
- Auf einem **Dedicated Server** wirkt sie gar nicht. Dort gehört der Code in `serverconfig.xml`:
  `<property name="SandboxCode" value="AAAJABJACJADJARFBNCCDA" />` (Name der Zeile aus dem Finding;
  die Zeile steht in Vanillas Datei schon da, mit dem Adventurer-Code).
- Ein **bestehender Spielstand** behält vermutlich seinen Code (nicht gelesen).
- `<sandbox_override option="BiomeProgression" />` ist **bewusst nicht** benutzt: es schaltet nichts
  aus, es sperrt nur das Bedienfeld — auf „an", sobald jemand eine Vanilla-Vorlage wählt.

Der feste Weg (die Gefahr umdeuten und lösbar machen) bleibt Weg B in WP6.3.

## 3. Die übrigen Optionen — Empfehlung, nicht gebaut

„Gebaut wird höchstens eine Einstellung" (Plan-0002 WP1.5). Alles Weitere steht hier als
Empfehlung mit Begründung; in die Vorlage kommt es erst nach deinem Ja.

| Option (Name im Spielcode) | Empfehlung | Warum | Lässt sich der Code rechnen? |
|---|---|---|---|
| Biom-Fortschritt (`BiomeProgression`) | ~~**aus**~~ **an** (seit D155) | ~~D128: nicht lösbar~~ mit Weg B lösbar (D154) | ja — ~~gebaut (`CDA`)~~ seit D155 nicht mehr im Code |
| Luftabwurf (`AirDropFrequency`) | **nie** | D95: ein Flugzeug gibt es im Jahr 700 nicht | **nein** — Ganzzahl-Option, die Reihenfolge der Werte ist nicht lesbar. Code aus dem Optionsfenster kopieren (S-11) |
| Markierung des Abwurfs (`AirDropMarker`) | entfällt mit dem Abwurf | — | ja (`CBA`), nur nötig, wenn der Abwurf bleibt |
| Händlerstimmen (`TraderDialog`) | **aus** | D102: 1336 gesprochene Zeilen in modernem Englisch | Typ nicht gelesen; vermutlich Ja/Nein (Wert 126 → `EW`), dann `EWA` — **ungeprüft** |
| Verkaufsautomaten (`VendingEnabled`) | **aus** | Automaten sind ein Anachronismus; ob der Purge sie schon stilllegt, ist nicht gemessen | ja (`EZA`) |
| Herausforderungen (`ChallengesEnabled`, `IntroChallengesEnabled`) | **an lassen** | die Einstiegsreihe ist heil und umgeschrieben (D80); die unerfüllbaren Ziele löst D104 in den Dateien, nicht über einen Schalter | ja (`FJA`, `FKA`), nicht empfohlen |
| Temperatur (`TemperatureSurvival`) | an lassen | Wetter ist zeitlos (D97) | — |
| Stürme (`StormFreq`, `StormWarning`) | wie Vanilla | D97: bleiben als Unwetter; die Warnung ist eine Bedienhilfe | — |
| Karte, Kompass (`AllowMap`, `AllowCompass`) | an lassen | D96: bleiben in Phase 1 als Bedienhilfe; der Grusel-Regler (D13) entscheidet später | ja (`CQA`, `CRA`), nicht empfohlen |
| Händler (`TradersEnabled`) | an lassen | F-10 baut auf ihnen | — |
| Höchste Technikstufe (`MaxTechType`) | **prüfen** | könnte Vanillas spätere Stufen von sich aus kappen — das wäre ein zweiter Riegel neben dem Purge. Was die fünf Werte bedeuten, ist nicht lesbar | nein — Ganzzahl-Option |
| Werkstätten in der Welt (`WorkstationsInTheWild`) | **prüfen** | D-Einträge zu Werkstätten (F-04) verlangen eigene; Vanillas stehen in POIs | nein — Kommazahl-Option |
| Schaden, Geruchssinn (sechs Gruppen von „Adventurer") | unverändert | „Mehr Gefahr für Spieler" (D29) hat noch keine Zahl; D112 entscheidet das in WP9 an dieser Vorlage | übernommen |
| Musik | **aus, aber nicht hier** | D114. Unter den 167 Namen der Sandbox-Optionen ist keiner mit „Music" — die dynamische Musik ist eine Audio-Einstellung des Spielers und über die Vorlage nicht erreichbar | — |

## 4. Was nur das Spiel zeigt (S-11)

Im Hauptmenü, ohne eine Welt zu laden, wenige Minuten:

1. „Neues Spiel" öffnen: steht „Jahr 700" in der Gruppe „Gemoddet", und ist es vorgewählt?
2. In den Optionen der Vorlage: steht ~~„Biomfortschritt" auf „Nein"~~ alles wie bei
   „Adventurer"? (Seit D155 ist auch der Biom-Fortschritt wie dort „Ja".)
3. Für die Erweiterung: Luftabwurf auf „nie", Händlerstimmen aus, Automaten aus stellen, „Code
   kopieren" — den Code hier eintragen. Damit sind die nicht rechenbaren Optionen erledigt.

Mit geladener Welt (deckt sich mit S-05): im Protokoll steht ~~`GameStat.BiomeProgression = False`,
und im Brandwald läuft keine Frist~~ seit D155 `GameStat.BiomeProgression = True`; was dann im
Brandland geschieht, prüft S-30.
