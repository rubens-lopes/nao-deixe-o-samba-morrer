extends StaticBody2D

func _ready():
	rotation = rand_range(0, 2 * PI)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
