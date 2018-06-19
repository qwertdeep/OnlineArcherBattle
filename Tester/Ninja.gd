extends Area2D
export (int) var SPEED  # how fast the player will move (pixels/sec)
export (bool) var active
export (bool) var nearby
var screensize  # size of the game window
onready var tie = get_node("../GUIlayer/GUI/dialogue-bubble/TextInterfaceEngine")
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	screensize = get_viewport_rect().size

	# Called every time the node is added to the scene.
	# Initialization here
	pass

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

func _nearby():
	if Input.is_action_just_pressed("ui_select"):
		print("select!!")
		tie.buff_clear()
		tie.buff_text("Arrrrgh! Aye bee the pairat! Wud ye laik te bee mee???", 0.05)
		tie.add_newline()
		tie.buff_text("y/n: ")
		tie.set_state(tie.STATE_OUTPUT)
		tie.buff_input()
		
func _on_input_enter(s):
	tie.buff_clear()
	tie.buff_text(s)
	tie.set_state(tie.STATE_OUTPUT)

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
	#else:
		#$AnimatedSprite.stop()
		#get_node("interrogation-point").hide()

	

#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.

func _on_Pirate_area_shape_entered(area_id, area, area_shape, self_shape):
	print('area shape entered')
	pass # replace with function body
