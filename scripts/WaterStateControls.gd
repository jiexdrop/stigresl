extends RigidBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(String, MULTILINE) var text
 
var water
func _ready():
	water = get_node("../Water")

func touch(player):
	match water.state:
		water.WATER_STATE.Solid:
			water.set_state(water.WATER_STATE.Liquid)
		water.WATER_STATE.Liquid:
			water.set_state(water.WATER_STATE.Solid)
	if text != null:
		player.set_text(text)
	