extends Control
 
# --- RÉFÉRENCES UI & MANAGER ---
@export_group("UI References")
@export var score_label: Label
@export var health_bar: ProgressBar
@export var mask_manager: MaskManager
 
# --- EFFETS VISUELS ---
@export_group("Effets Visuels")
@export var fx_steal_scene: PackedScene # Ta scène contenant le GPUParticles3D
 
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
 
# --- VARIABLES INTERNES ---
var score: int = 0
var clics_actuels: int = 0
var pv_actuels: float = 100.0
var pnj_actuel: Node3D = null
var décalage_aléatoire: Vector3 = Vector3.ZERO 
 
func _ready():
	mettre_a_jour_score()
	health_bar.value = pv_actuels
	# On centre le pivot pour que le bouton scale proprement depuis son milieu
	var bouton = get_node("Face Steal Button")
	bouton.pivot_offset = bouton.size / 2
 
func _process(delta: float) -> void:
	# Gestion de la perte de vie (accélérée naturellement par Engine.time_scale)
	pv_actuels -= perte_pv_seconde * delta
	pv_actuels = max(pv_actuels, 0)
	health_bar.value = pv_actuels
	
	if pv_actuels <= 0:
		print("Game Over")
		get_tree().reload_current_scene()
 
	# Mise à jour du bouton si un PNJ est à portée
	if pnj_actuel:
		positionner_bouton_dynamique()
 
func positionner_bouton_dynamique():
	var camera = get_viewport().get_camera_3d()
	var bouton = get_node("Face Steal Button")
	
	if camera and bouton.visible:
		var pos_base = pnj_actuel.global_position + Vector3(0, hauteur_visage, 0)
		var pos_3d_finale = pos_base + décalage_aléatoire
		
		# Calcul de l'échelle selon la distance
		var distance = camera.global_position.distance_to(pnj_actuel.global_position)
		var facteur_scale = distance_reference / distance
		facteur_scale = clamp(facteur_scale, scale_min, scale_max)
		bouton.scale = Vector2(facteur_scale, facteur_scale)
		
		if camera.is_position_behind(pos_3d_finale):
			bouton.hide()
		else:
			var position_2d = camera.unproject_position(pos_3d_finale)
			# Centrage du bouton sur la position projetée
			bouton.global_position = position_2d - (bouton.size * bouton.scale / 2)
			if not bouton.visible: bouton.show()
 
func enregistrer_cible(pnj):
	pnj_actuel = pnj
	clics_actuels = 0 
	# On génère un décalage aléatoire unique pour cette rencontre
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
 
func voler_visage_pnj():
	var mult = Engine.time_scale
	
	# Gains calculés
	var points_gagnes = round(1 * mult)
	score += int(points_gagnes)
	mettre_a_jour_score()
	
	# Soin avec progression : $gain \times \sqrt{vitesse}$
	var soin = gain_pv_mort * sqrt(mult)
	pv_actuels = min(pv_actuels + soin, 100.0)
	
	if pnj_actuel:
		# --- SPAWN DU FX ---
		if fx_steal_scene:
			var fx = fx_steal_scene.instantiate()
			# On l'ajoute à la racine du monde (current_scene)
			get_tree().current_scene.add_child(fx)
			# Positionnement précis sur le visage
			fx.global_position = pnj_actuel.global_position + Vector3(0, hauteur_visage, 0)
 
		# --- LOGIQUE DE VOL ---
		var npc_visuals = pnj_actuel as NPC_Sprites
		if not npc_visuals:
			npc_visuals = pnj_actuel.get_node_or_null("NPC_Sprites")
			
		if npc_visuals and mask_manager:
			mask_manager.collecter_morceau(npc_visuals.get_npc_data())
			npc_visuals.snatch_face()
		
		# On détruit le PNJ (le parent PathFollow3D)
		pnj_actuel.get_parent().queue_free()
	
	# Nettoyage interface
	pnj_actuel = null
	get_node("Face Steal Button").hide()
 
func mettre_a_jour_score():
	score_label.text = "Score : " + str(score)
