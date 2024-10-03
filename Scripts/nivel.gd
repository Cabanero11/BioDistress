extends Node

@onready var chat_box: TextEdit = $ChatBox
@onready var chat_input: LineEdit = $ChatBox/ChatInput

# Variable para controlar si el chat está visible
var chat_visible = false

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	# Si se presiona la tecla T o Enter
	if Input.is_action_just_pressed("text_ui_toggle"): 
		togglear_chat()


# Cuando pulsa ENTER
func _on_chat_input_text_submitted(new_text: String) -> void:
	# Poner en el chat Nombre: msg
	chat_box.text += str("[" + Steam.getPersonaName() + "]" + ": " + new_text + "\n")
	
	# Enviar el mensaje a otros jugadores (RPC)
	rpc("recibir_mensaje", Steam.getPersonaName(), new_text)
	
	# no msg tras mandar :8
	chat_input.clear()
	
	# Ocultar el chat después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	togglear_chat()

# Función remota para recibir mensajes de otros jugadores
@rpc
func recibir_mensaje(persona_name: String, msg: String) -> void:
	chat_box.text += str(persona_name + ": " + msg + "\n")


func _on_multiplayer_spawner_spawned(_node: Node) -> void:
	chat_box.text += str("[INFO] " + Steam.getPersonaName() + ": has joined the game. \n")


func togglear_chat():
	chat_visible = not chat_visible
	
	if chat_visible:
		chat_box.show()
		chat_input.show()
		# Pillar focus y que escriba
		chat_input.grab_focus() 
	else:
		chat_box.hide()
		chat_input.hide()
