using System.Text.Json;
using System.Text.Json.Serialization;

namespace Mod700.Check;

/// <summary>Wie schwer ein Befund wiegt. Nur <see cref="Error"/> macht den Lauf rot.</summary>
internal enum Severity
{
    Error,
    Hint
}

/// <summary>Ein einzelner Befund. <paramref name="Where"/> ist Datei, Zeile oder Kennung.</summary>
internal sealed record Finding(Severity Severity, string Rule, string Where, string Detail);

/// <summary>
/// Woher die geprueften Daten stammen. Steht in jeder Ausgabe, damit kein Vorlauf
/// versehentlich als Nachweis durchgeht (Vertrag 04, Abschnitt 1).
/// </summary>
internal sealed record SourceInfo(string Path, string Kind, string? Timestamp, string Note);

/// <summary>Sammelt Befunde und schreibt die Ausgabe. Exit-Code: 0 gruen, 1 rot, 2 Benutzungsfehler.</summary>
internal sealed class Report
{
    private readonly List<Finding> _findings = new();
    private readonly Dictionary<string, object> _counts = new();
    private readonly List<string> _limitations = new();

    public Report(string command, SourceInfo source)
    {
        Command = command;
        Source = source;
    }

    public string Command { get; }

    public SourceInfo Source { get; }

    public int Errors => _findings.Count(f => f.Severity == Severity.Error);

    public int Hints => _findings.Count(f => f.Severity == Severity.Hint);

    public void Error(string rule, string where, string detail) =>
        _findings.Add(new Finding(Severity.Error, rule, where, detail));

    public void Hint(string rule, string where, string detail) =>
        _findings.Add(new Finding(Severity.Hint, rule, where, detail));

    public void Count(string name, object value) => _counts[name] = value;

    public void Limitation(string text) => _limitations.Add(text);

    /// <summary>
    /// Schreibt die Ausgabe und liefert den Exit-Code. Ohne <paramref name="asJson"/> eine
    /// kurze Tabelle; der Exit-Code ist in beiden Faellen derselbe.
    /// </summary>
    public int Write(bool asJson, int maxShown = 40)
    {
        string verdict = Errors == 0 ? "green" : "red";

        if (asJson)
        {
            var payload = new
            {
                tool = "mod700check",
                command = Command,
                source = new
                {
                    path = Source.Path,
                    kind = Source.Kind,
                    timestamp = Source.Timestamp,
                    note = Source.Note
                },
                counts = _counts,
                findings = _findings.Select(f => new
                {
                    severity = f.Severity == Severity.Error ? "error" : "hint",
                    rule = f.Rule,
                    where = f.Where,
                    detail = f.Detail
                }),
                summary = new
                {
                    errors = Errors,
                    hints = Hints,
                    verdict
                },
                limitations = _limitations
            };

            Console.WriteLine(JsonSerializer.Serialize(payload, JsonOptions));
        }
        else
        {
            Console.WriteLine($"== mod700check {Command} ==");
            Console.WriteLine($"  Quelle: {Source.Path}");
            Console.WriteLine($"  Art:    {Source.Kind}  ({Source.Note})");
            if (Source.Timestamp is not null)
            {
                Console.WriteLine($"  Stand:  {Source.Timestamp}");
            }

            if (_counts.Count > 0)
            {
                Console.WriteLine();
                foreach (var (name, value) in _counts)
                {
                    Console.WriteLine($"  {name,-34} {value}");
                }
            }

            var shown = _findings
                .OrderBy(f => f.Severity)
                .Take(maxShown)
                .ToList();

            if (shown.Count > 0)
            {
                Console.WriteLine();
                foreach (var f in shown)
                {
                    string marker = f.Severity == Severity.Error ? "[ROT] " : "[Hinw]";
                    Console.WriteLine($"  {marker} {f.Rule}: {f.Where}");
                    Console.WriteLine($"          {f.Detail}");
                }

                if (_findings.Count > shown.Count)
                {
                    Console.WriteLine($"  ... und {_findings.Count - shown.Count} weitere (--json zeigt alle)");
                }
            }

            if (_limitations.Count > 0)
            {
                Console.WriteLine();
                Console.WriteLine("  Grenzen dieser Pruefung:");
                foreach (string limitation in _limitations)
                {
                    Console.WriteLine($"    - {limitation}");
                }
            }

            Console.WriteLine();
            Console.WriteLine($"== Ergebnis: {Errors} rot, {Hints} Hinweise -> {verdict.ToUpperInvariant()} ==");
        }

        return Errors == 0 ? 0 : 1;
    }

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.Never
    };
}
