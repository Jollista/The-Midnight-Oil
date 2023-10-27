extends CanvasLayer

signal flag(flag_name:String)

# path to default dialogue file json (should never play)
@export var dialogue_file = ""

const FAST = 0.010
const NORM = 0.025
const SLOW = 0.1

# text speed
@export var text_speed = NORM

# reference to components
@onready var dialogue_box = $DialogueBox
#@onready var display_name = $TextLabels/Name
@onready var chat = $TextLabels/Text
@onready var image = $Image
@onready var voice = $Voice
@onready var sfx = $SFX
@onready var timer = $Delay

signal dialogue_ended

# array of lines
var dialogue = []
# index of current line
var current_dialogue = 0
# is dialogue active
var active = false
# is current line finished displaying
var finished = true
# skip line if blackout_screen()
var skipping = false
# reset sprites to default (HEAD_SMILE, BODY_RELAX) on dialogue end if reset_sprites
# else, don't
var reset_sprites = true
# mute voice if muted
var muted = false
# used to mute music player on voice muted
signal muted_voice

func _ready():
	# set invisible by default
	visible = false

func _process(_delta):
	# allows player to skip dialogue animation
	if skipping or active and (Input.is_action_just_pressed("interact")):
		if finished: # go to next line
			next_line()
			skipping = false
		else: # skip dialogue animation and stop sounds
			chat.visible_characters = len(chat.text)
			voice.stop()

func start_dialogue(filepath:String=""):
	print("dialogue filepath : ", filepath)
	# if given filepath, load that instead of default
	if filepath != "" and filepath != null:
		dialogue_file = filepath
		print("dialogue_file : ", dialogue_file)
	
	# load dialogue
	dialogue = load_dialogue()
	
	# initial yield before it matters bc that one messes with 
	# chat.visible_characters for some reason
	print("initial timer check")
	timer.set_wait_time(text_speed)
	timer.start()
	await timer.timeout
	print("initial timer check works")
	
	# reset index and set visible/active true
	current_dialogue = 0
	active = true
	set_visible(active)
	
	# pause game
	pause()
	
	# update text
	next_line()

# load and parse dialogue from JSON file
func load_dialogue():
	print("\nLOADING DIALOGUE")
	if FileAccess.file_exists(dialogue_file):
		print("DIALOGUE EXISTS, OPENING")
		var file = FileAccess.open(dialogue_file, FileAccess.READ)
		var json = JSON.new()
		if OK == json.parse(file.get_as_text()): 
			print("AS TEXT:\n", file.get_as_text())
			print(json, " : ", json.get_data())
			return json.get_data()
		else:
			print("ERROR PARSING JSON : ", json.parse(file.get_as_text()))

func next_line():
	# update vars
	finished = false
	
	# if index is out of bounds, end dialogue
	if current_dialogue >= len(dialogue):
		end_dialogue()
		return
	# check index oob again just in case cause awaits make things a lil' wonky
	if (current_dialogue >= len(dialogue)):
		return
	
	# update text, works with bbcode
	chat.text = dialogue[current_dialogue]["Text"]
	
	# Update portrait if specified
	if dialogue[current_dialogue].has("Image"):
		var img = "res://dialogue/images/" + dialogue[current_dialogue]["Image"]
		#if FileAccess.file_exists(img): # if specified image exists
		image.texture = load(img) # set it to specified image
		#else: # no default image
		#	image.texture = null # set portrait to null
	else:
		image.texture = null # by default, no image
	
	# Play sound effect if specified
	if dialogue[current_dialogue].has("SFX"):
		var effect = "res://sound/effects/" + dialogue[current_dialogue]["SFX"]
		# if file exists
		#if FileAccess.file_exists(effect):
			# load and play it
		sfx.set_stream(load(effect))
		sfx.play()
	
	# change speed of text progression if needed
	if dialogue[current_dialogue].has("Speed"):
		match dialogue[current_dialogue]["Speed"]:
			"slow":
				timer.set_wait_time(SLOW)
			"fast":
				timer.set_wait_time(FAST)
			_:
				timer.set_wait_time(NORM)
	
	# get voice
	# if mute, short circuit
	if dialogue[current_dialogue].has("Voice"):
		match dialogue[current_dialogue]["Voice"]:
			"mute":
				muted = true
			_:
				var voice_sound = "res://sound/voices/" + dialogue[current_dialogue]["Voice"]
				#if FileAccess.file_exists(voice_sound):
				var stream = AudioStreamRandomizer.new() # create AudioStreamRandomizer
				stream.add_stream(0, load(voice_sound)) # set its stream to character's voice
				voice.set_stream(stream) # set randomizer as voice's stream
	
	if dialogue[current_dialogue].has("Signal"):
		flag.emit(dialogue[current_dialogue]["Signal"])
	
	# increment index
	current_dialogue += 1
	
	# clear textbox
	chat.visible_characters = 0
	
	# write phrase
	print("chat.text = ", chat.text)
	while chat.visible_characters < len(chat.text):
		
		#print("visible-ifying character")
		#print("visible characters = ", chat.visible_characters, "\nout of = ", len(chat.text))
		chat.visible_characters += 1 # make next char visible
		
		# pause for punctuation
		#print("punctuation juice")
		match chat.text.substr(chat.visible_characters-1, 1):
			".":
				timer.start(text_speed*10)
				await timer.timeout
			"?":
				timer.start(text_speed*10)
				await timer.timeout
			",": 
				timer.start(text_speed*6)
				await timer.timeout
		
		#print("resetting timer speed")
		timer.set_wait_time(text_speed)
		
		#print("voice check")
		if not muted:# and not voice.playing:
			voice.play() # play funny little sound hahaha make me laugh
		
		# delay between characters made visible
		#print("text-speed")
		timer.start(text_speed)
		await timer.timeout # delay while loop until timeout
		#print("finished waiting, next character\n")
	
	finished = true
	
	# restore text_speed
	timer.set_wait_time(text_speed)
	# unmute voice
	muted = false
	
	return

# end current dialogue
func end_dialogue():
	# print for debug
	print("ending dialogue")
	
	# reset variables
	active = false
	set_visible(active)
	current_dialogue = 0
	
	# unpause game
	unpause()
	# emit signal
	dialogue_ended.emit()

func unpause():
	# unpause game
	get_tree().set_deferred("paused", false)

func pause():
	# pause game
	get_tree().set_deferred("paused", true)
