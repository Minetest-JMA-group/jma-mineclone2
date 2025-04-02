import random

# Variables
abm_interval = 60
abm_chance = 2
fish_values = [92, 92.8, 95, 92.5]
junk_values = [10, 8.1, 7, 9]

fish_loot = [
    { 'itemstring': "mcl_fishing:fish_raw", 'weight': 60 },
	{ 'itemstring': "mcl_fishing:salmon_raw", 'weight': 25 },
	{ 'itemstring': "mcl_fishing:clownfish_raw", 'weight': 2 },
	{ 'itemstring': "mcl_fishing:pufferfish_raw", 'weight': 13 },
]

junk_loot = [
    { 'itemstring': "mcl_core:bowl", 'weight': 10 },
    { 'itemstring': "mcl_fishing:fishing_rod", 'weight': 2, 'wear_min': 6554, 'wear_max': 65535 }, # 10%-100% damage
    { 'itemstring': "mcl_mobitems:leather", 'weight': 10 },
    { 'itemstring': "mcl_armor:boots_leather", 'weight': 10, 'wear_min': 6554, 'wear_max': 65535 }, # 10%-100% damage
    { 'itemstring': "mcl_mobitems:rotten_flesh", 'weight': 10 },
    { 'itemstring': "mcl_core:stick", 'weight': 5 },
    { 'itemstring': "mcl_mobitems:string", 'weight': 5 },
    { 'itemstring': "mcl_potions:water", 'weight': 5 },
    { 'itemstring': "mcl_mobitems:bone", 'weight': 10 },
    { 'itemstring': "mcl_dye:black", 'weight': 1, 'amount_min': 10, 'amount_max': 10 },
    { 'itemstring': "mcl_mobitems:string", 'weight': 10 },
]

treasure_loot = [
    { 'itemstring': "mcl_bows:bow", 'weight': 0.5, 'wear_min': 49144, 'wear_max': 65535 }, # 75%-100% damage
    { 'itemstring': "mcl_books:book", 'weight': 0.5},
    { 'itemstring': "mcl_fishing:fishing_rod", 'weight': 1, 'wear_min': 49144, 'wear_max': 65535}, # 75%-100% damage
    { 'itemstring': "mcl_mobs:nametag", 'weight': 2},
    { 'itemstring': "mcl_mobitems:saddle", 'weight': 2},
    { 'itemstring': "mcl_flowers:waterlily", 'weight': 15},
    { 'itemstring': "mcl_mobitems:nautilus_shell", 'weight': 15},
]

def get_loot(l):
    items = []
    
    total_weight = sum(item.get('weight', 1) for item in l)

    for _ in range(1):
        r = random.randint(1, total_weight)

        accumulated_weight = 0
        selected_item = None

        for item in l:
            accumulated_weight += item.get('weight', 1)
            if accumulated_weight >= r:
                selected_item = item
                break 

        if selected_item:
            items.append(selected_item)
        else:
            print("ERROR: Failed to select random loot item!")

    return items


def run_abm():
    random_value = random.randint(1, 100)
    if random.randint(1, abm_chance) == 1:
        fv = fish_values[random.randint(1, len(fish_values))-1]
        jv = junk_values[random.randint(1, len(junk_values))-1]
        for jv in junk_values:
            if random_value <= fv:
                return get_loot(fish_loot)[0]
            elif random_value <= jv:
                return get_loot(junk_loot)[0]
            else:
                return get_loot(treasure_loot)[0]

tests = 10000

print(f"Simulating drops over 60 minutes (average out of {tests} hours)")

totals = 0
results = {}

for _ in range(tests):
    total = 0
    for _ in range(60):
        i = run_abm()
        if i:
            if i['itemstring'] in results:
                results[i['itemstring']] = results[i['itemstring']] + 1
            else:
                results[i['itemstring']] = 1
            total = total + 1

    #for item in results:
        #print(f"{results[item]} x {item}")

    #print(f"TOTAL: {total}")

    totals = totals + total

for item in results:
    print(f"{results[item]/tests} x {item}")

print(f"===\nAverage items per hour: {totals/tests}")