extends Control

# UI references
@onready var main: Node = $main
@onready var shop: Control = $Shop
@onready var settings: Panel = $settings
@onready var inventory: Panel = $inventory
@onready var inventory_grid: GridContainer = $inventory/InventoryGrid
@onready var leaderboards: Panel = $leaderboards
@onready var profile: Panel = $profile
@onready var pen_tool_button: Button = $BoardTools/PenToolButton
@onready var text_tool_button: Button = $BoardTools/TextToolButton

var whiteboard_scene = preload("res://Scenes/WhiteboardApp.tscn")
var whiteboard_instance: Control = null
var whiteboard_layer: CanvasLayer = null

# Placeholder texture for unrevealed items
var unrevealed_texture = preload("res://Images/Tools/sprite_0.png")
var draggable_item_script = preload("res://Godot script/Scenes Script/DraggableItem.gd")


# --- Setup ---
func _ready() -> void:
	main.visible = true
	_hide_all_panels()

	# Connect tool buttons
	if pen_tool_button:
		pen_tool_button.pressed.connect(_on_pen_tool_selected)
	if text_tool_button:
		text_tool_button.pressed.connect(_on_text_tool_selected)

	# Connect to inventory changes
	if GlobalCurrency.instance:
		GlobalCurrency.instance.inventory_changed.connect(_on_inventory_changed)
		# Initial inventory display
		_on_inventory_changed()

	# setup whiteboard ONCE
	call_deferred("_setup_whiteboard")

# --- Inventory Management ---
func _on_inventory_changed():
	# Clear the existing inventory display
	if inventory_grid:
		for child in inventory_grid.get_children():
			child.queue_free()

	# Get the inventory from the global manager
	var player_inventory = GlobalCurrency.instance.get_inventory()

	# Populate the grid with inventory items
	for item_data in player_inventory:
		var item_rect = TextureRect.new()
		item_rect.texture = unrevealed_texture
		item_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		item_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_rect.custom_minimum_size = Vector2(64, 64)
		
		# Store the item data in the node's metadata
		item_rect.set_meta("item_data", item_data)
		item_rect.set_script(draggable_item_script)
		
		if inventory_grid:
			inventory_grid.add_child(item_rect)


# --- Hide all panels helper ---
func _hide_all_panels() -> void:
	shop.visible = false
	settings.visible = false
	inventory.visible = false
	leaderboards.visible = false
	profile.visible = false

# --- White Board Stuff ---
func _setup_whiteboard() -> void:
	whiteboard_layer = CanvasLayer.new()
	whiteboard_layer.layer = 10  # High layer number to be on top
	add_child(whiteboard_layer)

	whiteboard_instance = whiteboard_scene.instantiate()
	whiteboard_layer.add_child(whiteboard_instance)

	whiteboard_instance.position = Vector2(221, 16)
	whiteboard_instance.size = Vector2(706, 608)
	whiteboard_instance.mouse_filter = Control.MOUSE_FILTER_STOP

# Tool selection functions that call whiteboard methods
func _on_pen_tool_selected():
	if whiteboard_instance:
		whiteboard_instance.call_deferred("_on_pen_tool_selected")

func _on_text_tool_selected():
	if whiteboard_instance:
		whiteboard_instance.call_deferred("_on_text_tool_selected")

# --- Button Handlers with panel + whiteboard toggle ---
func _on_shop_button_down() -> void:
	_hide_all_panels()
	shop.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_button_down() -> void:
	shop.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_settings_button_down() -> void:
	_hide_all_panels()
	settings.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_backk_button_down() -> void:
	settings.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_profile_button_down() -> void:
	_hide_all_panels()
	profile.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_profile_button_down() -> void:
	profile.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_inventory_button_down() -> void:
	_hide_all_panels()
	inventory.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_inventory_button_down() -> void:
	inventory.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true

func _on_leaderboards_button_down() -> void:
	_hide_all_panels()
	leaderboards.visible = true
	if whiteboard_layer: whiteboard_layer.visible = false

func _on_back_leaderboards_button_down() -> void:
	leaderboards.visible = false
	if whiteboard_layer: whiteboard_layer.visible = true
