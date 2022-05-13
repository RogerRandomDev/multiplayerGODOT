extends Node2D

var port=12049
var udp_port=12050
var targetIP=""
var udp=PacketPeerUDP.new()
var peer=ENetMultiplayerPeer.new()
var is_host="listenFor"

var reCheck=0.5;

var sendPacket=""

var connected=false
func _ready():
	
	setup()


func host():
	var targetIP=IP.get_local_addresses()[7]
	udp.set_broadcast_enabled(true)
	peer.set_bind_ip(targetIP)
	peer.create_server(port,16)
	is_host="hostServer"
	sendPacket=targetIP.to_ascii_buffer()
	multiplayer.set_multiplayer_peer(peer)
	peer.connect("peer_connected",print_peer)
	


func update_connection():
	$Map/Label.text="connected"

func connectServer(ip="",pack=""):
	peer.connect("connection_succeeded",update_connection)
	ip=targetIP
	var connecting=peer.create_client(ip,port)
	multiplayer.set_multiplayer_peer(peer)
	connected=true
	is_host="asClient"




func _process(delta):
	call(is_host,delta)

func listenFor(delta):
	if udp.get_available_packet_count()>0:
		
		var packet=udp.get_packet().get_string_from_ascii()
		print(packet)
		targetIP=packet
	
func hostServer(delta):
	reCheck-=delta
	if reCheck>0.0:return
	reCheck=0.5;
	udp.set_dest_address('255.255.255.255',udp_port)
	
	udp.put_packet(sendPacket)
func asClient(delta):
	pass


func setup() -> void:
	peer.set_target_peer(ENetMultiplayerPeer.TARGET_PEER_SERVER)
	if udp.bind(udp_port)!=OK:print("failed connection")


func print_peer(id):
	print(id)
