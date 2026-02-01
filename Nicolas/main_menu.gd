extends Control


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Alois/Scenes/face_snatcher_level_1.tscn")


func _on_leave_button_pressed() -> void:
	get_tree().quit()
