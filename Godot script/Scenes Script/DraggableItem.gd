extends TextureRect

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview = TextureRect.new()
	preview.texture = self.texture
	preview.size = self.size / 2
	preview.modulate.a = 0.5
	set_drag_preview(preview)
	
	var data = get_meta("item_data")
	return data
