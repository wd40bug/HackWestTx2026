extends Node
class_name Hands

enum HandTypes {
	SINGLE_1 = 0x01,
	SINGLE_5 = 0x05,
	THREE_2 = 0x12,
	THREE_3 = 0x13,
	THREE_4 = 0x14,
	THREE_5 = 0x15,
	THREE_6 = 0x16,
	THREE_1 = 0x11,
	FOUR_OF_KIND = 0x20,
	FOUR_OF_KIND_1 = 0x21,
	STRAIGHT = 0x30,
	STRAIGHT_GAP = 0x91,
	THREE_PAIR = 0x40,
	FULL_HOUSE = 0x50,
	FIVE_OF_KIND = 0x60,
	FIVE_OF_KIND_1 = 0x61,
	TWO_TRIPLETS = 0x70,
	SIX_OF_KIND = 0x80,
	SIX_OF_KIND_1 = 0x81,
}

const HandVals: Dictionary[HandTypes, int] = {
	HandTypes.SINGLE_1: 100,
	HandTypes.SINGLE_5 : 50,
	HandTypes.THREE_2 : 200,
	HandTypes.THREE_3 : 300,
	HandTypes.THREE_4 : 400,
	HandTypes.THREE_5 : 500,
	HandTypes.THREE_6 : 600,
	HandTypes.THREE_1 : 1000,
	HandTypes.FOUR_OF_KIND : 1000,
	HandTypes.FOUR_OF_KIND_1 : 1500,
	HandTypes.STRAIGHT : 1500,
	HandTypes.STRAIGHT_GAP : 1500,
	HandTypes.THREE_PAIR : 1500,
	HandTypes.FULL_HOUSE : 1500,
	HandTypes.FIVE_OF_KIND : 2000,
	HandTypes.FIVE_OF_KIND_1 : 2500,
	HandTypes.TWO_TRIPLETS : 2500,
	HandTypes.SIX_OF_KIND : 3000,
	HandTypes.SIX_OF_KIND_1 : 3500,
}

const optimal_iteration = [6, 4, 3, 2, 5, 1]

static func find_best_grouping(sizes: Array[int], counts: Dictionary[int, int], wilds: int) -> Array[int]:
	var sum = func(a, b): return a + b
	if counts.values().reduce(sum, 0) + wilds < sizes.reduce(sum, 0):
		return []
	var valid_combos: Array[Dictionary] = []
	search_grouping(sizes, counts, wilds, 0, [], valid_combos)
	
	if valid_combos.is_empty():
		return []
		
	# Multi-tier sort
	valid_combos.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a.wilds_used != b.wilds_used:
			return a.wilds_used < b.wilds_used # Priority 1: Fewest wilds
		if a.ones_used != b.ones_used:
			return a.ones_used < b.ones_used   # Priority 2: Fewest 1s
		return a.fives_used < b.fives_used     # Priority 3: Fewest 5s
	)
	return valid_combos[0].faces

static func search_grouping(sizes: Array[int], counts: Dictionary[int, int], current_wilds: int, step: int, current_faces: Array[int], valid_combos: Array[Dictionary]) -> void:
	if step == sizes.size():
		# Base case, succeeded
		var total_wilds = 0
		var ones = 0
		var fives = 0
		
		for i in range(sizes.size()):
			var face = current_faces[i]
			var size = sizes[i]
			
			var wilds_needed = max(0, size - counts[face])
			total_wilds += wilds_needed
			
			var natural_dice_used = size - wilds_needed
			if face == 1:
				ones += natural_dice_used
			elif face == 5:
				fives += natural_dice_used
			
		valid_combos.append({
			"faces": current_faces.duplicate(),
			"wilds_used": total_wilds,
			"ones_used": ones,
			"fives_used": fives
		})
		return
	
	var target_size = sizes[step]
	var start_idx = 0
	
	if step > 0 and sizes[step] == sizes[step - 1]:
		start_idx = optimal_iteration.find(current_faces[step - 1]) + 1
	
	for i in range(start_idx, optimal_iteration.size()):
		var face = optimal_iteration[i]
		
		if face in current_faces:
			continue
		
		if counts[face] + current_wilds >= target_size:
			var wilds_needed = max(0, target_size - counts[face])
			current_faces.append(face)
			search_grouping(sizes, counts, current_wilds - wilds_needed, step + 1, current_faces, valid_combos)
			current_faces.pop_back()

class CalculateHandsReturn extends RefCounted:
	var hands: Array[HandTypes]
	var remainder: Array[Die_side.DieType] = []

static func calculate_hands(dice: Array[Die_side.DieType], gap_in_straight: bool) -> CalculateHandsReturn:
	var hand = HandTypes.SIX_OF_KIND_1
	
	var counts: Dictionary[int, int] = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}
	var wilds = [0]
	
	var ret: Array[HandTypes]
	
	for die in dice:
		if (die == Die_side.DieType.WILD):
			wilds[0] += 1
		else:
			counts[die] += 1
	
	var consume = func(die_val: int, amount: int):
		var actual_taken = min(counts[die_val], amount)
		counts[die_val] -= actual_taken
		# wilds[0] are used if needed
		wilds[0] -= (amount - actual_taken)
	
	# Six of a kind
	if counts[1] + wilds[0] == 6:
		ret.append(HandTypes.SIX_OF_KIND_1)
		consume.call(1, 6)
	
	for v in range(6, 1, -1):
		if counts[v] + wilds[0] >= 6:
			ret.append(HandTypes.SIX_OF_KIND)
			consume.call(v, 6)
	
	# Two triple
	var two_triple_faces = find_best_grouping([3, 3], counts, wilds[0])
	if not two_triple_faces.is_empty():
		consume.call(two_triple_faces[0], 3)
		consume.call(two_triple_faces[1], 3)
		ret.append(HandTypes.TWO_TRIPLETS)
	
	# Five of a kind
	if counts[1] + wilds[0] >= 5:
		ret.append(HandTypes.FIVE_OF_KIND_1)
		consume.call(1, 5)
	
	for v in range(6, 1, -1):
		if counts[v] + wilds[0] == 5:
			ret.append(HandTypes.FIVE_OF_KIND)
			consume.call(v, 5)
	
	# Full House
	var full_house_faces = find_best_grouping([4, 2], counts, wilds[0])
	if not full_house_faces.is_empty():
		consume.call(full_house_faces[0], 4)
		consume.call(full_house_faces[1], 2)
		ret.append(HandTypes.FULL_HOUSE)
	
	# Three Pair
	var three_pair_faces = find_best_grouping([2, 2, 2], counts, wilds[0])
	if not three_pair_faces.is_empty():
		consume.call(three_pair_faces[0], 2)
		consume.call(three_pair_faces[1], 2)
		consume.call(three_pair_faces[2], 2)
		ret.append(HandTypes.THREE_PAIR)
	
	# Straight
	var straight_wilds_used = 0
	var gap_used = not gap_in_straight
	var gapped_val = 0
	for i in range(1, 7):
		if counts[i] == 0 && wilds[0] == straight_wilds_used && gap_used:
			break
		elif counts[i] == 0:
			if not gap_used:
				gap_used = true
				gapped_val = i
			else:
				straight_wilds_used += 1
		
		if i == 6:
			for j in range(1, 7):
				if (j == gapped_val):
					continue
				consume.call(j, 1)
			ret.append(HandTypes.STRAIGHT if not gap_in_straight || not gap_used else HandTypes.STRAIGHT_GAP)
			break
	
	# Four of a kind
	while counts[1] + wilds[0] >= 4:
		ret.append(HandTypes.FOUR_OF_KIND_1)
		consume.call(1, 4)
	
	for v in range(6, 1, -1):
		while counts[v] + wilds[0] >= 4:
			ret.append(HandTypes.FOUR_OF_KIND)
			consume.call(v, 4)
	
	# Three of a kind
	if counts[1] + wilds[0] == 3:
		ret.append(HandTypes.THREE_1)
		consume.call(1, 3)
	
	for v in range(6, 1, -1):
		if counts[v] + wilds[0] == 3:
			ret.append(0x10 | v)
			consume.call(v, 3)
	
	# Singles
	if counts[1] + wilds[0]>= 1:
		for i in range(counts[1] + wilds[0]):
			ret.append(HandTypes.SINGLE_1)
		consume.call(1, counts[1] + wilds[0])

			
	if counts[5] + wilds[0]>= 1:
		for i in range(counts[5] + wilds[0]):
			ret.append(HandTypes.SINGLE_5)
		consume.call(5, counts[5] + wilds[0])

	
	var ret_cls = CalculateHandsReturn.new()
	ret_cls.hands = ret
	for i in counts:
		for j in range(counts[i]):
			ret_cls.remainder.append(i)
	return ret_cls
