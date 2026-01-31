extends Node
 
# Listes de meshes pour chaque type de distance (à remplir dans l'inspecteur)
@export var meshes_far: Array[PackedScene] = []
@export var meshes_med: Array[PackedScene] = []
@export var meshes_close: Array[PackedScene] = []
 
# Vitesse de déplacement m/s maximum Decoration lointaines
@export var vitesse_max_far: float = 1.25
# Vitesse de déplacement m/s minimum Decoration lointaines
@export var vitesse_min_far: float = 0.2
# Vitesse de déplacement m/s maximum Decoration medium
@export var vitesse_max_med: float = 1.5
# Vitesse de déplacement m/s minimum Decoration medium
@export var vitesse_min_med: float = 0.3
# Vitesse de déplacement m/s maximum Decoration proches
@export var vitesse_max_close: float = 1.75
# Vitesse de déplacement m/s minimum Decoration proches
@export var vitesse_min_close: float = 0.4
 
# Seuils de distance pour les zones (Lointain)
@export var debut_ralentissement_far: float = 0.35
@export var fin_ralentissement_far: float = 0.85
@export var debut_acceleration_far: float = 0.85
@export var fin_acceleration_far: float = 1.0
 
# Seuils de distance pour les zones (Medium)
@export var debut_ralentissement_med: float = 0.4
@export var fin_ralentissement_med: float = 0.85
@export var debut_acceleration_med: float = 0.85
@export var fin_acceleration_med: float = 1.0
 
# Seuils de distance pour les zones (Proche)
@export var debut_ralentissement_close: float = 0.45
@export var fin_ralentissement_close: float = 0.85
@export var debut_acceleration_close: float = 0.85
@export var fin_acceleration_close: float = 1.0
 
# 6 Chemins pour inspector
@export var path_Left_left: Path3D    # Lointain
@export var path_Left_center: Path3D  # Medium
@export var path_Left_right: Path3D   # Proche
@export var path_Right_right: Path3D  # Lointain
@export var path_Right_center: Path3D # Medium
@export var path_Right_left: Path3D   # Proche
 
func decoration_spawn():
	# Liste des chemins disponibles
	var chemins = [path_Left_left, path_Left_center, path_Left_right, path_Right_right, path_Right_center, path_Right_left]
	var choice_index = randi() % 6
	var chemin_choisi = chemins[choice_index]
	
	# Sécurité si un chemin n'est pas assigné
	if chemin_choisi == null: return
 
	# Déterminer la liste de meshes à utiliser selon l'index du chemin
	var liste_a_utiliser: Array[PackedScene] = []
	
	if choice_index == 0 or choice_index == 3: # Lointain (LeftLeft ou RightRight)
		liste_a_utiliser = meshes_far
	elif choice_index == 1 or choice_index == 4: # Medium (LeftCenter ou RightCenter)
		liste_a_utiliser = meshes_med
	else: # Proche (LeftRight ou RightLeft)
		liste_a_utiliser = meshes_close
 
	# Sécurité si la liste est vide
	if liste_a_utiliser.size() == 0: return
 
	# Création suiveur de path
	var new_decoration = PathFollow3D.new()
	new_decoration.loop = false
	chemin_choisi.add_child(new_decoration)
 
	# Choisir un mesh aléatoirement dans la liste correspondante
	var mesh_aleatoire = liste_a_utiliser.pick_random()
	
	# Instance mesh dans le suiveur de path
	var new_mesh_decoration = mesh_aleatoire.instantiate()
	new_decoration.add_child(new_mesh_decoration)
 
func _process(delta: float) -> void:
	# Liste des chemins à traiter
	var chemins = [path_Left_left, path_Left_center, path_Left_right, path_Right_right, path_Right_center, path_Right_left]
 
	for p in chemins:
		if p == null: continue
 
		# Identifier le type de chemin pour appliquer les bonnes variables
		var v_max: float; var v_min: float; var d_ral: float; var f_ral: float; var d_acc: float; var f_acc: float
		
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
 
		# Faire avancer les decorations dans chaque path
		for decorationPathFollow in p.get_children():
			if decorationPathFollow is PathFollow3D:
				var ratio = decorationPathFollow.progress_ratio
				var v_actuelle = v_max
 
				# Calcul de la vitesse selon les zones de distance définies
				if ratio > d_ral and ratio <= f_ral:
					v_actuelle = remap(ratio, d_ral, f_ral, v_max, v_min)
				elif ratio > f_ral and ratio <= d_acc:
					v_actuelle = v_min
				elif ratio > d_acc and ratio <= f_acc:
					v_actuelle = remap(ratio, d_acc, f_acc, v_min, v_max)
 
				# Appliquer le mouvement
				decorationPathFollow.progress += v_actuelle * delta
 
				# Supprimer la decoration s'il arrive au bout du path
				if decorationPathFollow.progress_ratio >= 0.99:
					decorationPathFollow.queue_free()
 
# Callbacks des timers
func _on_decoration_leftleft_timer_1_timeout() -> void:
	decoration_spawn()
 
func _on_decoration_leftcenter_timer_2_timeout() -> void:
	decoration_spawn()
 
func _on_decoration_leftright_timer_3_timeout() -> void:
	decoration_spawn()
 
func _on_decoration_rightright_timer_4_timeout() -> void:
	decoration_spawn()
 
func _on_decoration_rightcenter_timer_5_timeout() -> void:
	decoration_spawn()
 
func _on_decoration_rightleft_timer_6_timeout() -> void:
	decoration_spawn()
