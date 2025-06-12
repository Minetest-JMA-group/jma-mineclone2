core.register_craftitem("dino_nuggets:stegosaurus", {
	description = S("Dino Nuggets"),
	_doc_items_longdesc = S("Dino Nuggets are made from cooked chicken. Very tasty!"),
	inventory_image = "dino_nuggets_stegosaurus.png",
	wield_image = "dino_nuggets_stegosaurus.png",
	on_place = core.item_eat(2),
	on_secondary_use = core.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 2,
	stack_max = 64,
})

core.register_craftitem("dino_nuggets:brachiosaurus", {
	description = S("Dino Nuggets"),
	_doc_items_longdesc = S("Dino Nuggets are made from cooked chicken. Very tasty!"),
	inventory_image = "dino_nuggets_brachiosaurus.png",
	wield_image = "dino_nuggets_brachiosaurus.png",
	on_place = core.item_eat(2),
	on_secondary_use = core.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 2,
	stack_max = 64,
})

core.register_craftitem("dino_nuggets:trex", {
	description = S("Dino Nuggets"),
	_doc_items_longdesc = S("Dino Nuggets are made from cooked chicken. Very tasty!"),
	inventory_image = "dino_nuggets_trex.png",
	wield_image = "dino_nuggets_trex.png",
	on_place = core.item_eat(2),
	on_secondary_use = core.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 2,
	stack_max = 64,
})

core.register_craft({
	output = "dino_nuggets:stegosaurus 6",
	recipe = {
		{"mcl_mobitems:cooked_chicken", "mcl_mobitems:cooked_chicken", }
	},
})

core.register_craft({
	output = "dino_nuggets:brachiosaurus 6",
	recipe = {
		{"mcl_mobitems:cooked_chicken", ""},
		{"", "mcl_mobitems:cooked_chicken"}
	},
})

core.register_craft({
	output = "dino_nuggets:trex 6",
	recipe = {
		{"mcl_mobitems:cooked_chicken",},
		{"mcl_mobitems:cooked_chicken",},
	},
})

core.register_alias("dino_nuggets:stegosaurus", "mcl_mobitems:dino_nuggets_stegosaurus")
core.register_alias("dino_nuggets:brachiosaurus", "mcl_mobitems:dino_nuggets_brachiosaurus")
core.register_alias("dino_nuggets:trex", "mcl_mobitems:dino_nuggets_trex")