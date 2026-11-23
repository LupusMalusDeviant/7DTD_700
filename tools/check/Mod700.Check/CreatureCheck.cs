using System.Xml;
using System.Xml.Linq;

namespace Mod700.Check;

/// <summary>
/// Die Pruefung <i>wesen</i> (Vertrag 04, Nachtrag Pruefungen der Phase 2, Teil 2): welche
/// Klassen erscheinen im Gelaende, und zeigt jeder Name auf etwas, das es gibt?
///
/// <para><b>Warum das ein eigener Blick ist.</b> Ein Wesen ist kein Gegenstand. Die Klassen
/// stehen in Gruppen (<c>entitygroups.xml</c>), und wer eine Gruppe ruft, steht in
/// <c>spawning.xml</c> (je Landschaft) und <c>gamestages.xml</c> (Spielstufen, Schlaefer,
/// Horden). Keiner der sechs Wege fuehrt dorthin.</para>
///
/// <para><b>Wesenregeln urteilen nur ueber Landschaftsgruppen</b> - Gruppen, die
/// <c>spawning.xml</c> nennt. In den Gruppen der Spielstufen duerfen die Rollentraeger der
/// Seuchennacht stehen (P2-E12); dieselbe Klasse ist dort kein Befund.</para>
///
/// <para><b>Die Verweise werden unabhaengig von jeder Regel geprueft.</b> Seit ein Modlet
/// Gruppen aendert, kann ein Name ins Leere zeigen, und eine Gruppe kann leer werden.</para>
/// </summary>
internal static class CreatureCheck
{
    /// <summary>Vanillas Zeichen fuer "hier erscheint nichts" - ein Eintrag, kein Verweis.</summary>
    private const string Nothing = "none";

    public static void Check(Report report, ConfigSource source, Denylist denylist)
    {
        report.Count("wesenregeln", denylist.CreatureRules);

        XDocument? groupsDoc = source.Load("entitygroups.xml");
        if (groupsDoc is null)
        {
            report.Count("wesengruppen", "keine entitygroups.xml - Wesen nicht geprueft");
            return;
        }

        // Klassen. Fehlt entityclasses.xml, kann kein Eintrag gegen sie gehalten werden.
        HashSet<string>? classes = null;
        XDocument? classesDoc = source.Load("entityclasses.xml");
        if (classesDoc is not null)
        {
            classes = new HashSet<string>(StringComparer.Ordinal);
            foreach (XElement c in classesDoc.Descendants("entity_class"))
            {
                if (c.Attribute("name")?.Value is string className && className.Length > 0)
                {
                    classes.Add(className);
                }
            }
        }

        // Gruppen mit ihren Eintraegen.
        var groups = new Dictionary<string, List<(string Class, int Line)>>(StringComparer.Ordinal);
        foreach (XElement group in groupsDoc.Descendants("entitygroup"))
        {
            string? name = group.Attribute("name")?.Value;
            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            if (!groups.TryGetValue(name, out List<(string, int)>? entries))
            {
                entries = new List<(string, int)>();
                groups[name] = entries;
            }

            foreach (XElement entry in group.Elements("e"))
            {
                if (entry.Attribute("n")?.Value is string className && className.Length > 0)
                {
                    entries.Add((className, ((IXmlLineInfo)entry).LineNumber));
                }
            }
        }

        // Wer ruft welche Gruppe? Landschaft: spawning.xml, <biome name><spawn entitygroup>.
        var calledByBiome = new Dictionary<string, SortedSet<string>>(StringComparer.Ordinal);
        var calls = new List<(string Group, string Where)>();

        XDocument? spawning = source.Load("spawning.xml");
        if (spawning is not null)
        {
            foreach (XElement spawn in spawning.Descendants("spawn"))
            {
                string? group = spawn.Attribute("entitygroup")?.Value;
                if (string.IsNullOrWhiteSpace(group))
                {
                    continue;
                }

                string biome = spawn.Ancestors("biome").FirstOrDefault()?.Attribute("name")?.Value
                               ?? "(ohne Landschaft)";
                if (!calledByBiome.TryGetValue(group, out SortedSet<string>? biomes))
                {
                    biomes = new SortedSet<string>(StringComparer.Ordinal);
                    calledByBiome[group] = biomes;
                }

                biomes.Add(biome);
                calls.Add((group, $"spawning.xml:{((IXmlLineInfo)spawn).LineNumber}"));
            }
        }

        // Spielstufen: gamestages.xml, <spawn group>.
        var calledByStage = new HashSet<string>(StringComparer.Ordinal);
        XDocument? stages = source.Load("gamestages.xml");
        if (stages is not null)
        {
            foreach (XElement spawn in stages.Descendants("spawn"))
            {
                string? group = spawn.Attribute("group")?.Value;
                if (string.IsNullOrWhiteSpace(group))
                {
                    continue;
                }

                calledByStage.Add(group);
                calls.Add((group, $"gamestages.xml:{((IXmlLineInfo)spawn).LineNumber}"));
            }
        }

        // --- Verweise
        int missing = 0;

        if (classes is not null)
        {
            foreach ((string group, List<(string Class, int Line)> entries) in
                     groups.OrderBy(g => g.Key, StringComparer.Ordinal))
            {
                foreach ((string className, int line) in entries)
                {
                    if (className == Nothing || classes.Contains(className))
                    {
                        continue;
                    }

                    missing++;
                    report.Error("wesen-verweis-fehlt", className,
                        $"die Gruppe '{group}' nennt diese Klasse (entitygroups.xml:{line}), und "
                        + "entityclasses.xml kennt sie nicht.");
                }
            }
        }
        else
        {
            report.Limitation(
                "Die Quelle hat keine entityclasses.xml: ob die Eintraege der Wesen-Gruppen auf "
                + "vorhandene Klassen zeigen, ist nicht geprueft.");
        }

        foreach (var call in calls
                     .Where(c => !groups.ContainsKey(c.Group))
                     .GroupBy(c => c.Group, StringComparer.Ordinal)
                     .OrderBy(g => g.Key, StringComparer.Ordinal))
        {
            missing++;
            report.Error("wesen-verweis-fehlt", call.Key,
                $"diese Gruppe wird gerufen ({call.Count()}x, zuerst {call.First().Where}), "
                + "und entitygroups.xml kennt sie nicht.");
        }

        // --- Leere Gruppen
        int empty = 0;
        foreach ((string group, List<(string Class, int Line)> entries) in
                 groups.OrderBy(g => g.Key, StringComparer.Ordinal))
        {
            if (entries.Count > 0)
            {
                continue;
            }

            empty++;
            bool called = calledByBiome.ContainsKey(group) || calledByStage.Contains(group);
            if (called)
            {
                report.Error("wesengruppe-leer", group,
                    "die Gruppe hat keinen Eintrag und wird gerufen. Das Spiel bricht das Laden "
                    + "einer leeren Gruppe ab ('Empty entity groups not allowed', statisch "
                    + "gelesen, Finding WP5.4) - jede Gruppe, der Eintraege genommen werden, "
                    + "behaelt mindestens einen.");
            }
            else
            {
                report.Hint("wesengruppe-leer", group,
                    "die Gruppe hat keinen Eintrag; niemand ruft sie.");
            }
        }

        // --- Wesenregeln: nur Landschaftsgruppen
        var inBiomeGroups = new Dictionary<string, SortedSet<string>>(StringComparer.Ordinal);
        foreach (string group in calledByBiome.Keys)
        {
            if (!groups.TryGetValue(group, out List<(string Class, int Line)>? entries))
            {
                continue;
            }

            foreach ((string className, int _) in entries)
            {
                if (className == Nothing)
                {
                    continue;
                }

                if (!inBiomeGroups.TryGetValue(className, out SortedSet<string>? where))
                {
                    where = new SortedSet<string>(StringComparer.Ordinal);
                    inBiomeGroups[className] = where;
                }

                where.Add(group);
            }
        }

        int blocked = 0;
        foreach ((string className, SortedSet<string> inGroups) in
                 inBiomeGroups.OrderBy(c => c.Key, StringComparer.Ordinal))
        {
            if (denylist.MatchCreature(className) is not string rule)
            {
                continue;
            }

            blocked++;
            var biomes = new SortedSet<string>(
                inGroups.SelectMany(g => calledByBiome[g]), StringComparer.Ordinal);
            report.Error("gesperrtes-wesen", className,
                $"steht in {inGroups.Count} Landschaftsgruppe(n) ({string.Join(", ", inGroups)}); "
                + $"gerufen in {string.Join(", ", biomes)}; verboten nach Wesenregel [{rule}]. "
                + "Die Klasse erscheint im Gelaende.");
        }

        report.Count("wesenklassen", classes?.Count ?? 0);
        report.Count("wesengruppen", groups.Count);
        report.Count("landschaftsgruppen", calledByBiome.Count);
        report.Count("klassen_in_landschaftsgruppen", inBiomeGroups.Count);
        report.Count("gesperrte_wesen_in_landschaftsgruppen", blocked);
        report.Count("wesen_verweise_auf_fehlendes", missing);
        report.Count("leere_wesengruppen", empty);

        if (denylist.CreatureRules > 0)
        {
            report.Limitation(
                "Wesenregeln sehen nur Gruppen, die spawning.xml ruft (Landschaften). Schlaefer "
                + "in Orten, Horden und die Seuchennacht (gamestages.xml), Spielereignisse und "
                + "Auftraege stehen nicht darin - und der Name einer Klasse sagt nicht, wie sie "
                + "aussieht.");
        }
    }
}
