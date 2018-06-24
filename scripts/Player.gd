extends KinematicBody

# http://docs.godotengine.org/en/3.0/tutorials/3d/fps_tutorial/part_one.html

export (String, FILE) var menu

const GRAVITY = -120
var vel = Vector3()
const MAX_SPEED = 30
const JUMP_SPEED = 60
const WAIT_TIME =  64
const READ_TIME =  0.02
var jump_speed = 60
const ACCEL= 4.4

var dir = Vector3()

const DEACCEL= 22
const MAX_SLOPE_ANGLE = 40

var camera
var rotation_helper
var ray
var over
var label
var timer

var global

var start_position

var MOUSE_SENSITIVITY = 0.05

const MAX_SPRINT_SPEED = 50
const SPRINT_ACCEL = 22
var is_sprinting = false



func _ready():
	camera = $Rotation_Helper/Camera
	ray = $Rotation_Helper/Ray_Cast
	over = $Over
	rotation_helper = $Rotation_Helper
	start_position = translation
	label = $Control/Label
	timer = $Timer
	
	global = get_node("/root/Global")
	
	$Control/VBoxContainer/Continue.connect("pressed", self, "button_pressed", ["continue"])
	$Control/VBoxContainer/Menu.connect("pressed", self, "button_pressed", ["menu"])
	$Control/VBoxContainer/Quit.connect("pressed", self, "button_pressed", ["quit"])
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	add_collision_exception_with($RigidBody)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_events(delta)

func process_input(delta):
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x = 1

	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = jump_speed
	# ----------------------------------
	jump_speed = JUMP_SPEED
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			$Control/VBoxContainer.set_visible(true)
	# ----------------------------------
	
	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	# ----------------------------------
	
	# ----------------------------------
	# Raycasting elements
	if Input.is_action_just_pressed("fire"):
		interact()
	# ----------------------------------

func button_pressed(button_name):
	if button_name == "continue":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		$Control/VBoxContainer.set_visible(false)
	elif button_name == "menu":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		global.goto_scene(menu)
	elif button_name == "quit":
		get_tree().quit()

func set_text(text):
	if text != label.text:
		timer.stop()
		label.set_text(text)
		label.visible_characters = 0
		timer.connect("timeout",self,"update_text") 
		timer.wait_time = 0.05
		timer.set_one_shot(false) 
		timer.start()

func update_text():
	label.visible_characters = label.visible_characters + 1
	if label.visible_characters > label.text.length()+WAIT_TIME:
		clear_text()

func clear_text():
	label.set_text("")
	timer.stop()

func interact():
	ray.force_raycast_update()

	if ray.is_colliding():
		var body = ray.get_collider()
		if body.has_method("touch"):
			body.touch(self)
			
func process_events(delta):

	if over.is_colliding():
		var event = over.get_collider()
		if event.has_method("over"):
			event.over(self)
			

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta*GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED


	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	
	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))



func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot