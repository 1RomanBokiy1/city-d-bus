extends Control

@onready var title_container = $TitleContainer
@onready var buttons_vbox = $ButtonsVBox
@onready var aurora_icon = $AuroraIcon
@onready var settings_button = $SettingsButton

func _ready():
	# Скрываем всё перед анимацией
	title_container.modulate.a = 0
	buttons_vbox.modulate.a = 0
	aurora_icon.modulate.a = 0
	settings_button.modulate.a = 0
	
	# Применяем красивые закруглённые стили к кнопкам
	setup_buttons()
	
	# Запускаем анимацию появления
	animate_appearance()

# ====================== ЗАКРУГЛЁННЫЕ КНОПКИ ======================
func setup_buttons():
	round_button($ButtonsVBox/PlayButton, Color("#00B5A3"), true)   # главная кнопка
	round_button($ButtonsVBox/AboutButton, Color(1, 1, 1, 0.95), false)

func round_button(button: Button, base_color: Color, is_primary: bool):
	# Normal стиль
	var normal = StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.corner_radius_top_left = 32
	normal.corner_radius_top_right = 32
	normal.corner_radius_bottom_left = 32
	normal.corner_radius_bottom_right = 32
	normal.shadow_color = Color(0, 0, 0, 0.25)
	normal.shadow_size = 12
	normal.shadow_offset = Vector2(0, 8)
	
	if not is_primary:
		normal.border_width_left = 4
		normal.border_width_right = 4
		normal.border_width_bottom = 4
		normal.border_color = Color("#00B5A3")
	
	button.add_theme_stylebox_override("normal", normal)
	
	# Hover стиль
	var hover = normal.duplicate()
	hover.bg_color = base_color.lightened(0.15) if is_primary else base_color.darkened(0.05)
	button.add_theme_stylebox_override("hover", hover)
	
	# Pressed стиль
	var pressed_style = normal.duplicate()
	pressed_style.bg_color = base_color.darkened(0.18)
	button.add_theme_stylebox_override("pressed", pressed_style)

# ====================== АНИМАЦИЯ ПОЯВЛЕНИЯ ======================
func animate_appearance():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Заголовок появляется первым и с лёгким "подпрыгиванием"
	tween.tween_property(title_container, "modulate:a", 1.0, 0.9).from(0.0)
	tween.parallel().tween_property(title_container, "position:y", title_container.position.y - 40, 1.0)\
		 .as_relative().set_trans(Tween.TRANS_BACK)
	
	# Иконка Авроры
	tween.tween_property(aurora_icon, "modulate:a", 1.0, 0.6).from(0.0)
	
	# Кнопки
	tween.tween_property(buttons_vbox, "modulate:a", 1.0, 0.8).from(0.0)
	
	# Шестерёнка
	tween.tween_property(settings_button, "modulate:a", 1.0, 0.5).from(0.0)

# ====================== НАЖАТИЯ КНОПОК ======================
func _on_play_pressed():
	press_animation($ButtonsVBox/PlayButton)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/start_level.tscn")

func _on_about_pressed():
	press_animation($ButtonsVBox/AboutButton)
	await get_tree().create_timer(0.15).timeout
	print("Открыт экран 'Об игре'")

func _on_settings_pressed():
	press_animation(settings_button)
	await get_tree().create_timer(0.15).timeout
	print("Открыты настройки")

# Анимация нажатия кнопки
func press_animation(node):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.18)
