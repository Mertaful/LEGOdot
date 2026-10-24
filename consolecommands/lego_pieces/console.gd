extends Node

#@export_category("Console")
@export_group("Panel")
@export var slide_duration := 0.05
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export_range(10.0, 100.0, 1.0, "How many percent of the screen the console panel fills when opened.") var panel_percent := 80.0
@export_group("Output")
@export var output_max_lines := 100

@onready var console_panel_spacer: Control = %ConsolePanelSpacer
@onready var console_panel: PanelContainer = %ConsolePanel
@onready var output_container: VBoxContainer = %OutputContainer
@onready var text_field: LineEdit = %TextField

var _commands : Dictionary[String, Callable]
var _output : Array[String]

var _panel_tween : Tween = null
var _shown := false


func print_to_console(string_to_print : String, output_prefix : String = "") -> void:
	_output.append(string_to_print)
	if _output.size() > output_max_lines:
		_output.pop_front()
	_build_output()
	print_rich(output_prefix + string_to_print)


## Supply callable that takes a string, and handle the string parsing yourself
func add_custom_command(command_name : String, command_callback : Callable) -> void:
	if _commands.has(command_name):
		push_error("Tried adding \"%s\" command when already added to commands." % command_name)
		return
	
	_commands[command_name] = command_callback


## Supply callable that takes a flag to assign to your parameter
func add_bool_command(command_name : String, command_callback : Callable) -> void:
	var bool_callback = func(arg : String):
		var low_arg = arg.to_lower()
		if low_arg == "true" || low_arg == "1":
			command_callback.call(true)
		elif low_arg == "false" || low_arg == "0":
			command_callback.call(false)
		else :
			print_to_console("[color=#CC0000]Invalid argument[/color] - \"%s\" did not recognize the argument \"%s\"." % [command_name, arg], "Console error: ")
	
	add_custom_command(command_name, bool_callback)


## Supply callable that takes a float to assign to your parameter
func add_float_command(command_name : String, command_callback : Callable) -> void:
	var float_callback = func(arg : String):
		arg.strip_edges()
		if arg.is_valid_float() || arg.is_valid_int():
			command_callback.call(arg.to_float())
		else :
			print_to_console("[color=#CC0000]Invalid argument[/color] - \"%s\" did not recognize the argument \"%s\"." % [command_name, arg], "Console error: ")
	
	add_custom_command(command_name, float_callback)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_console"):
		if _shown:
			_hide()
		else:
			_show()


func _ready() -> void:
	ready.connect(_on_ready)


func _on_ready() -> void:
	_set_spacer_size()
	get_window().size_changed.connect(_set_spacer_size)
	console_panel.offset_transform_position.y = -get_window().size.y * panel_percent * 0.01
	console_panel.visible = false
	text_field.editable = false


func _show() -> void:
	console_panel.visible = true
	if _panel_tween:
		_panel_tween.kill()
	_panel_tween = create_tween()
	
	_panel_tween.tween_property(console_panel, "offset_transform_position", Vector2(0.0, 0.0), slide_duration).set_trans(transition_type)
	_panel_tween.set_ease(Tween.EASE_IN_OUT)
	_panel_tween.tween_callback(func(): text_field.editable = true)
	
	_shown = true
	text_field.grab_focus()


func _hide() -> void:
	text_field.editable = false
	if _panel_tween:
		_panel_tween.kill()
	_panel_tween = create_tween()
	
	_panel_tween.tween_property(console_panel, "offset_transform_position", Vector2(0.0, -console_panel.size.y), slide_duration).set_trans(transition_type)
	_panel_tween.set_ease(Tween.EASE_IN_OUT)
	_panel_tween.tween_callback(func(): console_panel.visible = false)
	
	_shown = false
	text_field.release_focus()


func _set_spacer_size() -> void:
	console_panel_spacer.custom_minimum_size.y = get_window().size.y * (1.0 - (panel_percent * 0.01))


func _build_output() -> void:
	for i in range(_output.size()):
		if i == output_container.get_child_count():
			var new_label := RichTextLabel.new()
			new_label.text = _output[i]
			new_label.theme = output_container.theme
			new_label.fit_content = true
			new_label.bbcode_enabled = true
			output_container.add_child(new_label)
		else:
			var child : RichTextLabel = output_container.get_child(i)
			child.text = _output[i]


func _on_console_panel_resized() -> void:
	if console_panel && !console_panel.visible:
		console_panel.offset_transform_position.y = -console_panel.size.y


func _on_text_field_text_submitted(new_text: String) -> void:
	if !new_text.is_empty():
		print_to_console(new_text, "Console command: ")
		
		var text_values = new_text.split(" ", false, 1)
		var command_callback = _commands.get(text_values[0])
		if command_callback == null:
			print_to_console("[color=#CC0000]Invalid command.[/color] - \"%s\" was not found." % new_text, "Console error: ")
		else:
			var arg := ""
			if text_values.size() > 1:
				arg = text_values[1]
			command_callback.call(arg)
		
		text_field.text = ""
