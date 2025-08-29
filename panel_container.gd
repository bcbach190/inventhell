extends PanelContainer

var InvSize = 128
var itemLoad = [
	"res://itemsRes/rare.tres",
	"res://itemsRes/uncommon.tres",
	"res://itemsRes/common.tres"
]

func _ready():
	for i in InvSize:
		var slot := InventorySlot.new()
		slot.init(ItemData.Type.MAIN, Vector2(64, 64))
		%GridContainerINV.add_child(slot)
	
	for i in itemLoad.size():
		var item := InventoryItem.new()
		item.init(load(itemLoad[i]))
		%GridContainerINV.get_child(i).add_child(item)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		self.visible = !self.visible
