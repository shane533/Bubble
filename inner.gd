extends RigidBody2D
class_name inner

@export var label:Label

var _char: String

func init(char):
	_char = char
	label.text = char
