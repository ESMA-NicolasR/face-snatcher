extends Node
 
# Mesh pnj
@export var PNJ_mesh_scene: PackedScene = preload("res://Alois/Mesh/pnj_mesh.tscn")
 
# Vitesse de déplacement m/s maximum
@export var vitesse_max: float = 5.0
# Vitesse de déplacement m/s minimum
@export var vitesse_min: float = 1.0
 
# Seuil de début de ralentissement (ratio entre 0.0 et 1.0)
@export var debut_ralentissement: float = 0.2
# Seuil de fin de ralentissement (vitesse min atteinte)
@export var fin_ralentissement: float = 0.4
# Seuil de début de réaccélération
@export var debut_acceleration: float = 0.6
# Seuil de fin de réaccélération (retour vitesse max)
@export var fin_acceleration: float = 0.8
 
# Premier chemin à assigner dans l'inspecteur
@export var path_Left: Path3D
# Deuxième chemin à assigner dans l'inspecteur
@export var path_Right: Path3D
 
# Variables pour la logique de spawn consécutif
var last_side_index: int = -1
var consecutive_count: int = 0
 
func pnj_spawn():
	# Liste des chemins disponibles
	var chemins = [path_Left, path_Right]
	var choice = randi() % 2
	
	# Empêcher de spawner plus de 3 fois du même côté
	if choice == last_side_index:
		consecutive_count += 1
	else:
		last_side_index = choice
		consecutive_count = 1
		
	if consecutive_count > 3:
		choice = 1 - choice
		last_side_index = choice
		consecutive_count = 1
 
	var chemin_choisi = chemins[choice]
	
	# Sécurité si un chemin n'est pas assigné
	if chemin_choisi == null: return
 
	# Création suiveur de path
	var new_victim = PathFollow3D.new()
	new_victim.loop = false
	# On ajoute le suiveur au chemin choisi aléatoirement
	chemin_choisi.add_child(new_victim)
	
	# Instance mesh dans le suiveur de path
	var new_pnj = PNJ_mesh_scene.instantiate()
	new_victim.add_child(new_pnj)
 
func _process(delta: float) -> void:
	# Liste des chemins à traiter
	var chemins = [path_Left, path_Right]
	
	for p in chemins:
		if p == null: continue
		
		# Faire avancer les pnj dans chaque path
		for pnj in p.get_children():
			if pnj is PathFollow3D:
				var ratio = pnj.progress_ratio
				var v_actuelle = vitesse_max
				
				# Calcul de la vitesse selon les zones de distance définies
				if ratio > debut_ralentissement and ratio <= fin_ralentissement:
					# Zone de ralentissement progressif
					v_actuelle = remap(ratio, debut_ralentissement, fin_ralentissement, vitesse_max, vitesse_min)
				elif ratio > fin_ralentissement and ratio <= debut_acceleration:
					# Zone de vitesse minimale constante
					v_actuelle = vitesse_min
				elif ratio > debut_acceleration and ratio <= fin_acceleration:
					# Zone de réaccélération progressive
					v_actuelle = remap(ratio, debut_acceleration, fin_acceleration, vitesse_min, vitesse_max)
				
				# Appliquer le mouvement
				pnj.progress += v_actuelle * delta
				
				# Supprimer le PNJ s'il arrive au bout du path
				if pnj.progress_ratio >= 0.98:
					pnj.queue_free()
 
func _on_pnj_spawn_timer_timeout() -> void:
	print("Une nouvelle victime apparue")
	pnj_spawn()


func _on_decoration_leftright_timer_3_timeout() -> void:
	pass # Replace with function body.
