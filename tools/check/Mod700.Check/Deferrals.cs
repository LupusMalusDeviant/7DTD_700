using System.Text.RegularExpressions;

namespace Mod700.Check;

/// <summary>
/// Aufgeschobene Anachronismen: Kennungen, die verboten sind, aber erst in einem spaeteren
/// Arbeitspaket fallen, weil dort das System steht, das sie ersetzt.
///
/// <para><b>Ein Aufschub ist kein Bestanden.</b> Darum wird er nicht einfach aus der Pruefung
/// genommen, sondern umgebucht: aus einem Fehler wird ein Hinweis, und die Zahl steht mit
/// eigenem Namen im Bericht. Ein Lauf kann so "0 rot, 133 aufgeschoben" melden - erreichbar
/// fuer das laufende Arbeitspaket, und niemand kann es fuer fertig halten, weil die Zahl
/// daneben steht.</para>
///
/// <para><b>Jede Zeile MUSS ein Arbeitspaket nennen.</b> Ein Aufschub ohne Adresse ist kein
/// Aufschub, sondern ein Loch mit guter Presse: niemand weiss, wer ihn schliesst, und beim
/// naechsten Lauf sieht er aus wie eine getroffene Entscheidung. Fehlt die Angabe, ist das
/// ein Benutzungsfehler (Exit 2) und kein stilles Durchwinken.</para>
/// </summary>
internal sealed class Deferrals
{
    private readonly List<(Regex Pattern, string Package, string Reason)> _rules = new();

    public int Rules => _rules.Count;

    public static Deferrals Empty() => new();

    public static Deferrals Load(string path)
    {
        if (!File.Exists(path))
        {
            throw new UsageException($"Keine Aufschub-Datei: {path}");
        }

        var list = new Deferrals();
        string[] lines = File.ReadAllLines(path);

        for (int i = 0; i < lines.Length; i++)
        {
            int comment = lines[i].IndexOf('#');
            string rule = (comment >= 0 ? lines[i][..comment] : lines[i]).Trim();
            string reason = comment >= 0 ? lines[i][(comment + 1)..].Trim() : string.Empty;

            if (rule.Length == 0)
            {
                continue;
            }

            Match package = Regex.Match(reason, @"\bWP\s?\d+(\.\d+[a-z]?)?\b");
            if (!package.Success)
            {
                throw new UsageException(
                    $"{path}:{i + 1}: Der Aufschub '{rule}' nennt kein Arbeitspaket. "
                    + "Jede Zeile braucht eine Begruendung mit einem WP-Verweis, etwa "
                    + "'# WP7: F-21 ersetzt das System'. Ein Aufschub ohne Adresse ist ein "
                    + "Loch, das beim naechsten Lauf wie eine Entscheidung aussieht.");
            }

            string escaped = Regex.Escape(rule).Replace("\\*", ".*");
            list._rules.Add((new Regex($"^{escaped}$", RegexOptions.Compiled),
                package.Value, reason));
        }

        if (list._rules.Count == 0)
        {
            throw new UsageException(
                $"{path} enthaelt keine einzige Zeile. Eine leere Aufschub-Datei ist kein "
                + "Aufschub - dann die Option weglassen.");
        }

        return list;
    }

    /// <summary>Die Begruendung, wenn diese Kennung aufgeschoben ist — sonst null.</summary>
    public string? Match(string name)
    {
        foreach ((Regex pattern, string package, string reason) in _rules)
        {
            if (pattern.IsMatch(name))
            {
                return $"{package}: {reason}";
            }
        }

        return null;
    }
}
