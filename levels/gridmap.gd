extends GridMap

# Return a duplicate of the grid
func get_grid():
	var children = get_children()
	var grid = []
	for i in range(len(children)):
		print("getting columns")
		grid.append(get_child_positions(children[i]))
	print("grid with columns: ", grid)
	return grid

func get_child_positions(node):
	var children = node.get_children()
	var positions = []
	for i in range(len(children)):
		positions.append(children[i].get_global_position())
	print("columns: ", positions)
	return positions
