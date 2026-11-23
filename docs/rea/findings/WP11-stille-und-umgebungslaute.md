# WP11.8 — Woher die Umgebungslaute kommen (Stille: „Tiere verstummen")

**Stand:** 23. November 2026 (Plan-0002 WP11.8; Bezug: F-17 B2, F-09, Triage Phase 2 Zeile 21, D189)
**Build:** V 3.40 b10, Assembly-CSharp SHA-256 `cb54022c…56c58` · Soll-Datei `tools/meta/expect/wp118.tsv`
**Frage:** Können die Tierlaute der Landschaft verstummen, wenn Seuchentote nahe sind — und mit welchem Mittel?
**Methode:** `mod700meta types` und `members --callers` (Signaturen, Aufrufe, Feldzugriffe), Vanillas
`sounds.xml`, `biomes.xml`, `buffs.xml`. Kein Code übernommen. **Statisch gelesen, im Spiel nicht geprüft.**

## Kurz

| Frage | Antwort | Weg |
|---|---|---|
| Stehen Vogel-, Grillen-, Waldlaute in XML? | **nein** — `sounds.xml` hat keine Landschaftslaute, `biomes.xml` nur einen Platzhalter `AmbientSound value="..."` im Kommentar-Kopf | — |
| Wer spielt sie? | `EnvironmentAudioManager`, aus einer Unity-Vorlage, je Landschaft eine `AudioBiome` mit `AudioTrigger`n | Unity, Code |
| Gibt es einen XML-Hebel? | nur `SetAudioMixerState` (`Stunned`, `Deafened`) — der dämpft **alles**, auch Gegner und Schritte | ungeeignet |
| Geht „Stille" ohne Harmony? | **vielleicht:** alle Teile sind öffentlich (`Instance`, `audioBiomes`, `SetVolume`), aber Vanilla setzt die Lautstärke in jedem `FixedUpdate` neu **[verifizieren]** | C# (Client), sonst Postfix |

## Gelesen

- **Landschaftslaute.** `EnvironmentAudioManager` (öffentlich, eine Instanz `static Instance`) lädt in
  `Start` eine Vorlage und füllt `AudioBiome[] audioBiomes` (öffentlich). Je Landschaft stehen Listen
  `forestOnlyBiomeSounds`, `snowOnlyBiomeSounds`, `desertOnlyBiomeSounds`, `wastelandOnlyBiomeSounds`,
  `burnt_forestOnlyBiomeSounds`, `waterOnlyBiomeSounds` und `mixedBiomeSounds` — alle `AudioObject[]`.
- **Was einen Laut auslöst**, steht am `AudioObject` (Unity-Daten, nicht XML): `trigger` aus
  `Rain, Snow, Thunder, TimeOfDay, Dusk, Dawn, Day7Times, Day7Dusk, Day8Dawn, Random, Continual, Wind`,
  dazu `dayOnly`, `nightOnly`, `indoorOnly`, `outdoorOnly`, `validBiomes`, `repeatFreqRange`,
  `validThreatLevels`. Vanilla hat also eigene Auslöser für den **siebten Tag** (Abend und Morgen
  danach) — die Seuchennacht klingt in Vanilla schon anders, ohne XML.
- **Der Takt.** `EnvironmentAudioManager::FixedUpdate` ruft `AudioBiome::TransitionFrom/TransitionTo`
  (die rufen `AudioTrigger::SetVolume` und `Update`) und `AudioObject::SetVolume` — in **jedem** Takt.
  Eine Lautstärke, die fremder Code setzt, überschreibt Vanilla vermutlich im nächsten Takt.
- **`GlobalEnvironmentVolumeScale`** (öffentlich, statisch) liest nur `IncrementRainVolumes`: er regelt
  den **Regen**, nicht die Tiere.
- **`Pause`/`UnPause`** gibt es an Manager, `AudioBiome`, `AudioTrigger` und `AudioObject`; der Manager
  wird aus `GameManager::updatePauseState` gerufen. Ein eigenes „Pause" würde beim nächsten
  Pausenwechsel des Spiels aufgehoben — als Stille-Schalter brüchig.
- **`EnterBiome`** ruft nur `EntityPlayerLocal::onNewBiomeEntered`: alles läuft beim **lokalen
  Spieler**. Ein Dedicated Server spielt keine Umgebungslaute; Stille ist rein Client (Netz-Klasse C).
- **XML-Hebel.** `MinEventActionSetAudioMixerState` kennt zwei Zustände, `Stunned` und `Deafened`.
  Vanilla nutzt `Stunned` bei der Betäubung (`buffInjuryStunned00` und zwei weitere) und `Deafened`
  nur bei Twitch-Buffs (`twitch_buffDeafen`). Beides ist ein Mixer-Schnappschuss für den ganzen Klang.
- **Tiere als Wesen** (Hirsch, Hase, Wolf) haben ihre Laute an der Klasse (`SoundRandom…` in
  `entityclasses.xml`). Das sind keine Umgebungslaute; „Tiere verstummen" meint hier die Landschaft.

## Folgerung für den Bau

1. **Per XML geht „Stille" nicht.** Ein `Deafened` im Grauen wäre falsch: es nähme dem Spieler genau
   das Gehör, das der Lauscher (D188) belohnen soll.
2. **Der Weg ist C# beim Client,** im Direktor (WP11.6): „Seuchentote im Umkreis" zählen und die
   Lautstärke der Landschaftslaute senken. Ob das ohne Harmony hält oder Vanilla es jeden Takt
   zurückstellt, entscheidet ein kurzer Versuch **[verifizieren, mit WP11.6]**. Hält es nicht, ist ein
   Postfix auf `EnvironmentAudioManager::FixedUpdate` der kleinste Patch — erst dann mit Manifest-Zeile.
3. **Die Triage-Zeile 21** wechselt von „offen" auf **C# beim Client, Patch vielleicht**.
4. **Ferne Klänge** bleiben, wie D74 sagt, Trugbilder. Vanillas Glockenschlag ist der einzige ferne
   Laut ohne Gegner; er läutet schon die Seuchennacht ein (D186). Weitere ferne Klänge brauchen eigene
   Dateien (F-16, WP7.6).

## Soll-Signaturen

`tools/meta/expect/wp118.tsv` (11 Zeilen): `EnvironmentAudioManager::Instance`, `::audioBiomes`,
`::GlobalEnvironmentVolumeScale`, `::FixedUpdate`, `::Pause`, `::UnPause`, `AudioBiome::TransitionTo`,
`AudioBiome::triggers`, `AudioTrigger::SetVolume`, `AudioObject::SetVolume`,
`MinEventActionSetAudioMixerState::Execute`. `mod700meta verify`: Exit 0; Gegenprobe mit falschem
Parameter (`TransitionTo(int)`): Exit 1.
