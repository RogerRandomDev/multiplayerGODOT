extends Node2D
signal update_servers_list
signal connection_ok
signal connection_error
signal disconnected

var server_codes : Dictionary
var server_ip : String
var udp_network=PacketPeerUDP.new()
var enet_network=ENetMultiplayerPeer.new()
var server_udp_port=7001
var server_enet_port=7000
func setup() -> void:

	server_codes = {}

	enet_network.set_target_peer(ENetMultiplayerPeer.TARGET_PEER_SERVER)
	set_process(true)
	_start_client()

func connect_to_server_code(code : String) -> bool :
	if (server_codes.has(code)):
		server_ip = server_codes[code]
		_start_enet_client()
		return true
	return false

func _start_enet_client():
	udp_network.close()
	set_process(false)
# warning-ignore:return_value_discarded
	enet_network.create_client(server_ip, server_enet_port)
	multiplayer.set_multiplayer_peer(enet_network)

func _start_client():
	
	if udp_network.bind(server_udp_port) != OK:
		printt("Error bound on port: " + str(server_udp_port))
	else:
		printt("bound on port: " + str(server_udp_port))

# warning-ignore:unused_argument
func _process(delta: float) -> void:
	if udp_network.get_available_packet_count() > 0 and server_ip=="":
		var array_bytes = udp_network.get_packet()
		var server_code = array_bytes.get_string_from_ascii()
		if not server_codes.has(server_code):
			server_codes[server_code] = udp_network.get_packet_ip()
			emit_signal("update_servers_list")
			printt("Received server code: ", server_code)
			connect_to_server_code(server_code)

# TODO: Lifetime for server codes

func _connected_ok():
	emit_signal("connection_ok")

func _connected_fail():
	emit_signal("connection_error")

func _server_disconnected():
	emit_signal("disconnected")

func _ready() -> void:
	setup()
func _exit_tree() -> void:
	udp_network.close()
