# Vertrag 05 — Asset-Pipeline

- **Status:** **Entwurf — Abnahme offen.** Geschrieben im autonomen Lauf (Plan-0002, WP2.2); gebaut
  wird darauf „auf Vertragsentwurf" (P2-E02, N-71). **Teil A (Symbole) ist vollständig; Teil B
  (Modelle, Bundles) nennt, was vor dem ersten Modell belegt sein muss, und ist bis dahin
  ausdrücklich offen.**
- **Datum:** 2026-11-23
- **Gilt ab:** Phase 2 (Plan-0002 WP3, WP4, WP7)
- **Belege:** [F-16-symbole-aus-dem-modlet.md](../rea/findings/F-16-symbole-aus-dem-modlet.md) ·
  Spec 01 §6 (Assets, Recht) · F-16 · D84 (Asset-Quellen) ·
  [0000-entscheidungen](../pruefung/0000-entscheidungen-fuer-den-nutzer.md) N-60 bis N-65, N-75 bis N-79

## 1. Die Grundregeln

1. **Nichts von Vanilla und nichts von anderen Mods oder Spielen in unseren Dateien.** Kein
   Vanilla-Bild, kein Vanilla-Mesh, keine veränderte Vanilla-Textur — weder im Repository noch im
   Paket. Ein Vanilla-Bild darf **beim Namen genannt** werden (`CustomIcon` zeigt auf ein Bild, das
   das Spiel selbst mitbringt); kopiert wird es nie.
2. **Jedes ausgelieferte Stück hat eine Zeile im Register** `assets/ASSETS.md` — mit Quelle, Lizenz
   und Nennung. Ein Stück ohne Zeile wird nicht ausgeliefert; die Prüfung *asset-register* (§6)
   macht das rot.
3. **XML vor C# vor Assets** (Säule P5): ein eigenes Bild entsteht erst, wenn kein vorhandenes
   Vanilla-Bild passt (Umbiegen, D130).
4. **Reproduzierbar ohne Handarbeit:** vom Quellbild zum Bild im Modlet führt **ein** Befehl (§4).
5. **Kein Python im Repository — mit einer Ausnahme.** Werkzeuge sind PowerShell oder C#.
   ~~Blender-Skripte sind Python und liegen nicht im Repository, solange der Nutzer nichts anderes
   entscheidet (N-61).~~ **Entschieden vom Nutzer am 2026-11-23** („Du darfst Python für Blender
   nutzen"): Blender-Skripte liegen unter `tools/assets/blender/`. Sie laufen nur in Blender, nie im
   Spiel, nie im Paket und nie im Prüfbefehl; sonst bleibt das Verbot.

## 2. Ordner

| Ordner | Inhalt | Im Repository | Im Paket |
|---|---|---|---|
| `assets/ASSETS.md` | das Register (§5) | ja | nein |
| `assets/quelle/symbole/<Name>.png` | Quellbild eines Symbols, so wie es entstanden ist (beliebige Größe, freigestellt) | ja | nein |
| `assets/quelle/modelle/<Name>/` | ~~Quell-Modell (GLB), Texturen, ggf. Referenzbild~~ bei einem Modell aus einem Skript: zwei Ansichten und `masse.json` (§7.1); bei einem Modell ohne Skript die Quelldatei selbst | ja (~~Git LFS, sobald das erste Modell kommt~~ Git LFS erst für Quelldateien ohne Skript — §7.1 Nr. 4) | nein |
| `dist/modelle/<Name>/` | erzeugtes Modell (GLB, FBX) und gebackene Texturen (§7.1) | nein (`dist/` ist ignoriert) | nein |
| `tools/assets/blender/*.py` | Blender-Skripte, aus denen Quellbilder und Quell-Modelle entstehen — die einzige Stelle mit Python (§1 Nr. 5) | ja | nein |
| `mod/<Modlet>/UIAtlases/ItemIconAtlas/<Name>.png` | das fertige Symbol, **erzeugt**, nicht von Hand bearbeitet | ja | ja |
| `unity/` | Unity-Projekt für Bundles | Teil B | nein |
| `mod/<Modlet>/Resources/*.unity3d` | Bundles | Teil B | ja |

Ein Symbol liegt in dem Modlet, das den Gegenstand trägt oder umdeutet (Vertrag 01): Rohstoffe und
Währung in `700_20_Material`, Waffen, Werkzeug und Rüstung in `700_30_Ausruestung`, Blöcke in
`700_40_Bauen`, Schriften in `700_50_Fortschritt`. XML-Modlets laden auch mit EAC; Bilder sind
Dateien, kein Code.

## 3. Teil A — Symbole

### 3.1 Format (gemessen an Vanilla, Finding F-16)

| | |
|---|---|
| Datei | PNG, 32 Bit mit Alpha |
| Größe | **160×160** Pixel |
| Hintergrund | durchsichtig; der Gegenstand freigestellt, mittig, mit mindestens 6 Pixeln Rand |
| Darstellung | ein einzelner Gegenstand, schräg von oben, weiches Licht von links oben, kein Text, keine Hand, kein Boden, kein Rahmen — so wie Vanillas Bilder |
| Stil | gebrauchte Dinge des Frühmittelalters: mattes Eisen, Holz, Leder, Leinen, Ton; kein Chrom, kein Kunststoff, keine Schrift, kein lesbares Zeichen. Eine Münze darf ein Muster aus Punkten tragen (Perlkreis) — keine Buchstaben, keine Ziffer, kein Kopf, kein Wappen. *(Geändert 2026-11-23: vorher „keine Prägung"; eine glatte Scheibe ist als Münze nicht zu erkennen.)* |

### 3.2 Namen (Ergänzung zu Vertrag 02)

- Dateiname = Name des Bildes = `ico700_<wort>` in Kleinbuchstaben, ASCII, deutsch, ohne Umlaute
  (`ico700_silberpfennig`, `ico700_schmiedeeisen`). Das Präfix verhindert, dass ein Bild den Namen
  eines Vanilla-Bildes oder des Bildes einer fremden Mod trägt — was dann geschähe, ist nicht gelesen.
- Ein Bild darf von mehreren Gegenständen benutzt werden (mit `CustomIconTint`).
- In XML: `<property name="CustomIcon" value="ico700_…" />`; bei Vanilla-Gegenständen per `append`
  bzw. `set`, wie in `700_20_Material/Config/items.xml` (Abschnitt „Bilder im Beutel").

### 3.3 Quellen, in dieser Rangfolge (D84)

1. **Umbiegen** auf ein vorhandenes Vanilla-Bild, wenn eines ohne Neuzeit passt (kein eigenes Bild).
2. **Eigenes Bild aus einem eigenen Modell** (Teil B), sobald es eines gibt — das Bild ist dann eine
   Ansicht des Modells und ersetzt ein vorläufiges.
3. **Eigenes Bild aus Grundformen** (`eigen:blender`): harte, einfache Dinge — Barren, Münze,
   Nagel, Klinge — in Blender aus Grundformen gebaut und freigestellt gerendert (D84). Das
   Blender-Skript liegt seit dem 2026-11-23 unter `tools/assets/blender/` (`symbole.py`, Starter
   `lauf.py`; N-61), das Quellbild unter `assets/quelle/symbole/`. Aufruf:
   `blender -b --factory-startup --python tools/assets/blender/lauf.py -- <stueck> <ziel.png>`. *(Ergänzt 2026-11-23; so entstand das erste Symbol.)*
4. **Erzeugtes Bild** (Meshy, Text zu Bild, freigestellt) als vorläufiges oder bleibendes Symbol.
   Freigabe des Nutzers vom 2026-11-22 (N-63). Der Beschreibungstext (Prompt) nennt nur das Ding
   und den Stil aus §3.1 — **keinen** Namen eines Spiels, einer Marke, eines Künstlers.
   **Stand 2026-11-23: nicht möglich.** Meshy lehnt jede Erzeugung über die API ab (HTTP 402,
   „Task creation on the free plan is no longer supported"), obwohl das Konto 5332 Credits trägt.
   Bis der Nutzer den Tarif wechselt (N-64), entsteht kein Meshy-Stück.

### 3.4 Was ein Bild nicht zeigen darf

Nichts aus der Denylist und nichts, was das Glossar verbietet: keine Schraube, keine Schweißnaht,
kein Draht im heutigen Sinn, kein Klebeband, kein Kunststoff, kein Glas mit Schraubdeckel, keine
Schrift und keine Ziffer, kein Kreuzzeichen der Sanität. Jedes erzeugte Bild wird vor der Aufnahme
**angesehen**; ein Bild mit einem dieser Fehler wird verworfen und neu erzeugt (im Register steht
dann nur das angenommene).

## 4. Der Befehl

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/assets/symbole.ps1 [-Pruefen]
```

| Aufruf | Tut | Exit |
|---|---|---|
| ohne Schalter | liest `assets/ASSETS.md`, erzeugt aus jedem Quellbild der Art `symbol` das fertige PNG (160×160, 32 Bit, Alpha) im Ordner des dort genannten Modlets; schreibt nur, wenn sich der Inhalt ändert | 0 = alles erzeugt; 1 = ein Quellbild fehlt, ist kein PNG mit Alpha oder kleiner als 160×160; 2 = Benutzungsfehler (Register unlesbar, Modlet unbekannt) |
| `-Pruefen` | erzeugt nichts; vergleicht, ob jedes fertige PNG dem entspricht, was aus seinem Quellbild entstünde, und ob es im Modlet-Ordner ein PNG **ohne** Registerzeile gibt | 0 = stimmt; 1 = Abweichung; 2 = Benutzungsfehler |

Zuschnitt: das Quellbild wird auf seinen sichtbaren Inhalt beschnitten (Alpha über 8 von 255 —
ein Schleier aus der Freistellung zählt nicht), mittig mit 6 Pixeln Rand in ein Quadrat gesetzt
und mit guter Filterung auf 160×160 verkleinert. Keine Farbänderung, kein Schärfen. **Vergrößert
wird nie:** zeigt ein Quellbild in der längeren Richtung weniger als 148 sichtbare Bildpunkte, ist
das Ausgang 1. Werkzeug: PowerShell mit `System.Drawing` (auf diesem Rechner vorhanden; kein
zusätzliches Paket); die Bildarbeit steht als C# in derselben Datei.

„Entspricht" heißt beim Prüfen: gleiche Größe und **kein sichtbarer Unterschied** — verglichen
werden Deckkraft und Farbe mal Deckkraft, nicht die Farbe durchsichtiger Bildpunkte. Mit
`-Pruefen` werden außerdem die Pflichtfelder jeder Registerzeile geprüft (§5); ein leeres Feld ist
Ausgang 1. *(Präzisiert 2026-11-23 beim Bau; die Fassung davor nannte „Alpha > 0" und keine
Untergrenze für den Inhalt.)*

## 5. Das Register `assets/ASSETS.md`

Eine Markdown-Tabelle, eine Zeile je Stück. Pflichtfelder:

| Feld | Inhalt |
|---|---|
| `Name` | `ico700_…` bzw. Name des Modells |
| `Art` | `symbol` · `modell` · `textur` · `klang` |
| `Modlet` | Ordnername des Modlets, in dem das fertige Stück liegt |
| `Benutzt von` | Kennungen der Gegenstände |
| `Quelle` | `meshy:<Modell>` · `eigen:blender` · `cc0:<Quelle>` · `eigen:hand` |
| `Beleg` | bei Meshy die Aufgaben-Kennung und das Datum; bei CC0 die Adresse der Datei |
| `Lizenz` | siehe §5.1 |
| `Nennung` | der Wortlaut, mit dem die Quelle genannt wird, oder „keine nötig" |
| `Beschreibung` | bei erzeugten Bildern der Beschreibungstext, wörtlich |
| `Kosten` | bei Meshy die Credits |
| `Stand` | `vorläufig` (wird durch eine Modellansicht ersetzt) · `bleibt` · `zu prüfen` |

### 5.1 Lizenz der Meshy-Ergebnisse (gelesen am 2026-11-23)

Quelle: Meshys Nutzungsbedingungen (`meshy.ai/terms-of-use`, „Last Updated: September 19, 2026"),
Abschnitt 3.2, und die Preisseite. Sinngemäß:

- **Gratis-Tarif:** Meshy bleibt Inhaber und stellt die Ergebnisse unter **CC BY 4.0** bereit,
  solange Meshy angemessen genannt wird („commercial use with attribution").
- **Bezahl-Tarife:** der Kunde ist Inhaber seiner Ergebnisse („Private & Customer owned").
- **Nicht beantwortet** von den gelesenen Seiten: ob ein API-Nutzer mit gekauften Credits als
  Bezahl-Kunde gilt; ob der Tarif zum Zeitpunkt der Erzeugung zählt; eine eigene Aussage zu Bildern;
  die Weitergabe in einer Spielmodifikation.
- Ergebnisse, die über die API entstehen, werden laut Abschnitt 2.5 **nach drei Tagen gelöscht** —
  jedes Stück wird darum sofort heruntergeladen und als Quelle ins Repository gelegt.
- Kennzeichen, die Meshy in ein Ergebnis legt (Metadaten, Wasserzeichen), werden nicht entfernt
  (Abschnitt 2.4). Der Zuschnitt in §4 verändert nur Größe und Rand.

**Gemessen am 2026-11-23:** das Konto steht auf dem **Gratis-Tarif** — die API lehnt jede
Erzeugung mit HTTP 402 ab („Task creation on the free plan is no longer supported. To continue
creating tasks, please upgrade your plan."), bei 5332 Credits Guthaben. Damit ist die offene
Frage oben für uns entschieden, bevor sie sich stellt: gekaufte Credits allein machen keinen
Bezahl-Kunden, und auf dem Gratis-Tarif entsteht über die API gar nichts (N-64).

**Folge, sobald wieder erzeugt werden kann und bis der Nutzer den Tarif nennt (N-75):** jedes Meshy-Stück wird so geführt, als gälte
CC BY 4.0 — `Lizenz` = „Meshy; CC BY 4.0, falls Gratis-Tarif, sonst Eigentum des Nutzers (N-75)",
`Nennung` = „Erstellt mit Meshy (meshy.ai) — CC BY 4.0". Die Nennung steht im Register und, sobald
ein Paket gebaut wird, in der `README` des Pakets. Das ist in beiden Fällen zulässig.

## 6. Prüfungen (werden mit Vertrag 04, Nachtrag „Prüfungen der Phase 2", gebaut)

| Prüfung | Rot, wenn |
|---|---|
| *symbole* | ein `CustomIcon` in unseren Modlets auf einen Namen zeigt, den es weder in Vanillas `Data\ItemIcons` noch als PNG unter `UIAtlases/ItemIconAtlas` eines unserer Modlets gibt; ein PNG dort nicht 160×160 mit Alpha ist; zwei Modlets ein Bild gleichen Namens tragen; ein eigenes Bild nicht `ico700_…` heißt, den Namen eines Vanilla-Bildes trägt oder von keinem `CustomIcon` genannt wird |
| *asset-register* | ein ausgeliefertes Stück keine Registerzeile hat; einer Zeile ein Pflichtfeld fehlt; `symbole.ps1 -Pruefen` abweicht |

Jede Prüfung scheitert einmal nachweislich an einem bekannt falschen Input, bevor sie zählt
(Projektregel 5). **Gebaut am 2026-11-23** — die genauen Regeln, Grenzen und die 27 Gegenproben
stehen in [Vertrag 04, „Nachtrag Prüfungen der Phase 2, Teil 1"](04-pruefwerkzeuge.md).

## 7. Teil B — Modelle und Bundles: offen

Gemessen am 2026-11-22: das Spiel läuft auf **Unity 2022.3.62f2**; auf diesem Rechner ist **kein
Unity-Editor installiert** (N-60). Vor dem ersten Modell müssen belegt sein — je als Finding, nicht
als Annahme:

1. wie ein Modlet ein Bundle mitliefert und wie XML ein Prefab darin nennt (Syntax, Ordner);
2. welche Shader ein Prefab tragen darf, damit es im Spiel richtig erscheint;
3. wie ein Gegenstand in der Hand sitzt (Halterung, Maßstab, Achsen) und was ein Block braucht;
4. ob der Editor ohne Oberfläche gebaut werden kann (ein Befehl, Exit-Code);
5. Budgets je Stück (Dreiecke, Texturgröße) — Spec 01 nennt Richtwerte;
6. wo Bundles liegen, wenn das Kern-Modlet mit EAC nicht lädt (Vertrag 01, Nachtrag — offen).

Bis dahin gilt für Modelle nur: Quellen dürfen entstehen und im Register stehen (`Stand` =
`zu prüfen`), **ausgeliefert wird keines**.

### 7.1 Quell-Modelle ohne Unity (Nachtrag 2026-11-23 — Abnahme offen, N-65)

Geschrieben mit dem ersten Quell-Modell (Rundschild, Plan-0002 WP4.2). Regelt nur, was **vor**
Unity liegt; die sechs Punkte oben bleiben offen.

1. **Die Quelle eines eigenen Modells aus Grundformen ist sein Blender-Skript**
   (`tools/assets/blender/<stueck>.py`, Quelle `eigen:blender`). Ein Befehl baut alles neu:
   `blender -b --factory-startup --python tools/assets/blender/<stueck>.py -- dist/modelle/<stueck> assets/quelle/modelle/<stueck>`.
2. **Erzeugnisse liegen nicht im Repository:** `dist/modelle/<stueck>/` trägt `<stueck>.glb`,
   `<stueck>.fbx` und die Texturen als PNG. `dist/` steht schon in der `.gitignore`. Von dort
   liest später das Unity-Projekt (WP4.4).
3. **Im Repository liegen** das Skript und unter `assets/quelle/modelle/<stueck>/` zwei Ansichten
   des fertigen Modells (`ansicht-vorn.png`, `ansicht-hinten.png`, 900×900, freigestellt) und
   `masse.json` (Dreiecke, Ecken, Ausdehnung, Texturgröße, Blender-Fassung).
4. **Git LFS wird damit noch nicht gebraucht** und ist nicht eingerichtet. Nötig wird es erst
   für ein Modell, dessen Quelle **kein** Skript ist (ein Meshy-Ergebnis, eine von Hand gebaute
   `.blend`-Datei) — dann liegt die Datei selbst unter `assets/quelle/modelle/<stueck>/` (N-65).
5. **Form eines Quell-Modells:** ein Netz, ein Stoff (`m700_<stueck>`), eine UV-Abwicklung ohne
   Überlappung, drei Texturen — `_farbe` (sRGB), `_orm` (nach glTF: Grün = Rauheit, Blau =
   Metall; Rot ist frei und steht auf 1), `_normal` (Tangentenraum, +Y). Die Texturen sind aus
   dem Aufbau des Skripts **gebacken**, nicht gemalt. Einheit Meter, Maßstab 1. Was Unitys
   Standard-Stoff braucht (Metall in Rot, Glätte im Alpha), entsteht beim Bundle-Bau (WP4.4),
   nicht hier.
6. **Lage:** ein gehaltenes Stück steht so, wie es getragen wird; der **Ursprung liegt am Griff**
   (dort sitzt die Hand). In Blender zeigt die Vorderseite nach −Y, im GLB nach +Z. Wie das Spiel
   ein Stück an die Hand hängt, ist ungelesen (Punkt 3 oben) — die Lage kann sich danach ändern.
7. **Richtwerte (zu prüfen, N-65):** ein gehaltenes Stück höchstens **3000 Dreiecke**, Texturen
   **1024²** (Spec 01 §6: Standard 1024², höchstens 2048²). Eine Zahl für Dreiecke nennt Spec 01
   nicht; an Vanillas Modellen ist sie nicht gemessen.
8. **Gemessen am Rundschild (2026-11-23, Blender 5.3.0):** 1994 Dreiecke, 1123 Ecken im Netz
   (1937 im GLB nach dem Trennen an Kanten und UV-Nähten), 86,8 cm Durchmesser, 12,1 cm tief;
   GLB 1,7 MB mit drei eingebetteten Texturen. Zwei Läufe nacheinander ergeben **dasselbe GLB und
   dieselben drei Texturen, Byte für Byte**; die FBX-Datei (Zeitstempel) und die Ansichten
   (Renderer) unterscheiden sich von Lauf zu Lauf — die Ansichten werden darum nur neu
   eingecheckt, wenn sich das Modell ändert.
9. **Register:** eine Zeile der Art `modell`, `Stand` = `zu prüfen`, `Modlet` = das Modlet, in dem
   das Stück voraussichtlich landet. Die Prüfung *asset-register* liest bei einem Modell nur die
   Pflichtfelder; **ob ein Modell im Paket liegt, prüft sie noch nicht** (kommt mit dem ersten
   Bundle).

## 8. Was dieser Vertrag nicht regelt

Klänge und Musik (Quelle CC0 braucht die Freigabe N-78), Ladebilder und Schrift (Machbarkeit offen,
Plan-0002 WP3.10), Texturen auf Vanilla-Modellen (P2-E07: nur ohne Vanilla-Datei im Bundle).
