extends Node

@export var allFaces : Array[Texture]
@export var allLips : Array[Texture]
@export var allEyes : Array[Texture]
@export var allEyebrows : Array[Texture]
@export var allNoses : Array[Texture]

@export var npc_scene : PackedScene = preload("res://Nicolas/npc.tscn")
@export var spawnPoint : Node3D

func _process(delta):
	if(Input.is_action_just_pressed("debugSpawn")):
		create_npc()

func create_npc():
	# Create NPC
	var new_npc : NPC = npc_scene.instantiate()
	
	# Random face generation
	new_npc.change_face(allFaces.pick_random())
	new_npc.change_lips(allLips.pick_random())
	new_npc.change_eyes(allEyes.pick_random())
	new_npc.change_eyebrows(allEyebrows.pick_random())
	new_npc.change_nose(allNoses.pick_random())
	
	# Place NPC in scene
	spawnPoint.add_child(new_npc)
