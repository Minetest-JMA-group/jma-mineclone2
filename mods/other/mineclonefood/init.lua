
local S = minetest.get_translator(minetest.get_current_modname())
local mod = minetest.get_modpath("mineclonefood")

dofile(mod .. "/crafting.lua") -- load Crafting Recipes



--[[
--drop


if minetest.registered_nodes["mcl_trees:sapling_cherry_blossom"] then

	minetest.override_item("mcl_cherry_blossom:cherryleaves", {
		drop = {
			max_items = 1,
			items = {
				{items = {"mineclonefood:cherry"}, rarity = 8},
				{items = {"mcl_trees:sapling_cherry_blossom"}, rarity = 8},
			}
		}
	})
end

if minetest.registered_nodes["mcl_cherry_blossom:cherrysapling"] then

	minetest.override_item("mcl_cherry_blossom:cherryleaves", {
		drop = {
			max_items = 1,
			items = {
				{items = {"mineclonefood:cherry"}, rarity = 8},
				{items = {"mcl_cherry_blossom:cherrysapling"}, rarity = 8},
			}
		}
	})
end
--]]


--achievements

awards.register_achievement("mineclonefood:cherry_eating", {
	title = S("Don't smack your lips like that!"),
	icon = "mineclonefood_cherry.png",
	description = S("Eat a Cherry."),
	trigger = {
		type = "eat",
		item= "mineclonefood:cherry",
		target = 1,
	}
})

--Items

--Cherry

minetest.register_craftitem("mineclonefood:cherry", {
	description = S("Cherry"),
	inventory_image = "mineclonefood_cherry.png",
	groups = {food=2, eatable=2},
	_mcl_saturation = 2,
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
})













--Cherryjuce

minetest.register_craftitem("mineclonefood:cherryjuce", {
	description = S("Cherryjuce"),
	inventory_image = "mineclonefood_cherryjuce.png",
	stack_max = 1,
	groups = {food=3, eatable=14 },
	_mcl_saturation = 6,
	on_place = minetest.item_eat(6, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(6, "mcl_potions:glass_bottle"),
})











--Cherrycake

minetest.register_craftitem("mineclonefood:cherry_cake", {
	description = S("Cherrycake"),
	inventory_image = "mineclonefood_cherrycake.png",
	groups = {food=2, eatable=14},
	_mcl_saturation = 8,
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
})










--Cherrysugar

minetest.register_craftitem("mineclonefood:cherrysugar", {
	description = S("Cherrysugar"),
	inventory_image = "mineclonefood_cherrysugar.png",
	groups = {food=2, eatable=14},
	_mcl_saturation = 4,
	on_place = minetest.item_eat(3),
	on_secondary_use = minetest.item_eat(3),
})











--Cherryloly

minetest.register_craftitem("mineclonefood:cherryloly", {
	description = S("Cherryloly"),
	inventory_image = "mineclonefood_cherryloly.png",
	groups = {food=2, eatable=14},
	_mcl_saturation = 2,
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
})











--sandcake

minetest.register_craftitem("mineclonefood:sandcake", {
	description = S("Sandcake"),
	inventory_image = "mineclonefood_sandcake.png",
	groups = {food=2, eatable=14},
	_mcl_saturation = 5,
	on_place = minetest.item_eat(12),
	on_secondary_use = minetest.item_eat(12),
})










--firecake

minetest.register_craftitem("mineclonefood:firecake", {
	description = S("Firecake"),
	inventory_image = "mineclonefood_firecake.png",
	groups = {food=2, eatable=14},
	_mcl_saturation = 5,
	on_place = minetest.item_eat(12),
	on_secondary_use = minetest.item_eat(12),
})












--Sunfloweroil

minetest.register_craftitem("mineclonefood:sunfloweroil", {
	description = S("Sunfloweroil"),
	inventory_image = "mineclonefood_sunfloweroil.png",
	groups = {food=3, eatable=2},
	_mcl_saturation = 2,
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
})


















--Cherrybonbon

minetest.register_craftitem("mineclonefood:cherrybonbon", {
	description = S("Cherrybonbon"),
	inventory_image = "mineclonefood_cherrybonbon.png",
	groups = {food=2, eatable=4},
	_mcl_saturation = 2,
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
})














--Icecream(






--Cherry_Icecream

minetest.register_craftitem("mineclonefood:cherry_icecream", {
	description = S("Cherry Icecream"),
	inventory_image = "mineclonefood_cherry_icecream.png",
	groups = { craftitem = 1, food = 3, eatable = 6, },
	on_place = minetest.item_eat(6, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(6, "mcl_core:bowl"),
	_mcl_saturation = 1.2,
	stack_max = 1,
})










--Sweet_berry_Icecream

minetest.register_craftitem("mineclonefood:sweet_berry_icecream", {
	description = S("Sweet Berry Icecream"),
	inventory_image = "mineclonefood_sweet_berry_icecream.png",
	groups = { craftitem = 1, food = 3, eatable = 6, },
	on_place = minetest.item_eat(6, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(6, "mcl_core:bowl"),
	_mcl_saturation = 1.2,
	stack_max = 1,
})




--Icecream)

















--Roasted Potatoes

minetest.register_craftitem("mineclonefood:roasted_potatoes", {
	description = S("Roasted Potatoes"),
	inventory_image = "mineclonefood_roasted_potatoes.png",
	groups = {food=2, eatable=14},
	_mcl_saturation = 6,
	on_place = minetest.item_eat(14),
	on_secondary_use = minetest.item_eat(14),
})
