extends Node
 
# Cette variable ne sera jamais réinitialisée pendant que le jeu tourne
var score_total: int = 0
 
# Fonction utilitaire pour réinitialiser le score si besoin (ex: retour au menu)
func reset_game():
	score_total = 0
