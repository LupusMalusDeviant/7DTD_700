# WP10.6 — Eine CVar in der Oberfläche anzeigen (Odem-Leiste)

**Stand:** 23. November 2026 (Plan-0002 WP10.6; Bezug: F-15 „Odem / Anzeige", D5, Vertrag 07 Nachtrag 2)
**Build:** V 3.40 b10, Assembly-CSharp SHA-256 `cb54022c…56c58` · Soll-Datei `tools/meta/expect/wp106.tsv`
**Frage:** Kann eine XUi-Datei den Wert einer CVar zeigen, ohne C#?
**Methode:** `mod700meta find-string` (Zeichenketten im Code) und `members` (Signaturen), Vanillas XUi.
Kein Code übernommen. **Statisch gelesen, im Spiel nicht geprüft.**

## Kurz

| Frage | Antwort | Weg |
|---|---|---|
| Gibt es eine Bindung für CVars in der Oberfläche? | **ja, sehr wahrscheinlich** | XML (XUi) |
| Nutzt Vanilla sie? | **nein** — 0 Treffer für `cvar` in `Data/Config/XUi_InGame/*.xml` | — |
| Kann Vanillas Leisten-Controller (`HUDStatBar`) eine CVar zeigen? | nein, er kennt nur seine Stat-Arten (`stat_type`) | — |

## Gelesen

- Die Zeichenkette `{cvar(` steht in `BindingInfo::.ctor`, `BindingInfo::RefreshValue`,
  `BindingInfoNcalc::RefreshValue` und `BindingsManager::ReplaceCVars`; `cvar(` in
  `BindingItemCvar::.ctor`.
- `BindingItemCvar` hat ein Feld `format` und `GetValue()` liefert eine Zeichenkette. Das spricht für
  eine Schreibweise `{cvar(name)}` mit einer optionalen Formatangabe; welche Trennung (Doppelpunkt) und
  welches Zahlformat gelten, ist **nicht** gelesen.
- `BindingsManager::ReplaceCVars(string)` ist statisch: die Ersetzung geschieht im Text des Attributs,
  unabhängig vom Controller. Darum braucht die Leiste keinen eigenen Controller.

## Folgerung für den Bau

Die Odem-Leiste (`700_75_Magie/Config/XUi_InGame/windows.xml`) bindet die Füllung zweier Bilder an
`{cvar(.cv700_odemAnteil:0.00)}` und `{cvar(.cv700_odemZeigen:0)}`. Rechnen tut der Buff
(`buff700_odemRegen`), nicht die Oberfläche: Anteil 0..1 und Zeigen 0/1 stehen fertig in CVars. So hängt
nichts an der ungeprüften Rechen-Schreibweise `{# … }` mit CVars.

**[verifizieren, S-41]:** ob die Bindung greift, ob das Format mit Doppelpunkt angenommen wird und ob
ein Komma als Dezimalzeichen (deutsche Spracheinstellung) die Füllung bricht.

## Soll-Signaturen

`tools/meta/expect/wp106.tsv` (4 Zeilen): `BindingItemCvar::.ctor`, `BindingItemCvar::GetValue`,
`BindingsManager::ReplaceCVars`, `BindingInfoNcalc::nCalcEvaluateFunction`. `mod700meta verify`:
4× ok; Gegenprobe mit falscher Rückgabe (`int` statt `string`): Exit 1.

## Nachtrag D199 — warum die Leiste leer blieb, und der eigene Controller (2026-11-23)

**Anlass:** Spieltest S-41 am 2026-11-23. Im Protokoll rechnet der Odem richtig (`cv700_odemMax` 60,
`.cv700_odemAnteil` 0,87 nach einem Glutpfeil), die Leiste bleibt leer, auch nach Öffnen und Schließen
des Inventars. **Methode:** `mod700meta members --il` (Aufruf- und Feldfolgen, kein Code übernommen).

| Frage | Antwort |
|---|---|
| An wen hängt sich `{cvar(…)}`? | Der Konstruktor von `BindingItemCvar` geht vom Controller des Elements zu dessen Eltern, solange es nur der leere Grund-Controller ist, und trägt sich dort in die Bindungen ein. |
| Wann wird sie neu gelesen? | Nur wenn **dieser** Controller seine Bindungen neu liest (`RefreshBindings`). Über dem Balken links unten tut das niemand laufend — die Leiste zeigt den Wert beim Öffnen und bleibt dann stehen. |
| Zahlformat | `GetValue` ruft `Single.ToString(format)` ohne Kultur — mit deutscher Spracheinstellung also vermutlich mit Komma. |
| Kann ein Mod einen eigenen Controller liefern? | **ja.** `XUiFromXml::parseController` holt den Typ über `ReflectionHelpers::GetTypeWithPrefix("XUiC_", name)`; steht ein Komma im Namen, wird `XUiC_` hinter den letzten Punkt gesetzt und der Typ über `Type.GetType` gesucht — `Mod700.OdemLeiste, Mod700` ergibt `Mod700.XUiC_OdemLeiste, Mod700`. Fehlt der Typ, nimmt das Spiel den Grund-Controller und schreibt eine Warnung. |

**Folgerung (D199):** `src/Mod700/XUiC_OdemLeiste.cs` — liest `.cv700_odemAnteil` und `.cv700_odemZeigen`
viermal je Sekunde, frischt nur bei sichtbarer Änderung auf, gibt `{odemanteil}` mit Punkt und
`{odemzeigen}` als true/false. Netz: nur Client. **Im Spiel ungeprüft** (S-41 neu).

**Soll-Signaturen** jetzt 12 Zeilen in `tools/meta/expect/wp106.tsv` (dazu `parseController`,
`GetTypeWithPrefix`, `XUiController::Update`/`GetBindingValueInternal`/`RefreshBindings`, `XUi::get_playerUI`,
`LocalPlayerUI::get_entityPlayer`, `EntityAlive::GetCVar`). `mod700meta verify`: 12× ok, Exit 0; Gegenprobe
mit `RefreshBindings(bool)`: Exit 1.
