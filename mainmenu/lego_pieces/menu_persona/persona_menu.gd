class_name PersonaStyleMenu
extends Control

@export var _menu_resource : PersonaMenuResource

@onready var background: ColorRect = %Background
@onready var menu_name_label: RichTextLabel = %MenuNameLabel
@onready var buttons_container: VBoxContainer = %ButtonsContainer

var _rng : RandomNumberGenerator

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	for button : PersonaButton in buttons_container.get_children():
		_set_button_color(button)

func _set_button_color(button : PersonaButton) -> void:
	_rng.seed = hash(button.text) + 1
	var grey_amount := _rng.randf_range(_menu_resource.darkest_grey.r, _menu_resource.brightest_grey.r)
	var grey := Color(grey_amount, grey_amount, grey_amount)
	var offset_rotation := _rng.randf_range(-_menu_resource.max_rotation_offset, _menu_resource.max_rotation_offset)
	button.add_theme_color_override("font_color", grey)
	button.initialize_color(grey)
	button.offset_transform_enabled = true
	button.offset_transform_rotation = deg_to_rad(offset_rotation)
	button.add_theme_color_override("font_hover_color", _menu_resource.accent_color)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(preload("uid://cjv1o4kkfd50g"))
