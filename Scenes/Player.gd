extends KinematicBody

const GRAVITY = -24.8
var GRAV = 0

var vel = Vector3()
const MAX_SPEED = 15
const JUMP_SPEED = 15
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 16
const MAX_SLOPE_ANGLE = 40

var MOUSE_SENSITIVITY = 0.05

var JOYPAD_SENSITIVITY = 3
const JOYPAD_DEADZONE = 0.2

const MAX_SPRINT_SPEED = 50
const SPRINT_ACCEL = 10
var is_sprinting = false
var is_crouched = false

var origin = global_transform.origin
var chunk_size = 32

var health = 50
var current_weapon_model = preload("res://Scenes/Weapon.tscn")

var camera
onready var FirstPersonCamera = get_node("Body/FirstPersonCamera")
#onready var ThirdPersonCamera = get_node("SpringArm/3rdPersonCamera")
var transform_person_1st
var transform_person_3rd

var gun = preload("res://Scenes/Weapon.tscn")
var gun_left = null
var gun_right = null
var space_state

func _ready():
	camera = FirstPersonCamera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print(health)

func _physics_process(delta):
	player_detect_coords(delta)
	process_input(delta)
	process_movement(delta)
	process_view_input(delta)
	player_detect_coords(delta)
	
	space_state = get_world().direct_space_state

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("move_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("move_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("move_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_movement_vector.x += 1

	# Add joypad input if one is present
	if Input.get_connected_joypads().size() > 0:

		var joypad_vec = Vector2(0, 0)

		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 0), -Input.get_joy_axis(0, 1))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))

		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		input_movement_vector += joypad_vec

	input_movement_vector = input_movement_vector.normalized()
#	if input_movement_vector != Vector2(0,0):
#		anim_Player.play("run")
#	else:
#		anim_Player.play("idle")

	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x

	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			vel.y = JUMP_SPEED
	
	if not is_on_floor():
#		anim_Player.play("air_jump")
		if Input.is_action_just_pressed("jump"):
			GRAV = GRAVITY

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Sprinting
	if Input.is_action_just_pressed("sprint"):
		# Sprint is toggled for testing, make sure to remap later
		if is_sprinting == false:
			is_sprinting = true
#		$AvatarMaleV2/RootNode/AnimationPlayer.play("Run")
			print("Sprint Toggled: ON")
		else:
			is_sprinting = false
			print("Sprint Toggled: OFF")
		
	# Crouching
	if Input.is_action_just_pressed("crouch"):
		if is_crouched == false:
			is_crouched = true
			# TODO: translate camera down
			# TODO: display hidden eye in the HUD
		else:
			is_crouched = false
			# TODO: undo crouch behaviors
#		print("crouch value is :", is_crouched)

	# Return to Origin
	if Input.is_action_just_pressed("return_origin"):
		global_transform.origin = get_parent().get_node(".").transform.origin
		
#	if Input.is_action_just_pressed("swap_perspective"):
#		if camera == FirstPersonCamera:
#			get_node("SpringArm/3rdPersonCamera").make_current()
#			camera = ThirdPersonCamera
##			if transform_person_3rd:
##				camera.rotation = transform_person_3rd
#		elif camera == ThirdPersonCamera:
##			transform_person_3rd = camera.rotation
#			get_node("Body/1stPersonCamera").make_current()
#			camera = FirstPersonCamera
##			camera.rotation = transform_person_1st

	# Draw the gun
	if Input.is_action_just_released("draw_weapons"):
		var weapon = gun.instance()
		weapon.set_ammo(6)
		weapon.transform.origin = $Body/ArmLeft/Position3D.transform.origin

	# Firing the gun
#	if gun_left or gun_right not null:
	
	if Input.is_action_just_pressed("fire_right"):
#		current_weapon_model.fire_weapon(space_state)
		# Invalid call. Nonexistent function 'fire_weapon' in base 'PackedScene'.
		print("fired right")

	if Input.is_action_just_pressed("fire_left"):
#		current_weapon_model.fire_weapon(space_state)
		# Invalid call. Nonexistent function 'fire_weapon' in base 'PackedScene'.
		print("fired left")

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAV

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

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func process_view_input(delta):

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	# NOTE: Until some bugs relating to captured mice are fixed, we cannot put the mouse view
	# rotation code here. Once the bug(s) are fixed, code for mouse view rotation code will go here!

	# Joypad rotation
	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() > 0:

		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))

		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		camera.rotate_x(deg2rad(joypad_vec.y * JOYPAD_SENSITIVITY))

		rotate_y(deg2rad(joypad_vec.x * JOYPAD_SENSITIVITY * -1))

		var camera_rot = camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -25, 90)
		camera.rotation_degrees = camera_rot

func _input(event):
	# Mouse Rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		
		camera.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -25, 90)
		camera.rotation_degrees = camera_rot


func player_detect_coords(delta):
	var player_translation = global_transform.translated(origin)
	var x_coord = player_translation[3].x / chunk_size
	var z_coord = player_translation[3].z / chunk_size
#	$HUD/Coordinates.text = "Coords: " + str(int(x_coord)) + ", " +str(int(z_coord))
	
func change_health(amount):
	health += amount
	print(health)
