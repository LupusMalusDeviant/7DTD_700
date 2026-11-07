namespace Mod700
{
    /// <summary>
    /// Vergleicht die Spielfassung, gegen die diese Mod geprüft wurde, mit der laufenden.
    /// Bei Abweichung gibt es eine Warnung ins Protokoll — die Mod lädt trotzdem weiter,
    /// weil ein harter Abbruch dem Spieler mehr nimmt als er ihm sagt.
    /// </summary>
    /// <remarks>
    /// Kein Harmony-Patch nötig. Belegte Schnittstelle (Build Steam 26309840):
    /// <c>void VersionInformation::.ctor(VersionInformation/EGameReleaseType, int, int, int)</c> und
    /// <c>VersionInformation/EVersionComparisonResult VersionInformation::CompareToRunningBuild()</c>.
    /// Siehe docs/rea/findings/F-00-modloader-events-version.md.
    /// </remarks>
    internal static class BuildGuard
    {
        /// <summary>
        /// Die geprüfte Fassung: V 3.40, Build 10. Aus <c>Constants::.cctor</c> gelesen
        /// (vier Konstanten 1, 3, 40, 10 vor <c>newobj VersionInformation::.ctor</c>);
        /// Zielplattform nach Entscheidung D52.
        /// </summary>
        private const VersionInformation.EGameReleaseType TestedReleaseType = VersionInformation.EGameReleaseType.V;
        private const int TestedMajor = 3;
        private const int TestedMinor = 40;
        private const int TestedBuild = 10;

        internal static string TestedVersionText =>
            TestedReleaseType + " " + TestedMajor + "." + TestedMinor + " (b" + TestedBuild + ")";

        /// <summary>
        /// Prüft die laufende Fassung und protokolliert das Ergebnis.
        /// Gibt <c>true</c> zurück, wenn die Fassung passt (gleicher Build oder gleiche Minor).
        /// </summary>
        internal static bool Check()
        {
            var tested = new VersionInformation(TestedReleaseType, TestedMajor, TestedMinor, TestedBuild);
            var running = Constants.cVersionInformation;
            var comparison = tested.CompareToRunningBuild();

            string runningText = running != null ? running.LongString : "unbekannt";

            switch (comparison)
            {
                case VersionInformation.EVersionComparisonResult.SameBuild:
                    Log700.Out("Spielfassung " + runningText + " entspricht der geprüften Fassung.");
                    return true;

                case VersionInformation.EVersionComparisonResult.SameMinor:
                    Log700.Out("Spielfassung " + runningText + " hat dieselbe Minor-Fassung wie die geprüfte ("
                               + TestedVersionText + "), aber einen anderen Build. Sollte tragen.");
                    return true;

                case VersionInformation.EVersionComparisonResult.NewerMinor:
                    Log700.Warning("Das Spiel ist NEUER als geprüft: läuft " + runningText + ", geprüft "
                                   + TestedVersionText + ". Schnittstellen können sich geändert haben — "
                                   + "vor dem Weiterspielen 'mod700meta verify' gegen den neuen Build laufen lassen.");
                    return false;

                case VersionInformation.EVersionComparisonResult.OlderMinor:
                    Log700.Warning("Das Spiel ist ÄLTER als geprüft: läuft " + runningText + ", geprüft "
                                   + TestedVersionText + ". Diese Mod wurde für die neuere Fassung gebaut.");
                    return false;

                case VersionInformation.EVersionComparisonResult.DifferentMajor:
                    Log700.Error("Andere Major-Fassung: läuft " + runningText + ", geprüft " + TestedVersionText
                                 + ". Hier ist mit Fehlern zu rechnen.");
                    return false;

                default:
                    Log700.Warning("Fassungsvergleich lieferte einen unbekannten Wert (" + comparison
                                   + "); laufende Fassung " + runningText + ".");
                    return false;
            }
        }
    }
}
