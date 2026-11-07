# Hook-Hypothesen (UNGEPRÜFT)

> ⚠️ Alle Typ- und Methodennamen hier sind **Hypothesen** aus allgemeinem 7DTD-Modding-Wissen.
> Sie können in V2.x umbenannt, verschoben oder anders aufgebaut sein. **Nichts davon darf
> ungeprüft in einen Harmony-Patch.** Status wird nach dem REA-Lauf gepflegt:
> `?` ungeprüft · `✓` bestätigt (Finding-Link) · `✗` existiert nicht/anders

## F-00
| Status | Kandidat | Frage |
|---|---|---|
| ? | `IModApi` / `InitMod(Mod)` | Einstiegspunkt-Signatur in V2.x |
| ? | `ModEvents` | Welche Events gibt es (GameStartDone, PlayerSpawned, …) und lassen sich Patches dadurch vermeiden? |
| ? | `ConnectionManager`, `NetPackage*` (Auth/Login) | Gibt es einen Hook für einen Mod-Versions-Handshake? |
| ? | `Constants` / Versionsinfo-Klasse | Wo steht die Spielversion zur Laufzeit (Build-Guard)? |

## F-02
| Status | Kandidat | Frage |
|---|---|---|
| ? | `EntityAlive.DamageEntity(...)` | Zentraler Schadenseingang? Signatur, Server/Client? |
| ? | `DamageSource`, `DamageResponse` | Enthalten sie Richtung bzw. Angreifer für Blocken von vorn? |
| ? | `ItemActionMelee` / `ItemActionDynamicMelee` | Nahkampf-Aktionen; Hook für „Schild erhoben“-Zustand |
| ? | `ItemActionRanged` / `ItemActionLauncher` | Bogen-Basis; Pfeil-Projektil-Verhalten |
| ? | Buff/CVar-Check im Schadenspfad | Reicht ein CVar `shieldRaised` und ein Postfix statt eigener Logik? (Säule P5) |

## F-05
| Status | Kandidat | Frage |
|---|---|---|
| ? | Currency-Item-Referenz (z. B. `casinoCoin`/`TraderInfo`) | Ist die Währung per XML-Item definiert oder im Code hart verdrahtet? |

## F-08
| Status | Kandidat | Frage |
|---|---|---|
| ? | `BlockLight` / Lichtblock-Klassen | Gibt es einen Zustand an/aus, der netzsynchron ist? |
| ? | `Block.UpdateTick(...)` / `WorldBlockTicker` | Gibt es ein Block-Tick-System für zeitbasierte Änderungen (wie Pflanzenwachstum)? |
| ? | `TileEntity*` | Brauchen Fackeln einen TileEntity für persistenten Brennstoff, oder reicht Block-Meta? |
| ? | Pflanzen-Wachstumsblock (`BlockPlantGrowing`) | Vorbild für „nach N Stunden zu anderem Block wechseln“; eventuell **reines XML** möglich |

## F-09
| Status | Kandidat | Frage |
|---|---|---|
| ? | `SkyManager` / `WeatherManager` | Blutmond-Farbe und Himmel: Code oder Config? |
| ? | `AIDirector` + Horde-Night-Komponente | Wo wird die Horde-Nacht geplant (Vortags-Hook für Vorboten)? |
| ? | `GameUtils.IsBloodMoonTime(...)` o. ä. | Zentrale Abfrage für Seuchennacht-Logik |

## F-15
| Status | Kandidat | Frage |
|---|---|---|
| ? | Turret-Blöcke / `TileEntityPoweredRangedTrap` o. ä. | Wie hängt der Turm am Strom? Lässt er sich ohne Netz betreiben (Variante B), oder reicht das Umdeuten des Netzes (Variante A)? |
| ? | `PowerManager`, `PowerItem`/`PowerSource`/`PowerGenerator` o. ä. | Was verbraucht ein Generator (Item-Name per XML konfigurierbar?), damit Kraftsteine Bernstein bzw. Glutsteine verbrauchen |
| ? | Turret-Munition / Projektil-Definition | Kann ein Turm ein eigenes Projektil (Glutpfeil mit Partikel) statt Vanilla-Munition verschießen, rein per XML? |
| ? | `ItemActionLauncher` / `ItemActionProjectile` | Basis für Zauber-Items (Glutpfeil): Projektil, Partikel, Schaden per XML |
| ? | KI-Zielwahl / Pfadfindung (`EAI*`) | Gibt es eine Möglichkeit, eine „Meide-Zone“ für Bannkreis zu setzen? Sonst Fallback-Aura |
| ? | Item-Modifier-Slots (`ItemClassModifier`) | Grenzen für Runen als Waffen- bzw. Rüstungs-Mods; Accessoire-Slot vorhanden? |

## F-13
| Status | Kandidat | Frage |
|---|---|---|
| ? | `EntityVehicle` / `Vehicle` | Lässt sich ein Tiermodell als „Fahrzeug“ betreiben? |
| ? | `EntityAnimal*`, Folge-KI (`EAI*`) | Folgen-Verhalten für Packtier |

## F-14
| Status | Kandidat | Frage |
|---|---|---|
| ? | `EntityNPC`, `EntityTrader` | NPC-Basis, Persistenz, Netz |
