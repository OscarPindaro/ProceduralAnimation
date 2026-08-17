@tool
class_name Circle
extends Node2D

@export var icolor: Color = Color.WHITE:
    set(value):
        icolor = value
        queue_redraw()

@export var ocolor: Color = Color.BLACK:
    set(value):
        ocolor = value
        queue_redraw()

@export var radius: float = 10.0:
    set(value):
        radius = maxf(value, 0.0)
        queue_redraw()

@export var border: float = 0.0:
    set(value):
        border = value
        queue_redraw()

@export var antialised: bool = false:
    set(value):
        antialised = value
        queue_redraw()

const ARC_PRECISION: int = 50


func _ready() -> void:
    queue_redraw()


func _draw() -> void:
    draw_circle(Vector2.ZERO, radius, icolor, true, -1.0, antialised)
    var width := border if border > 0.0 else -1.0
    draw_arc(Vector2.ZERO, radius, 0.0, TAU + 0.01, ARC_PRECISION, ocolor, width, antialised)
