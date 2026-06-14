extends Node
class_name Constraints

static func constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	return (point-anchor).normalized() * distance + anchor

static func soft_constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	if (point-anchor).length() < distance:
		return point
	else:
		return (point-anchor).normalized() * distance + anchor

static func check_circle_collision(point1: Vector2, point2: Vector2, radius:float) -> bool:
	# checks if two balls with same radius collide
	var curr_displacement: Vector2 = point1 - point2
	return curr_displacement.length() < radius*2

static func constrain_circle_collision(point1: Vector2, point2: Vector2, radius:float) -> Array[Vector2]:
	# computes collision result of two balls with same radius
	var out_arr: Array[Vector2] = []
	if check_circle_collision(point1, point2, radius):
		var new_point1 = constrain_distance(point1, point2, radius)
		var new_point2 = constrain_distance(point2, point1, radius)
		out_arr.append(new_point1)
		out_arr.append(new_point2)
	else:
		out_arr.append(point1)
		out_arr.append(point2)
	return out_arr

static func constraint_circle_collision_all(points: Array[Vector2], radius: float)-> Array[Vector2]:
	# computes all the collision constraints of some points with the same radius
	for i in range(len(points)):
		for j in range(i, len(points)):
			var new_points: Array[Vector2] = constrain_circle_collision(points[i], points[j], radius)
			assert(len(new_points) == 2)
			points[i] = new_points[0]
			points[j] = new_points[1]
	return points




		
