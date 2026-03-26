extends Control
const PIXEL_UI = preload("res://shared/pixel_ui.gd")

@onready var title_container = $TitleContainer
@onready var buttons_vbox = $ButtonsVBox
@onready var levels_button = $ButtonsVBox/LevelsButton
@onready var settings_button = $SettingsButton
@onready var about_button = $AboutButton
@onready var clouds = $Clouds
@onready var cloud_left = $Clouds/CloudLeft
@onready var cloud_center = $Clouds/CloudCenter
@onready var cloud_right = $Clouds/CloudRight
@onready var cloud_bottom_a = $Clouds/CloudBottomA
@onready var cloud_bottom_b = $Clouds/CloudBottomB
@onready var cloud_top_ribbon = $Clouds/CloudTopRibbon

func _ready():
	# Скрываем всё перед анимацией
	title_container.modulate.a = 0
	buttons_vbox.modulate.a = 0
	settings_button.modulate.a = 0
	about_button.modulate.a = 0
	clouds.modulate.a = 1
	
	# Применяем красивые закруглённые стили к кнопкам
	setup_buttons()
	
	# Запускаем анимацию появления
	animate_appearance()

	# Ensure settings button works even if scene connections are missing.
	var settings_cb = Callable(self, "_on_settings_pressed")
	var about_cb = Callable(self, "_on_about_pressed")
	if not settings_button.pressed.is_connected(settings_cb):
		settings_button.pressed.connect(settings_cb)
	if not about_button.pressed.is_connected(about_cb):
		about_button.pressed.connect(about_cb)

# ====================== ЗАКРУГЛЁННЫЕ КНОПКИ ======================
func setup_buttons():
	PIXEL_UI.style_button($ButtonsVBox/PlayButton, true, false)
	PIXEL_UI.style_button(levels_button, false, false)

func _start_cloud_drift() -> void:
	var t = create_tween()
	t.set_loops()
	t.tween_property(cloud_left, "position:x", cloud_left.position.x + 90.0, 3.8)
	t.parallel().tween_property(cloud_right, "position:x", cloud_right.position.x - 110.0, 4.2)
	t.parallel().tween_property(cloud_center, "position:x", cloud_center.position.x + 60.0, 4.0)
	t.parallel().tween_property(cloud_bottom_a, "position:x", cloud_bottom_a.position.x + 70.0, 4.6)
	t.parallel().tween_property(cloud_bottom_b, "position:x", cloud_bottom_b.position.x - 80.0, 4.6)
	t.parallel().tween_property(cloud_top_ribbon, "position:y", cloud_top_ribbon.position.y + 12.0, 3.0)
	t.tween_property(cloud_left, "position:x", cloud_left.position.x, 0.1)
	t.parallel().tween_property(cloud_right, "position:x", cloud_right.position.x, 0.1)
	t.parallel().tween_property(cloud_center, "position:x", cloud_center.position.x, 0.1)
	t.parallel().tween_property(cloud_bottom_a, "position:x", cloud_bottom_a.position.x, 0.1)
	t.parallel().tween_property(cloud_bottom_b, "position:x", cloud_bottom_b.position.x, 0.1)
	t.parallel().tween_property(cloud_top_ribbon, "position:y", cloud_top_ribbon.position.y, 0.1)

# ====================== АНИМАЦИЯ ПОЯВЛЕНИЯ ======================
func animate_appearance():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Заголовок появляется первым и с лёгким "подпрыгиванием"
	tween.tween_property(title_container, "modulate:a", 1.0, 0.9).from(0.0)
	tween.parallel().tween_property(title_container, "position:y", title_container.position.y - 40, 1.0)\
		 .as_relative().set_trans(Tween.TRANS_BACK)
	
	# Кнопки
	tween.tween_property(buttons_vbox, "modulate:a", 1.0, 0.8).from(0.0)
	
	# Шестерёнка
	tween.tween_property(settings_button, "modulate:a", 1.0, 0.5).from(0.0)
	tween.parallel().tween_property(about_button, "modulate:a", 1.0, 0.5).from(0.0)
	_start_cloud_drift()

func _animate_clouds_open() -> void:
	var t = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(cloud_left, "position:x", cloud_left.position.x - 620, 0.45)
	t.parallel().tween_property(cloud_right, "position:x", cloud_right.position.x + 620, 0.45)
	t.parallel().tween_property(cloud_center, "position:y", cloud_center.position.y - 520, 0.5)
	t.parallel().tween_property(cloud_bottom_a, "position:y", cloud_bottom_a.position.y + 620, 0.48)
	t.parallel().tween_property(cloud_bottom_b, "position:y", cloud_bottom_b.position.y + 620, 0.48)
	t.parallel().tween_property(cloud_top_ribbon, "position:y", cloud_top_ribbon.position.y - 260, 0.4)
	t.parallel().tween_property(clouds, "modulate:a", 0.0, 0.45)
	await t.finished

# ====================== НАЖАТИЯ КНОПОК ======================
func _on_play_pressed():
	# Fresh run.
	GameManager.current_level = 1
	GameManager.unlocked_level = 1
	GameManager.score = 0
	GameManager.last_result = false
	GameManager.last_explanation = ""
	GameManager.showed_welcome = false

	press_animation($ButtonsVBox/PlayButton)
	await get_tree().create_timer(0.15).timeout
	await _animate_clouds_open()
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/start_level.tscn")

func _on_settings_pressed():
	press_animation(settings_button)
	await get_tree().create_timer(0.15).timeout
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/settings.tscn")

func _on_levels_pressed():
	press_animation(levels_button)
	await get_tree().create_timer(0.1).timeout
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/level_select.tscn")

func _on_about_pressed():
	press_animation(about_button)
	await get_tree().create_timer(0.1).timeout
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/about.tscn")

# Анимация нажатия кнопки
func press_animation(node):
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.18)
