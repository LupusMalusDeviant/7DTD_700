# Baut den Rundschild (Konzept Waffen S-33) als Quell-Modell: ein Netz, eine UV-Abwicklung, drei
# gebackene Texturen, dazu zwei Ansichten. Laeuft in Blender, nie im Spiel, nie im Paket und nie
# im Pruefbefehl (Vertrag 05, Abschnitt 1 Nr. 5 und Abschnitt 7.1).
#
#   blender -b --factory-startup --python tools/assets/blender/rundschild.py -- <modellordner> <ansichtordner> [textur] [proben]
#
# <modellordner>   Ziel fuer rundschild.glb, rundschild.fbx und die drei Texturen (PNG).
#                  Vorgabe im Projekt: dist/modelle/rundschild (nicht im Repository - das Modell
#                  entsteht aus diesem Skript jederzeit neu).
# <ansichtordner>  Ziel fuer ansicht-vorn.png, ansicht-hinten.png und masse.json.
#                  Vorgabe im Projekt: assets/quelle/modelle/rundschild
# [textur]         Kantenlaenge der Texturen, Vorgabe 1024 (Spec 01: Standard 1024, hoechstens 2048)
# [proben]         Cycles-Proben fuer die Ansichten, Vorgabe 48
#
# Python ist im Projekt verboten - mit EINER Ausnahme, die der Nutzer am 2026-11-23 freigegeben
# hat: Blender-Skripte (Entscheidungsliste N-61).
#
# Masse und Aufbau nach docs/konzept/waffen.md, S-33: runder Brettschild mit Mittelgriff,
# 86 cm, Bretter mit Rohhaut bezogen, Rand mit Rohhautstreifen gefasst, hoher kegeliger
# Eisenbuckel mit fuenf Nieten ueber dem Faustloch, innen die eiserne Fessel als Griff.
# Nicht dabei: Tragriemen (haengt lose - braucht eine eigene Entscheidung), Bemalung.
#
# Lage im fertigen Modell: Meter, Schild steht aufrecht, Vorderseite zeigt nach -Y (Blender),
# der Ursprung liegt in der Mitte des Griffs - dort sitzt die Faust.
import bpy, bmesh, json, math, os, sys
from mathutils import Vector

arg = sys.argv[sys.argv.index('--') + 1:] if '--' in sys.argv else []
if len(arg) < 2:
    raise SystemExit('Aufruf: ... rundschild.py -- <modellordner> <ansichtordner> [textur] [proben]')
MODELL = os.path.abspath(arg[0])
ANSICHT = os.path.abspath(arg[1])
TEXTUR = int(arg[2]) if len(arg) > 2 else 1024
PROBEN = int(arg[3]) if len(arg) > 3 else 48
NAME = 'rundschild'

# ---------------------------------------------------------------- Masse (Meter)
R = 0.43            # Halbmesser des Bretts (86 cm)
LOCH = 0.055        # Halbmesser des Faustlochs
WOELBUNG = 0.012    # Mitte steht so weit vor dem Rand ("ganz leicht gewoelbt")
DICKE_MITTE = 0.009
DICKE_RAND = 0.006
BRETTER = 7         # Zahl der Bretter; die Fugen zeichnen sich durch die Haut ab
SEG = 48            # Teilung des Bretts im Umfang
ZB = 0.0150         # Hoehe, auf der der Buckelrand aufsitzt
STICHE = 96         # Stiche der Randnaht


def mitte(r):
    return WOELBUNG * (1.0 - (r / R) ** 2)


def dicke(r):
    return DICKE_MITTE - (DICKE_MITTE - DICKE_RAND) * (r / R)


def vorn(r):
    return mitte(r) + dicke(r) / 2


def hinten(r):
    return mitte(r) - dicke(r) / 2


# ---------------------------------------------------------------- Knoten-Helfer
def rechne(nt, op, a, b=None):
    n = nt.nodes.new('ShaderNodeMath')
    n.operation = op
    for i, w in enumerate((a, b)):
        if w is None:
            continue
        if isinstance(w, (int, float)):
            n.inputs[i].default_value = w
        else:
            nt.links.new(w, n.inputs[i])
    return n.outputs['Value']


def mische(nt, art, fak, c1, c2):
    n = nt.nodes.new('ShaderNodeMixRGB')
    n.blend_type = art
    for name, w in (('Fac', fak), ('Color1', c1), ('Color2', c2)):
        if isinstance(w, (int, float)):
            n.inputs[name].default_value = w
        elif isinstance(w, tuple):
            n.inputs[name].default_value = (*w, 1.0) if len(w) == 3 else w
        else:
            nt.links.new(w, n.inputs[name])
    return n.outputs['Color']


def streifen(periode, breite, dunkel):
    # Linien quer zu X im Abstand 'periode' (Bretterfugen, Wicklung). Gibt (Farbe, Hoehe 0..1).
    def muster(nt, koord, farbe):
        sep = nt.nodes.new('ShaderNodeSeparateXYZ')
        nt.links.new(koord.outputs['Object'], sep.inputs['Vector'])
        a = rechne(nt, 'MULTIPLY', sep.outputs['X'], 1.0 / periode)
        a = rechne(nt, 'ADD', a, 0.5)
        a = rechne(nt, 'FRACT', a)
        a = rechne(nt, 'SUBTRACT', a, 0.5)
        a = rechne(nt, 'ABSOLUTE', a)
        mr = nt.nodes.new('ShaderNodeMapRange')
        nt.links.new(a, mr.inputs['Value'])
        mr.inputs['From Min'].default_value = 0.0
        mr.inputs['From Max'].default_value = breite
        f = mr.outputs['Result']                       # 0 in der Fuge, 1 daneben
        tief = mische(nt, 'MULTIPLY', 1.0, farbe, dunkel)
        return mische(nt, 'MIX', f, tief, farbe), f
    return muster


def naht(nt, koord, farbe):
    # Randnaht: kurze dunkle Stiche auf einem Kreis knapp innerhalb des Rands.
    sep = nt.nodes.new('ShaderNodeSeparateXYZ')
    nt.links.new(koord.outputs['Object'], sep.inputs['Vector'])
    x, y = sep.outputs['X'], sep.outputs['Y']
    w = rechne(nt, 'ARCTAN2', y, x)
    w = rechne(nt, 'MULTIPLY', w, STICHE / (2 * math.pi))
    w = rechne(nt, 'FRACT', w)
    stich = rechne(nt, 'LESS_THAN', w, 0.34)
    r = rechne(nt, 'SQRT', rechne(nt, 'ADD', rechne(nt, 'MULTIPLY', x, x), rechne(nt, 'MULTIPLY', y, y)))
    band = rechne(nt, 'MULTIPLY', rechne(nt, 'GREATER_THAN', r, R - 0.0145), rechne(nt, 'LESS_THAN', r, R - 0.0085))
    m = rechne(nt, 'MULTIPLY', stich, band)
    return mische(nt, 'MIX', m, farbe, (0.10, 0.075, 0.05)), rechne(nt, 'SUBTRACT', 1.0, m)


def stoff(name, grund, fleck, fleck_staerke, metall, rauheit, korn, hoehe, muster=None):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED')
    bsdf.inputs['Metallic'].default_value = metall
    bsdf.inputs['Roughness'].default_value = rauheit
    koord = nt.nodes.new('ShaderNodeTexCoord')
    grob = nt.nodes.new('ShaderNodeTexNoise')
    grob.inputs['Scale'].default_value = korn * 0.25
    grob.inputs['Detail'].default_value = 5.0
    nt.links.new(koord.outputs['Object'], grob.inputs['Vector'])
    ramp = nt.nodes.new('ShaderNodeValToRGB')
    ramp.color_ramp.elements[0].position = 0.35
    ramp.color_ramp.elements[1].position = 0.75
    nt.links.new(grob.outputs['Fac'], ramp.inputs['Fac'])
    fak = rechne(nt, 'MULTIPLY', ramp.outputs['Color'], fleck_staerke)
    farbe = mische(nt, 'MIX', fak, grund, fleck)
    fein = nt.nodes.new('ShaderNodeTexNoise')
    fein.inputs['Scale'].default_value = korn
    fein.inputs['Detail'].default_value = 8.0
    nt.links.new(koord.outputs['Object'], fein.inputs['Vector'])
    h = fein.outputs['Fac']
    if muster:
        farbe, f = muster(nt, koord, farbe)
        h = rechne(nt, 'ADD', rechne(nt, 'MULTIPLY', h, 0.4), rechne(nt, 'MULTIPLY', f, 0.6))
    bump = nt.nodes.new('ShaderNodeBump')
    bump.inputs['Strength'].default_value = 1.0
    bump.inputs['Distance'].default_value = hoehe
    nt.links.new(h, bump.inputs['Height'])
    nt.links.new(bump.outputs['Normal'], bsdf.inputs['Normal'])
    nt.links.new(farbe, bsdf.inputs['Base Color'])
    m['metall'] = metall
    m['rauheit'] = rauheit
    return m


# ---------------------------------------------------------------- Netz-Helfer
def objekt(name, bm, mat):
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new(name, me)
    bpy.context.collection.objects.link(ob)
    me.materials.append(mat)
    return ob


def drehkoerper(name, profil, segmente, mat, geschlossen=False):
    # Dreht ein Profil aus (Halbmesser, Hoehe) um die Z-Achse. Die Aussenseite liegt in
    # Laufrichtung des Profils links: Normale = (-dz, dr). Halbmesser 0 wird ein Pol.
    bm = bmesh.new()
    ringe = []
    for r, z in profil:
        if r < 1e-9:
            ringe.append([bm.verts.new((0.0, 0.0, z))])
        else:
            ringe.append([bm.verts.new((r * math.cos(2 * math.pi * i / segmente),
                                        r * math.sin(2 * math.pi * i / segmente), z))
                          for i in range(segmente)])
    paare = list(zip(ringe, ringe[1:]))
    if geschlossen:
        paare.append((ringe[-1], ringe[0]))
    for a, b in paare:
        if len(a) == 1 and len(b) == 1:
            continue
        for i in range(segmente):
            j = (i + 1) % segmente
            if len(a) == 1:
                bm.faces.new((a[0], b[i], b[j]))
            elif len(b) == 1:
                bm.faces.new((a[i], b[0], a[j]))
            else:
                bm.faces.new((a[i], b[i], b[j], a[j]))
    return objekt(name, bm, mat)


def stab(name, schnitte, mat):
    # Flacher Stab laengs X aus Querschnitten (x, halbe Breite in Y, halbe Dicke in Z).
    bm = bmesh.new()
    rahmen = []
    for x, w, t in schnitte:
        rahmen.append([bm.verts.new((x, w, t)), bm.verts.new((x, -w, t)),
                       bm.verts.new((x, -w, -t)), bm.verts.new((x, w, -t))])
    for a, b in zip(rahmen, rahmen[1:]):
        for i in range(4):
            j = (i + 1) % 4
            bm.faces.new((a[i], a[j], b[j], b[i]))
    bm.faces.new(rahmen[0])
    bm.faces.new(rahmen[-1])
    bmesh.ops.recalc_face_normals(bm, faces=bm.faces[:])
    return objekt(name, bm, mat)


def niete(mat, ort, r=0.0055, nach_hinten=False):
    ob = drehkoerper('niete', [(0.0, r * 0.62), (r * 0.72, r * 0.45), (r, 0.0)], 6, mat)
    ob.location = ort
    if nach_hinten:
        ob.rotation_euler = (math.pi, 0.0, 0.0)
    return ob


# ---------------------------------------------------------------- Bau
def bau():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

    haut = stoff('haut', (0.58, 0.46, 0.30), (0.36, 0.26, 0.16), 0.75, 0.0, 0.78, 70.0, 0.0018,
                 streifen(2 * R / BRETTER, 0.035, (0.70, 0.66, 0.62)))
    rand = stoff('rand', (0.33, 0.24, 0.15), (0.20, 0.14, 0.09), 0.70, 0.0, 0.82, 90.0, 0.0020, naht)
    eisen = stoff('eisen', (0.20, 0.19, 0.18), (0.27, 0.15, 0.08), 0.45, 1.0, 0.62, 110.0, 0.0012)
    leder = stoff('wicklung', (0.20, 0.12, 0.07), (0.11, 0.07, 0.04), 0.60, 0.0, 0.80, 120.0, 0.0015,
                  streifen(0.009, 0.22, (0.45, 0.42, 0.40)))

    aussen, innen = [], []      # zwei Gruppen von Kleinteilen, je eine eigene Ecke der Textur
    # Brett: geschlossenes Profil - Vorderseite nach aussen, Rand, Rueckseite, Lochwand
    stufen = [LOCH, 0.16, 0.30, R]
    profil = [(r, vorn(r)) for r in stufen] + [(r, hinten(r)) for r in reversed(stufen)]
    brett = drehkoerper(NAME, profil, SEG, haut, geschlossen=True)
    uv_brett(brett)
    # Randstreifen aus Rohhaut, um die Kante gelegt
    randprofil = [
        (R - 0.022, vorn(R - 0.022) + 0.0015),
        (R + 0.0015, vorn(R) + 0.0022),
        (R + 0.0040, mitte(R)),
        (R + 0.0015, hinten(R) - 0.0022),
        (R - 0.022, hinten(R - 0.022) - 0.0015)]
    streif = drehkoerper('rand', randprofil, SEG, rand)
    uv_rand(streif, randprofil)
    # Buckel: hoch und kegelig, mit flachem Rand
    aussen.append(drehkoerper('buckel', [
        (0.0, ZB + 0.098), (0.007, ZB + 0.094), (0.020, ZB + 0.082), (0.040, ZB + 0.062),
        (0.056, ZB + 0.036), (0.062, ZB + 0.012), (0.066, ZB + 0.0045), (0.086, ZB + 0.0035),
        (0.088, ZB)], 20, eisen))
    # Innenseite des Buckels - sonst sieht man von hinten durch das Faustloch ins Leere
    innen.append(drehkoerper('buckel_innen', [
        (LOCH, vorn(LOCH)), (0.057, ZB + 0.012), (0.052, ZB + 0.036), (0.037, ZB + 0.060),
        (0.018, ZB + 0.079), (0.0, ZB + 0.092)], 20, eisen))
    for i in range(5):
        w = 2 * math.pi * i / 5 + math.radians(90)
        aussen.append(niete(eisen, (0.076 * math.cos(w), 0.076 * math.sin(w), ZB + 0.0038)))
    # Fessel: Eisenband quer ueber das Loch, an den Enden breiter und je zweimal vernietet
    zg = hinten(0.17) - 0.0025
    innen.append(stab('fessel', [
        (-0.172, 0.009, 0.0020), (-0.166, 0.014, 0.0025), (-0.105, 0.013, 0.0025),
        (-0.060, 0.009, 0.0030), (0.0, 0.009, 0.0030), (0.060, 0.009, 0.0030),
        (0.105, 0.013, 0.0025), (0.166, 0.014, 0.0025), (0.172, 0.009, 0.0020)], eisen))
    innen[-1].location = (0.0, 0.0, zg)
    for x in (-0.152, -0.118, 0.118, 0.152):
        aussen.append(niete(eisen, (x, 0.0, zg - 0.0025), r=0.0050, nach_hinten=True))
        aussen.append(niete(eisen, (x, 0.0, vorn(abs(x))), r=0.0050))
    # Wicklung des Griffs: Holz und Leder um das Band, in der Mitte am dicksten
    wick = drehkoerper('wicklung', [
        (0.0, 0.050), (0.0105, 0.046), (0.0135, 0.0), (0.0105, -0.046), (0.0, -0.050)], 10, leder)
    wick.rotation_euler = (0.0, math.radians(90), 0.0)
    wick.scale = (0.88, 1.0, 1.0)      # nach dem Drehen: flacher in Z
    wick.location = (0.0, 0.0, zg)
    innen.append(wick)

    a = uv_gruppe(aussen, (0.005, 0.005, 0.395, 0.395))
    b = uv_gruppe(innen, (0.410, 0.005, 0.800, 0.395))
    ob = verbinden([brett, streif, a, b])
    for p in ob.data.polygons:
        p.use_smooth = True
    ob.data.set_sharp_from_angle(angle=math.radians(40))
    return ob, zg


# ---------------------------------------------------------------- UV-Abwicklung
# Aufteilung der Textur (u nach rechts, v nach oben):
#   oben      zwei Scheiben nebeneinander - Vorderseite links, Rueckseite rechts
#   Mitte     der Randstreifen, abgerollt, in zwei Haelften uebereinander
#   unten     links Buckel und Nieten, daneben Buckel-Innenseite, Fessel und Wicklung,
#             ganz rechts die Kante des Bretts und die Wand des Faustlochs
UV = 'UVMap'


def verbinden(obs):
    bpy.ops.object.select_all(action='DESELECT')
    for o in obs:
        o.select_set(True)
    bpy.context.view_layer.objects.active = obs[0]
    bpy.ops.object.join()
    return bpy.context.view_layer.objects.active


def uv_daten(me):
    return (me.uv_layers.get(UV) or me.uv_layers.new(name=UV)).data


def umlauf(me, p):
    # Anteil am Umfang (0..1) je Ecke einer Flaeche; die Flaeche ueber der Naht bleibt ganz.
    ws = [math.atan2(me.vertices[me.loops[li].vertex_index].co.y,
                     me.vertices[me.loops[li].vertex_index].co.x) % (2 * math.pi)
          for li in p.loop_indices]
    if max(ws) - min(ws) > math.pi:
        ws = [w + 2 * math.pi if w < math.pi else w for w in ws]
    return [w / (2 * math.pi) for w in ws]


def in_feld(feld, u, v):
    x0, y0, x1, y1 = feld
    return (x0 + u * (x1 - x0), y0 + v * (y1 - y0))


def uv_brett(ob):
    me = ob.data
    lay = uv_daten(me)
    s = 0.48 / (2 * R)
    for p in me.polygons:
        if abs(p.normal.z) > 0.5:
            vorne = p.normal.z > 0
            for li in p.loop_indices:
                co = me.vertices[me.loops[li].vertex_index].co
                lay[li].uv = ((0.25 + co.x * s) if vorne else (0.75 - co.x * s), 0.75 + co.y * s)
        else:
            feld = (0.84, 0.005, 0.995, 0.035) if p.center.length > R / 2 else (0.84, 0.050, 0.995, 0.080)
            for li, u in zip(p.loop_indices, umlauf(me, p)):
                co = me.vertices[me.loops[li].vertex_index].co
                lay[li].uv = in_feld(feld, u, 1.0 if co.z > p.center.z else 0.0)


def uv_rand(ob, profil):
    me = ob.data
    lay = uv_daten(me)
    weg = [0.0]
    for (r1, z1), (r2, z2) in zip(profil, profil[1:]):
        weg.append(weg[-1] + math.hypot(r2 - r1, z2 - z1))
    for p in me.polygons:
        us = umlauf(me, p)
        feld = (0.005, 0.455, 0.995, 0.495) if sum(us) / len(us) < 0.5 else (0.005, 0.405, 0.995, 0.445)
        ab = 0.0 if sum(us) / len(us) < 0.5 else 0.5
        for li, u in zip(p.loop_indices, us):
            ring = me.loops[li].vertex_index // SEG
            lay[li].uv = in_feld(feld, (u - ab) * 2.0, weg[ring] / weg[-1])


def uv_gruppe(obs, feld):
    ob = verbinden(obs)
    bpy.ops.object.mode_set(mode='EDIT')
    bpy.ops.mesh.select_all(action='SELECT')
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.03)
    bpy.ops.object.mode_set(mode='OBJECT')
    me = ob.data
    me.uv_layers.active.name = UV
    lay = me.uv_layers[UV].data
    us = [d.uv.x for d in lay]
    vs = [d.uv.y for d in lay]
    x0, y0, x1, y1 = feld
    s = min((x1 - x0) / (max(us) - min(us)), (y1 - y0) / (max(vs) - min(vs)))
    for d in lay:
        d.uv = (x0 + (d.uv.x - min(us)) * s, y0 + (d.uv.y - min(vs)) * s)
    return ob


def backen(ob):
    sc = bpy.context.scene
    sc.render.engine = 'CYCLES'
    sc.cycles.device = 'CPU'
    sc.cycles.samples = 8
    sc.cycles.use_denoising = False
    sc.render.bake.margin = 8
    bilder = {}
    for was, raum in (('farbe', 'sRGB'), ('orm', 'Non-Color'), ('normal', 'Non-Color')):
        b = bpy.data.images.new(NAME + '_' + was, TEXTUR, TEXTUR, alpha=False)
        b.colorspace_settings.name = raum
        bilder[was] = b
    stoffe = [m for m in ob.data.materials if m]
    for m in stoffe:
        nt = m.node_tree
        for n in nt.nodes:
            n.select = False
        ziel = nt.nodes.new('ShaderNodeTexImage')
        ziel.name = 'backziel'
        ziel.select = True
        nt.nodes.active = ziel

    def auf(bild):
        for m in stoffe:
            m.node_tree.nodes['backziel'].image = bild
            m.node_tree.nodes.active = m.node_tree.nodes['backziel']

    # 1. Normalen (Tangentenraum) - mit dem echten Aufbau aus Bump und Grundflaeche
    auf(bilder['normal'])
    bpy.ops.object.bake(type='NORMAL')
    # 2. Farbe und 3. Rauheit/Metall ueber ein Leuchten - so bleibt Metall nicht schwarz
    for m in stoffe:
        nt = m.node_tree
        aus = next(n for n in nt.nodes if n.type == 'OUTPUT_MATERIAL')
        bsdf = next(n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED')
        licht = nt.nodes.new('ShaderNodeEmission')
        licht.name = 'backlicht'
        nt.links.new(bsdf.inputs['Base Color'].links[0].from_socket, licht.inputs['Color'])
        nt.links.new(licht.outputs['Emission'], aus.inputs['Surface'])
    auf(bilder['farbe'])
    bpy.ops.object.bake(type='EMIT')
    for m in stoffe:
        nt = m.node_tree
        licht = nt.nodes['backlicht']
        for l in list(licht.inputs['Color'].links):
            nt.links.remove(l)
        # glTF-Belegung: R frei (1), G Rauheit, B Metall
        licht.inputs['Color'].default_value = (1.0, m['rauheit'], m['metall'], 1.0)
    auf(bilder['orm'])
    bpy.ops.object.bake(type='EMIT')

    os.makedirs(MODELL, exist_ok=True)
    for was, b in bilder.items():
        b.filepath_raw = os.path.join(MODELL, NAME + '_' + was + '.png')
        b.file_format = 'PNG'
        b.save()
    return bilder


def fertiger_stoff(ob, bilder):
    m = bpy.data.materials.new('m700_' + NAME)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED')
    farbe = nt.nodes.new('ShaderNodeTexImage')
    farbe.image = bilder['farbe']
    nt.links.new(farbe.outputs['Color'], bsdf.inputs['Base Color'])
    orm = nt.nodes.new('ShaderNodeTexImage')
    orm.image = bilder['orm']
    teil = nt.nodes.new('ShaderNodeSeparateColor')
    nt.links.new(orm.outputs['Color'], teil.inputs['Color'])
    nt.links.new(teil.outputs['Green'], bsdf.inputs['Roughness'])
    nt.links.new(teil.outputs['Blue'], bsdf.inputs['Metallic'])
    normal = nt.nodes.new('ShaderNodeTexImage')
    normal.image = bilder['normal']
    karte = nt.nodes.new('ShaderNodeNormalMap')
    nt.links.new(normal.outputs['Color'], karte.inputs['Color'])
    nt.links.new(karte.outputs['Normal'], bsdf.inputs['Normal'])
    alt = [x for x in ob.data.materials if x]
    ob.data.materials.clear()
    ob.data.materials.append(m)
    for p in ob.data.polygons:
        p.material_index = 0
    for x in alt:
        bpy.data.materials.remove(x)


def aufstellen(ob, zg):
    # Ursprung in die Mitte des Griffs, Schild aufrecht, Vorderseite nach -Y
    for v in ob.data.vertices:
        v.co.z -= zg
    ob.rotation_euler = (math.radians(90), 0.0, 0.0)
    bpy.ops.object.select_all(action='DESELECT')
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)


def ausfuehren(ob):
    bpy.ops.object.select_all(action='DESELECT')
    ob.select_set(True)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.export_scene.gltf(filepath=os.path.join(MODELL, NAME + '.glb'), export_format='GLB',
                              use_selection=True, export_apply=True, export_yup=True)
    bpy.ops.export_scene.fbx(filepath=os.path.join(MODELL, NAME + '.fbx'), use_selection=True,
                             object_types={'MESH'}, axis_forward='-Z', axis_up='Y',
                             apply_scale_options='FBX_SCALE_UNITS', bake_space_transform=True,
                             path_mode='STRIP', embed_textures=False)


def leuchte(ort, kraft, groesse):
    bpy.ops.object.light_add(type='AREA', location=ort)
    l = bpy.context.object
    l.data.energy = kraft
    l.data.size = groesse
    l.rotation_euler = (-Vector(ort)).to_track_quat('-Z', 'Y').to_euler()


def ansichten():
    sc = bpy.context.scene
    welt = sc.world or bpy.data.worlds.new('welt')
    sc.world = welt
    welt.use_nodes = True
    bg = welt.node_tree.nodes.get('Background')
    bg.inputs['Color'].default_value = (0.78, 0.80, 0.84, 1.0)
    bg.inputs['Strength'].default_value = 0.30
    leuchte((-1.6, -2.2, 1.8), 95, 2.5)
    leuchte((1.8, 2.2, 1.4), 85, 2.5)
    leuchte((2.0, -1.2, 0.4), 22, 3.0)
    bpy.ops.object.camera_add()
    cam = bpy.context.object
    cam.data.lens = 70.0
    sc.camera = cam
    sc.cycles.samples = PROBEN
    sc.cycles.use_denoising = True
    sc.render.film_transparent = True
    sc.render.resolution_x = 900
    sc.render.resolution_y = 900
    sc.render.resolution_percentage = 100
    sc.render.image_settings.file_format = 'PNG'
    sc.render.image_settings.color_mode = 'RGBA'
    sc.render.image_settings.color_depth = '8'
    sc.view_settings.view_transform = 'Standard'
    os.makedirs(ANSICHT, exist_ok=True)
    for datei, ort in (('ansicht-vorn.png', (-0.95, -1.75, 0.45)), ('ansicht-hinten.png', (0.85, 1.80, 0.40))):
        ziel = Vector((0.0, 0.0, 0.0))
        cam.location = ort
        cam.rotation_euler = (ziel - Vector(ort)).to_track_quat('-Z', 'Y').to_euler()
        sc.render.filepath = os.path.join(ANSICHT, datei)
        bpy.ops.render.render(write_still=True)


def messen(ob):
    me = ob.data
    ecken = [ob.matrix_world @ v.co for v in me.vertices]
    lo = [round(min(v[i] for v in ecken), 4) for i in range(3)]
    hi = [round(max(v[i] for v in ecken), 4) for i in range(3)]
    return {
        'stueck': NAME,
        'dreiecke': sum(len(p.vertices) - 2 for p in me.polygons),
        'flaechen': len(me.polygons),
        'ecken': len(me.vertices),
        'uv_inseln_ecken': len(me.uv_layers[0].data) if me.uv_layers else 0,
        'stoffe': len([m for m in me.materials if m]),
        'ausdehnung_m': {'von': lo, 'bis': hi},
        'texturen': {'kante': TEXTUR, 'dateien': [NAME + '_farbe.png', NAME + '_orm.png', NAME + '_normal.png']},
        'blender': bpy.app.version_string,
    }


ob, zg = bau()
bilder = backen(ob)
fertiger_stoff(ob, bilder)
aufstellen(ob, zg)
masse = messen(ob)
ausfuehren(ob)
ansichten()
with open(os.path.join(ANSICHT, 'masse.json'), 'w', encoding='utf-8', newline='\n') as f:
    json.dump(masse, f, indent=2, ensure_ascii=False)
    f.write('\n')
print('FERTIG', json.dumps(masse, ensure_ascii=False))
