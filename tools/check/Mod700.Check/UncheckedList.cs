namespace Mod700.Check;

/// <summary>
/// Listet die erreichbaren Kennungen, ueber die keine Regel geurteilt hat, samt ihren
/// Eigenschaften. Kein Pruefbefehl: es gibt kein Rot und kein Gruen, nur eine Liste, und der
/// Exit-Code ist immer 0 (bzw. 2 bei falscher Benutzung).
///
/// <para><b>Warum das ein Befehl des Werkzeugs ist und kein Hilfsskript.</b> In WP3.1 und
/// WP3.1b haben drei selbstgebaute Helfer falsche Zahlen geliefert - ein
/// gross-/kleinschreibungsblinder Mustervergleich, ein Leser, der XML-Kommentare mitzaehlte,
/// und ein Zaehlskript, das 533 statt 28 meldete. Jede dieser Zahlen waere beinahe in ein
/// Dokument gewandert. Die Sichtung der ungepruefen Kennungen ist zu wichtig, um sie auf so
/// etwas zu stuetzen: dieser Befehl liest die Daten mit demselben Code wie die Pruefung
/// selbst, und derselbe Code hat Gegenproben.</para>
/// </summary>
internal static class UncheckedList
{
    public static int Run(string path, string[] args)
    {
        string denylistPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "denylist.txt");
        string? onlyGroup = null;
        bool countOnly = false;

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--denylist" when i + 1 < args.Length:
                    denylistPath = args[++i];
                    break;
                case "--praefix" when i + 1 < args.Length:
                    onlyGroup = args[++i];
                    break;
                case "--nur-zahlen":
                    countOnly = true;
                    break;
                default:
                    throw new UsageException($"Unbekannte Option fuer ungeprueft: {args[i]}");
            }
        }

        Denylist denylist = Denylist.Load(Path.GetFullPath(denylistPath));
        ConfigSource source = ConfigSource.Open(path);
        Definitions definitions = Definitions.Load(source, resolveExtends: true);

        // Mit Aufschub, damit die Liste nicht vorschlaegt, was schon einem spaeteren
        // Arbeitspaket zugewiesen ist.
        Deferrals deferrals = Deferrals.Load(Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "aufschub.txt"));
        Judgement judgement = Judgement.Of(
            source, definitions, denylist, deferrals, NoneDisabled);
        List<Definition> open = judgement.Open().Select(v => v.Definition).ToList();

        // Nach dem ersten Kleinbuchstabenblock gruppieren: 'foodCanTuna' und 'foodRawMeat'
        // landen zusammen, und beim Sichten sieht man Verwandtes nebeneinander.
        var groups = open
            .GroupBy(d => Prefix(d.Name), StringComparer.Ordinal)
            .OrderByDescending(g => g.Count())
            .ThenBy(g => g.Key, StringComparer.Ordinal)
            .ToList();

        Console.WriteLine($"== ungeprueft: {open.Count} Kennungen in {groups.Count} Gruppen ==");
        Console.WriteLine($"   Quelle: {source.Path}");
        Console.WriteLine($"   {source.Info.Note}");
        Console.WriteLine();

        foreach (var group in groups)
        {
            if (onlyGroup is not null && !group.Key.StartsWith(onlyGroup, StringComparison.Ordinal))
            {
                continue;
            }

            Console.WriteLine($"### {group.Key}  ({group.Count()})");

            if (countOnly)
            {
                continue;
            }

            foreach (Definition d in group.OrderBy(d => d.Name, StringComparer.Ordinal))
            {
                string kind = d.Kind switch
                {
                    DefKind.Item => "item",
                    DefKind.Block => "block",
                    DefKind.Modifier => "mod",
                    DefKind.LootGroup => "lootgruppe",
                    _ => "UNAUFLOESBAR"
                };

                var parts = new List<string> { $"[{kind}]" };
                if (d.Class is not null) { parts.Add($"Class={d.Class}"); }
                if (d.Group is not null) { parts.Add($"Group={d.Group}"); }
                if (d.Tags.Count > 0) { parts.Add("Tags=" + string.Join("|", d.Tags.OrderBy(t => t, StringComparer.Ordinal))); }
                if (d.InstallableTags.Count > 0) { parts.Add("auf=" + string.Join("|", d.InstallableTags)); }
                if (parts.Count == 1) { parts.Add("-- keine Eigenschaft --"); }

                Console.WriteLine($"  {d.Name,-44} {string.Join("  ", parts)}");
            }

            Console.WriteLine();
        }

        return 0;
    }

    private static readonly IReadOnlySet<string> NoneDisabled =
        new HashSet<string>(StringComparer.Ordinal);

    private static string Prefix(string name)
    {
        int i = 0;
        while (i < name.Length && char.IsLower(name[i]))
        {
            i++;
        }

        return i == 0 ? name : name[..i];
    }
}
