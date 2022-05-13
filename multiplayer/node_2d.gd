extends Node2D

var port=2049
var udp_port=2050
var targetIP=""
var udp=PacketPeerUDP.new()
var peer=ENetMultiplayerPeer.new()
var is_host="listenFor"

var reCheck=0.5;

var sendPacket=""

var connected=false
func _ready():
	sendPacket="MyServer".to_ascii_buffer()
	setup()


func host():
	
	udp.set_broadcast_enabled(true)
	peer.create_server(port,4)
	is_host="hostServer"
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
		targetIP=udp.get_packet_ip()
		print(targetIP)
		var packet=udp.get_packet().get_string_from_ascii()
		
	
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
	udp.bind(udp_port)
	


func print_peer(id):
	print(id)
