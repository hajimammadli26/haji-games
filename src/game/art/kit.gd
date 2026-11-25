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
