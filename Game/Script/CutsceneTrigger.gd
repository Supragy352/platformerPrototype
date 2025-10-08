extends Area2D

@onready var cutscene = $"../CutscenePlayer/VideoStreamPlayer"

func _ready():
	# Connect the finished signal from the VideoStreamPlayer
	cutscene.finished.connect(_on_cutscene_player_finished)

func _on_body_entered(body):
	if body.is_in_group("player"):
		cutscene.visible = true
		cutscene.play()
		get_tree().paused = true
		# In Godot 4, pause_mode has been replaced with process_mode
		cutscene.process_mode = Node.PROCESS_MODE_ALWAYS

func _on_body_exited(body):
	if body.is_in_group("player"):
		cutscene.stop()
		cutscene.visible = false
		get_tree().paused = false

func _on_cutscene_player_finished():
	cutscene.visible = false
	get_tree().paused = false
