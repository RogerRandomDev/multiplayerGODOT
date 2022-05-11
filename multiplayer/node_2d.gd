extends Node2D

@export_range(10000,60000) var port=25000
@export var targetIP = "111.123.643"
@export var server:bool=true
var update_speed=0.1
var id=0


func _ready():
	var t=Timer.new()
	add_child(t)
	t.wait_time=update_speed
	t.connect('timeout',update_objects)
	t.start()

func create_server(host:bool):
#	targetIP=buildIP()
	targetIP="localhost"
	
	var peer=ENetMultiplayerPeer.new()
	if host:
		multiplayer.peer_connected.connect(self.load_player)
		multiplayer.peer_disconnected.connect(self.remove_player)
		peer.create_server(port,32)
		
	else:
		peer.create_client(targetIP,port)
		
		
	multiplayer.set_multiplayer_peer(peer)
	id =multiplayer.get_unique_id()
	if host:load_player(1)
	$HFlowContainer.queue_free()
var known_peers=[]
func load_player(id2):
	known_peers.push_back(id2)
	for player in known_peers:
		if id2==id:continue
		rpc_id(id2,StringName("player_join"),player)
		if player==id:continue
		rpc_id(player,StringName("player_join"),id2)
	if server:
		create_player(id2)
	



@rpc(any_peer,reliable)
func player_join(id2):
	if get_node_or_null("Players/"+str(id2))!=null:return
	create_player(id2)
func create_player(id2):
	var player=preload("res://player.tscn").instantiate()
	player.name=str(id2)
	$Players.add_child(player)

func remove_player(id):
	get_node("Players/"+str(id)).queue_free()


func _on_button_2_pressed():
	server=false
	create_server(false)


func _on_button_pressed():
	server=true
	create_server(true)

var players={}

@rpc(any_peer,unreliable_ordered)
func update_peers(peer,data):
	
	for child in data:
		var add=get_node_or_null("Players/"+str(child))
		if add==null:continue
		
		add.move_to=data[child][0]


func update_objects():
	if !multiplayer.is_server():return
	print(players)
	for peer in players:
		if !known_peers.has(peer)||peer==id:continue
		rpc_id(peer,StringName("update_peers"),peer,players)



