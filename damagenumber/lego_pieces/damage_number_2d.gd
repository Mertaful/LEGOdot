class_name DamageNumber2D
extends RichTextLabel

@export var properties : DamageNumber2DResource
## Type correlates to index of colors array in DamageNumberResourceBase
@export var type := 0

var _lifetime := 0.0
var _fade_tween : Tween
var _scale_tween : Tween
var _velocity : Vector2
var _acceleration : Vector2

func _init(new_position : Vector2, new_properties : DamageNumber2DResource, value : int,  new_type : int = 0):
	text = "%d" % value
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scroll_active = false
	fit_content = true
	autowrap_mode = TextServer.AUTOWRAP_OFF
	properties = new_properties
	
	if new_type > 0 && new_type < properties.colors.size():
		type = new_type
	elif new_type >= properties.colors.size():
		push_error("Invalid type pused to DamageNumber2D. Type was %d" % new_type)
		
	global_position = new_position

func _ready() -> void:
	bbcode_enabled = properties.enable_bbcode
	add_theme_font_override("normal_font", properties.font)
	add_theme_font_size_override("normal_font_size", properties.font_size)
	add_theme_color_override("default_color", properties.colors[type])
	_velocity = Vector2(randf_range(properties.min_velocity.x, properties.max_velocity.x), randf_range(properties.min_velocity.y, properties.max_velocity.y))
	_acceleration = Vector2(randf_range(properties.min_acceleration.x, properties.max_acceleration.x), randf_range(properties.min_acceleration.y, properties.max_acceleration.y))
	
	var x_offset := randf_range(-properties.spawn_radius, properties.spawn_radius)
	var y_offset := randf_range(-properties.spawn_radius, properties.spawn_radius) #this is mathematically incorrect and will cause spawn in a square but.... fuckit?
	global_position = Vector2(global_position.x + x_offset - (size.x * 0.5), global_position.y + y_offset - (size.y * 0.5))
	
	
	if properties.fade_enabled:
		assert(_fade_tween == null)
		_fade_tween = create_tween()
		_fade_tween.set_ease(properties.fade_ease)
		_fade_tween.tween_property(self, "theme_override_colors/default_color", Color(properties.colors[type], 0.0), properties.lifetime).set_trans(properties.fade_transition)
	
	if properties.value_scaling_enabled:
		var scale_difference := properties.value_scaling_highest_scale - properties.value_scaling_lowest_scale
		var value_difference := properties.value_scaling_high_value - properties.value_scaling_low_value
		var text_value := text.to_int()
		var value_ratio := maxf(float(text_value - properties.value_scaling_low_value) / value_difference, 0.0)
		var value_based_scale := minf(properties.value_scaling_highest_scale, maxf(properties.value_scaling_lowest_scale, (properties.value_scaling_lowest_scale + value_ratio * scale_difference)))
		
		print("Value ratio was %d for value %d. Value based scale was %d" % [value_ratio, text_value, value_based_scale])
		
		assert(_scale_tween == null)
		_scale_tween = create_tween()
		_scale_tween.set_ease(properties.value_scaling_ease)
		_scale_tween.tween_property(self, "scale", Vector2(value_based_scale + value_ratio, value_based_scale + value_ratio), properties.value_scaling_speed * 0.5).set_trans(properties.value_scaling_transition)
		_scale_tween.tween_property(self, "scale", Vector2(value_based_scale, value_based_scale), properties.value_scaling_speed * 0.5).set_trans(properties.value_scaling_transition)

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime > properties.lifetime:
		queue_free()
		return
	
	if properties.gravity:
		_velocity.y += 9.8 * delta
	_velocity += _acceleration * delta
	global_position += _velocity
	
