-- mcl_decor/hedges.lua

local S = minetest.get_translator(minetest.get_current_modname())

-- API
function mcl_decor.register_hedge(name, desc, material, tiles, color, paramtype2, palette, foliage_palette)
	-- use mcl_fences api to register hedge
	mcl_fences.register_fence(
		name .. "_hedge",
		desc,
		tiles,
		{handy = 1, axey = 1, hedge = 1, deco_block = 1,
		flammable = 2, fire_encouragement = 10,
		fire_flammability = 10, foliage_palette = foliage_palette},
		1, 1,
		{"group:hedge"},
		mcl_sounds.node_sound_leaves_defaults()
	)
	-- override the hedge to make it biome-colored
	local itemstring = "mcl_decor:"..name.."_hedge"
	if minetest.get_modpath("mcl_trees") then
		itemstring = "mcl_fences:"..name.."_hedge"
	end
	if minetest.registered_nodes[itemstring] then
		minetest.override_item(itemstring, {
			texture_alpha = "clip",
			palette_index = 0,
			color = color,
			paramtype2 = paramtype2,
			palette = palette,
			drop = "",
			after_dig_node = function(pos, oldnode)
				minetest.add_item(pos, oldnode)
			end,
			after_place_node = function(pos, placer, itemstack, pointed_thing)
				-- TODO
			end
		})
		-- crafting recipe
		minetest.register_craft({
			output = "mcl_decor:" .. name .. "_hedge" .. " 6",
			recipe = {
				{material, "mcl_core:stick", material},
				{material, "mcl_core:stick", material},
			}
		})
	end
end

local function readable_name(str)
	str = str:gsub("_", " ")
    return (str:gsub("^%l", string.upper))
end

local leaves = {
	["oak"] = { rname = S("Oak Hedge"), color = "#48B518", mcl2_item = "mcl_core:leaves", mcl2_texture = "default_leaves.png", mcl2_paramtype2 = "color", mcl2_palette = "mcl_core_palette_foliage.png", mcl2_foliage_palette = 1, },
	["dark"] = { rname = S("Dark Oak Hedge"), color = "#48B518", mcl2_item = "mcl_core:darkleaves", mcl2_texture = "mcl_core_leaves_big_oak.png", mcl2_paramtype2 = "color", mcl2_palette = "mcl_core_palette_foliage.png", mcl2_foliage_palette = 1, },
	["jungle"] = { rname = S("Jungle Hedge"), color = "#48B518", mcl2_item = "mcl_core:jungleleaves", mcl2_texture = "default_jungleleaves.png", mcl2_paramtype2 = "color", mcl2_palette = "mcl_core_palette_foliage.png", mcl2_foliage_palette = 1, },
	["acacia"] = { rname = S("Acacia Hedge"), color = "#619961", mcl2_item = "mcl_core:acacialeaves", mcl2_texture = "default_acacia_leaves.png", mcl2_paramtype2 = "none", mcl2_palette = nil, mcl2_foliage_palette = 1, },
	["spruce"] = { rname = S("Spruce Hedge"), color = "#48B518", mcl2_item = "mcl_core:spruceleaves", mcl2_texture = "mcl_core_leaves_spruce.png", mcl2_paramtype2 = "color", mcl2_palette = "mcl_core_palette_foliage.png", mcl2_foliage_palette = 0, },
	["birch"] = { rname = S("Birch Hedge"), color = "#80A755", mcl2_item = "mcl_core:birchleaves", mcl2_texture = "mcl_core_leaves_birch.png", mcl2_paramtype2 = "none", mcl2_palette = nil, mcl2_foliage_palette = 0, },
	["mangrove"] = { rname = S("Mangrove Hedge"), color = "#48B518", mcl2_item = "mcl_mangrove:mangroveleaves", mcl2_texture = "mcl_mangrove_leaves.png", mcl2_paramtype2 = "color", mcl2_palette = "mcl_core_palette_foliage.png", mcl2_foliage_palette = 1, },
	["cherry"] = { rname = S("Cherry Hedge"), color = nil, mcl2_item = "mcl_cherry_blossom:cherryleaves", mcl2_texture = "mcl_cherry_blossom_leaves.png", mcl2_paramtype2 = "none", mcl2_palette = nil, mcl2_foliage_palette = 0, },
}

-- REGISTER
if minetest.get_modpath("mcl_trees") then
	--mineclonia, use mcl_trees api
	leaves.dark_oak = leaves.dark
	leaves.cherry_blossom = leaves.cherry
	for name, def in pairs(mcl_trees.woods) do
		local rname = readable_name(name)
		local ldef = minetest.registered_nodes["mcl_trees:leaves_"..name]
		if ldef and ldef.tiles then
			--assert(leaves[name], name)
			mcl_decor.register_hedge(name, S(rname.." Hedge"), "mcl_trees:leaves_"..name, ldef.tiles[1], leaves[name].color, ldef.paramtype2, ldef.palette, 1)
		end
	end
else
	for name, v in pairs(leaves) do
		mcl_decor.register_hedge(name, v.rname, v.mcl2_item, v.mcl2_texture, v.color, v.mcl2_paramtype2, v.mcl2_palette, v.mcl2_foliage_palette)
	end
end

-- all hedges should be fuel
minetest.register_craft({
	type = "fuel",
	recipe = "group:hedge",
	burntime = 5,
})

