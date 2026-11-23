# WP8 — Händlerstimmen: was die Spieloption `TraderDialog` stumm schaltet

**Stand:** 23. November 2026 (Plan-0002 WP8.5 Teil 2; Bezug: D102, F-10 D, D164, N-109)
**Frage:** Nimmt die Sandbox-Option `TraderDialog` den Händlern die Stimme — alle 1 336
gesprochenen Zeilen in modernem Englisch —, und lässt sie sich über unsere Vorlage „Jahr 700"
ausschalten, ohne dass etwas bricht?
**Antwort (statisch gelesen, im Spiel nicht gehört):**

1. `TraderDialog` ist eine **Ja/Nein-Option**, Enum-Wert **126**, **Vorgabe „ein"**.
2. Beim Spielstart wird sie in das statische Feld `TraderInfo::TraderDialog` geschrieben.
3. Das Feld liest im durchsuchten Code **genau eine** Methode: `EntityTrader::PlayVoiceSetEntry` —
   der Weg, über den die **Figur** spricht (Begrüßung, Verkauf, Auftrag, Abschied, Selbstgespräch).
4. Die **Ansagen am Lautsprecher** beim Öffnen, kurz vor dem Schließen und beim Schließen laufen
   über einen anderen Weg (`BlockSpeakerTrader`) und lesen das Feld **nicht**. Sie bleiben hörbar.
5. Der Code-Baustein für „Händlerstimmen aus" ist **`EWA`** — berechnet nach F-17, im Spiel nicht
   geprüft.

**Kein Patch.** Dieses Finding trägt keinen Harmony-Eingriff und steht darum nicht im
Patch-Manifest. Es belegt einen Schalter, den das Spiel selbst anbietet (Vorlage in
`sandbox_overrides.xml`, F-17).

**Gebaut darauf (D164, 2026-11-23, zu prüfen N-109):** `mod/700_60_Welt/Config/sandbox_overrides.xml`
— Code der Vorlage von `AAAJABJACJADJARFBNC` auf `AAAJABJACJADJARFBNCEWA`; die Beschreibung der
Vorlage (`700_vorlageDesc`) sagt es dem Spieler.

## Gebunden an diesen Build

| | |
|---|---|
| Build | 7 Days to Die V 3.40 b10 (Stable) |
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta members <dll> --type … --il --callers` für
`SandboxOptions.SandboxOptions`, `SandboxOptions.SandboxOptionManager`, `TraderInfo`,
`EntityTrader`, `EntityNPC`, `EntityAlive`, `AudioObject`, `GamePrefs`, `GameStats`,
`EnumGamePrefs`, `EnumGameStats`, `TraderArea`, `DialogActionVoice`, `BlockSpeakerTrader` und
`mod700meta find-string` (`TraderDialog`). Für die Suche nach Lesern des Feldes:
`mod700meta types <dll> --contains` mit `Trader`, `NPC`, `Dialog`, `Voice`, `Speak`, `Audio`,
`Subtitle` — **187 Typen**, deren Methoden mit `--il` auf `TraderInfo::TraderDialog` durchsucht.
Gelesen werden Metadaten und IL-Bytes; die Assembly wird nicht geladen, nicht ausgeführt und
nicht dekompiliert. Was der IL-Auszug zeigt und was nicht, steht in F-17 („Was der Auszug zeigt");
dieselben Grenzen gelten hier: keine Sprünge, also ist jedes „wenn — dann" **geschlossen**.

**Daneben gelesene lose Dateien** (nichts davon liegt im Repository): `Data\Config\blocks.xml`
(Block `loudspeaker`), `npc.xml` (`voice_set` je Händler), `Localization.csv` (Untertitel und
Ansagen), `sandbox_overrides.xml`.

## Der Beleg

### 1. Die Option

`SandboxOptions.SandboxOptions::TraderDialog` ist ein Enum-Feld mit dem Wert **126**
(Token `0x04009567`). Daneben: `TraderHours` 127, `TradersEnabled` 128, `VendingEnabled` 129.

`SandboxOptionManager::SetupOptions` legt sie an mit den Konstanten 126, 1, 0 und dann
`SandboxOptionBoolean::.ctor` — nach der Lesart von F-17 Abschnitt 4: **Ja/Nein, Vorgabe ein**.
Die Wertemenge der Ja/Nein-Optionen ist `[aus, ein]` (F-17): Index 0 = aus.

Eine Zeichenkette `TraderDialog` lädt der Spielcode nirgends (`find-string`: 54 940 Methodenrümpfe,
0 Treffer); die Option wird nur über ihren Enum-Wert gelesen. In den XML-Dateien unter
`Data\Config` steht der Name einmal, als Kommentar in `sandbox_overrides.xml`.

### 2. Vom Optionswert ins Spiel

`SandboxOptionManager::UpdateInGameValuesWithSandboxOptions` enthält in dieser Folge:
`ldc.i4.s 126`, `SandboxOptionManager::GetBool`, `stsfld TraderInfo::TraderDialog`. Diese Methode
rufen `GameManager/<StartAsServer>d__167::MoveNext` und `EntityPlayerLocal::AfterPlayerRespawn`
(F-17 Abschnitt 3) — Server und Client setzen das Feld also beide.

`TraderInfo::.cctor` setzt das Feld vorab auf 1 (ein); ohne Sandbox-Code bleibt es also an.

Über `GamePrefs` oder `GameStats` läuft die Option **nicht**: beide spiegeln Sandbox-Optionen über
gleichnamige Einträge (`SetupSandboxReferences`: `ToString`, `Enum::TryParse`, `GetOption`), und
weder `EnumGamePrefs` noch `EnumGameStats` hat einen Eintrag mit `Trader` oder `Dialog` im Namen.

### 3. Wer das Feld liest — und wer nicht

In den 187 durchsuchten Typen greifen genau zwei Methoden auf `TraderInfo::TraderDialog` zu:

| Methode | Zugriff |
|---|---|
| `TraderInfo::.cctor` | schreibt (Vorgabe 1) |
| `EntityTrader::PlayVoiceSetEntry(string, EntityPlayer, bool, bool)` | **liest** |

`EntityTrader::PlayVoiceSetEntry` überschreibt die virtuelle Methode `EntityNPC::PlayVoiceSetEntry`.
Diese rufen (über `callvirt`): `DialogActionVoice::PerformAction` (Stimme zu einer Dialogzeile),
`EntityTrader::OnUpdateLive` (Begrüßung nach Tageszeit: Zeichenketten `greetmorn`, `greetaft`,
`greeteve`, `greetnightfall`, `greetbloodmoon`, `greeting`), `EntityTrader::TransitionToNextWindow`,
`ItemActionEntrySell::OnDisabledActivate`, `XUiC_QuestOfferWindow::OnOpen`, `::btnAccept_OnPress`,
`::btnDecline_OnPress` und `XUiC_TraderWindow::OnClose`.

In `PlayVoiceSetEntry` stehen: das Feld `TraderDialog`, `NPCInfo::VoiceSet`, `String::Concat` mit
der Zeichenkette `_`, `Entity::PlayOneShot`, für entfernte Spieler `NetPackageAudioPlayInHead`
und `ConnectionManager::SendPackage`, am Ende `PlayAnimReaction` und `lastVoiceTime`. *Geschlossen:*
die Methode baut den Klangnamen aus Stimmsatz und Eintrag (`trader_rekt` + `_` + `greeting`) und
spielt ihn ab — und **fragt vorher das Feld ab**. Ob „aus" die ganze Methode überspringt oder nur
das Abspielen (die Gebärde `PlayAnimReaction` bliebe dann), zeigt der Auszug nicht.

**Die Ansagen am Lautsprecher** (`trader_*_announce_open`, `…_closing`, `…_closed`; in der
Sprachdatei 45 solche Zeilen für Öffnen, Warnung und Schließen, dazu 15 `…_announce_special`
— Sonderangebote, nicht weiter gelesen —, etwa „Trader Rekt is now closed"): `EntityTrader::OnUpdateLive`
ruft `TraderArea::HandleWarning` und `TraderArea::SetClosed`, diese `BlockSpeakerTrader::PlayWarning`,
`::PlayOpen`, `::PlayClose`. Dort stehen die Zeichenketten `_announce_open`, `_announce_closing`,
`_announce_closed`, die Felder `openSound`/`closeSound`/`warningSound`, `NPCInfo::VoiceSet`,
`String::Concat` und `Audio.Manager::BroadcastPlay` — **kein Zugriff auf `TraderDialog`**.
`BlockSpeakerTrader` liegt in den 187 durchsuchten Typen. Diese Ansagen bleiben also an.

`BlockSpeakerTrader::Init` liest die Block-Eigenschaften `OpenSound`, `CloseSound`, `WarningSound`.
Vanillas Block `loudspeaker` (`blocks.xml`, „Trader_Loudspeaker POI ONLY") setzt keine davon.
*Geschlossen:* Ist die Eigenschaft leer (`String::IsNullOrEmpty`), nimmt der Lautsprecher den
Stimmsatz des Händlers plus `_announce_…`; ist sie gesetzt, vermutlich den genannten Klang. Damit
gäbe es einen **XML-Weg**, die Ansagen zu ersetzen (etwa durch eine Glocke) — nicht gebaut, Vorschlag
in N-109.

**Untertitel:** die Untertitel-Zeilen (`subtitle_trader_*`) tragen dieselben Namen wie die Klänge.
*Vermutet, nicht gelesen:* sie erscheinen nur, wenn der Klang abgespielt wird — mit stummer Figur
also auch keine Untertitel der Figur; die Ansagen kämen weiter mit Untertitel.

### 4. Code-Baustein

Nach F-17 Abschnitt 5: 126 = 4 · 26 + 22 → `E`, `W`; Wert „aus" = Index 0 → `A`. **`EWA`**.
Angehängt an den Code der Vorlage „Jahr 700": `AAAJABJACJADJARFBNCEWA`. Die Reihenfolge der Gruppen
ist beim Lesen gleichgültig (F-17); das Spiel selbst schriebe die Händler-Gruppe hinter die übrigen.

## Was das für den Bau heißt

| Punkt | Folgerung |
|---|---|
| Weg | `EWA` in den Code der Vorlage. Reine XML, kein Code, kein Patch. Gebaut (D164). |
| Wirkung | Die Figur spricht nicht mehr: Begrüßung, Kauf, Auftrag, Abschied. Der Text im Gespräch (D161) bleibt — er kommt aus `dialogs.xml` und der Sprachdatei, nicht aus Klängen. |
| Lücke | Die **Ansagen am Lautsprecher** bleiben (moderne Stimme, „Trader Joel's is now open"). Wege: Block-Eigenschaften `OpenSound`/`CloseSound`/`WarningSound` mit einem eigenen Klang (XML), oder den Lautsprecher beim Umkleiden der Händlerorte (WP6.5b) entfernen. |
| Nur Vorwahl | Wie jede Vorlage wählt sie nur vor (F-17). Wer „Adventurer" nimmt, hört die Händler. Dedicated Server: `SandboxCode` in `serverconfig.xml`. |
| Netz | Die Option setzt Server **und** Client (Abschnitt 2); die Stimme spielt der Client oder der Server schickt sie per Paket — welcher der beiden das Feld im Mehrspieler fragt, ist ein **Dedicated-Test** (Regel 5). |

## Offen — nur das Spiel zeigt es

1. **Schweigt die Figur?** Neue Welt mit „Jahr 700", zum Händler gehen: keine Begrüßung, kein
   Kommentar beim Kaufen, kein Untertitel der Figur. Gegenprobe: Vorlage „Adventurer" — er spricht.
2. **Bleibt die Gebärde?** Dreht sich der Händler, nickt er, obwohl er schweigt?
3. **Lautsprecher:** um 20:00 (unsere Schließzeit, D162) — kommt die Ansage weiter, mit Untertitel?
4. **Dedicated Server** mit `SandboxCode` = `AAAJABJACJADJARFBNCEWA`: schweigt der Händler auch für den
   zweiten Client?
5. **Code im Fenster:** „Code kopieren" in den Optionen der Vorlage liefert denselben Code, und
   „Händlerstimmen" steht auf „Nein" (deckt sich mit S-11).
