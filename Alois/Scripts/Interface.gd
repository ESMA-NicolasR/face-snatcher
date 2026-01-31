extends Control
 
# Référence au label de score
@export var score_label: Label
 
var score: int = 0
var clics_actuels: int = 0
var pnj_actuel: Node3D = null # Garde en mémoire le PNJ proche
 
func _ready():
	# Initialiser le texte du score
	print("Update score")
	mettre_a_jour_score()
 
# Fonction appelée par le PNJ quand on s'approche
func enregistrer_cible(pnj):
	print("Nouvelle cible à portée")
	pnj_actuel = pnj
	clics_actuels = 0 # On remet les clics à zéro pour ce nouveau PNJ
 
# Fonction appelée par le PNJ quand on s'éloigne
func retirer_cible():
	print("Cible hors portée")
	pnj_actuel = null
	clics_actuels = 0
 
func _on_face_steal_button_pressed() -> void:
	if pnj_actuel != null:
		clics_actuels += 1
		print("Clic : ", clics_actuels)
		
		# Si on atteint 5 clics
		if clics_actuels >= 5:
			detruire_pnj()
 
func detruire_pnj():
	# Ajouter un point au score
	score += 1
	print("Plus vivant")
	mettre_a_jour_score()
	
	# Détruire le PNJ (et son parent PathFollow3D)
	if pnj_actuel:
		# On remonte au parent car le script est sur le Mesh
		# mais c'est le PathFollow3D qu'on veut supprimer
		pnj_actuel.get_parent().queue_free()
		print("pnj actuel trouvé")
	
	# Cacher le bouton et nettoyer les références
	pnj_actuel = null
	get_node("Face Steal Button").hide()
 
func mettre_a_jour_score():
	score_label.text = "Score : " + str(score)
