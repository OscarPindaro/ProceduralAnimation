## A triangle defined by three draggable points (A, B, C).
## The triangle is drawn using a fill color and an outline color.
## When [member show_control_points] is enabled, interactive handles appear
## that can be dragged to reshape the triangle in the editor or at runtime.
@tool
class_name Triangle
extends Node2D


#region Exports

@export_group("Appearance")

## Fill color of the triangle interior.
@export var fill_color: Color = Color.WHITE:
	set(value):
		fill_color = value
		queue_redraw()

## Color of the triangle outline.
@export var outline_color: Color = Color.BLACK:
	set(value):
		outline_color = value
		queue_redraw()

## Thickness of the outline in pixels.
@export_range(0.0, 20.0, 0.1, "suffix:px") var outline_thickness: float = 1.0:
	set(value):
		outline_thickness = value
		queue_redraw()

@export_group("Control Points")

## Show interactive handles for points A, B and C.
## When enabled, each point is drawn as a circle; clicking and dragging
## moves the corresponding Node2D child and reshapes the triangle.
@export var show_control_points: bool = false:
	set(value):
		show_control_points = value
		queue_redraw()

## Radius of each control-point handle in pixels.
@export_range(4.0, 40.0, 1.0, "suffix:px") var handle_radius: float = 8.0:
	set(value):
		handle_radius = value
		queue_redraw()

#endregion


#region Private state

## Child Node2D references, set in _ready().
var _point_a: Node2D
var _point_b: Node2D
var _point_c: Node2D

## Which point (if any) is currently being dragged. Holds a Node2D or null.
var _dragged_point: Node2D = null

## Whether the mouse button is held down.
var _mouse_held: bool = false

## The point currently hovered (for visual feedback).
var _hovered_point: Node2D = null

#endregion


#region Constants

const _POINT_NAMES := ["A", "B", "C"]

## Half-side of the default equilateral triangle (side = 10).
const _DEFAULT_SIDE: float = 100.0

#endregion


func _ready() -> void:
	_ensure_points()
	queue_redraw()


## Creates the three point children if they don't exist yet.
func _ensure_points() -> void:
	_point_a = _get_or_create_point("A", _default_position(0))
	_point_b = _get_or_create_point("B", _default_position(1))
	_point_c = _get_or_create_point("C", _default_position(2))


## Returns the default position for vertex index i of an equilateral triangle
## centered at the origin with side length _DEFAULT_SIDE.
func _default_position(i: int) -> Vector2:
	# Vertices at angles -90°, 210°, 330° so the top vertex points upward.
	var angle := deg_to_rad(-90.0 + i * 120.0)
	# For an equilateral triangle with side s, circumradius R = s / sqrt(3).
	var circumradius := _DEFAULT_SIDE / sqrt(3.0)
	return Vector2(cos(angle), sin(angle)) * circumradius


## Retrieves an existing child Node2D named `point_name`, or creates one
## at `default_pos` if it does not exist.
func _get_or_create_point(point_name: String, default_pos: Vector2) -> Node2D:
	var existing := get_node_or_null(point_name)
	if existing is Node2D:
		return existing as Node2D

	var node := Node2D.new()
	node.name = point_name
	node.position = default_pos
	add_child(node)

	# Ensure the child is saved with the scene when working in the editor.
	if Engine.is_editor_hint():
		node.owner = get_tree().edited_scene_root

	return node


#region Drawing

func _draw() -> void:
	if not _points_ready():
		return

	var a := _point_a.position
	var b := _point_b.position
	var c := _point_c.position

	_draw_filled_triangle(a, b, c)
	_draw_outline(a, b, c)

	if show_control_points:
		_draw_handles(a, b, c)


func _points_ready() -> bool:
	return (
		is_instance_valid(_point_a)
		and is_instance_valid(_point_b)
		and is_instance_valid(_point_c)
	)


func _draw_filled_triangle(a: Vector2, b: Vector2, c: Vector2) -> void:
	var points := PackedVector2Array([a, b, c])
	var colors := PackedColorArray([fill_color, fill_color, fill_color])
	draw_polygon(points, colors)


func _draw_outline(a: Vector2, b: Vector2, c: Vector2) -> void:
	if outline_thickness <= 0.0:
		return
	draw_line(a, b, outline_color, outline_thickness, false)
	draw_line(b, c, outline_color, outline_thickness, false)
	draw_line(c, a, outline_color, outline_thickness, false)


func _draw_handles(a: Vector2, b: Vector2, c: Vector2) -> void:
	var centroid := (a + b + c) / 3.0
	var pts := [a, b, c]
	var nodes := [_point_a, _point_b, _point_c]

	for i in 3:
		var pos: Vector2 = pts[i]
		var node: Node2D = nodes[i]
		var label: String = _POINT_NAMES[i]

		var is_hovered: bool = (node == _hovered_point)
		var is_dragged: bool = (node == _dragged_point)

		# Enlarge handle when hovered or dragged.
		var radius := handle_radius
		if is_dragged:
			radius *= 1.6
		elif is_hovered:
			radius *= 1.3

		# Draw handle circle.
		draw_circle(pos, radius, Color.WHITE)
		draw_arc(pos, radius, 0.0, TAU, 32, Color.BLACK, 1.5, true)

		# Draw label outside the triangle (on the far side from the centroid).
		_draw_point_label(pos, label, centroid)


## Draws a point label (A / B / C) on the opposite side of the centroid
## so it is never inside the triangle.
func _draw_point_label(pos: Vector2, label: String, centroid: Vector2) -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size := 13

	# Direction away from the centroid.
	var outward: Vector2
	if pos.distance_squared_to(centroid) < 0.001:
		outward = Vector2.UP
	else:
		outward = (pos - centroid).normalized()

	var offset := outward * (handle_radius + 10.0)
	var label_pos := pos + offset

	# Small dark shadow for readability over any background.
	draw_string(
		font,
		label_pos + Vector2(1, 1),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		font_size,
		Color(0, 0, 0, 0.6)
	)
	draw_string(
		font,
		label_pos,
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		font_size,
		Color.WHITE
	)

#endregion


#region Input handling

func _process(_delta: float) -> void:
	if not show_control_points or not _points_ready():
		return
	# Keep the canvas refreshed so hover/drag feedback is smooth.
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not show_control_points or not _points_ready():
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_on_mouse_pressed(mb)
			else:
				_on_mouse_released()

	elif event is InputEventMouseMotion:
		_on_mouse_moved(event as InputEventMouseMotion)


func _on_mouse_pressed(mb: InputEventMouseButton) -> void:
	_mouse_held = true
	var local_mouse := to_local(mb.global_position)
	var closest := _closest_point_to(local_mouse)
	if closest != null and local_mouse.distance_to(closest.position) <= handle_radius * 1.5:
		_dragged_point = closest
		get_viewport().set_input_as_handled()


func _on_mouse_released() -> void:
	_mouse_held = false
	_dragged_point = null


func _on_mouse_moved(mm: InputEventMouseMotion) -> void:
	var local_mouse := to_local(mm.global_position)

	# Update hover state.
	var closest := _closest_point_to(local_mouse)
	if closest != null and local_mouse.distance_to(closest.position) <= handle_radius * 1.5:
		_hovered_point = closest
	else:
		_hovered_point = null

	# Move the dragged point.
	if _dragged_point != null and _mouse_held:
		_dragged_point.position = local_mouse
		get_viewport().set_input_as_handled()
		queue_redraw()


## Returns the Node2D point closest to `local_pos`, or null if none exist.
func _closest_point_to(local_pos: Vector2) -> Node2D:
	var best: Node2D = null
	var best_dist := INF

	for node in [_point_a, _point_b, _point_c]:
		if not is_instance_valid(node):
			continue
		var d := local_pos.distance_to(node.position)
		if d < best_dist:
			best_dist = d
			best = node

	return best

#endregion


#region Configuration warnings

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not is_instance_valid(_point_a) or not is_instance_valid(_point_b) or not is_instance_valid(_point_c):
		warnings.append("Triangle is missing one or more point children (A, B, C). Re-enter the scene or re-add the node to fix this.")
	return warnings

#endregion
