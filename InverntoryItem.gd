class_name InventoryItem
extends TextureRect

@export var data: ItemData
var description_popup: PopupPanel
var hover_timer: Timer

func init(d: ItemData) -> void:
	data = d

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture = data.texture
	
	# Enable mouse detection
	mouse_filter = Control.MOUSE_FILTER_PASS
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	# Create hover timer
	hover_timer = Timer.new()
	hover_timer.one_shot = true
	hover_timer.timeout.connect(_show_popup)
	add_child(hover_timer)

func _on_mouse_entered():
	# Start timer to show popup after short delay (0.5 seconds)
	hover_timer.start(0.5)

func _on_mouse_exited():
	# Stop timer and hide popup if visible
	hover_timer.stop()
	if description_popup and description_popup.visible:
		description_popup.hide()

func _show_popup():
	if not data:
		return
	
	# Create popup if it doesn't exist
	if not description_popup:
		description_popup = PopupPanel.new()
		description_popup.size = Vector2(300, 150)
		
		var margin = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 10)
		description_popup.add_child(margin)
		
		var vbox = VBoxContainer.new()
		margin.add_child(vbox)
		
		var title_label = Label.new()
		title_label.text = data.name
		title_label.add_theme_font_size_override("font_size", 16)
		title_label.add_theme_color_override("font_color", Color.GOLD)
		vbox.add_child(title_label)
		
		var desc_label = Label.new()
		desc_label.text = data.description
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.add_theme_font_size_override("font_size", 14)
		vbox.add_child(desc_label)
		
		add_child(description_popup)
	
	# Position popup near mouse
	var mouse_pos = get_global_mouse_position()
	description_popup.position = Vector2(mouse_pos.x + 20, mouse_pos.y + 20)
	description_popup.popup()

func _get_drag_data(at_position: Vector2):
	set_drag_preview(make_drag_preview(at_position))
	return self

func make_drag_preview(at_position: Vector2):
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size/2
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)
	
	return t

# Clean up when node is removed
func _exit_tree():
	if hover_timer:
		hover_timer.stop()
	if description_popup:
		description_popup.queue_free()
