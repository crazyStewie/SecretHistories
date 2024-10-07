extends Node
class_name HumanoidCharacterParameters
@export_range(0.0, 10.0, 0.1,"or_greater", "suffix:m/s") var base_speed : float = 1.0
@export_range(0.0, 10.0, 0.1,"or_greater", "suffix:m/s²") var base_acceleration : float = 16.0
@export_range(0.0, 90, 0.1, "radians_as_degrees") var min_slope_angle : float = deg_to_rad(30)
@export_range(0.0, 90, 0.1, "radians_as_degrees") var max_slope_angle : float = deg_to_rad(45)
@export_range(0.0, 10.0, 0.1,"or_greater", "suffix:m/s") var jump_speed : float = 2.5
@export var standing_height : float = 1.6
@export var crouch_height : float = 1.0
@export var jump_control_multiplier : float = 0.5
@export var crouch_speed_multiplier : float = 0.5
@export var sprint_speed_multiplier : float = 1.5
@export var crouch_animation_speed : float = 5.0
@export_range(0.0, 360, 1.0, "or_greater", "radians_as_degrees", "suffix:°/s") var turning_speed : float = TAU
