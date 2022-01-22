class_name Unhider
extends Spatial
export(bool) var active := true
export(String) var player_group := "player"
export(Vector3) var player_offset := Vector3(0, -0.15, 0)
export(int, "PhysicsBody is child of MeshInstance", "MeshInstance is child of PhysicsBody") var mesh_relation := 0
export(String, "alpha") var transparency_type := "alpha"
onready var camera:Camera = get_viewport().get_camera()
onready var world:World = get_world()
var player:Spatial = null
var last_focused_object:MeshInstance = null
var original_material:Material = null

# warning-ignore:return_value_discarded
func _ready(): _try_find_player_node()
func _try_find_player_node() -> bool:
	var group_nodes := get_tree().get_nodes_in_group(player_group)
	if group_nodes.size() == 0: return false
	player = group_nodes[0]
	return true

func _process(_delta):
	if !active: return
	if player == null && !_try_find_player_node(): return
	var player_screen_pos := camera.unproject_position(player.global_transform.origin + player_offset)
	var from := camera.project_ray_origin(player_screen_pos)
	var to := from + camera.project_ray_normal(player_screen_pos) * 100
	var space_state := world.direct_space_state
	var result:Dictionary = space_state.intersect_ray(from, to)
	if result.empty() || result["collider"] == player:
		if last_focused_object != null:
			_show_mesh(last_focused_object)
			last_focused_object = null
	else:
		var found_node:PhysicsBody = result["collider"]
		var found_mesh:MeshInstance = _get_mesh_from_body(found_node)
		if found_mesh == null:
			print("Couldn't find a mesh!")
			return
		if found_mesh == last_focused_object: return
		if last_focused_object != null: _show_mesh(last_focused_object)
		_hide_mesh(found_mesh)
		last_focused_object = found_mesh

func _get_mesh_from_body(b:PhysicsBody) -> MeshInstance:
	if mesh_relation == 0:
		return (b.get_parent() as MeshInstance)
	else:
		for n in b.get_children():
			if n is MeshInstance: return n
	return null

func _hide_mesh(m:MeshInstance):
	if last_focused_object == m: return
	var mat := _get_material(m)
	if mat == null: return
	match transparency_type:
		"alpha":
			original_material = mat
			var mn := mat.duplicate()
			mn.flags_transparent = true
			mn.albedo_color.a = 0.5
			m.set_surface_material(0, mn)

func _show_mesh(m:MeshInstance):
	m.set_surface_material(0, original_material)
	original_material = null

func _get_material(m:MeshInstance) -> SpatialMaterial: 
	var mat := m.get_active_material(0)
	if mat is SpatialMaterial: return (mat as SpatialMaterial)
	print("sorry, no ShaderMaterial support! :(")
	return null
