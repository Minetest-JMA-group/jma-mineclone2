-- mcl_decor/colored.lua

local S = minetest.get_translator(minetest.get_current_modname())

-- COLORS TABLE
local colors = {
--   color,        wool texture,          armchair desc,            curtains desc,            dyed planks desc,       dye,          colorgroup,             hexcolor
	{"white",      "wool_white",          S("White Armchair"),      S("White Curtains"),      S("White Planks"),      "white",      "unicolor_white",       "#D0D6D7"},
	{"grey",       "wool_dark_grey",      S("Grey Armchair"),       S("Grey Curtains"),       S("Grey Planks"),       "dark_grey",  "unicolor_darkgrey",    "#383B40"},
	{"silver",     "wool_grey",           S("Light Grey Armchair"), S("Light Grey Curtains"), S("Light Grey Planks"), "grey",       "unicolor_grey",        "#808176"},
	{"black",      "wool_black",          S("Black Armchair"),      S("Black Curtains"),      S("Black Planks"),      "black",      "unicolor_black",       "#080A0F"},
	{"red",        "wool_red",            S("Red Armchair"),        S("Red Curtains"),        S("Red Planks"),        "red",        "unicolor_red",         "#922222"},
	{"yellow",     "wool_yellow",         S("Yellow Armchair"),     S("Yellow Curtains"),     S("Yellow Planks"),     "yellow",     "unicolor_yellow",      "#F1B115"},
	{"green",      "wool_dark_green",     S("Green Armchair"),      S("Green Curtains"),      S("Green Planks"),      "dark_green", "unicolor_dark_green",  "#4B5E25"},
	{"cyan",       "wool_cyan",           S("Cyan Armchair"),       S("Cyan Curtains"),       S("Cyan Planks"),       "cyan",       "unicolor_cyan",        "#157B8C"},
	{"blue",       "wool_blue",           S("Blue Armchair"),       S("Blue Curtains"),       S("Blue Planks"),       "blue",       "unicolor_blue",        "#2E3093"},
	{"magenta",    "wool_magenta",        S("Magenta Armchair"),    S("Magenta Curtains"),    S("Magenta Planks"),    "magenta",    "unicolor_red_violet",  "#AB31A2"},
	{"orange",     "wool_orange",         S("Orange Armchair"),     S("Orange Curtains"),     S("Orange Planks"),     "orange",     "unicolor_orange",      "#E26501"},
	{"purple",     "wool_violet",         S("Purple Armchair"),     S("Purple Curtains"),     S("Purple Planks"),     "violet",     "unicolor_violet",      "#67209F"},
	{"brown",      "wool_brown",          S("Brown Armchair"),      S("Brown Curtains"),      S("Brown Planks"),      "brown",      "unicolor_dark_orange", "#623C20"},
	{"pink",       "wool_pink",           S("Pink Armchair"),       S("Pink Curtains"),       S("Pink Planks"),       "pink",       "unicolor_light_red",   "#D56790"},
	{"lime",       "mcl_wool_lime",       S("Lime Armchair"),       S("Lime Curtains"),       S("Lime Planks"),       "green",      "unicolor_green",       "#60AB19"},
	{"light_blue", "mcl_wool_light_blue", S("Light Blue Armchair"), S("Light Blue Curtains"), S("Light Blue Planks"), "lightblue",  "unicolor_light_blue,", "#258CC8"},
}

for _, row in ipairs(colors) do
	-- define rows
	local color = row[1]
	local wooltile = row[2]
	local desc = row[3]
	local desc2 = row[4]
	local desc3 = row[5]
	local dye = row[6]
	local colorgroup = row[7]
	local hexcolor = row[8]

	-- register armchairs
	local adef = {
		description = desc,
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, -0.0625, 0.1875},
				{-0.5, -0.5, 0.1875, 0.5, 0.5, 0.5},
			},
			disconnected_sides = {
				{-0.5, -0.4375, -0.5, -0.3125, 0.125, 0.1875},
				{0.3125, -0.4375, -0.5, 0.5, 0.125, 0.1875},
			},
			disconnected_right = {
				{0.3125, -0.4375, -0.5, 0.5, 0.125, 0.1875},
			},
			disconnected_left = {
				{-0.5, -0.4375, -0.5, -0.3125, 0.125, 0.1875},
			},
		},
		connects_to = {"group:armchair"},
		tiles = {wooltile..".png"},
		is_ground_content = false,
		paramtype = "light",
		stack_max = 64,
		selection_box = {
			type = "fixed",
			fixed = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },
		},
		groups = {handy=1, shearsy_wool=1, attached_node=1, deco_block=1, armchair=1, flammable=1, fire_encouragement=30, fire_flammability=60, [colorgroup]=1},
		_mcl_hardness = 1,
		_mcl_blast_resistance = 1,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		on_rightclick = mcl_decor.sit,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				-- no interaction possible with entities
				return itemstack
			end

			-- Call on_rightclick if the pointed node defines it
			local node = minetest.get_node(pointed_thing.under)
			if placer and not placer:get_player_control().sneak then
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			local facedir = minetest.dir_to_facedir(placer:get_look_dir(), false)
			local pos = pointed_thing.above
			local name = "mcl_decor:"..color.."_armchair"

			if facedir == 0 then
				itemstack:set_name(name)
			elseif facedir == 1 then
				itemstack:set_name(name.."_1")
			elseif facedir == 2 then
				itemstack:set_name(name.."_2")
			elseif facedir == 3 then
				itemstack:set_name(name.."_3")
			end
			local new_itemstack, _ = minetest.item_place_node(itemstack, placer, pointed_thing, facedir)
			new_itemstack:set_name(name)

			return itemstack
		end,
	}
	minetest.register_node("mcl_decor:"..color.."_armchair", adef)

	-- register directional variations of armchairs
	local adef2 = table.copy(adef)
	adef2.drop = "mcl_decor:"..color.."_armchair"
	adef2._doc_items_create_entry = false
	adef2.groups.armchair = nil
	adef2.groups.not_in_creative_inventory = 1
	adef2.groups.armchair_1 = 1
	adef2.node_box = {
		type = "connected",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.1875, -0.0625, 0.5 },
			{ 0.1875, -0.5, -0.5, 0.5, 0.5, 0.5 },
		},
		disconnected_front = {
			{ -0.5, -0.4375, -0.5, 0.1875, 0.125, -0.3125 },
		},
		disconnected_back = {
			{ -0.5, -0.4375, 0.3125, 0.1875, 0.125, 0.5 },
		},
	}
	adef2.connects_to = {"group:armchair_1"}
	minetest.register_node("mcl_decor:"..color.."_armchair_1", adef2)

	local adef3 = table.copy(adef2)
	adef3.groups.armchair_1 = nil
	adef3.groups.armchair_2 = 1
	adef3.node_box = {
		type = "connected",
		fixed = {
			{ -0.5, -0.5, -0.1875, 0.5, -0.0625, 0.5 },
			{ -0.5, -0.5, -0.5, 0.5, 0.5, -0.1875 },
		},
		disconnected_right = {
			{ 0.3125, -0.4375, -0.1875, 0.5, 0.125, 0.5 },
		},
		disconnected_left = {
			{ -0.5, -0.4375, -0.1875, -0.3125, 0.125, 0.5 },
		},
	}
	adef3.connects_to = {"group:armchair_2"}
	minetest.register_node("mcl_decor:"..color.."_armchair_2", adef3)

	local adef4 = table.copy(adef3)
	adef4.groups.armchair_2 = nil
	adef4.groups.armchair_3 = 1
	adef4.node_box = {
		type = "connected",
		fixed = {
			{ -0.1875, -0.5, -0.5, 0.5, -0.0625, 0.5 },
			{ -0.5, -0.5, -0.5, -0.1875, 0.5, 0.5 },
		},
		disconnected_back = {
			{ -0.1875, -0.4375, 0.3125, 0.5, 0.125, 0.5 },
		},
		disconnected_front = {
			{ -0.1875, -0.4375, -0.5, 0.5, 0.125, -0.3125 },
		},
	}
	adef4.connects_to = {"group:armchair_3"}
	minetest.register_node("mcl_decor:"..color.."_armchair_3", adef4)

	-- prevent doc entry spam
	for i=1,3 do
		doc.add_entry_alias("nodes", "mcl_decor:"..color.."_armchair", "nodes", "mcl_decor:"..color.."_armchair_"..i)
	end

	minetest.register_lbm({
		name = "mcl_decor:"..color.."_armchair_facedir",
		nodenames = {"mcl_decor:"..color.."_armchair"},
		action = function(pos, node)
			if node.param2 == 1 then
				minetest.set_node(pos, {name="mcl_decor:"..color.."_armchair_1"})
			elseif node.param2 == 2 then
				minetest.set_node(pos, {name="mcl_decor:"..color.."_armchair_2"})
			elseif node.param2 == 3 then
				minetest.set_node(pos, {name="mcl_decor:"..color.."_armchair_3"})
			end
		end
	})


	minetest.register_craft({
		output = "mcl_decor:"..color.."_armchair",
		recipe = {
			{"", "", "mcl_wool:"..color},
			{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
			{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"}
		}
	})
	minetest.register_craft({
		output = "mcl_decor:"..color.."_armchair",
		recipe = {
			{"mcl_wool:"..color, "", ""},
			{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
			{"mcl_core:stick", "mcl_core:stick", "mcl_core:stick"}
		}
	})
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_decor:"..color.."_armchair",
		recipe = {"group:armchair", "mcl_dye:"..dye},
	})
	minetest.register_craft({
		type = "fuel",
		recipe = "mcl_decor:"..color.."_armchair",
		burntime = 10,
	})

	-- register curtains
	minetest.register_node("mcl_decor:curtain_"..color, {
		description = desc2,
		tiles = {
			-- very hacky way to make curtains render as they should
			wooltile..".png".."^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
			wooltile..".png".."^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png^[transformFY",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformR270",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformR90",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformFY",
			wooltile..".png".."^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
		},
		use_texture_alpha = "clip",
		stack_max = 64,
		inventory_image = wooltile..".png".."^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
		wield_image = wooltile..".png".."^mcl_decor_curtain_alpha.png^[makealpha:255,126,126^mcl_decor_curtain_overlay.png",
		walkable = false,
		sunlight_propagates = true,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "wallmounted",
		groups = {handy=1, flammable=-1, curtain=1, attached_node=1, dig_by_piston=1, deco_block=1, material_wool=1, [colorgroup]=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		node_box = {
			type = "wallmounted",
		},
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		-- function to close curtains
		on_rightclick = function(pos, node, _, itemstack)
			minetest.set_node(pos, {name="mcl_decor:curtain_"..color.."_closed", param2=node.param2})
			-- play the sound
			minetest.sound_play("mcl_decor_curtain", {
				pos = pos,
				max_hear_distance = 8
			}, true)
			return itemstack
		end
	})

	minetest.register_node("mcl_decor:curtain_"..color.."_closed", {
		description = desc2..S(" (closed)"),
		tiles = {
			wooltile..".png".."^mcl_decor_curtain_overlay.png",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformFY",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformR270",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformR90",
			wooltile..".png".."^mcl_decor_curtain_overlay.png^[transformFY",
			wooltile..".png".."^mcl_decor_curtain_overlay.png",
		},
		use_texture_alpha = "clip",
		walkable = false,
		sunlight_propagates = true,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "wallmounted",
		groups = {handy=1, flammable=-1, attached_node=1, dig_by_piston=1, not_in_creative_inventory=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		node_box = {
			type = "wallmounted",
		},
		drop = "mcl_decor:curtain_"..color,
		_mcl_blast_resistance = 0.2,
		_mcl_hardness = 0.2,
		-- function to open curtains
		on_rightclick = function(pos, node, clicker, itemstack)
			minetest.set_node(pos, {name="mcl_decor:curtain_"..color, param2=node.param2})
			-- play the sound
			minetest.sound_play("mcl_decor_curtain", {
				pos = pos,
				max_hear_distance = 8
			}, true)
			return itemstack
		end
	})

	minetest.register_craft({
		output = "mcl_decor:curtain_"..color,
		recipe = {
			{"mcl_core:iron_nugget", "mcl_core:stick", "mcl_core:iron_nugget"},
			{"mcl_wool:"..color, "mcl_wool:"..color, "mcl_wool:"..color},
			{"mcl_wool:"..color, "", "mcl_wool:"..color}
		}
	})
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_decor:curtain_"..color,
		recipe = {"group:curtain", "mcl_dye:"..dye},
	})

	-- register dyed planks
	minetest.register_node("mcl_decor:"..color.."_planks", {
		description = desc3,
		tiles = {"mcl_decor_dyed_planks.png^[colorize:"..hexcolor..":125"},
		stack_max = 64,
		is_ground_content = false,
		groups = {handy=1, axey=1, flammable=3, wood=1, building_block=1, material_wood=1, fire_encouragement=5, fire_flammability=20, [colorgroup]=1},
		sounds = mcl_sounds.node_sound_wood_defaults(),
		_mcl_blast_resistance = 3,
		_mcl_hardness = 2,
	})
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_decor:"..color.."_planks",
		recipe = {"group:wood", "mcl_dye:"..dye}
	})
	-- maybe descriptions of slabs/stairs after that workaround will be VERY CRAPPY (especially with translations via locales), but at least it works
	mcl_stairs.register_stair_and_slab_simple(
		color.."_planks", "mcl_decor:"..color.."_planks", desc3..S(" Stair"), desc3..S(" Slab"), S("Double")..desc3..S(" Slab"), "woodlike"
	)
end
