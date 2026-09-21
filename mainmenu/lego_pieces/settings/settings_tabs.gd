extends TabContainer

@export var user_settings_theme : Theme

func _ready() -> void:
	var debug_dic : Dictionary
	_create_tab("Gameplay", debug_dic)
	_create_tab("Control", debug_dic)
	_create_tab("Video", debug_dic)
	_create_tab("Audio", debug_dic)
	_create_tab("Language", debug_dic)


func _create_tab(tab_name : String, setting_values : Dictionary) -> void:
	var new_margins = MarginContainer.new()
	new_margins.theme = user_settings_theme
	new_margins.name = tab_name
	add_child(new_margins)
	
	var new_container = VBoxContainer.new()
	var separator_line = HSeparator.new()
	separator_line.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	new_container.add_child(separator_line)
	new_margins.add_child(new_container)
	_fill_tab(new_container, setting_values)

func _fill_tab(parent : VBoxContainer, setting_values : Dictionary) -> void:
	pass
