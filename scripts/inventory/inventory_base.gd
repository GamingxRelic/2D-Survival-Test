extends Node
class_name Inventory

@export var slots : int
var items : Array[Item]

func add_item(item : Item):
	for i in items:
		if i.id == item.id and i.quantity < i.max_quantity:
			if i.quantity + item.quantity < i.max_quantity:
				i.quantity += item.quantity
				return
			else:
				var difference := i.max_quantity - i.quantity
				i.quantity = i.max_quantity
				item.quantity -= difference
				if item.quantity > 0:
					add_item(item)
				return
			
	items.append(item)

func print_info():
	for i in items:
		print(str(i.name) + " - " +str(i.quantity))
	print("----------------")
