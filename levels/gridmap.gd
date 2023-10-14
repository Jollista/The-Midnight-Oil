extends GridMap

# Return a duplicate of the grid
func get_grid():
	var children = get_children()
	var grid = []
	for i in range(len(children)):
		#print("getting columns")
		grid.append(get_child_positions(children[i]))
	#print("grid with columns: ", grid)
	return grid

# get the positions of child nodes, as well as their visibility
# visibility is used as 4th dimension of Vector4 to determine if the given node
# can be occupied or not
func get_child_positions(node):
	# get children and initialize array of positions
	var children = node.get_children()
	var positions = []
	
	# for each element of children, append a new Vector4(global_position(x,y,z), visibility)
	# to positions
	for i in range(len(children)):
		var v3 = children[i].get_global_position()
		positions.append(Vector4(v3.x, v3.y, v3.z, float(children[i].visible)))
	#print("columns: ", positions)
	return positions
