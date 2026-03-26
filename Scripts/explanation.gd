# explanation.gd
extends BaseScreen
const PIXEL_UI = preload("res://shared/pixel_ui.gd")

@onready var header_label: Label = $Header
@onready var explanation_text: RichTextLabel = $ExplanationText/Text
@onready var next_button: Button = $NextLevel

func _ready() -> void:
	var data = GameManager.levels_data[GameManager.current_level]
	header_label.text = data.name

	next_button.disabled = true
	$ExplanationText.modulate.a = 0.0
	var intro = create_tween()
	intro.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro.tween_property($ExplanationText, "modulate:a", 1.0, 0.25)

	await reveal_text(explanation_text, GameManager.last_explanation, GameManager.text_cps, true)
	PIXEL_UI.style_button(next_button, true, false)
	next_button.disabled = false

func _on_next_level_pressed() -> void:
	go_next()

func go_next() -> void:
	next_button.disabled = true
	GameManager.current_level += 1

	if GameManager.current_level > GameManager.unlocked_level:
		GameManager.unlocked_level = GameManager.current_level

	if GameManager.current_level > 6:
		var stm = get_node_or_null("/root/SceneTransitionManager")
		if stm != null:
			await stm.change_scene_to_file("res://Scenes/final.tscn")
	else:
		var stm2 = get_node_or_null("/root/SceneTransitionManager")
		if stm2 != null:
			await stm2.change_scene_to_file("res://Scenes/level.tscn")
