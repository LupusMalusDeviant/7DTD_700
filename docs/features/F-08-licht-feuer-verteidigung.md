# F-08 — Licht, Feuer & Verteidigung

| Phase | Tiefe | Netz | REA |
|---|---|---|---|
| MVP | X (H entfällt, siehe unten) | S+C | ja |

## Ziel
Licht ist eine Ressource (Säule P4). Ohne Strom verteidigt man sich mit Feuer, Holz,
Gräben und Mechanik.

## Umfang
**Licht — gebaut am 2026-11-08 (WP6.4/WP6.5, D64).** Vier Lichtquellen, drei davon Vanilla
umgedeutet, eine neu. Die Brenndauer ist **unkalibriert** und gilt erst nach WP6.6:

| 700 | Träger | `GrowthRate` | geht aus zu | wieder anzuzünden mit |
|---|---|---|---|---|
| Wandfackel | `wallTorchLightPlayer` | 30 | **`torchWallHolder`** (Vanilla!) | 1 × `meleeToolTorch` |
| Wandkerze | `candleWallLightPlayer` | 15 | `blk700_kerzenstumpf_wand` | 1 × `candle` |
| Standkerze | `candleTableLightPlayer` | 15 | `blk700_kerzenstumpf_tisch` | 1 × `candle` |
| Öllampe (4 Varianten) | `lanternOld_01..04_Player` | 60 | `blk700_oellampe_leer` | 2 × `resourceAnimalFat` |
| Holzfeuer | `blk700_holzfeuer` *(neu)* | 45 | `blk700_holzfeuer_aus` | 10 × `resourceWood` |

**Vanilla hatte für die Fackel beide Hälften des Kreislaufs schon gebaut.**
`torchWallHolder` ist der unbeleuchtete Halter (`CreativeMode="None"`, steht in POIs) und
trägt bereits einen `UpgradeBlock` zurück auf `wallTorchLightPlayer`, zu bezahlen mit einer
Fackel. Für die Wandfackel war also **eine Zeile** nötig: das `Next` darauf.

**Damit ist das „Phase 2"-Kriterium unten eingelöst, nicht aufgeschoben.** Der offene Punkt
war: *Nachlegen von Brennstoff ohne TileEntity.* Die Antwort ist `UpgradeBlock` auf dem
erloschenen Block — vier Schläge mit dem Brennstoff in der Hand, und es brennt wieder. Kein
TileEntity, keine Uhr zurückzusetzen, weil der neue Block seine Uhr beim Setzen selbst
startet (`OnBlockAdded` → `addScheduledTick`).

**`IsRandom="false"`, und das ist Absicht.** Die Streuung heißt `GrowthDeviation` (ein
`RandomGaussian` mal diesem Wert), und Vanilla setzt sie in ganz `blocks.xml` **null**-mal —
es gibt keinen Wert, an dem sich die Einheit ablesen ließe. Eine geratene Streuung kann eine
Fackel in Sekunden ausgehen oder Tage brennen lassen. Erst die Brenndauer messen (WP6.6),
dann streuen.

**Zwei Nebenwirkungen, beide gemessen:**
- `GetTickRate` multipliziert die Brenndauer mit einem spielweiten `CropGrowthModifier` —
  **wer die Pflanzenwachstums-Einstellung des Servers dreht, dreht die Brenndauer mit.**
- Der Klassenwechsel kostet `AIDirector::NotifyActivity`: **Fackeln machen keine Hitze mehr
  auf der Karte und ziehen keine Schreier.** Licht, Aufnehmen und Flamme bleiben (das Licht
  steckt im Prefab, `CanPickup` ist eine Block-Eigenschaft, ein `ParticleName` war nie
  angemeldet). Siehe
  [WP6-Finding §2a](../rea/findings/WP6-brenndauer-und-blockschaden.md).

**Zwei Dinge, die diese Fassung nicht hat, und warum:**
- **Der Kienspan fehlt.** Vanilla hat kein Modell, das als harzige Holzspleiße zu lesen wäre;
  der Torch-Halter ist schon der erloschene Fackelzustand. Seine Rolle — das billigste und
  kürzeste Licht — füllt die Unschlittkerze (1 Nesselfaser + 1 Tierfett, 15 Minuten). Ein
  eigenes Asset gehört zu F-16 in Phase 2.
- **„Feuerkorb" heißt Holzfeuer.** F-08 nennt einen Korb auf einem Gestell; so ein Modell hat
  Vanilla nicht. Was es hat, ist ein Glutbett aus verbrannten Scheiten, **mit** Licht
  (`pileEmberBurntLogs1LightPrefab`) und **ohne** (`…1NoEmissivePrefab`) — beide Hälften aus
  derselben Modellfamilie. Der Name folgt dem, was man sieht. Die Funktion, die F-08 will
  (helles Feuer im Freien, hält länger als eine Fackel, wärmt, verbrennt wer hineintritt,
  gibt Holzkohle), steht.

**Und die Öllampe war nicht baubar.** Vanillas Rezept verlangt 5 × `resourceOil` — gesperrt,
weil Mineralöl. Gefunden mit demselben Zähler, der die vier unbaubaren Werkstätten fand
(`rezepte_mit_gesperrter_zutat`). Das Öl einer Blechlampe um 700 ist Tierfett; die Menge
bleibt 5. Dazu geflickt: sie wurde mit `resourceElectricParts` repariert (jetzt
`resourceForgedIron`) und trug `TraderStageTemplate electricTier1` (jetzt `baseTier0`).

**Ursprünglicher Umfang, zum Abgleich:**
- Fackel (Hand, Wand), ~~Kienspan~~, Öllampe (Talg/Öl), ~~Feuerkorb~~ → Holzfeuer
- ~~**Brenndauer (C#):** Lichtquellen verbrauchen Brennstoff und erlöschen~~
- **Brenndauer (XML, berichtigt 2026-11-07):** Lichtquellen verbrauchen Brennstoff und
  erlöschen — über `Class="PlantGrowing"` mit `Next` und `GrowthRate`, wie eine wachsende
  Pflanze. **Kein C#**, siehe unten.
- Dunklere Nächte, Mondphasen und Nebel: siehe **F-17 B1** (Echte Dunkelheit). F-08 liefert die Lichtquellen, F-17 die Dunkelheit.
- Licht senkt Grauen (F-17 B3): Eine brennende Feuerstelle ist der wichtigste sichere Ort (B8).

**Verteidigung (XML):**
- Palisade, Spitzpfähle (Spikes-Umdeutung), Graben bzw. Fallgrube, Schwingbalken-Falle (mechanisch statt elektrisch), Pechtopf
- **Magische Verteidigung** kommt aus F-15: Runenstein der Glut (statt Geschützturm),
  Runenfallen (Glutzeichen statt Blade Trap, Bannkreis statt Elektrozaun), betrieben über
  Runenkraft (Kraftlinien, D37)
- Licht-Ergänzung aus F-15: **Lichtfunke** (Zauber) als seltene, teure Alternative zur Fackel. Licht bleibt eine Ressource (P4).

## Nicht im Umfang
- Feuerausbreitung auf Gebäude (Vanilla-Feuersystem prüfen; ggf. P2)

## Umsetzung
### XML
Lichtblöcke (Vanilla-Fackel/-Kerze als Basis), Fallen, Bau-Rezepte.
### C# / Harmony — **nicht nötig** (beantwortet 2026-11-07)

Die Frage war: gibt es ein Tick- oder Update-System für Blöcke, auf das man sich hängen kann,
statt jeden Lichtblock einzeln zu ticken? **Ja, und es ist per XML erreichbar.** `blocks.xml`
liefert das Vorbild selbst — `cropsGrowingMaster`:

| Eigenschaft | Bedeutung für die Fackel |
|---|---|
| `Class="PlantGrowing"` | Blockklasse mit Zeitlogik |
| `Next` | der erloschene Zustand |
| `GrowthRate` | Brenndauer in **Minuten** (Vanilla-Kommentar: nicht unter 2 setzen) |
| ~~`IsRandom`~~ | ~~Streuung, damit nicht alle Fackeln gleichzeitig ausgehen~~ **berichtigt 2026-11-08:** `IsRandom` ist nur der Schalter, die Breite heißt **`GrowthDeviation`** |
| `FertileLevel`, `LightLevelStay`, `LightLevelGrow` | **alle drei müssen auf `0`**, sonst gelten Pflanzenbedingungen. Belegt an Vanillas `plantedMushroom1` |
| `GrowIfAnythinOnTop` | der Tippfehler ist im Spiel. `GrowIfAnythingOnTop` liest niemand |

Eine Fackel ist mechanisch eine wachsende Pflanze. Der Zustand liegt im Block, nicht in einem
eigenen Manager — Persistenz und Netzsynchronisierung erledigt damit das Spiel.

**Kein Harmony-Patch, kein TileEntity, keine eigene Blockklasse.**
Befund: [02-10-schnittstellen-kurzcheck.md](../rea/findings/02-10-schnittstellen-kurzcheck.md#prio-3--f-08-licht-und-feuer)

~~Offen geblieben: **Nachlegen** von Brennstoff (die Uhr zurücksetzen) ohne TileEntity. Für die
MVP-Fassung „brennt ab, muss neu gesetzt werden" ist das gleichgültig; das Akzeptanzkriterium
„nachfüllbar" unten gehört damit in Phase 2.~~

**Gelöst am 2026-11-08, und einfacher als gedacht.** Die Uhr muss nicht zurückgesetzt werden —
der erloschene Block bekommt einen `UpgradeBlock` mit dem Brennstoff als `Item`, und der neue
Block startet seine Uhr beim Setzen selbst (`OnBlockAdded` → `addScheduledTick`). Vanilla macht
es an `torchWallHolder` genau so. Kein TileEntity, und das Kriterium „nachfüllbar" steht in
Phase 1.

## Schnittstellen (REA)
→ [hook-hypothesen.md#f-08](../rea/hook-hypothesen.md#f-08)

## Akzeptanzkriterien
- [ ] Eine Wandfackel brennt N Ingame-Minuten, dann erlischt sie
- [ ] Zustand bleibt nach Server-Neustart erhalten
- [ ] Clients sehen synchron, ob die Fackel brennt oder aus ist
- [ ] Keine messbaren Server-Frame-Einbrüche bei 200 Fackeln (Performance-Check)
- [x] ~~*(Phase 2)*~~ Brennstoff nachlegbar, ohne die Fackel neu zu setzen — **steht
      (2026-11-08)**: `UpgradeBlock` auf dem erloschenen Block, vier Schläge mit dem
      Brennstoff. Als XML geschrieben und auflösbar geprüft; im Spiel noch nicht gesehen.
- [ ] **Eine Wandfackel in einem GESCHLOSSENEN Raum brennt ab und hinterlässt einen Halter —
      keine Luft.** `CheckPlantAlive` ersetzt den Block bei Nichterfüllung durch
      `BlockValue::Air`, und Vanillas Beleg (`plantedMushroom1`) steht auf Boden, nicht an
      einer Wand. Eine Fackel im Freien beweist es nicht → Prüfliste 11
- [ ] **Eine Öllampe leuchtet unmittelbar nach dem Setzen.** Sie hatte die *leere* Klasse, und
      Vanillas Kommentar warnt vor einer nicht-leeren; `PlantGrowing` fasst Licht nicht an,
      aber das ist ein Schluss und keine Messung

Die ersten drei folgen aus `Class="PlantGrowing"`, wenn der Befund trägt — Zustand und Netz
erledigt das Spiel. Zu prüfen bleibt die Zahl (`GrowthRate` in Minuten gegen gewünschte
Ingame-Stunden; dazu der spielweite `CropGrowthModifier`) und die Last bei vielen Blöcken.
