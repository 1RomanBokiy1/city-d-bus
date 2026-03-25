# level.gd
extends Control

func _ready():
	var data = GameManager.levels_data[GameManager.current_level]
	$Header.text = data.name
	$SpeakerText/Text.text = data.task
	$ChoicePanel/Choice1.text = data.choices[0].text
	$ChoicePanel/Choice2.text = data.choices[1].text

func _on_choice_1_pressed():
	_process_choice(0)

func _on_choice_2_pressed():
	_process_choice(1)

func _process_choice(idx: int):
	var choice = GameManager.levels_data[GameManager.current_level].choices[idx]
	
	GameManager.last_result = choice.correct
	if choice.correct:
		GameManager.score += 1
	GameManager.last_explanation = choice.explanation
	
	get_tree().change_scene_to_file("res://Scenes/explanation.tscn")
