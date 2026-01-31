extends Path3D

# 1. Tes variables en haut
@export var PNJ_mesh_scene: PackedScene = preload("res://Alois/pnj_mesh.tscn")
@export var vitesse: float = 5.0

func _on_timer_timeout() -> void:
	print("spawn")
	pnj_spawn()

func pnj_spawn():
	# Création suiveur de path
	var new_victim = PathFollow3D.new()
	new_victim.loop = false
	add_child(new_victim)
	
	# Instance mesh dans le suiveur de path
	var new_pnj = PNJ_mesh_scene.instantiate()
	new_victim.add_child(new_pnj)

func _process(delta: float) -> void:
	# Faire avancer les pnj dans le path
	for pnj in get_children():
		if pnj is PathFollow3D:
			pnj.progress += vitesse * delta
			
			# Supprimer le PNJ s'il arrive au bout du path
			if pnj.progress_ratio >= 1:
				pnj.queue_free()
