@tool
extends EditorPlugin

enum shape_type {TRIMESH, SINGLE, SIMPLIFIED, MULTIPLE}

var glb_collision_batcher_instance: EditorContextMenuPlugin


func _enter_tree():
	const glb_collision_batcher := preload("glb_collision_batcher.gd")
	glb_collision_batcher_instance = glb_collision_batcher.new()
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, glb_collision_batcher_instance)
	glb_collision_batcher_instance.trigger_batch.connect(_on_batch_triggered)


func _exit_tree():
	if is_instance_valid(glb_collision_batcher_instance):
		remove_context_menu_plugin(glb_collision_batcher_instance)


func _on_batch_triggered(type : int, include_internal : bool, selected_nodes: PackedStringArray) -> void:
	var action_dict := _build_action_dict(include_internal, selected_nodes)
	
	if action_dict.is_empty():
		print("No nodes able to be processed in selection.")
	else:
		var undo_redo := get_undo_redo()
		undo_redo.create_action("Batch create collision meshes")
		undo_redo.add_undo_method(self, "_unbatch_action", action_dict)
		_make_nodes_local(action_dict, undo_redo)
		undo_redo.add_do_method(self, "_batch_action", type, action_dict)
		undo_redo.commit_action()
		EditorInterface.mark_scene_as_unsaved()


func _build_action_dict(include_internal : bool, node_paths: PackedStringArray) -> Dictionary[Node, bool]:
	var root := EditorInterface.get_edited_scene_root()
	var return_value : Dictionary[Node, bool]
	
	for path in node_paths:
		var node := root.get_node(path)
		if node is not Node3D:
			push_warning("Node %s selected in batch not a Node3D, which is usually the root of glbs. Unsupported because I am lazy.")
			continue
		
		for child in node.get_children(include_internal):
			if child is MeshInstance3D:
				if !_is_iffy(child):
					return_value[node] = false
					if !root.is_editable_instance(node):
						return_value[node] = true
	
	return return_value


func _is_iffy( mesh : MeshInstance3D) -> bool:
	var iffy := false
	for child in mesh.get_children():
		if child is StaticBody3D:
			push_warning("Tried batch generating collision mesh for %s but it already has a collision mesh as a child. No graceful way to undo so skipping." % mesh)
			iffy = true
	
	return iffy


func _make_nodes_local(actions : Dictionary[Node, bool], undo_redo : EditorUndoRedoManager) -> void:
	var root := EditorInterface.get_edited_scene_root()
	for node : Node in actions:
		if actions[node]:
			undo_redo.force_fixed_history()
			undo_redo.add_do_method(node, "set_scene_file_path", "");
			undo_redo.add_undo_method(node, "set_scene_file_path", node.scene_file_path);
			undo_redo.add_do_property(node, "owner", root);
			undo_redo.add_undo_property(node, "owner", node.owner);


func _batch_action(type : shape_type, actions : Dictionary[Node, bool]) -> void:
	var root := EditorInterface.get_edited_scene_root()
	
	for node : Node in actions:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.owner = root
				
				match type:
					shape_type.TRIMESH:
						child.create_trimesh_collision()
					shape_type.SINGLE:
						child.create_convex_collision()
					shape_type.SIMPLIFIED:
						child.create_convex_collision(true, true)
					shape_type.MULTIPLE:
						var decomposition_settings = MeshConvexDecompositionSettings.new()
						decomposition_settings.max_convex_hulls = 32
						decomposition_settings.max_concavity = 0.01
						child.create_multiple_convex_collisions(decomposition_settings)
				
				var collision := child.get_node(child.name + "_col")
				collision.owner = root
				for collision_child in collision.get_children():
					collision_child.owner = root


func _unbatch_action(actions : Dictionary[Node, bool]) -> void:
	var root := EditorInterface.get_edited_scene_root()
	
	for node : Node in actions:
		for child in node.get_children():
			if child is MeshInstance3D:
				child.owner = node
				var collision := child.get_node(child.name + "_col")
				child.remove_child(collision)
				collision.queue_free()
				
		if actions[node]:
			root.set_editable_instance(node, false)
