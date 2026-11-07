// Minimaler IL-Durchlauf: nur so viel, wie zum Auffinden von Aufruf- und
// Feldzugriff-Tokens nötig ist. Es wird nichts ausgeführt und nichts dekompiliert.
//
// Die Operandenlängen kommen aus System.Reflection.Emit.OpCodes, damit hier keine
// handgepflegte Opcode-Tabelle veralten kann.

using System.Buffers.Binary;
using System.Reflection;
using System.Reflection.Emit;
using System.Reflection.Metadata;
using System.Reflection.Metadata.Ecma335;
using System.Reflection.PortableExecutable;

namespace Mod700.Meta;

internal static class Il
{
    private static readonly Dictionary<ushort, OpCode> Map = BuildMap();

    private static Dictionary<ushort, OpCode> BuildMap()
    {
        var map = new Dictionary<ushort, OpCode>();
        foreach (var field in typeof(OpCodes).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            if (field.GetValue(null) is OpCode opcode)
            {
                map[unchecked((ushort)opcode.Value)] = opcode;
            }
        }
        return map;
    }

    private static int OperandLength(OperandType type, ReadOnlySpan<byte> tail) => type switch
    {
        OperandType.InlineNone => 0,
        OperandType.ShortInlineBrTarget or OperandType.ShortInlineI or OperandType.ShortInlineVar => 1,
        OperandType.InlineVar => 2,
        OperandType.InlineBrTarget or OperandType.InlineField or OperandType.InlineI
            or OperandType.InlineMethod or OperandType.InlineSig or OperandType.InlineString
            or OperandType.InlineTok or OperandType.InlineType or OperandType.ShortInlineR => 4,
        OperandType.InlineI8 or OperandType.InlineR => 8,
        OperandType.InlineSwitch => tail.Length >= 4
            ? 4 + 4 * BinaryPrimitives.ReadInt32LittleEndian(tail)
            : tail.Length,
        _ => 0
    };

    /// <summary>
    /// Läuft die IL-Bytes ab und gibt je Befehl den Opcode-Namen, das 4-Byte-Metadaten-Token
    /// (sonst 0) und den Zahlenoperanden zurück, wo es einen gibt.
    /// </summary>
    public static IEnumerable<(string Name, int Token, long? Value)> Walk(byte[] il)
    {
        int i = 0;
        while (i < il.Length)
        {
            ushort value = il[i];
            int opcodeSize = 1;
            if (value == 0xFE && i + 1 < il.Length)
            {
                value = (ushort)(0xFE00 | il[i + 1]);
                opcodeSize = 2;
            }

            if (!Map.TryGetValue(value, out var opcode))
            {
                // Unbekanntes Byte: Durchlauf abbrechen, statt Müll zu melden.
                yield break;
            }

            int operandStart = i + opcodeSize;
            if (operandStart > il.Length) yield break;

            var tail = il.AsSpan(operandStart);
            int operandSize = OperandLength(opcode.OperandType, tail);
            if (operandStart + operandSize > il.Length) yield break;

            int token = 0;
            if (operandSize == 4 && opcode.OperandType is OperandType.InlineMethod
                or OperandType.InlineField or OperandType.InlineTok
                or OperandType.InlineType or OperandType.InlineString)
            {
                token = BinaryPrimitives.ReadInt32LittleEndian(tail);
            }

            long? numeric = opcode.OperandType switch
            {
                OperandType.ShortInlineI => (sbyte)tail[0],
                OperandType.InlineI => BinaryPrimitives.ReadInt32LittleEndian(tail),
                OperandType.InlineI8 => BinaryPrimitives.ReadInt64LittleEndian(tail),
                _ => null
            };

            yield return (opcode.Name ?? value.ToString("x4"), token, numeric);
            i = operandStart + operandSize;
        }
    }

    internal sealed record Edges(string[] Calls, string[] FieldAccesses, string[] Strings);

    /// <summary>Aufrufe, Feldzugriffe und geladene Zeichenketten eines Methodenkörpers.</summary>
    public static Edges ReadEdges(PEReader pe, MetadataReader reader, MethodDefinition md, TypeNameProvider provider)
    {
        if (md.RelativeVirtualAddress == 0) return new Edges([], [], []);

        byte[] il;
        try { il = pe.GetMethodBody(md.RelativeVirtualAddress).GetILBytes() ?? []; }
        catch (BadImageFormatException) { return new Edges([], [], []); }
        if (il.Length == 0) return new Edges([], [], []);

        var calls = new List<string>();
        var fields = new List<string>();
        var strings = new List<string>();

        foreach (var (name, token, _) in Walk(il))
        {
            if (token == 0) continue;

            // ldstr adressiert den #US-Heap, nicht eine Metadaten-Tabelle.
            if (name == "ldstr")
            {
                try
                {
                    string literal = reader.GetUserString(MetadataTokens.UserStringHandle(token & 0x00FFFFFF));
                    if (literal.Length is > 0 and <= 160 && !strings.Contains(literal)) strings.Add(literal);
                }
                catch (ArgumentException) { }
                catch (BadImageFormatException) { }
                continue;
            }

            EntityHandle handle;
            try { handle = MetadataTokens.EntityHandle(token); }
            catch (ArgumentException) { continue; }
            if (handle.IsNil) continue;

            switch (name)
            {
                case "call" or "callvirt" or "newobj" or "ldftn" or "ldvirtftn" or "jmp":
                {
                    string target = $"{name} {Naming.MemberTarget(reader, handle)}";
                    if (!calls.Contains(target)) calls.Add(target);
                    break;
                }
                case "ldfld" or "stfld" or "ldsfld" or "stsfld" or "ldflda" or "ldsflda":
                {
                    string target = $"{name} {Naming.MemberTarget(reader, handle)}";
                    if (!fields.Contains(target)) fields.Add(target);
                    break;
                }
            }
        }

        return new Edges([.. calls], [.. fields], [.. strings]);
    }

    /// <summary>
    /// Kompakte Spur eines Methodenkörpers: nur Zahlenkonstanten und Aufrufe, in
    /// Befehlsreihenfolge. Damit lassen sich Konstanten ablesen, die einem Aufruf
    /// als Argumente vorausgehen — etwa die Versionszahlen vor
    /// <c>newobj VersionInformation::.ctor</c>.
    /// </summary>
    public static string[] Trace(PEReader pe, MetadataReader reader, MethodDefinition md)
    {
        if (md.RelativeVirtualAddress == 0) return [];

        byte[] il;
        try { il = pe.GetMethodBody(md.RelativeVirtualAddress).GetILBytes() ?? []; }
        catch (BadImageFormatException) { return []; }

        var steps = new List<string>();
        foreach (var (name, token, value) in Walk(il))
        {
            long? constant = value ?? MacroConstant(name);
            if (constant is not null)
            {
                steps.Add($"{name} {constant}");
                continue;
            }

            if (name is "call" or "callvirt" or "newobj" or "stsfld" or "stfld" && token != 0)
            {
                EntityHandle handle;
                try { handle = MetadataTokens.EntityHandle(token); }
                catch (ArgumentException) { continue; }
                if (handle.IsNil) continue;
                steps.Add($"{name} {Naming.MemberTarget(reader, handle)}");
            }
        }

        return [.. steps];
    }

    /// <summary>Wert der Kurzform-Ladebefehle (<c>ldc.i4.0</c> … <c>ldc.i4.8</c>, <c>ldc.i4.m1</c>).</summary>
    private static long? MacroConstant(string name) => name switch
    {
        "ldc.i4.m1" => -1,
        "ldc.i4.0" => 0,
        "ldc.i4.1" => 1,
        "ldc.i4.2" => 2,
        "ldc.i4.3" => 3,
        "ldc.i4.4" => 4,
        "ldc.i4.5" => 5,
        "ldc.i4.6" => 6,
        "ldc.i4.7" => 7,
        "ldc.i4.8" => 8,
        _ => null
    };
}
