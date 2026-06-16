extends Node2D
class_name Skeleton


# FUTURE CHANGES
# - need to have a simple skeleton class that is just the points with tool helpers that can adjust everything. 
#   the rest of the code will probably just receive vectors, it's a mess to compute all these positions. Otherwise, a joint is a more complex node with some informations, maybe also maximum angles and so on

@export_group("Skeleton Debug")
@export var joint_radius: float = 5
@export var segment_width: float = 2
@export var draw_segments_as_ellipses: bool = false

@export_category("Rendering")
@export_group("Rendering")
@export var body_color: Color = Color("#134fff")
@export var head_color: Color = Color("#82adfe")
@export var outline_color: Color = Color("#000000")
@export var outline_thickness: float = 5.0

@export_group("Body")
@export_range(0, 30, 1.0, "Thickness of shoulders") var shoulder_thickness: float = 10.
@export_range(0, 30, 1.0, "Thickness of hips") var hips_thickness: float = 10.
@export_range(0, 30, 1.0, "Thickness of legs") var legs_thickness: float = 10.

# Joint Nodes
@onready var head = $Joints/Head
@onready var neck = $Joints/Neck
@onready var right_shoulder = $Joints/RightShoulder
@onready var right_elbow = $Joints/RightElbow
@onready var right_hand = $Joints/RightHand
@onready var left_shoulder = $Joints/LeftShoulder
@onready var left_elbow = $Joints/LeftElbow
@onready var left_hand = $Joints/LeftHand
@onready var right_hip = $Joints/RightHip
@onready var right_knee = $Joints/RightKnee
@onready var right_foot = $Joints/RightFoot
@onready var left_hip = $Joints/LeftHip
@onready var left_knee = $Joints/LeftKnee
@onready var left_foot = $Joints/LeftFoot

# other control point
@onready var pube: Node2D = $Pube

# ─────────────────────────────────────────
# Joint Colors (OpenPose COCO 18 - points)
# ─────────────────────────────────────────
const COLOR_NECK            = Color("#FF5500")  # joint 1
const COLOR_RIGHT_SHOULDER  = Color("#FFAA00")  # joint 2
const COLOR_RIGHT_ELBOW     = Color("#FFFF00")  # joint 3
const COLOR_RIGHT_HAND      = Color("#AAFF00")  # joint 4
const COLOR_LEFT_SHOULDER   = Color("#55FF00")  # joint 5
const COLOR_LEFT_ELBOW      = Color("#00FF00")  # joint 6
const COLOR_LEFT_HAND       = Color("#00FF55")  # joint 7
const COLOR_RIGHT_HIP       = Color("#00FFAA")  # joint 8
const COLOR_RIGHT_KNEE      = Color("#00FFFF")  # joint 9
const COLOR_RIGHT_FOOT      = Color("#00AAFF")  # joint 10
const COLOR_LEFT_HIP        = Color("#0055FF")  # joint 11
const COLOR_LEFT_KNEE       = Color("#0000FF")  # joint 12
const COLOR_LEFT_FOOT       = Color("#5500FF")  # joint 13

# ─────────────────────────────────────────
# Segment / Bone Colors (OpenPose COCO 18 - lines, 60% shade)
# ─────────────────────────────────────────
const COLOR_SEG_RIGHT_SHOULDERBLADE = Color("#990000")  # pair 1-2
const COLOR_SEG_LEFT_SHOULDERBLADE  = Color("#993300")  # pair 1-5
const COLOR_SEG_RIGHT_ARM           = Color("#996600")  # pair 2-3
const COLOR_SEG_RIGHT_FOREARM       = Color("#999900")  # pair 3-4
const COLOR_SEG_LEFT_ARM            = Color("#669900")  # pair 5-6
const COLOR_SEG_LEFT_FOREARM        = Color("#339900")  # pair 6-7
const COLOR_SEG_RIGHT_TORSO         = Color("#009900")  # pair 1-8
const COLOR_SEG_RIGHT_UPPER_LEG     = Color("#009933")  # pair 8-9
const COLOR_SEG_RIGHT_LOWER_LEG     = Color("#009966")  # pair 9-10
const COLOR_SEG_LEFT_TORSO          = Color("#009999")  # pair 1-11
const COLOR_SEG_LEFT_UPPER_LEG      = Color("#006699")  # pair 11-12
const COLOR_SEG_LEFT_LOWER_LEG      = Color("#003399")  # pair 12-13
const COLOR_SEG_HEAD                = Color("#000099")  # pair 1-0


func all_joints() -> Array[Node2D]:
	return [
		head, neck,
		right_shoulder, right_elbow, right_hand,
		left_shoulder, left_elbow, left_hand,
		right_hip, right_knee, right_foot,
		left_hip, left_knee, left_foot
	]

func joints_with_colors() -> Dictionary:
	return {
		head:           COLOR_NECK,
		neck:           COLOR_NECK,
		right_shoulder: COLOR_RIGHT_SHOULDER,
		right_elbow:    COLOR_RIGHT_ELBOW,
		right_hand:     COLOR_RIGHT_HAND,
		left_shoulder:  COLOR_LEFT_SHOULDER,
		left_elbow:     COLOR_LEFT_ELBOW,
		left_hand:      COLOR_LEFT_HAND,
		right_hip:      COLOR_RIGHT_HIP,
		right_knee:     COLOR_RIGHT_KNEE,
		right_foot:     COLOR_RIGHT_FOOT,
		left_hip:       COLOR_LEFT_HIP,
		left_knee:      COLOR_LEFT_KNEE,
		left_foot:      COLOR_LEFT_FOOT,
	}

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			left_hand.position = left_elbow.position+ Constraints.constrain_distance(left_hand.position, get_local_mouse_position(), left_hand.position.distance_to(left_elbow.position)).normalized()*left_hand.position.distance_to(left_elbow.position)
			queue_redraw()

func _draw_skeleton():
	var joints = all_joints()
	var coloured_joints: Dictionary = joints_with_colors()
	for joint in joints:
		draw_circle(joint.position, joint_radius, coloured_joints[joint], true)

	_draw_segment(head.position,          neck.position,         COLOR_SEG_HEAD)
	_draw_segment(neck.position,          right_shoulder.position, COLOR_SEG_RIGHT_SHOULDERBLADE)
	_draw_segment(neck.position,          left_shoulder.position,  COLOR_SEG_LEFT_SHOULDERBLADE)
	_draw_segment(right_shoulder.position, right_elbow.position,  COLOR_SEG_RIGHT_FOREARM)
	_draw_segment(left_shoulder.position,  left_elbow.position,   COLOR_SEG_LEFT_FOREARM)
	_draw_segment(right_elbow.position,    right_hand.position,   COLOR_SEG_RIGHT_ARM)
	_draw_segment(left_elbow.position,     left_hand.position,    COLOR_SEG_LEFT_ARM)
	_draw_segment(neck.position,           right_hip.position,    COLOR_SEG_RIGHT_TORSO)
	_draw_segment(neck.position,           left_hip.position,     COLOR_SEG_LEFT_TORSO)
	_draw_segment(right_hip.position,      right_knee.position,   COLOR_SEG_RIGHT_UPPER_LEG)
	_draw_segment(left_hip.position,       left_knee.position,    COLOR_SEG_LEFT_UPPER_LEG)
	_draw_segment(right_knee.position,     right_foot.position,   COLOR_SEG_RIGHT_LOWER_LEG)
	_draw_segment(left_knee.position,      left_foot.position,    COLOR_SEG_LEFT_LOWER_LEG)

func _draw_segment(from: Vector2, to: Vector2, color: Color) -> void:
	if draw_segments_as_ellipses:
		var center = (from + to) / 2.0
		var length = from.distance_to(to)
		var angle = from.angle_to_point(to)
		draw_set_transform(center, angle, Vector2.ONE)
		draw_ellipse(Vector2.ZERO, length / 2.0, segment_width / 2.0, color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_line(from, to, color, segment_width)

func _perp_at_joint(from: Node2D, joint: Node2D, to: Node2D) -> Vector2:
	var in_dir: Vector2 = (joint.position - from.position).normalized()
	var out_dir: Vector2 = (to.position - joint.position).normalized()
	return (in_dir + out_dir).normalized().rotated(deg_to_rad(90))

func _joint_points(from: Node2D, joint: Node2D, to: Node2D, thickness: float) -> Array[Vector2]:
	var perp = _perp_at_joint(from, joint, to)
	return [
		joint.position + perp * thickness / 2.0,
		joint.position - perp * thickness / 2.0,
	]

func _middle_hip() -> Vector2:
	return (right_hip.position + left_hip.position)/2

func _draw_arm(shoulder: Node2D, elbow: Node2D, hand: Node2D, from: Node2D) -> void:
	var arm_length: float = shoulder.position.distance_to(elbow.position) + elbow.position.distance_to(hand.position)
	var elbow_t: float = shoulder.position.distance_to(elbow.position) / arm_length
	var elbow_thikness: float = lerpf(shoulder_thickness, 0.0, elbow_t)

	var sp = _joint_points(from, shoulder, elbow, shoulder_thickness)
	var ep = _joint_points(shoulder, elbow, hand, elbow_thikness)

	draw_colored_polygon(PackedVector2Array([
		sp[0], sp[1], ep[1], ep[0],
	]), body_color)

	draw_colored_polygon(PackedVector2Array([
		ep[0], ep[1], hand.position,
	]), body_color)

func _outer_hip_point(hip: Node2D, knee: Node2D, from: Node2D) -> Vector2:
	# from is the middle hip node
	# [0] is left of travel direction, [1] is right
	# for right hip (travels rightward from center) outer is [0]
	# for left hip (travels leftward from center) outer is [1]
	# so the caller decides which index to pick
	return _joint_points(from, hip, knee, hips_thickness)[0]

func _hip_points() -> Array[Vector2]:
	# returns [right_outer, left_outer]
	var mid = Node2D.new()
	mid.position = _middle_hip()
	return [
		_joint_points(mid, right_hip, right_knee, hips_thickness)[0],
		_joint_points(mid, left_hip, left_knee, hips_thickness)[1],
	]

func _draw_leg(hip: Node2D, knee: Node2D, foot: Node2D, outer_hip_point: Vector2, hip_mid: Vector2, flip: bool = false) -> void:
	var leg_length: float = hip.position.distance_to(knee.position) + knee.position.distance_to(foot.position)
	var knee_t: float = hip.position.distance_to(knee.position) / leg_length
	var knee_thickness: float = lerpf(legs_thickness, 0.0, knee_t)

	var kp = _joint_points(hip, knee, foot, knee_thickness)
	var k0 = kp[0] if not flip else kp[1]
	var k1 = kp[1] if not flip else kp[0]

	draw_colored_polygon(PackedVector2Array([
		outer_hip_point,
		k0, k1,
		pube.position,
		hip_mid,
	]), body_color)

	draw_colored_polygon(PackedVector2Array([
		k0, k1, foot.position,
	]), body_color)

func _draw_torso():
	# get the trpezoid done by the arms
	var right_join_points = _joint_points(neck, right_shoulder, right_elbow, shoulder_thickness)
	var left_join_points = _joint_points(neck, left_shoulder, left_elbow, shoulder_thickness)

	# now let's connect to the hips. 
	# i'm doing the same thinkes computation, and for the right hip i need the one above, which is the "right" point (0 index)
	# for the left, is the left point 1 index. here left and right are different ideas.
	# for the joints, left and right are mirrored (left on the right, right on the left, because the character is in front of me)
	# for the rendering, if you consider the actualy vectors, right is right, left is left
	var hip_node: Node2D = Node2D.new()
	hip_node.position = _middle_hip()
	var right_hip_point: Vector2 =_joint_points(hip_node, right_hip, right_knee, legs_thickness)[0]
	var left_hip_point: Vector2 =_joint_points(hip_node, left_hip, left_knee, legs_thickness)[1]
	
	draw_colored_polygon(PackedVector2Array([
		right_join_points[0], right_join_points[1], right_hip_point, left_hip_point, left_join_points[0], left_join_points[1],
	]), body_color)

func _draw_head():
	var radius: float = neck.position.distance_to(head.position)/2
	var center: Vector2 = (neck.position + head.position) / 2
	draw_circle(center, radius, head_color)




func _simple_render():
	_draw_arm(right_shoulder, right_elbow, right_hand, neck)
	_draw_arm(left_shoulder, left_elbow, left_hand, neck)
	_draw_torso()
	var hp = _hip_points()
	var hip_mid = (hp[0] + hp[1]) / 2.0
	_draw_leg(right_hip, right_knee, right_foot, hp[0], hip_mid)
	_draw_leg(left_hip, left_knee, left_foot, hp[1], hip_mid, true)
	_draw_head()

func _draw():
	_draw_skeleton()
	_simple_render()

	

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		print("A")
		queue_redraw()
