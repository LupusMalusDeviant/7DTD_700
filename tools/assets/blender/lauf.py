# Starter fuer symbole.py - laeuft in Blender, nicht im Spiel und nicht im Pruefbefehl.
#
#   blender -b --factory-startup --python tools/assets/blender/lauf.py -- <stueck> <ziel.png> [proben]
#
# <stueck>  einer der Namen aus bau() in symbole.py (silberpfennig, schmiedeeisen, tiegelstahl, klinge)
# <ziel>    Quellbild, z. B. assets/quelle/symbole/ico700_silberpfennig.png
# [proben]  Cycles-Proben, Vorgabe 48
#
# Python ist im Projekt verboten - mit EINER Ausnahme, die der Nutzer am 2026-11-23 freigegeben
# hat: Blender-Skripte (Entscheidungsliste N-61, Vertrag 05 Abschnitt 1 Nr. 5).
import sys, os, time
arg = sys.argv[sys.argv.index('--') + 1:]
WAS = arg[0]
AUS = arg[1]
PROBEN = int(arg[2]) if len(arg) > 2 else 48
hier = os.path.dirname(os.path.abspath(__file__))
quelle = open(os.path.join(hier, 'symbole.py'), encoding='utf-8').read()
quelle = quelle.replace('rendern(AUS)', 'rendern(AUS, proben=PROBEN)')
t = time.time()
exec(compile(quelle, 'symbole.py', 'exec'))
print('FERTIG', WAS, AUS, round(time.time() - t, 1), 's')
