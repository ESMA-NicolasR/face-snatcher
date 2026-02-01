extends Node3D

func _ready():
	# On attend la fin de l'émission
	if has_node("GPUParticles3D"):
		$GPUParticles3D.finished.connect(queue_free)
	else:
		# Suppression après 2 secondes si pas de signal
		await get_tree().create_timer(2.0).timeout
		queue_free()
