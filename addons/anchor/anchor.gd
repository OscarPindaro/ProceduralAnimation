@tool
extends EditorPlugin

## The anchor currently being dragged, or null.
var _dragged_anchor: AnchorPoint = null
## Offset between the anchor's origin and the mouse at grab time (local space),
## so the point doesn't snap its center to the cursor.
var _grab_offset: Vector2 = Vector2.ZERO


## Return true when the edited scene contains AnchorPoints we might want to drag.
## Returning true routes viewport input through _forward_canvas_gui_input.
func _handles(object: Object) -> bool:
	return true
# func _handles(object: Object) -> bool:
# 	return _find_anchors().size() > 0


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			return _try_begin_drag(event)
		else:
			return _end_drag()

	if event is InputEventMouseMotion and _dragged_anchor != null:
		_update_drag()
		return true  # consume: stop the editor from box-selecting/panning

	return false


## Picks the topmost anchor under the cursor and starts dragging it.
func _try_begin_drag(event: InputEventMouseButton) -> bool:
	var anchors := _find_anchors()
	# Iterate in reverse so anchors drawn on top (later siblings) win the hit test.
	for i in range(anchors.size() - 1, -1, -1):
		var anchor := anchors[i]
		var local_mouse := anchor.get_local_mouse_position()
		if anchor.is_point_inside(local_mouse):
			_dragged_anchor = anchor
			_grab_offset = local_mouse  # vector from origin to cursor, local space
			return true  # consume so the editor doesn't start its own selection
	return false


func _update_drag() -> void:
	if _dragged_anchor == null:
		return
	# Where is the mouse in the anchor's parent space? Move the origin there,
	# keeping the original grab offset so the point doesn't jump under the cursor.
	var parent := _dragged_anchor.get_parent() as Node2D
	var mouse_in_parent: Vector2
	if parent != null:
		mouse_in_parent = parent.get_local_mouse_position()
	else:
		mouse_in_parent = _dragged_anchor.get_global_mouse_position()

	var offset_in_parent := _grab_offset.rotated(_dragged_anchor.rotation) * _dragged_anchor.scale
	var new_pos := mouse_in_parent - offset_in_parent

	# Route through UndoRedo so the move is undoable and marks the scene dirty.
	var undo_redo := get_undo_redo()
	undo_redo.create_action("Move AnchorPoint", UndoRedo.MERGE_ENDS)
	undo_redo.add_do_property(_dragged_anchor, "position", new_pos)
	undo_redo.add_undo_property(_dragged_anchor, "position", _dragged_anchor.position)
	undo_redo.commit_action()
	update_overlays()
	EditorInterface.get_selection().emit_signal("selection_changed")


func _end_drag() -> bool:
	if _dragged_anchor == null:
		return false
	_dragged_anchor = null
	return true


## Collects every AnchorPoint in the currently edited scene.
func _find_anchors() -> Array[AnchorPoint]:
	var result: Array[AnchorPoint] = []
	var root := EditorInterface.get_edited_scene_root()
	if root == null:
		return result
	_collect(root, result)
	return result


func _collect(node: Node, into: Array[AnchorPoint]) -> void:
	if node is AnchorPoint:
		into.append(node)
	for child in node.get_children():
		_collect(child, into)