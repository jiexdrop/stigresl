extends RigidBody

export(String, MULTILINE) var text
export(String, FILE) var scene

func _ready():
	pass

func over(player):
	if scene != null:
		get_tree().change_scene(scene)
	if text != null:
		player.set_text(text)
