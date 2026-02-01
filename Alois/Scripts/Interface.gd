extends Control
 
# --- RÉFÉRENCES UI & MANAGER ---
@export_group("UI References")
@export var score_label: Label
@export var health_bar: ProgressBar
@export var mask_manager: MaskManager
@export var mask_texture: TextureRect # Utilisé pour l'effet visuel de perte de PV
 
# --- EFFETS VISUELS ---
@export_group("Effets Visuels")
@export var fx_steal_scene: PackedScene
 
# --- CONFIGURATION DU BOUTON ---
@export_group("Réglages du Bouton")
@export var hauteur_visage: float = 1.6
@export var zone_largeur: Vector2 = Vector2(-0.5, 0.5)
@export var zone_hauteur: Vector2 = Vector2(-0.3, 0.3)
@export var scale_min: float = 0.4
@export var scale_max: float = 1.5
@export var distance_reference: float = 5.0 
 
# --- LOGIQUE DE JEU ---
@export_group("Paramètres de Jeu")
@export var perte_pv_seconde: float = 1.0
@export var gain_pv_mort: float = 5.0
 
# --- PROGRESSION ---
@export_group("Progression")
@export var score_objectif: int = 10000
@export var prochain_niveau: String = "face_snatcher_level_2"
 
# --- VARIABLES INTERNES ---
var score: int = 0
var clics_actuels: int = 0
var pv_actuels: float = 100.0
var pnj_actuel: Node3D = null
var décalage_aléatoire: Vector3 = Vector3.ZERO 
var en_transition: bool = false 
 
func _ready():
	# Initialisation du score persistant
	score = Global.score_total
	actualiser_affichage_score() 
 
	health_bar.value = pv_actuels
	var bouton = get_node("Face Steal Button")
	bouton.pivot_offset = bouton.size / 2
 
func _process(delta: float) -> void:
	# 1. Gestion des PV
	pv_actuels -= perte_pv_seconde * delta
	pv_actuels = max(pv_actuels, 0)
	health_bar.value = pv_actuels
 
	# 2. Effet visuel sur la texture du masque (Taille qui change selon PV)
	if mask_texture:
		# Quand PV = 100, size.y = 0. Quand PV = 0, size.y = 96.
		mask_texture.size.y = (1.0 - (pv_actuels / 100.0)) * 96
 
	# 3. Vérification Mort
	if pv_actuels <= 0:
		print("Mort du joueur")
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()
 
	# 4. Positionnement du bouton
	if pnj_actuel:
		positionner_bouton_dynamique()
 
# --- LOGIQUE DE SCORE ET VICTOIRE ---
 
func actualiser_affichage_score():
	Global.score_total = score
	score_label.text = "Score : " + str(score)
 
func verifier_victoire():
	if score >= score_objectif and not en_transition:
		en_transition = true
		print("Objectif atteint !")
		passer_au_niveau_suivant(prochain_niveau)
 
func voler_visage_pnj():
	var mult = Engine.time_scale
	
	# Gain de points
	var points_gagnes = round(100 * mult)
	score += int(points_gagnes)
	actualiser_affichage_score()
 
	# Vérification victoire (pendant le vol seulement)
	verifier_victoire()
 
	# Gain de PV adouci
	var soin = gain_pv_mort * sqrt(mult)
	pv_actuels = min(pv_actuels + soin, 100.0)
 
	if pnj_actuel:
		# FX Particules
		if fx_steal_scene:
			var fx = fx_steal_scene.instantiate()
			get_tree().current_scene.add_child(fx)
			fx.global_position = pnj_actuel.global_position + Vector3(0, hauteur_visage, 0)
 
		# Transfert de visage
		var npc_visuals = pnj_actuel as NPC_Sprites
		if not npc_visuals:
			npc_visuals = pnj_actuel.get_node_or_null("NPC_Sprites")
 
		if npc_visuals and mask_manager:
			mask_manager.collecter_morceau(npc_visuals.get_npc_data())
			npc_visuals.snatch_face()
 
		# Destruction du PNJ
		# pnj_actuel.get_parent().queue_free()
 
	pnj_actuel = null
	get_node("Face Steal Button").hide()
 
# --- UTILITAIRES ---
 
func passer_au_niveau_suivant(nom_scene_suivante: String):
	print("Niveau terminé ! Passage à : ", nom_scene_suivante)
	Engine.time_scale = 1.0
	var chemin_scene = "res://Alois/Scenes/" + nom_scene_suivante + ".tscn"
	get_tree().change_scene_to_file(chemin_scene)
 
func positionner_bouton_dynamique():
	var camera = get_viewport().get_camera_3d()
	var bouton = get_node("Face Steal Button")
	if camera and bouton.visible:
		var pos_base = pnj_actuel.global_position + Vector3(0, hauteur_visage, 0)
		var pos_3d_finale = pos_base + décalage_aléatoire
		var distance = camera.global_position.distance_to(pnj_actuel.global_position)
		var facteur_scale = clamp(distance_reference / distance, scale_min, scale_max)
		bouton.scale = Vector2(facteur_scale, facteur_scale)
		
		if camera.is_position_behind(pos_3d_finale):
			bouton.hide()
		else:
			var position_2d = camera.unproject_position(pos_3d_finale)
			bouton.global_position = position_2d - (bouton.size * bouton.scale / 2)
			if not bouton.visible: bouton.show()
 
func enregistrer_cible(pnj):
	pnj_actuel = pnj
	clics_actuels = 0 
	décalage_aléatoire = Vector3(
		randf_range(zone_largeur.x, zone_largeur.y), 
		randf_range(zone_hauteur.x, zone_hauteur.y), 
		0
	)
	get_node("Face Steal Button").show()
 
func retirer_cible():
	pnj_actuel = null
	clics_actuels = 0
	get_node("Face Steal Button").hide()
 
func _on_face_steal_button_pressed() -> void:
	if pnj_actuel != null:
		clics_actuels += 1
		if clics_actuels >= 1:
			voler_visage_pnj()
