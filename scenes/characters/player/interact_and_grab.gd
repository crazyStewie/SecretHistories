extends Node

@onready var interaction_cast: RayCast3D = $"../../ModelRoot/MainCamera/InteractionCast"
@onready var grab_cast: RayCast3D = $"../../ModelRoot/MainCamera/GrabCast"

# Releasing the interact key before this time will cause an interaction, holding
# it longer will attempt a grab
@export var interact_threshold : float = 0.2


var _interaction_held_timer : float = 0.0

var grabbed_item : RigidBody3D = null
# Where the object was grabbed, relative to the object
var grab_position_object : Vector3
# Where the object was grabbed, relative to the raycast
var grab_position_raycast : Vector3

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"player|interact"):
		_interaction_held_timer = 0.0
	if Input.is_action_just_released(&"player|interact"):
		if _interaction_held_timer < interact_threshold:
			_try_interact()
		if grabbed_item != null:
			grabbed_item = null
	if Input.is_action_pressed(&"player|interact"):
		_interaction_held_timer += delta
		if _interaction_held_timer > interact_threshold and grabbed_item == null:
			_try_grab()

func _try_grab() -> void:
	grab_cast.force_raycast_update()
	if grab_cast.get_collider() is RigidBody3D:
		grabbed_item = grab_cast.get_collider()
		grab_position_object = grabbed_item.to_local(grab_cast.get_collision_point())
		grab_position_raycast = grab_cast.to_local(grab_cast.get_collision_point())
		print("grabbed")
	pass

func _physics_process(delta: float) -> void:
	if is_instance_valid(grabbed_item):
		var point_object := grabbed_item.to_global(grab_position_object)
		var point_raycast := grab_cast.to_global(grab_position_raycast)
		var difference = point_raycast - point_object
		print("force : ", difference*grabbed_item.mass)
		grabbed_item.apply_force(difference * grabbed_item.mass * 10.0, point_object - grabbed_item.global_position)

func _try_interact() -> void:
	interaction_cast.force_raycast_update()
	var interactable : Interactable = interaction_cast.get_collider() as Interactable
	if is_instance_valid(interactable):
		interactable.interact(owner)
	pass
