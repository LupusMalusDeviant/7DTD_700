# Skill-Nutzung: plan-builder

Jüngster Lauf zuerst.

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
