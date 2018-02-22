extends StaticBody2D

func _ready():
	rotation = rand_range(0, PI / 4)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
