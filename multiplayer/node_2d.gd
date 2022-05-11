extends Node2D

@export_range(10000,60000) var port=25000
@export var targetIP = "111.123.643"
@export var server:bool=true
var update_speed=0.05
var id=0


func create_server(host:bool):
#	targetIP=buildIP()
	if host:
		targetIP=IP.get_local_addresses()[3]
	else:
		targetIP=$HFlowContainer/IP.text
	var peer=ENetMultiplayerPeer.new()
	if host:
		multiplayer.peer_connected.connect(self.load_player)
		multiplayer.peer_disconnected.connect(self.remove_player)
		peer.create_server(port,32)
		print("Current IP is: %s"%targetIP)
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
	known_peers.erase(id)


func _on_button_2_pressed():
	server=false
	create_server(false)


func _on_button_pressed():
	server=true
	create_server(true)

var players={}




