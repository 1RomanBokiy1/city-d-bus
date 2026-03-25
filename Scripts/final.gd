# final.gd
extends Control

func _ready():
	var text_node = $Panel/Text   # ← поменяй путь, если у тебя другой
	var final_text = ""
	
	if GameManager.score == 6:
		final_text = "ГОРОД СТАБИЛЕН! Ты архитектор межпроцессного взаимодействия\n\nТеперь ты понимаешь, что D-Bus — это не просто шина сообщений, а полноценная архитектура IPC в Linux."
	elif GameManager.score >= 4:
		final_text = "Хорошее понимание архитектуры\n\nГород стабилен, но некоторые решения были не оптимальны.\nСтоит глубже разобраться в именовании сервисов и политиках доступа."
	else:
		final_text = "Город ещё нестабилен. Стоит разобраться получше.\n\nПопробуй пройти уровни ещё раз и обрати внимание:\n• почему прямые соединения не масштабируются;\n• зачем нужны уникальные имена;\n• почему Signal не возвращает ответ;\n• и почему System Bus защищён."
	
	text_node.text = final_text

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
