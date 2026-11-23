using System.Xml;
using System.Xml.Linq;

namespace Mod700.Check;

/// <summary>
/// Prueft die ZIELE der Herausforderungen (challenges.xml): kann der Spieler, was eine
/// Herausforderung verlangt, ueberhaupt noch tun? (Vertrag 04, Nachtrag Ziele der
/// Herausforderungen; D104 Frage 2, D137.)
///
/// <para><b>Warum das ein eigener Blick ist.</b> Ein Ziel ist kein Weg zu einem Gegenstand.
/// "Sammle zehn Rohre" gibt nichts in die Hand, also steht die Herausforderung in keinem der
/// sechs Wege - und der Purge nimmt die Rohre aus dem Spiel, waehrend die Aufgabe stehen
/// bleibt. 35 von 148 sichtbaren Herausforderungen waren so unerfuellbar, und die Pruefung
/// war gruen.</para>
///
/// <para><b>Zwei Signale, getrennt gezaehlt.</b> (1) <i>gesperrt</i>: die Kennung faellt
/// unter eine Regel der Sperrliste - gefragt wird die Regel, nicht die Erreichbarkeit, denn
/// nach dem Purge hat ein gesperrter Gegenstand keinen Weg mehr und trotzdem verlangt die
/// Aufgabe ihn. (2) <i>ohne Weg</i> / <i>ohne Rezept</i> / <i>nicht definiert</i>: die
/// Kennung ist erlaubt, aber es fuehrt nichts zu ihr - der Tippfehler in einem umgebogenen
/// Ziel. Kalibriert am unveraenderten Vanilla V 3.40: dort meldet das zweite Signal
/// nichts.</para>
///
/// <para><b>Eine Liste ist ein Entweder-oder</b> (<c>item="a,b,c"</c> bei CureDebuff). Tot
/// ist ein Ziel erst, wenn KEIN Wert lebt; lebt einer, steht der Rest als Hinweis da. Dass
/// das Spiel Listen so liest, ist eine Annahme, bis ein Finding sie bestaetigt.</para>
/// </summary>
internal static class ChallengeTargets
{
    private const string VariantSuffix = ":VariantHelper";

    public static void Check(
        Report report,
        ConfigSource source,
        Definitions definitions,
        Judgement judgement,
        Deferrals deferrals)
    {
        XDocument? document = source.Load("challenges.xml");
        if (document is null)
        {
            // Kein Fehler: die kleinen Pruefsaetze haben keine. Aber gesagt, nicht verschwiegen.
            report.Count("herausforderungen", "keine challenges.xml - Ziele nicht geprueft");
            return;
        }

        var anyWay = new HashSet<string>(judgement.Names, StringComparer.Ordinal);
        var recipes = new HashSet<string>(
            judgement.Ways.Where(w => w.Via == "Rezept").Select(w => w.Name),
            StringComparer.Ordinal);

        int challenges = 0;
        int namingObjectives = 0;
        int dead = 0;
        int deadBlocked = 0;
        int deadOther = 0;
        int deferred = 0;
        int partial = 0;

        foreach (XElement challenge in document.Descendants("challenge"))
        {
            string? name = challenge.Attribute("name")?.Value;
            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            challenges++;
            var deadTexts = new List<string>();
            var partialTexts = new List<string>();
            bool onlyBlocked = true;

            foreach (XElement objective in challenge.Elements("objective"))
            {
                string type = objective.Attribute("type")?.Value ?? "(ohne type)";
                int line = ((IXmlLineInfo)objective).LineNumber;
                var groups = Groups(objective, type, definitions, judgement, anyWay, recipes);
                if (groups.Count == 0)
                {
                    continue;
                }

                namingObjectives++;

                foreach ((string attribute, List<(string Name, string? State)> values) in groups)
                {
                    var gone = values.Where(v => v.State is not null).ToList();
                    if (gone.Count == 0)
                    {
                        continue;
                    }

                    string listed = string.Join(", ", gone.Select(v => $"{v.Name} ({v.State})"));

                    if (gone.Count == values.Count)
                    {
                        deadTexts.Add($"{type} {attribute} (challenges.xml:{line}): {listed}");
                        if (gone.Any(v => v.State != "gesperrt"))
                        {
                            onlyBlocked = false;
                        }
                    }
                    else
                    {
                        partialTexts.Add(
                            $"{type} {attribute} (challenges.xml:{line}): {listed}; es lebt "
                            + string.Join(", ", values.Where(v => v.State is null).Select(v => v.Name)));
                    }
                }
            }

            if (deadTexts.Count > 0)
            {
                dead++;
                string detail = string.Join(" | ", deadTexts);

                if (deferrals.MatchTarget(name) is string reason)
                {
                    deferred++;
                    report.Hint("aufgeschobenes-ziel", name,
                        $"unerfuellbar, aber aufgeschoben - {reason}. {detail}");
                }
                else
                {
                    if (onlyBlocked)
                    {
                        deadBlocked++;
                    }
                    else
                    {
                        deadOther++;
                    }

                    report.Error("unerfuellbares-ziel", name,
                        $"{detail}. Die Herausforderung steht im Spiel, und niemand kann sie "
                        + "erfuellen: Ziel ersetzen (challenges.xml in 700_50_Fortschritt), oder "
                        + $"mit '{Deferrals.TargetPrefix}{name}  # WP...' in aufschub.txt aufschieben.");
                }
            }
            else if (partialTexts.Count > 0)
            {
                partial++;
                report.Hint("ziel-nennt-gesperrtes", name,
                    string.Join(" | ", partialTexts)
                    + ". Erfuellbar, solange das Spiel die Liste als Entweder-oder liest.");
            }
        }

        report.Count("herausforderungen", challenges);
        report.Count("ziele_mit_kennung", namingObjectives);
        report.Count("unerfuellbare_herausforderungen", dead);
        report.Count("davon_aufgeschoben", deferred);
        report.Count("unerfuellbar_gesperrt", deadBlocked);
        report.Count("unerfuellbar_ohne_weg", deadOther);
        report.Count("ziele_mit_gesperrtem_listenwert", partial);
        report.Count("zielaufschubregeln", deferrals.TargetRules);

        var unused = deferrals.UnusedTargetRules.ToList();
        report.Count("zielaufschub_ohne_treffer", unused.Count);
        foreach (string rule in unused)
        {
            report.Hint("zielaufschub-trifft-nichts", rule,
                "dieser Aufschub hat keine unerfuellbare Herausforderung aufgeschoben. Entweder "
                + "ist sie inzwischen erfuellbar - dann kann die Zeile weg - oder die Kennung "
                + "ist falsch geschrieben.");
        }

        References(report, source, document);

        report.Limitation(
            "Die Zielpruefung liest an einem Ziel nur Kennungen von Gegenstaenden und Bloecken "
            + "(item, block, alternate_item, needed_resource, held mit required_held). Ob es "
            + "die verlangten Wesen, Biome, Haendler, Auftraege oder Zustaende noch gibt "
            + "(Kill, EnterBiome, MeetTrader, QuestComplete, debuff), sieht sie nicht; ebenso "
            + "wenig, ob eine Menge erreichbar ist oder ob das Spiel ein Ziel ueberhaupt "
            + "zaehlt. Eine Liste gilt als Entweder-oder - das ist eine Annahme.");
    }

    /// <summary>
    /// Verweise zwischen Herausforderungen, Gruppen und der Abschluss-Aktion. Noetig, seit
    /// unser Modlet Herausforderungen ENTFERNT (D139): nach Finding F-18 schlaegt das Spiel
    /// drei dieser Namen ohne Vorpruefung nach - eine Herausforderung in einer Gruppe, die
    /// es nicht gibt, ein Ziel 'ChallengeComplete' auf eine fehlende Gruppe, und die
    /// Namensliste der Aktion 'CompleteChallenge' in gameevents.xml. Eine leere Gruppe gilt
    /// sofort als vollstaendig, ihre Zeile bleibt stehen und die Belohnung kommt nie.
    /// </summary>
    private static void References(Report report, ConfigSource source, XDocument document)
    {
        var groups = new HashSet<string>(StringComparer.Ordinal);
        foreach (XElement group in document.Descendants("challenge_group"))
        {
            if (group.Attribute("name")?.Value is string groupName && groupName.Length > 0)
            {
                groups.Add(groupName);
            }
        }

        var names = new HashSet<string>(StringComparer.Ordinal);
        var members = new Dictionary<string, int>(StringComparer.Ordinal);
        int missing = 0;

        foreach (XElement challenge in document.Descendants("challenge"))
        {
            string? name = challenge.Attribute("name")?.Value;
            if (string.IsNullOrWhiteSpace(name))
            {
                continue;
            }

            names.Add(name);
            string? group = challenge.Attribute("group")?.Value;
            if (string.IsNullOrWhiteSpace(group))
            {
                continue;
            }

            members[group] = members.GetValueOrDefault(group) + 1;
            if (!groups.Contains(group))
            {
                missing++;
                report.Error("herausforderung-verweis-fehlt", name,
                    $"steht in der Gruppe '{group}', und die gibt es nicht "
                    + $"(challenges.xml:{((IXmlLineInfo)challenge).LineNumber}). Das Spiel "
                    + "schlaegt die Gruppe ohne Vorpruefung nach (Finding F-18).");
            }
        }

        foreach (XElement challenge in document.Descendants("challenge"))
        {
            string owner = challenge.Attribute("name")?.Value ?? "(ohne name)";
            foreach (XElement objective in challenge.Elements("objective"))
            {
                if (objective.Attribute("type")?.Value != "ChallengeComplete")
                {
                    continue;
                }

                bool isGroup = string.Equals(objective.Attribute("is_group")?.Value, "true",
                    StringComparison.OrdinalIgnoreCase);
                foreach (string target in Values(objective, "challenge"))
                {
                    if (isGroup ? groups.Contains(target) : names.Contains(target))
                    {
                        continue;
                    }

                    missing++;
                    report.Error("herausforderung-verweis-fehlt", owner,
                        $"Ziel ChallengeComplete nennt die {(isGroup ? "Gruppe" : "Herausforderung")} "
                        + $"'{target}', und die gibt es nicht "
                        + $"(challenges.xml:{((IXmlLineInfo)objective).LineNumber}).");
                }
            }
        }

        // Die Abschluss-Aktion: <action class="CompleteChallenge"> mit der Namensliste in
        // <property name="challenges" value="a,b,c"/>.
        XDocument? events = source.Load("gameevents.xml");
        if (events is not null)
        {
            foreach (XElement action in events.Descendants("action"))
            {
                if (action.Attribute("class")?.Value != "CompleteChallenge")
                {
                    continue;
                }

                foreach (XElement property in action.Elements("property"))
                {
                    if (property.Attribute("name")?.Value != "challenges")
                    {
                        continue;
                    }

                    foreach (string target in Values(property, "value"))
                    {
                        if (names.Contains(target))
                        {
                            continue;
                        }

                        missing++;
                        report.Error("herausforderung-verweis-fehlt", target,
                            "die Aktion CompleteChallenge nennt diese Herausforderung, und es "
                            + $"gibt sie nicht (gameevents.xml:{((IXmlLineInfo)property).LineNumber}). "
                            + "Die Aktion greift ohne Vorpruefung zu (Finding F-18).");
                    }
                }
            }
        }

        int empty = 0;
        foreach (string group in groups.OrderBy(g => g, StringComparer.Ordinal))
        {
            if (members.GetValueOrDefault(group) > 0)
            {
                continue;
            }

            empty++;
            report.Error("gruppe-ohne-herausforderung", group,
                "die Gruppe hat keine Herausforderung mehr. Sie gilt sofort als vollstaendig, "
                + "ihre Zeile bleibt im Fenster stehen, und die Gruppenbelohnung kommt nie "
                + "(Finding F-18). Die Gruppe mit entfernen.");
        }

        report.Count("herausforderungsgruppen", groups.Count);
        report.Count("verweise_auf_fehlendes", missing);
        report.Count("gruppen_ohne_herausforderung", empty);
        report.Count("kleinste_gruppe", members.Count == 0 ? 0 : members.Values.Min());
    }

    /// <summary>
    /// Die Gruppen eines Ziels: je Attribut die genannten Kennungen mit ihrem Zustand
    /// (<c>null</c> = lebt). Jede Gruppe muss fuer sich erfuellbar sein; innerhalb einer
    /// Gruppe genuegt ein lebender Wert.
    /// </summary>
    private static List<(string Attribute, List<(string Name, string? State)> Values)> Groups(
        XElement objective,
        string type,
        Definitions definitions,
        Judgement judgement,
        HashSet<string> anyWay,
        HashSet<string> recipes)
    {
        var groups = new List<(string, List<(string, string?)>)>();

        // Herstellen verlangt ein Rezept; alles andere irgendeinen Weg.
        bool craft = type == "Craft";

        List<(string, string?)> items = Values(objective, "item")
            .Select(v => (v, ItemState(v, craft, judgement, anyWay, recipes)))
            .ToList();
        if (items.Count > 0)
        {
            groups.Add(("item", items));
        }

        // Ein Block wird gesetzt oder aufgewertet, nicht erworben: 'wallTorchLightPlayer'
        // hat in Vanilla keinen Weg, die Fackel in der Hand (alternate_item) setzt ihn. Darum
        // gilt fuer Bloecke "definiert und nicht gesperrt", und alternate_item zaehlt als
        // zweiter Wert derselben Gruppe.
        List<(string, string?)> blocks = Values(objective, "block")
            .Select(v => (v, BlockState(v, definitions, judgement)))
            .Concat(Values(objective, "alternate_item")
                .Select(v => (v, ItemState(v, false, judgement, anyWay, recipes))))
            .ToList();
        if (blocks.Count > 0)
        {
            groups.Add(("block", blocks));
        }

        List<(string, string?)> resources = Values(objective, "needed_resource")
            .Select(v => (v, ItemState(v, false, judgement, anyWay, recipes)))
            .ToList();
        if (resources.Count > 0)
        {
            groups.Add(("needed_resource", resources));
        }

        // 'held' ist nur dann eine Bedingung, wenn das Ziel es verlangt.
        if (string.Equals(objective.Attribute("required_held")?.Value, "true",
                StringComparison.OrdinalIgnoreCase))
        {
            List<(string, string?)> held = Values(objective, "held")
                .Select(v => (v, ItemState(v, false, judgement, anyWay, recipes)))
                .ToList();
            if (held.Count > 0)
            {
                groups.Add(("held", held));
            }
        }

        return groups;
    }

    private static IEnumerable<string> Values(XElement objective, string attribute) =>
        (objective.Attribute(attribute)?.Value ?? string.Empty)
        .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

    private static string Bare(string name) =>
        name.EndsWith(VariantSuffix, StringComparison.Ordinal)
            ? name[..^VariantSuffix.Length]
            : name;

    private static string? ItemState(
        string name, bool craft, Judgement judgement,
        HashSet<string> anyWay, HashSet<string> recipes)
    {
        string bare = Bare(name);
        if (judgement.IsBlockedName(bare))
        {
            return "gesperrt";
        }

        if (craft)
        {
            return recipes.Contains(name) || recipes.Contains(bare) ? null : "ohne Rezept";
        }

        return anyWay.Contains(name) || anyWay.Contains(bare) ? null : "ohne Weg";
    }

    private static string? BlockState(string name, Definitions definitions, Judgement judgement)
    {
        string bare = Bare(name);
        if (judgement.IsBlockedName(bare))
        {
            return "gesperrt";
        }

        return definitions.Lookup(bare).Kind == DefKind.Unresolved ? "nicht definiert" : null;
    }
}
