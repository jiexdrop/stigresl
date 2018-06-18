extends Control

export (String, FILE) var level

func _ready():
	$Play.connect("pressed", self, "start_menu_button_pressed", ["play"])
	$Godot.connect("pressed", self, "start_menu_button_pressed", ["godot"])
	$Fullscreen.connect("pressed", self, "start_menu_button_pressed", ["fullscreen"])
	$Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])
	
func start_menu_button_pressed(button_name):
	if button_name == "play":
		get_tree().change_scene(level)
	elif button_name == "fullscreen":
		OS.window_fullscreen = !OS.window_fullscreen
	elif button_name == "godot":
		OS.shell_open("https://godotengine.org/")
	elif button_name == "quit":
		get_tree().quit()
