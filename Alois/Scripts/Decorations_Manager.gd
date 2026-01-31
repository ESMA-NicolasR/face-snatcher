extends Node
 
# Listes de meshes pour chaque type de distance
@export var meshes_far: Array[PackedScene] = []
@export var meshes_med: Array[PackedScene] = []
@export var meshes_close: Array[PackedScene] = []
 
# Vitesse de déplacement m/s (Max/Min) par catégorie
@export var vitesse_max_far: float = 1.25
@export var vitesse_min_far: float = 0.2
@export var vitesse_max_med: float = 1.5
@export var vitesse_min_med: float = 0.3
@export var vitesse_max_close: float = 1.75
@export var vitesse_min_close: float = 0.4
 
# Seuils de distance (Lointain)
@export var debut_ralentissement_far: float = 0.35
@export var fin_ralentissement_far: float = 0.85
@export var debut_acceleration_far: float = 0.85
@export var fin_acceleration_far: float = 1.0
 
# Seuils de distance (Medium)
@export var debut_ralentissement_med: float = 0.4
@export var fin_ralentissement_med: float = 0.85
@export var debut_acceleration_med: float = 0.85
@export var fin_acceleration_med: float = 1.0
 
# Seuils de distance (Proche)
@export var debut_ralentissement_close: float = 0.45
@export var fin_ralentissement_close: float = 0.85
@export var debut_acceleration_close: float = 0.85
@export var fin_acceleration_close: float = 1.0
 
# --- CONFIGURATION DES TIMERS (Ranges de temps en secondes) ---
@export_group("Timer Ranges Lointains")
@export var range_far_left_min: float = 3.0
@export var range_far_left_max: float = 6.0
@export var range_far_right_min: float = 3.0
@export var range_far_right_max: float = 6.0
 
@export_group("Timer Ranges Medium")
@export var range_med_left_min: float = 2.0
@export var range_med_left_max: float = 5.0
@export var range_med_right_min: float = 2.0
@export var range_med_right_max: float = 5.0
 
@export_group("Timer Ranges Proches")
@export var range_close_left_min: float = 1.5
@export var range_close_left_max: float = 4.0
@export var range_close_right_min: float = 1.5
@export var range_close_right_max: float = 4.0
 
# --- REFERENCES NOEUDS ---
@export_group("Chemins et Timers")
@export var path_Left_left: Path3D
@export var timer_LL: Timer
@export var path_Left_center: Path3D
@export var timer_LC: Timer
@export var path_Left_right: Path3D
@export var timer_LR: Timer
@export var path_Right_right: Path3D
@export var timer_RR: Timer
@export var path_Right_center: Path3D
@export var timer_RC: Timer
@export var path_Right_left: Path3D
@export var timer_RL: Timer
 
func execute_decoration_spawn(chemin_choisi: Path3D, type_distance: String, timer_concerne: Timer, t_min: float, t_max: float):
	# Sécurité si le chemin n'est pas assigné
	if chemin_choisi == null: return
 
	# Déterminer la liste de meshes à utiliser
	var liste_a_utiliser: Array[PackedScene] = []
	if type_distance == "far": liste_a_utiliser = meshes_far
	elif type_distance == "med": liste_a_utiliser = meshes_med
	elif type_distance == "close": liste_a_utiliser = meshes_close
 
	if liste_a_utiliser.size() == 0: return
 
	# Création suiveur de path et instance mesh
	var new_decoration = PathFollow3D.new()
	new_decoration.loop = false
	chemin_choisi.add_child(new_decoration)
	var new_mesh_decoration = liste_a_utiliser.pick_random().instantiate()
	new_decoration.add_child(new_mesh_decoration)
 
	# Relancer le timer avec un nouveau temps aléatoire dans sa range
	timer_concerne.wait_time = randf_range(t_min, t_max)
	timer_concerne.start()
 
func _process(delta: float) -> void:
	# Liste des chemins à traiter pour le défilement
	var chemins = [path_Left_left, path_Left_center, path_Left_right, path_Right_right, path_Right_center, path_Right_left]
 
	for p in chemins:
		if p == null: continue
 
		# Variables temporaires pour le calcul de vitesse par path
		var v_max: float; var v_min: float; var d_ral: float; var f_ral: float; var d_acc: float; var f_acc: float
 
		# Identifier le type de chemin pour appliquer les bonnes variables
		if p == path_Left_left or p == path_Right_right:
			v_max = vitesse_max_far; v_min = vitesse_min_far
			d_ral = debut_ralentissement_far; f_ral = fin_ralentissement_far
			d_acc = debut_acceleration_far; f_acc = fin_acceleration_far
		elif p == path_Left_center or p == path_Right_center:
			v_max = vitesse_max_med; v_min = vitesse_min_med
			d_ral = debut_ralentissement_med; f_ral = fin_ralentissement_med
			d_acc = debut_acceleration_med; f_acc = fin_acceleration_med
		else:
			v_max = vitesse_max_close; v_min = vitesse_min_close
			d_ral = debut_ralentissement_close; f_ral = fin_ralentissement_close
			d_acc = debut_acceleration_close; f_acc = fin_acceleration_close
 
		# Parcourir chaque décoration sur ce chemin spécifique
		for decorationPathFollow in p.get_children():
			if decorationPathFollow is PathFollow3D:
				var ratio = decorationPathFollow.progress_ratio
				var v_actuelle = v_max
 
				# Calcul de la vitesse selon les zones de distance définies
				if ratio > d_ral and ratio <= f_ral:
					# Zone de ralentissement progressif
					v_actuelle = remap(ratio, d_ral, f_ral, v_max, v_min)
				elif ratio > f_ral and ratio <= d_acc:
					# Zone de vitesse minimale constante
					v_actuelle = v_min
				elif ratio > d_acc and ratio <= f_acc:
					# Zone de réaccélération progressive
					v_actuelle = remap(ratio, d_acc, f_acc, v_min, v_max)
 
				# Appliquer le mouvement
				decorationPathFollow.progress += v_actuelle * delta
 
				# Supprimer la décoration s'il arrive au bout du path
				if decorationPathFollow.progress_ratio >= 0.99:
					decorationPathFollow.queue_free()
 
# --- CALLBACKS DES TIMERS ---
func _on_decoration_leftleft_timer_1_timeout() -> void:
	execute_decoration_spawn(path_Left_left, "far", timer_LL, range_far_left_min, range_far_left_max)
 
func _on_decoration_leftcenter_timer_2_timeout() -> void:
	execute_decoration_spawn(path_Left_center, "med", timer_LC, range_med_left_min, range_med_left_max)
 
func _on_decoration_leftright_timer_3_timeout() -> void:
	execute_decoration_spawn(path_Left_right, "close", timer_LR, range_close_left_min, range_close_left_max)
 
func _on_decoration_rightright_timer_4_timeout() -> void:
	execute_decoration_spawn(path_Right_right, "far", timer_RR, range_far_right_min, range_far_right_max)
 
func _on_decoration_rightcenter_timer_5_timeout() -> void:
	execute_decoration_spawn(path_Right_center, "med", timer_RC, range_med_right_min, range_med_right_max)
 
func _on_decoration_rightleft_timer_6_timeout() -> void:
	execute_decoration_spawn(path_Right_left, "close", timer_RL, range_close_right_min, range_close_right_max)
