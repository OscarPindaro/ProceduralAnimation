extends Node2D

@export_group("algorithm parameters")
@export var is_soft: bool = false
@export_group("chain properties")
@export var do_draw: bool = true
@export var use_catmull_rom: bool = false
@export var catmull_rom_steps: int = 10
@export var number_of_points: int = 5
@export var points: Array[Vector2] = []
@export var distance: float = 10
@export var point_thickness: float = 5
@export var point_color: Color = Color.WHITE_SMOKE
@export_group("thickness curve")
@export var use_thickness_curve: bool = false
@export var thickness_curve: Curve

var mouse_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	for i in range(self.number_of_points):
		points.append(Vector2.ZERO)

func set_point(source: Vector2, target: Vector2):
	source.x = target.x
	source.y = target.y
	return source

func get_thickness(idx: int) -> float:
	if not use_thickness_curve or thickness_curve == null:
		return point_thickness
	var t = idx / float(len(points) - 1)
	return point_thickness * thickness_curve.sample(t)

func _process(_delta: float) -> void:
	self.mouse_pos = get_local_mouse_position()
	if self.is_soft:
		self.points[0] = Constraints.soft_constrain_distance(self.points[0], self.mouse_pos, self.distance)
	else:
		self.points[0] = Constraints.constrain_distance(self.points[0], self.mouse_pos, self.distance)
	for idx in range(1, len(self.points)):
		if self.is_soft:
			self.points[idx] = Constraints.soft_constrain_distance(self.points[idx], self.points[idx-1], self.distance)
		else:
			self.points[idx] = Constraints.constrain_distance(self.points[idx], self.points[idx-1], self.distance)
	self.queue_redraw()

func draw_segment_quads() -> void:
	for idx in range(len(points) - 1):
		var p0 = points[idx]
		var p1 = points[idx+1]
		var tangent = (p1 - p0).normalized()
		var normal = tangent.rotated(PI/2)
		var t0 = get_thickness(idx)
		var t1 = get_thickness(idx+1)

		var quad = PackedVector2Array([
			p0 + normal * t0,
			p1 + normal * t1,
			p1 - normal * t1,
			p0 - normal * t0,
		])
		draw_colored_polygon(quad, point_color)

	for idx in range(len(points)):
		draw_circle(points[idx], get_thickness(idx), point_color)

func build_outline_points() -> Array[Vector2]:
	var outline_points: Array[Vector2] = []
	var front = Vector2.ZERO

	for idx in range(len(self.points)):
		var th = get_thickness(idx)
		if idx == 0:
			var tangent = (mouse_pos - points[0]).normalized()
			var normal = tangent.rotated(PI/2)
			front        = points[0] + tangent * th
			var right_45 = points[0] + tangent.rotated(PI/4) * th
			var right_90 = points[0] + normal * th
			outline_points.append(front)
			outline_points.append(right_45)
			outline_points.append(right_90)
		else:
			var tangent: Vector2
			if idx < len(points) - 1:
				tangent = (points[idx-1] - points[idx+1]).normalized()
			else:
				tangent = (points[idx-1] - points[idx]).normalized()
			var normal = tangent.rotated(PI/2)
			outline_points.append(points[idx] + normal * th)

	var tail_tangent = (points[-2] - points[-1]).normalized()
	var th_tail = get_thickness(len(points) - 1)
	outline_points.append(points[-1] + tail_tangent.rotated(PI) * th_tail * 2)
	outline_points.append(points[-1] - tail_tangent.rotated(PI/2) * th_tail)

	for idx in range(len(points)-2, 0, -1):
		var th = get_thickness(idx)
		var tangent: Vector2
		if idx < len(points) - 1:
			tangent = (points[idx-1] - points[idx+1]).normalized()
		else:
			tangent = (points[idx-1] - points[idx]).normalized()
		var normal = tangent.rotated(PI/2)
		outline_points.append(points[idx] - normal * th)

	var head_tangent = (mouse_pos - points[0]).normalized()
	var head_normal = head_tangent.rotated(PI/2)
	var th_head = get_thickness(0)
	outline_points.append(points[0] - head_normal * th_head)
	outline_points.append(points[0] + head_tangent.rotated(-PI/4) * th_head)
	outline_points.append(front)

	return outline_points

func catmull_rom_sample(outline_points: Array[Vector2]) -> PackedVector2Array:
	var result: PackedVector2Array = []
	var n = len(outline_points)
	for i in range(n - 1):
		var pre  = outline_points[max(i-1, 0)]
		var p0   = outline_points[i]
		var p1   = outline_points[i+1]
		var post = outline_points[min(i+2, n-1)]
		for t_step in range(catmull_rom_steps):
			var t = t_step / float(catmull_rom_steps)
			result.append(p0.cubic_interpolate(p1, pre, post, t))
	result.append(outline_points[-1])
	return result

func _draw() -> void:
	if do_draw:
		var outline_points = build_outline_points()

		var poly: PackedVector2Array
		if use_catmull_rom:
			poly = catmull_rom_sample(outline_points)
		else:
			poly = PackedVector2Array(outline_points)

		draw_colored_polygon(poly, point_color)
