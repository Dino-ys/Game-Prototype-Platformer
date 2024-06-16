extends CenterContainer
@onready var start_game = %"Start game"
@onready var quit = %Quit

func _ready():
	start_game.grab_focus()
	pass

func _on_start_game_pressed():
	await LevelTransition.fade_to_black()
	get_tree(). change_scene_to_file("res://level_one.tscn")
	await LevelTransition.fade_from_black()

func _on_quit_pressed():
	get_tree().quit()
