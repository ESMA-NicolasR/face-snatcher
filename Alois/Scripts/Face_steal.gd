extends Node3D
 
var interface: Control
 
func _ready() -> void:
	# On va chercher l'interface (adaptez le chemin selon votre scène)
	# Si votre UI est dans un groupe "UI", c'est plus simple :
	interface = get_tree().get_first_node_in_group("UI")
 
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if interface:
			# On dit à l'interface que c'est nous la cible
			interface.enregistrer_cible(self)
			interface.get_node("Face Steal Button").show()
 
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		if interface:
			interface.retirer_cible()
			interface.get_node("Face Steal Button").hide()
