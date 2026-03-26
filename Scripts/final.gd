# final.gd
extends BaseScreen

@onready var text_node: Label = $Panel/Text
@onready var menu_button: Button = $Menu

func _ready() -> void:
	menu_button.disabled = true

	var final_text := ""
	# Переносим логику по смыслу из doc: “точность” в диапазоне.
	if GameManager.score >= 5:
		final_text = "ГОРОД СТАБИЛЕН!\n\nФабрики регистрируются корректно, сообщения маршрутизируются через центр, сигналы доходят до подписчиков, а системные службы защищены политиками доступа.\nТеперь ты понимаешь, что D-Bus — это не просто шина сообщений, а полноценная архитектура IPC в Linux."
	elif GameManager.score >= 3:
		final_text = "Хорошее понимание архитектуры.\n\nГород стабилен, но некоторые решения были не оптимальны.\nТы понимаешь базовые принципы централизованной шины: \nзачем нужен единый узел; \nчем отличается личный вызов от сигнала.\nНо стоит глубже разобраться в вопросах именования сервисов и политиках доступа.\nВ реальной системе именно эти детали чаще всего становятся источником ошибок."
	else:
		final_text = "Город ещё нестабилен. Стоит разобраться получше.\n\nВ городе возникают конфликты маршрутизации и проблемы с доступом.\nПохоже, ты пока смотришь на D-Bus как на ещё один способ отправить сообщение.\nПопробуй пройти уровни ещё раз и обрати внимание:\nпочему прямые соединения не масштабируются;\nзачем нужны уникальные имена;\nпочему Signal не возвращает ответ;\nи почему System Bus защищён политиками доступа."

	# Анимация панели.
	$Panel.modulate.a = 0.0
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property($Panel, "scale", Vector2(1.02, 1.02), 0.18).from(Vector2(0.98, 0.98))
	tween.tween_property($Panel, "modulate:a", 1.0, 0.22)

	# Упрощённая “печать” для Label (без RichTextLabel).
	if GameManager.reduce_animations:
		text_node.text = final_text
		menu_button.disabled = false
		return

	text_node.text = ""
	var full_len := final_text.length()
	var cps := max(10.0, GameManager.text_cps)
	var shown := 0
	var elapsed := 0.0

	while shown < full_len:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
		var target := min(full_len, int(elapsed * cps))
		if target > shown:
			shown = target
			text_node.text = final_text.substr(0, shown)

	text_node.text = final_text
	menu_button.disabled = false

func _on_menu_pressed() -> void:
	menu_button.disabled = true
	var stm = get_node_or_null("/root/SceneTransitionManager")
	if stm != null:
		await stm.change_scene_to_file("res://Scenes/menu.tscn")
