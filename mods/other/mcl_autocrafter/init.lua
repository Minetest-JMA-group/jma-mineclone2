--[[
    mcl_autocrafter: Automated crafting on MineClone2
    Copyright (C) 20218-2021  VanessaE
    Copyright (C) 2023  1F616EMO

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local MP = minetest.get_modpath("mcl_autocrafter")
local S = minetest.get_translator("mcl_autocrafter")
local craft_time = 1

mcl_autocrafter = {}

-- [pos hash] = {consumption = {[Item Name] = [int],...}, output = {[ItemStack],...}, main_output = [ItemStack], last_use = [os.time()]}
local crafting_cache = {}

function mcl_autocrafter.count_index(invtable)
    local index = {}
    for _, stack in ipairs(invtable) do
        if not stack:is_empty() then
            local stack_name = stack:get_name()
            index[stack_name] = (index[stack_name] or 0) + stack:get_count()
        end
    end
    return index
end

function mcl_autocrafter.get_craft_for(pos,force_refresh)
    local pos_hash = minetest.hash_node_position(pos)
    if not(crafting_cache[pos_hash]) or force_refresh then
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local recipe = inv:get_list("recipe")
        local output, decremented_input = minetest.get_craft_result({method = "normal", width = 3, items = recipe})

        if output.item:is_empty() then
            crafting_cache[pos_hash] = nil
            return false
        end

        local output_table = {}
        table.insert(output_table,output.item)
        for _,v in ipairs(output.replacements) do
            table.insert(output_table,v[2])
        end
        for _,v in ipairs(decremented_input) do
            table.insert(output_table,v)
        end

        crafting_cache[pos_hash] = {
            consumption = mcl_autocrafter.count_index(recipe),
            output = mcl_autocrafter.count_index(output_table),
            main_output = output.item
        }
    end
    crafting_cache[pos_hash].last_used = os.time()
    return crafting_cache[pos_hash]
end

-- loops: number of maximum crafts to be done
function mcl_autocrafter.do_autocraft_on(pos,loops,craft,force_refresh)
    local meta = minetest.get_meta(pos)
    local inv = meta:get_inventory()
    craft = craft or mcl_autocrafter.get_craft_for(pos,force_refresh)
    if not craft then
        return false, "NO_VALID_CRAFT"
    end

    local src_final = {}
    local times_final = 0
    local output_final = {}
    do
        local i = 0
        local broken = false
        while (i < loops) and not(broken) do
            i = i + 1

            local src_timed = {}
            for k,v in pairs(craft.consumption) do
                src_timed[k] = (i == 1) and v or (v * i)
            end

            local output_timed = {}
            for k,v in pairs(craft.output) do
                output_timed[k] = (i == 1) and v or (v * i)
            end

            for k,v in pairs(src_timed) do
                local stack = ItemStack(k)
                stack:set_count(v)
                if not inv:contains_item("src", stack, false) then
                    broken = true
                end
            end
            
            if not broken then
                for k,v in pairs(output_timed) do
                    local stack = ItemStack(k)
                    stack:set_count(v)
                    if not inv:room_for_item("dst",stack) then
                        broken = true
                    end
                end

                if not broken then
                    src_final = src_timed
                    output_final = output_timed
                    times_final = i
                end
            end
        end -- Do not exceed the given limit
    end

    if times_final <= 0 then
        return false, "NOT_ENOUGH_SPACE" -- We do not craft void
    end

    -- Consume materieal
    for name, number in pairs(src_final) do
        local stack_max = minetest.registered_items[name] and minetest.registered_items[name].stack_max or 99
        while number > 0 do -- We have to do that since remove_item does not work if count > stack_max
            local number_take = math.min(number,stack_max)
            number = number - number_take
            inv:remove_item("src",name .. " " .. number_take)
        end
    end

    -- Craft and add to dst
    for k,v in pairs(output_final) do
        inv:add_item("dst",k .. " " .. v)
    end

    return true
end

function mcl_autocrafter.make_formspec(state)
    return "" ..
        "size[9,12]" ..
        "label[0,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Recipe grid"))).."]" ..
        "list[context;recipe;0,0.5;3,3]" ..
        mcl_formspec.get_itemslot_bg(0,0.5,3,3) .. 
        "list[context;output;3.5,1.5;1,1]" ..
        mcl_formspec.get_itemslot_bg(3.5,1.5,1,1) .. 
        "image_button[3.5,2.7;1,0.6;pipeworks_button_" .. state .. ".png;" .. state .. ";;;false;pipeworks_button_interm.png]" .. 
        "label[5,0;"..minetest.formspec_escape(minetest.colorize("#313131", S("Output"))).."]" ..
        "list[context;dst;5,0.5;4,3;]" ..
        mcl_formspec.get_itemslot_bg(5,0.5,4,3) .. 
        "label[0,3.5;"..minetest.formspec_escape(minetest.colorize("#313131", S("Crafting materieals"))).."]" ..
        "list[context;src;0,4;9,3;]" ..
        mcl_formspec.get_itemslot_bg(0,4,9,3) .. 
        "label[0,7;"..minetest.formspec_escape(minetest.colorize("#313131", S("Inventory"))).."]" ..
        "list[current_player;main;0,7.5;9,3;9]" ..
        mcl_formspec.get_itemslot_bg(0,7.5,9,3) .. 
        "list[current_player;main;0,11;9,1;]" ..
        mcl_formspec.get_itemslot_bg(0,11,9,1) .. 
        "listring[current_player;main]" ..
        "listring[context;src]" ..
        "listring[current_player;main]" ..
        "listring[context;dst]" ..
        "listring[current_player;main]"
end

function mcl_autocrafter.get_infotext(output,state)
    local output_string = S("Unconfigured")
    if output and not(output:is_empty()) then
        output_string = output:get_short_description()
    elseif state == "UNCONFIGURED" then
        return S("Autocrafter: @1", output_string)
    end

    local state_string = "ERROR"
    if state == "OK" then
        state_string = S("Runnning")
    elseif state == "NOT_ENOUGH_SPACE" then
        local paused_string = S("Not enough inventory space or materieals.")
        state_string = S("Paused: @1",paused_string)
    elseif state == "NO_VALID_CRAFT" then
        state_string = S("Unconfigured.")
    elseif state == "STOPPED" then
        state_string = S("Stopped.")
    end

    return S("Autocrafter: @1",output_string) .. "\n" .. state_string
end

local function after_dig_node(pos,node,oldmetadata)
    mcl_autocrafter.drop_all(pos,node,oldmetadata)

    local timer = minetest.get_node_timer(pos)
    if timer:is_started() then
        timer:stop()
    end
end

function mcl_autocrafter.start_autocrafter(pos)
    local meta = minetest.get_meta(pos)
	if meta:get_int("enabled") == 1 then
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then
			timer:start(craft_time)
		end
	end
end

function mcl_autocrafter.after_recipe_change(pos, inv)
    local meta = minetest.get_meta(pos)
    if not inv then
        inv = meta:get_inventory()
    end

    if inv:is_empty("recipe") then -- Nothing to do
        minetest.log("action",string.format("[mcl_autocrafter] Recipe of autocrafter at %s is cleared",minetest.pos_to_string(pos)))
        local timer = minetest.get_node_timer(pos)
        if timer:is_started() then
            timer:stop()
        end

        local pos_hash = minetest.hash_node_position(pos)
        crafting_cache[pos_hash] = nil

        meta:set_string("infotext",mcl_autocrafter.get_infotext(nil,"UNCONFIGURED"))
        return
    end

    local craft = mcl_autocrafter.get_craft_for(pos,true) -- Force-refresh the cached recipe
    if craft then
        meta:set_string("infotext",mcl_autocrafter.get_infotext(craft.main_output,"OK"))
        inv:set_stack("output", 1, craft.main_output)
    else
        meta:set_string("infotext",mcl_autocrafter.get_infotext(nil,"NO_VALID_CRAFT"))
    end

    mcl_autocrafter.start_autocrafter(pos)
end

-- HACK! Forcely change "fuel" to "src" for autocrafters
-- The source and destination inventories should NEVER EVER BE HARDCODED INTO THE SOURCECODE!
do
    local old_move_item_container = mcl_util.move_item_container
    function mcl_util.move_item_container(source_pos, destination_pos, source_list, source_stack_id, destination_list)
        local dest_node = minetest.get_node(destination_pos)
        if dest_node.name == "mcl_autocrafter:autocrafter" and destination_list == "fuel" then
            -- FORCEly change it back to "src"
            destination_list = "src"
        end
        return old_move_item_container(source_pos, destination_pos, source_list, source_stack_id, destination_list)
    end

    local old_get_eligible_transfer_item_slot = mcl_util.get_eligible_transfer_item_slot
    function mcl_util.get_eligible_transfer_item_slot(src_inventory, src_list, dst_inventory, dst_list, condition)
        local dst_inv_location = dst_inventory:get_location()
        if dst_inv_location.type == "node" then
            local dest_node = minetest.get_node(dst_inv_location.pos)
            if dest_node.name == "mcl_autocrafter:autocrafter" and dst_list == "fuel" then
                -- FORCEly change it back to "src"
                dst_list = "src"
                -- Hey, no conditions!
                condition = nil
            end
        end
        return old_get_eligible_transfer_item_slot(src_inventory, src_list, dst_inventory, dst_list, condition)
    end
end

minetest.register_node("mcl_autocrafter:autocrafter", {
    description = S("Autocrafter"),
    tiles = {"pipeworks_autocrafter.png"},
    stack_max = 64,
    sounds = mcl_sounds.node_sound_wood_defaults(),

    -- node group container: 4
    -- -> take from dst, put to src; the same as furnace
    groups = { dig_generic = 1, axey=5, container = 4 },
    _mcl_hardness=1.6,

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        inv:set_size("src", 3*9)
		inv:set_size("recipe", 3*3)
		inv:set_size("dst", 4*3)
		inv:set_size("output", 1)

        meta:set_int("enabled", 0)
        meta:set_string("infotext",mcl_autocrafter.get_infotext(nil,"UNCONFIGURED"))
        meta:set_string("formspec",mcl_autocrafter.make_formspec("off"))
    end,

    on_receive_fields = function(pos, formname, fields, sender)
        if fields.quit then return end
        local name = sender:get_player_name() -- "" if not a player
        if minetest.is_protected(pos, name) then
            if name ~= "" then
                minetest.record_protection_violation(pos, name)
            end
            return
        end

        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()
        local output = inv:get_list("output")
        if output then output = output[1] end
        if output:is_empty() then output = nil end

        if fields.on then
            meta:set_int("enabled", 0)
            meta:set_string("infotext",mcl_autocrafter.get_infotext(output,"UNCONFIGURED"))
            meta:set_string("formspec",mcl_autocrafter.make_formspec("off"))
        elseif fields.off then
            meta:set_int("enabled",1)
            meta:set_string("infotext",mcl_autocrafter.get_infotext(output,"OK"))
            meta:set_string("formspec",mcl_autocrafter.make_formspec("on"))

            local timer = minetest.get_node_timer(pos)
            if not timer:is_started() then
			    timer:start(craft_time)
		    end
        end
    end,

    after_dig_node = function(pos, oldnode, oldmetadata, digger) -- Modified from the one of furnaces
        if not oldmetadata.inventory then return end
		for _, listname in ipairs({"src", "dst"}) do
            if oldmetadata.inventory[listname] then
                for _,stack in ipairs(oldmetadata.inventory[listname]) do
                    if stack then
                        stack = ItemStack(stack) -- Ensure it is an ItemStack
                        if not stack:is_empty() then
                            -- from mcl_util
                            local drop_offset = vector.new(math.random() - 0.5, 0, math.random() - 0.5)
                            minetest.add_item(vector.add(pos, drop_offset), stack)
                        end
                    end
                end
            end
		end
	end,

    on_destruct = function(pos)
        local pos_hash = minetest.hash_node_position(pos)
        crafting_cache[pos_hash] = nil

        local timer = minetest.get_node_timer(pos)
		if timer:is_started() then
			timer:stop()
		end
    end,

    allow_metadata_inventory_put = function(pos, listname, index, stack, player)
        local name = player:get_player_name() -- "" if not a player
        if minetest.is_protected(pos, name) then
            if name ~= "" then
                minetest.record_protection_violation(pos, name)
            end
            return
        end

        local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "recipe" then
			stack:set_count(1)
            minetest.log("action",string.format("[mcl_autocrafter] %s is put at index %d at %s",stack:to_string(),index,minetest.pos_to_string(pos)))
			inv:set_stack(listname, index, stack)
			mcl_autocrafter.after_recipe_change(pos, inv)
			return 0
		elseif listname == "output" then
            -- I am lazy, so let's not to handle outputs
			return 0
		end
		mcl_autocrafter.start_autocrafter(pos)
		return stack:get_count()
	end,

    allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		local name = player:get_player_name() -- "" if not a player
        if minetest.is_protected(pos, name) then
            if name ~= "" then
                minetest.record_protection_violation(pos, name)
            end
            return
        end

		local inv = minetest.get_meta(pos):get_inventory()
		if listname == "recipe" then
			inv:set_stack(listname, index, ItemStack(""))
			mcl_autocrafter.after_recipe_change(pos, inv)
			return 0
		elseif listname == "output" then
			-- I am lazy, so let's not to handle outputs
			return 0
		end
		mcl_autocrafter.start_autocrafter(pos)
		return stack:get_count()
	end,

    allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		local name = player:get_player_name() -- "" if not a player
        if minetest.is_protected(pos, name) then
            if name ~= "" then
                minetest.record_protection_violation(pos, name)
            end
            return
        end

		local inv = minetest.get_meta(pos):get_inventory()
		local stack = inv:get_stack(from_list, from_index)

		if to_list == "output" then
			-- I am lazy, so let's not to handle outputs
			return 0
		elseif from_list == "output" then
			if to_list ~= "recipe" then
				return 0
			end -- else fall through to recipe list handling
		end

		if from_list == "recipe" or to_list == "recipe" then
			if from_list == "recipe" then
				inv:set_stack(from_list, from_index, ItemStack(""))
			end
			if to_list == "recipe" then
				stack:set_count(1)
				inv:set_stack(to_list, to_index, stack)
			end
			mcl_autocrafter.after_recipe_change(pos, inv)
			return 0
		end

		mcl_autocrafter.start_autocrafter(pos)
		return count
	end,
    on_timer = function(pos, elapsed)
        local meta = minetest.get_meta(pos)
	    local inv = meta:get_inventory()
        local craft = mcl_autocrafter.get_craft_for(pos, false)
        if not craft then
            meta:set_string("infotext",mcl_autocrafter.get_infotext(nil,"NO_VALID_CRAFT"))
        end

        -- Stop node timer if a fatal error occured.
        -- mcl_util will restart the nodetimer just like a furnace.
        local loops = math.floor(elapsed/craft_time)
        local status, msg = mcl_autocrafter.do_autocraft_on(pos,loops,craft,false)
        minetest.log("action",string.format("[mcl_autocrafter] Nodetimer on %s done, %s",minetest.pos_to_string(pos),(status and "success" or ("failed, " .. msg))))
        if status then
            ---@diagnostic disable-next-line: need-check-nil
            meta:set_string("infotext",mcl_autocrafter.get_infotext(craft.main_output,"OK"))
        elseif msg == "NO_VALID_CRAFT" then
            meta:set_string("infotext",mcl_autocrafter.get_infotext(nil,"NO_VALID_CRAFT"))
            return false
        elseif msg == "NOT_ENOUGH_SPACE" then
            ---@diagnostic disable-next-line: need-check-nil
            meta:set_string("infotext",mcl_autocrafter.get_infotext(craft.main_output,"NOT_ENOUGH_SPACE"))
            return false
        end

        return true
    end
})

minetest.register_craft({
	output = "mcl_autocrafter:autocrafter 2",
	recipe = {
		{ "mcl_core:iron_ingot", "mcl_core:diamond", "mcl_core:iron_ingot" },
		{ "mcl_core:paper", "mcl_core:iron_ingot", "mcl_core:paper" },
		{ "mcl_core:iron_ingot", "mcl_core:diamond", "mcl_core:iron_ingot" }
	}
})

