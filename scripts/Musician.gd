extends KinematicBody2D

var velocity = Vector2(0, 0)
var friction = -0.2
var use_friction = false

func _ready():
	pass

var _delta
func _physics_process(delta):
	_delta = delta
	move_and_slide(velocity)# * (friction * delta) if use_friction else Vector2(1, 1))
	pass

func _on_Player_moved(vel):
	velocity = vel

func _on_Player_hit(travel, reminder):
	var v = (reminder + travel) * (rand_range(0, 3) - friction) / _delta
	v.rotated(rand_range(0, 2 * PI))
	velocity = v

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()