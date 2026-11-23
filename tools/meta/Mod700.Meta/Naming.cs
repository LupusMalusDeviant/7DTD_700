// Namen und Signaturen aus Metadaten-Handles bilden.

using System.Collections.Immutable;
using System.Reflection;
using System.Reflection.Metadata;

namespace Mod700.Meta;

internal static class Naming
{
    /// <summary>Voller Name einer TypeDefinition, verschachtelte Typen mit "/" getrennt.</summary>
    public static string TypeDefFullName(MetadataReader reader, TypeDefinitionHandle handle)
    {
        var td = reader.GetTypeDefinition(handle);
        string name = reader.GetString(td.Name);

        var declaring = td.GetDeclaringType();
        if (!declaring.IsNil)
        {
            return TypeDefFullName(reader, declaring) + "/" + name;
        }

        string ns = reader.GetString(td.Namespace);
        return string.IsNullOrEmpty(ns) ? name : ns + "." + name;
    }

    /// <summary>Voller Name einer TypeReference.</summary>
    public static string TypeRefFullName(MetadataReader reader, TypeReferenceHandle handle)
    {
        var tr = reader.GetTypeReference(handle);
        string name = reader.GetString(tr.Name);

        if (tr.ResolutionScope.Kind == HandleKind.TypeReference)
        {
            return TypeRefFullName(reader, (TypeReferenceHandle)tr.ResolutionScope) + "/" + name;
        }

        string ns = reader.GetString(tr.Namespace);
        return string.IsNullOrEmpty(ns) ? name : ns + "." + name;
    }

    /// <summary>Voller Name für TypeDef-, TypeRef- oder TypeSpec-Handles.</summary>
    public static string EntityFullName(MetadataReader reader, EntityHandle handle) => handle.Kind switch
    {
        HandleKind.TypeDefinition => TypeDefFullName(reader, (TypeDefinitionHandle)handle),
        HandleKind.TypeReference => TypeRefFullName(reader, (TypeReferenceHandle)handle),
        HandleKind.TypeSpecification =>
            reader.GetTypeSpecification((TypeSpecificationHandle)handle).DecodeSignature(new TypeNameProvider(), null),
        _ => $"<{handle.Kind}>"
    };

    /// <summary>Kanonische Signaturzeile. Dieses Format liest <c>verify</c> auch wieder ein.</summary>
    public static string MethodSignature(
        string declaringType,
        string methodName,
        MethodAttributes attributes,
        MethodSignature<string> signature)
    {
        string prefix = (attributes & MethodAttributes.Static) != 0 ? "static " : "";
        string generics = signature.GenericParameterCount > 0 ? $"`{signature.GenericParameterCount}" : "";
        string parameters = string.Join(", ", signature.ParameterTypes);
        return $"{prefix}{signature.ReturnType} {declaringType}::{methodName}{generics}({parameters})";
    }

    /// <summary>
    /// Kanonische Feldzeile, ohne Klammern: <c>[static ]Typ Deklarierer::Name</c>. Auch dieses
    /// Format liest <c>verify</c> wieder ein (ergänzt 2026-11-23, Plan-0002 WP9.9 — die Ereignisse
    /// der Mod-API wie <c>ModEvents::GameUpdate</c> sind Felder).
    /// </summary>
    public static string FieldSignature(
        string declaringType,
        string fieldName,
        FieldAttributes attributes,
        string fieldType)
    {
        string prefix = (attributes & FieldAttributes.Static) != 0 ? "static " : "";
        return $"{prefix}{fieldType} {declaringType}::{fieldName}";
    }

    /// <summary>Lesbarer Name für ein Aufruf- oder Feldzugriff-Token.</summary>
    public static string MemberTarget(MetadataReader reader, EntityHandle handle)
    {
        switch (handle.Kind)
        {
            case HandleKind.MethodDefinition:
            {
                var md = reader.GetMethodDefinition((MethodDefinitionHandle)handle);
                return $"{TypeDefFullName(reader, md.GetDeclaringType())}::{reader.GetString(md.Name)}";
            }
            case HandleKind.FieldDefinition:
            {
                var fd = reader.GetFieldDefinition((FieldDefinitionHandle)handle);
                return $"{TypeDefFullName(reader, fd.GetDeclaringType())}::{reader.GetString(fd.Name)}";
            }
            case HandleKind.MemberReference:
            {
                var mr = reader.GetMemberReference((MemberReferenceHandle)handle);
                return $"{EntityFullName(reader, mr.Parent)}::{reader.GetString(mr.Name)}";
            }
            case HandleKind.MethodSpecification:
            {
                var ms = reader.GetMethodSpecification((MethodSpecificationHandle)handle);
                return MemberTarget(reader, ms.Method);
            }
            case HandleKind.TypeDefinition:
            case HandleKind.TypeReference:
            case HandleKind.TypeSpecification:
                return EntityFullName(reader, handle);
            default:
                return $"<{handle.Kind}>";
        }
    }
}

/// <summary>
/// Bildet Signatur-Blobs auf lesbare Typnamen ab. Reine Namensbildung, kein Auflösen
/// über einen Lader und kein Dekompilieren.
/// </summary>
internal sealed class TypeNameProvider : ISignatureTypeProvider<string, object?>
{
    public string GetPrimitiveType(PrimitiveTypeCode typeCode) => typeCode switch
    {
        PrimitiveTypeCode.Void => "void",
        PrimitiveTypeCode.Boolean => "bool",
        PrimitiveTypeCode.Char => "char",
        PrimitiveTypeCode.SByte => "sbyte",
        PrimitiveTypeCode.Byte => "byte",
        PrimitiveTypeCode.Int16 => "short",
        PrimitiveTypeCode.UInt16 => "ushort",
        PrimitiveTypeCode.Int32 => "int",
        PrimitiveTypeCode.UInt32 => "uint",
        PrimitiveTypeCode.Int64 => "long",
        PrimitiveTypeCode.UInt64 => "ulong",
        PrimitiveTypeCode.Single => "float",
        PrimitiveTypeCode.Double => "double",
        PrimitiveTypeCode.String => "string",
        PrimitiveTypeCode.Object => "object",
        PrimitiveTypeCode.IntPtr => "nint",
        PrimitiveTypeCode.UIntPtr => "nuint",
        PrimitiveTypeCode.TypedReference => "System.TypedReference",
        _ => typeCode.ToString()
    };

    public string GetTypeFromDefinition(MetadataReader reader, TypeDefinitionHandle handle, byte rawTypeKind)
        => Naming.TypeDefFullName(reader, handle);

    public string GetTypeFromReference(MetadataReader reader, TypeReferenceHandle handle, byte rawTypeKind)
        => Naming.TypeRefFullName(reader, handle);

    public string GetTypeFromSpecification(MetadataReader reader, object? genericContext, TypeSpecificationHandle handle, byte rawTypeKind)
        => reader.GetTypeSpecification(handle).DecodeSignature(this, genericContext);

    public string GetSZArrayType(string elementType) => elementType + "[]";

    public string GetArrayType(string elementType, ArrayShape shape)
        => elementType + "[" + new string(',', Math.Max(0, shape.Rank - 1)) + "]";

    public string GetByReferenceType(string elementType) => elementType + "&";

    public string GetPointerType(string elementType) => elementType + "*";

    public string GetGenericInstantiation(string genericType, ImmutableArray<string> typeArguments)
        => genericType + "<" + string.Join(", ", typeArguments) + ">";

    public string GetGenericMethodParameter(object? genericContext, int index) => "!!" + index;

    public string GetGenericTypeParameter(object? genericContext, int index) => "!" + index;

    public string GetFunctionPointerType(MethodSignature<string> signature)
        => $"delegate*<{string.Join(", ", signature.ParameterTypes)}, {signature.ReturnType}>";

    public string GetModifiedType(string modifier, string unmodifiedType, bool isRequired) => unmodifiedType;

    public string GetPinnedType(string elementType) => elementType + " pinned";

    public string GetTypeFromSerializedName(string name) => name;

    public PrimitiveTypeCode GetUnderlyingEnumType(string type) => PrimitiveTypeCode.Int32;

    public bool IsSystemType(string type) => type == "System.Type";
}
