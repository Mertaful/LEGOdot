@abstract
class_name UserSetting
extends HBoxContainer

const MINIMUM_RIGHTY_SIZE := 50.0
const SLIDER_SIZE := 100.0

var setting_name : String

var _display_name : String
var _setting_label : Label = null

@abstract func _init_controller(value : Variant, min : float, max : float) -> void

func _init(display_name : String, parent_theme : Theme, value : Variant, min : float = -1.0, max : float = -1.0) -> void:
	assert(parent_theme, "Make sure you have set the theme in the parent. This is crucial and there are definitely better ways to do this.")
	_setting_label = Label.new()
	
	theme = parent_theme
	_display_name = display_name
	setting_name = display_name.to_snake_case()
	
	_setting_label.theme = theme
	_setting_label.text = display_name
	
	var spacer := HSeparator.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	add_child(_setting_label)
	add_child(spacer)
	
	_init_controller(value, min, max)

#Bools
class BoolSetting extends UserSetting:
	func _init_controller(value : Variant, _min : float, _max : float) -> void:
		var setting_controller := CheckButton.new()
		setting_controller.theme = theme
		setting_controller.set_pressed_no_signal(value)
		setting_controller.custom_minimum_size.x = MINIMUM_RIGHTY_SIZE
		add_child(setting_controller)

#Percent
class PercentSetting extends UserSetting:
	var slider_label : Label = null
	func _init_controller(value : Variant, _min : float, _max : float) -> void:
		var setting_controller := HSlider.new()
		setting_controller.theme = theme
		setting_controller.value = value
		setting_controller.custom_minimum_size.x = SLIDER_SIZE
		setting_controller.min_value = 0.0
		setting_controller.max_value = 100.0
		setting_controller.rounded = true
		
		slider_label = Label.new()
		slider_label.theme = theme
		slider_label.custom_minimum_size.x = MINIMUM_RIGHTY_SIZE
		
		setting_controller.value_changed.connect(_set_label_value)
		
		add_child(setting_controller)
		add_child(slider_label)
	
	func _set_label_value(new_value : float) -> void:
		slider_label.text = "%d" % int(new_value)

#Float slider
class FloatSetting extends UserSetting:
	var slider_label : Label = null
	func _init_controller(value : Variant, min : float, max : float) -> void:
		var setting_controller := HSlider.new()
		setting_controller.theme = theme
		setting_controller.value = value
		setting_controller.custom_minimum_size.x = SLIDER_SIZE
		setting_controller.min_value = min
		setting_controller.max_value = max
		setting_controller.step = 0.1
		setting_controller.rounded = false
		
		slider_label = Label.new()
		slider_label.theme = theme
		slider_label.custom_minimum_size.x = MINIMUM_RIGHTY_SIZE
		
		setting_controller.value_changed.connect(_set_label_value)
		
		add_child(setting_controller)
		add_child(slider_label)
	
	func _set_label_value(new_value : float) -> void:
		slider_label.text = "%.1f" % new_value
