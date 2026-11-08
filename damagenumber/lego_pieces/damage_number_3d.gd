class_name DamageNumber3D
extends Label3D

@export var properties : DamageNumberResource
## Type correlates to index of types array in DamageNumberResourceBase
@export var type := 0

var _lifetime := 0.0
var _fade_tween : Tween
var _scale_tween : Tween
var _velocity : Vector3
var _acceleration : Vector3
var _spawn_position : Vector3 # 3D nodes like to be in the tree before setting the global position

func _init(new_position : Vector3, new_properties : DamageNumberResource, value : int,  new_type : int = -1):
	#fixed_size = true
	text = "%d" % value
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	autowrap_mode = TextServer.AUTOWRAP_OFF
	sorting_offset = -10
	if new_properties.colors.size() == 0 || new_properties.font_sizes.size() == 0:
		push_error("DamageNumberResource pushed in %s is missing items in at least one of its mandatory arrays which is not valid! Creating default to not crash.\n%s" % [self, get_stack()])
		new_properties = DamageNumberResource.new()
	properties = new_properties
	
	if _check_if_type_is_valid(new_type, properties):
		if new_type > 0:
			type = new_type
	else:
		push_error("Invalid type pushed to %s. Type was %d" % [self, new_type])
		
	_spawn_position = new_position

func _check_if_type_is_valid(type_to_check : int, resource : DamageNumberResource) -> bool:
	var max_type = max(resource.colors.size(), resource.font_sizes.size(), resource.outline_colors.size())
	return type_to_check < max_type

func _get_color() -> Color:
	if properties.colors.size() > type:
		return properties.colors[type]
	return properties.colors[0]
	
func _get_outline_color() -> Color:
	if properties.outline_colors.size() > type:
		return properties.outline_colors[type]
	return properties.outline_colors[0]
	
func _get_font_size() -> int:
	if properties.font_sizes.size() > type:
		return properties.font_sizes[type]
	return properties.font_sizes[0]

func _ready() -> void:
	global_position = _spawn_position
	font = properties.font
	font_size = _get_font_size()
	modulate = _get_color()
	if properties.outline_thickness > 0:
		outline_modulate = _get_outline_color()
		outline_size = properties.outline_thickness
	
	_velocity = Vector3(randf_range(properties.min_velocity.x, properties.max_velocity.x), randf_range(-properties.min_velocity.y, -properties.max_velocity.y), 0.0)
	_acceleration = Vector3(randf_range(properties.min_acceleration.x, properties.max_acceleration.x), randf_range(-properties.min_acceleration.y, -properties.max_acceleration.y), 0.0)
	
	var x_offset := randf_range(-properties.spawn_radius, properties.spawn_radius)
	var y_offset := randf_range(-properties.spawn_radius, properties.spawn_radius) #this is mathematically incorrect and will cause spawn in a square but.... fuckit?
	global_position = Vector3(global_position.x + x_offset, global_position.y + y_offset, global_position.z)
	
	
	if properties.fade_enabled:
		assert(_fade_tween == null)
		_fade_tween = create_tween()
		_fade_tween.set_ease(properties.fade_ease)
		_fade_tween.set_parallel(true)
		_fade_tween.tween_property(self, "modulate", Color(_get_color(), 0.0), properties.lifetime).set_trans(properties.fade_transition)
		_fade_tween.tween_property(self, "outline_modulate", Color(_get_outline_color(), 0.0), properties.lifetime).set_trans(properties.fade_transition)
	
	if properties.value_scaling_enabled:
		var scale_difference := properties.value_scaling_highest_scale - properties.value_scaling_lowest_scale
		var value_difference := properties.value_scaling_high_value - properties.value_scaling_low_value
		var text_value := text.to_int()
		var value_ratio := maxf(float(text_value - properties.value_scaling_low_value) / value_difference, 0.0)
		var value_based_scale := minf(properties.value_scaling_highest_scale, maxf(properties.value_scaling_lowest_scale, (properties.value_scaling_lowest_scale + value_ratio * scale_difference)))
		
		print("Value ratio was %f for value %d. Value based scale was %f" % [value_ratio, text_value, value_based_scale])
		
		assert(_scale_tween == null)
		_scale_tween = create_tween()
		_scale_tween.set_ease(properties.value_scaling_ease)
		_scale_tween.tween_property(self, "scale", Vector3(value_based_scale + value_ratio, value_based_scale + value_ratio, value_based_scale + value_ratio), properties.value_scaling_speed * 0.5).set_trans(properties.value_scaling_transition)
		_scale_tween.tween_property(self, "scale", Vector3(value_based_scale, value_based_scale, value_based_scale), properties.value_scaling_speed * 0.5).set_trans(properties.value_scaling_transition)

func _process(delta: float) -> void:
	_lifetime += delta
	if _lifetime > properties.lifetime:
		queue_free()
		return
	
	if properties.gravity:
		_velocity.y += (-9.8 * delta)
	_velocity += _acceleration * delta
	global_position += _velocity * delta
	#print(_velocity)
	
