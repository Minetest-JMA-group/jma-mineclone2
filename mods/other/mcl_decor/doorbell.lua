-- mcl_decor/doorbell.lua

-- The article for doorbells uses a lot of locale strings
-- from other mods to make translation process easier,
-- which is why we load all these translators here and
-- assign one capital letter to each
local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.get_translator("mcl_core")
local N = minetest.get_translator("mcl_nether")
local M = minetest.get_translator("mcl_mobitems")
local W = minetest.get_translator("mcl_wool")
local F = minetest.get_translator("mcl_farming")
local S_ = minetest.get_translator("subtitles")

local instruments = {
	-- desc,                sound,             material
	{S("Sticks"),           "hit",             "group:material_glass"     },
	{S("Bass guitar"),      "bass_guitar",     "group:material_wood"      },
	{S("Bass drum"),        "bass_drum",       "group:material_stone"     },
	{S("Snare drum"),       "snare",           "group:material_sand"      },
	{S("Bell"),             "bell",            "mcl_core:gold_ingot"      },
	{S("Flute"),            "flute",           "mcl_core:clay_lump"       },
	{S("Chime"),            "chime",           "mcl_core:ice"             },
	{S("Guitar"),           "guitar",          "group:wool"               },
	{S("Xylophone"),        "xylophone_wood",  "mcl_mobitems:bone"        },
	{S("Iron xylophone"),   "xylophone_metal", "mcl_core:iron_ingot"      },
	{S("Cow bell"),         "cowbell",         "mcl_nether:soul_sand"     },
	{S("Didgeridoo"),       "didgeridoo",      "group:pumpkin"            },
	{S("Square wave"),      "squarewave",      "mcl_core:emerald"         },
	{S("Banjo"),            "banjo",           "mcl_farming:wheat_item"   },
	{S("Electric piano"),   "piano_digital",   "mcl_nether:glowstone_dust"},
	{S("Piano"),            "c",               ""                         } -- default
}

-- noteblock param2s
-- (the amount of times you rightclicked each noteblock)
local melody = {}
local mcl_decor_melody = minetest.settings:get("mcl_decor_melody") or "14,8,1,4,6,10"
local mcl_decor_doorbell_timeout = minetest.settings:get("mcl_decor_doorbell_timeout") or 3.0

for note in mcl_decor_melody:gmatch("([%d%.%+%-]+),?") do
	melody[#melody + 1] = tonumber(note)
end

-- from mesecons_noteblock
local function param2_to_pitch(param2)
	return 2^((param2-12)/12)
end

-- from mesecons_button
local function on_button_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		-- no interaction possible with entities
		return itemstack
	end

	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local def = minetest.registered_nodes[node.name]
	if not def then return end
	local groups = def.groups

	-- Check special rightclick action of pointed node
	if def and def.on_rightclick then
		if not placer:get_player_control().sneak then
			return def.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack, false
		end
	end

	-- If the pointed node is buildable, let's look at the node *behind* that node
	if def.buildable_to then
		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		local actual = vector.subtract(under, dir)
		local actualnode = minetest.get_node(actual)
		def = minetest.registered_nodes[actualnode.name]
		groups = def.groups
	end

	-- Only allow placement on full-cube solid opaque nodes
	if (not groups) or (not groups.solid) or (not groups.opaque) or (def.node_box and def.node_box.type ~= "regular") then
		return itemstack
	end

	local above = pointed_thing.above

	local idef = itemstack:get_definition()
	local itemstack, success = minetest.item_place_node(itemstack, placer, pointed_thing)

	if success then
		if idef.sounds and idef.sounds.place then
			minetest.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
		end
	end
	return itemstack
end

-- register doorbells
for _, row in ipairs(instruments) do
	-- define rows
	local desc = row[1]
	local sound = row[2]
	local material = row[3]

	local is_canonical = desc == S("Piano")

	local itemstring = "mcl_decor:doorbell_"..sound
	if is_canonical then
		itemstring = "mcl_decor:doorbell"
	end

	local doorbell_def =  {
		description = S("Doorbell").."\n"..
		minetest.colorize("yellow", S("Instrument: ")..desc),
		_tt_help = S("Plays a melody when rung"),
		_doc_items_create_entry = is_canonical,
		_doc_items_longdesc = S("A doorbell is a button-like musical block which plays a melody when rung, allowing the visitors to notify the owner of their arrival."),
		_doc_items_usagehelp = S("To ring the doorbell, rightclick it. Doorbell plays a different instrument based on which additional ingredient (beside a wood plank and Redstone Dust) was added when crafting it:").."\n\n"..
	
		"• "..C("Glass")..": "..S("Sticks").."\n"..
		"• "..S("Wood")..": "..S("Bass guitar").."\n"..
		"• "..C("Stone")..": "..S("Bass drum").."\n"..
		"• "..C("Sand")..S(" or ")..C("Gravel")..": "..S("Snare drum").."\n"..
		"• "..C("Gold Ingot")..": "..S("Bell").."\n"..
		"• "..C("Clay Ball")..": "..S("Flute").."\n"..
		"• "..C("Ice")..": "..S("Chime").."\n"..
		"• "..W("Wool")..": "..S("Guitar").."\n"..
		"• "..M("Bone")..": "..S("Xylophone").."\n"..
		"• "..C("Iron Ingot")..": "..S("Iron xylophone").."\n"..
		"• "..N("Soul Sand")..": "..S("Cow bell").."\n"..
		"• "..F("Pumpkin")..": "..S("Didgeridoo").."\n"..
		"• "..C("Emerald")..": "..S("Square wave").."\n"..
		"• "..F("Wheat")..": "..S("Banjo").."\n"..
		"• "..N("Glowstone Dust")..": "..S("Electric piano").."\n"..
		"• "..S("Nothing")..": "..S("Piano").."\n\n"..
	
		S("The melody played by the doorbell can be configured through modifying the mod.conf file."),
		
		tiles = {"mesecons_noteblock.png"},
		inventory_image = "mcl_decor_doorbell_alpha.png^mesecons_noteblock.png^mcl_decor_doorbell_alpha.png^[makealpha:255,126,126",
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "wallmounted",
		node_box = {
			type = "wallmounted",
			wall_side = { -8/16, -2/16, -2/16, -6/16, 2/16, 2/16 },
			wall_bottom = { -2/16, -8/16, -2/16, 2/16, -6/16, 2/16 },
			wall_top = { -2/16, 6/16, -2/16, 2/16, 8/16, 2/16 },
		},
		groups = {handy=1, axey=1, attached_node=1, dig_by_water=1, destroy_by_lava_flow=1, dig_by_piston=1, dig_immediate_piston=1},
		stack_max = 64,
		on_place = on_button_place,
		on_rightclick = function(pos)
			local node = minetest.get_node(pos)
			minetest.set_node(pos, {name=itemstring.."_on", param2=node.param2})
			for i=1,#melody do
				local sound_def = {
					pos = pos,
					gain = 1.0,
					max_hear_distance = 64,
					pitch = param2_to_pitch(melody[i]),
					description = ""
				}
				if i == 1 then -- the first note
					sound_def.description = S_("Doorbell rings")
					-- this is to prevent subtitles spam
				end
				minetest.after(0.15*i, minetest.sound_play, "mesecons_noteblock_"..sound, sound_def)
			end
			local timer = minetest.get_node_timer(pos)
			timer:start(mcl_decor_doorbell_timeout)
		end,
	}
	
	local doorbell_on_def = table.copy(doorbell_def)
	doorbell_on_def._doc_items_create_entry = false
	doorbell_on_def.drop = itemstring
	doorbell_on_def.on_rightclick = nil
	doorbell_on_def.groups.not_in_creative_inventory = 1
	doorbell_on_def.node_box.wall_side = {-8/16, -2/16, -2/16, -7/16, 2/16, 2/16}
	doorbell_on_def.node_box.wall_bottom = {-2/16, -8/16, -2/16, 2/16, -7/16, 2/16}
	doorbell_on_def.node_box.wall_top = {-2/16, 7/16, -2/16, 2/16, 8/16, 2/16}
	doorbell_on_def.on_timer = function(pos, elapsed)
		local node = minetest.get_node(pos)
		if node.name == itemstring.."_on" then -- has not been dug
			minetest.set_node(pos, {name=itemstring, param2=node.param2})
		end
	end

	-- register
	minetest.register_node(itemstring, doorbell_def)
	minetest.register_node(itemstring.."_on", doorbell_on_def)

	local recipe
	if is_canonical then
		recipe = {
			"group:wood",
			"mesecons:wire_00000000_off",
		}
	else
		recipe = {
			"group:wood",
			"mesecons:wire_00000000_off",
			material,
		}
	end

	minetest.register_craft({
		type = "shapeless",
		output = itemstring,
		recipe = recipe
	})

	-- fix entry spam
	if not is_canonical then
		doc.add_entry_alias("nodes", "mcl_decor:doorbell", "nodes", itemstring)
	end
	doc.add_entry_alias("nodes", "mcl_decor:doorbell", "nodes", itemstring.."_on")
end
