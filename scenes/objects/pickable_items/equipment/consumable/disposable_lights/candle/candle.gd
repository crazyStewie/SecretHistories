class_name CandleItem
extends DisposableLightItem


signal item_is_dropped

var is_lit = true
var burn_time : float
var is_depleted : bool = false
var is_dropped: bool = false
var is_just_dropped: bool = true
var light_timer
var random_number
export(float, 0.0, 1.0) var life_percentage_lose : float = 0.0
export(float, 0.0, 1.0) var prob_going_out : float = 0.0

var material
var new_material

onready var firelight = $FireOrigin/Fire/Light


func _ready():
	light_timer = $BurnTime
	self.connect("item_is_dropped", self, "item_drop")
	if not light_timer.is_connected("timeout", self, "_light_depleted"):
		light_timer.connect("timeout", self, "_light_depleted")
	burn_time = 3600.0
	light()


func _process(delta):
	if item_state == GlobalConsts.ItemState.DROPPED:
		$Ignite/CollisionShape.disabled = false
		is_dropped = true
		
		if is_dropped and not is_just_dropped:
			is_just_dropped = true
			self.emit_signal("item_is_dropped")
			item_drop()
	else:
		$Ignite/CollisionShape.disabled = true
		is_dropped = false
		is_just_dropped = false


func light():
	if not is_depleted:
		$AnimationPlayer.play("flicker")
		$Sounds/LightSound.play()
	#	$FireOrigin/Fire.emitting = not $FireOrigin/Fire.emitting
		$FireOrigin/Fire.visible = not $FireOrigin/Fire.visible
		firelight.visible = not firelight.visible
		$MeshInstance.cast_shadow = false
		$MeshInstance.get_surface_material(0).emission_enabled = true
		
		is_lit = true
		light_timer.set_wait_time(burn_time)
		light_timer.start()


func unlight():
	if not is_depleted:
		$AnimationPlayer.stop()
		$MeshInstance.get_surface_material(0).emission_enabled = false
	#	$FireOrigin/Fire.emitting = false
		$FireOrigin/Fire.visible = false
		firelight.visible = false
		$MeshInstance.cast_shadow = true
		
		is_lit = false
		stop_light_timer()


func _use_primary():
	print("Lit state before use_primary: ", is_lit)
	if is_lit == false:
		light()
	else:
		unlight()
		$Sounds/BlowOutSound.play()


func _item_state_changed(previous_state, current_state):
#	if previous_state == GlobalConsts.ItemState.EQUIPPED and current_state == GlobalConsts.ItemState.DROPPED:
#		unlight()
#		return
#	if previous_state == GlobalConsts.ItemState.EQUIPPED:  
#		unlight()
#		$Sounds/BlowOutSound.play()   # This is the messed one, all jacked with the sound etc
#	if previous_state == GlobalConsts.ItemState.EQUIPPED and current_state == GlobalConsts.ItemState.INVENTORY:
#		$Sounds/BlowOutSound.play()
#		unlight()
	pass


func _light_depleted():
	burn_time = 0
	unlight()
	is_depleted = true


func stop_light_timer():
	burn_time = light_timer.get_time_left()
	print("current burn time " + str(burn_time))
	light_timer.stop()


# Not working
func item_drop():
	stop_light_timer()
	burn_time -= (burn_time * life_percentage_lose)
	print("reduced burn time " + str(burn_time))
	random_number = rand_range(0.0, 1.0)
	
	light_timer.set_wait_time(burn_time)
	light_timer.start()
	
	if random_number < prob_going_out:
		unlight()
