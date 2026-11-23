using System.Text;
using System.Xml.Linq;
using System.Xml.XPath;

namespace Mod700.Check;

/// <summary>
/// Erzeugt die XPath-Patches des Purge-Modlets (Plan-0001 WP3.2) aus demselben Urteil, das
/// <see cref="AnachronismCheck"/> faellt.
///
/// <para><b>Warum erzeugt und nicht von Hand geschrieben.</b> 592 gesperrte Kennungen auf
/// sieben Dateien von Hand zu verteilen heisst, dieselbe Liste zweimal zu fuehren: einmal in
/// <c>denylist.txt</c> und einmal im Modlet. Zwei Listen laufen auseinander, und die
/// Pruefung wuerde den Unterschied nicht sehen - sie liest die gemergte Config, nicht unsere
/// Patch-Dateien. In dieser Arbeit sind schon dreimal Zahlen auseinandergelaufen, weil
/// dieselbe Frage an zwei Stellen beantwortet wurde.</para>
///
/// <para><b>Der XPath kommt aus den Daten, nicht aus dem Gedaechtnis.</b> Fuer jedes
/// Element, das entfernt werden soll, baut dieses Werkzeug den Pfad aus der tatsaechlichen
/// Elternkette im Vanilla-XML (<c>/recipes/recipe[@name='X']</c>). Ein Schema, das ich
/// falsch erinnere, kann so nicht in die Patches geraten - und eine Verschachtelung, die ich
/// nicht kenne, wird trotzdem getroffen.</para>
///
/// <para><b>Was das NICHT beweist.</b> Die Patches stammen aus demselben Urteil wie die
/// Pruefung; dass beide zusammenpassen, heisst nur, dass sie zueinander passen. Der Nachweis
/// bleibt der Weg ueber das Spiel: Patch -> Spielstart -> ConfigsDump -> <c>anachronisms</c>.
/// Ist ein XPath formal falsch oder trifft er nichts, steht die Kennung im Dump noch, und die
/// Pruefung wird rot. Bis dahin prueft dieses Werkzeug das Naechstbeste und meldet es als
/// <c>patches_ohne_treffer</c>: jeder erzeugte XPath MUSS im Quell-XML mindestens ein Element
/// treffen. Eine Patch-Zeile ohne Treffer ist derselbe Fehler wie eine Verbotsregel ohne
/// Treffer - sie fuehlt sich wie Arbeit an und tut nichts.</para>
/// </summary>
internal static class PurgePatch
{
    /// <summary>
    /// Der Planschritt, der im Kopf jeder erzeugten Datei steht.
    /// </summary>
    private const string Stufe = "WP3.2 bis WP3.4";

    /// <summary>
    /// Woraus erzeugt wurde, fuer den Kopf jeder Datei. Steht dort, weil eine erzeugte
    /// Datei ohne ihre Quelle nicht nachpruefbar ist: dieselbe Denylist ergibt gegen eine
    /// andere Spielfassung andere Zeilen.
    /// </summary>
    private static string Rendered = "unbekannt";

    public static int Run(string path, string[] args)
    {
        string? outDir = null;
        string denylistPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "denylist.txt");
        string deferralPath = Path.Combine(
            AppContext.BaseDirectory, "..", "..", "..", "..", "aufschub.txt");
        bool asJson = false;
        bool dryRun = false;
        bool skipRemovals = false;
        bool compareOnly = false;
        bool show = false;

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--out" when i + 1 < args.Length:
                    outDir = args[++i];
                    break;
                case "--denylist" when i + 1 < args.Length:
                    denylistPath = args[++i];
                    break;
                case "--aufschub" when i + 1 < args.Length:
                    deferralPath = args[++i];
                    break;
                case "--json":
                    asJson = true;
                    break;

                // Trockenlauf: rechnet alles, schreibt nichts. Fuer die Gegenproben und um
                // zu sehen, was eine Aenderung an der Denylist am Modlet bewegen WUERDE.
                case "--trocken":
                    dryRun = true;
                    break;

                // GEGENPROBE: erzeugt die Entfernungen nicht. Die Nachprobe unten muss
                // dann rot werden und sagen, dass die Wege noch da sind. Ohne diesen
                // Schalter wuerde die Nachprobe immer gruen melden, und niemand wuesste,
                // ob sie ueberhaupt etwas prueft.
                case "--ohne-entfernen":
                    skipRemovals = true;
                    break;

                // Vergleichen statt schreiben: meldet rot, wenn die Dateien im Modlet
                // nicht mehr dem entsprechen, was aus der heutigen Denylist entstehen
                // wuerde. Das ist die Luecke, die erzeugte und mitgelieferte Dateien
                // immer haben - ohne diesen Lauf merkt niemand, dass eine Zeile in
                // denylist.txt nie im Modlet angekommen ist.
                case "--vergleiche":
                    compareOnly = true;
                    break;

                // Zeigt die erzeugten Zeilen auf der Ausgabe. Dafuer, dass eine Gegenprobe
                // die FORM pruefen kann ('set' gegen 'append') und nicht nur eine Zahl.
                case "--zeigen":
                    show = true;
                    break;
                default:
                    throw new UsageException($"Unbekannte Option fuer purge-patch: {args[i]}");
            }
        }

        if (outDir is null && !dryRun)
        {
            throw new UsageException(
                "purge-patch braucht --out <ordner> (oder --trocken, dann wird nichts geschrieben).");
        }

        Denylist denylist = Denylist.Load(Path.GetFullPath(denylistPath));
        Deferrals deferrals = Deferrals.Load(Path.GetFullPath(deferralPath));
        ConfigSource source = ConfigSource.Open(path);
        Definitions definitions = Definitions.Load(source, resolveExtends: true);
        var report = new Report("purge-patch", source.Info);

        Judgement judgement = Judgement.Of(
            source, definitions, denylist, deferrals, new HashSet<string>(StringComparer.Ordinal));

        List<Verdict> blocked = judgement.Blocked();
        var blockedNames = new HashSet<string>(blocked.Select(v => v.Name), StringComparer.Ordinal);

        report.Count("gesperrte_kennungen", blocked.Count);
        report.Count("aufgeschoben_nicht_gepatcht", judgement.Deferred);

        // Eine Kennung mit einem Apostroph im Namen wuerde das XPath-Literal sprengen. In
        // Vanilla gibt es das nicht - aber lautlos falschen XPath zu schreiben waere der
        // schlechteste Ausgang, darum bricht das Werkzeug lieber ab.
        foreach (string name in blockedNames.Where(n => n.Contains('\'')))
        {
            throw new UsageException(
                $"Die Kennung '{name}' enthaelt ein Apostroph. Daraus laesst sich kein "
                + "XPath-Literal bauen; dieser Fall braucht Handarbeit.");
        }

        Rendered = $"{source.Info.Kind}, Stand {source.Info.Timestamp}";

        var files = new List<PatchFile>
        {
            CreativeMode(source, blocked, DefKind.Item, "items.xml", "item",
                "F-01 sperrt, es loescht nicht (Vertrag 03 §4): der Gegenstand bleibt "
                + "aufloesbar, damit Prefabs und Quests nicht brechen."),

            CreativeMode(source, blocked, DefKind.Block, "blocks.xml", "block",
                "Dieselbe Regel wie bei den Gegenstaenden. D9 bleibt gewahrt: die Klassen "
                + "bleiben vollstaendig stehen, damit F-15 sie in Phase 2 umdeutet."),

            Removals(source, blockedNames, "blocks.xml", "drop", "name",
                "DER SECHSTE WEG, nachgetragen am 7. November 2026. Ein <drop> gibt dem "
                + "Spieler einen Gegenstand in die Hand, wenn er einen Block abbaut oder "
                + "zerschlaegt - und das zaehlte in Reachability bis dahin nicht als Weg. "
                + "Der Purge aus WP3 meldete darum 'gesperrt_und_noch_erreichbar 0', "
                + "waehrend 26 gesperrte Kennungen weiter aus Bloecken fielen: Kunststoff "
                + "aus dem Sofa, Mechanikteile aus der Waschmaschine, Elektrikteile aus der "
                + "Lampe. Die Zeilen tragen bewusst kein Block-Praedikat: der Gegenstand "
                + "soll aus JEDEM Block verschwinden, nicht aus einem. Der Block selbst "
                + "bleibt stehen (D9) und faellt weiter - er gibt nur das Gesperrte nicht "
                + "mehr her. Was an seine Stelle tritt, entscheidet F-05 in WP4.",
                skipRemovals),

            Removals(source, blockedNames, "recipes.xml", "recipe", "name",
                "Das Rezept ist ein WEG zu einem Gegenstand, und Wege darf 'remove' treffen "
                + "(Vertrag 03 §4). Mehrere Treffer sind hier Absicht: ein Gegenstand kann "
                + "mehrere Rezepte haben, und alle sollen fallen.",
                skipRemovals),

            Removals(source, blockedNames, "loot.xml", "item", "name",
                "F-01 sagt 'Loot-Tabellen leeren bzw. umbiegen'. Geleert wird hier: der "
                + "Eintrag faellt, die Gruppe bleibt stehen. Eine Gruppe zu entfernen waere "
                + "schlimmer als sie zu leeren - Behaelter und Quest-Belohnungen zeigen auf "
                + "ihren Namen, und ein fehlender Name bricht hart. Wie viele Gruppen dadurch "
                + "leer dastehen, sagt der Bericht; umgebogen werden sie erst mit F-05.",
                skipRemovals),

            Removals(source, blockedNames, "traders.xml", "item", "name",
                "Haendlerware ist ein Weg wie jeder andere. Eintraege mit 'group' statt "
                + "'name' bleiben unberuehrt - was in der Gruppe liegt, entscheidet loot.xml.",
                skipRemovals),

            ListAttribute(source, blockedNames, "quests.xml", "reward", "id",
                "Eine Quest-Belohnung nennt in 'id' eine Kennung ODER eine Liste davon. "
                + "Steht nur Gesperrtes darin, faellt die Belohnung; stehen auch erlaubte "
                + "Namen darin, wird die Liste gekuerzt statt die Belohnung entfernt. Wer "
                + "hier blind 'remove' nimmt, nimmt dem Spieler drei erlaubte Belohnungen "
                + "mit, weil eine gesperrte in derselben Liste stand.",
                skipRemovals),

            ListAttribute(source, blockedNames, "entityclasses.xml", "property", "value",
                "Die Startausruestung steht als kommagetrennte Liste im 'value' einer "
                + "Eigenschaft unter 'ItemsOnEnterGame' - mit Stueckzahlen wie "
                + "'drinkJarBoiledWater=2'. Gekuerzt wird, nicht entfernt: ohne die "
                + "Eigenschaft startet der Spieler mit leeren Haenden. Was dazukommt, steht "
                + "in 700_30_Ausruestung - dieses Modlet nimmt nur weg.",
                skipRemovals, parentClass: "ItemsOnEnterGame")
        };

        // Auftraege (D103, Vertrag 04, Nachtrag Auftragsregeln). Ein eigener Regelsatz und
        // ein eigener Teil von quests.xml: die Kennungen sind keine Gegenstaende, also
        // stehen sie nicht in 'blockedNames' und gehen durch keine der Proben oben.
        //
        // Der Teil entsteht NUR, wenn die Sperrliste Auftragsregeln fuehrt. Ohne Regeln
        // sieht quests.xml aus wie vor diesem Nachtrag - Kopf, Zeilenzahl, alles.
        var listedQuests = Reachability.ListedQuests(source);
        var blockedQuests = new HashSet<string>(
            listedQuests
                .Select(q => q.Quest)
                .Distinct(StringComparer.Ordinal)
                .Where(q => denylist.MatchQuest(q) is not null),
            StringComparer.Ordinal);

        report.Count("auftragsregeln", denylist.QuestRules);
        report.Count("auftraege_in_listen", listedQuests.Count);
        report.Count("gesperrte_auftraege", blockedQuests.Count);

        if (denylist.QuestRules > 0)
        {
            foreach (string quest in blockedQuests.Where(q => q.Contains('\'')))
            {
                throw new UsageException(
                    $"Der Auftrag '{quest}' enthaelt ein Apostroph. Daraus laesst sich kein "
                    + "XPath-Literal bauen; dieser Fall braucht Handarbeit.");
            }

            if (listedQuests.Count > 0)
            {
                files.Add(Removals(source, blockedQuests, "quests.xml", "quest", "id",
                    "Auftraege (D103): ein gesperrter Auftrag faellt aus JEDER Auftragsliste, "
                    + "darum traegt die Zeile kein Praedikat an der Liste. Getroffen wird nur "
                    + "der Eintrag unter 'quest_list' - die Definition des Auftrags eine Ebene "
                    + "hoeher bleibt stehen wie jede Definition (Vertrag 03 §4), und die "
                    + "Bloecke, Marken und Klaenge, die er im Gelaende benutzt, ebenso.",
                    skipRemovals, parentElement: "quest_list",
                    reason: "gesperrter Auftrag in einer Auftragsliste"));

                // Gegen Vanilla ist eine Auftragsregel ohne Treffer ein Tippfehler, und zwar
                // der stille: der Auftrag bleibt beim Haendler, und nichts wird rot, weil
                // 'anachronisms' eine Regel ohne Treffer bei einem gepatchten Stand fuer das
                // Ziel halten muss. Darum ist es HIER ein Fehler und kein Hinweis.
                foreach (string rule in denylist.UnusedQuestRules)
                {
                    report.Error("auftragsregel-trifft-nichts", rule,
                        "auf diese Auftragsregel passt kein einziger Auftrag in einer "
                        + "Auftragsliste dieser Quelle. Entweder ist sie falsch geschrieben, "
                        + "oder die Spielfassung fuehrt den Auftrag nicht mehr.");
                }
            }
            else
            {
                report.Limitation(
                    "Diese Quelle hat keine Auftragslisten (quest_list in quests.xml). Ob die "
                    + $"{denylist.QuestRules} Auftragsregeln der Sperrliste etwas treffen, "
                    + "laesst sich hier nicht sagen; geprueft wird das gegen Vanilla.");
            }
        }

        // Wesen (D149, Vertrag 04, Nachtrag WP5.4). Der dritte eigene Regelsatz: eine
        // Klasse ist kein Gegenstand, also steht sie nicht in 'blockedNames'. Wie bei den
        // Auftraegen entsteht der Teil NUR, wenn die Sperrliste Wesenregeln fuehrt - ohne
        // Regeln gibt es keine entitygroups.xml im Erzeugnis.
        int creatureTrouble = 0;
        report.Count("wesenregeln", denylist.CreatureRules);

        if (denylist.CreatureRules > 0)
        {
            PatchFile? creatureFile = Creatures(
                report, source, denylist, skipRemovals, ref creatureTrouble);
            if (creatureFile is not null)
            {
                files.Add(creatureFile);
            }
        }

        int lines = 0;
        int withoutHit = 0;

        // Geht eine Ausgabedatei aus mehreren Teilen hervor, bekommt jeder Teil seine eigene
        // Zahl. Sonst traegt der zweite Teil denselben Namen wie der erste, der Bericht zeigt
        // nur einen Wert, und 'patchzeilen' stimmt waehrend die Einzelzahlen sich nicht mehr
        // dazu addieren - eine Zahl, die man nachrechnen kann und die dann nicht aufgeht,
        // ist schlimmer als keine.
        var sharedNames = files
            .GroupBy(f => f.FileName, StringComparer.Ordinal)
            .Where(g => g.Count() > 1)
            .Select(g => g.Key)
            .ToHashSet(StringComparer.Ordinal);

        foreach (PatchFile file in files)
        {
            string label = sharedNames.Contains(file.FileName)
                ? $"{file.FileName} [{file.ElementName ?? "creativemode"}]"
                : file.FileName;

            report.Count($"patchzeilen_{label}", file.Operations.Count);
            lines += file.Operations.Count;

            foreach (PatchOperation op in file.Operations.Where(o => o.Matches == 0))
            {
                withoutHit++;
                report.Error("patch-ohne-treffer", op.Target,
                    $"der erzeugte XPath '{op.VerifyXPath}' trifft im Quell-XML kein Element. "
                    + "Eine Patch-Zeile ohne Treffer tut nichts und fuehlt sich wie Arbeit an.");
            }
        }

        report.Count("patchzeilen", lines);
        report.Count("patches_ohne_treffer", withoutHit);

        // Nachprobe: nach den Entfernungen darf auf diesem Weg keine gesperrte Kennung
        // mehr erreichbar sein.
        int left = 0;
        foreach (PatchFile file in files.Where(f => f.ElementName is not null))
        {
            int remaining = WaysLeft(source, file, blockedNames);

            // Der Auftragsteil teilt sich die Datei mit den Belohnungen. Er bekommt seine
            // eigene Zahl; die der Belohnungen behaelt ihren Namen.
            string leftLabel = file.ParentElement is null
                ? file.FileName
                : $"{file.FileName} [{file.ElementName}]";
            report.Count($"wege_uebrig_{leftLabel}", remaining);
            left += remaining;

            if (remaining > 0)
            {
                report.Error("weg-bleibt-offen", leftLabel,
                    $"nach den erzeugten Entfernungen sind in {file.FileName} noch {remaining} "
                    + $"<{file.ElementName} {file.Attribute}='...'> auf gesperrte Kennungen "
                    + "uebrig. Die Patches dieser Datei decken nicht, was die Pruefung findet.");
            }
        }

        report.Count("wege_uebrig", left);

        // Vertrag 03 §4 und D9: 'remove' darf WEGE treffen, nie eine Definition. Wer einen
        // Gegenstand entfernt, auf den ein Prefab zeigt, bricht das Laden der Welt - und wer
        // eine Stromklasse entfernt, nimmt F-15 in Phase 2 ein ganzes Feature weg.
        //
        // Heute kann diese Zahl nicht steigen, weil nur recipes.xml Entfernungen bekommt.
        // Sie steht hier fuer WP3.3 und WP3.4, die loot.xml, traders.xml und quests.xml
        // dazunehmen: ein Tippfehler in einem Elementnamen soll dann hier auffallen und
        // nicht erst beim Weltladen. Dass sie heute 0 ist, ist darum keine Leistung des
        // Pruefers, sondern eine Eigenschaft des erzeugten Satzes.
        int onDefinition = files
            .SelectMany(f => f.Operations.Select(o => (f.FileName, o.Xml, o.VerifyXPath)))
            .Count(o => o.Xml.StartsWith("<remove", StringComparison.Ordinal)
                        && (o.VerifyXPath.StartsWith("/items/item[", StringComparison.Ordinal)
                            || o.VerifyXPath.StartsWith("/blocks/block[", StringComparison.Ordinal)
                            || o.VerifyXPath.StartsWith("/item_modifiers/item_modifier[", StringComparison.Ordinal)
                            || o.VerifyXPath.StartsWith("/quests/quest[", StringComparison.Ordinal)));

        report.Count("remove_auf_definition", onDefinition);

        // Eine geleerte Loot-Gruppe ist der bekannte Nebeneffekt von "leeren statt
        // entfernen". Sie bleibt stehen, weil Behaelter und Quest-Belohnungen auf ihren
        // Namen zeigen - aber sie gibt nichts mehr her. Das ist keine Fehlermeldung, es ist
        // eine Zahl, die beim Spielstart in WP3.6 nachzusehen ist: ob das Spiel eine leere
        // Gruppe stillschweigend hinnimmt oder eine Protokollzeile schreibt, weiss hier
        // niemand, und behaupten soll es auch niemand.
        // Die Gesamtprobe. Jede Datei fuer sich zu pruefen sagt nicht, ob der Satz ZUSAMMEN
        // alle sechs Wegarten schliesst: eine Kennung, die nur noch in der Startausruestung
        // steht, waere in jeder Einzelprobe gruen. Also werden alle erzeugten Zeilen auf
        // Kopien angewandt und die Erreichbarkeit auf dem Ergebnis neu gerechnet - mit
        // demselben Reachability, das die Pruefung benutzt, nicht mit einer zweiten Fassung.
        //
        // Je AUSGABEDATEI eine Kopie, nicht je Teil. blocks.xml hat zwei Teile; wer die
        // Kopie pro Teil anlegt und unter dem Dateinamen ablegt, wirft die erste weg und
        // prueft am Ende nur den zweiten Teil - stillschweigend und gruen.
        var patchedDocs = new Dictionary<string, XDocument>(StringComparer.OrdinalIgnoreCase);
        foreach (PatchFile file in files.Where(f => f.Operations.Count > 0))
        {
            if (!patchedDocs.TryGetValue(file.FileName, out XDocument? copy))
            {
                XDocument? original = source.Load(file.FileName);
                if (original is null)
                {
                    continue;
                }

                copy = new XDocument(original);
                patchedDocs[file.FileName] = copy;
            }

            foreach (PatchOperation op in file.Operations)
            {
                foreach (XElement hit in copy.XPathSelectElements(op.VerifyXPath).ToList())
                {
                    if (op.SetAttribute is null && op.Xml.StartsWith("<remove", StringComparison.Ordinal))
                    {
                        hit.Remove();
                    }
                    else if (op.SetAttribute is not null)
                    {
                        hit.SetAttributeValue(op.SetAttribute, op.NewValue);
                    }
                }
            }

        }

        ConfigSource patchedSource = ConfigSource.Patched(source, patchedDocs);
        var stillReachable = Reachability.Names(patchedSource)
            .Where(blockedNames.Contains)
            .ToList();

        report.Count("gesperrt_und_noch_erreichbar", stillReachable.Count);

        foreach (string name in stillReachable.Take(20))
        {
            report.Error("gesperrt-trotz-patch", name,
                "diese Kennung ist auch nach allen erzeugten Patchzeilen noch erreichbar. "
                + "Der Patch-Satz deckt nicht, was die Pruefung findet.");
        }

        // Dieselbe Gesamtprobe fuer die Auftraege, mit derselben Lesart wie 'anachronisms'
        // (Reachability.ListedQuests) und auf demselben gepatchten Stand.
        if (denylist.QuestRules > 0)
        {
            var stillListed = Reachability.ListedQuests(patchedSource)
                .Where(q => blockedQuests.Contains(q.Quest))
                .Select(q => q.Quest)
                .Distinct(StringComparer.Ordinal)
                .OrderBy(q => q, StringComparer.Ordinal)
                .ToList();

            report.Count("gesperrte_auftraege_noch_in_listen", stillListed.Count);

            foreach (string quest in stillListed)
            {
                report.Error("auftrag-trotz-patch", quest,
                    "dieser Auftrag steht auch nach allen erzeugten Patchzeilen noch in einer "
                    + "Auftragsliste. Der Patch-Satz deckt nicht, was die Pruefung findet.");
            }
        }

        // Dieselbe Frage wie bei den Loot-Gruppen, nur fuer Bloecke: wie viele geben nach dem
        // Patch nichts mehr her? Ein Block ohne Abwurf ist kein Fehler - Stein gibt Stein -,
        // aber eine Waschmaschine, die beim Zerschlagen nichts hinterlaesst, ist eine Luecke
        // im Spiel und gehoert gezaehlt, nicht entdeckt.
        PatchFile dropFile = files.First(
            f => f.FileName == "blocks.xml" && f.ElementName == "drop");
        (int mute, int withDrops) = MutedBlocks(source, dropFile);
        report.Count("bloecke_mit_abwurf_gesamt", withDrops);
        report.Count("bloecke_ohne_abwurf_danach", mute);

        if (mute > 0)
        {
            report.Hint("block-ohne-abwurf", $"{mute} von {withDrops} Bloecken",
                "diese Bloecke hatten einen Abwurf und haben nach dem Patch keinen mehr. "
                + "Sie bleiben stehen und bleiben abbaubar, geben aber nichts her, bis F-05 "
                + "in WP4 einen Ersatz einsetzt. Das ist eine bekannte Folge, keine "
                + "Entdeckung - und wie bei den leeren Loot-Gruppen ist hier nicht "
                + "geprueft, was das Spiel daraus macht.");
        }

        PatchFile lootFile = files.First(f => f.FileName == "loot.xml");
        (int emptied, int total) = EmptiedLootGroups(source, lootFile);
        report.Count("loot_gruppen_gesamt", total);
        report.Count("loot_gruppen_leer_danach", emptied);

        if (emptied > 0)
        {
            report.Hint("loot-gruppe-leer", $"{emptied} von {total} Gruppen",
                "diese Loot-Gruppen enthalten nach dem Patch keinen Eintrag mehr. Sie "
                + "bleiben absichtlich stehen, weil Behaelter und Quest-Belohnungen auf "
                + "ihre Namen zeigen und ein fehlender Name hart bricht. Umgebogen werden "
                + "sie mit F-05 in WP4. ACHTUNG, ungeprueft: ob das Spiel eine leere Gruppe "
                + "stillschweigend hinnimmt oder eine Protokollzeile schreibt oder beim "
                + "Wuerfeln abbricht, weiss hier niemand. Das ist der erste Punkt, den der "
                + "Protokolllauf in WP3.6 beantworten muss.");
        }

        // Und dieselbe Frage ein drittes Mal, diesmal fuer Rezepte: welche ueberleben den
        // Purge und sind trotzdem nicht herstellbar, weil eine Zutat gesperrt ist? Das ist
        // keine Folge, die man einplant, sondern eine, die man uebersieht - siehe DeadRecipes.
        PatchFile recipeFile = files.First(f => f.FileName == "recipes.xml");
        (var deadRecipes, int recipesLeft) = DeadRecipes(source, recipeFile, blockedNames);
        var deadNames = deadRecipes.Select(d => d.Recipe).ToHashSet(StringComparer.Ordinal);
        report.Count("rezepte_nach_purge", recipesLeft);
        report.Count("rezepte_mit_gesperrter_zutat", deadNames.Count);

        if (deadNames.Count > 0)
        {
            // Genannt werden die ZUTATEN, nicht die 102 Rezepte: ersetzt wird je Zutat, nicht
            // je Rezept. Wer Panzerband durch Sehne tauscht, erledigt 44 Zeilen auf einmal.
            string worst = string.Join(", ", deadRecipes
                .GroupBy(d => d.Ingredient, StringComparer.Ordinal)
                .OrderByDescending(g => g.Select(d => d.Recipe).Distinct(StringComparer.Ordinal).Count())
                .ThenBy(g => g.Key, StringComparer.Ordinal)
                .Select(g => $"{g.Key} ({g.Select(d => d.Recipe).Distinct(StringComparer.Ordinal).Count()})"));

            report.Hint("rezept-mit-gesperrter-zutat",
                $"{deadNames.Count} von {recipesLeft} Rezepten",
                "diese Rezepte ueberleben den Purge und sind trotzdem nicht herstellbar: "
                + "mindestens eine Zutat ist gesperrt. Der Gegenstand bleibt erlaubt, das "
                + "Rezept bleibt stehen, und im Handwerksfenster ist es grau. Ersetzt wird je "
                + "ZUTAT, nicht je Rezept - F-02 bis F-05 in WP5 bis WP7 schreiben die "
                + "betroffenen Rezepte um. ACHTUNG, DIESE ZAHL IST EINE ARBEITSLISTE UND KEIN "
                + "FORTSCHRITTSBALKEN: erzeugt wird gegen VANILLA, unsere eigenen Modlets sind "
                + "hier nicht geladen. Ein Rezept, das ein Paket von uns schon ersetzt hat, "
                + "steht trotzdem weiter in dieser Zahl. Dass es wirklich ersetzt ist, sagt "
                + "erst ein Lauf gegen einen frischen ConfigsDump (WP3.6). Gesperrte Zutaten "
                + "nach Zahl der Rezepte: " + worst);
        }

        if (onDefinition > 0)
        {
            report.Error("remove-auf-definition", "Vertrag 03 §4",
                $"{onDefinition} Entfernungen zeigen auf eine Definition statt auf einen Weg. "
                + "Das ist verboten: ein entfernter Gegenstand, auf den ein Prefab zeigt, "
                + "bricht das Laden der Welt, und eine entfernte Stromklasse nimmt F-15 in "
                + "Phase 2 ein ganzes Feature weg (D9).");
        }

        if (show)
        {
            foreach (PatchFile file in files)
            {
                foreach (PatchOperation op in file.Operations)
                {
                    report.Hint("patchzeile", $"{file.FileName}: {op.Xml}", op.Reason);
                }
            }
        }

        // Was nicht gepatcht werden kann, wird gesagt und nicht verschwiegen.
        int unresolved = blocked.Count(v => v.Definition.Kind == DefKind.Unresolved);
        int modifiers = blocked.Count(v => v.Definition.Kind == DefKind.Modifier);
        report.Count("ohne_definition_nicht_sperrbar", unresolved);
        report.Count("mods_ohne_creativemode", modifiers);

        Limitations(report, source, unresolved, modifiers);

        if (skipRemovals)
        {
            report.Limitation(
                "ACHTUNG: --ohne-entfernen. Die Entfernungen sind nicht erzeugt. Dieser Lauf "
                + "ist eine Gegenprobe zur Nachprobe, kein Nachweis - und es wird nichts "
                + "geschrieben.");
        }

        // Eine Ausgabedatei kann aus mehreren Teilen bestehen (siehe Render): gruppiert wird
        // ueber den Dateinamen, denn der ist es, worueber das Spiel zuordnet.
        var groups = files
            .GroupBy(f => f.FileName, StringComparer.Ordinal)
            .Select(g => (FileName: g.Key, Parts: (IReadOnlyList<PatchFile>)g.ToList()))
            .ToList();

        if (compareOnly && outDir is not null)
        {
            int different = 0;
            foreach ((string name, IReadOnlyList<PatchFile> parts) in groups)
            {
                string target = Path.Combine(outDir, name);
                string wanted = Render(parts);
                string? have = File.Exists(target) ? File.ReadAllText(target) : null;

                if (have is null)
                {
                    different++;
                    report.Error("patchdatei-fehlt", name,
                        $"{Path.GetFullPath(target)} gibt es nicht. 'purge-patch --out "
                        + "<ordner>' erzeugt sie.");
                }
                else if (have.Replace("\r\n", "\n") != wanted.Replace("\r\n", "\n"))
                {
                    different++;
                    report.Error("patchdatei-veraltet", name,
                        "die Datei im Modlet entspricht nicht dem, was aus der heutigen "
                        + "denylist.txt und aufschub.txt entstehen wuerde. Entweder ist eine "
                        + "Regel nie im Modlet angekommen, oder jemand hat die erzeugte "
                        + "Datei von Hand geaendert. 'purge-patch --out <ordner>' raeumt das auf.");
                }
            }

            // Die Gegenrichtung fuer den Teil, den es nur mit Regeln gibt: liegt eine
            // entitygroups.xml im Modlet und die Sperrliste fuehrt keine Wesenregel mehr,
            // dann nimmt das Modlet Klassen aus dem Gelaende, von denen keine Regel weiss.
            if (denylist.CreatureRules == 0 && File.Exists(Path.Combine(outDir, CreatureFileName)))
            {
                different++;
                report.Error("patchdatei-ohne-regel", CreatureFileName,
                    $"{Path.GetFullPath(Path.Combine(outDir, CreatureFileName))} liegt im Modlet, "
                    + "und die Sperrliste fuehrt keine Wesenregel. Die Datei stammt aus einer "
                    + "aelteren Sperrliste; entweder kommen die Regeln zurueck, oder die Datei "
                    + "wird geloescht.");
            }

            report.Count("patchdateien_abweichend", different);
        }
        else if (withoutHit == 0 && left == 0 && creatureTrouble == 0
                 && !skipRemovals && !dryRun && outDir is not null)
        {
            Directory.CreateDirectory(outDir);
            foreach ((string name, IReadOnlyList<PatchFile> parts) in groups)
            {
                File.WriteAllText(
                    Path.Combine(outDir, name), Render(parts), new UTF8Encoding(false));
            }

            report.Count("geschrieben_nach", Path.GetFullPath(outDir));
        }
        else if (dryRun)
        {
            report.Count("geschrieben_nach", "nichts (--trocken)");
        }

        return report.Write(asJson);
    }

    private static void Limitations(Report report, ConfigSource source, int unresolved, int modifiers)
    {
        report.Limitation(
            "Diese Patches stammen aus demselben Urteil wie 'anachronisms'. Dass beide "
            + "zusammenpassen, ist kein Nachweis - der Nachweis ist der Weg ueber das Spiel: "
            + "Patch, Spielstart, ConfigsDump, 'anachronisms'. Erst dort entscheidet der "
            + "XML-Patcher des Spiels, ob ein XPath wirklich getroffen hat.");

        report.Limitation(
            "CreativeMode='None' ist KEINE Sperre fuer den Spieler. Es nimmt den Gegenstand "
            + "aus dem Kreativmenue und aus der Entwicklerliste - mehr nicht. Dass ein "
            + "Gegenstand unerreichbar wird, leisten allein die entfernten Wege "
            + "(Block-Abwurf, Rezept, Loot, Haendler, Quest-Belohnung, Startausruestung). "
            + "Der Plan nennt "
            + "CreativeMode in WP3.2 als 'sperren statt loeschen'; das ist richtig als "
            + "Absichtserklaerung in den Daten, nicht als Wirkung.");

        report.Limitation(
            $"{Stufe} schreibt sieben Dateien: items.xml und blocks.xml (CreativeMode), "
            + "blocks.xml zusaetzlich die Abwuerfe, recipes.xml, loot.xml, traders.xml "
            + "(Wege entfernt), quests.xml und entityclasses.xml (Listen gekuerzt); "
            + "quests.xml nimmt dazu gesperrte Auftraege aus den Auftragslisten, wenn die "
            + "Sperrliste Auftragsregeln fuehrt (D103). Was dem "
            + "Spieler dafuer gegeben wird, "
            + "steht nicht hier - dieses Modlet nimmt nur weg (D53: 700_10_Purge laeuft vor "
            + "allen anderen).");

        if (unresolved > 0)
        {
            report.Limitation(
                $"{unresolved} gesperrte Kennungen haben in dieser Quelle keine Definition in "
                + "items.xml, blocks.xml oder item_modifiers.xml. Sie bekommen kein "
                + "CreativeMode - es gibt kein Element, an das es gehoerte. Ihre Wege fallen "
                + "trotzdem.");
        }

        if (modifiers > 0)
        {
            report.Limitation(
                $"{modifiers} gesperrte Aufsaetze stehen in item_modifiers.xml. Diese Datei "
                + "kennt kein CreativeMode; Aufsaetze verschwinden allein ueber ihre Wege.");
        }

        if (!source.IsMerged)
        {
            report.Limitation(
                "Erzeugt gegen Vanilla. Das ist hier richtig: die Patches sollen Vanilla "
                + "veraendern. Gegen einen ConfigsDump erzeugt, in dem unsere Modlets schon "
                + "geladen waren, waeren sie leer - die Wege sind dort schon weg.");
        }
    }

    /// <summary>
    /// Setzt <c>CreativeMode</c> auf <c>None</c>. Ob mit <c>set</c> oder mit <c>append</c>,
    /// entscheiden die Daten und nicht eine Annahme: traegt der Gegenstand die Eigenschaft
    /// selbst, wird ihr Wert ersetzt; traegt er sie nicht (oder erbt sie), wird sie
    /// angehaengt und ueberschreibt damit die geerbte. Ein <c>set</c> auf eine Eigenschaft,
    /// die es nicht gibt, trifft nichts und schweigt - genau die Art Fehler, die in WP3.1
    /// dreimal passiert ist.
    /// </summary>
    private static PatchFile CreativeMode(
        ConfigSource source, List<Verdict> blocked, DefKind kind, string fileName,
        string elementName, string why)
    {
        XDocument? document = source.Load(fileName);
        var operations = new List<PatchOperation>();

        if (document?.Root is null)
        {
            return new PatchFile(fileName, why, operations);
        }

        Dictionary<string, XElement> byName = document.Root
            .Elements(elementName)
            .Where(e => e.Attribute("name") is not null)
            .GroupBy(e => e.Attribute("name")!.Value, StringComparer.Ordinal)
            .ToDictionary(g => g.Key, g => g.First(), StringComparer.Ordinal);

        foreach (Verdict v in blocked
            .Where(v => v.Definition.Kind == kind)
            .OrderBy(v => v.Name, StringComparer.Ordinal))
        {
            if (!byName.TryGetValue(v.Name, out XElement? element))
            {
                continue;
            }

            string target = $"/{document.Root.Name.LocalName}/{elementName}[@name='{v.Name}']";
            bool ownProperty = element
                .Elements("property")
                .Any(p => p.Attribute("name")?.Value == "CreativeMode");

            string xml = ownProperty
                ? $"<set xpath=\"{target}/property[@name='CreativeMode']/@value\">None</set>"
                : $"<append xpath=\"{target}\"><property name=\"CreativeMode\" value=\"None\" /></append>";

            operations.Add(new PatchOperation(v.Name, xml, target, Count(document, target),
                $"verboten nach {v.By}: {v.Rule}"));
        }

        return new PatchFile(fileName, why, operations);
    }

    /// <summary>
    /// Entfernt Wege. Der XPath wird aus der tatsaechlichen Elternkette des gefundenen
    /// Elements gebaut, nicht aus einer Erinnerung an das Schema - und je Kette nur einmal,
    /// auch wenn dieselbe Kennung dort mehrfach steht.
    /// </summary>
    private static PatchFile Removals(
        ConfigSource source, HashSet<string> blocked, string fileName, string elementName,
        string attribute, string why, bool skip = false, string? parentElement = null,
        string reason = "Weg zu einer gesperrten Kennung")
    {
        XDocument? document = source.Load(fileName);
        var operations = new List<PatchOperation>();

        // Mit 'parentElement' gehoert dem Teil eine eigene Sperrmenge: die Nachprobe darf
        // die Auftraege nicht gegen die gesperrten GEGENSTAENDE zaehlen.
        HashSet<string>? own = parentElement is null ? null : blocked;

        if (document is null || skip)
        {
            return new PatchFile(fileName, why, operations, elementName, attribute,
                ParentElement: parentElement, OwnBlocked: own);
        }

        var seen = new HashSet<string>(StringComparer.Ordinal);

        foreach (XElement element in document.Descendants(elementName))
        {
            // 'quest' heisst sowohl der Eintrag einer Auftragsliste als auch die Definition
            // des Auftrags. Ohne diese Zeile entstuende ein 'remove' auf die Definition.
            if (parentElement is not null && element.Parent?.Name.LocalName != parentElement)
            {
                continue;
            }

            string? value = element.Attribute(attribute)?.Value;
            if (value is null || !blocked.Contains(value))
            {
                continue;
            }

            string xpath = $"{Chain(element)}[@{attribute}='{value}']";
            if (!seen.Add(xpath))
            {
                continue;
            }

            operations.Add(new PatchOperation(
                value, $"<remove xpath=\"{xpath}\" />", xpath, Count(document, xpath),
                reason));
        }

        operations.Sort((a, b) => string.CompareOrdinal(a.VerifyXPath, b.VerifyXPath));
        return new PatchFile(fileName, why, operations, elementName, attribute,
            ParentElement: parentElement, OwnBlocked: own);
    }

    private const string CreatureFileName = "entitygroups.xml";

    /// <summary>Vanillas Zeichen fuer "hier erscheint nichts" - ein Eintrag, keine Klasse.</summary>
    private const string NoCreature = "none";

    /// <summary>
    /// Nimmt gesperrte Wesen aus den Landschaftsgruppen (D149, Vertrag 04, Nachtrag WP5.4).
    ///
    /// <para><b>Nur Landschaftsgruppen.</b> Eine Wesenregel urteilt ueber Gruppen, die
    /// <c>spawning.xml</c> ruft, und ueber nichts sonst - dieselbe Lesart wie
    /// <see cref="CreatureCheck"/>. Darum traegt jede Zeile den Namen der Gruppe: ein
    /// <c>remove</c> ohne dieses Praedikat naehme die Klasse auch den Schlaefern und der
    /// Seuchennacht, wo die Rollentraeger stehen duerfen (P2-E12).</para>
    ///
    /// <para><b>Getroffen wird der Eintrag, nie die Klasse und nie die Gruppe</b>
    /// (Vertrag 03, Nachtrag Phase 2 C). Das Spiel bricht das Laden ab, wenn eine Gruppe
    /// eine Klasse nennt, die es nicht gibt, wenn eine Gruppe keinen Eintrag hat oder wenn
    /// spawning.xml eine Gruppe ruft, die fehlt (Finding WP5.4, statisch gelesen). Die
    /// Nachprobe hier rechnet darum auf einer Kopie nach, dass keine Landschaftsgruppe leer
    /// wird und keine mit 'none' beginnt - den ersten Eintrag liest das Spiel, um zu
    /// entscheiden, ob die Gruppe Feinde fuehrt.</para>
    ///
    /// <para>Der Teil hat keine <c>ElementName</c>-Nachprobe (<see cref="WaysLeft"/>): die
    /// zaehlte gesperrte Klassen in ALLEN Gruppen und waere bei jedem Schlaefer rot.</para>
    /// </summary>
    private static PatchFile? Creatures(
        Report report, ConfigSource source, Denylist denylist, bool skip, ref int trouble)
    {
        XDocument? groupsDoc = source.Load(CreatureFileName);
        XDocument? spawning = source.Load("spawning.xml");

        if (groupsDoc is null || spawning is null)
        {
            report.Limitation(
                "Diese Quelle hat keine entitygroups.xml oder keine spawning.xml. Ob die "
                + $"{denylist.CreatureRules} Wesenregeln der Sperrliste etwas treffen, laesst "
                + "sich hier nicht sagen; geprueft wird das gegen Vanilla.");
            return null;
        }

        var called = new HashSet<string>(StringComparer.Ordinal);
        foreach (XElement spawn in spawning.Descendants("spawn"))
        {
            if (spawn.Attribute("entitygroup")?.Value is string group
                && !string.IsNullOrWhiteSpace(group))
            {
                called.Add(group);
            }
        }

        static bool IsLandscape(XElement group, HashSet<string> called) =>
            group.Attribute("name")?.Value is string name && called.Contains(name);

        var operations = new List<PatchOperation>();
        var seen = new HashSet<string>(StringComparer.Ordinal);
        var blockedClasses = new SortedSet<string>(StringComparer.Ordinal);
        int landscapeGroups = 0;

        foreach (XElement group in groupsDoc.Descendants("entitygroup"))
        {
            if (!IsLandscape(group, called))
            {
                continue;
            }

            landscapeGroups++;
            string groupName = group.Attribute("name")!.Value;

            // Das Spiel liest drei Formen: <e n>, <entity name> und eine Textliste. Vanilla
            // benutzt nur die erste (26734 Eintraege, gemessen an V 3.40 b10), und nur die
            // rechnet dieses Werkzeug. Eine Gruppe in anderer Form waere hier unsichtbar -
            // also wird sie gesagt statt uebersehen.
            bool otherForm = group.Elements().Any(e => e.Name.LocalName != "e")
                             || group.Nodes().OfType<XText>().Any(t => t.Value.Trim().Length > 0);
            if (otherForm)
            {
                trouble++;
                report.Error("wesengruppe-andere-form", groupName,
                    "diese Landschaftsgruppe fuehrt Eintraege, die nicht <e n='...'> heissen "
                    + "(<entity name> oder eine Textliste). Das Spiel liest sie, dieses Werkzeug "
                    + "nicht - ob eine gesperrte Klasse darin steht, ist nicht geprueft.");
            }

            foreach (XElement entry in group.Elements("e"))
            {
                string? className = entry.Attribute("n")?.Value;
                if (string.IsNullOrEmpty(className) || className == NoCreature
                    || denylist.MatchCreature(className) is null)
                {
                    continue;
                }

                blockedClasses.Add(className);

                if (groupName.Contains('\'') || className.Contains('\''))
                {
                    throw new UsageException(
                        $"Die Gruppe '{groupName}' oder die Klasse '{className}' enthaelt ein "
                        + "Apostroph. Daraus laesst sich kein XPath-Literal bauen; dieser Fall "
                        + "braucht Handarbeit.");
                }

                if (skip)
                {
                    continue;
                }

                string xpath = $"{Chain(group)}[@name='{groupName}']/e[@n='{className}']";
                if (!seen.Add(xpath))
                {
                    continue;
                }

                operations.Add(new PatchOperation(
                    className, $"<remove xpath=\"{xpath}\" />", xpath, Count(groupsDoc, xpath),
                    "gesperrtes Wesen in einer Landschaftsgruppe"));
            }
        }

        operations.Sort((a, b) => string.CompareOrdinal(a.VerifyXPath, b.VerifyXPath));

        report.Count("landschaftsgruppen", landscapeGroups);
        report.Count("gesperrte_wesen_in_landschaftsgruppen", blockedClasses.Count);

        // Gegen Vanilla ist eine Wesenregel ohne Treffer ein Tippfehler, und zwar der stille:
        // die Klasse bleibt im Gelaende, und 'anachronisms' muss eine Regel ohne Treffer bei
        // einem gepatchten Stand fuer das Ziel halten.
        foreach (string rule in denylist.UnusedCreatureRules)
        {
            trouble++;
            report.Error("wesenregel-trifft-nichts", rule,
                "auf diese Wesenregel passt keine einzige Klasse in einer Landschaftsgruppe "
                + "dieser Quelle. Entweder ist sie falsch geschrieben, oder die Klasse steht "
                + "nur in Gruppen, die spawning.xml nicht ruft - dort urteilt keine Wesenregel.");
        }

        // Nachprobe auf einer Kopie, mit derselben Lesart wie oben.
        var copy = new XDocument(groupsDoc);
        foreach (PatchOperation op in operations)
        {
            foreach (XElement hit in copy.XPathSelectElements(op.VerifyXPath).ToList())
            {
                hit.Remove();
            }
        }

        int still = 0;
        int emptied = 0;
        int startsWithNothing = 0;

        foreach (XElement group in copy.Descendants("entitygroup"))
        {
            if (!IsLandscape(group, called))
            {
                continue;
            }

            string groupName = group.Attribute("name")!.Value;
            var entries = group.Elements("e")
                .Select(e => e.Attribute("n")?.Value ?? string.Empty)
                .ToList();

            foreach (string className in entries
                         .Where(c => c.Length > 0 && c != NoCreature
                                     && denylist.MatchCreature(c) is not null)
                         .Distinct(StringComparer.Ordinal))
            {
                still++;
                report.Error("wesen-trotz-patch", className,
                    $"diese Klasse steht auch nach allen erzeugten Patchzeilen noch in der "
                    + $"Landschaftsgruppe '{groupName}'. Der Patch-Satz deckt nicht, was die "
                    + "Pruefung findet.");
            }

            if (entries.Count == 0)
            {
                emptied++;
                report.Error("wesengruppe-leer-durch-patch", groupName,
                    "nach den erzeugten Entfernungen hat diese Landschaftsgruppe keinen Eintrag "
                    + "mehr. Das Spiel bricht das Laden einer leeren Gruppe ab ('Empty entity "
                    + "groups not allowed', statisch gelesen, Finding WP5.4). Eine Regel "
                    + "weniger, oder die Gruppe bekommt vorher einen Eintrag, der bleibt.");
            }
            else if (entries[0] == NoCreature)
            {
                startsWithNothing++;
                report.Error("wesengruppe-beginnt-mit-none", groupName,
                    "nach den erzeugten Entfernungen steht 'none' an erster Stelle dieser "
                    + "Landschaftsgruppe. Den ersten Eintrag liest das Spiel, um zu entscheiden, "
                    + "ob die Gruppe Feinde fuehrt; in Vanilla steht 'none' nie vorn, und was "
                    + "das Spiel dann tut, ist nicht gelesen (Finding WP5.4).");
            }
        }

        trouble += still + emptied + startsWithNothing;

        report.Count("gesperrte_wesen_noch_in_landschaftsgruppen", still);
        report.Count("landschaftsgruppen_leer_danach", emptied);
        report.Count("landschaftsgruppen_beginnen_mit_none", startsWithNothing);

        return new PatchFile(CreatureFileName,
            "Wesen (D149): eine gesperrte Klasse faellt aus den LANDSCHAFTSGRUPPEN - den "
            + "Gruppen, die spawning.xml ruft. Darum traegt jede Zeile den Namen der Gruppe. "
            + "Getroffen wird der Eintrag; die Klasse bleibt stehen wie jede Definition "
            + "(Vertrag 03, Nachtrag Phase 2 C), und in Schlaefer-Gruppen, Horden und der "
            + "Seuchennacht bleibt sie auch (P2-E12). Was an ihrer Stelle erscheint, steht in "
            + "700_65_Wesen - dieses Modlet nimmt nur weg.",
            operations);
    }

    /// <summary>
    /// Die Nachprobe: die erzeugten Entfernungen werden auf eine KOPIE des Quell-XML
    /// angewandt, und danach wird gezaehlt, wie viele gesperrte Kennungen auf diesem Weg
    /// noch erreichbar sind. Die Zahl muss 0 sein.
    ///
    /// <para>Das ist der Unterschied zwischen "der XPath trifft etwas" und "der XPath
    /// trifft das Richtige, und zwar alles davon". Eine Zeile, die ein Element trifft, waehrend
    /// dieselbe Kennung an drei weiteren Stellen steht, waere nach der ersten Pruefung
    /// gruen und nach dieser rot.</para>
    ///
    /// <para>Kein Nachweis bleibt: hier rechnet mein XPath, im Spiel der XML-Patcher des
    /// Spiels. Dass die Nachprobe ueberhaupt etwas prueft, zeigt <c>--ohne-entfernen</c>:
    /// ohne die Zeilen muss sie rot werden.</para>
    /// </summary>
    private static int WaysLeft(ConfigSource source, PatchFile file, HashSet<string> blocked)
    {
        if (file.ElementName is null || file.Attribute is null)
        {
            return 0;
        }

        XDocument? original = source.Load(file.FileName);
        if (original is null)
        {
            return 0;
        }

        var copy = new XDocument(original);

        foreach (PatchOperation op in file.Operations)
        {
            foreach (XElement hit in copy.XPathSelectElements(op.VerifyXPath).ToList())
            {
                if (op.SetAttribute is null)
                {
                    hit.Remove();
                }
                else
                {
                    hit.SetAttributeValue(op.SetAttribute, op.NewValue);
                }
            }
        }

        IEnumerable<XElement> candidates = copy.Descendants(file.ElementName);
        if (file.ParentClass is not null)
        {
            candidates = candidates.Where(
                e => e.Parent?.Attribute("class")?.Value == file.ParentClass);
        }

        if (file.ParentElement is not null)
        {
            candidates = candidates.Where(
                e => e.Parent?.Name.LocalName == file.ParentElement);
        }

        blocked = file.OwnBlocked ?? blocked;

        return candidates
            .Select(e => e.Attribute(file.Attribute)?.Value)
            .Where(v => v is not null)
            .Sum(v => file.ValuesAreLists
                ? v!.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .Count(entry => blocked.Contains(Bare(entry)))
                : blocked.Contains(v!) ? 1 : 0);
    }

    /// <summary>
    /// Kuerzt ein Attribut, das eine kommagetrennte Liste von Kennungen traegt, um die
    /// gesperrten Eintraege - und entfernt das Element nur dann, wenn nichts uebrig bleibt.
    ///
    /// <para>Das ist der Fall, in dem ein blindes 'remove' Schaden anrichtet. Vanilla hat
    /// 256 Quest-Belohnungen, deren 'id' eine Liste ist
    /// (<c>groupQuestFood,groupQuestAmmo,groupQuestSchematics</c>). Wer die Belohnung
    /// entfernt, weil ein Name darin gesperrt ist, nimmt dem Spieler die anderen mit. Und
    /// die Startausruestung ist genau eine solche Liste: ohne sie startet der Spieler mit
    /// leeren Haenden.</para>
    ///
    /// <para>Stueckzahlen bleiben erhalten: aus <c>drinkJarBoiledWater=2,foodCanChili</c>
    /// wird <c>drinkJarBoiledWater=2</c>, nicht <c>drinkJarBoiledWater</c>.</para>
    /// </summary>
    private static PatchFile ListAttribute(
        ConfigSource source, HashSet<string> blocked, string fileName, string elementName,
        string attribute, string why, bool skip = false, string? parentClass = null)
    {
        XDocument? document = source.Load(fileName);
        var operations = new List<PatchOperation>();

        if (document is null || skip)
        {
            return new PatchFile(fileName, why, operations);
        }

        var seen = new HashSet<string>(StringComparer.Ordinal);

        foreach (XElement element in document.Descendants(elementName))
        {
            if (parentClass is not null
                && element.Parent?.Attribute("class")?.Value != parentClass)
            {
                continue;
            }

            string? value = element.Attribute(attribute)?.Value;
            if (value is null)
            {
                continue;
            }

            List<string> entries = value
                .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                .ToList();

            List<string> survivors = entries.Where(e => !blocked.Contains(Bare(e))).ToList();
            if (survivors.Count == entries.Count)
            {
                continue;
            }

            string target = $"{PreciseChain(element)}[@{attribute}='{value}']";
            if (!seen.Add(target))
            {
                continue;
            }

            string xml;
            string reason;
            if (survivors.Count == 0)
            {
                xml = $"<remove xpath=\"{target}\" />";
                reason = "nur gesperrte Kennungen in der Liste";
            }
            else
            {
                xml = $"<setattribute xpath=\"{target}\" name=\"{attribute}\">"
                      + $"{string.Join(",", survivors)}</setattribute>";
                reason = $"Liste gekuerzt, {entries.Count - survivors.Count} von "
                         + $"{entries.Count} gesperrt";
            }

            operations.Add(new PatchOperation(
                value, xml, target, Count(document, target), reason,
                survivors.Count == 0 ? null : attribute,
                survivors.Count == 0 ? null : string.Join(",", survivors)));
        }

        operations.Sort((a, b) => string.CompareOrdinal(a.VerifyXPath, b.VerifyXPath));
        return new PatchFile(fileName, why, operations, elementName, attribute,
            ValuesAreLists: true, ParentClass: parentClass);
    }

    /// <summary>Der Name ohne Stueckzahl: aus <c>drinkJarBoiledWater=2</c> wird die Kennung.</summary>
    private static string Bare(string entry) => entry.Split('=', 2)[0].Trim();

    /// <summary>
    /// Zaehlt die Loot-Gruppen, die nach den Entfernungen keinen Eintrag mehr haben. Gezaehlt
    /// wird an einer Kopie, auf die die erzeugten Zeilen angewandt sind - nicht geschaetzt.
    /// </summary>
    /// <summary>
    /// Wie viele Bloecke hatten vor dem Patch einen benannten Abwurf und haben danach keinen
    /// mehr. Gezaehlt wird nur ueber &lt;drop name="…"/&gt;: ein
    /// <c>&lt;drop event="Destroy" count="0"/&gt;</c> ohne Namen ist Vanillas Art zu sagen
    /// "hier faellt nichts", und wer den mitzaehlt, meldet jeden Terrainblock als Luecke.
    /// </summary>
    private static (int Mute, int WithDrops) MutedBlocks(ConfigSource source, PatchFile drops)
    {
        XDocument? original = source.Load(drops.FileName);
        if (original is null)
        {
            return (0, 0);
        }

        static int Named(XElement block) =>
            block.Elements("drop").Count(d => d.Attribute("name") is not null);

        // Verglichen wird ueber die Blocknamen, nicht ueber Anzahlen: eine Differenz zweier
        // Zaehlungen waere auch dann plausibel, wenn sie zwei verschiedene Mengen zaehlt.
        var namesBefore = new HashSet<string>(
            original.Descendants("block")
                .Where(b => Named(b) > 0)
                .Select(b => b.Attribute("name")?.Value)
                .Where(n => n is not null)
                .Select(n => n!),
            StringComparer.Ordinal);
        int withDrops = namesBefore.Count;

        if (drops.Operations.Count == 0)
        {
            return (0, withDrops);
        }

        var copy = new XDocument(original);
        foreach (PatchOperation op in drops.Operations)
        {
            foreach (XElement hit in copy.XPathSelectElements(op.VerifyXPath).ToList())
            {
                hit.Remove();
            }
        }

        int mute = copy.Descendants("block").Count(
            b => b.Attribute("name") is { } a && namesBefore.Contains(a.Value) && Named(b) == 0);

        return (mute, withDrops);
    }

    /// <summary>
    /// Die Rezepte, die den Purge UEBERLEBEN und trotzdem toter Buchstabe sind, weil eine ihrer
    /// Zutaten gesperrt ist. Gezaehlt an einer Kopie, auf die die erzeugten Entfernungen
    /// angewandt sind.
    ///
    /// NACHGETRAGEN AM 2026-11-08, UND DAS WAR WIEDER EIN LOCH. Der Purge nimmt die Wege zu
    /// gesperrten Gegenstaenden. Niemand hatte gefragt, ob die UEBRIGEN Rezepte danach noch
    /// herstellbar sind - und fast jedes Vanilla-Waffenrezept ab T1 verlangt Panzerband. Der
    /// Gegenstand bleibt erlaubt, das Rezept bleibt stehen, im Handwerksfenster steht es grau,
    /// und kein Lauf hat es gemeldet: 'anachronisms' urteilt ueber Kennungen, nicht ueber
    /// Zutatenlisten, und 'recipes' prueft eine Quelle, in der unsere Modlets nicht geladen
    /// sind - dort ist Panzerband noch da. Gefunden beim Lesen der Waffenrezepte fuer WP5.1.
    /// </summary>
    private static (List<(string Recipe, string Ingredient)> Dead, int Total) DeadRecipes(
        ConfigSource source, PatchFile recipes, HashSet<string> blocked)
    {
        var dead = new List<(string, string)>();

        XDocument? original = source.Load(recipes.FileName);
        if (original is null)
        {
            return (dead, 0);
        }

        var copy = new XDocument(original);
        foreach (PatchOperation op in recipes.Operations)
        {
            foreach (XElement hit in copy.XPathSelectElements(op.VerifyXPath).ToList())
            {
                hit.Remove();
            }
        }

        var surviving = copy.Descendants("recipe").ToList();
        foreach (XElement recipe in surviving)
        {
            string name = recipe.Attribute("name")?.Value ?? string.Empty;
            if (name.Length == 0)
            {
                continue;
            }

            foreach (XElement ingredient in recipe.Elements("ingredient"))
            {
                string ing = ingredient.Attribute("name")?.Value ?? string.Empty;

                // count="0" ist Vanillas Art, eine Zutat nur fuer die Qualitaetsstufen zu
                // nennen (resourceLegendaryParts steht so in fast jedem Waffenrezept). Sie
                // kostet nichts und blockiert darum auch nichts.
                string count = ingredient.Attribute("count")?.Value ?? "1";
                if (count == "0")
                {
                    continue;
                }

                if (ing.Length > 0 && blocked.Contains(ing))
                {
                    dead.Add((name, ing));
                }
            }
        }

        return (dead, surviving.Count);
    }

    private static (int Emptied, int Total) EmptiedLootGroups(ConfigSource source, PatchFile loot)
    {
        XDocument? original = source.Load(loot.FileName);
        if (original is null)
        {
            return (0, 0);
        }

        int total = original.Descendants("lootgroup").Count();
        if (loot.Operations.Count == 0)
        {
            return (original.Descendants("lootgroup").Count(g => !g.Elements().Any()), total);
        }

        var copy = new XDocument(original);
        foreach (PatchOperation op in loot.Operations)
        {
            foreach (XElement hit in copy.XPathSelectElements(op.VerifyXPath).ToList())
            {
                hit.Remove();
            }
        }

        return (copy.Descendants("lootgroup").Count(g => !g.Elements().Any()), total);
    }

    /// <summary>Der absolute Pfad der Elementnamen von der Wurzel bis zu diesem Element.</summary>
    private static string Chain(XElement element)
    {
        var parts = new List<string>();
        for (XElement? e = element; e is not null; e = e.Parent)
        {
            parts.Add(e.Name.LocalName);
        }

        parts.Reverse();
        return "/" + string.Join("/", parts);
    }

    /// <summary>
    /// Wie <see cref="Chain"/>, aber mit einem Praedikat an jedem Vorfahren, der sich
    /// unterscheiden laesst (<c>@name</c>, sonst <c>@class</c>).
    ///
    /// <para>Noetig, wo der blosse Elementpfad nichts aussagt. Die Startausruestung liegt
    /// unter <c>/entity_classes/entity_class/property/property</c> - ein Pfad, auf den in
    /// entityclasses.xml tausende Eigenschaften passen. Mit Praedikaten wird daraus
    /// <c>/entity_classes/entity_class[@name='playerMale']/property[@class='ItemsOnEnterGame']/property[@name='GameModeSurvival']</c>,
    /// und das trifft genau eine.</para>
    /// </summary>
    private static string PreciseChain(XElement element)
    {
        var parts = new List<string>();
        for (XElement? e = element; e is not null; e = e.Parent)
        {
            string? name = e.Attribute("name")?.Value;
            string? klass = e.Attribute("class")?.Value;

            parts.Add(name is not null
                ? $"{e.Name.LocalName}[@name='{name}']"
                : klass is not null
                    ? $"{e.Name.LocalName}[@class='{klass}']"
                    : e.Name.LocalName);
        }

        parts.Reverse();
        return "/" + string.Join("/", parts);
    }

    private static int Count(XDocument document, string xpath)
    {
        try
        {
            return document.XPathSelectElements(xpath).Count();
        }
        catch (XPathException)
        {
            return 0;
        }
    }

    /// <summary>
    /// Schreibt eine Patchdatei. Mehrere Teile koennen in dieselbe Datei gehen, und sie
    /// MUESSEN es: der XML-Patcher des Spiels ordnet eine Modlet-Datei ihrer Vanilla-Datei
    /// ueber den DATEINAMEN zu. Eine 'blocks-abwuerfe.xml' wuerde nie angewandt. blocks.xml
    /// traegt darum zwei Teile - die CreativeMode-Zeilen und die Abwurf-Entfernungen -, und
    /// sie bleiben im Werkzeug getrennte PatchFile-Objekte, weil jede Nachprobe nur ein
    /// Element und ein Attribut kennt. Zusammengelegt koennte 'wege_uebrig' nur noch eines
    /// von beiden pruefen und waere beim anderen stillschweigend gruen.
    /// </summary>
    private static string Render(IReadOnlyList<PatchFile> parts)
    {
        string fileName = parts[0].FileName;
        int lineCount = parts.Sum(p => p.Operations.Count);

        var text = new StringBuilder();
        text.Append("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n");
        text.Append("<config>\n");
        text.Append($"\t<!-- 700_10_Purge / {fileName}\n");
        text.Append($"\t     F-01 Anachronismen-Purge, Plan-0001 {Stufe}\n");

        foreach (PatchFile part in parts)
        {
            text.Append("\n");
            text.Append($"\t     {Wrap(part.Why, "\t     ")}\n");
        }

        text.Append("\n");
        text.Append("\t     ERZEUGT von 'mod700check purge-patch' aus denylist.txt und\n");
        text.Append("\t     aufschub.txt. Nicht von Hand aendern: die naechste Erzeugung\n");
        text.Append("\t     ueberschreibt die Aenderung lautlos, und check-all.ps1 meldet\n");
        text.Append("\t     jede Handaenderung als 'patchdatei-veraltet'. Wer hier etwas\n");
        text.Append("\t     anderes haben will, aendert die Denylist und laesst neu erzeugen.\n");
        text.Append($"\t     Quelle der Erzeugung: {Rendered}.\n");
        text.Append($"\t     {lineCount} Zeilen");
        text.Append(parts.Count > 1 ? $" aus {parts.Count} Teilen. -->\n" : ". -->\n");
        text.Append("\n");

        foreach (PatchFile part in parts)
        {
            foreach (PatchOperation op in part.Operations)
            {
                text.Append($"\t{op.Xml}  <!-- {op.Reason} -->\n");
            }
        }

        if (lineCount == 0)
        {
            text.Append("\t<!-- keine Zeilen: in dieser Quelle gibt es nichts zu patchen. -->\n");
        }

        text.Append("</config>\n");
        return text.ToString();
    }

    /// <summary>Bricht eine Begruendung auf Kommentarbreite um, damit der Kopf lesbar bleibt.</summary>
    private static string Wrap(string text, string indent)
    {
        var lines = new List<string>();
        var line = new StringBuilder();

        foreach (string word in text.Split(' '))
        {
            if (line.Length > 0 && line.Length + word.Length + 1 > 72)
            {
                lines.Add(line.ToString());
                line.Clear();
            }

            if (line.Length > 0)
            {
                line.Append(' ');
            }

            line.Append(word);
        }

        if (line.Length > 0)
        {
            lines.Add(line.ToString());
        }

        return string.Join("\n" + indent, lines);
    }

    private sealed record PatchFile(
        string FileName, string Why, List<PatchOperation> Operations,
        string? ElementName = null, string? Attribute = null,
        bool ValuesAreLists = false, string? ParentClass = null,
        string? ParentElement = null, HashSet<string>? OwnBlocked = null);

    private sealed record PatchOperation(
        string Target, string Xml, string VerifyXPath, int Matches, string Reason,
        string? SetAttribute = null, string? NewValue = null);
}
