extends Control
const PIXEL_UI = preload("res://shared/pixel_ui.gd")

@onready var scroll = $ScrollContainer
@onready var vbox = $ScrollContainer/LevelsVBox
@onready var background = $Background
@onready var back_button = $BackButton

func _ready() -> void:
	background.modulate = Color(1, 1, 1, 0.95)
	PIXEL_UI.style_button(back_button, true, false)

	# Subtle entrance animation for list.
	vbox.modulate.a = 0.0
	var entrance = create_tween()
	entrance.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entrance.tween_property(vbox, "modulate:a", 1.0, 0.35)
	
	# Настраиваем ScrollContainer чтобы точно скроллился
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	#scroll.scroll_vertical_enabled = true
	
	for i in range(1, 7):
		var btn = Button.new()
		btn.text = str(i) + ". " + GameManager.levels_data[i].name
		btn.custom_minimum_size = Vector2(860, 120)
		PIXEL_UI.style_button(btn, false, false)
		btn.modulate.a = 0.0

		# Locked state (no emoji; keep consistent UI).
		if i > GameManager.unlocked_level:
			btn.disabled = true
			btn.text += "  (закрыто)"
			btn.modulate.a = 0.7
		else:
			btn.modulate.a = 0.0
		
		btn.pressed.connect(Callable(self, "_on_level_pressed").bind(i))
		vbox.add_child(btn)

		# Animate unlocked cards in.
		if not btn.disabled:
			var local_tween = create_tween()
			local_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			local_tween.tween_property(btn, "modulate:a", 1.0, 0.25).set_delay(0.04 * i)

func _on_back_pressed() -> void:
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/menu.tscn")

func _on_level_pressed(level: int) -> void:
	if level > GameManager.unlocked_level:
		return
	GameManager.current_level = level
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/level.tscn")
