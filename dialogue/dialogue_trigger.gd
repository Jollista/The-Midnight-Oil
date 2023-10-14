extends Area3D

# true if the player is inside the area2d's collision shape; else, false
var player_in_range = false
# reference to player, initialized when player enters area2d's collision shape
var player

# reference to dialogue_canvas in the scene
@onready var dialogue_canvas = get_parent().get_node("DialogueCanvas")
# list of dialogues this trigger can play
@export var dialogues:Array[String]
@export var stops:Array[String]

func _ready():
	# connect signal from dialogue_canvas, dialogue_ended, to trigger dialogue_over when received
	dialogue_canvas.dialogue_ended.connect(dialogue_over)
	dialogue_canvas.flag.connect(_flag_received)

# Choose dialogue to be played.
func choose_dialogue():
	# check bounds
	print("Length of dialogues arr: ", len(dialogues))
	if len(dialogues) == 0 and len(stops) == 0:
		queue_free()
		return "res://dialogue/JSONs/Nothing.json"
	elif len(stops) != 0:
		return stops[0]
	
	# if current dialogue to be played at dialogues isn't a filepath, but is instead
	# STOP, then pull from stops instead.
	if dialogues[0] == "STOP":
		return stops[0]
	else: # Else, pop_front from dialogues and return it.
		return dialogues.pop_front()

# On flag received, check to see if the flag_name matches the name of the currently stopped at
# dialogue. If it does, pop_front from stop and dialogues to pass stop
func _flag_received(flag_name):
	var current_stop_name = get_json_name(stops[0])
	if flag_name == current_stop_name:
		stops.pop_front()
		dialogues.pop_front()
		if len(dialogues) == 0 and len(stops) == 0:
			queue_free()

# get the name of a json file from filepath, e.g. 'Intro.json'
func get_json_name(filepath:String):
	var path_components = filepath.split("/")
	return path_components[len(path_components)-1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("interact"):
		trigger_dialogue()

# choose a dialogue and then have dialogue_canvas start it
func trigger_dialogue():
	# stop checking for input for starting dialogue
	set_process(false)
	
	# choose a dialogue
	var dialogue = choose_dialogue()
	print("chose dialogue : ", dialogue)
	
	# start it
	dialogue_canvas.start_dialogue(dialogue)

# called when signal received dialogue_ended
func dialogue_over():
	# start checking for input for starting dialogue again
	set_process(true)
	print("dialogue end signal received")


# keep track of player_in_range
func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player = body # save reference to player if needed

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
