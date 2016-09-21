extends Node2D

var RunCount = 0
var PlayerInfo = []

var RunCoeff  = 1
var RunDeltaX = 0

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	set_process_input(true)
	set_fixed_process(true)

func _player_connected(id):
	pass
func _player_disconnected(id):
	pass
func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id())
func _connected_fail():
	pass
func _server_disconnected():
	pass

remote func register_player(id):
	PlayerInfo.append(id)
	assert(get_tree().is_network_server())
	for peer in PlayerInfo:
		rpc_id(peer, "registered_player", PlayerInfo.size())

remote func registered_player(players):
	get_node("Players").set_text(players)

func _input(event):
	if (event.is_action("ui_roll_down")):
		PlayerForward(1 * RunCoeff)
	if (event.is_action("ui_roll_up")):
		PlayerForward(10 * RunCoeff)
		RunCoeff = RunCoeff * 0.7

func PlayerForward(Count):
	RunCount = RunCount + Count
	RunCoutn = RunCount * max(1, Clients * 0.7)

func _fixed_process(delta):
	