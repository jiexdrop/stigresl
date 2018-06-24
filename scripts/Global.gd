extends Node

var current_scene = null

var loader
var wait_frames
var time_max = 1000 # msec

var control
var progress_bar

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() -1)
	control = $Control
	progress_bar = $Control/ProgressBar
		
func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.

	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	# Load new scene.
	loader = ResourceLoader.load_interactive(path)
	if loader == null: # check for errors
		print("loader null")
		return

	set_process(true)
	# Free the old scene
	current_scene.queue_free()
	
	control.set_visible(true)
	$AnimationPlayer.play("load")
	wait_frames = 1

func _process(time):
	if loader == null:
		# no need to process anymore
		set_process(false)
		return

	if wait_frames > 0: # wait for frames to let the "loading" animation to show up
		wait_frames -= 1
		return
	
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max: # use "time_max" to control how much time we block this thread

		# poll your loader
		var err = loader.poll()

		if err == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			show_error()
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	# update progress bar
	progress_bar.max_value = loader.get_stage_count()
	progress_bar.value = progress
	
	var length = $AnimationPlayer.get_current_animation_length()

	# call this on a paused animation. use "true" as the second parameter to force the animation to update
	$AnimationPlayer.seek(progress * length, true)

func set_new_scene(scene_resource):
	control.set_visible(false)
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)