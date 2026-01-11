# =============================================================================
# UI_Manager.gd - User interface controller
# =============================================================================
# This script manages all UI elements including the health bar, coin counter,
# and game over screen. It connects to player signals to update UI in real-time
# and handles the restart button functionality.
# =============================================================================
extends CanvasLayer

# --- Node References ---
@onready var health_bar: ProgressBar = $GameScreen/HealthBar                       # Player health bar UI
@onready var stamina_bar: ProgressBar = $GameScreen/StaminaBar                     # Player stamina bar UI
@onready var pause_button: Button = $GameScreen/Pause                              # Game pause button
@onready var resume_button: Button = $PauseScreen/Resume                           # Game resume button
@onready var game_over_screen: Panel = $GameOverScreen                             # Game over overlay panel
@onready var game_pause_screen: Panel = $PauseScreen                               # Game pause overlay panel
@onready var score_label: Label = $GameScreen/VBoxContainer/ScoreElement/Score     # Score display label
@onready var coin_label: Label = $GameScreen/VBoxContainer/CoinElement/Coin        # Coin count display label
@onready var time_label: Label = $GameScreen/VBoxContainer/TimerElement/Time       # Time display label


# =============================================================================
# _ready() - Called when the node enters the scene tree
# Sets up signal connections between player/game manager and UI elements
# =============================================================================
func _ready():
	# Get reference to the player
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController

	# Connect player signals to UI update functions
	if player:
		player.playerHealthUpdated.connect(UpdateHealthBar)    # Update health bar when health changes
		player.playerStaminaUpdated.connect(UpdateStaminaBar)  # Update stamina bar when stamina changes
		player.playerScoreUpdated.connect(UpdateScoreLabel)    # Update score display when score changes
		player.playerCoinUpdated.connect(UpdateCoinLabel)      # Update coin display when coins change
		player.playerTimerUpdated.connect(UpdateTimeLabel)     # Update timer display when time changes

	# Connect GameManager's GameOver signal to show game over screen
	GameManager.GameOver.connect(ShowGameOverScreen)

	# Hide game over screen initially
	game_over_screen.visible = false

	# Hide game pause screen initially
	game_pause_screen.visible = false

func _process(_delta) -> void:
	if (Input.is_action_pressed("PauseGame") || pause_button.is_pressed()) && game_pause_screen.visible == false:
		print("GamePaused")
		ShowGamePauseScreen()

	if game_pause_screen.visible == true && (resume_button.is_pressed() || Input.is_action_pressed("ResumeGame")):
		print("GameUnpaused")
		HideGamePauseScreen()

# =============================================================================
# UpdateHealthBar(newValue, maxValue) - Updates the health bar display
# Converts current/max health to a percentage for the progress bar
# =============================================================================
func UpdateHealthBar(newValue: int , maxValue: int):
	# Calculate percentage and update progress bar (0-100 scale)
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue

# =============================================================================
# UpdateStaminaBar(newValue, maxValue) - Updates the stamina bar display
# Converts current/max stamina to a percentage for the progress bar
# =============================================================================
func UpdateStaminaBar(newValue: int , maxValue: int):
	# Calculate percentage and update progress bar (0-100 scale)
	var barValue = float(newValue) / float(maxValue) * 100
	stamina_bar.value = barValue

# =============================================================================
# UpdateScoreLabel(newValue) - Updates the score counter display
# Converts the score count to string and displays it
# =============================================================================
func UpdateScoreLabel(newValue:int):
	score_label.text = str(newValue)

# =============================================================================
# UpdateCoinLabel(newValue) - Updates the coin counter display
# Converts the coin count to string and displays it
# =============================================================================
func UpdateCoinLabel(newValue:int):
	coin_label.text = str(newValue)

# =============================================================================
# UpdateTimeLabel(newValue) - Updates the time counter display
# Converts the time count to string and displays it
# =============================================================================
func UpdateTimeLabel(newValue:int):
	time_label.text = str(newValue)

# =============================================================================
# ShowGameOverScreen() - Displays the game over overlay
# Called when the player dies or completes the level
# =============================================================================
func ShowGameOverScreen():
	game_over_screen.visible = true

# =============================================================================
# ShowGamePauseScreen() - Displays the game pause overlay
# Called when the user pauses the game
# =============================================================================
func ShowGamePauseScreen():
	game_pause_screen.visible = true
	get_tree().paused = true

# =============================================================================
# HideGamePauseScreen() - Resumes the game
# Called when the user resumes the game
# =============================================================================
func HideGamePauseScreen():
	game_pause_screen.visible = false
	get_tree().paused = false

# =============================================================================
# _on_restart_button_pressed() - Restart button callback
# Reloads the current scene to restart the game
# =============================================================================
func _on_restart_button_pressed():
	print("GameRestarted")
	# Reload the entire scene to reset all game state
	get_tree().reload_current_scene()
