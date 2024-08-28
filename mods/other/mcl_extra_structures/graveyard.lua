local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures.register_structure("graveyard",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = function(pr) return -(pr:next(3,3)) end,
	chunk_probability = 400,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "BirchForest", "Forest", "Plains", "Taiga" },
	sidelen = 10,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_graveyard_1.mts",
		modpath.."/schematics/mcl_extra_structures_graveyard_2.mts",
	},
	loot = {
		["mcl_barrels:barrel_closed"] ={{
			stacks_min = 2,
			stacks_max = 6,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:sword_diamond", weight = 15, },
				{ itemstring = "mcl_tools:pick_diamond", weight = 15, },
				{ itemstring = "mcl_tools:shovel_iron", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_armor:chestplate_diamond", weight = 1 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 2 },
			}
		}}
	},
	after_place = function(pos, def, pr)
		local p1 = vector.offset(pos,-5,-3,-5)
		local p2 = vector.offset(pos,5,4,5)
		local sp = minetest.find_nodes_in_area(pos,vector.offset(pos,0,3,0),{"mcl_mobspawners:spawner"})
		if not sp[1] then return end
		mcl_mobspawners.setup_spawner(sp[1], "mobs_mc:zombie", 0, minetest.LIGHT_MAX+1, 10, 3, -1)
		for _,n in pairs(minetest.find_nodes_in_area(p1,p2,{"group:wall"})) do
			local def = minetest.registered_nodes[minetest.get_node(n).name:gsub("_%d+$","")]
			if def and def.on_construct then
				def.on_construct(n)
			end
		end
	end
})
