@tool
class_name Polygon
extends VectorObject

@export_tool_button("Randomize", "Callable") var randomize_action: Callable = Callable(self, &"randomize_shape")

func randomize_shape() -> void:
    var rng := RandomNumberGenerator.new()
    rng.randomize()

    var count := rng.randi_range(3, 10)
    var spacing := TAU / count
    var generated := PackedVector2Array()
    for index in range(count):
        var angle := index * spacing + rng.randf_range(-spacing * 0.25, spacing * 0.25)
        var distance := rng.randf_range(50.0, 120.0)
        generated.append(Vector2.RIGHT.rotated(angle) * distance)
    points = generated
