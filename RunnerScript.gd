extends Node2D

var RunCount = 0
var PlayerInfo = []

var RunCoeff  = 1
var RunDeltaX = 0

var DEFAULT_PORT = 10000
var DEFAULT_IP = "192.168.0.13"

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	set_process_input(true)
	set_fixed_process(true)

	get_node("Timer").start()
	get_node("Sprite").set_network_mode(RPC_MODE_SLAVE)

func _player_connected(id):
	pass
func _player_disconnected(id):
	pass
func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id())
func _connected_fail():
	pass
func _server_disconnected():
	rpc("unregister_player", get_tree().get_network_unique_id())

remote func register_player(id):
	print("New Player" , id)
	PlayerInfo.append(id)
	assert(get_tree().is_network_server())
	registered_player(PlayerInfo.size())
	for peer in PlayerInfo:
		rpc_id(peer, "registered_player", PlayerInfo.size())

remote func unregister_player(id):
	print("PlayerLeft" , id)
	PlayerInfo.remove(id)
	assert(get_tree().is_network_server())
	rpc_id(1 , "registered_player", PlayerInfo.size())
	for peer in PlayerInfo:
		rpc_id(peer, "registered_player", PlayerInfo.size())

sync func registered_player(players):
	get_node("Players").set_text(var2str(players))

var timeOut = true
	
func _input(event):
	var time = get_node("Timer")
	if (timeOut):
		if (event.is_action("ui_roll_down")):
			PlayerForward()
		if (event.is_action("ui_roll_up")):
			PlayerBoost()
		if (event.is_action("ui_accept")):
			TurnToClient()
		time.start()
		timeOut = false
	
	

var forward = 0
var boost = 0

remote func PlayerForward():
#	RunCount = RunCount + 0.5
#	RunCount = RunCount * max(1, PlayerInfo.size() * 0.7)
	forward = forward + 0.5

remote func PlayerBoost():	
#	RunCount = RunCount + 5
#	RunCount = RunCount * max(1, PlayerInfo.size() * 0.7)
#	RunCoeff  = RunCoeff * 0.5
	boost = boost + 1
	RunCoeff  = RunCoeff * 0.5 * max(1, PlayerInfo.size())

remote func _fixed_process(delta):
	var RunSprite = get_node("Sprite")
	var Count = (forward * 0.2 * max(1, RunCoeff*2)) + (boost * 30 * RunCoeff)
	RunSprite.translate(Vector2(Count, 0))
	#RunCount = max(0, RunCount - 1 )
	RunCoeff = min(1, RunCoeff + (0.001 / max(1, boost)))
	forward = max(0, forward - 1)
	boost = max(0, boost - 1.5)
	get_node("Coeff").set_text(var2str(RunCoeff))
	get_node("forward").set_text(var2str(forward))
	get_node("boost").set_text(var2str(boost))

func _on_Timer_timeout():
	timeOut = true
