# F-02 — Waffen & Kampf

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X+H (+A) | S+C | ja |

## Ziel
Nahkampf mit Gewicht (Säule P3): Waffenwahl, Reichweite, Ausdauer und Schild entscheiden.
Fernkampf ist knapp, handgemacht und munitionshungrig.

## Umfang
**Nahkampf** (XML, auf Basis vorhandener Vanilla-Nahkampf-Aktionen):
| Waffe | Rolle | Vanilla-Basis (Modell/Aktion) |
|---|---|---|
| Knüppel / Keule | T0, Wucht, Betäubung | Club |
| Handbeil / Bartaxt | T0–T2, Werkzeug + Waffe | Axe |
| Sax (Kurzschwert) | T1–T2, schnell | Machete/Knife |
| Speer / Ango | T1–T3, Reichweite | Spear |
| Spatha | T3–T4, Allrounder | Machete (Modell offen, Q3) |
| Breitaxt | T3–T4, schwer, Rüstungsbrecher | Fireaxe |

**Fernkampf:** Selbstbogen (T1), Langbogen (T3), Schleuder (T0), Wurfspeer (T1), Armbrust
(T4, selten; historisch grenzwertig, Säule P1 → *Q: rein?*). Munition: Pfeile (Feuerstein,
Knochen, Eisen), Bolzen, Schleudersteine.

**Schild (C#):** Rundschild als Offhand mit aktivem Blocken (Schaden und Stagger
reduzieren, Ausdauerkosten). Vanilla kennt kein Blocken, deshalb ist das der zentrale
Harmony-Teil dieses Features.

**Perks:** Feuerwaffen-Skills umwidmen zu Bogenschießen, Schildkampf und Wurfwaffen.

## Nicht im Umfang
- Reittier-Kampf, Formationen, Gegner-KI mit Waffen (→ F-06)

## Umsetzung
### XML
Items, Rezepte, Perks, Buffs (z. B. „Blutung“ für Klingen, „Betäubt“ für Wuchtwaffen).
### C# / Harmony — Warum nicht XML?
Blocken braucht (a) einen Eingabe-Zustand „Schild erhoben“, (b) einen Eingriff in die
Schadensberechnung abhängig von diesem Zustand und der Trefferrichtung und (c) die Anzeige
beim Client. Das lässt sich per Buff und Item-Aktion nach unserem Kenntnisstand nicht
abbilden. **[verifizieren]** per REA: Gibt es eine Hook-Stelle im Schadenspfad, an der ein
Buff- oder CVar-Check reicht? Dann ließe sich der C#-Anteil minimieren (Säule P5).
### Assets
Ohne eigene Assets (Q3) laufen Spatha und Schild auf Vanilla-Modellen. Das ist ein bekannter
Bruch mit Säule P1 im MVP.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-02](../rea/hook-hypothesen.md#f-02)

## Akzeptanzkriterien
- [ ] Jede Waffe ist craftbar und hat einen klaren Zweck (Balancing-Tabelle in `docs/balancing/`)
- [ ] Blocken reduziert Schaden von vorn, nicht von hinten; Ausdauer sinkt; das funktioniert auf dem Dedicated Server mit 2 Clients
- [ ] Bogen ist in T1 relevant, aber durch Pfeilverbrauch begrenzt
