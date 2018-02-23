extends KinematicBody2D

var velocity = Vector2(0, 0)

func _ready():
	pass

func _physics_process(delta):
	move_and_slide(velocity)
	pass

func _on_Player_moved(vel):
	velocity = vel

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()