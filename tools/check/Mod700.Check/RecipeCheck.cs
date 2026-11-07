namespace Mod700.Check;

/// <summary>
/// Prueft den Rezeptgraphen auf Sackgassen, Zyklen und unbekannte Zutaten.
///
/// Die Wurzelmenge — was ohne Herstellen zu bekommen ist — war in Vertrag 04 noch offen.
/// Beantwortet am 2026-11-07: blocks.xml traegt &lt;drop event="Harvest" name="…"/&gt;, und
/// das ist der Weg, auf dem Rohstoffe aus der Welt kommen. Wurzeln sind damit alles, was
/// faellt, geplündert, gehandelt oder mitgebracht wird.
/// </summary>
internal static class RecipeCheck
{
    public static int Run(string path, string[] args)
    {
        string? explain = null;
        bool asJson = false;
        string? worldRootsPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "world-roots.txt");

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--from" when i + 1 < args.Length:
                    explain = args[++i];
                    break;
                case "--world-roots" when i + 1 < args.Length:
                    worldRootsPath = args[++i];
                    break;
                case "--no-world-roots":
                    // Fuer die Gegenprobe: zeigt, was die Datei abdeckt.
                    worldRootsPath = null;
                    break;
                case "--json":
                    asJson = true;
                    break;
                default:
                    throw new UsageException($"Unbekannte Option fuer recipes: {args[i]}");
            }
        }

        ConfigSource source = ConfigSource.Open(path);
        var report = new Report("recipes", source.Info);

        if (!source.IsMerged)
        {
            report.Limitation(
                "Dies ist ein Vorlauf gegen Vanilla, kein Nachweis: unsere Patches sind hier " +
                "nicht angewandt.");
        }
        else
        {
            report.Limitation(
                "Ein ConfigsDump sagt nicht, von welcher Spielfassung er stammt und welche " +
                "Modlets dabei geladen waren. Ein alter Dump sieht aus wie ein frischer - auf " +
                "den Zeitstempel oben achten.");
        }

        report.Limitation(
            "Geprueft wird Erreichbarkeit, nicht Balance. Dass ein Pfad existiert, heisst " +
            "nicht, dass er sich gut anfuehlt - das entscheidet der Playtest.");
        report.Limitation(
            "Wurzeln sind Block-Drops, Loot, Haendlerware und Startausruestung. Wege, die das " +
            "XML nicht ausdrueckt (Einschmelzen in der Esse, Eimer an der Wasserquelle), " +
            "stehen in world-roots.txt - nachlesbar statt im Code geraten. Ein Weg, den auch " +
            "diese Datei nicht kennt, erscheint faelschlich als Sackgasse.");

        // --- Rezepte einlesen
        var recipes = new List<Recipe>();
        var document = source.Load("recipes.xml");
        if (document is null)
        {
            throw new UsageException($"In {path} liegt keine recipes.xml.");
        }

        foreach (var element in document.Descendants("recipe"))
        {
            string? name = element.Attribute("name")?.Value;
            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            var ingredients = element.Elements("ingredient")
                .Select(i => i.Attribute("name")?.Value)
                .Where(n => !string.IsNullOrWhiteSpace(n))
                .Select(n => n!)
                .ToList();

            recipes.Add(new Recipe(name, ingredients,
                ((System.Xml.IXmlLineInfo)element).LineNumber));
        }

        // --- Universum der bekannten Kennungen
        var known = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach ((string name, _) in source.Attributes("items.xml", "item", "name"))
        {
            known.Add(name);
        }

        foreach ((string name, _) in source.Attributes("blocks.xml", "block", "name"))
        {
            known.Add(name);
        }

        // --- Wurzeln
        var roots = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach ((string name, _) in source.Attributes("blocks.xml", "drop", "name"))
        {
            roots.Add(name);
        }

        foreach ((string name, _) in source.Attributes("loot.xml", "item", "name"))
        {
            roots.Add(name);
        }

        foreach ((string name, _) in source.Attributes("traders.xml", "item", "name"))
        {
            roots.Add(name);
        }

        report.Count("wurzeln_aus_xml", roots.Count);

        // Wurzeln, die das XML nicht ausdrueckt (Esse, Wasserquelle). Sie stehen in einer
        // eigenen Datei, damit die Annahme nachlesbar ist und nicht im Code steckt.
        var worldRootPatterns = new List<(System.Text.RegularExpressions.Regex Pattern, string Reason)>();
        if (worldRootsPath is not null)
        {
            string full = Path.GetFullPath(worldRootsPath);
            if (!File.Exists(full))
            {
                throw new UsageException($"Keine world-roots-Datei: {full}");
            }

            foreach (string raw in File.ReadAllLines(full))
            {
                int comment = raw.IndexOf('#');
                string reason = comment >= 0 ? raw[(comment + 1)..].Trim() : string.Empty;
                string rule = (comment >= 0 ? raw[..comment] : raw).Trim();
                if (rule.Length == 0)
                {
                    continue;
                }

                string escaped = System.Text.RegularExpressions.Regex.Escape(rule).Replace("\\*", ".*");
                worldRootPatterns.Add((
                    new System.Text.RegularExpressions.Regex($"^{escaped}$",
                        System.Text.RegularExpressions.RegexOptions.IgnoreCase),
                    reason.Length > 0 ? reason : "ohne Begruendung"));
            }

            report.Count("world_roots_datei", Path.GetFileName(full));
            report.Count("world_roots_regeln", worldRootPatterns.Count);

            int added = 0;
            foreach (string name in known)
            {
                if (!roots.Contains(name) && worldRootPatterns.Any(p => p.Pattern.IsMatch(name)))
                {
                    roots.Add(name);
                    added++;
                }
            }

            report.Count("wurzeln_aus_world_roots", added);
        }
        else
        {
            report.Count("world_roots_datei", "aus (--no-world-roots)");
        }

        report.Count("rezepte", recipes.Count);
        report.Count("bekannte_kennungen", known.Count);
        report.Count("wurzeln", roots.Count);

        // --- Erreichbarkeit: von den Wurzeln aus so lange Rezepte freischalten,
        //     wie noch eines dazukommt.
        var reachable = new HashSet<string>(roots, StringComparer.OrdinalIgnoreCase);
        var open = new List<Recipe>(recipes);
        bool progress = true;

        while (progress)
        {
            progress = false;
            for (int i = open.Count - 1; i >= 0; i--)
            {
                Recipe recipe = open[i];
                if (recipe.Ingredients.All(reachable.Contains))
                {
                    reachable.Add(recipe.Name);
                    open.RemoveAt(i);
                    progress = true;
                }
            }
        }

        report.Count("erreichbare_rezepte", recipes.Count - open.Count);
        report.Count("unerreichbare_rezepte", open.Count);

        // --- Befunde einordnen
        int unknownIngredients = 0;
        int deadEnds = 0;
        int clusters = 0;

        foreach (Recipe recipe in open)
        {
            var missing = recipe.Ingredients.Where(i => !reachable.Contains(i)).ToList();
            var unknown = missing.Where(i => !known.Contains(i)).ToList();
            var craftableButBlocked = missing
                .Where(i => known.Contains(i) && recipes.Any(r =>
                    string.Equals(r.Name, i, StringComparison.OrdinalIgnoreCase)))
                .ToList();

            string where = $"recipes.xml:{recipe.Line}";

            if (unknown.Count > 0)
            {
                unknownIngredients++;
                report.Error("zutat-unbekannt", recipe.Name,
                    $"{where}: Zutat {string.Join(", ", unknown)} ist in items.xml und " +
                    "blocks.xml nicht definiert. Tippfehler oder fehlender Patch.");
                continue;
            }

            if (craftableButBlocked.Count == missing.Count)
            {
                // Alle fehlenden Zutaten sind selbst Rezept-Ergebnisse, die ebenfalls
                // haengen: eine zusammenhaengende unerreichbare Gruppe, meist ein Zyklus.
                clusters++;
                report.Error("zyklus-oder-gruppe", recipe.Name,
                    $"{where}: haengt an {string.Join(", ", craftableButBlocked)}, " +
                    "die selbst unerreichbar sind. Zyklus oder abgeschnittene Kette.");
                continue;
            }

            deadEnds++;
            report.Error("sackgasse", recipe.Name,
                $"{where}: Zutat {string.Join(", ", missing)} ist definiert, aber auf keinem " +
                "Weg zu bekommen (kein Drop, kein Loot, keine Haendlerware, kein Rezept).");
        }

        report.Count("zutat_unbekannt", unknownIngredients);
        report.Count("sackgassen", deadEnds);
        report.Count("zyklen_oder_gruppen", clusters);

        // --- Einzelnen Pfad erklaeren
        if (explain is not null)
        {
            Explain(explain, recipes, roots, reachable, report);
        }

        return report.Write(asJson);
    }

    private static void Explain(
        string target,
        List<Recipe> recipes,
        HashSet<string> roots,
        HashSet<string> reachable,
        Report report)
    {
        Recipe? recipe = recipes.FirstOrDefault(r =>
            string.Equals(r.Name, target, StringComparison.OrdinalIgnoreCase));

        if (recipe is null)
        {
            report.Error("kein-rezept", target,
                roots.Contains(target)
                    ? "Es gibt kein Rezept dafuer - der Gegenstand kommt aus der Welt " +
                      "(Drop, Loot oder Haendler)."
                    : "Es gibt kein Rezept dafuer und auch keinen Weg aus der Welt.");
            return;
        }

        var lines = new List<string>();
        Walk(recipe, recipes, roots, reachable, lines, 0, new HashSet<string>(StringComparer.OrdinalIgnoreCase));
        report.Count("pfad_" + target, string.Join(" | ", lines));
    }

    private static void Walk(
        Recipe recipe,
        List<Recipe> recipes,
        HashSet<string> roots,
        HashSet<string> reachable,
        List<string> lines,
        int depth,
        HashSet<string> visiting)
    {
        string indent = new(' ', depth * 2);

        if (!visiting.Add(recipe.Name))
        {
            lines.Add($"{indent}{recipe.Name} (ZYKLUS)");
            return;
        }

        lines.Add($"{indent}{recipe.Name}{(reachable.Contains(recipe.Name) ? "" : " (UNERREICHBAR)")}");

        foreach (string ingredient in recipe.Ingredients)
        {
            Recipe? sub = recipes.FirstOrDefault(r =>
                string.Equals(r.Name, ingredient, StringComparison.OrdinalIgnoreCase));

            if (sub is not null)
            {
                Walk(sub, recipes, roots, reachable, lines, depth + 1, visiting);
            }
            else
            {
                string mark = roots.Contains(ingredient) ? "aus der Welt" : "FEHLT";
                lines.Add($"{indent}  {ingredient} ({mark})");
            }
        }

        visiting.Remove(recipe.Name);
    }

    private sealed record Recipe(string Name, List<string> Ingredients, int Line);
}
