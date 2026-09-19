class_name PlainMainMenu
extends Control

@export var _game_scene : PackedScene = null
@export var _settings_scene : PackedScene = null
@export var _credits_scene : PackedScene = null

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	if _game_scene and _game_scene.can_instantiate():
		var start_game_lambda = func():
			queue_free()
			get_tree().change_scene_to_packed(_game_scene)
		start_button.pressed.connect(start_game_lambda)
	
	if _settings_scene and _settings_scene.can_instantiate():
		settings_button.pressed.connect(func() : add_child(_settings_scene.instantiate()))
	
	if _credits_scene and _credits_scene.can_instantiate():
		credits_button.pressed.connect(func() : add_child(_credits_scene.instantiate()))
	
	exit_button.pressed.connect(func() : get_tree().quit())
