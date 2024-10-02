extends MultiplayerSpawner

# variable para
@export var playerScene : PackedScene

func _ready() -> void:
	spawn_function = spawnearPlayer
	
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.disconnect(deletePlayer)


var listaJugadores = {}

func spawnearPlayer(data):
	# si
	var escena = playerScene.instantiate()
	escena.set_multiplayer_authority(data)
	
	listaJugadores[data] = escena
	
	print("Spawneado jugador con ID: ", data)
	
	return escena
	
func deletePlayer(data):
	#
	listaJugadores[data].queue_free()
	listaJugadores.erase(data)
	
