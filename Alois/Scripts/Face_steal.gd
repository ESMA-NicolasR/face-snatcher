extends Node3D
 
# Référence au bouton dans l'interface
var bouton: Button
 
func _ready() -> void:
	# Récupérer le bouton via le groupe au lancement
	bouton = get_tree().get_first_node_in_group("Boutons_interaction")
	
	# Sécurité si le bouton n'est pas trouvé
	if bouton:
		bouton.hide()
 
# Déclanché quand un corps entre dans la zone
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("entrée collision")
	# Vérifier si c'est bien le joueur qui est proche
	if body.is_in_group("Player"):
		if bouton:
			bouton.show()
			print("Joueur proche : Bouton affiché")
 
# Déclanché quand un corps sort de la zone
func _on_area_3d_body_exited(body: Node3D) -> void:
	print("sortie collision")
	# Cacher le bouton quand le joueur s'éloigne
	if body.is_in_group("Player"):
		if bouton:
			bouton.hide()
			print("Joueur loin : Bouton caché")
