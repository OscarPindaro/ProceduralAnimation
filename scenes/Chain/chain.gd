extends Node2D

@export_group("algorithm parameters")
@export var is_soft: bool = false
@export var check_collisions: bool = false
@export_group("chain properties")
@export var do_draw: bool = true
@export var number_of_points: int = 5
@export var points: Array[Vector2] = []
@export var distance: float = 10
@export var point_thickness: float = 5
@export var point_color: Color = Color.WHITE_SMOKE

var mouse_pos: Vector2 = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(self.number_of_points):
		points.append(Vector2.ZERO)


func set_point(source: Vector2, target: Vector2):
	source.x = target.x
	source.y = target.y
	return source

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.mouse_pos = get_local_mouse_position()
	self.points[0] = set_point(self.points[0], self.mouse_pos)
	for idx in range(1,len(self.points)):
		if self.is_soft:
			self.points[idx] = Constraints.soft_constrain_distance(self.points[idx], self.points[idx-1], self.distance)
		else:
			self.points[idx] = Constraints.constrain_distance(self.points[idx], self.points[idx-1], self.distance)
	self.queue_redraw()

	if check_collisions:
		self.points = Constraints.constraint_circle_collision_all(self.points, self.point_thickness)

func _draw() -> void:
	if do_draw:
		for point in self.points:
			draw_circle(point, self.point_thickness, point_color)
		for idx in range(1, len(self.points)):
			draw_line(self.points[idx-1], self.points[idx], self.point_color, 3)
