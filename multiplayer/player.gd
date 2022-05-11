extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var move_to=Vector2.ZERO
func _physics_process(delta):
	if name!=str(multiplayer.get_unique_id()):
		position=move_to
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	var updateData=[name,[position,rotation]]
	rpc(StringName("push_to_server"),updateData[0],updateData[1])



@rpc(any_peer,unreliable_ordered)
func push_to_server(peer,pos):
	if str(get_parent().get_parent().id)==peer:return
	move_to=pos[0]
	
