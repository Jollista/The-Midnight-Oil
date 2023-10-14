extends Node3D

@onready var dialogue_canvas = $DialogueCanvas

func _ready():
	dialogue_canvas.flag.connect(_flag_received)

func _flag_received(flag_name):
	print("Flag \"", flag_name, "\" received")
