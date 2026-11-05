class_name DamageNumber3D
extends Label3D

@export var properties : DamageNumber3DResource
## Type correlates to index of colors array in DamageNumberResourceBase
@export var type := 0


func _init(new_text : String, new_properties : DamageNumber3DResource, new_type : int = 0):
	properties = new_properties
	text = new_text
	if new_type > 0 && new_type < properties.colors.size():
		type = new_type
	else:
		push_error("Invalid type pused to DamageNumber3D. Type was %d" % new_type)


func _ready() -> void:
	font = properties.font
	font_size = properties.font_size
	outline_size = 0
	modulate = properties.colors[type]
	
