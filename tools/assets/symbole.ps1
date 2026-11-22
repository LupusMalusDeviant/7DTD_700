<#
.SYNOPSIS
    Macht aus den Quellbildern der Symbole die fertigen Bilder im Modlet - oder prueft, ob
    beides noch zusammenpasst (Vertrag 05, Abschnitt 4).

.DESCRIPTION
    Liest das Register assets/ASSETS.md. Fuer jede Zeile der Art 'symbol':

        assets/quelle/symbole/<Name>.png   ->   mod/<Modlet>/UIAtlases/ItemIconAtlas/<Name>.png

    Zuschnitt: das Quellbild wird auf seinen sichtbaren Inhalt beschnitten (Alpha ueber 8 von
    255, damit ein Schleier aus der Freistellung nicht zaehlt), mittig mit 6 Pixeln Rand in
    ein Quadrat gesetzt und auf 160x160 verkleinert. Keine Farbaenderung, kein Schaerfen.
    Geschrieben wird nur, wenn sich das Bild aendert.

    Mit -Pruefen wird nichts geschrieben. Geprueft wird dann:
      1. jede Registerzeile traegt alle Pflichtfelder in gueltiger Form;
      2. jedes fertige Bild entspricht dem, was aus seinem Quellbild entstuende;
      3. unter mod/*/UIAtlases liegt keine Datei ohne Registerzeile.

    AUSGAENGE (Vertrag 05 Abschnitt 4):
      0  alles erzeugt bzw. alles stimmt
      1  Befund: Quellbild fehlt, ist kein PNG mit Alpha, ist zu klein; Zeile unvollstaendig;
         Bild weicht ab; Datei ohne Zeile
      2  nicht ausfuehrbar: Register fehlt oder ist unlesbar, Modlet unbekannt

.PARAMETER Pruefen
    Nichts erzeugen, nur vergleichen.

.PARAMETER Wurzel
    Wurzel des Repositorys. Ohne Angabe zwei Ordner ueber diesem Skript. Die Gegenproben
    geben hier einen nachgebauten Baum an.

.NOTES
    Die Bildarbeit steht als C# in dieser Datei (Add-Type): eine Schleife ueber eine halbe
    Million Bildpunkte dauert in PowerShell Sekunden, und mit hundert Bildern liefe der
    Pruefbefehl Minuten. Gebraucht wird nur System.Drawing, das Windows mitbringt.
    Die Datei enthaelt nur ASCII und braucht darum keine BOM.
#>
[CmdletBinding()]
param(
    [switch]$Pruefen,
    [string]$Wurzel
)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
if (-not $Wurzel) { $Wurzel = Split-Path -Parent (Split-Path -Parent $here) }
# Ein relativer Pfad gilt gegen den Ordner der PowerShell, nicht gegen den des Prozesses.
$Wurzel = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Wurzel).TrimEnd('\')

function Stop-Unausfuehrbar {
    param([string]$Grund)
    Write-Output "symbole: $Grund - NICHT AUSGEFUEHRT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht ausfuehrbar -> RED =='
    exit 2
}

# Was keine Stelle unten abfaengt, ist "nicht ausfuehrbar" und kein Befund.
trap {
    Write-Output "symbole: unerwarteter Fehler ($($_.Exception.Message)) - NICHT AUSGEFUEHRT."
    Write-Output ''
    Write-Output '== Ergebnis: nicht ausfuehrbar -> RED =='
    exit 2
}

Add-Type -AssemblyName System.Drawing
if (-not ('Symbol700' -as [type])) {
    Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Runtime.InteropServices;

public static class Symbol700
{
    public const int Kante = 160;
    public const int Rand = 6;
    public const int Schwelle = 8;

    // Liest eine Bilddatei und gibt sie frei; der Rueckgabewert haelt die Datei nicht offen.
    public static Bitmap Laden(string pfad, out bool istPng, out bool hatAlpha)
    {
        using (Bitmap bild = new Bitmap(pfad))
        {
            istPng = bild.RawFormat.Equals(ImageFormat.Png);
            hatAlpha = Image.IsAlphaPixelFormat(bild.PixelFormat);
            // Die Bildpunkte werden als Bytes kopiert, nicht gezeichnet: Zeichnen rechnet
            // die Farbe mit der Deckkraft mal und wieder zurueck, und bei fast durchsichtigen
            // Punkten bleibt davon eine andere Farbe uebrig (gemessen: Unterschied 124 -
            // ein Bild war nie gleich sich selbst).
            Rectangle alles = new Rectangle(0, 0, bild.Width, bild.Height);
            Bitmap kopie = new Bitmap(bild.Width, bild.Height, PixelFormat.Format32bppArgb);
            BitmapData von = bild.LockBits(alles, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            try
            {
                BitmapData nach = kopie.LockBits(alles, ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
                try
                {
                    byte[] roh = new byte[von.Stride * bild.Height];
                    Marshal.Copy(von.Scan0, roh, 0, roh.Length);
                    Marshal.Copy(roh, 0, nach.Scan0, roh.Length);
                }
                finally { kopie.UnlockBits(nach); }
            }
            finally { bild.UnlockBits(von); }
            return kopie;
        }
    }

    static byte[] Bytes(Bitmap b)
    {
        BitmapData d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
        try
        {
            byte[] roh = new byte[d.Stride * b.Height];
            Marshal.Copy(d.Scan0, roh, 0, roh.Length);
            return roh;
        }
        finally { b.UnlockBits(d); }
    }

    // Das fertige Symbol aus einem Quellbild. Bei einem Fehler null und der Grund in 'grund'.
    public static Bitmap Erzeugen(string pfad, out string grund)
    {
        grund = null;
        bool istPng, hatAlpha;
        Bitmap quelle;
        try { quelle = Laden(pfad, out istPng, out hatAlpha); }
        catch (Exception e) { grund = "laesst sich nicht als Bild lesen (" + e.GetType().Name + ")"; return null; }

        using (quelle)
        {
            if (!istPng) { grund = "ist kein PNG"; return null; }
            if (!hatAlpha) { grund = "hat keinen Alphakanal"; return null; }
            if (quelle.Width < Kante || quelle.Height < Kante)
            {
                grund = "ist kleiner als " + Kante + "x" + Kante + " (" + quelle.Width + "x" + quelle.Height + ")";
                return null;
            }

            byte[] roh = Bytes(quelle);
            int links = quelle.Width, oben = quelle.Height, rechts = -1, unten = -1;
            for (int y = 0; y < quelle.Height; y++)
            {
                int zeile = y * quelle.Width * 4;
                for (int x = 0; x < quelle.Width; x++)
                {
                    if (roh[zeile + x * 4 + 3] > Schwelle)
                    {
                        if (x < links) links = x;
                        if (x > rechts) rechts = x;
                        if (y < oben) oben = y;
                        if (y > unten) unten = y;
                    }
                }
            }
            if (rechts < 0) { grund = "ist vollstaendig durchsichtig"; return null; }

            int breite = rechts - links + 1, hoehe = unten - oben + 1;
            int innen = Kante - 2 * Rand;
            int laengste = Math.Max(breite, hoehe);
            if (laengste < innen)
            {
                grund = "zeigt nur " + breite + "x" + hoehe + " sichtbare Bildpunkte, gebraucht werden " + innen + " in der laengeren Richtung";
                return null;
            }

            double faktor = (double)innen / laengste;
            int zielBreite = Math.Max(1, (int)Math.Round(breite * faktor));
            int zielHoehe = Math.Max(1, (int)Math.Round(hoehe * faktor));
            Bitmap ziel = new Bitmap(Kante, Kante, PixelFormat.Format32bppArgb);
            using (Graphics g = Graphics.FromImage(ziel))
            using (ImageAttributes rand = new ImageAttributes())
            {
                g.Clear(Color.Transparent);
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;
                g.CompositingQuality = CompositingQuality.HighQuality;
                rand.SetWrapMode(WrapMode.TileFlipXY);
                Rectangle wohin = new Rectangle((Kante - zielBreite) / 2, (Kante - zielHoehe) / 2, zielBreite, zielHoehe);
                g.DrawImage(quelle, wohin, links, oben, breite, hoehe, GraphicsUnit.Pixel, rand);
            }
            return ziel;
        }
    }

    // Groesster SICHTBARER Unterschied; -1 bei verschiedener Groesse. Verglichen wird die
    // Deckkraft und die Farbe mal Deckkraft: die Farbe eines durchsichtigen Punktes sieht
    // niemand, und sie soll keinen Befund machen.
    public static int Unterschied(Bitmap a, Bitmap b)
    {
        if (a.Width != b.Width || a.Height != b.Height) return -1;
        byte[] x = Bytes(a), y = Bytes(b);
        int groesster = 0;
        for (int i = 0; i < x.Length; i += 4)
        {
            int ax = x[i + 3], ay = y[i + 3];
            int d = Math.Abs(ax - ay);
            if (d > groesster) groesster = d;
            for (int k = 0; k < 3; k++)
            {
                d = Math.Abs(x[i + k] * ax - y[i + k] * ay) / 255;
                if (d > groesster) groesster = d;
            }
        }
        return groesster;
    }
}
'@
}

# ---------------------------------------------------------------- Register lesen
$registerPfad = [IO.Path]::Combine($Wurzel, 'assets\ASSETS.md')
if (-not [IO.File]::Exists($registerPfad)) { Stop-Unausfuehrbar "das Register fehlt ($registerPfad)" }

$pflicht = @('Name', 'Art', 'Modlet', 'Benutzt von', 'Quelle', 'Beleg', 'Lizenz', 'Nennung', 'Beschreibung', 'Kosten', 'Stand')
$darfLeerSein = @('Beleg', 'Beschreibung', 'Kosten')    # nur bei eigenen Stuecken
$strich = @('-', [string][char]0x2013, [string][char]0x2014)

function Split-Tabellenzeile {
    param([string]$Zeile)
    $kern = $Zeile.Trim()
    if ($kern.StartsWith('|')) { $kern = $kern.Substring(1) }
    if ($kern.EndsWith('|')) { $kern = $kern.Substring(0, $kern.Length - 1) }
    return @($kern.Split('|') | ForEach-Object { $_.Trim().Trim('`').Trim() })
}

$zeilen = [IO.File]::ReadAllLines($registerPfad, [Text.Encoding]::UTF8)
$spalte = $null
$eintraege = @()
$befunde = @()
for ($i = 0; $i -lt $zeilen.Count; $i++) {
    $z = $zeilen[$i].Trim()
    if ($null -eq $spalte) {
        if ($z -match '^\|\s*`?Name`?\s*\|') {
            $kopf = Split-Tabellenzeile $z
            $spalte = @{}
            for ($k = 0; $k -lt $kopf.Count; $k++) { $spalte[$kopf[$k]] = $k }
            $fehlend = @($pflicht | Where-Object { -not $spalte.ContainsKey($_) })
            if ($fehlend.Count -gt 0) { Stop-Unausfuehrbar ("dem Register fehlen die Spalten: " + ($fehlend -join ', ')) }
            $i++    # Trennzeile
        }
        continue
    }
    if (-not $z.StartsWith('|')) { break }
    $zellen = Split-Tabellenzeile $z
    if ($zellen.Count -ne $spalte.Count) {
        $befunde += "Registerzeile $($i + 1): $($zellen.Count) Zellen statt $($spalte.Count)"
        continue
    }
    $eintrag = @{ Zeile = $i + 1 }
    foreach ($feld in $pflicht) { $eintrag[$feld] = $zellen[$spalte[$feld]] }
    $eintraege += , $eintrag
}
if ($null -eq $spalte) { Stop-Unausfuehrbar "das Register hat keine Tabelle mit der Spalte 'Name'" }
if ($eintraege.Count -eq 0 -and $befunde.Count -eq 0) { Stop-Unausfuehrbar 'das Register hat keine Zeile' }

# ---------------------------------------------------------------- Zeilen pruefen
$gesehen = @{}
$symbole = @()
foreach ($e in $eintraege) {
    $wo = "Registerzeile $($e.Zeile) ($($e.Name))"
    $eigen = $e.Quelle -match '^eigen:(blender|hand)$'
    foreach ($feld in $pflicht) {
        $wert = [string]$e[$feld]
        if ($wert -eq '') { $befunde += "${wo}: Pflichtfeld '$feld' ist leer"; continue }
        if ($strich -contains $wert -and -not ($eigen -and $darfLeerSein -contains $feld)) {
            $befunde += "${wo}: Pflichtfeld '$feld' traegt nur einen Strich"
        }
    }
    if ($e.Art -notmatch '^(symbol|modell|textur|klang)$') { $befunde += "${wo}: Art '$($e.Art)' gibt es nicht" }
    if ($e.Quelle -notmatch '^(meshy:.+|cc0:.+|eigen:blender|eigen:hand)$') { $befunde += "${wo}: Quelle '$($e.Quelle)' hat keine der vier Formen" }
    if ($e.Stand -notmatch '^(vorl.ufig|bleibt|zu pr.fen)$') { $befunde += "${wo}: Stand '$($e.Stand)' gibt es nicht" }
    $schluessel = $e.Name.ToLowerInvariant()
    if ($gesehen.ContainsKey($schluessel)) { $befunde += "${wo}: der Name steht schon in Zeile $($gesehen[$schluessel])" }
    else { $gesehen[$schluessel] = $e.Zeile }

    if ($e.Art -eq 'symbol') {
        if ($e.Name -cnotmatch '^ico700_[a-z0-9_]+$') { $befunde += "${wo}: ein Symbol heisst ico700_<wort> in Kleinbuchstaben" }
        $modletOrdner = [IO.Path]::Combine($Wurzel, 'mod', $e.Modlet)
        if ($e.Modlet -eq '' -or -not [IO.Directory]::Exists($modletOrdner)) {
            Stop-Unausfuehrbar "$wo nennt das Modlet '$($e.Modlet)', das es unter mod nicht gibt"
        }
        $symbole += , $e
    }
}

# ---------------------------------------------------------------- erzeugen oder vergleichen
$erzeugt = 0
$unveraendert = 0
$ziele = @{}
foreach ($e in $symbole) {
    $quelle = [IO.Path]::Combine($Wurzel, 'assets\quelle\symbole', "$($e.Name).png")
    $zielOrdner = [IO.Path]::Combine($Wurzel, 'mod', $e.Modlet, 'UIAtlases\ItemIconAtlas')
    $ziel = [IO.Path]::Combine($zielOrdner, "$($e.Name).png")
    $ziele[$ziel.ToLowerInvariant()] = $true

    if (-not [IO.File]::Exists($quelle)) {
        $befunde += "$($e.Name): das Quellbild fehlt (assets\quelle\symbole\$($e.Name).png)"
        continue
    }
    $grund = $null
    $neu = [Symbol700]::Erzeugen($quelle, [ref]$grund)
    if ($null -eq $neu) {
        $befunde += "$($e.Name): das Quellbild $grund"
        continue
    }
    try {
        $abstand = -2    # -2 = es gibt noch kein fertiges Bild
        if ([IO.File]::Exists($ziel)) {
            $png = $false; $alpha = $false
            $alt = [Symbol700]::Laden($ziel, [ref]$png, [ref]$alpha)
            try { $abstand = [Symbol700]::Unterschied($alt, $neu) } finally { $alt.Dispose() }
        }
        if ($Pruefen) {
            if ($abstand -eq -2) { $befunde += "$($e.Name): das fertige Bild fehlt (mod\$($e.Modlet)\UIAtlases\ItemIconAtlas\$($e.Name).png)" }
            elseif ($abstand -ne 0) { $befunde += "$($e.Name): das fertige Bild entspricht nicht seinem Quellbild (groesster Unterschied $abstand)" }
            else { $unveraendert++ }
        }
        elseif ($abstand -eq 0) { $unveraendert++ }
        else {
            [void][IO.Directory]::CreateDirectory($zielOrdner)
            $neu.Save($ziel, [System.Drawing.Imaging.ImageFormat]::Png)
            $erzeugt++
        }
    }
    finally { $neu.Dispose() }
}

# ---------------------------------------------------------------- Dateien ohne Zeile
$ohneZeile = 0
if ($Pruefen) {
    $modWurzel = [IO.Path]::Combine($Wurzel, 'mod')
    if ([IO.Directory]::Exists($modWurzel)) {
        foreach ($modlet in [IO.Directory]::GetDirectories($modWurzel)) {
            $atlas = [IO.Path]::Combine($modlet, 'UIAtlases')
            if (-not [IO.Directory]::Exists($atlas)) { continue }
            foreach ($datei in [IO.Directory]::GetFiles($atlas, '*', [IO.SearchOption]::AllDirectories)) {
                if (-not $ziele.ContainsKey($datei.ToLowerInvariant())) {
                    $ohneZeile++
                    $befunde += "Datei ohne Registerzeile: " + $datei.Substring($Wurzel.TrimEnd('\').Length + 1)
                }
            }
        }
    }
}

# ---------------------------------------------------------------- Ergebnis
$modus = if ($Pruefen) { 'geprueft' } else { 'erzeugt' }
Write-Output "symbole: Register $registerPfad"
Write-Output ("  Zeilen: {0}, davon Symbole: {1}" -f $eintraege.Count, $symbole.Count)
if ($Pruefen) { Write-Output ("  fertige Bilder gleich ihrem Quellbild: {0}; Dateien ohne Zeile: {1}" -f $unveraendert, $ohneZeile) }
else { Write-Output ("  geschrieben: {0}, unveraendert: {1}" -f $erzeugt, $unveraendert) }
foreach ($b in $befunde) { Write-Output "  BEFUND: $b" }
Write-Output ''
if ($befunde.Count -gt 0) {
    Write-Output "== Ergebnis ($modus): $($befunde.Count) Befunde -> RED =="
    exit 1
}
Write-Output "== Ergebnis ($modus): 0 Befunde -> GREEN =="
exit 0
