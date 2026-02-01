extends Node3D
 
func _ready():
	# On récupère le nœud de particules
	var particles = $Emitter

	# Configuration de sécurité par code
	particles.one_shot = true
	particles.emitting = true 
	
	# Auto-destruction : on libère la mémoire quand l'effet est fini
	particles.finished.connect(queue_free)
