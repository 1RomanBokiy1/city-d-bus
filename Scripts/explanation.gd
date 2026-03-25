# explanation.gd
extends Control

func _ready():
	var data = GameManager.levels_data[GameManager.current_level]
	$Header.text = data.name
	$ExplanationText/Text.text = GameManager.last_explanation

func _on_next_level_pressed() -> void:
	go_next()

func go_next():
	GameManager.current_level += 1
	
	if GameManager.current_level > GameManager.unlocked_level:
		GameManager.unlocked_level = GameManager.current_level
	
	if GameManager.current_level > 6:
		get_tree().change_scene_to_file("res://Scenes/final.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/level.tscn")
