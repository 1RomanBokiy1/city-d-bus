class_name BaseScreen
extends Control

var _can_typewriter_skip: bool = true

var _typewriter_active: bool = false
var _typewriter_label: RichTextLabel
var _typewriter_total_chars: int = 0
var _typewriter_tween: Tween

func _ready() -> void:
	var ui = get_node_or_null("/root/UIManager")
	if ui != null:
		ui.register_game_ui(self)

func _exit_tree() -> void:
	var ui = get_node_or_null("/root/UIManager")
	if ui != null:
		ui.unregister_game_ui(self)

func _unhandled_input(event: InputEvent) -> void:
	if not _typewriter_active:
		return
	if not _can_typewriter_skip:
		return

	if event is InputEventScreenTouch and event.pressed:
		_skip_typewriter()

func _skip_typewriter() -> void:
	if not _typewriter_active:
		return
	if _typewriter_label == null:
		return

	_typewriter_active = false
	_typewriter_label.visible_characters = _typewriter_total_chars

func reveal_text(
	label: RichTextLabel,
	full_text: String,
	cps: float = 35.0,
	disable_input_while_typing: bool = true
) -> void:
	if label == null:
		return
	if full_text.is_empty():
		label.text = ""
		return

	var previously_disabled: Array = []
	if disable_input_while_typing:
		_collect_and_disable_buttons(self, previously_disabled)

	_typewriter_active = true
	_typewriter_label = label

	# Reduced motion mode — instant show
	if GameManager.reduce_animations:
		label.bbcode_text = full_text
		label.visible_characters = label.get_total_character_count()
		_typewriter_active = false
		if disable_input_while_typing:
			_restore_buttons(previously_disabled)
		return

	# Normal typewriter effect
	label.bbcode_text = full_text
	label.visible_characters = 0
	_typewriter_total_chars = label.get_total_character_count()

	if _typewriter_total_chars <= 0:
		_typewriter_active = false
		if disable_input_while_typing:
			_restore_buttons(previously_disabled)
		label.text = full_text
		return

	# ← Вот исправление (явно указали тип float)
	var duration: float = max(0.2, float(_typewriter_total_chars) / max(1.0, cps))

	_typewriter_tween = create_tween()
	_typewriter_tween.set_trans(Tween.TRANS_SINE)
	_typewriter_tween.set_ease(Tween.EASE_OUT)
	_typewriter_tween.tween_property(label, "visible_characters", _typewriter_total_chars, duration)

	while _typewriter_active and label.visible_characters < _typewriter_total_chars:
		await get_tree().process_frame

	_typewriter_active = false
	label.visible_characters = _typewriter_total_chars

	if _typewriter_tween:
		_typewriter_tween.kill()
	_typewriter_tween = null

	if disable_input_while_typing:
		_restore_buttons(previously_disabled)

func _collect_and_disable_buttons(root: Node, previously_disabled: Array) -> void:
	for child in root.get_children():
		if child is BaseButton:
			previously_disabled.append([child, child.disabled])
			child.disabled = true
		if child.get_child_count() > 0:
			_collect_and_disable_buttons(child, previously_disabled)

func _restore_buttons(previously_disabled: Array) -> void:
	for pair: Array in previously_disabled:
		var btn: BaseButton = pair[0]
		var was_disabled: bool = pair[1]
		if is_instance_valid(btn) and btn is BaseButton:
			btn.disabled = was_disabled
