extends Node2D
class_name BottomHole

signal s_ball_in_hole(ball, is_suceed)

@export var label:Label

var _target_char: String

func init(char) -> void:
	_target_char = char
	label.text = char
	label.self_modulate = Color.WHITE

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Inner:
		print("%s enterred this hole!" % body.get_char())
		if _target_char == body.get_char():
			label.self_modulate = Color.GREEN
			s_ball_in_hole.emit(body, true)
		else:
			label.self_modulate = Color.RED
			s_ball_in_hole.emit(body, false)
			
