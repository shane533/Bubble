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
var _levelBubbles: Array = []

var _is_showing_levels: bool = false
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
		l.position.y= 2000
		l.process_mode =Node.PROCESS_MODE_DISABLED
	Global.current_level = level_index
	var level:Level = levels[level_index]
	level.visible = true
	level.position.y = 0
	level.process_mode = Node.PROCESS_MODE_INHERIT
	#level.reset()
	if level_index == 0:
		level.position.y = 250
		_is_first_click = true
		
	levelLabel.visible = level_index != 0
	levelLabel.text = "Level %d" % level_index
	
	limitLabel.visible = level_index > 2
	_click_limit = level.levelData.pop_limit
	update_click_limit()
	
	var code = "BUBBLE"
	for i in range(len(code)):
		var b = level.bubbles[i]
		var is_moving:bool = Global.current_level in [1,2]
		b.init(code[i])
		match Global.current_level:
			
			1:
				b.start_move(randi()%2==1, 100+randi()%50, b.position.x - 150, b.position.x+150)
			2:
				b.start_move(false, 150+randi()%50, 50 + 600 * (i/3), 600+ 600*(i/3))
			3:
				b.start_move(false, 150, 50 + 600 * (i/3), 600+ 600*(i/3))
			4:
				b.start_move(false, 150+randi()%50, 50, 1000)
			6:
				b.start_move(i%2==1, 150, 50, 1200)
				#b.start_grow(5)
		if len(level.levelData.bubble_grow_time) > i:
			b.start_grow(level.levelData.bubble_grow_time[i])
		b.s_bubble_clicked.connect(on_bubble_clicked)
		var h = level.holes[i]
		h.init(code[i])
		h.s_ball_in_hole.connect(on_ball_in_hole)

	
func on_bubble_clicked(bubble, is_active):
	print("Main.Bubble %s clicked" % bubble.get_char())
	var code:String = bubble.get_char()
	if is_active and code == "RESET":
		reset_level()
		return 
		
	if is_active and code == "LIST":
		show_hide_levels()
		return
		
	if is_active and code == "NEXT":
		bubble.visible = false
		next_level()
		return
		
	if is_active and code.is_valid_int():
		print("Jump to Level %d" % int(code))
		init_level(int(code))
		return
		
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

func show_hide_levels():
	if _is_showing_levels:
		for b in _levelBubbles:
			b.queue_free()
		_levelBubbles.clear()
	else:
		for i in range(len(levels)):
			var lb = bubble_ts.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			lb.init("%d" % i)
			lb.position.y = (i+1) * 120
			lb.s_bubble_clicked.connect(on_bubble_clicked)
			$TopRightUI/ListButton.add_child(lb)
			_levelBubbles.append(lb)
	_is_showing_levels = !_is_showing_levels

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
	
	
