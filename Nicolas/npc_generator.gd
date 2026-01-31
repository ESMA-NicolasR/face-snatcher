extends Node

@export var allFaces : Array[Texture]
@export var allBodies : Array[Texture]
@export var allLips : Array[Texture]
@export var allEyes : Array[Texture]
@export var allEyebrows : Array[Texture]
@export var allNoses : Array[Texture]

@export var npc_scene : PackedScene = preload("res://Nicolas/npc_sprites.tscn")
@export var spawnPoint : Node3D

func _process(delta):
	if(Input.is_action_just_pressed("debugSpawn")):
		create_npc()

func create_npc():
	# Create NPC
	var new_npc : NPC_Sprites = npc_scene.instantiate()
	
	# Random face generation
	init_npc(new_npc)
	
	# Place NPC in scene
	spawnPoint.add_child(new_npc)

func init_npc(npc):
	npc.change_face(randi())
	npc.change_body(allBodies.pick_random())
	npc.change_lips(allLips.pick_random())
	npc.change_eyes(allEyes.pick_random())
	npc.change_eyebrows(allEyebrows.pick_random())
	npc.change_nose(allNoses.pick_random())
