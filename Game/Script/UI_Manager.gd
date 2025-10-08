extends CanvasLayer

@onready var health_bar: ProgressBar = $GameScreen/HealthBar
@onready var coin_label: Label = $GameScreen/CoinLabel
@onready var game_over_screen: Panel = $GameOverScreen

func _ready():
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
	if player:
		player.playerHealthUpdated.connect(UpdateHealthBar)
		player.playerCoinUpdated.connect(UpdateCoinLabel)
	
	GameManager.GameOver.connect(ShowGameOverScreen)
	game_over_screen.visible = false
func UpdateHealthBar(newValue: int , maxValue: int):
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue

func UpdateCoinLabel(newValue:int):
	coin_label.text = str(newValue)
	
func ShowGameOverScreen():
	game_over_screen.visible = true

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	
