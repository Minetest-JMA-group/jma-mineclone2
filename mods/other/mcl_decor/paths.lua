-- mcl_decor/paths.lua

local S = minetest.get_translator(minetest.get_current_modname())

-- API
function mcl_decor.register_path(name, desc, material, tiles, sgroup, sounds)
	local ndef = minetest.registered_nodes[material]
	local texture = "mcl_decor_path_alpha.png^"..ndef.tiles[1].."^" ..
				"mcl_decor_path_alpha.png^[makealpha:255,126,126"

	minetest.register_node("mcl_decor:"..name.."_path", {
		description = desc,
		tiles = ndef.tiles,
		wield_image = texture,
		inventory_image = texture,
		groups = {handy=1, [sgroup]=1, attached_node=1, dig_by_piston=1, deco_block=1},
		drawtype = "nodebox",
		paramtype = "light",
		sunlight_propagates = true,
		buildable_to = true,
		walkable = true,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.4375, -0.5, -0.4375, -0.125, -0.4375, -0.125},
				{-0.125, -0.5, -0.0625, 0.0625, -0.4375, 0.125},
				{-0.3125, -0.5, 0.1875, -0.0625, -0.4375, 0.4375},
				{0.0625, -0.5, -0.375, 0.25, -0.4375, -0.1875},
				{0.125, -0.5, 0.125, 0.375, -0.4375, 0.375},
				{0.25, -0.5, -0.125, 0.375, -0.4375, 0},
				{-0.4375, -0.5, 0, -0.3125, -0.4375, 0.125},
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			}
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.4375, 0.5},
			}
		},
		_mcl_blast_resistance = 0.3,
		_mcl_hardness = 0.3,
		sounds = sounds
	})
	
	minetest.register_craft({
		output = "mcl_decor:"..name.."_path".." 16",
		recipe = {
			{material, "", material},
			{"", material, ""},
			{material, "", material}
		}
	})
end



-- REGISTER
mcl_decor.register_path(
	"gravel",
	S("Gravel Path"),
	"mcl_core:gravel",
	"default_gravel.png",
	"shovely",
	mcl_sounds.node_sound_dirt_defaults({footstep = {name="default_gravel_footstep", gain=0.45}})
)
mcl_decor.register_path(
	"cobble",
	S("Cobblestone Path"),
	"mcl_core:cobble",
	"default_cobble.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"stone",
	S("Stone Path"),
	"mcl_core:stone",
	"default_stone.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"granite",
	S("Granite Path"),
	"mcl_core:granite",
	"mcl_core_granite.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"andesite",
	S("Andesite Path"),
	"mcl_core:andesite",
	"mcl_core_andesite.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"diorite",
	S("Diorite Path"),
	"mcl_core:diorite",
	"mcl_core_diorite.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"netherrack",
	S("Netherrack Path"),
	"mcl_nether:netherrack",
	"mcl_nether_netherrack.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"deepslate",
	S("Deepslate Path"),
	"mcl_deepslate:deepslate",
	"mcl_deepslate_top.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
mcl_decor.register_path(
	"deepslate_cobbled",
	S("Cobbled Deepslate Path"),
	"mcl_deepslate:deepslate_cobbled",
	"mcl_cobbled_deepslate.png",
	"pickaxey",
	mcl_sounds.node_sound_stone_defaults()
)
