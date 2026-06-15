extends Node2D
class_name Skeleton

@export_group("Skeleton Debug")
@export var joint_radius: float = 5
@export var segment_width: float = 2



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

# ─────────────────────────────────────────
# Joint Colors (OpenPose COCO 18 - points)
# ─────────────────────────────────────────
# Your skeleton uses: neck(1), shoulders(2,5), elbows(3,6),
# wrists/hands(4,7), hips(8,11), knees(9,12), ankles/feet(10,13)

const COLOR_NECK            = Color(1.000, 0.333, 0.000)  # #FF5500  joint 1
const COLOR_RIGHT_SHOULDER  = Color(1.000, 0.667, 0.000)  # #FFAA00  joint 2
const COLOR_RIGHT_ELBOW     = Color(1.000, 1.000, 0.000)  # #FFFF00  joint 3
const COLOR_RIGHT_HAND      = Color(0.667, 1.000, 0.000)  # #AAFF00  joint 4
const COLOR_LEFT_SHOULDER   = Color(0.333, 1.000, 0.000)  # #55FF00  joint 5
const COLOR_LEFT_ELBOW      = Color(0.000, 1.000, 0.000)  # #00FF00  joint 6
const COLOR_LEFT_HAND       = Color(0.000, 1.000, 0.333)  # #00FF55  joint 7
const COLOR_RIGHT_HIP       = Color(0.000, 1.000, 0.667)  # #00FFAA  joint 8
const COLOR_RIGHT_KNEE      = Color(0.000, 1.000, 1.000)  # #00FFFF  joint 9
const COLOR_RIGHT_FOOT      = Color(0.000, 0.667, 1.000)  # #00AAFF  joint 10
const COLOR_LEFT_HIP        = Color(0.000, 0.333, 1.000)  # #0055FF  joint 11
const COLOR_LEFT_KNEE       = Color(0.000, 0.000, 1.000)  # #0000FF  joint 12
const COLOR_LEFT_FOOT       = Color(0.333, 0.000, 1.000)  # #5500FF  joint 13

# ─────────────────────────────────────────
# Segment / Bone Colors (OpenPose COCO 18 - lines, 60% shade)
# ─────────────────────────────────────────
const COLOR_SEG_RIGHT_SHOULDERBLADE = Color(0.600, 0.000, 0.000)  # #990000  pair 1,2
const COLOR_SEG_LEFT_SHOULDERBLADE  = Color(0.600, 0.200, 0.000)  # #993300  pair 1,5
const COLOR_SEG_RIGHT_ARM           = Color(0.600, 0.400, 0.000)  # #996600  pair 2,3
const COLOR_SEG_RIGHT_FOREARM       = Color(0.600, 0.600, 0.000)  # #999900  pair 3,4
const COLOR_SEG_LEFT_ARM            = Color(0.400, 0.600, 0.000)  # #669900  pair 5,6
const COLOR_SEG_LEFT_FOREARM        = Color(0.200, 0.600, 0.000)  # #339900  pair 6,7
const COLOR_SEG_RIGHT_TORSO         = Color(0.000, 0.600, 0.000)  # #009900  pair 1,8
const COLOR_SEG_RIGHT_UPPER_LEG     = Color(0.000, 0.600, 0.200)  # #009933  pair 8,9
const COLOR_SEG_RIGHT_LOWER_LEG     = Color(0.000, 0.600, 0.400)  # #009966  pair 9,10
const COLOR_SEG_LEFT_TORSO          = Color(0.000, 0.600, 0.600)  # #009999  pair 1,11
const COLOR_SEG_LEFT_UPPER_LEG      = Color(0.000, 0.400, 0.600)  # #006699  pair 11,12
const COLOR_SEG_LEFT_LOWER_LEG      = Color(0.000, 0.200, 0.600)  # #003399  pair 12,13
const COLOR_SEG_HEAD                = Color(0.000, 0.000, 0.600)  # #000099  pair 1,0


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

func _draw():
	var joints = all_joints()
	var coloured_joints: Dictionary = joints_with_colors()
	for joint in joints:
		draw_circle(joint.position, joint_radius, coloured_joints[joint], true)
	# now let's draw the segments
	draw_line(head.position, neck.position, COLOR_SEG_HEAD, segment_width)
	draw_line(neck.position, right_shoulder.position, COLOR_SEG_RIGHT_SHOULDERBLADE, segment_width)
	draw_line(neck.position, left_shoulder.position, COLOR_SEG_LEFT_SHOULDERBLADE, segment_width)
	draw_line(right_shoulder.position, right_elbow.position, COLOR_SEG_RIGHT_FOREARM, segment_width)
	draw_line(left_shoulder.position, left_elbow.position, COLOR_SEG_LEFT_FOREARM, segment_width)
	draw_line(right_elbow.position, right_hand.position, COLOR_SEG_RIGHT_ARM, segment_width)
	draw_line(left_elbow.position, left_hand.position, COLOR_SEG_LEFT_ARM, segment_width)
	draw_line(neck.position, right_hip.position, COLOR_SEG_RIGHT_TORSO, segment_width)
	draw_line(neck.position, left_hip.position, COLOR_SEG_LEFT_TORSO, segment_width)
	draw_line(right_hip.position, right_knee.position, COLOR_SEG_RIGHT_UPPER_LEG, segment_width)
	draw_line(left_hip.position, left_knee.position, COLOR_SEG_LEFT_UPPER_LEG, segment_width)
	draw_line(right_knee.position, right_foot.position, COLOR_SEG_RIGHT_LOWER_LEG, segment_width)
	draw_line(left_knee.position, left_foot.position, COLOR_SEG_LEFT_LOWER_LEG, segment_width)
