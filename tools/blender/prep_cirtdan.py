"""Prepares the Tripo3D-made hero Cirtdan for the game: a rigged, animated glTF (.glb), headless and re-runnable.

Usage (Blender as a Python module, `pip install bpy`):
    python tools/blender/prep_cirtdan.py [--in assets/incoming/char_cirtdan_tripo.glb]
        [--out assets/models/char_cirtdan.glb] [--preview DIR] [--height 1.785] [--tris 5000] [--tex 512]

What it does to the Tripo export (1 skinned mesh, 1 textured material, a humanoid rig, clips run.001, dive.001,
fall.001, jump_down.001, wait.001):
- drops the importer's stray bone-shape Icosphere;
- scales the rig so the top of the papaq is at --height (the Blender pilot / procedural figure: 1.785 m) with the
  origin at the feet; the scale lives on the armature node's transform, so the clips' bone-local keys stay valid.
  The Tripo export faces Blender -Y (Godot +Z): it is turned to face Blender +Y = Godot -Z, the way the runner
  runs, on the same node (checked in the game's menu, where he faces the camera);
- decimates the mesh to <= --tris triangles (collapse, which interpolates the skin weights) and the texture to
  <= --tex px;
- re-bakes the clips from frame ranges of the source clips (table CLIPS): the hips' horizontal drift is locked
  (the runner stays in place; the game moves the holder), and "ground" clips put the lowest body point on the
  floor every frame (jump_down starts on a ledge; the roll and the fall go head-down);
- adds "fly" (no source clip): the rest T-pose with the arms lowered a little and waving, legs trailing, a lean.
Clips out: run, idle, fly (loops; looped in Godot by GlbRunner), jump (seeked by vertical speed: start = take-off,
middle = apex, end = landing), slide (a forward roll, ends low), stumble (a trip back and recover, loops), fall
(collapses and holds: death).
"""
import argparse
import math
import os
import sys

import bpy
import numpy as np
from mathutils import Euler, Quaternion, Vector

# name: (source action, first frame, last frame, output frames, ground, ping-pong)
CLIPS = {
    "run": ("run.001", 1, 31, 30, False, False),
    "idle": ("wait.001", 1, 145, 144, False, False),
    "jump": ("jump_down.001", 31, 54, 24, True, False),
    "slide": ("dive.001", 29, 57, 16, True, False),  # 16 frames at 24 fps ~ tune.slide_time 0.65 s
    "stumble": ("fall.001", 1, 24, 10, True, True),
    "fall": ("fall.001", 1, 73, 48, True, False),
}
FEET = ["Left_Foot", "Left_Toes", "Left_ToesEnd", "Right_Foot", "Right_Toes", "Right_ToesEnd"]
LOW = FEET + ["Hips", "Head", "Left_Hand", "Right_Hand", "Left_LowerArm", "Right_LowerArm"]


def setup(path):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=path)
    for o in list(bpy.data.objects):
        if o.type == "MESH" and o.parent is None:  # the importer's bone-shape icosphere
            bpy.data.objects.remove(o)
    arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    body = next(o for o in bpy.data.objects if o.type == "MESH")
    body.name = "Body"
    ad = arm.animation_data
    for t in list(ad.nla_tracks):
        ad.nla_tracks.remove(t)
    ad.action = None
    for pb in arm.pose.bones:
        pb.rotation_mode = "QUATERNION"
    return arm, body


def use(arm, act):
    arm.animation_data.action = act
    if act is not None and act.slots:
        arm.animation_data.action_slot = act.slots[0]


def heights(arm):
    """Lowest and highest points of the posed body (armature space): bone heads plus the head's tail."""
    pts = [arm.pose.bones[b].head.z for b in LOW] + [arm.pose.bones["Head"].tail.z]
    return min(pts), max(pts)


def sample(arm, act, fr, ground, rest_low):
    sc = bpy.context.scene
    use(arm, act)
    sc.frame_set(int(math.floor(fr)), subframe=fr - math.floor(fr))
    pose = {pb.name: (pb.location.copy(), pb.rotation_quaternion.copy(), pb.scale.copy()) for pb in arm.pose.bones}
    hips = arm.data.bones["Hips"]
    rot = hips.matrix_local.to_3x3()
    delta = arm.pose.bones["Hips"].head - hips.head_local  # where the hips went, armature space
    delta.x = delta.y = 0.0  # stay in place: the game moves the runner
    if ground:
        delta.z -= heights(arm)[0] - rest_low
    pose["Hips"] = (rot.inverted() @ delta, pose["Hips"][1], pose["Hips"][2])
    return pose


def key(arm, act, frame, pose, prev):
    use(arm, act)
    for name, (loc, q, s) in pose.items():
        pb = arm.pose.bones[name]
        if name in prev and prev[name][1].dot(q) < 0.0:
            q = -q  # keep quaternions on one hemisphere so the interpolation takes the short way
        pb.location, pb.rotation_quaternion, pb.scale = loc, q, s
        pb.keyframe_insert("location", frame=frame)
        pb.keyframe_insert("rotation_quaternion", frame=frame)
        pb.keyframe_insert("scale", frame=frame)
        pose[name] = (loc, q, s)


def bake(arm, name, src, f0, f1, n, ground, pingpong, rest_low):
    poses = [sample(arm, src, f0 + (f1 - f0) * i / n, ground, rest_low) for i in range(n + 1)]
    if pingpong:
        poses += poses[-2::-1]
    act = bpy.data.actions.new(name)
    prev = {}
    for i, p in enumerate(poses):
        key(arm, act, i, p, prev)
        prev = p
    return act


def arm_rot(arm, bone, euler_deg):
    """A rotation given about armature axes (degrees) as the bone's local pose rotation."""
    r = arm.data.bones[bone].matrix_local.to_quaternion()
    q = Euler([math.radians(v) for v in euler_deg]).to_quaternion()
    return r.inverted() @ q @ r


def make_fly(arm, n=24):
    """Arms out and waving, legs trailing, a lean forward. Armature space: the model faces -Y (it is turned later)."""
    act = bpy.data.actions.new("fly")
    prev = {}
    for i in range(n + 1):
        w = math.sin(TAU * i / n)
        rots = {
            "Hips": (18 + 2 * w, 0, 0),  # +X tips the top forward (-Y)
            "Chest": (-8, 0, 0),
            "Head": (-14, 0, 0),
            "Left_UpperArm": (0, 22 + 10 * w, 0),  # +Y lowers the arm on +X, -Y the one on -X
            "Right_UpperArm": (0, -22 - 10 * w, 0),
            "Left_LowerArm": (0, -8 * w, 0),
            "Right_LowerArm": (0, 8 * w, 0),
            "Left_UpperLeg": (28 + 4 * w, 0, 3),  # +X swings a hanging leg back (+Y)
            "Right_UpperLeg": (22 - 4 * w, 0, -3),
            "Left_LowerLeg": (38, 0, 0),
            "Right_LowerLeg": (48, 0, 0),
        }
        pose = {pb.name: (Vector(), Quaternion(), Vector((1, 1, 1))) for pb in arm.pose.bones}
        for b, e in rots.items():
            pose[b] = (Vector(), arm_rot(arm, b, e), Vector((1, 1, 1)))
        key(arm, act, i, pose, prev)
        prev = pose
    return act


TAU = math.tau


def decimate(body, budget):
    body.data.calc_loop_triangles()
    tris = len(body.data.loop_triangles)
    if tris > budget:
        mod = body.modifiers.new("Decimate", "DECIMATE")
        mod.ratio = budget * 0.97 / tris
        bpy.context.view_layer.objects.active = body
        bpy.ops.object.modifier_move_to_index(modifier="Decimate", index=0)
        bpy.ops.object.modifier_apply(modifier="Decimate")
        body.data.calc_loop_triangles()
    return tris, len(body.data.loop_triangles)


def shrink_textures(body, size):
    out = []
    for m in body.data.materials:
        for nd in m.node_tree.nodes:
            if nd.type == "TEX_IMAGE" and nd.image is not None:
                img = nd.image
                if max(img.size) > size:
                    img.scale(size, size)
                    img.pack()
                out.append((img.name, tuple(img.size)))
    return out


def render_previews(out_dir, arm, shots):
    """shots: (file name, action or None, frame, camera yaw in degrees: 0 = in front of him)."""
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"
    sc.cycles.samples = 12
    sc.cycles.device = "CPU"
    sc.render.resolution_x, sc.render.resolution_y = 240, 300
    world = bpy.data.worlds.new("w")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.62, 0.7, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = 1.6
    sc.world = world
    sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN"))
    sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(40), 0, math.radians(30))
    sc.collection.objects.link(sun)
    cam = bpy.data.objects.new("cam", bpy.data.cameras.new("cam"))
    cam.data.type = "ORTHO"
    cam.data.ortho_scale = 2.4
    sc.collection.objects.link(cam)
    sc.camera = cam
    os.makedirs(out_dir, exist_ok=True)
    files = []
    for name, act, fr, yaw in shots:
        use(arm, act)
        sc.frame_set(fr)
        a = math.radians(yaw)
        target = Vector((0, 0, 0.9))
        pos = target + Vector((math.sin(a) * 5, math.cos(a) * 5, 0.6))  # he faces +Y once turned
        cam.location = pos
        cam.rotation_euler = (target - pos).to_track_quat("-Z", "Y").to_euler()
        sc.render.filepath = os.path.join(out_dir, f"{name}.png")
        bpy.ops.render.render(write_still=True)
        files.append(sc.render.filepath)
    use(arm, None)
    sheet(files, 6, os.path.join(out_dir, "sheet.png"))


def sheet(files, cols, out):
    tiles = []
    for f in files:
        im = bpy.data.images.load(f)
        w, h = im.size
        tiles.append(np.array(im.pixels[:], dtype=np.float32).reshape(h, w, 4))
    h, w = tiles[0].shape[:2]
    rows = (len(tiles) + cols - 1) // cols
    canvas = np.ones((rows * h, cols * w, 4), dtype=np.float32)
    for i, t in enumerate(tiles):
        r, c = rows - 1 - i // cols, i % cols  # Blender images are bottom-up
        canvas[r * h:(r + 1) * h, c * w:(c + 1) * w] = t
    img = bpy.data.images.new("sheet", cols * w, rows * h, alpha=True)
    img.pixels.foreach_set(canvas.ravel())
    img.filepath_raw = out
    img.file_format = "PNG"
    img.save()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="src", default="assets/incoming/char_cirtdan_tripo.glb")
    ap.add_argument("--out", default="assets/models/char_cirtdan.glb")
    ap.add_argument("--preview", default="")
    ap.add_argument("--height", type=float, default=1.785, help="papaq top, m (the pilot and procedural figure)")
    ap.add_argument("--tris", type=int, default=5000)
    ap.add_argument("--tex", type=int, default=512)
    a = ap.parse_args(sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else sys.argv[1:])
    arm, body = setup(os.path.abspath(a.src))
    assert len(body.data.materials) == 1, "expected one material"
    rest_low, rest_top = heights(arm)
    zs = [(body.matrix_world @ v.co).z for v in body.data.vertices]
    top = max(zs)
    src = {act.name: act for act in bpy.data.actions}
    made = {n: bake(arm, n, src[s], f0, f1, k, g, pp, rest_low) for n, (s, f0, f1, k, g, pp) in CLIPS.items()}
    made["fly"] = make_fly(arm)
    for act in src.values():
        bpy.data.actions.remove(act)
    use(arm, None)
    for pb in arm.pose.bones:
        pb.location, pb.rotation_quaternion, pb.scale = Vector(), Quaternion(), Vector((1, 1, 1))
    arm.rotation_mode = "XYZ"  # the importer leaves it in quaternion mode, which ignores rotation_euler
    arm.rotation_euler = (0, 0, math.pi)  # face Blender +Y = Godot -Z
    k = a.height / top
    arm.scale = (k, k, k)
    t0, t1 = decimate(body, a.tris)
    texs = shrink_textures(body, a.tex)
    print(f"height {top:.3f} -> {a.height} (x{k:.3f}); triangles {t0} -> {t1} (budget {a.tris}); textures {texs}; "
          f"bones {len(arm.data.bones)}; materials {len(body.data.materials)}")
    assert t1 <= a.tris, "over the triangle budget"
    if a.preview:
        L = {n: int(act.frame_range[1]) for n, act in made.items()}
        shots = [("rest_front", None, 0, 0), ("rest_34", None, 0, 40), ("rest_back", None, 0, 180),
                 ("idle_front", made["idle"], 30, 0)]
        shots += [(f"run_{i}", made["run"], i * L["run"] // 4, 70) for i in range(4)]
        shots += [(f"jump_{i}", made["jump"], i * L["jump"] // 4, 70) for i in range(5)]
        shots += [(f"slide_{i}", made["slide"], i * L["slide"] // 4, 70) for i in range(5)]
        shots += [(f"stumble_{i}", made["stumble"], i * L["stumble"] // 2, 70) for i in range(2)]
        shots += [("fall_end", made["fall"], L["fall"], 70), ("fly_0", made["fly"], 0, 70),
                  ("fly_back", made["fly"], 6, 160), ("run_back", made["run"], 7, 180)]
        render_previews(os.path.abspath(a.preview), arm, shots)
    out = os.path.abspath(a.out)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    arm.select_set(True)
    body.select_set(True)
    kw = dict(filepath=out, export_format="GLB", use_selection=True, export_yup=True, export_apply=False,
              export_animations=True, export_animation_mode="ACTIONS", export_skins=True, export_def_bones=False,
              export_force_sampling=True, export_frame_range=False, export_optimize_animation_size=False,
              export_image_format="AUTO", export_materials="EXPORT")
    while True:
        try:
            bpy.ops.export_scene.gltf(**kw)
            break
        except TypeError as e:  # an option this exporter version does not know: drop it and retry
            bad = [x for x in kw if x in str(e) and x != "filepath"]
            if not bad:
                raise
            print("exporter: dropping", bad[0])
            kw.pop(bad[0])
    print("wrote", out, os.path.getsize(out), "bytes; clips:", ", ".join(made))


if __name__ == "__main__":
    main()
