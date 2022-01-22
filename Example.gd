extends Spatial
const MOVE_SPEED := 50.0

onready var camera_gimbal := $Gimbal
onready var player := $Player
onready var player_init_y:float = player.transform.origin.y

func _physics_process(delta:float):
	var move := Vector2.ZERO
	if Input.is_action_pressed("ui_left"): move.x -= 1
	elif Input.is_action_pressed("ui_right"): move.x += 1
	if Input.is_action_pressed("ui_up"): move.y -= 1
	elif Input.is_action_pressed("ui_down"): move.y += 1
	move = move.normalized()
	player.move_and_slide(Vector3(move.x, 0, move.y) * MOVE_SPEED * delta, Vector3.UP)
	player.transform.origin.y = player_init_y

func _on_HScrollBar_value_changed(value:float): camera_gimbal.rotation_degrees.y = value
func _on_VScrollBar_value_changed(value:float): camera_gimbal.rotation_degrees.x = value
