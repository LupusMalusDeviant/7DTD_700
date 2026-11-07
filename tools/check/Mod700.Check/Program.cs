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
                "ungeprueft" => UncheckedList.Run(path, rest),
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
                                               [--no-extends] [--ohne-regel <kennung>]
              mod700check recipes      <ordner> [--from <kennung>] [--json]
              mod700check localization <datei>  [--sprachen english,german]
                                               [--prefix 700_] [--vanilla-keys <datei>] [--json]
              mod700check ungeprueft   <ordner> [--denylist <datei>] [--praefix <anfang>]
                                               [--nur-zahlen]

            'ungeprueft' ist KEIN Pruefbefehl: es listet die erreichbaren Kennungen, ueber
            die keine Regel geurteilt hat, samt ihren Eigenschaften, und endet immer mit 0.
            Gedacht fuer die Sichtung - es liest mit demselben Code wie die Pruefung, damit
            die Liste genau das zeigt, was die Pruefung auch sieht.

            anachronisms urteilt zuerst nach Eigenschaften, die Vanilla selbst fuehrt (Tags,
            Block-Klasse, eigene Group), und erst dann nach Namensmustern aus der Denylist.
            Der Bericht weist beide Zahlen getrennt aus; 'verboten_nach_name' sagt, wie viel
            noch am Gedaechtnis des Autors haengt, und soll fallen. Die Regeln heissen:
              schusswaffe, patronenmunition, entwicklergegenstand, strom, elektrikerhandwerk

            --no-extends und --ohne-regel sind GEGENPROBEN, kein Nachweis: sie schalten die
            Vererbung bzw. eine Regel ab, damit sichtbar wird, dass sie wirklich etwas
            beitragen. Beide Laeufe sagen das in ihren Grenzen auch selbst.

            <ordner> ist ein ConfigsDump des Spiels (gemergt) oder ein Data/Config der
            Installation (Vanilla, Vorlauf). Welches von beiden es ist, erkennt das Werkzeug
            am Inhalt und schreibt es in jede Ausgabe. Ein Dump ist nur dann ein Nachweis,
            wenn unsere Modlets beim Spielstart geladen waren - das kann das Werkzeug nicht
            wissen und behauptet es darum nicht.

            Den ConfigsDump legt das Spiel bei jedem Start selbst an, unter
              %APPDATA%\\7DaysToDie\\Saves\\<Welt>\\<Spielstand>\\ConfigsDump\\

            Exit-Code: 0 gruen, 1 rot, 2 Benutzungsfehler.
            """);
    }
}
