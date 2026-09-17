class_name PersonaButton
extends Button

var _cray_material : ShaderMaterial
var _normal_material : CanvasItemMaterial

var default_color : Color
var pop_tween : Tween = null

signal on_button_with_polygon_hovered(button_position : Vector2, button_dimensions : Vector2, offset_rotation : float)


func _init() -> void:
	_normal_material = CanvasItemMaterial.new()
	_normal_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_cray_material = ShaderMaterial.new()
	_cray_material.shader = preload("uid://byjbmi6tj51ft")

func initialize_color(default_grey : Color) -> void:
	default_color = default_grey

func go_crazy() -> void:
	material = _cray_material
	
	offset_transform_scale = Vector2(1.2, 1.2)
	if pop_tween:
		pop_tween.kill()
	pop_tween = create_tween()
	
	pop_tween.tween_property(self, "offset_transform_scale", Vector2(1.3, 1.3), 0.07).set_trans(Tween.TRANS_BACK)
	pop_tween.tween_property(self, "offset_transform_scale", Vector2(1.2, 1.2), 0.07).set_trans(Tween.TRANS_BACK)
	pop_tween.set_ease(Tween.EASE_OUT)

func go_normal() -> void:
	material = _normal_material
	if pop_tween:
		pop_tween.kill()
	offset_transform_scale = Vector2(1.0, 1.0)

func _on_mouse_entered() -> void:
	go_crazy()
	on_button_with_polygon_hovered.emit(global_position, size, offset_transform_rotation)

func _on_mouse_exited() -> void:
	go_normal()
