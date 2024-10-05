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
var ancho_contrasena_lobby = 250
var alto_boton_lobby = 10

# UI y contrasena
@onready var contrasena_lobby: LineEdit = $"Hostear/ContraseñaLobby"
@onready var contrasena_texto: TextEdit = $"Hostear/Contraseña"
@onready var activar_contrasena: CheckBox = $"Hostear/ActivarContraseña"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_spawner.spawn_function = pasar_al_nivel
	
	# Esconder contrasenas
	contrasena_texto.hide()
	contrasena_lobby.hide()
	
	# Asociar crear lobby
	compa.lobby_created.connect(_on_lobby_created)
	
	# Asociar la lista de lobbys
	Steam.lobby_match_list.connect(_on_listar_lobbys)
	
	# LLamar a abrir listas al iniciar juego
	listar_lobbys()
	
	
# Boton de Host
func _on_hostear_pressed() -> void:
	compa.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = compa
	
	# Recoger la contraseña del input field
	var password = contrasena_lobby.text
	
	# Poner contrasena al lobby (vacia si no pone)
	Steam.setLobbyData(lobby_id, "password", password)
	
	# Cambiar de nivel
	multiplayer_spawner.spawn(nivel1)

	
	hostear.hide()
	lobbies.hide()
	refrescar_lista.hide()
	
# Unirse pal lobyy
func join_lobby(id, contrasena_lobby_lista):
	# 
	var password_lobby = Steam.getLobbyData(id, "password") or "" 
	var password = contrasena_lobby_lista.text

	# Imprime las contraseñas para debugging
	print("Password lobby: " + password_lobby)
	print("Password usuario: " + password)

	if password_lobby == password:
		# Si las contraseñas coinciden
		compa.connect_lobby(id)
		multiplayer.multiplayer_peer = compa
		lobby_id = id
	
		if multiplayer.has_multiplayer_peer():
			print("Conectado al peer correctamente")
		else:
			print("Error al conectar con el peer :(")

		# Ocultar botones al unirse
		hostear.hide()
		lobbies.hide()
		refrescar_lista.hide()
		
		print("Me uno al lobby con ID:", id)
		
		if multiplayer.is_server():
			print("Host: Conectado y cambiando de nivel con ID:", id)
			multiplayer_spawner.spawn(nivel1)
			rpc("pasar_al_nivel_cliente", nivel1)
		else:
			print("Cliente: Espero al host")
	else:
		print("Contraseña incorrecta bro")	
	
	
	
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
		

	
# Listar lobbys abiertas publicas
func listar_lobbys():
	# Mirar globalmente las lobbys, se puede cambiar a otras
	# LOBBY_DISTANCE_FILTER_PEPE
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_CLOSE)
	Steam.requestLobbyList()


func _on_listar_lobbys(lista_lobbies):
	for lobby in lista_lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var num_personas = Steam.getNumLobbyMembers(lobby)
		
		# Crear un HBoxContainer para mantener el boton y la contrasena alineados
		var hbox_lobby = HBoxContainer.new()
		
		# Crear boton para cada lobby
		var boton_lobby = Button.new()
		boton_lobby.set_text(str(lobby_name + " | Players: " + str(num_personas)))
		boton_lobby.set_size(Vector2(ancho_boton_lobby, alto_boton_lobby))
		
		# Ponerle input de contrasena a cada lobby mejol creo xd
		var contrasena_lobby_lista = LineEdit.new()
		contrasena_lobby_lista.set_size(Vector2(ancho_contrasena_lobby, alto_boton_lobby))
		contrasena_lobby_lista.placeholder_text = "password"
		
		# Conectar el boton al lobby actual (el que se pulse), y pasar contrasena
		boton_lobby.connect("pressed", Callable(self, "join_lobby").bind(lobby, contrasena_lobby_lista))
		
		# Anadir al Hbox el boton y contrasena
		hbox_lobby.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox_lobby.add_child(boton_lobby)
		hbox_lobby.add_child(contrasena_lobby_lista)
		
		lobbies.add_child(hbox_lobby)
		
		
# Remotely Callable 
# para que el cliente se conecte a la vez que el host al nivel
@rpc
func pasar_al_nivel_cliente(data):
	var instanscia_nivel = (load(data) as PackedScene).instantiate()
	get_tree().root.add_child(instanscia_nivel)
	get_tree().current_scene.queue_free()

# CheckBox para mostra contrasena lobby
func _on_activar_contraseña_toggled(toggled_on: bool) -> void:
	if toggled_on:
		contrasena_texto.show()
		contrasena_lobby.show()
		contrasena_lobby.grab_focus()
	elif not toggled_on:
		contrasena_texto.hide()
		contrasena_lobby.hide()
