# WP8 — Nacht und Nebel: was `worldglobal.xml` und `biomes.xml` wirklich steuern

| | |
|---|---|
| Datum | 20. November 2026 |
| Build | V 3.40 b10, `Assembly-CSharp.dll` SHA-256 `cb54022c…9656c58` |
| Werkzeug | `mod700meta find-string` und `members --il` — **Aufrufe, Feldzugriffe, Zeichenketten, keine Verzweigungen und keine Arithmetik** |
| Feature | F-17 Bausteine B1 (Dunkelheit, Nebel) |
| Harmony-Patch | **keiner** — reines XML, das Patch-Manifest bleibt leer |

## 1 Wer die Himmelswerte liest

Genau **eine** Methode lädt die Namen aus `worldglobal.xml`: `WorldEnvironment::OnXMLChanged`
(gefunden über die Zeichenketten `ambientEquatorScale`, `ambientGroundScale`, `ambientMoon`,
`ambientInsideThreshold`, `fogPower`). Sie ruft elfmal `DynamicProperties::ParseVec` und
dreimal `ParseFloat` und füllt statische Felder `dataAmbient…`, `dataFogPow`, `dataFogWater`.

Beide Dateien stehen in der Liste der patchbaren Configs
([WP1-Befund](WP1-modlet-lader-und-xml-patcher.md)) und im ConfigsDump.

## 2 Wie das Umgebungslicht entsteht

`WorldEnvironment::AmbientSpectrumFrameUpdate` setzt dreimal `RenderSettings.ambient…Color`
— Himmel, Äquator, Boden — und liest dafür in dieser Reihenfolge:

1. `PlayerEntityStats::LightInsidePer`, `dataAmbientInsideThreshold`, `dataAmbientInsideSpeed`
   → `insideCurrent` (wie sehr der Spieler „drinnen" ist, mit `MoveTowards` geglättet).
2. `GamePrefs::GetFloat(195)`, dann `FastLerpUnclamped`, `FastMax`, `LerpUnclamped`,
   `FastLerp` → `brightnessInOutDayNight`. **195 ist `OptionsGfxBrightness`**, der
   Helligkeitsregler des Spielers.
3. `SkyManager::GetMoonAmbientScale` mit `dataAmbientMoon.x` und `.y`.
4. Je Farbe ein Paar aus `dataAmbient…Scale` und `dataAmbientInside…Scale`, über
   `LerpUnclamped` gemischt.

**Zwei Dinge daran sind hart:**

- `WorldEnvironment::cBrightnessMin` ist eine **Konstante mit dem Wert 0,2**. Zusammen mit
  dem `FastMax` in Schritt 2 liest sich das als Untergrenze der Helligkeit. *Schluss, nicht
  Messung:* die Konstante ist in den IL-Befehl eingebettet und in der Aufrufliste nicht zu
  sehen; dass genau sie im `FastMax` steht, ist die naheliegende Lesart.
- **Der Helligkeitsregler geht in dieselbe Rechnung ein.** Ein Spieler kann sich die Nacht
  aufhellen — auf seinem Bildschirm, unabhängig vom Server. XML ändert das nicht.

## 3 Der Mond

`SkyManager::GetMoonAmbientScale(float, float)` liest `moonBright` und `dayPercent` und ruft
`FastLerp`. `moonBright` wird in `SkyManager::Update` gesetzt, aus den statischen Tabellen
`sMoonPhases` und `sMoonBrights`.

`worldglobal.xml` kommentiert `ambientMoon` selbst mit `add, scale`.

*Schluss:* Mondanteil = Sockel + Mondhelle × Anteil, zum Tag hin ausgeblendet. Vanilla
`.8, .4` gäbe bei Neumond 0,8 und bei vollem Mond 1,2 — **wenn** `sMoonBrights` von 0 bis 1
läuft. Die Werte der Tabelle sind nicht gelesen (statische Feldinitialisierung).

## 4 Der Nebel

`WorldEnvironment::SpectrumsFrameUpdate` liest `dataFogPow` (`.y`, dann `.x`) zusammen mit
`dayPercent`, ruft `FastLerpUnclamped` und `Mathf::Pow`, danach
`WeatherManager/BiomeWeather::FogPercent`, und endet in `SkyManager::SetFogDensity`.

- `fogPower` ist damit ein **Exponent**, getrennt für Tag und Nacht.
- **Worauf** er wirkt, ist nicht zu lesen: der `Pow`-Aufruf steht *vor* `FogPercent`, die
  Basis kommt aus einer lokalen Variablen. Ob ein Wert unter 1 den Nebel nachts verdichtet
  oder ausdünnt, hängt davon ab, ob die Basis unter oder über 1 liegt. **Darum ist
  `fogPower` nicht angefasst.**
- Die Nebelstärke eines Wetters ist ein Prozentwert (`FogPercent`).

`biomes.xml`, Wurzel `/worldgeneration/biomes`. Fünf Land-Biome und `underwater`:

| Biom | Kulturzone (D43) | Nebel in Vanilla |
|---|---|---|
| `pine_forest` | Klosterland (Wald) | `default` 0–2 (prob 83), **`fog` 17–27 (prob 7)**, Regen 1–3 und 3–7 |
| `wasteland` | Moorland | `default`, `cold`, `hot` je 0–5; **kein Nebelwetter** |
| `burnt_forest` | Brandland | `default` 0–5; kein Nebelwetter |
| `snow` | Burgwall-Land | `default` 0–2, `fog` 9–18 (prob 8) |
| `desert` | Küste | `default` 0–3; kein Nebelwetter |

Vanillas dichtester Wert ist `twitch_fog` mit 35–45. Die Datei führt zwei Schreibweisen
nebeneinander: `range="a,b"` und die alte `min`/`max` (ihr eigener Kommentar nennt sie
„OLD format"). Die Summe der `prob` über die Wetter mit `prob > 0` ist in Wald und Moor
je 100; laut Dateikommentar wird ohnehin normalisiert.

**Ein Flusstal ist kein Biom.** F-17 und F-07 nennen „Moor und Flusstäler"; Vanilla hat
dafür keinen Knoten.

## 5 Was gebaut ist

`mod/700_60_Welt/Config/worldglobal.xml` — vier `<set>`, nur der Nachtwert:

| Eigenschaft | Vanilla | neu |
|---|---|---|
| `ambientEquatorScale` | `.7, .45` | `.7, .25` |
| `ambientGroundScale` | `.3, .05` | `.3, .02` |
| `ambientSkyScale` | `1, .7` | `1, .4` |
| `ambientMoon` | `.8, .4` | `.5, .7` |

`mod/700_60_Welt/Config/biomes.xml` — acht `<set>`:

| Biom | Wetter | Vanilla | neu |
|---|---|---|---|
| Wald | `default` Nebel | 0–2 | 1–5 |
| Wald | `default` prob | 83 | 76 |
| Wald | `fog` prob | 7 | 14 |
| Wald | `fog` Nebel | 17–27 | 20–32 |
| Moor | `default`, `cold`, `hot` Nebel | 0–5 | 6–14 |

**Alle zwölf Zahlen sind Setzungen.** Gemessen ist, *dass* sie wirken und *wo*; wie es
aussieht, nicht.

## 6 Nachweis

- Jeder der zwölf XPaths trifft in Vanilla **genau einen** Knoten (gezählt mit
  `SelectNodes` gegen `Data/Config`), und der alte Wert ist der erwartete.
- `kette-pruefen`: 392 → **404** XPaths, 0 unaufgelöst.
- **Gegenprobe (Projektregel 5):** dieselben zwei Dateien mit je einem falschen XPath
  (`biome[@name='moorland']`, `property[@name='ambientMond']`) → `kette-pruefen` meldet
  „XPath trifft nichts" zweimal, 2 rot, Exit 1. Mit den echten Dateien: 12 geprüft, 0 rot,
  Exit 0. Von Hand gelaufen am 20. November 2026, nicht in `gegenproben.ps1`.
- **Dabei aufgefallen:** übergibt man `-Patches` einen Pfad, den es nicht gibt (bei mir:
  zwei Pfade versehentlich als *eine* Zeichenkette), meldet `kette-pruefen`
  „0 XPaths … 0 rot → GREEN". Im normalen Lauf sucht das Skript seine Dateien selbst und
  ist davon nicht betroffen; als Lücke in Vertrag 04 vermerkt.

## 7 Grenzen

- **Im Spiel hat das niemand gesehen.** Für Licht gilt das schärfer als für jede Zahl
  bisher: ein Rezept ist gesperrt oder nicht, eine Nacht ist „zu dunkel" erst, wenn jemand
  hinsieht → Prüfliste 18.
- **Keine Arithmetik.** Die Formeln in §2 bis §4 sind aus der Reihenfolge von Aufrufen und
  Feldern erschlossen.
- **`ambientInside*` ist nicht angefasst.** Vanilla hebt das Licht unter einem Dach nachts
  an (`ambientInsideEquatorScale .55, 1.5`). Nach dem Absenken draußen kann ein dunkles Haus
  heller wirken als der Wald davor.
- **`fogPower`, und damit „abends dichter", ist nicht gebaut** (§4).
- **Der frühere Befund nennt die falsche Entscheidung.**
  [02-10-schnittstellen-kurzcheck.md](02-10-schnittstellen-kurzcheck.md) und F-17 schreiben
  „der Hebel für D16 (dunklere Nächte)". D16 ist die Mobilität; dunklere Nächte gehören zu
  D12. In F-17 berichtigt, der alte Befund bleibt als Stand seines Tages stehen.
