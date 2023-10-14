extends Node3D

@onready var dialogue_canvas = get_parent().get_node("DialogueCanvas")

func _ready():
	dialogue_canvas.flag.connect(_on_flag_received)
	set_deferred("visible", false)

func _on_flag_received(flagname):
	if flagname == "BetterHurryBack.json":
		set_deferred("visible", true)
