class_name CollisionShapeBatcher
extends EditorContextMenuPlugin

const COLLISION_BATCH_POPUP := preload("collision_shape_batcher_popup.tscn")

signal trigger_batch

var _window : Window
var _selected_nodes : PackedStringArray

func _init():
	print("Initialized GLBCollisionBatcher")

func _popup_menu(paths: PackedStringArray) -> void:
	add_context_menu_item("Generate collision shapes for glb(s)...", _on_batcher_selected)

func _on_batcher_selected(paths: PackedStringArray) -> void:
	_selected_nodes = paths
	var editor_settings = EditorInterface.get_editor_settings()
	var editor_theme = editor_settings.get_setting("interface/theme/preset")
	
	_window = Window.new()
	_window.unresizable = true
	_window.maximize_disabled = true
	_window.minimize_disabled = true
	_window.title = "GLB Collision Batcher"
	_window.theme = editor_theme
	EditorInterface.popup_dialog_centered(_window)
	
	var gui := COLLISION_BATCH_POPUP.instantiate()
	_window.add_child(gui)
	
	gui.execute.connect(_on_batch)
	gui.cancelled.connect(_close_window)
	
	_window.size = gui.get_size()
	_window.close_requested.connect(func(): _window.queue_free())

func _on_batch(type : int, include_internal : bool) -> void:
	trigger_batch.emit(type, include_internal, _selected_nodes)
	_close_window()

func _close_window() -> void:
	_window.queue_free()
	_selected_nodes.clear()
