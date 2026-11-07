# F-02 — Waffen & Kampf

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 1: Waffen, Qualität, Verschleiß · 2: Schild, Schadensarten, Werfen | X+H (+A) | S+C | ja |

## Ziel
**Vanilla+** (D20): Die vertraute Vanilla-Steuerung (Hieb, Power-Attack) bleibt, ergänzt um
Schild-Blocken, Schadensarten, Verschleiß und Wurfwaffen (D21). Nahkampf ist die Basis;
**Fernkampf (Jäger) und Kampfmagie (Runenkundiger) sind gleichwertige Spezialisierungen** (D22).

## Waffen
**Nahkampf:**
| Waffe | Schadensart | Rolle | Vanilla-Basis |
|---|---|---|---|
| Knüppel / Keule | Wucht | T0, Betäubung | Club |
| Handbeil / Bartaxt | Schnitt | T0–T2, Werkzeug + Waffe | Axe |
| Sax (Kurzschwert) | Schnitt/Stich | T1–T2, schnell | Machete/Knife |
| Speer / Ango | Stich | T1–T3, Reichweite | Spear |
| Spatha | Schnitt | T3–T4, Allrounder | Machete (Phase 1), neues Modell (Phase 2) |
| Breitaxt | Schnitt/Wucht | T3–T4, schwer, Rüstungsbrecher | Fireaxe |
| Streitkolben / Hammer | Wucht | T3–T4, gegen Rüstung (Kultisten, Plünderer) | Sledgehammer |

**Fernkampf:** Schleuder (T0), Selbstbogen (T1), Langbogen (T3), Armbrust (T4, selten, D8).
Munition: Pfeile (Feuerstein, Knochen, Eisen), Bolzen, Schleudersteine.

**Wurfwaffen (D21):** Wurfaxt, Wurfspeer, Wurfmesser. Sie werden geworfen und müssen
**aufgehoben** werden (bleiben im Ziel bzw. am Boden stecken).

## Mechaniken (D21)

| Mechanik | Beschreibung | Tiefe | Phase |
|---|---|---|---|
| **Qualität** (D23) | **Material** = Grundstufe (Knochen < Bronze < Schmiedeeisen < Stahl < Damast); **Handwerksqualität** = Feinstufe (Vanilla-Qualität 1–6 umbenannt: grob, einfach, solide, gut, meisterlich, legendär), steigt durch Learning by Doing (F-21) | X | 1 |
| **Verschleiß & Reparatur** | Vanilla-Haltbarkeit stärker gewichtet; Reparatur mit Schleifstein (einfach, verliert Maximal-Haltbarkeit) oder beim Schmied bzw. an der Esse (voll) | X (+H) | 1 |
| **Schadensarten** | Schnitt (stark gegen ungeschützt, schwach gegen Kette), Stich (gegen Kette und Gambeson), Wucht (gegen schwere Rüstung, Betäubung). Gegner und Rüstungen tragen Schutzwerte je Art | X+H | 2 |
| **Schild blocken** | Rundschild als Offhand mit aktivem Blocken: Schaden und Stagger von vorn reduziert, Ausdauerkosten; Schild verschleißt | H | 2 |
| **Werfen** | Wurfwaffen als Projektil, das als aufhebbares Item liegen bleibt | X (+H) | 2 |

Furcht (F-17 B3, D14) wirkt vor allem auf Fernkampf (Zittern) und Zauber, kaum auf den Nahkampf.

## Umsetzung
### XML
Items, Rezepte, Qualitätsnamen, Haltbarkeit, Reparatur-Items, Perks (F-21 Krieger bzw. Jäger), Buffs (Blutung, Betäubt).
### C# / Harmony — Warum nicht XML?
- **Blocken:** Eingabe-Zustand + Schadensberechnung abhängig von Richtung → REA am Schadenspfad. Erst prüfen, ob ein Buff/CVar-Check im Schadenspfad reicht (P5).
- **Schadensarten:** Vanilla kennt Schadensklassen bzw. Tags [verifizieren]; falls die nicht frei erweiterbar sind, Postfix am Schadenspfad mit Tag-Tabelle.
- **Werfen und Aufheben:** prüfen, ob die Vanilla-Speer-Wurfmechanik (falls vorhanden) übertragbar ist.
### Assets
Phase 2 (D3, F-16): neue Modelle für Spatha, Sax, Rundschild, Langbogen, Armbrust, Wurfaxt; Retexturen für Keule, Beile, Speer.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-02](../rea/hook-hypothesen.md#f-02)

## Akzeptanzkriterien
- [ ] Jede Waffe ist herstellbar und hat einen klaren Zweck (Balancing-Tabelle in `docs/balancing/`)
- [ ] Material- und Handwerksqualität sind im Tooltip verständlich
- [ ] Blocken reduziert Schaden von vorn, nicht von hinten; auf Dedicated + 2 Clients
- [ ] Wurfaxt bleibt nach dem Wurf aufhebbar liegen (kein Item-Verlust durch Netz-Desync)
- [ ] Bogen-Build und Magie-Build schaffen T3-Inhalte gleich gut (Playtest)
