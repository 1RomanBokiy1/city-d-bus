# welcome.gd
extends BaseScreen
const PIXEL_UI = preload("res://shared/pixel_ui.gd")

@onready var speaker_panel: PanelContainer = $Speaker
@onready var speaker_text: RichTextLabel = $Speaker/Text
@onready var header_label: Label = $Header
@onready var continue_button: Button = $ContinueButton
@onready var mouth_open: ColorRect = $Speaker/NarratorIcon/MouthOpen
@onready var mouth_closed: ColorRect = $Speaker/NarratorIcon/MouthClosed
var _tap_requested: bool = false

func _ready() -> void:
	# Disable interaction until content is shown.
	continue_button.disabled = true

	# Intro animation: fade/scale speaker panel.
	speaker_panel.modulate.a = 0.0
	header_label.modulate.a = 0.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(header_label, "modulate:a", 1.0, 0.35)
	tween.tween_property(speaker_panel, "modulate:a", 1.0, 0.35)

	PIXEL_UI.style_button(continue_button, true, false)

	# Narrator speaks in chunks, tap to continue each chunk.
	var chunks = PackedStringArray()
	chunks.append("Добро пожаловать в D-Bus City!")
	chunks.append("В мире Android вы привыкли общаться через Intents и Binder.\nНо в Linux роль связного играет D-Bus.")
	chunks.append("Здесь приложения — это фабрики, а данные — грузовики.\nТвоя задача — навести порядок в городе.")

	for chunk in chunks:
		_start_talking()
		await reveal_text(speaker_text, chunk, GameManager.text_cps, true)
		_stop_talking()
		await _wait_tap()

	continue_button.disabled = false

func _on_continue_button_pressed() -> void:
	continue_button.disabled = true
	GameManager.current_level = 1
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/level.tscn")

func _start_talking() -> void:
	var loop_tween = create_tween()
	loop_tween.set_loops()
	loop_tween.tween_callback(Callable(self, "_mouth_open_state"))
	loop_tween.tween_interval(0.12)
	loop_tween.tween_callback(Callable(self, "_mouth_closed_state"))
	loop_tween.tween_interval(0.12)
	$Speaker.set_meta("talk_tween", loop_tween)

func _stop_talking() -> void:
	if $Speaker.has_meta("talk_tween"):
		var t = $Speaker.get_meta("talk_tween")
		if t:
			t.kill()
	$Speaker.remove_meta("talk_tween")
	_mouth_closed_state()

func _mouth_open_state() -> void:
	mouth_open.visible = true
	mouth_closed.visible = false

func _mouth_closed_state() -> void:
	mouth_open.visible = false
	mouth_closed.visible = true

func _wait_tap() -> void:
	_tap_requested = false
	while true:
		await get_tree().process_frame
		if _tap_requested:
			return

func _input(event: InputEvent) -> void:
	# Keep base typewriter-skip behavior.
	_unhandled_input(event)

	# Chunk-advance input for desktop + mobile.
	if event is InputEventScreenTouch and event.pressed:
		_tap_requested = true
	elif event is InputEventMouseButton and event.pressed:
		_tap_requested = true
	elif event.is_action_pressed("ui_accept"):
		_tap_requested = true
