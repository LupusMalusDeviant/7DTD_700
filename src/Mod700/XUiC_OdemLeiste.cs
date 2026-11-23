using System.Globalization;

namespace Mod700
{
    /// <summary>
    /// Controller der Odem-Leiste über den Balken links unten (F-15 „Anzeige", Vertrag 07
    /// Nachtrag 2 mit Nachtrag 7, D199). In XUi: <c>controller="Mod700.OdemLeiste, Mod700"</c> —
    /// das Spiel setzt das Präfix <c>XUiC_</c> vor den Klassennamen
    /// (<c>ReflectionHelpers::GetTypeWithPrefix</c>, Finding WP10-odem-leiste, Nachtrag).
    /// </summary>
    /// <remarks>
    /// Rechnet nichts: Anteil (0..1) und Sichtbarkeit (0/1) rechnet der Buff
    /// <c>buff700_odemRegen</c> in die lokalen CVars <c>.cv700_odemAnteil</c> und
    /// <c>.cv700_odemZeigen</c>. Der Controller liest sie viermal je Sekunde und frischt die
    /// Bindungen nur auf, wenn sich etwas sichtbar geändert hat.
    ///
    /// Warum nicht XML: die Bindung <c>{cvar(...)}</c> hängt sich an den nächsten eigenen
    /// Controller darüber und wird nur aufgefrischt, wenn der seine Bindungen neu liest — über
    /// den Balken links unten tut das niemand laufend (Spieltest S-41, 2026-11-23: Werte im
    /// Protokoll richtig, Leiste leer). Dazu formatiert sie Zahlen nach der Spracheinstellung
    /// des Rechners (Komma im Deutschen). Hier steht die Zahl immer mit Punkt.
    ///
    /// Netz: nur Client (C). Liest den lokalen Spieler, schreibt nichts.
    /// </remarks>
    public class XUiC_OdemLeiste : XUiController
    {
        private const float Takt = 0.25f;
        private const float Schwelle = 0.004f;

        private float bisZumNaechsten;
        private float anteil;
        private bool zeigen;
        private bool gelesen;

        public override void Update(float _dt)
        {
            base.Update(_dt);

            bisZumNaechsten -= _dt;
            if (bisZumNaechsten > 0f)
            {
                return;
            }

            bisZumNaechsten = Takt;

            EntityPlayerLocal spieler = xui?.playerUI?.entityPlayer;
            if (spieler == null)
            {
                return;
            }

            bool neuZeigen = spieler.GetCVar(".cv700_odemZeigen") > 0.5f;
            float neuAnteil = neuZeigen ? Klemmen(spieler.GetCVar(".cv700_odemAnteil")) : 0f;

            if (!gelesen || neuZeigen != zeigen || System.Math.Abs(neuAnteil - anteil) > Schwelle)
            {
                gelesen = true;
                zeigen = neuZeigen;
                anteil = neuAnteil;
                RefreshBindings();
            }
        }

        public override bool GetBindingValueInternal(ref string _value, string _bindingName)
        {
            switch (_bindingName)
            {
                case "odemzeigen":
                    _value = zeigen ? "true" : "false";
                    return true;
                case "odemanteil":
                    _value = anteil.ToString("0.000", CultureInfo.InvariantCulture);
                    return true;
                default:
                    return base.GetBindingValueInternal(ref _value, _bindingName);
            }
        }

        private static float Klemmen(float wert)
        {
            if (wert < 0f)
            {
                return 0f;
            }

            return wert > 1f ? 1f : wert;
        }
    }
}
