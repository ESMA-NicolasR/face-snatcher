extends Node
 
@export var vitesse_max_jeu: float = 16.0
@export var increment_vitesse: float = 0.5
@export var intervalle_temps: float = 15.0
 
var temps_total: float = 0.0
var paliers_atteints: int = 0
 
func _ready() -> void:
	# RESET CRUCIAL : On remet le moteur à vitesse normale au chargement
	Engine.time_scale = 1.0
	temps_total = 0.0
	paliers_atteints = 0
	print("Vitesse réinitialisée à x1.0")
 
func _process(_delta: float) -> void:
	temps_total += get_process_delta_time()
	var paliers_actuels = floor(temps_total / intervalle_temps)
 
	if paliers_actuels > paliers_atteints:
		paliers_atteints = paliers_actuels
		var nouvelle_vitesse = 1.0 + (paliers_atteints * increment_vitesse)
		Engine.time_scale = min(nouvelle_vitesse, vitesse_max_jeu)
		
		print("Palier franchi ! Nouvelle vitesse : x", Engine.time_scale)
