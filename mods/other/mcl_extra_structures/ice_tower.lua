local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures.register_structure("ice_tower",{
	place_on = {"group:ice", "group:dirt", "group:grass_block", "mcl_core:ice"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	chunk_probability = 800,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "IcePlains", "IcePlainsSpikes" },
	sidelen = 25,
	construct_nodes = {"mcl_books:bookshelf", "mcl_furnaces:furnace", "mcl_grindstone:grindstone"},
	filenames = {
		modpath.."/schematics/mcl_extra_structures_ice_tower.mts",
	},
	loot = {
		["mcl_barrels:barrel_closed"] ={{
			stacks_min = 6,
			stacks_max = 10,
			items = {
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:cookie", weight = 15, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:sprucetree", weight = 15, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_tools:pick_iron", weight = 6, },
				{ itemstring = "mcl_tools:shovel_iron", weight = 6, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 1, func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_armor:leggings_iron", weight = 2, func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
				{ itemstring = "mcl_bows:arrow", weight = 15, amount_min = 2, amount_max=7 },
				{ itemstring = "mcl_bows:bow", weight = 5, func = function(stack, pr) mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr) end },
			}
		}}
	},
	after_place = function(pos, def, pr)
		local p1 = vector.offset(pos,-5,-3,-5)
		local p2 = vector.offset(pos,10,25,10)
		for _,n in pairs(minetest.find_nodes_in_area(p1,p2,{"group:fence"})) do
			local def = minetest.registered_nodes[minetest.get_node(n).name:gsub("_%d+$","")]
			if def and def.on_construct then
				def.on_construct(n)
			end
		end
		mcl_structures.spawn_mobs("mobs_mc:illusioner",{"mcl_beds:bed_light_blue_bottom"},p1,p2,pr,1)
	end
})
