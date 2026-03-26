# welcome.gd
extends BaseScreen

@onready var speaker_panel: PanelContainer = $Speaker
@onready var speaker_text: RichTextLabel = $Speaker/Text
@onready var header_label: Label = $Header
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
	# Disable interaction until content is shown.
	continue_button.disabled = true

	# Intro animation: fade/scale speaker panel.
	speaker_panel.modulate.a = 0.0
	header_label.modulate.a = 0.0
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(header_label, "modulate:a", 1.0, 0.35)
	tween.tween_property(speaker_panel, "modulate:a", 1.0, 0.35)

	# Typing effect for the narrator text.
	await reveal_text(speaker_text, GameManager.welcome_text, GameManager.text_cps, true)

	continue_button.disabled = false

func _on_continue_button_pressed() -> void:
	continue_button.disabled = true
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/level_select.tscn")
