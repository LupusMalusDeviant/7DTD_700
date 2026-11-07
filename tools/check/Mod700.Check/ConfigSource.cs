using System.Xml;
using System.Xml.Linq;

namespace Mod700.Check;

/// <summary>
/// Ein Ordner mit Config-XML: entweder ein ConfigsDump des Spiels (die gemergte Fassung,
/// Nachweis) oder ein Data/Config der Installation (Vanilla, Vorlauf).
/// Unterschieden wird am Inhalt, nicht am Pfad — und das Ergebnis steht in jeder Ausgabe,
/// damit ein Vorlauf nicht als Nachweis durchgeht (Vertrag 04, Abschnitt 1).
/// </summary>
internal sealed class ConfigSource
{
    private readonly Dictionary<string, XDocument?> _cache = new(StringComparer.OrdinalIgnoreCase);

    private ConfigSource(string path, string kind, string? timestamp, string note)
    {
        Path = path;
        Info = new SourceInfo(path, kind, timestamp, note);
    }

    /// <summary>
    /// Eine Quelle, in der einzelne Dateien durch gepatchte Fassungen im Speicher ersetzt
    /// sind. Dafuer, dass <see cref="Reachability"/> und <see cref="Definitions"/>
    /// unveraendert auf dem Ergebnis eines Patch-Satzes rechnen koennen - ohne eine zweite
    /// Fassung derselben Fragen. Zwei Implementierungen derselben Frage sind zwei
    /// Gelegenheiten, verschiedene Antworten zu geben; das ist in dieser Arbeit dreimal
    /// passiert.
    ///
    /// <para>Die Art bleibt die der Ursprungsquelle, der Vermerk sagt aber ausdruecklich,
    /// dass hier gerechnet und nicht gemessen wurde. Ein Patch-Satz, den ich selbst
    /// angewandt habe, ist kein Spielstart.</para>
    /// </summary>
    public static ConfigSource Patched(
        ConfigSource original, IReadOnlyDictionary<string, XDocument> replacements)
    {
        var patched = new ConfigSource(original.Path, original.Info.Kind, original.Info.Timestamp,
            original.Info.Note + " | gepatcht im Speicher - gerechnet, nicht gemessen");

        foreach ((string name, XDocument document) in replacements)
        {
            patched._cache[name] = document;
        }

        return patched;
    }

    public string Path { get; }

    public SourceInfo Info { get; }

    public bool IsMerged => Info.Kind == "configs-dump";

    public static ConfigSource Open(string path)
    {
        if (!Directory.Exists(path))
        {
            throw new UsageException($"Kein Ordner: {path}");
        }

        string items = System.IO.Path.Combine(path, "items.xml");
        if (!File.Exists(items))
        {
            throw new UsageException(
                $"In {path} liegt keine items.xml. Erwartet wird ein ConfigsDump oder ein Data/Config.");
        }

        // Unterscheidungsmerkmal: Localization.csv liegt in Data/Config, aber NICHT im
        // ConfigsDump — nachgesehen am 2026-11-07 an einem echten Dump (43 Dateien, keine
        // Localization.csv). Darum ist ihre Anwesenheit das Kennzeichen fuer Vanilla.
        bool hasLocalization = File.Exists(System.IO.Path.Combine(path, "Localization.csv"));
        string timestamp = Directory.GetLastWriteTimeUtc(path).ToString("yyyy-MM-dd HH:mm:ss'Z'");

        return hasLocalization
            ? new ConfigSource(path, "vanilla-config", timestamp,
                "Vanilla ohne Modlets - Vorlauf, kein Nachweis")
            // Frueher stand hier "gilt als Nachweis". Das war zu viel behauptet: ein Dump
            // sagt nicht, welche Modlets beim Start geladen waren, und ein Dump VOR unseren
            // Modlets ist ein Vorlauf wie jeder andere. Das Werkzeug kann das nicht wissen,
            // also soll es es auch nicht behaupten.
            : new ConfigSource(path, "configs-dump", timestamp,
                "gemergte Config des Spiels - Nachweis nur, wenn unsere Modlets dabei "
                + "geladen waren; sonst Vorlauf");
    }

    /// <summary>
    /// Laedt eine Datei des Ordners. Fehlt sie, kommt <c>null</c> zurueck: ein ConfigsDump
    /// enthaelt nicht zwingend alle 52 Dateien, und das ist kein Fehler.
    /// </summary>
    public XDocument? Load(string fileName)
    {
        if (_cache.TryGetValue(fileName, out XDocument? cached))
        {
            return cached;
        }

        string full = System.IO.Path.Combine(Path, fileName);
        XDocument? document = null;
        if (File.Exists(full))
        {
            document = XDocument.Load(full, LoadOptions.SetLineInfo);
        }

        _cache[fileName] = document;
        return document;
    }

    /// <summary>Alle Werte eines Attributs unter einem Elementnamen, ueber eine Datei hinweg.</summary>
    public IEnumerable<(string Value, int Line)> Attributes(string fileName, string element, string attribute)
    {
        XDocument? document = Load(fileName);
        if (document is null)
        {
            yield break;
        }

        foreach (XElement e in document.Descendants(element))
        {
            string? value = e.Attribute(attribute)?.Value;
            if (!string.IsNullOrWhiteSpace(value))
            {
                yield return (value, (e as IXmlLineInfo).LineNumber);
            }
        }
    }
}

/// <summary>Falsche Benutzung des Werkzeugs. Fuehrt zu Exit-Code 2, nicht zu „rot".</summary>
internal sealed class UsageException : Exception
{
    public UsageException(string message) : base(message)
    {
    }
}
