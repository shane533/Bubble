extends Node2D
class_name Main

@export var bubbleContainer:Node2D
@export var physicArea:Area2D
@export var bottom:Node2D

const bubble_ts = preload("res://bubble.tscn")
const inner_ts = preload("res://inner.tscn")
const hole_ts = preload("res://bottom_hole.tscn")

const WIN_COUNT = 6

var _bubbles: Array = []
var _succeed_count = 0


func _ready() -> void:
	print("Main Init")
	var code = "bubble"
	for i in range(len(code)):
		print(code[i])
		var b = bubble_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		b.init(code[i])
		b.bubble_clicked.connect(on_bubble_clicked)
		_bubbles.append(b)
		var x = 50 + randi() % 100 + 200*i
		var y = randi() % 100 + 300
		b.position = Vector2(x,y)
		bubbleContainer.add_child(b)
		b.start_anim()
		
		var hole = hole_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		hole.init(code[i])
		hole.position = Vector2(50+200*i, 0)
		hole.s_ball_in_hole.connect(on_ball_in_hole)
		bottom.add_child(hole)

	
func on_bubble_clicked(bubble):
	print("Main.Bubble %s clicked" % bubble.get_char())
	
	pop_the_bubble(bubble)

func pop_the_bubble(bubble: Bubble) -> void:
	var obj = inner_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	obj.init(bubble.get_char())
	obj.position = bubble.position
	bubble.queue_free()
	physicArea.add_child(obj)
	
func on_ball_in_hole(ball:Inner, is_succeed:bool):
	if not is_succeed:
		print("Failed")
	else:
		_succeed_count += 1
		if _succeed_count == WIN_COUNT:
			print("WIN!")
