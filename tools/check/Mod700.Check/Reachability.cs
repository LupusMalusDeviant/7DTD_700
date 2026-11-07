namespace Mod700.Check;

/// <summary>Ein Weg, auf dem ein Spieler an eine Kennung kommt.</summary>
internal sealed record Way(string Name, string Via, string Where);

/// <summary>
/// Sammelt die Erreichbarkeitswege. Erreichbar heisst: ueber einen Block-Abwurf, ein Rezept,
/// eine Loot-Gruppe, eine Haendlergruppe, eine Quest-Belohnung oder die Startausruestung.
///
/// <para>Das steht absichtlich an einer Stelle und nicht in jedem Befehl einzeln: die
/// Liste der ungepruefen Kennungen muss genau die Kennungen zeigen, die die Pruefung auch
/// sieht. Zwei Implementierungen derselben Frage waeren zwei Gelegenheiten, verschiedene
/// Antworten zu geben - und in dieser Arbeit hat genau das schon dreimal falsche Zahlen
/// erzeugt.</para>
/// </summary>
internal static class Reachability
{
    public static List<Way> Ways(ConfigSource source)
    {
        var ways = new List<Way>();

        // Block-Abwuerfe. NACHGETRAGEN AM 2026-11-07, UND DAS WAR EIN LOCH, KEIN DETAIL.
        //
        // Bis WP4.1 kannte diese Stelle fuenf Wege und blocks.xml war keiner davon. Die
        // Pruefung meldete darum fuer den Purge aus WP3 'gesperrt_und_noch_erreichbar 0',
        // obwohl 26 gesperrte Kennungen weiter aus Bloecken fielen - resourceScrapPolymers
        // aus 163 Abwurfzeilen, resourceMechanicalParts aus 127, resourceElectricParts aus
        // 115. Wer ein Sofa zerschlug, hatte Kunststoff; der Purge sah fertig aus.
        //
        // RecipeCheck wusste es die ganze Zeit: dort sind Block-Abwuerfe seit dem ersten Tag
        // eine Wurzel ("Der Rezeptgraph kennt vier Wege ... <drop event=Harvest> in
        // blocks.xml"). Zwei Stellen beantworteten dieselbe Frage verschieden - genau das,
        // wovor der Absatz oben warnt, und er stand schon da, als es passierte. Beide lesen
        // jetzt dieselbe Zeile.
        //
        // Alle Ereignisse, nicht nur Harvest: Destroy und Fall geben dem Spieler den
        // Gegenstand genauso in die Hand.
        foreach ((string name, int line) in source.Attributes("blocks.xml", "drop", "name"))
        {
            ways.Add(new Way(name, "Block-Abwurf", $"blocks.xml:{line}"));
        }

        foreach ((string name, int line) in source.Attributes("recipes.xml", "recipe", "name"))
        {
            ways.Add(new Way(name, "Rezept", $"recipes.xml:{line}"));
        }

        foreach ((string name, int line) in source.Attributes("loot.xml", "item", "name"))
        {
            ways.Add(new Way(name, "Loot", $"loot.xml:{line}"));
        }

        foreach ((string name, int line) in source.Attributes("traders.xml", "item", "name"))
        {
            ways.Add(new Way(name, "Haendler", $"traders.xml:{line}"));
        }

        // Quest-Belohnungen: id kann eine Liste sein und auf Gruppen oder Items zeigen.
        foreach ((string value, int line) in source.Attributes("quests.xml", "reward", "id"))
        {
            foreach (string name in Split(value))
            {
                ways.Add(new Way(name, "Quest-Belohnung", $"quests.xml:{line}"));
            }
        }

        // Startausruestung: <property class="ItemsOnEnterGame"> mit Werten wie
        // "drinkJarBoiledWater=2,foodCanChili,medicalFirstAidBandage". Der Inhalt steht im
        // value-Attribut, nicht im name - wer name liest, findet die Startausruestung nie
        // und meldet dafuer Gruen.
        foreach ((string value, int line) in StartingItems(source))
        {
            foreach (string entry in Split(value))
            {
                string bare = entry.Split('=', 2)[0].Trim();
                if (bare.Length > 0)
                {
                    ways.Add(new Way(bare, "Startausruestung", $"entityclasses.xml:{line}"));
                }
            }
        }

        return ways;
    }

    /// <summary>
    /// Die erreichbaren Kennungen, jede einmal, gross-/kleinschreibungsgenau. Kennungen in
    /// 7DTD unterscheiden Gross- und Kleinschreibung; wer hier ignorierend zusammenfasst,
    /// verschmilzt zwei verschiedene Kennungen zu einer.
    /// </summary>
    public static List<string> Names(ConfigSource source) => Ways(source)
        .Select(w => w.Name)
        .Distinct(StringComparer.Ordinal)
        .OrderBy(n => n, StringComparer.Ordinal)
        .ToList();

    private static IEnumerable<(string Value, int Line)> StartingItems(ConfigSource source)
    {
        var document = source.Load("entityclasses.xml");
        if (document is null)
        {
            yield break;
        }

        foreach (var container in document.Descendants("property"))
        {
            if (container.Attribute("class")?.Value != "ItemsOnEnterGame")
            {
                continue;
            }

            foreach (var entry in container.Elements("property"))
            {
                string? value = entry.Attribute("value")?.Value;
                if (!string.IsNullOrWhiteSpace(value))
                {
                    yield return (value, ((System.Xml.IXmlLineInfo)entry).LineNumber);
                }
            }
        }
    }

    private static IEnumerable<string> Split(string value) =>
        value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
}
