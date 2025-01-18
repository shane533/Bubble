extends Node2D
class_name Main

#@export var bubbleContainer:Node2D
#@export var physicArea:Area2D
#@export var bottom:Node2D


@export var levels:Array[Level]
@export var nextBubble:Bubble
@export var levelLabel:Label
@export var limitLabel:Label

const bubble_ts = preload("res://bubble.tscn")
const inner_ts = preload("res://inner.tscn")
const hole_ts = preload("res://bottom_hole.tscn")

const WIN_COUNT = 6

var _balls: Array = []

#var _current_level_index: int = 0
var _is_first_click: bool = false
var _click_limit: int = 99

func _ready() -> void:
	print("Main Init")
	init_level(Global.current_level)

func init_level(level_index):
	print("INIT LEVEL %d" % level_index)
	for b in _balls:
		b.queue_free()
	_balls.clear()
	for l in levels:
		l.visible = false
		l.process_mode =Node.PROCESS_MODE_DISABLED
	Global.current_level = level_index
	var level:Level = levels[level_index]
	level.visible = true
	level.process_mode = Node.PROCESS_MODE_INHERIT
	#level.reset()
	if level_index == 0:
		level.position.y = 250
		_is_first_click = true
		
	levelLabel.visible = level_index != 0
	levelLabel.text = "Level %d" % level_index
	
	
	match Global.current_level:
		0,1,2:
			_click_limit = 999
		3:
			_click_limit = 4
			
	limitLabel.visible = level_index > 2
	update_click_limit()
	
	var code = "BUBBLE"
	for i in range(len(code)):
		var b = level.bubbles[i]
		var is_moving:bool = Global.current_level in [1,2]
		match Global.current_level:
			0:
				b.init(code[i])
			1:
				b.init(code[i])
				b.start_move(randi()%2==1, 100+randi()%50, b.position.x - 150, b.position.x+150)
			2:
				b.init(code[i])
				b.start_move(false, 150+randi()%50, 50 + 600 * (i/3), 600+ 600*(i/3))
			3:
				b.init(code[i])
				b.start_move(false, 150, 50 + 600 * (i/3), 600+ 600*(i/3))
		b.s_bubble_clicked.connect(on_bubble_clicked)
		var h = level.holes[i]
		h.init(code[i])
		h.s_ball_in_hole.connect(on_ball_in_hole)

	
func on_bubble_clicked(bubble, is_active):
	print("Main.Bubble %s clicked" % bubble.get_char())
	var code = bubble.get_char()
	if is_active and code == "RESET":
		reset_level()
	
	if is_active and code == "NEXT":
		bubble.visible = false
		next_level()
		
	if code in ["B","U","L","E"]:
		if is_active:
			if _click_limit <= 0:
				red_blink_limit_label()
				return
			_click_limit -= 1	
			update_click_limit()
		if _is_first_click:
			move_down_level0()
			_is_first_click = false
			await get_tree().create_timer(0.5).timeout
		pop_the_bubble(bubble)

func red_blink_limit_label():
	var tween = create_tween()
	tween.tween_property(limitLabel, "self_modulate", Color.RED, 0.1)
	tween.tween_interval(0.5)
	tween.tween_property(limitLabel, "self_modulate", Color.WHITE, 0.1)

func update_click_limit():
	limitLabel.text = "Pop Limit: %d" % _click_limit

func move_down_level0() -> void:
	var tween = create_tween()
	tween.tween_property(levels[0], "position", Vector2(0,0), 0.5)

func reset_level():
	get_tree().reload_current_scene()
	
func next_level():
	if Global.current_level < len(levels)-1:
		init_level(Global.current_level+1)

func pop_the_bubble(bubble: Bubble) -> void:
	var obj = inner_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	obj.init(bubble.get_char())
	obj.position = bubble.position
	bubble.explode()
	levels[Global.current_level].add_child(obj)
	_balls.append(obj)
	
func on_ball_in_hole(ball:Inner, is_succeed:bool):
	if not is_succeed:
		print("Failed")
	else:
		var count = 0
		for h in levels[Global.current_level].holes:
			if h.is_succeed():
				count += 1
		if count == WIN_COUNT:
			win()
			print("WIN!")
			
func win():
	nextBubble.scale = Vector2(0.01, 0.01)
	create_tween().tween_property(nextBubble, "scale", Vector2(1.5,1.5), 0.5)
	nextBubble.visible = true
	
	
