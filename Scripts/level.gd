# level.gd
extends BaseScreen
const PIXEL_UI = preload("res://shared/pixel_ui.gd")

@onready var header_label: Label = $Header
@onready var speaker_text: RichTextLabel = $SpeakerText/Text
@onready var choice_panel: VBoxContainer = $ChoicePanel
@onready var choice1_button: Button = $ChoicePanel/Choice1
@onready var choice2_button: Button = $ChoicePanel/Choice2
@onready var city_overlay: Control = $CityOverlay
@onready var car1: ColorRect = $CityOverlay/Car1
@onready var car2: ColorRect = $CityOverlay/Car2
@onready var speaker_panel: Panel = $SpeakerText
@onready var mouth_open: ColorRect = $SpeakerText/NarratorIcon/MouthOpen
@onready var mouth_closed: ColorRect = $SpeakerText/NarratorIcon/MouthClosed

var _tap_requested: bool = false

func _ready() -> void:
	var data = GameManager.levels_data[GameManager.current_level]

	header_label.text = data.name
	choice1_button.text = data.choices[0].text
	choice2_button.text = data.choices[1].text
	PIXEL_UI.style_button(choice1_button, false, false)
	PIXEL_UI.style_button(choice2_button, false, false)
	_start_city_loop()

	choice_panel.modulate.a = 0.0
	choice_panel.visible = false
	choice1_button.disabled = true
	choice2_button.disabled = true
	speaker_panel.visible = false

	# Сначала показываем хаос в городе, затем диктора и выбор.
	await get_tree().create_timer(0.7).timeout
	speaker_panel.visible = true
	await _speak_chunks(_split_for_dialog(data.task))

	choice_panel.visible = true
	var intro = create_tween()
	intro.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro.tween_property(choice_panel, "modulate:a", 1.0, 0.25).from(0.0)
	choice1_button.disabled = false
	choice2_button.disabled = false

func _on_choice_1_pressed() -> void:
	_process_choice(0)

func _on_choice_2_pressed() -> void:
	_process_choice(1)

func _process_choice(idx: int) -> void:
	var choice = GameManager.levels_data[GameManager.current_level].choices[idx]

	choice1_button.disabled = true
	choice2_button.disabled = true
	choice_panel.visible = false
	speaker_panel.visible = false

	# Update game state.
	GameManager.last_result = choice.correct
	if choice.correct:
		GameManager.score += 1
	GameManager.last_explanation = choice.explanation
	await _show_choice_result(choice.correct)

	speaker_panel.visible = true
	await _speak_chunks(_split_for_dialog(choice.explanation))
	speaker_panel.visible = false

	# Переходим на экран объяснения/следующий шаг.
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/explanation.tscn")

func _start_city_loop() -> void:
	city_overlay.modulate = Color(1, 0.86, 0.86, 0.82) # хаос
	var t1 = create_tween()
	t1.set_loops()
	t1.tween_property(car1, "position:x", 1220.0, 1.5).from(-140.0)
	t1.tween_interval(0.15)
	var t2 = create_tween()
	t2.set_loops()
	t2.tween_property(car2, "position:x", -200.0, 1.55).from(1220.0)
	t2.tween_interval(0.15)

func _apply_city_state(is_good_choice: bool) -> void:
	if is_good_choice:
		city_overlay.modulate = Color(0.8, 1.0, 0.86, 0.75)
	else:
		city_overlay.modulate = Color(1.0, 0.74, 0.74, 0.8)

func _show_choice_result(is_good_choice: bool) -> void:
	# Камера/город "приближается" и меняется по выбору.
	var z = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	z.tween_property(city_overlay, "scale", Vector2(1.08, 1.08), 0.45)
	await z.finished
	_apply_city_state(is_good_choice)
	await get_tree().create_timer(0.5).timeout

func _split_for_dialog(full_text: String) -> PackedStringArray:
	var out := PackedStringArray()
	if full_text.find("\n\n") != -1:
		for p in full_text.split("\n\n", false):
			out.append(p.strip_edges())
	else:
		var sentences = full_text.split(". ", false)
		var chunk = ""
		for s in sentences:
			if chunk.length() == 0:
				chunk = s
			else:
				chunk += ". " + s
			if chunk.length() > 120:
				out.append(chunk)
				chunk = ""
		if chunk.length() > 0:
			out.append(chunk)
	if out.size() == 0:
		out.append(full_text)
	return out

func _speak_chunks(chunks: PackedStringArray) -> void:
	for c in chunks:
		if c.is_empty():
			continue
		_start_talking()
		await reveal_text(speaker_text, c, GameManager.text_cps, true)
		_stop_talking()
		await _wait_tap()

func _start_talking() -> void:
	var loop_tween = create_tween()
	loop_tween.set_loops()
	loop_tween.tween_callback(Callable(self, "_mouth_open_state"))
	loop_tween.tween_interval(0.12)
	loop_tween.tween_callback(Callable(self, "_mouth_closed_state"))
	loop_tween.tween_interval(0.12)
	speaker_panel.set_meta("talk_tween", loop_tween)

func _stop_talking() -> void:
	if speaker_panel.has_meta("talk_tween"):
		var t = speaker_panel.get_meta("talk_tween")
		if t:
			t.kill()
	speaker_panel.remove_meta("talk_tween")
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
