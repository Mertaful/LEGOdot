## No class_name, just register this in globals
extends Node

var window_resolution : Vector2i
var window_fullscreen : bool
var input_map_overrides : Dictionary[String, Array]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_action"):
		print("Debug action was just pressed.")


func _ready() -> void:
	window_resolution = get_window().size
	window_fullscreen = get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN || Window.MODE_FULLSCREEN
	save_settings()


## Returns true if it successfully added the override to the action
func override_input_action(action_name : String, new_event : InputEvent) -> bool:
	var added_override := false
	
	if new_event is InputEventKey:
		var key_event : InputEventKey = new_event
		input_map_overrides[action_name] = [InputEvent.DEVICE_ID_KEYBOARD, key_event.keycode]
		added_override = true
	elif new_event is InputEventMouseButton:
		var mouse_event : InputEventMouseButton = new_event
		input_map_overrides[action_name] = [InputEvent.DEVICE_ID_MOUSE, mouse_event.button_index]
		added_override = true
	
	if added_override:
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, new_event)
	return added_override

func _build_save_dictionary() -> Dictionary:
	return {
		"resolution" : window_resolution,
		"fullscreen" : window_fullscreen,
		"input_overrides" : input_map_overrides
	}

func save_settings() -> void:
	var save_file = FileAccess.open("user://user.settings", FileAccess.WRITE)
	var json_string = JSON.stringify(_build_save_dictionary())
	save_file.store_line(json_string)

func load_settings() -> void:
	var json = JSON.new()
	#json.parse()
