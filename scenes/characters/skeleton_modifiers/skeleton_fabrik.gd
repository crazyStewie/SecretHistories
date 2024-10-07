@tool
extends SkeletonModifier3D
class_name FabrikSkeletonModifier
## This script looks through a list of bones to detect if any of them is
## below the floor (lower than the origin of the skeleton itself), and moves
## the whole skeleton up by the corresponding amount if it is, keeping the
## skeleton grounded

@export var target_node : Node3D
@export var track_basis : bool = true

var valid_bones = false
var end_bone_is_child = false
@export var start_bone : String = "" :
	set(value):
		start_bone = value
		_update_bone_list()
@export var end_bone : String = "":
	set(value):
		end_bone = value
		_update_bone_list()
@export var iterations : int = 1
@export var margin := 0.01

# bone ids of the chain (end bone first, base bone last)
var bone_ids : Array[int] = []

func _update_bone_list():
	if not is_node_ready():
		if not ready.is_connected(_update_bone_list):
			ready.connect(_update_bone_list, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
		return
	valid_bones = true
	end_bone_is_child = true
	bone_ids.clear()
	var skeleton := get_skeleton()
	var start_bone_id := skeleton.find_bone(start_bone)
	if start_bone_id < 0: valid_bones = false; update_configuration_warnings(); return
	var end_bone_id := skeleton.find_bone(end_bone)
	if end_bone_id < 0: valid_bones = false; update_configuration_warnings(); return
	bone_ids.push_back(end_bone_id)
	var current_bone := end_bone_id
	while current_bone != start_bone_id:
		current_bone = skeleton.get_bone_parent(current_bone)
		if current_bone < 0: end_bone_is_child = false; update_configuration_warnings(); return
		bone_ids.push_back(current_bone)
	update_configuration_warnings()

func _get_configuration_warnings() -> PackedStringArray:
	if not valid_bones:
		return PackedStringArray(["Both the start and end bones must be set to valid bones"])
	elif not end_bone_is_child:
		return PackedStringArray(["The end bone must be a descendent (child, grandchild, etc) of the start bone"])
	return PackedStringArray()

func _validate_property(property: Dictionary) -> void:
	match property["name"]:
		"start_bone", "end_bone":
			property["hint"] = PROPERTY_HINT_ENUM
			property["hint_string"] = get_skeleton().get_concatenated_bone_names()




var max_horizontal_angle := deg_to_rad(90)
var max_vertical_angle := deg_to_rad(60)


func _ready() -> void:
	_update_bone_list()

func _process_modification() -> void:
	if not (is_instance_valid(target_node) and valid_bones and end_bone_is_child): return
	var skeleton := get_skeleton()
	var target_transform : Transform3D = target_node.global_transform*skeleton.global_transform.inverse()

	var end_bone_transform = skeleton.get_bone_global_pose(bone_ids[0])
	if not track_basis : target_transform.basis = end_bone_transform.basis

	var bone_positions : Array[Vector3]
	bone_positions.push_back(target_transform.origin)

	for i in bone_ids.size():
		bone_positions.push_back(skeleton.get_bone_global_pose(bone_ids[i]).origin)
	bone_positions.push_back(bone_positions[-1])

	var bone_positions_original = bone_positions.duplicate(true)

	var segment_lengths : Array[float]
	for i in bone_positions.size() - 1:
		segment_lengths.push_back(bone_positions[i].distance_to(bone_positions[i + 1]))
	segment_lengths[0] = 0.0
	for _iter in iterations:
		# end-first pass
		for i in range(1, bone_positions.size()-1):
			var current_distance = bone_positions[i].distance_to(bone_positions[i-1])
			var original = bone_positions[i]
			bone_positions[i] = bone_positions[i].move_toward(bone_positions[i-1], current_distance - segment_lengths[i-1])

		# start-first pass
		for i in range(bone_positions.size() - 2, 0, -1):
			var current_distance = bone_positions[i].distance_to(bone_positions[i+1])
			bone_positions[i] = bone_positions[i].move_toward(bone_positions[i+1], current_distance - segment_lengths[i])
		pass
	var cumm_basis := Basis.IDENTITY
	for i in range(bone_ids.size()-1, 0, -1):
		var current_transform := skeleton.get_bone_global_pose(bone_ids[i])
		current_transform.origin = bone_positions[i+1]
		var bone_rotation = Basis(
			Quaternion(
				cumm_basis*(bone_positions_original[i] - bone_positions_original[i+1]).normalized(),
				(bone_positions[i] - bone_positions[i+1]).normalized()
			)
		)
		cumm_basis = bone_rotation*cumm_basis
		current_transform.basis = bone_rotation*current_transform.basis
		skeleton.set_bone_global_pose(bone_ids[i], current_transform)
		skeleton.force_update_bone_child_transform(bone_ids[i])
	var end_transform = Transform3D(target_transform.basis, bone_positions[1])
	skeleton.set_bone_global_pose(bone_ids[0], end_transform)
