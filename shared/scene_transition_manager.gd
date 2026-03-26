extends Node

# Handles consistent scene transitions (fade + change scene).
# Autoload-only: instance is available globally as `SceneTransitionManager`.

var _busy: bool = false
var _fade_layer: CanvasLayer
var _fade_rect: ColorRect

func _ready() -> void:
	_create_fade_layer()

func _create_fade_layer() -> void:
	# Если уже существует — не создаём заново
	if _fade_rect != null and is_instance_valid(_fade_rect):
		return

	_fade_layer = CanvasLayer.new()
	_fade_layer.layer = 1000

	_fade_rect = ColorRect.new()
	_fade_rect.name = "FadeRect"
	_fade_rect.color = Color.BLACK
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Растягиваем на весь экран
	_fade_rect.anchor_left = 0.0
	_fade_rect.anchor_top = 0.0
	_fade_rect.anchor_right = 1.0
	_fade_rect.anchor_bottom = 1.0

	_fade_rect.offset_left = 0.0
	_fade_rect.offset_top = 0.0
	_fade_rect.offset_right = 0.0
	_fade_rect.offset_bottom = 0.0

	_fade_layer.add_child(_fade_rect)

	# ВАЖНО: используем deferred
	get_tree().root.add_child.call_deferred(_fade_layer)

func _ensure_fade() -> void:
	if _fade_rect != null and is_instance_valid(_fade_rect):
		return
	_create_fade_layer()

func _fade_to(alpha: float, duration: float):
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(_fade_rect, "modulate:a", alpha, duration)
	return tween.finished

func change_scene_to_file(scene_path: String, fade_duration: float = 0.22) -> void:
	if _busy:
		return
	if scene_path.is_empty():
		return

	_busy = true
	_ensure_fade()

	# Ждём, чтобы fade_layer точно добавился в дерево
	await get_tree().process_frame
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	# Fade in
	await _fade_to(1.0, fade_duration)
	_fade_rect.modulate.a = 1.0

	# Смена сцены
	get_tree().change_scene_to_file(scene_path)

	# Ждём кадр после смены сцены
	await get_tree().process_frame

	# Fade out
	await _fade_to(0.0, fade_duration)
	_fade_rect.modulate.a = 0.0
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	_busy = false