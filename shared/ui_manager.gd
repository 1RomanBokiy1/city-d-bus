extends Node

# Lightweight UI registry + pause helper.
# Autoload-only: instance is available globally as `UIManager`.

var _registered: Array[Node] = []

func register_game_ui(ui: Node) -> void:
	if ui == null:
		return
	if _registered.has(ui):
		return
	_registered.append(ui)

func unregister_game_ui(ui: Node) -> void:
	if ui == null:
		return
	_registered.erase(ui)

func is_paused() -> bool:
	return get_tree().paused

func pause_game(pause: bool) -> void:
	get_tree().paused = pause

