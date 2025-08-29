# GlobalCurrency.gd
extends Node

# Signals
signal currency_changed(new_amount: int)
signal currency_earned(amount: int, reason: String)
signal currency_spent(amount: int, reason: String)
signal inventory_changed()

# Static reference to the singleton
static var instance: GlobalCurrency

# Currency amount - use a private backing field
var _current_currency: int = 999
var current_currency: int:
	get:
		return _current_currency
	set(value):
		_set_current_currency(value)

# Inventory
var inventory: Array = []

# Save file path
const SAVE_PATH = "user://currency_save.cfg"

func _init():
	# Make this a singleton/autoload
	if instance == null:
		instance = self
	else:
		queue_free()
		return

func _ready():
	# Load saved data
	load_data()
	
	# Connect to problem solving events if available
	_connect_to_problem_events()

func _connect_to_problem_events():
	# Try to find problem solver and connect to it
	call_deferred("_deferred_connect_to_problem_events")

func _deferred_connect_to_problem_events():
	var problem_solver = get_tree().get_first_node_in_group("problem_solver")
	if problem_solver and problem_solver.has_signal("problem_solved"):
		problem_solver.problem_solved.connect(_on_problem_solved)
		print("Connected to problem solver")
	else:
		# Try again after a short delay
		get_tree().create_timer(1.0).timeout.connect(_connect_to_problem_events)

func _set_current_currency(value: int):
	var old_value = _current_currency
	_current_currency = max(0, value)  # Ensure currency doesn't go negative
	
	if _current_currency != old_value:
		currency_changed.emit(_current_currency)
		save_data()

# Add currency
func add_currency(amount: int, reason: String = "") -> void:
	if amount > 0:
		# Use the backing field directly to avoid infinite recursion
		_current_currency += amount
		currency_earned.emit(amount, reason)
		currency_changed.emit(_current_currency)
		save_data()
		print("Earned %d coins%s. Total: %d" % [amount, " (" + reason + ")" if reason != "" else "", _current_currency])

# Spend currency
func spend_currency(amount: int, reason: String = "") -> bool:
	if amount <= 0:
		return false
	
	if _current_currency >= amount:
		# Use the backing field directly to avoid infinite recursion
		_current_currency -= amount
		currency_spent.emit(amount, reason)
		currency_changed.emit(_current_currency)
		save_data()
		print("Spent %d coins%s. Remaining: %d" % [amount, " (" + reason + ")" if reason != "" else "", _current_currency])
		return true
	else:
		print("Not enough coins! Need %d, have %d" % [amount, _current_currency])
		return false

# Check if player can afford something
func can_afford(amount: int) -> bool:
	return _current_currency >= amount

# Get current currency
func get_currency() -> int:
	return _current_currency

# --- Inventory Management ---

func add_to_inventory(item_data: Dictionary):
	inventory.append(item_data)
	inventory_changed.emit()
	save_data()
	print("Added to inventory: ", item_data)

func remove_from_inventory(item_data: Dictionary):
	var index = inventory.find(item_data)
	if index != -1:
		inventory.remove_at(index)
		inventory_changed.emit()
		save_data()
		print("Removed from inventory: ", item_data)

func get_inventory() -> Array:
	return inventory

# --- Data Persistence ---

func save_data():
	var config = ConfigFile.new()
	config.set_value("currency", "amount", _current_currency)
	config.set_value("inventory", "items", inventory)
	var error = config.save(SAVE_PATH)
	if error != OK:
		print("Error saving data: ", error)

func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err == OK:
		# Load currency
		var saved_currency = config.get_value("currency", "amount", 999)
		if saved_currency >= 0:
			_current_currency = saved_currency
		else:
			_current_currency = 999
		
		# Load inventory
		inventory = config.get_value("inventory", "items", [])
		
		print("Data loaded. Currency: %d, Inventory items: %d" % [_current_currency, inventory.size()])
	else:
		# Default starting values
		_current_currency = 999
		inventory = []
		print("No save file found, using default data.")
	
	currency_changed.emit(_current_currency)
	inventory_changed.emit()

# Reset data (for testing/debugging)
func reset_data(currency_amount: int = 999):
	_current_currency = currency_amount
	inventory = []
	currency_changed.emit(_current_currency)
	inventory_changed.emit()
	save_data()
	print("Data reset. Currency: %d, Inventory cleared." % _current_currency)

# Event handler for problem solving
func _on_problem_solved(correct: bool, difficulty: int = 0):
	if correct:
		var reward = _calculate_reward(difficulty)
		add_currency(reward, "Solved problem")
	else:
		# Optional: deduct currency for wrong answers
		# var penalty = 5
		# spend_currency(penalty, "Wrong answer")
		pass

func _calculate_reward(difficulty: int) -> int:
	match difficulty:
		1:  # Uncommon
			return 15
		2:  # Rare
			return 25
		_:  # Common/default
			return 10

# DEBUG: Add this function to fix stuck currency
func _input(event):
	# Press R to reset currency for debugging
	if event.is_action_pressed("ui_accept"):  # Enter key
		reset_data(1000)
		print("DEBUG: Reset data.")
