# WP8 — Der Beschreibungsschlüssel wird vererbt, und er geht der Vorgabe `<Name>Desc` vor

**Stand:** 22. November 2026
**Frage:** Unsere Sprachdatei trägt sechs Beschreibungen `<Name>Desc` für die Bruchstücke aus
dem Zerlegen (`meleeWpnBladeT3MachetePartsDesc` und fünf Geschwister). Vanillas Sprachdatei hat
diese Schlüssel nicht. Liest das Spiel sie?
**Antwort:** Nein. Die sechs Gegenstände erben über `Extends` die Eigenschaft
`DescriptionKey = gunPartsGroupDesc`, und eine vorhandene Eigenschaft geht der Vorgabe
`<Name>Desc` vor. Gelesen wurde Vanillas Satz über fortgeschrittene Waffen.

Gefunden in WP8.8, weil „`mod700check localization` grün" nichts darüber sagt, ob eine Zeile
gelesen wird.

## Gebunden an diesen Build

| | |
|---|---|
| Artefakt | `7DaysToDie_Data/Managed/Assembly-CSharp.dll` |
| SHA-256 | `cb54022ccc862aa673e0ee55dafe67d842b364c80df6916958d171e959656c58` |
| MVID | `0dfd4a8c-e2eb-4a72-8af4-f69f7c5b1480` |
| Länge | 11.980.288 Bytes |

**Werkzeug:** `mod700meta find-string <dll> --text DescriptionKey`, `--text Extends`,
`--text Desc` und `mod700meta members <dll> --type <T> --il` für `ItemClass`,
`ItemClassesFromXml`, `Block`, `BlocksFromXml`. Gelesen werden Metadaten und IL-Bytes; die
Assembly wird nicht geladen, nicht ausgeführt und nicht dekompiliert.

**Was der Auszug zeigt und was nicht:** `--il` gibt die Aufrufe, Feldzugriffe und
Zeichenketten einer Methode in ihrer Reihenfolge aus, nicht die Sprünge dazwischen. „Wenn —
sonst" ist unten darum aus der Reihenfolge gelesen und als solches gekennzeichnet.

## Der Beleg

### Gegenstände

`ItemClass::.cctor` legt die Zeichenkette `DescriptionKey` in das Feld
`ItemClass::PropDescriptionKey`. `ItemClass::Init` greift auf dieses Feld zu
(`ldsfld ItemClass::PropDescriptionKey`), trägt die Zeichenkette `Desc`, und seine Aufrufe
und Zuweisungen stehen an dieser Stelle in dieser Reihenfolge:

```
callvirt Dictionary<string,string>::ContainsKey
callvirt Dictionary<string,string>::get_Item
stfld    ItemClass::DescriptionKey
call     XMLData.Item.ItemData::get_Name
call     System.String::Concat
stfld    ItemClass::DescriptionKey
```

Gelesen: steht die Eigenschaft im Wörterbuch des Gegenstands, wird ihr Wert der
Beschreibungsschlüssel; sonst Name plus `Desc`. `ItemClass::GetItemDescriptionKey` gibt das
Feld zurück.

`ItemClassesFromXml::parseItem` trägt die Zeichenketten `Extends` und
`Extends item {0} is not specified for item {1}'` und ruft `HashSet<string>::.ctor`,
`HashSet<string>::Add` und `DynamicProperties::CopyFrom`. Gelesen: die Eigenschaften des
Elternteils werden in den Gegenstand kopiert, bis auf eine Menge von Ausnahmen. Dass diese
Menge aus `param1` kommt, steht für **Blöcke** im Auszug (`BlocksFromXml::ParseExtendedBlock`
greift auf `XNames::property`, `XNames::value` und `XNames::param1` zu); für Gegenstände ist
es **aus Vanillas Daten abgeleitet** (`<property name="Extends" value="partsMaster"
param1="CustomIcon"/>`).

### Blöcke

`Block::Init` trägt die Zeichenkette `{0}Desc` und greift auf `Block::PropDescriptionKey`,
`Block::DescriptionKey` (schreibend und lesend) und `Block::defaultBlockDescriptionKey` zu.
Aufrufe und Zuweisungen, in dieser Reihenfolge:

```
callvirt Dictionary<string,string>::ContainsKey
callvirt Dictionary<string,string>::get_Item
stfld    Block::DescriptionKey
call     System.String::Format
stfld    Block::DescriptionKey
call     Localization::Exists
stfld    Block::DescriptionKey
```

Gelesen: wie beim Gegenstand, und danach ein dritter Schritt — gibt es zu dem Schlüssel
keine Zeile, tritt die Gruppenbeschreibung an seine Stelle. Sie kommt aus dem Wurzelknoten
(`<blocks defaultDescriptionKey="creativeMenuBlockGroupDesc">`; der Lader
`BlocksFromXml/<CreateBlocks>` trägt die Zeichenkette `defaultDescriptionKey`). **Ein Gegenstand hat diesen dritten Schritt nicht.**

### In den Daten gemessen

- `gunMGT1AK47Parts` setzt `DescriptionKey` auf `gunPartsGroupDesc` und hat **15** Erben. Die
  sechs Bruchstücke gehören dazu, und keines trägt eine eigene Eigenschaft `DescriptionKey`.
- Über Vanillas `items.xml` (1.434 Gegenstände, 1.156 mit `Extends`): **202** lesen einen
  geerbten Schlüssel, **315** tragen einen eigenen, obwohl die Elternkette einen liefert,
  **7** schließen ihn über `param1` aus. Über `blocks.xml` (6.643 Blöcke, 5.907 mit
  `Extends`): 2.564, 161 und 225.
- Im `ConfigsDump` vom 2026-11-21 (mit unseren Modlets geladen) steht an keinem der sechs
  eine Eigenschaft `DescriptionKey`; gerechnet lesen alle sechs `gunPartsGroupDesc`.

## Was daraus folgt

1. **Sechs Zeilen waren tot.** Behoben in `mod/700_30_Ausruestung/Config/items.xml`: je ein
   `<append>` hängt den sechs Gegenständen die Eigenschaft `DescriptionKey` mit ihrem eigenen
   Schlüssel an. Ein `<set>` träfe nichts — die Eigenschaft gibt es an ihnen nicht.
2. **Eine Zeile `<Name>Desc` zu schreiben genügt nicht.** Gelesen wird sie nur, wenn der
   Gegenstand oder Block weder eine eigene noch eine geerbte Eigenschaft `DescriptionKey` hat.
   Das prüft seit WP8.8 `tools/check/sprachverweise-pruefen.ps1` (Vertrag 04, „Nachtrag
   WP8.8").
3. **Ein eigener Block ohne Beschreibungszeile zeigt die Gruppenbeschreibung, ein eigener
   Gegenstand nicht.** Darum verlangt die Prüfung die Zeile nur beim Gegenstand.

## Was nicht belegt ist

- **Dass die eigene Eigenschaft der geerbten vorgeht**, ist nicht aus dem IL gelesen: ob
  `CopyFrom` einen vorhandenen Eintrag überschreibt, zeigt der Auszug nicht. Vanilla verlässt
  sich in 315 Gegenständen und 161 Blöcken darauf, und unsere Öllampen 02 bis 04
  (`700_40_Bauen`) tun dasselbe. Ob ein per `<append>` **nach** `Extends` angehängter `DescriptionKey` genauso
  gilt, entscheidet der Lauf im Spiel (Prüfliste 23).
- **Was ein Gegenstand anzeigt, dessen Schlüssel keine Zeile hat**, ist nicht gelesen.
- **Im Spiel gesehen ist nichts davon.** Die Mod ist derzeit nicht installiert.
- **Andere Arten** (Buffs, Fertigkeiten, Aufträge) haben eigene Lader; dieses Finding sagt
  über sie nichts.
