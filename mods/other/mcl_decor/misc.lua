-- mcl_decor/misc.lua

local S = minetest.get_translator(minetest.get_current_modname())

--- Checkerboard Tile ---
minetest.register_node("mcl_decor:checkerboard_tile", {
	description = S("Checkerboard Tile"),
	tiles = {"mcl_decor_coalquartz_tile.png"},
	is_ground_content = false,
	groups = {pickaxey=1, quartz_block=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 3,
})
minetest.register_craft({
	output = "mcl_decor:checkerboard_tile 4",
	recipe = {
		{"mcl_blackstone:blackstone", "mcl_nether:quartz_block"},
		{"mcl_nether:quartz_block", "mcl_blackstone:blackstone"}
	}
})
minetest.register_craft({
	output = "mcl_decor:checkerboard_tile 4",
	recipe = {
		{"mcl_nether:quartz_block", "mcl_blackstone:blackstone"},
		{"mcl_blackstone:blackstone", "mcl_nether:quartz_block"}
	}
})
mcl_stairs.register_stair_and_slab_simple("checkerboard_tile", "mcl_decor:checkerboard_tile", S("Checkerboard Stair"), S("Checkerboard Slab"), S("Double Checkerboard Slab"))



--- Table Lamp ---
local on_def = {
	description = S("Table Lamp"),
	tiles = {"mcl_decor_table_lamp.png"},
	use_texture_alpha = "clip",
	drawtype = "mesh",
	mesh = "mcl_decor_table_lamp.obj",
	paramtype = "light",
	stack_max = 64,
	selection_box = {
		type = "fixed",
		fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
	},
	is_ground_content = false,
	light_source = minetest.LIGHT_MAX,
	groups = {handy=1, axey=1, attached_node=1, deco_block=1, flammable=-1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.9,
	_mcl_hardness = 0.9,
	on_rightclick = function(pos, node, _, itemstack)
		minetest.set_node(pos, {name="mcl_decor:table_lamp_off"})
		minetest.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=8}, true)
	end
}
minetest.register_node("mcl_decor:table_lamp", on_def)

local off_def = table.copy(on_def)

off_def.tiles = {"mcl_decor_table_lamp_off.png"}
off_def.light_source = nil
off_def.drop = "mcl_decor:table_lamp"
off_def.groups.not_in_creative_inventory = 1
off_def._doc_items_create_entry = false
off_def.on_rightclick = function(pos, node, _, itemstack)
	minetest.set_node(pos, {name="mcl_decor:table_lamp"})
	minetest.sound_play("mesecons_button_push", {pos=pos, max_hear_distance=8}, true)
end

minetest.register_node("mcl_decor:table_lamp_off", off_def)

minetest.register_craft({
	output = "mcl_decor:table_lamp 3",
	recipe = {
		{"group:wool", "group:wool", "group:wool"},
		{"group:wool", "mcl_torches:torch", "group:wool"},
		{"mcl_core:cobble", "mesecons:wire_00000000_off", "mcl_core:cobble"}
	}
})



-- Counter
minetest.register_node("mcl_decor:counter", {
	description = S("Counter"),
	tiles = {
		"default_obsidian.png",
		"default_obsidian.png",
		"default_obsidian.png^[lowpart:87:mcl_nether_quartz_block_bottom.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "connected",
		fixed = {
			{-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}, -- countertop
			{-0.4375, -0.5, -0.4375, 0.4375, 0.375, 0.4375}, -- base
		},
		connect_front = {
			{-0.4375, -0.5, -0.5, 0.4375, 0.375, -0.4375},
		},
		connect_back = {
			{-0.4375, -0.5, 0.4375, 0.4375, 0.375, 0.5},
		},
		connect_left = {
			{-0.5, -0.5, -0.4375, -0.4375, 0.375, 0.4375},
		},
		connect_right = {
			{0.4375, -0.5, -0.4375, 0.5, 0.375, 0.4375},
		},
	},
	connects_to = {"mcl_decor:counter", "mcl_decor:oven", "mcl_core:obsidian", "group:quartz_block"},
	groups = {pickaxey=1, deco_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 1.4,
	_mcl_hardness = 1.2,
})

minetest.register_craft({
	output = "mcl_decor:counter 2",
	recipe = {
		{"mcl_nether:quartz", "mcl_core:obsidian", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_nether:quartz", "mcl_nether:quartz"},
		{"mcl_nether:quartz", "mcl_nether:quartz", "mcl_nether:quartz"},
	}
})
