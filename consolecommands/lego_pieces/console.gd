extends Node

#region Exports
@export_group("Panel")
@export var slide_duration := 0.05
@export var transition_type : Tween.TransitionType = Tween.TransitionType.TRANS_SINE
@export_range(10.0, 100.0, 1.0, "How many percent of the screen the console panel fills when opened.") var panel_percent := 80.0
@export_group("Output")
@export var output_max_lines := 100
@export_group("Suggestions")
@export var enable_suggestions := true
@export var max_suggestions := 3
#endregion

#region OnReadys
@onready var console_panel_spacer: Control = %ConsolePanelSpacer
@onready var console_panel: PanelContainer = %ConsolePanel
@onready var output_container: VBoxContainer = %OutputContainer

@onready var text_field: LineEdit = %TextField

@onready var suggestions_root: Control = %SuggestionsRoot
@onready var suggestions_container: VBoxContainer = %SuggestionsContainer
#endregion

#region Private Variables
var _commands : Dictionary[String, CommandSignal]
var _output : Array[String]

var _history : Array[String]
var _history_index := 0
var _is_scrolling_history := false

var _is_scrolling_suggestions := false
var _focused_suggestion_text := ""

var _panel_tween : Tween = null
var _shown := false
#endregion


#region Private Classes
class CommandSignal:
	func emit(arg : String) -> void:
		for callback in callbacks:
			callback.call(arg)
	
	func add_callable(new_callable : Callable) -> void:
		callbacks.append(new_callable)
		
	var callbacks : Array[Callable]

#endregion

#region Public functions
func print_to_console(string_to_print : String, output_prefix : String = "") -> void:
	_output.append(string_to_print)
	if _output.size() > output_max_lines:
		_output.pop_front()
	_build_output()
	print_rich(output_prefix + string_to_print)


## Supply callable that takes a string, and handle the string parsing yourself
func add_custom_command(command_name : String, command_callback : Callable) -> void:
	if !_commands.has(command_name):
		_commands[command_name] = CommandSignal.new()
	
	_commands[command_name].add_callable(command_callback)


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
#endregion


#region Private Functions
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_console"):
		if _shown:
			_hide()
		else:
			_show()
	
	if event.is_action_pressed("ui_up"):
		if text_field.text.is_empty() || _is_scrolling_history:
			_is_scrolling_history = true
			_next_history_command()
		elif suggestions_container.get_child_count() > 0 and !_is_scrolling_suggestions:
			_is_scrolling_suggestions = true
			var suggestion : Label = suggestions_container.get_child(-1)
			suggestion.grab_focus()
			get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_down"):
		if _is_scrolling_history:
			_previous_history_command()
		elif _is_scrolling_suggestions:
			var suggestion : Label = suggestions_container.get_child(-1)
			if suggestion.has_focus():
				_is_scrolling_suggestions = false
				text_field.grab_focus()
				text_field.edit()
				get_viewport().set_input_as_handled()


func _ready() -> void:
	ready.connect(_on_ready)
	
	var font := suggestions_container.theme.get_font("font", "Label")
	var font_size := suggestions_container.get_theme_font_size("font_size", "Label")
	
	var font_height := font.get_string_size("ql", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).y
	var separator_height := suggestions_container.theme.get_constant("separation", "VBoxContainer")
	
	suggestions_root.custom_maximum_size.y = font_height * max_suggestions + separator_height * (max_suggestions - 1)


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
		
		_add_history(new_text)
		var text_values := new_text.split(" ", false, 1)
		
		if !_commands.has(text_values[0]):
			print_to_console("[color=#CC0000]Invalid command.[/color] - \"%s\" was not found." % new_text, "Console error: ")
		else:
			var arg := ""
			if text_values.size() > 1:
				arg = text_values[1]
			_commands.get(text_values[0]).emit(arg)
		
		text_field.text = ""
		_update_suggestions(text_field.text)


func _on_text_field_text_changed(new_text: String) -> void:
	_is_scrolling_history = false
	_update_suggestions(new_text)


func _update_suggestions(text : String) -> void:
	if !enable_suggestions:
		return
	
	for child in suggestions_container.get_children():
		child.queue_free()
	
	var matches : Array[String]
	
	if !text.is_empty():
		for key : String in _commands.keys():
			if key.contains(text):
				matches.append(key)
			
		var weak_matches : Array[String]
		var weak_querries := text.split(" ", false)
		for key : String in _commands.keys():
			var was_match := true
			for word : String in weak_querries:
				if !key.contains(word):
					was_match = false
					break
			
			if was_match:
				weak_matches.append(key)
		
		for command in weak_matches:
			if !matches.has(command):
				matches.append(command)
	
	var font := suggestions_container.theme.get_font("font", "Label")
	var font_size := suggestions_container.get_theme_font_size("font_size", "Label")
	
	var textfield_font := text_field.theme.get_font("font", "LineEdit")
	var textfield_font_size := text_field.get_theme_font_size("font_size", "LineEdit")
	
	var width := 0.0
	for suggestion in matches:
		var suggestion_label = Label.new()
		suggestion_label.text = suggestion
		suggestion_label.name = suggestion #remove me
		suggestion_label.theme = suggestions_container.theme
		suggestion_label.focus_mode = Control.FOCUS_ALL
		suggestion_label.gui_input.connect(_on_suggestion_gui_input)
		suggestion_label.focus_entered.connect(_on_suggestion_focused.bind(suggestion))
		width = maxf(width, font.get_string_size(suggestion, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		suggestions_container.add_child(suggestion_label)
	
	var font_height := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).y
	var separator_height := suggestions_container.theme.get_constant("separation", "VBoxContainer")
	var height := (font_height * matches.size()) + separator_height * (matches.size() - 1)
	
	suggestions_root.size = Vector2(width, height)
	suggestions_root.position = Vector2(text_field.position.x + textfield_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, textfield_font_size).x, text_field.position.y - height)


func _on_suggestion_gui_input(event : InputEvent)-> void:
	if event.is_action_pressed("ui_accept"):
		text_field.text = _focused_suggestion_text + " "
		text_field.grab_focus()
		text_field.caret_column = text_field.text.length()
		_update_suggestions("")


func _on_suggestion_focused(suggestion : String) -> void:
	_focused_suggestion_text = suggestion


func _next_history_command() -> void:
	if _history.is_empty():
		return
	
	_history_index = maxi(0, _history_index - 1)
	text_field.text = _history[_history_index]
	text_field.caret_column = text_field.text.length()


func _previous_history_command() -> void:
	if _history.is_empty() || _history_index >= _history.size():
		return
	
	_history_index = mini(_history.size() - 1, _history_index + 1)
	text_field.text = _history[_history_index]
	text_field.caret_column = text_field.text.length()


func _add_history(command : String) -> void:
	_history.append(command)
	if _history.size() > float(output_max_lines) / 2.0:
		_history.pop_front()
	
	_history_index = _history.size()
#endregion
