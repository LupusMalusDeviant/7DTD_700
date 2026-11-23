using System.Text.RegularExpressions;

namespace Mod700.Check;

/// <summary>
/// Die Denylist aus Vertrag 04: Muster fuer verbotene Kennungen, dazu eine Freigabeliste.
///
/// Eine Freigabe sagt: "dieser Gegenstand darf der Spieler erreichen". Sie sagt NICHT "diese
/// Klasse bleibt im Spiel". Das war der Denkfehler des ersten Standes: die D9-Systeme
/// (Geschuetztuerme, Generator, Kabel, Schalter, Sensoren, elektrische Fallen) standen hier
/// als Freigaben, damit F-15 sie in Phase 2 umdeuten kann. Aber F-01 sagt woertlich, dass
/// F-01 "nur ihre modernen Varianten (Namen, Rezepte, Loot)" sperrt und die Logik erhaelt.
/// Rezepte und Loot sind genau das, was dieses Werkzeug messen kann - die Klasse sieht es
/// nie. D9 wird also in Vertrag 03 Abschnitt 4 gewahrt (kein 'remove' auf die Definition),
/// nicht durch eine Freigabe hier. Mit den Freigaben blieben Generator und Geschuetzturm in
/// Phase 1 herstellbar, und das Werkzeug haette dazu "0 rot" gemeldet.
///
/// Freigaben gelten darum nur noch fuer Gegenstaende, die ueberhaupt kein Anachronismus sind
/// und blosz unglueckliche Vanilla-Namen tragen (D54, D55, D56).
///
/// Dateiformat: eine Regel pro Zeile. '#' beginnt einen Kommentar. Eine Zeile mit '!' am
/// Anfang ist eine Freigabe. '*' steht fuer beliebig viele Zeichen.
/// </summary>
internal sealed class Denylist
{
    private readonly List<(Regex Pattern, string Source, string Text)> _deny = new();
    private readonly List<(Regex Pattern, string Reason, string Text, string Source)> _allow = new();
    private readonly List<(Regex Pattern, string Source, string Text)> _quests = new();

    public int DenyRules => _deny.Count;

    public int AllowRules => _allow.Count;

    public static Denylist Load(string path)
    {
        if (!File.Exists(path))
        {
            throw new UsageException($"Keine Denylist-Datei: {path}");
        }

        var list = new Denylist();
        string[] lines = File.ReadAllLines(path);

        for (int i = 0; i < lines.Length; i++)
        {
            string line = lines[i];
            int comment = line.IndexOf('#');
            string reason = comment >= 0 ? line[(comment + 1)..].Trim() : string.Empty;
            string rule = (comment >= 0 ? line[..comment] : line).Trim();

            if (rule.Length == 0)
            {
                continue;
            }

            if (rule.StartsWith(QuestPrefix, StringComparison.Ordinal))
            {
                string pattern = rule[QuestPrefix.Length..].Trim();
                if (pattern.Length == 0)
                {
                    throw new UsageException($"{path}:{i + 1}: Auftragsregel ohne Muster.");
                }

                list._quests.Add((Compile(pattern), $"{Path.GetFileName(path)}:{i + 1}", pattern));
            }
            else if (rule.StartsWith(CreaturePrefix, StringComparison.Ordinal))
            {
                string pattern = rule[CreaturePrefix.Length..].Trim();
                if (pattern.Length == 0)
                {
                    throw new UsageException($"{path}:{i + 1}: Wesenregel ohne Muster.");
                }

                list._creatures.Add((Compile(pattern), $"{Path.GetFileName(path)}:{i + 1}", pattern));
            }
            else if (rule.StartsWith('!'))
            {
                string pattern = rule[1..].Trim();
                if (pattern.Length == 0)
                {
                    throw new UsageException($"{path}:{i + 1}: Freigabe ohne Muster.");
                }

                list._allow.Add((
                    Compile(pattern),
                    reason.Length > 0 ? reason : "ohne Begruendung",
                    pattern,
                    $"{Path.GetFileName(path)}:{i + 1}"));
            }
            else
            {
                list._deny.Add((Compile(rule), $"{Path.GetFileName(path)}:{i + 1}", rule));
            }
        }

        if (list._deny.Count == 0)
        {
            throw new UsageException($"{path} enthaelt keine einzige Verbotsregel.");
        }

        return list;
    }

    /// <summary>
    /// Liefert die Verbotsregel, die auf <paramref name="name"/> passt — oder null, wenn der
    /// Name erlaubt ist. Eine Freigabe schlaegt jedes Verbot.
    /// </summary>
    public string? Match(string name, out string? allowReason)
    {
        allowReason = null;

        foreach ((Regex pattern, string reason, _, string source) in _allow)
        {
            if (pattern.IsMatch(name))
            {
                _allowUsed.Add(source);
                allowReason = reason;
                return null;
            }
        }

        foreach ((Regex pattern, string source, _) in _deny)
        {
            if (pattern.IsMatch(name))
            {
                _denyUsed.Add(source);
                return source;
            }
        }

        return null;
    }

    private readonly HashSet<string> _denyUsed = new(StringComparer.Ordinal);
    private readonly HashSet<string> _allowUsed = new(StringComparer.Ordinal);
    private readonly HashSet<string> _questUsed = new(StringComparer.Ordinal);

    /// <summary>
    /// Der Anfang einer Auftragsregel: <c>auftrag:tier*_restore_power</c>.
    ///
    /// <para>Ein Auftrag ist kein Gegenstand. "Geh hin und wirf die Generatoren wieder an"
    /// ist ein Anachronismus, den keine Namensregel fuer Gegenstaende trifft, weil er keinen
    /// Gegenstand in die Hand gibt (D103, Vertrag 04, Nachtrag Auftragsregeln). Die Regeln
    /// stehen trotzdem in derselben Datei: eine zweite Liste waere eine zweite Stelle, an
    /// der Sperrliste und Modlet auseinanderlaufen koennen.</para>
    ///
    /// <para>Sie sind ein EIGENER Regelsatz und mischen sich nicht mit den anderen: eine
    /// Auftragsregel urteilt nie ueber einen Gegenstand, eine Gegenstandsregel nie ueber
    /// einen Auftrag, und eine Freigabe ('!') gibt es fuer Auftraege nicht - was bleiben
    /// soll, bekommt einfach keine Regel.</para>
    /// </summary>
    public const string QuestPrefix = "auftrag:";

    public int QuestRules => _quests.Count;

    /// <summary>
    /// Liefert die Auftragsregel, die auf die Kennung eines Auftrags passt - oder null.
    /// </summary>
    public string? MatchQuest(string questId)
    {
        foreach ((Regex pattern, string source, string text) in _quests)
        {
            if (pattern.IsMatch(questId))
            {
                _questUsed.Add(source);
                return $"{text}  ({source})";
            }
        }

        return null;
    }

    /// <summary>
    /// Auftragsregeln, die in diesem Lauf auf keinen einzigen Auftrag gepasst haben. Gegen
    /// Vanilla ist das ein Tippfehler; gegen einen Stand, in dem unsere Modlets schon
    /// geladen sind, ist es das Ziel - darum entscheidet der Aufrufer, was es bedeutet.
    /// </summary>
    public IEnumerable<string> UnusedQuestRules => _quests
        .Where(q => !_questUsed.Contains(q.Source))
        .Select(q => $"{q.Text}  ({q.Source})");

    // --- Wesenregeln (Vertrag 04, Nachtrag Pruefungen der Phase 2, Teil 2) ---------------
    // Eigener Regelsatz wie die Auftragsregeln: ein Wesen ist kein Gegenstand, und 'zombie*'
    // als Gegenstandsregel soll nie ueber eine Klasse urteilen.
    private readonly List<(Regex Pattern, string Source, string Text)> _creatures = new();

    /// <summary>Vorsatz einer Zeile, die ueber Wesen-Klassen in Landschaftsgruppen urteilt.</summary>
    public const string CreaturePrefix = "wesen:";

    public int CreatureRules => _creatures.Count;

    /// <summary>
    /// Liefert die Wesenregel, die auf den Namen einer Klasse passt - oder null.
    /// </summary>
    public string? MatchCreature(string className)
    {
        foreach ((Regex pattern, string source, string text) in _creatures)
        {
            if (pattern.IsMatch(className))
            {
                return $"{text}  ({source})";
            }
        }

        return null;
    }

    /// <summary>
    /// Verbotsregeln, die in diesem Lauf auf keine einzige Kennung gepasst haben.
    ///
    /// <para>Das ist der Waechter gegen den Fehler, der in WP3.1 zweimal passiert ist. Erst
    /// hiess eine Regel 'drugs*' statt 'drug*' und traf drei Drogen nur deshalb, weil der
    /// Vergleich die Schreibung ignorierte. Dann hiess eine 'magazine*' statt
    /// '*SkillMagazine' und traf gar nichts - und niemand haette es bemerkt, weil eine Regel
    /// ohne Treffer sich genauso anfuehlt wie eine, die nichts zu tun hatte.</para>
    ///
    /// <para>Eine Regel ohne Treffer ist nicht zwingend falsch: sie kann auf etwas zeigen,
    /// das es in dieser Spielfassung nicht gibt. Darum ist das ein Hinweis und kein Fehler -
    /// aber ein sichtbarer.</para>
    /// </summary>
    /// <summary>
    /// Trennt zwei Faelle, die beide "kein Treffer" heissen und nichts miteinander zu tun
    /// haben.
    ///
    /// <para><b>leer</b>: kein einziger erreichbarer Name passt auf die Regel. Das ist der
    /// verdaechtige Fall - so sah 'magazine*' aus, das '*SkillMagazine' heissen musste.</para>
    ///
    /// <para><b>verdeckt</b>: Namen passen schon, aber eine breitere Regel steht vorher in
    /// der Datei und bekommt sie zugeschrieben. 'gunBot*' ist von 'gun*' verdeckt,
    /// 'electricfencepost*' von 'electric*'. Das ist harmlos und oft Absicht (die engere
    /// Regel dokumentiert, WARUM etwas fallen soll), nur eben wirkungslos.</para>
    ///
    /// <para>Der erste Entwurf dieses Zaehlers hat beide zusammengeworfen und 20 Regeln
    /// gemeldet, von denen 7 nur verdeckt waren. Eine Warnung, die zu Schatten fuehrt,
    /// verliert ihre Glaubwuerdigkeit schneller als eine, die fehlt.</para>
    /// </summary>
    public (List<string> Empty, List<string> Shadowed) ClassifyUnused(IEnumerable<string> names)
    {
        var all = names.ToList();
        var empty = new List<string>();
        var shadowed = new List<string>();

        // Der Hinweis nennt Datei, Zeile UND das Muster. Nur Datei und Zeile zu melden
        // verlangt, dass man die Datei aufschlaegt, um zu sehen, worum es geht - und genau
        // das Muster ist die Information: 'magazine*' statt '*SkillMagazine' erkennt man
        // beim Lesen, 'denylist.txt:41' nicht.
        foreach ((Regex pattern, string source, string text) in _deny)
        {
            if (_denyUsed.Contains(source))
            {
                continue;
            }

            bool anyMatch = all.Any(n => pattern.IsMatch(n));
            (anyMatch ? shadowed : empty).Add($"{text}  ({source})");
        }

        return (empty, shadowed);
    }

    /// <summary>
    /// Freigaben, die in diesem Lauf auf keine einzige erreichbare Kennung gepasst haben.
    ///
    /// <para>Das ist der gefaehrlichere der beiden Tippfehler. Eine Verbotsregel ohne
    /// Treffer laesst etwas durch, und das wird als Befund gemeldet. Eine Freigabe ohne
    /// Treffer laesst etwas FALLEN - und ein Befund mehr sieht aus wie Arbeit, die getan
    /// wurde, nicht wie ein Fehler. Darum nennt der Hinweis das Muster.</para>
    /// </summary>
    public IEnumerable<string> UnusedAllowRules => _allow
        .Where(a => !_allowUsed.Contains(a.Source))
        .Select(a => $"{a.Text}  ({a.Source})");

    /// <summary>
    /// Baut aus einem Wildcard-Muster einen verankerten, <b>gross-/kleinschreibungsgenauen</b>
    /// Ausdruck.
    ///
    /// Dass hier kein IgnoreCase steht, ist der Kern dieser Methode. Mit IgnoreCase hat die
    /// Regel 'drugs*' in WP3.1 drei Treffer gemeldet - nicht weil sie stimmte, sondern weil
    /// 'drugSteroids', 'drugSkullCrushers' und 'drugSugarButts' an der fuenften Stelle ein
    /// grosses S tragen und 'drugs' case-insensitiv auf 'drugS' passt. Gemeint war 'drug*'.
    /// Die Regel sah also aus, als arbeite sie, waehrend sie zwoelf weitere Drogen durchliess
    /// (drugAntibiotics, drugPainkillers, drugVitamins und so weiter).
    ///
    /// Kennungen in 7DTD sind gross-/kleinschreibungsgenau. Eine Regel, die lockerer passt als
    /// sie sich liest, taeuscht Deckung vor - und eine getaeuschte Deckung ist schlimmer als
    /// eine fehlende, weil die fehlende auffaellt.
    /// </summary>
    private static Regex Compile(string wildcard)
    {
        string escaped = Regex.Escape(wildcard).Replace("\\*", ".*");
        return new Regex($"^{escaped}$", RegexOptions.Compiled);
    }
}
