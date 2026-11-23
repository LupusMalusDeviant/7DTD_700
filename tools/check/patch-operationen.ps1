<#
.SYNOPSIS
    Die neun Patch-Operationen des Spiels, nachgebaut fuer die Pruefskripte.

.DESCRIPTION
    Wird EINGELESEN, nicht aufgerufen:  . (Join-Path $PSScriptRoot 'patch-operationen.ps1')
    Zwei Skripte tun das: sprachverweise-pruefen.ps1 (seit WP8.8) und
    vertraeglichkeit-pruefen.ps1 (seit WP8.9). Der Code stand bis zum 2026-11-22 in
    sprachverweise-pruefen.ps1 und ist von dort unveraendert uebernommen; neu ist nur der
    Parameter -Eingefuegt an Invoke-Operation.

    Was hier steht, ist KEIN zweiter Patcher des Spiels (Vertrag 04, Nachtrag Review zu
    WP8.8, Grenzen): die Operationen sind so nachgebaut, wie Vertrag 03 und das Finding WP1
    sie beschreiben, und rechnen ueber XmlDocument. Welche Paare aus Operation und
    Knotenart gerechnet werden, entscheidet Get-Hindernis - wer Invoke-Operation ruft, fragt
    vorher Get-Hindernis.

.NOTES
    Der Aufbau eines XML-Knotens wird ueber METHODEN gelesen, nie ueber Eigenschaften
    (Vertrag 04, viertes Review zu WP8.7). Die Datei enthaelt nur ASCII und braucht darum
    keine BOM.
#>

function Test-Gleich {
    # Zeichen fuer Zeichen. -eq und -ceq vergleichen nach Kulturregeln.
    param([string]$Links, [string]$Rechts)
    return [string]::Equals($Links, $Rechts, [System.StringComparison]::Ordinal)
}

function Test-In {
    param([string]$Wert, [string[]]$Menge)
    foreach ($m in $Menge) { if (Test-Gleich $Wert $m) { return $true } }
    return $false
}

$element = [System.Xml.XmlNodeType]::Element
$attributArt = [System.Xml.XmlNodeType]::Attribute

function Get-Kinder {
    # Die Kindelemente einer Operation, fuer das Zieldokument uebernommen.
    param($Operation, $ZielDoc)
    $kinder = New-Object System.Collections.Generic.List[object]
    foreach ($kind in $Operation.get_ChildNodes()) {
        if ($kind.get_NodeType() -ne $element) { continue }
        $kinder.Add($ZielDoc.ImportNode($kind, $true))
    }
    return , $kinder
}

function Invoke-Operation {
    # EINE Operation auf EINEN getroffenen Knoten. So, wie Vertrag 03 und das Finding WP1
    # die neun Operationen beschreiben.
    # -Eingefuegt (seit WP8.9): eine Liste, in die jedes Element kommt, das die Operation
    # ins Zieldokument einfuegt. Ohne Angabe wird nichts gesammelt.
    param([string]$Name, $Operation, $Treffer, $ZielDoc, $Eingefuegt = $null)
    $text = $Operation.get_InnerText().Trim()
    $istAttribut = ($Treffer.get_NodeType() -eq $attributArt)

    if (Test-Gleich $Name 'set') {
        if ($istAttribut) { $Treffer.set_Value($text) } else { $Treffer.set_InnerText($text) }
        return
    }
    # Welche Paare aus Operation und Knotenart hier ankommen, entscheidet Get-Hindernis:
    # setattribute, remove, insertAfter und insertBefore nur mit einem Element,
    # removeattribute und csv nur mit einem Attribut. Darum steht unten kein stilles
    # "sonst nichts".
    if (Test-Gleich $Name 'setattribute') {
        $Treffer.SetAttribute($Operation.GetAttribute('name'), $text)
        return
    }
    if (Test-Gleich $Name 'removeattribute') {
        # WIE DAS SPIEL (geaendert 2026-11-23, Spieltest): das Attribut kommt aus dem XPath,
        # ein Attribut 'name' an der Operation liest das Spiel nicht. Bis dahin stand hier
        # RemoveAttribute(name) auf einem Element - genau die Form, die das Spiel ablehnt
        # ("Can only remove Attributes (matched Element ...)", Player.log 2026-11-23).
        [void]$Treffer.get_OwnerElement().RemoveAttributeNode($Treffer)
        return
    }
    if (Test-Gleich $Name 'remove') {
        [void]$Treffer.get_ParentNode().RemoveChild($Treffer)
        return
    }
    if (Test-Gleich $Name 'csv') {
        $trenner = $Operation.GetAttribute('delim')
        if (-not $trenner) { $trenner = ',' }
        $liste = New-Object System.Collections.Generic.List[string]
        foreach ($teil in $Treffer.get_Value().Split(@($trenner), [System.StringSplitOptions]::None)) { $liste.Add($teil) }
        $weg = Test-Gleich $Operation.GetAttribute('op') 'remove'
        foreach ($teil in $text.Split(@($trenner), [System.StringSplitOptions]::None)) {
            if ($weg) { [void]$liste.Remove($teil) }
            elseif (-not $liste.Contains($teil)) { $liste.Add($teil) }
        }
        $Treffer.set_Value(($liste -join $trenner))
        return
    }
    if (Test-Gleich $Name 'append') {
        if ($istAttribut) { $Treffer.set_Value($Treffer.get_Value() + $text); return }
        foreach ($neu in (Get-Kinder $Operation $ZielDoc)) {
            [void]$Treffer.AppendChild($neu)
            if ($null -ne $Eingefuegt) { [void]$Eingefuegt.Add($neu) }
        }
        return
    }
    if (Test-Gleich $Name 'prepend') {
        if ($istAttribut) { $Treffer.set_Value($text + $Treffer.get_Value()); return }
        $erstes = $Treffer.get_FirstChild()
        foreach ($neu in (Get-Kinder $Operation $ZielDoc)) {
            if ($null -eq $erstes) { [void]$Treffer.AppendChild($neu) } else { [void]$Treffer.InsertBefore($neu, $erstes) }
            if ($null -ne $Eingefuegt) { [void]$Eingefuegt.Add($neu) }
        }
        return
    }
    $eltern = $Treffer.get_ParentNode()
    if (Test-Gleich $Name 'insertBefore') {
        foreach ($neu in (Get-Kinder $Operation $ZielDoc)) {
            [void]$eltern.InsertBefore($neu, $Treffer)
            if ($null -ne $Eingefuegt) { [void]$Eingefuegt.Add($neu) }
        }
        return
    }
    # insertAfter: der Reihe nach, jedes hinter das vorige.
    $hinter = $Treffer
    foreach ($neu in (Get-Kinder $Operation $ZielDoc)) {
        [void]$eltern.InsertAfter($neu, $hinter)
        $hinter = $neu
        if ($null -ne $Eingefuegt) { [void]$Eingefuegt.Add($neu) }
    }
}

$nurElement = @('setattribute', 'insertAfter', 'insertBefore')

function Get-Hindernis {
    # Warum sich eine Operation an ihren Treffern NICHT rechnen laesst - oder $null.
    # Vorher tat das Skript an diesen Stellen nichts und zaehlte die Operation als
    # angewandt; ein <remove> auf ein Attribut entfernte es sogar, obwohl das Spiel genau
    # das ablehnt (zweites Review zu WP8.8, Befund 1; Vertrag 03, Abschnitt 2).
    param([string]$Name, $Treffer)
    foreach ($knoten in $Treffer) {
        $art = $knoten.get_NodeType()
        if ($art -eq $script:attributArt) {
            # Die Namespace-Achse (/items/namespace::xml) liefert fuer den Namespace 'xml'
            # ein Attribut, das an keinem Element haengt. Es zu setzen aendert am Dokument
            # nichts (drittes Review zu WP8.8, Befund 2). Ein ausdruecklich deklarierter
            # Namespace ist ein gewoehnliches Attribut und kommt hier nicht an.
            if ($null -eq $knoten.get_OwnerElement()) {
                return 'ein Attribut, das zu keinem Element gehoert (Namespace-Achse)'
            }
            if (Test-Gleich $Name 'remove') {
                return 'ein Attribut; das Spiel lehnt das ab ("use removeattribute instead")'
            }
            if (Test-In $Name $script:nurElement) {
                return "ein Attribut; <$Name> rechnet diese Pruefung nur auf einem Element"
            }
        }
        elseif ($art -eq $script:element) {
            if (Test-Gleich $Name 'removeattribute') {
                return 'ein Element; das Spiel lehnt das ab ("Can only remove Attributes ... use remove instead")'
            }
            if (Test-Gleich $Name 'csv') {
                return 'ein Element; <csv> rechnet diese Pruefung nur auf einem Attribut'
            }
        }
        else {
            return "einen Knoten der Art $art; gerechnet werden nur Elemente und Attribute"
        }
    }
    return $null
}
