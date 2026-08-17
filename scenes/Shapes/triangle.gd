@tool
class_name Triangle
extends VectorObject

@export var radius: float = 10.0:
    set(value):
        radius = maxf(value, 0.0)
        _update_points()

func _ready() -> void:
    _update_points()

func _update_points() -> void:
    var triangle_points := PackedVector2Array()
    for index in range(3):
        triangle_points.append(Vector2.UP.rotated(index * TAU / 3.0) * radius)
    points = triangle_points
