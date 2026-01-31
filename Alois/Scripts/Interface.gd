extends Control
 
# Référence au label de score
@export var score_label: Label
# Référence à la barre de vie (ProgressBar ou TextureProgressBar)
@export var health_bar: ProgressBar
 
# Vitesse de perte de PV (% par seconde)
@export var perte_pv_seconde: float = 1.0
# Points de vie récupérés par PNJ tué
@export var gain_pv_mort: float = 15.0
 
var score: int = 0
var clics_actuels: int = 0
var pv_actuels: float = 100.0
var pnj_actuel: Node3D = null # Garde en mémoire le PNJ proche
 
func _ready():
	# Initialiser le texte du score
	print("Update score")
	mettre_a_jour_score()
	# Initialiser la barre de vie
	health_bar.value = pv_actuels
 
func _process(delta: float) -> void:
	# Diminuer les PV progressivement selon le temps
	pv_actuels -= perte_pv_seconde * delta
	
	# Empêcher les PV de descendre en dessous de 0
	pv_actuels = max(pv_actuels, 0)
	
	# Mettre à jour l'affichage de la barre
	health_bar.value = pv_actuels
	
	# Logique de Game Over si PV à zéro
	if pv_actuels <= 0:
		print("Mort du joueur")
		get_tree().reload_current_scene()
 
# Fonction appelée par le PNJ quand on s'approche
func enregistrer_cible(pnj):
	print("Nouvelle cible à portée")
	pnj_actuel = pnj
	clics_actuels = 0 # On remet les clics à zéro pour le nouveau PNJ
 
# Fonction appelée par le PNJ quand on s'éloigne
func retirer_cible():
	print("Cible hors portée")
	pnj_actuel = null
	clics_actuels = 0
 
func _on_face_steal_button_pressed() -> void:
	if pnj_actuel != null:
		clics_actuels += 1
		print("Clic : ", clics_actuels)
		# Si on atteint 5 clics on détruit le pnj
		if clics_actuels >= 5:
			detruire_pnj()
 
func detruire_pnj():
	# Ajouter un point au score
	score += 1
	print("Plus vivant")
	mettre_a_jour_score()
	
	# Récupérer des points de vie
	pv_actuels += gain_pv_mort
	# Limiter les PV à 100
	pv_actuels = min(pv_actuels, 100.0)
	
	# Détruire le PNJ (via son parent PathFollow3D)
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
