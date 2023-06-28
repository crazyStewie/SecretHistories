class_name BT_Gun_Cooldown
extends BT_Node


func tick(state : CharacterState) -> int:
	var equipment = state.character.inventory.current_mainhand_equipment as GunItem
	if equipment:
#		if equipment.on_cooldown or equipment.is_reloading:
		if equipment.on_cooldown or state.character.is_reloading:
			return Status.RUNNING
		return Status.SUCCESS
	return Status.FAILURE
