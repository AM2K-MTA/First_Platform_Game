extends ConsumableItem

var remaining_uses := 3

func interaction_interact(interactionComponentParent : Node) -> void:
	print("Drank coffee!")
	remaining_uses -= 1
	if (remaining_uses <= 0):
		queue_free()

func interaction_get_text() -> String:
	if (remaining_uses == 3):
		return "3x Drink"
	elif (remaining_uses == 2):
		return "2x Drink"
	elif (remaining_uses == 1):
		return "1x Drink"
	else:
		return "else lol"
		#return String(remaining_uses) + " remaining use"
