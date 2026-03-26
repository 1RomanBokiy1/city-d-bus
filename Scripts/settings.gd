extends BaseScreen

@onready var text_speed_slider: HSlider = $Panel/TextSpeedSlider
@onready var text_speed_value: Label = $Panel/TextSpeedValue
@onready var reduce_animations: CheckBox = $Panel/ReduceAnimations
@onready var back_button: Button = $BackButton

func _ready() -> void:
	back_button.disabled = false

	text_speed_slider.value = GameManager.text_cps
	text_speed_value.text = str(int(GameManager.text_cps))
	reduce_animations.button_pressed = GameManager.reduce_animations

	text_speed_slider.value_changed.connect(Callable(self, "_on_text_speed_changed"))
	reduce_animations.toggled.connect(Callable(self, "_on_reduce_animations_toggled"))

func _on_text_speed_changed(v: float) -> void:
	GameManager.text_cps = v
	text_speed_value.text = str(int(v))

func _on_reduce_animations_toggled(pressed: bool) -> void:
	GameManager.reduce_animations = pressed

func _on_back_pressed() -> void:
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/menu.tscn")

