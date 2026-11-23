namespace Mod700.Check;

/// <summary>Wie eine Kennung beurteilt wurde.</summary>
internal sealed record Verdict(
    string Name,
    Definition Definition,
    bool Blocked,
    string By,
    string? Rule,
    string? Reason);

/// <summary>
/// Das Urteil ueber alle erreichbaren Kennungen — an EINER Stelle.
///
/// <para>Die Pruefung (<see cref="AnachronismCheck"/>) und die Sichtungsliste
/// (<see cref="UncheckedList"/>) fragen dasselbe und muessen dieselbe Antwort bekommen. Als
/// die Liste ihre eigene Fassung hatte, meldete sie 822 ungepruefe Kennungen und die Pruefung
/// 800 — die Liste rechnete die Mod-Ableitung nicht mit. Zwei Implementierungen derselben
/// Frage sind zwei Gelegenheiten, verschiedene Antworten zu geben.</para>
///
/// <para><b>Reihenfolge</b> (Vertrag 04 §3a): Freigabe schlaegt alles, dann entscheidet die
/// EIGENSCHAFT, und erst wenn keine zutrifft, der Name. Umgekehrt waere
/// <c>verboten_nach_name</c> sinnlos — es wuerde nur sagen, was zufaellig auch ein
/// Namensmuster trifft, nicht was ohne den Namen durchfiele.</para>
/// </summary>
internal sealed class Judgement
{
    private readonly Dictionary<string, Verdict> _verdicts = new(StringComparer.Ordinal);
    private readonly Definitions _definitions;
    private readonly Denylist _denylist;
    private readonly Deferrals _deferrals;
    private readonly IReadOnlySet<string> _disabled;

    private Judgement(
        Definitions definitions, Denylist denylist, Deferrals deferrals,
        IReadOnlySet<string> disabled)
    {
        _definitions = definitions;
        _denylist = denylist;
        _deferrals = deferrals;
        _disabled = disabled;
    }

    public IReadOnlyList<Way> Ways { get; private set; } = Array.Empty<Way>();

    public IReadOnlyList<string> Names { get; private set; } = Array.Empty<string>();

    public IReadOnlyCollection<Verdict> Verdicts => _verdicts.Values;

    public int Unresolved { get; private set; }

    public int LootGroups { get; private set; }

    public int WithoutProperties { get; private set; }

    public int ModsFallen { get; private set; }

    /// <summary>Mods, ueber die nicht geurteilt werden konnte, mit Begruendung.</summary>
    public List<(string Name, string Rule, string Detail)> ModsUnjudged { get; } = new();

    public static Judgement Of(
        ConfigSource source,
        Definitions definitions,
        Denylist denylist,
        Deferrals deferrals,
        IReadOnlySet<string> disabledRules)
    {
        var j = new Judgement(definitions, denylist, deferrals, disabledRules);

        j.Ways = Reachability.Ways(source);
        j.Names = j.Ways
            .Select(w => w.Name)
            .Distinct(StringComparer.Ordinal)
            .OrderBy(n => n, StringComparer.Ordinal)
            .ToList();

        j.FirstPass();
        j.ModPass();
        j.UnlocksPass();
        j.DeferralPass();
        return j;
    }

    /// <summary>
    /// Bucht aufgeschobene Anachronismen aus den Fehlern in die Hinweise um. Laeuft als
    /// LETZTER Durchgang, damit auch das aufgeschoben wird, was erst eine Ableitung gefunden
    /// hat. Die Kennung bleibt als verboten erkannt - sie zaehlt nur nicht gegen das laufende
    /// Arbeitspaket.
    /// </summary>
    private void DeferralPass()
    {
        foreach (string name in Names)
        {
            Verdict verdict = _verdicts[name];
            if (!verdict.Blocked)
            {
                continue;
            }

            if (_deferrals.Match(name) is string reason)
            {
                Deferred++;
                _verdicts[name] = verdict with
                {
                    Blocked = false,
                    By = "aufgeschoben",
                    Reason = $"verboten nach {verdict.By} [{verdict.Rule}], aber aufgeschoben - {reason}"
                };
            }
        }
    }

    public int Deferred { get; private set; }

    private void FirstPass()
    {
        foreach (string name in Names)
        {
            Definition def = _definitions.Lookup(name);

            if (def.Kind == DefKind.LootGroup)
            {
                // Eine Loot-Gruppe ist kein Gegenstand. Sie taucht als erreichbar auf, weil
                // eine Quest-Belohnung oder ein Loot-Eintrag auf sie zeigt - was der Spieler
                // daraus bekommt, sind ihre Mitglieder, und die werden einzeln beurteilt.
                // Darum gehoert sie nicht in 'ungeprueft': dort stand sie 70 Mal und liess
                // die offene Arbeit groesser aussehen, als sie ist.
                LootGroups++;
                _verdicts[name] = new Verdict(name, def, false, "lootgruppe", null,
                    "Loot-Gruppe, kein Gegenstand - ihre Mitglieder werden einzeln beurteilt.");
                continue;
            }
            else if (def.Kind == DefKind.Unresolved)
            {
                Unresolved++;
            }
            else if (!def.HasProperties)
            {
                WithoutProperties++;
            }

            string? nameRule = _denylist.Match(name, out string? allowReason);

            if (allowReason is not null)
            {
                _verdicts[name] = new Verdict(name, def, false, "freigabe", null, allowReason);
                continue;
            }

            // Eigenschaftsregeln gelten auch fuer Mods: 'moderner_aufsatz' urteilt ueber
            // modifier_tags. Die Traeger-Ableitung im zweiten Durchgang kommt zusaetzlich.
            if (PropertyRules.Match(def, _disabled) is PropertyRule rule)
            {
                _verdicts[name] = new Verdict(name, def, true, "eigenschaft", rule.Id, rule.Reason);
                continue;
            }

            if (nameRule is not null)
            {
                _verdicts[name] = new Verdict(name, def, true, "name", nameRule,
                    "keine Eigenschaft hat entschieden, nur das Namensmuster");
                continue;
            }

            _verdicts[name] = new Verdict(name, def, false, "ungeprueft", null, null);
        }
    }

    /// <summary>
    /// Mods werden ABGELEITET, nicht aufgezaehlt: ein Mod faellt, wenn jeder Gegenstand, auf
    /// den er passt, selbst gesperrt ist. Ob der Traeger erreichbar ist, geht nicht ein —
    /// gefragt ist, ob es ihn im Spiel noch gibt.
    /// </summary>
    private void ModPass()
    {
        foreach (string name in Names)
        {
            Verdict verdict = _verdicts[name];
            if (verdict.Definition.Kind != DefKind.Modifier || verdict.Blocked ||
                verdict.By == "freigabe")
            {
                continue;
            }

            IReadOnlySet<string> slots = verdict.Definition.InstallableTags;
            if (slots.Count == 0)
            {
                ModsUnjudged.Add((name, "mod-ohne-traegerangabe",
                    "kein installable_tags - ueber diesen Mod kann nicht nach Eigenschaft "
                    + "geurteilt werden; er braucht eine Namensregel oder eine Ausnahme."));
                continue;
            }

            List<string> carriers = _definitions.CarriersFor(slots).ToList();
            if (carriers.Count == 0)
            {
                ModsUnjudged.Add((name, "mod-ohne-traeger",
                    $"kein Gegenstand traegt {string.Join("/", slots)} - nicht beurteilbar, "
                    + "also auch nicht gesperrt."));
                continue;
            }

            if (carriers.All(IsBlocked))
            {
                ModsFallen++;
                _verdicts[name] = verdict with
                {
                    Blocked = true,
                    By = "mod-ableitung",
                    Rule = "mod-ohne-ueberlebenden-traeger",
                    Reason = $"passt nur auf {string.Join("/", slots)}; alle {carriers.Count} "
                             + "Traeger sind gesperrt, also faellt der Mod mit ihnen."
                };
            }
        }
    }

    /// <summary>
    /// Ein Schaltplan oder Lehrbuch traegt <c>Unlocks</c> mit dem Namen dessen, was es
    /// freischaltet: <c>modGunScopeLargeSchematic</c> hat
    /// <c>Unlocks = "modGunScopeLarge"</c>. Faellt das Freigeschaltete, faellt der Schaltplan
    /// mit — sonst bliebe eine Bauanleitung fuer etwas Gesperrtes im Loot liegen.
    ///
    /// <para>Das steht in den Daten und ist keine Namensregel. Die Namenskonvention
    /// (Mod + "Schematic") gilt zwar auch, aber <c>Unlocks</c> ist das, was das Spiel selbst
    /// benutzt — und es trifft auch die Faelle, in denen die Namen nicht zusammenpassen.</para>
    ///
    /// <para>Laeuft nach der Mod-Ableitung, damit ein Schaltplan auch dann faellt, wenn sein
    /// Mod erst dort gefallen ist. Ein Schaltplan, der einen Schaltplan freischaltet, kaeme
    /// erst in einem weiteren Durchgang dran; so etwas gibt es in Vanilla nicht, und wenn es
    /// auftaucht, bleibt es als ungeprueft stehen statt still durchzufallen.</para>
    /// </summary>
    private void UnlocksPass()
    {
        foreach (string name in Names)
        {
            Verdict verdict = _verdicts[name];
            if (verdict.Blocked || verdict.By == "freigabe")
            {
                continue;
            }

            string? target = verdict.Definition.Unlocks;
            if (string.IsNullOrWhiteSpace(target))
            {
                continue;
            }

            // Unlocks kann auch auf einen Fertigkeitsbaum zeigen (craftingElectrician) -
            // daraus laesst sich nichts ableiten, das bleibt ungeprueft.
            Definition targetDef = _definitions.Lookup(target);
            if (targetDef.Kind is DefKind.Unresolved or DefKind.LootGroup)
            {
                continue;
            }

            // Die Ableitung gilt in BEIDE Richtungen. Faellt das Freigeschaltete, faellt der
            // Bauplan; bleibt es erlaubt, bleibt der Bauplan erlaubt. Ohne die zweite
            // Haelfte standen 37 Baulaene als 'ungeprueft' da und verlangten je eine eigene
            // Regel - fuer eine Frage, die in den Daten schon beantwortet ist. Welche
            // Bauplaene es am Ende ueberhaupt noch gibt, entscheidet F-21 in WP7 (D47);
            // hier geht es nur darum, ob F-01 etwas gegen diesen einzuwenden hat.
            if (!IsBlocked(target))
            {
                UnlocksErlaubt++;
                _verdicts[name] = verdict with
                {
                    By = "unlocks-ableitung",
                    Rule = "schaltet-erlaubtes-frei",
                    Reason = $"schaltet '{target}' frei, und das ist erlaubt - der Bauplan "
                             + "folgt dem, was er freischaltet."
                };
                continue;
            }

            UnlocksFallen++;
            _verdicts[name] = verdict with
            {
                Blocked = true,
                By = "unlocks-ableitung",
                Rule = "schaltet-gesperrtes-frei",
                Reason = $"schaltet '{target}' frei, und das ist gesperrt - eine Bauanleitung "
                         + "fuer etwas Gesperrtes gehoert nicht ins Loot."
            };
        }
    }

    public int UnlocksFallen { get; private set; }

    public int UnlocksErlaubt { get; private set; }

    /// <summary>
    /// Ist diese Kennung gesperrt — auch wenn sie auf keinem Weg mehr erreichbar ist? Die
    /// Zielpruefung braucht genau das: nach dem Purge hat ein gesperrter Gegenstand keinen
    /// Weg mehr und darum kein Urteil in <see cref="Verdicts"/>, aber eine Herausforderung
    /// verlangt ihn weiter. Eine aufgeschobene Kennung gilt hier als lebend, wie ueberall.
    ///
    /// <para>ACHTUNG: schreibt der Sperrliste Treffer zu. Erst aufrufen, wenn die Listen der
    /// Regeln ohne Treffer schon gebildet sind.</para>
    /// </summary>
    public bool IsBlockedName(string name) => IsBlocked(name);

    private bool IsBlocked(string carrier)
    {
        if (_verdicts.TryGetValue(carrier, out Verdict? known))
        {
            return known.Blocked;
        }

        // Traeger, der selbst nicht erreichbar ist: nach denselben Regeln beurteilen.
        if (_denylist.Match(carrier, out string? allow) is not null && allow is null)
        {
            return true;
        }

        return allow is null &&
               PropertyRules.Match(_definitions.Lookup(carrier), _disabled) is not null;
    }

    public int Count(string by) => _verdicts.Values.Count(v => v.By == by);

    public List<Verdict> Blocked() => _verdicts.Values
        .Where(v => v.Blocked)
        .OrderBy(v => v.Name, StringComparer.Ordinal)
        .ToList();

    public List<Verdict> Open() => _verdicts.Values
        .Where(v => v.By == "ungeprueft")
        .OrderBy(v => v.Name, StringComparer.Ordinal)
        .ToList();
}
