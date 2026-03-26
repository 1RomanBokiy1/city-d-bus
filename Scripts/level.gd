# level.gd
extends BaseScreen

@onready var header_label: Label = $Header
@onready var speaker_text: RichTextLabel = $SpeakerText/Text
@onready var choice_panel: VBoxContainer = $ChoicePanel
@onready var choice1_button: Button = $ChoicePanel/Choice1
@onready var choice2_button: Button = $ChoicePanel/Choice2

func _ready() -> void:
	var data = GameManager.levels_data[GameManager.current_level]

	header_label.text = data.name
	choice1_button.text = data.choices[0].text
	choice2_button.text = data.choices[1].text

	choice_panel.modulate.a = 0.0
	choice1_button.disabled = true
	choice2_button.disabled = true

	# Animate speaker & choices in.
	var intro = create_tween()
	intro.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro.tween_property($Speaker, "modulate:a", 1.0, 0.25)
	intro.parallel().tween_property(choice_panel, "modulate:a", 1.0, 0.25)

	await reveal_text(speaker_text, data.task, GameManager.text_cps, true)

	choice1_button.disabled = false
	choice2_button.disabled = false

func _on_choice_1_pressed() -> void:
	_process_choice(0)

func _on_choice_2_pressed() -> void:
	_process_choice(1)

func _process_choice(idx: int) -> void:
	var choice = GameManager.levels_data[GameManager.current_level].choices[idx]

	choice1_button.disabled = true
	choice2_button.disabled = true

	# Update game state.
	GameManager.last_result = choice.correct
	if choice.correct:
		GameManager.score += 1
	GameManager.last_explanation = choice.explanation

	# Small press feedback.
	var tween = create_tween()
	tween.tween_property(choice_panel, "scale", Vector2(0.985, 0.985), 0.08).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/explanation.tscn")
