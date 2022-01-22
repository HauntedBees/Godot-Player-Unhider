class_name Unhider
extends Spatial
var dots_shader:ShaderMaterial = preload("res://partial.tres")
export(bool) var active := true
export(String) var player_group := "player"
export(Vector3) var player_offset := Vector3(0, -0.15, 0)
export(int, "PhysicsBody is child of MeshInstance", "MeshInstance is child of PhysicsBody") var mesh_relation := 0
export(String, "none", "alpha", "dots") var transparency_type := "none"
onready var camera:Camera = get_viewport().get_camera()
onready var world:World = get_world()
var player:Spatial = null
var last_focused_object:MeshInstance = null
var original_material:Material = null
var tween:Tween = null

# warning-ignore:return_value_discarded
func _ready():
	tween = Tween.new()
	add_child(tween)
	_try_find_player_node()
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
		if last_focused_object != null: _show_mesh(last_focused_object, true)
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
	original_material = mat
	match transparency_type:
		"alpha":
			var mn := mat.duplicate()
			mn.flags_transparent = true
			mn.albedo_color.a = 0.5
			m.set_surface_material(0, mn)
		"dots":
			m.set_surface_material(0, dots_shader)
			if mat.albedo_texture == null:
				dots_shader.set_shader_param("use_color", true)
				dots_shader.set_shader_param("color_albedo", mat.albedo_color)
			else:
				dots_shader.set_shader_param("use_color", false)
				dots_shader.set_shader_param("texture_albedo", mat.albedo_texture)
			tween.interpolate_property(dots_shader, "shader_param/dot_radius", 1.2, 0.2, 0.25)
			tween.start()

func _show_mesh(m:MeshInstance, immediate:bool = false):
	match transparency_type:
		"alpha":
			m.set_surface_material(0, original_material)
		"dots":
			if !immediate:
				tween.interpolate_property(dots_shader, "shader_param/dot_radius", 0.2, 1.2, 0.25)
				tween.start()
				yield(tween, "tween_completed")
			m.set_surface_material(0, original_material)
	original_material = null

func _get_material(m:MeshInstance) -> SpatialMaterial: 
	var mat := m.get_active_material(0)
	if mat is SpatialMaterial: return (mat as SpatialMaterial)
	print("sorry, no ShaderMaterial support! :(")
	return null
