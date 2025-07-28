extends Node2D

@onready var sprite = $Sprite
@onready var line:Line2D = $Line2D

@export var globalPosition:Vector2
var isReady = false
var weapon:Vector2

var t = 0.0
var speed = 1

var p0: Vector2
var p1: Vector2
var p2: Vector2

func _process(delta: float) -> void:
	if t <= 1.0 && isReady:
		# Position along curve
		sprite.global_position = _quadratic_bezier(p0, p1, p2, t)

		# Small look-ahead point
		var look_ahead_t = clamp(t + 0.01, 0, 1)
		var next_point = _quadratic_bezier(p0, p1, p2, look_ahead_t)
		
		# Get direction vector and rotate
		var direction = (next_point - sprite.global_position).normalized()
		if direction.x > 0:
			sprite.rotation = atan2(direction.y, direction.x)
		elif direction.x < 0:
			sprite.rotation = atan2(-direction.y, -direction.x)

		t += speed * delta
	else:
		queue_free()

func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r
	
func setReady(flip:bool, weapon:Vector2, mousePos:Vector2):
	if flip:
		sprite.global_position = globalPosition + Vector2(-30,-20)
		p0 = sprite.global_position
		p1 = globalPosition + mousePos - Vector2(0,(globalPosition + mousePos).y / 2) #+ Vector2((globalPosition + mousePos).x, 0)
		p2 = globalPosition + mousePos
		sprite.flip_h = true
	else:
		sprite.global_position = globalPosition + Vector2(-30,-20)
		p0 = sprite.global_position
		p1 = globalPosition + mousePos - Vector2(0,(globalPosition + mousePos).y / 2) #+ Vector2((globalPosition + mousePos).x, 0)
		p2 = globalPosition + mousePos
	self.weapon = weapon
	isReady = true
	#line.add_point(sprite.position)
	#line.add_point(get_local_mouse_position())

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("damage"):
			body.call("damage", randi_range(weapon.x, weapon.y))
			queue_free()
