@tool
class_name RegularPolygon
extends Polygon

var _batch_update: bool = false

@export_range(3, 100) var sides: int = 3:
    set(value):
        sides = maxi(value, 3)
        if not _batch_update:
            update_points()

@export var radius: float = 10.0:
    set(value):
        radius = maxf(value, 0.0)
        if not _batch_update:
            update_points()

@export var start_angle: float = 0.0:
    set(value):
        start_angle = value
        if not _batch_update:
            update_points()

func _ready() -> void:
    update_points()

func update_points() -> void:
    var generated_points := PackedVector2Array()
    for index in range(sides):
        var angle := start_angle + TAU / sides * index
        generated_points.append(Vector2.RIGHT.rotated(angle) * radius)
    points = generated_points

func randomize_shape() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()

    _batch_update = true
    sides = rng.randi_range(3, 10)
    radius = rng.randf_range(10.0, 120.0)
    start_angle = rng.randf_range(0.0, TAU)
    _batch_update = false

    update_points()
