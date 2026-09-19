class_name PersonaStyleMenu
extends Control

enum PolygonCorner {TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT}

@export var _menu_resource : PersonaMenuResource

@onready var background: ColorRect = %Background
@onready var menu_name_label: RichTextLabel = %MenuNameLabel
@onready var buttons_container: VBoxContainer = %ButtonsContainer
@onready var back_polygon: Polygon2D = %BackPolygon
@onready var front_polygon: Polygon2D = %FrontPolygon

var _rng : RandomNumberGenerator
var _polygon_tween : Tween = null
var _hovered_buttons : Array[int]

func _ready() -> void:
	_rng = RandomNumberGenerator.new()
	for button : PersonaButton in buttons_container.get_children():
		_set_button_color(button)
		button.on_button_with_polygon_hovered.connect(_on_button_hovered)
		button.on_button_with_polygon_lost_focus.connect(_on_button_left)
	
	back_polygon.color = _menu_resource.accent_color
	front_polygon.color = Color(1.0, 1.0, 1.0, 1.0)
	_update_polygon(Vector2(-10000.0, -10000.0))
	background.color = _menu_resource.main_color

func _set_button_color(button : PersonaButton) -> void:
	_rng.seed = hash(button.text) + 3
	var grey_amount := _rng.randf_range(_menu_resource.darkest_grey.r, _menu_resource.brightest_grey.r)
	var grey := Color(grey_amount, grey_amount, grey_amount)
	var offset_rotation := _rng.randf_range(-_menu_resource.max_rotation_offset, _menu_resource.max_rotation_offset)
	button.add_theme_color_override("font_color", grey)
	button.initialize_color(grey)
	button.offset_transform_enabled = true
	button.offset_transform_rotation = deg_to_rad(offset_rotation)
	button.add_theme_color_override("font_hover_color", _menu_resource.accent_color)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(preload("uid://cjv1o4kkfd50g"))
	
func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_button_left(button_id : int) -> void:
	_hovered_buttons.erase(button_id)
	if _hovered_buttons.is_empty():
		_update_polygon(Vector2(-10000.0, -10000.0))

func _on_button_hovered(button_id : int, button_center_position : Vector2, string_dimensions : Vector2, offset_rotation : float) -> void:
	_hovered_buttons.append(button_id)
	_update_polygon(button_center_position, string_dimensions, offset_rotation)

func _update_polygon(polygon_center_position : Vector2, dimensions : Vector2 = Vector2(0.0, 0.0), polygon_rotation : float = 0.0) -> void:
	dimensions *= 1.2
	var half_x = dimensions.x * 0.5
	var half_y = dimensions.y * 0.5
	
	var new_vertices : PackedVector2Array
	var availableCorners := [PolygonCorner.TOP_LEFT, PolygonCorner.TOP_RIGHT, PolygonCorner.BOTTOM_RIGHT, PolygonCorner.BOTTOM_LEFT]
	var popped_corner : PolygonCorner = availableCorners.pop_at(randi_range(0, 3))
	for i in range(3):
		var new_vertex : Vector2
		var vertex_random_offset := randf_range(_menu_resource.polygon_margin - 5.0, _menu_resource.polygon_margin + 5.0)
		match availableCorners.pop_back():
			PolygonCorner.TOP_LEFT:
				new_vertex = Vector2(-vertex_random_offset - half_x, (-vertex_random_offset - half_y) if popped_corner != PolygonCorner.BOTTOM_LEFT else 0.0)
			PolygonCorner.TOP_RIGHT:
				new_vertex = Vector2(half_x + vertex_random_offset, (-vertex_random_offset - half_y) if popped_corner != PolygonCorner.BOTTOM_RIGHT else 0.0)
			PolygonCorner.BOTTOM_LEFT:
				new_vertex = Vector2(-vertex_random_offset - half_x, (vertex_random_offset + half_y) if popped_corner != PolygonCorner.TOP_LEFT else 0.0)
			PolygonCorner.BOTTOM_RIGHT:
				new_vertex = Vector2(half_x + vertex_random_offset, (vertex_random_offset + half_y) if popped_corner != PolygonCorner.TOP_RIGHT else 0.0)
		new_vertices.append(new_vertex)
	
	
	if _polygon_tween:
		_polygon_tween.kill()
	_polygon_tween = create_tween()
	_polygon_tween.set_parallel()
	_polygon_tween.tween_property(back_polygon, "global_position", polygon_center_position, 0.01)
	_polygon_tween.tween_property(front_polygon, "global_position", polygon_center_position, 0.01)
	_polygon_tween.tween_property(back_polygon, "rotation", polygon_rotation, 0.01)
	_polygon_tween.tween_property(front_polygon, "rotation", polygon_rotation, 0.01)
	back_polygon.polygon = new_vertices
	front_polygon.polygon = new_vertices
