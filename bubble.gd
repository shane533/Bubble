extends Node2D
class_name Bubble

@export var label:Label
@export var outer: Sprite2D
@export var target_char: String
@export var explosion: AnimatedSprite2D

signal s_bubble_clicked(bubble, is_active)

var _is_moving:bool = false
var _is_towards_left: bool = true
var _left_border:int
var _right_border:int
var _speed:float

var _is_growing:bool = false
var _growing_time:float = 1
const BASE_SCALE:float = 1
const GLOW_SCALE:float = 1.5
const MAX_SCALE:float = 1.8

func _ready() -> void:
	tween_floating()


func init(p_char:String):
	print("INIT BUBBLE %d" % get_instance_id())
	target_char = p_char
	label.text = p_char

func start_move(is_left:bool, speed:float = 0, left_border:int = 0, right_border:int = 0):
		_is_moving = true
		_is_towards_left = is_left
		_left_border = left_border
		_right_border = right_border
		_speed = speed
		
func start_grow(grow_time:float):
	_is_growing = true
	_growing_time = grow_time
	
func _input(event: InputEvent) -> void:
	if not self.is_visible_in_tree():
		return
	if explosion.is_playing():
		return
	if event is InputEventMouseButton and event.is_pressed() and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if outer.get_rect().has_point(outer.to_local(event.position)):
			if target_char != "":
				print("Bubble.bubble %s clicked" % target_char)
			else:
				print("Bubble.bubble %d clicked" % get_instance_id())
			s_bubble_clicked.emit(self, true)

func get_char():
	return target_char
	
func explode():
	_is_moving= false
	_is_growing = false
	explosion.frame = 0
	explosion.visible = true
	outer.visible = false
	$InnerNode.visible = false
	$OuterNode/Area2D/CollisionShape2D.set_deferred("disabled", true)
	explosion.play()

func tween_floating():
	await get_tree().create_timer(randf()).timeout
	var tween = create_tween()
	var oriX = outer.scale.x
	var oriY = outer.scale.y
	tween.tween_property(outer, "scale", Vector2(oriX*0.95, oriY*1.05), 1).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(outer, "scale", Vector2(oriX*0.98, oriY*0.9), 1).set_trans(Tween.TRANS_LINEAR)
	#tween.tween_property(self, "scale", Vector2(0.98, 0.9), 0.5).set_trans(Tween.TRANS_BOUNCE)
	tween.set_loops(0)
	
func _process(delta: float) -> void:
	if _is_moving:
		var delta_offset = delta * _speed
		if _is_towards_left:
			self.position.x = self.position.x - delta_offset
			if self.position.x < _left_border:
				_is_towards_left = !_is_towards_left
		else:
			self.position.x = self.position.x + delta_offset
			if self.position.x > _right_border:
				_is_towards_left = !_is_towards_left

	if _is_growing:
		var delta_scale = (MAX_SCALE - BASE_SCALE)/_growing_time * delta
		var outerNode = $OuterNode
		outerNode.scale = Vector2(outerNode.scale.x + delta_scale, outerNode.scale.y+delta_scale)
		if outerNode.scale.x >= GLOW_SCALE:
			if int((outerNode.scale.x - GLOW_SCALE) * 100) % 2 == 0:
				outer.self_modulate = Color.RED
			else:
				outer.self_modulate = Color.WHITE
		if outerNode.scale.x >= MAX_SCALE:
			_is_growing = false
			s_bubble_clicked.emit(self, false)
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Inner:
		print("%s enterred this bubble!" % body.get_char())
		s_bubble_clicked.emit(self, false)


func _on_explode_animation_finished() -> void:
	self.queue_free()
