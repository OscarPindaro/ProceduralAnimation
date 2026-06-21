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
		color = value
		queue_redraw()
@export var border_thickness: float = 3:
	set(value):
		border_thickness = value
		queue_redraw()
@export var radius: float = DEFAULT_RADIUS:
	set(value):
		radius = value
		queue_redraw()
@export var antialised: bool = false:
	set(value):
		antialised = value
		queue_redraw()
@export var resolution_points: int = 32:
	set(value):
		resolution_points = value
		queue_redraw()

var center: Vector2:
	get:
		return self.position
var global_center: Vector2:
	get:
		return self.global_position 

	
func _is_mouse_in_anchor() -> bool:
	var local_mouse_p: Vector2 = get_local_mouse_position() 
	var mouse_distance: float = (center - local_mouse_p).length()
	if mouse_distance <= self.radius:
		return true
	else:
		return false


func _draw() -> void:
	draw_circle(center, radius, color)
	draw_arc(center, radius, 0.0, TAU, resolution_points, border_color, border_thickness, antialised)

