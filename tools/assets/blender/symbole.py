# Baut einfache Formen in Blender und rendert sie freigestellt als Quellbild fuer ein Symbol
# (Vertrag 05, Abschnitt 3.3 Nr. 3: Quelle 'eigen:blender'). Laeuft in Blender, nie im Spiel und
# nie im Pruefbefehl. Aufruf ueber lauf.py daneben; erwartet die Variablen WAS (Name des Stuecks)
# und AUS (Zielpfad der PNG-Datei).
#
# Python ist im Projekt verboten - mit EINER Ausnahme, die der Nutzer am 2026-11-23 freigegeben
# hat: Blender-Skripte (Entscheidungsliste N-61). Bis dahin lag diese Datei nur im Arbeitsordner
# einer Sitzung; die vier Quellbilder unter assets/quelle/symbole/ sind mit ihr entstanden.
#
# Aus diesem Skript wird das QUELLBILD. Das fertige 160x160-Symbol im Modlet macht
# tools/assets/symbole.ps1 daraus (Zuschnitt, keine Farbaenderung).
import bpy, bmesh, math, random
from mathutils import Vector, noise


def leeren():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for block in (bpy.data.meshes, bpy.data.materials, bpy.data.lights, bpy.data.cameras):
        for d in list(block):
            if d.users == 0:
                block.remove(d)


def material(name, farbe, metall, rauheit, bump=0.3, masstab=18.0, fleck=None, fleck_staerke=0.5):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = nt.nodes.get('Principled BSDF')
    bsdf.inputs['Metallic'].default_value = metall
    bsdf.inputs['Roughness'].default_value = rauheit
    # Farbe: Grundton, durch grobes Rauschen zu einem zweiten Ton gemischt (Anlauf, Russ, Brand)
    n1 = nt.nodes.new('ShaderNodeTexNoise')
    n1.inputs['Scale'].default_value = masstab * 0.35
    n1.inputs['Detail'].default_value = 6.0
    ramp = nt.nodes.new('ShaderNodeValToRGB')
    ramp.color_ramp.elements[0].position = 0.35
    ramp.color_ramp.elements[1].position = 0.75
    mix = nt.nodes.new('ShaderNodeMixRGB')
    mix.inputs['Color1'].default_value = (*farbe, 1.0)
    zweit = fleck if fleck else tuple(c * 0.45 for c in farbe)
    mix.inputs['Color2'].default_value = (*zweit, 1.0)
    nt.links.new(n1.outputs['Fac'], ramp.inputs['Fac'])
    scale = nt.nodes.new('ShaderNodeMath')
    scale.operation = 'MULTIPLY'
    scale.inputs[1].default_value = fleck_staerke
    nt.links.new(ramp.outputs['Color'], scale.inputs[0])
    nt.links.new(scale.outputs['Value'], mix.inputs['Fac'])
    nt.links.new(mix.outputs['Color'], bsdf.inputs['Base Color'])
    # Oberflaeche: feines Rauschen als Bump (Hammerschlag, Narben)
    n2 = nt.nodes.new('ShaderNodeTexNoise')
    n2.inputs['Scale'].default_value = masstab
    n2.inputs['Detail'].default_value = 8.0
    bmp = nt.nodes.new('ShaderNodeBump')
    bmp.inputs['Strength'].default_value = bump
    nt.links.new(n2.outputs['Fac'], bmp.inputs['Height'])
    nt.links.new(bmp.outputs['Normal'], bsdf.inputs['Normal'])
    return m


def verformen(obj, staerke, masstab, seed=0.0):
    for v in obj.data.vertices:
        p = v.co * masstab + Vector((seed, seed * 0.7, seed * 1.3))
        v.co += v.normal * (noise.noise(p) * staerke)


def glatt(obj):
    for p in obj.data.polygons:
        p.use_smooth = True


def muenze(mat, ort, drehung, seed):
    random.seed(seed)
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, cap_tris=False, segments=48,
                          radius1=1.0, radius2=1.0, depth=0.13)
    # unrunder Rand, wie gehaemmert
    for v in bm.verts:
        r = math.hypot(v.co.x, v.co.y)
        if r > 0.5:
            w = math.atan2(v.co.y, v.co.x)
            f = 1.0 + 0.022 * math.sin(w * 3 + seed) + 0.012 * math.sin(w * 7 + seed * 2.1)
            v.co.x *= f
            v.co.y *= f
    bmesh.ops.bevel(bm, geom=[e for e in bm.edges if abs(e.verts[0].co.z - e.verts[1].co.z) < 1e-6],
                    offset=0.02, segments=2, affect='EDGES')
    me = bpy.data.meshes.new('muenze')
    bm.to_mesh(me)
    bm.free()
    ob = bpy.data.objects.new('muenze', me)
    bpy.context.collection.objects.link(ob)
    ob.data.materials.append(mat)
    glatt(ob)
    me.set_sharp_from_angle(angle=math.radians(35))
    teile = [ob]
    # Praegung: Perlkreis und Mittelpunkt, flach erhaben - keine Schrift, keine Ziffer
    def perle(x, y, r):
        bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, radius=r, location=(x, y, 0.065))
        p = bpy.context.object
        p.scale.z = 0.35
        p.data.materials.append(mat)
        glatt(p)
        teile.append(p)
    for i in range(16):
        w = 2 * math.pi * i / 16
        perle(0.78 * math.cos(w), 0.78 * math.sin(w), 0.055)
    perle(0, 0, 0.12)
    for i in range(4):
        w = 2 * math.pi * i / 4 + 0.4
        perle(0.38 * math.cos(w), 0.38 * math.sin(w), 0.075)
    for t in teile[1:]:
        t.parent = ob
    ob.location = ort
    ob.rotation_euler = drehung
    return ob


def barren(mat, laenge, breite, hoehe, ort, drehung, seed, kante=0.05, narbe=0.035):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
    ob = bpy.context.object
    ob.scale = (laenge, breite, hoehe)
    bpy.ops.object.transform_apply(scale=True)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=10, use_grid_fill=True)
    bm.to_mesh(ob.data)
    bm.free()
    # leicht verjuengt und verzogen: ausgeschmiedet, nicht gegossen
    for v in ob.data.vertices:
        t = v.co.x / (laenge * 0.5)
        v.co.y *= 1.0 - 0.10 * t * t
        v.co.z *= 1.0 - 0.08 * abs(t)
        v.co.z += 0.02 * math.sin(v.co.x * 3.0 + seed)
    verformen(ob, narbe, 3.5, seed)
    mod = ob.modifiers.new('fase', 'BEVEL')
    mod.width = kante
    mod.segments = 3
    sub = ob.modifiers.new('sub', 'SUBSURF')
    sub.levels = 1
    sub.render_levels = 2
    ob.data.materials.append(mat)
    glatt(ob)
    ob.location = ort
    ob.rotation_euler = drehung
    return ob


def klinge(mat, laenge, breite, dicke, ort, drehung, seed):
    # Rohe Klinge ohne Griff: flacher Stab, zur Spitze verjuengt, hinten eine schmale Angel.
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
    ob = bpy.context.object
    ob.scale = (laenge, breite, dicke)
    bpy.ops.object.transform_apply(scale=True)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=14, use_grid_fill=True)
    bm.to_mesh(ob.data)
    bm.free()
    for v in ob.data.vertices:
        t = v.co.x / (laenge * 0.5)          # -1 Angel ... +1 Spitze
        q = v.co.y / (breite * 0.5)          # -1 ... +1 ueber die Breite
        if t > 0.45:
            f = max(0.0, 1.0 - ((t - 0.45) / 0.55) ** 1.6)
            v.co.y *= max(f, 0.03)
        if t < -0.62:
            v.co.y *= 0.38
        # Schneiden: zu den Raendern hin duenner
        v.co.z *= 1.0 - 0.75 * abs(q) ** 1.5
        v.co.z *= 1.0 - 0.5 * max(0.0, t) ** 2
    verformen(ob, 0.012, 3.0, seed)
    ob.data.materials.append(mat)
    glatt(ob)
    ob.data.set_sharp_from_angle(angle=math.radians(50))
    ob.location = ort
    ob.rotation_euler = drehung
    return ob


def licht_und_kamera(ziel=(0, 0, 0), abstand=6.0, hoehe_winkel=50.0, brennweite=85.0):
    # Hauptlicht von links oben, weich; Aufhellung von rechts; schwaches Umgebungslicht
    bpy.ops.object.light_add(type='AREA', location=(-4.0, -3.0, 6.0))
    k = bpy.context.object
    k.data.energy = 450
    k.data.size = 5.0
    k.rotation_euler = (math.radians(40), math.radians(-30), math.radians(-20))
    bpy.ops.object.light_add(type='AREA', location=(4.5, -2.0, 2.5))
    f = bpy.context.object
    f.data.energy = 90
    f.data.size = 6.0
    f.rotation_euler = (math.radians(70), math.radians(35), math.radians(30))
    bpy.ops.object.light_add(type='AREA', location=(0.5, 5.0, 3.0))
    r = bpy.context.object
    r.data.energy = 110
    r.data.size = 4.0
    r.rotation_euler = (math.radians(-65), 0, math.radians(180))
    welt = bpy.context.scene.world or bpy.data.worlds.new('welt')
    bpy.context.scene.world = welt
    welt.use_nodes = True
    bg = welt.node_tree.nodes.get('Background')
    bg.inputs['Color'].default_value = (0.75, 0.78, 0.82, 1.0)
    bg.inputs['Strength'].default_value = 0.40
    w = math.radians(hoehe_winkel)
    ort = Vector(ziel) + Vector((0.0, -abstand * math.cos(w), abstand * math.sin(w)))
    bpy.ops.object.camera_add(location=ort)
    cam = bpy.context.object
    cam.data.lens = brennweite
    richtung = Vector(ziel) - ort
    cam.rotation_euler = richtung.to_track_quat('-Z', 'Y').to_euler()
    bpy.context.scene.camera = cam
    return cam


def rendern(pfad, groesse=640, proben=96):
    sc = bpy.context.scene
    sc.render.engine = 'CYCLES'
    sc.cycles.samples = proben
    sc.cycles.use_denoising = True
    sc.cycles.device = 'CPU'
    sc.render.film_transparent = True
    sc.render.resolution_x = groesse
    sc.render.resolution_y = groesse
    sc.render.resolution_percentage = 100
    sc.render.image_settings.file_format = 'PNG'
    sc.render.image_settings.color_mode = 'RGBA'
    sc.render.image_settings.color_depth = '8'
    sc.view_settings.view_transform = 'Standard'
    sc.render.filepath = pfad
    bpy.ops.render.render(write_still=True)


def bau(was):
    leeren()
    if was == 'silberpfennig':
        silber = material('silber', (0.80, 0.79, 0.75), 0.85, 0.40, bump=0.40, masstab=22.0,
                          fleck=(0.20, 0.19, 0.17), fleck_staerke=0.80)
        muenze(silber, (-0.80, 0.45, 0.0), (0.0, 0.0, 0.3), 1.0)
        muenze(silber, (0.80, 0.30, 0.15), (math.radians(5), math.radians(-6), 1.9), 2.0)
        muenze(silber, (0.05, -0.75, 0.30), (math.radians(-6), math.radians(4), 4.1), 3.0)
        licht_und_kamera(ziel=(0.0, -0.05, 0.1), abstand=13.0, hoehe_winkel=55.0)
    elif was == 'schmiedeeisen':
        eisen = material('eisen', (0.23, 0.22, 0.21), 1.0, 0.62, bump=0.55, masstab=14.0,
                         fleck=(0.30, 0.16, 0.09), fleck_staerke=0.45)
        barren(eisen, 2.6, 0.62, 0.34, (0.0, 0.0, 0.0), (0.0, 0.0, math.radians(24)), 1.0)
        barren(eisen, 2.3, 0.58, 0.32, (0.15, 0.20, 0.33), (math.radians(4), math.radians(-3), math.radians(-12)), 4.0)
        licht_und_kamera(ziel=(0.05, 0.05, 0.2), abstand=8.5, hoehe_winkel=48.0)
    elif was == 'tiegelstahl':
        stahl = material('stahl', (0.50, 0.53, 0.57), 1.0, 0.34, bump=0.30, masstab=20.0,
                         fleck=(0.12, 0.14, 0.20), fleck_staerke=0.55)
        barren(stahl, 2.4, 0.42, 0.26, (0.0, -0.25, 0.0), (0.0, 0.0, math.radians(18)), 2.0, kante=0.04, narbe=0.02)
        barren(stahl, 2.4, 0.42, 0.26, (0.0, 0.30, 0.0), (0.0, 0.0, math.radians(14)), 5.0, kante=0.04, narbe=0.02)
        barren(stahl, 2.2, 0.40, 0.25, (0.05, 0.02, 0.27), (math.radians(3), 0.0, math.radians(21)), 7.0, kante=0.04, narbe=0.02)
        licht_und_kamera(ziel=(0.0, 0.0, 0.15), abstand=8.5, hoehe_winkel=48.0)
    elif was == 'klinge':
        eisen = material('klinge', (0.46, 0.46, 0.45), 1.0, 0.45, bump=0.35, masstab=16.0,
                         fleck=(0.16, 0.13, 0.11), fleck_staerke=0.55)
        klinge(eisen, 3.4, 0.62, 0.11, (0.0, 0.0, 0.0), (math.radians(8), 0.0, math.radians(32)), 3.0)
        licht_und_kamera(ziel=(0.0, 0.0, 0.0), abstand=9.5, hoehe_winkel=62.0)
    else:
        raise ValueError('unbekanntes Stueck: ' + was)


bau(WAS)
rendern(AUS)
result = {'stueck': WAS, 'bild': AUS, 'blender': bpy.app.version_string}
