extends PanelContainer
class_name InventorySlot

@export var type: ItemData.Type
var current_item: InventoryItem = null

# Custom init function so that it doesn't error
func init(t: ItemData.Type, cms: Vector2) -> void:
	type = t
	custom_minimum_size = cms
	
	# Enable drop detection
	mouse_filter = Control.MOUSE_FILTER_PASS
	#gui_input.connect(_on_gui_input)

func _can_drop_data(at_position: Vector2, data) -> bool:
	# Check if the dropped data is an InventoryItem
	if data is InventoryItem:
		var item_data = data.data
		# Check if the slot type matches the item type (or allow any type)
		if type == ItemData.Type.MAIN or item_data.type == type:
			# Check if slot is empty or can stack
			return current_item == null
	return false

func _drop_data(at_position: Vector2, data) -> void:
	if data is InventoryItem:
		# Remove item from its previous parent
		var previous_parent = data.get_parent()
		if previous_parent and previous_parent is InventorySlot:
			previous_parent.current_item = null
		
		# Add item to this slot
		data.get_parent().remove_child(data)
		add_child(data)
		current_item = data
		
		# Center the item in the slot
		data.position = Vector2.ZERO
