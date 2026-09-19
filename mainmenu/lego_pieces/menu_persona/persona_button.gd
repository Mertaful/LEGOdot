class_name PersonaButton
extends Button

var _cray_material : ShaderMaterial
var _normal_material : CanvasItemMaterial

var default_color : Color
var pop_tween : Tween = null

signal on_button_with_polygon_hovered(id : int, button_position : Vector2, button_dimensions : Vector2, offset_rotation : float)
signal on_button_with_polygon_lost_focus(id : int)


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
	var text_dimensions = theme.get_font("font", "Button").get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, get_theme_font_size("font_size", "Button"))
	on_button_with_polygon_hovered.emit(get_instance_id(), Vector2(global_position.x + size.x * 0.5, global_position.y + size.y * 0.5), text_dimensions, offset_transform_rotation)

func _on_mouse_exited() -> void:
	go_normal()
	on_button_with_polygon_lost_focus.emit(get_instance_id())
	
