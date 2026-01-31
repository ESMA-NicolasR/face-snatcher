extends Node

# Mesh pnj
@export var PNJ_mesh_scene: PackedScene = preload("res://Alois/pnj_mesh.tscn")
# Vitesse de déplacement m/s
@export var vitesse: float = 5.0
# Premier chemin à assigner dans l'inspecteur
@export var path_Left: Path3D
# Deuxième chemin à assigner dans l'inspecteur
@export var path_Right: Path3D

func pnj_spawn():
	# Choisir un chemin aléatoirement entre les deux
	var chemins = [path_Left, path_Right]
	var chemin_choisi = chemins.pick_random()
	
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
				pnj.progress += vitesse * delta
				
				# Supprimer le PNJ s'il arrive au bout du path
				if pnj.progress_ratio >= 0.98:
					pnj.queue_free()


func _on_pnj_spawn_timer_timeout() -> void:
	print("spawn")
	pnj_spawn()
