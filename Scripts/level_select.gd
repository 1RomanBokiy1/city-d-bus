extends Control

@onready var scroll = $ScrollContainer
@onready var vbox = $ScrollContainer/LevelsVBox
@onready var background = $Background

func _ready():
	background.modulate = Color(1, 1, 1, 0.95)
	
	# Настраиваем ScrollContainer чтобы точно скроллился
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	#scroll.scroll_vertical_enabled = true
	
	for i in range(1, 7):
		var btn = Button.new()
		btn.text = str(i) + ". " + GameManager.levels_data[i].name
		btn.custom_minimum_size = Vector2(720, 115)
		btn.add_theme_font_size_override("font_size", 60)
		
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
		
		# Замочек
		if i > GameManager.unlocked_level:
			btn.disabled = true
			btn.text += "    🔒"
		
		btn.pressed.connect(_on_level_pressed.bind(i))
		vbox.add_child(btn)

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
	
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://Scenes/menu.tscn"))
	vbox.add_child(back)

func _on_level_pressed(level: int):
	if level > GameManager.unlocked_level:
		return
	GameManager.current_level = level
	get_tree().change_scene_to_file("res://Scenes/level.tscn")
