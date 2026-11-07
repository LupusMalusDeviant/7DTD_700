namespace Mod700.Check;

/// <summary>Eine Regel, die ueber eine Eigenschaft urteilt, nicht ueber einen Namen.</summary>
internal sealed record PropertyRule(string Id, string Reason, Func<Definition, bool> Matches);

/// <summary>
/// Die Eigenschaftsregeln aus Vertrag 04 §3a.
///
/// <para>Jede Regel hier ist <b>gemessen</b>, nicht vermutet: die Zahl in Klammern ist die
/// Trefferzahl gegen Vanilla V 3.40, und bei jeder steht, was sie NICHT trifft. Drei Regeln
/// des Vertragsentwurfs haben die Messung nicht ueberlebt und stehen darum nicht hier:</para>
/// <list type="bullet">
/// <item>Die Munitionsregel sollte <c>ammo44Magnum</c> und <c>ammoShotgun</c> abdecken —
/// diese Tags gibt es in Vanilla nicht. Nur <c>ammo9mm</c> und <c>ammo762mm</c> existieren,
/// das sind 6 von 28 Munitionssorten. Der Rest bleibt beim Namen.</item>
/// <item><c>Group = "Special Items"</c> sollte "die vier Admin-Items und die zehn
/// TEST_ITEM_*" treffen. Es trifft 28 Entwickler- und Vorlagen-Gegenstaende und <b>keinen
/// einzigen</b> TEST_ITEM: die tragen <c>Group = Decor/Miscellaneous</c> und
/// <c>Tags = ammo</c>. Die TEST_ITEMs brauchen eine Namensregel.</item>
/// <item>Die Admin-Regel trifft 13, nicht 4.</item>
/// </list>
///
/// <para>Ein Befund nennt immer die Regel-Kennung und ihre Begruendung. Eine Regel ohne
/// nachlesbaren Grund ist kein Befund, sondern eine Behauptung.</para>
/// </summary>
internal static class PropertyRules
{
    /// <summary>
    /// Block-Klassen, die Strom brauchen oder moderne Technik sind. D9 bleibt gewahrt, weil
    /// hier nur der WEG zum Gegenstand faellt — die Klasse selbst bleibt in blocks.xml
    /// stehen, damit F-15 sie in Phase 2 umdeuten kann (Vertrag 03 §4).
    /// </summary>
    private static readonly HashSet<string> PoweredClasses = new(StringComparer.Ordinal)
    {
        "Powered", "PoweredLight", "PoweredDoor", "Generator", "SolarPanel",
        "Switch", "TimerRelay", "MotionSensor", "PressurePlate", "TripWire",
        "Spotlight", "Speaker", "SpeakerTrader", "VendingMachine", "Mine"
    };

    public static readonly IReadOnlyList<PropertyRule> All = new PropertyRule[]
    {
        new("schusswaffe",
            "Vanilla markiert Feuerwaffen mit dem Tag 'gun' (19 Stueck). Boegen und Armbrueste "
            + "tragen stattdessen 'bow', 'archery' oder 'crossbow' und bleiben nach D54 - das "
            + "ist die Trennung, die kein Namensmuster leisten konnte, weil beide 'gun...' heissen.",
            d => d.Tags.Contains("gun")),

        new("patronenmunition",
            "Patronen tragen ein Kaliber-Tag ('ammo9mm', 'ammo762mm'). Pfeile und Bolzen tragen "
            + "'perkArchery' und bleiben nach D54. Deckt nur 6 der 28 Munitionssorten: fuer "
            + "Schrot und Magnum fuehrt Vanilla kein Kaliber-Tag, die bleiben beim Namen.",
            d => d.Tags.Contains("ammo9mm") || d.Tags.Contains("ammo762mm")),

        new("entwicklergegenstand",
            "Tag 'admin' (13 Stueck) oder eigene Group 'Special Items' (28): Werkzeuge der "
            + "Spielentwickler und Vorlagen-Gegenstaende. Trifft die TEST_ITEM_* NICHT, die "
            + "tragen Group 'Decor/Miscellaneous'.",
            d => d.Tags.Contains("admin") || d.Group == "Special Items"),

        new("strom",
            "Block-Klasse aus der Stromliste (Generator, Schalter, Relais, Melder, Platte, "
            + "Scheinwerfer, Lautsprecher, Automat, Mine, bewegliche Tueren). Eine Regel "
            + "statt vieler Namen - sie fand motionsensor, switch und spotlightPlayer, die in "
            + "der Denylist nach Namen alle drei fehlten.",
            d => d.Kind == DefKind.Block && d.Class is not null && PoweredClasses.Contains(d.Class)),

        new("elektrikerhandwerk",
            "Tag 'electricianSkill': Vanilla haengt alles, was der Elektriker baut, an diese "
            + "Fertigkeit. Zweitsignal zur Stromregel und faengt, was keine eigene Klasse hat "
            + "(batterybank, switch, tripwirepost, meleeToolWireTool).",
            d => d.Tags.Contains("electricianSkill"))
    };

    /// <summary>
    /// Die erste zutreffende Regel, oder null. Die Reihenfolge entscheidet, welche Regel im
    /// Befund steht — darum stehen die aussagekraeftigsten oben.
    /// </summary>
    public static PropertyRule? Match(Definition definition, IReadOnlySet<string> disabled)
    {
        foreach (PropertyRule rule in All)
        {
            if (!disabled.Contains(rule.Id) && rule.Matches(definition))
            {
                return rule;
            }
        }

        return null;
    }

    public static bool Exists(string id) => All.Any(r => r.Id == id);

    public static string Ids => string.Join(", ", All.Select(r => r.Id));
}
