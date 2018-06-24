extends RigidBody

export(String, MULTILINE) var text
export(String, FILE) var scene

var global

func _ready():
	global = get_node("/root/Global")

func over(player):
	if scene != null:
		global.goto_scene(scene)
	if text != null:
		player.set_text(text)
