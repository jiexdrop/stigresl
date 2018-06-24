extends Control

export (String, FILE) var level

var global

func _ready():
	global = get_node("/root/Global")
	
	$Play.connect("pressed", self, "start_menu_button_pressed", ["play"])
	$Godot.connect("pressed", self, "start_menu_button_pressed", ["godot"])
	$Fullscreen.connect("pressed", self, "start_menu_button_pressed", ["fullscreen"])
	$Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])
	
func start_menu_button_pressed(button_name):
	if button_name == "play":
		global.goto_scene(level)
	elif button_name == "fullscreen":
		OS.window_fullscreen = !OS.window_fullscreen
	elif button_name == "godot":
		OS.shell_open("https://godotengine.org/")
	elif button_name == "quit":
		get_tree().quit()
