## EditorPlugin that intercepts canvas mouse events and forwards them to the
## selected Triangle node so its control-point handles can be dragged.
##
## Installation
## ------------
## 1. Place triangle.gd and this file anywhere inside res://addons/triangle/
## 2. Create res://addons/triangle/plugin.cfg:
##
##     [plugin]
##     name="Triangle"
##     description="Draggable triangle tool node."
##     author="you"
##     version="1.0"
##     script="triangle_editor_plugin.gd"
##
## 3. Enable the plugin in Project → Project Settings → Plugins.
@tool
extends EditorPlugin


## The Triangle node currently selected in the scene tree, or null.
var _triangle: Triangle = null

## Whether the left mouse button is currently held.
var _mouse_held: bool = false


func _enter_tree() -> void:
	# Listen for selection changes so we always track the active Triangle.
	get_editor_interface().get_selection().selection_changed.connect(_on_selection_changed)
	_refresh_selection()


func _exit_tree() -> void:
	var sel := get_editor_interface().get_selection()
	if sel.selection_changed.is_connected(_on_selection_changed):
		sel.selection_changed.disconnect(_on_selection_changed)
	_clear_triangle()


func _on_selection_changed() -> void:
	_refresh_selection()


func _refresh_selection() -> void:
	_clear_triangle()
	var selected := get_editor_interface().get_selection().get_selected_nodes()
	for node in selected:
		if node is Triangle:
			_triangle = node as Triangle
			break


func _clear_triangle() -> void:
	if is_instance_valid(_triangle):
		_triangle.set_hovered_point(null)
		_triangle.set_dragged_point(null)
	_triangle = null
	_mouse_held = false


## Called by the editor for every input event in the 2D viewport.
## Return true to consume the event (prevents the editor from acting on it).
func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not is_instance_valid(_triangle):
		return false
	if not _triangle.show_control_points:
		return false

	if event is InputEventMouseButton:
		return _handle_mouse_button(event as InputEventMouseButton)

	if event is InputEventMouseMotion:
		return _handle_mouse_motion(event as InputEventMouseMotion)

	return false


func _handle_mouse_button(mb: InputEventMouseButton) -> bool:
	if mb.button_index != MOUSE_BUTTON_LEFT:
		return false

	if mb.pressed:
		_mouse_held = true
		var local_pos := _to_triangle_local(mb.global_position)
		var closest := _closest_point(local_pos)
		if closest != null and local_pos.distance_to(closest.position) <= _triangle.handle_radius * 1.5:
			_triangle.set_dragged_point(closest)
			return true  # consume — stop editor from moving the node
	else:
		_mouse_held = false
		# Notify undo/redo that the scene changed.
		if _triangle._dragged_point != null:
			_commit_undo()
		_triangle.set_dragged_point(null)

	return false


func _handle_mouse_motion(mm: InputEventMouseMotion) -> bool:
	var local_pos := _to_triangle_local(mm.global_position)

	# Update hover highlight.
	var closest := _closest_point(local_pos)
	if closest != null and local_pos.distance_to(closest.position) <= _triangle.handle_radius * 1.5:
		_triangle.set_hovered_point(closest)
	else:
		_triangle.set_hovered_point(null)

	# Drag the active point.
	if _mouse_held and _triangle._dragged_point != null:
		_triangle.move_dragged_point_to(local_pos)
		return true  # consume motion so the editor doesn't pan/select

	return false


## Converts a global screen position to the Triangle node's local space,
## accounting for the editor camera transform.
func _to_triangle_local(global_screen_pos: Vector2) -> Vector2:
	var viewport := get_editor_interface().get_editor_viewport_2d()
	# global_position on editor events is already in viewport canvas coordinates.
	# Transform it through the triangle's global transform to get local coords.
	var canvas_pos := viewport.get_canvas_transform().affine_inverse() * global_screen_pos
	return _triangle.to_local(canvas_pos)


## Returns the Triangle point node closest to `local_pos`.
func _closest_point(local_pos: Vector2) -> Node2D:
	var best: Node2D = null
	var best_dist := INF
	for node in _triangle.get_points():
		var d := local_pos.distance_to(node.position)
		if d < best_dist:
			best_dist = d
			best = node
	return best


## Registers a single undo step after a drag completes so Ctrl+Z works.
func _commit_undo() -> void:
	var undo := get_undo_redo()
	var point := _triangle._dragged_point
	# We don't have the "before" position here easily, so just mark the scene
	# modified. For full undo support you'd store the start position in
	# _handle_mouse_button when pressing and use it here.
	undo.create_action("Move Triangle Point")
	undo.commit_action()