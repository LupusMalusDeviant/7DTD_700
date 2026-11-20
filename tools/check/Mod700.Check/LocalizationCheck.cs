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

        // Mehrere Praefixe, nicht eines. Vertrag 02 §2 gibt je Art ein eigenes Praefix
        // (itm700_, blk700_, buff700_ ...), und der Sprachschluessel eines Gegenstands IST
        // seine Kennung - es gibt in 7DTD keine Eigenschaft, mit der ein Gegenstand auf
        // einen anderen Namensschluessel zeigen koennte. Mit einem einzelnen '700_' waere
        // jeder eigene Gegenstand rot, und der Ausweg waere, ihn in vanilla-keys.txt zu
        // schreiben: eine Freigabe fuer etwas, das gar kein Vanilla ist, und damit eine
        // Luege in genau der Datei, die die Ausnahmen aufzaehlt.
        List<string>? prefixes = null;
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
                    prefixes = args[++i]
                        .Split(',', StringSplitOptions.RemoveEmptyEntries |
                                    StringSplitOptions.TrimEntries)
                        .ToList();
                    if (prefixes.Count == 0)
                    {
                        throw new UsageException(
                            "--prefix braucht mindestens ein Praefix, etwa '700_' oder " +
                            "'700_,itm700_,blk700_'.");
                    }

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

            // Nachgestellte Kommentare abschneiden - genau wie Denylist, Deferrals und
            // RecipeCheck es tun. Ohne das wurde aus "casinoCoin  # Silberpfennig" ein
            // Schluessel samt Grund, der nie passt; die Pruefung blieb rot und wies auf eine
            // Datei, in der der Schluessel sichtbar dastand. Der Grund gehoert neben die
            // Zeile, also muss der Leser ihn vertragen.
            foreach (string raw in File.ReadAllLines(allowFile))
            {
                int comment = raw.IndexOf('#');
                string key = (comment >= 0 ? raw[..comment] : raw).Trim();
                if (key.Length > 0)
                {
                    allowed.Add(key);
                }
            }
        }

        var source = new SourceInfo(
            path,
            "localization-csv",
            File.GetLastWriteTimeUtc(path).ToString("yyyy-MM-dd HH:mm:ss'Z'"),
            prefixes is null
                ? "Praefix-Pruefung aus (kein --prefix)"
                : $"Praefix-Pruefung auf {string.Join(", ", prefixes.Select(p => $"'{p}'"))}");
        var report = new Report("localization", source);

        report.Limitation(
            "Geprueft wird die Form, nicht der Inhalt: ob eine Uebersetzung richtig oder " +
            "verstaendlich ist, kann dieses Werkzeug nicht sagen.");
        report.Limitation(
            "Localization.csv liegt NICHT im ConfigsDump des Spiels. Geprueft wird also immer " +
            "eine Quelldatei, nie die gemergte Fassung - doppelte Schluessel ueber zwei Modlets " +
            "hinweg findet dieser Lauf nur, wenn beide Dateien zusammen geprueft werden.");

        var csvProblems = new List<Csv.Problem>();
        List<Csv.Row> rows = Csv.Read(path, csvProblems);
        if (rows.Count == 0)
        {
            report.Error("leere-datei", path, "Die Datei hat keine Zeilen.");
            return report.Write(asJson);
        }

        // Kaputte Anfuehrung zuerst: eine Zeile, die kein gueltiges CSV ist, kann alle
        // anderen Pruefungen bestehen und trotzdem falsch im Spiel ankommen.
        report.Count("csv_form_fehler", csvProblems.Count);
        foreach (Csv.Problem problem in csvProblems)
        {
            report.Error("csv-form", $"{path}:{problem.Line}", problem.Text);
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

            if (prefixes is not null
                && !prefixes.Any(p => key.StartsWith(p, StringComparison.Ordinal))
                && !allowed.Contains(key))
            {
                report.Error("schluessel-ohne-praefix", where,
                    $"'{key}' faengt mit keinem der erwarteten Praefixe an " +
                    $"({string.Join(", ", prefixes)}). Bewusste Vanilla-Ueberschreibungen " +
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

        // Eine Liste bewusster Vanilla-Ueberschreibungen ist eine Abschaltung der
        // Praefix-Pruefung. Ein Eintrag, zu dem es keine Zeile gibt, schaltet sie fuer einen
        // Schluessel ab, den niemand setzt - und bleibt stehen, wenn eine Uebersetzung
        // spaeter geloescht oder umbenannt wird. Darum wird er genannt.
        if (allowFile is not null)
        {
            report.Count("vanilla_schluessel_erlaubt", allowed.Count);
            var unusedAllowed = allowed
                .Where(k => !seen.ContainsKey(k))
                .OrderBy(k => k, StringComparer.Ordinal)
                .ToList();
            report.Count("vanilla_schluessel_ohne_zeile", unusedAllowed.Count);

            foreach (string key in unusedAllowed)
            {
                report.Hint("vanilla-schluessel-ohne-zeile", allowFile,
                    $"'{key}' steht als bewusste Vanilla-Ueberschreibung in der Liste, aber " +
                    "diese CSV setzt ihn nicht. Entweder fehlt die Zeile oder der Eintrag ist " +
                    "uebrig.");
            }
        }

        return report.Write(asJson);
    }
}
