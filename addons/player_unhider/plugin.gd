tool
extends EditorPlugin
var uh = preload("res://addons/player_unhider/unhider.gd")
func _enter_tree(): add_custom_type("Unhider", "Spatial", uh, get_editor_interface().get_base_control().get_icon("Spatial", "EditorIcons"))
func _exit_tree(): remove_custom_type("Unhider")
func _handles(obj) -> bool: return obj is uh
