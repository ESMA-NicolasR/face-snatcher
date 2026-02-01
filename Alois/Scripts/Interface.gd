extends Control

# Références existantes
@export var score_label: Label
@export var health_bar: ProgressBar
@export var mask_manager: MaskManager

# --- NOUVELLE RÉFÉRENCE FX ---
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
@export var gain_pv_mort: float = 15.0

var score: int = 0
var clics_actuels: int = 0
var pv_actuels: float = 100.0
var pnj_actuel: Node3D = null
var décalage_aléatoire: Vector3 = Vector3.ZERO 

func _ready():
	mettre_a_jour_score()
	health_bar.value = pv_actuels
	var bouton = get_node("Face Steal Button")
	bouton.pivot_offset = bouton.size / 2

func _process(delta: float) -> void:
	pv_actuels -= perte_pv_seconde * delta
	pv_actuels = max(pv_actuels, 0)
	health_bar.value = pv_actuels
	
	if pv_actuels <= 0:
		get_tree().reload_current_scene()

	if pnj_actuel:
		positionner_bouton_dynamique()

func positionner_bouton_dynamique():
	var camera = get_viewport().get_camera_3d()
	var bouton = get_node("Face Steal Button")
	
	if camera and bouton.visible:
		var pos_base = pnj_actuel.global_position + Vector3(0, hauteur_visage, 0)
		var pos_3d_finale = pos_base + décalage_aléatoire
		
		var distance = camera.global_position.distance_to(pnj_actuel.global_position)
		var facteur_scale = distance_reference / distance
		facteur_scale = clamp(facteur_scale, scale_min, scale_max)
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
			detruire_pnj()

func detruire_pnj():
	var mult = Engine.time_scale
	
	# Score et Soin
	var points_gagnes = round(1 * mult)
	score += int(points_gagnes)
	mettre_a_jour_score()
	
	var soin = gain_pv_mort * sqrt(mult)
	pv_actuels = min(pv_actuels + soin, 100.0)
	
	# --- LOGIQUE DE VOL ET FX ---
	if pnj_actuel:
		# 1. Spawn du FX à la position du visage
		if fx_steal_scene:
			var fx = fx_steal_scene.instantiate()
			# On l'ajoute à la scène courante pour qu'il ne soit pas supprimé avec le PNJ
			get_tree().current_scene.add_child(fx)
			fx.global_position = pnj_actuel.global_position + Vector3(0, hauteur_visage, 0)

		# 2. Logique de vol de visage
		var npc_visuals = pnj_actuel as NPC_Sprites
		if not npc_visuals:
			npc_visuals = pnj_actuel.get_node_or_null("NPC_Sprites")
			
		if npc_visuals and mask_manager:
			mask_manager.collecter_morceau(npc_visuals.get_npc_data())
			npc_visuals.snatch_face()
		
		# 3. Suppression du PNJ
		pnj_actuel.get_parent().queue_free()
	
	pnj_actuel = null
	get_node("Face Steal Button").hide()

func mettre_a_jour_score():
	score_label.text = "Score : " + str(score)
