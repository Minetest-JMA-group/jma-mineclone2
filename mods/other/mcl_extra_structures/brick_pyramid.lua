local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

mcl_structures.register_structure("brick_pyramid",{
	place_on = {"group:dirt"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	make_foundation = false,
	y_offset = function(pr) return -(pr:next(0,1)) end,
	chunk_probability = 1200,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Plains" },
	--sidelen = 18,
	filenames = {
		modpath.."/schematics/mcl_extra_structures_brick_pyramid.mts",
	},
})
