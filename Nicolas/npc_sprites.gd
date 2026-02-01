extends Node3D

class_name NPC_Sprites

func change_face(frame: int):
	$BaseFace.frame = frame%$BaseFace.hframes

func change_lips(sprite: Texture):
	$BaseFace/Lips.texture = sprite

func change_eyes(sprite: Texture):
	$BaseFace/Eyes.texture = sprite
	
func change_nose(sprite: Texture):
	$BaseFace/Nose.texture = sprite
	
func change_eyebrows(sprite: Texture):
	$BaseFace/Eyebrows.texture = sprite
	
func change_body(sprite: Texture):
	$Body.texture = sprite

func snatch_face():
	$BaseFace.frame += $BaseFace.hframes
	change_lips(null)
	change_eyes(null)
	change_nose(null)
	change_eyebrows(null) 
 
# Fonction pour récupérer toutes les données visuelles du PNJ avant destruction
func get_npc_data() -> Dictionary:
	return {
		"face_frame": $BaseFace.frame,
		"lips": $BaseFace/Lips.texture,
		"eyes": $BaseFace/Eyes.texture,
		"nose": $BaseFace/Nose.texture,
		"eyebrows": $BaseFace/Eyebrows.texture
	}
