extends Node2D
class_name Main

@export var bubbleContainer:Node2D
@export var physicArea:Area2D

const bubble_ts = preload("res://bubble.tscn")
const inner_ts = preload("res://inner.tscn")

var _bubbles: Array = []

func _ready() -> void:
	print("Main Init")
	var code = "bubble"
	for i in range(len(code)):
		print(code[i])
		var b = bubble_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		b.init(code[i])
		b.bubble_clicked.connect(on_bubble_clicked)
		_bubbles.append(b)
		var x = randi() % 100 + 200*i
		var y = randi() % 100 + 300
		b.position = Vector2(x,y)
		bubbleContainer.add_child(b)

	
func on_bubble_clicked(bubble):
	print("Main.Bubble %s clicked" % bubble.get_char())
	
	pop_the_bubble(bubble)

func pop_the_bubble(bubble: Bubble) -> void:
	var obj = inner_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	obj.init(bubble.get_char())
	obj.position = bubble.position
	bubble.queue_free()
	physicArea.add_child(obj)
