# Vertrag 04 — Prüfwerkzeuge

- **Status:** Entwurf, wartet auf Abnahme
- **Datum:** 2026-11-07
- **Gilt ab:** Phase 1 (Plan-0001 WP2)
- **Beleg:** [WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md)

Die drei Signale, an denen die Ziele Z2, Z3 und Z4 des Plans hängen. Ohne sie ist „keine
Anachronismen" eine Behauptung.

## 1. Woher die Daten kommen — das war die offene Frage

Geprüft werden muss die **gemergte** Config: Vanilla plus unsere Patches, so wie das Spiel sie
am Ende sieht. Ein Werkzeug, das nur unsere Patch-Dateien liest, sieht nicht, was davon
tatsächlich gegriffen hat.

**Das Spiel liefert diese Daten selbst.** `ConsoleCmdExportCurrentConfigs` sagt wörtlich:

> *„Patched XMLs are automatically dumped on game start to a ConfigsDump subdirectory of the
> save game."*

Es gibt also nach **jedem** Spielstart einen Ordner mit der fertig gemergten Config. Auf diesem
Rechner liegen bereits fünf davon, zum Beispiel:

```
%APPDATA%\7DaysToDie\Saves\<Welt>\<Spielstand>\ConfigsDump\
    43 Dateien, 15 MB, items.xml mit 32.052 Zeilen
```

Dazu der Konsolenbefehl `exportcurrentconfigs`, der auch im Hauptmenü läuft — dort allerdings
nur mit `rwgmixer`, `loadingscreen` und den `XUi_Menu`-Dateien („No game started, exporting XUi
menu and rwgmixer configs").

**Damit muss kein Werkzeug den XML-Patcher nachbauen.** Das war der teure Weg, und er ist nicht
nötig.

### Zwei Betriebsarten

| Art | Eingabe | Was sie beweist | Braucht Spielstart |
|---|---|---|---|
| **Vorlauf** | `Data/Config/` des Spiels + unsere Modlet-Dateien | Formfehler, Denylist-Treffer in unseren eigenen Patches, Localization-Form | nein |
| **Nachweis** | ein `ConfigsDump/` | den tatsächlichen Endzustand | **ja**, einmal pro Prüfung |

Der Vorlauf läuft bei jeder Änderung und ist billig. Der Nachweis zählt für die
Erfolgskriterien. **Nur der Nachweis darf „grün" heißen.** Der Vorlauf sagt „nichts gefunden",
was nicht dasselbe ist.

## 2. Ein Werkzeug, drei Befehle

Wie `mod700meta`: ein C#-Projekt, mehrere Unterbefehle. **Kein Python** (globale Regel).

```
tools/check/Mod700.Check/           → mod700check.exe
```

```
mod700check anachronisms <ordner> [--denylist <datei>] [--json]
mod700check recipes      <ordner> [--from <kennung>] [--json]
mod700check localization <datei>  [--sprachen english,german] [--json]
```

`<ordner>` ist entweder ein `ConfigsDump/` oder ein `Data/Config/`. Das Werkzeug erkennt am
Inhalt, welche Art es ist, und schreibt es in die Ausgabe — damit in keinem Bericht ein Vorlauf
als Nachweis durchgeht.

### Gemeinsame Regeln für alle drei

| Punkt | Festlegung |
|---|---|
| Ausgabe | JSON auf stdout, wie `mod700meta`: `tool`, `command`, `source`, `counts`, `findings`, `summary`, `limitations` |
| `summary.verdict` | `green` oder `red` |
| Exit-Code | **0** bei grün, **1** bei rot, **2** bei Benutzungsfehler |
| Lesbare Fassung | ohne `--json` eine kurze Tabelle für Menschen, mit demselben Exit-Code |
| Keine Schreibzugriffe | die Werkzeuge lesen, sie ändern nichts |
| Herkunft | jede Ausgabe nennt den geprüften Ordner, seinen Zeitstempel und ob es ein Dump oder Vanilla war |
| Grenzen | jede Ausgabe trägt `limitations`, wie `mod700meta` es tut |

## 3. `anachronisms` — Z2

**Prüft:** Kommt ein verbotener Gegenstand noch irgendwo vor, wo ein Spieler ihn erreichen kann?

Erreichbar heißt: in `loot.xml`, in `recipes.xml`, in einer Händlergruppe in `traders.xml`, in
der Startausrüstung, als Quest-Belohnung in `quests.xml`.

**Nicht** geprüft wird die bloße Existenz in `items.xml` — gesperrte Gegenstände bleiben
absichtlich stehen ([Vertrag 03](03-xpath-regeln.md) §4), weil Prefabs auf sie zeigen.

**Denylist** als eigene Datei (`tools/check/denylist.txt`), eine Regel pro Zeile, Kommentare mit
`#`:

```
# Schusswaffen und Munition
gun*
ammo*
# Fahrzeuge
vehicle*
# ... Elektronik, Konserven, Medikamente, Treibstoff, Beton, Industriestahl
```

~~**Ausnahmen sind Pflicht, nicht Kür.** D9 verlangt, dass Geschütztürme, Generator, Kabel,
Schalter, Sensoren und Sprengstoff als *Klassen* erhalten bleiben, weil F-15 sie in Phase 2
umdeutet. Die Denylist bekommt darum eine Freigabeliste, und jeder Eintrag darin trägt eine
Begründung:~~

```
!autoTurret        # D9: wird in Phase 2 der Runenstein der Glut (F-15)   ← GESTRICHEN
!electricWire      # D9: wird die Odem-Leitung                            ← GESTRICHEN
```

**Gestrichen in WP3.1, und zwar als Kategorienfehler.** Eine Freigabe sagt „dieser Gegenstand
darf erreichbar sein" — nicht „diese Klasse bleibt im Spiel". F-01 sagt wörtlich, es sperre
*„nur ihre modernen Varianten (Namen, Rezepte, Loot)"* und erhalte die Logik; Rezepte und Loot
sind genau das, was dieses Werkzeug messen kann, die Klasse sieht es nie. Mit diesen Freigaben
wären `autoTurret`, `generatorbank`, `solarbank`, `batterybank` und ein Dutzend mehr in Phase 1
herstellbar geblieben — und das Werkzeug hätte dazu „0 rot" gemeldet. **D9 wird in
[Vertrag 03](03-xpath-regeln.md) §4 gewahrt** (kein `remove` auf die Definition), nicht hier.
Freigaben gelten nur noch für Vanilla-Namen, die gar kein Anachronismus sind (D54, D55, D56).
Beleg: [WP3-bestandsaufnahme-anachronismen.md](../rea/findings/WP3-bestandsaufnahme-anachronismen.md).

**Gegenprobe (Projektregel 5):** Ein `gunPistol`-Eintrag wird in eine Loot-Gruppe des Prüfordners
eingeschmuggelt, das Werkzeug muss **rot** werden und genau diesen Eintrag nennen. Erst dann
zählt ein späteres Grün. Das Ergebnis gehört in `tools/check/README.md`.

## 3a. Urteil nach Eigenschaften (Nachtrag WP3.1)

- **Status:** abgenommen 2026-11-07, **gebaut** 2026-11-07 (WP3.1b). Die Regeltabelle unten
  wurde beim Bau an drei Stellen berichtigt, siehe den Kasten dort.
- **Anlass:** Die Namensmuster haben in WP3.1 dreimal auf drei Wegen versagt, und 844 der
  1129 erreichbaren Kennungen hat die Liste nie angesehen. Ein viertes Namensmuster-Versagen
  ist wahrscheinlicher als keines.

**Stand nach dem Bau, gegen Vanilla gemessen:**

| Zähler | Wert |
|---|---|
| geprüfte Kennungen | 1129 |
| verboten nach **Eigenschaft** | **61** |
| verboten durch **Mod-Ableitung** | **22** |
| verboten nach **Name** | 215 |
| verbotene Kennungen gesamt | **298** (vorher 254) |
| ungeprüft | 800 (vorher 844) |
| unauflösbar | 11 |
| ohne Eigenschaft | 126 |
| `Extends`-Tiefe erreicht | 0 |

`verboten_nach_name` = 215 ist die ehrliche Restzahl: so viel hängt noch an Namensmustern.
Die 83 neuen Treffer sind das, was die Eigenschaften zusätzlich fanden.

### Die Grundregel

**Wo Vanilla eine Eigenschaft führt, die etwas bedeutet, entscheidet die Eigenschaft. Wo
Vanilla keine führt, entscheidet der Name — und das Werkzeug sagt, welche Regel entschied.**

Der zweite Halbsatz ist kein Rückzug, sondern gemessen. Nicht alles, was wir trennen müssen,
trennt Vanilla auch:

| Gegenüberstellung | Group | Tags | trennbar? |
|---|---|---|---|
| `gunHandgunT1Pistol` / `gunBowT1WoodenBow` | gleich | `gun` ↔ `bow,archery` | **ja, über Tags** |
| `switch`, `motionsensor`, `generatorbank` | `Science,TCScience` | gleich | **ja, über Block-`Class`** |
| `gunHandgunPistolAdmin` | `Special Items` | enthält `admin` | **ja** |
| `foodCanTuna` / `foodRawMeat` | **gleich** | **gleich** | **nein** |
| `medicalFirstAidKit` / `medicalBandage` | fast gleich | **gleich** | **nein** |
| `airConditioner` | **fehlt** | nur `challenge_*` | **nein** |

Für Konserven, Medikamente und Einzelgänger wie das Klimagerät bleibt der Name das einzige
Signal, das Vanilla hergibt. Das steht hier, damit niemand später eine Eigenschaft sucht, die
es nicht gibt.

### Drei Definitionsquellen, nicht eine

| Quelle | Element | erreichbare Kennungen daraus |
|---|---|---|
| `items.xml` | `item` | 788 |
| `blocks.xml` | `block` | 163 |
| `item_modifiers.xml` | `item_modifier` | 95 |

Dazu 73 Loot-Gruppennamen und rund zehn Sonderfälle (`quest_tier1complete`,
`*Shapes:VariantHelper`, `Influence`), die keine Gegenstände sind. **Eine erreichbare Kennung,
die sich auf keine der drei Quellen auflöst, wird als `unaufloesbar` berichtet — nie
stillschweigend als grün.**

### `Extends` muss aufgelöst werden

Ohne Vererbung haben **328** der 1129 erreichbaren Kennungen eine `Group`, mit Vererbung
**932**. Wer `Extends` nicht verfolgt, hält zwei Drittel für eigenschaftslos und fällt auf den
Namen zurück, ohne es zu merken. Die Tiefe ist begrenzt und die Grenze wird berichtet; eine
Kette, die anstößt, ist ein Befund, keine stille Null.

### Die Eigenschaftsregeln

| Regel | Woran | Trifft (gemessen) |
|---|---|---|
| `schusswaffe` | Item-`Tags` enthält `gun` | **19** Feuerwaffen, **kein** Bogen. Bögen tragen `bow`/`archery`/`crossbow` |
| `patronenmunition` | Item-`Tags` enthält `ammo9mm` oder `ammo762mm` | **6** von 28 Munitionssorten |
| `entwicklergegenstand` | Item-`Tags` enthält `admin` **oder** eigene `Group` ist `Special Items` — in §3b um `CreativeMode = Dev` erweitert | **13** + **28** |
| `strom` | Block-`Class` ∈ `Powered`, `PoweredLight`, `PoweredDoor`, `Generator`, `SolarPanel`, `Switch`, `TimerRelay`, `MotionSensor`, `PressurePlate`, `TripWire`, `Spotlight`, `Speaker`, `SpeakerTrader`, `VendingMachine`, `Mine` | **108** Blöcke |
| `elektrikerhandwerk` | Block- oder Item-`Tags` enthält `electricianSkill` | **97**, Zweitsignal zur Zeile darüber |

Jede Regel trägt im Werkzeug eine **Begründung in einem Satz**, und der Befund nennt sie. Ein
Befund ohne nachlesbare Regel ist kein Befund.

#### Berichtigt beim Bau (2026-11-07): drei Zeilen hielten der Messung nicht stand

Die Tabelle oben steht so erst **nach** dem Gegenlauf gegen Vanilla. Der erste Entwurf dieses
Abschnitts war an drei Stellen falsch, und zwar weil ich Einzelfälle angesehen und daraus
Mengen geschlossen hatte:

| Entwurf sagte | Messung sagt |
|---|---|
| Munitionsregel deckt auch `ammo44Magnum` und `ammoShotgun` | **Diese Tags gibt es nicht.** Nur `ammo9mm` und `ammo762mm`; Schrot und Magnum bleiben beim Namen |
| `Group = Special Items` trifft „die vier Admin-Items und die zehn `TEST_ITEM_*`" | Trifft **28** Entwickler- und Vorlagen-Gegenstände und **keinen einzigen** `TEST_ITEM`: die tragen `Group = Decor/Miscellaneous` und `Tags = ammo` |
| Admin-Regel trifft 4 | trifft **13** |

**Und eine vierte Zahl war ein Fehler in meinem eigenen Messskript.** Ein erster Lauf meldete
533 Treffer für `Group = Special Items`; ein zweites Skript sagte 25, und `grep` auf die rohe
Datei sagt **28**. Das erste Skript war fehlerhaft — die Zahl wäre beinahe in diesen Vertrag
gewandert. Es war in dieser Arbeit die **dritte** Stelle, an der ein selbstgebauter Helfer
lockerer gelesen hat, als er aussah (nach `IgnoreCase` und den XML-Kommentaren).

**Daraus die Regel für diesen Vertrag:** Zahlen in Dokumenten kommen aus dem **Werkzeug** oder
aus einem Befehl, den man in einer Zeile nachlesen kann — nicht aus einem Hilfsskript, das
niemand gegengeprüft hat. Das Werkzeug hat Gegenproben, das Hilfsskript hat keine.

### Mods werden abgeleitet, nicht aufgezählt

Ein `item_modifier` trägt `installable_tags`. Daraus folgt sein Urteil **ohne eine eigene
Regel**: *ein Mod fällt, wenn jeder Gegenstand, auf den er passt, selbst gesperrt ist.*

```
modGunSoundSuppressorSilencer  installable_tags="gun"            -> fällt mit den Schusswaffen
modGunScopeLarge               installable_tags="largeTopAttachments" -> fällt, der Schlitz gibt es nur an Gewehren
modGunBowArrowRest             installable_tags="bow"            -> bleibt, der Bogen bleibt (D54)
modMeleeSerratedBlade          installable_tags="knife,machete,…" -> bleibt
```

Das trifft die 95 erreichbaren Mods, ohne 95 Zeilen zu schreiben, und es bleibt richtig, wenn
sich eine Entscheidung über die Waffen ändert. Läuft als **zweiter Durchgang**, nachdem die
Gegenstände beurteilt sind.

### Was der Bericht zusätzlich ausweisen muss

| Zähler | Warum |
|---|---|
| `verboten_nach_eigenschaft` | wie viel auf Daten ruht |
| `verboten_nach_name` | wie viel auf meinem Gedächtnis ruht — diese Zahl soll fallen |
| `unaufloesbar` | Kennungen ohne Definition in den drei Quellen |
| `ohne_eigenschaft` | aufgelöst, aber keine Eigenschaft vorhanden |
| `extends_tiefe_erreicht` | abgebrochene Vererbungsketten |

### Gegenproben (Projektregel 5), verbindlich — alle fünf gebaut und grün

Der Prüfsatz liegt unter `tools/check/testdaten/eigenschaften/`. Alle Kennungen darin beginnen
mit `pruef`, und **keine Namensregel der Denylist passt auf sie**: was dort rot wird, wird
allein durch eine Eigenschaft rot. In Vanilla wäre das nicht zu trennen — dort könnte immer
auch zufällig ein Namensmuster gegriffen haben.

| | Gegenprobe | Erwartung |
|---|---|---|
| 1 | `anachronisms eigenschaften` | `pruefFeuerrohr` fällt (`[schusswaffe]`), `pruefSelbstbogen` **nicht** — gleiche `Group`, nur die Tags trennen |
| 2 | `--ohne-regel strom` | `pruefKraftstein` erscheint **nicht** mehr — fiele er weiter, hätte nicht die Regel entschieden |
| 3 | `anachronisms eigenschaften` | `unaufloesbare-kennung: pruefGeisterding` steht in der Ausgabe |
| 4 | `--no-extends` | `pruefKraftsteinVariante` erscheint **nicht** mehr — sie erbt ihre Klasse |
| 5 | `anachronisms eigenschaften` | `pruefModRohrAufsatz` fällt über `mod-ohne-ueberlebenden-traeger`, `pruefModBogenauflage` bleibt |

Dazu: eine unbekannte Regel-Kennung bei `--ohne-regel` ist Exit 2, kein Befund.

Die Gegenproben 1, 3 und 5 prüfen die **Ausgabe**, nicht nur den Exit-Code. Dass ein Lauf rot
ist, sagt noch nicht, dass er das Richtige gefunden hat — `gegenproben.ps1` hat dafür ein
zweites Hilfsmittel (`Test-Output`) bekommen.

### Was dieser Nachtrag nicht behauptet

Eigenschaften sind kein Verständnis, nur ein besseres Signal als Namen. `cementMixer` und
`forge` tragen dieselbe `Group` und dieselben `Tags`; nur die `Class` trennt sie
(`Workstation` gegen `Forge`), und das ist Zufall, nicht Absicht der Spielentwickler. Die
Werkstätten bleiben darum eine kurze Liste von Hand. **Der Nachweis bleibt in jedem Fall der
`ConfigsDump`-Lauf nach einem Spielstart mit den Modlets, nicht der Vorlauf gegen Vanilla.**

## 3b. Jede Kennung bekommt ein Urteil (Nachtrag WP3.1c) — **Abnahme offen**

> **Status:** gebaut und gemessen, aber **nicht abgenommen.** §3a hat der Nutzer am
> 2026-11-07 abgenommen; dieser Abschnitt geht darüber hinaus. Was hier steht, ist im
> Werkzeug und in `denylist.txt`/`aufschub.txt` schon umgesetzt — das war nötig, um die
> Zahlen überhaupt messen zu können. Bevor die XPath-Patches von WP3.2 geschrieben werden,
> gehört dieser Abschnitt abgenommen oder geändert.

### Das Problem, das §3a offengelassen hat

§3a hat das Urteil besser gemacht, aber nicht vollständig. Nach WP3.1b standen **512** von
1129 erreichbaren Kennungen auf `ungeprueft`: keine Eigenschaft, kein Name, kein Urteil.
Diese Zahl war die ehrlichste im Bericht und die unangenehmste — sie heisst nicht „harmlos",
sondern „niemand hat hingesehen". Ein Werkzeug, das 512 Kennungen stillschweigend durchlässt
und daneben „356 verboten" meldet, lädt dazu ein, die zweite Zahl für die Arbeit zu halten.

### Die Grundregel dieses Nachtrags

**Jede erreichbare Kennung bekommt genau ein Urteil, und `ungeprueft` ist kein Urteil.**
Die fünf möglichen Ausgänge:

| Ausgang | Bedeutung | Zähler |
|---|---|---|
| verboten | Anachronismus, fällt in Phase 1 | `verbotene_kennungen` |
| aufgeschoben | Anachronismus, fällt in einem **genannten** Arbeitspaket | `aufgeschoben` |
| durch Freigabe erlaubt | angesehen, **kein** Anachronismus | `durch_freigabe_erlaubt` |
| abgeleitet | folgt aus den Daten (Mod-Träger, `Unlocks`) | `*_ableitung` |
| Loot-Gruppe | kein Gegenstand, die Mitglieder werden einzeln beurteilt | `loot_gruppen_erreichbar` |

`ungeprueft` muss **0** sein. Steigt die Zahl nach einem Spiel-Update, ist das kein Mangel
des Werkzeugs, sondern neuer Inhalt, der ein Urteil braucht.

### Vier zusätzliche Eigenschaftsregeln

Die Zahlen hier zählen **erreichbare** Kennungen, nicht Definitionen — darum sind sie
kleiner als die in §3a. Gemessen gegen Vanilla V 3.40 `Data/Config`.

| Regel | Woran | Trifft (gemessen) |
|---|---|---|
| `sprengkoerper` | Item-`Class` ist `ItemClassTimeBomb` | **6**: Molotow, Rohrbombe, Dynamit, zwei Granaten, Zeitladung |
| `robotik` | `Tags` enthält `roboticsSkill` | **7** |
| `moderner_werkstoff` | `Tags` enthält `challenge_elec_parts`, `challenge_polymers`, `challenge_mech_parts`, `challenge_cars` oder `challenge_sinks` | **15** |
| `entwicklergegenstand` (erweitert) | zusätzlich: `CreativeMode = Dev` | 3 → **13** |

Drei Begründungen, die zum Vertrag gehören:

- **Warum `ItemClassTimeBomb` und nicht `explosivesSkill`.** Der Tag wäre das naheliegende
  Signal und ist unbrauchbar: Vanilla hängt auch `resourceLockPick` daran, weil derselbe
  Perk beides trägt. Ein Dietrich ist kein Sprengkörper. Der Prüfling `pruefWurfglut` trägt
  den Tag darum **nicht** und muss trotzdem fallen — sonst wäre die Gegenprobe keine.
- **Warum `CreativeMode = Dev`.** Das ist Vanillas eigene Aussage „nur für die
  Spielentwickler". Weder `Tags = admin` noch `Group = Special Items` trifft die sechs
  `tier0xLoadout`, und die teilen über `Create_item` Schmerzmittel, Metallrohre und
  Yuccafasern aus. Sie erben ihr `Dev` von `noteTestersDelightAdmin`, also muss die
  Eigenschaft über `Extends` vererbt werden (wie `Tags` und `Class`).
- **Warum `moderner_werkstoff` als letzte Regel steht.** Die Marke sagt „besteht aus", nicht
  „ist modern". Das ist ein mittelbares Signal, und jede andere Regel soll zuerst urteilen
  dürfen, damit der Befund den aussagekräftigeren Grund nennt. `challenge_leather` steht
  bewusst **nicht** in der Liste: Leder gab es um 700.

**Nicht verwendet, obwohl es gepasst hätte:** der Tag `biomeChallenge` trifft alle 62 Teile
von Vanillas 16 modernen Rüstungsgarnituren und keines der vier Primitiv-Teile — eine Regel,
eine Zeile, 62 Treffer. Er bedeutet aber „zählt für den Biom-Fortschritt", nicht „modern".
Eine Regel, die nur zufällig richtig liegt, ist keine Eigenschaftsregel; die 16 Garnituren
stehen darum als 16 Namen in `denylist.txt` und zählen unter `verboten_nach_name`. Das ist
die Zeile, an der dieser Nachtrag am ehesten widersprochen werden kann.

### Die `Unlocks`-Ableitung gilt in beide Richtungen

§3a hatte nur die eine Hälfte: fällt das Freigeschaltete, fällt der Bauplan. Die andere
Hälfte fehlte, und darum standen **37** Baupläne auf `ungeprueft` — für eine Frage, die in
den Daten beantwortet ist.

```
pruefBauplanRohr   Unlocks="pruefFeuerrohr"    -> fällt mit ihm   (schaltet-gesperrtes-frei)
pruefBauplanBogen  Unlocks="pruefSelbstbogen"  -> bleibt mit ihm  (schaltet-erlaubtes-frei)
```

Gemessen: **27** fallen, **24** bleiben. Welche Baupläne es am Ende überhaupt noch gibt,
entscheidet F-21 in WP7 (D47); hier geht es nur darum, ob F-01 etwas gegen diesen einzuwenden
hat.

### Aufschub: eine Umbuchung, kein Bestanden

Eine Kennung in `aufschub.txt` ist **als verboten erkannt** und wird aus den Fehlern in die
Hinweise umgebucht. Sie zählt unter `aufgeschoben`, nie unter „bestanden". **Jede Zeile muss
ein Arbeitspaket nennen** (`WP<n>`); ohne WP-Verweis bricht das Werkzeug mit Exit 2 ab. Ein
Aufschub ohne Adresse ist kein Aufschub, sondern ein Loch mit guter Presse: niemand weiss,
wer es schliesst, und beim nächsten Lauf sieht es aus wie eine getroffene Entscheidung.

Gemessen: **170** aufgeschoben — 157 nach WP7 (Vanillas Buchsystem, D47, Entscheidung des
Nutzers vom 2026-11-07), 10 nach WP4 (Währung, Faserkette, Schrottwirtschaft), 2 nach WP5
(Reparatur- und Rüstbau-„Kits"), 1 nach WP8 (Dukes Brief in der Startausrüstung).

Der Aufschub läuft als **letzter** Durchgang, damit auch das aufgeschoben wird, was erst eine
Ableitung gefunden hat.

### Was eine Freigabe heisst — und was nicht

Eine Freigabe (`!muster`) heisst: **angesehen, und es ist kein Anachronismus.** Sie heisst
nicht „später prüfen" und nicht „diese Klasse bleibt im Spiel". Sie schlägt jedes Verbot und
jede Eigenschaftsregel, auch die Ableitungen.

Daraus folgt der neue Zähler **`freigaberegeln_ohne_treffer`**. Er ist wichtiger als sein
Gegenstück bei den Verboten: eine Verbotsregel, die nicht greift, lässt etwas **durch**, und
das erscheint beim nächsten Lauf als Befund. Eine Freigabe, die nicht greift, lässt etwas
**fallen** — und ein Befund mehr sieht aus wie Arbeit, die getan wurde, nicht wie ein Fehler.
Niemand sucht nach einer Sperre, die zu viel sperrt. Beide Zähler müssen **0** sein; beide
Hinweise nennen das **Muster**, nicht nur Datei und Zeile.

### Zusätzliche Zähler dieses Nachtrags

| Zähler | Warum |
|---|---|
| `ungeprueft` | muss 0 sein; jede Kennung braucht ein Urteil |
| `aufgeschoben` / `aufschubregeln` | wie viel erkannt, aber verschoben ist |
| `erlaubt_durch_unlocks_ableitung` | Baupläne, die Erlaubtem folgen |
| `verbotsregeln_ohne_treffer` / `verbotsregeln_verdeckt` | Tippfehler gegen Redundanz getrennt |
| `freigaberegeln_ohne_treffer` | der gefährlichere Tippfehler |

### Der Befehl `ungeprueft`

`mod700check ungeprueft <ordner> [--denylist <datei>] [--praefix <anfang>] [--nur-zahlen]`
listet, was noch kein Urteil hat, gruppiert nach Namensanfang, mit den Eigenschaften daneben.
Er ist die Arbeitsliste der Sichtung und endet **immer** mit Exit 0 — er ist keine Prüfung.
Er benutzt dasselbe `Judgement` wie `anachronisms`; als die Liste eine eigene Fassung hatte,
meldete sie 822 und die Prüfung 800.

### Gegenproben dieses Nachtrags — alle fünf gebaut und grün

| | Gegenprobe | Erwartung |
|---|---|---|
| 6 | `anachronisms eigenschaften` | `pruefWurfglut` fällt über `[sprengkoerper]` — ohne den Tag `explosivesSkill` |
| 7 | `anachronisms eigenschaften` | `pruefDevKiste` fällt über `[entwicklergegenstand]` — nur `CreativeMode=Dev` |
| 8 | `anachronisms eigenschaften` | `pruefLadenkasse` fällt über `[moderner_werkstoff]` — Klasse bewusst nicht in der Stromliste |
| 9 | `anachronisms eigenschaften` | `pruefBauplanRohr` fällt, `pruefBauplanBogen` **nicht** |
| 10 | `--denylist denylist-tote-freigabe.txt` | `freigaberegel-trifft-nichts` nennt das Muster |

Dazu die drei Aufschub-Gegenproben aus WP3.1b (umbuchen, `--ohne-aufschub`, Exit 2 ohne
WP-Verweis) und die Regelprüfung (`verbotsregel-trifft-nichts`).

**Lauf vom 2026-11-07: 28 Gegenproben, 0 fehlgeschlagen.**

### Was dieser Nachtrag nicht behauptet

Jede Kennung hat ein Urteil — nicht jedes Urteil ist richtig. **441 von 592** Sperren ruhen
weiter auf einem Namensmuster und damit auf meinem Urteil über Vanilla-Inhalt, nicht auf
Daten. Die Zahl ist gestiegen, nicht gefallen, und das ist kein Rückschritt: vorher ruhten
512 Kennungen auf **nichts**. Wo die Sichtung inhaltlich entschieden hat, steht die
Begründung in der Zeile, und drei Gruppen gehören ausdrücklich dem Nutzer vorgelegt:

1. **16 Rüstungsgarnituren fallen, nur `armorPrimitive*` bleibt.** Bis WP5 (F-03) hat der
   Spieler keine andere Rüstung. F-01 sagt „Nicht im Umfang: Ersatzinhalte" — die Lücke ist
   eingeplant, aber sie ist spürbar.
2. **Pflanzen der Neuen Welt fallen:** Mais, Kartoffel, Kürbis, Blaubeere, Yucca — dazu
   Kaffee, Chrysantheme und Baumwolle. Das nimmt Vanilla den halben Ackerbau; Yuccafaser und
   Baumwolle sind darum nach WP4 aufgeschoben, die Nahrung nicht.
3. **Werkstätten:** `forge`, `campfire`, `workbench`, Amboss, Blasebalg, Schmelztiegel,
   Kochtopf, Bienenstock und Hühnerstall bleiben; Betonmischer, Chemiestation,
   „Combine Station", Becherglas, Tauwassersammler und Wärmelampe fallen.

**Der Nachweis bleibt der `ConfigsDump`-Lauf nach einem Spielstart mit den Modlets.** Dieser
Nachtrag ist gegen Vanilla gemessen, und das ist ein Vorlauf.

## 3c. `purge-patch` — das Werkzeug schreibt das Modlet (Nachtrag WP3.2)

> **Status:** gebaut, gemessen, mit fünf Gegenproben. Dass die Patches **erzeugt** statt von Hand
> geschrieben werden, ist eine Erweiterung dieses Vertrags und steht auch in Vertrag 03 §4.

### Warum ein Werkzeug und keine Handarbeit

592 gesperrte Kennungen verteilen sich auf sieben Vanilla-Dateien. Von Hand geschrieben heißt
das: dieselbe Liste zweimal führen, einmal in `denylist.txt` und einmal im Modlet. Zwei Listen
laufen auseinander, und `anachronisms` sieht den Unterschied **nicht** — es liest die gemergte
Config des Spiels, nicht unsere Patch-Dateien. In dieser Arbeit sind schon dreimal Zahlen
auseinandergelaufen, weil dieselbe Frage an zwei Stellen beantwortet wurde.

```
mod700check purge-patch <quelle> --out <ordner> [--denylist <datei>] [--aufschub <datei>]
                                 [--vergleiche] [--trocken] [--zeigen] [--ohne-entfernen] [--json]
```

Erzeugt wird **gegen Vanilla**, nie gegen einen Dump mit unseren Modlets — dort wären die
Patches leer, weil die Wege schon weg sind.

### Drei verbindliche Eigenschaften

1. **Der XPath kommt aus den Daten.** Für jedes zu entfernende Element wird der Pfad aus der
   tatsächlichen Elternkette im Quell-XML gebaut (`/recipes/recipe[@name='X']`). Ein Schema, das
   der Autor falsch erinnert, kann nicht in die Patches geraten; eine Verschachtelung, die er
   nicht kennt, wird trotzdem getroffen.
2. **`set` oder `append` entscheidet die Quelle, nicht eine Annahme.** Eigene Eigenschaft →
   `set` auf den Wert. Geerbte oder fehlende → `append`, das die geerbte überschreibt. Ein `set`
   auf eine Eigenschaft, die es nicht gibt, trifft nichts und schweigt.
3. **Aufgeschobenes wird nicht gepatcht.** Die 170 Kennungen aus `aufschub.txt` sind als verboten
   erkannt und bleiben erreichbar, bis ihr Arbeitspaket sie ersetzt. Der Bericht weist sie als
   `aufgeschoben_nicht_gepatcht` aus.

### Die Zähler

| Zähler | muss | Warum |
|---|---|---|
| `patches_ohne_treffer` | 0 | eine Patch-Zeile, die im Quell-XML kein Element trifft, tut nichts und fühlt sich wie Arbeit an |
| `wege_uebrig` | 0 | nach den Entfernungen darf auf diesem Weg keine gesperrte Kennung mehr stehen |
| `remove_auf_definition` | 0 | Vertrag 03 §4 und D9: `remove` trifft Wege, nie eine Definition |
| `patchdateien_abweichend` | 0 | bei `--vergleiche`: das Modlet entspricht der heutigen Denylist |
| `gesperrt_und_noch_erreichbar` | 0 | die Gesamtprobe: alle Zeilen zusammen auf Kopien angewandt, Erreichbarkeit neu gerechnet |

Stand WP3.2 bis WP3.4 gegen Vanilla V 3.40: **1780 Patchzeilen** (items.xml 437, blocks.xml 106,
recipes.xml 369, loot.xml 467, traders.xml 348, quests.xml 50, entityclasses.xml 3), alle fünf
Zähler 0.

### Listen werden gekürzt, nicht entfernt

Vanilla hat 256 Quest-Belohnungen, deren `id` eine kommagetrennte Liste ist
(`groupQuestFood,groupQuestAmmo,groupQuestSchematics`), und die Startausrüstung ist ebenfalls
eine. Verbindlich:

- nur gesperrte Einträge in der Liste → der Eintrag fällt (`remove`),
- gemischt → die Liste wird gekürzt (`setattribute`), der Eintrag bleibt,
- Stückzahlen bleiben erhalten: aus `drinkJarBoiledWater=2,foodCanChili` wird
  `drinkJarBoiledWater=2`, nicht `drinkJarBoiledWater`.

Wer hier blind `remove` nimmt, nimmt dem Spieler die erlaubten Einträge derselben Liste mit —
und bei der Startausrüstung startet er mit leeren Händen.

### Die Gesamtprobe

Jede Datei einzeln zu prüfen sagt **nicht**, ob der Satz zusammen alle fünf Wegarten schließt:
eine Kennung, die nur noch in der Startausrüstung steht, wäre in jeder Einzelprobe grün. Darum
werden alle erzeugten Zeilen auf Kopien angewandt und die Erreichbarkeit auf dem Ergebnis neu
gerechnet — mit demselben `Reachability`, das `anachronisms` benutzt, über eine Quelle, deren
Dateien im Speicher ersetzt sind. Keine zweite Fassung derselben Frage.

Gemessen: **0**. Mit `--ohne-entfernen`: **592**.

### Leere Loot-Gruppen — ein benannter Nebeneffekt

F-01 sagt „Loot-Tabellen leeren bzw. umbiegen". Geleert wird: der Eintrag fällt, die Gruppe
bleibt stehen, weil Behälter und Quest-Belohnungen auf ihren Namen zeigen und ein fehlender Name
hart bricht. Ergebnis: **217 von 1016** Gruppen enthalten nach dem Patch keinen Eintrag mehr. Der
Bericht weist das als `loot_gruppen_leer_danach` aus.

Ob das Spiel eine leere Gruppe stillschweigend hinnimmt, eine Protokollzeile schreibt oder beim
Würfeln abbricht, ist **ungeprüft** und wird hier nicht behauptet. Es ist der erste Punkt, den der
Protokolllauf in WP3.6 beantworten muss.

### Gegenproben (Projektregel 5) — fünf gebaut und grün

Der Prüfsatz liegt unter `tools/check/testdaten/purge/`.

| | Gegenprobe | Erwartung |
|---|---|---|
| 11 | `purge-patch purge --zeigen` | `set` für `pruefFeuerrohrEigen`, `append` für `pruefFeuerrohrGeerbt`, `pruefSelbstbogen` in **keiner** Zeile Ziel |
| 12 | `purge-patch purge` | `wege_uebrig 0` **und** `gesperrt_und_noch_erreichbar 0` — `pruefFeuerrohrEigen` hat **zwei** Rezepte |
| 13 | `--ohne-entfernen` | Exit 1, `weg-bleibt-offen` **und** `gesperrt-trotz-patch` — der Nachweis, dass beide Nachproben etwas prüfen |
| 14 | `--vergleiche` gegen einen leeren Ordner | Exit 1, `patchdatei-fehlt` |
| 15 | ohne `--out` und ohne `--trocken` | Exit 2 |
| 16 | `purge-patch purge --zeigen` | gemischte Belohnungsliste wird **gekürzt**, die rein gesperrte entfernt; kein `remove` auf die gemischte |
| 17 | `purge-patch purge --zeigen` | Startausrüstung gekürzt, `pruefSelbstbogen=2` behält die Stückzahl, XPath mit Prädikaten bis zur Entity-Klasse |

Dazu ein Nachweis an der echten Quelle, am 2026-11-07: eine Änderung am Kopftext machte die drei
Dateien im Modlet `patchdatei-veraltet` (Exit 1), die Neuerzeugung machte sie wieder grün. Ein
Vergleich, der nie rot wird, wäre kein Vergleich.

### Was dieser Nachtrag nicht behauptet

Patches und Prüfung stammen aus **demselben Urteil**. Dass beide zusammenpassen, sagt nur, dass
sie zueinander passen — es ist Selbstbestätigung, kein Nachweis. Der Nachweis ist der Weg über
das Spiel: Patch → Spielstart → `ConfigsDump` → `anachronisms`. Erst dort entscheidet der
XML-Patcher des Spiels, ob ein XPath wirklich getroffen hat; ist eine Zeile formal falsch, steht
die Kennung im Dump noch und die Prüfung wird rot. Das ist WP3.6 und braucht den Nutzer.

Die Gesamtprobe rechnet ebenfalls mit meinem XPath, nicht mit dem Patcher des Spiels. Sie ist das
Beste, was ohne Spielstart zu haben ist, und sie ist kein Nachweis.

Und: `CreativeMode="None"` ist **keine Sperre für den Spieler.** Es nimmt den Gegenstand aus dem
Kreativmenü und aus der Entwicklerliste, nicht aus dem Spiel. Unerreichbar wird er allein durch
die entfernten Wege.

Was dem Spieler *statt* der gesperrten Startausrüstung gegeben wird, steht nicht hier: das ist
eine Entscheidung und folgt aus keiner Liste. Sie steht von Hand in
`mod/700_30_Ausruestung/Config/entityclasses.xml`. Die Grenze zwischen den beiden Modlets ist
damit auch die Grenze zwischen erzeugt und geschrieben: `700_10_Purge` nimmt weg, was aus der
Denylist folgt; alles, was dazukommt, gehört in die späteren Modlets (D53).

## 3d. Der sechste Weg: Block-Abwürfe (Nachtrag WP4.1) — **Abnahme offen**

**Stand:** 7. November 2026, gebaut und grün. Dieser Nachtrag **berichtigt** §3a, §3b und §3c.

### Was falsch war

§3a und §3b definierten *erreichbar* als fünf Wege: Rezept, Loot, Händler, Quest-Belohnung,
Startausrüstung. `blocks.xml` war keiner davon — und `blocks.xml` trägt
`<drop event="Harvest|Destroy|Fall" name="…"/>`, also genau den Weg, auf dem in diesem Spiel
die meisten Rohstoffe in die Hand des Spielers kommen.

Die Folge war kein Schönheitsfehler. WP3 meldete für den fertigen Purge
`gesperrt_und_noch_erreichbar 0` und der Commit nannte ihn **vollständig**. Gemessen am
6. Weg waren es **26 gesperrte Kennungen in 869 Abwurfzeilen**, die weiter zu haben waren:

| Kennung | Abwurfzeilen |
|---|---|
| `resourceScrapPolymers` | 163 |
| `resourceMechanicalParts` | 127 |
| `resourceElectricParts` | 115 |
| `resourceMetalPipe` | 72 |
| `resourceSpring` | 57 |
| 21 weitere | 335 |

Ein Spieler, der ein Sofa zerschlägt, hatte Kunststoff; eine Waschmaschine gab Mechanikteile.
Die Prüfung sagte dazu nichts, weil sie nicht hinsah.

**`RecipeCheck` wusste es die ganze Zeit.** Dort sind Block-Abwürfe seit dem ersten Tag eine
Wurzel — „Der Rezeptgraph kennt vier Wege … `<drop event="Harvest">` in blocks.xml". Zwei
Stellen beantworteten dieselbe Frage verschieden, und der Warnabsatz davor stand schon im
Kopf von `Reachability.cs`, als es passierte. Die Lehre ist nicht „sorgfältiger lesen",
sondern: **beide Stellen lesen jetzt dieselbe Zeile Code.**

### Die neue Grundregel

> Erreichbar heißt: über einen **Block-Abwurf**, ein Rezept, eine Loot-Gruppe, eine
> Händlergruppe, eine Quest-Belohnung oder die Startausrüstung. Gezählt werden **alle**
> Abwurf-Ereignisse, nicht nur `Harvest`: `Destroy` und `Fall` geben dem Spieler den
> Gegenstand genauso.

`purge-patch` schreibt dafür einen siebten Teil: `remove` auf `/blocks/block/drop[@name='…']`.
Diese Zeilen tragen **bewusst kein Block-Prädikat** — der Gegenstand soll aus *jedem* Block
verschwinden, nicht aus einem. Der Block selbst bleibt vollständig stehen (D9); er gibt nur
das Gesperrte nicht mehr her.

### Eine Ausgabedatei, zwei Teile

`blocks.xml` bekommt jetzt zwei Teile: die `CreativeMode`-Zeilen und die Abwurf-Entfernungen.
Sie **müssen** in dieselbe Datei, weil der XML-Patcher des Spiels eine Modlet-Datei ihrer
Vanilla-Datei über den **Dateinamen** zuordnet; eine `blocks-abwuerfe.xml` würde nie
angewandt. Im Werkzeug bleiben sie getrennte Objekte, weil jede Einzelprobe nur ein Element
und ein Attribut kennt — zusammengelegt könnte `wege_uebrig` nur noch eines von beiden prüfen
und wäre beim anderen stillschweigend grün.

Daraus folgen zwei Pflichten, die beim Bau beide als echte Fehler gefunden wurden:

1. **Je Ausgabedatei eine Kopie, nicht je Teil.** Die Gesamtprobe legte ihre Kopien unter dem
   Dateinamen ab und warf damit die erste weg — sie hätte am Ende nur den zweiten Teil
   geprüft, grün und schweigend.
2. **Je Teil eine eigene Zahl.** `patchzeilen_blocks.xml` stand zweimal im Bericht; angezeigt
   wurde einer der beiden Werte, und die Summe `patchzeilen` ging nicht mehr auf. Jetzt heißen
   sie `patchzeilen_blocks.xml [creativemode]` und `patchzeilen_blocks.xml [drop]`.

### Zusätzliche Zähler

| Zähler | Soll | heißt |
|---|---|---|
| `bloecke_mit_abwurf_gesamt` | — | Blöcke, die vor dem Patch einen benannten Abwurf hatten |
| `bloecke_ohne_abwurf_danach` | Hinweis | davon welche, die danach keinen mehr haben |

Gezählt wird nur über `<drop name="…"/>`: ein `<drop event="Destroy" count="0"/>` ohne Namen
ist Vanillas Art zu sagen „hier fällt nichts", und wer den mitzählt, meldet jeden
Terrainblock als Lücke. Verglichen wird über **Blocknamen**, nicht über zwei Zählungen —
eine Differenz zweier Zahlen ist auch dann plausibel, wenn sie zwei verschiedene Mengen zählt.

### `ungeprueft` muss Namen nennen

§3b verlangt `ungeprueft = 0`. Als der sechste Weg dazukam, sprang die Zahl von 0 auf **11**,
und der Bericht sagte nicht, auf welche elf — eine Zahl ohne Namen lässt sich nicht
abarbeiten. `anachronisms` gibt jetzt je ungeprüfte Kennung einen Hinweis aus.

Die elf waren Waldboden, Schnee, Schutt, drei Setzlinge, ein Schneebeerenstrauch und ein
Trümmerteil. Neun stehen seither als Freigabe in `denylist.txt`, zwei als Verbot
(`plantedSnowberry*` wie Yucca, `scrapMetalPile` als modernes Trümmerteil). Dass sie harmlos
aussahen, ist kein Urteil.

### Gemessen, 7. November 2026

Jede Zahl hier kommt aus dem Werkzeug oder aus einem Einzeiler über die Quelldatei; keine ist
von Hand geschätzt.

| gemessen an | Wert |
|---|---|
| Erreichbarkeitswege gesamt (ConfigsDump) | 8.511 |
| davon Block-Abwürfe | 3.106 in 90 verschiedenen Namen |
| geprüfte Kennungen | 1.136 |
| `ungeprueft` | 0 — über 11 Namen und zwei neue Urteile |
| `gesperrt_und_noch_erreichbar` | 0 bei sechs Wegen (591 ohne die Entfernungen) |
| Patchzeilen gesamt | 1.818, davon 41 Abwurf-Entfernungen |
| `bloecke_ohne_abwurf_danach` | 130 von 1.149 |
| das Loch selbst | 26 gesperrte Kennungen in 869 Abwurfzeilen |

Ein „vorher/nachher" der Gesamtzahlen steht hier **nicht**: dafür müsste der Lauf mit
ausgebautem sechsten Weg wiederholt werden, und eine Zahl, die ich nicht gemessen habe,
gehört in keine Tabelle. Die 1.780 Patchzeilen aus dem WP3.4-Commit und die 1.818 von heute
sind beide gemessen und stehen oben; was dazwischen auf die Denylist-Änderungen aus WP4.1
und was auf die Abwürfe entfällt, trennen die Einzelzähler im Bericht.

### Was dieser Nachtrag nicht behauptet

Dass es keinen **siebten** Weg gibt. Gefunden wurde der sechste, weil eine Zahl in WP4
(585 Abwurfzeilen für Schrotteisen) nicht zur Behauptung „der Purge ist vollständig" passte.
Kandidaten, über die hier nichts geprüft ist: `entityclasses.xml` jenseits der
Startausrüstung (Beute von Tieren und Zombies), die Prefabs der Welt, `progression.xml`.
Jede dieser Dateien kann einen Weg tragen, den diese Liste nicht kennt — und dann steht hier
wieder „0" für eine Frage, die nicht gestellt wurde.

Was die 130 stummen Blöcke im Spiel bedeuten, ist ebenfalls ungeprüft. Wie bei den leeren
Loot-Gruppen gehört das in WP3.6.

## 4. `recipes` — Z3

**Prüft:** Ist jedes herstellbare Ergebnis aus Rohstoffen erreichbar, die es im Spiel gibt?

Das Werkzeug baut aus `recipes.xml` einen gerichteten Graphen (Zutat → Ergebnis), nimmt als
Wurzeln alles, was abgebaut, geerntet, geplündert oder gehandelt werden kann, und meldet:

| Befund | Bedeutung |
|---|---|
| **Sackgasse** | ein Rezept existiert, aber mindestens eine Zutat ist nirgends erreichbar |
| **Zyklus** | A braucht B, B braucht A |
| **Verwaiste Werkstatt** | ein Rezept verlangt eine Werkbank, für die es kein Bau-Rezept gibt |
| **Unerreichbares Tier** | ein T3-Rezept, zu dem kein Pfad von T0 führt |

`--from <kennung>` prüft einen einzelnen Pfad und erklärt ihn Schritt für Schritt — das ist das
Werkzeug für die Frage „warum kann ich die Spatha nicht bauen?".

**Gegenprobe:** Ein Rezept mit einer erfundenen Zutat (`itm700_gibtEsNicht`) muss **rot** werden.

**Grenze, die in die Ausgabe gehört:** Das Werkzeug prüft Erreichbarkeit, nicht Balance. Dass
ein Pfad existiert, heißt nicht, dass er sich gut anfühlt. Das entscheidet der Playtest.

## 5. `localization` — Z4

**Prüft:** `Config/Localization.csv` gegen die belegte Form.

Die Kopfzeile der ausgelieferten Datei:

```
Key,File,Type,UsedInMainMenu,NoTranslate,KeepLoaded,english,
Context / Alternate Text,german,spanish,french,italian,japanese,koreana,
polish,brazilian,russian,turkish,schinese,tchinese
```

**Das Werkzeug liest die Spaltennamen aus der Kopfzeile und verlässt sich auf keine Position.**
Der Grund steht im Finding: `Context / Alternate Text` sitzt **zwischen** `english` und `german`.
Ein Werkzeug, das „die Spalte nach english ist Deutsch" annimmt, prüft die Kommentarspalte und
meldet Grün für fehlende Übersetzungen. Dieser Fehler wäre ohne den Blick in die echte Datei
passiert — er ist der Grund, warum diese Regel hier so ausdrücklich steht.

**Befunde:**

| Befund | Regel |
|---|---|
| leere Pflichtspalte | `english` oder `german` leer → rot (D7) |
| doppelter Schlüssel | `Localization::addCsv` verwirft den zweiten stillschweigend → rot |
| Schlüssel ohne `700_` | außer in einer kommentierten Gruppe bewusster Vanilla-Überschreibungen → rot |
| Spaltenzahl weicht ab | eine Zeile mit anderer Spaltenzahl als die Kopfzeile → rot |
| Kopfzeile unbrauchbar | erste Zelle nicht `Key`, oder eine Spaltendefinition leer bzw. nicht lateinisch → rot |
| gefüllte Fremdsprache | eine der zwölf übrigen Sprachen gefüllt → **Hinweis**, nicht rot |

Der letzte Punkt ist bewusst nur ein Hinweis: D7 sagt „leer lassen, nicht mit EN füllen", aber
wenn später jemand wirklich übersetzt, darf das Werkzeug nicht im Weg stehen.

**Gegenprobe:** In einer Kopie der Datei wird eine `german`-Zelle geleert → **rot**; ein
Schlüssel verdoppelt → **rot**.

### Nachtrag WP4.1 (2026-11-07): die Liste der bewussten Vanilla-Überschreibungen

Die „kommentierte Gruppe" aus der Befundtabelle ist jetzt eine eigene Datei,
`tools/check/vanilla-keys.txt`, die `check-all.ps1` übergibt, wenn sie existiert. Sie ist
nötig, weil WP4 Vanilla-Dinge **umdeutet** statt ersetzt: `resourceScrapIron` heißt in der XML
weiter so — 585 Abwurfzeilen und jedes Rezept zeigen auf diesen Namen — und der Spieler liest
„Raseneisenerz". Dass eine Modlet-Zeile den Vanilla-Schlüssel überschreibt, ist belegt in
[WP4-localization-ueberschreibt-vanilla.md](../rea/findings/WP4-localization-ueberschreibt-vanilla.md):
`addCsv` nimmt im Modlet-Zweig `Dictionary::set_Item`, nicht `Add`.

Drei Regeln für diese Datei, alle drei mit einer Gegenprobe:

1. **Sie wirkt.** Ohne sie ist ein Schlüssel ohne Präfix rot. Eine Freigabeliste, die man
   weglassen kann, ist keine.
2. **Sie verträgt einen nachgestellten Grund** (`casinoCoin  # Silberpfennig`) — wie
   `denylist.txt`, `aufschub.txt` und die Rezeptliste. **Das war ein echter Fehler:** der
   Leser schnitt den Kommentar nicht ab, machte aus der Zeile den Schlüssel
   `"casinoCoin  # Silberpfennig"` und meldete zehn Schlüssel ohne Präfix — mit Verweis auf
   eine Datei, in der jeder davon sichtbar stand. Vier Leser im selben Werkzeug, drei mit
   derselben Regel und einer ohne, ist eine Falle, kein Stil.
3. **Ein Eintrag ohne Zeile wird genannt.** Neue Zähler `vanilla_schluessel_erlaubt` und
   `vanilla_schluessel_ohne_zeile`, dazu ein Hinweis je Name. Die Liste ist eine
   **Abschaltung** der Präfix-Prüfung; ein Eintrag, zu dem es keine Übersetzung gibt, schaltet
   sie für einen Schlüssel ab, den niemand setzt — und bleibt stehen, wenn eine Zeile später
   gelöscht oder umbenannt wird.

**Jede Zeile dort ist eine Entscheidung.** Wer einen Schlüssel einträgt, nur damit die Prüfung
schweigt, hat die Prüfung abgeschaltet und nicht bestanden. Der Grund gehört daneben.

### Nachtrag WP4.6 (2026-11-08): `--prefix` nimmt eine Liste

`--prefix` nahm ein einzelnes Präfix, weil Vertrag 02 §5 ein einzelnes `700_` vorschrieb.
Dieser Teil von §5 war **falsch** und ist berichtigt: der Sprachschlüssel eines Gegenstands
**ist seine Kennung**, und Kennungen heißen nach §2 `itm700_…`, `blk700_…` und so weiter. Mit
nur `700_` war jeder eigene Gegenstand rot — und der naheliegende Ausweg, ihn in
`vanilla-keys.txt` zu schreiben, wäre eine Freigabe für etwas, das gar kein Vanilla ist: eine
Lüge in genau der Datei, die die Ausnahmen aufzählt.

`--prefix` nimmt darum eine kommagetrennte Liste, und `check-all.ps1` übergibt wörtlich die
aus §2 plus `700_` für alles, was keine Kennung ist. Zwei Gegenproben halten es fest: ein
Kennungsschlüssel ist mit `--prefix 700_` **rot** und mit der Liste **grün**.

## 5a. `kette-pruefen.ps1` — unsere eigenen Rezepte (Nachtrag WP4.6)

`recipes` prüft eine **Quelle**, und unsere Modlets stehen in keiner, die ohne Spielstart zu
haben ist: der vorhandene `ConfigsDump` ist vom 7. Juli und kennt sie nicht. **„`recipes`
grün" heißt heute „Vanilla hat keine Sackgasse"** und sagt über unsere Kette nichts. Das ist
keine Schwäche des Werkzeugs, sondern die Stelle, an der der Spielstart aus WP3.6 fehlt — und
sie gehört benannt, weil ein grünes `recipes` sonst wie eine Aussage über unsere Arbeit
aussieht.

`tools/check/kette-pruefen.ps1` schließt die kleinere Hälfte: es liest unsere
Rezept-Patches, sammelt **jeden** Verweis — Ergebnis, Zutaten, `craft_tool` — und sucht ihn
in Vanillas `items.xml`/`blocks.xml` und in unseren eigenen `items.xml`. Ein Tippfehler in
einer Zutat ist der wahrscheinlichste Fehler in handgeschriebenen Rezepten, und das Spiel
sagt dazu nichts: ein Rezept mit unbekannter Zutat ist einfach nicht herstellbar.

Gegenprobe (Projektregel 5): `testdaten/kette-rot.xml` trägt drei erfundene Namen, darunter
`resourceCole` statt `resourceCoal` — der Lauf meldet 3 rot und endet mit Exit 1. Gegen die
echten Dateien: 5 Rezepte, 4 werkzeuggebunden, **0 unaufgelöste Verweise**.

**Was es nicht prüft** und in seiner Ausgabe selbst sagt: Erreichbarkeit von T0 aus, Zyklen,
und ob der XML-Patcher des Spiels unsere XPaths trifft. Ohne `SDTD_PATH` überspringt es sich
und sagt ausdrücklich „KEIN GRUEN".

### Nachtrag WP5.1 (2026-11-08): es sucht die Dateien jetzt selbst — **Abnahme offen**

Die beiden Pfade standen fest im Skript, auf `700_20_Material`. Als WP5.1 die Waffenrezepte in
`700_30_Ausruestung` anlegte, **hat das Skript sie nicht gesehen und weiter grün gemeldet**.
Ein Prüfer, der nur die Dateien kennt, die man ihm beim Schreiben genannt hat, prüft das
falsche Projekt — und er fällt nicht auf, weil er grün bleibt.

Jetzt sucht es `mod/**/recipes.xml` und `mod/**/items.xml` selbst und nimmt `700_10_Purge`
aus (erzeugt, enthält nur Entfernungen). Gemessen nach der Änderung: **15 Rezepte, 12
werkzeuggebunden, 0 unaufgelöste Verweise** — vorher sah derselbe Lauf nur 4 davon.

### Nachtrag WP5.5b (2026-11-08): es sieht auch unsere **Blöcke** — **Abnahme offen**

Derselbe Fehler, eine Stufe später bemerkt. Das Skript las Vanillas `blocks.xml`, **unsere
aber nicht**: die Definitionen kamen aus Vanillas `items.xml` und `blocks.xml` plus unseren
`items.xml`. Beim ersten eigenen Block des Projekts — dem Webstuhl — meldete es dessen
Bau-Rezept darum als

```
[ROT]  Ergebnis 'blk700_webstuhl' ist nirgends definiert  (recipes.xml / blk700_webstuhl)
```

obwohl die Definition zwei Dateien weiter liegt. **Diesmal war der Fehler ein falsches Rot und
kein falsches Grün** — und genau darum ist er aufgefallen. Hätte das Projekt den Block ohne
Rezept gebaut, wäre er umgekehrt gelaufen: ein Tippfehler in einem Blocknamen wäre nie
aufgefallen.

Jetzt sucht es zusätzlich `mod/**/blocks.xml` (ohne `700_10_Purge`) und nimmt `<block name>`
daraus auf. Neuer Parameter `-Bloecke`, damit der Satz Prüfdaten von außen zu setzen ist.

**Gegenproben (Projektregel 5) — zwei gebaut und grün.** Eine Erweiterung, die nur ein Rot
wegnimmt, kann das Signal auch abgeschaltet haben. Beide Läufe stehen in `gegenproben.ps1`
(neue Hilfsfunktion `Test-Script`, weil auch ein PowerShell-Skript ein Prüfwerkzeug ist) und
arbeiten auf `testdaten/kette/` mit erfundenen Kennungen:

| Gegenprobe | erwartet | prüft |
|---|---|---|
| eigener Block wird aufgelöst | Exit 0, `unaufgeloeste Verweise: 0` | die Erweiterung wirkt |
| vertippter Blockname bleibt rot | Exit 1, `'pruefBlockGibtesnicht' ist nirgends definiert` | sie hat das Signal nicht abgeschaltet |

Gemessen nach der Änderung: **32 eigene Rezepte, 17 werkzeuggebunden, 18 eigene Definitionen,
0 unaufgelöste Verweise**; 44 Gegenproben, 0 fehlgeschlagen.

### Nachtrag WP6 (2026-11-08): eingehängte Zutaten und Reparaturwerkzeuge — **Abnahme offen**

**Nach einem echten Fehler geschlossen.** WP5.5b hat vier Werkstatt-Bau-Rezepte berichtigt und
dabei `resourceClay` als Zutat eingetragen. **Diese Kennung gibt es in Vanilla nicht** — der
Lehm heißt `resourceClayLump`. Der Lauf war **grün**, und zwar aus einem Grund, der eine Bauart
ist und kein Zufall: die Zutat steht in

```xml
<append xpath="/recipes/recipe[@name='forge']">
    <ingredient name="resourceClay" count="20" />
</append>
```

also in **keinem `<recipe>`-Knoten unserer Datei**. Das Skript lief über `//recipe` und sah sie
nie. Dieselbe Lücke an einer zweiten Stelle: ein umgehängtes `RepairTools` ist eine **Kommaliste
im Elementtext** eines `<set>` — weder Rezept noch Attribut. Ein Tippfehler darin macht einen
Gegenstand unreparierbar, und das fällt erst im Spiel auf.

Beides wird jetzt aufgelöst, und der Lauf **zählt** es, statt nur zu schweigen:

```
eingehaengte Zutaten: 5, Reparaturwerkzeuge: 21
```

Eine Zahl, die man sehen kann, ist der Unterschied zwischen „geprüft" und „nicht angesehen".

Bei `RepairTools` wird **nur dieser eine Pfad** aufgelöst (`xpath` endet auf
`RepairTools']/@value`). Ein allgemeines „löse jeden `<set>`-Wert auf" würde über Zahlen,
Marken und Pfade stolpern und wäre ein Prüfer, der schreit.

**Gegenproben (Projektregel 5) — drei gebaut und grün**, damit 47 statt 44:

| Gegenprobe | erwartet | prüft |
|---|---|---|
| eingehängte Zutat und Reparaturwerkzeug werden gezählt | Exit 0, `eingehaengte Zutaten: 1, Reparaturwerkzeuge: 2` | dass die Pfade wirklich angesehen werden |
| vertippte eingehängte Zutat wird rot | Exit 1, nennt `pruefLehmGibtesnicht` | der Fehler von WP5.5b, nachgestellt |
| vertipptes Reparaturwerkzeug wird rot | Exit 1, nennt `pruefFlickenGibtesnicht` | die zweite Stelle |

### Nachtrag WP6.1 (2026-11-08): umgebogene Verweise — **Abnahme offen**

**Diesmal vor dem Fehler geschlossen, nicht nach ihm.** Beim Schreiben des Ausbaupfades fiel
auf, dass die drei Arten von `<set>`-Zeile, die WP6.1 braucht, in dieselbe Lücke fallen wie
die zwei aus dem Nachtrag davor — eine Kennung im **Elementtext**, weder Attribut noch Rezept:

```xml
<set xpath="…[@class='UpgradeBlock']/property[@name='Item']/@value">resourceRockSmall</set>
<set xpath="…[@class='RepairItems']/property[@name='resourceConcreteMix']/@name">resourceRockSmall</set>
<set xpath="…/drop[@event='Harvest'][@name='resourceScrapIron']/@name">resourceRockSmall</set>
```

Ein Tippfehler in der ersten macht eine **Baustufe unerreichbar**, in der zweiten einen Block
**unreparierbar**, in der dritten einen Abbau **ertraglos**. Alle drei fallen erst im Spiel
auf. `ToBlock` kommt mit, weil ein umgebogenes Aufwertungsziel genauso eine Kennung ist.

Der Lauf **zählt** sie jetzt:

```
eingehaengte Zutaten: 5, Reparaturwerkzeuge: 21, umgebogene Verweise: 5
```

Aufgelöst wird gegen **einen** Topf aus Gegenständen und Blöcken. Dieser Lauf prüft also, dass
die Kennung **existiert**, nicht dass sie von der richtigen **Art** ist — ein Block als
Aufwertungs-Zutat bliebe hier grün. Das ist bewusst die billigere Prüfung; die Art steht erst
im gemergten Dump fest (WP3.6), und das steht auch in den „Grenzen dieser Prüfung".

**Gegenproben (Projektregel 5) — zwei gebaut, 47 → 49:**

| Gegenprobe | erwartet | prüft |
|---|---|---|
| umgebogene Verweise werden gezählt, Zahlen nicht | Exit 0, `umgebogene Verweise: 4` | dass die vier Pfade angesehen werden **und** die fünfte Zeile der Prüfdatei (`ItemCount`, eine Zahl) *nicht* mitzählt |
| vertippte Aufwertungs-Zutat wird rot | Exit 1, nennt alle drei: `pruefSteinGibtesnicht`, `pruefMoertelGibtesnicht`, `pruefSchuttGibtesnicht` | jede der drei Stellen einzeln |

Die erste Gegenprobe ist die wichtigere: ohne die Zahlenzeile würde sie nur beweisen, dass der
Prüfer etwas sieht — mit ihr beweist sie, dass er nicht **alles** sieht. Ein Prüfer, der jeden
`<set>`-Wert aufzulösen versucht, stolpert über `ItemCount`, `damage_category` und
Prefab-Pfade und schreit, bis niemand mehr hinhört.

### Nachtrag WP6.4 (2026-11-08): Verweise in eigenen Definitionen — **Abnahme offen**

**Die vierte Stelle, und die größte.** Die drei Nachträge davor schlossen Lücken im
*Umbiegen* von Vanilla. Diese schließt eine im *eigenen Schreiben*: ein selbst geschriebener
Block nennt Kennungen in **Attributen** — und `kette-pruefen` prüfte bis hierher nur, **dass**
unsere Blöcke existieren, nicht, **worauf** sie zeigen.

WP6.4 schreibt über dreißig solcher Verweise in einem Commit. Aufgelöst werden jetzt sechs
Stellen, als abgezählte Liste:

| Stelle | was dort steht | Tippfehler kostet |
|---|---|---|
| `property[@name='Next']/@value` | der Folgeblock einer `PlantGrowing`-Uhr | **die ganze `blocks.xml`** — `LateInit` wirft `Block with name '…' not found!` |
| `property[@name='ToBlock']/@value` | das Ziel einer Aufwertung | der Weg zurück fehlt |
| `property[@name='Item']/@value` | die Zutat einer Aufwertung | die Stufe ist unerreichbar |
| `property[@name='Extends']/@value` | die Grundlage eines Blocks | der Block erbt nichts |
| `drop/@name` | ein Abwurf | der Abbau gibt nichts her |
| `property[@class='RepairItems']/property/@name` | ein Reparaturstoff | der Block ist unreparierbar |

Der Lauf **zählt** sie:

```
Verweise in eigenen Definitionen: 46
```

**Nicht dabei, und mit Absicht:** `ActiveRadiusEffects` und `BuffsWhenWalkedOn` (Buffs, stehen
in `buffs.xml`), `DescriptionKey` und `CustomIcon` (Sprachschlüssel und Symbole — die prüft
`localization` bzw. das Auge), `Material` (`materials.xml`), `Model` (ein Prefab-Pfad, den nur
das Spiel auflösen kann), `TraderStageTemplate`. Ein Prüfer, der auch die auflösen wollte,
wäre ein Prüfer, der schreit.

**Grenze, ausdrücklich:** aufgelöst wird gegen **einen** Topf aus Gegenständen und Blöcken.
Geprüft ist, dass die Kennung **existiert**, nicht dass sie von der richtigen **Art** ist — ein
Gegenstand als `Next` bliebe hier grün. Die Art steht erst im gemergten Dump fest (WP3.6).

**Gegenprobe (Projektregel 5) — eine, 49 → 50:** ein eigener Block mit vier vertippten
Verweisen (`Next`, `Extends`, Reparaturstoff, Abwurf) muss **alle vier einzeln** nennen und
Exit 1 liefern. Der saubere Satz ist die Probe darüber, die weiter Exit 0 gibt.

**Und der Prüfer hat sich im selben Lauf schon bezahlt:** meine Kommentar-Trennlinien in
`blocks.xml` enthielten `----`, und `--` ist in einem XML-Kommentar nicht erlaubt. Der Lauf
brach beim Einlesen ab und nannte Zeile und Spalte. Ohne ihn wäre die Datei im Spiel
stillschweigend liegengeblieben — dasselbe Muster wie am 8. November früh, nur diesmal in
Sekunden statt nach einem Commit.

**Was dieser Nachtrag nicht behauptet.** Dass `blk700_webstuhl` auflösbar ist, heißt nicht, dass
der Block lädt: ob `Mwood`, `ui_game_symbol_workbench`, `advBuilding` und der geborgte
Prefab-Pfad gültig sind, sieht dieses Skript nicht — es vergleicht Namen von Definitionen mit
Namen aus Rezepten. Und ob die Fenstergruppe `workstation_blk700_webstuhl` wirklich gefunden
wird, entscheidet WP3.6.

## 5b. `rezepte_mit_gesperrter_zutat` — der dritte Nebeneffekt des Purge (Nachtrag WP5.1) — **Abnahme offen**

**Stand:** 8. November 2026, gebaut, zwei Gegenproben grün. Dieser Nachtrag ergänzt §3c.

### Was übersehen war

Der Purge nimmt die **Wege zu gesperrten Gegenständen**. Niemand hatte gefragt, ob die
**übrigen** Rezepte danach noch herstellbar sind. Gemessen: von den 247 Rezepten, die den
Purge überleben, sind **94 toter Buchstabe** — mindestens eine ihrer Zutaten ist gesperrt.
Der Gegenstand bleibt erlaubt, das Rezept bleibt stehen, und im Handwerksfenster ist es grau.

Kein Lauf hat das gemeldet, und zwar aus zwei Gründen gleichzeitig: `anachronisms` urteilt
über **Kennungen** und nicht über Zutatenlisten, und `recipes` prüft eine **Quelle**, in der
unsere Modlets nicht geladen sind — dort ist Panzerband noch da. Gefunden wurde es beim Lesen
der Vanilla-Waffenrezepte für WP5.1: **fast jedes Waffenrezept ab T1 verlangt Panzerband.**

### Die Zähler

| Zähler | Bedeutung |
|---|---|
| `rezepte_nach_purge` | Rezepte, die nach den Entfernungen übrig sind (gemessen 247) |
| `rezepte_mit_gesperrter_zutat` | davon die, die mindestens eine gesperrte Zutat haben (gemessen 94) |

Der Hinweis nennt die **Zutaten** mit der Zahl ihrer Rezepte, nicht die 94 Rezepte: ersetzt
wird je Zutat. Die größten: `resourceDuctTape` (40), `resourceMechanicalParts` (34),
`resourceScrapPolymers` (31), `resourceSpring` (18), `resourceGunPowder` (8).

**`count="0"` zählt nicht.** So schreibt Vanilla eine Zutat, die nur die Qualitätsstufen
staffelt und nichts kostet — `resourceLegendaryParts` steht so in fast jedem Waffenrezept.
Wer sie mitzählt, meldet jedes Waffenrezept als tot.

### Diese Zahl ist eine Arbeitsliste, kein Fortschrittsbalken

Erzeugt wird gegen **Vanilla**; unsere eigenen Modlets sind dabei nicht geladen. Ein Rezept,
das ein Paket von uns schon ersetzt hat, steht trotzdem weiter in den 94. Der Hinweis sagt das
selbst. Dass ein Ersatz wirklich greift, sagt erst ein Lauf gegen einen frischen
`ConfigsDump` — **WP3.6**.

### Gegenproben (Projektregel 5) — zwei gebaut und grün

| Probe | Erwartung |
|---|---|
| `tote Rezepte werden gezaehlt, eine Zutat mit count=0 nicht` | `rezept-mit-gesperrter-zutat: 1 von`, und die gesperrte Zutat namentlich |
| `ohne gesperrte Zutat meldet der Zaehler nichts` | der Hinweis fehlt ganz |

Der Prüfsatz `testdaten/purge/recipes.xml` hat dafür zwei neue Rezepte: `pruefKoecher` nennt
eine gesperrte Zutat mit `count="1"`, `pruefSehne` dieselbe mit `count="0"`. Meldet der Lauf
„2 von", zählt der Zähler Vanillas Qualitätszutaten mit.

### Was dieser Nachtrag nicht behauptet

- **Kein Fehler, nur ein Hinweis.** Die 94 fallen nicht in WP5; sie fallen über WP5 bis WP7,
  je Feature. Ein Fehler wäre eine Schuld ohne Adresse.
- **Nichts über Loot und Händler.** Ein gesperrter Gegenstand kann weiter in einer Loot-Liste
  stehen, die wir nicht angefasst haben — das deckt `wege_uebrig`, nicht dieser Zähler.
- **Nichts über Verweise jenseits von Zutaten.** `RepairTools`, `required_tools` in XUi und
  `RepairItems` an Blöcken nennen Gegenstände ebenfalls. Das ist der offene Punkt „der Purge
  deckt Wege, nicht VERWEISE" in §8, und er bleibt offen.

## 6. Ein Befehl für alles

`tools/check/check-all.ps1` ruft die drei Befehle, fasst zusammen und endet mit Exit 1, wenn
einer rot ist. Dieser Befehl kommt in `.claude/verify.json` und ist damit **der** Prüfbefehl des
Projekts — nach „Nachweis statt Status" darf ohne seinen Lauf keine Antwort „grün" sagen.

`tools/build/smoke.ps1` bleibt daneben: es prüft Paket und Protokoll, nicht die Inhalte.

## 7. Was die Werkzeuge nicht tun

1. **Nichts ändern.** Keine Reparatur, kein Formatieren, kein Sortieren.
2. **Keine Balance beurteilen.** Erreichbarkeit ja, Spielgefühl nein.
3. **Nicht raten.** Wo eine Prüfung unmöglich ist, steht das in `limitations`, nicht ein
   schweigendes Grün.
4. **Kein Spiel starten.** Für die Nachweis-Betriebsart liefert der Nutzer den `ConfigsDump`.

## 8. Offene Punkte dieses Vertrags

### Beim Bau geklärt (2026-11-07, WP2)

- **Die Wurzeln des Rezeptgraphen** sind beantwortet: `blocks.xml` trägt
  `<drop event="Harvest" name="…"/>`, und das ist der Weg, auf dem Rohstoffe aus der Welt
  kommen. Wurzeln sind damit Block-Drops, Loot, Händlerware und Startausrüstung. Dazu acht
  Kennungen, die über Sondermechaniken kommen (Schmelz-Einheiten der Esse, Eimer an der
  Wasserquelle, lebendes Tier) — sie stehen nachlesbar in `tools/check/world-roots.txt`, nicht
  im Code. Ohne diese Datei meldet der Lauf gegen unverändertes Vanilla 38 Sackgassen, mit ihr
  ist Vanilla grün.
- **`Localization.csv` liegt NICHT im `ConfigsDump`.** Die Tabelle in Abschnitt 1 unterstellt für
  alle drei Befehle den Dump — für `localization` trifft das nicht zu. Geprüft wird dort immer
  die Quelldatei des Sprach-Modlets. Folge: ein Schlüssel, den zwei Modlets doppelt setzen,
  fällt nur auf, wenn beide Dateien zusammen geprüft werden.
- **Vanilla-Schlüssel ohne `700_`-Präfix** lassen sich in einer CSV nicht „kommentiert
  gruppieren", wie Abschnitt 5 es vorsah — CSV kennt keine Kommentare. Stattdessen:
  `--vanilla-keys <datei>`, eine Freigabeliste neben der Datei.
- **13 Sprachen**, nicht 14 (Abschnitt 5 nannte die falsche Zahl): 20 Spalten, davon fünf
  Metadaten, eine Kommentarspalte und 13 Sprachen.

### Weiter offen

- **Der Purge deckt Wege, nicht VERWEISE** (gefunden am 2026-11-08 in WP4.5, von Hand).
  Erreichbarkeit heißt „der Spieler kann es bekommen". Wo Vanilla eine gesperrte Kennung nur
  **nennt**, bleibt der Name stehen, und keine der sechs Wegarten sieht das:
  - **Werkzeugslots in XUi.** Vanillas Werkzeugfenster der Feuerstelle verlangt
    `required_tools="toolCookingPot,toolCookingGrill,toolBeaker"`. Das Becherglas ist
    gesperrt, also blieb ein dritter Platz übrig, den niemand füllen kann. Behoben in
    `700_40_Bauen`, aber eben von Hand.
  - **`RepairItems`.** Der Betonmischer verlangt zur Reparatur `resourceSpring` und
    `resourceMechanicalParts`, beide gesperrt. Ein unreparierbarer Block ist kein Absturz,
    aber auch keine Entscheidung.
  - **`RepairTools`** (gefunden am 2026-11-08 in WP5.5, von Hand). **23 erlaubte Gegenstände
    reparieren mit dem gesperrten `resourceRepairKit`** — acht Waffen, fünf
    Rüstungs-Basisklassen, vier Bögen, fünf Werkzeuge und `partsMaster`. Ein Gegenstand, dessen
    Reparaturwerkzeug es nicht mehr gibt, ist nicht reparierbar, und das fällt erst im Spiel
    auf. WP5.4 und WP5.5 haben 13 davon umgehängt (D60, D62), **zehn sind offen**. Die Zahl ist
    **von Hand gezählt**: eine Prüfung „erlaubter Gegenstand verweist auf gesperrtes Werkzeug"
    gibt es nicht, und sie wäre dieselbe Frage wie die drei Punkte darüber.
  - **Prefab-Inhalte.** Steht ungeprüft, siehe §3d.

  Eine Prüfung dafür gibt es nicht. Sie wäre machbar — dieselben Dateien, andere Frage: nicht
  „woher bekommt man es", sondern „wo wird es genannt" — und sie würde vermutlich viel
  finden, von dem das meiste harmlos ist. Das ist der Grund, warum sie noch nicht gebaut ist
  und nicht, dass die Frage unwichtig wäre.
- **`kette-pruefen -Patches` mit einem Pfad, den es nicht gibt, ist grün** (gefunden am
  2026-11-20 in WP8.1, beim Bau einer Gegenprobe). Zwei Pfade, versehentlich als *eine*
  Zeichenkette übergeben, ergaben „0 XPaths … 0 rot → GREEN", Exit 0. Im normalen Lauf
  sucht das Skript seine Dateien selbst unter `mod/` und ist nicht betroffen; betroffen ist
  jede **Gegenprobe**, die Dateien übergibt — sie könnte grün sein, weil nichts geprüft
  wurde. Nicht behoben: eine Datei, die nicht existiert, und ein Lauf mit null XPaths bei
  übergebenen Dateien müssten Exit 2 sein. Bis dahin gilt für jede Gegenprobe: die Zahl
  der geprüften XPaths mitlesen, nicht nur die Farbe.
- **Buff-Verweise prüft kein Werkzeug** (gefunden am 2026-11-20 in WP8.3). `kette-pruefen`
  löst Verweise auf Gegenstände und Blöcke auf, nicht auf Buffs: ein vertippter Name in
  `ActiveRadiusEffects`, in `BuffsWhenWalkedOn` oder in `action="AddBuff" buff="…"` bleibt
  grün und fällt erst im Spiel auf — als Wirkung, die still fehlt. WP8.3 führt vier solche
  Verweise; sie sind von Hand aufgelöst. Mit dem Grauen-System (Phase 2) werden es viele.
  Nicht gebaut; es wäre dieselbe Prüfung mit einer dritten Definitionsart.
- **Der Inhalt der Denylist** ist ein Anfang, kein Ende. `tools/check/denylist.txt` deckt
  Schusswaffen, Munition, Fahrzeuge, Elektronik, moderne Nahrung und Medizin, Treibstoff und
  industrielle Baustoffe ab, dazu 19 Freigaben nach D9. Die vollständige Liste entsteht in WP3.1
  gegen die echten Dateien.
- Die vorhandenen `ConfigsDump`-Ordner auf diesem Rechner sind von **V 3.1.0**, nicht von
  V 3.40 — brauchbar, um die Werkzeuge zu bauen und zu kalibrieren, **nicht** als Nachweis. Der
  erste echte Dump entsteht beim Spielstart des Nutzers.
- **Ein Dump verrät seine Herkunft nicht:** weder Spielfassung noch geladene Modlets stehen
  darin. Die Werkzeuge geben darum den Zeitstempel aus und nennen diese Grenze in jeder Ausgabe.
  Eine härtere Prüfung (etwa auf Spuren unserer Modlets im Dump) ist denkbar, aber noch nicht
  gebaut.

---

## Nachtrag WP7.1 — die XPaths selbst (8. November 2026), **Abnahme offen**

Bis hierher stand unter den Grenzen von `kette-pruefen.ps1` wortwörtlich: *„Ob der
XML-Patcher des Spiels unsere XPaths trifft, steht hier nicht."* Das war die größte Lücke
des Projekts, und sie ist still: trifft ein XPath nichts, schreibt
`XmlPatcher::PatchXml` die Zeile `XML patch for "…" from mod "…" did not apply` ins
Protokoll und **lädt weiter**. Das Spiel startet, der Patch fehlt, und niemand erfährt es,
bis jemand im Spiel nachsieht.

Vier Verweisklassen prüfen den **Inhalt** unserer Patches. Diese fünfte prüft, ob ein Patch
überhaupt **irgendwo landet**.

**Was geprüft wird.** Je Patch-Datei unter `mod/*/Config/` wird die Vanilla-Datei
**gleichen Namens** geladen — genau so sucht `XmlPatcher::LoadAndPatchConfig` (D53) — und
jeder XPath der Verben `set`, `setattribute`, `removeattribute`, `append`, `prepend`,
`insertAfter`, `insertBefore`, `remove`, `csv` dagegen aufgelöst. Null Treffer ist rot,
außer jede Kennung im XPath ist eine, die wir selbst definieren (dann stammt der Knoten aus
einem früher ladenden Modlet).

**Was der erste Lauf gefunden hat.** Sechs Patches aus dem schon committeten WP6.4:
`lanternOld_02/03/04_Player` führen `Class` und `DescriptionKey` nicht selbst, sie **erben**
sie von `lanternOld_01_Player`. Drei `<set>` auf `Class` und drei auf `DescriptionKey`
trafen nichts. Berichtigt zu `<append>` — nicht auf die Vererbung verlassen, weil
„Extends wird nach dem Patchen aufgelöst" eine Annahme ist und ein `<append>` keine
braucht.

**Und einen Fehler im Prüfer selbst.** Beim ersten Lauf blieb
`mod/700_50_Fortschritt/Config/progression.xml` mit ihren 20 Patches **unbemerkt
übersprungen**, ohne eine Zeile Ausgabe. Ursache: PowerShells XML-Adapter legt die
XML-Attribute als Eigenschaften über das Objekt, und ein Attribut `name="hidden"`
überdeckt dabei die Eigenschaft `Name` des Elements — `$node.Name` liefert bei
`<setattribute name="hidden" xpath="…">` also `"hidden"` statt `"setattribute"`. Behoben
mit `$node.get_Name()`. Die Gegenprobe *„setattribute ohne Treffer wird rot"* steht genau
dafür: mit `.Name` wird sie grün und die Prüfung ist für jede `setattribute`-Datei blind.

**Drei neue Gegenproben, Stand 53** (vorher 50):

| Gegenprobe | erwartet | beweist |
|---|---|---|
| treffende XPaths werden gezählt | Exit 0, `geprueefte XPaths: 3 (3 in Vanilla, 0 auf eigene Knoten)` | der Zähler sieht alle drei Verben, auch `setattribute` und `append` |
| XPath ohne Treffer wird rot | Exit 1, nennt beide Fälle einzeln | fehlender Block **und** fehlende Eigenschaft bei vorhandenem Block |
| setattribute ohne Treffer wird rot | Exit 1 | der Prüfer sieht `setattribute` überhaupt (Rückfallwache) |

Die Prüfung brauchte dafür einen **Parameter** `-Patches`. Vorher suchte sie ihre Dateien
selbst unter `mod/` — und ein Prüfer, der seine Dateien selbst sucht, lässt sich nicht
gegenprüfen: die Gegenproben hielten die echten Mod-Dateien gegen das winzige
Test-Vanilla und wurden rot. Der Vorgabewert hängt jetzt an
`$PSBoundParameters.ContainsKey('Patches')` und nicht an `-not $Patches`, damit `@()`
„prüfe keine XPaths" heißen kann statt „suche selbst".

**Gemessene Grenzen, in der Ausgabe genannt:**

- Geprüft wird gegen **Vanilla**, nicht gegen den fertig gepatchten Stand. Ein XPath, der
  nur auf einen Knoten eines früheren eigenen Modlets zeigt, gilt als grün, sobald jede
  Kennung darin von uns definiert ist. Dass dieses Modlet wirklich früher lädt, prüft die
  Ladereihenfolge (D53), nicht dieses Skript.
- Geprüft wird nur die **erste Ebene** unter `<config>`. Patches in einem `<conditional>`
  sieht die Prüfung nicht; das Projekt benutzt bisher keines.
- Dateien, die Vanilla unter diesem Namen nicht hat (`XUi_InGame/*`, `Localization.csv`),
  bleiben außen vor.
- **Ein getroffener XPath heißt nicht, dass der Patch das Richtige tut.** Dafür sind die
  vier anderen Verweisklassen da — und für den Rest der Spieltest.

## Nachtrag WP7.1b — ein Erzeuger für Localization-Zeilen, **Abnahme offen**

`tools/gen/wp7-baumtexte.ps1` ist das erste Skript des Projekts, das **Mod-Inhalt
erzeugt** statt ihn zu prüfen. Begründung: Vanilla benennt die Rangschlüssel der Attribute
nicht einheitlich — vier Attribute schreiben `attXRank01Desc` bis `Rank10Desc`,
`attIntellect` aber `Rank1Desc` bis `Rank9Desc` und dann `Rank10Desc`. Von Hand getippt
wären neun von 115 Schlüsseln still falsch gewesen, und ein Schlüssel, den niemand liest,
fällt nicht auf. Das Skript liest die Schlüssel aus `progression.xml` des Builds und setzt
nur den Text dazu; es bricht ab, wenn das Spiel andere Rangzahlen führt als die Tabelle,
und wenn ein Schlüssel zweimal entstünde.

Die **Ausgabe** (`tools/gen/out/`) ist nicht das Erzeugnis — das Erzeugnis ist die Zeile in
`mod/700_90_Sprache/Config/Localization.csv`, von Hand angehängt und mitcommittet. Das
Skript ist der Nachweis, wie sie entstanden ist, und das Werkzeug für den nächsten Build.

**Für PowerShell 5.1 trägt die Datei eine UTF-8-BOM.** Ohne sie liest Windows PowerShell
eine `.ps1` als ANSI, und aus „Jäger" wird „JÃ¤ger" — genau so stand es im ersten Lauf in
der CSV. Die übrigen Skripte des Projekts umgehen das, indem sie gar keine Umlaute
enthalten.

## Nachtrag WP7.2 — Fortschritts-Verweise (8. November 2026), **Abnahme offen**

Die XPath-Prüfung aus WP7.1 sagt, ob ein Patch **landet**. Sie sagt nichts darüber, ob der
**Wert**, den er schreibt, etwas bedeutet. Bei `progression.xml` ist das die gefährlichere
Hälfte: ein `<set …/@parent>` mit `attFortitud` trifft den XPath einwandfrei und hängt den
Unterbereich an ein Attribut, das es nicht gibt — er verschwindet aus dem
Fertigkeitsfenster, ohne Fehlermeldung. Dasselbe bei `progression_name`: der Perk verlangt
dann die Stufe eines Attributs, das nirgends existiert, und ist unerreichbar. WP7.2
schreibt **105** solcher Zeilen.

**Was geprüft wird.** Aus Vanillas `progression.xml` werden alle Namen von `attribute`,
`skill`, `perk`, `crafting_skill`, `book_group` und `book` eingesammelt, dazu die, die wir
selbst anlegen. Dagegen werden die Werte von `@parent` und `@progression_name` aufgelöst.
121 Verweise, 0 unaufgelöst.

**Zwei neue Gegenproben, Stand 55** (vorher 53):

| Gegenprobe | erwartet | beweist |
|---|---|---|
| Fortschritts-Verweise werden gezählt, Schlüssel nicht | Exit 0, `Fortschritts-Verweise: 3` | der Zähler ist wählerisch: die Testdatei trägt einen vierten `<set>`, der einen **Sprachschlüssel** schreibt, und der darf nicht mitgezählt werden |
| vertippte Fortschritts-Verweise werden rot | Exit 1, nennt beide einzeln | `@parent` **und** `@progression_name`, und beide XPaths treffen — die XPath-Prüfung sagt also grün |

Der zweite Fall ist der Beweis, dass die beiden Prüfungen nicht dasselbe tun: dieselbe
Datei ist für die XPath-Prüfung einwandfrei und für diese rot.

**Gemessene Grenzen:**

- Geprüft werden nur `@parent` und `@progression_name`. `name_key`, `desc_key`, `icon` und
  die Werte in `display_entry`/`unlock_entry` stehen ungeprüft; die Sprachschlüssel prüft
  `mod700check localization`, die Symbole niemand.
- Der Vorrat kommt aus **Vanilla** plus unseren eigenen Knoten in derselben Datei. Ein
  Verweis auf einen Knoten, den ein **anderes** Modlet anlegt, gilt als rot — das Projekt
  hat bisher nur eine `progression.xml`.
- **Ein auflösbarer Verweis heißt nicht, dass die Zuordnung sinnvoll ist.** Dass der Bogen
  beim Jäger und nicht beim Fuhrmann hängt, prüft kein Skript.

## Nachtrag WP7.2b — der zweite Erzeuger, **Abnahme offen**

`tools/gen/wp7-perks.ps1` hält die Zuordnung der 16 Unterbereiche und 38 lebenden Perks als
Tabelle und erzeugt daraus drei Dateien: die Patch-Zeilen für `progression.xml`, die für
`items.xml` und die Localization-Zeilen. Es **bricht ab**, sobald die Wirklichkeit nicht zur
Tabelle passt, und das ist der eigentliche Wert:

- ein Perk oder Unterbereich im Spiel, der in keiner Tabelle steht (oder umgekehrt),
- ein Perk, der auf einen verborgenen Unterbereich zeigt,
- ein Perk mit einer anderen Zahl als fünf `level_requirements`,
- ein Gegenstand, der die Marke nicht trägt, die umgehängt werden soll,
- **zwei Knoten, die denselben Sprachschlüssel bekommen würden.**

Der letzte Wächter hat beim ersten Lauf `skillCombatPerksName` gefunden — fünf
Nahkampf-Bereiche, ein Schlüssel. Ohne ihn hätten vier unserer Unterbereiche denselben
Namen getragen.

Auch diese Datei trägt eine **UTF-8-BOM** (Windows PowerShell 5.1, siehe Nachtrag WP7.1b).

## Nachtrag WP7.4 — der dritte Erzeuger, **Abnahme offen**

`tools/gen/wp7-abschriften.ps1` erzeugt die Zeilen für D69 aus einer Tabelle im Skript:
welche der 19 Buchreihen lebt, wie sie heißt, welche Einzelbände tot sind und **warum**.

**Schnittstelle.** `-Spiel` (sonst `SDTD_PATH`), `-Repo` (sonst zwei Ebenen über dem
Skript), `-AusOrdner` (sonst `tools/gen/out/`). Gelesen werden `progression.xml`,
`items.xml`, `item_modifiers.xml` und `Localization.csv` des Builds sowie die **erzeugten**
Purge-Dateien `mod/700_10_Purge/Config/items.xml` und `recipes.xml`. Geschrieben werden
fünf Bruchstücke: Zeilen für `progression.xml`, für `items.xml`, für `Localization.csv`,
Freigaben für `denylist.txt` und Schlüssel für `vanilla-keys.txt`.

**Es schreibt keine Mod-Datei.** `mod/700_50_Fortschritt/Config/progression.xml` und
`items.xml` tragen je einen Block zwischen der Zeile
`===== WP7.4 Abschriften (D69) - ERZEUGT von tools/gen/wp7-abschriften.ps1 …` und
`</config>`; er wird von Hand ersetzt. Das gilt jetzt auch für `items.xml`, die bisher
ganz von `wp7-perks.ps1` kam: **eine Datei, zwei Erzeuger** (D53 erlaubt je Modlet nur
eine Datei je Vanilla-Config). Wer `wp7-perks.ps1` neu laufen lässt und seine Ausgabe
über die Datei kopiert, verliert den WP7.4-Block — `kette-pruefen` merkt das nicht, weil
fehlende Zeilen keine falschen XPaths sind. **Das ist eine bekannte Lücke, kein Schutz.**

**Abbruchbedingungen** — bei jeder schreibt das Skript nichts:

1. Eine Reihe steht im Spiel und nicht in der Tabelle, oder umgekehrt.
2. Eine Reihe hat nicht genau acht Knoten, der Abschluss ist nicht der letzte, oder ein
   Band hat nicht genau einen Gegenstand.
3. Ein Gegenstand trägt nicht genau zwei `PerksUnlocked`-Bedingungen auf die eigene Reihe
   mit dem Wert 7.
4. Ein Band wird als tot geführt und ist es nach dem genannten Grund gemessen **nicht**
   (`Rezept`: alle freigeschalteten Rezepte entfernt; `Marke`: jeder Träger gesperrt;
   `Buff`: jeder Geber gesperrt; `ModTraeger`: jeder Träger der Marke gesperrt).
5. Ein Band wird als lebend geführt, und der Purge hat **alle** seine Rezepte entfernt.
6. Ein lebender Band erbt von einem toten.
7. Die Ablage ist keine tote Reihe.
8. Ein Schlüssel, der überschrieben werden soll, ist geteilt — außer
   `perkBookGroupLongDesc`, der von genau den 19 Reihen geteilt sein **muss**.

**Nachweis nach Projektregel 5.** Vier Läufe gegen eine absichtlich falsche Tabelle, jeder
mit Exit 1 und null geschriebenen Dateien:

| falsch gemacht | Meldung |
|---|---|
| `perkBatterUpBigHits` als tot mit Grund `Rezept` | „wird als tot gefuehrt …, ist es gemessen aber NICHT" |
| `perkUrbanCombatCigar` aus der Tabelle genommen | „gilt als lebend, aber der Purge hat ALLE seine Rezepte entfernt" |
| Ablage `skillArchery` | „Die Ablage 'skillArchery' ist keine tote Reihe" |
| `perkFiremansAlmanacHeat` als tot | 17 Fehler, darunter 16 Mal „lebt, erbt aber vom toten" |

Diese vier Läufe stehen **nicht** in `gegenproben.ps1`: sie brauchen den Build und
verändern das Skript. Sie sind von Hand gelaufen, am 16. November 2026, und müssten nach
einer Änderung am Skript von Hand wiederholt werden. **Auch das ist eine Lücke.**

**Reihenfolge.** Das Skript liest die Purge-Dateien, und die Purge-Dateien entstehen aus
der Denylist, in die das Skript Freigaben schreibt. Der Kreis ist keiner, solange die
Reihenfolge stimmt: Erzeuger → Freigaben in die Denylist → `mod700check purge-patch` →
Erzeuger noch einmal. Der zweite Lauf muss dieselben fünf Dateien schreiben; am
16. November tat er das (gleiche Prüfsummen).

**Grenzen.**

- Der Grund eines toten Bandes wird geprüft, die **Vollständigkeit** nur für Rezepte:
  ein Band, der über eine Marke oder einen Buff tot ist und in der Tabelle fehlt, fällt
  nicht auf. Die sechs heutigen sind von Hand gefunden (Befund §7.4).
- Geprüft wird gegen Vanilla und die erzeugten Purge-Zeilen, nicht gegen einen
  ConfigsDump.
- Was das Spiel aus den Zeilen macht, sagt das Skript nicht — Prüfliste 16.

## Nachtrag WP7.5 — der vierte Erzeuger, **Abnahme offen**

`tools/gen/wp7-bindung.ps1` erzeugt die Zeilen für D70. Im Skript stehen fünf Tabellen:
welche Rezepte Vanillas Linie folgen, welche Rüstungsteile unter welcher Basisklasse
stehen, wohin der Webstuhl gehört, welche Rezepte **offen** bleiben und **warum**, und die
Schablonen für Lehrblätter und Pergament. **Stufe, Level und Marken stehen nicht im
Skript** — sie werden aus dem Build gelesen.

**Schnittstelle.** `-Spiel` (sonst `SDTD_PATH`), `-Repo`, `-AusOrdner` (sonst
`tools/gen/out/`). Gelesen werden `progression.xml`, `recipes.xml`, `items.xml` und
`Localization.csv` des Builds; aus dem Repo die drei handgeschriebenen Rezeptdateien
(700_20, 700_30, 700_40), `700_30_Ausruestung/Config/items.xml`, unsere
`progression.xml` (welche Stufen verborgen sind), unsere `Localization.csv` (die Namen
der Stufen) und die **erzeugte** `700_10_Purge/Config/recipes.xml`. Geschrieben werden
fünf Dateien: `recipes.xml` für 700_50 **als ganze Datei**, dazu Bruchstücke für
`progression.xml`, `Localization.csv`, `denylist.txt` und `vanilla-keys.txt`.

**Zum ersten Mal schreibt ein Erzeuger eine ganze Mod-Datei** — aber weiter nach
`tools/gen/out/`, nicht in den Mod-Ordner; sie wird von Hand hinüberkopiert. Die Bindung
hat damit eine Quelle. `progression.xml` trägt einen dritten erzeugten Block
(`===== WP7.5 Bindung (D70) - ERZEUGT …`), für den dieselbe Lücke gilt wie im Nachtrag
WP7.4: wer einen anderen Erzeuger über die Datei kopiert, verliert ihn unbemerkt.

**Abbruchbedingungen** — bei jeder schreibt das Skript nichts:

1. Eines unserer Rezepte steht in **keiner** Tabelle (weder gebunden noch offen), in
   **zwei** Tabellen, oder eine Tabelle nennt ein Rezept, das wir nicht haben.
2. Ein Rezept trägt in seiner eigenen Datei schon ein `tags`-Attribut.
3. Vanillas Linie: Vanilla hat kein Rezept dieses Namens, führt mehrere mit
   verschiedenen Marken, das Rezept ist dort nicht `learnable`, oder nicht **genau eine**
   Handwerks-Stufe schaltet es frei.
4. Rüstung: die Anzeigezeile beginnt nicht mit der genannten Basisklasse; sie führt noch
   ein **lebendes** Rezept (das Überschreiben nähme es aus der Anzeige); ein Teil erbt
   nicht von der genannten Klasse; das Symbol-Teil hat kein `CustomIcon`; die Klasse hat
   nicht genau eine Freischalt- und eine Qualitätszeile.
5. Werkstatt: der Platz ist nicht frei (sein Rezept lebt), er liegt nicht **nach** der
   Werkbank des Rezepts, es gibt einen **früheren** freien Platz, oder das Vanilla-Rezept
   des Platzes entsteht an einer anderen Werkbank (die Marken wären nicht übertragbar).
6. Ein gebundenes Rezept hängt an einer verborgenen Stufe oder verlangt mehr als deren
   Höchstlevel.
7. Eine **lebende** Stufe hat nicht genau ein Heft, oder das Heft führt kein
   `AddProgressionLevel` auf sie.
8. Ein Schlüssel, der überschrieben wird, fehlt in Vanilla oder wird mehrfach benutzt;
   ein erzeugter Schlüssel kommt doppelt vor.

**Nachweis nach Projektregel 5.** Vier Läufe gegen eine absichtlich falsche Tabelle, jeder
mit Exit 1 und null geschriebenen Dateien:

| falsch gemacht | Meldung |
|---|---|
| `doorWoodLargeGate` aus der Tabelle „offen" genommen | „hat keine Entscheidung: weder gebunden noch offen" |
| `resourceForgedIron` zusätzlich in Vanillas Linie | „steht in zwei Tabellen" und „verschiedene Marken" |
| Platz des Webstuhls `cntDewCollector` | „Der erste freie Platz nach 'workbench' ist 'toolChickenCoopLamp' (Level 14)" |
| Wolle und Leder unter `armorMediumMaster` | 5 Fehler (Basisklasse der Anzeigezeile und Vererbung der Teile passen nicht zur Tabelle) |

Wie im Nachtrag WP7.4 stehen diese Läufe **nicht** in `gegenproben.ps1` (sie brauchen
den Build und verändern das Skript); gelaufen von Hand am 16. November 2026.

**Reihenfolge.** Erzeuger → Freigaben in die Denylist, `*SkillMagazine` und
`resourcePaper` aus `aufschub.txt` → `mod700check purge-patch` → Erzeuger noch einmal.
Der zweite Lauf schrieb am 16. November dieselben fünf Dateien (gleiche Prüfsummen), und
`mod/700_50_Fortschritt/Config/recipes.xml` ist bytegleich mit dem Erzeugnis.

**Was `check-all.ps1` danach meldet** (16. November 2026, `SDTD_PATH` gesetzt): 55
Gegenproben, 0 fehlgeschlagen; `recipes`, `purge-patch`, `localization` und
`kette-pruefen` grün (392 XPaths, 141 Fortschritts-Verweise, 0 unaufgelöst; 1971
Patchzeilen, 0 ohne Treffer, 0 gesperrt und noch erreichbar); `anachronisms` **rot mit
645** gegen den ConfigsDump vom 7. Juli, in dem unsere Modlets nicht geladen waren —
derselbe Grund wie seit WP3, zehn mehr als nach WP7.4, weil zehn Hefte jetzt verboten
statt aufgeschoben sind.

**Grenzen.**

- **Die Vollständigkeit prüft das Skript nur in eine Richtung.** Ein neues eigenes Rezept
  ohne Zeile bricht den Lauf ab. Ob ein als „offen" geführtes Rezept offen sein *sollte*,
  prüft niemand — der Grund daneben ist Text.
- **`kette-pruefen` kennt `learnable` nicht.** Ein gebundenes Rezept ohne Stufe, die es
  freischaltet, wäre nie herstellbar; das fängt allein der Erzeuger (Bedingung 3 und 6),
  nicht der Prüflauf. Wer `recipes.xml` in 700_50 von Hand ändert, hat diesen Schutz nicht.
- **Dass 700_50 nach 700_20/30/40 lädt**, setzt jede der 24 Zeilen voraus und prüft
  dieses Skript nicht.
- Was das Spiel aus den Zeilen macht, sagt das Skript nicht — Prüfliste 17.
