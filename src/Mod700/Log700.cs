using System;

namespace Mod700
{
    /// <summary>
    /// Protokollausgabe der Mod. Jede Zeile trägt das Präfix <c>[700]</c>, damit sie sich im
    /// Spielprotokoll von Vanilla und anderen Mods trennen lässt.
    /// </summary>
    /// <remarks>
    /// Schreibt über <c>Log</c> aus <c>LogLibrary.dll</c> — nicht aus Assembly-CSharp.
    /// Belegte Signaturen (Build Steam 26309840, LogLibrary.dll SHA-256 48b932cc…):
    /// <c>static void Log::Out(string)</c>, <c>static void Log::Warning(string)</c>,
    /// <c>static void Log::Error(string)</c>, <c>static void Log::Exception(System.Exception)</c>.
    /// Die Überladungen mit <c>object[]</c> nutzen wir nicht, um Formatierungsfehler im
    /// Spielprotokoll zu vermeiden.
    /// </remarks>
    internal static class Log700
    {
        private const string Prefix = "[700] ";

        internal static void Out(string message) => Log.Out(Prefix + message);

        internal static void Warning(string message) => Log.Warning(Prefix + message);

        internal static void Error(string message) => Log.Error(Prefix + message);

        internal static void Exception(string context, Exception exception)
        {
            Log.Error(Prefix + context);
            Log.Exception(exception);
        }
    }
}
