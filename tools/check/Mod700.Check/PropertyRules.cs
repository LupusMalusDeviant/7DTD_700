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

    /// <summary>
    /// Was ein Aufsatz tut, steht in seinen <c>modifier_tags</c>. Diese Werte benennen
    /// moderne Technik. Nicht in der Liste und darum erlaubt: dye, durability, health,
    /// movement, resistance, shaft, accuracy, grips, velocity, damageStone/Iron/Dirt,
    /// stealth, thermal, misc.
    /// </summary>
    private static readonly HashSet<string> ModernModifierTags = new(StringComparer.Ordinal)
    {
        "scope", "nightVision", "sideAttachment", "magazine", "trigger",
        "barrelTipAttachment", "barrelAttachment", "stocks", "waterPurifier",
        "fuel", "droneWeapon"
    };

    /// <summary>
    /// Die 'challenge_*'-Marken, die einen modernen Werkstoff benennen. Vanilla haengt sie
    /// an Bloecke, damit die Herausforderung "schlachte zehn Autos aus" zaehlen kann - und
    /// benennt damit nebenbei, woraus ein Block besteht. 'challenge_leather' fehlt
    /// absichtlich: Leder gab es um 700.
    /// </summary>
    private static readonly HashSet<string> ModernMaterialTags = new(StringComparer.Ordinal)
    {
        "challenge_elec_parts", "challenge_polymers", "challenge_mech_parts",
        "challenge_cars", "challenge_sinks"
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
            "Tag 'admin', eigene Group 'Special Items' oder CreativeMode 'Dev': Werkzeuge der "
            + "Spielentwickler und Vorlagen-Gegenstaende. CreativeMode kam in WP3.1c dazu, "
            + "weil Tag und Group die tier0xLoadouts und die TEST_ITEM_* beide nicht tragen - "
            + "die Loadouts erben ihr 'Dev' von noteTestersDelightAdmin und teilen ueber "
            + "Create_item Schmerzmittel und Metallrohre aus.",
            d => d.Tags.Contains("admin") || d.Group == "Special Items"
                 || d.CreativeMode == "Dev"),

        new("sprengkoerper",
            "Item-Klasse 'ItemClassTimeBomb': was einen Zuender hat. Trifft Molotow, Rohrbombe, "
            + "Dynamit, Granaten und Zeitladung. Der Tag 'explosivesSkill' waere das naechste "
            + "Signal gewesen und ist unbrauchbar - Vanilla haengt auch den Dietrich daran, "
            + "weil der Perk beides traegt. D9 bleibt gewahrt: die Klasse bleibt stehen, "
            + "damit F-15 daraus Runenfallen machen kann, nur der Weg dahin faellt.",
            d => d.Class == "ItemClassTimeBomb"),

        new("robotik",
            "Tag 'roboticsSkill': Vanillas Robotik-Zweig - Elektroschlagstock und seine Teile. "
            + "Schwesterregel zu 'elektrikerhandwerk'; Drohne und Junk-Turret fallen schon "
            + "ueber den Namen, aber der Schlagstock trug keine der beiden Marken.",
            d => d.Tags.Contains("roboticsSkill")),

        new("strom",
            "Block-Klasse aus der Stromliste (Generator, Schalter, Relais, Melder, Platte, "
            + "Scheinwerfer, Lautsprecher, Automat, Mine, bewegliche Tueren). Eine Regel "
            + "statt vieler Namen - sie fand motionsensor, switch und spotlightPlayer, die in "
            + "der Denylist nach Namen alle drei fehlten.",
            d => d.Kind == DefKind.Block && d.Class is not null && PoweredClasses.Contains(d.Class)),

        new("moderner_aufsatz",
            "Ein Mod traegt 'modifier_tags', und Vanilla benennt darin, WAS der Aufsatz tut. "
            + "Optik ('scope'), Nachtsicht, Seitenaufsatz (Laserpunkt und Taschenlampe), "
            + "Magazin, Abzugsgruppe, Lauf- und Schaftteile, Wasserfilter, Treibstofftank und "
            + "Drohnenwaffe sind moderne Technik. Das trifft auch die Aufsaetze, die ueber die "
            + "Traeger-Ableitung durchkaemen, weil die Armbrust ihre Schlitze teilt: eine "
            + "Armbrust mit Laserpunkt waere kein Anachronismus nach Traeger, aber einer.",
            d => d.ModifierTags.Overlaps(ModernModifierTags)),

        new("elektrikerhandwerk",
            "Tag 'electricianSkill': Vanilla haengt alles, was der Elektriker baut, an diese "
            + "Fertigkeit. Zweitsignal zur Stromregel und faengt, was keine eigene Klasse hat "
            + "(batterybank, switch, tripwirepost, meleeToolWireTool).",
            d => d.Tags.Contains("electricianSkill")),

        new("moderner_werkstoff",
            "Vanilla markiert mit 'challenge_*', welchen modernen Rohstoff ein Block beim "
            + "Abbau hergibt. Elektrikteile, Kunststoffe, Mechanikteile, Autoteile und "
            + "Sanitaerkeramik gab es um 700 nicht, also auch nicht die Bloecke daraus: "
            + "Klimaanlage, Fernseher, Nachttischlampe, Kasse, Kuehlbox, Jalousie, "
            + "Buerostuhl, Rohre, Waschbecken, Toiletten, Wanduhr. 'challenge_leather' steht "
            + "bewusst NICHT in der Liste - Leder ist kein Anachronismus. Dieses Signal ist "
            + "mittelbar: es sagt 'besteht aus', nicht 'ist modern'. Darum steht die Regel "
            + "als letzte - jede andere Regel soll zuerst urteilen duerfen.",
            d => d.Tags.Overlaps(ModernMaterialTags))
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
