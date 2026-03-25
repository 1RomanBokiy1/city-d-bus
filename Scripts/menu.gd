extends Control

func _ready():
	print("Menu loaded")

func _on_play_pressed():
	if not GameManager.showed_welcome:
		GameManager.showed_welcome = true
		get_tree().change_scene_to_file("res://Scenes/start_level.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_quit_pressed():
	get_tree().quit()
