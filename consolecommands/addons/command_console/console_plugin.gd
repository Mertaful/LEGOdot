@tool
extends EditorPlugin

const ACTION_NAME := "toggle_console"

func _enable_plugin() -> void:
	add_autoload_singleton("Console", "console.tscn")
	var key_event := InputEventKey.new()
	key_event.physical_keycode = Key.KEY_QUOTELEFT
	ProjectSettings.set("input/" + ACTION_NAME, {deadzone = 0.5, events = [key_event]})
	ProjectSettings.save()
	
func _disable_plugin() -> void:
	ProjectSettings.set("input/" + ACTION_NAME, null)
	ProjectSettings.save()
	remove_autoload_singleton("Console")

func _enter_tree() -> void:
	
	print("--- Command console plugin v.%s ---" % get_plugin_version())
