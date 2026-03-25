# welcome.gd
extends Control

func _ready():
	# Полное приветствие из твоего документа
	$Speaker/Text.text = """Добро пожаловать в D-Bus City!
В мире Android вы привыкли общаться между компонентами через Intents и Binder. 
Но в Linux-системах роль главного связного играет D-Bus. 

Это наша центральная логистическая система. 
Здесь приложения – это Фабрики, а данные — грузовики с посылками. 

Ваша задача – навести порядок в городе и понять, как работает эта магистраль."""
	
	# Можно сделать весь экран тапаемым (по желанию)
	# $ColorRect.gui_input.connect(_on_screen_tapped)

func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")
