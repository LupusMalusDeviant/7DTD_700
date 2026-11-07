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
    private readonly List<(Regex Pattern, string Source)> _deny = new();
    private readonly List<(Regex Pattern, string Reason)> _allow = new();

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

            if (rule.StartsWith('!'))
            {
                string pattern = rule[1..].Trim();
                if (pattern.Length == 0)
                {
                    throw new UsageException($"{path}:{i + 1}: Freigabe ohne Muster.");
                }

                list._allow.Add((Compile(pattern), reason.Length > 0 ? reason : "ohne Begruendung"));
            }
            else
            {
                list._deny.Add((Compile(rule), $"{Path.GetFileName(path)}:{i + 1}"));
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

        foreach ((Regex pattern, string reason) in _allow)
        {
            if (pattern.IsMatch(name))
            {
                allowReason = reason;
                return null;
            }
        }

        foreach ((Regex pattern, string source) in _deny)
        {
            if (pattern.IsMatch(name))
            {
                return source;
            }
        }

        return null;
    }

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
