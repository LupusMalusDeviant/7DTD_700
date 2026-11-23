namespace Mod700.Check;

/// <summary>
/// Prueft, ob ein verbotener Gegenstand noch irgendwo steht, wo ein Spieler ihn ERREICHEN
/// kann. Die bloesse Existenz in items.xml ist kein Befund — gesperrte Gegenstaende bleiben
/// absichtlich stehen, weil Prefabs und Quests auf sie zeigen (Vertrag 03, Abschnitt 4).
///
/// Erreichbar heisst: ueber einen Block-Abwurf, ein Rezept, eine Loot-Gruppe, eine
/// Haendlergruppe, eine Quest-Belohnung oder die Startausruestung. Der Block-Abwurf kam am
/// 7. November 2026 dazu (siehe Reachability) - bis dahin war er ein Loch.
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
        string deferralPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "aufschub.txt");
        bool asJson = false;
        bool resolveExtends = true;
        bool useDeferrals = true;
        var disabledRules = new HashSet<string>(StringComparer.Ordinal);

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--denylist" when i + 1 < args.Length:
                    denylistPath = args[++i];
                    break;
                case "--aufschub" when i + 1 < args.Length:
                    deferralPath = args[++i];
                    break;

                // Gegenprobe: ohne Aufschub muessen die aufgeschobenen Kennungen wieder
                // als Fehler erscheinen. Sonst waere nicht zu sehen, dass der Aufschub
                // etwas umbucht und nicht etwas verschweigt.
                case "--ohne-aufschub":
                    useDeferrals = false;
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
        Deferrals deferrals = useDeferrals
            ? Deferrals.Load(Path.GetFullPath(deferralPath))
            : Deferrals.Empty();
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

        // Das Urteil kommt aus Judgement - derselben Klasse, die auch 'ungeprueft' benutzt.
        // Als die Liste ihre eigene Fassung hatte, wichen die Zahlen um 22 ab.
        Judgement judgement = Judgement.Of(
            source, definitions, denylist, deferrals, disabledRules);

        report.Count("erreichbarkeitswege", judgement.Ways.Count);
        report.Count("gepruefte_kennungen", judgement.Names.Count);

        // --- Zaehlen und berichten
        List<Verdict> blocked = judgement.Blocked();

        report.Count("durch_freigabe_erlaubt", judgement.Count("freigabe"));
        report.Count("verboten_nach_eigenschaft", blocked.Count(v => v.By == "eigenschaft"));
        report.Count("verboten_nach_name", blocked.Count(v => v.By == "name"));
        report.Count("verboten_durch_mod_ableitung", judgement.ModsFallen);
        report.Count("verboten_durch_unlocks_ableitung", judgement.UnlocksFallen);
        report.Count("erlaubt_durch_unlocks_ableitung", judgement.UnlocksErlaubt);
        report.Count("aufgeschoben", judgement.Deferred);
        report.Count("aufschubregeln", deferrals.Rules);
        report.Count("mods_nicht_beurteilbar", judgement.ModsUnjudged.Count);
        report.Count("unaufloesbar", judgement.Unresolved);
        report.Count("loot_gruppen_erreichbar", judgement.LootGroups);
        report.Count("ohne_eigenschaft", judgement.WithoutProperties);
        report.Count("extends_tiefe_erreicht", definitions.DepthExceededCount);
        report.Count("ungeprueft", judgement.Count("ungeprueft"));
        report.Count("verbotene_kennungen", blocked.Count);

        // Eine Regel ohne Treffer ist nicht zwingend falsch - aber sie soll auffallen.
        // 'drugs*' und 'magazine*' waren beide Tippfehler, die sich wie Arbeit anfuehlten.
        (List<string> emptyRules, List<string> shadowedRules) =
            denylist.ClassifyUnused(judgement.Names);

        report.Count("verbotsregeln_ohne_treffer", emptyRules.Count);
        report.Count("verbotsregeln_verdeckt", shadowedRules.Count);

        // Eine Freigabe ohne Treffer ist der gefaehrlichere Tippfehler von beiden: eine
        // Verbotsregel, die nicht greift, laesst etwas durch und faellt als Befund auf; eine
        // Freigabe, die nicht greift, laesst etwas FALLEN, und der Befund sieht aus wie
        // Arbeit, die getan wurde.
        var unusedAllow = denylist.UnusedAllowRules.ToList();
        report.Count("freigaberegeln_ohne_treffer", unusedAllow.Count);

        // Die Regelpruefung braucht eine vollstaendige Config. Gegen einen kleinen
        // Pruefsatz mit elf Kennungen sieht fast jede Regel "tot" aus, und sechzig
        // nutzlose Hinweise verdraengen die echten Befunde aus der Ausgabe - genau das ist
        // beim ersten Versuch passiert. Die ZAHL steht oben in jedem Fall; aufgezaehlt
        // werden die Regeln nur, wenn die Quelle gross genug ist, dass es etwas bedeutet.
        bool worthListing = emptyRules.Count <= 5 ||
                            emptyRules.Count * 2 <= denylist.DenyRules;

        if (worthListing)
        {
            foreach (string rule in emptyRules)
            {
                report.Hint("verbotsregel-trifft-nichts", rule,
                    "auf diese Verbotsregel passt keine einzige erreichbare Kennung. Entweder "
                    + "zeigt sie auf etwas, das es in dieser Spielfassung nicht gibt - oder sie "
                    + "ist falsch geschrieben, so wie 'magazine*' statt '*SkillMagazine'.");
            }

            foreach (string rule in unusedAllow)
            {
                report.Hint("freigaberegel-trifft-nichts", rule,
                    "dieser Freigabe wurde keine einzige erreichbare Kennung zugeschrieben. "
                    + "Entweder passt keine - dann ist das Muster falsch geschrieben und "
                    + "laesst etwas fallen, was bleiben sollte - oder eine breitere Freigabe "
                    + "weiter oben bekommt sie zugeschrieben, dann ist die Zeile nur "
                    + "ueberfluessig. Anders als bei den Verbotsregeln trennt der Bericht "
                    + "diese beiden Faelle hier nicht: so lange die Zahl klein ist, ist das "
                    + "Nachsehen in der Datei billiger als die Unterscheidung im Werkzeug.");
            }

            foreach (string rule in shadowedRules)
            {
                report.Hint("verbotsregel-verdeckt", rule,
                    "diese Regel wuerde passen, aber eine breitere Regel weiter oben in der "
                    + "Datei bekommt die Kennungen zugeschrieben. Harmlos und oft Absicht - die "
                    + "engere Regel haelt fest, WARUM etwas fallen soll - nur wirkungslos.");
            }
        }
        else
        {
            report.Limitation(
                $"Die Regelpruefung ist hier nicht aufgezaehlt: {emptyRules.Count} von "
                + $"{denylist.DenyRules} Verbotsregeln haben keinen Treffer, und das heisst "
                + "bei dieser Quelle nur, dass sie zu klein ist. Die Zahl steht oben, die "
                + "Aufzaehlung braucht eine vollstaendige Config.");
        }

        var waysByName = judgement.Ways
            .GroupBy(r => r.Name, StringComparer.Ordinal)
            .ToDictionary(g => g.Key, g => g.ToList(), StringComparer.Ordinal);

        foreach (Verdict v in blocked)
        {
            string ways = string.Join(", ", waysByName[v.Name]
                .GroupBy(h => h.Via)
                .Select(g => $"{g.Key} ({g.Count()}x, zuerst {g.First().Where})"));

            report.Error("erreichbarer-anachronismus", v.Name,
                $"erreichbar ueber {ways}; verboten nach {v.By} [{v.Rule}]: {v.Reason}");
        }

        // Auftraege (D103, Vertrag 04, Nachtrag Auftragsregeln). Ein Auftrag gibt nichts in
        // die Hand und steht darum in keinem der sechs Wege oben - "wirf die Generatoren
        // wieder an" blieb in allen fuenf Haendlerlisten, waehrend die Pruefung gruen war.
        // Geurteilt wird mit einem eigenen Regelsatz, nicht mit den Gegenstandsregeln.
        var listedQuests = Reachability.ListedQuests(source);
        report.Count("auftragsregeln", denylist.QuestRules);
        report.Count("auftraege_in_listen", listedQuests.Count);

        int blockedQuests = 0;
        foreach (var group in listedQuests
            .GroupBy(q => q.Quest, StringComparer.Ordinal)
            .OrderBy(g => g.Key, StringComparer.Ordinal))
        {
            if (denylist.MatchQuest(group.Key) is not string questRule)
            {
                continue;
            }

            blockedQuests++;
            string lists = string.Join(", ", group.Select(q => q.List).Distinct(StringComparer.Ordinal));
            report.Error("gesperrter-auftrag", group.Key,
                $"steht in {group.Count()} Auftragsliste(n) ({lists}; zuerst quests.xml:"
                + $"{group.First().Line}); verboten nach Auftragsregel [{questRule}]. Ein "
                + "Haendler kann diesen Auftrag anbieten.");
        }

        report.Count("gesperrte_auftraege_in_listen", blockedQuests);

        if (denylist.QuestRules > 0)
        {
            report.Limitation(
                "Auftragsregeln sehen nur die Auftragslisten in quests.xml (quest_list/quest). "
                + "Ein Auftrag, den ein Dialog unmittelbar vergibt (dialogs.xml, quest_entry), "
                + "der Startauftrag und alles, was ein Auftrag im Gelaende zeigt (Bloecke, "
                + "Marken, Klaenge), stehen nicht darin. Und dass eine Regel hier nichts "
                + "trifft, ist bei einem Stand mit unseren Modlets das Ziel, kein Tippfehler - "
                + "den Tippfehler meldet 'purge-patch' gegen Vanilla.");
        }

        // Ziele der Herausforderungen (D104 Frage 2, D137; Vertrag 04, Nachtrag Ziele). Steht
        // NACH den Listen der Regeln ohne Treffer oben: die Zielpruefung fragt die Sperrliste
        // nach Kennungen, die auf keinem Weg mehr liegen, und schreibt ihr damit Treffer zu.
        ChallengeTargets.Check(report, source, definitions, judgement, deferrals);

        // Wesen (Vertrag 04, Nachtrag Pruefungen der Phase 2, Teil 2): Klassen in den
        // Landschaftsgruppen gegen die Wesenregeln, und die Verweise zwischen Gruppen,
        // Klassen, Spawning und Spielstufen.
        CreatureCheck.Check(report, source, denylist);

        foreach ((string name, string rule, string detail) in judgement.ModsUnjudged)
        {
            report.Hint(rule, name, detail);
        }

        // Aufgeschobenes ist kein Bestanden: es steht als Hinweis da, mit dem
        // Arbeitspaket, das es schliesst, und zaehlt oben unter 'aufgeschoben'.
        foreach (Verdict v in judgement.Verdicts
            .Where(v => v.By == "aufgeschoben")
            .OrderBy(v => v.Name, StringComparer.Ordinal))
        {
            report.Hint("aufgeschobener-anachronismus", v.Name, v.Reason ?? "aufgeschoben");
        }

        // Unaufloesbares ist kein Gruen. Es ist eine Kennung, ueber die nichts bekannt ist.
        foreach (Verdict v in judgement.Verdicts
            .Where(v => v.Definition.Kind == DefKind.Unresolved && !v.Blocked)
            .OrderBy(v => v.Name, StringComparer.Ordinal))
        {
            report.Hint("unaufloesbare-kennung", v.Name,
                "erreichbar, aber in items.xml, blocks.xml und item_modifiers.xml nicht "
                + "definiert - ueber diese Kennung kann nicht nach Eigenschaft geurteilt werden.");
        }

        // 'ungeprueft' ist die eine Zahl in diesem Bericht, die nicht stehen bleiben darf
        // (Vertrag 04 §3b: jede erreichbare Kennung bekommt ein Urteil). Eine Zahl ohne
        // Namen laesst sich aber nicht abarbeiten: als der sechste Weg - die Block-Abwuerfe -
        // am 7. November 2026 dazukam, sprang sie von 0 auf 11, und der Bericht sagte nicht,
        // auf welche elf. Jetzt sagt er es.
        foreach (Verdict v in judgement.Open())
        {
            report.Hint("ungeprueft", v.Name,
                "erreichbar, aber von keiner Eigenschaft, keiner Regel und keiner Ableitung "
                + "beurteilt. Es fehlt eine Eigenschaftsregel, eine Zeile in denylist.txt "
                + "(Verbot oder Freigabe) oder ein Aufschub mit Arbeitspaket.");
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
}
