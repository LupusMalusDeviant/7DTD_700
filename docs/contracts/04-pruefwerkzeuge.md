# Vertrag 04 — Prüfwerkzeuge

- **Status:** **Abgenommen vom Nutzer am 2026-11-22** (Entwurf vom 2026-11-07) — als Block, mit
  allen Abschnitten und Nachträgen bis einschließlich „Nachtrag Review zu WP8.9". Grundlage
  war eine Kurzübersicht der Regeln, die Entscheidungen des Nutzers sind. Darin enthalten sind
  die zwei Berichtigungen, die eine eigene Abnahme brauchten: §3a (Erreichbarkeit) und §3d samt
  den §5-Nachträgen. Wo weiter unten „gebaut vor der Abnahme" steht, beschreibt das den Stand,
  als der Abschnitt entstand. **Nicht** Teil der Abnahme: was der Vertrag selbst als offen oder
  als Grenze nennt, und die zwei unbehobenen Befunde aus dem zweiten Review der Vorprüfung
  (Plan-0001, offene Punkte) — das sind Fehler im Werkzeug, keine Regeln. *(Seit dem Nachtlauf
  vom 2026-11-22 behoben, siehe den letzten Nachtrag; dessen Abnahme ist offen.)*
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

## 3b. Jede Kennung bekommt ein Urteil (Nachtrag WP3.1c) — **abgenommen 2026-11-22**

> **Abgenommen:** vom Nutzer am 2026-11-07 (Plan-0001 WP3, samt den drei Sichtungsgruppen),
> bestätigt mit der Block-Abnahme vom 2026-11-22. Der Vermerk aus der Zeit davor lautete:
>
> **Status:** gebaut und gemessen, aber ~~**nicht abgenommen.**~~ §3a hat der Nutzer am
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

## 3d. Der sechste Weg: Block-Abwürfe (Nachtrag WP4.1) — **abgenommen 2026-11-22**

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

### Nachtrag WP5.1 (2026-11-08): es sucht die Dateien jetzt selbst — **abgenommen 2026-11-22**

Die beiden Pfade standen fest im Skript, auf `700_20_Material`. Als WP5.1 die Waffenrezepte in
`700_30_Ausruestung` anlegte, **hat das Skript sie nicht gesehen und weiter grün gemeldet**.
Ein Prüfer, der nur die Dateien kennt, die man ihm beim Schreiben genannt hat, prüft das
falsche Projekt — und er fällt nicht auf, weil er grün bleibt.

Jetzt sucht es `mod/**/recipes.xml` und `mod/**/items.xml` selbst und nimmt `700_10_Purge`
aus (erzeugt, enthält nur Entfernungen). Gemessen nach der Änderung: **15 Rezepte, 12
werkzeuggebunden, 0 unaufgelöste Verweise** — vorher sah derselbe Lauf nur 4 davon.

### Nachtrag WP5.5b (2026-11-08): es sieht auch unsere **Blöcke** — **abgenommen 2026-11-22**

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

### Nachtrag WP6 (2026-11-08): eingehängte Zutaten und Reparaturwerkzeuge — **abgenommen 2026-11-22**

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

### Nachtrag WP6.1 (2026-11-08): umgebogene Verweise — **abgenommen 2026-11-22**

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

### Nachtrag WP6.4 (2026-11-08): Verweise in eigenen Definitionen — **abgenommen 2026-11-22**

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

## 5b. `rezepte_mit_gesperrter_zutat` — der dritte Nebeneffekt des Purge (Nachtrag WP5.1) — **abgenommen 2026-11-22**

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

## Nachtrag WP7.1 — die XPaths selbst (8. November 2026), **abgenommen 2026-11-22**

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
- ~~Dateien, die Vanilla unter diesem Namen nicht hat (`XUi_InGame/*`, `Localization.csv`),
  bleiben außen vor.~~ *(Seit dem 2026-11-20 anders, siehe „Nachtrag drittes Review":
  Patches unter `XUi_InGame/` werden gegen Vanillas `XUi_InGame/` geprüft, eine XML-Patch-Datei
  ohne Vanilla-Gegenstück ist rot. `Localization.csv` ist keine XML-Datei; sie prüft
  `mod700check localization`.)*
- **Ein getroffener XPath heißt nicht, dass der Patch das Richtige tut.** Dafür sind die
  vier anderen Verweisklassen da — und für den Rest der Spieltest.

## Nachtrag WP7.1b — ein Erzeuger für Localization-Zeilen, **abgenommen 2026-11-22**

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

## Nachtrag WP7.2 — Fortschritts-Verweise (8. November 2026), **abgenommen 2026-11-22**

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
  `mod700check localization`, die Symbole niemand. *(Berichtigt am 2026-11-22: `localization`
  prüft nur die Form der Datei. Ob ein genannter Schlüssel eine Zeile hat, prüft seit WP8.8
  `sprachverweise-pruefen.ps1`, siehe „Nachtrag WP8.8".)*
- Der Vorrat kommt aus **Vanilla** plus unseren eigenen Knoten in derselben Datei. Ein
  Verweis auf einen Knoten, den ein **anderes** Modlet anlegt, gilt als rot — das Projekt
  hat bisher nur eine `progression.xml`.
- **Ein auflösbarer Verweis heißt nicht, dass die Zuordnung sinnvoll ist.** Dass der Bogen
  beim Jäger und nicht beim Fuhrmann hängt, prüft kein Skript.

## Nachtrag WP7.2b — der zweite Erzeuger, **abgenommen 2026-11-22**

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

## Nachtrag WP7.4 — der dritte Erzeuger, **abgenommen 2026-11-22**

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

## Nachtrag WP7.5 — der vierte Erzeuger, **abgenommen 2026-11-22**

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

## Nachtrag WP8.5 — Glossar gegen Sprachdatei (20. November 2026), **abgenommen 2026-11-22**

F-12 verlangt als Abnahme „Glossar und Localization sind konsistent (Prüfskript)". Dieser
Nachtrag beschreibt das Skript. **Gebaut vor der Abnahme**, wie die Nachträge seit WP7.1 —
das ist eine Abweichung von „Verträge zuerst" und steht darum hier und in Prüfliste 21.

**Schnittstelle.** `tools/check/glossar-pruefen.ps1 [-Glossar <datei>] [-Sprachdatei <datei>]`.
Ohne Angabe `docs/glossar.md` und `mod/700_90_Sprache/Config/Localization.csv`. Kein
`SDTD_PATH`, kein Spiel: das Skript liest nur Dateien des Repos.

**Eingabeformat — das Glossar ist die Quelle, es gibt keine zweite Liste.** Gelesen werden
Markdown-Tabellen, erkannt an ihrer Kopfzeile; jede andere Tabelle und jeder Fließtext wird
übersprungen.

| Kopfzeile | Bedeutung einer Zeile |
|---|---|
| `Kennung, Deutsch, Englisch, Vanilla, Quelle` | Festbegriff. Erste Spalte: Kennung in Backticks, oder ein Gedankenstrich für „noch kein Schlüssel" (gezählt, nicht verglichen). |
| `Verboten, Sprache, Stattdessen, Quelle` | Verbot. Erste Spalte: regulärer Ausdruck in Backticks, Groß-/Kleinschreibung egal. Sprache ist `DE`, `EN` oder `beide`. |

**Was rot ist (Exit 1).**

1. Ein Festbegriff, dessen Schlüssel in der Sprachdatei fehlt.
2. Ein Festbegriff, dessen deutscher oder englischer Text nicht **zeichengenau** dem Glossar
   entspricht.
3. Eine Zeile der Sprachdatei, deren deutsche oder englische Spalte ein verbotenes Muster
   enthält — in der Sprache, für die es verboten ist.

**Was nicht prüfbar ist (Exit 2) — und in `check-all.ps1` als rot zählt.** Glossar oder
Sprachdatei fehlt; im Glossar steht kein Festbegriff mit Kennung oder kein Verbot; eine
Tabellenzeile hat die falsche Spaltenzahl (ein `|` im Muster); ein Muster ist kein regulärer
Ausdruck; die Sprache ist unbekannt; der Sprachdatei fehlt eine der Spalten `Key`, `english`,
`german`, oder sie hat keine Zeile. **Das ist die Lehre aus dem Befund zu `kette-pruefen`**
(Review vom 20. November: ohne `SDTD_PATH` überspringt es sich mit Exit 0 und wird grün
gezählt) — ein Prüfer, der nichts gelesen hat, hat nicht bestanden.

**Gegenproben (Projektregel 5) — neun, alle grün am 20. November.** Testdaten unter
`tools/check/testdaten/glossar/`. Sauber → 0. Verbotener Begriff → 1, **und** ein Wort, das
nur im Deutschen verboten ist, bleibt im Englischen unbemerkt („level", „duke" in der
Einzahl). Abweichender und fehlender Festbegriff → 1. Glossar ohne Tabelle, Glossar ohne
Verbote, kaputtes Muster, `|` im Muster, fehlende Sprachdatei, fehlendes Glossar → je 2, und
in keiner dieser Ausgaben steht „GREEN".

**Was `check-all.ps1` danach meldet** (20. November 2026, `SDTD_PATH` gesetzt): 64
Gegenproben, 0 fehlgeschlagen; sechs Prüfungen statt fünf; `recipes`, `purge-patch`,
`localization` (612 Zeilen), **Glossar** (49 Festbegriffe mit Kennung, 13 ohne, 48 Muster, 0
Abweichungen, 0 Treffer) und `kette-pruefen` (415 XPaths, 0 unaufgelöst) grün; `anachronisms`
**rot mit 645** gegen den ConfigsDump vom 7. Juli — derselbe Grund wie seit WP3.

**Grenzen.**

- **Gelesen wird nur unsere Sprachdatei.** Vanilla-Zeilen, die wir nicht überschreiben, sieht
  die Prüfung nicht. Gemessen tragen 686 davon einen Weltbegriff, 505 möglicherweise sichtbar
  — das ist Arbeitsvorrat für WP8.5, und „Glossar grün" sagt darüber nichts.
- **Gefunden wird das Verbotene, nicht das Fehlende.** Ob ein Text „Seuchentote" sagt, wo er
  es sollte, prüft niemand.
- **Ein Muster ist so gut wie sein Schreiber.** `beton(?![teu])` lässt „betont" durch und
  fängt „Betonblock" — ein Wort, an das niemand dachte, fängt es nicht. Die Liste wächst mit
  den Texten.
- **Vollständigkeit prüft das Skript nicht.** Ein Name in der Sprachdatei, der im Glossar
  fehlt, ist kein Fehler; 49 von rund 290 Namenszeilen stehen drin.
- **Die Gegenproben der mod700check-Befehle und die von `kette-pruefen` laufen weiter über
  dieselbe Hilfsfunktion** (`Test-Script`, jetzt mit dem Parameter `-Skript`); der Vorgabewert
  hält die alten Aufrufe unverändert.

**Nicht in diesem Schritt behoben:** der Befund zu `kette-pruefen` selbst (Exit 0 ohne
`SDTD_PATH`) und der übersprungene `purge-patch`-Lauf, der in `check-all.ps1` weder gezählt
noch rot wurde. → Behoben im folgenden Nachtrag.

## Nachtrag Review 2026-11-20 — ohne Spielpfad ist nichts grün, **abgenommen 2026-11-22**

Vor dem Push von WP1–WP8.4 hat ein unabhängiges Review (Codex war am Limit, darum eine
getrennte, nur lesende Claude-Sitzung) sieben Befunde gemeldet. Dieser Nachtrag behebt den
ersten und hält die übrigen fest.

**Befund 1 (hoch), behoben.** Ohne `SDTD_PATH`, aber mit einem ConfigsDump unter
`%APPDATA%`, endete `check-all.ps1` mit „N Prüfungen, 0 rot, GRUEN" und Exit 0:

- `kette-pruefen.ps1` schrieb „übersprungen, KEIN GRUEN" und ging mit **Exit 0** hinaus —
  der Text sagte das Richtige, der Ausgang das Gegenteil.
- der `purge-patch`-Vergleich schrieb „kein Grün" und änderte **keinen Zähler**.

Der Stop-Hook liest den Ausgang. **Vertragsänderung:** ein Prüfschritt, der nicht laufen
kann, ist **nicht geprüft und zählt als rot** — für jeden Schritt von `check-all.ps1`, nicht
nur für die `mod700check`-Befehle (dort galt Exit 2 = rot schon seit WP2).

| Schritt | vorher | jetzt |
|---|---|---|
| `kette-pruefen.ps1` ohne `SDTD_PATH` und ohne `-Vanilla` | Exit 0 | **Exit 2**, „NICHT GEPRUEFT" |
| `purge-patch` ohne Vanilla | nicht gezählt | gezählt, **rot** |
| `localization`, wenn unsere Datei fehlt | nicht gezählt | gezählt, **rot** |
| `kette-pruefen.ps1` fehlt | still ausgelassen | gezählt, **rot** |

**Gegenproben — zwei, und beide einmal rot gesehen.** `Test-Script` hat dafür den Schalter
`-OhneSpielpfad` (nimmt `SDTD_PATH` für den einen Lauf weg und stellt sie wieder her).
(1) `kette-pruefen` ohne Spielpfad → Exit 2. (2) `check-all.ps1 -SkipGegenproben` ohne
Spielpfad gegen `testdaten/sauber` → „6 Pruefungen, 3 rot", beide Schritte namentlich als
nicht geprüft. **Gegen die alten Skripte gefahren** (Stand `c829afa`): 66 Gegenproben, **2
fehlgeschlagen** — genau diese beiden („Exit 0 erwartet 2"; „fehlt in der Ausgabe: 6
Pruefungen, 3 rot"). Mit den neuen: 66, 0 fehlgeschlagen.

**Folge für die Arbeit:** wer `SDTD_PATH` nicht gesetzt hat, bekommt vom Prüfbefehl kein Grün
mehr. Das ist gewollt. Die Variable ist auf diesem Rechner nicht dauerhaft gesetzt (jeder
Lauf setzt sie selbst).

**Die übrigen Befunde — nicht behoben, damit sie nicht verloren gehen:**

2. ~~*(mittel)* Patches unter `XUi_InGame/` überspringt `kette-pruefen` still: die
   Vanilla-Datei wird nur nach Dateinamen im obersten Ordner gesucht. Der Kommentar daneben
   sagt „gezählt". Zwei Dateien in `700_40_Bauen` sind betroffen.~~ **Behoben am 2026-11-20,
   siehe „Nachtrag drittes Review".**
3. *(mittel)* `purge-patch --vergleiche` vergleicht eine Kopfzeile mit dem Änderungsdatum von
   `Data/Config` mit. Ein Steam-Update ohne inhaltliche Änderung meldet jede Datei als
   veraltet.
4. *(mittel, bekannt)* Die Erzeuger unter `tools/gen/` haben keinen Vergleichslauf.
5. *(mittel, bekannt seit WP8.3)* Buff-Verweise (`ActiveRadiusEffects`, `triggered_effect/@buff`)
   löst niemand auf.
6. *(niedrig)* `wp7-bindung.ps1` zählt seine Rezeptdateien von Hand auf — derselbe Fehler, den
   `kette-pruefen` seit WP5.1 nicht mehr macht.
7. *(niedrig, dokumentierte Grenze)* XPaths werden gegen Vanilla geprüft, nicht gegen den
   Stand nach dem Purge.

Dazu aus diesem Vertrag selbst, seit WP8.1 offen und von derselben Art wie Befund 1:
`kette-pruefen -Patches <pfad, den es nicht gibt>` meldet „0 XPaths, GREEN". → Behoben im
folgenden Nachtrag.

## Nachtrag zweites Review 2026-11-20 — sechs Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `c829afa` und `71cd623` hat Codex (`gpt-6.2-sol`) acht Befunde gemeldet:
keiner kritisch oder hoch, fünf mittel, drei niedrig. Sechs sind hier behoben, zwei nicht.

| Nr. | Befund | Was jetzt gilt |
|---|---|---|
| 1 | Tippfehler in einer Glossar-Kopfzeile („Sprachen") machte die Tabelle zu Fließtext; ihre Verbote fielen still weg. | **Jede Tabelle des Glossars muss eine der zwei Formen haben.** Unbekannte Kopfzeile → Exit 2. |
| 4 | Relativer Pfad nach einem Ordnerwechsel: gefunden, aber nicht gelesen (PowerShell-Ordner ≠ Prozess-Ordner). | Beide Pfade werden vor dem Lesen aufgelöst; ein Lesefehler ist Exit 2. |
| 5 | `SDTD_PATH` gesetzt, aber ohne `Data\Config`: `kette-pruefen` warf eine Ausnahme, `check-all.ps1` endete **ohne Ergebniszeile**. | `kette-pruefen` → Exit 2. `check-all.ps1` fängt Ausnahmen beider Prüfskripte und zählt sie als nicht geprüft. |
| 6 | Die verschachtelte Gegenprobe rief `check-all.ps1` immer mit Release. | `Configuration` wird durchgereicht. |
| 7 | „Groß-/Kleinschreibung egal" hing an der Sprache des Rechners (tr-TR: `zombie` traf `ZOMBIE` nicht). | `RegexOptions.CultureInvariant`. |
| 8 | „Jagdmesser" stand im Glossar als alter Name, aber ohne Verbot. | 29 Muster nachgetragen (77 statt 48); eine Liste „alte Namen ohne Verbot, mit Grund" im Glossar. |

Dazu der Fall aus WP8.1: **ein genannter Pfad, den es nicht gibt**
(`-Rezepte`, `-Gegenstaende`, `-Bloecke`, `-Patches`), ist in `kette-pruefen` jetzt Exit 2.

**Befund 8 hat sofort etwas gefunden.** Die nachgetragenen Muster machten den echten Lauf
rot: vier unserer Zeilen benutzten einen alten Namen — „forged iron" statt „wrought iron"
(`meleeWpnKnucklesT1IronKnucklesDesc`, `trapSpikesGroupDesc`) und „Vorschlaghammer" /
„sledgehammer" statt „Hammer" (`prk700_strengthCombatDesc`, `perkSkullCrusherDesc`). Die
Texte sind berichtigt, die beiden Perk-Texte auch im Erzeuger `tools/gen/wp7-perks.ps1`.

**Gegenproben — sechs neue, alle einmal rot gesehen.** Gegen die Skripte des Stands
`71cd623`: 72 Gegenproben, **6 fehlgeschlagen** — genau diese sechs (Kopfzeile, relativer
Pfad, türkische Kultur, Spielpfad ohne `Data\Config` in `kette-pruefen` und in `check-all`,
genannter Pfad ohne Datei). Gegen die neuen: 72, 0 fehlgeschlagen. `Test-Script` hat dafür
den Parameter `-Spielpfad` (setzt `SDTD_PATH` für einen Lauf auf einen falschen Ordner).

**Dabei selbst gebaut und selbst gefangen:** der erste Wurf von `-Spielpfad` sicherte den
alten Wert in `$spielpfad` — in PowerShell dieselbe Variable wie der Parameter `$Spielpfad`.
Vier Gegenproben wurden rot, bevor irgendetwas committet war.

**Nicht behoben:**

- ~~**Befund 2** — der CSV-Leser von `mod700check` nimmt ein Anführungszeichen mitten in einem
  Feld ohne Anführung hin. Eigener Schritt, eigener Commit.~~ **Behoben im folgenden
  Commit, siehe unten.**
- **Befund 3** — eine gefüllte dritte Sprachspalte ist nur ein Hinweis. F-12 sagt „Spalten
  leer lassen" **und** „weitere Sprachen später über die Community"; ob das heute ein Fehler
  sein soll, entscheidet der Nutzer.

### Befund 2 — `localization` meldet kaputte Anführung (`csv-form`)

**Vertragsänderung an `mod700check localization`:** ein neuer Fehler `csv-form` und ein
Zähler `csv_form_fehler`. Der CSV-Leser liest weiter nachsichtig (damit Spaltenzahl und
Schlüssel prüfbar bleiben), **meldet** aber jede Stelle, an der die Anführung nicht stimmt:

1. ein Anführungszeichen mitten in einem Feld (`Scrap of "Parchment"`),
2. ein Zeichen nach dem schließenden Anführungszeichen (`"Hearth"x`),
3. ein nie geschlossenes Anführungszeichen — gemeldet wird die Zeile, in der es **aufgeht**.

Gültig bleibt das verdoppelte Zeichen in einem Feld in Anführung (`"A ""good"" word"`).

**Gegenproben — zwei, beide einmal rot gesehen.** `testdaten/Localization-anfuehrung.csv` ist
so gebaut, dass die Spaltenzahl stimmt. Gegen das alte Programm: 74 Gegenproben, **2
fehlgeschlagen** („Exit 0 erwartet 1"). Gegen das neu gebaute: 74, 0 fehlgeschlagen.

**Unsere Datei:** 612 Zeilen, `csv_form_fehler 0`.

**Grenze:** was das **Spiel** aus einer solchen Zeile macht, ist nicht gelesen
(`Localization::addCsv`). Die Prüfung verlangt sauberes CSV, sie behauptet nicht, das Spiel
verlange es auch.

## Nachtrag drittes Review 2026-11-20 — fünf Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `537fa6c` und `034313f` hat Codex (`gpt-6.2-sol`) sieben Befunde gemeldet:
keiner kritisch oder hoch, vier mittel, drei niedrig. Fünf sind hier behoben, einer schon in
`4420e66` (Befund 7: die Einengung von D75 steht als eigene Zeile D76), einer wartet auf den
Nutzer.

| Nr. | Befund | Was jetzt gilt |
|---|---|---|
| 1 | `kette-pruefen -Patches <Ordner>` und eine Patch-Datei ohne Vanilla-Gegenstück: beides „0 XPaths, GREEN". | Ein genannter Pfad muss eine **Datei** sein → sonst Exit 2. Eine XML-Patch-Datei ohne Vanilla-Gegenstück ist **rot** (Exit 1), nicht „außen vor". |
| 2 | Eine Glossar-Tabelle **ohne Randstriche** (gültiges Markdown) galt als Fließtext; ihre Verbote fielen weg, die Kopfzeilen-Prüfung sah sie nie. | Tabellen werden an ihrer **Trennzeile** erkannt, mit oder ohne Rand. Eine Trennzeile ohne Kopfzeile davor → Exit 2. |
| 3 | Der CSV-Leser verwarf einen einzelnen Wagenrücklauf (CR ohne LF) außerhalb der Anführung: `"Hearth"<CR>,` las sich wie `"Hearth",`. | Vierter Fall von `csv-form`. Ein CR direkt vor einem LF bleibt gültig (unsere Datei ist CRLF). |
| 5 | `SDTD_PATH` auf einem Laufwerk, das nicht eingehängt ist: `Join-Path` warf, `check-all.ps1` endete wieder ohne Ergebniszeile. | Beide Skripte bauen den Pfad mit `[IO.Path]::Combine`. `kette-pruefen` → Exit 2 („den Vanilla-Ordner … gibt es nicht"), `check-all.ps1` → „6 Pruefungen, 3 rot". |
| 6 | Eine Datei aus einem einzigen Anführungszeichen meldete nur `leere-datei`. | `csv-form` wird **vor** der Abfrage auf eine leere Datei gemeldet; beide Fehler stehen da. |

### Vertragsänderung an `kette-pruefen`: das Gegenstück wird nach Pfad gesucht

Bisher wurde zu jeder Patch-Datei nur ihr **Dateiname** im obersten Vanilla-Ordner gesucht.
`mod/700_40_Bauen/Config/XUi_InGame/xui.xml` und `…/windows.xml` fanden dort nichts und
wurden übersprungen — Befund 2 des **ersten** Reviews, seit WP8.1 nur aufgeschrieben. Jetzt
gilt der Pfad **relativ zu `Config\`**: `Config/XUi_InGame/windows.xml` wird gegen
`Data/Config/XUi_InGame/windows.xml` gehalten. Liegt eine Datei unter keinem `Config`-Ordner
(Testdaten), zählt wie bisher der Dateiname.

Die Ausgabe hat eine neue Zeile: `Patch-Dateien: N mit Vanilla-Gegenstueck, M ohne`.

**Gemessen am 2026-11-20:** 18 Patch-Dateien, 0 ohne Gegenstück; **418 XPaths** (vorher 415),
405 in Vanilla, 13 auf eigene Knoten, 0 unaufgelöst. Die drei neuen sind die XUi-Patches aus
`700_40_Bauen` — sie treffen.

### Gegenproben — zehn neue, alle einmal rot gesehen

Gegen die Skripte des Stands `4420e66` und das noch nicht neu gebaute `mod700check`:
**84 Gegenproben, 12 fehlgeschlagen** — die zehn neuen und die zwei bestehenden, deren
erwarteter Text sich geändert hat (ein Spielpfad ohne `Data\Config` meldet jetzt „den
Vanilla-Ordner … gibt es nicht" statt „items.xml fehlt", weil der Ordner zuerst geprüft wird).
Gegen den neuen Stand: 84, 0 fehlgeschlagen.

| Gegenprobe | vorher | jetzt |
|---|---|---|
| `localization`: einzelnes CR (`Localization-einzelnes-cr.csv`) | Exit 0 | Exit 1, `csv-form` Zeile 2 |
| `localization`: nur ein Anführungszeichen | nur `leere-datei` | dazu `csv-form` Zeile 1 |
| `kette-pruefen -Patches <Ordner>` | Exit 0, GREEN | Exit 2 |
| Patch-Datei ohne Gegenstück (`kette/ohne-gegenstueck/biomes.xml`) | Exit 0 | Exit 1 |
| Patch im Unterordner (`kette/unterordner/Config/XUi_InGame/windows.xml`) | Exit 0 | Exit 1, „XPath trifft nichts" |
| Glossar ohne Randstriche (`glossar-ohne-rand.md`) | Exit 2, „kein einziger Festbegriff" | gelesen; Exit 1 an `ZOMBIE` |
| ohne Randstriche **und** „Sprachen" im Kopf | Exit 0, GREEN | Exit 2 |
| Trennzeile ohne Kopfzeile | Exit 0, GREEN | Exit 2 |
| `kette-pruefen`, Spielpfad auf fehlendem Laufwerk | Ausnahme | Exit 2 |
| `check-all.ps1`, Spielpfad auf fehlendem Laufwerk | Ausnahme, keine Ergebniszeile | „6 Pruefungen, 3 rot" |

Den Laufwerksbuchstaben für die letzten beiden **sucht** die Gegenprobe (der erste freie); ist
keiner frei, zählen beide als fehlgeschlagen, nicht als übersprungen.
`Localization-einzelnes-cr.csv` ist mit `printf` erzeugt, weil ein Editor das eine Byte `0x0D`
nicht stehen lässt.

### Grenzen und was offen bleibt

- **Befund 4** (zugleich Befund 3 des zweiten Reviews): eine gefüllte dritte Sprachspalte ist
  weiter nur ein Hinweis. Die Entscheidung liegt beim Nutzer.
- **Eine Patch-Datei ohne Vanilla-Gegenstück ist rot** — das stützt sich auf Vertrag 03 §3
  und das Finding WP1 (der Patcher ordnet über den Dateinamen zu). Legt ein späteres Paket
  eine XML-Datei unter `Config/` an, die **kein** Patch ist, wird sie hier rot; dann ist diese
  Regel zu ändern, nicht die Datei umzubenennen.
- **Was unter einer Tabelle ohne Leerzeile steht, zählt als Tabellenzeile.** So liest es auch
  Markdown; ein Satz direkt unter einer Tabelle wird damit „N Spalten statt M", Exit 2 —
  laut, nicht still.
- **Dass eine CRLF-Datei grün bleibt, zeigt nur unsere echte Datei** (618 CRLF,
  `csv_form_fehler 0`). Eine Testdatei dafür gibt es nicht: `core.autocrlf` würde ihre
  Zeilenenden je Rechner umschreiben.
- **Dabei gefunden, nicht behoben:** Vertrag 03 §5 verlangt für **jeden** XUi-Eingriff einen
  `conditional`-Block (D5). Die drei XUi-Patches in `700_40_Bauen` stehen ohne einen auf der
  ersten Ebene — nur deshalb zählt `kette-pruefen` sie. Das ist eine Abweichung vom Vertrag,
  die bisher nirgends stand. Und sie hat eine Kehrseite: sobald die Patches in einem
  `<conditional>` stecken, sieht `kette-pruefen` sie **nicht** mehr (Grenze seit WP7.1). Beides
  gehört zusammen gelöst, in WP8.7/WP8.9: die Schreibweise der Bedingungen ist noch nicht
  belegt, und welche UI-Mods hineingehören, hängt an Q8 (Vertrag 03 §9).
- Offen aus dem ersten Review bleiben die Befunde 3 bis 7.

## Nachtrag viertes Review 2026-11-21 — fünf Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `4420e66` bis `5fd3ea9` hat Codex (`gpt-6.2-sol`) fünf Befunde gemeldet:
keiner kritisch oder hoch, drei mittel, zwei niedrig. Drei treffen die Prüfwerkzeuge, zwei
die Texte der dritten Scheibe von WP8.5.

| Nr. | Befund | Was jetzt gilt |
|---|---|---|
| 1 | `kette-pruefen` zählte eine Datei als geprüft, in der es **keinen** XPath fand: falscher Wurzelknoten (`<configs>`), eine Vanilla-Datei als Patch, ein Tippfehler im Namen der Operation. „1 Patch-Datei, 0 XPaths, GREEN". | Der Wurzelknoten muss `<config>` heißen (Vertrag 03 §7). Jedes Kind muss eine bekannte Operation sein und ein `xpath` tragen. Eine Patch-Datei ohne eine einzige Operation ist rot. Alles Exit 1. |
| 2 | Eine kaputte Trennzeile (`---\|---\|---\|oops`) unter einer Glossar-Tabelle ohne Randstriche: die Tabelle fiel still weg; stand daneben eine heile Verbots-Tabelle, blieb der Lauf grün. | Eine Zeile außerhalb jeder Tabelle, die nach Abzug von Code-Spannen **zwei oder mehr** Striche `\|` trägt, ist Exit 2 („sieht aus wie eine Tabellenzeile"). |
| 3 | Der Imkerei-Tipp (`loadingTipApiary`) riet zu Chrysanthemen; `resourceCropChrysanthemumPlant` ist gesperrt (Denylist Zeile 349). | Text berichtigt: Goldrute oder Flachs. Dazu eine Einmal-Suche über alle Texte, siehe unten. |
| 4 | `SDTD_PATH` mit **wörtlichen** Anführungszeichen (`set SDTD_PATH="C:\…"` in cmd): `[IO.Path]::Combine` wirft, `check-all.ps1` endete ohne Ergebniszeile. Ebenso, wenn es gar keine Quelle fand (`throw`). | `kette-pruefen` → Exit 2 („SDTD_PATH ist kein gueltiger Pfad"). `check-all.ps1` fängt den Pfadfehler; ohne Quelle zählen `anachronisms` und `recipes` als rot, und die Ergebniszeile steht. |
| 5 | Zwei Optionstexte nannten zwei verschiedene Obergrenzen für die ganze Karte, ohne zu sagen, wann welche gilt. | Beide Texte nennen jetzt den Geltungsbereich: die Einstellung, und in einer Seuchennacht etwa das 1,9-Fache davon. Herkunft siehe unten. |

### Vertragsänderung an `kette-pruefen`: was eine Patch-Datei ist

Bisher galt jedes Kind von `DocumentElement` mit einem `xpath`-Attribut als Operation, und
alles andere wurde übergangen. Jetzt:

- Der Wurzelknoten heißt `<config>` — sonst rot, und die Datei wird nicht weiter gelesen.
- Bekannte Operationen: die Liste `$patchVerbs` des Skripts. Ein anderes Element ist rot
  („unbekannte Patch-Operation"), eine bekannte Operation ohne `xpath` ebenso.
- `<conditional>` und `<include>` sind bekannt, werden aber **nicht von innen geprüft**. Sie
  werden gezählt: neue Ausgabezeile `nicht von innen geprueft (conditional, include): N`.
  Das ist die alte Grenze (WP7.1), nur nicht mehr verschwiegen.
- Eine Datei, die sich nicht als XML lesen lässt, ist rot statt einer Ausnahme.

**Gemessen am 2026-11-21:** 18 Patch-Dateien, 418 XPaths (405 in Vanilla, 13 auf eigene
Knoten), 0 unaufgelöst, **0** nicht von innen geprüft. Die neuen Regeln treffen im echten Mod
also nichts — sie schließen eine Lücke, in die bisher niemand gefallen war.

### Gegenproben — acht neue, alle einmal rot gesehen

Gegen die Skripte des Stands `5fd3ea9`: **91 Gegenproben, 7 fehlgeschlagen** — genau die
sieben neuen dieses Laufs. Die achte (kaputtes XML) kam danach dazu und ist einzeln gegen
das alte Skript gehalten: eine Ausnahme mitten im Lauf, keine Ergebniszeile — die Gegenprobe
verlangt die Ergebniszeile. Gegen den neuen Stand: **92, 0 fehlgeschlagen.**

| Gegenprobe | vorher | jetzt |
|---|---|---|
| `kette/wurzel-falsch/blocks.xml` (`<configs>`, XPath trifft) | Exit 0, GREEN | Exit 1, „Wurzelknoten <configs> statt <config>" |
| `kette/operation-falsch/blocks.xml` (`<sett>`, `<set>` ohne xpath, ein `<conditional>`) | Exit 0, „0 XPaths" | Exit 1, drei Meldungen; Zähler 1 |
| Vanillas `blocks.xml` als Patch | Exit 0, GREEN | Exit 1, „Wurzelknoten <blocks>" |
| `kette/xml-kaputt/blocks.xml` (ein Ende-Tag fehlt) | Ausnahme, keine Ergebniszeile | Exit 1, „kein gueltiges XML", mit Zeile und Stelle |
| `glossar-trennzeile-kaputt.md` | Exit 0, GREEN (mit „ZOMBIE" in der Sprachdatei) | Exit 2 |
| `kette-pruefen`, Spielpfad in Anführungszeichen | Ausnahme | Exit 2 |
| `check-all.ps1`, Spielpfad in Anführungszeichen | Ausnahme, keine Ergebniszeile | „6 Pruefungen, 3 rot" |
| `check-all.ps1` ohne jede Quelle | `throw`, keine Ergebniszeile | „Quelle: KEINE", „6 Pruefungen, 4 rot" |

Für die letzte setzt die Gegenprobe `%APPDATA%` **für den einen Lauf** auf einen Testordner
um (neuer Parameter `-Appdata` von `Test-Script`): auf einem Rechner mit einem ConfigsDump
ließe sich „keine Quelle" sonst nicht herstellen.

### Befund 3: die Einmal-Suche über alle Texte

Der Fehler war meiner: ich hatte Vanillas Zutatenliste übernommen, ohne sie gegen den Purge
zu halten. Damit das nicht der eine gefundene von mehreren ist, lief einmal eine Suche:
aus `700_10_Purge/Config/items.xml` und `blocks.xml` die 598 als „verboten" markierten
Kennungen, zu jeder Vanillas englischer und deutscher Name (1.131 Namen ab fünf Zeichen),
gesucht als ganzes Wort in beiden Spalten unserer 710 Zeilen.

- Gegen den Stand `5fd3ea9`: **3 Treffer** — „Chrysanthemum" und „Chrysantheme" in
  `loadingTipApiary`, dazu „Schädelbrecher" in `perkSkullCrusherName`.
- Gegen den neuen Stand: **1 Treffer**, „Schädelbrecher". Das ist der deutsche Name eines
  Perks, der zufällig so heißt wie Vanillas gesperrte Süßigkeit (`drugSkullCrushers`) —
  kein Verweis auf sie.

Das ist **kein** Dauerprüfer, sondern ein Skript im Arbeitsordner der Sitzung. Als Prüfung
taugte es erst mit einer Ausnahmeliste (der Perk-Name) und einer Antwort darauf, was mit
umgedeuteten Kennungen ist, deren Vanilla-Name weiterlebt. **Vorschlag, nicht umgesetzt:**
als siebte Prüfung in `check-all.ps1`, sobald der Nutzer das will.

### Befund 5: woher die 1,9 kommt

Beide Zahlen stehen in **Vanillas** eigenen Texten (`goMaxSpawnedZombiesDesc`: „only this
many on the entire map"; `goBloodMoonEnemyCountDesc`: „the world cap is about 1.9x the
MaxSpawnedZombies"). Im Code belegt ist davon nur die Gruppenobergrenze 30
(`AIDirectorBloodMoonParty::InitParty`, `ldc.i4.s 30` vor `Utils::FastMin`). Den Faktor 1,9
habe ich in `AIDirectorBloodMoonComponent` und `AIDirectorBloodMoonParty` **nicht** gefunden
und nicht weiter gesucht. Unsere Texte sagen jetzt, was Vanillas zwei Texte zusammen sagen —
in einer Seuchennacht gilt das 1,9-Fache —, und das ist **gelesen, nicht gemessen**.

### Grenzen und was offen bleibt

- **Die Strich-Regel des Glossars kennt nur Code-Spannen.** Ein Satz im Fließtext mit zwei
  senkrechten Strichen außerhalb von Backticks wird Exit 2. Im heutigen Glossar gibt es
  keinen (Lauf grün); wer einen schreibt, bekommt die Meldung mit Zeilennummer.
- **`<conditional>` wird gezählt, nicht geprüft.** Sobald die XUi-Patches einen tragen
  (Vertrag 03 §5, WP8.7/WP8.9), steht in der Ausgabe eine Zahl größer 0 — und dann muss das
  Skript hineinsehen, sonst ist die Zahl nur ein besser sichtbares Loch.
- **Flachs lässt sich nicht anbauen** (`plantedCotton*` ist gesperrt, Denylist Zeile 379;
  die Faser `resourceCropCottonPlant` lebt, WP4.1). Der Imkerei-Tipp nennt ihn weiter als
  Futter, weil es ihn gibt — ob er als Bienenfutter taugt, wenn man ihn nur findet, ist eine
  Balance-Frage und hier nicht beantwortet.
- Befund 4 des dritten Reviews (dritte Sprachspalte) wartet weiter auf den Nutzer; offen aus
  dem ersten Review bleiben die Befunde 3 bis 7.

## Nachtrag fünftes Review 2026-11-21 — zwei Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `5fc2d3f` und `fba889b` hat Codex (`gpt-6.1-sol`) zwei Befunde gemeldet,
beide an `kette-pruefen.ps1`: einer mittel, einer niedrig. Zu Daten, Texten und Hygiene
keiner. Beide treffen die Korrektur des vierten Reviews — sie war an **einer** Stelle
gemacht, wo es acht gab.

| Nr. | Befund | Was jetzt gilt |
|---|---|---|
| 1 | Kaputtes XML wurde nur in der Patch-Schleife abgefangen. Dieselbe Datei als `-Bloecke` **und** `-Patches` (im echten Mod der Normalfall: jede `blocks.xml` ist beides) fiel an der früheren Lesestelle mit einer Ausnahme heraus, ohne Ergebniszeile. Meine Gegenprobe gab eine heile Block-Datei mit und sah es nicht. | Eine Funktion `Read-XmlDatei` liest jede XML-Datei, einmal. Kaputtes XML ist **eine** rote Zeile je Datei (Exit 1), gleich an welcher Stelle sie gebraucht wird. |
| 2 | Eine Patch-Datei, die sich nicht **lesen** lässt, meldete „kein gültiges XML", Exit 1 — ein Befund, wo ein Eingang fehlt. | Lesen und Zerlegen sind getrennt. Nicht lesbar → Exit 2 („laesst sich nicht lesen … NICHT GEPRUEFT"). |

### Vertragsänderung an `kette-pruefen`: Lesen ist nicht Zerlegen

- **Eine eigene Datei, die kein gültiges XML ist:** Befund, Exit 1. Die Meldung nennt die
  letzten drei Glieder des Pfads (`700_40_Bauen\Config\blocks.xml`), weil es `blocks.xml`
  in fünf Modlets gibt, und Zeile und Stelle des Fehlers.
- **Eine Datei, die sich nicht lesen lässt** (gesperrt, kein Zugriff): nicht prüfbar, Exit 2.
- **Eine Vanilla-Datei, die kein gültiges XML ist:** ebenfalls Exit 2. Das ist kein Befund an
  unserem Mod; gegen sie lässt sich nichts prüfen.
- Rezept-, Gegenstands- und Block-Dateien werden **vor** der ersten Ausgabe einmal gelesen.
- **Gelesen wird als UTF-8** (`[IO.File]::ReadAllText`, BOM erkannt). Vorher las
  `[xml](Get-Content -Raw)` unter Windows PowerShell 5.1 eine Datei ohne BOM in der
  ANSI-Codepage. Für die Prüfung von Kennungen und XPaths ändert das nichts (gemessen: die
  Zahlen unten sind dieselben), es ist nur nicht mehr vom Rechner abhängig.

**Gemessen am 2026-11-21, nach der Änderung:** 18 Patch-Dateien, 418 XPaths (405 in Vanilla,
13 auf eigene Knoten), 0 unaufgelöst — unverändert.

### Gegenproben — vier neue, alle einmal rot gesehen

Gegen `kette-pruefen.ps1` des Stands `fba889b`: **96 Gegenproben, 5 fehlgeschlagen** — die
vier neuen und die bestehende „kaputtes XML", deren Meldung jetzt den Pfad statt nur den
Dateinamen nennt. Gegen den neuen Stand: **96, 0 fehlgeschlagen.**

| Gegenprobe | vorher | jetzt |
|---|---|---|
| `kette/xml-kaputt/blocks.xml` als Rezept-, Gegenstands-, Block- **und** Patch-Datei | Ausnahme, keine Ergebniszeile | Exit 1, **eine** rote Zeile, „1 rot" |
| `kette/vanilla-kaputt/` (Vanillas `blocks.xml` kaputt) | Ausnahme | Exit 2, „Vanilla-Datei … ist kein gueltiges XML" |
| gesperrte Patch-Datei | Exit 1, „kein gueltiges XML" | Exit 2, „laesst sich nicht lesen" |
| gesperrte Rezept-Datei (die frühe Lesestelle) | Ausnahme | Exit 2 |

„Gesperrt" heißt: die Gegenprobe hält die Datei für die Dauer des einen Laufs mit
`FileShare.None` offen und gibt sie danach wieder frei.

### Grenzen und was offen bleibt

- **Vanillas `items.xml` und `blocks.xml` werden für die Liste der Kennungen weiter als Text
  gelesen** (`Select-String`), nicht als XML. Eine kaputte Vanilla-`blocks.xml` fällt darum
  nur auf, wenn eine Patch-Datei ihr Gegenstück braucht — im echten Mod immer.
- **Die anderen Skripte haben keine gemeinsame Lesestelle.** `glossar-pruefen.ps1` und
  `check-all.ps1` lesen kein XML; `mod700check` (C#) hat seinen eigenen Leser. Geprüft ist
  hier nur `kette-pruefen.ps1`.
- Offen bleiben wie zuvor: Befund 4 des dritten Reviews, die Befunde 3 bis 7 des ersten.

## Nachtrag sechstes Review 2026-11-21 — zwei Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `071708b` hat Codex (`gpt-6.1-sol`) zwei Befunde gemeldet, wieder beide an
`kette-pruefen.ps1`: einer mittel, einer niedrig. Beide zeigen, dass der Nachtrag darüber
mehr versprach, als das Skript hielt.

| Nr. | Befund | Was jetzt gilt |
|---|---|---|
| 1 | Vanillas `items.xml` und `blocks.xml` wurden für die Liste der Kennungen mit `Select-String` gelesen, ohne Abfang. Ließ sich eine nicht lesen, warf das Skript: Exit 1, keine Ergebniszeile — der Nachtrag zum fünften Review sagte „Exit 2". (Dort stand der Text-Leser unter „Grenzen", aber als Frage der Gültigkeit, nicht der Lesbarkeit.) | Auch dieser Leser geht durch dieselbe Lesestelle. Nicht lesbar → Exit 2. |
| 2 | Der Zwischenspeicher hielt je Pfad das fertige **Urteil**. Dieselbe kaputte Datei, erst als eigene Block-Datei und dann als Vanilla-Datei gelesen, bekam das Urteil der ersten Rolle: Exit 1 mit falschen XPath-Befunden statt „nicht prüfbar". | Der Speicher hält nur, was gelesen wurde (Text, Dokument, Fehler). Was daraus folgt, entscheidet jeder Aufruf für seine Rolle. |

### Was sich am Skript ändert

- `Read-Datei` liest den **Text** einer Datei, einmal je Pfad. `Read-XmlDatei` zerlegt ihn
  bei Bedarf und urteilt je Aufruf (`-Vanilla` oder nicht). `Get-Kennungen` holt die Namen
  aus dem Text — für Vanilla **und** für unsere `items.xml`/`blocks.xml`.
- **In `kette-pruefen.ps1` gibt es damit keinen Dateizugriff mehr außerhalb von
  `Read-Datei`** (nachgezählt: kein `Select-String`, kein `Get-Content`, ein
  `ReadAllText`).
- Die rote Zeile „kein gueltiges XML" steht weiter **einmal** je Datei.

**Gemessen am 2026-11-21, nach der Änderung:** 8.092 Definitionen aus Vanilla, 23 eigene;
18 Patch-Dateien, 418 XPaths (405 in Vanilla, 13 auf eigene Knoten), 0 unaufgelöst —
unverändert. Der Wechsel von `Select-String` (zeilenweise) auf ein Muster über den ganzen
Text hat an der Zahl der Kennungen nichts geändert.

### Gegenproben — drei neue, dazu eine Vorprüfung; alles einmal rot gesehen

Gegen `kette-pruefen.ps1` des Stands `071708b`: **99 Gegenproben, 3 fehlgeschlagen** — genau
die drei neuen. Gegen den neuen Stand: **99, 0 fehlgeschlagen.**

| Gegenprobe | vorher | jetzt |
|---|---|---|
| gesperrte Vanilla-`items.xml` | Ausnahme | Exit 2, „laesst sich nicht lesen" |
| gesperrte Vanilla-`blocks.xml` | Ausnahme | Exit 2 |
| `kette/vanilla-kaputt/blocks.xml` als `-Bloecke` **und** als Vanilla-Datei | Exit 1 | Exit 2, „Vanilla-Datei … ist kein gueltiges XML" |

**Die Sperre wird erst geprüft.** In der Umgebung des Reviews schlugen die zwei
Sperr-Gegenproben aus dem fünften Review fehl („96 Gegenproben, 2 fehlgeschlagen"), weil das
Dateisystem dort eine mit `FileShare.None` geöffnete Datei trotzdem lesen lässt. Jede der
vier Sperr-Gegenproben versucht darum zuerst, die gesperrte Datei ein zweites Mal zu öffnen.
Gelingt das, steht sie als **rot mit diesem Grund** da („die Sperre … greift auf diesem
Dateisystem nicht") — nicht als rätselhaftes „Exit 0 erwartet 2", und nicht als
übersprungen: eine Gegenprobe, die nicht geführt werden kann, ist kein Grün.
*Vorgeführt:* mit `FileShare.Read` statt `None` in der Gegenprobe — 99 Gegenproben, 4
fehlgeschlagen, alle vier mit diesem Grund.

### Grenzen und was offen bleibt

- **Auf einem Dateisystem ohne wirksame Sperre sind vier Gegenproben rot**, und
  `check-all.ps1` bricht dort nach den Gegenproben ab. Das ist gewollt laut, aber es heißt:
  der Prüflauf ist dort nicht führbar, bis es einen anderen Weg gibt, eine unlesbare Datei
  herzustellen. Auf diesem Rechner (NTFS) greift die Sperre.
- **Zwischen dem Lesen und dem Ende des Laufs** kann sich eine Datei ändern; gelesen wird
  jede nur einmal, das Skript prüft also einen festen Stand.
- Offen bleiben wie zuvor: Befund 4 des dritten Reviews, die Befunde 3 bis 7 des ersten.

## Nachtrag siebtes Review 2026-11-21 — ein Befund behoben, **abgenommen 2026-11-22**

Vor dem Push von `a231b8c` hat Codex (`gpt-6.1-sol`) einen Befund gemeldet, niedrig — und
er widerlegt einen Satz des Nachtrags darüber: „Der Wechsel von `Select-String`
(zeilenweise) auf ein Muster über den ganzen Text hat an der Zahl der Kennungen nichts
geändert." Am echten Mod stimmte das. Als Aussage über das Skript war es falsch.

| Befund | Was jetzt gilt |
|---|---|
| Das Muster für Kennungen lief über den ganzen Dateitext, und `[^"]+` schließt Zeilenumbrüche ein. Ein Kommentar mit einem angefangenen `<item name="` reichte dann bis zum Anführungszeichen der nächsten echten Definition und verschluckte sie; gültige Verweise wurden rot. | `Get-Kennungen` wendet das Muster wieder **Zeile für Zeile** an, wie `Select-String` es tat. Was das Muster selbst enthält, kann die Zeilengrenze so nicht überschreiten. |

Die Richtung des Fehlers: ein **falsches Rot**, kein falsches Grün — eine Definition
verschwand, es kam keine hinzu, auf die ein Verweis hätte zeigen können.

**Gegenprobe, einmal rot gesehen.** `kette/kommentar-vor-definition/` ist ein Vanilla-Stand
mit genau diesem Kommentar vor der Definition von `pruefRohstoff`. Erwartet ist **grün**
(Exit 0, „unaufgeloeste Verweise: 0"). Gegen `kette-pruefen.ps1` des Stands `a231b8c`:
**100 Gegenproben, 1 fehlgeschlagen** — diese, mit Exit 1 und „ist nirgends definiert".
Gegen den neuen Stand: **100, 0 fehlgeschlagen.**

**Gemessen am 2026-11-21, nach der Änderung:** 8.092 Definitionen aus Vanilla, 23 eigene,
418 XPaths, 0 unaufgelöst — unverändert.

**Grenze, alt und unverändert:** Gelesen wird Text, kein XML. Eine Definition, die
**vollständig in einer Zeile eines Kommentars** steht (`<!-- <item name="x"> -->`), zählt
weiter als definiert. Das war mit `Select-String` schon so; es kann ein falsches Grün
erzeugen, wenn ein Verweis auf eine auskommentierte Kennung zeigt.

## Nachtrag Review zu WP8.6, 2026-11-21 — ein Befund behoben, **abgenommen 2026-11-22**

Vor dem Push von `9c74af9` hat Codex (`gpt-6.1-sol`) einen Befund gemeldet, mittel: die
Absicherung des Mod-Namens aus WP8.6 hatte ein Loch, und ich hatte es im Glossar als
„Grenze" notiert, statt es zu schließen.

| Befund | Was jetzt gilt |
|---|---|
| Der Mod-Name stand im Glossar als Festbegriff unter `700_modName`, dazu zwei Verbotsmuster, die ihn nur **in** einem längeren Text trafen. Eine zweite Zeile mit anderem Schlüssel, deren Text **nur** aus dem Namen besteht, blieb grün — und damit wäre die Umbenennung zwei Zeilen statt einer (D6, Vertrag 02 §4). | **Dritte Tabellenform im Glossar: der Alleinname.** Ein Name, der in der ganzen Sprachdatei nur unter seinem einen Schlüssel stehen darf — egal ob als ganzer Text oder mitten in einem Satz. |

### Vertragsänderung an `glossar-pruefen`: dritte Tabellenform

Bisher: jede Tabelle des Glossars hat eine von **zwei** Kopfzeilen. Neu ist eine dritte:

```
| Alleinname | Deutsch | Englisch | Quelle |
```

Die erste Spalte trägt den Schlüssel in Backticks. Geprüft wird je Zeile zweierlei:

1. **Die eine Zeile gibt es, und sie stimmt.** Die Sprachdatei hat diesen Schlüssel, und
   seine deutsche und englische Spalte tragen zeichengenau die Namen des Glossars — wie
   beim Festbegriff.
2. **Es bleibt bei der einen.** In **jeder anderen** Zeile der Sprachdatei darf weder der
   deutsche noch der englische Name vorkommen, in keiner der beiden Sprachspalten: gesucht
   als Zeichenfolge, ohne Wortgrenzen, Groß- und Kleinschreibung egal (kulturunabhängig).
   „Andere Zeile" heißt: jede außer der **ersten** mit diesem Schlüssel — eine zweite Zeile
   mit demselben Schlüssel ist also auch ein Verstoß.

**Nicht prüfbar (Exit 2):** die erste Spalte ist kein Schlüssel in Backticks (ein
Gedankenstrich ist hier nicht erlaubt — ein Alleinname ohne Schlüssel hat keinen Sinn);
die Zeile hat nicht vier Spalten; ein Name fehlt oder ist kürzer als drei Zeichen (er
stünde in fast jedem Text, und das Ergebnis wäre Lärm statt Befund).

**Eine Alleinname-Tabelle ist freiwillig.** Fehlt sie, bleibt das Glossar prüfbar; Pflicht
sind weiter mindestens ein Festbegriff mit Kennung und ein Verbot.

**Ausgabe:** eine neue Zeile `Alleinnamen: N, Verstoesse: M`; jeder Verstoß zählt als ein
Rot. Die bestehenden Zeilen ändern sich nicht.

### Gegenproben — acht neue, alle einmal rot gesehen

Testdaten unter `tools/check/testdaten/glossar/` (`glossar-alleinname*.md`,
`Localization-alleinname-*.csv`).

| Fall | Erwartet |
|---|---|
| Name unter seinem Schlüssel und sonst nirgends | Exit 0, „Alleinnamen: 1, Verstoesse: 0" |
| **Zweite Zeile mit anderem Schlüssel, deren Text nur der Name ist** (der Fall aus dem Review) | Exit 1, genannt in beiden Sprachen |
| Name mitten in einem englischen Satz, groß geschrieben | Exit 1, nur englisch genannt |
| Die Zeile des Schlüssels fehlt | Exit 1 |
| Die Zeile trägt einen anderen Namen | Exit 1 |
| Derselbe Schlüssel zweimal | Exit 1 |
| Alleinname mit Gedankenstrich statt Schlüssel | Exit 2 |
| Alleinname mit zwei Zeichen | Exit 2 |

Gegen `glossar-pruefen.ps1` des Stands `9c74af9`: **108 Gegenproben, 13 fehlgeschlagen** —
die acht neuen, dazu fünf `check-all`-Proben, deren Rot-Zahl sich verschiebt, weil das alte
Skript das Glossar mit der neuen Tabelle als „unbekannte Kopfzeile" ablehnt. Gegen den neuen
Stand: **108, 0 fehlgeschlagen.**

Dazu elf Proben am **echten** Glossar auf Kopien der Sprachdatei (kein Bestandteil von
`gegenproben.ps1`): unverändert → grün; ohne die Zeile, mit anderem Namen, Name mitten im
Text, am Ende, am Anfang, zweite Zeile nur mit dem Namen, und jeder der vier alten
Vanilla-Namen → je rot.

**Gemessen am 2026-11-21, nach der Änderung:** 51 Festbegriffe mit Kennung, 13 ohne, 88
Muster, 1 Alleinname, 887 Zeilen; 0 Abweichungen, 0 verbotene Begriffe, 0 Verstöße.

### Grenzen und was offen bleibt

- **Gesucht wird in unserer Sprachdatei, nirgends sonst.** Ein Mod-Name in einem
  XUi-Attribut (`text="…"`) oder in einer Meldung aus dem Code fiele hier nicht auf. Heute
  steht er an keiner solchen Stelle (gesucht am 2026-11-21 in `mod\` und `src\`: ein Treffer,
  die Zeile `700_modName`; sonst nur Pfade in Build-Ausgaben unter `src\Mod700\obj\`); eine
  Dauerprüfung dafür gibt es nicht.
- **Ohne Wortgrenzen.** Ein Alleinname, der Teil eines anderen Wortes ist, wird dort
  mitgefunden. Für „7DTD_700" ist das ohne Belang; ein kurzer künftiger Name („Asche") träfe
  auch „Aschenlauge". Dann braucht die Form eine Wortgrenze — nicht vorher.
- **`ModInfo.xml` liest diese Prüfung nicht.** Die acht `DisplayName` sagen „700 — …", nicht
  „7DTD_700" (nachgesehen am 2026-11-21), und können keinen Sprachschlüssel lesen
  (Vertrag 02 §4). Eine Umbenennung ist dort acht Zeilen von Hand, und kein Werkzeug hält
  sie gegen `700_modName`.

## Nachtrag zweites Review zu WP8.6, 2026-11-21 — fünf Befunde behoben, **abgenommen 2026-11-22**

Das Review des Stands `be1e58b` fand in der neuen Alleinnamen-Prüfung zwei mittlere und drei
niedrige Lücken. Alle fünf waren echt.

| # | Schwere | Befund | Wo behoben |
|---|---|---|---|
| 1 | mittel | Fehlt `700_modName` im Glossar **und** in der Sprachdatei, meldet die Prüfung „Alleinnamen: 0" und grün — die Tabelle war freiwillig | Pflicht-Alleinname |
| 2 | mittel | Der Schlüssel wurde ohne Groß/Klein gesucht: `700_modname` mit richtigem Namen vor `700_modName` mit falschem — geprüft wurde die falsche Zeile, Ergebnis grün | Schlüssel zeichengenau |
| 3 | niedrig | Derselbe Schlüssel zweimal, die zweite Zeile mit **anderem** Titel: grün; nur die CSV-Prüfung fing die Dublette | Schlüssel wird gezählt |
| 4 | niedrig | Der Namensvergleich war nicht zeichengenau: ein weiches Trennzeichen (U+00AD) im Namen blieb unter PowerShell 5.1 grün | Vergleich ordinal |
| 5 | niedrig | F-12 beschrieb im selben Absatz die alte Regel (Festbegriff) und die neue | F-12 berichtigt |

### Vertragsänderungen an `glossar-pruefen`

1. **Pflicht-Alleinname.** Neuer Parameter `-PflichtAlleinname <Schlüssel[,…]>`: jeder
   genannte Schlüssel muss im Glossar **genau einmal** als Alleinname stehen, sonst Exit 2
   (das Glossar ist unvollständig — nicht prüfbar, nicht grün). **Vorgabe:** läuft das
   Skript gegen das echte Glossar (ohne `-Glossar`), gilt `700_modName` als Pflicht; mit
   einem ausdrücklich genannten Glossar gilt keine Pflicht, solange der Parameter fehlt.
   `check-all.ps1` ruft das Skript ohne Parameter und bekommt damit die Pflicht. Die Aussage
   des vorigen Nachtrags, die Tabelle sei „freiwillig", gilt nur noch für Testglossare.
2. **Schlüssel zeichengenau.** Der Schlüssel eines Alleinnamens **und** die Kennung eines
   Festbegriffs werden in der Sprachdatei ordinal gesucht, Groß- und Kleinschreibung zählt.
   `700_modname` ist nicht `700_modName`, `prueffeuer` nicht `pruefFeuer`. (Der Festbegriff
   stand nicht im Review; er hatte denselben Fehler, weil eine PowerShell-Hashtabelle
   Schlüssel ohne Groß/Klein vergleicht.)
3. **Der Schlüssel eines Alleinnamens steht genau einmal.** Steht er öfter, ist das ein
   Befund dieser Prüfung, gleich was die weiteren Zeilen tragen.
4. **Texte ordinal.** Soll und Ist werden Zeichen für Zeichen verglichen
   (`StringComparison.Ordinal`), beim Alleinnamen wie beim Festbegriff. Der Vergleich der
   PowerShell (`-cne`) übergeht Zeichen ohne Sortiergewicht. Ob die englische Fassung eines
   Alleinnamens eigens gesucht werden muss, entscheidet `OrdinalIgnoreCase`.

Ausgabe, Tabellenformen und die übrigen Ausgänge bleiben wie sie sind.

### Gegenproben — elf neue

Testdaten unter `tools/check/testdaten/glossar/` (`Localization-alleinname-kleinschreibung*.csv`,
`-doppelt-anders.csv`, `-trennzeichen.csv`, `Localization-kennung-kleinschreibung.csv`,
`Localization-festbegriff-trennzeichen.csv`, `glossar-alleinname-zweimal.md`).

| Fall | Erwartet | Gegen `be1e58b` |
|---|---|---|
| `700_modname` (richtiger Name) vor `700_modName` (falscher Name) | Exit 1, die echte Zeile ist geprüft | grün |
| Dieselben zwei Zeilen in der anderen Reihenfolge | Exit 1 | schon rot |
| `700_modName` zweimal, zweite Zeile mit anderem Titel | Exit 1, „steht 2-mal" | grün |
| Weiches Trennzeichen im Alleinnamen | Exit 1 | grün |
| Kennung eines Festbegriffs in anderer Schreibweise | Exit 1 | grün |
| Weiches Trennzeichen im Festbegriff | Exit 1 | grün |
| `-PflichtAlleinname`, Name fehlt im Glossar | Exit 2 | Abbruch (Parameter unbekannt) |
| `-PflichtAlleinname`, Name vorhanden | Exit 0 | Abbruch (Parameter unbekannt) |
| `-PflichtAlleinname`, Name zweimal im Glossar | Exit 2 | Abbruch (Parameter unbekannt) |
| Ohne Parameter, echtes Glossar und echte Sprachdatei | Exit 0 | grün (muss es sein) |
| **Ohne Parameter, `700_modName` fehlt in Glossar und Sprachdatei** (der Fall aus dem Review) | Exit 2 | grün |

Die letzten beiden laufen gegen einen nachgebauten Baum im Temp-Ordner: eine Kopie des
Skripts unter `tools\check\`, Kopien des echten Glossars und der echten Sprachdatei an
ihren Plätzen, einmal unverändert, einmal ohne die Zeile. So ist der Aufruf geprüft, den
`check-all.ps1` wirklich macht. Der Baum wird nach dem Lauf gelöscht.

Gegen `glossar-pruefen.ps1` des Stands `be1e58b`: **119 Gegenproben, 9 fehlgeschlagen** (die
neun, die oben nicht „schon rot" oder „muss es sein" tragen). Gegen den neuen Stand:
**119, 0 fehlgeschlagen.**

**`check-all.ps1` am 2026-11-21 nach der Änderung:** 6 Prüfungen, 1 rot. Glossar: 51
Festbegriffe mit Kennung, 13 ohne, 88 Muster, 1 Alleinname, 0 Verstöße, 887 Zeilen — die
strengeren Vergleiche haben an den echten Dateien nichts gefunden. Rot ist jetzt `recipes`
(80 Sackgassen), nicht mehr `anachronisms` (grün): der Lauf liest zum ersten Mal einen
ConfigsDump mit geladenen Modlets. Das hat mit dieser Änderung nichts zu tun und steht im
Plan-0001 unter den offenen Punkten.

### Grenzen

- **Ein unsichtbares Zeichen im Namen einer ANDEREN Zeile** (`7DTD` + U+00AD + `_700` in
  einem Fließtext) findet die Suche nicht: sie sucht die Zeichenfolge des Glossars, und die
  steht dort dann nicht. Das wäre Absicht, kein Versehen, und dagegen prüft hier nichts.
- **Die Pflicht hängt am Aufruf ohne `-Glossar`.** Wer das Skript mit `-Glossar
  docs\glossar.md` ruft, bekommt sie nicht, solange er `-PflichtAlleinname` weglässt.
  `check-all.ps1` ruft ohne Parameter.
- **Die beiden Proben am nachgebauten Baum hängen an den echten Dateien.** Ist das echte
  Glossar oder die echte Sprachdatei aus einem anderen Grund rot, fällt die erste der
  beiden mit — dann ist `check-all` aber ohnehin rot.

## Nachtrag WP8.7, 2026-11-22 — `kette-pruefen` sieht in bedingte Blöcke, **abgenommen 2026-11-22**

Vertrag 03 §5 verlangt für XUi-Eingriffe einen `<conditional>`-Block. Bis hierher zählte
`kette-pruefen` solche Blöcke nur („nicht von innen geprueft (conditional, include): N");
jeder Patch darin war unsichtbar. Mit den ersten echten Blöcken (WP8.7) hätte die Prüfung
genau die Dateien verloren, die neu entstehen. Die Grenze stand seit dem dritten Review als
„gehört zusammen gelöst" in diesem Vertrag.

Was das Spiel mit dem Block tut, ist aus dem Code gelesen:
[Finding WP1 §4, Nachtrag 2026-11-22](../rea/findings/WP1-modlet-lader-und-xml-patcher.md).

### Vertragsänderungen

1. **Jeder Zweig wird geprüft, als wäre er der aktive.** Die Kinder eines `<if>` und eines
   `<else>` laufen durch dieselbe Prüfung wie die Kinder von `<config>`: bekannte Operation,
   `xpath` vorhanden, Treffer in Vanilla oder auf einen eigenen Knoten. Ein `<conditional>`
   im Zweig wird ebenso gelesen.
2. **Der Aufbau des Blocks wird geprüft.** Rot sind: ein Kind, das weder `<if>` noch `<else>`
   heißt (im Spiel eine Ausnahme); ein `<if>` ohne `cond` (Ausnahme); ein Attribut
   `evaluator` (im Spiel eine Warnung); ein Zweig hinter `<else>` (nie erreicht); ein `<else>`
   mit `cond` (wird nicht gelesen); ein Block ohne `<if>`; ein Block ohne eine einzige
   Operation in seinen Zweigen.
3. **Die Bedingung wird grob zerlegt.** Texte in einfachen Anführungszeichen werden maskiert,
   dann die Funktionsaufrufe gesucht. Rot sind: ein Funktionsname, den das Spiel nicht kennt
   (die elf aus dem Finding, klein geschrieben; `not`, `and`, `or` sind keine Funktionen);
   ein offenes Anführungszeichen; eine nicht geschlossene Klammer; `mod_loaded` oder `xpath`
   mit etwas anderem als genau einem Text; ein XPath in `xpath(…)`, der kein gültiger
   Ausdruck ist; **`xpath(…)` ohne Vergleich davor oder dahinter** (das Spiel verlangt einen
   Wahrheitswert); `xpath('…') != null`, dessen XPath in Vanilla nichts trifft und nicht nur
   eigene Kennungen nennt (toter Zweig).
4. **Neue Ausgabezeilen**, die alte entfällt:
   `bedingte Bloecke: N (Zweige: N, XPaths darin: N, xpath-Bedingungen: N)`,
   `in Bedingungen genannte Mods: …` und `nicht von innen geprueft (include): N`.
   `<include>` bleibt ungeprüft und gezählt.

### Gegenproben (Projektregel 5)

Vier neue, eine angepasste. Testdaten unter `tools/check/testdaten/kette/bedingt-*/`.

| Probe | erwartet | altes Skript |
|---|---|---|
| Patches in bedingten Blöcken werden geprüft und gezählt (`xpath … != null` mit `&quot;` und mit `\'`, `mod_loaded`, `<else>`, Block im Block) | Exit 0, „4 XPaths", „3 Bloecke" | Exit 0 mit „0 XPaths" — rot an den Zahlen |
| Falsche Patches im `<if>`, im `<else>` und im inneren Block | Exit 1, 3 rot | Exit 0, grün |
| Sechs falsche Bedingungen (`xpath` ohne Vergleich, `eventActive`, toter Zweig, offenes Anführungszeichen, ungültiger XPath, `mod_loaded` ohne Text) | Exit 1, 6 rot | Exit 0, grün |
| Sieben falsch gebaute Blöcke | Exit 1, 7 rot | Exit 0, grün |
| *(angepasst)* unbekannte Operation und fehlender `xpath`: der Patch **im** Block der Testdatei trifft nichts | Exit 1, dritte rote Zeile | Exit 1, aber mit der alten Zählzeile |

Gegen `kette-pruefen.ps1` des Stands `6bd1eaa`: **123 Gegenproben, 5 fehlgeschlagen** (genau
diese fünf). Gegen den neuen Stand: **123, 0 fehlgeschlagen.**

**Eine zweite Messung, unabhängig von diesem Skript:** die sechs falschen Bedingungen der
Testdatei sind auch mit der `NCalc.dll` des Spiels ausgewertet worden (`xpath` und
`mod_loaded` nachgestellt). Fünf scheitern dort — eine liefert Text statt eines
Wahrheitswerts, vier werfen eine Ausnahme —, die sechste (toter Zweig) wertet zu „falsch"
aus. Das ist dieselbe Einteilung, die `kette-pruefen` trifft. Die neun Bedingungen unserer
beiden echten Dateien werten gegen Vanilla alle zu „wahr" aus.

**`check-all.ps1` am 2026-11-22 nach der Änderung:** 6 Prüfungen, 1 rot (`recipes`, 80
Sackgassen, unverändert). `kette-pruefen`: 20 Patch-Dateien (vorher 18), 427 XPaths (414 in
Vanilla, 13 auf eigene Knoten), 9 bedingte Blöcke mit 9 Zweigen, 9 XPaths darin und 9
`xpath`-Bedingungen, keine genannte Mod, 0 unaufgelöst.

### Grenzen

- **Ob eine Bedingung im Spiel wahr wird, prüft niemand.** `mod_loaded`-Namen werden
  aufgelistet, nicht geprüft — ob es eine Mod dieses Namens gibt und ob das Spiel den `Name`
  aus `ModInfo.xml` oder den Ordnernamen vergleicht, ist ungelesen.
- **Die Zerlegung ist kein NCalc-Leser.** Ein Ausdruck, der die groben Regeln besteht und
  trotzdem keinen Wahrheitswert liefert (`mod_loaded('A') + 1`), fällt nicht auf. NCalcs
  eigene Funktionen (`if(…)`, `Max(…)`) gelten hier als unbekannt und wären rot.
- **Jeder Zweig wird gegen Vanilla gehalten.** Ein `<else>`, das auf Elemente einer anderen
  Mod zielt, wäre rot. Heute gibt es keinen; braucht WP8.9 einen, muss diese Regel zuerst
  geändert werden.
- **Fortschritts-Verweise** (`parent`, `progression_name`) werden weiter nur auf der obersten
  Ebene gelesen, nicht in einem Block.
- **Kein Lauf im Spiel.** Dass ein bedingter Block von uns lädt, zeigt erst das Protokoll
  (Plan-0001, Prüfliste 22).

## Nachtrag Review zu WP8.7, 2026-11-22 — drei Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `a390459` und `f4a0476` hat Codex (`gpt-6.1-sol`) drei Befunde gemeldet,
alle mittel, alle an der Zerlegung der Bedingung aus dem Nachtrag oben. Die Mod-Dateien
waren nicht betroffen: unsere neun Bedingungen benutzen keine der drei Formen.

| # | Befund | Folge | jetzt |
|---|---|---|---|
| 1 | Klammern wurden nur von einem Funktionsaufruf aus gezählt. `(mod_loaded('X')` und `mod_loaded('X'))` waren **grün**. | NCalc kann beide nicht lesen; im Spiel bliebe die Patch-Datei an der Stelle unangewandt. | Die Klammern des ganzen Ausdrucks werden gezählt (über den maskierten Text). Rot: eine schließende ohne offene, eine offene am Ende. |
| 2 | Die Probe auf den toten Zweig sah nur nach rechts. `null != xpath('…')` mit einem XPath ohne Treffer war **grün**. | Ein Tippfehler im Ziel der Bedingung blieb unentdeckt, der Zweig liefe nie. | Beide Seiten gelten gleich: `xpath(…) != null` und `null != xpath(…)`, auch mit `<>`. |
| 3 | `(xpath('…')) != null` wurde **rot** („ohne Vergleich"), obwohl gültig. | Eine Prüfung, die Richtiges abweist, wird umgangen oder abgeschaltet. | Klammerpaare, die nur den Aufruf umschließen, werden abgestreift, bevor nach dem Vergleich gesucht wird — auch mehrere, auch hinter `not`, `and`, `or`. Eine Klammer hinter einem anderen Namen ist ein Funktionsaufruf und bleibt stehen. |

### Vertragsänderung

Punkt 3 des Nachtrags WP8.7 wird um drei Sätze ergänzt: Die Klammern des ganzen Ausdrucks
müssen aufgehen. Der Vergleich neben `xpath(…)` darf durch Gruppierungsklammern vom Aufruf
getrennt sein. Der tote Zweig wird in beiden Schreibrichtungen erkannt.

### Gegenproben (Projektregel 5)

Zwei neue, Testdaten unter `tools/check/testdaten/kette/bedingt-klammern-*/`.

| Probe | erwartet | altes Skript (`f4a0476`) |
|---|---|---|
| Sechs gültige Formen: `(xpath(…)) != null`, `null != xpath(…)`, zwei Klammerpaare, `not (xpath(…) = null)`, zwei geklammerte Teile mit `and`, Klammer hinter `or` | Exit 0, 6 Blöcke, keine Zeile „ohne Vergleich" | Exit 1 — die geklammerten Aufrufe fälschlich rot |
| Sechs falsche Formen: offene Klammer, eine zu viel, falsche Reihenfolge, toter Zweig mit `null` links, toter Zweig hinter Gruppierungsklammer, geklammerter Aufruf ohne Vergleich | Exit 1, 6 rot | Exit 1, aber mit anderen Zeilen: die Klammerfehler und der tote Zweig mit `null` links fehlen |

Gegen das Skript des Stands `f4a0476`: **125 Gegenproben, 2 fehlgeschlagen** (diese zwei).
Gegen den neuen Stand: **125, 0 fehlgeschlagen.**

**Gegenmessung mit der `NCalc.dll` des Spiels**, unabhängig vom Skript: die sechs gültigen
Formen werten alle zu „wahr" aus. Von den sechs falschen werfen drei eine Ausnahme (die
Klammerfehler), zwei werten zu „falsch" aus (die toten Zweige), eine liefert Text statt
eines Wahrheitswerts. Das ist dieselbe Einteilung, die `kette-pruefen` jetzt trifft.

**`check-all.ps1` am 2026-11-22 nach der Änderung:** 6 Prüfungen, 1 rot (`recipes`, 80
Sackgassen, unverändert); `kette-pruefen` unverändert 20 Patch-Dateien, 427 XPaths, 9
bedingte Blöcke, 0 unaufgelöst.

### Grenzen

- **Abgestreift werden nur Klammern, die genau den Aufruf umschließen.** Steht in der
  Klammer noch etwas anderes — `(xpath('a') + '') != null` —, entscheidet weiter der Text
  direkt neben dem Aufruf, und der ist hier ein `+`. So ein Ausdruck würde fälschlich rot
  („ohne Vergleich"). Wir schreiben keinen; wer einen braucht, muss diese Regel erweitern.
- **Die anderen Grenzen des Nachtrags WP8.7 gelten weiter**: kein NCalc-Leser, `mod_loaded`
  nur aufgelistet, jeder Zweig gegen Vanilla, kein Lauf im Spiel.

## Nachtrag zweites Review zu WP8.7, 2026-11-22 — die Bedingung wird mit NCalc ausgewertet, **abgenommen 2026-11-22**

Vor dem Push von `049280e` hat Codex (`gpt-6.2-sol`) zwei weitere mittlere Befunde an
derselben Stelle gemeldet: ein erreichbarer Zweig wurde als tot gemeldet
(`not (null != xpath('…'))`, ebenso mit `or`), und Klammern um `null` versteckten einen
toten Zweig (`xpath('…') != (null)`). Das war das zweite Review in Folge mit Lücken in der
Zerlegung der Bedingung, und der Grund war beide Male derselbe: **die Prüfung las den
Ausdruck nicht, sie riet an seinem Text.** Jede Sonderregel schloss eine Form und öffnete
die nächste. Der Nutzer hat am 2026-11-22 entschieden: die Bedingung wird mit der
NCalc-Bibliothek des Spiels ausgewertet.

### Vertragsänderungen — sie ersetzen Punkt 3 des Nachtrags WP8.7 und den Nachtrag „Review zu WP8.7"

1. **Gelesen wird mit NCalc.** `kette-pruefen` lädt `NCalc.dll` aus der Spielinstallation
   (`<SDTD_PATH>\7DaysToDie_Data\Managed\`, oder der Pfad aus dem neuen Parameter `-NCalc`)
   und liest jede Bedingung mit denselben Optionen wie das Spiel (1542). Die Bibliothek
   wird nur geladen, nichts davon liegt im Repo (Projektregel 1). Eigene Klammer-, Text-
   und Vergleichsregeln gibt es nicht mehr.
2. **Rot ist, was das Spiel nicht auswerten könnte:** ein Ausdruck, den NCalc nicht lesen
   kann (Klammern, Anführungszeichen, Operatoren); ein Funktionsname außerhalb der elf des
   Spiels; `mod_loaded` oder `xpath` mit etwas anderem als genau einem festen Text; ein
   Ausdruck, der bei der Auswertung eine Ausnahme wirft oder **keinen Wahrheitswert**
   liefert.
3. **Ausgewertet wird wie im Spiel, soweit es hier geht.** `xpath(…)` läuft gegen die
   Vanilla-Datei und liefert, was `XmlPatchConditionEvaluator::xpath` liefert: `null` ohne
   Treffer, `More than one match` bei mehreren, sonst den Text des Treffers.
   `mod_loaded(…)` ist unbekannt — also wird **jede Belegung** der in der Bedingung
   genannten Mods durchgerechnet (geladen / nicht geladen), und rot ist ein Fehler in
   irgendeiner davon. Bei mehr als acht genannten Mods in einer Bedingung ist sie nicht
   prüfbar (Exit 2).
4. **Der „tote Zweig" entfällt als Begriff.** Ob ein Zweig läuft, hängt an Mods, die diese
   Prüfung nicht kennt; `xpath(…) = null` ist in Vanilla nie wahr und trotzdem sinnvoll.
   An seine Stelle tritt eine einfachere Regel, die den Tippfehler fängt, um den es ging:
   **jeder XPath in einer Bedingung muss in Vanilla etwas treffen** (oder nur eigene
   Kennungen nennen) — gleich, wie der Ausdruck um ihn herum gebaut ist. Rot auch, wenn
   der XPath kein gültiger Ausdruck ist oder keine Knotenmenge liefert.
5. **Bedingungen mit anderen Funktionen** (`game_version`, `version`, `gamepref`, `event`,
   `serverinfo`, `time_minutes`, `game_loaded`, `mod_version`, `has_entitlement`) werden
   gelesen und auf ihre Funktionsnamen geprüft, aber **nicht ausgewertet** — ihre Werte
   kennt nur das laufende Spiel. Sie werden gezählt.
6. **Ohne NCalc ist es nicht geprüft.** Enthält eine Patch-Datei einen bedingten Block und
   lässt sich die Bibliothek nicht laden, endet der Lauf mit Exit 2. Ohne bedingten Block
   wird sie nicht gebraucht und nicht gesucht.
7. **Neue Ausgabezeile:** `Bedingungen mit NCalc gelesen: N (ohne genannte Mods wahr: N,
   falsch: N, nicht ausgewertet: N)`.

### Gegenproben (Projektregel 5)

Sieben neue; drei bestehende erwarten andere Zeilen, weil die Meldungen jetzt von NCalc
kommen (die Urteile sind dieselben). Testdaten unter `tools/check/testdaten/kette/bedingt-*/`.

| Probe | erwartet | altes Skript (`049280e`) |
|---|---|---|
| Fünf Schreibweisen für „das Ziel der Bedingung gibt es in Vanilla nicht" (`not (null != xpath(…))`, mit `or`, `!= (null)`, `(null) <> ((xpath(…)))`, `= null`) | Exit 1, 5 rot, keine Zeile „toter Text" | weniger als 5 rot, und die roten mit der Begründung „toter Text" |
| Vier Bedingungen, an denen nichts falsch ist — eine ergibt in Vanilla „falsch", eine nennt drei Mods, eine ruft `event(…)` | Exit 0; gelesen 4, wahr 2, falsch 1, nicht ausgewertet 1 | Exit 0, aber ohne die Zeile |
| Vier Bedingungen, die erst beim Auswerten scheitern — die erste nur, **wenn die genannte Mod geladen ist** | Exit 1, 4 rot | weniger als 4 rot |
| Bedingter Block, `-NCalc` führt ins Leere | Exit 2, „NICHT GEPRUEFT" | kennt den Parameter nicht |
| Bedingter Block, `-NCalc` ist keine Bibliothek | Exit 2 | dito |
| Bedingter Block, kein `SDTD_PATH` | Exit 2 | Exit 0 — grün ohne die Bibliothek |
| **Kein** bedingter Block, `-NCalc` führt ins Leere | Exit 0 — die Bibliothek wird nicht gesucht | kennt den Parameter nicht |

Gegen `kette-pruefen.ps1` des Stands `049280e`: **132 Gegenproben, 10 fehlgeschlagen** (die
sieben neuen und die drei mit umbenannten Zeilen). Gegen den neuen Stand: **132, 0
fehlgeschlagen.**

**`check-all.ps1` am 2026-11-22 nach der Änderung:** 6 Prüfungen, 1 rot (`recipes`, 80
Sackgassen, unverändert). `kette-pruefen`: 20 Patch-Dateien, 427 XPaths, 9 bedingte Blöcke;
**9 Bedingungen mit NCalc gelesen, ohne genannte Mods 9 wahr, 0 falsch, 0 nicht
ausgewertet**; 0 unaufgelöst.

### Grenzen

- **Die Gegenproben zu bedingten Blöcken brauchen die Spielinstallation.** Ohne `SDTD_PATH`
  enden sie mit Exit 2 und zählen als fehlgeschlagen — nicht geprüft ist nicht grün.
- **Ein XPath, der auf das Element einer anderen Mod zielt, ist rot** (Regel 4). Heute gibt
  es keinen; braucht WP8.9 einen, muss diese Regel zuerst erweitert werden.
- **`mod_loaded`-Namen werden nicht geprüft**, nur aufgelistet und durchgerechnet.
- **Der Text eines Treffers** (`ToString()`) wird hier aus einem `XDocument` gebildet wie
  im Spiel; ein Vergleich damit (`xpath(…) = '<label …/>'`) ist trotzdem ungesehen — wir
  vergleichen nur mit `null`.
- **Kein Lauf im Spiel** (Plan-0001, Prüfliste 22).

## Nachtrag drittes Review zu WP8.7, 2026-11-22 — fünf Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `20ea35e` hat Codex (`gpt-6.2-sol`) fünf Befunde an der neuen Auswertung
gemeldet: zwei mittel, drei niedrig. Keiner trifft die Mod-Dateien; die neun echten
Bedingungen ergeben weiter „wahr".

| # | Befund | jetzt |
|---|---|---|
| 1 *(mittel)* | Nannte eine Bedingung eine Funktion, die nur das laufende Spiel auswerten kann, entfiel mit der Auswertung auch, was ohne Spiel prüfbar ist: `event()` ohne Argument war grün (im Spiel eine Ausnahme), und die Grenze von acht Mods griff nicht. | **Die Zahl der Argumente wird für alle elf Funktionen geprüft**, gelesen aus dem Code: `game_version`, `time_minutes`, `game_loaded` nehmen keines; `mod_loaded`, `mod_version`, `gamepref`, `event`, `serverinfo`, `xpath`, `has_entitlement` genau eines; `version` mindestens zwei. Die Grenze von acht Mods gilt vor dem Überspringen. |
| 2 *(mittel)* | Die Ausnahme „der XPath nennt nur eigene Kennungen" suchte Namen per Textmuster. Sie ließ ein fremdes Ziel durch (ein zweites Prädikat mit einem eigenen Namen genügte) und wies ein echtes eigenes ab (die Fenstergruppe des Webstuhls steht nicht im Verzeichnis der Gegenstände und Blöcke). | **Die Ausnahme ist für Bedingungen gestrichen.** Das Ziel einer Bedingung muss in Vanilla stehen — ohne Wenn. Kein Raten am Text mehr an dieser Stelle. |
| 3 *(niedrig)* | Funktionsnamen wurden mit PowerShells Kulturvergleich verglichen: ein weiches Trennzeichen (U+00AD) im Namen blieb grün, das Spiel fände die Funktion nicht. | Verglichen wird ordinal ohne Groß/Klein, in der Liste der elf wie in der nachgestellten Auswertung. |
| 4 *(niedrig)* | Das Spiel gibt jeder Bedingung den Namen `xml` mit (die Zieldatei); die Prüfung kannte ihn nicht, `xml != null` wurde rot. | Der Name ist bei der Auswertung belegt. |
| 5 *(niedrig)* | Ein Block, dessen einziges `<if>` kein `cond` trägt, endete bei fehlender Bibliothek mit Exit 1 statt Exit 2 — die Bibliothek wurde erst beim Lesen einer Bedingung gesucht. | Sie wird gesucht, sobald ein `<conditional>` gelesen wird. |

### Vertragsänderungen am Nachtrag „zweites Review zu WP8.7"

- **Zu Regel 4:** die Klammer „(oder nur eigene Kennungen nennen)" entfällt. Ein XPath in
  einer Bedingung, der auf einen Knoten zielt, den ein früheres eigenes Modlet anlegt, ist
  damit **rot**. Vertrag 03 §5 braucht so eine Bedingung nicht: Eigenes an der Wurzel
  steht ohne Block. Braucht ein späteres Paket sie doch, muss die Prüfung unsere eigenen
  Patches in Ladereihenfolge auf Vanilla anwenden — das ist ein eigenes Vorhaben, kein
  Textmuster. *(Die Ausnahme gleicher Bauart bei den XPaths der Patches selbst bleibt, wie
  sie seit WP7.1 dokumentiert ist; heute 13 XPaths.)*
- **Zu Regel 5:** nicht ausgewertet heißt nicht ungeprüft — Funktionsname, Zahl der
  Argumente, fester Text bei `mod_loaded` und `xpath`, Ziel in Vanilla und die Grenze von
  acht Mods gelten auch für diese Bedingungen.
- **Zu Regel 6:** „enthält einen bedingten Block" heißt: sobald die Prüfung ein
  `<conditional>` liest, gleich wie es gebaut ist.

### Gegenproben (Projektregel 5)

Fünf neue Läufe über vier Testdateien unter `tools/check/testdaten/kette/`:

| Testdatei | Lauf | Stand `20ea35e` | jetzt |
|---|---|---|---|
| `bedingt-funktion-falsch` | `event()`, `game_version('a')`, `version(1)`, weiches Trennzeichen in `mod_loaded`, zwei Ziele mit eigenem Namen | Exit 0 | Exit 1, 6 rot |
| `bedingt-funktion-gut` | `xml != null`, `event('christmas')`, `game_loaded()`, `MOD_LOADED(…) or XPATH(…) != null` | Exit 1 | Exit 0; gelesen 4, wahr 2, nicht ausgewertet 2 |
| `bedingt-neun-mods` | neun Mods neben `event('christmas')` | Exit 0 | Exit 2, nicht geprüft |
| `bedingt-ohne-cond` | mit Bibliothek | Exit 1 | Exit 1 *(Kontrolle, unverändert)* |
| `bedingt-ohne-cond` | `-NCalc` zeigt ins Leere | Exit 1 | Exit 2, nicht geprüft |

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: gegen das Skript des Stands
`20ea35e` **137 Gegenproben, 4 fehlgeschlagen** (die vier Läufe, die einen Befund treffen),
gegen das neue **137 Gegenproben, 0 fehlgeschlagen**. `check-all.ps1`: 6 Prüfungen, 1 rot
(`recipes`, 80 Sackgassen, unverändert); `kette-pruefen` über die Mod: 20 Patch-Dateien,
427 XPaths, 9 bedingte Blöcke, 9 Bedingungen gelesen, alle wahr.

### Grenzen

- **Die Art der Argumente wird nicht geprüft**, nur ihre Zahl. `event(1)` oder
  `version('a', 'b')` scheitern im Spiel („Expected string argument", „Expected int
  arguments") und bleiben hier grün und „nicht ausgewertet".
- **Ob es das Ereignis, die Einstellung, das Besitzrecht gibt**, das eine solche Funktion
  nennt, weiß nur das laufende Spiel.

## Nachtrag viertes Review zu WP8.7, 2026-11-22 — vier Befunde behoben, **abgenommen 2026-11-22**

Vor dem Push von `75a10dd` hat Codex (`gpt-6.2-sol`) vier Befunde gemeldet: einen mittel,
drei niedrig. Keiner trifft die Mod-Dateien.

| # | Befund | jetzt |
|---|---|---|
| 1 *(mittel)* | In Windows PowerShell 5.1 legt der XML-Adapter Attribute **und Kindelemente** als Eigenschaften über den Knoten. Ein Attribut `NodeType` verdeckte die gleichnamige Eigenschaft: `<conditional NodeType="skip">` wurde wie ein Kommentar übersprungen, der Lauf war grün, und die fehlende Bibliothek fiel nicht auf. Dieselbe Bauart: ein Kind `<ChildNodes/>` in einem Zweig verdeckte dessen Kinderliste, und der Rest des Zweigs blieb ungelesen. | **Der Aufbau eines Knotens wird nur noch über Methoden gelesen** (`get_NodeType()`, `get_ChildNodes()`, `get_InnerText()`, `get_DocumentElement()`, `get_ParentNode()`, `get_LocalName()`, wie seit WP7.1 schon `get_Name()`) — im ganzen Skript, nicht nur an der gemeldeten Stelle. Ein Methodenaufruf geht am Adapter vorbei. |
| 2 *(niedrig)* | Neun Mods **und** ein zweiter Fehler in derselben Bedingung (`event()` ohne Argument): die Prüfung kehrte mit dem Befund zurück, bevor sie die Grenze von acht Mods erreichte — Exit 1 statt Exit 2. | Die Grenze wird geprüft, sobald die Funktionsaufrufe gelesen sind, **vor** jeder Rückkehr wegen eines Befunds. „Nicht prüfbar" geht vor „Befund". |
| 3 *(niedrig)* | Die Gegenproben deckten nur drei der elf Argumentzahlen ab. Ein falscher Eintrag in der Tabelle (etwa `mod_version` = 0) wäre nicht aufgefallen. | Zwei neue Testdateien rufen **jede der elf Funktionen** einmal richtig und einmal falsch auf, `version` dazu mit mehr als zwei Argumenten. Bewiesen wird an einer absichtlich verfälschten Tabelle (siehe Gegenproben). |
| 4 *(niedrig)* | Ein Kommentar im Skript nannte für Bedingungen noch die gestrichene Ausnahme „oder nur eigene Kennungen"; die Ausgabe „Grenzen dieser Prüfung" sagte nicht, dass die Ausnahme nur für Patch-Operationen gilt. | Kommentar berichtigt; die Ausgabe sagt es ausdrücklich. |

### Vertragsänderungen

- **Neue Regel für alle Skripte unter `tools/check`, die XML lesen:** der Aufbau eines
  Knotens (Art, Name, Kinder, Elternknoten, Text) wird über Methoden gelesen, nie über
  Eigenschaften.
- **Zu Regel 4 des Nachtrags „zweites Review zu WP8.7":** mehr als acht genannte Mods in
  einer Bedingung sind Exit 2, gleich welche Befunde dieselbe Bedingung sonst trägt.

### Gegenproben (Projektregel 5)

Sieben neue Läufe über sechs Testdateien unter `tools/check/testdaten/kette/`:

| Testdatei | Lauf | Stand `75a10dd` | jetzt |
|---|---|---|---|
| `bedingt-nodetype` | `<conditional NodeType="skip">`, `<if>` ohne `cond`; mit Bibliothek | Exit 0, 0 Blöcke | Exit 1, 1 rot |
| `bedingt-nodetype` | dasselbe, `-NCalc` zeigt ins Leere | Exit 0 | Exit 2, nicht geprüft |
| `bedingt-adapter-falsch` | Kind `<ChildNodes/>` im Zweig, Operation und `<if>` mit `NodeType` | Exit 0 | Exit 1, 4 rot |
| `prog-adapter` | Fortschritts-Verweise hinter `NodeType` und `InnerText` | Exit 0 | Exit 1, 2 rot |
| `bedingt-neun-mods-und-fehler` | neun Mods neben `event()` | Exit 1 | Exit 2, nicht geprüft |
| `bedingt-argumente-gut` | jede der elf Funktionen richtig, `version` mit vier Argumenten | Exit 0 | Exit 0; gelesen 12, wahr 1, falsch 1, nicht ausgewertet 10 |
| `bedingt-argumente-falsch` | jede der elf Funktionen mit falscher Zahl | Exit 1, 11 rot | Exit 1, 11 rot |

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: gegen das Skript des Stands
`75a10dd` **144 Gegenproben, 5 fehlgeschlagen** (die fünf Läufe zu den Befunden 1 und 2),
gegen das neue **144 Gegenproben, 0 fehlgeschlagen**.

**Die zwei Läufe zu Befund 3 sind gegen `75a10dd` grün — die Tabelle stimmte.** Ihr Nachweis
ist eine absichtlich verfälschte Tabelle im neuen Skript (`mod_version` 0, `game_version` 1,
`version` mindestens 3, `serverinfo` 0, `gamepref` 2, `event` 2, `time_minutes` 1,
`game_loaded` 1, `has_entitlement` 0): **144 Gegenproben, 6 fehlgeschlagen**, darunter beide
neuen Läufe; im Lauf „falsche Zahl" fehlt jede der neun Zeilen einzeln. Eine zweite
Verfälschung (`version` genau 2 statt mindestens 2) macht `bedingt-argumente-gut` rot
(Exit 1, `version(1, 2, 3, 4)`). Die Zahl bei `mod_loaded` und `xpath` prüft nicht die
Tabelle, sondern die Regel „genau ein fester Text"; ihre beiden Zeilen stehen im selben Lauf.

`check-all.ps1`: 6 Prüfungen, 1 rot (`recipes`, 80 Sackgassen, unverändert); `kette-pruefen`
über die Mod: 20 Patch-Dateien, 427 XPaths, 9 bedingte Blöcke, 9 Bedingungen gelesen, alle
wahr.

### Grenzen

- **Im Teil, der unsere eigenen Rezepte, Gegenstände und Blöcke auflöst**, werden
  Attributwerte weiter als Eigenschaft gelesen (`$zutat.name`). Ein Kindelement gleichen
  Namens würde den Wert dort verändern; solche Dateien schreiben wir nicht. Umgestellt ist
  dort nur, was den Aufbau liest (Elternknoten, Name, Text), und das ohne eigene Gegenprobe:
  die fünf Stellen sind mechanisch ersetzt, die bestehenden Läufe bleiben grün.
- **Von den Skripten unter `tools/check` liest heute nur `kette-pruefen.ps1` XML**; die
  Regel trifft also nur dieses eine. *(Seit WP8.8 liest auch `sprachverweise-pruefen.ps1`
  XML, nach derselben Regel.)*

## Nachtrag WP8.8, 2026-11-22 — Sprachschlüssel-Verweise, **abgenommen 2026-11-22**

### Anlass

WP8.8 verlangt „`mod700check localization` grün". Das war es schon — und es prüft die
**Form** der Datei, nicht, ob eine Zeile gelesen wird oder ein genannter Schlüssel eine Zeile
hat. Zwei Stellen dieses Vertrags behaupten mehr, als gebaut ist: „die Sprachschlüssel prüft
`mod700check localization`" (Nachtrag WP7.2, Grenzen) und der Kommentar in
`kette-pruefen.ps1` zu `name_key`/`DescriptionKey`. Gemessen am 2026-11-22 mit einem
Wegwerf-Skript:

- **Vorwärts:** unsere XML-Dateien nennen 61 Sprachschlüssel; alle 61 haben eine Zeile.
- **Rückwärts:** sechs unserer Zeilen liest das Spiel nie. `meleeWpnBladeT3MachetePartsDesc`
  und seine fünf Geschwister beschreiben die Bruchstücke aus dem Zerlegen. Die sechs
  Gegenstände erben aber über `Extends` den `DescriptionKey` `gunPartsGroupDesc`
  ([Finding](../rea/findings/WP8-beschreibungsschluessel-wird-vererbt.md)); der Spieler liest
  unter „Klingenbruchstücke" Vanillas Text über fortgeschrittene Waffen. `localization` war
  dabei grün, weil die sechs Schlüssel in `vanilla-keys.txt` stehen — als Überschreibung von
  etwas, das Vanilla gar nicht hat.

### Das Werkzeug

`tools/check/sprachverweise-pruefen.ps1`, siebte Prüfung in `check-all.ps1`. Parameter
`-Patches` (unsere XML-Dateien; ohne Angabe alle unter `mod/` außer `ModInfo.xml`),
`-Sprachdatei` (ohne Angabe die des Sprach-Modlets), `-Vanilla` (ohne Angabe
`<SDTD_PATH>\Data\Config`; gebraucht werden `Localization.csv`, `items.xml`, `blocks.xml`).
Ausgänge wie überall: 0 grün, 1 Befund, 2 nicht prüfbar.

### Die Regeln

1. **Jeder genannte Schlüssel hat eine Zeile** — in unserer Datei oder in Vanillas. Als
   genannt gilt:
   - der Wert jedes Attributs, dessen Name auf `_key` endet (`name_key`, `desc_key`,
     `description_key`, `tooltip_key`, `text_key` …), an einem Element, das keine
     Patch-Operation ist; eine Kommaliste zählt je Teil;
   - der Text eines `<set>`, dessen XPath auf `/@…_key` endet, und eines
     `<setattribute name="…_key">`;
   - der Wert jeder Eigenschaft `DescriptionKey` und der Text eines `<set>` auf deren `@value`;
   - der Name jedes eigenen Gegenstands und Blocks (ein `<item>` oder `<block>` mit `name`
     und mindestens einem `<property>`-Kind) und, **bei Gegenständen**, der Schlüssel, den
     das Spiel als Beschreibung liest. Bei Blöcken nicht: fehlt die Zeile, nimmt das Spiel
     die Gruppenbeschreibung (Finding).
2. **Jede Zeile, die Vanilla nicht hat, wird gelesen.** Eine Zeile, deren Schlüssel in
   Vanillas Sprachdatei fehlt, überschreibt nichts; sie muss also von etwas gelesen werden,
   das diese Prüfung sieht: genannt nach Regel 1, der wirksame Beschreibungsschlüssel eines
   Gegenstands oder Blocks, oder der Wert irgendeiner Eigenschaft in `items.xml`/`blocks.xml`
   (Vanilla oder unsere).
3. **Jede Beschreibungszeile wird gelesen.** Für eine Zeile `<Name>Desc`, deren `<Name>` ein
   Gegenstand oder Block ist, gilt dasselbe auch dann, wenn Vanilla den Schlüssel hat.
4. **Der wirksame Beschreibungsschlüssel** eines Gegenstands oder Blocks ist: die eigene
   Eigenschaft `DescriptionKey`; sonst die des nächsten Elternteils über `Extends`, sofern
   `param1` sie nicht ausschließt; sonst `<Name>Desc`. Gerechnet wird über Vanilla, unsere
   eigenen Definitionen und **zwei Patch-Formen**: `<append xpath="/items/item[@name='X']">`
   mit einem Kind `DescriptionKey` und `<set xpath="/items/item[@name='X']/property[@name='DescriptionKey']/@value">`
   (ebenso `/blocks/block`).
5. **Eine andere Patch-Form an `DescriptionKey` ist rot** — nicht, weil sie falsch wäre,
   sondern weil Regel 4 sie nicht lesen kann und das Ergebnis sonst geraten wäre.
6. **Nichts gelesen ist nicht grün.** Fehlt eine Eingabe, hat eine Sprachdatei keine Spalte
   `Key` oder keinen Schlüssel, oder nennt keine Patch-Datei einen Schlüssel und trifft keine
   Zeile Regel 2 oder 3, endet der Lauf mit Exit 2.

Der Aufbau eines XML-Knotens wird über Methoden gelesen (Nachtrag viertes Review zu WP8.7).
Schlüssel werden Zeichen für Zeichen verglichen, mit Groß- und Kleinschreibung.

### Grenzen

- **Gelesen wird, was in XML steht.** Schlüssel, die der Spielcode zusammensetzt oder fest
  nennt (`lblQuality…`, Ladebildschirm, Tagebuch), sieht die Prüfung nicht. Eine neue Zeile
  für einen solchen Schlüssel wäre nach Regel 2 rot; bisher gibt es keine.
- **Regel 3 gilt nur für Gegenstände und Blöcke.** Ob eine überschriebene Vanilla-Zeile
  anderer Art (Buff, Fertigkeit, Auftrag, Anzeige) noch gelesen wird, prüft niemand.
- **Ein Patch in einem bedingten Block gilt als angewandt.**
- **`Extends` wird über die unveränderte Elternkette gerechnet.** Ein Patch, der `Extends`
  selbst umsetzt, bleibt ungesehen.
- **Die Form der Sprachdatei prüft weiter `mod700check localization`.** Dieses Skript liest
  sie mit `Import-Csv` und nimmt, was es bekommt.
- **Dass ein Schlüssel eine Zeile hat, heißt nicht, dass der Text passt.**
- **`vanilla-keys.txt` führt die sechs Bruchstück-Schlüssel weiter**, obwohl Vanilla sie
  nicht hat: `localization` kennt nur „Präfix oder Liste", und ein drittes Fach „neuer
  Schlüssel an einem Vanilla-Gegenstand" gibt es dort nicht. Dass eine solche Zeile gelesen
  wird, prüft jetzt Regel 2.

### Gegenproben (Projektregel 5)

Zwölf neue Läufe über Testdaten unter `tools/check/testdaten/sprache/`; alle nehmen
`-Vanilla` aus den Testdaten und brauchen keine Spielinstallation.

| Lauf | Eingang | erwartet |
|---|---|---|
| sauberer Satz | eigene Eigenschaft, Vorgabe `<Name>Desc`, geerbter Schlüssel, Patch setzt den Schlüssel um, Zeile wird über `PromptDescription` gelesen, leeres Attribut, Kommaliste, bedingter Block | Exit 0; 15 genannt (12 in unserer Datei, 3 nur in Vanilla), 15 Zeilen rückwärts, 0 nicht gelesen |
| Regel 1 | dieselben Patch-Dateien, sieben Zeilen weniger — je eine für jede Art, einen Schlüssel zu nennen | Exit 1, 7 rot, jeder einzeln; der Schlüssel, den nur Vanilla hat, nicht |
| Regeln 2 bis 4 | vier tote Zeilen: anderer eigener Schlüssel, **geerbter** Schlüssel (der Fall der Bruchstücke), geerbter an einem Block, neuer Schlüssel ohne Nennung | Exit 1, 4 rot; die über `PromptDescription` gelesene und die Vorgabezeile nicht |
| Regel 5 | fünf Patches an `DescriptionKey` in anderer Form (`starts-with`, `or`, `remove`, `setattribute`, `insertAfter`) | Exit 1, 5 rot |
| XML-Adapter | Attribute und Kinder namens `NodeType`, `LocalName`, `ChildNodes`, `Attributes`, `InnerText` | Exit 1, 3 rot, 1 eigene Definition, 1 Patch gelesen |
| Regel 6, sieben Läufe | Sprachdatei ohne Spalte `Key` · nichts zu prüfen · Patch-Datei kein XML · Vanilla-Ordner ohne `Localization.csv` · Sprachdatei fehlt · Patch-Datei fehlt · kein Spielpfad | je Exit 2, nie `GREEN` |

Dazu ziehen fünf ältere Läufe von `check-all.ps1` nach: ohne Spielpfad heißt die
Ergebniszeile jetzt „7 Prüfungen, 4 rot" (vorher 6 und 3), ohne jede Quelle „7 Prüfungen,
5 rot"; der erste nennt die neue Prüfung als nicht geprüft.

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: **156 Gegenproben, 0
fehlgeschlagen** (vorher 144).

**Am echten Stand:** gegen `700_30_Ausruestung/Config/items.xml` des Commits `3633948` meldet
das Skript **Exit 1, 6 rot** — genau die sechs Bruchstück-Zeilen, jede mit „liest
`gunPartsGroupDesc` (geerbt von `gunMGT1AK47Parts`)"; 63 genannte Schlüssel, 132 Zeilen
rückwärts. Mit den sechs `<append>`: **Exit 0**, 69 genannte Schlüssel, alle in unserer Datei,
14 `DescriptionKey`-Patches gelesen, 132 Zeilen rückwärts, 0 nicht gelesen.

**Sieben Verfälschungen des Skripts, jede macht mindestens einen Lauf rot** (je ein voller
Lauf der Gegenproben, das Skript danach bytegleich wiederhergestellt):

| Verfälschung | fehlgeschlagen |
|---|---|
| Knotenart über die Eigenschaft `NodeType` statt über die Methode | 1 (XML-Adapter) |
| `param1` schließt `DescriptionKey` nicht mehr aus | 2 |
| Werte anderer Eigenschaften zählen nicht als gelesen | 3 |
| Regel 6 abgeschaltet | 1 (nichts zu prüfen) |
| Kommaliste wird nicht geteilt | 2 |
| Regel 5 für `<set>` abgeschaltet | 1 |
| Regel 3 abgeschaltet (nur neue Schlüssel rückwärts) | 2 |

`check-all.ps1`: **7 Prüfungen, 1 rot** (`recipes`, 80 Sackgassen, unverändert);
`kette-pruefen` über die Mod: 20 Patch-Dateien, 433 XPaths (420 in Vanilla, 13 auf eigene
Knoten), 9 bedingte Blöcke.

### Berichtigt an älteren Stellen dieses Vertrags

- Nachtrag WP7.2, Grenzen: „die Sprachschlüssel prüft `mod700check localization`" stimmte
  nur für die Form. Ob `name_key` und `desc_key` eine Zeile haben, prüft seit WP8.8
  `sprachverweise-pruefen.ps1`; die Symbole weiter niemand.

## Nachtrag Review zu WP8.8, 2026-11-22 — sechs Befunde behoben, **abgenommen 2026-11-22**

Das Review des Commits `723e23c` fand fünf mittlere und einen niedrigen Befund, alle in
`sprachverweise-pruefen.ps1`, keinen an den Mod-Dateien.

| # | Befund | Folge |
|---|---|---|
| 1 | `<prepend>` kannte das Skript nicht; ein `<remove>`, dessen XPath das Wort `DescriptionKey` nicht trägt, sah es nicht | eine Änderung am Beschreibungsschlüssel ging ungesehen durch, grün |
| 2 | ein `<set>` auf `DescriptionKey/@value` galt als angewandt, auch wenn das Ziel die Eigenschaft nicht selbst trägt | der gesetzte Schlüssel galt als gelesen; im Spiel trifft der XPath nichts |
| 3 | jeder von einem Patch **genannte** Schlüssel galt als gelesen, auch ein später überschriebener; dazu zählte jeder Eigenschaftswert in **jeder** unserer Dateien | tote Zeile grün |
| 4 | der Wert eines `DescriptionKey` wurde an Kommas geteilt | `a,b` grün, wenn `a` und `b` Zeilen haben; das Spiel liest `a,b` als einen Schlüssel |
| 5 | geprüft wurde nur die Summe aus Gegenständen und Blöcken | eine leere `blocks.xml` in Vanilla: grün statt nicht prüfbar |
| 6 | ein Pfad mit unzulässigen Zeichen bei `-Sprachdatei` oder `-Patches` warf | Exit 1 statt 2 |

Die Befunde 1 bis 3 haben eine Ursache: das Skript **erkannte** zwei Patch-Formen am Text,
statt die Patches anzuwenden. Der Umbau nimmt die Ursache weg.

### Geänderte Regeln (ersetzen die Regeln 4 und 5 des Nachtrags WP8.8)

4. **Der wirksame Beschreibungsschlüssel wird am gepatchten Stand gerechnet.** Das Skript
   wendet jede Patch-Datei, die `items.xml` oder `blocks.xml` heißt, in der Reihenfolge der
   Dateien auf Vanillas Datei an — alle neun Operationen des Spiels (`set`, `setattribute`,
   `append`, `prepend`, `insertAfter`, `insertBefore`, `remove`, `removeattribute`, `csv`),
   jeder XPath gegen den Stand ausgewertet, den die Operationen davor hinterlassen haben.
   Am Ergebnis gilt wie bisher: eigene Eigenschaft `DescriptionKey`, sonst geerbt über
   `Extends` (außer `param1` schließt sie aus), sonst `<Name>Desc`. Eigene Gegenstände und
   Blöcke sind die, die nach den Patches da sind und in Vanilla nicht.
5. **Was sich nicht anwenden lässt, ist rot** — der gerechnete Stand wäre sonst geraten:
   - eine Operation in einer dieser Dateien, deren XPath **nichts trifft** oder sich nicht
     auswerten lässt;
   - ein bedingter Block in einer dieser Dateien (das Skript rechnet keine Bedingung);
   - ein unbekanntes Element auf der ersten Ebene einer dieser Dateien;
   - ein Gegenstand oder Block, der nach den Patches **zwei** eigene Eigenschaften
     `DescriptionKey` trägt und in Vanilla nicht: welche gilt, ist nicht gelesen.

### Geänderte Regeln 1 bis 3

- **Regel 1, `DescriptionKey`:** in `items.xml` und `blocks.xml` zählt nicht mehr, was ein
  Patch nennt, sondern was nach den Patches dasteht — jede eigene Eigenschaft
  `DescriptionKey`, die Vanilla an dieser Stelle nicht oder anders hat, braucht eine Zeile.
  In allen anderen Dateien zählt weiter die Nennung. **Der Wert ist ein Schlüssel und wird
  nicht geteilt**; geteilt werden nur Attribute auf `_key`.
- **Regeln 2 und 3, „gelesen":** der Name eines Gegenstands oder Blocks im gepatchten Stand,
  sein wirksamer Beschreibungsschlüssel, der Wert einer Eigenschaft und eines Attributs auf
  `_key` **im gepatchten Stand** von `items.xml`/`blocks.xml`, und eine Nennung in einer
  **anderen** Datei. Eine Nennung in einem Patch für `items.xml`/`blocks.xml` zählt nicht
  mehr — nur, was davon übrig ist.
- **Regel 6:** jede der beiden Vanilla-Dateien muss die erwartete Wurzel (`items`, `blocks`)
  und mindestens eine benannte Definition tragen, sonst Exit 2. Ein Pfad, der sich nicht
  prüfen oder auflösen lässt, ist Exit 2; ebenso jeder unerwartete Fehler des Skripts.

### Grenzen, neu oder geändert

- **Das Skript ist kein zweiter Patcher des Spiels.** Es wendet die neun Operationen so an,
  wie Vertrag 03 und das Finding WP1 sie beschreiben; `csv` und `append`/`prepend` auf ein
  Attribut sind nachgebaut, nicht am Spiel gemessen. Für `DescriptionKey` benutzt das
  Projekt sie nicht.
- **Die Reihenfolge ist die der Dateinamen** (bei `-Patches` die genannte). Dass das Spiel
  die Modlets in dieser Reihenfolge lädt, sagt D53, nicht dieses Skript.
- **„Ein Patch in einem bedingten Block gilt als angewandt"** gilt nur noch für die Nennung
  in anderen Dateien. In `items.xml`/`blocks.xml` ist ein bedingter Block rot.
- **„Patch trifft nichts" meldet jetzt auch dieses Skript**, für `items.xml` und
  `blocks.xml` und gegen den Stand zur Zeit der Operation. `kette-pruefen` prüft dasselbe
  für alle Dateien gegen Vanilla; die beiden Meldungen können dieselbe Zeile treffen.
- **Das Netz hinter den Pfadprüfungen hat keine eigene Gegenprobe.** Jeder unerwartete
  Fehler endet über einen `trap` mit Exit 2. Kein Eingang der Testdaten erreicht ihn, solange
  die Pfadprüfungen selbst abfangen; dass er trägt, zeigt nur die Verfälschung unten, die
  das Abfangen wegnimmt.

### Gegenproben (Projektregel 5)

Neun neue Läufe, einer ersetzt, drei mit neuen Erwartungen — zusammen 21 Läufe für dieses
Skript (vorher 12). Testdaten unter `tools/check/testdaten/sprache/`.

| Befund | Lauf | Eingang | erwartet |
|---|---|---|---|
| 1 | `verben` | ein `<prepend>` hängt einem Vanilla-Gegenstand den Schlüssel an; ein `<remove>`, dessen XPath das Wort `DescriptionKey` nicht trägt, nimmt dem Elternteil die Eigenschaft | Exit 1, **1 rot**: die Vorgabezeile des eigenen Erben fehlt; die Zeile hinter dem `<prepend>` ist **nicht** rot; 3 Operationen angewandt |
| 2 | `set-ohne-treffer` | `<set>` auf `DescriptionKey/@value` an einem Gegenstand, der die Eigenschaft nur erbt | Exit 1, 2 rot: „Patch trifft nichts", und die Zeile wird nicht gelesen |
| 3 | `ueberschrieben` | zwei `<set>` nacheinander auf denselben Schlüssel; in `buffs.xml` eine Eigenschaft, die zufällig `pruefTeilDesc` als Wert trägt | Exit 1, 2 rot: beide Zeilen werden nicht gelesen |
| 4 | `komma` | `DescriptionKey` mit dem Wert `a,b`, einmal im gepatchten Stand, einmal in einer Datei, in der die Nennung zählt; `a` und `b` haben je eine Zeile | Exit 1, 2 rot: `a,b` hat keine Zeile |
| 5 | `vanilla-leer`, `vanilla-falsch` | Vanillas `blocks.xml` ohne Block · mit der Wurzel `<items>`; dazu der saubere Satz | je Exit 2, nie `GREEN` |
| 6 | drei Läufe | `C:\invalid<file>` als `-Sprachdatei` · als `-Patches` · `C:\invalid<ordner>` als `-Vanilla` | je Exit 2 mit der Meldung der Stelle, die den Pfad prüft; nie „unerwarteter Fehler" |
| Regel 5 | `nicht-anwendbar` (ersetzt den Lauf „Regel 5" des Nachtrags WP8.8) | bedingter Block · unbekanntes Element · XPath, der sich nicht auswerten lässt · XPath ohne Treffer · zwei Eigenschaften `DescriptionKey` nach den Patches | Exit 1, 5 rot |

Die Läufe „sauberer Satz", „Regel 1" und „XML-Adapter" behalten ihre Eingänge und ihre
Ergebnisse (Exit 0 · 7 rot · 3 rot); sie erwarten jetzt die neuen Zählzeilen („Patch-Operationen
angewandt", „nach den Patches … davon eigene …", „Beschreibungsschlüssel von uns gesetzt").

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: **165 Gegenproben, 0
fehlgeschlagen** (vorher 156).

**Gegen die Fassung des Commits `723e23c`** (das Skript an Ort und Stelle getauscht, die
Gegenproben unverändert): **11 von 165 fehlgeschlagen.** Acht davon sind neue Läufe — jeder
der Befunde 1 bis 5 und zwei der drei Pfadläufe. Der dritte Pfadlauf (`-Vanilla`) war schon
gegen die erste Fassung Exit 2; er hält den Stand und beweist am Befund 6 nichts. Die übrigen
drei scheitern an den neuen Zählzeilen und am ersetzten Lauf, nicht an einem Befund.

**Fünfzehn Verfälschungen der Neufassung** (je ein voller Lauf der Gegenproben, das Skript
danach bytegleich wiederhergestellt):

| Verfälschung | fehlgeschlagen |
|---|---|
| `prepend` aus der Liste der Operationen genommen | 1 (`verben`) |
| `<remove>` entfernt nichts | 1 (`verben`) |
| „Patch trifft nichts" wird nicht gemeldet | 2 |
| eine Nennung in `items.xml`/`blocks.xml` zählt wieder als gelesen | 6 |
| jede Eigenschaft einer anderen Datei zählt als `DescriptionKey` | 1 (`ueberschrieben`) |
| `DescriptionKey` wird an Kommas geteilt | 1 (`komma`) |
| leere Vanilla-Tabelle ist kein Abbruch | 1 (`vanilla-leer`) |
| Wurzel der Vanilla-Datei wird nicht geprüft | 1 (`vanilla-falsch`) |
| Pfadprüfungen fangen nicht mehr selbst ab | 3 (die drei Pfadläufe) |
| Pfadprüfungen fangen nicht ab **und** der `trap` fehlt | 3 |
| zwei Eigenschaften `DescriptionKey` werden nicht gemeldet | 1 (`nicht-anwendbar`) |
| bedingter Block wird nicht gemeldet | 1 (`nicht-anwendbar`) |
| unauswertbarer XPath wird nicht gemeldet | 1 (`nicht-anwendbar`) |
| Regel 1 am gepatchten Stand abgeschaltet | 4 |
| **nur der `trap` fehlt** | **0** — siehe Grenzen |

Die Zeile „Pfadprüfungen fangen nicht mehr selbst ab" hat eine Vorgeschichte: im ersten Durchgang verlangten die drei
Pfadläufe nur Exit 2, und die Verfälschung „fangen nicht mehr selbst ab" machte **keinen** rot
— der `trap` gab denselben Ausgang. Die Läufe verlangen seither die Meldung der Stelle.

**Am echten Stand** (`sprachverweise-pruefen.ps1` ohne Parameter): 27 Patch-Dateien, 7 davon
auf `items.xml` und `blocks.xml` angewandt, **729 Operationen angewandt, 0 ohne Treffer**;
1 434 Gegenstände und 6 643 Blöcke in Vanilla, nach den Patches 1 451 und 6 649, davon
eigene 17 und 6; 32 Beschreibungsschlüssel von uns gesetzt; 72 genannte Schlüssel, alle in
unserer Datei; 132 Zeilen rückwärts, 0 nicht gelesen; **Exit 0**. Die Zahlen 1 451 und 6 649
sind dieselben, die der ConfigsDump des Spiels für den gepatchten Stand trägt.

**Gegen den Stand vor dem Fix** (dieselbe Dateiliste, nur `700_30_Ausruestung/Config/items.xml`
aus dem Commit `3633948`): 723 Operationen, **6 rot** — wieder genau die sechs Bruchstück-Zeilen,
jede mit „liest `gunPartsGroupDesc` (geerbt von `gunMGT1AK47Parts`)".

`check-all.ps1`: **7 Prüfungen, 1 rot** (`recipes`, 80 Sackgassen, unverändert);
`kette-pruefen` unverändert 433 XPaths (420 in Vanilla, 13 auf eigene Knoten), 9 bedingte
Blöcke.

## Nachtrag zweites Review zu WP8.8, 2026-11-22 — zwei Befunde behoben, **abgenommen 2026-11-22**

Das Review des Commits `a60fe9b` fand zwei mittlere Befunde, beide in
`sprachverweise-pruefen.ps1`, keinen an den Mod-Dateien. Beide Lücken hat der Umbau des
ersten Reviews geöffnet: die Fassung davor war in diesen Fällen rot.

| # | Befund | Folge |
|---|---|---|
| 1 | ein `<remove>`, dessen XPath ein **Attribut** trifft, entfernte das Attribut und zählte als angewandt | das Spiel lehnt genau das ab (Vertrag 03 §2: *„use removeattribute instead"*); gerechnet wurde ein Stand, den das Spiel nicht erzeugt — grün |
| 2 | entfernt oder benennt ein Patch einen Vanilla-Gegenstand um, galt dessen Zeile `<Name>Desc` nicht mehr als Beschreibung und wurde übersprungen | tote Zeile grün |

Der Befund 1 ist ein Fall einer Klasse: an fünf weiteren Stellen tat das Skript bei einem
Treffer der falschen Knotenart **nichts** und zählte die Operation als angewandt. Die Regel
unten nimmt die Klasse.

### Geänderte Regeln

- **Regel 5, neuer Punkt — eine Operation, die das Skript an ihrem Treffer nicht rechnet, ist
  rot und wird nicht angewandt.** Gerechnet wird:

  | Operation | auf einem Element | auf einem Attribut |
  |---|---|---|
  | `set` | ja | ja |
  | `append`, `prepend` | ja (Kinder) | ja (Text anhängen, nachgebaut) |
  | `setattribute`, `removeattribute`, `insertAfter`, `insertBefore` | ja | **rot** |
  | `remove` | ja | **rot** — das Spiel lehnt es ab |
  | `csv` | **rot** | ja (nachgebaut) |

  Ein Treffer, der weder Element noch Attribut ist (Kommentar, Text), ist für jede Operation
  rot. Trifft ein XPath mehrere Knoten und einer davon ist rot, wird die ganze Operation nicht
  angewandt.
- **Regel 3, erweitert — „Beschreibung eines Gegenstands oder Blocks" heißt: in Vanilla
  *oder* im gepatchten Stand.** Eine Zeile `<Name>Desc` fällt unter die Rückwärtsprüfung, wenn
  `<Name>` in Vanilla oder nach den Patches ein Gegenstand oder Block ist. Wer sie **liest**,
  wird weiter allein am gepatchten Stand geprüft. Ist `<Name>` nach den Patches nicht mehr da
  (entfernt oder umbenannt) und liest nichts im gepatchten Stand den Schlüssel, ist die Zeile
  rot.

### Grenzen, neu

- **Was das Spiel bei den roten Paaren tut, ist nur für `remove` auf ein Attribut gelesen.**
  Für die übrigen (`setattribute`, `removeattribute`, `insertAfter`, `insertBefore` auf ein
  Attribut; `csv` auf ein Element; Treffer auf Kommentar oder Text) heißt rot: *diese Prüfung
  rechnet es nicht* — nicht: das Spiel lehnt es ab. Die Mod benutzt keines dieser Paare.
- **Eine umbenannte Definition ist für das Skript eine entfernte und eine eigene.** Es folgt
  dem Namen nicht.

### Gegenproben (Projektregel 5)

Drei neue Läufe — zusammen 24 für dieses Skript. Testdaten unter
`tools/check/testdaten/sprache/`.

| Befund | Lauf | Eingang | erwartet |
|---|---|---|---|
| 1 | `remove-attribut` | ein `<remove>` auf `…/property[@name='DescriptionKey']/@value` | Exit 1, 1 rot; 0 Operationen angewandt, 1 nicht gerechnet |
| 1, Klasse | `knotenart` | `setattribute`, `removeattribute`, `insertAfter`, `insertBefore` auf ein Attribut · `csv` auf ein Element · `set` auf einen Kommentar · ein `<remove>` mit zwei Treffern, erst Element, dann Attribut | Exit 1, 7 rot; 0 angewandt, 7 nicht gerechnet; **5 Gegenstände nach den Patches** — der erste Treffer des letzten Falls ist nicht entfernt |
| 2 | `entfernt` | drei Vanilla-Gegenstände verschwinden: entfernt · umbenannt · entfernt, aber ein eigener Gegenstand nimmt die Zeile als Beschreibungsschlüssel | Exit 1, 2 rot; die dritte Zeile ist **nicht** rot |

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: **168 Gegenproben, 0
fehlgeschlagen** (vorher 165).

**Gegen die Fassung des Commits `a60fe9b`:** 3 von 168 fehlgeschlagen — genau die drei neuen.

**Acht Verfälschungen der Neufassung, jede macht mindestens einen Lauf rot** (je ein voller
Lauf der Gegenproben, das Skript danach bytegleich wiederhergestellt):

| Verfälschung | fehlgeschlagen |
|---|---|
| `remove` auf ein Attribut gilt nicht mehr als Hindernis | 2 |
| die Liste „nur auf einem Element" ist leer | 1 (`knotenart`) |
| `csv` auf ein Element gilt nicht mehr als Hindernis | 1 (`knotenart`) |
| Treffer anderer Knotenarten gelten nicht mehr als Hindernis | 1 (`knotenart`) |
| Beschreibungszeilen werden wieder nur am gepatchten Stand erkannt | 1 (`entfernt`) |
| eine Zeile zu einem verschwundenen Gegenstand ist immer rot, ohne nach Lesern zu sehen | 1 (`entfernt`) |
| geprüft wird nur der erste Treffer einer Operation | 1 (`knotenart`) |
| das Verhalten von `a60fe9b` für `remove` auf ein Attribut | 2 |

Bei vier dieser Verfälschungen scheitert der Lauf nicht an einem falschen Grün, sondern an
Exit 2: die Operation erreicht dann einen Knoten, an dem sie eine Ausnahme wirft, und das Netz
für unerwartete Fehler greift. Das ist gewollt — im Skript steht an diesen Stellen kein stilles
„sonst nichts" mehr.

**Am echten Stand unverändert:** 729 Operationen angewandt, 0 ohne Treffer, **0 nicht
gerechnet**; 1 451 Gegenstände und 6 649 Blöcke nach den Patches; 72 genannte Schlüssel, 132
Zeilen rückwärts, 0 nicht gelesen; Exit 0. Gegen den Stand vor dem Fix weiter genau die sechs
Bruchstück-Zeilen. Die Mod entfernt keine Definition (1 434 + 17 eigene = 1 451) und trifft mit
keiner Operation eine der roten Knotenarten.

`check-all.ps1`: **7 Prüfungen, 1 rot** (`recipes`, 80 Sackgassen, unverändert).

## Nachtrag drittes Review zu WP8.8, 2026-11-22 — drei Befunde behoben, **abgenommen 2026-11-22**

Das Review des Commits `387761b` fand einen mittleren und zwei niedrige Befunde, alle in
`sprachverweise-pruefen.ps1` und seinen Gegenproben, keinen an den Mod-Dateien.

| # | Schwere | Befund | Folge |
|---|---|---|---|
| 1 | mittel | die Gruppenbeschreibung der Blöcke (`<blocks defaultDescriptionKey="…">`) zählte nirgends als gelesen | eine Zeile, die ein Block über diesen Rückfall liest, konnte rot werden — falsches Rot |
| 2 | niedrig | ein XPath auf einen Namespace-Knoten (`/items/namespace::xml`) liefert ein Attribut ohne Element; die Operation zählte als angewandt und änderte nichts | grün |
| 3 | niedrig | keine Gegenprobe für einen entfernten Vanilla-**Block** | der Zweig konnte wegfallen, ohne dass ein Lauf rot wird |

Der Befund 1 zeigt auf eine ältere Lücke: das Finding beschreibt den Rückfall auf die
Gruppenbeschreibung seit WP8.8, das Skript rechnete ihn nie.

### Geänderte Regeln

- **Regel 4, dritter Schritt für Blöcke.** Hat der wirksame Beschreibungsschlüssel eines
  Blocks im gepatchten Stand **keine Zeile** — weder in unserer Sprachdatei noch in Vanillas
  —, liest das Spiel die Gruppenbeschreibung: den Wert von `defaultDescriptionKey` am
  Wurzelknoten der gepatchten `blocks.xml`
  ([Finding](../rea/findings/WP8-beschreibungsschluessel-wird-vererbt.md), „Blöcke"). Der
  Schlüssel gilt als **gelesen**, sobald mindestens ein Block so auf ihn zurückfällt — und nur
  dann.
- **Regel 1, neuer Punkt.** Trägt der Wurzelknoten der gepatchten `blocks.xml` einen anderen
  `defaultDescriptionKey` als Vanilla, haben wir ihn gesetzt; er braucht eine Zeile.
- **Regel 5, Ergänzung.** Ein Attributtreffer ohne Eigentümerelement (Namespace-Knoten) ist
  für jede Operation rot.

### Grenzen, neu

- **„Keine Zeile" heißt hier: der Schlüssel steht in keiner der beiden Sprachdateien.** Was
  das Spiel bei einer Zeile mit leerem Text tut, ist nicht gelesen.
- **Die Mod setzt `defaultDescriptionKey` nicht.** Die Regel 1 dazu ist an Testdaten
  vorgeführt, nicht am echten Stand.

### Gegenproben (Projektregel 5)

Sechs neue Läufe — zusammen 30 für dieses Skript. Vier davon nehmen eine zweite
Vanilla-Vorlage (`testdaten/sprache/vanilla-gruppe/`): dort heißt die Gruppenbeschreibung der
Blöcke wie die Vorgabezeile eines Gegenstands, und ein Block hat für seinen Schlüssel keine
Zeile.

| Befund | Lauf | Eingang | erwartet |
|---|---|---|---|
| 1 | `gruppe` | der Gegenstand verschwindet; seine Zeile ist die Gruppenbeschreibung, und ein Block fällt auf sie zurück | **Exit 0**; 1 Block liest die Gruppenbeschreibung |
| 1, Gegenstück | `gruppe` + `gruppe/ungelesen` | dazu verschwindet der einzige Block, der zurückfiel | Exit 1, 1 rot; 0 Blöcke lesen sie |
| Regel 1 | `gruppe-gesetzt`, zwei Läufe | wir setzen `defaultDescriptionKey` auf einen eigenen Schlüssel · mit Zeile · ohne Zeile | Exit 0, 1 genannt und gelesen · Exit 1, 1 rot |
| 3 | `block-entfernt` | ein Vanilla-Block verschwindet, unsere Datei überschreibt seine Zeile | Exit 1, 1 rot |
| 2 | `namespace` | `<set xpath="/items/namespace::xml">` | Exit 1, 1 rot; 0 angewandt, 1 nicht gerechnet |

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: **174 Gegenproben, 0
fehlgeschlagen** (vorher 168).

**Gegen die Fassung des Commits `387761b`:** 5 von 174 fehlgeschlagen, alle unter den sechs
neuen. Drei mit dem falschen Ausgang (das falsche Rot aus Befund 1, der Namespace-Knoten,
die gesetzte Gruppenbeschreibung ohne Zeile), einer, weil ein neuer eigener Gruppenschlüssel
dort als ungelesen galt, und einer nur an der neuen Ausgabezeile — der Ausgang war derselbe.
Der sechste Lauf (`block-entfernt`) ist gegen `387761b` grün: der Zweig war dort schon
richtig, ihm fehlte die Gegenprobe. Dass sie trägt, zeigt die fünfte Verfälschung unten.

**Sieben Verfälschungen der Neufassung, jede macht mindestens einen Lauf rot** (je ein voller
Lauf der Gegenproben, das Skript danach bytegleich wiederhergestellt):

| Verfälschung | fehlgeschlagen |
|---|---|
| Namespace-Knoten gilt nicht mehr als Hindernis | 1 (`namespace`) |
| die Gruppenbeschreibung gilt nie als gelesen | 2 |
| die Gruppenbeschreibung gilt immer als gelesen | 1 (Gegenstück) |
| eine von uns gesetzte Gruppenbeschreibung wird nicht genannt | 2 |
| der Zweig für verschwundene **Blöcke** fehlt | 1 (`block-entfernt`) |
| der Zweig für verschwundene **Gegenstände** fehlt | 3 |
| „keine Zeile" sieht nur in unsere Sprachdatei, nicht in Vanillas | 3 |

**Am echten Stand:** die Gruppenbeschreibung heißt `creativeMenuBlockGroupDesc`, und **3 246**
der 6 649 Blöcke fallen auf sie zurück. Sonst unverändert: 729 Operationen angewandt, 0 ohne
Treffer, 0 nicht gerechnet; 72 genannte Schlüssel, 132 Zeilen rückwärts, 0 nicht gelesen;
Exit 0. Gegen den Stand vor dem Fix weiter genau die sechs Bruchstück-Zeilen.

`check-all.ps1`: **7 Prüfungen, 1 rot** (`recipes`, 80 Sackgassen, unverändert).

## Nachtrag viertes Review zu WP8.8, 2026-11-22 — vier Befunde behoben, **abgenommen 2026-11-22**

Das Review des Commits `c353996` fand einen mittleren und drei niedrige Befunde: zwei im
Skript, einen an den Gegenproben, einen am Wortlaut des Plans. Keinen an den Mod-Dateien.
Die Befunde 1 und 3 sind vor dem Beheben am Stand `c353996` nachgestellt worden.

| # | Schwere | Befund | Folge |
|---|---|---|---|
| 1 | mittel | leert oder entfernt ein Patch `defaultDescriptionKey`, übersprang das Skript die ganze Prüfung dazu | nachgestellt: Exit 0, obwohl ein Block auf die Gruppenbeschreibung zurückfiele und der geänderte Wert keine Zeile hat |
| 2 | niedrig | fällt ein Block auf die Gruppenbeschreibung zurück, nannte die Meldung zu seiner ungelesenen Zeile weiter seinen eigenen Schlüssel | richtiger Ausgang, falscher Text |
| 3 | niedrig | keine Gegenprobe für eine Blockzeile, die nur **unsere** Sprachdatei hat | nachgestellt: ohne die Abfrage unserer Datei blieben alle 174 Gegenproben grün |
| 4 | niedrig | der Plan sagte „ein Namespace-Knoten ist rot" | der Vertrag sagt es enger: rot ist ein Attributtreffer **ohne Eigentümerelement** |

### Geänderte Regeln

- **Regel 1, Gruppenbeschreibung, genauer.** Trägt der Wurzelknoten der gepatchten
  `blocks.xml` einen anderen `defaultDescriptionKey` als Vanilla, haben wir ihn geändert. Ist
  der neue Wert ein Schlüssel, braucht er eine Zeile. **Ist er leer oder fehlt das Attribut,
  ist das rot** — ein leerer Schlüssel hat keine Zeile. Die Meldung nennt, wie viele Blöcke
  ohne eigene Zeile auf die Gruppenbeschreibung zurückfielen.
- **Meldung zu einer ungelesenen Blockzeile.** Hat der wirksame Schlüssel des Blocks keine
  Zeile, nennt die Meldung die Gruppenbeschreibung als das, was der Block liest, und seinen
  eigenen Schlüssel als den, dem die Zeile fehlt.
- **Regel 5, Wortlaut.** Rot ist ein Attributtreffer, der zu keinem Element gehört. So liefert
  die Namespace-Achse den Namespace `xml` (`/items/namespace::xml`). Ein ausdrücklich
  deklarierter Namespace (`xmlns:p="…"`) ist ein gewöhnliches Attribut seines Elements und
  wird gerechnet wie jedes andere.

### Grenzen, neu

- **Was das Spiel bei einer leeren Gruppenbeschreibung anzeigt, ist nicht gelesen.** Rot heißt
  hier: wir haben den Schlüssel geändert, und er hat keine Zeile.

### Gegenproben (Projektregel 5)

Vier neue Läufe — zusammen 34 für dieses Skript —, alle gegen die Vorlage
`testdaten/sprache/vanilla-gruppe/`. Der Lauf zum Namespace-Knoten erwartet den neuen
Wortlaut der Meldung.

| Befund | Lauf | Eingang | erwartet |
|---|---|---|---|
| 1 | `gruppe-leer` | `<set>` leert `defaultDescriptionKey` | Exit 1, 1 rot; die Meldung nennt Vanillas Schlüssel und 1 Block, der zurückfiele |
| 1 | `gruppe-leer/entfernt` | `<removeattribute>` nimmt das Attribut weg | dasselbe |
| 3 | `gruppe` + `gruppe/eigene-zeile` | die Zeile des Blocks, der zurückfiel, steht nur in **unserer** Sprachdatei | Exit 1, 1 rot; 0 Blöcke lesen die Gruppenbeschreibung, ihre Zeile ist ungelesen |
| 2 | `gruppe-meldung` | ein Block bekommt einen Schlüssel ohne Zeile; seine alte Zeile bleibt in unserer Datei | Exit 1, 2 rot; die Meldung zur alten Zeile nennt die Gruppenbeschreibung und den Schlüssel, dem die Zeile fehlt |

Gemessen am 2026-11-22 mit `tools/check/gegenproben.ps1`: **178 Gegenproben, 0
fehlgeschlagen** (vorher 174).

**Gegen die Fassung des Commits `c353996`:** 4 von 178 fehlgeschlagen. Zwei mit dem falschen
Ausgang (geleert, entfernt: Exit 0 statt 1), zwei am Wortlaut (die Meldung zur Blockzeile,
die Meldung zum Namespace-Knoten). Der Lauf zum Befund 3 ist gegen `c353996` grün — dort
rechnete das Skript richtig, ihm fehlte die Gegenprobe. Dass sie trägt, zeigt die zweite
Verfälschung unten; es ist dieselbe, die vor dem Beheben alle 174 Läufe grün ließ.

**Fünf Verfälschungen der Neufassung, jede macht mindestens einen Lauf rot** (je ein voller
Lauf der Gegenproben, das Skript danach bytegleich wiederhergestellt):

| Verfälschung | fehlgeschlagen |
|---|---|
| eine geleerte Gruppenbeschreibung ist kein Befund | 2 |
| „hat eine Zeile" sieht nicht in unsere Sprachdatei | 1 (Befund 3) |
| „hat eine Zeile" sieht nicht in Vanillas Sprachdatei | 8 |
| die Meldung nennt wieder den eigenen Schlüssel des Blocks | 1 |
| Blöcke ohne Zeile werden nur gezählt, wenn die Gruppenbeschreibung nicht leer ist | 2 |

**Am echten Stand unverändert:** Gruppenbeschreibung `creativeMenuBlockGroupDesc`, 3 246
Blöcke fallen auf sie zurück; 729 Operationen angewandt, 0 ohne Treffer, 0 nicht gerechnet;
72 genannte Schlüssel, 132 Zeilen rückwärts, 0 nicht gelesen; Exit 0. Gegen den Stand vor dem
Fix weiter genau die sechs Bruchstück-Zeilen.

`check-all.ps1`: **7 Prüfungen, 1 rot** (`recipes`, 80 Sackgassen, unverändert).

### Bekannte Lücken nach dem fünften Review (Commit `52be401`, 2026-11-22) — nicht behoben

Das Review dieses Stands fand einen mittleren und zwei niedrige Befunde. Der Nutzer hat am
selben Tag entschieden, hier aufzuhören und sie als offen zu führen. Sie gelten damit als
**bekannte Grenzen dieses Skripts**, nicht als Regelbruch:

- **Geändert heißt: der Wert ist ein anderer.** Ob es das Attribut `defaultDescriptionKey`
  gibt, vergleicht das Skript nicht. Ein in Vanilla fehlendes Attribut, das ein Patch leer
  ergänzt, und ein schon leeres, das ein Patch entfernt, sind für das Skript keine Änderung.
- **Die Meldungen zur Gruppenbeschreibung setzen einen befüllten Schlüssel voraus.** Ist sie
  nach den Patches leer und hat zugleich ein Block einen Schlüssel ohne Zeile, nennt die
  Meldung zu dessen alter Zeile seinen eigenen Schlüssel, und die Zählzeile spricht von
  Blöcken, die eine leere Gruppenbeschreibung „lesen". Der Ausgang ist richtig.
- **Dass ein ausdrücklich deklarierter Namespace gerechnet wird, hält keine Gegenprobe.**

Keine der drei ist nachgestellt. Geführt werden sie im Plan unter „Offene Punkte".

## Nachtrag WP8.9, 2026-11-22 — Vorprüfung der Verträglichkeit mit einer fremden Mod, **abgenommen 2026-11-22**

### Anlass

D86 nennt zwei Referenz-UI-Mods, ihre Dateien liegen seit dem 22. November 2026 unter
`GameRefs/ui-mods/`. Die Testmatrix (Prüfliste 24 des Plans) braucht drei Läufe im Spiel. Was
sich **ohne** Spiel sagen lässt, sagt bisher nur eine Textsuche — und die sieht nicht, ob die
fremde Mod einen Elternknoten unserer Ziele entfernt oder einen Wert überschreibt, den wir
gesetzt haben. Diese Prüfung rechnet es aus, statt es am Text zu erkennen. **Sie ersetzt
keinen Lauf**: sie sagt, wo ein Lauf hinsehen muss.

### Das Werkzeug

`tools/check/vertraeglichkeit-pruefen.ps1`. Parameter:

- `-Fremd` — ein oder mehrere Ordner fremder Mods, jeder mit `ModInfo.xml` und `Config\`
  direkt darin. Ohne Angabe jeder solche Ordner unmittelbar unter `GameRefs\ui-mods\`.
- `-Unsere` — unsere Modlet-Ordner. Ohne Angabe jeder Ordner unter `mod\` mit `ModInfo.xml`.
- `-Vanilla` — ohne Angabe `<SDTD_PATH>\Data\Config`.
- `-NCalc` — die `NCalc.dll` des Spiels, wie bei `kette-pruefen.ps1`; gebraucht, sobald eine
  gerechnete Datei einen bedingten Block hat.

Jede fremde Mod wird **für sich** gegen unsere Modlets gerechnet, nie zwei fremde zusammen
(so fährt auch die Matrix). Ausgänge wie überall: 0 grün, 1 Befund, 2 nicht prüfbar; bei
mehreren fremden Mods gilt der schlechteste.

**Die neun Patch-Operationen liegen jetzt in einer Datei**, `tools/check/patch-operationen.ps1`,
die `sprachverweise-pruefen.ps1` und das neue Skript beide einlesen. Es ist derselbe Code,
der vorher in `sprachverweise-pruefen.ps1` stand (Nachträge „Review" bis „viertes Review zu
WP8.8"), an der Regel ändert sich dort nichts. Fehlt die Datei, endet jedes der beiden
Skripte mit Ausgang 2.

**Nicht in `check-all.ps1`.** Die Eingabe dieser Prüfung liegt außerhalb des Repositorys, und
ihr Ergebnis sagt etwas über fremde Dateien, nicht über unseren Stand: ein roter Lauf hier
ist eine Frage an die Matrix, kein Fehler in der Mod, und er dürfte `check-all` nicht auf
Dauer rot halten. Ihre Gegenproben laufen in `gegenproben.ps1` und damit in jedem
`check-all`. *(Die Alternative — achte Prüfung in `check-all`, ohne Dateien Ausgang 2 — ist
möglich; sie wartet auf die Abnahme.)*

### Die Regeln

1. **Geladen wird wie im Spiel.** Je Mod höchstens eine Patch-Datei je Vanilla-Datei, gesucht
   unter demselben Pfad relativ zu `Config\` (D53). Unsere Modlets in der Reihenfolge ihrer
   Ordnernamen. Eine XML-Datei ohne Vanilla-Gegenstück lädt das Spiel nicht; sie wird
   genannt und nicht gerechnet.
2. **Vier Stände je gemeinsamer Datei.** Gemeinsam ist eine XML-Datei, die die fremde Mod
   **und** mindestens eines unserer Modlets patcht. Für sie wird, jeweils von der
   unveränderten Vanilla-Datei aus, gerechnet: wir allein · die fremde Mod allein · wir,
   dann die fremde · die fremde, dann wir. Jede Operation läuft gegen den Stand, den die
   Operationen davor hinterlassen haben. Dateien, die nur die fremde Mod patcht, werden
   allein gerechnet (Regel 5); Dateien, die nur wir patchen, prüft `kette-pruefen.ps1`.
3. **Beide Reihenfolgen, eine davon erwartet.** Erwartet ist die, die die Ordnernamen
   ergeben (der Lader sortiert sie, Finding WP1 §1). Sortieren der zeichenweise und der
   sprachabhängige Vergleich verschieden, ist keine erwartet. Befunde aus beiden
   Reihenfolgen zählen; jede Zeile nennt ihre.
4. **Befund ist** (jeder zählt, Ausgang 1):
   - **Ziel verloren** — eine Operation, die allein mindestens einen Knoten trifft, läuft in
     der Kombination und trifft nichts. Das Spiel schriebe dafür eine Warnung ins Protokoll.
   - **Zweig wechselt** — eine Operation in einem bedingten Block läuft allein und in der
     Kombination nicht, oder umgekehrt, weil die Bedingung anders ausfällt.
   - **Wirkung verändert** — was die zuerst geladene Seite geschrieben hat, ist nach der
     zweiten entfernt oder anders. Verfolgt wird: der Wert eines Attributs, das `set`,
     `setattribute`, `csv`, `append` oder `prepend` geschrieben hat; ein Element, das
     `append`, `prepend`, `insertAfter` oder `insertBefore` eingefügt hat, mit allem
     darunter; der Text, den `set` an einem Element gesetzt hat. Die Zeile nennt die
     Operation der zweiten Seite, nach der es zuerst anders war.
   - **Nicht gerechnet** — in irgendeinem der vier Stände: eine Operation, die
     `patch-operationen.ps1` an ihren Treffern nicht rechnet, eine unbekannte Operation,
     `<include>`, ein ungültiger XPath, ein bedingter Block mit falschem Aufbau, eine
     Bedingung, die NCalc nicht liest, die keinen Wahrheitswert liefert oder die eine andere
     Funktion als `mod_loaded` und `xpath` ruft. Der Stand danach wäre geraten.
   - **Gemeinsamer Sprachschlüssel** — ein Schlüssel, der in einer `Config\Localization.csv`
     von uns und in der der fremden Mod steht. Welcher Text gilt, hängt an der Reihenfolge.
     Eine Sprachdatei, die sich nicht lesen lässt, ist „nicht gerechnet".
5. **Kein Befund, aber gezählt und einzeln genannt:** Operationen der fremden Mod, die schon
   **allein** nichts treffen — das sagt etwas über die fremde Mod und die Spielfassung,
   nichts über uns; unsere Operationen, die allein nichts treffen (das ist Sache von
   `kette-pruefen.ps1` und `sprachverweise-pruefen.ps1`); Dateien ohne Vanilla-Gegenstück.
6. **Bedingungen** werden mit der `NCalc.dll` des Spiels ausgewertet, mit denselben Optionen
   wie in `kette-pruefen.ps1`. `mod_loaded('X')` ist wahr, wenn `X` der `Name` aus der
   `ModInfo.xml` einer Mod ist, die in diesem Stand geladen ist — allein also nur die der
   eigenen Seite. `xpath('…')` läuft gegen die Zieldatei **im Stand vor dieser Operation**
   (Finding WP1 §4) und liefert, was das Spiel liefert. Es gewinnt das erste `<if>`, dessen
   Bedingung wahr ist, sonst `<else>`; die Kinder des Zweigs laufen wie die oberste Ebene.
7. **Nichts gerechnet ist nicht grün.** Ausgang 2: kein Vanilla-Ordner; kein fremder Ordner
   oder einer ohne `ModInfo.xml`; eine Seite ohne eine einzige XML-Patch-Datei mit
   Vanilla-Gegenstück; eine Datei, die sich nicht als XML lesen lässt; ein bedingter Block
   ohne `NCalc.dll`; `patch-operationen.ps1` fehlt. Gibt es beides, aber **keine gemeinsame
   Datei**, ist das ein Ergebnis und kein Ausfall: Ausgang 0, mit einer Zeile, die es sagt.
8. **Fremde Dateien sind Daten.** XML wird ohne DTD und ohne Auflösen fremder Verweise
   gelesen; eine Datei mit `<!DOCTYPE` gilt als nicht lesbar. Ausgeführt wird aus dem
   fremden Ordner nichts, geladen keine DLL. Nichts aus ihm wird ins Repository geschrieben.

Der Aufbau eines XML-Knotens wird über Methoden gelesen (Nachtrag viertes Review zu WP8.7).
Namen und Werte werden Zeichen für Zeichen verglichen.

### Grenzen

- **Nur XML.** Was eine DLL der fremden Mod zur Laufzeit an Fenstern ändert, sieht keine
  XML-Prüfung. Für E C H O (zwei DLLs) ist das die größere Hälfte.
- **Nur dieselbe Datei.** Ein Fenster, das auf einen Stil, eine Vorlage oder ein
  Steuerelement in einer **anderen** Datei zeigt, die die fremde Mod ändert, bleibt
  ungesehen. Ebenso, ob zwei Fenster einander auf dem Bildschirm verdecken.
- **Kein zweiter Patcher des Spiels.** Es gelten die Grenzen von `patch-operationen.ps1`
  (Nachtrag Review zu WP8.8): die Operationen sind nachgebaut, nicht im Spiel gemessen; das
  Spiel rechnet über `XDocument`, dieses Skript über `XmlDocument`.
- **Entfernen wird nicht verfolgt.** Was `remove` oder `removeattribute` weggenommen hat und
  die zweite Seite wieder einfügt, ist kein Befund.
- **Werte werden als Text verglichen.** `255,0,0` und `255, 0, 0` sind verschieden.
- **`mod_loaded` vergleicht mit dem `Name` aus `ModInfo.xml`, genau.** Ob das Spiel diesen
  Namen meint und ob Groß/Klein zählt, ist nicht gelesen (Finding WP1 §4).
- **Die erwartete Reihenfolge ist abgeleitet, nicht gesehen.** Darum laufen beide.
- **„Allein ohne Treffer" bei der fremden Mod ist kein Urteil über sie.** Es kann ein
  Fehler der fremden Mod sein, eine andere Spielfassung — oder eine Stelle, die dieses
  Skript anders rechnet als das Spiel.
- **Geprüft ist das Paar, nicht die Matrix.** Zwei fremde Mods zugleich rechnet niemand.

Vier weitere Grenzen hat erst der Bau gezeigt (alle am echten Stand der zwei Referenz-Mods
aufgefallen, keine ändert eine Regel):

- **Operationsnamen werden Zeichen für Zeichen verglichen.** AGF schreibt in `items.xml`
  `<insertafter>` klein; das ist hier eine unbekannte Operation und damit „nicht gerechnet".
  Ob das Spiel die Schreibweise annimmt, ist **nicht gelesen** — der Blick auf `XmlPatcher`
  überstieg am 22. November 2026 die Darstellung des REA-Werkzeugs und blieb ohne Antwort.
- **`game_version()` und `version()` rechnet diese Prüfung nicht** (Regel 4, „eine andere
  Funktion als `mod_loaded` und `xpath`"). Der ganze bedingte Block entfällt dann in diesem
  Stand, und alles Weitere läuft auf einem Stand **ohne** ihn. Steht `mod_loaded(…)` davor
  und ist falsch, wertet NCalc den Rest nicht aus — dann ist der Block gerechnet.
- **Ein `<conditional>` in eingefügtem Inhalt ist ein gewöhnliches Element.** AGF hängt
  Fenster an, in denen `<conditional evaluator="client">` steht. Ausgewertet werden hier nur
  bedingte Blöcke auf der Ebene der Operationen (Finding WP1 §4); was das Spiel mit denen im
  Inhalt beim Laden der Datei tut, sieht diese Prüfung nicht.
- **`xpath('…')` mit mehreren Treffern** liefert, was `kette-pruefen.ps1` dafür liefert
  („More than one match"). Eine eigene Gegenprobe dafür gibt es hier nicht.

### Gegenproben (Projektregel 5)

Gemessen am 2026-11-22, am Stand, der committet wird. Alle Namen in
`tools/check/testdaten/vertraeglich/` sind erfunden (58 Dateien: ein Vanilla-Satz mit drei
Dateien, vier Sätze eigener Prüf-Modlets mit zusammen fünf Modlets, 19 fremde Prüf-Mods).

**31 neue Läufe in `gegenproben.ps1`, Abschnitt „vertraeglichkeit-pruefen.ps1 (WP8.9)".**
Befehl: `powershell -NoProfile -ExecutionPolicy Bypass -File tools/check/gegenproben.ps1` —
**209 Gegenproben, 0 fehlgeschlagen** (vorher 178).

| Was der Lauf zeigt | Läufe | Ausgang |
|---|---|---|
| dieselben Dateien, andere Knoten; keine gemeinsame Datei; „allein ohne Treffer" und „ohne Gegenstück" genannt, kein Befund; ohne Parameter aus `mod\` und `GameRefs\ui-mods\` | 4 | 0 |
| Ziel verloren, in beiden Richtungen (wir nehmen es der fremden Mod, sie nimmt es uns) | 2 | 1 |
| Wirkung verändert: derselbe Wert; ein breiter Pfad, der unser eingefügtes Element mittrifft; jede verfolgte Schreibart einmal (11 Befunde in einem Lauf) | 2 | 1 |
| Zweig wechselt: `mod_loaded` und `xpath()` fallen in der Kombination anders aus; das erste wahre `<if>` gewinnt, sonst `<else>` | 1 | 1 |
| zehn Stellen „nicht gerechnet" in einer Datei | 1 | 1 |
| gemeinsamer Sprachschlüssel (Kopfzeile `KEY` groß geschrieben); fremde Sprachdatei ohne Schlüsselspalte | 2 | 1 |
| Reihenfolge: Ordner sortiert vor unseren; zwischen unseren; Zeichen- und Sprachvergleich uneins | 3 | 1 |
| zwei fremde Mods in einem Aufruf, jede für sich, schlechtester Ausgang | 1 | 1 |
| nicht prüfbar: ohne `ModInfo.xml`, ohne Namen, nur Dateien ohne Gegenstück, kein XML, `<!DOCTYPE`, keine einzige Operation, fremder Ordner fehlt, unsere Seite ohne Datei, Vanilla fehlt, kein Spielpfad, `NCalc.dll` fehlt (angegeben und über den Spielpfad), ohne `GameRefs\ui-mods\`, `patch-operationen.ps1` fehlt (für beide Skripte je ein Lauf) | 15 | 2 |

**38 Verfälschungen, jede macht mindestens eine Gegenprobe rot.** 34 am Skript, vier an
`patch-operationen.ps1`. Gefahren mit einem Teil-Läufer, der nur die Hilfsfunktionen von
`gegenproben.ps1` und diesen Abschnitt enthält (31 Läufe, unverändert 0 rot); nach jedem
Lauf wurde die Datei zurückkopiert, am Ende sind beide byte-gleich mit dem Stand davor.
Verfälscht wurde je eine Stelle:

- *die Befundklassen:* „Ziel verloren" aus (3 rot); „Zweig wechselt" aus (1); der Wächter
  für „Wirkung verändert" aus (9); die Spur für eingefügte Elemente (3), für Attribute (1),
  für Text (1), für `setattribute` (9) aus; der Wert wird nicht verglichen (6); die Regel
  „die letzte Schreibende gilt" aus (1); selbst Entferntes zählt (1); „hängt noch am
  Dokument" immer wahr (3); der Vergleich in der umgekehrten Reihenfolge fehlt (3);
- *Bedingungen:* `mod_loaded` immer falsch (2); geladen ist nur die fremde Mod (1); der
  Stand für `xpath()` veraltet (1); `<else>` gewinnt nie (1); nicht das erste wahre `<if>`
  gewinnt (2);
- *„nicht gerechnet":* die Meldung bleibt still (1); `Get-Hindernis` wird nicht gefragt (1);
- *Lesen:* DTD erlaubt (1); Name, Knotenart und Kinder über Eigenschaften statt Methoden
  (4, 2, 4) — dafür trägt die saubere Prüf-Mod Attribute namens `LocalName`, `NodeType`
  und `ChildNodes`;
- *Sprache und Reihenfolge:* Sprachvergleich aus (1); Schlüsselspalte nur in genauer
  Schreibweise (1); Sprachdatei ohne Schlüsselspalte gilt als leer (1); nur der
  Zeichenvergleich entscheidet die Reihenfolge (1);
- *Ausfälle und Ausgang:* jede Datei hat angeblich ein Vanilla-Gegenstück (3); die Zeile
  „ohne Gegenstück" fehlt (1); eine Mod ohne Operation ist grün (1); die fehlende
  `patch-operationen.ps1` wird nicht geprüft (1); der Abbruchgrund geht verloren (2);
  Ausgang 0 statt 1 (12); nur die letzte fremde Mod zählt (1);
- *`patch-operationen.ps1`:* `append`, `prepend`, `insertBefore`, `insertAfter` melden
  nicht, was sie einfügen (2, 1, 1, 1).

**Am echten Stand, an `sprachverweise-pruefen.ps1`:** nach dem Auslagern der Operationen
unverändert 729 Operationen angewandt, 0 ohne Treffer, Ausgang 0.

**Was der Bau geändert hat, das oben nicht steht.** Ein Abbruch (Regel 7) schreibt seine
Meldung nicht mehr an der Stelle, an der er entsteht: er wirft, und die eine Fangstelle des
Skripts schreibt den Grund und endet mit Ausgang 2. Vorher ging die Meldung verloren, wenn
der Abbruch in einer Funktion entstand, deren Ausgabe gesammelt wird (der Lauf „ohne
`GameRefs\ui-mods\`" hatte Ausgang 2 und keinen Text).

### Lauf gegen die zwei Referenz-Mods, 2026-11-22

Befehl: `powershell -NoProfile -ExecutionPolicy Bypass -File
tools/check/vertraeglichkeit-pruefen.ps1` (ohne Parameter, 10 Sekunden). **Ausgang 1,
11 Befunde** — unsere 8 Modlets gegen jede der beiden. Vanilla ist V 3.40.

| | AGF-1HUDPlus 6.6.2 | EchoHybridUI 1.6 |
|---|---|---|
| XML-Dateien unter `Config\` (mit / ohne Vanilla-Gegenstück) | 5 (5 / 0) | 19 (14 / 5) |
| gemeinsame Dateien | 4 | 8 |
| erwartete Reihenfolge | wir, dann sie | wir, dann sie |
| ihre Operationen allein (davon ohne Treffer) | 84 (0) | 703 (7) |
| unsere Operationen in den gemeinsamen Dateien (ohne Treffer) | 556 (0) | 621 (0) |
| Sprachschlüssel: unsere / ihre / gemeinsam | 887 / 147 / 0 | 887 / 48 / 1 |
| Ziel verloren | 0 | 0 |
| Zweig wechselt | 0 | 0 |
| Wirkung verändert | 0 | 6 |
| nicht gerechnet | 3 | 1 |
| gemeinsamer Sprachschlüssel | 0 | 1 |

Was die Zeilen im Einzelnen sagen, steht im Plan unter WP8.9. Die Ausgabe selbst liegt
nicht im Repository: sie nennt Pfade und Werte aus fremden Dateien.

## Nachtrag Review zu WP8.9, 2026-11-22 — drei Befunde an `vertraeglichkeit-pruefen.ps1`, **abgenommen 2026-11-22**

### Anlass

Das Review von Commit `7fe07c7` fand drei Stellen, an denen das Skript dem „Nachtrag WP8.9"
nicht folgte oder ihn zu eng las. Keine betrifft die Mod. Dieser Nachtrag stellt die drei
Regeln klar; der „Nachtrag WP8.9" bleibt stehen, wie er ist.

### Die Regeln

1. **Zu Regel 7 — die `NCalc.dll` wird für JEDEN bedingten Block gebraucht.** Sobald eine
   gerechnete Datei auf der Ebene der Operationen ein `<conditional>` hat, muss die
   Bibliothek des Spiels geladen sein, **bevor** der Block angesehen wird — auch wenn er nur
   ein `<else>` hat, auch wenn er falsch gebaut ist. Fehlt sie, ist das Ausgang 2.
   *Vorher* lud das Skript sie erst beim Auswerten eines `<if cond=…>`: ein Block nur mit
   `<else>` lief ohne Bibliothek durch (Ausgang 0), ein `<if>` ohne `cond` war „nicht
   gerechnet" (Ausgang 1). Beides sagte etwas über einen Stand, den das Skript ohne die
   Bibliothek nicht rechnen darf.
2. **Zu Regel 6 — `mod_loaded` und `xpath` bekommen genau ein Argument.** So verlangt es
   das Spiel (Nachtrag drittes Review zu WP8.7; `kette-pruefen.ps1` führt dieselben Zahlen).
   Jede andere Zahl — keines, zwei, mehr — macht die Bedingung „nicht gerechnet"; die
   Meldung nennt die Funktion und die Zahl. *Vorher* las das Skript nur das erste Argument:
   `not mod_loaded('X', 'zuviel')` galt als wahr, obwohl das Spiel die Bedingung ablehnt.
   **Grenze, unverändert wie bei `kette-pruefen.ps1`:** die Art der Argumente wird nicht
   geprüft.
3. **Zu Regel 4 — „nicht gerechnet" ist eine Zeile je Stelle.** Eine Stelle ist: die Mod,
   die Datei, die Position der Operation in ihr und der Text der Meldung. Dieselbe Stelle
   in mehreren der vier Stände wird einmal gemeldet, mit den Ständen dahinter. *Vorher*
   fehlte die Datei: begannen zwei Dateien einer Mod mit derselben nicht gerechneten
   Operation, blieb eine Zeile, und die zweite Stelle fehlte im Bericht und in der Zahl.

**Grenze zu Regel 2, wie schon bei `game_version()`:** geprüft wird die Zahl der Argumente
dort, wo NCalc die Funktion aufruft. Einen Aufruf, den NCalc nicht auswertet, weil der Teil
davor das Ergebnis schon festlegt (`mod_loaded('X') and mod_loaded('Y', 'zuviel')` mit
falschem ersten Teil), sieht diese Prüfung nicht.

### Gegenproben (Projektregel 5)

Gemessen am 2026-11-22, am Stand, der committet wird. Vier neue erfundene Prüf-Mods unter
`tools/check/testdaten/vertraeglich/` (`fremd-nur-else`, `fremd-if-ohne-cond`,
`fremd-argumente`, `fremd-zwei-dateien`; 9 Dateien).

**Fünf neue Läufe in `gegenproben.ps1`** (Abschnitt „vertraeglichkeit-pruefen.ps1 (WP8.9)",
Teil o2) — **214 Gegenproben, 0 fehlgeschlagen** (vorher 209):

| Regel | Was der Lauf zeigt | Ausgang |
|---|---|---|
| 1 | Block nur mit `<else>`, die angegebene `NCalc.dll` fehlt | 2 |
| 1 | `<if>` ohne `cond`, die angegebene `NCalc.dll` fehlt | 2 |
| 1 | derselbe Block nur mit `<else>`, mit der Bibliothek: der Zweig läuft, 0 Befunde | 0 |
| 2 | `mod_loaded` mit zwei und mit keinem Argument, `xpath` mit zwei: drei Zeilen „nicht gerechnet", kein Zweig läuft, die Operation danach trifft ihr Fenster noch | 1 |
| 3 | dieselbe unbekannte Operation am Anfang von `styles.xml` und `windows.xml`: zwei Zeilen, jede nennt ihre Datei | 1 |

In den drei Läufen zu Regel 1 und im Lauf zu Regel 2 ist unsere Seite nur das Prüf-Modlet
ohne bedingten Block — mit dem zweiten lüden unsere eigenen Bedingungen die Bibliothek,
und die Läufe zu Regel 1 wären auch ohne die Änderung rot.

**Vier neue Verfälschungen, jede nimmt eine der Änderungen zurück, jede macht mindestens
eine Gegenprobe rot:** die Bibliothek wird erst beim Auswerten eines `<if>` geladen (2 rot);
die Argumentzahl von `mod_loaded` wird nicht geprüft (1); die von `xpath` nicht (1); die
Stelle zählt ohne Datei (1). Zusammen mit den 38 aus dem „Nachtrag WP8.9" sind es **42**;
alle 42 sind am neuen Stand wiederholt (Teil-Läufer mit 36 Läufen, unverändert 0 rot),
jede macht mindestens eine Gegenprobe rot, und Skript und gemeinsame Datei sind danach
byte-gleich mit dem Stand davor.

**Der Lauf gegen die zwei Referenz-Mods ist unverändert:** derselbe Befehl, Ausgang 1,
11 Befunde, die Ausgabe Zeile für Zeile gleich mit der vor der Änderung. Die Tabelle im
„Nachtrag WP8.9" gilt weiter; insbesondere hat Regel 3 dort keine verschluckte Stelle
aufgedeckt.

## Nachtrag Dump-Suche, 2026-11-22 — `check-all.ps1` kennt `-UserDataFolder`, **Abnahme offen**

Gebaut auf ausdrücklichen Auftrag des Nutzers vom 2026-11-22 („Ja, bau sie"), nach der
Block-Abnahme desselben Tages; dieser Nachtrag selbst ist noch nicht abgenommen.

**Der Fehler.** §1 nennt als Ort des Dumps `%APPDATA%\7DaysToDie\Saves\…\ConfigsDump`. Das
stimmt nur für die Vorgabe des Spiels: mit `-UserDataFolder=<Ordner>` liegen Spielstände unter
`<Ordner>\Saves`. Auf diesem Rechner gibt das Startprogramm des Spiels den Schalter bei jedem
Start mit. `check-all.ps1` las deshalb am 2026-11-22 nach einem Start mit dem neuen Stand
weiter den Dump vom Vortag — 80 Sackgassen, obwohl der neue Dump 0 hatte.

**Die Regel.** Ohne `-Source` sucht `check-all.ps1` an bis zu drei Orten, und über alle Orte
gewinnt der **jüngste** Dump (Änderungszeit des Ordners `ConfigsDump`):

| # | Ort | Woher |
|---|---|---|
| 1 | `%APPDATA%\7DaysToDie\Saves` | Vorgabe des Spiels, wie bisher |
| 2 | `<Ordner>\Saves` | `<Ordner>` aus `%APPDATA%\7DaysToDie\launchersettings.json`, Feld `DefaultRunConfig.AdditionalParameters`, Schalter `-UserDataFolder=` (mit oder ohne Anführungszeichen, Groß-/Kleinschreibung egal) |
| 3 | `%SDTD_USERDATA%\Saves` | Umgebungsvariable, falls gesetzt — für Starts am Startprogramm vorbei |

Die Ausgabe nennt die Suchorte in einer Zeile `Gesucht unter:` vor der Zeile `Quelle:`. Eine
unlesbare `launchersettings.json` und ein ungültiges `SDTD_USERDATA` sind je ein Hinweis, kein
Abbruch; der Ort wird übergangen. `-Source` geht allem vor, wie bisher. Kein Pfad ist im
Skript fest eingetragen.

**Grenzen.** (1) „Der jüngste Dump" ist der des letzten Spielstarts, **auch wenn der ohne die
Mod lief** — dann wird Vanilla geprüft und `anachronisms` ist rot. Das galt schon vorher; die
Zeile `Quelle:` zu lesen bleibt Pflicht. (2) Ein `-UserDataFolder`, der nur auf einer
Befehlszeile stand und in keiner der drei Quellen, wird nicht gefunden. (3) Gelesen wird nur
`DefaultRunConfig`; andere Abschnitte der Datei nicht.

**Gegenproben** (218 statt 214, alle in einem nachgebauten Baum unter dem Temp-Ordner, mit
kaputtem Spielpfad — „4 rot" heißt Dump gefunden, „5 rot" heißt keiner):

| Lauf | Erwartet |
|---|---|
| Dump nur unter dem Ordner aus `launchersettings.json` | `Quelle:` nennt ihn, 4 rot |
| zwei Dumps, der unter `%APPDATA%` ist jünger | `Quelle:` nennt den jüngeren, nicht den des Startprogramms |
| `launchersettings.json` ist kaputtes JSON | Hinweis, `Quelle: KEINE`, Ergebniszeile mit 5 rot |
| kein Startprogramm, `SDTD_USERDATA` gesetzt | `Quelle:` nennt den Dump dort, 4 rot |

**Drei Verfälschungen, jede macht ihre Gegenprobe rot:** der Schalter wird in der Datei nicht
erkannt (Lauf 1 rot); `SDTD_USERDATA` wird nicht gelesen (Lauf 4 rot); die Sortierung läuft
aufsteigend (Lauf 2 rot). Das Skript ist danach byte-gleich mit dem Stand davor.

**Am echten Rechner:** `check-all.ps1` ohne Zusatz nennt
`Gesucht unter: …\AppData\Roaming\7DaysToDie\Saves; C:\Users\Anwender\Saves`, liest den Dump
von 22:08 und endet mit 218 Gegenproben, 0 fehlgeschlagen; 7 Prüfungen, 0 rot, Exit 0.

## Nachtrag Leermeldung, 2026-11-22 — `=kein-aufschub` in `aufschub.txt`, **Abnahme offen**

Gebaut im Nachtlauf vom 2026-11-22 auf 23 ohne Rückfrage (Auftrag des Nutzers: „agiere nach
deinen Empfehlungen, aber markiere die Entscheidung als zu prüfen durch mich", D92). **Zu
prüfen durch den Nutzer; dieser Nachtrag ist nicht abgenommen.**

**Der Anlass.** Mit dem Reparatur-Kit ist der letzte Aufschub eingelöst (23 von 23 Zeigern
umgehängt). Eine `aufschub.txt` ohne Regel ist aber nach dem Abschnitt „Aufschub: eine
Umbuchung, kein Bestanden" ein Benutzungsfehler (Exit 2) — zu Recht, denn eine versehentlich
geleerte Datei darf nicht wie „nichts aufgeschoben" aussehen. Die Datei wegzulassen ginge
auch nicht: `check-all.ps1`, `purge-patch` und die Gegenproben reichen sie fest durch, und
mit ihr ginge die Geschichte der eingelösten Aufschübe verloren.

**Die Regel.** Eine Zeile `=kein-aufschub  # <Grund>` sagt ausdrücklich: nichts ist
aufgeschoben.

| Inhalt der Datei | Ergebnis |
|---|---|
| mindestens eine Regel, keine Leermeldung | wie bisher |
| nur die Leermeldung, mit Grund | gültig, 0 Aufschubregeln; jede verbotene Kennung ist ein Fehler |
| Leermeldung **ohne** Grund hinter `#` | Benutzungsfehler, Exit 2 |
| Leermeldung **und** eine Regel | Benutzungsfehler, Exit 2 („Widerspruch") |
| weder Regel noch Leermeldung | Benutzungsfehler, Exit 2, wie bisher |

Das Gleichheitszeichen kommt in keiner Kennung vor; die Zeile ist mit keiner Regel zu
verwechseln. Wer wieder etwas aufschiebt, ersetzt die Leermeldung durch die neue Regel.

**Gegenproben** (222 statt 218; `tools/check/testdaten/aufschub-leer*.txt`,
`aufschub-leermeldung*.txt`):

| Lauf | Erwartet |
|---|---|
| nur Leermeldung, im Baum eine verbotene Kennung | Exit 1, `erreichbarer-anachronismus`, kein `aufgeschobener-anachronismus` |
| Datei nur mit Kommentar | Exit 2 |
| Leermeldung neben einer Regel | Exit 2 |
| Leermeldung ohne Grund | Exit 2 |

**Drei Verfälschungen, jede macht ihre Gegenprobe rot:** der Widerspruch wird nicht geprüft
(Lauf 3 rot, Exit 1 statt 2); der Grund wird nicht verlangt (Lauf 4 rot, Exit 1 statt 2); die
Leermeldung zählt nicht als Inhalt (Lauf 1 rot, dazu 30 weitere, weil die echte
`aufschub.txt` dann selbst abgelehnt wird). `Deferrals.cs` ist danach byte-gleich mit dem
Stand davor (SHA-256 verglichen), das Werkzeug neu gebaut und signiert.

**Stand der Prüfung, ehrlich:** `check-all.ps1` ohne Zusatz ist mit diesem Stand **rot**:
222 Gegenproben, 0 fehlgeschlagen; 7 Prüfungen, **1 rot** — `erreichbarer-anachronismus:
resourceRepairKit`. Das ist das Signal, das es geben muss: der Dump von 22:08 stammt aus
einem Spielstart **vor** der Sperre, dort gibt es das Kit noch, und der Aufschub, der es
bisher entschuldigte, ist weg. Am Vorlauf des neuen Standes
(`check-all.ps1 -Source <Vorlauf> -SkipGegenproben`): 7 Prüfungen, 0 rot; 543 Kennungen,
0 aufgeschoben, 0 verboten; 271 Rezepte, 0 Sackgassen; 626 gesperrte Kennungen, 0 davon noch
erreichbar. Ein Vorlauf ist kein Nachweis — grün wird der Prüfbefehl erst mit dem Dump des
nächsten Spielstarts mit diesem Stand (Plan-0001, Prüfliste).

## Nachtrag zweites Review der Vorprüfung, 2026-11-22 — zwei Befunde behoben, **Abnahme offen**

Die zwei Befunde, die der Statusblock oben als unbehoben nennt (Codex über
`014528c..467646d`), sind im Nachtlauf vom 2026-11-22 auf 23 behoben — ohne Rückfrage, nach
Claudes Empfehlung (D92). **Zu prüfen durch den Nutzer; dieser Nachtrag ist nicht
abgenommen.** Beide betreffen nur `vertraeglichkeit-pruefen.ps1`, nicht die Mod.

**Befund 1 — eine kaputte fremde Sprachdatei ging grün durch.** Liest `Import-Csv` keine
einzige Zeile, galt die Schlüsselmenge als leer („0 Schlüssel, 0 gemeinsam"). **Regel jetzt:**
ohne Datenzeile zählt die Datei nur dann als leer, wenn ihre erste Zeile die Spalte `Key`
nennt (Groß- und Kleinschreibung egal). Sonst ist sie nicht lesbar — bei der fremden Mod ein
Befund „nicht gerechnet", bei unserer eigenen Sprachdatei wie bisher ein Ausfall (Exit 2).

**Befund 2 — eine fremde Mod, die allein nichts tut, war „nicht prüfbar".** Stehen alle ihre
Operationen in einem bedingten Block, der nur mit uns zusammen läuft, lief allein keine; das
endete mit Exit 2 („keine einzige Patch-Operation"), und die in der Kombination gerechneten
Befunde gingen verloren. **Regel jetzt:** Operationen, die in einer gemeinsamen Datei erst in
der Kombination laufen, zählen mit. Die Ausgabe nennt es in einer eigenen Zeile („allein
läuft keine Operation der fremden Mod, in der Kombination laufen N").

**Grenze, bewusst gelassen:** fragt die fremde Mod in einer Datei nach uns, die wir **nicht**
anfassen, wird für diese Datei weiter keine Kombination gerechnet. Hat sie sonst keine
Operation, bleibt es bei Exit 2 — nicht geprüft, aber auch nicht grün.

**Gegenproben** (225 statt 222; `testdaten/vertraeglich/fremd-sprache-zeichen`,
`fremd-sprache-kopf`, `fremd-nur-mit-uns`):

| Lauf | Erwartet | Vor der Korrektur |
|---|---|---|
| fremde Sprachdatei besteht aus einem Anführungszeichen | Exit 1, „nicht gerechnet 1", kein `GREEN` | **Exit 0, grün** |
| fremde Sprachdatei nur mit Kopfzeile `Key,…` | Exit 0, „die der fremden Mod: 0" | Exit 0 (Gegenrichtung, darf nicht kippen) |
| alle Operationen in `<if cond="mod_loaded('700_10_Pruef')">` | Exit 1, „Zweig wechselt 2", die neue Zeile | **Exit 2, nicht geprüft** |

Die erste und die dritte Gegenprobe waren am unveränderten Skript rot (225 Gegenproben,
2 fehlgeschlagen) und sind nach der Korrektur grün (225, 0 fehlgeschlagen) — das ist der
Nachweis, dass sie den Fehler finden.

## Nachtrag Prüfungen der Phase 2, Teil 1 — *symbole* und *asset-register*, 2026-11-23, **Abnahme offen**

Geschrieben und gebaut im autonomen Lauf (Plan-0002 WP2.6 c/d, WP2.7), nach Claudes Empfehlung;
**zu prüfen durch den Nutzer** (N-71). Die Regeln, was ein Symbol ist und wie das Register
aussieht, stehen in [Vertrag 05](05-asset-pipeline.md); hier steht nur, was der Prüfbefehl damit
tut. Die übrigen Prüfungen der Phase 2 (*wesen*, *welt*, *textluecken*) folgen in Teil 2.

### Anlass

`CustomIcon` ist ein Name. Fehlt das Bild dazu, bleibt das Feld im Beutel leer — ohne Meldung im
Protokoll. Bis hierher hat das nur ein Blick in Vanillas Bilderordner geprüft. Mit dem ersten
eigenen Bild (`ico700_silberpfennig`) kommen zwei Fragen dazu: hat das Bild die Form, die das
Spiel erwartet, und steht es mit Quelle und Lizenz im Register?

### Die zwei Prüfungen

`check-all.ps1` zählt jetzt **neun** Prüfungen.

| Prüfung | Skript | Braucht | Ausgänge |
|---|---|---|---|
| *Symbole (genannte Bilder)* | `tools/check/symbole-pruefen.ps1 [-ModOrdner <Ordner>] [-VanillaBilder <Ordner>]` | `SDTD_PATH` (Vanillas `Data\ItemIcons`) | 0 grün · 1 Befund · 2 nicht prüfbar |
| *Asset-Register* | `tools/assets/symbole.ps1 -Pruefen [-Wurzel <Ordner>]` | nichts außerhalb des Repositorys | 0 grün · 1 Befund · 2 nicht ausführbar |

Ausgang 2 zählt in `check-all.ps1` als rot, wie bei jeder anderen Prüfung.

**Regeln von *symbole*:**

1. Jeder Wert von `CustomIcon` in unseren XML-Dateien nennt ein Bild, das es gibt: `<Name>.png` in
   Vanillas `Data\ItemIcons` **oder** unter `UIAtlases\ItemIconAtlas` eines unserer Modlets.
   Groß- und Kleinschreibung zählt; ein Name, der nur in anderer Schreibung vorkommt, ist ein
   eigener Befund mit der richtigen Schreibung.
2. Gelesen werden zwei Formen: `<property name="CustomIcon" value="…"/>` an jeder Stelle, und
   `<set xpath="…/property[@name='CustomIcon']/@value">Name</set>`.
3. Jedes eigene Bild ist ein PNG mit Alphakanal, 160×160.
4. Jedes eigene Bild heißt `ico700_<wort>` in Kleinbuchstaben und trägt nicht den Namen eines
   Vanilla-Bildes.
5. Kein Bildname kommt in zwei Modlets vor.
6. Unter `UIAtlases` liegt nichts außer PNG-Dateien in `ItemIconAtlas`.
7. Jedes eigene Bild wird von mindestens einem `CustomIcon` genannt.
8. Nichts gelesen ist nicht grün: ohne Vanillas Bilderordner, ohne ein PNG darin oder ohne ein
   einziges `CustomIcon` ist der Ausgang 2. Eine XML-Datei, die sich nicht lesen lässt, ebenso.

**Regeln von *asset-register*:**

1. Das Register `assets/ASSETS.md` hat eine Tabelle mit allen elf Spalten aus Vertrag 05 §5 und
   mindestens einer Zeile; sonst Ausgang 2.
2. Kein Pflichtfeld ist leer. Ein Strich ist nur in `Beleg`, `Beschreibung` und `Kosten` erlaubt
   und nur bei `eigen:blender` und `eigen:hand`.
3. `Art`, `Quelle` und `Stand` tragen einen der Werte aus Vertrag 05; kein Name steht zweimal.
4. Zu jeder Zeile der Art `symbol` gibt es das Quellbild und das fertige Bild, und das fertige
   Bild ist das, was aus dem Quellbild entsteht (sichtbarer Unterschied 0).
5. Unter `mod/*/UIAtlases` liegt keine Datei ohne Zeile.
6. Eine Zeile, die ein Modlet nennt, das es nicht gibt, ist Ausgang 2.

### Grenzen

- *symbole* liest **nicht**, ob das Spiel das Bild wirklich lädt — das ist gelesen (Finding F-16)
  und im Spiel nicht gesehen (S-09).
- Ein Gegenstand **ohne** `CustomIcon` zeigt das Bild seines eigenen Namens; ob es das gibt, prüft
  diese Fassung nicht.
- `CustomIcon` in einer Form, die keine der zwei gelesenen ist (etwa `setattribute`), wird nicht
  gesehen. In unseren Dateien kommt keine vor (28 genannte Bilder am 2026-11-23, alle gelesen).
- Der Vergleich „fertiges Bild gleich Quellbild" rechnet mit `System.Drawing` dieses Rechners.
  Auf einem anderen Windows kann die Verkleinerung um einzelne Stufen abweichen; dann wäre die
  Regel 4 dort rot, obwohl nichts falsch ist. Bis ein zweiter Rechner prüft, ist das ungemessen.

### Gegenproben (Projektregel 5)

27 neue Gegenproben in `gegenproben.ps1` (Abschnitt „Symbole und Asset-Register"); die Prüfbilder
werden dort gezeichnet (eine Ellipse) und liegen nicht im Repository. Vier laufen gegen den
sauberen Baum und müssen grün sein, 23 je gegen einen falschen Eingang:

| Falscher Eingang | Erwartung |
|---|---|
| fertiges Bild stammt aus einem anderen Quellbild | Exit 1, „entspricht nicht seinem Quellbild" |
| Bild im Modlet ohne Registerzeile | Exit 1, „Datei ohne Registerzeile" |
| fertiges Bild fehlt | Exit 1 |
| leeres Pflichtfeld; Strich bei Meshy-Quelle; Art, Quelle, Stand unbekannt | Exit 1, fünf Befunde einzeln |
| derselbe Name in zwei Zeilen; Symbol ohne `ico700_` | Exit 1 |
| Quellbild fehlt; ohne Alpha; kleiner als 160×160; Inhalt kleiner als 148; keine Bilddatei | Exit 1, je eigener Wortlaut |
| Register fehlt; ohne Zeile; ohne die Spalte `Lizenz`; Modlet unbekannt | Exit 2 |
| genanntes Bild fehlt (als `property` und als `set`); falsche Schreibung; leerer Wert | Exit 1, vier Befunde |
| eigenes Bild 128×128 ohne Alpha | Exit 1, zwei Befunde |
| zwei Modlets mit demselben Bildnamen | Exit 1 |
| Bild mit Vanilla-Namen; ungenutztes Bild; fremder Atlas-Ordner | Exit 1 |
| Vanillas Bilderordner fehlt; kein Spielpfad; kein `CustomIcon`; kaputtes XML | Exit 2 |

Lauf vom 2026-11-23: `powershell -File tools/check/check-all.ps1` — **252 Gegenproben, 0
fehlgeschlagen; 9 Prüfungen, 1 rot** (rot bleibt `resourceRepairKit` am Dump vom 22.11., N-01).
*Symbole*: 5261 Vanilla-Bilder, 1 eigenes, 28 genannte Bilder (27 aus Vanilla, 1 aus dem Modlet),
0 Befunde. *Asset-Register*: 1 Zeile, 1 Symbol, 0 Befunde.

Beim Bau gefunden, weil der zweite Lauf des Werkzeugs das Bild noch einmal schrieb: eine Kopie
über „Zeichnen" verändert fast durchsichtige Bildpunkte (Unterschied 124 bei einem Bild gegen
sich selbst). Bilder werden darum als Bytes gelesen, und verglichen wird, was man sieht
(Deckkraft und Farbe mal Deckkraft).

---

## Nachtrag Auftragsregeln, 2026-11-23 — `auftrag:` in `denylist.txt`, **Abnahme offen**

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP1.6, D103, D135). Abnahme: N-14 der
Entscheidungsliste.

### Anlass

Die Händler bieten „Strom wiederherstellen" an (`tier2_restore_power` bis `tier4_restore_power`,
in allen fünf Händlerlisten, 15 Einträge). `anachronisms` war dabei grün: ein Auftrag gibt
nichts in die Hand und steht in keinem der sechs Wege aus Abschnitt 3. Die Sperrliste konnte ihn
nicht nennen, der Erzeuger konnte ihn nicht entfernen.

### Die Regel

1. Eine Zeile `auftrag:<Muster>` in `denylist.txt` ist eine **Auftragsregel**. Das Muster folgt
   denselben Regeln wie alle anderen (`*`, Groß- und Kleinschreibung zählt, `#` beginnt den
   Kommentar).
2. Sie urteilt über die **Kennung eines Auftrags in einer Auftragsliste** — jedes
   `<quest id="…">` unmittelbar unter einer `<quest_list>` in `quests.xml` — und über nichts
   sonst. Auftragsregeln und Gegenstandsregeln mischen sich nicht: eine Auftragsregel fällt kein
   Urteil über einen Gegenstand, eine Gegenstandsregel keines über einen Auftrag. Aufträge
   stehen darum auch nicht unter `erreichbarkeitswege`, `unaufloesbar` oder `ungeprueft`.
3. Eine **Freigabe** (`!`) gibt es für Aufträge nicht. Was bleiben soll, bekommt keine Regel.
4. `auftrag:` ohne Muster ist ein Benutzungsfehler (Exit 2).
5. Auftragsregeln zählen nicht als Verbotsregel: eine Sperrliste, die nur Auftragsregeln führt,
   gilt weiter als leer (Exit 2).

### Was die Befehle damit tun

| Befehl | Verhalten |
|---|---|
| `anachronisms` | Neue Zähler `auftragsregeln`, `auftraege_in_listen`, `gesperrte_auftraege_in_listen`. Jeder Auftrag in einer Liste, auf den eine Auftragsregel passt, ist ein Fehler `gesperrter-auftrag` mit den Listen, in denen er steht. Eine Regel ohne Treffer ist hier **kein** Befund: bei einem Stand mit unseren Modlets ist das das Ziel. |
| `purge-patch` | Schreibt in `quests.xml` einen zweiten Teil: je gesperrtem Auftrag **eine** Zeile `<remove xpath="/quests/quest_list/quest[@id='…']" />` — ohne Prädikat an der Liste, der Auftrag fällt aus jeder. Die Definition `/quests/quest[@id='…']` bleibt stehen (Vertrag 03 §4); ein `remove` darauf zählt unter `remove_auf_definition` und ist rot. Der Teil entsteht nur, wenn die Sperrliste Auftragsregeln führt **und** die Quelle Auftragslisten hat; sonst ist die Datei Zeichen für Zeichen wie zuvor. |
| `purge-patch`, Nachprobe | `wege_uebrig_quests.xml [quest]` (je Teil) und `gesperrte_auftraege_noch_in_listen` (Gesamtprobe auf dem gepatchten Stand, mit derselben Lesart wie `anachronisms`); beide müssen 0 sein, sonst `weg-bleibt-offen` bzw. `auftrag-trotz-patch`. |
| `purge-patch`, Tippfehler | Eine Auftragsregel, auf die in einer Quelle **mit** Auftragslisten kein Auftrag passt, ist ein **Fehler** `auftragsregel-trifft-nichts` — nicht ein Hinweis wie bei den Gegenstandsregeln, weil `anachronisms` diesen Tippfehler nie sehen kann. Hat die Quelle keine Auftragslisten, steht das als Grenze im Bericht und ist nicht rot. |

`check-all.ps1` ändert sich nicht: beide Befehle bekommen `--denylist` schon heute.

### Grenzen

- Gesehen werden **nur die Auftragslisten**. Ein Auftrag, den ein Dialog unmittelbar vergibt
  (`dialogs.xml`, `quest_entry`), und der Startauftrag stehen nicht darin. In V 3.40 b10 vergibt
  ein Dialog so nur `test_restorepower` und die anderen Prüfaufträge der Entwickler; sie bleiben
  unberührt (auch die Liste `test_quests`, auf die das Muster `tier*_restore_power` nicht passt).
- Was der Auftrag im Gelände benutzt, bleibt stehen: der Block mit `QuestRestorePower`, die
  Marke `restore_power`, die zwei Klänge, die Ereignisfolge `quest_restorepower_generator`. Ohne
  Auftrag ruft sie niemand; **gelesen, nicht gemessen**.
- Ob ein Händler in einer Stufe weiter genug Aufträge hat, prüft diese Fassung nicht. Stufe 4
  behält drei Arten (Räumen, verseuchtes Räumen, Holen und Räumen) — so viele wie Stufe 5 in
  Vanilla.
- Ein **laufender** Stromauftrag in einem alten Spielstand: was das Spiel damit macht, wenn er
  nicht mehr in der Liste steht, ist ungelesen. Die Definition bleibt, also bricht er vermutlich
  nicht.

### Gegenproben (Projektregel 5)

Acht neue Gegenproben in `gegenproben.ps1` (Abschnitt „Auftragsregeln"), Prüfsätze
`testdaten/auftraege`, `auftraege-danach`, `auftraege-ohne-listen` und vier Prüflisten
`denylist-auftrag*.txt` (erfundene Kennungen):

| Eingang | Erwartung |
|---|---|
| gesperrter Auftrag in zwei Händlerlisten | Exit 1, `gesperrter-auftrag` je Auftrag, beide Listen genannt, der erlaubte Auftrag ungenannt |
| dieselbe Quelle, Sperrliste ohne Auftragsregel | Exit 0, `auftragsregeln 0` — rot macht die Regel, nicht die Daten |
| Stand nach dem Patch: Definitionen stehen, Listeneinträge fehlen | Exit 0 — die Definition ist kein Angebot |
| `purge-patch --zeigen` | Exit 0, zwei `remove`-Zeilen auf `quest_list/quest`, keine auf `/quests/quest[@id=`, der erlaubte Auftrag in keiner Zeile |
| `purge-patch --ohne-entfernen` | Exit 1, `weg-bleibt-offen: quests.xml [quest]` und `auftrag-trotz-patch` |
| falsch geschriebene Auftragsregel | Exit 1, `auftragsregel-trifft-nichts` |
| Quelle ohne Auftragslisten | Exit 0, „hat keine Auftragslisten" steht im Bericht |
| `auftrag:` ohne Muster | Exit 2 |

Lauf vom 2026-11-23: `powershell -File tools/check/check-all.ps1` — **278 Gegenproben, 0
fehlgeschlagen; 10 Prüfungen, 1 rot.** Rot ist weiter `anachronisms` am Dump vom 22.11., jetzt
mit **vier** Fehlern statt einem: `resourceRepairKit` (N-01) und die drei Stromaufträge, die in
jenem Spielstand noch in den Listen standen — die neue Regel sieht am alten Stand genau das, wofür
sie gebaut ist. Gegen Vanilla: 131 Aufträge in Listen, 3 gesperrt, 3 Patchzeilen, 15 Einträge
fallen. Vorlauf ohne Spiel (kein Nachweis): 2696 Operationen, 0 ohne Treffer; 116 Aufträge in
Listen, 0 gesperrt.

---

## Nachtrag Sprachschlüssel einer Spielvorlage, 2026-11-23 — `localized_name`, **Abnahme offen**

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP1.5, D136). Abnahme: N-13.

**Anlass.** Eine Sandbox-Vorlage (`<preset>` in `sandbox_overrides.xml`) nennt ihren Anzeigenamen
im Attribut `localized_name`. `sprachverweise-pruefen.ps1` sammelt Schlüssel aus Attributen, die
auf `_key` enden; dieses endet nicht so. Am echten Stand fiel es sofort auf: die Zeile
`700_vorlageName` stand als „wird nicht gelesen" da, während `700_vorlageDesc` (aus
`description_key`) grün war.

**Regel.** An einem Element `preset` ist `localized_name` ein genannter Schlüssel — **einer**, keine
Kommaliste; ein leerer Wert nennt nichts. Beleg, dass das Spiel ihn liest: Finding F-17,
Abschnitt 1 (`SandboxOptionPreset::get_DisplayName`), statisch gelesen. Es gelten dieselben Regeln
wie für jeden genannten Schlüssel (Regel 1: er hat eine Zeile; Regel 2: die Zeile gilt als gelesen).

**Grenze.** Die Regel hängt am Elementnamen `preset`, nicht an der Datei. Ein anderes Element
dieses Namens mit einem Attribut `localized_name`, das kein Schlüssel wäre, gäbe einen falschen
Befund; in Vanillas Dateien ist keines bekannt (nicht durchsucht).

**Gegenproben (Projektregel 5).** Zwei neue in `gegenproben.ps1`, Prüfsatz
`testdaten/sprache/vorlage`: Vorlage mit beiden Zeilen — Exit 0, „genannte Schluessel: 2", die
Namenszeile gilt als gelesen, die zweite Vorlage mit leerem Attribut nennt nichts; dieselbe Vorlage
ohne die Namenszeile — Exit 1, „Schluessel 'pruef700_vorlage' hat keine Zeile". Ohne die Regel wäre
die erste Probe rot (so wie der echte Stand es war).

Lauf vom 2026-11-23: `powershell -File tools/check/check-all.ps1` — **280 Gegenproben, 0
fehlgeschlagen; 10 Prüfungen, 1 rot** (weiter `anachronisms` am Dump vom 22.11., vier Fehler).
Sprachschlüssel: 76 genannte, 0 ohne Zeile. Eigene Kette: 774 XPaths, 0 ohne Treffer.

## Nachtrag Ziele der Herausforderungen, 2026-11-23 — `unerfuellbares-ziel` und `ziel:` in `aufschub.txt`, **Abnahme offen**

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP1.6, D104 Frage 2, D137, D138).
Abnahme: N-34 der Entscheidungsliste.

### Anlass

35 von 148 sichtbaren Herausforderungen verlangten etwas, das der Purge gesperrt hat („Sammle
zehn Rohre"), und `anachronisms` war dabei grün: ein Ziel gibt nichts in die Hand und steht in
keinem der sechs Wege aus Abschnitt 3. Gefunden hat es ein Skript außerhalb des Repositorys.
Nach dem Purge ist der Fall für eine Erreichbarkeitsprüfung sogar unsichtbar: der gesperrte
Gegenstand hat keinen Weg mehr und darum kein Urteil — die Aufgabe verlangt ihn weiter.

### Die Regel

1. `anachronisms` liest `challenges.xml` der Quelle. Fehlt die Datei, steht
   `herausforderungen: keine challenges.xml - Ziele nicht geprueft` im Bericht; das ist kein
   Fehler (die kleinen Prüfsätze haben keine).
2. An jedem `<objective>` einer `<challenge>` werden **Kennungen** gelesen, in Gruppen:
   ~~`item` (Kommaliste); `block` zusammen mit `alternate_item`;~~ `item` — eine Kommaliste
   nur bei `Craft`, `UseItem` und `CureDebuff`, bei jeder anderen Art das **ganze Attribut als
   ein Name**; `block` für sich; `needed_resource`; `held` nur, wenn `required_held="true"`.
   Der Zusatz `:VariantHelper` wird für das Urteil abgetrennt. *Berichtigt am 2026-11-23 nach
   Review 33, siehe „Berichtigung nach Review 33" unten.*
3. Jeder Wert hat einen **Zustand**:
   - *gesperrt* — eine Regel der Sperrliste oder eine Eigenschaftsregel trifft die Kennung.
     Gefragt wird die **Regel, nicht die Erreichbarkeit**; eine Freigabe schlägt wie überall,
     eine aufgeschobene Kennung gilt als lebend.
   - *ohne Rezept* — Ziel der Art `Craft`, und kein Rezept trägt den Namen.
   - *ohne Weg* — jede andere Art an `item`, `alternate_item`, `needed_resource`, `held`: keiner
     der sechs Wege führt zu der Kennung.
   - *nicht definiert* — ein Wert an `block`, den `blocks.xml` (und `items.xml`) nicht kennt.
     Ein Block braucht **keinen** Weg: er wird gesetzt, nicht erworben (Vanillas
     `wallTorchLightPlayer` hat keinen).
   - sonst *lebt* er.
4. Eine **Gruppe** ist tot, wenn kein Wert lebt — eine Liste ist ein Entweder-oder (für
   `CureDebuff` in Finding F-18 gelesen). Ein Ziel ist tot, wenn eine seiner Gruppen tot ist;
   eine Herausforderung ist **unerfüllbar**, wenn eines ihrer Ziele tot ist.
5. Eine unerfüllbare Herausforderung ist ein Fehler **`unerfuellbares-ziel`** mit Zielart,
   Attribut, Zeile und dem Zustand jedes Werts. Lebt in einer Liste ein Wert und andere nicht,
   ist das der Hinweis `ziel-nennt-gesperrtes`.
6. Zähler: `herausforderungen`, `ziele_mit_kennung`, `unerfuellbare_herausforderungen`,
   `davon_aufgeschoben`, `unerfuellbar_gesperrt` (nur Gesperrtes), `unerfuellbar_ohne_weg`
   (mindestens ein Wert ohne Weg, ohne Rezept oder nicht definiert),
   `ziele_mit_gesperrtem_listenwert`, `zielaufschubregeln`, `zielaufschub_ohne_treffer`.

### Der Zielaufschub

7. Eine Zeile `ziel:<Muster>  # WP…: Grund` in `aufschub.txt` schiebt eine **unerfüllbare
   Herausforderung** auf (Muster über die Kennung der Herausforderung, `*` wie überall). Aus dem
   Fehler wird der Hinweis `aufgeschobenes-ziel`, gezählt unter `davon_aufgeschoben`. Wie jeder
   Aufschub: eine Umbuchung mit Adresse, kein Bestanden; ohne Arbeitspaket Exit 2.
8. Zielaufschübe und Aufschübe für Gegenstände sind **getrennte Regelsätze**: derselbe Name
   ohne Vorsatz schiebt keine Herausforderung auf, und `ziel:` nie einen Gegenstand.
   `--ohne-aufschub` schaltet beide ab.
9. Ein Zielaufschub, der nichts aufgeschoben hat (die Herausforderung ist erfüllbar oder die
   Kennung falsch geschrieben), ist der Hinweis `zielaufschub-trifft-nichts`.
10. `ziel:` ohne Muster ist ein Benutzungsfehler (Exit 2). Die Leermeldung `=kein-aufschub`
    neben einem Zielaufschub ist derselbe Widerspruch wie neben einem Aufschub für einen
    Gegenstand (Exit 2). **Folge für `aufschub.txt`:** die Leermeldung vom 2026-11-22 ist den
    14 Zielaufschüben gewichen; sie kommt zurück, wenn auch die eingelöst sind.

`purge-patch` und `ungeprueft` lesen dieselbe Datei und beachten die `ziel:`-Zeilen nicht.
`check-all.ps1` ändert sich nicht.

### Verweise ins Leere (ergänzt am selben Tag, D139)

Seit `700_50_Fortschritt` Herausforderungen **entfernt**, kann ein Name zurückbleiben, den
niemand mehr trägt. Nach Finding F-18 §6 schlägt das Spiel diese Namen **ohne Vorprüfung** nach.

11. Fehler **`herausforderung-verweis-fehlt`**, je Stelle einer:
    - eine `<challenge group="X">`, und es gibt keine `<challenge_group name="X">`;
    - ein Ziel `ChallengeComplete challenge="X"` auf eine Herausforderung, die es nicht gibt —
      mit `is_group="true"` auf eine Gruppe, die es nicht gibt;
    - ein Name in `<action class="CompleteChallenge">` → `<property name="challenges" value="…">`
      in `gameevents.xml`, den keine Herausforderung trägt. Fehlt `gameevents.xml` in der
      Quelle, entfällt dieser Teil ohne Meldung.
12. Fehler **`gruppe-ohne-herausforderung`**: eine `<challenge_group>`, der keine
    Herausforderung mehr angehört. Sie gälte sofort als vollständig, ihre Zeile bliebe stehen,
    die Belohnung käme nie (F-18 §3).
13. Zähler: `herausforderungsgruppen`, `verweise_auf_fehlendes`, `gruppen_ohne_herausforderung`,
    `kleinste_gruppe` (die Mitgliederzahl der kleinsten Gruppe, die Mitglieder hat).
14. Für diese beiden Fehler gibt es **keinen Aufschub**: ein Verweis ins Leere ist kein Stand,
    den ein späteres Arbeitspaket einlöst, sondern ein möglicher Abbruch beim Laden.

An Vanilla: `herausforderungsgruppen 19`, `verweise_auf_fehlendes 0`,
`gruppen_ohne_herausforderung 0`, `kleinste_gruppe 7`. Nicht geprüft: `hidden_by` (nach F-18
abgesichert), `category` einer Gruppe, mehr als zehn in einer Gruppe.

### Berichtigung nach Review 33, 2026-11-23 — **Abnahme offen** (mit N-34)

Das Codex-Review der Commits `75091ed..d2596a1` fand drei Stellen, an denen die Regel anders
liest als das Spiel nach Finding F-18. Alle drei machten die Prüfung **grün, wo sie rot sein
müsste** (oder umgekehrt). Geändert, weil der Nachtrag noch nicht abgenommen ist; die Abnahme
unter N-34 umfasst diese Berichtigung.

15. **`alternate_item` entscheidet nichts.** Es ersetzt bei `BlockPlace` nur die
    Vorbedingungs-Anzeige; gezählt wird der genannte Block (F-18 §7.5). Bisher war es ein
    zweiter Wert der Block-Gruppe: ein fehlender Block mit lebender Fackel war nur ein Hinweis.
    Jetzt steht `block` allein. Lebt `alternate_item` nicht, ist das der Hinweis
    **`ziel-anzeige-nennt-totes`** (Zähler `anzeige_nennt_totes`): erfüllbar, aber das Fenster
    nennt etwas, das man nicht bekommt.
16. **Eine Liste nur, wo das Spiel teilt.** `Craft` (F-18 §7.4), `UseItem` und `CureDebuff`
    (§7.6) teilen `item` am Komma. `Harvest`, `Gather` und `Wear` lösen das ganze Attribut über
    `ItemClass::GetItem` in **eine** Typnummer auf (§7.2, §7.3, §7.7): `item="a,b"` ist dort ein
    Name, den es nicht gibt, und das Ziel ist tot. Für Arten, die F-18 nicht gelesen hat
    (`BlockUpgrade`), gilt dasselbe — ein Komma zählt erst als Liste, wenn ein Finding das
    Teilen zeigt. `block`, `needed_resource`, `held` und `alternate_item` werden nie geteilt.
17. **Groß- und Kleinschreibung zählt bei Namen nicht.** Herausforderungen und Gruppen liegen
    im Spiel in einem `CaseInsensitiveStringDictionary` (F-18 §1). Regel 11 und 12 vergleichen
    seither ohne Schreibung: `group="BASICS"` trifft `Basics`, und die Gruppe ist nicht leer.
    Die Schreibung der **Zielart** (`type`) bleibt wie in Vanilla verlangt — wie das Spiel sie
    vergleicht, ist nicht gelesen.

**Kalibrierung danach** (mit der Sperrliste vom 2026-11-23, ohne Aufschub, alte gegen neue
Fassung): am unveränderten `Data/Config` beide `unerfuellbare_herausforderungen 24`,
`unerfuellbar_ohne_weg 0`, `ziele_mit_gesperrtem_listenwert 6`; am Dump vom 22.11., 22:08,
beide 35 (24 gesperrt, 11 ohne Weg), dieselben 35 Namen. Vanilla hat keine Liste außerhalb von
`CureDebuff`, nur ein `alternate_item` (die Fackel) — an echten Daten ändert sich nichts. Die
35 aus der Kalibrierung oben gehörten zur Sperrliste jenes Tages.

**Gegenproben** (Projektregel 5): Z12 (`testdaten/ziele-listen`) und Z13
(`testdaten/ziele-schreibung`) in `gegenproben.ps1`. Gegen die alte Fassung (`ec9140d`) war
Z12 **grün** (Exit 0, drei Hinweise statt drei Fehlern, `zielGatherListe` gar nicht genannt)
und Z13 **rot** (drei fehlende Verweise, eine leere Gruppe); mit der neuen ist es umgekehrt.

### Kalibrierung

Gegen das unveränderte `Data/Config` von V 3.40 b10 mit der heutigen Sperrliste:
`herausforderungen 175`, `unerfuellbare_herausforderungen 35`, `unerfuellbar_gesperrt 35`,
`unerfuellbar_ohne_weg 0`, `ziele_mit_gesperrtem_listenwert 6`. Die 35 und die 6 sind die Zahlen
des Skripts (D80, D137), unabhängig gerechnet; das zweite Signal schweigt an Vanilla. Ein
Prüfer, der schon am unveränderten Spiel rot meldet, taugte nicht als Signal — in der ersten
Messung waren es fünf Ziele mit drei Kennungen (`frameShapes`, `woodShapes`,
`wallTorchLightPlayer`), daher die Regeln zu `:VariantHelper` und zu Blöcken.

### Grenzen

- Gelesen werden nur Kennungen von Gegenständen und Blöcken. Ob es die verlangten **Wesen,
  Biome, Händler, Aufträge, Zustände** noch gibt (`Kill`, `EnterBiome`, `MeetTrader`,
  `QuestComplete`, `debuff`), sieht die Prüfung nicht; `item_tags` an `UseItem` auch nicht.
- Sie weiß nicht, ob das Spiel ein Ziel **zählt**: `Harvest` zählt nur beim Zuschlagen und mit
  `block_tag` nur an Blöcken mit dem Tag, an Kadavern nur mit `is_block="false"`; `CureDebuff`
  und `UseItem` nur Gegenstände der Aktion „Essen" (alles Finding F-18). Ein Gegenstand, der
  nur im Loot liegt, gilt bei `Harvest` als „mit Weg".
- ~~**Verweise ohne Vorprüfung im Spiel** (F-18 §6) sind nicht abgedeckt.~~ *Seit D139
  abgedeckt, siehe „Verweise ins Leere".* Sie laufen wie alles in `anachronisms` gegen den
  **Dump**; am Repository allein (vor einem Spielstart) sieht sie nur der Vorlauf.
- Was ein **Spielereignis** ausgibt (`gameevents.xml`, Aktionen wie `AddItems`; 13 Stellen in
  V 3.40 b10), ist kein Weg in Abschnitt 3 — ungemessen, ob darunter Gesperrtes ist.
- Was aus Wesen fällt (`entityclasses.xml`, `<drop>`), ist weiter **kein Weg** in Abschnitt 3.
  Gemessen am 2026-11-23: sieben Kennungen, alle haben auch einen anderen Weg, keine ist
  gesperrt — heute kein Loch, aber eines, sobald ein Wesen etwas fallen lässt, das sonst
  nirgends liegt.
- Der Dump vom 22.11. kennt unsere `challenges.xml` nicht: dort sind die neun umgebogenen Ziele
  rot. Am Vorlauf des heutigen Standes ist keines rot.

### Gegenproben (Projektregel 5)

Elf neue Gegenproben in `gegenproben.ps1` (Abschnitt „Ziele der Herausforderungen"), Prüfsätze
`testdaten/ziele` (Stand nach dem Purge: das gesperrte Teil liegt auf keinem Weg),
`ziele-vor-purge`, `ziele-tippfehler`, zwei Prüflisten `denylist-ziele*.txt` und fünf
`aufschub-ziel*.txt` (erfundene Kennungen):

1. Gesperrtes Ziel und gesperrtes verlangtes Werkzeug sind rot; fünf erfüllbare (darunter
   Block ohne Weg, Sammelblock mit Zusatz, Werkzeug ohne `required_held`) bleiben ungenannt;
   die Liste mit lebendem Wert ist ein Hinweis.
2. Vor dem Purge fallen Gegenstand **und** Ziel auf.
3. Dieselbe Quelle ohne die Sperrregel: grün — rot macht die Regel, nicht die Daten.
4. Zielaufschub: zwei Hinweise statt zwei Fehler, Exit 0, die Zahl steht da.
5. `--ohne-aufschub`: wieder Fehler.
6. Zielaufschub ohne Treffer wird genannt.
7. Ein Aufschub ohne Vorsatz schiebt keine Herausforderung auf.
8. Tippfehler, `Craft` ohne Rezept, unbekannter Block: drei Fehler des zweiten Signals.
9. Quelle ohne `challenges.xml`: gesagt, nicht rot.
10. `ziel:` ohne Kennung: Exit 2.
11. Leermeldung neben Zielaufschub: Exit 2.
12. (D139) Prüfsatz `ziele-verweise`: Gruppe fehlt, `ChallengeComplete` auf fehlende
    Herausforderung und auf fehlende Gruppe, `CompleteChallenge` nennt eine fehlende, eine
    Gruppe ist leer — vier Verweise und eine leere Gruppe, Exit 1; die vorhandenen Verweise
    und eine fremde Aktion mit gleichnamiger Eigenschaft bleiben ungenannt. Der saubere
    Prüfsatz aus Nr. 1 zeigt für beide Zähler 0.

Lauf vom 2026-11-23: `powershell -File tools/check/check-all.ps1` — **291 Gegenproben, 0
fehlgeschlagen; 10 Prüfungen, 1 rot** (`anachronisms` am Dump vom 22.11., jetzt 13 Fehler: die
vier alten und die neun Ziele, die der Dump noch in Vanillas Fassung zeigt). Am Vorlauf:
`unerfuellbare_herausforderungen 26`, `davon_aufgeschoben 26`, 0 rot.

Lauf nach D139 (zehn Herausforderungen entfernt, zehn Zielaufschübe eingelöst, Verweisprüfung):
**292 Gegenproben, 0 fehlgeschlagen; 10 Prüfungen, 1 rot** — `anachronisms` am Dump vom 22.11.
mit 23 Fehlern (die vier alten und 19 Ziele: der Dump kennt weder die neun umgebogenen noch die
zehn entfernten). Am Vorlauf: `herausforderungen 165`, `unerfuellbare_herausforderungen 16`,
`davon_aufgeschoben 16`, `verweise_auf_fehlendes 0`, `kleinste_gruppe 4`, 0 rot.

## Nachtrag Prüfungen der Phase 2, Teil 2 — *wesen*, 2026-11-23, **Abnahme offen**

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP2.6 a, WP2.7). Abnahme: N-36 der
Entscheidungsliste. Die Prüfung ist **kein eigener Befehl**: sie läuft in `anachronisms`, wie die
Aufträge und die Ziele der Herausforderungen — eine Quelle, ein Bericht, ein Ausgang.

### Anlass

Ein Wesen ist kein Gegenstand. Welche Klassen im Gelände erscheinen, steht in
`entitygroups.xml` (Gruppen mit Einträgen `<e n="Klasse">`), und wer eine Gruppe ruft, in
`spawning.xml` (je Landschaft) und `gamestages.xml` (Spielstufen, Schläfer, Seuchennacht). Keiner
der sechs Wege aus Abschnitt 3 führt dorthin; `zombieNurse` und `zombieBusinessMan` stehen je in
sieben Landschaftsgruppen und werden in allen fünf Landschaften gerufen, während die Prüfung grün
ist. Und sobald `700_65_Wesen` Gruppen
ändert (Vertrag 03, Nachtrag Phase 2 C), kann ein Name ins Leere zeigen.

### Die Regel

1. Eine Zeile `wesen:<Muster>` in `denylist.txt` ist eine **Wesenregel** (Muster wie überall).
   Sie urteilt über den **Namen einer Klasse in einer Landschaftsgruppe** — einer Gruppe, die
   `spawning.xml` in einem `<spawn entitygroup="…">` nennt — und über nichts sonst. Gruppen, die
   nur die Spielstufen rufen (Schläfer, Horden, Seuchennacht), bleiben unberührt: dort dürfen die
   Rollenträger stehen (P2-E12).
2. Jede Klasse in einer Landschaftsgruppe, auf die eine Wesenregel passt, ist ein Fehler
   **`gesperrtes-wesen`**, mit den Gruppen, in denen sie steht, und den Landschaften, die sie rufen.
3. Wesenregeln sind ein **eigener Regelsatz** wie die Auftragsregeln: keine Freigabe mit `!`,
   kein Urteil über Gegenstände, und sie zählen nicht als Verbotsregel. `wesen:` ohne Muster ist
   ein Benutzungsfehler (Exit 2).
4. Unabhängig von den Regeln prüft der Befehl die **Verweise** — Fehler **`wesen-verweis-fehlt`**:
   - ein Eintrag `<e n="X">`, und `entityclasses.xml` kennt keine Klasse `X` (der Sonderwert
     `none` ist Vanillas Zeichen für „hier erscheint nichts" und kein Verweis);
   - ein `<spawn entitygroup="G">` in `spawning.xml` oder ein `<spawn group="G">` in
     `gamestages.xml`, und es gibt keine Gruppe `G`.
5. Fehler **`wesengruppe-leer`**: eine Gruppe ohne Eintrag, die `spawning.xml` oder
   `gamestages.xml` ruft. Eine leere Gruppe, die niemand ruft, ist ein Hinweis gleichen Namens.
6. Zähler: `wesenregeln`, `wesenklassen`, `wesengruppen`, `landschaftsgruppen`,
   `klassen_in_landschaftsgruppen`, `gesperrte_wesen_in_landschaftsgruppen`,
   `wesen_verweise_auf_fehlendes`, `leere_wesengruppen`.
7. Fehlt `entitygroups.xml` in der Quelle, steht `wesengruppen: keine entitygroups.xml - Wesen
   nicht geprueft` im Bericht; kein Fehler. Fehlt nur `entityclasses.xml`, werden die Einträge
   gegen nichts gehalten, und der Bericht sagt das unter den Grenzen; kein Fehler.
8. Für `wesen-verweis-fehlt` und `wesengruppe-leer` gibt es **keinen Aufschub**. Für
   `gesperrtes-wesen` in dieser Fassung auch nicht: eine Wesenregel kommt in die Sperrliste, wenn
   der Patch, der die Klasse aus den Landschaftsgruppen nimmt, gebaut ist (WP5.4) — nicht vorher.
   Darum führt `denylist.txt` heute **keine** Wesenregel.

### Was die Prüfung noch nicht tut

- `purge-patch` erzeugt aus Wesenregeln **keine** Entfernungen. Vertrag 01 (Teil 2) legt das
  Herausnehmen nach `10_Purge`, „sobald die Sperrliste Wesen kennt"; die Regelart gibt es jetzt,
  der Erzeuger folgt mit WP5.4. Bis dahin stehen Entfernungen von Hand in `65_Wesen`.
- Der **Anzeigename** einer Klasse (Plan-0002 WP5.3: „jede Klasse in einer Gruppe hat eine
  Sprachzeile") ist Sache der Sprachprüfung, nicht dieser.

### Kalibrierung

Unverändertes `Data/Config` von V 3.40 b10, heutige Sperrliste (ohne Wesenregel):
`wesenklassen 293`, `wesengruppen 1875`, `landschaftsgruppen 29`,
`klassen_in_landschaftsgruppen 78`, `wesen_verweise_auf_fehlendes 0`, `leere_wesengruppen 0`
(Lauf vom 23.11.2026; derselbe Stand am Vorlauf mit unseren acht Modlets — kein Modlet fasst
diese Dateien heute an). Der einzige Eintrag ohne Klasse ist `none`. Eine Textsuche nach
`<entity_class ` und `<entitygroup ` zählt 315 und 1892: die Differenz steht in Kommentaren, und
das Werkzeug liest keine Kommentare.

**Messung für WP5.4, keine Projektregel:** mit siebzehn Wesenregeln nach den Grundnamen aus
`docs/pruefung/0002-erscheinung.md` (PartyGirl, Nurse, BusinessMan, MaleHazmat, Janitor, Inmate,
Lab, UtilityWorker, Biker, FatHawaiian, Bowler, FatCop, Skateboarder, Soldier, Demolition,
Rancher, Lumberjack; Messliste nur im Scratchpad) meldet der Befehl an Vanilla
`gesperrte_wesen_in_landschaftsgruppen 26` — 26 der 78 Klassen, in 13 Landschaftsgruppen, in allen
fünf Landschaften. `Inmate` und `Lab` stehen in keiner Landschaftsgruppe. Das ist der Umfang, den
WP5.4 herausnehmen muss.

### Grenzen

- **Schläfer in Orten** nennt das Prefab, nicht eine dieser Dateien; gesehen werden Gruppen,
  keine Orte (wie die Kisteninhalte: die bekannte Lücke von F-07).
- Was ein **Spielereignis**, ein **Auftrag** oder ein **Block** erscheinen lässt
  (`gameevents.xml`, `quests.xml`, Klassen mit eigenem Spawn), steht nicht darin.
- Der Name sagt nicht, wie ein Wesen **aussieht**. `zombieJoe` trägt Jeans; keine Regel über
  Namen findet das.
- Geprüft wird die Quelle, die der Befehl bekommt — am Dump unser Stand nach einem Spielstart,
  am Vorlauf eine Rechnung ohne Spiel.

### Gegenproben (Projektregel 5)

Abschnitt „Wesen" in `gegenproben.ps1`, Prüfsätze `testdaten/wesen`, `wesen-verweise`,
`wesen-ohne-klassen` (erfundene Kennungen), Prüflisten `denylist-wesen*.txt`:

1. Eine gesperrte Klasse in einer Landschaftsgruppe ist rot, mit Gruppe und Landschaft; die
   Gruppe, die nur die Spielstufen rufen, wird nicht genannt, und eine gesperrte Klasse, die nur
   dort steht, auch nicht. Die Wesenregel urteilt nicht über einen herstellbaren Gegenstand
   gleichen Namensanfangs, die Gegenstandsregel nicht über eine Klasse; eine auskommentierte
   Klasse zählt nicht.
2. Dieselbe Quelle ohne die Wesenregel: grün.
3. Eintrag ohne Klasse, `spawning.xml` und `gamestages.xml` mit fehlender Gruppe, gerufene leere
   Gruppe: vier Fehler; `none` ist keiner, die ungerufene leere Gruppe ist ein Hinweis.
4. `wesen:` ohne Muster: Exit 2.
5. Quelle ohne `entitygroups.xml`: gesagt, nicht rot.
6. Quelle ohne `entityclasses.xml`: gesagt, nicht rot.

### Lauf

23.11.2026, `tools/check/check-all.ps1` mit gesetztem `SDTD_PATH`: Zahlen im Commit und in der
Entscheidungsliste (N-36).

## Nachtrag WP5.3 — der Erzeuger der Wesen-Namen, 2026-11-23, **Abnahme offen** (N-67)

`tools/gen/wp5-wesen-namen.ps1` erzeugt die Sprachzeilen für die Namen aller Wesen (F-06 §2 bis
§4, D147). Begründung wie bei den Erzeugern aus WP7: Vanilla gibt jeder Klasse ihren eigenen
Sprachschlüssel — der Schlüssel ist der Klassenname, die Stufe steht im Namen ausgeschrieben. Aus
56 Namen und vier Stufenwörtern werden **176 Zeilen** (155 Seuchentote, 21 Tiere); eine
Namensänderung wäre von Hand fünf Zeilen, und eine vergessene Stufe fiele niemandem auf.

**Anders als die Erzeuger aus WP7** steht die Tabelle nicht im Skript, sondern daneben in
`tools/gen/wp5-wesen-namen.tsv` (UTF-8, fünf Spalten: Kennung, Art, Geschlecht, Deutsch,
Englisch). Das Skript enthält darum keine Umlaute und braucht keine BOM; wer einen Namen ändert,
fasst nur die Tabelle an.

**Es bricht ab** (Exit 1, schreibt nichts), wenn

- eine Klasse `zombie*` oder `animal*` des Builds in der Tabelle fehlt (Vorlagen ausgenommen),
- eine Tabellenzeile im Build keine Klasse hat,
- Vanillas Sprachdatei für eine Klasse keinen Schlüssel führt (unsere Zeile wäre tot),
- zwei Klassen denselben Namen bekämen, ohne dass Vanilla ihnen selbst denselben gibt
  (`zombieFrostclaw` und `zombieChuck` heißen in Vanilla beide „Chuck" — das ist erlaubt),
- eine Stufe vorkommt, für die kein Stufenwort in der Tabelle steht.

**Vier Gegenproben von Hand** (2026-11-23, je eine verfälschte Kopie der Tabelle; nicht in
`gegenproben.ps1`, weil der Erzeuger kein Teil des Prüfbefehls ist): Zeile `zombieBoe` gestrichen →
Exit 1, „steht nicht in der Tabelle" (5 Fehler: die Grundklasse und ihre vier Stufen); `zombieJoe`
auf den Namen von `zombieBoe` gesetzt → Exit 1, „Derselbe Name"; eine Zeile `zombieGibtEsNicht`
angehängt → Exit 1, „hat im Build keine Klasse"; das Stufenwort `Charged` gestrichen → Exit 1,
26 Fehler. In allen vier Fällen wurde keine Datei geschrieben. Der echte Lauf: 176 Klassen,
176 Zeilen, 0 Fehler.

**Ausgabe** nach `tools/gen/out/` (nicht im Repository): `wp5-wesen-namen-texte.csv`,
`wp5-wesen-namen-keys.txt` (für `vanilla-keys.txt`, mit dem englischen Namen als Grund) und
`wp5-wesen-namen-glossar.md` (55 Zeilen Festbegriffe für die Grundklassen). Das Erzeugnis sind die
Zeilen in Sprachdatei, Schlüsselliste und Glossar; die Prüfung *Glossar gegen Sprachdatei* hält
die 55 Grundnamen danach Zeichen für Zeichen gegen die Sprachdatei.

**Grenze:** der Erzeuger prüft, dass jede Klasse einen Namen hat — nicht, ob der Name passt, und
nicht, ob das Spiel ihn je zeigt (F-06 §2: gelesen sind die Meldungen im Chat; S-26).

## Nachtrag WP5.4 — `purge-patch` kennt Wesenregeln, 2026-11-23, **Abnahme offen** (N-68)

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP5.4, D149). Der Nachtrag *wesen* oben
hat es angekündigt („der Erzeuger folgt mit WP5.4"); Vertrag 01 (Nachtrag Phase 2, Teil 2) legt
das Herausnehmen nach `10_Purge`.

### Die Regel

1. Führt die Sperrliste **keine** Wesenregel, erzeugt `purge-patch` nichts für
   `entitygroups.xml`; das Erzeugnis sieht aus wie vor diesem Nachtrag. Der Zähler `wesenregeln`
   steht in jedem Bericht.
2. Mit Wesenregeln entsteht ein Teil `entitygroups.xml`: je **Landschaftsgruppe** (eine Gruppe, die
   `spawning.xml` ruft) und je gesperrter Klasse eine Zeile
   `<remove xpath="/entitygroups/entitygroup[@name='G']/e[@n='X']" />`. Der Name der Gruppe steht
   **immer** im XPath: Gruppen, die nur die Spielstufen rufen, bleiben unberührt (P2-E12).
   Getroffen wird der Eintrag, nie die Klasse, nie die Gruppe (Vertrag 03, Nachtrag Phase 2 C).
3. **Nachprobe** auf einer Kopie, vor dem Schreiben. Jeder dieser Befunde ist ein Fehler, und bei
   einem Fehler wird **keine** Datei geschrieben:
   - `wesen-trotz-patch` — eine gesperrte Klasse steht nach den Zeilen noch in einer
     Landschaftsgruppe;
   - `wesengruppe-leer-durch-patch` — eine Landschaftsgruppe hätte keinen Eintrag mehr (das Spiel
     bricht das Laden ab, Finding F-06 Wesen-Gruppen);
   - `wesengruppe-beginnt-mit-none` — `none` stünde an erster Stelle (das Spiel liest den ersten
     Eintrag; in Vanilla steht `none` nie vorn);
   - `wesenregel-trifft-nichts` — eine Wesenregel passt auf keine Klasse in einer
     Landschaftsgruppe der Quelle (gegen Vanilla ein Tippfehler);
   - `wesengruppe-andere-form` — eine Landschaftsgruppe führt Einträge, die nicht `<e n>` heißen
     (`<entity name>` oder eine Textliste; das Spiel liest sie, das Werkzeug nicht).
4. Zähler: `landschaftsgruppen`, `gesperrte_wesen_in_landschaftsgruppen`,
   `gesperrte_wesen_noch_in_landschaftsgruppen`, `landschaftsgruppen_leer_danach`,
   `landschaftsgruppen_beginnen_mit_none`, `patchzeilen_entitygroups.xml`.
5. `--vergleiche`: fehlt die Datei im Modlet, `patchdatei-fehlt`; weicht sie ab,
   `patchdatei-veraltet` (wie bei jeder erzeugten Datei). Neu ist die Gegenrichtung
   **`patchdatei-ohne-regel`**: im Modlet liegt eine `entitygroups.xml`, und die Sperrliste führt
   keine Wesenregel mehr.
6. Fehlt der Quelle `entitygroups.xml` oder `spawning.xml`, steht das unter den Grenzen; kein
   Fehler, kein Teil.
7. `--ohne-entfernen` lässt die Zeilen weg; die Nachprobe muss dann rot sein
   (`wesen-trotz-patch`).

### Was der Erzeuger nicht tut

- Er setzt nichts ein. Nachrücker und Ersatz (der Wolf für Kojote und Berglöwe) stehen von Hand in
  `700_65_Wesen`. Die Nachprobe rechnet **ohne** dieses Modlet: `10_Purge` allein darf keine
  Gruppe leeren (Vertrag 01 §3: jedes Modlet für sich).
- Die Mindestzahl aus F-06 §3.1 („fällt eine Gruppe unter drei Einträge, rückt eine Klasse nach")
  prüft er nicht; sie ist eine Regel des Features, kein Ladefehler.
- Schläfer in Orten, Horden, Seuchennacht, Spielereignisse und Aufträge sieht er nicht — dieselbe
  Grenze wie die Prüfung *wesen*.

### Kalibrierung

`mod700check purge-patch "<SDTD_PATH>/Data/Config" --out mod/700_10_Purge/Config --denylist
tools/check/denylist.txt` am 23.11.2026, V 3.40 b10, elf Wesenregeln: `landschaftsgruppen 29`,
`gesperrte_wesen_in_landschaftsgruppen 17`, `gesperrte_wesen_noch_in_landschaftsgruppen 0`,
`landschaftsgruppen_leer_danach 0`, `landschaftsgruppen_beginnen_mit_none 0`,
`patchzeilen_entitygroups.xml 72`, `patchzeilen 2007`; 0 rot. Die sieben übrigen erzeugten
Dateien sind dabei Zeichen für Zeichen gleich geblieben (`git status`: nur `entitygroups.xml`
neu).

Am Vorlauf mit neun Modlets (2863 Operationen, 0 ohne Treffer) meldet `anachronisms`:
`klassen_in_landschaftsgruppen 61` (vorher 78), `gesperrte_wesen_in_landschaftsgruppen 0`,
`wesen_verweise_auf_fehlendes 0`, `leere_wesengruppen 0`; 0 rot. An unverändertem Vanilla und am
Dump vom 22.11.: `gesperrte_wesen_in_landschaftsgruppen 17` — **der Prüfbefehl ist am alten Dump
damit um 17 Zeilen röter**, bis ein Spielstart einen neuen schreibt (N-01).

### Gegenproben (Projektregel 5)

Abschnitt „Wesen" in `gegenproben.ps1`, W7 bis W15, Prüfsatz `testdaten/wesen`, Prüflisten
`denylist-wesen.txt`, `-ohne`, `-tippfehler`, `-leert`, `-alles`:

| | Fall | Erwartung |
|---|---|---|
| W7 | eine Regel, Klasse in Landschafts- **und** Stufengruppe | eine Zeile mit dem Namen der Landschaftsgruppe; keine für die Stufengruppe; Exit 0 |
| W8 | `--ohne-entfernen` | `wesen-trotz-patch`; Exit 1 |
| W9 | Regel trifft nur eine Klasse in einer Stufengruppe | `wesenregel-trifft-nichts`; Exit 1 |
| W10 | Regel leert eine Landschaftsgruppe | `wesengruppe-leer-durch-patch`; Exit 1 |
| W11 | Regel trifft alles, `none` bleibt allein | `wesengruppe-beginnt-mit-none`; Exit 1 |
| W12 | keine Wesenregel | kein Wort von `entitygroups.xml`; Exit 0 |
| W13 | `--vergleiche` gegen einen Ordner ohne die Datei | `patchdatei-fehlt: entitygroups.xml`; Exit 1 |
| W14 | `--vergleiche`, Datei da, keine Regel | `patchdatei-ohne-regel`; Exit 1 |
| W15 | Quelle ohne `entitygroups.xml` | gesagt, nicht rot; Exit 0 |

`check-all.ps1`: 307 Gegenproben, 0 fehlgeschlagen (vorher 298).

### Grenzen

- Die Nachprobe rechnet mit `XDocument` und XPath des Werkzeugs, im Spiel rechnet der Patcher des
  Spiels. Der Nachweis ist der Weg über das Spiel: Start, Dump, `anachronisms` (S-27, N-01).
- `wesengruppe-andere-form` hat **keine** eigene Gegenprobe; Vanilla führt die Form nicht (0 von
  26 734 Einträgen), und der Fall ist bisher nur gelesen.
- Zwei Regeln, die dieselbe Klasse treffen: die erste gilt als benutzt, die zweite als
  `wesenregel-trifft-nichts` — wie bei den Auftragsregeln.

## Nachtrag WP5.5 — Farben der Wesen in der Prüfung *wesen*, 2026-11-23, **Abnahme offen** (N-69)

Gebaut auf Vertragsentwurf im autonomen Lauf (Plan-0002 WP5.5, D150).

**Anlass.** Die Eigenschaft `MatColor` einer Klasse nennt einen `<color name>`-Knoten in
`entityclasses.xml` beim Namen. Das Spiel schlägt ihn erst nach, wenn es das Modell baut (Finding
`F-06-wesen-farbe-und-stufen`): ein Name ohne Knoten bricht nicht beim Laden, sondern beim
**Erscheinen** des Wesens — kein Start-Log zeigt es. Mit `ent700_spukhund` nennt zum ersten Mal
eine eigene Klasse eine eigene Farbe.

**Die Regel** (in `anachronisms`, ohne jede Wesenregel, ohne Aufschub):

1. Fehler **`wesen-farbe-fehlt`**: eine `<property name="MatColor" value="X">` direkt an einer
   `entity_class`, und die Datei führt keinen `<color name="X">`. Eine Klasse, die die Eigenschaft
   nur erbt, wird nicht eigens gemeldet — gemeldet wird die Stelle, an der der Name steht.
2. Fehler **`wesen-farbe-doppelt`**: derselbe `<color name>` zweimal (das Spiel füllt ein
   Wörterbuch ohne Ersetzen; ein doppelter Name ist ein Ladefehler).
3. Zähler `wesenfarben`, `wesen_farben_fehlend`. Fehlt `entityclasses.xml`, steht keiner von
   beiden im Bericht.

**Kalibrierung:** Vanilla V 3.40 b10 `wesenfarben 3`, `wesen_farben_fehlend 0`; Vorlauf mit neun
Modlets `wesenfarben 4`, `wesen_farben_fehlend 0`.

**Gegenproben** (Abschnitt „Wesen", W6b und W6c, Prüfsatz `testdaten/wesen-farbe`): eine Klasse
mit vorhandener Farbe, eine mit fehlender, eine erbende — Exit 1, genau **eine** Meldung
(`pruefOhneFarbe`); am Prüfsatz `wesen` ohne `MatColor` Exit 0 und keine Meldung.

**Grenzen:** `wesen-farbe-doppelt` hat keine eigene Gegenprobe. Ob der **Wert** einer Farbe lesbar
ist (vier Zahlen) und was er am Modell tut, prüft niemand — das zeigt nur das Spiel (S-28).

**Dazu, in `sprachverweise-pruefen.ps1` (Nachtrag WP8.8):** `<entity_class name="X">` in einer
Patch-Datei **nennt** den Schlüssel `X` — das Spiel holt den Anzeigenamen eines Wesens über
`Entity::get_LocalizedEntityName`, das den Klassennamen (`EntityClass::entityClassName`) als
Schlüssel nachschlägt. Ohne die Regel stand die Zeile `ent700_spukhund` als „wird nicht gelesen"
da (am echten Stand so aufgefallen: 1 rot). Gegenproben (e3), Prüfsatz `testdaten/sprache/wesen`:
Klasse mit Zeile — Exit 0, `nicht gelesen: 0`; Klasse ohne Zeile und eine Zeile ohne Klasse —
Exit 1, beide gemeldet. Am echten Stand: 82 genannte Schlüssel, 0 ohne Zeile, 0 nicht gelesen.

## Nachtrag WP10.4 — `kette-pruefen` liest angelegte Fortschritts-Knoten und Freischaltungen, 2026-11-23, **Abnahme offen** (N-121)

Gebaut im autonomen Lauf (Plan-0002 WP10.4, D177).

**Anlass.** Die Fortschritts-Verweise (WP7.2) las die Prüfung nur in `<set>`-Werten. Seit WP10.3
legen wir Attribut, Gruppen und Perks **selbst an**; ihre `@parent` und
`requirement/@progression_name` stehen im angelegten Knoten. Und ein Perk schaltet Rezepte per
`passive_effect name="RecipeTagUnlocked"` frei, dessen Marken Rezeptnamen sind. Gefunden an der
Runenritzer-Bank: die Marke `blk700_runenritzerX` blieb grün — die Bank wäre für immer gesperrt
gewesen, ohne Meldung.

**Die Regel** (in jeder `progression.xml` unter den Patches, auch in `<conditional>`):

1. Rot **„Baum-Zuordnung … im angelegten Knoten … ist kein Fortschritts-Knoten"**: ein `@parent`
   an einem Element unterhalb einer Patch-Operation zeigt auf keinen Knoten aus Vanilla oder uns.
2. Rot **„Stufenbedingung … in einem angelegten Knoten …"**: dasselbe für `requirement/@progression_name`.
3. Rot **„Freischaltung … trifft kein Rezept"**: eine Marke in `RecipeTagUnlocked` ist kein
   Rezeptname aus Vanillas `recipes.xml` oder unseren Rezepten. *Kalibriert:* Vanilla V 3.40 b10
   führt 327 verschiedene Freischalt-Marken, 323 sind Rezeptnamen; die vier anderen (`armor*Master`)
   schreiben wir nicht.
4. Zähler „Verweise in angelegten Fortschritts-Knoten: N, Freischaltungen: M". Am echten Stand
   **18** und **16**.

**Gegenproben** (2 neu, 316 → **318**): `testdaten/kette/prog-angelegt-gut` — Exit 0, Zähler 3 und 1;
`prog-angelegt-schlecht` — vier Tippfehler bei treffenden XPaths, Exit 1, alle vier gemeldet. Am
echten Stand: `blk700_runenritzerX` → Exit 1, gemeldet.

**Grenzen:** Ob eine Marke **das richtige** Rezept trifft, prüft niemand. Freischaltungen in einem
`<set>`-Wert werden nicht gelesen (wir schreiben keine).

## Nachtrag WP10.5a — Aufsätze (`item_modifier`) in `kette-pruefen` und `sprachverweise-pruefen`, 2026-11-23, **Abnahme offen** (N-122)

Gebaut im autonomen Lauf (Plan-0002 WP10.5a, D178).

**Anlass.** Die Runen sind die ersten **eigenen Aufsätze** (`<item_modifier>`). Ein Aufsatz ist für das
Spiel ein Gegenstand (`ItemClassModifier` erbt `ItemClass`): ein Rezept stellt ihn her, und sein
Anzeigename ist sein Name als Schlüssel. Beide Prüfungen kannten nur `items.xml` und `blocks.xml` — am
echten Stand fünfmal „Ergebnis … nirgends definiert" und fünfmal „Zeile … wird nicht gelesen".

**Die Regeln:**

1. `kette-pruefen`: Definitionen sind auch die `<item_modifier name>` aus Vanillas
   `item_modifiers.xml` (wenn vorhanden) und aus unseren `item_modifiers.xml` (neuer Parameter
   `-AufsatzDateien`; ohne Angabe unter `mod/` gefunden — aber nur, wenn auch `-Rezepte` fehlt, damit
   Prüfdaten nicht die echten Aufsätze mitlesen).
2. `sprachverweise-pruefen`: ein `<item_modifier name="X">` **nennt** den Schlüssel `X`, wie eine
   Wesen-Klasse (Nachtrag WP5.5). Seine Beschreibung nennt er wie bisher über `DescriptionKey`.

**Gegenproben** (4 neu, 318 → **322**; eine angepasst): `kette/aufsatz` — mit der Aufsatz-Datei ist
nur das fehlende Ergebnis rot (1 rot), ohne sie beide (2 rot); `sprache/aufsatz` — Aufsatz mit Zeile
grün, ohne Zeile rot und die fremde Zeile „nicht gelesen". Angepasst: die Gegenprobe „DescriptionKey mit
Komma" findet jetzt **drei** statt zwei Befunde — ihr Prüfsatz `komma/buffs.xml` trägt einen Aufsatz
ohne Namenszeile, und das ist nach der neuen Regel richtig rot.

**Grenzen:** Ob `installable_tags`, `modifier_tags` und Wirkungen eines Aufsatzes im Spiel greifen,
prüft keine statische Prüfung (S-37).

## Nachtrag WP10.5d — Beute und Ware in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-125)

Gebaut im autonomen Lauf (Plan-0002 WP10.5d, D181).

**Anlass.** Reliquienkapsel, Kreuzanhänger und Bernstein gibt es **nur** als Beute bzw. beim Händler.
Ihr einziger Weg ins Spiel ist ein Name in `loot.xml` oder `traders.xml`. Die Gegenprobe am echten
Stand — `itm700_reliquienkapsl` in der Beute, `itm700_kreuzanhanger` in der Ware — blieb in
`check-all` grün: keine Prüfung las diese Namen.

**Die Regel.** `kette-pruefen` liest in den Patch-Dateien `loot.xml` und `traders.xml` jedes
`<item name>` und sucht es unter den Definitionen (Vanilla `items.xml`/`blocks.xml`, unsere
`items.xml`/`blocks.xml`, Aufsätze). `<item group>` ist ein Gruppenverweis und wird nicht gelesen.
Neue Zeile in der Ausgabe: `Beute und Ware mit Namen: N` (am echten Stand 96).

**Gegenprobe** (1 neu, 322 → **323**): `kette/ware` mit Vanilla-Gegenstücken `kette/vanilla/loot.xml`
und `traders.xml` — die vertippte Beute und die vertippte Ware sind rot (2 rot), die bekannten Namen und
der Gruppenverweis nicht.

**Grenzen:** Lootgruppen-Verweise (`group=`), Wahrscheinlichkeiten und ob ein Händler die Ware
wirklich zeigt, prüft das nicht. Entfernungen im Purge (`<remove xpath>`) sind XPaths und laufen wie
bisher durch die XPath-Prüfung.

## Nachtrag WP10.6 — Buff-Namen in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-126)

Gebaut im autonomen Lauf (Plan-0002 WP10.6, D182).

**Anlass.** Die Volksmagie hängt an Buff-Namen: Trank → Buff, Segen → Buff und Abklingzeit,
Statusprüfung → Odem-Buffs, Wurf → Fluch. Die Gegenprobe `buff700_odemRegn` (statt `buff700_odemRegen`)
im `AddBuff` der Statusprüfung blieb in `check-all` grün — der Odem wäre still nie gelaufen.

**Die Regel.** `kette-pruefen` liest in den Patch-Dateien jedes Attribut `buff="…"` (Listen mit Komma)
und jedes `<property name="Buff">` und sucht den Namen unter Vanillas `buffs.xml` und den `<buff name>`
der Patch-Dateien. Fehlt `buffs.xml` im Vanilla-Ordner (Prüfdaten), bleibt die Regel aus und die Ausgabe
sagt „nicht geprüft". Neue Zeile: `Buff-Verweise: N` (am echten Stand 20).

**Gegenproben** (2 neu, 323 → **325**): `kette/buff` — vertippter Buff im `AddBuff` und in der
Explosion rot, Vanilla- und eigener Buff nicht (2 rot); ohne `buffs.xml` im Vanilla-Ordner „nicht
geprüft", 0 rot.

**Grenzen:** Buffs, die nur über Marken oder Code gesetzt werden, und `buff_tags` liest die Regel nicht.
Die Test-Überlagerung (`test/`) gehört nicht zu den Patch-Dateien.

## Nachtrag WP10.9 — Tags in Bedingungen in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-127)

Gebaut im autonomen Lauf (Plan-0002 WP10.9, D183).

**Anlass.** Der Lichtfunke kostet Odem über `HoldingItemHasTags`, das Bernsteinamulett wirkt über
`WornItems` — beide hängen an einem Tag eines Gegenstands. Die Gegenprobe `lichtfunk700` (statt
`lichtfunke700`) blieb in `check-all` grün: der Funke hätte still nichts gekostet.

**Die Regel.** `kette-pruefen` liest in den Patch-Dateien `tags="…"` jeder `<requirement>` namens
`HoldingItemHasTags`, `!HoldingItemHasTags`, `ItemHasTags` oder `WornItems` (Listen mit Komma oder `|`)
und sucht jeden Tag unter den `Tags` der Gegenstände und Aufsätze aus Vanilla (`items.xml`,
`item_modifiers.xml`) und aus den Patch- und Gegenstands-Dateien. Fehlt `items.xml` im Vanilla-Ordner,
bleibt die Regel aus und die Ausgabe sagt „nicht geprüft". Neue Zeile: `Tags in Bedingungen: N` (am
echten Stand 3).

**Gegenprobe** (1 neu, 325 → **326**): `kette/tag` — vertippter Tag in einer verneinten Liste und in
`WornItems` rot; eigener Tag, Vanilla-Tag und der zweite Tag einer Vanilla-Liste nicht; `EntityTagCompare`
zählt nicht mit (2 rot). Am echten Modlet: `lichtfunk700` zweimal rot.

**Grenzen:** Tags auf Wesen (`EntityTagCompare`), Block-Tags und `buff_tags` liest die Regel nicht. Groß- und
Kleinschreibung unterscheidet sie nicht. Der Zweig „nicht geprüft" hat keine eigene Gegenprobe:
`kette-pruefen` braucht Vanillas `items.xml` schon für die Gegenstände und bricht ohne sie früher ab.

## Nachtrag WP11.3 — CVar-Namen gegen Vertrag 07 in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-129)

Gebaut im autonomen Lauf (Plan-0002 WP11.3, D185).

**Anlass.** Das Grauen rechnet in einem Buff mit sieben CVars, liest drei, die erst C# schreiben soll,
und den Schutz aus einem anderen Modlet. Ein vertippter Name liest still 0. Die Gegenprobe
`@.cv700_grauenSchtuz` blieb in `check-all` grün.

**Die Regel.** Gelesen werden Namen, die mit `cv700_` oder `.cv700_` beginnen. Als **Lesen** zählt
`cvar="…"` außerhalb eines `ModifyCVar` (also in `<requirement>`), jedes `@name` in einem Attribut und
`{cvar(name…)}` in Oberflächen-Dateien; als **Schreiben** `cvar="…"` eines `ModifyCVar`. Ein Name, der in
den Patch-Dateien geschrieben **und** gelesen wird, ist grün. **Nur gelesen** ist er grün nur, wenn
Vertrag 07 ihm in einer Tabellenzeile (erste Spalte: der Name) einen Schreiber außerhalb der XML gibt —
„Server" oder „C#" in den Spalten danach. **Nur geschrieben** ist er grün, wenn Vertrag 07 ihn irgendwo
nennt (z. B. ein Wert für die Oberfläche). Neuer Parameter `-Zustaende` (Pfad des Vertrags); im echten
Lauf `docs/contracts/07-zustaende-phase-2.md`, fehlt er dort, ist das rot. Neue Zeile:
`CVar-Verweise: N` (am echten Stand 110).

**Gegenproben** (2 neu, 326 → **328**): `kette/cvar` — ein gelesener Name ohne Schreiber, ein
geschriebener ohne Leser und einer, den der Vertrag nur einem Buff gibt, sind rot; ein Name mit „Server"
im eigenen Wort spricht sich nicht frei (die Gegenprobe fand diesen Fehler beim Bau); Vertragsname mit
Server-Schreiber, nur geschriebener Vertragsname, `t700_` und `$` bleiben grün (3 rot). Ohne `-Zustaende`
in Prüfdaten „nicht geprüft", 0 rot. Am echten Modlet: `@.cv700_grauenSchtuz` rot,
`{cvar(.cv700_odemAntel` rot, `.cv700_grauenSchutz` im ganzen Schutz-Buff vertippt rot.

**Grenzen:** die Regel prüft Namen, nicht Werte oder Einheiten. Ein Name, der in einer Datei
geschrieben und in derselben vertippt gelesen wird, fällt nur auf, wenn der Tippfehler nicht auch
geschrieben wird. Die Test-Überlagerung (`test/`) gehört nicht zu den Patch-Dateien. Die Schreiber-Spalte
wird als Text gelesen, nicht als Tabelle verstanden.

## Nachtrag WP11.9 — Wesen-Gruppen in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-130)

Gebaut im autonomen Lauf (Plan-0002 WP11.9, D186).

**Anlass.** Die Seuchennacht ruft unsere Gruppen aus `gamestages.xml`. Die Gegenprobe
`eg700_brecherFrue` blieb grün — `mod700check wesen` prüft nur gegen einen ConfigsDump, und der alte
Dump kennt unsere Modlets nicht.

**Die Regel.** `kette-pruefen` liest `group="…"` und `entitygroup="…"` jeder `<spawn>` in den Patch-Dateien
und sucht sie unter Vanillas `entitygroups.xml` und unseren `<entitygroup name>`; dazu `n="…"` jedes `<e>`
in unseren Gruppen gegen Vanillas `entityclasses.xml` und unsere `<entity_class name>`. Ohne Vanillas
`entitygroups.xml` bleibt die Regel aus und die Ausgabe sagt es. Neue Zeile: `Wesen und Gruppen: N`
(am echten Stand 36).

**Gegenprobe** (1 neu, 328 → **329**): `kette/gruppe` — vertippte Gruppe in einer Wellen-Zeile und
vertipptes Wesen in einer eigenen Gruppe rot, Vanilla-Gruppe, eigene Gruppe und Vanilla-Wesen nicht; der
Zahlvergleich `gamestage[@stage >= 10]` trifft (2 rot). Am echten Modlet: `eg700_brecherFrue` rot,
`ent700_spukhunt` rot, die Schwelle `@stage >= 9000` als „XPath trifft nichts" rot.

**Grenzen:** Gruppen, die nur der Spielcode nennt (z. B. Vanillas Wanderhorden in `spawning.xml` über
eigene Attribute), und die Gewichte `p` liest die Regel nicht. Ob eine Gruppe leer wird, weil die
Säuberung Wesen entfernt, prüft weiter `mod700check wesen` am Dump.

## Nachtrag WP11.5 — Laute in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-131)

Gebaut im autonomen Lauf (Plan-0002 WP11.5, D187).

**Anlass.** Trugbilder, die Glocke der Seuchennacht und die Zauber sind Laute. Ein vertippter Name
spielt nichts, ohne Meldung — die Gegenprobe `rustel` blieb grün.

**Die Regel.** `kette-pruefen` liest `sound="…"` jedes `triggered_effect` mit `action="PlaySound"` und den
Wert jeder `<property>`, deren Name mit `Sound` beginnt, in den Patch-Dateien, und sucht ihn unter Vanillas
`<SoundDataNode name>` in `sounds.xml`. Leere Werte, Namen mit `#` (Vanilla setzt dort Stimme oder
Geschlecht ein) und Zahlen (`SoundRandomTime` u. a.) zählen nicht. Ohne Vanillas `sounds.xml` bleibt die
Regel aus. Neue Zeile: `Laute: N` (am echten Stand 69).

**Gegenprobe** (1 neu, 329 → **330**): `kette/laut` — vertippter Laut im `PlaySound` und in `Sound_start`
rot; Vanilla-Laute, `#`, die Zahl und der leere Wert nicht (2 rot). Am echten Modlet: `rustel` und
`club_swinglite` je rot.

**Grenzen:** eigene Laute (F-16) gibt es noch nicht; kommen sie, muss die Regel deren Liste kennen.
Laute, die der Spielcode aus Teilen zusammensetzt, liest sie nicht.

## Nachtrag WP14.2 — Prüfung `drehbuch-pruefen`, 2026-11-23, **Abnahme offen** (N-135)

Gebaut im autonomen Lauf (Plan-0002 WP14.2 Teil, D191).

**Anlass.** Die Spieltests (S-01 bis S-47) stehen als Tabellenzeilen in der Entscheidungsliste §6; das
Drehbuch `docs/pruefung/0004-drehbuch-spieltests.md` ordnet sie fünf Sitzungen zu. Wächst die Liste und
das Drehbuch nicht mit, fällt ein Test still heraus. Der erste Abgleich von Hand fand genau das: S-33
stand nur im Bereich „S-32 bis S-35".

**Die Regel.** `tools/check/drehbuch-pruefen.ps1` (Parameter `-Liste`, `-Drehbuch`, Vorgaben die beiden
echten Dateien) liest jede Tabellenzeile der Liste, die mit `| S-NN` beginnt, und sucht die Nummer im
Drehbuch als **eigene Nummer** (davor kein Buchstabe, keine Ziffer, kein Bindestrich; danach keine
Ziffer). Bereiche zählen nicht. Rot ist (1) eine Zeile ohne Platz und (2) eine Nummer im Drehbuch, die
die Liste nicht kennt. Eine ganz gestrichene Zeile (`| ~~S-NN`) braucht keinen Platz und darf genannt
werden. Ausgang 0/1/2; 2 heißt nicht prüfbar (Datei fehlt, keine S-Zeile). Ausgabe: `Drehbuch: N
S-Zeilen, M ohne Platz, K unbekannt, G gestrichen` (am echten Stand 47, 0, 0, 0).

**In `check-all.ps1`** als **elfte** Prüfung, ohne Spielpfad. Die neun Gegenproben, die die Ergebniszeile
von `check-all` lesen, erwarten jetzt „11 Prüfungen".

**Gegenproben** (7 neu, 330 → **337**), Testdaten `testdaten/drehbuch/`: sauber (0); eine Zeile fehlt
und eine steckt nur in einem Bereich (1, beide genannt); `S-3` gegen `S-33` und eine zu kurze Nummer (1);
eine erfundene Nummer, die gestrichene darf stehen (1); Liste ohne S-Zeile (2); Drehbuch fehlt (2); ohne
Parameter am echten Stand (0). Beim Bau fand die Gegenprobe einen Fehler in den eigenen Testdaten: die
Überschrift nannte die fehlenden Nummern und machte sie so „platziert" — jede Nennung zählt, auch im
Fließtext. Das ist gewollt (das Drehbuch nennt Zeilen auch in Sätzen); die Testdaten sind berichtigt.

**Grenzen:** die Prüfung sieht nicht, ob ein Teilpunkt (S-31 (3)–(8)) seinen Platz hat — nur die Zeile.
Ob die Minuten stimmen, prüft sie nicht.

## Nachtrag WP12.4 — Marken im Schutz in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-137)

Gebaut im autonomen Lauf (Plan-0002 WP12.4, D193).

**Anlass.** Schutz je Schadensart hängt an den Marken der **angreifenden** Waffe
(`PhysicalDamageResist` mit `tags="bladeSkill,…"`, F-02 Ausarbeitung §1). Eine vertippte Marke gilt für
keine Waffe; der Schutz fällt still weg, kein Ladefehler.

**Die Regel.** Im Block „Tags in Bedingungen" liest `kette-pruefen` zusätzlich `tags="…"` jedes
`<passive_effect name="PhysicalDamageResist">` in den Patch-Dateien und sucht jede Marke im selben Vorrat
(Tags der Gegenstände und Aufsätze aus Vanilla und aus unseren Dateien). `DamageModifier` und
`ElementalDamageResist` zählen **nicht** — dort sind die Marken Stoffe (`earth`, `metal`) bzw. Elemente
(`heat`), keine Gegenstände. Neue Zeile: `Tags im Schutz: N` (am echten Stand 123).

**Gegenprobe** (1 neu, 337 → **338**): `kette/schutz` — vertippte Marke in einer Liste rot; Vanilla-Tag,
eigener Tag, zweiter Tag einer Liste grün; `DamageModifier` und `ElementalDamageResist` nicht gezählt.
Am echten Modlet: `bladeSkil` am Krieger rot (Exit 1), danach grün.

**Grenzen:** ob Vanilla die Marken an **getragener** Rüstung gegen die angreifende Waffe hält, prüft
kein Werkzeug — das zeigt S-48.

## Nachtrag WP12.3 — Stufen und Herstell-Zähler in `kette-pruefen`, 2026-11-23, **Abnahme offen** (N-138)

Gebaut im autonomen Lauf (Plan-0002 WP12.3, D194).

**Anlass.** Lernen durch Tun liest Vanillas Zähler `_craftCount_<Gegenstand>` und hebt eine
Handwerks-Stufe per `AddProgressionLevel`, beides in `buffs.xml`. `kette-pruefen` las `progression_name`
bisher nur in `progression.xml`. Ein vertippter Gegenstand liest still 0 (die Stufe steigt nie), eine
vertippte Stufe hebt nichts — kein Ladefehler. Am echten Buff blieb `craftingBlade` vorher grün.

**Die Regel.** In jeder Patch-Datei außer `progression.xml` wird jedes Attribut `progression_name`
(Bedingung und Wirkung) im Fortschritts-Vorrat gesucht (Vanillas `progression.xml` und unsere Knoten),
jedes `cvar="_craftCount_X"` im Rezept-Vorrat (Vanillas `recipes.xml` und unsere Rezepte). Andere
Motorwerte mit `_` (`_coretemp`) zählen nicht. Ohne Vanillas `progression.xml` bleibt der Block aus und
sagt das. Neue Zeile: `Lern-Verweise (Stufen, Zaehler): N` (am echten Stand 117).

**Erzeuger mit eigener Prüfung:** `tools/gen/wp12-lernen.ps1` liest die Tabelle `wp12-lernen.tsv` und
bricht mit Exit 1 ab, ohne zu schreiben, wenn ein Gegenstand kein Rezept hat, eine Stufe nicht im Build
steht, ein gebundenes Rezept unter 36 (D70) in der Tabelle fehlt oder eine Stufe kein Lehrblatt hat.
Gegenprobe beim Bau: vertippte Klinge, vertippte Stufe, fehlender Webstuhl → 4 Fehler, Exit 1, nichts
geschrieben. Er gehört nicht zu `check-all` (er schreibt), er läuft beim Ändern der Tabelle.

**Gegenprobe** (1 neu, 338 → **339**): `kette/lernen` — vertippte Stufe in einer Wirkung und Zähler ohne
Rezept rot; Vanilla-Stufe, Vanilla-Perk, eigenes Rezept grün; `_coretemp` nicht gezählt. Am echten
Modlet: `craftingBlade` und `_craftCount_itm700_stepbahn` rot (3 rot), danach grün.

**Grenzen:** ob Vanilla den Zähler wirklich unter diesem Namen führt und ob er auch für Blöcke zählt
(Webstuhl, Holzfeuer), prüft kein Werkzeug — das zeigt S-49.

## Nachtrag Spieltest — Form der Patch-Operationen in `kette-pruefen`, 2026-11-23, **Abnahme offen**

Gebaut auf Wunsch des Nutzers („Prüflücken schließen", 2026-11-23) nach dem Spieltest.

**Anlass.** Zwei Fehler fand erst das Spiel, `kette-pruefen` war grün:
- `<removeattribute xpath="…" name="min_count"/>` in `700_60_Welt/rwgmixer.xml` und zwanzigmal in
  `700_50_Fortschritt/challenges.xml`. Das Spiel nimmt das Attribut aus dem XPath und bricht den Patch
  ab, wenn der ein Element trifft („Can only remove Attributes (matched Element …), use remove instead",
  Player.log 2026-11-23 15:37). Behoben in 4192042.
- Ein `<append>` in `700_75_Magie/XUi_InGame/windows.xml` traf **zwei** `rect name="hud"`; die
  Odem-Leiste erschien doppelt. Behoben in f076429.

**Die Regeln** (gegen die Vanilla-Datei gleichen Pfads, wie die XPath-Prüfung):
1. `<removeattribute>` mit einem Attribut `name` ist rot — das Spiel liest nur den XPath.
2. `<removeattribute>`, dessen XPath in Vanilla ein Element trifft, ist rot. Trifft er nichts (Ziel aus
   einem eigenen Modlet), muss sein letzter Schritt ein Attribut sein (`…/@name`), sonst rot.
3. `<remove>`, das ein Attribut trifft, ist rot (das Spiel verlangt dafür `removeattribute`).
4. `<append>`, `<prepend>`, `<insertAfter>`, `<insertBefore>`, die in Vanilla **mehr als eine** Stelle
   treffen, sind rot — außer unmittelbar davor (nur Leerraum dazwischen) steht ein Kommentar, der mit
   `mehrere Ziele:` beginnt und den Grund nennt. Die fünf Horden-Zeilen in
   `700_65_Wesen/gamestages.xml` tragen ihn jetzt.

Neue Zeile: `Patch-Form: N removeattribute geprueft, M Einfuegen an mehreren Stellen vermerkt` (am
echten Stand 21 und 5).

**Gegenprobe** (1 neu, 344 → **345**): `kette/patchform` — name=, Element, `remove` auf ein Attribut,
Einfügen ohne Vermerk und mit einem Vermerk, der nicht am Anfang steht: 5 rot; XPath auf das Attribut und
Einfügen mit Vermerk grün. Dieselben Testdaten mit der Fassung vor diesem Nachtrag: **Exit 0, grün** — die
Lücke war echt.

**Grenzen.** Mehrfach-Treffer werden gegen Vanilla gezählt, nicht gegen den gepatchten Stand. Das
gemeinsame Patch-Modell `patch-operationen.ps1` (genutzt von `sprachverweise-pruefen`,
`vertraeglichkeit-pruefen`, `testueberlagerung-pruefen`) rechnet `removeattribute` **seit
2026-11-23 so wie das Spiel** (Wunsch des Nutzers): das Attribut kommt aus dem XPath, ein Treffer auf ein
Element ist „nicht gerechnet" mit dem Grund „das Spiel lehnt das ab". Drei Testdateien standen noch in
der alten Form und sind nachgezogen (`sprache/knotenart`, `sprache/gruppe-leer/entfernt`,
`vertraeglich/fremd-arten`); die Erwartung der Knotenart-Gegenprobe nennt jetzt das Element. Gegen die
alte Fassung von `patch-operationen.ps1` zählt dieselbe Gegenprobe die falsche Form als angewandt
(6 rot statt 7) und schlägt fehl.
