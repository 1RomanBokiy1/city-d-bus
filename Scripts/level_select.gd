extends Control

@onready var scroll = $ScrollContainer
@onready var vbox = $ScrollContainer/LevelsVBox
@onready var background = $Background

func _ready() -> void:
	background.modulate = Color(1, 1, 1, 0.95)

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
		btn.custom_minimum_size = Vector2(720, 115)
		btn.add_theme_font_size_override("font_size", 60)
		btn.modulate.a = 0.0
		
		# Цвет текста всегда тёмный
		btn.add_theme_color_override("font_color", Color(0.05, 0.05, 0.05))
		btn.add_theme_color_override("font_hover_color", Color(0.05, 0.05, 0.05))
		btn.add_theme_color_override("font_pressed_color", Color(0.05, 0.05, 0.05))
		
		# Стиль карточки (как на твоём последнем скрине)
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1, 0.98)           # почти непрозрачный
		style.corner_radius_top_left = 22
		style.corner_radius_top_right = 22
		style.corner_radius_bottom_left = 22
		style.corner_radius_bottom_right = 22
		style.border_width_left = 20
		style.border_color = Color("#00B5A3")
		style.shadow_color = Color(0, 0, 0, 0.2)
		style.shadow_size = 15
		style.shadow_offset = Vector2(0, 10)
		
		var style_hover = style.duplicate()
		style_hover.bg_color = Color(0.96, 0.99, 1.0, 1.0)
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style)
		
		# Locked state (no emoji; keep consistent UI).
		if i > GameManager.unlocked_level:
			btn.disabled = true
			btn.text += "  (закрыто)"
			btn.modulate.a = 0.55
		else:
			btn.modulate.a = 0.0
		
		btn.pressed.connect(Callable(self, "_on_level_pressed").bind(i))
		vbox.add_child(btn)

		# Animate unlocked cards in.
		if not btn.disabled:
			var local_tween = create_tween()
			local_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			local_tween.tween_property(btn, "modulate:a", 1.0, 0.25).set_delay(0.04 * i)

	# Кнопка Назад
	var back = Button.new()
	back.text = "Назад"
	back.custom_minimum_size = Vector2(420, 95)
	back.add_theme_font_size_override("font_size", 40)
	
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color("#00B5A3")
	back_style.corner_radius_top_left = 18
	back_style.corner_radius_top_right = 18
	back_style.corner_radius_bottom_left = 18
	back_style.corner_radius_bottom_right = 18
	back.add_theme_stylebox_override("normal", back_style)
	
	back.pressed.connect(Callable(self, "_on_back_pressed"))
	vbox.add_child(back)

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
