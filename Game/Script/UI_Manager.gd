# =============================================================================
# UI_Manager.gd - User interface controller
# =============================================================================
# This script manages all UI elements including the health bar, coin counter,
# and game over screen. It connects to player signals to update UI in real-time
# and handles the restart button functionality.
# =============================================================================
extends CanvasLayer

# --- Node References ---
@onready var health_bar: ProgressBar = $GameScreen/HealthBar    # Player health bar UI
@onready var coin_label: Label = $GameScreen/CoinLabel          # Coin count display label
@onready var game_over_screen: Panel = $GameOverScreen          # Game over overlay panel

# =============================================================================
# _ready() - Called when the node enters the scene tree
# Sets up signal connections between player/game manager and UI elements
# =============================================================================
func _ready():
	# Get reference to the player
	var player = get_tree().get_root().get_node("Root").get_node("Player") as PlayerController
	
	# Connect player signals to UI update functions
	if player:
		player.playerHealthUpdated.connect(UpdateHealthBar)  # Update health bar when health changes
		player.playerCoinUpdated.connect(UpdateCoinLabel)    # Update coin display when coins change
	
	# Connect GameManager's GameOver signal to show game over screen
	GameManager.GameOver.connect(ShowGameOverScreen)
	
	# Hide game over screen initially
	game_over_screen.visible = false

# =============================================================================
# UpdateHealthBar(newValue, maxValue) - Updates the health bar display
# Converts current/max health to a percentage for the progress bar
# =============================================================================
func UpdateHealthBar(newValue: int , maxValue: int):
	# Calculate percentage and update progress bar (0-100 scale)
	var barValue = float(newValue) / float(maxValue) * 100
	health_bar.value = barValue

# =============================================================================
# UpdateCoinLabel(newValue) - Updates the coin counter display
# Converts the coin count to string and displays it
# =============================================================================
func UpdateCoinLabel(newValue:int):
	coin_label.text = str(newValue)

# =============================================================================
# ShowGameOverScreen() - Displays the game over overlay
# Called when the player dies or completes the level
# =============================================================================
func ShowGameOverScreen():
	game_over_screen.visible = true

# =============================================================================
# _on_restart_button_pressed() - Restart button callback
# Reloads the current scene to restart the game
# =============================================================================
func _on_restart_button_pressed():
	# Reload the entire scene to reset all game state
	get_tree().reload_current_scene()
