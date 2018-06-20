
extends KinematicBody2D
export (int) var SPEED  # how fast the player will move (pixels/sec)
export (bool) var active
export (bool) var nearby
var screensize  # size of the game window
#onready var tie = get_node("../GUIlayer/GUI/dialogue-bubble/TextInterfaceEngine")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"
const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var shoot_time=99999 #time since last shot

var anim=""

#cache the sprite

func _ready():
	screensize = get_viewport_rect().size

	# Called every time the node is added to the scene.
	# Initialization here
	pass
#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $AnimatedSprite

func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta

	### MOVEMENT ###

	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		$sound_jump.play()

	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if shoot_time < SHOOT_TIME_SHOW_WEAPON:
		new_anim += "_weapon"

	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)


func _handleinput(delta):
	$AnimatedSprite.play()
	var velocity = Vector2() # the player's movement vector
	if Input.is_action_pressed("ui_right"):
	   	velocity.x += 1
	if Input.is_action_pressed("ui_left"):
	   	velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
	   	velocity.y += 1
	if Input.is_action_pressed("ui_up"):
       	velocity.y -= 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * SPEED
		$AnimatedSprite.animation = "run"
	if Input.is_action_pressed("ui_attack"):
		$AnimatedSprite.animation = "attack1"
	else:
       	$AnimatedSprite.animation = "idle"
	position += velocity * delta
    #position.x = clamp(position.x, 0, screensize.x)
    #position.y = clamp(position.y, 0, screensize.y)
	if velocity.x != 0:
	   	$AnimatedSprite.animation = "run"
	   	$AnimatedSprite.flip_v = false
	   	$AnimatedSprite.flip_h = velocity.x < 0
	if Input.is_action_just_pressed("ui_click"):
		print(self.position)
		print('player click')

func _handle_collision(oldpos):
	#if $CollisionShape2D.body
	pass	



func _process(delta):
	if nearby and Input.is_action_just_pressed("ui_select"):
		#get_node("interrogation-point").hide()
		_nearby()
	elif nearby:
		pass
	if active:
		#get_node("interrogation-point").hide()
		$Camera.make_current()
		var oldpos = self.position
		_handleinput(delta)
		_handle_collision(oldpos)
	else:
		active = true
		#$AnimatedSprite.stop()
		#get_node("interrogation-point").hide()

	

#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

func _on_Pirate_area_shape_entered(area_id, area, area_shape, self_shape):
	print('area shape entered')
	pass # replace with function body
