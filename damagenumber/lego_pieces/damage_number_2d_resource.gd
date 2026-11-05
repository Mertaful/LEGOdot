class_name DamageNumber2DResource
extends DamageNumberResourceBase

@export_group("Number behavior")
@export var gravity := false
@export var min_velocity := Vector2(0.0, -1.0)
@export var max_velocity := Vector2(0.0, -1.0)
@export var min_acceleration := Vector2(0.0, 0.0)
@export var max_acceleration := Vector2(0.0, 0.0)
@export_range(0.0, 10.0, 0.05, "or_greater") var spawn_radius := 0.0
