-- mcl_decor/wooden.lua

local S = minetest.get_translator(minetest.get_current_modname())

-- API
function mcl_decor.register_chair_and_table(name, desc, desc2, material, tiles, flammable)
	local group = {handy=1, axey=1, attached_node=1, material_wood=1, deco_block=1}
	local burntime = 0
	-- assume flammable by default
	if flammable or (flammable == nil) then
		group.fire_encouragement = 5
		group.fire_flammability = 20
		burntime = 8
	end

	-- chair part
	minetest.register_node("mcl_decor:"..name.."_chair", {
		description = desc,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.25, 0, 0.125, 0.25, 0.5, 0.25},
				{-0.25, -0.125, -0.25, 0.25, 0, 0.25},
				{-0.25, -0.5, 0.125, -0.125, -0.125, 0.25},
				{0.125, -0.5, -0.25, 0.25, -0.125, -0.125},
				{0.125, -0.5, 0.125, 0.25, -0.125, 0.25},
				{-0.25, -0.5, -0.25, -0.125, -0.125, -0.125},
			}
		},
		tiles = {tiles},
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		stack_max = 64,
		sunlight_propagates = true,
		selection_box = {
			type = "fixed",
			fixed = { -0.25, -0.5, -0.25, 0.25, 0.5, 0.25 },
		},
		groups = group,
		_mcl_hardness = 1,
		_mcl_blast_resistance = 1,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rightclick = mcl_decor.sit
	})
	minetest.register_craft({
		output = "mcl_decor:"..name.."_chair",
		recipe = {
			{"", "", "mcl_core:stick"},
			{material, material, material},
			{"mcl_core:stick", "", "mcl_core:stick"}
		}
	})
	minetest.register_craft({
		output = "mcl_decor:"..name.."_chair",
		recipe = {
			{"mcl_core:stick", "", ""},
			{material, material, material},
			{"mcl_core:stick", "", "mcl_core:stick"}
		}
	})
	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..name.."_chair",
		burntime = burntime,
	})

	group.table = 1

	-- table part
	minetest.register_node("mcl_decor:"..name.."_table", {
		description = desc2,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{ -0.5, 0.375, -0.5, 0.5, 0.5, 0.5 },
				{ -0.4375, -0.5, -0.4375, -0.3125, 0.375, -0.3125 },
				{ 0.3125, -0.5, -0.4375, 0.4375, 0.375, -0.3125 },
				{ 0.3125, -0.5, 0.3125, 0.4375, 0.375, 0.4375 },
				{ -0.4375, -0.5, 0.3125, -0.3125, 0.375, 0.4375 },
			},
		},
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		},
		tiles = {tiles},
		is_ground_content = false,
		paramtype = "light",
		stack_max = 64,
		sunlight_propagates = true,
		groups = group,
		_mcl_hardness = 2,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})
	minetest.register_craft({
		output = "mcl_decor:"..name.."_table".." 2",
		recipe = {
			{material, material, material},
			{"mcl_core:stick", "", "mcl_core:stick"},
			{"mcl_core:stick", "", "mcl_core:stick"}
		}
	})
	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..name.."_table",
		burntime = 10,
	})
end

function mcl_decor.register_slab_table(name, desc, material, tiles, flammable)
	local group
	if flammable == nil then
		group = {handy=1, axey=1, attached_node=1, material_wood=1, deco_block=1, slab_table=1, flammable=-1}
	else
		group = {handy=1, axey=1, attached_node=1, material_wood=1, deco_block=1, slab_table=1}
	end
	minetest.register_node("mcl_decor:"..name.."_stable", {
		description = desc,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = {
				{-0.125, -0.5, -0.125, 0.125, 0, 0.125},
				{-0.5, 0, -0.5, 0.5, 0.5, 0.5},
			},
		},
		tiles = {tiles},
		is_ground_content = false,
		paramtype = "light",
		stack_max = 64,
		sunlight_propagates = true,
		groups = group,
		_mcl_hardness = 2,
		_mcl_blast_resistance = 3,
		sounds = mcl_sounds.node_sound_wood_defaults(),
	})
	minetest.register_craft({
		output = "mcl_decor:"..name.."_stable".." 3",
		recipe = {
			{material, material, material},
			{"", "mcl_core:stick", ""}
		}
	})
	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..name.."_stable",
		burntime = 10,
	})
end

local function readable_name(str)
	str = str:gsub("_", " ")
	return (str:gsub("^%l", string.upper))
end

-- REGISTER
if minetest.get_modpath("mcl_trees") then
	-- Mineclonia
	for name, def in pairs(mcl_trees.woods) do
		local rname = readable_name(name)
		local item = "mcl_trees:wood_"..name
		local wdef = minetest.registered_nodes[item]
		if wdef and wdef.tiles then
			mcl_decor.register_chair_and_table(name, S(rname.." Chair"), S(rname.."Table"), item, wdef.tiles[1])
			mcl_decor.register_slab_table(name, S(rname.." Slab Table"), item, wdef.tiles[1])
		end
	end
else
	-- VoxeLibre
	mcl_decor.register_chair_and_table("wooden", S("Oak Chair"), S("Oak Table"), "mcl_core:wood", "default_wood.png")
	mcl_decor.register_chair_and_table("dark_oak", S("Dark Oak Chair"), S("Dark Oak Table"), "mcl_core:darkwood", "mcl_core_planks_big_oak.png")
	mcl_decor.register_chair_and_table("jungle", S("Jungle Chair"), S("Jungle Table"), "mcl_core:junglewood", "default_junglewood.png")
	mcl_decor.register_chair_and_table("spruce", S("Spruce Chair"), S("Spruce Table"), "mcl_core:sprucewood", "mcl_core_planks_spruce.png")
	mcl_decor.register_chair_and_table("acacia", S("Acacia Chair"), S("Acacia Table"), "mcl_core:acaciawood", "default_acacia_wood.png")
	mcl_decor.register_chair_and_table("birch", S("Birch Chair"), S("Birch Table"), "mcl_core:birchwood", "mcl_core_planks_birch.png")
	mcl_decor.register_chair_and_table("mangrove", S("Mangrove Chair"), S("Mangrove Table"), "mcl_mangrove:mangrove_wood", "mcl_mangrove_planks.png")
	mcl_decor.register_chair_and_table("cherry", S("Cherry Chair"), S("Cherry Table"), "mcl_cherry_blossom:cherrywood", "mcl_cherry_blossom_planks.png")
	mcl_decor.register_chair_and_table("bamboo", S("Bamboo Chair"), S("Bamboo Table"), "mcl_bamboo:bamboo_plank", "mcl_bamboo_bamboo_block_stripped.png")
	mcl_decor.register_chair_and_table("crimson", S("Crimson Chair"), S("Crimson Table"), "mcl_crimson:crimson_hyphae_wood", "mcl_crimson_crimson_hyphae_wood.png", true)
	mcl_decor.register_chair_and_table("warped", S("Warped Chair"), S("Warped Table"), "mcl_crimson:warped_hyphae_wood", "mcl_crimson_warped_hyphae_wood.png", true)

	mcl_decor.register_slab_table("wooden", S("Oak Slab Table"), "mcl_core:wood", "default_wood.png")
	mcl_decor.register_slab_table("dark_oak", S("Dark Oak Slab Table"), "mcl_core:darkwood", "mcl_core_planks_big_oak.png")
	mcl_decor.register_slab_table("jungle", S("Jungle Slab Table"), "mcl_core:junglewood", "default_junglewood.png")
	mcl_decor.register_slab_table("spruce", S("Spruce Slab Table"), "mcl_core:sprucewood", "mcl_core_planks_spruce.png")
	mcl_decor.register_slab_table("acacia", S("Acacia Slab Table"), "mcl_core:acaciawood", "default_acacia_wood.png")
	mcl_decor.register_slab_table("birch", S("Birch Slab Table"), "mcl_core:birchwood", "mcl_core_planks_birch.png")
	mcl_decor.register_slab_table("mangrove", S("Mangrove Slab Table"), "mcl_mangrove:mangrove_wood", "mcl_mangrove_planks.png")
	mcl_decor.register_slab_table("cherry", S("Cherry Slab Table"), "mcl_cherry_blossom:cherrywood", "mcl_cherry_blossom_planks.png")
	mcl_decor.register_slab_table("bamboo", S("Bamboo Slab Table"), "mcl_bamboo:bamboo_plank", "mcl_bamboo_bamboo_block_stripped.png")
	mcl_decor.register_slab_table("crimson", S("Crimson Slab Table"), "mcl_crimson:crimson_hyphae_wood", "mcl_crimson_crimson_hyphae_wood.png", true)
	mcl_decor.register_slab_table("warped", S("Warped Slab Table"), "mcl_crimson:warped_hyphae_wood", "mcl_crimson_warped_hyphae_wood.png", true)
end
