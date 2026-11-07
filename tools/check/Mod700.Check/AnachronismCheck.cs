namespace Mod700.Check;

/// <summary>
/// Prueft, ob ein verbotener Gegenstand noch irgendwo steht, wo ein Spieler ihn ERREICHEN
/// kann. Die bloesse Existenz in items.xml ist kein Befund — gesperrte Gegenstaende bleiben
/// absichtlich stehen, weil Prefabs und Quests auf sie zeigen (Vertrag 03, Abschnitt 4).
///
/// Erreichbar heisst: ueber ein Rezept, eine Loot-Gruppe, eine Haendlergruppe, eine
/// Quest-Belohnung oder die Startausruestung.
///
/// <para><b>Urteil nach Eigenschaften (Vertrag 04 §3a).</b> Zuerst entscheidet eine
/// Eigenschaft, die Vanilla selbst fuehrt (Tags, Block-Klasse, eigene Group), dann erst der
/// Name. Der Bericht weist beide Zahlen getrennt aus: <c>verboten_nach_name</c> ist das Mass
/// dafuer, wie viel noch auf dem Gedaechtnis des Autors ruht, und soll fallen.</para>
/// </summary>
internal static class AnachronismCheck
{
    public static int Run(string path, string[] args)
    {
        string denylistPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "denylist.txt");
        bool asJson = false;
        bool resolveExtends = true;
        var disabledRules = new HashSet<string>(StringComparer.Ordinal);

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

                // Gegenprobe 4 aus Vertrag 04 §3a: ohne Vererbung muss die Zahl der
                // eigenschaftslosen Kennungen sprunghaft steigen.
                case "--no-extends":
                    resolveExtends = false;
                    break;

                // Gegenprobe 2: eine herausgenommene Regel muss auffallen.
                case "--ohne-regel" when i + 1 < args.Length:
                    string id = args[++i];
                    if (!PropertyRules.Exists(id))
                    {
                        throw new UsageException(
                            $"Unbekannte Eigenschaftsregel: {id}. Bekannt sind: {PropertyRules.Ids}");
                    }

                    disabledRules.Add(id);
                    break;

                default:
                    throw new UsageException($"Unbekannte Option fuer anachronisms: {args[i]}");
            }
        }

        denylistPath = Path.GetFullPath(denylistPath);
        Denylist denylist = Denylist.Load(denylistPath);
        ConfigSource source = ConfigSource.Open(path);
        Definitions definitions = Definitions.Load(source, resolveExtends);
        var report = new Report("anachronisms", source.Info);

        report.Count("denylist", Path.GetFileName(denylistPath));
        report.Count("verbotsregeln", denylist.DenyRules);
        report.Count("freigaberegeln", denylist.AllowRules);
        report.Count("eigenschaftsregeln", PropertyRules.All.Count - disabledRules.Count);
        if (disabledRules.Count > 0)
        {
            report.Count("abgeschaltete_regeln", string.Join(",", disabledRules));
        }

        if (!resolveExtends)
        {
            report.Count("extends_aufgeloest", "nein");
        }

        report.Count("definitionen_items", definitions.ItemCount);
        report.Count("definitionen_bloecke", definitions.BlockCount);
        report.Count("definitionen_mods", definitions.ModifierCount);
        report.Count("loot_gruppen", definitions.LootGroupCount);

        Limitations(report, source, resolveExtends, disabledRules);

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

        foreach ((string value, int line) in source.Attributes("quests.xml", "reward", "id"))
        {
            foreach (string name in Split(value))
            {
                reachable.Add((name, "Quest-Belohnung", $"quests.xml:{line}"));
            }
        }

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

        // Kennungen sind gross-/kleinschreibungsgenau (siehe Denylist.Compile): hier darf
        // nicht ordinal-ignorierend zusammengefasst werden, sonst verschmelzen zwei
        // verschiedene Kennungen zu einer.
        var names = reachable
            .Select(r => r.Name)
            .Distinct(StringComparer.Ordinal)
            .OrderBy(n => n, StringComparer.Ordinal)
            .ToList();

        report.Count("erreichbarkeitswege", reachable.Count);
        report.Count("gepruefte_kennungen", names.Count);

        // --- Erster Durchgang: Gegenstaende, Bloecke, Unaufloesbares
        var verdicts = new Dictionary<string, Verdict>(StringComparer.Ordinal);
        int unresolved = 0, lootGroups = 0, withoutProperties = 0;

        foreach (string name in names)
        {
            Definition def = definitions.Lookup(name);

            if (def.Kind == DefKind.LootGroup)
            {
                lootGroups++;
            }
            else if (def.Kind == DefKind.Unresolved)
            {
                unresolved++;
            }
            else if (!def.HasProperties)
            {
                withoutProperties++;
            }

            string? nameRule = denylist.Match(name, out string? allowReason);

            // Reihenfolge ist der Kern von Vertrag 04 §3a: die Freigabe schlaegt alles, dann
            // entscheidet die EIGENSCHAFT, und erst wenn keine zutrifft, der Name. Umgekehrt
            // waere 'verboten_nach_name' sinnlos - es wuerde nur sagen, was zufaellig auch
            // ein Namensmuster trifft, nicht was ohne den Namen durchfiele.
            if (allowReason is not null)
            {
                verdicts[name] = new Verdict(name, def, Blocked: false, "freigabe", null, allowReason);
                continue;
            }

            if (def.Kind != DefKind.Modifier &&
                PropertyRules.Match(def, disabledRules) is PropertyRule rule)
            {
                verdicts[name] = new Verdict(name, def, Blocked: true, "eigenschaft", rule.Id, rule.Reason);
                continue;
            }

            if (nameRule is not null)
            {
                verdicts[name] = new Verdict(name, def, Blocked: true, "name", nameRule,
                    "keine Eigenschaft hat entschieden, nur das Namensmuster");
                continue;
            }

            verdicts[name] = new Verdict(name, def, Blocked: false, "ungeprueft", null, null);
        }

        // --- Zweiter Durchgang: Mods aus installable_tags ableiten
        //
        // Ein Mod faellt, wenn JEDER Gegenstand, auf den er passt, selbst gesperrt ist. Das
        // trifft alle Mods ohne eine einzige eigene Regel und bleibt richtig, wenn sich eine
        // Entscheidung ueber die Waffen aendert. Ob der Traeger selbst erreichbar ist, geht
        // hier nicht ein - gefragt ist, ob es ihn im Spiel noch gibt.
        int modsFallen = 0, modsUnjudged = 0;

        foreach (string name in names)
        {
            Verdict verdict = verdicts[name];
            if (verdict.Definition.Kind != DefKind.Modifier || verdict.Blocked ||
                verdict.By == "freigabe")
            {
                continue;
            }

            IReadOnlySet<string> slots = verdict.Definition.InstallableTags;
            if (slots.Count == 0)
            {
                modsUnjudged++;
                report.Hint("mod-ohne-traegerangabe", name,
                    "kein installable_tags - ueber diesen Mod kann nicht nach Eigenschaft "
                    + "geurteilt werden; er braucht eine Namensregel oder eine Ausnahme.");
                continue;
            }

            List<string> carriers = definitions.CarriersFor(slots).ToList();
            if (carriers.Count == 0)
            {
                modsUnjudged++;
                report.Hint("mod-ohne-traeger", name,
                    $"kein Gegenstand traegt {string.Join("/", slots)} - nicht beurteilbar, "
                    + "also auch nicht gesperrt.");
                continue;
            }

            List<string> surviving = carriers.Where(c => !IsBlocked(c)).ToList();
            if (surviving.Count == 0)
            {
                modsFallen++;
                verdicts[name] = verdict with
                {
                    Blocked = true,
                    By = "mod-ableitung",
                    Rule = "mod-ohne-ueberlebenden-traeger",
                    Reason = $"passt nur auf {string.Join("/", slots)}; alle {carriers.Count} "
                             + "Traeger sind gesperrt, also faellt der Mod mit ihnen."
                };
            }
        }

        bool IsBlocked(string carrier)
        {
            if (verdicts.TryGetValue(carrier, out Verdict? known))
            {
                return known.Blocked;
            }

            // Traeger, der selbst nicht erreichbar ist: nach denselben Regeln beurteilen.
            Definition def = definitions.Lookup(carrier);
            if (denylist.Match(carrier, out string? allow) is not null && allow is null)
            {
                return true;
            }

            return allow is null && PropertyRules.Match(def, disabledRules) is not null;
        }

        // --- Zaehlen und berichten
        var blocked = verdicts.Values.Where(v => v.Blocked).ToList();

        report.Count("durch_freigabe_erlaubt", verdicts.Values.Count(v => v.By == "freigabe"));
        report.Count("verboten_nach_eigenschaft", blocked.Count(v => v.By == "eigenschaft"));
        report.Count("verboten_nach_name", blocked.Count(v => v.By == "name"));
        report.Count("verboten_durch_mod_ableitung", modsFallen);
        report.Count("mods_nicht_beurteilbar", modsUnjudged);
        report.Count("unaufloesbar", unresolved);
        report.Count("loot_gruppen_erreichbar", lootGroups);
        report.Count("ohne_eigenschaft", withoutProperties);
        report.Count("extends_tiefe_erreicht", definitions.DepthExceededCount);
        report.Count("ungeprueft", verdicts.Values.Count(v => v.By == "ungeprueft"));
        report.Count("verbotene_kennungen", blocked.Count);

        var waysByName = reachable
            .GroupBy(r => r.Name, StringComparer.Ordinal)
            .ToDictionary(g => g.Key, g => g.ToList(), StringComparer.Ordinal);

        foreach (Verdict v in blocked.OrderBy(v => v.Name, StringComparer.Ordinal))
        {
            string ways = string.Join(", ", waysByName[v.Name]
                .GroupBy(h => h.Via)
                .Select(g => $"{g.Key} ({g.Count()}x, zuerst {g.First().Where})"));

            report.Error("erreichbarer-anachronismus", v.Name,
                $"erreichbar ueber {ways}; verboten nach {v.By} [{v.Rule}]: {v.Reason}");
        }

        // Unaufloesbares ist kein Gruen. Es ist eine Kennung, ueber die nichts bekannt ist.
        foreach (Verdict v in verdicts.Values
            .Where(v => v.Definition.Kind == DefKind.Unresolved && !v.Blocked)
            .OrderBy(v => v.Name, StringComparer.Ordinal))
        {
            report.Hint("unaufloesbare-kennung", v.Name,
                "erreichbar, aber in items.xml, blocks.xml und item_modifiers.xml nicht "
                + "definiert - ueber diese Kennung kann nicht nach Eigenschaft geurteilt werden.");
        }

        return report.Write(asJson);
    }

    private static void Limitations(
        Report report, ConfigSource source, bool resolveExtends, IReadOnlySet<string> disabled)
    {
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
                "den Zeitstempel oben achten. Ein Dump ohne unsere Modlets ist trotz des " +
                "Vermerks oben ein Vorlauf.");
        }

        report.Limitation(
            "Geprueft werden Erreichbarkeitswege, die in XML stehen. Gegenstaende, die nur in " +
            "einem Prefab liegen (platzierte Bloecke, Kisteninhalte in POIs), sieht dieses " +
            "Werkzeug nicht - das ist die bekannte MVP-Luecke von F-01 und gehoert zu F-07.");
        report.Limitation(
            "Eigenschaften sind kein Verstaendnis, nur ein besseres Signal als Namen. Wo " +
            "Vanilla keine fuehrt - Konserve gegen Rohfleisch, Verbandskasten gegen " +
            "Wundauflage - entscheidet weiter der Name, und 'verboten_nach_name' sagt, wie " +
            "viel daran haengt.");

        if (!resolveExtends)
        {
            report.Limitation(
                "ACHTUNG: --no-extends. Die Vererbung ist abgeschaltet, also sind die meisten " +
                "Kennungen kuenstlich eigenschaftslos. Dieser Lauf ist eine Gegenprobe, kein " +
                "Nachweis.");
        }

        if (disabled.Count > 0)
        {
            report.Limitation(
                $"ACHTUNG: abgeschaltete Eigenschaftsregeln ({string.Join(", ", disabled)}). " +
                "Dieser Lauf ist eine Gegenprobe, kein Nachweis.");
        }
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

    private sealed record Verdict(
        string Name,
        Definition Definition,
        bool Blocked,
        string By,
        string? Rule,
        string? Reason);
}
