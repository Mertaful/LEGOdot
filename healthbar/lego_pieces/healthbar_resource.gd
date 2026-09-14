class_name Healthbar_Resource
extends Resource

#@export_category("Visuals")
@export_group("Bar textures")
@export var background : Texture2D
@export var fill : Texture2D
@export var frame : Texture2D
@export var progress : Texture2D
@export_group("Flash")
@export var should_flash : = true
@export var damage_color : Color = Color(1.0, 0.0, 0.0, 1.0)
@export var heal_color : Color = Color(0.0, 1.0, 0.0, 1.0)
@export_group("Shake")
@export var should_shake := true
