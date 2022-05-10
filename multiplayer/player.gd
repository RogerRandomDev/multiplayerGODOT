extends Sprite2D


var move_to=Vector2.ZERO
var Speed=64
func _process(delta):
	if name!=str(multiplayer.get_unique_id()):
		position=(move_to-position)*(delta*10)+position
		return
	var speed=Vector2.ZERO
	if Input.is_key_pressed(KEY_W):
		speed.y-=delta
	if Input.is_key_pressed(KEY_A):
		speed.x-=delta
	if Input.is_key_pressed(KEY_S):
		speed.y+=delta
	if Input.is_key_pressed(KEY_D):
		speed.x+=delta
	position+=speed*Speed
	if !multiplayer.get_peers().has(1):return
	rpc_id(1,StringName("push_to_server"),position)



@rpc(any_peer,unreliable_ordered)
func push_to_server(pos):
	if !multiplayer.is_server():return
	if name!=str(multiplayer.get_remote_sender_id()):return
	move_to=pos
