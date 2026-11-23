# test/ — die Test-Überlagerung

Hier liegt, was **nur zum Testen** neben die Mod gelegt wird und **nie im Paket** landet. Regeln:
[Vertrag 01, „Nachtrag Phase 2, Teil 1", Abschnitt B](../docs/contracts/01-modlet-grenzen.md).

| Ordner | Tut |
|---|---|
| `700_99_Test/` | verkürzt Uhren: die acht Lichtquellen aus F-08 brennen `GrowthRate` 2 statt 15 bis 60 |

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

## Eine Zeile ergänzen

Nur `<set>`, nur auf Knoten, die unsere Modlets angelegt haben. Die Prüfung
`tools/check/testueberlagerung-pruefen.ps1` (Teil von `check-all.ps1`) zeigt je Zeile
„alt -> neu" und wird rot, wenn eine Zeile nichts trifft oder nichts ändert.
