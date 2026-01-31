extends Node3D

class_name NPC_Sprites

func change_face(sprite: Texture):
	$BaseFace.texture = sprite

func change_lips(sprite: Texture):
	$BaseFace/Lips.texture = sprite

func change_eyes(sprite: Texture):
	$BaseFace/Eyes.texture = sprite
	
func change_nose(sprite: Texture):
	$BaseFace/Nose.texture = sprite
	
func change_eyebrows(sprite: Texture):
	$BaseFace/Eyebrows.texture = sprite
