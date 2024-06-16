extends CharacterBody2D

@export var movement_data : PlayerMovementData

var double_jump = false
var just_wall_jumped = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var was_wall_normal = Vector2.ZERO
@onready var sprite_2d = $Sprite2D
@onready var grace_jump_timer = $GraceJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer = $WallJumpTimer

func _physics_process(delta):
	#for moving left and right
	var direction = Input.get_axis("left","right")
	#for grace jump, also see just_left_ledge
	
	apply_gravity(delta)
	apply_wall_jump()
	apply_jump()
	apply_friction(direction,delta)
	apply_air_resistance(direction,delta)
	apply_acceleration(direction,delta)
	apply_air_acceleration(direction,delta)
	apply_flip(direction)
	move_and_slide()
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	
	#for grace jump
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		grace_jump_timer.start()
	just_wall_jumped= false
	var just_left_wall = was_on_wall and not is_on_wall()
	if just_left_wall:
		wall_jump_timer.start()

func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

func apply_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left<=0:
		return
	#to get which direction should character wall jump to 
	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left>0:
		wall_normal = was_wall_normal
	#jumping left after wall jump
	if Input.is_action_just_pressed("jump") :
		velocity.x = wall_normal.x * movement_data.SPEED
		velocity.y = movement_data.JUMP_VELOCITY
		just_wall_jumped = true
	#if Input.is_action_just_pressed("ui_right") and wall_normal == Vector2.RIGHT:
		#velocity.x = wall_normal.x * movement_data.SPEED
		#velocity.y = movement_data.JUMP_VELOCITY
func apply_jump():
	
	if is_on_floor():
		double_jump = true
	# Handle jump, grace jump, double jump
	if is_on_floor() or grace_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.JUMP_VELOCITY
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.JUMP_VELOCITY/2:
			velocity.y = movement_data.JUMP_VELOCITY/2
		# for double jump
		if Input.is_action_just_pressed("jump") and double_jump and not just_wall_jumped:
			velocity.y = movement_data.JUMP_VELOCITY*0.8
			double_jump = false

func apply_friction(direction,delta):
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, movement_data.FRICTION*delta)

func apply_air_resistance(direction,delta):
	if direction==0 and not is_on_floor():
		velocity.x = move_toward(velocity.x,0,movement_data.air_resistance*delta)

func apply_acceleration(direction,delta):
	if not is_on_floor():
		return
	if direction !=0:
		velocity.x = move_toward(velocity.x,movement_data.SPEED*direction,movement_data.ACCELERATION*delta)

func apply_air_acceleration(direction,delta):
	if not is_on_floor() and direction != 0:
		velocity.x = move_toward(velocity.x,movement_data.SPEED*direction,movement_data.air_acceleration*delta)

func apply_flip(direction):
	#flips character wrt direction
	if direction !=0:
		sprite_2d.flip_h = (direction>0)
		
func _on_hazard_detector_area_entered(area):
	global_position = starting_position
