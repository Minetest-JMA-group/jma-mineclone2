--||||||||||||||||||
--|| Fishing Trap ||
--||||||||||||||||||

local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize
local F = minetest.formspec_escape

-- Inventory Init
-- Code from mcl_util
local function drop_item_stack(pos, stack)
	if not stack or stack:is_empty() then return end
	local drop_offset = vector.new(math.random() - 0.5, 0, math.random() - 0.5)
	minetest.add_item(vector.add(pos, drop_offset), stack)
end

local function drop_inventory(listname)
	return function(pos, oldnode, oldmetadata)
		if oldmetadata and oldmetadata.inventory then
			-- process in after_dig_node callback
			local main = oldmetadata.inventory.main
			if not main then return end
			for _, stack in pairs(main) do
				drop_item_stack(pos, stack)
			end
		else
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			for i = 1, inv:get_size("main") do
				drop_item_stack(pos, inv:get_stack("main", i))
			end
			meta:from_table()
		end
	end
end

local drop_stack = drop_inventory("main")

local function on_blast(pos)
	local node = minetest.get_node(pos)
	drop_stack()
	minetest.remove_node(pos)
end

-- Simple protection checking functions
local function protection_check_move(pos, from_list, from_index, to_list, to_index, count, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return count
	end
end

local function protection_check_put_take(pos, listname, index, stack, player)
	local name = player:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return 0
	else
		return stack:get_count()
	end
end

core.register_craftitem("mcl_fish_traps:earth_worm", {
	description = "Earth Worm",
    inventory_image = "mcl_fish_traps_worm.png",
    stack_max = 16,
    groups = {fish_bait = 2},
	on_drop = function(itemstack, dropper, pos)
        if dropper and awards then
			if dropper:is_player() then
            	local player_name = dropper:get_player_name()
				awards.unlock(player_name, "mcl_fish_traps_worm")
			end
        end
		return core.item_drop(itemstack, dropper, pos)
	end
})

core.register_craftitem("mcl_fish_traps:silver_worm", {
	description = "Silver Worm",
    inventory_image = "mcl_fish_traps_worm_silver.png",
    stack_max = 16,
    groups = {fish_bait = 3}
})

if awards then
	core.log("[mcl_fish_traps] Awards found, registering achievements")
	awards.register_achievement("mcl_fish_traps_worm", {
		title = S("Worm Regards"),
		description = S("Send a worm on its way."),
		icon = "mcl_fish_traps_worm.png",
	})
else
	core.log("error", "[mcl_fish_traps] Awards not found, NOT registering achievements")
end

-- Trap GUI
local gui = function(pos, node, clicker, itemstack, pointed_thing)
	local name = minetest.get_meta(pos):get_string("name")

	if name == "" then
		name = S("Fishing Trap")
	end

	local playername = clicker:get_player_name()

	minetest.show_formspec(playername,
		"mcl_fishing_trap:fishing_trap_"..pos.x.."_"..pos.y.."_"..pos.z,
		table.concat({
			"size[9,8.75]",
			"label[0,0;"..F(C("#313131", name)).."]",
			"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main;0,0.5;9,2;]",
			mcl_formspec.get_itemslot_bg(0, 0.5, 9, 2),
			"label[2,2.7;"..F(C("#313131", S("Place bait in the fishing trap to lure more fish!"))).."]",
			"label[0,4.0;"..F(C("#313131", S("Inventory"))).."]",
			"list[current_player;main;0,4.5;9,3;9]",
			mcl_formspec.get_itemslot_bg(0, 4.5, 9, 3),
			"list[current_player;main;0,7.74;9,1;]",
			mcl_formspec.get_itemslot_bg(0, 7.74, 9, 1),
			"listring[nodemeta:"..pos.x..","..pos.y..","..pos.z..";main]",
			"listring[current_player;main]",
		})
	)
end

-- Register Fish Trap Nodes
trap = {
	description = S("Fishing Trap"),
	_tt_help = S("Used to automatically fish."),
	_doc_items_longdesc = S("Used to automatically fish when placed in water."),
	use_texture_alpha = "clip",
	is_ground_content = false,
	paramtype2 = "facedir",
	drawtype = "allfaces_optional",
	groups = { axey = 1, punchy = 2, container = 2 },
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.rotate_and_place(itemstack, placer, pointed_thing, minetest.is_creative_enabled(placer:get_player_name()), {}, false)
		return itemstack
	end,
	on_rightclick = gui,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("main", 9*2)
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		minetest.get_meta(pos):set_string("name", itemstack:get_meta():get_string("name"))
	end,
	allow_metadata_inventory_move = protection_check_move,
	allow_metadata_inventory_take = protection_check_put_take,
	allow_metadata_inventory_put = protection_check_put_take,
	on_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		minetest.log("action", player:get_player_name()..
			" moves stuff in fishing trap at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
			" moves stuff to fishing trap at "..minetest.pos_to_string(pos))
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		minetest.log("action", player:get_player_name()..
			" takes stuff from fishing trap at "..minetest.pos_to_string(pos))
	end,
	after_dig_node = drop_stack,
	on_blast = on_blast,
	drop = "mcl_fish_traps:fishing_trap",
}

local trap_w = table.copy(trap)
local trap_rw = table.copy(trap)

trap.tiles = {
	"mcl_fish_traps_trap.png", "mcl_fish_traps_trap.png",
	"mcl_fish_traps_trap.png", "mcl_fish_traps_trap.png",
	"mcl_fish_traps_trap.png", "mcl_fish_traps_trap.png"
}

water_tex = "mcl_core_water_source_animation.png^[verticalframe:16:0^[colorize:#0003be:100"
trap_w.tiles = { 
	"("..water_tex..")^mcl_fish_traps_trap.png",
	"("..water_tex..")^mcl_fish_traps_trap.png",
	"("..water_tex..")^mcl_fish_traps_trap.png",
}
trap_w.groups.not_in_creative_inventory = 1

minetest.register_node("mcl_fish_traps:fishing_trap", trap)
minetest.register_node("mcl_fish_traps:fishing_trap_water", trap_w)

-- Register Fish Trap Crafting Recipe
minetest.register_craft({
	output = "mcl_fish_traps:fishing_trap",
	recipe = {
		{ "mcl_mobitems:string", "mcl_core:stick", "mcl_mobitems:string" },
		{ "mcl_core:stick", "mcl_fishing:fishing_rod", "mcl_core:stick" },
		{ "mcl_mobitems:string", "mcl_core:stick", "mcl_mobitems:string" },
	}
})

-- Register Water Logging Fish Trap ABM
local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

minetest.register_abm({
	label = "Waterlog fish trap",
	nodenames = {"mcl_fish_traps:fishing_trap"},
	neighbors = {"group:water"},
	interval = 5,
	chance = 1,
	action = function(pos,value)
		for _,v in pairs(adjacents) do
			local n = minetest.get_node(vector.add(pos,v)).name
			if minetest.get_item_group(n,"water") > 0 then
				minetest.swap_node(pos,{name="mcl_fish_traps:fishing_trap_water"})
				return
			end
		end
	end
})

-- Register Fishing ABM
minetest.register_abm({
	label = "Run fish trap",
	nodenames = {"mcl_fish_traps:fishing_trap_water"},
	interval = 60,
	chance = 1,
	action = function(pos,value)
		local chance = 15
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local pr = PseudoRandom(os.time() * math.random(1, 100))
		local i_s = nil

		local bait = nil
		for i, stack in ipairs(inv:get_list("main")) do
			if stack:get_count() > 0 then
				local item_name = stack:get_name()
				if core.get_item_group(item_name, "fish_bait") > 0 then
					bait = core.get_item_group(item_name, "fish_bait")
					i_s = ItemStack(item_name .. " 1")
					break
				end
			end
		end

		if bait then
			--core.log("Found bait: "..bait)
			if bait == 1 then chance = 10
			elseif bait == 2 then chance = 7
			elseif bait == 3 then chance = 5 end
		end

		local c = pr:next(1, chance)
		if c ~= 1 then return end

		inv:remove_item("main", i_s)

		local item
		local r = pr:next(1, 100)
		local fish_values = {92, 92.8, 95, 92.5}
		local junk_values = {10, 8.1, 7, 9}

		local fv = fish_values[math.random(#fish_values)]
		local jv = junk_values[math.random(#junk_values)]

		if bait == 3 then fv = 70 end

		if r <= fv then
			-- Fish
			item = mcl_loot.get_loot({
				items = {
				{ itemstring = "mcl_fishing:fish_raw", weight = 60 },
				{ itemstring = "mcl_fishing:salmon_raw", weight = 25 },
				{ itemstring = "mcl_fishing:clownfish_raw", weight = 2 },
				{ itemstring = "mcl_fishing:pufferfish_raw", weight = 13 },
			},
			stacks_min = 1,
			stacks_max = 1,
			}, pr)
		elseif r <= jv then
		-- Junk
			item = mcl_loot.get_loot({
				items = {
					{ itemstring = "mcl_core:bowl", weight = 10 },
					{ itemstring = "mcl_fishing:fishing_rod", weight = 2, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
					{ itemstring = "mcl_mobitems:leather", weight = 10 },
					{ itemstring = "mcl_armor:boots_leather", weight = 10, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
					{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
					{ itemstring = "mcl_core:stick", weight = 5 },
					{ itemstring = "mcl_mobitems:string", weight = 5 },
					{ itemstring = "mcl_potions:water", weight = 5 },
					{ itemstring = "mcl_mobitems:bone", weight = 10 },
					{ itemstring = "mcl_dye:black", weight = 1, amount_min = 10, amount_max = 10 },
					{ itemstring = "mcl_mobitems:string", weight = 10 }, -- TODO: Tripwire Hook
				},
				stacks_min = 1,
				stacks_max = 1,
			}, pr)
		else
			local enchant_weight = 1
			local common_weight = 15
			if bait == 3 then
				enchant_weight = 10
				common_weight = 3
			end
			-- Treasure
			item = mcl_loot.get_loot({
				items = {
					{ itemstring = "mcl_bows:bow", weight = enchant_weight/2, wear_min = 49144, wear_max = 65535, func = function(stack, pr)
						mcl_enchanting.enchant_randomly(stack, 30, true, false, false, pr)
					end }, -- 75%-100% damage
					{ itemstring = "mcl_books:book", weight = enchant_weight/2, func = function(stack, pr)
						mcl_enchanting.enchant_randomly(stack, 30, true, true, false, pr)
					end },
					{ itemstring = "mcl_fishing:fishing_rod", weight = enchant_weight, wear_min = 49144, wear_max = 65535, func = function(stack, pr)
						mcl_enchanting.enchant_randomly(stack, 30, true, false, false, pr)
					end }, -- 75%-100% damage
					{ itemstring = "mcl_mobs:nametag", weight = 2},
					{ itemstring = "mcl_mobitems:saddle", weight = 2},
					{ itemstring = "mcl_flowers:waterlily", weight = common_weight},
					{ itemstring = "mcl_mobitems:nautilus_shell", weight = common_weight},
				},
				stacks_min = 1,
				stacks_max = 1,
			}, pr)
		end
		if #item >= 1 then
			item = ItemStack(item[1])
		else
			item = ItemStack()
		end
		if inv:room_for_item("main", item) then
			inv:add_item("main", item)
		end
	end
})
