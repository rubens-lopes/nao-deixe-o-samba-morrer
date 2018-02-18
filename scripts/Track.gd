extends TileMap

signal screen_entered

func _on_Visibility_screen_exited():
	queue_free()

func _on_Visibility_screen_entered():
	emit_signal("screen_entered")