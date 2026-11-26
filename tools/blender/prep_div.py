"""Prepares the owner's Tripo3D Div (assets/incoming/char_div_tripo.glb) for the game, headless and re-runnable.

Usage (Blender as a Python module, `pip install bpy`; run with -I so nothing next to the input is imported):
    python -I tools/blender/prep_div.py --in assets/incoming/char_div_tripo.glb --out assets/models/char_div.glb \
        [--preview DIR] [--height 3.75] [--tris 7800] [--tex 512]

Spec: design/art/art-bible.md section 5 (the Div: big, round, always behind) and section 8 (Asset Standards:
the Div <= 8k triangles, hero textures 256-512 px, <= 4 materials, origin at the feet, 1 unit = 1 m).
What it does:
- drops the importer's bone-display icosphere; merges exact duplicate vertices;
- scales the model (bones, mesh and the run clip's translations) to --height metres, the procedural Div's height
  (Characters.div() is ~3.78 m before game.gd's 0.85), origin kept at the feet;
- decimates (collapse) the skinned mesh to <= --tris triangles; vertex-group weights are interpolated by the
  collapse, then normalised and limited to 4 influences (what glTF carries);
- downsizes the texture to --tex px (PNG on export: Godot 4.7.2 could not decode the exporter's JPEG); one material;
- clips: run (Tripo's "run.001", renamed; loops), idle (breathing, loops) and catch (rear back, lunge and grab;
  plays once, holds the last frame), keyed on the Tripo humanoid bones (Hips, Spine, Chest, UpperChest, Neck,
  Head, Left_/Right_ Shoulder, UpperArm, LowerArm, Hand, UpperLeg, LowerLeg, Foot).
- Facing: the model faces Blender -Y = glTF/Godot +Z, like Characters.div(); game.gd turns the holder by PI.
"""
import argparse
import math
import tempfile
import os
import sys

import bpy
from mathutils import Euler, Matrix, Vector

FPS = 24  # the Tripo run clip's own rate


def rest_rot(ob, bone):
    return ob.data.bones[bone].matrix_local.to_3x3()


def apply_pose(ob, pose):
    """pose: bone -> (rx, ry, rz) Euler radians about armature axes, relative to the parent; "hips_up"/"hips_fwd"
    metres (fwd = toward the face, -Y). Bones not named go to rest. +X tips an upright bone forward (toward -Y);
    -X swings a hanging arm forward and up."""
    for pb in ob.pose.bones:
        pb.rotation_mode = "QUATERNION"
        pb.rotation_quaternion = (1, 0, 0, 0)
        pb.location = (0, 0, 0)
        pb.scale = (1, 1, 1)
    for k, val in pose.items():
        if k in ("hips_up", "hips_fwd"):
            continue
        R = rest_rot(ob, k)
        ob.pose.bones[k].rotation_quaternion = (R.inverted() @ Euler(val, "XYZ").to_matrix() @ R).to_quaternion()
    d = Vector((0, -pose.get("hips_fwd", 0.0), pose.get("hips_up", 0.0)))
    ob.pose.bones["Hips"].location = rest_rot(ob, "Hips").inverted() @ d


def key_all(ob, frame):
    for pb in ob.pose.bones:
        pb.keyframe_insert("rotation_quaternion", frame=frame)
        pb.keyframe_insert("location", frame=frame)


def mirror(pose, bone_l, val):
    """Puts val on the Left_ bone and its mirror (Y and Z rotations flipped) on the Right_ bone."""
    pose["Left_" + bone_l] = val
    pose["Right_" + bone_l] = (val[0], -val[1], -val[2])


def pose_idle(fr):
    """Breathing: 2 s loop. The chest swells, the shoulders rise, the head sways; arms hang a little out."""
    w = math.sin(fr / (2 * FPS) * 2 * math.pi)
    p = {"Chest": (-0.04 * w, 0, 0), "UpperChest": (-0.03 * w, 0, 0), "Head": (0.05 * w, 0.0, 0.06 * w),
         "Spine": (0.06, 0, 0), "hips_up": -0.03 + 0.02 * w}
    mirror(p, "Shoulder", (0, 0, 0.05 * w))
    mirror(p, "UpperArm", (-0.1, 0, 0.12 + 0.03 * w))
    mirror(p, "LowerArm", (-0.35, 0, 0))
    mirror(p, "UpperLeg", (-0.08, 0, 0))
    mirror(p, "LowerLeg", (0.16, 0, 0))
    mirror(p, "Foot", (-0.08, 0, 0))
    return p


def _lerp_pose(a, b, u):
    out = {}
    for k in set(a) | set(b):
        va, vb = a.get(k, (0, 0, 0) if k not in ("hips_up", "hips_fwd") else 0.0), b.get(k, (0, 0, 0) if k not in ("hips_up", "hips_fwd") else 0.0)
        if isinstance(va, tuple) or isinstance(vb, tuple):
            va = va if isinstance(va, tuple) else (0, 0, 0)
            vb = vb if isinstance(vb, tuple) else (0, 0, 0)
            out[k] = tuple(x + (y - x) * u for x, y in zip(va, vb))
        else:
            out[k] = va + (vb - va) * u
    return out


def _catch_keys():
    stand = pose_idle(0)
    rear = {"Spine": (-0.15, 0, 0), "Chest": (-0.2, 0, 0), "UpperChest": (-0.1, 0, 0), "Head": (-0.25, 0, 0),
            "hips_up": 0.05}
    mirror(rear, "UpperArm", (-2.7, 0, 0.35))  # both arms up: "Hamm!"
    mirror(rear, "LowerArm", (-0.3, 0, 0))
    mirror(rear, "UpperLeg", (0.1, 0, 0))
    lunge = {"Spine": (0.35, 0, 0), "Chest": (0.3, 0, 0), "UpperChest": (0.15, 0, 0), "Head": (-0.35, 0, 0),
             "hips_fwd": 0.45, "hips_up": -0.25}
    mirror(lunge, "UpperArm", (-1.25, 0, -0.25))  # arms forward and in: the grab
    mirror(lunge, "LowerArm", (-0.7, 0, 0.3))
    mirror(lunge, "Hand", (0.4, 0, 0))
    mirror(lunge, "UpperLeg", (-0.6, 0, 0))
    lunge["Right_UpperLeg"] = (0.35, 0, 0)  # one leg trailing behind
    mirror(lunge, "LowerLeg", (0.9, 0, 0))
    lunge["Right_LowerLeg"] = (0.5, 0, 0)
    mirror(lunge, "Foot", (-0.3, 0, 0))
    return [(0, stand), (7, rear), (11, rear), (17, lunge), (30, lunge)]


def pose_catch(fr):
    keys = _catch_keys()
    for (f0, a), (f1, b) in zip(keys, keys[1:]):
        if f0 <= fr <= f1:
            u = (fr - f0) / max(1, f1 - f0)
            return _lerp_pose(a, b, u * u * (3 - 2 * u))
    return keys[-1][1]


CLIPS = {"idle": (48, 4, pose_idle), "catch": (30, 1, pose_catch)}


def make_actions(ob):
    made = {}
    for name, (n, step, fn) in CLIPS.items():
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
    return made


def all_fcurves(act):
    try:
        return list(act.fcurves)
    except AttributeError:  # Blender 4.4+: layered (slotted) actions
        return [fc for ly in act.layers for st in ly.strips for cb in st.channelbags for fc in cb.fcurves]


def recentre_run(arm, act):
    """Tripo's run clip holds the hips ~0.5 model units in front of the rest pose and a little low (a constant
    offset, not travel). Shifts the Hips keys so the clip's mean hip position is over the origin and its lowest
    foot point touches the ground (as in the rest pose)."""
    sc = bpy.context.scene
    arm.animation_data.action = act
    feet = ["Left_Toes", "Right_Toes", "Left_ToesEnd", "Right_ToesEnd", "Left_Foot", "Right_Foot"]
    rest_low = min(arm.data.bones[b].head_local.z for b in feet)
    f0, f1 = int(act.frame_range[0]), int(act.frame_range[1])
    hx = hy = 0.0
    low = 1e9
    for f in range(f0, f1 + 1):
        sc.frame_set(f)
        h = arm.pose.bones["Hips"].head
        hx, hy = hx + h.x, hy + h.y
        low = min(low, min(arm.pose.bones[b].head.z for b in feet))
    n = f1 - f0 + 1
    rest = arm.data.bones["Hips"].head_local
    d_arm = Vector((rest.x - hx / n, rest.y - hy / n, rest_low - low))
    d_loc = rest_rot(arm, "Hips").inverted() @ d_arm
    for fc in all_fcurves(act):
        if fc.data_path == 'pose.bones["Hips"].location':
            for kp in fc.keyframe_points:
                for c in (kp.co, kp.handle_left, kp.handle_right):
                    c[1] += d_loc[fc.array_index]
    arm.animation_data.action = None
    sc.frame_set(0)
    return d_arm


# --- preview renders ------------------------------------------------------------------------------------------------
def render_previews(out_dir, arm, made, height):
    os.makedirs(out_dir, exist_ok=True)
    sc = bpy.context.scene
    sc.render.engine = "CYCLES"  # CPU: works headless without a GPU (Workbench/EEVEE need EGL)
    sc.cycles.device = "CPU"
    sc.cycles.samples = 12
    sc.cycles.use_denoising = False
    sun = bpy.data.objects.new("sun", bpy.data.lights.new("sun", "SUN"))
    sun.data.energy = 3.0
    sun.rotation_euler = (math.radians(50), 0, math.radians(-30))
    sc.collection.objects.link(sun)
    sc.render.resolution_x, sc.render.resolution_y = 480, 600
    world = bpy.data.worlds.new("w")
    world.use_nodes = True
    world.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.62, 0.7, 1)
    world.node_tree.nodes["Background"].inputs[1].default_value = 0.8
    sc.world = world
    cam_data = bpy.data.cameras.new("cam")
    cam_data.lens = 50
    cam = bpy.data.objects.new("cam", cam_data)
    sc.collection.objects.link(cam)
    sc.camera = cam
    # angle 0 = in front of the face (-Y)
    views = [("front", 0.0, None, 0), ("threeq", 40.0, None, 0), ("back", 180.0, None, 0),
             ("run", 200.0, "run", 6), ("run_side", 90.0, "run", 4), ("run_side2", 90.0, "run", 12), ("idle", 20.0, "idle", 12),
             ("catch_rear", 60.0, "catch", 9), ("catch_grab", 60.0, "catch", 24)]
    target = Vector((0, 0, height * 0.48))
    for name, deg, act, fr in views:
        arm.animation_data.action = made[act] if act else None
        if act is None:
            for pb in arm.pose.bones:
                pb.rotation_quaternion, pb.location = (1, 0, 0, 0), (0, 0, 0)
        sc.frame_set(int(made[act].frame_range[0]) + fr if act else 0)
        a = math.radians(deg)
        pos = target + Vector((math.sin(a) * height * 2.4, -math.cos(a) * height * 2.4, height * 0.2))
        cam.location = pos
        cam.rotation_euler = (target - pos).to_track_quat("-Z", "Y").to_euler()
        sc.render.filepath = os.path.join(out_dir, f"div_{name}.png")
        bpy.ops.render.render(write_still=True)
    arm.animation_data.action = None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="assets/incoming/char_div_tripo.glb")
    ap.add_argument("--out", default="assets/models/char_div.glb")
    ap.add_argument("--preview", default="")
    ap.add_argument("--height", type=float, default=3.75)
    ap.add_argument("--tris", type=int, default=7800)
    ap.add_argument("--tex", type=int, default=512)
    a = ap.parse_args(sys.argv[1:])
    bpy.ops.wm.read_factory_settings(use_empty=True)
    sc = bpy.context.scene
    sc.render.fps = FPS
    bpy.ops.import_scene.gltf(filepath=os.path.abspath(a.inp))
    arm = next(o for o in bpy.data.objects if o.type == "ARMATURE")
    body = next(o for o in bpy.data.objects if o.type == "MESH" and o.parent == arm)
    for o in list(bpy.data.objects):
        if o not in (arm, body):
            bpy.data.objects.remove(o)
    for pb in arm.pose.bones:
        pb.custom_shape = None
    arm.name, body.name = "Armature", "Body"
    arm.animation_data_create()
    run = bpy.data.actions[0] if len(bpy.data.actions) == 1 else bpy.data.actions["run.001"]
    run.name = "run"
    run.use_fake_user = True
    arm.animation_data.action = None

    # --- scale to the game's height (feet stay at the origin) ---
    zs = [(body.matrix_world @ v.co).z for v in body.data.vertices]
    s = a.height / (max(zs) - min(zs))
    body.data.transform(Matrix.Scale(s, 4))
    bpy.context.view_layer.objects.active = arm
    bpy.ops.object.mode_set(mode="EDIT")
    for eb in arm.data.edit_bones:
        eb.head, eb.tail = eb.head * s, eb.tail * s
    bpy.ops.object.mode_set(mode="OBJECT")
    for fc in all_fcurves(run):
        if fc.data_path.endswith(".location") or fc.data_path == "location":
            for kp in fc.keyframe_points:
                kp.co[1] *= s
                kp.handle_left[1] *= s
                kp.handle_right[1] *= s

    shift = recentre_run(arm, run)
    print("run clip hips shifted by", tuple(round(v, 3) for v in shift), "m")

    # --- decimate the skinned mesh (weights travel with the collapse) ---
    bpy.ops.object.select_all(action="DESELECT")
    bpy.context.view_layer.objects.active = body
    body.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.mesh.remove_doubles(threshold=1e-6)
    bpy.ops.object.mode_set(mode="OBJECT")
    body.data.calc_loop_triangles()
    before = len(body.data.loop_triangles)
    if before > a.tris:
        dec = body.modifiers.new("Decimate", "DECIMATE")
        dec.decimate_type = "COLLAPSE"
        dec.ratio = a.tris / before
        while body.modifiers[0] != dec:
            bpy.ops.object.modifier_move_up(modifier=dec.name)
        bpy.ops.object.modifier_apply(modifier=dec.name)
    bpy.ops.object.vertex_group_limit_total(group_select_mode="ALL", limit=4)
    bpy.ops.object.vertex_group_normalize_all(group_select_mode="ALL", lock_active=False)
    body.data.calc_loop_triangles()
    tris = len(body.data.loop_triangles)

    # --- texture ---
    imgs = []
    for im in [im for im in bpy.data.images if im.size[0] > 0]:
        n = min(a.tex, im.size[0])
        im.scale(n, n)
        # A new PNG image from the scaled pixels: the exporter keeps a .jpg source as JPEG, and that JPEG failed
        # Godot 4.7.2's libjpeg-turbo loader (the material lost its texture: a white Div).
        png = bpy.data.images.new("tex_div", n, n, alpha=False)
        png.pixels.foreach_set(im.pixels[:])
        png.filepath_raw = os.path.join(tempfile.mkdtemp(), "tex_div.png")
        png.file_format = "PNG"
        png.save()
        png.pack()
        im.user_remap(png)
        bpy.data.images.remove(im)
        imgs.append(png)
    mats = len(body.data.materials)

    # --- clips ---
    made = {"run": run}
    made.update(make_actions(arm))
    arm.animation_data.action = None
    for name, act in made.items():
        tr = arm.animation_data.nla_tracks.new()
        tr.name = name
        tr.strips.new(name, int(act.frame_range[0]), act).name = name
        tr.mute = True
    for pb in arm.pose.bones:
        pb.rotation_quaternion, pb.location = (1, 0, 0, 0), (0, 0, 0)
    print(f"scale {s:.4f}; triangles {before} -> {tris} (budget 8000); materials {mats}; "
          f"textures {[tuple(im.size) for im in imgs]}; bones {len(arm.data.bones)}; "
          f"clips {[(n, tuple(act.frame_range)) for n, act in made.items()]}")
    assert tris <= 8000, "over the Div's triangle budget"
    if a.preview:
        render_previews(a.preview, arm, made, a.height)
    out = os.path.abspath(a.out)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    kw = dict(filepath=out, export_format="GLB", export_yup=True, export_apply=False, export_animations=True,
              export_animation_mode="ACTIONS", export_skins=True, export_def_bones=False, export_force_sampling=True,
              export_frame_range=False, export_nla_strips=True, export_optimize_animation_size=False,
              export_image_format="AUTO", export_materials="EXPORT", use_selection=False)
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
    sys.stdout.flush()
    os._exit(0)  # skip bpy's teardown (it aborts on a second glog init in this build)


if __name__ == "__main__":
    main()
