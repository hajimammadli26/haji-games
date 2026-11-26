"""Builds the hero Cirtdan as a rigged, animated glTF (.glb) in Blender, headless and deterministic.

Usage (Blender as a Python module, `pip install bpy`):
    python tools/blender/make_cirtdan.py --out assets/models/char_cirtdan_blender.glb [--preview DIR]

Spec: design/art/art-bible.md section 5 (Character Design Direction) and section 8 (Asset Standards), and the
procedural figure in src/game/art/characters.gd runner() (proportions and colours are copied from it).
- 1 unit = 1 m, origin at the feet, +Z up in Blender (+Y up in glTF), faces Blender +Y = Godot -Z.
- Two meshes on one armature: "Body" (gets the ink outline in Godot) and "Face" (eyes, brows, cheeks, mouths:
  small parts that an outline would muddy). One shared material; every colour is a face-corner vertex colour.
- Clips (actions): run (loop), jump, slide, stumble, idle (loop), fly (loop). jump is posed by vertical speed:
  frame 0 = take-off, the middle = apex, the end = landing (the game seeks it by vy).
"""
import argparse
import math
import os
import sys

import bpy
from mathutils import Euler, Matrix, Vector

# --- colours (sRGB hex, the same values as characters.gd) ----------------------------------------------------------
SKIN = "#f2c08f"
RED = "#c8221d"  # Player Red: the papaq
RED_DARK = "#7a1512"  # the papaq's fur band
GOLD = "#c89b45"  # Antique Gold: trims, the knot, the buckle
VEST = "#1f4f8f"
SHIRT = "#f3ecd8"
PANTS = "#4b3221"
SHOE = "#7a3b16"
MADDER = "#8f2b2b"
HAIR = "#3b2414"
SACK = "#c9a46a"
STRAP = "#8a6a44"
PATCH = "#7d5a9b"
NOSE = "#e9a776"
CHEEK = "#f08a8a"
EYE_W = "#ffffff"
PUPIL = "#2a1a10"
MOUTH = "#8a2a1c"
MOUTH_O = "#5a1410"

FPS = 30
TRI_BUDGET = 5000


def hex_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) / 255.0 for i in (0, 2, 4))


# --- geometry: plain python lists, so every piece is exact and repeatable -----------------------------------------
class Part:
    """A piece of geometry with one bone weighting and a colour per face."""

    def __init__(self):
        self.v = []  # Vector
        self.f = []  # tuple of indices
        self.fc = []  # colour hex per face
        self.w = []  # dict bone -> weight per vertex

    def add(self, verts, faces, color, weight, xf=Matrix.Identity(4)):
        """Adds verts/faces transformed by xf. color: hex or fn(face_index)->hex. weight: bone name or fn(pos)->dict."""
        base = len(self.v)
        for p in verts:
            q = xf @ Vector(p)
            self.v.append(q)
            self.w.append({weight: 1.0} if isinstance(weight, str) else weight(q))
        for i, f in enumerate(faces):
            self.f.append(tuple(base + k for k in f))
            self.fc.append(color(i) if callable(color) else color)


def lathe(profile, segs, a0=0.0, a1=2.0 * math.pi, angles=None):
    """Revolves profile [(r, z)] about Z. Angle measured from the front (+Y). Points with r = 0 become poles.
    angles: an explicit open list of angles instead of a0..a1 in segs steps.
    Returns verts, faces and per-face (profile index, segment index)."""
    if angles is not None:
        segs = len(angles) - 1
        a0, a1 = angles[0], angles[-1]
    full = angles is None and abs((a1 - a0) - 2.0 * math.pi) < 1e-6
    cols = segs if full else segs + 1
    verts, faces, idx = [], [], []
    rows = []
    for r, z in profile:
        if r < 1e-6:
            rows.append([len(verts)] * cols)
            verts.append((0.0, 0.0, z))
        else:
            row = []
            for j in range(cols):
                a = angles[j] if angles is not None else a0 + (a1 - a0) * j / segs
                row.append(len(verts))
                verts.append((r * math.sin(a), r * math.cos(a), z))
            rows.append(row)
    for i in range(len(profile) - 1):
        for j in range(segs):
            j2 = (j + 1) % cols
            a, b, c, d = rows[i][j], rows[i][j2], rows[i + 1][j2], rows[i + 1][j]
            quad = [a, b, c, d]
            uniq = []
            for k in quad:  # drop the repeated pole vertex: a triangle
                if k not in uniq:
                    uniq.append(k)
            if len(uniq) >= 3:  # wound counter-clockwise seen from outside: normals point out
                faces.append(tuple(reversed(uniq)))
                idx.append((i, j))
    return verts, faces, idx


def ellipsoid(sx, sy, sz, segs=16, rings=10):
    prof = [(math.sin(math.pi * i / rings), -math.cos(math.pi * i / rings)) for i in range(rings + 1)]
    v, f, _ = lathe(prof, segs)
    return [(x * sx, y * sy, z * sz) for x, y, z in v], f


def cylinder(r_bot, r_top, h, segs=16):
    v, f, _ = lathe([(0.0, -h / 2), (r_bot, -h / 2), (r_top, h / 2), (0.0, h / 2)], segs)
    return v, f


def capsule(r, length, segs=12, cap=4):
    """A capsule along Z from 0 down to -length (total), radius r."""
    prof = []
    for i in range(cap + 1):  # bottom hemisphere
        a = math.pi / 2 * i / cap
        prof.append((r * math.sin(a), -length + r - r * math.cos(a)))
    for i in range(cap + 1):  # top hemisphere
        a = math.pi / 2 * i / cap
        prof.append((r * math.cos(a), -r + r * math.sin(a)))
    v, f, _ = lathe(prof, segs)
    return v, f


def torus(R, r, segs=24, sides=8):
    verts, faces = [], []
    for i in range(segs):
        a = 2 * math.pi * i / segs
        for j in range(sides):
            b = 2 * math.pi * j / sides
            rr = R + r * math.cos(b)
            verts.append((rr * math.cos(a), rr * math.sin(a), r * math.sin(b)))
    for i in range(segs):
        for j in range(sides):
            i2, j2 = (i + 1) % segs, (j + 1) % sides
            faces.append((i * sides + j, i2 * sides + j, i2 * sides + j2, i * sides + j2))
    return verts, faces


def tube(points, r, sides=6):
    """A closed tube through points (Vectors), capped at both ends."""
    verts, faces = [], []
    n = len(points)
    for i, p in enumerate(points):
        t = (points[min(i + 1, n - 1)] - points[max(i - 1, 0)]).normalized()
        up = Vector((0, 1, 0)) if abs(t.y) < 0.9 else Vector((1, 0, 0))
        a = t.cross(up).normalized()
        b = t.cross(a).normalized()
        for j in range(sides):
            ang = 2 * math.pi * j / sides
            verts.append(tuple(p + (a * math.cos(ang) + b * math.sin(ang)) * r))
    for i in range(n - 1):
        for j in range(sides):
            j2 = (j + 1) % sides
            faces.append((i * sides + j, i * sides + j2, (i + 1) * sides + j2, (i + 1) * sides + j))
    faces.append(tuple(reversed(range(sides))))
    faces.append(tuple((n - 1) * sides + j for j in range(sides)))
    return verts, faces


def box(sx, sy, sz):
    v = [(x * sx / 2, y * sy / 2, z * sz / 2) for x in (-1, 1) for y in (-1, 1) for z in (-1, 1)]
    f = [(0, 1, 3, 2), (4, 6, 7, 5), (0, 4, 5, 1), (2, 3, 7, 6), (0, 2, 6, 4), (1, 5, 7, 3)]
    return v, f


def X(pos, rot=(0.0, 0.0, 0.0)):
    return Matrix.Translation(Vector(pos)) @ Euler(rot, "XYZ").to_matrix().to_4x4()


def torso_w(p):
    """Torso weights by height: hips below the belt, spine at the waist, chest above."""
    z = p.z
    if z < 0.62:
        return {"hips": 1.0}
    if z < 0.74:
        t = (z - 0.62) / 0.12
        return {"hips": 1.0 - t, "spine": t}
    if z < 0.86:
        t = (z - 0.74) / 0.12
        return {"spine": 1.0 - t, "chest": t}
    return {"chest": 1.0}


# --- the figure ------------------------------------------------------------------------------------------------------
HIP = 0.52
SHOULDER = 0.90
HEAD = 1.14
HEAD_C = 1.32


def build_parts():
    body, face = Part(), Part()
    # legs: thigh, shin, a çarıq with a turned-up toe and a madder tie
    for s, side in ((-1, "L"), (1, "R")):
        x = 0.12 * s
        body.add(*capsule(0.085, 0.24, 10, 3), PANTS, f"upper_leg.{side}", X((x, 0, HIP + 0.02)))
        body.add(*capsule(0.075, 0.24, 10, 3), PANTS, f"lower_leg.{side}", X((x, 0, 0.34)))
        body.add(*ellipsoid(0.1, 0.16, 0.075, 12, 7), SHOE, f"foot.{side}", X((x, 0.04, 0.075)))
        body.add(*cylinder(0.03, 0.0, 0.09, 8), SHOE, f"foot.{side}", X((x, 0.2, 0.1), (-1.0, 0, 0)))
        body.add(*cylinder(0.078, 0.078, 0.03, 12), MADDER, f"lower_leg.{side}", X((x, 0, 0.15)))
    # shirt: a rounded body, capped below
    shirt_prof = [(0.0, -0.04), (0.19, -0.04), (0.205, 0.1), (0.2, 0.26), (0.175, 0.37), (0.12, 0.45), (0.0, 0.48)]
    v, f, _ = lathe(shirt_prof, 18)
    body.add(v, f, SHIRT, torso_w, X((0, 0, HIP)))
    # the vest: wrapped round the body, open down the front so the shirt shows; Antique Gold trim along the
    # opening, the collar and the hem (thin rows and columns of faces, so the colour edge stays crisp)
    gap, trim = 0.42, 0.13
    inner = [gap + trim + (2 * math.pi - 2 * (gap + trim)) * k / 11 for k in range(12)]
    angles = [gap] + inner + [2 * math.pi - gap]
    vest_prof = [(0.226, -0.1), (0.229, -0.065), (0.236, 0.05), (0.232, 0.22), (0.205, 0.35), (0.165, 0.42), (0.118, 0.47)]
    rows, cols = len(vest_prof) - 1, len(angles) - 1
    v, f, idx = lathe(vest_prof, 0, angles=angles)
    body.add(v, f, lambda i: GOLD if idx[i][0] in (0, rows - 1) or idx[i][1] in (0, cols - 1) else VEST, torso_w, X((0, 0, HIP)))
    v, f, _ = lathe([(r - 0.018, z) for r, z in vest_prof], 0, angles=angles)  # the inside, seen through the opening
    body.add(v, [tuple(reversed(q)) for q in f], VEST, torso_w, X((0, 0, HIP)))
    # belt and buckle, over the vest
    body.add(*cylinder(0.245, 0.245, 0.07, 18), MADDER, "hips", X((0, 0, HIP + 0.03)))
    body.add(*ellipsoid(0.045, 0.02, 0.04, 8, 6), GOLD, "hips", X((0, 0.245, HIP + 0.03)))
    # the sack's strap, diagonal round the body
    sash = 0.6
    body.add(*torus(0.25, 0.02, 16, 4), STRAP, "chest",
             X((0, 0, HIP + 0.24)) @ Euler((0, -sash, 0)).to_matrix().to_4x4() @ Matrix.Diagonal((1 / math.cos(sash), 1, 1, 1)))
    # the sack on his back, a patch, the knot
    sack_c = Vector((0, -0.24, HIP + 0.26))
    body.add(*ellipsoid(0.24, 0.16, 0.27, 12, 7), SACK, "sack", X(sack_c))
    body.add(*box(0.12, 0.03, 0.12), PATCH, "sack", X(sack_c + Vector((0.06, -0.15, 0.05))))
    body.add(*cylinder(0.05, 0.03, 0.07, 8), STRAP, "sack", X(sack_c + Vector((0, 0, 0.27))))
    # arms: puffed sleeve, forearm, a hand with a thumb
    for s, side in ((-1, "L"), (1, "R")):
        x = 0.25 * s
        body.add(*capsule(0.075, 0.2, 10, 3), SHIRT, f"upper_arm.{side}", X((x, 0, SHOULDER + 0.03)))
        body.add(*capsule(0.06, 0.18, 8, 3), SHIRT, f"lower_arm.{side}", X((x, 0, 0.77)))
        body.add(*ellipsoid(0.07, 0.07, 0.07, 8, 6), SKIN, f"hand.{side}", X((x, 0, 0.57)))
        body.add(*ellipsoid(0.032, 0.032, 0.032, 6, 4), SKIN, f"hand.{side}", X((x - s * 0.05, 0.03, 0.59)))
    # head, ears, hair at the back, tufts at the temples, nose
    body.add(*ellipsoid(0.3, 0.28, 0.29, 20, 11), SKIN, "head", X((0, 0, HEAD_C)))
    for s in (-1, 1):
        body.add(*ellipsoid(0.05, 0.05, 0.08, 8, 6), SKIN, "head", X((0.29 * s, 0, HEAD_C - 0.01)))
        body.add(*ellipsoid(0.06, 0.06, 0.08, 8, 6), HAIR, "head", X((0.2 * s, 0.12, HEAD_C + 0.08)))
    body.add(*ellipsoid(0.29, 0.22, 0.2, 14, 7), HAIR, "head", X((0, -0.08, HEAD_C + 0.08)))
    face.add(*ellipsoid(0.05, 0.04, 0.04, 8, 6), NOSE, "head", X((0, 0.275, HEAD_C - 0.06)))
    # the papaq: a red crown, a dark fur band, a rounded top and a gold knot
    body.add(*cylinder(0.26, 0.24, 0.22, 18), RED, "head", X((0, 0, HEAD + 0.42)))
    body.add(*torus(0.255, 0.045, 18, 5), RED_DARK, "head", X((0, 0, HEAD + 0.33)))
    body.add(*ellipsoid(0.24, 0.24, 0.07, 16, 4), RED, "head", X((0, 0, HEAD + 0.53)))
    body.add(*ellipsoid(0.04, 0.04, 0.04, 8, 6), GOLD, "head", X((0, 0, HEAD + 0.605)))
    # the face: big eyes (each on a bone that squashes to blink), glints, brows, cheeks, the smile and the "O"
    for s, side in ((-1, "L"), (1, "R")):
        ex = 0.11 * s
        e = Vector((ex, 0.235, HEAD_C + 0.02))
        face.add(*ellipsoid(0.085, 0.06, 0.1, 10, 6), EYE_W, f"eye.{side}", X(e))
        face.add(*ellipsoid(0.048, 0.03, 0.058, 8, 5), PUPIL, f"eye.{side}", X(e + Vector((0.0, 0.042, -0.01))))
        face.add(*ellipsoid(0.016, 0.01, 0.016, 6, 4), EYE_W, f"eye.{side}", X(e + Vector((0.015, 0.07, 0.012))))
        tilt = -0.15 * s  # inner ends up: a bright, cheeky look
        face.add(*box(0.1, 0.03, 0.024), HAIR, "head", X((ex, 0.255, HEAD_C + 0.15), (0, tilt, 0)))
        face.add(*ellipsoid(0.05, 0.02, 0.03, 8, 4), CHEEK, "head", X((0.176 * s, 0.225, HEAD_C - 0.1)))
    pts = []
    for i in range(9):  # the smile follows the face's curve
        t = -1.0 + 2.0 * i / 8
        x = 0.075 * t
        z = HEAD_C - 0.15 - 0.032 * (1.0 - t * t)
        y = 0.28 * math.sqrt(max(0.0, 1.0 - (x / 0.3) ** 2 - ((z - HEAD_C) / 0.29) ** 2)) + 0.006
        pts.append(Vector((x, y, z)))
    face.add(*tube(pts, 0.013, 6), MOUTH, "mouth_smile")
    face.add(*ellipsoid(0.04, 0.02, 0.05, 10, 6), MOUTH_O, "mouth_o", X((0, 0.232, HEAD_C - 0.17)))
    return body, face


def make_mesh(name, part):
    me = bpy.data.meshes.new(name)
    me.from_pydata([tuple(p) for p in part.v], [], part.f)
    me.validate()
    col = me.color_attributes.new("Col", "BYTE_COLOR", "CORNER")
    for poly in me.polygons:
        r, g, b = hex_rgb(part.fc[poly.index])
        for li in poly.loop_indices:
            col.data[li].color_srgb = (r, g, b, 1.0)
    me.color_attributes.active_color = col
    me.color_attributes.render_color_index = 0
    for poly in me.polygons:
        poly.use_smooth = True
    me.set_sharp_from_angle(angle=math.radians(50))
    ob = bpy.data.objects.new(name, me)
    bpy.context.scene.collection.objects.link(ob)
    groups = {}
    for i, w in enumerate(part.w):
        for bone, val in w.items():
            if val <= 0.0:
                continue
            if bone not in groups:
                groups[bone] = ob.vertex_groups.new(name=bone)
            groups[bone].add([i], val, "REPLACE")
    return ob


def toon_material():
    m = bpy.data.materials.new("toon")
    nt = m.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    vc = nt.nodes.new("ShaderNodeVertexColor")
    vc.layer_name = "Col"
    nt.links.new(vc.outputs["Color"], bsdf.inputs["Base Color"])
    bsdf.inputs["Roughness"].default_value = 0.85
    return m


# --- the armature ----------------------------------------------------------------------------------------------------
BONES = [  # name, head, tail, parent
    ("hips", (0, 0, HIP), (0, 0, 0.64), None),
    ("spine", (0, 0, 0.64), (0, 0, 0.78), "hips"),
    ("chest", (0, 0, 0.78), (0, 0, 1.0), "spine"),
    ("neck", (0, 0, 1.0), (0, 0, HEAD), "chest"),
    ("head", (0, 0, HEAD), (0, 0, 1.62), "neck"),
    ("eye.L", (-0.11, 0.235, HEAD_C + 0.02), (-0.11, 0.33, HEAD_C + 0.02), "head"),
    ("eye.R", (0.11, 0.235, HEAD_C + 0.02), (0.11, 0.33, HEAD_C + 0.02), "head"),
    ("mouth_smile", (0, 0.24, HEAD_C - 0.17), (0, 0.32, HEAD_C - 0.17), "head"),
    ("mouth_o", (0, 0.232, HEAD_C - 0.17), (0, 0.31, HEAD_C - 0.17), "head"),
    ("sack", (0, -0.24, HIP + 0.26), (0, -0.24, HIP + 0.5), "chest"),
]
for _s, _sd in ((-1, "L"), (1, "R")):
    BONES += [
        (f"upper_arm.{_sd}", (0.25 * _s, 0, SHOULDER), (0.25 * _s, 0, 0.75), "chest"),
        (f"lower_arm.{_sd}", (0.25 * _s, 0, 0.75), (0.25 * _s, 0, 0.6), f"upper_arm.{_sd}"),
        (f"hand.{_sd}", (0.25 * _s, 0, 0.6), (0.25 * _s, 0, 0.5), f"lower_arm.{_sd}"),
        (f"upper_leg.{_sd}", (0.12 * _s, 0, HIP), (0.12 * _s, 0, 0.32), "hips"),
        (f"lower_leg.{_sd}", (0.12 * _s, 0, 0.32), (0.12 * _s, 0, 0.1), f"upper_leg.{_sd}"),
        (f"foot.{_sd}", (0.12 * _s, 0, 0.1), (0.12 * _s, 0.18, 0.04), f"lower_leg.{_sd}"),
    ]


def make_armature():
    arm = bpy.data.armatures.new("CirtdanRig")
    ob = bpy.data.objects.new("Armature", arm)
    bpy.context.scene.collection.objects.link(ob)
    bpy.context.view_layer.objects.active = ob
    bpy.ops.object.mode_set(mode="EDIT")
    for name, h, t, parent in BONES:
        eb = arm.edit_bones.new(name)
        eb.head, eb.tail, eb.roll = h, t, 0.0
        eb.use_deform = True
        if parent:
            eb.parent = arm.edit_bones[parent]
    bpy.ops.object.mode_set(mode="OBJECT")
    for pb in ob.pose.bones:
        pb.rotation_mode = "QUATERNION"
    return ob


# --- animation: poses given as rotations about armature (world) axes, relative to the parent --------------------
def rest_rot(ob, bone):
    return ob.data.bones[bone].matrix_local.to_3x3()


def apply_pose(ob, pose):
    """pose: bone -> (rx, ry, rz) world-axis Euler radians; "hips_up"/"hips_fwd" metres; "scale:<bone>" -> (sx, sy, sz)
    along world axes. Bones not named go to rest. +X rotation swings a hanging limb forward (+Y) and tips an upright
    bone backward."""
    for pb in ob.pose.bones:
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.location = (0, 0, 0)
        pb.scale = (1, 1, 1)
    for k, val in pose.items():
        if k in ("hips_up", "hips_fwd"):
            continue
        if k.startswith("scale:"):
            b = k[6:]
            R = rest_rot(ob, b)
            loc = R.inverted() @ Vector(val)  # world-axis scale -> local axes (bones here are axis-aligned)
            ob.pose.bones[b].scale = tuple(abs(c) for c in loc)
            continue
        R = rest_rot(ob, k)
        q = (R.inverted() @ Euler(val, "XYZ").to_matrix() @ R).to_quaternion()
        ob.pose.bones[k].rotation_quaternion = q
    d = Vector((0, pose.get("hips_fwd", 0.0), pose.get("hips_up", 0.0)))
    ob.pose.bones["hips"].location = rest_rot(ob, "hips").inverted() @ d


def key_all(ob, frame):
    for pb in ob.pose.bones:
        pb.keyframe_insert("rotation_quaternion", frame=frame)
        pb.keyframe_insert("location", frame=frame)
        pb.keyframe_insert("scale", frame=frame)


HIDE = (0.001, 0.001, 0.001)


def base_face(pose, gasp=False):
    pose["scale:mouth_o"] = (1, 1, 1) if gasp else HIDE
    pose["scale:mouth_smile"] = HIDE if gasp else (1, 1, 1)
    return pose


def limbs(pose, leg_l, leg_r, knee_l, knee_r, arm_l, arm_r, elbow_l, elbow_r, spread=0.15):
    pose["upper_leg.L"] = (leg_l, 0, 0)
    pose["upper_leg.R"] = (leg_r, 0, 0)
    pose["lower_leg.L"] = (knee_l, 0, 0)
    pose["lower_leg.R"] = (knee_r, 0, 0)
    pose["upper_arm.L"] = (arm_l, spread, 0)
    pose["upper_arm.R"] = (arm_r, -spread, 0)
    pose["lower_arm.L"] = (elbow_l, 0, 0)
    pose["lower_arm.R"] = (elbow_r, 0, 0)
    return pose


def pose_run(ph):
    run = math.sin(ph)
    bounce = abs(math.cos(ph))
    p = limbs({}, run * 0.95, -run * 0.95,
              -(0.15 + max(0.0, -math.sin(ph + 0.7)) * 1.3), -(0.15 + max(0.0, -math.sin(ph + 0.7 + math.pi)) * 1.3),
              -run * 1.0, run * 1.0, 1.1 + bounce * 0.15, 1.1 + bounce * 0.15)
    p["foot.L"] = (max(0.0, -run) * 0.5, 0, 0)
    p["foot.R"] = (max(0.0, run) * 0.5, 0, 0)
    p["spine"] = (-0.12, 0, -run * 0.12)  # leaning into the run, shoulders twisting against the hips
    p["chest"] = (-0.08, 0, -run * 0.1)
    p["head"] = (0.15 + math.sin(ph * 2) * 0.05, 0, run * 0.15)
    p["sack"] = (math.sin(ph * 2 + 1.0) * 0.12, 0, 0)
    p["hips_up"] = bounce * 0.07 - 0.03
    return base_face(p)


def pose_idle(t, w):
    run = math.sin(t * w)
    bounce = abs(math.cos(t * w))
    p = limbs({}, max(0.0, run) * 0.6, max(0.0, -run) * 0.6, -0.1 - max(0.0, run) * 0.5, -0.1 - max(0.0, -run) * 0.5,
              2.5 + math.sin(t * 2 * w) * 0.4, 2.5 - math.sin(t * 2 * w) * 0.4, 0.4, 0.4, spread=0.35)
    p["spine"] = (0, -math.sin(t * w) * 0.12, 0)
    p["head"] = (math.sin(t * w) * 0.1, math.sin(t * w) * 0.1, 0)
    p["sack"] = (0, math.sin(t * w + 0.8) * 0.1, 0)
    p["hips_up"] = bounce * 0.06
    return base_face(p)


def pose_jump(u):
    """u: 0 take-off, 0.5 apex, 1 landing."""
    up = 1.0 - 2.0 * u  # +1 rising, -1 falling
    rise = max(0.0, up)
    fall = max(0.0, -up)
    p = limbs({}, 1.1 * rise + 0.5 * fall, -0.4 * rise + 0.2 * fall, -1.7 * rise - 0.4 * fall, -1.5 * rise - 0.2 * fall,
              2.6 * rise + 2.2 * fall, 2.2 * rise + 2.5 * fall, 0.3, 0.3, spread=0.3 + 0.3 * fall)
    p["spine"] = (-0.25 * up, 0, 0)
    p["head"] = (0.2 * up, 0, 0)
    p["sack"] = (0.35 * up, 0, 0)
    p["foot.L"] = (0.4 * rise, 0, 0)
    p["foot.R"] = (0.6 * rise, 0, 0)
    return base_face(p, gasp=up > 0.2)


def pose_slide(k):
    p = limbs({}, 1.45 * k, 1.1 * k, -0.15 * k, -0.9 * k, -0.9 * k, -0.6 * k, 0.3, 0.5, spread=0.15 + 0.5 * k)
    p["spine"] = (0.75 * k, 0, 0)
    p["chest"] = (0.25 * k, 0, 0)
    p["head"] = (-0.6 * k, 0, 0)  # chin down: he still looks where he slides
    p["sack"] = (-0.4 * k, 0, 0)
    p["hips_up"] = -0.3 * k
    return base_face(p)


def pose_stumble(t):
    f = math.sin(t * 2 * math.pi * 2)  # two flails a cycle
    p = limbs({}, 0.5 + 0.3 * f, -0.4 - 0.3 * f, -0.6, -0.4, 2.0 + f * 0.8, 2.0 - f * 0.8, 0.6, 0.6, spread=0.6)
    p["spine"] = (0.25, 0, f * 0.12)
    p["head"] = (0.3, 0, -f * 0.15)
    p["sack"] = (0.3 * f, 0, 0)
    p["hips_up"] = -0.04 + 0.03 * f
    p["scale:eye.L"] = (1.1, 1, 1.2)
    p["scale:eye.R"] = (1.1, 1, 1.2)
    return base_face(p, gasp=True)


def pose_fly(t, w):
    s = math.sin(t * w)
    p = limbs({}, 0.25 + s * 0.15, -0.1 + math.sin(t * w + 1.0) * 0.15, -0.6 + s * 0.2, -0.4 + math.sin(t * w + 1.0) * 0.2,
              2.95, 2.95, 0.15, 0.15, spread=0.12)
    p["spine"] = (0.05, 0, s * 0.08)
    p["head"] = (0.15, 0, -s * 0.1)
    p["sack"] = (0.2 + s * 0.1, 0, 0)
    p["hips_up"] = s * 0.04
    return base_face(p)


def clips():
    """name -> (frame count, step, pose fn of frame)."""
    run_n = 16
    idle_n = 60
    fly_n = 60
    return {
        "run": (run_n, 2, lambda f: pose_run(2 * math.pi * f / run_n)),
        "jump": (24, 3, lambda f: pose_jump(f / 24.0)),
        "slide": (24, 3, lambda f: pose_slide(min(1.0, f / 6.0))),
        "stumble": (18, 1, lambda f: pose_stumble(f / 18.0)),
        "idle": (idle_n, 3, lambda f: pose_idle(f / FPS, 2 * math.pi / (idle_n / FPS))),
        "fly": (fly_n, 4, lambda f: pose_fly(f / FPS, 2 * math.pi / (fly_n / FPS))),
    }


def make_actions(ob):
    ob.animation_data_create()
    made = {}
    for name, (n, step, fn) in clips().items():
        act = bpy.data.actions.new(name)
        act.use_fake_user = True
        ob.animation_data.action = act
        frames = list(range(0, n + 1, step))
        if frames[-1] != n:
            frames.append(n)
        for fr in frames:
            apply_pose(ob, fn(fr))
            key_all(ob, fr)
        made[name] = act
        ob.animation_data.action = None
        track = ob.animation_data.nla_tracks.new()
        track.name = name
        strip = track.strips.new(name, 0, act)
        strip.name = name
        track.mute = True
    apply_pose(ob, {"scale:mouth_o": HIDE})
    return made


# --- preview renders ------------------------------------------------------------------------------------------------
def render_previews(out_dir, arm, made):
    os.makedirs(out_dir, exist_ok=True)
    sc = bpy.context.scene
    try:
        sc.render.engine = "BLENDER_WORKBENCH"
        sc.display.shading.light = "STUDIO"
        sc.display.shading.color_type = "VERTEX"
        sc.display.shading.show_object_outline = True
        sc.display.shading.show_cavity = False
    except Exception as e:  # noqa: BLE001
        print("workbench setup:", e)
    sc.render.resolution_x, sc.render.resolution_y = 480, 600
    sc.render.film_transparent = False
    world = bpy.data.worlds.new("w")
    world.color = (0.55, 0.62, 0.7)
    sc.world = world
    cam_data = bpy.data.cameras.new("cam")
    cam_data.lens = 50
    cam = bpy.data.objects.new("cam", cam_data)
    sc.collection.objects.link(cam)
    sc.camera = cam
    views = [("front", 0.0, None, 0), ("threeq", 40.0, None, 0), ("back", 180.0, None, 0),
             ("run", 210.0, "run", 4), ("jump", 90.0, "jump", 7), ("slide", 70.0, "slide", 20),
             ("idle", 20.0, "idle", 15), ("fly", 200.0, "fly", 10), ("stumble", 30.0, "stumble", 4)]
    target = Vector((0, 0, 0.85))
    for name, deg, act, fr in views:
        arm.animation_data.action = made[act] if act else None
        if act is None:
            apply_pose(arm, {"scale:mouth_o": HIDE})
        sc.frame_set(fr)
        a = math.radians(deg)
        pos = target + Vector((math.sin(a) * 4.2, math.cos(a) * 4.2, 0.5))
        cam.location = pos
        cam.rotation_euler = (target - pos).to_track_quat("-Z", "Y").to_euler()
        sc.render.filepath = os.path.join(out_dir, f"cirtdan_{name}.png")
        bpy.ops.render.render(write_still=True)
    arm.animation_data.action = None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default="assets/models/char_cirtdan_blender.glb")  # the game draws the Tripo one
    ap.add_argument("--preview", default="")
    a = ap.parse_args(sys.argv[1:])
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.fps = FPS
    body_p, face_p = build_parts()
    arm = make_armature()
    mat = toon_material()
    tris = 0
    for name, part in (("Body", body_p), ("Face", face_p)):
        ob = make_mesh(name, part)
        ob.data.materials.append(mat)
        ob.parent = arm
        mod = ob.modifiers.new("Armature", "ARMATURE")
        mod.object = arm
        ob.data.calc_loop_triangles()
        tris += len(ob.data.loop_triangles)
    print(f"triangles: {tris} (budget {TRI_BUDGET}), bones: {len(arm.data.bones)}, materials: 1")
    assert tris <= TRI_BUDGET, "over the triangle budget"
    made = make_actions(arm)
    if a.preview:
        render_previews(a.preview, arm, made)
    out = os.path.abspath(a.out)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    kw = dict(filepath=out, export_format="GLB", export_yup=True, export_apply=False, export_animations=True,
              export_animation_mode="ACTIONS", export_skins=True, export_def_bones=False, export_force_sampling=True,
              export_frame_range=False, export_nla_strips=True, export_optimize_animation_size=False,
              export_vertex_color="ACTIVE", export_materials="EXPORT")
    while True:
        try:
            bpy.ops.export_scene.gltf(**kw)
            break
        except TypeError as e:  # an option this exporter version does not know: drop it and retry
            bad = [k for k in kw if k in str(e) and k != "filepath"]
            if not bad:
                raise
            print("exporter: dropping", bad[0])
            kw.pop(bad[0])
    print("wrote", out, os.path.getsize(out), "bytes; clips:", ", ".join(made))


if __name__ == "__main__":
    main()
