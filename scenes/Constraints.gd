extends Node
class_name Constraints

static func constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	return (point-anchor).normalized() * distance + anchor

static func soft_constrain_distance(point: Vector2, anchor: Vector2, distance: float) -> Vector2:
	if (point-anchor).length() < distance:
		return point
	else:
		return (point-anchor).normalized() * distance + anchor
