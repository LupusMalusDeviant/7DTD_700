using System.Text;

namespace Mod700.Check;

/// <summary>
/// Minimaler CSV-Leser fuer Localization.csv. Keine Bibliothek, aber auch kein
/// String.Split: die Datei enthaelt Felder in Anfuehrungszeichen, und darin stehen
/// Kommas und Zeilenumbrueche. Ein Split waere stillschweigend falsch.
///
/// Der Leser ist NACHSICHTIG beim Lesen und STRENG beim Melden (seit 2026-11-20). Er liest
/// eine kaputte Zeile so weit wie moeglich weiter, damit Spaltenzahl und Schluessel
/// pruefbar bleiben - und schreibt jede Stelle, an der die Anfuehrung nicht stimmt, in
/// <c>problems</c>. Vorher nahm er ein Anfuehrungszeichen mitten in einem Feld still hin:
/// <c>Scrap of "Parchment"</c> behielt die richtige Spaltenzahl, und die Pruefung war gruen
/// (Review-Befund). Was das Spiel aus so einer Zeile macht, ist nicht gelesen; eine Datei,
/// die wir schreiben, soll sich darauf nicht verlassen.
/// </summary>
internal static class Csv
{
    /// <summary>Eine Zeile mit ihrer Nummer in der Datei (1-basiert, wie ein Editor sie zeigt).</summary>
    public sealed record Row(int Line, List<string> Fields);

    /// <summary>Eine Stelle, an der die Anfuehrung nicht stimmt.</summary>
    public sealed record Problem(int Line, string Text);

    public static List<Row> Read(string path) => Read(path, new List<Problem>());

    public static List<Row> Read(string path, List<Problem> problems)
    {
        string text = File.ReadAllText(path, new UTF8Encoding(false));
        var rows = new List<Row>();
        var fields = new List<string>();
        var field = new StringBuilder();

        bool inQuotes = false;

        // Wahr, sobald in diesem Feld ein Anfuehrungs-Abschnitt geschlossen wurde. Danach
        // darf bis zum naechsten Komma oder Zeilenende nichts mehr kommen.
        bool afterQuote = false;

        int line = 1;
        int rowStartLine = 1;
        int quoteOpenedLine = 1;

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
                        afterQuote = true;
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
                    // Ein Feld in Anfuehrung FAENGT mit dem Zeichen an. Steht davor schon
                    // etwas, oder wurde in diesem Feld schon ein Abschnitt geschlossen, ist
                    // die Zeile kein gueltiges CSV.
                    if (field.Length > 0 || afterQuote)
                    {
                        problems.Add(new Problem(line,
                            "Anfuehrungszeichen mitten im Feld. Ein Feld steht ganz in " +
                            "Anfuehrungszeichen oder gar nicht; ein woertliches Zeichen wird " +
                            "in einem Feld in Anfuehrung verdoppelt (\"\")."));
                    }

                    inQuotes = true;
                    quoteOpenedLine = line;
                    break;

                case ',':
                    fields.Add(field.ToString());
                    field.Clear();
                    afterQuote = false;
                    break;

                case '\r':
                    break;

                case '\n':
                    fields.Add(field.ToString());
                    field.Clear();
                    afterQuote = false;
                    rows.Add(new Row(rowStartLine, new List<string>(fields)));
                    fields.Clear();
                    line++;
                    rowStartLine = line;
                    break;

                default:
                    if (afterQuote)
                    {
                        problems.Add(new Problem(line,
                            $"Zeichen '{c}' nach dem schliessenden Anfuehrungszeichen. Dahinter " +
                            "darf nur ein Komma oder das Zeilenende stehen."));

                        // Einmal je Feld reicht; der Rest des Feldes ist dieselbe Stelle.
                        afterQuote = false;
                    }

                    field.Append(c);
                    break;
            }
        }

        if (inQuotes)
        {
            problems.Add(new Problem(quoteOpenedLine,
                "Anfuehrungszeichen nicht geschlossen: das Feld laeuft bis zum Dateiende. " +
                "Alle Zeilen danach sind in dieses Feld geraten."));
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
