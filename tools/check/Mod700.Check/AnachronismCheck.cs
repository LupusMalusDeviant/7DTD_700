namespace Mod700.Check;

/// <summary>
/// Prueft, ob ein verbotener Gegenstand noch irgendwo steht, wo ein Spieler ihn ERREICHEN
/// kann. Die bloesse Existenz in items.xml ist kein Befund — gesperrte Gegenstaende bleiben
/// absichtlich stehen, weil Prefabs und Quests auf sie zeigen (Vertrag 03, Abschnitt 4).
///
/// Erreichbar heisst: ueber ein Rezept, eine Loot-Gruppe, eine Haendlergruppe, eine
/// Quest-Belohnung oder die Startausruestung.
/// </summary>
internal static class AnachronismCheck
{
    public static int Run(string path, string[] args)
    {
        string denylistPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "denylist.txt");
        bool asJson = false;

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--denylist" when i + 1 < args.Length:
                    denylistPath = args[++i];
                    break;
                case "--json":
                    asJson = true;
                    break;
                default:
                    throw new UsageException($"Unbekannte Option fuer anachronisms: {args[i]}");
            }
        }

        denylistPath = Path.GetFullPath(denylistPath);
        Denylist denylist = Denylist.Load(denylistPath);
        ConfigSource source = ConfigSource.Open(path);
        var report = new Report("anachronisms", source.Info);

        report.Count("denylist", Path.GetFileName(denylistPath));
        report.Count("verbotsregeln", denylist.DenyRules);
        report.Count("freigaberegeln", denylist.AllowRules);

        if (!source.IsMerged)
        {
            report.Limitation(
                "Dies ist ein Vorlauf gegen Vanilla, kein Nachweis: unsere Patches sind hier " +
                "nicht angewandt. Ein Nachweis braucht einen ConfigsDump nach einem Spielstart " +
                "mit den Modlets.");
        }
        else
        {
            report.Limitation(
                "Ein ConfigsDump sagt nicht, von welcher Spielfassung er stammt und welche " +
                "Modlets dabei geladen waren. Ein alter Dump sieht aus wie ein frischer - auf " +
                "den Zeitstempel oben achten.");
        }

        report.Limitation(
            "Geprueft werden Erreichbarkeitswege, die in XML stehen. Gegenstaende, die nur in " +
            "einem Prefab liegen (platzierte Bloecke, Kisteninhalte in POIs), sieht dieses " +
            "Werkzeug nicht - das ist die bekannte MVP-Luecke von F-01 und gehoert zu F-07.");
        report.Limitation(
            "Die Denylist ist eine Liste von Mustern, kein Verstaendnis. Ein Anachronismus mit " +
            "unerwartetem Namen faellt durch, bis die Liste ihn kennt.");

        // --- Erreichbarkeitswege sammeln
        var reachable = new List<(string Name, string Via, string Where)>();

        foreach ((string name, int line) in source.Attributes("recipes.xml", "recipe", "name"))
        {
            reachable.Add((name, "Rezept", $"recipes.xml:{line}"));
        }

        foreach ((string name, int line) in source.Attributes("loot.xml", "item", "name"))
        {
            reachable.Add((name, "Loot", $"loot.xml:{line}"));
        }

        foreach ((string name, int line) in source.Attributes("traders.xml", "item", "name"))
        {
            reachable.Add((name, "Haendler", $"traders.xml:{line}"));
        }

        // Quest-Belohnungen: id kann eine Liste sein und auf Gruppen oder Items zeigen.
        foreach ((string value, int line) in source.Attributes("quests.xml", "reward", "id"))
        {
            foreach (string name in Split(value))
            {
                reachable.Add((name, "Quest-Belohnung", $"quests.xml:{line}"));
            }
        }

        // Startausruestung: <property class="ItemsOnEnterGame"> mit Werten wie
        // "drinkJarBoiledWater=2,foodCanChili,medicalFirstAidBandage".
        foreach ((string value, int line) in StartingItems(source))
        {
            foreach (string name in Split(value))
            {
                string bare = name.Split('=', 2)[0].Trim();
                if (bare.Length > 0)
                {
                    reachable.Add((bare, "Startausruestung", $"entityclasses.xml:{line}"));
                }
            }
        }

        report.Count("erreichbarkeitswege", reachable.Count);
        report.Count("gepruefte_kennungen", reachable.Select(r => r.Name)
            .Distinct(StringComparer.OrdinalIgnoreCase).Count());

        // --- gegen die Denylist halten
        var hitsByName = new SortedDictionary<string, List<(string Via, string Where, string Rule)>>(
            StringComparer.OrdinalIgnoreCase);
        int allowedHits = 0;

        foreach ((string name, string via, string where) in reachable)
        {
            string? rule = denylist.Match(name, out string? allowReason);
            if (allowReason is not null)
            {
                allowedHits++;
                continue;
            }

            if (rule is null)
            {
                continue;
            }

            if (!hitsByName.TryGetValue(name, out var list))
            {
                list = new List<(string, string, string)>();
                hitsByName[name] = list;
            }

            list.Add((via, where, rule));
        }

        report.Count("durch_freigabe_erlaubt", allowedHits);
        report.Count("verbotene_kennungen", hitsByName.Count);

        foreach ((string name, var hits) in hitsByName)
        {
            string ways = string.Join(", ", hits
                .GroupBy(h => h.Via)
                .Select(g => $"{g.Key} ({g.Count()}x, zuerst {g.First().Where})"));
            report.Error("erreichbarer-anachronismus", name,
                $"erreichbar ueber {ways}; Regel {hits[0].Rule}");
        }

        return report.Write(asJson);
    }

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
