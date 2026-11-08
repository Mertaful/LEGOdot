class_name DamageNumberResource
extends Resource

@export_group("Number behavior")
## The damage number will fall towards the ground once emitted
@export var gravity := false
## All vectors will be turned into Vector3s in 3D, Z being zeroed. Y is inverted in 3D to mimic it being screenspace
@export var min_velocity := Vector2(0.0, -1.0)
## All vectors will be turned into Vector3s in 3D, Z being zeroed. Y is inverted in 3D to mimic it being screenspace
@export var max_velocity := Vector2(0.0, -1.0)
## All vectors will be turned into Vector3s in 3D, Z being zeroed. Y is inverted in 3D to mimic it being screenspace
@export var min_acceleration := Vector2(0.0, 0.0)
## All vectors will be turned into Vector3s in 3D, Z being zeroed. Y is inverted in 3D to mimic it being screenspace
@export var max_acceleration := Vector2(0.0, 0.0)
## Random offset applied to given emission position
@export_range(0.0, 10.0, 0.05, "or_greater") var spawn_radius := 0.0
@export_range(0.0, 10.0, 0.05, "suffix:seconds") var lifetime := 1.0

@export_group("Text")
@export var font : Font
## These sizes coincide with types
@export var font_sizes : Array[int] = [32]
@export var enable_bbcode := false
## These colors coincide with types
@export var colors : Array[Color] = [Color.WHITE]
@export var outline_thickness := 0
## These colors coincide with types
@export var outline_colors : Array[Color] = [Color.BLACK]

@export_subgroup("Fade", "fade_")
@export var fade_enabled := true
@export var fade_ease := Tween.EaseType.EASE_IN_OUT
@export var fade_transition := Tween.TransitionType.TRANS_CIRC

@export_subgroup("Value scales", "value_scaling_")
@export var value_scaling_enabled := false
@export var value_scaling_low_value := 50
@export var value_scaling_high_value := 100	
@export var value_scaling_lowest_scale := 0.7
@export var value_scaling_highest_scale := 1.8
@export var value_scaling_ease := Tween.EaseType.EASE_IN_OUT
@export var value_scaling_speed := 0.3
@export var value_scaling_transition := Tween.TransitionType.TRANS_CIRC
