using System.Text;

namespace Mod700.Check;

/// <summary>
/// Minimaler CSV-Leser fuer Localization.csv. Keine Bibliothek, aber auch kein
/// String.Split: die Datei enthaelt Felder in Anfuehrungszeichen, und darin stehen
/// Kommas und Zeilenumbrueche. Ein Split waere stillschweigend falsch.
/// </summary>
internal static class Csv
{
    /// <summary>Eine Zeile mit ihrer Nummer in der Datei (1-basiert, wie ein Editor sie zeigt).</summary>
    public sealed record Row(int Line, List<string> Fields);

    public static List<Row> Read(string path)
    {
        string text = File.ReadAllText(path, new UTF8Encoding(false));
        var rows = new List<Row>();
        var fields = new List<string>();
        var field = new StringBuilder();

        bool inQuotes = false;
        int line = 1;
        int rowStartLine = 1;

        for (int i = 0; i < text.Length; i++)
        {
            char c = text[i];

            if (inQuotes)
            {
                if (c == '"')
                {
                    // Zwei Anfuehrungszeichen hintereinander sind ein woertliches Zeichen.
                    if (i + 1 < text.Length && text[i + 1] == '"')
                    {
                        field.Append('"');
                        i++;
                    }
                    else
                    {
                        inQuotes = false;
                    }
                }
                else
                {
                    if (c == '\n')
                    {
                        line++;
                    }

                    field.Append(c);
                }

                continue;
            }

            switch (c)
            {
                case '"':
                    inQuotes = true;
                    break;

                case ',':
                    fields.Add(field.ToString());
                    field.Clear();
                    break;

                case '\r':
                    break;

                case '\n':
                    fields.Add(field.ToString());
                    field.Clear();
                    rows.Add(new Row(rowStartLine, new List<string>(fields)));
                    fields.Clear();
                    line++;
                    rowStartLine = line;
                    break;

                default:
                    field.Append(c);
                    break;
            }
        }

        // Letzte Zeile ohne abschliessenden Umbruch.
        if (field.Length > 0 || fields.Count > 0)
        {
            fields.Add(field.ToString());
            rows.Add(new Row(rowStartLine, new List<string>(fields)));
        }

        // Ein BOM am Dateianfang gehoert nicht zum ersten Spaltennamen.
        if (rows.Count > 0 && rows[0].Fields.Count > 0)
        {
            rows[0].Fields[0] = rows[0].Fields[0].TrimStart('﻿');
        }

        return rows;
    }
}
