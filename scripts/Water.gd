extends RigidBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var state

enum WATER_STATE{
	Solid,
	Liquid,
	Gas
}

var ice
var water
var steam

func _ready():
	ice = $Ice
	steam = $Ice
	water = $Water
	
	set_state(WATER_STATE.Liquid)

func set_state(s):
	state = s
	ice.set_visible(false)
	water.set_visible(false)
	steam.set_visible(false)
	match state:
		Solid:
			ice.set_visible(true)
		Liquid:
			water.set_visible(true)

func over(player):
	match state:
		Solid:
			pass
		Liquid:
			player.translation = player.start_position
	