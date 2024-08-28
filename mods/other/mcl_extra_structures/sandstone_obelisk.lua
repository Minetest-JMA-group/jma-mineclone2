--||||||||||||||||||||||
--|||||| Obelisks ||||||
--||||||||||||||||||||||

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

-- Sandstone Obelisk, sandstone capped
mcl_structures.register_structure("sandstone_obelisk",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = 0,
	chunk_probability = 300,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert" },
	sidelen = 1,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_sandstone_obelisk.mts",
	},
})

-- Sandstone Obelisk, iron capped
mcl_structures.register_structure("iron_sandstone_obelisk",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = 0,
	chunk_probability = 600,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert" },
	sidelen = 1,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_iron_sandstone_obelisk.mts",
	},
})

-- Sandstone Obelisk, diamond capped
mcl_structures.register_structure("diamond_sandstone_obelisk",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = true,
	y_offset = 0,
	chunk_probability = 900,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert" },
	sidelen = 1,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_diamond_sandstone_obelisk.mts",
	},
})
