extends BaseScreen
const PIXEL_UI = preload("res://shared/pixel_ui.gd")

@onready var header: Label = $Header
@onready var rich_text: RichTextLabel = $ScrollContainer/Panel/Text
@onready var back_button: Button = $BackButton

func _ready() -> void:
	# Сразу запрещаем кнопку “Назад”, пока идёт появление текста.
	back_button.disabled = true
	header.text = "Об игре"

	var txt := GameManager.about_text
	if txt.is_empty():
		txt = "D-Bus City — обучающий квест про централизованную шину сообщений."

	# Чуть медленнее на важном тексте.
	await reveal_text(rich_text, txt, GameManager.text_cps, true)
	PIXEL_UI.style_button(back_button, true, false)
	back_button.disabled = false

func _on_back_pressed() -> void:
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/menu.tscn")
