extends Node2D


var lobby_id = 0
# Peer 2 Peer 
var compa = SteamMultiplayerPeer.new()
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var hostear: Button = $Hostear
@onready var refrescar_lista: Button = $RefrescarLista


var nivel1 = "res://Scenes/nivel.tscn"

@onready var lobbies: VBoxContainer = $ListaLobbys/Lobbies
var ancho_boton_lobby = 300
var alto_boton_lobby = 10



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_spawner.spawn_function = pasar_al_nivel
	
	# Asociar crear lobby
	compa.lobby_created.connect(_on_lobby_created)
	
	# Asociar la lista de lobbys
	Steam.lobby_match_list.connect(_on_listar_lobbys)
	
	# LLamar a abrir listas al iniciar juego
	listar_lobbys()
	
	
	
func _on_hostear_pressed() -> void:
	compa.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = compa
	
	multiplayer_spawner.spawn(nivel1)
	
	# Envía una señal a todos los clientes para que también cambien de nivel
	rpc("pasar_al_nivel_cliente", nivel1)
	
	hostear.hide()
	lobbies.hide()
	refrescar_lista.hide()
	
# Borrar lista antigua
func _on_refrescar_lista_pressed() -> void:
	if lobbies.get_child_count() > 0:
		for lobby in lobbies.get_children():
			lobby.queue_free()
	# Tras borrar antiguas, mostrar nuevas
	listar_lobbys()
	
	
func pasar_al_nivel(data):
	var instancia_nivel = (load(data) as PackedScene).instantiate()
	return instancia_nivel
	
# Al crearse la lobyy, STEAM ABIERTO XD
func _on_lobby_created(connect_status, id):
	if connect_status:
		lobby_id = id
		Steam.setLobbyData(lobby_id, "name", str(Steam.getPersonaName() + "'s Lobby."))
		Steam.setLobbyJoinable(lobby_id, true)
		
		print("Lobby id = " + str(lobby_id))
		
# Unirse pal lobyy	
func join_lobby(id):
	# Pal lobby te vas
	compa.connect_lobby(id)
	multiplayer.multiplayer_peer = compa
	lobby_id = id
	
	# Ocultar botones
	hostear.hide()
	lobbies.hide()
	refrescar_lista.hide()
	
	print("Me uno al lobby con ID:", id)
	
	# Comprobar que tienes el peer configurado y que tienes autoridad
	if multiplayer.has_multiplayer_peer() and multiplayer.is_multiplayer_authority():
		multiplayer_spawner.spawn(nivel1)
		print("Conectado y cambiando de nivel con ID:", id)
	else:
		print("Error: No tienes autoridad o el peer no está configurado")
	
	
# Listar lobbys abiertas publicas
func listar_lobbys():
	# Mirar globalmente las lobbys, se puede cambiar a cerquita
	# LOBBY_DISTANCE_FILTER_CLOSE
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_CLOSE)
	Steam.requestLobbyList()

func _on_listar_lobbys(lista_lobbies):
	for lobby in lista_lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var num_personas = Steam.getNumLobbyMembers(lobby)
		# Crear boton para cada lobby
		var boton_lobby = Button.new()
		boton_lobby.set_text(str(lobby_name + " | Players: " + str(num_personas)))
		boton_lobby.set_size(Vector2(ancho_boton_lobby, alto_boton_lobby))
		# Conectar el boton al lobby actual (el que se pulse)
		boton_lobby.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		lobbies.add_child(boton_lobby)
	
	
	
func pasar_al_nivel_cliente(data):
	var instanscia_nivel = (load(data) as PackedScene).instantiate()
	get_tree().root.add_child(instanscia_nivel)
	get_tree().current_scene.queue_free()
