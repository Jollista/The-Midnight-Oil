extends Node3D

@onready var dialogue_canvas = $DialogueCanvas

func _ready():
	dialogue_canvas.flag.connect(_flag_received)

func _flag_received(flag_name):
	if flag_name == "ENDING_REACHED":
		get_tree().change_scene_to_file("res://levels/endscreen.tscn")
