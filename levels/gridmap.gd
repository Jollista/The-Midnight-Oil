extends GridMap

@export var grid_array : Array[Vector3]

# Return a duplicate of the grid
func get_grid():
	return grid_array.duplicate()
