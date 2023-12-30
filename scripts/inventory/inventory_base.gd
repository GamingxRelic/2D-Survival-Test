extends Node
class_name InventoryBase

var items : Array[Item]
var full := false

@export var size : int :
	set(value):
		size = value if value > 0 else 1
		items.resize(size)
	get:
		return size

func _ready() -> void:
	items.resize(size)

func add_item(item : Item) -> bool:
	for i in items:
		if i != null and i.id == item.id and i.quantity < i.max_quantity:
			if i.quantity + item.quantity < i.max_quantity:
				i.quantity += item.quantity
				return true
			else:
				var difference := i.max_quantity - i.quantity
				i.quantity = i.max_quantity
				item.quantity -= difference
				if item.quantity > 0:
					add_item(item)
				else:
					return true
	
	is_full()
	
	if !full:
		for i in items.size():
			if items[i] == null:
				items[i] = item
				return true

	return false

func is_full() -> bool:
	full = true
	
	for i in items.size():
		if items[i] == null:
			full = false
			
	return full

func print_inv() -> void:
	print("------- Inventory ---------")
	for i in items:
		if i != null:
			print(str(i.name) + " - " +str(i.quantity))
		else:
			print("<null>")
	
func sort() -> void:
	# Combine stacks
	# Quicksort based on quantity
	# Split stacks into appropriate quantities
	var new_array : Array[Item] = []
	
	# Combine stacks into big stacks
	_sort_combine(new_array)
	_sort_quicksort(new_array)
	_sort_split(new_array)
	
func _sort_combine(new_array : Array[Item]) -> void:
	for item in items:
			if item != null:
				var found = false
				for new_item in new_array:
					if item.id == new_item.id and new_item.max_quantity > 1:
						found = true
						new_item.quantity += item.quantity
				if !found:
					new_array.append(item.duplicate())

# TODO:
# Improve quicksort with this:

#func quicksort(arr, low, high):
	#if low < high:
		#var pivot_index = partition(arr, low, high)
		#quicksort(arr, low, pivot_index - 1)
		#quicksort(arr, pivot_index + 1, high)
#
#func partition(arr, low, high) -> int:
	#var pivot = arr[high]
	#var i = low - 1
#
	#for j in range(low, high):
		#if arr[j].quantity >= pivot.quantity:
			#i += 1
			#swap(arr, i, j)
#
	#swap(arr, i + 1, high)
	#return i + 1
#
#func swap(arr, i, j):
	#var temp = arr[i]
	#arr[i] = arr[j]
	#arr[j] = temp


func _sort_quicksort(new_array : Array[Item]) -> void:
	for i in new_array.size():
		for j in new_array.size():
			if j+1 < new_array.size():
				var curr = new_array[j]
				var next := new_array[j+1]
			
				# If current item quantity is less than next item quantity, swap them
				if curr.quantity < next.quantity:
					var temp = curr
					new_array[j] = next
					new_array[j+1] = temp

func _sort_split(array : Array[Item]) -> void:
	var new_items_array : Array[Item] = []
	
	for item in array:
		while item.quantity > item.max_quantity:
			var difference = abs(item.max_quantity - item.quantity)
			item.quantity = difference
			
			var new_item := item.duplicate() as Item
			new_item.quantity = new_item.max_quantity
			new_items_array.append(new_item)
			
		if item.quantity > 0:
			new_items_array.append(item.duplicate())
	
	items.clear()
	array.clear()
	items = new_items_array
	items.resize(size)
