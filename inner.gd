extends RigidBody2D
class_name Inner

@export var label:Label

var _char: String

func init(char):
	_char = char
	label.text = char
	label.self_modulate = Color.WHITE
	
func get_char() -> String:
	return _char

func look_follow(state: PhysicsDirectBodyState2D, current_transform: Transform2D, target_position: Vector2) -> void:
	var forward_local_axis: Vector2 = Vector2(0, 1)
	var forward_dir: Vector2 = (current_transform * forward_local_axis).normalized()
	var target_dir: Vector2 = (target_position - current_transform.origin).normalized()
	var local_speed: float = clampf(0.1, 0, acos(forward_dir.dot(target_dir)))
	if forward_dir.dot(target_dir) > 1e-4:
		state.angular_velocity = local_speed * forward_dir.cross(target_dir) / state.step

func _integrate_forces(state):
	var target_position = self.global_transform.origin
	target_position = target_position.rotated(0)
	look_follow(state, global_transform, target_position)
	
