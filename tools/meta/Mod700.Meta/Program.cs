// mod700meta — statischer Metadaten-Leser für 7DTD_700.
//
// Liest eine managed PE-Datei ausschließlich über System.Reflection.Metadata.
// Die Assembly wird NICHT geladen, NICHT ausgeführt und NICHT dekompiliert.
// Es werden nur Metadaten gelesen und IL-Bytes nach Aufruf-Tokens durchlaufen.
//
// Hintergrund: REA (rea-agents) bricht an der Assembly-CSharp.dll von 7DTD V2.x mit
// "Managed metadata exceeds the 67108864 byte representation budget" ab und liefert
// keine Member und keine Signaturen. Siehe docs/rea/findings/00-rea-grenzen.md.
//
// Befehle:
//   types   <dll> [--contains <text>] [--max <n>]      Typ-Inventar, optional gefiltert
//   members <dll> --type <FullName> [--type ...] [--callers]
//   verify  <dll> --expect <datei.tsv>                 Soll-Signaturen prüfen, Exit 1 bei Abweichung
//
// Ausgabe: JSON auf stdout. Jede Ausgabe nennt SHA-256 und MVID des Artefakts,
// damit ein Befund an genau einen Build gebunden bleibt.

using System.Collections.Immutable;
using System.Reflection;
using System.Reflection.Emit;
using System.Reflection.Metadata;
using System.Reflection.Metadata.Ecma335;
using System.Reflection.PortableExecutable;
using System.Security.Cryptography;
using System.Text.Json;

namespace Mod700.Meta;

internal static class Program
{
    private static int Main(string[] args)
    {
        try
        {
            if (args.Length == 0) { Usage(); return 2; }

            string command = args[0];
            if (command is "-h" or "--help" or "help") { Usage(); return 0; }
            if (args.Length < 2) { Usage(); return 2; }

            string path = Path.GetFullPath(args[1]);
            if (!File.Exists(path))
            {
                Console.Error.WriteLine($"error: Datei nicht gefunden: {path}");
                return 2;
            }

            var rest = args.Skip(2).ToArray();
            return command switch
            {
                "types" => CmdTypes(path, rest),
                "members" => CmdMembers(path, rest),
                "verify" => CmdVerify(path, rest),
                _ => Fail($"unbekannter Befehl: {command}")
            };
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"error: {ex.GetType().Name}: {ex.Message}");
            return 3;
        }
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine($"error: {message}");
        Usage();
        return 2;
    }

    private static void Usage()
    {
        Console.Error.WriteLine(
            """
            mod700meta — statischer Metadaten-Leser (liest nur Metadaten, lädt nichts)

              types   <dll> [--contains <text>] [--max <n>]
              members <dll> --type <FullName> [--type <FullName> ...] [--callers]
              verify  <dll> --expect <datei.tsv>

            verify erwartet Zeilen "Typ<TAB>Member<TAB>Signatur" und endet mit Exit 1,
            sobald eine Soll-Signatur im Build fehlt oder abweicht.
            """);
    }

    // ---------------------------------------------------------------- Identität

    private sealed record Identity(string Path, string Sha256, string? Mvid, long ByteLength);

    private static Identity ReadIdentity(string path, MetadataReader reader)
    {
        using var stream = File.OpenRead(path);
        string sha = Convert.ToHexStringLower(SHA256.HashData(stream));

        string? mvid = null;
        if (!reader.GetModuleDefinition().Mvid.IsNil)
        {
            mvid = reader.GetGuid(reader.GetModuleDefinition().Mvid).ToString();
        }

        return new Identity(path, sha, mvid, new FileInfo(path).Length);
    }

    private static void Emit(object payload)
    {
        Console.WriteLine(JsonSerializer.Serialize(payload, new JsonSerializerOptions
        {
            WriteIndented = true
        }));
    }

    // ------------------------------------------------------------------- types

    private static int CmdTypes(string path, string[] args)
    {
        string? contains = null;
        int max = 500;
        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--contains" when i + 1 < args.Length: contains = args[++i]; break;
                case "--max" when i + 1 < args.Length: max = int.Parse(args[++i]); break;
                default: return Fail($"unbekannte Option für types: {args[i]}");
            }
        }

        using var pe = new PEReader(File.OpenRead(path));
        var reader = pe.GetMetadataReader();
        var identity = ReadIdentity(path, reader);

        var rows = new List<object>();
        int matched = 0;

        foreach (var handle in reader.TypeDefinitions)
        {
            var td = reader.GetTypeDefinition(handle);
            string full = Naming.TypeDefFullName(reader, handle);

            if (contains is not null && !full.Contains(contains, StringComparison.OrdinalIgnoreCase))
            {
                continue;
            }

            matched++;
            if (rows.Count >= max) continue;

            string? baseName = td.BaseType.IsNil ? null : Naming.EntityFullName(reader, td.BaseType);
            var interfaces = td.GetInterfaceImplementations()
                .Select(h => Naming.EntityFullName(reader, reader.GetInterfaceImplementation(h).Interface))
                .ToArray();

            rows.Add(new
            {
                full_name = full,
                token = $"0x{MetadataTokens.GetToken(handle):x8}",
                attributes = td.Attributes.ToString(),
                is_interface = (td.Attributes & TypeAttributes.Interface) != 0,
                is_abstract = (td.Attributes & TypeAttributes.Abstract) != 0,
                is_sealed = (td.Attributes & TypeAttributes.Sealed) != 0,
                base_type = baseName,
                interfaces,
                method_count = td.GetMethods().Count,
                field_count = td.GetFields().Count,
                property_count = td.GetProperties().Count
            });
        }

        Emit(new
        {
            tool = "mod700meta",
            command = "types",
            artifact = identity,
            selection = new { contains, max },
            counts = new
            {
                type_defs_total = reader.TypeDefinitions.Count,
                matched,
                returned = rows.Count,
                truncated = matched > rows.Count
            },
            types = rows,
            method = "Nur Metadaten gelesen. Die Assembly wurde nicht geladen, nicht ausgeführt und nicht dekompiliert."
        });
        return 0;
    }

    // ----------------------------------------------------------------- members

    private static int CmdMembers(string path, string[] args)
    {
        var wanted = new List<string>();
        bool withCallers = false;
        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--type" when i + 1 < args.Length: wanted.Add(args[++i]); break;
                case "--callers": withCallers = true; break;
                default: return Fail($"unbekannte Option für members: {args[i]}");
            }
        }

        if (wanted.Count == 0) return Fail("members braucht mindestens ein --type");

        using var pe = new PEReader(File.OpenRead(path));
        var reader = pe.GetMetadataReader();
        var identity = ReadIdentity(path, reader);
        var provider = new TypeNameProvider();

        var index = new Dictionary<string, TypeDefinitionHandle>(StringComparer.Ordinal);
        foreach (var handle in reader.TypeDefinitions)
        {
            index[Naming.TypeDefFullName(reader, handle)] = handle;
        }

        var unmatched = wanted.Where(w => !index.ContainsKey(w)).ToArray();
        var selected = wanted.Where(index.ContainsKey).ToArray();

        // Tokens der ausgewählten Methoden, für die Aufrufer-Suche.
        var targetMethods = new Dictionary<int, string>();

        var typeRows = new List<object>();
        foreach (string name in selected)
        {
            var handle = index[name];
            var td = reader.GetTypeDefinition(handle);

            var methods = new List<object>();
            foreach (var mh in td.GetMethods())
            {
                var md = reader.GetMethodDefinition(mh);
                var sig = md.DecodeSignature(provider, null);
                string methodName = reader.GetString(md.Name);
                string signature = Naming.MethodSignature(name, methodName, md.Attributes, sig);

                var edges = Il.ReadEdges(pe, reader, md, provider);

                targetMethods[MetadataTokens.GetToken(mh)] = $"{name}::{methodName}";

                methods.Add(new
                {
                    name = methodName,
                    signature,
                    token = $"0x{MetadataTokens.GetToken(mh):x8}",
                    attributes = md.Attributes.ToString(),
                    is_static = (md.Attributes & MethodAttributes.Static) != 0,
                    is_virtual = (md.Attributes & MethodAttributes.Virtual) != 0,
                    is_abstract = (md.Attributes & MethodAttributes.Abstract) != 0,
                    has_body = md.RelativeVirtualAddress != 0,
                    return_type = sig.ReturnType,
                    parameters = sig.ParameterTypes.ToArray(),
                    generic_parameter_count = sig.GenericParameterCount,
                    calls = edges.Calls,
                    field_accesses = edges.FieldAccesses,
                    string_literals = edges.Strings
                });
            }

            var fields = new List<object>();
            foreach (var fh in td.GetFields())
            {
                var fd = reader.GetFieldDefinition(fh);
                fields.Add(new
                {
                    name = reader.GetString(fd.Name),
                    type = fd.DecodeSignature(provider, null),
                    token = $"0x{MetadataTokens.GetToken(fh):x8}",
                    attributes = fd.Attributes.ToString(),
                    is_static = (fd.Attributes & FieldAttributes.Static) != 0
                });
            }

            typeRows.Add(new
            {
                full_name = name,
                token = $"0x{MetadataTokens.GetToken(handle):x8}",
                attributes = td.Attributes.ToString(),
                base_type = td.BaseType.IsNil ? null : Naming.EntityFullName(reader, td.BaseType),
                interfaces = td.GetInterfaceImplementations()
                    .Select(h => Naming.EntityFullName(reader, reader.GetInterfaceImplementation(h).Interface))
                    .ToArray(),
                methods,
                fields
            });
        }

        object? callers = null;
        if (withCallers && targetMethods.Count > 0)
        {
            callers = FindCallers(pe, reader, targetMethods);
        }

        Emit(new
        {
            tool = "mod700meta",
            command = "members",
            artifact = identity,
            selection = new { requested = wanted, matched = selected, unmatched_type_names = unmatched },
            types = typeRows,
            incoming_calls = callers,
            method = "Nur Metadaten und IL-Aufruf-Tokens gelesen. Die Assembly wurde nicht geladen, nicht ausgeführt und nicht dekompiliert.",
            limitations = new[]
            {
                "Aufrufer über Reflection, Unity-Messages (Update, Awake) und Delegaten tauchen hier nicht auf.",
                "Server/Client-Zuordnung ist daraus nur ein Indiz und braucht den Dedicated-Test.",
                "Metadaten-Tokens gelten nur für genau diesen SHA-256 und diese MVID."
            }
        });
        return 0;
    }

    /// <summary>Durchläuft jeden Methodenkörper der Assembly und sammelt Aufrufe auf die Zielmethoden.</summary>
    private static object FindCallers(PEReader pe, MetadataReader reader, Dictionary<int, string> targets)
    {
        var hits = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        int scanned = 0;

        foreach (var mh in reader.MethodDefinitions)
        {
            var md = reader.GetMethodDefinition(mh);
            if (md.RelativeVirtualAddress == 0) continue;

            byte[] il;
            try { il = pe.GetMethodBody(md.RelativeVirtualAddress).GetILBytes() ?? []; }
            catch (BadImageFormatException) { continue; }
            if (il.Length == 0) continue;

            scanned++;
            string? callerName = null;

            foreach (var (opcode, operandToken) in Il.Walk(il))
            {
                if (operandToken == 0) continue;
                if (opcode is not ("call" or "callvirt" or "newobj" or "ldftn" or "ldvirtftn" or "jmp")) continue;
                if (!targets.TryGetValue(operandToken, out string? target)) continue;

                callerName ??= $"{Naming.TypeDefFullName(reader, md.GetDeclaringType())}::{reader.GetString(md.Name)}";
                if (!hits.TryGetValue(target, out var list)) hits[target] = list = [];
                if (!list.Contains(callerName)) list.Add(callerName);
            }
        }

        return new
        {
            scanned_method_bodies = scanned,
            by_target = hits.ToDictionary(k => k.Key, v => v.Value.OrderBy(x => x, StringComparer.Ordinal).ToArray())
        };
    }

    // ------------------------------------------------------------------ verify

    private static int CmdVerify(string path, string[] args)
    {
        string? expectPath = null;
        for (int i = 0; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--expect" when i + 1 < args.Length: expectPath = args[++i]; break;
                default: return Fail($"unbekannte Option für verify: {args[i]}");
            }
        }

        if (expectPath is null) return Fail("verify braucht --expect <datei.tsv>");
        if (!File.Exists(expectPath)) { Console.Error.WriteLine($"error: Soll-Datei fehlt: {expectPath}"); return 2; }

        using var pe = new PEReader(File.OpenRead(path));
        var reader = pe.GetMetadataReader();
        var identity = ReadIdentity(path, reader);
        var provider = new TypeNameProvider();

        // Ist-Zustand: alle Signaturen je Typ.
        var actual = new Dictionary<string, HashSet<string>>(StringComparer.Ordinal);
        foreach (var handle in reader.TypeDefinitions)
        {
            string full = Naming.TypeDefFullName(reader, handle);
            var set = new HashSet<string>(StringComparer.Ordinal);
            foreach (var mh in reader.GetTypeDefinition(handle).GetMethods())
            {
                var md = reader.GetMethodDefinition(mh);
                set.Add(Naming.MethodSignature(full, reader.GetString(md.Name), md.Attributes,
                    md.DecodeSignature(provider, null)));
            }
            actual[full] = set;
        }

        var results = new List<object>();
        int failed = 0;

        foreach (string raw in File.ReadLines(expectPath))
        {
            string line = raw.Trim();
            if (line.Length == 0 || line.StartsWith('#')) continue;

            var parts = line.Split('\t');
            if (parts.Length < 3)
            {
                failed++;
                results.Add(new { line, verdict = "malformed", detail = "erwartet: Typ<TAB>Member<TAB>Signatur" });
                continue;
            }

            string type = parts[0].Trim(), member = parts[1].Trim(), expected = parts[2].Trim();

            if (!actual.TryGetValue(type, out var signatures))
            {
                failed++;
                results.Add(new { type, member, expected, verdict = "type-missing", detail = "Typ existiert in diesem Build nicht" });
                continue;
            }

            if (signatures.Contains(expected))
            {
                results.Add(new { type, member, expected, verdict = "ok", detail = (string?)null });
                continue;
            }

            failed++;
            var near = signatures.Where(s => s.Contains($"::{member}(", StringComparison.Ordinal)).OrderBy(s => s, StringComparer.Ordinal).ToArray();
            results.Add(new
            {
                type,
                member,
                expected,
                verdict = near.Length == 0 ? "member-missing" : "signature-changed",
                detail = near.Length == 0
                    ? $"kein Member namens {member} in {type}"
                    : "Signatur abweichend; vorhanden: " + string.Join(" | ", near)
            });
        }

        Emit(new
        {
            tool = "mod700meta",
            command = "verify",
            artifact = identity,
            expect_file = Path.GetFullPath(expectPath),
            summary = new { checked_rows = results.Count, failed, verdict = failed == 0 ? "green" : "red" },
            results
        });

        return failed == 0 ? 0 : 1;
    }
}
