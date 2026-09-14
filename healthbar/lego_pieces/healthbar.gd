class_name Healthbar
extends Control

@export var bar_resource : Healthbar_Resource
@export var max_health := 100.0 : set = _set_max_health

@onready var _back: TextureProgressBar = $pivot/back
@onready var _front: TextureProgressBar = $pivot/front
@onready var _pivot: Control = $pivot

var health := max_health

var _bar_tween : Tween = null
var _flash_tween : Tween = null
var _shake_tween : Tween = null

func _ready() -> void:
	if bar_resource:
		_back.max_value = max_health
		_front.max_value = max_health
		
		_back.value = max_health
		_front.value = max_health
		
		_back.texture_under = bar_resource.background
		_back.texture_over = bar_resource.frame
		_back.texture_progress = bar_resource.progress
		_front.texture_progress = bar_resource.fill

func apply_change(change_in_health : float) -> void:
	var target_health = clampf(health + change_in_health, 0.0, max_health)
	
	if _bar_tween:
			_bar_tween.kill()
	
	if change_in_health < 0.0 and health > 0.0:
		_front.value = target_health
		_bar_tween = create_tween()
		_bar_tween.tween_property(_back, "value", target_health, 0.33)
		_flash(bar_resource.damage_color)
		_shake()
	elif change_in_health > 0.0 and health < max_health:
		_back.value = target_health
		_bar_tween = create_tween()
		_bar_tween.tween_property(_front, "value", target_health, 0.2)
		_flash(bar_resource.heal_color)
	
	health = target_health

func _flash(color : Color) -> void:
	if bar_resource.should_flash:
		modulate = color
		if _flash_tween:
			_flash_tween.kill()
		_flash_tween = create_tween()
		_flash_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func _shake() -> void:
	if bar_resource.should_shake:
		if _shake_tween:
			_shake_tween.kill()
			
		_shake_tween = create_tween()
		
		_shake_tween.tween_property(_pivot, "position", Vector2(2.0, 0.0), 0.05)
		_shake_tween.tween_property(_pivot, "position", Vector2(-2.0, 0.0), 0.05)
		_shake_tween.tween_property(_pivot, "position", Vector2(0.0, 0.0), 0.05)

func _set_max_health(new_health : float) -> void:
	max_health = new_health
	_back.max_value = max_health
	_front.max_value = max_health
