# 00 — Grenzen von REA an dieser Assembly

| Build | Assembly SHA-256 | MVID | Datum |
|---|---|---|---|
| Steam 26309840 (public) | `cb54022c…56c58` | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` | 2026-11-07 |

## Frage

Liefert REA für `Assembly-CSharp.dll` das, was `interface-discovery.md` als „belegt“ definiert —
**Typ, Member, Signatur, Aufrufer**?

## Ergebnis: nein, nur zur Hälfte

`inspect_managed_members` scheitert an der Größe der Metadaten dieser Assembly. Die
Metadaten umfassen 6 300 292 Byte mit 7 677 TypeDefs, **57 629 MethodDefs**, 44 934 Fields und
60 459 CustomAttributes. Beim Dekodieren der Member sprengt die interne Darstellung das
Budget von 67 108 864 Byte.

| REA-Fassung | Aufruf | `coverage.state` | Was zurückkommt |
|---|---|---|---|
| 6.7.0 (MCP + CLI) | `inspect-managed-members <dll> --type IModApi` | `unavailable` | **nichts** — `types: []`, Meldung „The CLI metadata could not be admitted; managed member inspection is unavailable.“ |
| 6.8.0 (npx) | derselbe Aufruf | `partial` | **Typ-Bestand ja, Member nein** — TypeDef mit `full_name`, Flags, Token und den Zeilenbereichen der Member-Listen; `methods`, `fields`, `call_edges`, `field_accesses`, `user_strings` bleiben leer |

Wörtlich aus 6.8.0: *„Member decoding exceeded capacity after the type inventory was admitted;
fields, methods, member references, call edges, field accesses, exported types and user strings
are not examined to completion. Empty member collections do not establish absence.“*

Das Eingrenzen über `--type` hilft **nicht**: die Grenze wird beim Aufnehmen der Metadaten
erreicht, nicht beim Auswählen. Mit sieben ausgewählten Typen bricht es sogar früher ab
(Offset 877 981) als mit einem (Offset 6 632 656). `inspect-managed-members --help` kennt
keinen Schalter, der das Budget hebt.

### Was damit trotzdem belegbar ist

Der Typ-Bestand aus 6.8.0 ist vollwertige Evidenz für **Existenz, Art und Umfang** eines Typs.
Erster Lauf, `unmatched_type_names: []` für alle sieben Namen:

| Typ | TypeDef-Token | Flags | Methoden | Felder |
|---|---|---|---|---|
| `IModApi` | `0x02000730` | `0xA1` (public interface, abstract) | **1** | 0 |
| `Mod` | `0x02000731` | `0x100001` | 39 | 16 |
| `ModEvents` | `0x02000733` | `0x100181` (public static) | 1 | **22** |
| `ModManager` | `0x02000751` | `0x100181` (public static) | 21 | 6 |
| `ProgressionClass` | `0x02000aec` | `0x100001` | 27 | 22 |
| `Constants` | `0x020011b5` | `0x100001` | 2 | **244** |
| `EntityAlive` | `0x02000477` | `0x1000C1` | 411 | 312 |

Damit sind die Kandidatennamen aus `hook-hypothesen.md` als **vorhanden** nachgewiesen — aber
kein einziger Methodenname und keine Signatur.

## Folge für die Methode des Projekts

`CLAUDE.md` Regel 2 verlangt für jeden Harmony-Zielpunkt ein **REA-Finding** mit Typ, Member,
Signatur und Build. Dieser Teil ist mit REA an dieser Assembly derzeit nicht erreichbar. Vor
dem ersten Patch (F-08, Brenndauer der Fackeln) braucht es eine Entscheidung des Nutzers.
Die Lage ist dem Nutzer am 2026-11-07 vorgelegt; die gewählte Variante kommt als neue
D-Zeile in `docs/GDD.md`.

## Offene Punkte / Limitierungen

- Die Zahlen oben stammen aus *einem* Lauf je Fassung. Ein Gegenprobe-Lauf mit einem bewusst
  falschen Typnamen (Regel 5: „Prüfe mit einem Signal, das den Fehler finden könnte“) steht
  noch aus und gehört zum ersten echten Patch-Check.
- `Assembly-CSharp-firstpass.dll` wurde nicht geprüft; sie ist kleiner und könnte durchlaufen,
  enthält aber nicht die Spiellogik.
- Node.js ist v26.8.1 und damit unter der von REA genannten Untergrenze 26.12.1 für die
  26er-Linie. Ob das Budget-Verhalten davon abhängt, ist **nicht** geprüft.
