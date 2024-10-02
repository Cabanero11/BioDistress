extends Node


func _ready() -> void:
	# AVISO!!
	# 480 es temporal, tras tener una se cambia 
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	
	# Inicializar el SDK, 0 es OK
	Steam.steamInitEx()



func _process(_delta: float) -> void:
	Steam.run_callbacks()
