extends Node3D
class_name MaskManager
 
# On utilise ../ pour remonter vers le parent "Visuals"
var face: Sprite3D
@onready var p_lips: Sprite3D = $"../PlayerFace/Lips"
@onready var p_eyes: Sprite3D = $"../PlayerFace/Eyes"
@onready var p_nose: Sprite3D = $"../PlayerFace/Nose"
@onready var p_eyebrows: Sprite3D = $"../PlayerFace/EyeBrows"

@onready var t_lips : TextureRect = $"../../../UI/CustomFace/Lips"
@onready var t_eyes : TextureRect = $"../../../UI/CustomFace/Eyes"
@onready var t_eyebrows : TextureRect = $"../../../UI/CustomFace/Eyebrows"
@onready var t_nose : TextureRect = $"../../../UI/CustomFace/Nose"
 
var pieces_manquantes = ["lips", "eyes", "nose", "eyebrows"]
var masque_complet = false
 
func collecter_morceau(npc_data: Dictionary):
	var type_a_voler: String
 
	if not masque_complet:
		# Remplissage des trous
		pieces_manquantes.shuffle()
		type_a_voler = pieces_manquantes.pop_back()
		if pieces_manquantes.is_empty(): masque_complet = true
	else:
		# Remplacement aléatoire
		var types = ["lips", "eyes", "nose", "eyebrows"]
		type_a_voler = types.pick_random()
 
	appliquer_piece(type_a_voler, npc_data)
 
func appliquer_piece(type: String, data: Dictionary):
	# Sécurité : on vérifie que les nœuds ont bien été trouvés
	match type:
		"lips": 
			if p_lips:
				p_lips.texture = data["lips"]
				t_lips.texture = data["lips"]
		"eyes": 
			if p_eyes:
				p_eyes.texture = data["eyes"]
				t_eyes.texture = data["eyes"]
		"nose": 
			if p_nose:
				p_nose.texture = data["nose"]
				t_nose.texture = data["nose"]
		"eyebrows": 
			if p_eyebrows:
				p_eyebrows.texture = data["eyebrows"]
				t_eyebrows.texture = data["eyebrows"]
 
	print("Le masque du joueur a obtenu : ", type)
