extends KinematicBody2D

export (Vector2) var ACCELERATION = Vector2(0, 150)
export (Vector2) var MAX_VELOCITY = Vector2(1000, 500)
export (Vector2) var MIN_VELOCITY = Vector2(1000, 0)
export (float) var FRICTION = -0.1

var velocity = Vector2(1000, 0)

var can_move = false

func _ready():
	pass
	
func _physics_process(delta):
	if not can_move:
		return
	
	var acc = Vector2()
	if Input.is_action_pressed("ui_up"):
		acc.y = -1
	if Input.is_action_pressed("ui_down"):
		acc.y = 1

	acc.y *= ACCELERATION.y
	if acc.y == 0:
		acc.y = velocity.y * FRICTION

	velocity += acc

	velocity.x = clamp(velocity.x, MIN_VELOCITY.x, MAX_VELOCITY.x)
	velocity.y = clamp(velocity.y, -MAX_VELOCITY.y, MAX_VELOCITY.y)
	
	move_and_slide(velocity)
