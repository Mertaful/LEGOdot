extends TabContainer

@export var user_settings_theme : Theme

func _ready() -> void:
	for section : UserSettings.SettingSection in UserSettings.get_settings_sections():
		_create_tab(section)


func _create_tab(section : UserSettings.SettingSection) -> void:
	var new_margins = MarginContainer.new()
	new_margins.theme = user_settings_theme
	new_margins.name = section.name
	add_child(new_margins)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.theme = user_settings_theme
	#scroll_container.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	new_margins.add_child(scroll_container)
	
	var new_container = VBoxContainer.new()
	new_container.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	var separator_line = HSeparator.new()
	separator_line.size_flags_horizontal = Container.SIZE_EXPAND_FILL
	
	scroll_container.add_child(new_container)
	new_container.add_child(separator_line)
	_fill_tab(new_container, section.entries)

func _fill_tab(parent : VBoxContainer, entries : Array[UserSettings.SettingEntry]) -> void:
	for setting in entries:
		var setting_visuals
		match setting.type:
			UserSettings.SettingTypes.FLAG:
				setting_visuals = SettingVisuals.BoolSetting.new(setting.name, user_settings_theme, setting.callable, setting.value)
			UserSettings.SettingTypes.PERCENT:
				setting_visuals = SettingVisuals.PercentSetting.new(setting.name, user_settings_theme, setting.callable, setting.value)
			UserSettings.SettingTypes.FLOAT:
				setting_visuals = SettingVisuals.FloatSetting.new(setting.name, user_settings_theme, setting.callable, setting.value, setting.min_value, setting.max_value)
		if setting_visuals:
			parent.add_child(setting_visuals)
	
	
	
	
