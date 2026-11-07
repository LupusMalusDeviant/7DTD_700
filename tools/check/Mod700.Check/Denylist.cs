using System.Text.RegularExpressions;

namespace Mod700.Check;

/// <summary>
/// Die Denylist aus Vertrag 04: Muster fuer verbotene Kennungen, dazu eine Freigabeliste.
///
/// Die Freigaben sind Pflicht, nicht Kuer. D9 verlangt, dass Geschuetztuerme, Generator,
/// Kabel, Schalter, Sensoren und Sprengstoff als Klassen erhalten bleiben, weil F-15 sie in
/// Phase 2 umdeutet. Ohne Freigabe wuerde dieses Werkzeug verlangen, ein ganzes Feature der
/// naechsten Phase zu zerstoeren.
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

    private static Regex Compile(string wildcard)
    {
        string escaped = Regex.Escape(wildcard).Replace("\\*", ".*");
        return new Regex($"^{escaped}$", RegexOptions.IgnoreCase | RegexOptions.Compiled);
    }
}
