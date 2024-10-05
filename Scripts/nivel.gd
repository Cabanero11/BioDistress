extends Node

@onready var chat_box: TextEdit = $ChatBox
@onready var chat_input: LineEdit = $ChatBox/ChatInput

# Variable para controlar si el chat está visible
var chat_visible = false

func _ready() -> void:
	chat_box.hide()
	chat_input.hide()


func _process(_delta: float) -> void:
	# Si se presiona la tecla T o Enter
	if Input.is_action_just_pressed("text_ui_toggle") and not chat_input.has_focus(): 
		togglear_chat()

	# Si se presiona Enter (ui_accept) mientras el input tiene foco, enviar el mensaje
	if Input.is_action_just_pressed("ui_accept") and chat_input.has_focus():
		_on_chat_input_text_submitted(chat_input.text)

# Cuando pulsa ENTER
func _on_chat_input_text_submitted(new_text: String) -> void:
	# No vacio pls
	if new_text.strip_edges() == "":
		return
	
	# Poner en el chat Nombre: msg
	chat_box.text += str("[" + Steam.getPersonaName() + "]" + ": " + new_text + "\n")
	
	# Enviar el mensaje a otros jugadores (RPC)
	rpc("recibir_mensaje", Steam.getPersonaName(), new_text)
	
	# no msg tras mandar :8
	chat_input.clear()
	
	esperar_y_toglear_chat()
	
	
# Eso
func esperar_y_toglear_chat():
	await get_tree().create_timer(3.0).timeout
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
		chat_input.release_focus()
