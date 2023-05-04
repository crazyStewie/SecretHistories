extends GenerationStep


export var door_dict : Dictionary
export var door_probability = 0.9

func _execute_step(data : WorldData, gen_data : Dictionary, generation_seed : int):
	var random = RandomNumberGenerator.new()
	random.seed = generation_seed
	var game_world = GameManager.game.level
	for cell in data.cell_count:
		for dir in data.Direction.size():
			var wall_tile = data.get_wall_tile_index(cell, dir)
			var door_scene = door_dict.get(wall_tile)
			if door_scene is PackedScene:
				var current_door = data.get_wall_door(cell, dir)
				if not is_instance_valid(current_door) and fposmod(random.randf(), 1.0) >= (1.0 - door_probability):
					var new_door = door_scene.instance() as Spatial
					var basis = Basis.IDENTITY
					var rotation_basis = Basis(Vector3.BACK, Vector3.UP, Vector3.LEFT)
					for i in dir:
						basis = rotation_basis*basis
					new_door.transform.basis = basis
					var cell_corner = data.get_local_cell_position(cell)
					var wall_type = data.get_wall_type(cell, dir)
					match wall_type:
						data.EdgeType.DOOR:
							new_door.transform.origin = cell_corner + (Vector3(1, 0, 1) - basis.z)*0.5*data.CELL_SIZE
							data.set_wall_door(cell, dir, new_door)
							game_world.add_child(new_door)
						data.EdgeType.HALFDOOR_N:
							match dir:
								data.Direction.NORTH:
									new_door.transform.origin = cell_corner
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.WEST), data.Direction.NORTH, new_door)
									game_world.add_child(new_door)
								
								data.Direction.EAST:
									new_door.transform.origin = cell_corner + Vector3.RIGHT*data.CELL_SIZE
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.NORTH), data.Direction.EAST, new_door)
									game_world.add_child(new_door)
								
								data.Direction.SOUTH:
									new_door.transform.origin = cell_corner + Vector3.BACK*data.CELL_SIZE
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.WEST), data.Direction.SOUTH, new_door)
									game_world.add_child(new_door)
								
								data.Direction.WEST:
									new_door.transform.origin = cell_corner
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.NORTH), data.Direction.WEST, new_door)
									game_world.add_child(new_door)
								
						data.EdgeType.HALFDOOR_P:
							match dir:
								data.Direction.NORTH:
									new_door.transform.origin = cell_corner + Vector3.RIGHT*data.CELL_SIZE
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.EAST), data.Direction.NORTH, new_door)
									game_world.add_child(new_door)
								
								data.Direction.EAST:
									new_door.transform.origin = cell_corner + (Vector3.RIGHT + Vector3.BACK)*data.CELL_SIZE
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.SOUTH), data.Direction.EAST, new_door)
									game_world.add_child(new_door)
								
								data.Direction.SOUTH:
									new_door.transform.origin = cell_corner + (Vector3.RIGHT + Vector3.BACK)*data.CELL_SIZE
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.EAST), data.Direction.SOUTH, new_door)
									game_world.add_child(new_door)
								
								data.Direction.WEST:
									new_door.transform.origin = cell_corner + Vector3.BACK*data.CELL_SIZE
									data.set_wall_door(cell, dir, new_door)
									data.set_wall_door(data.get_neighbour_cell(cell, data.Direction.SOUTH), data.Direction.WEST, new_door)
									game_world.add_child(new_door)
			pass
