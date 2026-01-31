extends Node
 
# Multiplicateur de vitesse maximum
@export var vitesse_max_jeu: float = 16.0
# Valeur de l'augmentation à chaque palier
@export var increment_vitesse: float = 0.5
# Temps en secondes entre chaque augmentation
@export var intervalle_temps: float = 15.0
 
# Variable pour suivre le temps total écoulé (réel)
var temps_total: float = 0.0
# Variable pour savoir combien de paliers ont déjà été passés
var paliers_atteints: int = 0
 
func _process(_delta: float) -> void:
	# On suit le temps écoulé de manière réelle (indépendant du Time Scale)
	# get_process_delta_time() ne s'accélère pas quand le jeu s'accélère
	temps_total += get_process_delta_time()
	
	# Calculer combien de paliers de 15 secondes se sont écoulés
	var paliers_actuels = floor(temps_total / intervalle_temps)
	
	# Si on vient de franchir un nouveau palier
	if paliers_actuels > paliers_atteints:
		paliers_atteints = paliers_actuels
		
		# Calcul de la nouvelle vitesse : Base (1.0) + (Nombre de paliers * 0.5)
		var nouvelle_vitesse = 1.0 + (paliers_atteints * increment_vitesse)
		
		# Appliquer la vitesse au moteur avec la limite max
		Engine.time_scale = min(nouvelle_vitesse, vitesse_max_jeu)
		
		# Debug pour suivre l'évolution
		print("Palier franchi ! Nouvelle vitesse : x", Engine.time_scale)
