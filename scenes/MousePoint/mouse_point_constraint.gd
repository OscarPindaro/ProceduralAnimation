extends Node2D

@export var is_soft: bool = false
@export var do_draw: bool = false
@export var point_position: Vector2 = Vector2.ZERO
@export var distance: float = 10
@export var point_thickness: float = 5


var mouse_pos: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.mouse_pos = get_local_mouse_position()
	if self.is_soft:
		self.point_position = Constraints.soft_constrain_distance(self.point_position, self.mouse_pos, self.distance)
	else:
		self.point_position = Constraints.constrain_distance(self.point_position, self.mouse_pos, self.distance)
	self.queue_redraw()

func _draw() -> void:
	if do_draw:
		draw_circle(self.point_position, self.point_thickness, Color.AQUA)
		draw_circle(self.mouse_pos, self.distance, Color.DARK_RED, false, 2)
