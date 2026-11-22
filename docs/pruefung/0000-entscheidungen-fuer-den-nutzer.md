# Entscheidungen für den Nutzer — die eine Liste

| | |
|---|---|
| **Angelegt** | 2026-11-22, Nachtlauf |
| **Auftrag** | „abschließen … soweit wie du es ohne meinen Input schaffst … Wenn du unsicher bist, agiere nach deinen Empfehlungen, aber markiere die Entscheidung als zu prüfen durch mich" und danach „Loop bis Ende Phase 2. Alles wo du meine Entscheidung brauchst, entsprechend notieren. Du darfst Meshy via API nutzen, so viel wie du brauchst." |
| **Regel dieser Liste** | Jeder Punkt, der eine Entscheidung, eine Abnahme oder einen Blick ins Spiel braucht, steht **hier** mit Nummer. Wo ohne Antwort weitergebaut wurde, steht, **nach welcher Empfehlung**. Erledigtes wird durchgestrichen, nicht gelöscht. |
| **Stand** | wird bei jedem Arbeitsschritt des Loops fortgeschrieben; der Kopf von Abschnitt 0 nennt den letzten Stand |

Marken: **[E]** Entscheidung · **[A]** Abnahme eines Vertrags · **[S]** nur im Spiel zu sehen · **[P]** Freigabe (Push, Installation).

## 0. Stand und das Wichtigste zuerst

**Stand 2026-11-22, spät:** Phase 1 ist gebaut, aber **nicht abgenommen**; nichts ist gepusht (HEAD lokal
vor `origin`), die Mod liegt **nicht** im Spielordner.

Der Prüfbefehl `powershell -File tools/check/check-all.ps1` endet mit **225 Gegenproben, 0 fehlgeschlagen;
7 Prüfungen, 1 rot (Exit 1)**. Rot ist `erreichbarer-anachronismus: resourceRepairKit`: der Spiel-Dump von
22:08 stammt aus einem Start **vor** der Sperre des Reparatur-Kits. Am Vorlauf des neuen Standes sind alle
sieben Prüfungen grün; ein Vorlauf ist kein Nachweis. **Grün wird der Prüfbefehl erst mit einem Spielstart
mit dem neuen Stand** (N-01).

Die fünf Punkte, die am meisten bewegen:

1. **N-01** — einmal installieren und starten, damit ein neuer Dump entsteht (ohne ihn bleibt der Prüfbefehl rot).
2. **N-02** — der **Biom-Fortschritt ist mit unserer Mod nicht lösbar** und war im Testlauf an.
3. **N-10** — Push: braucht deine Freigabe und die Wahl des Codex-Modells.
4. **N-20 bis N-27** — was der Nachtlauf nach Empfehlung **gebaut** hat (Namen, Rezepte, Bilder).
5. **N-40** — die sechs Kernfragen des Spiels ohne Antwort (Ziel, Tod, Seuchennacht, Religion, Figuren, Schwierigkeit).

## 1. Sofort — hält etwas auf

| Nr. | Art | Was | Empfehlung / wonach gebaut wurde |
|---|---|---|---|
| N-01 | [P] [S] | **Installieren und einmal starten** (`tools\build\build.ps1 -Install`, Spielstart ohne EAC wie am 22.11.), neue Welt oder vorhandene laden, bis der `ConfigsDump` geschrieben ist. Danach `check-all.ps1`. | Erwartet: 7 Prüfungen, 0 rot. Die Mod bleibt bis zu deinem Ja aus dem Spielordner. |
| N-02 | [E] [S] | **Biom-Fortschritt:** je Reihe nennen 4 von 7 Aufgaben gesperrte Kennungen, alle Gegenmittel und Schutzstücke sind gesperrt. Außerhalb des Kiefernwalds läuft unter freiem Himmel eine Frist ab, danach verliert man Leben bis unter ein Dach. Gemessen aus XML und Spielprotokoll, **im Spiel nicht gesehen** ([`konzept/biome.md`](../konzept/biome.md) §1.10). | **Weg A: in Phase 1 abschalten** — Spieloption „Biom-Fortschritt" beim Anlegen der Welt auf Aus. Umdeuten und zurückholen (Weg B) mit F-07 in Phase 2. Gebaut ist nichts. |
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
| N-15 | [A] | Vertrag 04, **Nachtrag Dump-Suche** (`check-all.ps1` kennt `-UserDataFolder`). |
| N-16 | [A] | Vertrag 04, **Nachtrag Leermeldung** (`=kein-aufschub` in `aufschub.txt`). |
| N-17 | [A] | Vertrag 04, **Nachtrag zweites Review der Vorprüfung** (zwei Befunde an `vertraeglichkeit-pruefen.ps1` behoben). |

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
| N-26 | [E] | **Texte für Lücken** (Unterkleidung, Aufsätze, Bögen T0/T1, Geschosse, Sturmtexte …) | folgt, D129 | Namen einzeln |
| N-27 | [E] | Berichtigung: die Biom-Ausrüstung trägt in Vanilla Namen (Lesefehler in Balancing 0003). | `037110f` | — |

## 5. Vorschläge auf dem Papier — nichts davon ist gebaut

| Nr. | Art | Was | Wo es steht |
|---|---|---|---|
| N-40 | [E] | **Sechs Kernfragen:** Spielziel (D106), Tod und Wiederkehr (D105), Deutung der Seuchennacht (D107), Leitplanke für Religion (D108), Frauen- und Männerfiguren (D109), Schwierigkeit und empfohlene Voreinstellung (D112). | GDD 7.8 |
| N-41 | [E] | **Was darf in Phase 1 modern bleiben?** Geschlossene Liste getragener Lücken (D93) — sonst ist das MVP-Ziel „ohne Anachronismus in Texten" nie erfüllbar. | GDD 7.8 |
| N-42 | [E] | **Wasser** (D98: Tausammler als Regentonne), **Infektion** (D99: Kräutersud), **Luftabwurf** (D95: aus), **Stürme** (D97), **Karte und Kompass** (D96), **Musik** (D114). | GDD 7.8 |
| N-43 | [E] | **Gegner:** vier Stufennamen, Sprenger als platzende Fäulnis (D100); vollständige Zuordnungstabelle (D101). | GDD 7.8, F-06 |
| N-44 | [E] | **Händler:** Zuordnung, Namen, Stimmen stumm (D102); Stromaufträge heraus (D103); 35 unerfüllbare Herausforderungen (D104). | GDD 7.8 |
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
| S-06 | Wandfackel und Kerzenstumpf mit **kurzem Test-Timer** (Testbau mit verkürzter Brenndauer, von Claude vorbereitet, sobald du den Test ansetzt) (N-03). | 5 min |
| S-07 | Neue Texte (N-26): Unterkleidung, ein Aufsatz, Haselbogen im Beutel lesen. | 3 min |
| S-08 | Prüfliste 25 b–d aus Plan-0001 (zweiter Mitspieler, Dedicated) — nur wenn ein Mitspieler da ist. | offen |

## 7. Phase 2 — Entscheidungen aus dem Loop

Der Plan für Phase 2 ([`docs/plans/`](../plans/), Plan-0002) führt seine Entscheidungen als `P2-E01 …`. Sie
werden hier mit Nummer N-60 ff. gespiegelt, sobald der Plan steht, und bei jedem Arbeitsschritt ergänzt.
