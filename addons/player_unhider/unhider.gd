class_name Unhider
extends Spatial
var dots_shader:ShaderMaterial = preload("res://addons/player_unhider/partial.tres")
export(bool) var active := true
export(String) var player_group := "player"
export(String) var hide_group := "scenery"
export(Vector3) var player_offset := Vector3(0, 0, 0)
export(int, "PhysicsBody is child of MeshInstance", "MeshInstance is child of PhysicsBody") var mesh_relation := 0
export(String, "none", "alpha", "dots") var transparency_type := "alpha"
onready var camera:Camera = get_viewport().get_camera()
onready var world:World = get_world()
var player:Spatial = null
var tween:Tween = null
var current_focus_object:HiderInfo
var clearing_queue := []

class HiderInfo:
	signal completed
	var mesh:MeshInstance
	var material:Material
	var tween:Tween
	func _init(me:MeshInstance, ma:Material, t:Tween):
		mesh = me
		material = ma
		tween = t
	func hide(transparency_type:String, dots_shader:ShaderMaterial):
		match transparency_type:
			"alpha":
				var mn := material.duplicate()
				mn.flags_transparent = true
				mn.albedo_color.a = 0.5
				mesh.set_surface_material(0, mn)
			"dots":
				mesh.set_surface_material(0, dots_shader)
				if material.albedo_texture == null:
					dots_shader.set_shader_param("use_color", true)
					dots_shader.set_shader_param("color_albedo", material.albedo_color)
				else:
					dots_shader.set_shader_param("use_color", false)
					dots_shader.set_shader_param("texture_albedo", material.albedo_texture)
				tween.interpolate_property(dots_shader, "shader_param/dot_radius", 1.2, 0.2, 0.25)
				tween.start()
	func show(transparency_type:String, dots_shader:ShaderMaterial, immediate:bool):
		match transparency_type:
			"alpha":
				mesh.set_surface_material(0, material)
			"dots":
				if !immediate:
					tween.interpolate_property(dots_shader, "shader_param/dot_radius", 0.2, 1.2, 0.25)
					tween.start()
					yield(tween, "tween_completed")
				mesh.set_surface_material(0, material)
		if !immediate: emit_signal("completed")

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
		if current_focus_object != null:
			_show_current_mesh(false)
	else:
		var found_node:PhysicsBody = result["collider"]
		if hide_group != "" && !found_node.is_in_group(hide_group): return
		var found_mesh:MeshInstance = _get_mesh_from_body(found_node)
		if found_mesh == null:
			print("Couldn't find a mesh!")
			return
		if current_focus_object != null:
			if current_focus_object.mesh == found_mesh: return
			_show_current_mesh(true)
		_hide_mesh(found_mesh)

func _get_mesh_from_body(b:PhysicsBody) -> MeshInstance:
	if mesh_relation == 0:
		return (b.get_parent() as MeshInstance)
	else:
		for n in b.get_children():
			if n is MeshInstance: return n
	return null

func _hide_mesh(m:MeshInstance):
	if current_focus_object != null && current_focus_object.mesh == m: return
	var mat := _get_material(m)
	if mat == null: return
	var info := HiderInfo.new(m, mat, tween)
	info.connect("completed", self, "_on_show_complete", [info])
	info.hide(transparency_type, dots_shader)
	current_focus_object = info

func _on_show_complete(info:HiderInfo): clearing_queue.erase(info)

func _show_current_mesh(immediate:bool = false):
	if !immediate: clearing_queue.append(current_focus_object)
	var me := current_focus_object
	current_focus_object = null
	me.show(transparency_type, dots_shader, immediate)

func _get_material(m:MeshInstance) -> SpatialMaterial: 
	var mat := m.get_active_material(0)
	if mat is SpatialMaterial: return (mat as SpatialMaterial)
	print("sorry, no ShaderMaterial support! :(")
	return null
