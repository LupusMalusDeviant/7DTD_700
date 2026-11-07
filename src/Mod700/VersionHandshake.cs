namespace Mod700
{
    /// <summary>
    /// Begleitet den Login eines Spielers und protokolliert, was der Client an
    /// Kompatibilitätsangabe mitbringt.
    /// </summary>
    /// <remarks>
    /// <para>
    /// Kein Harmony-Patch nötig. <c>ModEvents.PlayerLogin</c> ist ein
    /// <c>ModEventInterruptible</c>: ein Handler bekommt
    /// <c>ref ModEvents.SPlayerLoginData</c> und gibt <c>ModEvents.EModEventResult</c> zurück.
    /// Mit <c>StopHandlersAndVanilla</c> ließe sich der Login abbrechen.
    /// Belegt für Build Steam 26309840, siehe
    /// docs/rea/findings/F-00-modloader-events-version.md.
    /// </para>
    /// <para>
    /// <b>Dieser Handler weist bewusst niemanden ab.</b> <c>SPlayerLoginData</c> hat die Felder
    /// <c>ClientInfo</c>, <c>CompatibilityVersion</c> und <c>CustomMessage</c>; was das Spiel in
    /// <c>CompatibilityVersion</c> hineinschreibt und wer es setzt, ist **nicht** belegt. Eine
    /// Abweisung auf Verdacht würde im Zweifel den eigenen Server aussperren. Erst wird
    /// mitgeschrieben, was wirklich ankommt; die Regel kommt danach.
    /// </para>
    /// </remarks>
    internal static class VersionHandshake
    {
        private static bool _registered;

        internal static void Register()
        {
            if (_registered)
            {
                return;
            }

            ModEvents.PlayerLogin.RegisterHandler(OnPlayerLogin);
            _registered = true;
            Log700.Out("Login-Handler registriert (nur Protokoll, keine Abweisung).");
        }

        private static ModEvents.EModEventResult OnPlayerLogin(ref ModEvents.SPlayerLoginData data)
        {
            string reported = string.IsNullOrEmpty(data.CompatibilityVersion)
                ? "(leer)"
                : data.CompatibilityVersion;

            Log700.Out("Login: CompatibilityVersion=" + reported
                       + ", Mod-Fassung hier " + ModApi.ModVersionText
                       + ". Keine Prüfung aktiv — Feldbedeutung noch nicht belegt.");

            return ModEvents.EModEventResult.Continue;
        }
    }
}
