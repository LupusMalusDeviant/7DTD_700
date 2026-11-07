using System.Xml.Linq;

namespace Mod700.Check;

/// <summary>Woher eine Kennung ihre Definition hat.</summary>
internal enum DefKind
{
    /// <summary>Kein Eintrag in items.xml, blocks.xml oder item_modifiers.xml.</summary>
    Unresolved,

    Item,
    Block,
    Modifier,

    /// <summary>Name einer Loot-Gruppe, kein Gegenstand.</summary>
    LootGroup
}

/// <summary>
/// Was Vanilla ueber eine Kennung sagt. <see cref="Group"/> traegt absichtlich nur die
/// EIGENE Eigenschaft, <see cref="Tags"/> und <see cref="Class"/> die geerbte — warum,
/// steht in <see cref="Definitions"/>.
/// </summary>
internal sealed record Definition(
    string Name,
    DefKind Kind,
    string? Group,
    IReadOnlySet<string> Tags,
    string? Class,
    IReadOnlySet<string> InstallableTags,
    bool DepthExceeded,
    IReadOnlySet<string> ModifierTags = null!,
    string? Unlocks = null,

    // Vanillas eigene Aussage, wer einen Gegenstand im Kreativmenue sehen darf: None,
    // Player, Dev, All. 'Dev' heisst "nur fuer die Spielentwickler" und ist damit das
    // ehrlichste Signal fuer einen Entwicklergegenstand - ehrlicher als der Tag 'admin',
    // der die tier0xLoadouts und die TEST_ITEM_* nicht traegt.
    string? CreativeMode = null)
{
    public IReadOnlySet<string> ModifierTags { get; init; } = ModifierTags ?? EmptySet;

    public bool HasProperties =>
        Group is not null || Tags.Count > 0 || Class is not null || InstallableTags.Count > 0
        || ModifierTags.Count > 0 || Unlocks is not null || CreativeMode is not null;

    public static Definition None(string name, DefKind kind) => new(
        name, kind, null, EmptySet, null, EmptySet, false);

    internal static readonly IReadOnlySet<string> EmptySet =
        new HashSet<string>(StringComparer.Ordinal);
}

/// <summary>
/// Laedt die Definitionen aus den drei Quellen und loest <c>Extends</c> auf.
///
/// <para><b>Warum Extends sein muss:</b> ohne Aufloesung haben 328 der erreichbaren
/// Kennungen eine <c>Group</c>, mit Aufloesung 932. Wer die Vererbung nicht verfolgt, haelt
/// zwei Drittel fuer eigenschaftslos und faellt auf den Namen zurueck, ohne es zu merken.</para>
///
/// <para><b>Warum Group trotzdem nur eigen zaehlt:</b> eine geerbte Eigenschaft bedeutet nicht
/// immer dasselbe wie eine eigene. <c>questRewardBowCraftingBundle</c> erbt von
/// <c>questRewardBundleMaster</c>, also von einer Vorlage — was fuer die Vorlage gilt, gilt
/// nicht fuer das Buendel. Bei <c>Group = "Special Items"</c> macht das derzeit keinen
/// Unterschied (28 eigene, keine nur geerbten), es ist ein Sicherheitsabstand, keine Behebung
/// eines gemessenen Fehlers. <c>Tags</c> und <c>Class</c> dagegen werden vererbt gemeint: eine
/// Variante eines Stromblocks ist ein Stromblock.</para>
/// </summary>
internal sealed class Definitions
{
    private const int MaxDepth = 12;

    private readonly Dictionary<string, XElement> _items = new(StringComparer.Ordinal);
    private readonly Dictionary<string, XElement> _blocks = new(StringComparer.Ordinal);
    private readonly Dictionary<string, XElement> _modifiers = new(StringComparer.Ordinal);
    private readonly HashSet<string> _lootGroups = new(StringComparer.Ordinal);
    private readonly Dictionary<string, Definition> _cache = new(StringComparer.Ordinal);
    private readonly bool _resolveExtends;

    private Definitions(bool resolveExtends) => _resolveExtends = resolveExtends;

    public int ItemCount => _items.Count;

    public int BlockCount => _blocks.Count;

    public int ModifierCount => _modifiers.Count;

    public int LootGroupCount => _lootGroups.Count;

    /// <summary>Wie oft eine Vererbungskette an <see cref="MaxDepth"/> angestossen ist.</summary>
    public int DepthExceededCount { get; private set; }

    public static Definitions Load(ConfigSource source, bool resolveExtends)
    {
        var defs = new Definitions(resolveExtends);

        Fill(defs._items, source.Load("items.xml"), "item");
        Fill(defs._blocks, source.Load("blocks.xml"), "block");
        Fill(defs._modifiers, source.Load("item_modifiers.xml"), "item_modifier");

        XDocument? loot = source.Load("loot.xml");
        if (loot is not null)
        {
            foreach (XElement g in loot.Descendants("lootgroup"))
            {
                string? name = g.Attribute("name")?.Value;
                if (!string.IsNullOrWhiteSpace(name))
                {
                    defs._lootGroups.Add(name);
                }
            }
        }

        return defs;
    }

    private static void Fill(Dictionary<string, XElement> into, XDocument? document, string element)
    {
        if (document?.Root is null)
        {
            return;
        }

        // Nur die direkten Kinder der Wurzel sind Definitionen. Descendants() wuerde auch
        // <item> innerhalb eines Rezepts oder einer Loot-Gruppe einsammeln.
        foreach (XElement e in document.Root.Elements(element))
        {
            string? name = e.Attribute("name")?.Value;
            if (!string.IsNullOrWhiteSpace(name) && !into.ContainsKey(name))
            {
                into[name] = e;
            }
        }
    }

    /// <summary>
    /// Alle Gegenstaende, auf die ein Mod mit diesen <c>installable_tags</c> passt: jeder
    /// Gegenstand, dessen Tags mindestens einen der Schlitze tragen.
    ///
    /// <para>Das ist die Umkehrung von <c>installable_tags</c> und der Grund, warum die 95
    /// erreichbaren Mods ohne eine einzige eigene Regel beurteilt werden koennen. Gefragt ist,
    /// ob es den Traeger im Spiel noch gibt - nicht, ob er erreichbar ist.</para>
    /// </summary>
    public IEnumerable<string> CarriersFor(IReadOnlySet<string> slots)
    {
        if (slots.Count == 0)
        {
            yield break;
        }

        foreach (string name in _items.Keys)
        {
            Definition def = Lookup(name);
            foreach (string slot in slots)
            {
                if (def.Tags.Contains(slot))
                {
                    yield return name;
                    break;
                }
            }
        }
    }

    public Definition Lookup(string name)
    {
        if (_cache.TryGetValue(name, out Definition? cached))
        {
            return cached;
        }

        Definition result = Build(name);
        _cache[name] = result;
        return result;
    }

    private Definition Build(string name)
    {
        if (_items.TryGetValue(name, out XElement? item))
        {
            return FromElement(name, DefKind.Item, item, _items);
        }

        if (_blocks.TryGetValue(name, out XElement? block))
        {
            return FromElement(name, DefKind.Block, block, _blocks);
        }

        if (_modifiers.TryGetValue(name, out XElement? modifier))
        {
            return FromModifier(name, modifier);
        }

        return Definition.None(name, _lootGroups.Contains(name) ? DefKind.LootGroup : DefKind.Unresolved);
    }

    private Definition FromElement(
        string name, DefKind kind, XElement element, Dictionary<string, XElement> universe)
    {
        bool exceeded = false;

        // Group: nur die eigene Eigenschaft (Begruendung im Klassenkommentar).
        string? group = Own(element, "Group");

        string? tags = Own(element, "Tags");
        string? klass = Own(element, "Class");
        string? creative = Own(element, "CreativeMode");

        if (_resolveExtends)
        {
            tags ??= Inherited(element, universe, "Tags", ref exceeded);
            klass ??= Inherited(element, universe, "Class", ref exceeded);
            creative ??= Inherited(element, universe, "CreativeMode", ref exceeded);
        }

        if (exceeded)
        {
            DepthExceededCount++;
        }

        return new Definition(
            name, kind, group, Tokens(tags), klass, Definition.EmptySet, exceeded,
            Unlocks: Own(element, "Unlocks"),
            CreativeMode: creative);
    }

    private static Definition FromModifier(string name, XElement element) => new(
        name,
        DefKind.Modifier,
        Own(element, "Group"),
        Tokens(Own(element, "Tags")),
        null,
        Tokens(element.Attribute("installable_tags")?.Value),
        false,
        Tokens(element.Attribute("modifier_tags")?.Value),
        Own(element, "Unlocks"));

    private static string? Own(XElement element, string property)
    {
        foreach (XElement p in element.Elements("property"))
        {
            if (p.Attribute("name")?.Value == property)
            {
                string? value = p.Attribute("value")?.Value;
                return string.IsNullOrWhiteSpace(value) ? null : value;
            }
        }

        return null;
    }

    private string? Inherited(
        XElement element, Dictionary<string, XElement> universe, string property, ref bool exceeded)
    {
        XElement current = element;

        for (int depth = 0; depth < MaxDepth; depth++)
        {
            string? extends = Own(current, "Extends");
            if (extends is null)
            {
                return null;
            }

            // "parent" oder "parent,Property1,Property2" - der Elternteil ist das erste Feld.
            string parent = extends.Split(',', 2)[0].Trim();
            if (parent.Length == 0 || !universe.TryGetValue(parent, out XElement? next))
            {
                return null;
            }

            string? value = Own(next, property);
            if (value is not null)
            {
                return value;
            }

            current = next;
        }

        // Eine Kette, die hier anstoesst, ist ein Befund und keine stille Null.
        exceeded = true;
        return null;
    }

    private static IReadOnlySet<string> Tokens(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return Definition.EmptySet;
        }

        var set = new HashSet<string>(StringComparer.Ordinal);
        foreach (string part in value.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            set.Add(part);
        }

        return set;
    }
}
