# test/ — die Test-Überlagerung

Hier liegt, was **nur zum Testen** neben die Mod gelegt wird und **nie im Paket** landet. Regeln:
[Vertrag 01, „Nachtrag Phase 2, Teil 1", Abschnitt B](../docs/contracts/01-modlet-grenzen.md).

| Ordner | Tut |
|---|---|
| `700_99_Test/` | verkürzt Uhren: die acht Lichtquellen aus F-08 brennen `GrowthRate` 2 statt 15 bis 60; seit WP9.10 dazu **11 Proben** (8 Buffs, 3 Gegenstände) für S-32 bis S-35 |

## Benutzen

```powershell
tools\build\build.ps1 -Install -MitTest
```

legt die Mod **und** die Überlagerung in den Spielordner.

```powershell
tools\build\build.ps1 -Install
```

legt die Mod hinein und **entfernt** die Überlagerung wieder.

`tools\build\smoke.ps1` meldet eine liegengebliebene Überlagerung als eigenen roten Punkt;
`smoke.ps1 -MitTest` erwartet sie.

## Der Fackel-Test (S-06), rund fünf Minuten

1. Mit `-MitTest` installieren, Test-Spielstand laden.
2. In einem **geschlossenen** Raum je eine Wandfackel, Unschlittkerze (Wand und Tisch), Öllampe und
   ein Holzfeuer setzen, Uhrzeit merken.
3. Warten, bis sie ausgehen — erwartet nach rund zwei Minuten. Die gemessene Zeit notieren: aus ihr
   folgt, wie lange die echten Werte (15, 30, 45, 60) brennen.
4. Ansehen: steht statt der Fackel der leere Halter, statt der Kerze der Stumpf, statt der Lampe die
   leere Lampe, statt des Feuers die kalte Glut? Verschwindet nichts?
5. Kerzenstumpf: Name, Aufnehmen mit E, Abschlagen (N-03).
6. Danach ohne `-MitTest` neu installieren.

## Proben (seit Nachtrag Teil 1d, 2026-11-23)

Neben `<set>` darf die Überlagerung **Proben** anhängen: Buffs oder Gegenstände, deren Name mit
`t700_` beginnt. Sie dienen nur dem Test (z. B. ein Buff, der einen CVar ins Protokoll schreibt),
liegen in keiner Beute und keinem Rezept und kommen per Konsole (`buff t700_…`, `giveself t700_…`).
Die Mod nennt `t700_` nie. Regeln: [Vertrag 01, Abschnitt B2](../docs/contracts/01-modlet-grenzen.md).

## Der Proben-Lauf (S-32 bis S-35), rund 20 Minuten, Dedicated Server + ein Client

Vorbereitung: mit `-MitTest` installieren — auf dem Server **und** beim Client. Konsole mit F1.
Danach die Protokolle beider Seiten aufheben; Claude liest die Zeilen `CVarLogValue:` und
`MinEventLogMessage: t700`.

| Schritt | Konsole | Ansehen |
|---|---|---|
| S-32 (1)–(3) | `buff t700_cvarSetzen` | nichts — die Antwort steht im Protokoll: welche der vier Werte stehen beim **Server**? |
| S-32 (5) | Server neu starten, wieder rein, `buff t700_cvarZeigen` | welche Werte sind nach dem Neustart noch da (Protokoll) |
| S-33 (1)–(3) | `buff t700_craftZaehler`, dann dreimal einen Steinspeer herstellen; einmal an einer Werkstatt herstellen lassen, weggehen, wiederkommen | Zähler im Protokoll: 1, 2, 3, dann +1 nach der Rückkehr |
| S-33 (2) | neu laden, `buff t700_craftZaehler` | steht die Zahl noch |
| S-33 (4) | `giveself t700_wurfspeer`, rechte Maustaste halten und loslassen | fliegt er, trifft er, bleibt er stecken oder liegen, lässt er sich aufheben |
| S-34 (1) | `buff t700_lichtAnzeige`; nachts ohne Licht, mit Fackel, am Feuer, im Haus | Meldung über der Schnellleiste wechselt das Band; zeigt sie immer „ab 60", vergleicht das Spiel als Bruch — sagen |
| S-34 (2) | beide: `buff t700_gesellschaftSender`; nebeneinander, dann 20 m auseinander | „TEST Gesellschaft" bei beiden nah, bei keinem fern; **allein**: erscheint es trotzdem? |
| S-34 Seuchennacht | `buff t700_seuchennacht`, dann auf den Abend einer Seuchennacht springen | „TEST Seuchennacht läuft" ab Beginn |
| S-35 (1) | `giveself t700_zauberstab`, `buff t700_odemFuellen`, viermal schlagen | Protokoll 20, 10, 0; der vierte Schlag geht nicht — und wie merkt man es? |
| S-35 (2) | `giveself t700_amulett`, anlegen; dazu ein `biomeWeatherItem4` | welchen Platz nimmt es, verdrängt es das Abzeichen |

**Nicht in diesem Lauf** (kein Ersatz durch eine Probe): S-32 (4) „Server setzt einen Wert" braucht
den ersten C#-Code (Regler); S-34 (3) Farbe des Himmels braucht eine Wetter-Zeile ohne `t700_`-Namen
und wird mit F-09 im Modlet selbst geprüft; S-34 (4) Vortag braucht den Direktor; S-35 (3) neuntes
Feld im Fertigkeitsfenster kommt mit dem Bau des Runenkundigen (WP10.3).

## Eine Zeile ergänzen

Nur `<set>`, nur auf Knoten, die unsere Modlets angelegt haben. Die Prüfung
`tools/check/testueberlagerung-pruefen.ps1` (Teil von `check-all.ps1`) zeigt je Zeile
„alt -> neu" und wird rot, wenn eine Zeile nichts trifft oder nichts ändert.
