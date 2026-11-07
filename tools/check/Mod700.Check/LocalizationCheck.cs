using System.Text.RegularExpressions;

namespace Mod700.Check;

/// <summary>
/// Prueft eine Localization.csv gegen die belegte Form.
///
/// Der wichtigste Punkt steckt in der Kopfzeile: zwischen <c>english</c> und <c>german</c>
/// steht <c>Context / Alternate Text</c>, und davor liegen fuenf Metadatenspalten. Ein
/// Werkzeug, das „die Spalte nach english ist Deutsch" annimmt, prueft die Kommentarspalte
/// und meldet Gruen fuer fehlende Uebersetzungen. Darum wird hier ausschliesslich nach
/// Spaltennamen gesucht, nie nach Position.
/// Beleg: docs/rea/findings/WP1-modlet-lader-und-xml-patcher.md, Abschnitt 6.
/// </summary>
internal static class LocalizationCheck
{
    private static readonly Regex LatinOnly = new("^[A-Za-z0-9 /_-]+$", RegexOptions.Compiled);

    /// <summary>Die Spalten, die keine Sprachen sind (Metadaten und die Kommentarspalte).</summary>
    private static readonly string[] NonLanguageColumns =
    {
        "Key", "File", "Type", "UsedInMainMenu", "NoTranslate", "KeepLoaded",
        "Context / Alternate Text"
    };

    public static int Run(string path, string[] args)
    {
        var required = new List<string> { "english", "german" };
        string? prefix = null;
        string? allowFile = null;
        bool asJson = false;

        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--sprachen" when i + 1 < args.Length:
                    required = args[++i].Split(',', StringSplitOptions.RemoveEmptyEntries |
                                                    StringSplitOptions.TrimEntries).ToList();
                    break;
                case "--prefix" when i + 1 < args.Length:
                    prefix = args[++i];
                    break;
                case "--vanilla-keys" when i + 1 < args.Length:
                    allowFile = args[++i];
                    break;
                case "--json":
                    asJson = true;
                    break;
                default:
                    throw new UsageException($"Unbekannte Option fuer localization: {args[i]}");
            }
        }

        if (!File.Exists(path))
        {
            throw new UsageException($"Keine Datei: {path}");
        }

        var allowed = new HashSet<string>(StringComparer.Ordinal);
        if (allowFile is not null)
        {
            if (!File.Exists(allowFile))
            {
                throw new UsageException($"Keine Datei: {allowFile}");
            }

            foreach (string raw in File.ReadAllLines(allowFile))
            {
                string key = raw.Trim();
                if (key.Length > 0 && !key.StartsWith('#'))
                {
                    allowed.Add(key);
                }
            }
        }

        var source = new SourceInfo(
            path,
            "localization-csv",
            File.GetLastWriteTimeUtc(path).ToString("yyyy-MM-dd HH:mm:ss'Z'"),
            prefix is null
                ? "Praefix-Pruefung aus (kein --prefix)"
                : $"Praefix-Pruefung auf '{prefix}'");
        var report = new Report("localization", source);

        report.Limitation(
            "Geprueft wird die Form, nicht der Inhalt: ob eine Uebersetzung richtig oder " +
            "verstaendlich ist, kann dieses Werkzeug nicht sagen.");
        report.Limitation(
            "Localization.csv liegt NICHT im ConfigsDump des Spiels. Geprueft wird also immer " +
            "eine Quelldatei, nie die gemergte Fassung - doppelte Schluessel ueber zwei Modlets " +
            "hinweg findet dieser Lauf nur, wenn beide Dateien zusammen geprueft werden.");

        List<Csv.Row> rows = Csv.Read(path);
        if (rows.Count == 0)
        {
            report.Error("leere-datei", path, "Die Datei hat keine Zeilen.");
            return report.Write(asJson);
        }

        // --- Kopfzeile
        List<string> header = rows[0].Fields;
        report.Count("spalten", header.Count);
        report.Count("zeilen_mit_daten", rows.Count - 1);

        if (!string.Equals(header[0], "Key", StringComparison.OrdinalIgnoreCase))
        {
            report.Error("kopfzeile", $"{path}:1",
                $"Die erste Spalte muss 'Key' heissen, gefunden '{header[0]}'. " +
                "Localization::loadCsv erwartet das.");
        }

        for (int c = 0; c < header.Count; c++)
        {
            if (string.IsNullOrWhiteSpace(header[c]))
            {
                report.Error("kopfzeile", $"{path}:1",
                    $"Spalte {c + 1} hat keinen Namen. Localization::loadCsv verlangt " +
                    "nicht-leere Spaltendefinitionen.");
            }
            else if (!LatinOnly.IsMatch(header[c]))
            {
                report.Error("kopfzeile", $"{path}:1",
                    $"Spaltenname '{header[c]}' enthaelt Zeichen, die der Lader nicht annimmt " +
                    "(nur lateinische Buchstaben).");
            }
        }

        // Spaltennamen auf Index abbilden. NUR so - nie ueber die Position raten.
        var index = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
        for (int c = 0; c < header.Count; c++)
        {
            string name = header[c].Trim();
            if (name.Length > 0 && !index.ContainsKey(name))
            {
                index[name] = c;
            }
        }

        var missingColumns = required.Where(r => !index.ContainsKey(r)).ToList();
        foreach (string column in missingColumns)
        {
            report.Error("pflichtspalte-fehlt", $"{path}:1",
                $"Die Spalte '{column}' gibt es in der Kopfzeile nicht.");
        }

        var requiredIndexes = required
            .Where(index.ContainsKey)
            .Select(r => (Name: r, Index: index[r]))
            .ToList();

        var otherLanguages = header
            .Select((name, i) => (Name: name.Trim(), Index: i))
            .Where(x => x.Name.Length > 0
                        && !NonLanguageColumns.Contains(x.Name, StringComparer.OrdinalIgnoreCase)
                        && !required.Contains(x.Name, StringComparer.OrdinalIgnoreCase))
            .ToList();
        report.Count("weitere_sprachspalten", otherLanguages.Count);

        // --- Datenzeilen
        var seen = new Dictionary<string, int>(StringComparer.Ordinal);
        int filledForeign = 0;

        for (int r = 1; r < rows.Count; r++)
        {
            Csv.Row row = rows[r];
            string where = $"{path}:{row.Line}";

            // Eine Leerzeile am Dateiende ist kein Fehler.
            if (row.Fields.Count == 1 && row.Fields[0].Trim().Length == 0)
            {
                continue;
            }

            if (row.Fields.Count != header.Count)
            {
                report.Error("spaltenzahl", where,
                    $"{row.Fields.Count} Spalten statt {header.Count}. Damit landen alle Werte " +
                    "in den falschen Spalten.");
                continue;
            }

            string key = row.Fields[0].Trim();
            if (key.Length == 0)
            {
                report.Error("schluessel-leer", where,
                    "Zeile ohne Schluessel. Localization::addCsv ueberspringt sie.");
                continue;
            }

            if (seen.TryGetValue(key, out int firstLine))
            {
                report.Error("schluessel-doppelt", where,
                    $"'{key}' steht schon in Zeile {firstLine}. Localization::addCsv verwirft " +
                    "den zweiten Eintrag stillschweigend.");
            }
            else
            {
                seen[key] = row.Line;
            }

            if (prefix is not null && !key.StartsWith(prefix, StringComparison.Ordinal)
                                   && !allowed.Contains(key))
            {
                report.Error("schluessel-ohne-praefix", where,
                    $"'{key}' hat kein '{prefix}' am Anfang. Bewusste Vanilla-Ueberschreibungen " +
                    "gehoeren in die Datei hinter --vanilla-keys.");
            }

            foreach ((string name, int column) in requiredIndexes)
            {
                if (row.Fields[column].Trim().Length == 0)
                {
                    report.Error("pflichtsprache-leer", where,
                        $"'{key}': Spalte '{name}' ist leer (D7 verlangt sie).");
                }
            }

            foreach ((string name, int column) in otherLanguages)
            {
                if (row.Fields[column].Trim().Length > 0)
                {
                    filledForeign++;
                    report.Hint("fremdsprache-gefuellt", where,
                        $"'{key}': Spalte '{name}' ist gefuellt. D7 sagt, weitere Sprachen leer " +
                        "lassen statt mit Englisch zu fuellen - kein Fehler, nur ein Hinweis.");
                }
            }
        }

        report.Count("schluessel", seen.Count);
        report.Count("gefuellte_fremdsprachen_zellen", filledForeign);

        return report.Write(asJson);
    }
}
