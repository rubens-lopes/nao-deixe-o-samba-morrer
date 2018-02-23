extends KinematicBody2D

signal hit
signal moved

var acceleration = Vector2(500, 1500)
var friction = Vector2(-10, -150)
var bounce_coefficent = 0.5
var velocity = Vector2()
var can_move = false

var state = IDLE
enum {THRUST, AUTO_BREAK, BREAK, IDLE}

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
		
	acc.y *= acceleration.y
	if acc.y == 0:
        acc.y = velocity.y * friction.y * delta
	
	acc.x = 1
	if Input.is_action_pressed("ui_left"):
		state = BREAK
		acc.x = -1
	elif Input.is_action_pressed("ui_right"):
		state = THRUST
	elif velocity.x > 750:
		state = AUTO_BREAK
	else:
		state = IDLE
		
	acc.x *= acceleration.x
	if state == AUTO_BREAK:
		acc.x = velocity.x * friction.x * delta
	
	velocity += acc * delta
	match(state):
		AUTO_BREAK: velocity.x = max(velocity.x, 750)
		THRUST: velocity.x = min(velocity.x, 1500)
		BREAK: velocity.x = max(velocity.x, 500)
		IDLE: velocity.x = min(velocity.x, 750)
	
	var collision = move_and_collide(velocity * delta)
	emit_signal("moved", velocity)

	if collision:
		emit_signal("hit")
		velocity = velocity.bounce(collision.normal) * bounce_coefficent