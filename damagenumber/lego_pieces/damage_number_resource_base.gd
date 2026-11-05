@abstract class_name DamageNumberResourceBase
extends Resource

@export_group("Text")
@export var font : Font
@export var font_size := 32
@export var enable_bbcode := false
@export_range(0.0, 10.0, 0.05, "suffix:seconds") var lifetime := 1.0
@export var colors : Array[Color] = [Color.WHITE]

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
@export var value_scaling_transition := Tween.TransitionType.TRANS_CIRC
@export var value_scaling_speed := 0.3
