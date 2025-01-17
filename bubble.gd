extends Node2D
class_name Bubble

@export var label:Label
@export var outer: Sprite2D

signal bubble_clicked(bubble)

var _char: String

func init(char:String):
	_char = char
	label.text = _char
	tween_floating()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if outer.get_rect().has_point(outer.to_local(event.position)):
			print("Bubble %s clicked" % _char)
			bubble_clicked.emit(self)

func get_char():
	return _char

func tween_floating():
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 1.05), 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", Vector2(0.98, 0.9), 0.5).set_trans(Tween.TRANS_LINEAR)
	#tween.tween_property(self, "scale", Vector2(0.98, 0.9), 0.5).set_trans(Tween.TRANS_BOUNCE)
	tween.set_loops(0)
