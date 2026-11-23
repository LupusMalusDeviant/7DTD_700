# Drehbuch der Spieltests — alle S-Zeilen in fünf Sitzungen

> **Stand:** 2026-11-23, Plan-0002 WP14.2 (Teil: T1 bis T3), D191. **Vorschlag, zu prüfen durch den
> Nutzer (N-135).** Grundlage: die Spieltest-Zeilen S-01 bis S-53 in
> [`0000-entscheidungen-fuer-den-nutzer.md`](0000-entscheidungen-fuer-den-nutzer.md) §6 und die
> Befehlstabelle in [`test/README.md`](../../test/README.md).
> Nach deiner Vorgabe vom 22.11.: keine langen Wartetests, kurze Timer, alles gebündelt, **die Dauer steht
> vorher da.**

Dieses Drehbuch sagt nur **in welcher Reihenfolge, mit welchem Aufbau und wie lange**. Was je Punkt zu
sehen ist, steht in der S-Zeile; die Konsolenbefehle stehen in `test/README.md`. Nichts ist doppelt
geschrieben, damit nichts auseinanderläuft.

## Kurz

| Sitzung | Aufbau | Zeilen | Dauer |
|---|---|---|---|
| **A** Hauptmenü und neues Spiel | Einzelspieler, `build.ps1 -Install -MitTest` | S-22, S-11, S-01, S-17, (S-13) | **rund 15 min** (+10 mit S-13) |
| **B** Kreativ und Konsole | dieselbe Installation, Test-Spielstand, Kreativmodus, Konsole (F1) | sechs Blöcke, unten | **rund 215 min**, in zwei Abenden (95 und 120) |
| **C** Dedicated + ein Client | Server und Client je mit `-MitTest` | Proben-Lauf S-32, S-33, S-34, S-35 (1)(2), dazu S-43 (6), S-45 (3)(4) | **rund 25 min** |
| **D** Neue Welt | eine **kleine** Zufallswelt erzeugen, nicht laden | S-29, S-24, S-27 (2)–(4), S-31 (3)–(8), S-05, S-30, S-12 | **rund 60 min** |
| **E** wartet | — | S-25 (Unity), S-29 (4) (WP6.5b), S-32 (4) und S-34 (4) (erster C#-Code), S-34 (3) (Himmel), S-23 (Mitspieler) | — |

**Zusammen rund 5 ¼ Stunden** — die Summe der Zeiten aus den S-Zeilen (A 15, B 215, C 25, D 60), keine
neue Schätzung. Am Ende jeder Sitzung:
`build.ps1 -Install` **ohne** `-MitTest`, damit die Überlagerung nicht liegen bleibt (`smoke.ps1` meldet
sie sonst rot).

### Wenn nur eine halbe Stunde da ist

| Zeile | Warum zuerst | Dauer |
|---|---|---|
| S-01 | danach wird der Prüfbefehl grün (N-01: 56 rote Zeilen hängen am alten Dump) | 5 min |
| S-27 (1) | lädt das Spiel mit unseren Wesen-Gruppen überhaupt | 1 min |
| S-41 (1)(2) | die Odem-Leiste ist die einzige neue Oberfläche der Phase 2 | 4 min |
| S-43 (1)–(3) | das Grauen ist Säule P2 | 7 min |
| S-44 (1) | stiller Beginn und Glocke | 5 min |
| S-42 (1) | ein Zauber, stellvertretend für alle drei | 3 min |
| S-47 (1) | Texte mit Umlauten und Absätzen im Fenster | 2 min |
| Protokoll aufheben | Claude liest es | — |

## Sitzung A — Hauptmenü und neues Spiel (rund 15 min)

1. `tools\build\build.ps1 -Install -MitTest` (installiert Mod und Überlagerung).
2. **Im Hauptmenü, ohne Welt:** S-22 (2 min), dann S-11 (3 min).
3. **Neues Spiel** mit der Vorlage „Jahr 700", Navezgane oder eine vorhandene Welt: S-01 (5 min) —
   erst laden, dann das Protokoll aufheben — dasselbe Protokoll beantwortet S-27 (1) (kein `ERR` zu
   `entitygroups`). S-17 (6 min) gleich danach, solange das Spiel neu ist.
4. *Wenn ein alter Spielstand da ist:* S-13 (10 min).

## Sitzung B — Kreativ und Konsole (rund 215 min, zwei Abende)

Ein Test-Spielstand aus Sitzung A, Kreativmodus (`cm`), Konsole F1. Reihenfolge innerhalb der Blöcke so,
dass ein Schritt den nächsten vorbereitet.

**Abend 1 (rund 95 min)**

| Block | Zeilen, in dieser Reihenfolge | Dauer | Hinweis |
|---|---|---|---|
| B1 Dinge und Texte | S-02, S-09, S-07, S-21, S-31 (1)(2), S-47, S-51, S-14, S-15, S-16, S-03, S-04, S-08, S-10 | 56 min | fast alles im Kreativmenü; S-08 braucht einen Auftrag der Stufe 1 |
| B4 Wesen | S-26, S-46, S-48, S-28 | 28 min | `spawnentity`; S-46 und S-48 bei Tag, S-28 bei Nacht — S-28 ans Ende, `settime` auf 22 Uhr |
| B5 Seuchennacht | S-44 | 10 min | `settime 7 21 50`; geht gleich nach S-28 in derselben Nacht |

**Abend 2 (rund 120 min)**

| Block | Zeilen, in dieser Reihenfolge | Dauer | Hinweis |
|---|---|---|---|
| B2 Magie | S-41, S-35 (3), S-36, S-37, S-38, S-39, S-40, S-42 | 43 min | S-41 zuerst, ohne Punkt in Runenkunde; dann `giveselfskillpoints 20` einmal für alles |
| B3 Licht, Nacht, Grauen | S-06, S-19, S-18, S-20, S-43 (1)–(5), S-45 (1)(2) | 36 min | S-06 gleich am Anfang setzen (brennt 2 min, läuft nebenher); S-43 vor S-45, beide nachts draußen |
| B6 Handwerk und Heilkunde | S-49, S-50, S-52, S-53 | 45 min | *(seit WP12.3)* am Ende des Abends; S-52 (2) im Schnee-Biom, nachts; S-49 (3) und S-50 (3) verlangen Speichern und Neuladen — einmal Laden für beide, das beendet die Sitzung ohnehin |

## Sitzung C — Dedicated Server + ein Client (rund 25 min)

Server und Client auf **einem** Rechner reichen für alles außer S-43 (6) und S-45 (3) — dort steht der
zweite Spieler daneben (ein zweiter Rechner oder ein Mitspieler). Ablauf und Befehle: der
**Proben-Lauf** in `test/README.md` (S-32, S-33, S-34, S-35 (1)(2), rund 20 min), danach S-43 (6) und S-45 (3)(4)
(rund 5 min). Beide Protokolle aufheben; Claude liest `CVarLogValue:` und `MinEventLogMessage: t700`.

*Das ist zugleich der Dedicated-Test, den Projektregel 5 für jede statische Server/Client-Aussage
verlangt.*

## Sitzung D — Neue Welt (rund 60 min)

1. Eine Zufallswelt der **kleinsten** Größe erzeugen (S-29 (1)–(3), 15 min) — das Protokoll beim
   Erzeugen aufheben.
2. In dieser Welt: S-24 (3 min, Flugmodus, Ödland), S-27 (2)–(4) (10 min), S-05 (5 min), S-30 (10 min,
   Biom-Fortschritt an), S-12 (5 min).
3. Am nächsten **Händlerposten** (Karte): S-31 (3)–(8) (rund 10 min) — Pulte und Särge, ein Auftrag, die
   Ware, Name und Posten, die Stimme, Truhen und Schränke.

## Rückmeldung

Eine Zeile je Punkt reicht, auch als Stichwort. Claude trägt sie in die S-Zeilen und die N-Zeilen ein.

```
S-43 (1) ja, steigt, mit Fackel langsamer
S-43 (3) Rand dunkel, Panik kam nicht
S-44 (1) Glocke ja, zu laut
```

Dazu je Sitzung das Protokoll (`%APPDATA%\7DaysToDie\logs\` beim Client, `output_log` des Servers).

## Abgleich mit dem Plan (T1 bis T4)

| Plan-0002 | hier |
|---|---|
| T1 (Symbole, Modell in der Hand) | B1 (S-02, S-09) und E (S-25, wartet auf Unity) |
| T2 (Welt, Landschaften, Händler, Gegner) | D, dazu B1 (S-08, S-31) und B4 |
| T3 (Test-Überlagerung: Seuchennacht, Odem, Grauen) | B2, B3, B5, C |
| T4 (Playtest mit Mitspieler, ohne Überlagerung) | **nicht hier** — mehrere Stunden Spielen, vom Nutzer anzusetzen (WP14.4) |

**Pflege:** jede neue S-Zeile bekommt hier einen Platz in einer Sitzung, im selben Commit.
