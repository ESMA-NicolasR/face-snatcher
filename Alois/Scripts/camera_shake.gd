extends Camera3D

# --- CONFIGURATION ---
@export_group("Réglages du Tremblement (Position)")
@export var seuil_stress: float = 40.0
@export var force_min: float = 0.05
@export var force_max: float = 0.6

@export_group("Réglages du Tangage (Roll)")
# Intensité du Roll en degrés (très léger au début, plus fort à la fin)
@export var roll_min: float = 0.1
@export var roll_max: float = 2.5

@export_group("Références")
@export var ui_interface: Control

# Variables pour stocker l'état initial
var position_originale: Vector3
var rotation_originale: Vector3

func _ready() -> void:
	# On stocke la position et la rotation initiales de la caméra
	position_originale = transform.origin
	rotation_originale = rotation

func _process(_delta: float) -> void:
	if ui_interface:
		calculer_shake(ui_interface.pv_actuels)
	else:
		reset_camera()

func calculer_shake(pv: float):
	if pv < seuil_stress:
		# 1. Calcul de l'intensité (0.0 à 1.0)
		var intensite = (seuil_stress - pv) / seuil_stress
		
		# 2. Tremblement de Position (Translation)
		var force_actuelle = lerp(force_min, force_max, intensite)
		var shake_offset = Vector3(
			randf_range(-force_actuelle, force_actuelle),
			randf_range(-force_actuelle, force_actuelle),
			0
		)
		transform.origin = position_originale + shake_offset
		
		# 3. Tremblement de Rotation (Roll sur l'axe Z)
		var roll_actuel = lerp(roll_min, roll_max, intensite)
		# On applique la rotation sur l'axe Z (index 2 du Vector3 rotation)
		# deg_to_rad est nécessaire car Godot travaille en Radians dans le code
		var random_roll = randf_range(-roll_actuel, roll_actuel)
		rotation.z = rotation_originale.z + deg_to_rad(random_roll)
		
	else:
		reset_camera()

func reset_camera():
	# Retour fluide ou immédiat aux valeurs de base
	transform.origin = position_originale
	rotation.z = rotation_originale.z
