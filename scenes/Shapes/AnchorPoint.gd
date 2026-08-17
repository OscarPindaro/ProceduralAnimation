@tool
class_name AnchorPoint
extends Node2D


const DEFAULT_ANCHOR_POSITION: Vector2 = Vector2.ZERO
const DEFAULT_RADIUS: float = 10
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()
@export var border_color: Color = Color.BLACK:
	set(value):
		border_color = value
		queue_redraw()
@export var border_thickness: float = 3:
	set(value):
		border_thickness = value
		queue_redraw()
@export var radius: float = DEFAULT_RADIUS:
	set(value):
		radius = value
		queue_redraw()
@export var antialiased: bool = false:
	set(value):
		antialiased = value
		queue_redraw()
@export var resolution_points: int = 32:
	set(value):
		resolution_points = value
		queue_redraw()

var global_center: Vector2:
	get:
		return self.global_position 

	
func is_point_inside(local_point: Vector2) -> bool:
	return local_point.length() <= self.radius


func is_mouse_inside() -> bool:
	return is_point_inside(get_local_mouse_position())


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, resolution_points, border_color, border_thickness, antialiased)