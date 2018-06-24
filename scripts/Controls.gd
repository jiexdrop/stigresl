extends RigidBody

var anim
var active

export(String, MULTILINE) var text

func _ready():
	anim = $AnimationPlayer
	active = false

func touch(player):
	if active:
		anim.play("touch", -1, -1.0, true)
	else:
		anim.play("touch", -1, 1.0, false)
	active = !active
	if text != null:
		player.set_text(text)