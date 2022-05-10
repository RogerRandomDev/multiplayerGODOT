extends Node2D

@export_range(10000,60000) var port=25000
@export var targetIP = "localhost"
@export var server:bool=true

var id=0

func create_server(host:bool):
	var peer=ENetMultiplayerPeer.new()
	if host:
		multiplayer.peer_connected.connect(self.load_player)
		multiplayer.peer_disconnected.connect(self.remove_player)
		peer.create_server(port,32)
		
		print("made server")
	else:
		peer.create_client(targetIP,port)
		
		
	multiplayer.set_multiplayer_peer(peer)
	
		
var known_peers=[]
func load_player(id2):
	id=id2
	known_peers.push_back(id2)
	for player in known_peers:
		rpc_id(id2,StringName("player_join"),player)
		rpc_id(player,StringName("player_join"),id2)
	create_player(id2)



@rpc(any_peer,reliable)
func player_join(id2):
	create_player(id2)
func create_player(id2):
	var player=preload("res://player.tscn").instantiate()
	player.name=str(id2)
	add_child(player)

func remove_player(id):
	get_node(str(id)).queue_free()


func _on_button_2_pressed():
	create_server(false)


func _on_button_pressed():
	create_server(true)



@rpc(any_peer,unreliable_ordered)
func update_peers(peer,data):
	for child in data:
		get_node(str(child)).move_to=data[child]


func _process(delta):
	if !multiplayer.is_server():return
	var player_list={}
	for child in get_children():
		if typeof(str2var(child.name))==typeof(int(1)):
			player_list[str2var(child.name)]=child.position
	for peer in player_list:
		if !known_peers.has(peer):continue
		rpc_id(peer,StringName("update_peers"),peer,player_list)
	
