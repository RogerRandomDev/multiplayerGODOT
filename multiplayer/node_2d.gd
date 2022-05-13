extends Node2D

var port=12049
var udp_port=12050
var udp := PacketPeerUDP.new()
var connected = false
var server := UDPServer.new()
var peers = []



func host(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer : PacketPeerUDP = server.take_connection()
		var pkt = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [pkt.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet(pkt)
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)

	for i in range(0, peers.size()):
		pass # Do something with the connected peers.


func client(delta):
	if !connected:
		# Try to contact server
		udp.put_packet("The answer is... 42!".to_ascii_buffer())
	if udp.get_available_packet_count() > 0:
		print("Connected: %s" % udp.get_packet().get_string_from_ascii())
		connected = true

var cur_load="nulll"
func nulll(delta):pass
func _on_button_pressed():
	server.listen(4242)
	cur_load="host"


func _on_button_2_pressed():
	cur_load="client"
	udp.connect_to_host("255.255.255.255", 4242)


func _process(delta):
	call(cur_load,delta)

