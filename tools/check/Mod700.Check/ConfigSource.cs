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
            : new ConfigSource(path, "configs-dump", timestamp,
                "gemergte Config des Spiels - gilt als Nachweis");
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
