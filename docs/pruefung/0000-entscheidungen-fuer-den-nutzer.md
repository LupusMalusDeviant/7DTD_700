# Entscheidungen für den Nutzer — die eine Liste

| | |
|---|---|
| **Angelegt** | 2026-11-22, Nachtlauf |
| **Auftrag** | „abschließen … soweit wie du es ohne meinen Input schaffst … Wenn du unsicher bist, agiere nach deinen Empfehlungen, aber markiere die Entscheidung als zu prüfen durch mich" und danach „Loop bis Ende Phase 2. Alles wo du meine Entscheidung brauchst, entsprechend notieren. Du darfst Meshy via API nutzen, so viel wie du brauchst." |
| **Regel dieser Liste** | Jeder Punkt, der eine Entscheidung, eine Abnahme oder einen Blick ins Spiel braucht, steht **hier** mit Nummer. Wo ohne Antwort weitergebaut wurde, steht, **nach welcher Empfehlung**. Erledigtes wird durchgestrichen, nicht gelöscht. |
| **Stand** | wird bei jedem Arbeitsschritt des Loops fortgeschrieben; der Kopf von Abschnitt 0 nennt den letzten Stand |

Marken: **[E]** Entscheidung · **[A]** Abnahme eines Vertrags · **[S]** nur im Spiel zu sehen · **[P]** Freigabe (Push, Installation).

## 0. Stand und das Wichtigste zuerst

**Stand 2026-11-23, früh:** Phase 1 ist gebaut, aber **nicht abgenommen**; Phase 2 läuft im Loop (Plan-0002,
Entwurf); nichts ist gepusht (HEAD lokal vor `origin`), die Mod liegt **nicht** im Spielordner.

Der Prüfbefehl `powershell -File tools/check/check-all.ps1` endet mit **280 Gegenproben, 0 fehlgeschlagen;
10 Prüfungen, 1 rot (Exit 1)** — drei Prüfungen sind neu (*Symbole*, *Asset-Register*, *Test-Überlagerung*;
N-18, N-19). Rot ist *anachronisms* mit vier Fehlern: `erreichbarer-anachronismus: resourceRepairKit` und
seit dem 23.11. dreimal `gesperrter-auftrag` (die Stromaufträge, N-31) — der Spiel-Dump von
22:08 stammt aus einem Start **vor** der Sperre des Reparatur-Kits und vor der Auftragsregel. Am Vorlauf des neuen Standes sind alle
sieben Prüfungen grün; ein Vorlauf ist kein Nachweis. **Grün wird der Prüfbefehl erst mit einem Spielstart
mit dem neuen Stand** (N-01).

Die fünf Punkte, die am meisten bewegen:

1. **N-01** — einmal installieren und starten, damit ein neuer Dump entsteht (ohne ihn bleibt der Prüfbefehl rot).
2. **N-02** — der **Biom-Fortschritt ist mit unserer Mod nicht lösbar** und war im Testlauf an.
3. **N-10** — Push: braucht deine Freigabe und die Wahl des Codex-Modells.
4. **N-20 bis N-27** — was der Nachtlauf nach Empfehlung **gebaut** hat (Namen, Rezepte, Bilder).
5. **N-40** — die sechs Kernfragen des Spiels ohne Antwort (Ziel, Tod, Seuchennacht, Religion, Figuren, Schwierigkeit).
6. **N-64** — **Meshy nimmt keine Aufträge an** (Gratis-Tarif, HTTP 402 trotz 5332 Credits). Ohne Tarifwechsel
   entsteht kein Meshy-Bild und kein Meshy-Modell; der Loop baut einfache Symbole solange in Blender.
7. **N-60** — ohne Unity-Editor kommt kein eigenes 3D-Modell ins Spiel.

## 1. Sofort — hält etwas auf

| Nr. | Art | Was | Empfehlung / wonach gebaut wurde |
|---|---|---|---|
| N-01 | [P] [S] | **Installieren und einmal starten** (`tools\build\build.ps1 -Install`, Spielstart ohne EAC wie am 22.11.), neue Welt oder vorhandene laden, bis der `ConfigsDump` geschrieben ist. Danach `check-all.ps1`. | Erwartet: 7 Prüfungen, 0 rot. Die Mod bleibt bis zu deinem Ja aus dem Spielordner. |
| N-02 | [E] [S] | **Biom-Fortschritt:** je Reihe nennen 4 von 7 Aufgaben gesperrte Kennungen, alle Gegenmittel und Schutzstücke sind gesperrt. Außerhalb des Kiefernwalds läuft unter freiem Himmel eine Frist ab, danach verliert man Leben bis unter ein Dach. Gemessen aus XML und Spielprotokoll, **im Spiel nicht gesehen** ([`konzept/biome.md`](../konzept/biome.md) §1.10). | **Weg A: in Phase 1 abschalten** — Spieloption „Biom-Fortschritt" beim Anlegen der Welt auf Aus. Umdeuten und zurückholen (Weg B) mit F-07 in Phase 2. ~~Gebaut ist nichts.~~ *Stand 2026-11-23: gebaut ist eine vorgewählte Vorlage „Jahr 700" ohne Biom-Fortschritt (N-32, D136) — sie wählt nur vor, erzwingt nichts.* |
| N-03 | [E] | **Kerzenstumpf** hängt nach dem Ausbrennen ohne Text an der Wand, lässt sich nicht aufnehmen, gibt beim Abschlagen nichts (dein Befund vom 22.11.). | Offen. Vorschlag: Name und Beschreibung für den Stumpf, Abschlagen gibt 1 Talg zurück; Zahlen mit dem nächsten Test. |
| N-04 | [E] | **Armbrust vor dem Langbogen:** D8 will die Armbrust „selten, T4"; Vanilla schaltet sie bei Bogenbau 21 frei, den Langbogen bei 36 (D125). | Freischaltstufen tauschen, wie D88 bei den Äxten — **oder** die einfache Armbrust als Jagdwaffe der Mitte tragen. Nicht gebaut. |

## 2. Freigaben

| Nr. | Art | Was | Empfehlung |
|---|---|---|---|
| N-10 | [P] | **Push** des Branches `ccr-da9f2bb1-utwrjz`. Vorher läuft das Codex-Review über den dann aktuellen HEAD; das Modell wählst du (bisherige Auswahl: `gpt-6.1-sol`, `gpt-6.2-sol`, `gpt-6.2-astra`, Überspringen). | Erst N-01, damit der Prüfbefehl grün ist; dann Review und Push. Im Loop wird **nicht** gepusht. |
| N-11 | [P] | **Installation in den Spielordner** und Spielstarts durch Claude während des Loops. | Nicht ohne dein Ja. Alles, was das Spiel braucht, steht im gesammelten Spieltest (Abschnitt 6). |

## 3. Abnahmen offener Verträge

| Nr. | Art | Was |
|---|---|---|
| N-13 | [A] | Zwei kleine Nachträge zur Spielvorlage (N-32): **Vertrag 01, Teil 1b** — `700_60_Welt` trägt `sandbox_overrides.xml` mit genau einer Vorlage und keinem `sandbox_override`; **Vertrag 04, Sprachschlüssel einer Spielvorlage** — `localized_name` an einem `preset` zählt als genannter Schlüssel (zwei Gegenproben). Gebaut am 2026-11-23. |
| N-14 | [A] | Vertrag 04, **Nachtrag Auftragsregeln** — eine Zeile `auftrag:<Muster>` in `denylist.txt` urteilt über Aufträge in den Händlerlisten; `purge-patch` nimmt sie aus den Listen (die Definition bleibt), `anachronisms` meldet sie; eine Auftragsregel ohne Treffer ist beim Erzeugen ein Fehler. Acht Gegenproben. Gebaut am 2026-11-23 für N-31. |
| N-15 | [A] | Vertrag 04, **Nachtrag Dump-Suche** (`check-all.ps1` kennt `-UserDataFolder`). |
| N-16 | [A] | Vertrag 04, **Nachtrag Leermeldung** (`=kein-aufschub` in `aufschub.txt`). |
| N-17 | [A] | Vertrag 04, **Nachtrag zweites Review der Vorprüfung** (zwei Befunde an `vertraeglichkeit-pruefen.ps1` behoben). |
| N-18 | [A] | Vertrag 04, **Nachtrag Prüfungen der Phase 2, Teil 1** (*Symbole* und *Asset-Register*: Regeln, Grenzen, 27 Gegenproben) — gebaut am 2026-11-23. Dazu gehört **Vertrag 05** (Asset-Pipeline, N-71), am selben Tag in drei Punkten präzisiert: eine Münze darf ein Punktmuster tragen; Zuschnitt ab Alpha 8, nie vergrößern; Quelle `eigen:blender` als eigener Rang. |

| N-19 | [A] | Vertrag 01, **Nachtrag Phase 2, Teil 1** — (A) ein Modlet darf Symbole unter `UIAtlases/ItemIconAtlas` tragen (das stand bisher als „keine Datei außerhalb von `Config/`"; die ersten vier Symbole lagen schon dort, bevor der Nachtrag geschrieben war — beim Schreiben aufgefallen). (B) die **Test-Überlagerung** `test/700_99_Test`: liegt außerhalb von `mod/`, nie im Paket, nur mit `build.ps1 -Install -MitTest` installiert, ein gewöhnliches `-Install` entfernt sie, `smoke.ps1` meldet sie rot; sie darf nur `<set>`. Dazu die zehnte Prüfung. |

Verträge für Phase 2 kommen dazu, sobald sie geschrieben sind (Plan-0002).

## 4. Gebaut nach Empfehlung — zu prüfen

Alles hier ist im Mod bzw. in den Werkzeugen **umgesetzt** und lokal committet. Nimmst du es an, fällt die
Marke; sonst wird es zurückgebaut.

| Nr. | Art | Was gebaut ist | Wo | Was du prüfst |
|---|---|---|---|---|
| N-20 | [E] [S] | **Bogenzeug** `itm700_bogenzeug` flickt Holzbogen, Langbogen und beide Armbrüste; Rezept von Hand: 10 Nesselfaser, 1 Tierfett, 2 Holz → 2 Stück. | `d52faba`, D91/D92 | Name („Bogenzeug / Bowyer's Kit"), Rezept, Reparaturmenge |
| N-21 | [E] | **Werkzeug flickt wie die Äxte:** Zimmermannshammer, Spitzhacken, Schaufeln mit Schleifstein oder Schmiedeflicken. F-05-Gebiet, nur Zeiger, keine neuen Zahlen. | `18ad647` | ob das so bleiben soll, bis F-05 es ausarbeitet |
| N-22 | [E] | **Reparatur-Kit gesperrt** (23 von 23 Zeigern umgehängt), Purge neu erzeugt; drei Beutegruppen sind neu leer. | `18ad647` | einverstanden? |
| N-23 | [E] [S] | **Acht Bilder im Beutel** umgebogen: Silberpfennig (Casino-Jeton → Silberbrocken), Raseneisenerz und Luppe (Schrott → Erzbrocken), Leim, Nähzeug, Erste-Hilfe-Verband, Pergamentfetzen, Bogenzeug. | `4506690`, D130 | jedes Bild im Spiel ansehen; der Silberpfennig sieht dem Silberbrocken ähnlich |
| N-24 | [E] | **Leermeldung** und **zwei Review-Korrekturen** an den Prüfwerkzeugen. | `18ad647`, `608b5fa` | siehe N-16, N-17 |
| N-25 | [E] | **Nachgezogene Widersprüche** in GDD und Features (fünf statt sechs Bäume, Blockschaden bleibt Vanilla, Karte in Phase 4 …) — nur Stand schon getroffener Entscheidungen, alter Wortlaut durchgestrichen. | `457a379` | Stichprobe |
| N-26 | [E] [S] | **241 Sprachzeilen für Lücken**, darunter **102 neue Namen** (Sprachdatei 941 → 1182 Schlüssel): Startquest („Der Weg zum Händler"), Salbenverband, Steinpfeil / Eisenpfeil / Brandpfeil und die Bolzen, Haselbogen, Jagdbogen, 15 Waffen-Aufsätze (Pechwicklung, Stahlschneide, Spaltkeil …), zwölf Stücke Unterkleidung (Leinenhemd, Gewalkte Socken …), 22 Rüstungs-Aufsätze (Wollfutter, Gürteltasche, Köcherriemen, Eberzier …), Stürme (Fauler Wind, Aschesturm). Jeder Name steht im Glossar mit „Name zu prüfen". | D129; Liste aller Namen im Glossar §2, §3, §5, §6, §8 | Namen einzeln; zwei deutsche Formen für die Reparaturangabe („zu flicken" / „ausbessern") angleichen? |
| N-27 | [E] | Berichtigung: die Biom-Ausrüstung trägt in Vanilla Namen (Lesefehler in Balancing 0003). | `037110f` | — |
| N-28 | [E] [S] | **Erstes eigenes Bild:** der Silberpfennig zeigt `ico700_silberpfennig` — drei gehämmerte Silberscheiben mit Perlkreis, in Blender gebaut — statt des umgebogenen Silberbrockens (N-23). Dazu das Werkzeug `tools/assets/symbole.ps1`, das Register `assets/ASSETS.md` und zwei Prüfungen. Quellbild: `assets/quelle/symbole/ico700_silberpfennig.png`. | D131, Plan-0002 WP3.4 | ob dir das Bild gefällt; ob es im Beutel erscheint (S-09). Bleibt das Feld leer, ist es eine Zeile zurück auf den Silberbrocken. |
| N-29 | [E] [S] | **Drei weitere eigene Bilder** statt Vanillas Barren mit dem Stempel „Fe 26": **Schmiedeeisen** (auch Schmiedeflicken, getönt), **Tiegelstahl**, **Klinge**. Alle aus Blender, alle im Register. Quellbilder unter `assets/quelle/symbole/`. | D132, Plan-0002 WP3.6 | die Bilder selbst (einfach gehalten — Stäbe und eine rohe Klinge); im Spiel S-09. |
| N-30 | [E] [S] | **Kräutersud** gegen Infektion: `drugHerbalAntibiotics` ist von der Denylist genommen (die Denylist ist deine Sache — darum ausdrücklich hier), heißt „Kräutersud / Herb Decoction" und hat ein Rezept ohne Chrysantheme, Salpeter und Blaubeeren: Pilze 3, Goldrute 3, Aloe-Blatt 2, abgekochtes Wasser 1, an der Feuerstelle mit Topf. Freischaltung über Wundversorgung 30 wie in Vanilla; er liegt auch wieder in der Beute. Vorher gab es gegen eine Infektion nur Honig. | D133 | Freigabe der Kennung; Name; Rezept und Mengen; ob Aloe als Zutat passt. Im Spiel: S-10. |
| N-31 | [E] | **Stromaufträge heraus:** „Strom wiederherstellen" (Stufe 2 bis 4) steht bei keinem der fünf Händler mehr in der Auftragsliste — 15 Einträge, drei Patchzeilen. Die Sperrliste hat dafür eine neue Regelart bekommen (`auftrag:tier*_restore_power`; die Denylist ist deine Sache, darum ausdrücklich hier). Der Auftrag selbst bleibt im Spiel stehen, damit er als „Brunnen wiederherstellen" zurückkommen kann (F-10, WP8); bis dahin hat Stufe 4 drei Auftragsarten statt vier. | D135, N-14 | die Regel in der Sperrliste; ob der Auftrag bis WP8 ganz fehlen darf oder lieber sofort umgedeutet werden soll. Im Spiel nichts zu tun: der Prüfbefehl liest die Listen im nächsten Dump (S-01). |
| N-32 | [E] [S] | **Spielvorlage „Jahr 700"** (englisch „Year 700"): beim Anlegen einer Welt vorgewählt, Schwierigkeit wie Vanillas „Adventurer", **Biom-Fortschritt aus**. Der Optionscode ist **gerechnet, nicht kopiert** (`AAAJABJACJADJARFBNCCDA`; Finding F-17). Gemessen dabei: `sandbox_override` taugt nicht — es sperrt nur das Bedienfeld. Die Vorlage wählt nur vor; auf einem Dedicated Server muss der Code in `serverconfig.xml`. Weitere Optionen (Luftabwurf nie, Händlerstimmen aus, Automaten aus, Technikstufe) sind **Empfehlung, nicht gebaut**: [`konzept/voreinstellung-700.md`](../konzept/voreinstellung-700.md). | D136, N-13 | Name der Vorlage; ob sie vorgewählt sein soll; welche der weiteren Optionen hinein sollen. Im Spiel: S-11. |

## 5. Vorschläge auf dem Papier — nichts davon ist gebaut

| Nr. | Art | Was | Wo es steht |
|---|---|---|---|
| N-40 | [E] | **Sechs Kernfragen:** Spielziel (D106), Tod und Wiederkehr (D105), Deutung der Seuchennacht (D107), Leitplanke für Religion (D108), Frauen- und Männerfiguren (D109), Schwierigkeit und empfohlene Voreinstellung (D112). | GDD 7.8 |
| N-41 | [E] | **Was darf in Phase 1 modern bleiben?** Geschlossene Liste getragener Lücken (D93) — sonst ist das MVP-Ziel „ohne Anachronismus in Texten" nie erfüllbar. | GDD 7.8 |
| N-42 | [E] | ~~**Wasser** (D98: Tausammler als Regentonne), **Infektion** (D99: Kräutersud),~~ *Stand 2026-11-23: Wasser ist gemessen und erreichbar — ein leeres Gefäß füllt sich in V 3.40 am Gewässer, nichts zu bauen, die Regentonne ist Kür (D134); der Kräutersud ist gebaut (N-30). Offen bleibt daraus nur der Name „Tonkrug" für das Schraubglas.* Weiter offen: **Luftabwurf** (D95: aus), **Stürme** (D97), **Karte und Kompass** (D96), **Musik** (D114). | GDD 7.8 |
| N-43 | [E] | **Gegner:** vier Stufennamen, Sprenger als platzende Fäulnis (D100); vollständige Zuordnungstabelle (D101). | GDD 7.8, F-06 |
| N-44 | [E] | **Händler:** Zuordnung, Namen, Stimmen stumm (D102); ~~Stromaufträge heraus (D103)~~ *gebaut am 2026-11-23, N-31*; 35 unerfüllbare Herausforderungen (D104). | GDD 7.8 |
| N-45 | [E] | **Begriffe, die später als 700 sind** (D123): Tiegelstahl, Motte, Geselle, Destillierhelm, Weberschiffchen, Tee, Hexenbesen, Kraftlinien, Damast; Heidelbeere freigeben. | GDD 7.8, Prüfung 0003 §5 |
| N-46 | [E] | **Waffen, 22 Empfehlungen** — die gewichtigsten: Machete → Langsax und Spatha als eigenes Stück (ändert D58); Eisenspeer → Ger; Streitkolben → Beschlagene Keule; Streithammer → Zuschlaghammer; „wurmbunt" statt Damast. | [`konzept/waffen.md`](../konzept/waffen.md) §6, D126 |
| N-47 | [E] | **Rüstung, 15 Fragen** — Gambeson / Polsterrock, Kettenhemd / Brünne, Spangenhelm als Erbstück, Kopf-Aufsätze, Wärme nur aus Unterkleidung. | [`konzept/ruestung.md`](../konzept/ruestung.md) §5.4, D127 |
| N-48 | [E] | **Biome, 15 Fragen** — Zuordnung abweichend von D43 (Sandheide statt Küste, Winterhöhen statt Heide), Namen der fünf Landschaften, Schutzstücke und Sude. | [`konzept/biome.md`](../konzept/biome.md) §5, D128 |
| N-49 | [E] | **Erscheinung, 15 Stellen** — Denylist ergänzen (Patronengurt, Gasmasken, Dart, Logo-Fahne), Dekor der Landschaft streichen (63 Zeilen, 12 davon Landminen), Uniform-Zombies, Spielvorlage „700", 100 Abschriften und Lehrblätter mit Papierbild. | [`0002-erscheinung.md`](0002-erscheinung.md) §8 |
| N-50 | [E] | Übrige Vorschläge D110, D111, D113, D115 bis D122, D124. | GDD 7.8 |
| N-51 | — | `CLAUDE.md` nennt „Entscheidungen D1–D50"; es sind D1–D91 (plus Vorschläge bis D130). Regeldatei — von Claude nicht geändert. | `CLAUDE.md:8` |

## 6. Gesammelter Spieltest (ein Lauf, nicht viele)

Nach deiner Vorgabe vom 22.11.: keine langen Wartetests für Einzelfragen, kurze Timer, alles in einem Lauf.
Erwartete Dauer: **rund 30 Minuten**, wenn N-01 ohnehin läuft.

| Nr. | Was | Wie lange |
|---|---|---|
| S-01 | Start ohne `ERR`/XML-Fehler im Protokoll; Dump entsteht; `check-all.ps1` danach 0 rot (N-01). | 5 min |
| S-02 | Acht Bilder im Beutel (N-23): im Kreativmenü je einmal ansehen. | 3 min |
| S-03 | Bogenzeug herstellen, einen beschädigten Bogen flicken (N-20); eine Spitzhacke mit Schleifstein flicken (N-21). | 5 min |
| S-04 | Reparatur-Kit: weder im Kreativmenü-Filter „Spieler" herstellbar noch beim Händler (N-22). | 2 min |
| S-05 | Biom-Fortschritt (N-02): neue Welt mit Option „Aus" **oder** fünf Minuten im Brandwald mit „An" — Zähler, Text, Schaden ansehen. | 5 min |
| S-06 | Wandfackel und Kerzenstumpf mit **kurzem Test-Timer** ~~(Testbau mit verkürzter Brenndauer, von Claude vorbereitet, sobald du den Test ansetzt)~~ (N-03). **Vorbereitet am 2026-11-23:** `tools\build\build.ps1 -Install -MitTest` legt die Test-Überlagerung dazu — alle acht Lichtquellen brennen dann rund 2 Minuten. Ablauf in sechs Schritten: [`test/README.md`](../../test/README.md). Bitte die Zeit vom Setzen bis zum Erlöschen notieren (daraus folgt die echte Brenndauer). Danach `build.ps1 -Install` ohne den Schalter. | 5 min |
| S-07 | Neue Texte (N-26): Unterkleidung, ein Aufsatz, Haselbogen im Beutel lesen. | 3 min |
| S-08 | Prüfliste 25 b–d aus Plan-0001 (zweiter Mitspieler, Dedicated) — nur wenn ein Mitspieler da ist. | offen |
| S-10 | **Wasser und Sud:** ein leeres Gefäß am Fluss oder Tümpel benutzen — wird es zu trübem Wasser (D134)? Kräutersud im Kreativmenü ansehen (Name, Bild) und an der Feuerstelle mit Topf suchen (N-30). | 3 min |
| S-11 | **Spielvorlage** (N-32), im Hauptmenü ohne Welt: „Neues Spiel" öffnen — steht „Jahr 700" unter „Gemoddet" und ist vorgewählt? Steht darin „Biomfortschritt" auf „Nein"? Dann Luftabwurf auf „nie", Händlerstimmen und Automaten aus stellen, „Code kopieren" und den Code nennen. | 3 min |
| S-09 | **Eigenes Bild im Beutel** (N-28, N-29, N-62): Silberpfennig im Kreativmenü ansehen — drei graue Scheiben statt eines leeren Feldes; dazu Schmiedeeisen, Tiegelstahl, Klinge, Schmiedeflicken. Im Protokoll steht dann eine Zeile `[MODS] Creating new atlas 'ItemIconAtlas' for mod '700_20_Material'` oder ähnlich (Finding F-16). | 1 min |

## 7. Phase 2 — Entscheidungen aus dem Loop

Der Plan für Phase 2 ([`docs/plans/`](../plans/), Plan-0002) führt seine Entscheidungen als `P2-E01 …`. Sie
werden hier mit Nummer N-60 ff. gespiegelt, sobald der Plan steht, und bei jedem Arbeitsschritt ergänzt.

**Gemessen am 2026-11-22 für die Asset-Arbeit** (Befehle: `UnityPlayer.dll` ProductVersion; Deinstallationsliste
und Programmordner; Zeichenketten in `Assembly-CSharp.dll`):

- Das Spiel läuft auf **Unity 2022.3.62f2**.
- **Kein Unity-Editor ist installiert.** Blender ist da (Steam, `X:\SteamLibrary\steamapps\common\Blender`).
- Vanillas Symbole sind lose PNG-Dateien, **160×160, 32 Bit mit Alpha**. Der Spielcode nennt für Mods die
  Ordner `UIAtlases` („Creating new atlas … for mod") und `ItemIcons`; ob ein eigenes PNG unter
  `UIAtlases/ItemIconAtlas/` unseres Modlets im Beutel erscheint, ist **im Spiel nicht gesehen**.

| Nr. | Art | Was | Empfehlung / wonach gebaut wird |
|---|---|---|---|
| N-60 | [E] [P] | **Unity-Editor 2022.3.62f2 installieren** (Download, Lizenz-Anmeldung — kann nur der Nutzer). Ohne ihn gibt es kein Asset-Bundle und damit **kein eigenes 3D-Modell im Spiel**. | Bis dahin baut der Loop alles, was ohne Editor geht: eigene **Symbole** (PNG), Quell-Modelle aus Meshy, Texte, XML, REA-Befunde. Modelle liegen dann fertig als Quelle bereit, aber nicht im Spiel. |
| N-61 | [E] | **Python-Ausnahme für Blender-Skripte?** Ein Render- oder Export-Skript für Blender ist Python; im Projekt gilt das Python-Verbot. | Ohne dein Ja liegt kein Blender-Skript im Repository. ~~Symbole entstehen dann ohne Blender (Bild aus Meshy, Zuschnitt mit PowerShell/.NET).~~ **Stand 2026-11-23:** weil Meshy gesperrt ist (N-64), entstehen die Symbole doch in Blender. Das Skript (rund 280 Zeilen Python: Formen, Material, Licht, Kamera) liegt **nur im Arbeitsordner dieser Sitzung** und ist weg, wenn der geleert wird — die vier Quellbilder im Repository bleiben, ließen sich dann aber nicht mehr gleich nachbauen. **Empfehlung:** Ausnahme erlauben und das Skript unter `tools/assets/blender/` ablegen (es läuft nie im Spiel und nie im Prüfbefehl). |
| N-62 | [S] | **Eigenes Symbol im Beutel:** ein Test-PNG unseres Modlets ansehen (Teil des gesammelten Spieltests, S-09). | Gebaut wird nach der Annahme `UIAtlases/ItemIconAtlas/<Name>.png`; stimmt sie nicht, zeigt der Gegenstand kein Bild — sofort sichtbar. |
| N-63 | — | **Meshy:** freigegeben am 2026-11-22 („so viel wie du brauchst"). Je Stück werden Modell, Zweck und Credits im Asset-Register festgehalten. | — (bisher 0 Credits verbraucht, siehe N-64) |
| N-64 | [E] [P] | **Meshy lehnt jede Erzeugung ab.** Gemessen am 2026-11-23: Guthaben 5332 Credits (100 monatlich, 5232 dauerhaft), aber der erste Auftrag (Text zu Bild) kommt mit **HTTP 402** zurück: „Task creation on the free plan is no longer supported. To continue creating tasks, please upgrade your plan." Das Konto steht also auf dem Gratis-Tarif, und der erlaubt über die API nichts mehr. **Den Tarif wechseln kannst nur du** (Zahlung). | Bis dahin: einfache, harte Formen als Symbol **in Blender** (Münze, Barren, Klinge — D84 sieht das ohnehin so vor); alles Organische (Wesen, Kleidung, Rüstung als Modell) wartet. Nebenwirkung des Tarifs: auf einem Bezahl-Tarif gehören dir die Ergebnisse, auf dem Gratis-Tarif gälte CC BY 4.0 mit Nennung (N-75) — mit dem Wechsel erledigt sich auch diese Frage. |

### 7.1 Die 26 Entscheidungen des Phase-2-Plans

[Plan-0002](../plans/0002-phase-2-leben-in-der-welt.md), Abschnitt „Entscheidungen für den Nutzer", nennt je
Frage, was daran hängt. Hier die Kurzform; **gebaut wird nach der Empfehlung**, jeder Bau trägt „zu prüfen".
Baustopp-Regel des Plans: ein Schritt, an dem zwei oder mehr offene Entscheidungen hohen Gewichts hängen,
wird nur bis zum Dokument oder Vertragsentwurf geführt.

| Nr. | Plan | Frage | Empfehlung, nach der gebaut wird |
|---|---|---|---|
| N-70 | P2-E01 | Phase 2 beginnen, bevor Phase 1 im Spiel abgenommen ist (D50)? | Ja für Papier und alles Unabhängige; der Sammellauf T0 holt den Nachweis nach. |
| N-71 | P2-E02 | Auf Vertragsentwürfen bauen? | Ja, mit Marke „Abnahme offen"; nichts wird gepusht oder installiert. |
| N-72 | P2-E03 | Teilung in 2a und 2b, „Phase 2 fertig heißt …" | Wie im Plan; als Vorschlagszeile ins GDD. |
| N-73 | P2-E04 | Vier Lücken aus Phase 1 jetzt bauen: Wasser (D98), Infektion (D99), Stromaufträge (D103), Herausforderungen (D104)? | Ja, soweit reines XML; je eigener Commit. |
| N-74 | P2-E05 | Unity-Editor installieren; darf Claude ihn per Skript starten? | Du installierst und meldest an; Claude startet nur den Bundle-Bau. (= N-60) |
| N-75 | P2-E06 | Meshy-Tarif und Lizenz der Ergebnisse (Q31) | Claude liest die Bedingungen und hält sie im Register fest; welcher Tarif gebucht ist, bestimmt, was ausgeliefert werden darf. |
| N-76 | P2-E07 | Was darf „Retextur" heißen (D84 b)? | Nur ohne Vanilla-Datei im Bundle; sonst eigenes Modell oder es bleibt Vanilla. |
| N-77 | P2-E08 | Blender-Skripte (Python) im Repository? | Nein; Blender bleibt Claudes Werkzeug außerhalb. (= N-61) |
| N-78 | P2-E09 | CC0-Downloads (Texturen, Klänge) | Sammelfreigabe je Quelle nötig; bis dahin kein Download. |
| N-79 | P2-E10 | Asset-Schnittlinie; Quelle für Kleidung am Körper | Rang 1 fest, Rang 2 bei Restbudget. |
| N-80 | P2-E11 | Umbenennungen aus D123, D126, D127 | Kein gebauter Name wird geändert; Vorschläge bleiben ein Entwurfsstapel. |
| N-81 | P2-E12 | Gegner: Stufennamen, Sprenger, Tiere, 17 neuzeitliche Klassen | Nach D100, D101, D109; die 17 aus den Biom-Gruppen nehmen, Rollenträger bleiben. |
| N-82 | P2-E13 | Landschaften abweichend von D43 | Nach `konzept/biome.md` §2.2; technische Kennungen bleiben. |
| N-83 | P2-E14 | Welt von 2a, Zahl der Orte, wer baut, Fertigkarten | Keine Vanilla-Gebäude; Zahl aus der Bedarfsrechnung, mindestens 10; Fertigkarten nicht unterstützt. |
| N-84 | P2-E15 | Händler: Zuordnung, Namen, Stimmen | Nach D102, D103; Stimmen über die Voreinstellung aus. |
| N-85 | P2-E16 | Runenkundiger als sechstes Attribut; Amulett-Platz (Q32) | Sechstes Attribut, wenn das Fenster es trägt; Amulette als Aufsatz. |
| N-86 | P2-E17 | Kraftlinien: Stromnetz aus der Sperre holen | Nach D37, Freigabe je Kennung; der Name bleibt Vorschlag. |
| N-87 | P2-E18 | Umfang von Learning by Doing (Q21) | Nur Handwerks-Stufen; das Lehrblatt bleibt ein Sprung; ein Server-Patch. |
| N-88 | P2-E19 | Grauen: grob per XML oder Lichtabfrage in C#? | Erst XML; C# nur für Kleines; im Einzelspiel zählt „allein" nicht; die Karte bleibt. |
| N-89 | P2-E20 | Härtere Todesfolgen (Q17) | In Phase 2 nicht bauen. |
| N-90 | P2-E21 | Seuchennacht: Deutung, Vorboten | Nach D107; Vorboten zuerst über vorhandene Bedingungen. |
| N-91 | P2-E22 | Schild in Phase 2 oder 3; Werfen, Maximal-Haltbarkeit, Wurfmesser | Das GDD gilt (Phase 2); Werfen und Maximal-Haltbarkeit sind die ersten Streichposten; das Wurfmesser entfällt. |
| N-92 | P2-E23 | Ansteckung zwischen Spielern (Q10) | Nein. |
| N-93 | P2-E24 | Verderb ohne Vanilla-Verfallssystem | Nur bei kleinem Patch ohne eigene Netzpakete; sonst rutscht er nach Phase 3. |
| N-94 | P2-E25 | „Host + 1 Mitspieler" statt „Dedicated + 2 Clients" (D113) | Ja, so markiert; Dedicated bleibt Bedingung für einen öffentlichen Release. |
| N-95 | P2-E26 | Voreinstellung „700" und Musik | Dokument sofort, Datei nach kopiertem Optionscode; Vanilla-Musik aus, keine eigene Musik in Phase 2. *Stand 2026-11-23: Dokument und Datei sind da (N-32) — der Code für Ja/Nein-Optionen ließ sich rechnen; für Luftabwurf und Technikstufe braucht es weiter den kopierten Code (S-11). Musik ist keine Sandbox-Option und über die Vorlage nicht abstellbar.* |

**Was ohne dich steht** (Plan-0002, Risiko R3 und R5): jedes eigene 3D-Modell im Spiel (Unity, N-60), jeder
Nachweis im Spiel (fünf gebündelte Testläufe T0 bis T4), CC0-Downloads (N-78) und womöglich der Bau eigener
Orte, falls er nur im Editor des Spiels geht.
