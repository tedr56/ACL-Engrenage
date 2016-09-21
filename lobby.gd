
extends Control

const DEFAULT_PORT = 8910 # some random number, pick your port properly

# callback from SceneTree
func _player_connected(id):
	#someone connected, start the game!
	var runner = load("res://Runner.tscn").instance()
	runner.connect("game_finished",self,"_end_game",[],CONNECT_DEFERRED) # connect deferred so we can safely erase it from the callback
	
	get_tree().get_root().add_child(runner)
	hide()

#### Network callbacks from SceneTree ####
func _set_status(text,isok):
	#simple way to show status		
	if (isok):
		get_node("panel/status_ok").set_text(text)
		get_node("panel/status_fail").set_text("")
	else:
		get_node("panel/status_ok").set_text("")
		get_node("panel/status_fail").set_text(text)


func _on_host_pressed():
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT,100) # max: 1 peer, since it's a 2 players game
	if (err!=OK):
		#is another server running?
		_set_status("Can't host, address in use.",false)
		return
		
	get_tree().set_network_peer(host)
	get_node("panel/join").set_disabled(true)
	get_node("panel/host").set_disabled(true)
	_set_status("Waiting for player..",true)
	_player_connected(1)

func _on_join_pressed():
	
	var ip = get_node("panel/address").get_text()
	if (not ip.is_valid_ip_address()):
		_set_status("IP address is invalid",false)
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip,DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting..",true)

### INITIALIZER ####
	
func _ready():
	# connect all the callbacks related to networking
	get_tree().connect("network_peer_connected",self,"_player_connected")