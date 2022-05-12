extends Node2D
const UDP_BROADCAST_FREQUENCY = 0.5

signal player_connected(id)
signal player_disconnected
signal update_players_list

var max_players = 4
var auto_broadcast = true

var server_code : String
var player_index : int

var broadcasting : bool=true
var players_connected : Array

var _broadcast_timer : float = 0
var udp_network=PacketPeerUDP.new()
var enet_network=ENetMultiplayerPeer.new()
var server_udp_port=7001
var server_enet_port=7000
func setup():
	_start_server()
	
	server_code = ""
	for _i in range(4):
		server_code += char(97 + (randi() % 25))

	players_connected = []
	set_accept_connections(true)
	set_process(true)
	
	if (auto_broadcast):
		start_broadcast()

func start_broadcast():
	broadcasting = true
	if not udp_network.is_bound():
		if udp_network.bind(server_udp_port) != OK:
			printt("Error bound on port: " + str(server_udp_port))
		else:
			printt("bound on port: " + str(server_udp_port))
		udp_network.set_broadcast_enabled(true)

func stop_broadcast():
	broadcasting = false
	udp_network.close()

func _start_server():
	var err = enet_network.create_server(server_enet_port, max_players)
	print("Create server status code: ", err)
	
	multiplayer.set_multiplayer_peer(enet_network)

#warning-ignore:unused_argument
func _process(delta: float) -> void:
	_broadcast_timer -= delta
	if broadcasting and _broadcast_timer <= 0:
		_broadcast_timer = UDP_BROADCAST_FREQUENCY
		#warning-ignore:return_value_discarded
		udp_network.set_dest_address("255.255.255.255", server_udp_port)
		var stg = server_code
		var pac = stg
		#warning-ignore:return_value_discarded
		udp_network.put_var(pac.to_ascii_buffer())

func set_accept_connections(is_accepting : bool):
	pass

func _player_connected(id):
	emit_signal("player_connected", id)
	players_connected.append(id)
	if players_connected.size() >= max_players - 1:
		set_accept_connections(false)
		if (auto_broadcast):
			stop_broadcast()
	emit_signal("update_players_list")

#warning-ignore:unused_argument
func _player_disconnected(id):
	emit_signal("player_disconnected")
	if (players_connected.has(id)):
		players_connected.erase(id)
		emit_signal("update_players_list")

func _ready() -> void:
	print("Ready1")
	setup()
#	set_process(false)

func _exit_tree() -> void:
	udp_network.close()
