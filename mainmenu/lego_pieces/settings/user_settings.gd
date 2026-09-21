## No class_name, just register this in globals
extends Node

enum SettingTypes {INVALID, FLAG, PERCENT, FLOAT, ENUM, KEYBIND}

const USER_SETTINGS_VERSION := 1
var user_settings : Array[SettingSection]

var input_map_overrides : Dictionary[String, Array]


func _init() -> void:
	_build_settings_array()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_action"):
		print("Debug action was just pressed.")

func _ready() -> void:
	if !load_settings():
		save_settings()

## Returns true if it successfully added the override to the action
func override_input_action(action_name : String, new_event : InputEvent) -> bool:
	var added_override := false
	
	if new_event is InputEventKey:
		var key_event : InputEventKey = new_event
		input_map_overrides[action_name] = [InputEvent.DEVICE_ID_KEYBOARD, key_event.keycode]
		added_override = true
		get_setting(action_name).value = key_event.keycode
	elif new_event is InputEventMouseButton:
		var mouse_event : InputEventMouseButton = new_event
		input_map_overrides[action_name] = [InputEvent.DEVICE_ID_MOUSE, mouse_event.button_index]
		added_override = true
		get_setting(action_name).value = mouse_event.keycode
	
	if added_override:
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, new_event)
	return added_override

func _build_settings_array() -> void:
	#Gameplay
	var gameplay_section = SettingSection.new("Gameplay")
	
	gameplay_section.add_entry(SettingEntry.new("Be gay, do crime", SettingTypes.FLAG, true))
	
	#Control
	var control_section = SettingSection.new("Control")
	
	control_section.add_entry(SettingEntry.new("Mouse Sensitivity", SettingTypes.FLOAT, 3.0, 0.1, 20.0))
	
	var debug_bind := SettingEntry.new("Debug Action", SettingTypes.KEYBIND)
	debug_bind.callable = func(action_name : String, new_event : InputEvent):
		UserSettings.override_input_action(action_name, new_event)
	control_section.add_entry(debug_bind)
	
	#Control
	var video_section = SettingSection.new("Video")
	
	#Audio
	var audio_section = SettingSection.new("Audio")
	
	#Language
	var language_section = SettingSection.new("Language")
	
	
	var new_section_array : Array[SettingSection]
	new_section_array.append(gameplay_section)
	new_section_array.append(control_section)
	new_section_array.append(video_section)
	new_section_array.append(audio_section)
	new_section_array.append(language_section)

func get_settings_sections() -> Array[SettingSection]:
	return user_settings

## Returns null if it can't find the setting
func get_setting(setting_name : String, setting_section : String = "") -> SettingEntry:
	var result : SettingEntry = null
	if !setting_section.is_empty():
		var section_index = user_settings.find_custom(func(section : SettingSection) : return section.name == setting_section )
		if section_index == -1:
			push_error("[UserSettings] Tried getting setting with nonexistent section defined. Section was: %s" % setting_section)
			return null
			
		result = user_settings[section_index].get_entry(setting_name)
	else:
		for section in user_settings:
			var entry = section.get_entry(setting_name)
			if entry != null:
				result = entry
				break
	if result == null:
		push_error("[UserSettings] Couldn't find setting with name: %s" % setting_name)
	return result

func get_setting_callables_for_section(section_name : String) -> Dictionary[String, Callable]:
	return {}

func save_settings() -> void:
	# Vincent is afraid of bytes
	_save_as_json()

func load_settings() -> bool:
	return _load_as_json()

func _save_as_json() -> void:
	var save_file := FileAccess.open("user://settings.json", FileAccess.WRITE)
	#var json_string := JSON.stringify(_build_save_dictionary())
	save_file.store_line("%d" % USER_SETTINGS_VERSION)
	#save_file.store_line(json_string)

func _load_as_json() -> bool:
	if not FileAccess.file_exists("user://settings.json"):
		return false
	
	var loaded_successfully := true
	var save_file = FileAccess.open("user://settings.json", FileAccess.READ)
	
	var settings_version = save_file.get_line().to_int()
	assert(settings_version is int)
	if settings_version == USER_SETTINGS_VERSION:
		var json = JSON.new()
		while save_file.get_position() < save_file.get_length():
			var json_string = save_file.get_line()			
			var result := json.parse(json_string)
			if result != OK:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				loaded_successfully = false
	else:
		loaded_successfully = false
	
	return loaded_successfully

class SettingSection:
	var name : String
	var entries : Array[SettingEntry]
	
	func _init(section_name : String) -> void:
		name = section_name
	
	func add_entry(new_entry : SettingEntry) -> void:
		var insertion_index = entries.find_custom(func(entry : SettingEntry) : entry.type > new_entry.type)
		if insertion_index == -1:
			entries.append(new_entry)
		else:
			entries.insert(insertion_index, new_entry)
	
	func get_entry(entry_name : String) -> SettingEntry:
		var entry_index := entries.find_custom(func(entry : SettingEntry) : return entry.name == entry_name)
		if entry_index != -1:
			return entries[entry_index]
		return null
	
	func serialize_binary(serializer : FileAccess) -> void:
		serializer.store_var(str_to_var(name))
		serializer.store_var(entries.size())
		
		for entry in entries:
			entry.serialize_binary(serializer)
	
	func deserialize_binary(serializer : FileAccess) -> bool:
		name = var_to_str(serializer.get_var())
		var n_entries = serializer.get_var()
		
		for i in range(n_entries):
			var new_entry := SettingEntry.new()
			if !new_entry.deserialize_binary(serializer):
				return false
			
		return true

class SettingEntry:
	var name : String
	var type : SettingTypes
	var value : Variant
	var min : float
	var max : float
	var callable : Callable
	
	func _init(setting_name : String = "", setting_type : SettingTypes = SettingTypes.INVALID, default_value : Variant = null, min_value : float = -1.0, max_value : float = -1.0) -> void:
		name = setting_name
		type = setting_type
		value = default_value
		min = min_value
		max = max_value
		callable = func(new_value) : value = new_value
	
	func serialize_binary(serializer : FileAccess) -> void:
		serializer.store_var(str_to_var(name))
		serializer.store_var(type)
		serializer.store_var(value)
	
	func deserialize_binary(serializer : FileAccess) -> bool:
		name = var_to_str(serializer.get_var())
		type = serializer.get_var()
		value = serializer.get_var()
		return validate()
	
	func validate() -> bool:
		match type:
			SettingTypes.PERCENT or SettingTypes.ENUM or SettingTypes.KEYBIND:
				return value is int
			SettingTypes.FLOAT:
				return value is float
			SettingTypes.FLAG:
				return value is bool
		return false
