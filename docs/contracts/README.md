# Verträge

Vor der Implementierung stehen die Verträge: Schnittstellen, Grenzen, Namen, Formate. **Der
Nutzer nimmt sie ab, erst dann wird gebaut.** Weicht die Umsetzung später ab, wird zuerst der
Vertrag geändert und erneut abgenommen — nicht umgekehrt.

| Vertrag | Inhalt | Status |
|---|---|---|
| [01 — Modlet-Grenzen](01-modlet-grenzen.md) | Acht Modlets, Ladereihenfolge über Zahlenpräfix, was in welches gehört, `ModInfo.xml`, eine Fassung für alle | **abgenommen 2026-11-22**; Nachträge Phase 2 Teil 1, 1b, 1c und 2 **Abnahme offen** (Symbole im Modlet, Test-Überlagerung `test/700_99_Test`; Spielvorlage in `700_60_Welt`; Herausforderungen in `700_50_Fortschritt`; vier neue Modlets der Phase 2 und die Ablage der Assets — Teil 2 ist nur Papier) |
| [02 — Namensraum](02-namensraum.md) | Kennung gegen Anzeigename, Präfixe je Art, Deutsch in Kennungen, `Localization.csv` und ihre Spalten, Ortsnamen (D1) | **abgenommen 2026-11-22**; Nachtrag Phase 2 **Abnahme offen** (Präfixe für Wesen, Welt, Handel, Assets; Namensmuster) |
| [03 — XPath-Regeln](03-xpath-regeln.md) | Die elf Patch-Operationen, die 52 patchbaren Dateien, sperren statt löschen, bedingte Blöcke mit `mod_loaded` | **abgenommen 2026-11-22**; Nachtrag Phase 2 **Abnahme offen** (die 52 Stammdateien vollständig, Dateien der Phase 2, sperren statt löschen für Wesen) |
| [04 — Prüfwerkzeuge](04-pruefwerkzeuge.md) | `mod700check` mit drei Befehlen, `ConfigsDump` als Datenquelle, Exit-Codes, Gegenproben | **abgenommen 2026-11-22** (als Block, mit allen Nachträgen); zehn spätere Nachträge **Abnahme offen** (Dump-Suche, Leermeldung, zweites Review der Vorprüfung, Prüfungen der Phase 2 Teil 1: *Symbole* und *Asset-Register*, Auftragsregeln, Sprachschlüssel einer Spielvorlage, Ziele der Herausforderungen, Prüfungen der Phase 2 Teil 2: *Wesen*, der Erzeuger der Wesen-Namen, `purge-patch` kennt Wesenregeln) |
| [05 — Asset-Pipeline](05-asset-pipeline.md) | Symbole: Format 160×160, Ablage `UIAtlases/ItemIconAtlas`, Namen `ico700_…`, ein Befehl, Register `assets/ASSETS.md`, Lizenz der Meshy-Ergebnisse; Modelle und Bundles ausdrücklich offen | **Entwurf — Abnahme offen** (Plan-0002 WP2.2); Teil A seit 2026-11-23 gebaut (Werkzeug, Register, erstes Symbol) |

Alle vier gehören zu [Plan-0001](../plans/0001-phase-1-mvp-700-und-grauen.md), Arbeitspaket WP1,
und stützen sich auf
[WP1-modlet-lader-und-xml-patcher.md](../rea/findings/WP1-modlet-lader-und-xml-patcher.md).

## Was diese vier Verträge gegenüber dem Plan geändert haben

Beim Schreiben kamen Dinge heraus, die der Plan noch nicht wusste:

1. **Acht Modlets statt sechs** (Vertrag 01). Bauen und Fortschritt haben eigene Schichten
   bekommen, weil sie sich unabhängig abschalten lassen sollen.
2. **`Localization.csv`, nicht `Localization.txt`** (Vertrag 02). Die Datei, die Spec 01 und F-12
   nannten, gibt es im Spiel nicht. Beide sind berichtigt.
3. **Bedingte XML-Blöcke** mit `mod_loaded`, `game_version` und `xpath` (Vertrag 03). Damit ist
   die UI-Mod-Verträglichkeit (D5, Plan-Risiko R6) ohne C# erreichbar — das war vorher offen.
4. **Das Spiel liefert die gemergte Config selbst** (Vertrag 04). `ConfigsDump` nach jedem
   Spielstart; kein Werkzeug muss den XML-Patcher nachbauen. Das war der teure Weg, und er
   entfällt.
