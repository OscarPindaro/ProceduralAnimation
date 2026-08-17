@tool
class_name VectorObject
extends Node2D

## Base class for drawable vector shapes.
##
## A VectorObject can be filled, outlined, redrawn in the editor,
## and sampled for shape transformations.

@export var points: PackedVector2Array = PackedVector2Array():
    set(value):
        points = value
        queue_redraw()
        update_configuration_warnings()

@export var icolor: Color = Color.WHITE:
    set(value):
        icolor = value
        queue_redraw()

@export var ocolor: Color = Color.BLACK:
    set(value):
        ocolor = value
        queue_redraw()

@export var border: float = 0.0:
    set(value):
        border = value
        queue_redraw()

@export var antialised: bool = false:
    set(value):
        antialised = value
        queue_redraw()

func _ready() -> void:
    queue_redraw()

func _get_configuration_warnings() -> PackedStringArray:
    var warnings := PackedStringArray()
    if points.size() < 3:
        warnings.append("VectorObject requires at least 3 points.")
    return warnings

func _draw() -> void:
    if points.size() < 2:
        return

    if points.size() >= 3:
        var colors := PackedColorArray()
        for _index in points:
            colors.append(icolor)
        draw_polygon(points, colors)

    var closed_points: PackedVector2Array = points.duplicate()
    closed_points.append(points[0])
    var width := border if border > 0.0 else -1.0
    draw_polyline(closed_points, ocolor, width, antialised)

func sample_points(_n: int) -> PackedVector2Array:
    # normally samples n points, but Mobject can contain anything
    return self.points