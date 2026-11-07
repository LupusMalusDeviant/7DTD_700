using System;
using System.Reflection;
using HarmonyLib;

namespace Mod700
{
    /// <summary>
    /// Einstiegspunkt der Mod.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Belegte Schnittstelle (Build Steam 26309840, Assembly-CSharp.dll SHA-256 cb54022c…56c58):
    /// <c>void IModApi::InitMod(Mod)</c>, aufgerufen aus <c>Mod::InitModCode</c>.
    /// </para>
    /// <para>
    /// Diese Klasse muss <c>public</c>, nicht abstrakt und mit einem öffentlichen
    /// parameterlosen Konstruktor versehen sein: der Lader sucht per
    /// <c>Type.IsAssignableFrom</c> nach <c>IModApi</c> und erzeugt die Instanz mit
    /// <c>Activator.CreateInstance</c> ohne Argumente.
    /// Siehe docs/rea/findings/F-00-modloader-events-version.md.
    /// </para>
    /// </remarks>
    public sealed class ModApi : IModApi
    {
        private const string HarmonyId = "de.lupusmalus.mod700";

        private static readonly Version AssemblyVersion =
            typeof(ModApi).Assembly.GetName().Version ?? new Version(0, 0, 0, 0);

        /// <summary>Fassung dieser Mod als Text, für Protokoll und Handshake.</summary>
        internal static string ModVersionText =>
            AssemblyVersion.Major + "." + AssemblyVersion.Minor + "." + AssemblyVersion.Build;

        public void InitMod(Mod modInstance)
        {
            try
            {
                string gameBuild = Constants.cVersionInformation != null
                    ? Constants.cVersionInformation.LongString
                    : "unbekannt";

                Log700.Out("loaded v" + ModVersionText + " (game build " + gameBuild + ")");

                BuildGuard.Check();
                VersionHandshake.Register();
                ApplyPatches();

                ModEvents.GameStartDone.RegisterHandler(OnGameStartDone);
            }
            catch (Exception exception)
            {
                // Eine Ausnahme hier darf den Mod-Lader nicht mitnehmen: Mod::InitModCode
                // protokolliert sie, aber andere Mods sollen trotzdem laden.
                Log700.Exception("InitMod fehlgeschlagen — die Mod ist nicht einsatzbereit.", exception);
            }
        }

        /// <summary>
        /// Hängt die Harmony-Patches ein. <b>Stand Phase 0: es gibt keine.</b> Der Aufruf bleibt
        /// trotzdem drin, weil er belegt, dass das vorgeladene HarmonyX zur Laufzeit auflösbar
        /// ist — das ist ein echtes Smoke-Signal und nichts, was man erst beim ersten Patch
        /// erfahren will. Der erste Patch kommt mit F-08.
        /// </summary>
        private static void ApplyPatches()
        {
            var harmony = new Harmony(HarmonyId);
            harmony.PatchAll(Assembly.GetExecutingAssembly());

            int patched = 0;
            foreach (var _ in harmony.GetPatchedMethods())
            {
                patched++;
            }

            Log700.Out("Harmony " + typeof(Harmony).Assembly.GetName().Version
                       + " angebunden, " + patched + " Patch-Ziele (Phase 0: erwartet 0).");
        }

        private static void OnGameStartDone(ref ModEvents.SGameStartDoneData data)
        {
            Log700.Out("GameStartDone erreicht — Welt läuft.");
        }
    }
}
