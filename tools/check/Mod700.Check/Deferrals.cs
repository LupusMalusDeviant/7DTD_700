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

    // Aufgeschobene ZIELE (Vertrag 04, Nachtrag Ziele der Herausforderungen). Eigener
    // Regelsatz: eine Herausforderung ist kein Gegenstand, und 'gatherer*' soll nie
    // versehentlich eine Kennung gleichen Anfangs aufschieben.
    private readonly List<(string Text, Regex Pattern, string Package, string Reason)> _targets = new();
    private readonly HashSet<string> _targetUsed = new(StringComparer.Ordinal);

    public int Rules => _rules.Count;

    public int TargetRules => _targets.Count;

    /// <summary>Vorsatz einer Zeile, die eine Herausforderung aufschiebt.</summary>
    public const string TargetPrefix = "ziel:";

    /// <summary>
    /// Die Zeile, die sagt: nichts ist aufgeschoben. Kein gueltiger Kennungsname (das
    /// Gleichheitszeichen kommt in keiner Kennung vor), also nicht mit einer Regel zu
    /// verwechseln.
    /// </summary>
    public const string EmptyMarker = "=kein-aufschub";

    public static Deferrals Empty() => new();

    public static Deferrals Load(string path)
    {
        if (!File.Exists(path))
        {
            throw new UsageException($"Keine Aufschub-Datei: {path}");
        }

        var list = new Deferrals();
        string[] lines = File.ReadAllLines(path);
        int emptyMarkerLine = 0;

        for (int i = 0; i < lines.Length; i++)
        {
            int comment = lines[i].IndexOf('#');
            string rule = (comment >= 0 ? lines[i][..comment] : lines[i]).Trim();
            string reason = comment >= 0 ? lines[i][(comment + 1)..].Trim() : string.Empty;

            if (rule.Length == 0)
            {
                continue;
            }

            // Die ausdrueckliche Leermeldung (seit dem 2026-11-22): sind alle Aufschuebe
            // eingeloest, steht in der Datei genau diese eine Zeile, mit einem Grund. Eine
            // Datei ganz ohne Zeile bleibt ein Benutzungsfehler - sie koennte auch
            // versehentlich geleert sein, und dann fiele niemandem auf, dass nichts mehr
            // aufgeschoben ist.
            if (rule == EmptyMarker)
            {
                if (reason.Length == 0)
                {
                    throw new UsageException(
                        $"{path}:{i + 1}: '{EmptyMarker}' braucht einen Grund hinter '#', etwa "
                        + "'# alle Aufschuebe eingeloest am 2026-11-22'.");
                }

                emptyMarkerLine = i + 1;
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

            if (rule.StartsWith(TargetPrefix, StringComparison.Ordinal))
            {
                string target = rule[TargetPrefix.Length..].Trim();
                if (target.Length == 0)
                {
                    throw new UsageException(
                        $"{path}:{i + 1}: '{TargetPrefix}' ohne Muster. Hinter den Vorsatz "
                        + "gehoert die Kennung der Herausforderung, etwa 'ziel:farmingCorn'.");
                }

                string targetEscaped = Regex.Escape(target).Replace("\\*", ".*");
                list._targets.Add((target,
                    new Regex($"^{targetEscaped}$", RegexOptions.Compiled),
                    package.Value, reason));
                continue;
            }

            string escaped = Regex.Escape(rule).Replace("\\*", ".*");
            list._rules.Add((new Regex($"^{escaped}$", RegexOptions.Compiled),
                package.Value, reason));
        }

        int all = list._rules.Count + list._targets.Count;
        if (emptyMarkerLine > 0 && all > 0)
        {
            throw new UsageException(
                $"{path}:{emptyMarkerLine}: '{EmptyMarker}' steht neben {all} "
                + "Aufschub-Zeile(n). Entweder ist etwas aufgeschoben oder nichts - beides "
                + "zugleich ist ein Widerspruch.");
        }

        if (all == 0 && emptyMarkerLine == 0)
        {
            throw new UsageException(
                $"{path} enthaelt keine einzige Zeile. Eine leere Aufschub-Datei ist kein "
                + $"Aufschub - dann die Option weglassen, oder '{EmptyMarker}  # Grund' "
                + "eintragen, wenn alle Aufschuebe eingeloest sind.");
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

    /// <summary>
    /// Die Begruendung, wenn diese HERAUSFORDERUNG aufgeschoben ist — sonst null. Gefragt
    /// wird nur fuer eine Herausforderung, die unerfuellbar IST; eine Regel, die nie gefragt
    /// wird oder nie passt, steht danach in <see cref="UnusedTargetRules"/>.
    /// </summary>
    public string? MatchTarget(string challenge)
    {
        foreach ((string text, Regex pattern, string _, string reason) in _targets)
        {
            if (pattern.IsMatch(challenge))
            {
                _targetUsed.Add(text);

                // Die Begruendung nennt ihr Arbeitspaket schon selbst (ohne es waere die
                // Zeile abgelehnt worden); es noch einmal davorzusetzen, verdoppelt es nur.
                return reason;
            }
        }

        return null;
    }

    /// <summary>Zielaufschuebe, die keine unerfuellbare Herausforderung aufgeschoben haben.</summary>
    public IEnumerable<string> UnusedTargetRules => _targets
        .Where(t => !_targetUsed.Contains(t.Text))
        .Select(t => TargetPrefix + t.Text);
}
