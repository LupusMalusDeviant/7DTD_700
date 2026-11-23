# Triage Phase 2 — XML, C# oder später

**Stand:** 23. November 2026 (Plan-0002 WP9.6, D172; zu prüfen N-116)
**Grundlage:** die Findings aus WP9.3, WP9.4 und WP9.5
([Herstellen und Schaden](findings/WP9-herstellen-und-schaden.md),
[Licht und Seuchennacht](findings/WP9-licht-und-seuchennacht.md),
[Odem und Verderb](findings/WP9-odem-und-verderb.md)), Vertrag 06 und 07, das Patch-Manifest.
**Alles statisch.** Jedes Urteil „XML reicht" hängt an einem Spieltest (S-32 bis S-35); fällt der
Test, rückt der Kandidat eine Spalte nach rechts.

## Die Urteile

Der Plan nannte drei: **XML reicht** · **ein Patch** · **zu groß, rutscht**. Die Findings brachten
ein viertes, das zwischen den ersten beiden liegt:

- **C# ohne Patch** — eigener Code im Kern-Modlet (Vertrag 06 `Systeme/`), der nur über die
  öffentliche Mod-API hört (`ModEvents.GameUpdate`, `ModEvents.PlayerSpawnedInWorld`, beide gelesen)
  und CVars am Spieler setzt (`EntityBuffs::SetCustomVarNetwork`, `v07-zustaende.tsv`). Kein
  Harmony, also auch kein Eingriff, den ein Spiel-Update still verbiegt. So arbeitet schon F-00.

## Ergebnis

| # | Kandidat | Feature | Urteil | Weg | hängt an |
|---|---|---|---|---|---|
| 1 | Lernen durch **Herstellen** | F-21 | **XML reicht** | Buff liest `_craftCount_<Gegenstand>`, hebt per `AddProgressionLevel` | S-33 (1)–(3) |
| 2 | Lernen durch **Benutzen** (Treffer, Abbau) | F-21 | **XML reicht** | Vanillas Treffer- und Abbau-Auslöser, CVar-Zähler `cv700_…` | Bau (WP12) |
| 3 | Grauen: Dunkelheit | F-17 B3 | **XML reicht** | `CompareLightLevel` | S-34 (1) |
| 4 | Grauen: Mitspieler in der Nähe | F-17 B3 | **XML reicht** | Gesellschafts-Buff, `selfAOE`/`selfOtherPlayers` + `IsAlly` | S-34 (2) |
| 5 | Trugbilder nur beim Betroffenen | F-17 B4 | **XML reicht** (+ Klänge als Asset) | `IsLocalPlayer`, `PlaySound`, `RandomRoll` | eigene Klänge (F-16) |
| 6 | Regler aus/mild/voll | F-17, D13 | **C# ohne Patch** | Kern liest `Schalter.xml`, setzt `cv700_grauenDaempfung` beim Betreten (`PlayerSpawnedInWorld`) | Vertrag 06/07 |
| 7 | Bedrohungs-Direktor | F-17 B5 | **C# ohne Patch** | eigener Takt über `GameUpdate` auf dem Server; liest Spieltag, Seuchennacht-Tag, Grauen; setzt `cv700_direktorPhase`, `cv700_grauenDruck` | Vertrag 07 §3.3; Dedicated-Test |
| 8 | „Seuchennacht läuft" | F-09 | **XML reicht** | `IsBloodMoon` | S-34 |
| 9 | Nebel, Wolken der Seuchennacht | F-09 | **XML reicht** | Wetter `bloodMoon` je Biom | — |
| 10 | Farbe der Seuchennacht (grau statt rot) | F-09, D12 | **XML vielleicht**, sonst **rutscht** (Asset, Unity) | `<spectrum>` im Wetter | S-34 (3) |
| 11 | Vorboten am Vortag | F-09 | **C# ohne Patch** (Teil des Direktors, Nr. 7) | Direktor setzt am Vortag die Phase „Vorzeichen"; Klang und Partikel per XML | Nr. 7 |
| 12 | Odem als Kosten | F-15 | **XML reicht** | `<requirement>` in `<action>` (`ExecutionRequirements`) + `ModifyCVar` | S-35 (1) |
| 13 | Zauber-Projektil | F-15 | **XML reicht** (+ Partikel als Asset) | `ItemActionProjectile` / Werfer | F-16 |
| 14 | Bannkreis | F-15 | **XML reicht** als **Aura**; Meide-Zone **rutscht** | Bremse im Umkreis | N-115 (3) |
| 15 | Amulett-Platz | F-15, Q32 | **XML reicht** | `BiomeBadge4` | S-35 (2) |
| 16 | Sechstes Attribut im Fenster | F-21, D111 | **XML reicht** | XUi: Raster 8 → 9 | S-35 (3) |
| 17 | Verderb nach Zeit | F-19, D32 | **rutscht** (C# mit Patch am Inventar, ohne Finding zum Ziel) — **XML ohne Uhr** als Ersatz | Krankheitsrisiko frischer Ware | N-115 (1) |
| 18 | Wurfspeer | F-02 | **XML reicht** | `ItemActionThrownWeapon` (Vanilla, auskommentiert) | S-33 (4) |
| 19 | Schild blockt von vorn | F-02 | **ein Patch — Phase 3** | Postfix auf `EntityAlive::DamageEntity`, beim Besitzer des Getroffenen | Phase 3 (D50) |
| 20 | Seuchennacht-Sperre für Wegsteine | F-13 | **XML reicht** | Buff setzt `cv700_…` während `IsBloodMoon`; Ereignis-Kette prüft `RequirementCVar` | Phase 3 |
| 21 | Tiere verstummen (Stille) | F-09, F-17 B2 | **offen** — nicht gelesen | Tierlaute liegen bei den Wesen (`entityclasses.xml`, `SoundRandom…`) | eigenes Finding vor WP11.9 |

## Was daraus folgt

- **Phase 2 braucht keinen Harmony-Patch.** Der einzige echte Patch-Kandidat (Nr. 19) gehört zu
  Phase 3. Verderb mit Uhr (Nr. 17) wäre der zweite — er rutscht, bis der Nutzer ihn will (N-115).
- **C# kommt trotzdem**, als „C# ohne Patch": Regler und Direktor (Nr. 6, 7, 11). Vertrag 06 gilt
  für sie in allem außer §3/§4 (Patch-Kopf, Register); die Soll-Dateien sind `f00.tsv`
  (`RegisterHandler`), `v06-kern.tsv`, `v07-zustaende.tsv`.
- ~~**Lücke im Werkzeug:**~~ *Geschlossen mit WP9.9 (2026-11-23): `verify` prüft jetzt auch Felder,
  `GameUpdate` und `PlayerSpawnedInWorld` stehen in `v06-kern.tsv`.* ~~`mod700meta verify` prüft nur Methoden, keine Felder.~~ Die Ereignisse
  `ModEvents.GameUpdate` und `PlayerSpawnedInWorld` sind **Felder** — ihr Verschwinden nach einem
  Update fiele nicht auf. Vor dem ersten Code in `Systeme/` bekommt `verify` eine Feldprüfung (mit
  Gegenprobe, Projektregel 5). Plan-Punkt WP9.9.
- **„Warum nicht XML?"** steht jetzt in F-02, F-09, F-15, F-17, F-19 und F-21 (Projektregel 3),
  jeweils mit Verweis auf diese Tabelle.
- **Risiko R10** (großer Eingriff) ist für Phase 2 kleiner geworden: Lichtabfrage, Meide-Zone und
  Lernen kosten keinen Patch; offen bleiben Direktor (C# ohne Patch) und Verderb (rutscht).
