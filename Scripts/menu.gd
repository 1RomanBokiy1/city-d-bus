extends Control

@onready var title_container = $TitleContainer
@onready var buttons_vbox = $ButtonsVBox
@onready var aurora_icon = $AuroraIcon
@onready var play_button = $ButtonsVBox/PlayButton
@onready var about_button = $ButtonsVBox/AboutButton
@onready var settings_button = $SettingsButton

func _ready():
	# Скрываем всё перед анимацией
	title_container.modulate.a = 0
	buttons_vbox.modulate.a = 0
	aurora_icon.modulate.a = 0
	settings_button.modulate.a = 0
	
	# Запускаем красивую анимацию появления
	animate_appearance()

func animate_appearance():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# 1. Появление заголовка
	tween.tween_property(title_container, "modulate:a", 1.0, 0.8).from(0.0)
	
	# 2. Появление иконки Авроры
	tween.tween_property(aurora_icon, "modulate:a", 1.0, 0.6).from(0.0)
	
	# 3. Появление кнопок
	tween.tween_property(buttons_vbox, "modulate:a", 1.0, 0.7).from(0.0)
	
	# 4. Появление шестерёнки
	tween.tween_property(settings_button, "modulate:a", 1.0, 0.5).from(0.0)
	
	# Лёгкая анимация "подпрыгивания" заголовка
	tween.tween_property(title_container, "position:y", title_container.position.y - 30, 0.6)\
		 .as_relative().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

# ==================== КНОПКИ ====================

func _on_play_pressed():
	press_animation(play_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/start_level.tscn")

func _on_about_pressed():
	press_animation(about_button)
	await get_tree().create_timer(0.15).timeout
	# Пока просто печатаем, потом сделаем экран "Об игре"
	print("Экран 'Об игре' открыт")

func _on_settings_pressed():
	press_animation(settings_button)
	await get_tree().create_timer(0.15).timeout
	print("Открыты настройки")

# Анимация нажатия (лёгкое уменьшение + возврат)
func press_animation(button: Button):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(0.92, 0.92), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.2)
