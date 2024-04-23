-- Crafting
local planks = "mcl_cherry_blossom:cherrywood"
local logs = "mcl_cherry_blossom:cherrytree"
local stripped_logs = "mcl_cherry_blossom:stripped_cherrytree"

minetest.register_craft({
	output = "mcl_cherry_blossom:cherrytree_bark 3",
	recipe = {
		{ logs, logs },
		{ logs, logs },
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:stripped_cherrytree_bark 3",
	recipe = {
		{ stripped_logs, stripped_logs },
		{ stripped_logs, stripped_logs },
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:cherrywood 4",
	recipe = {
		{ logs },
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:cherry_door 3",
	recipe = {
		{planks, planks},
		{planks, planks},
		{planks, planks}
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:cherry_trapdoor 2",
	recipe = {
		{planks, planks, planks},
		{planks, planks, planks},
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:cherry_fence 3",
	recipe = {
		{planks, "mcl_core:stick", planks},
		{planks, "mcl_core:stick", planks},
	}
})
minetest.register_craft({
	output = "mcl_cherry_blossom:cherry_fence_gate",
	recipe = {
		{"mcl_core:stick", planks, "mcl_core:stick"},
		{"mcl_core:stick", planks, "mcl_core:stick"},
	}
})

mcl_signs.register_sign_craft("mcl_cherry_blossom", "mcl_cherry_blossom:cherrywood", "_cherrywood")

-- Smelting
minetest.register_craft({
	type = "fuel",
	recipe = "mcl_cherry_blossom:cherry_door",
	burntime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_cherry_blossom:cherry_trapdoor",
	burntime = 15,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_cherry_blossom:pressure_plate_cherrywood_off",
	burntime = 15
})

minetest.register_craft({
	type = "fuel",
	recipe = "mesecons_button:button_cherrywood_off",
	burntime = 5,
})
