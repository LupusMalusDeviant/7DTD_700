namespace Mod700.Check;

/// <summary>
/// mod700check — die drei Pruefwerkzeuge aus Vertrag 04.
///
/// Exit-Code: 0 gruen, 1 rot, 2 Benutzungsfehler. Der Unterschied ist wichtig: ein
/// Benutzungsfehler ist kein Befund, und ein Lauf, der nicht stattgefunden hat, darf nicht
/// als gruen gelten.
/// </summary>
internal static class Program
{
    private static int Main(string[] args)
    {
        try
        {
            if (args.Length == 0 || args[0] is "-h" or "--help" or "help")
            {
                Usage();
                return args.Length == 0 ? 2 : 0;
            }

            string command = args[0];
            if (args.Length < 2)
            {
                throw new UsageException($"Dem Befehl '{command}' fehlt der Pfad.");
            }

            string path = args[1];
            string[] rest = args[2..];

            return command switch
            {
                "anachronisms" => AnachronismCheck.Run(path, rest),
                "recipes" => RecipeCheck.Run(path, rest),
                "localization" => LocalizationCheck.Run(path, rest),
                _ => throw new UsageException($"Unbekannter Befehl: {command}")
            };
        }
        catch (UsageException e)
        {
            Console.Error.WriteLine($"mod700check: {e.Message}");
            Console.Error.WriteLine("'mod700check --help' zeigt die Benutzung.");
            return 2;
        }
        catch (Exception e)
        {
            // Ein Absturz ist kein „rot": er bedeutet, dass nicht geprueft wurde.
            Console.Error.WriteLine($"mod700check: Pruefung abgebrochen: {e.GetType().Name}: {e.Message}");
            return 2;
        }
    }

    private static void Usage()
    {
        Console.WriteLine(
            """
            mod700check — Pruefwerkzeuge fuer 7DTD_700 (Vertrag 04)

              mod700check anachronisms <ordner> [--denylist <datei>] [--json]
              mod700check recipes      <ordner> [--from <kennung>] [--json]
              mod700check localization <datei>  [--sprachen english,german]
                                               [--prefix 700_] [--vanilla-keys <datei>] [--json]

            <ordner> ist ein ConfigsDump des Spiels (gemergt, gilt als Nachweis) oder ein
            Data/Config der Installation (Vanilla, nur Vorlauf). Welches von beiden es ist,
            erkennt das Werkzeug am Inhalt und schreibt es in jede Ausgabe.

            Den ConfigsDump legt das Spiel bei jedem Start selbst an, unter
              %APPDATA%\\7DaysToDie\\Saves\\<Welt>\\<Spielstand>\\ConfigsDump\\

            Exit-Code: 0 gruen, 1 rot, 2 Benutzungsfehler.
            """);
    }
}
