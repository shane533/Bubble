extends Node2D
class_name BottomHole

signal s_ball_in_hole(ball, is_suceed)
@export var label:Label

var _target_char: String
var _is_succeed: bool
var _occupied:Inner

func init(char) -> void:
	print("INIT HOLE %s" % char)
	_target_char = char
	label.text = char
	label.self_modulate = Color.WHITE

func is_succeed() -> bool:
	return _is_succeed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Inner:
		_occupied = body
		print("%s enterred this hole!" % body.get_char())
		if _target_char == body.get_char():
			label.self_modulate = Color.GREEN
			_is_succeed = true
		else:
			label.self_modulate = Color.RED
			_is_succeed = false
		s_ball_in_hole.emit(body, _is_succeed)
			


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Inner:
		print("%s exit this hole!" % body.get_char())
		if _target_char == body.get_char():
			_is_succeed = false
		if _occupied == body:
			label.self_modulate = Color.WHITE
	pass # Replace with function body.
