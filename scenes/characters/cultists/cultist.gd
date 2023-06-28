class_name Cultist
extends Character


var weapon_resource = preload("res://scenes/objects/pickable_items/equipment/ranged/double-barrel_shotgun/shotgun_item.tscn")
var ammo_resource = preload("res://resources/tiny_items/ammunition/shotgun_shell.tres")

onready var direct_player_sight_sensor : Node = $Body/DirectPlayerSight


#enum #LOADOUT PACKAGES FOR NEOPHYTES:
#(# in parentheses is probability weight) {
#    (50) Double-barrel shotgun + 2 loaded + 1-3 spare + old knife
#    (50) Double-barrel shotgun + 2 loaded + 1-3 spare + dagger
#    (10) Sawed-off shotgun + 2 loaded + 1-3 spare + old knife
#    (10) Sawed-off shotgun + 2 loaded + 1-3 spare + dagger
#    (10) Martini-Henry rifle + 1 loaded + 2-3 spare + old knife
#    (10) Martini-Henry rifle + 1 loaded + 2-3 spare + dagger
#    (3) Webley + 6 loaded + old knife
#    (3) Webley + 6 loaded + dagger
#    (1) Khyber-pass Martini + 1 loaded + 2-3 spare + old knife
#    (1) Khyber-pass Martini + 1 loaded + 2-3 spare + dagger
#}


func _ready():
#	._ready()   # Not needed
	print("Cultist ready function:")
	inventory.add_item(weapon_resource.instance())
	print("cultist.gd added shotgun")
	inventory.insert_tiny_item(ammo_resource, 10)
	print("cultist.gd added ammo")
	inventory.equip_mainhand_item()
	
	print("Max health: ", max_health)

	# This override is for purpose of ragdoll, but still not working
	skeleton = $FPSCamera/MainCharOnlyArmsGameRig/rig_deform/Skeleton
