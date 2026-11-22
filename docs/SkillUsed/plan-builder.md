# Skill-Nutzung: plan-builder

Jüngster Lauf zuerst.

## 2026-11-22 23:50 — Run

**Aufgabe:** Umsetzungsplan für Phase 2 („Leben in der Welt") schreiben, im autonomen Lauf ohne
Rückfragen: der Nutzer ist nicht erreichbar, Entscheidungen werden gesammelt statt gestellt.
Grundlage: GDD §4, §5, §7, §8, elf Feature-Dokumente, Prüfungen 0002 und 0003, drei Konzeptpapiere.

**Entscheidungen:**
- Modus: **Standalone** — `docs/prd/` existiert nicht; keine Modus-Frage (AskUserQuestion entfällt,
  Nutzer nicht erreichbar).
- Nummerierung und Slug: `0002-phase-2-leben-in-der-welt` (Name der Phase aus GDD §5).
- Arbeitspakete: **vierzehn** statt 3–12, begründet mit elf Features; dafür Teilung in 2a (sieben
  Pakete, kein Harmony-Patch) und 2b (fünf Pakete, erste Patches) nach dem Vorschlag D119, mit
  einem Vertragspaket am Anfang jedes Teils. 115 Schritte, 185 Arbeitstage, mit Puffer und
  Risikozuschlag 246.
- Meilensteine **ohne Kalenderdaten** (Abweichung vom Template): jeder hängt an einem Testlauf, den
  nur der Nutzer ansetzt, und die Durchsatz-Annahme aus Plan-0001 ist nie bestätigt worden.
- Asset-Arbeit nach vier Messwerten vom selben Tag geordnet: Symbole ohne Unity zuerst (WP3),
  Modelle hinter der Installation des Unity-Editors (WP4, WP7).
- 26 Entscheidungen für den Nutzer als `P2-E01 …`, je mit Empfehlung, nach der gebaut wird.
- Der Index `docs/plans/README.md` ist **nicht** ergänzt — der Auftrag erlaubte nur den Plan und
  diesen Eintrag.

**Artefakte:**
- `docs/plans/0002-phase-2-leben-in-der-welt.md`

**Status:** abgeschlossen

---

## 2026-11-07 14:45 — Run

**Aufgabe:** Phase-1-Plan („MVP 700 & Grauen") für 7DTD_700 erstellen, nachdem der Kurz-Check der
Schnittstellen Prio 2–10 abgeschlossen war. Grundlage: GDD §5 Roadmap, Entscheidungen D1–D52,
die zehn Phase-1-Feature-Dokumente und der Befund zu Prio 2–10.

**Entscheidungen:**
- Modus: **Standalone** — `docs/prd/` existiert nicht, also keine Modus-Frage nötig.
- Nummerierung: `0001`, erster Plan des Projekts. `docs/plans/` neu angelegt.
- Arbeitspakete: **neun** statt der üblichen 3–7, begründet mit zehn Features in Phase 1;
  dafür vier eng geschnittene Meilensteine.
- Schätzeinheit: Arbeitstage, nicht Kalendertage. Durchsatz-Annahme drei Tage/Woche,
  ausdrücklich als wackeligste Zahl markiert (R11) und zur Korrektur durch den Nutzer gestellt.
- Zwei Scope-Schnitte vorweggenommen: B2-Stille-Logik (F-17) und Schadensarten (F-02) nach
  Phase 2, weil beide C# brauchen und Phase 1 patchfrei bleiben soll.
- Vor dem Plan berichtigt: `F-08` behauptete „Brenndauer (C#)". Der Befund zeigt XML
  (`Class="PlantGrowing"`). Alte Zeile durchgestrichen, nicht gelöscht (Projektregel 4).

**Artefakte:**
- `docs/plans/0001-phase-1-mvp-700-und-grauen.md`
- `docs/plans/README.md` (Index neu angelegt)
- `docs/features/F-08-licht-feuer-verteidigung.md` (berichtigt)

**Status:** abgeschlossen

---
