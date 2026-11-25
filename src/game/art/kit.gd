## The art kit every figure is built from: shared meshes (one per shape and size, reused everywhere), toon
## materials (plain colours or the painted textures in assets/textures), the ink outline, and part() to place
## a piece. Caching keeps a long run from creating thousands of meshes and materials.
## Look: soft two-band toon light with a rim, dark ink outlines on characters and obstacles (design stage).
##
## Usage:
##   var g := Node3D.new()
##   Kit.part(g, Kit.ball(0.3), Kit.mat("#f2c08f"), Vector3(0, 1.3, 0))
##   Kit.part(g, Kit.box(1, 1, 1), Kit.tex("carpet_red"), Vector3.ZERO)
##   Kit.ink(g)   # outline everything under g
class_name Kit
extends RefCounted

const TEX_DIR := "res://assets/textures/"
const INK := Color("#2a140a")
const INK_GROW := 0.025

static var _mats := {}
static var _meshes := {}
static var _tex := {}
static var _ink: StandardMaterial3D


## A toon material of a colour (a hex string or a Color). emissive glows; alpha < 1 is see-through.
static func mat(color: Variant, emissive := false, rough := 0.85) -> StandardMaterial3D:
	var c: Color = color if color is Color else Color(String(color))
	var key := "c" + c.to_html() + ("e" if emissive else "") + str(rough)
	if not _mats.has(key):
		var m := _toon()
		m.albedo_color = c
		m.roughness = rough
		if emissive:
			m.emission_enabled = true
			m.emission = c
			m.emission_energy_multiplier = 0.8
		if c.a < 1.0:
			m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_mats[key] = m
	return _mats[key]


## A toon material with a painted texture; uv repeats it, tint multiplies it, two_sided for hanging cloth.
static func tex(name: String, uv := Vector2.ONE, tint := Color.WHITE, two_sided := false) -> StandardMaterial3D:
	var key := "t%s%s%s%s" % [name, uv, tint.to_html(), two_sided]
	if not _mats.has(key):
		var m := _toon()
		m.albedo_texture = texture(name)
		m.albedo_color = tint
		m.uv1_scale = Vector3(uv.x, uv.y, 1)
		m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		if two_sided:
			m.cull_mode = BaseMaterial3D.CULL_DISABLED
		_mats[key] = m
	return _mats[key]


## A texture from assets/textures (cached).
static func texture(name: String) -> Texture2D:
	if not _tex.has(name):
		_tex[name] = load(TEX_DIR + name + ".png")
	return _tex[name]


static func _toon() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	m.specular_mode = BaseMaterial3D.SPECULAR_TOON
	m.rim_enabled = true
	m.rim = 0.35
	m.rim_tint = 0.6
	return m


## The ink outline: an inflated back-face shell drawn over a figure.
static func ink_mat() -> StandardMaterial3D:
	if _ink == null:
		_ink = StandardMaterial3D.new()
		_ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_ink.albedo_color = INK
		_ink.cull_mode = BaseMaterial3D.CULL_FRONT
		_ink.grow = true
		_ink.grow_amount = INK_GROW
	return _ink


## Outlines every mesh under node (skips see-through and glowing parts, and tiny ones).
static func ink(node: Node) -> void:
	for c in node.get_children():
		ink(c)
	if node is MeshInstance3D and not node.has_meta("no_ink"):
		var m: Material = node.material_override
		if m is StandardMaterial3D and ((m as StandardMaterial3D).transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or (m as StandardMaterial3D).emission_enabled):
			return
		var mi := node as MeshInstance3D
		if mi.mesh != null and (mi.mesh.get_aabb().size * mi.scale).length() < 0.25 and not node.has_meta("ink"):
			return # eyes, glints, buttons: an outline there only muddies the face (meta "ink" forces one: a small
			# piece of a bigger shape then shares that shape's merged, inked mesh instead of costing its own draw)
		node.material_overlay = ink_mat()


## Adds a mesh piece to parent at pos, turned by rot (radians), with the given material.
static func part(parent: Node3D, mesh: Mesh, material: Material, pos := Vector3.ZERO, rot := Vector3.ZERO, scale := Vector3.ONE) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.position = pos
	mi.rotation = rot
	mi.scale = scale
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(mi)
	return mi


## An empty joint (for animation) under parent at pos.
static func joint(parent: Node3D, pos := Vector3.ZERO) -> Node3D:
	var n := Node3D.new()
	n.position = pos
	parent.add_child(n)
	return n


# --- shared meshes (keys round sizes so near-equal pieces share) -----------------------------------

static func _mesh(key: String, make: Callable) -> Mesh:
	if not _meshes.has(key):
		_meshes[key] = make.call()
	return _meshes[key]


## A box of the given size.
static func box(sx: float, sy: float, sz: float) -> Mesh:
	return _mesh("b%.3f,%.3f,%.3f" % [sx, sy, sz], func() -> Mesh:
		var m := BoxMesh.new()
		m.size = Vector3(sx, sy, sz)
		return m)


## A cylinder (r_top 0 makes a cone); segs around.
static func cyl(r_top: float, r_bot: float, h: float, segs := 16) -> Mesh:
	return _mesh("c%.3f,%.3f,%.3f,%d" % [r_top, r_bot, h, segs], func() -> Mesh:
		var m := CylinderMesh.new()
		m.top_radius = r_top
		m.bottom_radius = r_bot
		m.height = h
		m.radial_segments = segs
		m.rings = 1
		return m)


## A capsule (a rounded limb) of radius r and total height h, along y and centred.
static func capsule(r: float, h: float) -> Mesh:
	return _mesh("k%.3f,%.3f" % [r, h], func() -> Mesh:
		var m := CapsuleMesh.new()
		m.radius = r
		m.height = maxf(h, r * 2.0)
		m.radial_segments = 14
		m.rings = 6
		return m)


## A sphere of radius r (h: its height, for eggs and discs); segs around (low counts look faceted).
static func ball(r: float, h := -1.0, segs := 18) -> Mesh:
	return _mesh("s%.3f,%.3f,%d" % [r, h, segs], func() -> Mesh:
		var m := SphereMesh.new()
		m.radius = r
		m.height = r * 2.0 if h < 0.0 else h
		m.radial_segments = segs
		m.rings = maxi(4, segs / 2)
		return m)


## An ellipsoid: a unit ball scaled (use as part(..., scale = Vector3(rx, ry, rz))).
static func unit_ball(segs := 18) -> Mesh:
	return ball(1.0, -1.0, segs)


## A ring (torus) of radius r and tube thickness t, lying flat (axis up).
static func ring(r: float, t: float) -> Mesh:
	return _mesh("t%.3f,%.3f" % [r, t], func() -> Mesh:
		var m := TorusMesh.new()
		m.inner_radius = r - t
		m.outer_radius = r + t
		m.rings = 20
		m.ring_segments = 8
		return m)


## A triangular prism (a pitched roof): width w across, height h, length l along z.
static func prism(w: float, h: float, l: float) -> Mesh:
	return _mesh("p%.3f,%.3f,%.3f" % [w, h, l], func() -> Mesh:
		var m := PrismMesh.new()
		m.size = Vector3(w, h, l)
		return m)


## A flat rectangle facing +z.
static func plane(w: float, h: float) -> Mesh:
	return _mesh("q%.3f,%.3f" % [w, h], func() -> Mesh:
		var m := QuadMesh.new()
		m.size = Vector2(w, h)
		return m)


## A turned shape (jug, vase): profile points (radius, height) from bottom to top, spun around y.
static func lathe(points: PackedVector2Array, segs := 16) -> Mesh:
	return _mesh("l%s%d" % [points, segs], func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for i in segs:
			var a0 := i * TAU / segs
			var a1 := (i + 1) * TAU / segs
			for j in points.size() - 1:
				var p := points[j]
				var q := points[j + 1]
				var v := [Vector3(cos(a0) * p.x, p.y, sin(a0) * p.x), Vector3(cos(a1) * p.x, p.y, sin(a1) * p.x),
					Vector3(cos(a1) * q.x, q.y, sin(a1) * q.x), Vector3(cos(a0) * q.x, q.y, sin(a0) * q.x)]
				for k in [0, 2, 1, 0, 3, 2]:
					st.set_uv(Vector2(float(i) / segs, float(j) / (points.size() - 1)))
					st.add_vertex(v[k])
		st.generate_normals()
		return st.commit())


## A cut turned shell (a vest open at the front, a cape): the lathe profile (radius, height; bottom to top) swept
## from angle a0 to a1 (radians; 0 is +x, PI/2 is +z), thick inward, closed at the cut edges and rims so the ink
## outlines it cleanly. u runs along the arc (0 to 1), v down the profile, so a bordered texture trims every edge.
static func shell(points: PackedVector2Array, a0: float, a1: float, thick: float, segs := 16) -> Mesh:
	return _mesh("h%s%.3f,%.3f,%.3f,%d" % [points, a0, a1, thick, segs], func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var np := points.size()
		var nrm := PackedVector2Array() ## the profile's outward normal at each point (smooth along it)
		for j in np:
			var d := points[mini(j + 1, np - 1)] - points[maxi(j - 1, 0)]
			nrm.append(Vector2(d.y, -d.x).normalized())
		var at := func(p: Vector2, a: float, inset: float) -> Vector3:
			return Vector3(cos(a) * maxf(0.0, p.x - inset), p.y, sin(a) * maxf(0.0, p.x - inset))
		var turn := func(n: Vector2, a: float) -> Vector3:
			return Vector3(cos(a) * n.x, n.y, sin(a) * n.x)
		for i in segs:
			var u0 := float(i) / segs
			var u1 := float(i + 1) / segs
			var b0 := lerpf(a0, a1, u0)
			var b1 := lerpf(a0, a1, u1)
			for j in np - 1:
				var p := points[j]
				var q := points[j + 1]
				var v0 := 1.0 - float(j) / (np - 1)
				var v1 := 1.0 - float(j + 1) / (np - 1)
				var uv := [Vector2(u0, v0), Vector2(u1, v0), Vector2(u1, v1), Vector2(u0, v1)]
				for side in [0.0, thick]: # the outside, then the inside facing in
					var sg := 1.0 if side == 0.0 else -1.0
					_quad(st, [at.call(p, b0, side), at.call(p, b1, side), at.call(q, b1, side), at.call(q, b0, side)],
						[turn.call(nrm[j], b0) * sg, turn.call(nrm[j], b1) * sg, turn.call(nrm[j + 1], b1) * sg, turn.call(nrm[j + 1], b0) * sg], uv)
			for e in [[0, -1.0], [np - 1, 1.0]]: # the bottom and top rims
				var p := points[e[0]]
				var t: Vector2 = (points[mini(e[0] + 1, np - 1)] - points[maxi(e[0] - 1, 0)]).normalized() * float(e[1])
				var vv := 1.0 if e[0] == 0 else 0.0
				var n0: Vector3 = turn.call(t, b0)
				var n1: Vector3 = turn.call(t, b1)
				_quad(st, [at.call(p, b0, 0.0), at.call(p, b1, 0.0), at.call(p, b1, thick), at.call(p, b0, thick)],
					[n0, n1, n1, n0], [Vector2(u0, vv), Vector2(u1, vv), Vector2(u1, vv), Vector2(u0, vv)])
		for e in [[a0, -1.0, 0.0], [a1, 1.0, 1.0]]: # the two cut edges (the open front of a vest)
			var a: float = e[0]
			var n: Vector3 = Vector3(-sin(a), 0, cos(a)) * float(e[1])
			for j in np - 1:
				var p := points[j]
				var q := points[j + 1]
				var v0 := 1.0 - float(j) / (np - 1)
				var v1 := 1.0 - float(j + 1) / (np - 1)
				_quad(st, [at.call(p, a, 0.0), at.call(q, a, 0.0), at.call(q, a, thick), at.call(p, a, thick)],
					[n, n, n, n], [Vector2(e[2], v0), Vector2(e[2], v1), Vector2(e[2], v1), Vector2(e[2], v0)])
		return st.commit())


## Adds a quad (corners in order around it) facing along its normals, whichever way the corners wind.
static func _quad(st: SurfaceTool, p: Array, n: Array, uv: Array) -> void:
	var facing: Vector3 = n[0] + n[1] + n[2] + n[3]
	var order := [0, 2, 1, 0, 3, 2]
	if ((p[2] - p[0]) as Vector3).cross(p[1] - p[0]).dot(facing) > 0.0: # Godot's front faces wind clockwise
		order = [0, 1, 2, 0, 2, 3]
	for k in order:
		st.set_normal(n[k])
		st.set_uv(uv[k])
		st.add_vertex(p[k])


## A mesh made by make (a Callable returning a Mesh), built once per key and shared, like the shapes above.
static func cached(key: String, make: Callable) -> Mesh:
	return _mesh("u" + key, make)


## An extruded outline (the gate's arch): points in the xy plane, depth along z, centred.
static func extrude(points: PackedVector2Array, depth: float, key: String) -> Mesh:
	return _mesh("x" + key, func() -> Mesh:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var tri := Geometry2D.triangulate_polygon(points)
		var hz := depth / 2.0
		for face in [hz, -hz]:
			for i in range(0, tri.size(), 3):
				var order := [0, 1, 2] if face > 0 else [0, 2, 1]
				for k in order:
					var p := points[tri[i + k]]
					st.set_uv(p * 0.15)
					st.add_vertex(Vector3(p.x, p.y, face))
		for i in points.size():
			var a := points[i]
			var b := points[(i + 1) % points.size()]
			var u := a.distance_to(b) * 0.15
			for v in [[a, hz, 0.0], [b, hz, u], [b, -hz, u], [a, hz, 0.0], [b, -hz, u], [a, -hz, 0.0]]:
				st.set_uv(Vector2(v[2], v[1] * 0.15))
				st.add_vertex(Vector3(v[0].x, v[0].y, v[1]))
		st.generate_normals()
		return st.commit())


## Merges every still mesh under node into one mesh per material (and ink), so a house of forty pieces
## draws in a handful of calls instead of forty. Pieces marked "keep" (animated) and non-mesh nodes stay.
## Call on things that never move inside: houses, gates, the horizon, still obstacles.
static func merge(node: Node3D, deep := true) -> void:
	var groups := {} ## key -> Batch
	var gone: Array[Node] = []
	_collect(node, Transform3D.IDENTITY, groups, gone, deep)
	if gone.size() < 2:
		return
	for n in gone:
		n.get_parent().remove_child(n)
		n.queue_free()
	for key in groups:
		var b: Batch = groups[key]
		var mi := MeshInstance3D.new()
		mi.mesh = b.commit()
		mi.material_override = b.material
		if b.inked:
			mi.material_overlay = ink_mat()
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("no_ink", true)
		node.add_child(mi)


## One merged mesh being built: vertices, normals, uvs, colours and indices from many pieces.
class Batch:
	var material: Material
	var inked := false
	var tinted := false ## pieces of plain colour: the colour goes into the vertices, one material for all
	var verts := PackedVector3Array()
	var norms := PackedVector3Array()
	var uvs := PackedVector2Array()
	var cols := PackedColorArray()
	var idx := PackedInt32Array()

	func add(mesh: Mesh, xf: Transform3D, color: Color, own_colors := false) -> void:
		var nxf := Transform3D(xf.basis.inverse().transposed(), Vector3.ZERO)
		for s in mesh.get_surface_count():
			var a := mesh.surface_get_arrays(s)
			var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var base := verts.size()
			verts.append_array(xf * v)
			var n: Variant = a[Mesh.ARRAY_NORMAL]
			norms.append_array(nxf * (n as PackedVector3Array) if n != null else PackedVector3Array())
			if (n == null):
				var up := PackedVector3Array()
				up.resize(v.size())
				up.fill(Vector3.UP)
				norms.append_array(up)
			var uv: Variant = a[Mesh.ARRAY_TEX_UV]
			if uv != null:
				uvs.append_array(uv)
			else:
				var z := PackedVector2Array()
				z.resize(v.size())
				uvs.append_array(z)
			if own_colors and a[Mesh.ARRAY_COLOR] != null: # an already-merged piece keeps its baked colours
				cols.append_array(a[Mesh.ARRAY_COLOR])
			else:
				var c := PackedColorArray()
				c.resize(v.size())
				c.fill(color)
				cols.append_array(c)
			var ix: Variant = a[Mesh.ARRAY_INDEX]
			if ix != null:
				for i in (ix as PackedInt32Array):
					idx.append(i + base)
			else:
				for i in v.size():
					idx.append(i + base)

	func commit() -> ArrayMesh:
		var arrays := []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_NORMAL] = norms
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		if tinted:
			arrays[Mesh.ARRAY_COLOR] = cols
		arrays[Mesh.ARRAY_INDEX] = idx
		var m := ArrayMesh.new()
		m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		return m


static var _tint_mat: StandardMaterial3D


## The one toon material for every plain-coloured piece after merging: the colour is in the vertices.
static func tint_mat() -> StandardMaterial3D:
	if _tint_mat == null:
		_tint_mat = _toon()
		_tint_mat.vertex_color_use_as_albedo = true
		_tint_mat.vertex_color_is_srgb = true # the colours are the same sRGB values the plain materials had
		_tint_mat.albedo_color = Color.WHITE
	return _tint_mat


## True for a material that is only a colour (no texture, no glow, not see-through): it can be tinted in.
static func _plain(m: Material) -> bool:
	if not m is StandardMaterial3D:
		return false
	var s := m as StandardMaterial3D
	return s.albedo_texture == null and not s.emission_enabled and s.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED \
		and not s.disable_fog and s.diffuse_mode == BaseMaterial3D.DIFFUSE_TOON


static func _collect(n: Node, xf: Transform3D, groups: Dictionary, gone: Array[Node], deep := true) -> void:
	for c in n.get_children():
		if not c is Node3D or c.has_meta("keep") or c.has_meta("parts") or c.has_meta("sway") or c.has_meta("scroll") \
				or c.has_meta("drift") or c is Label3D or c is CPUParticles3D:
			continue
		var cxf: Transform3D = xf * (c as Node3D).transform
		if not deep and not c is MeshInstance3D:
			continue # a joint: it moves on its own, so it keeps its own pieces
		if c is MeshInstance3D and (c as MeshInstance3D).mesh != null and (c as MeshInstance3D).material_override != null:
			var mi := c as MeshInstance3D
			var inked := mi.material_overlay != null
			var was_tinted := mi.material_override == _tint_mat and _tint_mat != null
			var plain := was_tinted or _plain(mi.material_override)
			var key := "tint|%s" % inked if plain else "%d|%s" % [mi.material_override.get_instance_id(), inked]
			if not groups.has(key):
				var b := Batch.new()
				b.material = tint_mat() if plain else mi.material_override
				b.inked = inked
				b.tinted = plain
				groups[key] = b
			var col: Color = (mi.material_override as StandardMaterial3D).albedo_color if plain and not was_tinted else Color.WHITE
			(groups[key] as Batch).add(mi.mesh, cxf, col, was_tinted)
			if c.get_child_count() == 0:
				gone.append(c)
				continue
		_collect(c, cxf, groups, gone)
		if c.get_child_count() == 0 and not c in gone and not c is MeshInstance3D:
			gone.append(c)


## Merges a jointed figure without stopping it moving: each joint's own still pieces become one mesh per
## material; joints, and pieces marked "keep" (eyes, brows, mouths the animator moves), stay as they are.
static func merge_joints(fig: Node3D) -> void:
	var joints: Array[Node3D] = [fig]
	var i := 0
	while i < joints.size():
		for c in joints[i].get_children():
			if c is Node3D and not c is MeshInstance3D:
				joints.append(c)
		i += 1
	for j in joints:
		merge(j, false)


## A blob shadow under a figure (a dark soft disc).
static func shadow(parent: Node3D, r: float, stretch := 1.0) -> MeshInstance3D:
	var m := _mesh("shadow", func() -> Mesh:
		var q := QuadMesh.new()
		q.size = Vector2(2, 2)
		q.orientation = PlaneMesh.FACE_Y
		return q)
	if not _mats.has("shadow"):
		var sm := StandardMaterial3D.new()
		sm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm.albedo_texture = _shadow_tex()
		sm.albedo_color = Color(0.23, 0.14, 0.06, 0.45)
		_mats["shadow"] = sm
	var mi := part(parent, m, _mats["shadow"], Vector3(0, 0.02, 0), Vector3.ZERO, Vector3(r, 1, r * stretch))
	mi.set_meta("no_ink", true)
	return mi


static func _shadow_tex() -> Texture2D:
	var g := GradientTexture2D.new()
	g.fill = GradientTexture2D.FILL_RADIAL
	g.fill_from = Vector2(0.5, 0.5)
	g.fill_to = Vector2(1.0, 0.5)
	var gr := Gradient.new()
	gr.set_color(0, Color(1, 1, 1, 1))
	gr.set_color(1, Color(1, 1, 1, 0))
	g.gradient = gr
	g.width = 64
	g.height = 64
	return g
