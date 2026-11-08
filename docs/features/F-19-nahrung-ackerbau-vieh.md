# F-19 — Nahrung, Ackerbau & Viehhaltung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| 2: Verderb, Ackerbau · 3: Viehhaltung | X+H (+A) | S | ja |

## Ziel
Nahrung ist ein ständiges, aber nicht nerviges Thema: Vanilla-Hunger und -Durst bleiben,
Lebensmittel **verderben** (D32), und eine Siedlung lebt von Acker und Vieh (D33).

## Umfang
### Verderb (D32)
- Frische Lebensmittel (Fleisch, Fisch, Milch, Gemüse) verderben nach Zeit → „verdorben“ (essbar mit Ruhr-Risiko, F-11)
- **Konservieren:** Räuchern (Räucherkammer), Salzen (Salz knapp, Handelsware), Trocknen (Trockengestell), Einlegen
- **Die Räucherkammer bzw. das Trockengestell wird hier gebaut, nicht in Phase 1 (D57,
  8. November 2026).** F-04 führt sie als Werkstatt, und der Plan hatte sie in WP4.4; ihr Inhalt
  — die Konserven — ist aber dieses Feature, und in Phase 1 gibt es kein Rezept, das auf sie
  gehört. Zu bauen sind dann Klon-Block, XUi-Fenstergruppe, Bau-Rezept und die Brennstoffregel
  (Holz, Vanilla-Forge-Prinzip nach D26); das Muster liegt vor
  (`mod/700_40_Bauen/Config/XUi_InGame/`, WP4.5)
- Kühle Lagerung (Erdkeller) verlangsamt den Verderb
- [verifizieren] per REA: Hat V 3.40 ein Verfallssystem für Items, auf das man aufbauen kann? Sonst C# (Zeitstempel je Stack, Prüfung beim Öffnen bzw. Laden)

### Ackerbau
- Vanilla-Farming umgedeutet: Getreide (Gerste, Roggen, Emmer), Rüben, Kohl, Erbsen, Bohnen, Flachs, Hanf, Kräuter
- Mühle bzw. Handmühle → Mehl → Brot; Brauen (Bier, Met)
- Keine Jahreszeiten (D34)

### Viehhaltung (D33)
- Huhn (Eier, Federn für Pfeile), Ziege bzw. Schaf (Milch, Wolle), Schwein (Fleisch), Rind (Milch, Zugtier F-13)
- Tiere finden bzw. fangen, im Pferch halten, füttern; Vermehrung langsam
- Tiere sind **Ziel der Seuchentote** und Sagengestalten (Nachzehrer!) → Stall verteidigen (F-17)
- Technik: Vanilla-Tiere mit friedlicher KI + Pferch-Bindung → REA

## Akzeptanzkriterien
- [ ] Ohne Konservieren verdirbt Fleisch innerhalb von 1–2 Ingame-Tagen; geräuchert hält es eine Woche oder länger
- [ ] Ein Pferch mit Hühnern versorgt einen Spieler dauerhaft mit Eiern, wenn gefüttert
- [ ] Verderb-Logik ist auf dem Dedicated Server konsistent (keine Client-Abweichungen)
