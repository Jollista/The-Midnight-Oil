extends CharacterBody3D

# vars
@onready var animation = $AnimationPlayer # animation player used for 
@onready var grid_map = get_parent().get_node("GridMap") # GridMap keeps track of tiles

@export var player_index:Vector2 # player's location index in matrix
@export var player_direction:Vector2 = Vector2(0,-1) # player's direction, NSEW
var prev_player_index:Vector2
var facing_index = 0

var grid # 2d matrix of vector3 global positions

# Constant vectors used for tracking facing direction on grid
const NORTH = 0
const SOUTH = 2
const EAST = 1
const WEST = 3
const FACING = [Vector2(0,-1), Vector2(1,0), Vector2(0,1), Vector2(-1,0)]

# constant references to NSEW rotation vectors
const NORTH_ROTATION = Vector3(0,0,0)
const SOUTH_ROTATION = Vector3(0,90,0)
const EAST_ROTATION = Vector3(0,180,0)
const WEST_ROTATION = Vector3(0,270,0)

func _ready():
	# get grid from gridmap parent
	grid = grid_map.get_grid()
	
	print(grid)
	
	# make sure grid isn't empty
	if len(grid) == 0:
		print("EMPTY GRID")
	elif len(grid[0]) == 0:
		print("GRID MISSING COLUMNS")
	
	# set initial position
	var v3 = get_grid_position(player_index.x, player_index.y)
	set_global_position(v3)
	
	# face initial direction
	match player_direction:
		FACING[NORTH]:
			set_global_rotation_degrees(NORTH_ROTATION)
		FACING[SOUTH]:
			set_global_rotation_degrees(SOUTH_ROTATION)
		FACING[EAST]:
			set_global_rotation_degrees(EAST_ROTATION)
		FACING[WEST]:
			set_global_rotation_degrees(WEST_ROTATION)

# get the Vector3 position component from Vector4 from grid
func get_grid_position(x, y):
	var v4 = grid[x][y]
	return Vector3(v4.x, v4.y, v4.z)

# Get input and move accordingly, using animation players for choppy animation
func _physics_process(_delta):
	if Input.is_action_just_pressed("left"):
		animation.play("turn_left")
		update_facing(-1)
	if Input.is_action_just_pressed("right"):
		animation.play("turn_right")
		update_facing(1)
	if Input.is_action_just_pressed("forward"):
		print("forward input received")
		move(1)
	if Input.is_action_just_pressed("back"):
		print("backward input received")
		move(-1)

# update variables tracking the direction the player is facing
func update_facing(direction:int):
	facing_index += direction
	
	# bounds check
	if facing_index < 0:
		facing_index = len(FACING)-1
	elif facing_index >= len(FACING):
		facing_index = 0
	
	# update player direction
	player_direction = FACING[facing_index]

# Turn left (1) or right (-1) about the y axis by degrees
# Used by animation player to animate turning
func turn(direction:int, degrees:int):
	var deg_rotation = degrees*direction
	rotate_y(deg_to_rad(deg_rotation))

# Move forward (1) or back (-1)
func move(direction:int):
	# check if can move in direction
	if can_move(direction * player_direction):
		prev_player_index = player_index # set previous index to current
		player_index += direction * player_direction # set current to new
		
		# play move animation
		animation.play("move")
	else:
		print("can't move")
		print("player_index = ", player_index)
		print("player_direction = ", player_direction)

# check if the player can move in a given cardinal direction
func can_move(direction:Vector2):
	var desired_location = player_index + direction
	print("checking if can move")
	print("desired_location = player_index + direction")
	print(desired_location, " = ", player_index, " + ", direction)
	return grid_location_exists(desired_location) and grid_location_valid(desired_location)

# Check location vector is in bounds of potentially jagged array, grid
func grid_location_exists(location:Vector2):
	if location.x >= 0 and location.y >= 0:
		print("grid_location_exists = ", location.x < len(grid) and location.y < len(grid[location.x]))
		return location.x < len(grid) and location.y < len(grid[location.x])

# assume location exists, check if location is valid (node was visible)
func grid_location_valid(location:Vector2):
	print("location valid = ", true if grid[location.x][location.y].w > 0 else false)
	return true if grid[location.x][location.y].w > 0 else false

# Take a step, used for moving animation
# steps is the number of steps required to fully move from one position to
# the next, used to create a choppy walk animation
func step(steps:int):
	print("stepping")
	# calculate distance from starting position to desired position
	var from = get_grid_position(prev_player_index.x, prev_player_index.y)
	var to = get_grid_position(player_index.x, player_index.y)
	
	# divide into steps
	var distance = (from - to)/steps
	
	# move one step
	set_velocity(distance)
	move_and_slide()
