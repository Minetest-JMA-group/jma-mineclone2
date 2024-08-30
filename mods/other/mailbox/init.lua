-- mailbox/init.lua
-- Inbox for items
--[[
	Mailbox: Inbox for items
    Copyright (c) 2015-2016  kilbith <jeanpatrick.guerrero@gmail.com>
    Copyright (c) 2016       James Stevenson
    Copyright (c) 2017-2021  Gabriel Pérez-Cerezo <gabriel@gpcf.eu>
    Copyright (c) 2024       1F616EMO <root@1f616emo.xyz>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

local mailbox = {}

local S = minetest.get_translator("mailbox")
local NS = function(s) return s end
local FS = function(...) return minetest.formspec_escape(S(...)) end
local NFS = function(s) return minetest.formspec_escape(s) end

mailbox.allow_interact = function(pos, owner, name)
	return owner == name or minetest.check_player_privs(name, { protection_bypass = true })
end

function mailbox.get_formspec(pos, owner, fs_type)
	local selected = "false"
	if minetest.get_node(pos).name == "mailbox:letterbox" then
		selected = "true"
	end
	local xbg = default.gui_bg .. default.gui_bg_img .. default.gui_slots
	local spos = pos.x .. "," .. pos.y .. "," .. pos.z

	if fs_type == 1 then
		return "size[8,9.5]" .. xbg .. default.get_hotbar_bg(0, 5.5) ..
			"checkbox[0,0;books_only;" .. FS("Only allow written books") .. ";" .. selected .. "]" ..
			"list[nodemeta:" .. spos .. ";mailbox;0,1;8,4;]" ..
			"list[current_player;main;0,5.5;8,1;]" ..
			"list[current_player;main;0,6.75;8,3;8]" ..
			"listring[nodemeta:" .. spos .. ";mailbox]" ..
			"listring[current_player;main]" ..
			"button_exit[5,0;2,1;unrent;" .. FS("Unrent") .. "]" ..
			"button_exit[7,0;1,1;exit;X]"
	else
		return "size[8,5.5]" .. xbg .. default.get_hotbar_bg(0, 1.5) ..
			"label[0,0;" .. FS("Send your goods\nto @1", owner) .. " :]" ..
			"list[nodemeta:" .. spos .. ";drop;3.5,0;1,1;]" ..
			"list[current_player;main;0,1.5;8,1;]" ..
			"list[current_player;main;0,2.75;8,3;8]" ..
			"listring[nodemeta:" .. spos .. ";drop]" ..
			"listring[current_player;main]"
	end
end

function mailbox.unrent(pos, player)
	local meta = minetest.get_meta(pos)
	local node = minetest.get_node(pos)
	node.name = "mailbox:mailbox_free"
	minetest.swap_node(pos, node)
	mailbox.after_place_free(pos, player)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname:match("mailbox:mailbox_") then
		return
	end
	if fields.unrent then
		local pos = minetest.string_to_pos(formname:sub(17))
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if inv:is_empty("mailbox") then
			mailbox.unrent(pos, player)
		else
			minetest.chat_send_player(player:get_player_name(), S("Your mailbox is not empty!"))
		end
	end
	if fields.books_only then
		local pos = minetest.string_to_pos(formname:sub(17))
		local node = minetest.get_node(pos)
		if node.name == "mailbox:mailbox" then
			node.name = "mailbox:letterbox"
			minetest.swap_node(pos, node)
		else
			node.name = "mailbox:mailbox"
			minetest.swap_node(pos, node)
		end
	end
end)


mailbox.after_place_node = function(pos, placer, _)
	local meta = minetest.get_meta(pos)
	local player_name = placer:get_player_name()

	meta:set_string("owner", player_name)
	meta:set_string("infotext", S("@1's Mailbox", player_name))

	local inv = meta:get_inventory()
	inv:set_size("mailbox", 8 * 4)
	inv:set_size("drop", 1)
end

mailbox.on_rightclick_free = function(pos, _, clicker, _)
	local node = minetest.get_node(pos)
	node.name = "mailbox:mailbox"
	minetest.swap_node(pos, node)
	mailbox.after_place_node(pos, clicker)
end

mailbox.after_place_free = function(pos, placer, _)
	local meta = minetest.get_meta(pos)
	local player_name = placer:get_player_name()

	meta:set_string("owner", player_name)
	meta:set_string("infotext", S("Free Mailbox, right-click to claim"))
end


mailbox.on_rightclick = function(pos, _, clicker, _)
	local meta = minetest.get_meta(pos)
	local player = clicker:get_player_name()
	local owner = meta:get_string("owner")
	if clicker:get_wielded_item():get_name() == "mailbox:unrenter" then
		mailbox.unrent(pos, clicker)
		return
	end
	if player == owner then
		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		minetest.show_formspec(player, "mailbox:mailbox_" .. spos, mailbox.get_formspec(pos, owner, 1))
	else
		minetest.show_formspec(player, "mailbox:mailbox", mailbox.get_formspec(pos, owner, 0))
	end
end

mailbox.can_dig = function(pos, player)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local player_name = player:get_player_name()
	local inv = meta:get_inventory()

	return inv:is_empty("mailbox") and player and player_name == owner
end

mailbox.on_metadata_inventory_put = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	if listname == "drop" then
		local inv = meta:get_inventory()
		if inv:room_for_item("mailbox", stack) then
			inv:remove_item("drop", stack)
			inv:add_item("mailbox", stack)
		end
	end
end

mailbox.allow_metadata_inventory_put = function(pos, listname, index, stack, player)
	if listname == "drop" then
		if minetest.get_node(pos).name == "mailbox:letterbox" and
			stack:get_name() ~= "default:book_written" then
			return 0
		end

		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local inv = meta:get_inventory()
		if inv:room_for_item("mailbox", stack) then
			return -1
		else
			minetest.chat_send_player(player:get_player_name(), S("Mailbox full."))
			return 0
		end
	end
	return 0
end

mailbox.allow_metadata_inventory_take = function(pos, listname, index, stack, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if mailbox.allow_interact(pos, meta:get_string("owner"), name) then
		return stack:get_count()
	end
	return 0
end

mailbox.allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local name = player:get_player_name()
	if mailbox.allow_interact(pos, meta:get_string("owner"), name) then
		return count
	end
	return 0
end

if minetest.global_exists("pipeworks") then
	mailbox.pipeworks = {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("mailbox", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("mailbox", stack)
		end,
		input_inventory = "mailbox",
		connect_sides = { left = 1, right = 1, back = 1, bottom = 1, top = 1 },
	}

	mailbox.pipeworks_free = table.copy(mailbox.pipeworks)
	mailbox.pipeworks_free.can_insert = function() return 0 end

	local old_after_place_node = mailbox.after_place_node
	mailbox.after_place_node = function(...)
		old_after_place_node(...)
		pipeworks.after_place(...)
	end

	mailbox.after_dig_node = pipeworks.after_dig
end


minetest.register_node("mailbox:mailbox", {
	description = S("Mailbox"),
	tiles = {
		"mailbox_mailbox_top.png", "mailbox_mailbox_bottom.png",
		"mailbox_mailbox_side.png", "mailbox_mailbox_side.png",
		"mailbox_mailbox.png", "mailbox_mailbox.png",
	},
	groups = { cracky = 3, oddly_breakable_by_hand = 1, tubedevice = 1, tubedevice_receiver = 1 },
	on_rotate = minetest.global_exists("screwdriver") and screwdriver.rotate_simple or nil,
	sounds = xcompat.sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	after_place_node = mailbox.after_place_node,
	after_dig_node = mailbox.after_dig_node,
	on_rightclick = mailbox.on_rightclick,
	can_dig = mailbox.can_dig,
	on_metadata_inventory_put = mailbox.on_metadata_inventory_put,
	allow_metadata_inventory_put = mailbox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = mailbox.allow_metadata_inventory_take,
	allow_metadata_inventory_move = mailbox.allow_metadata_inventory_move,
	tube = mailbox.pipeworks,
})

minetest.register_node("mailbox:mailbox_free", {
	description = S("Mailbox for Rent"),
	tiles = {
		"mailbox_mailbox_free_top.png", "mailbox_mailbox_free_bottom.png",
		"mailbox_mailbox_free_side.png", "mailbox_mailbox_free_side.png",
		"mailbox_mailbox_free.png", "mailbox_mailbox_free.png",
	},
	groups = { cracky = 3, oddly_breakable_by_hand = 1, tubedevice = 1, tubedevice_receiver = 1 },
	on_rotate = minetest.global_exists("screwdriver") and screwdriver.rotate_simple or nil,
	sounds = xcompat.sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	drop = "mailbox:mailbox",

	after_place_node = mailbox.after_place_free,
	after_dig_node = mailbox.after_dig_node,
	on_rightclick = mailbox.on_rightclick_free,
	can_dig = mailbox.can_dig,
	tube = mailbox.pipeworks_free,
})



minetest.register_node("mailbox:letterbox", {
	tiles = {
		"mailbox_letterbox_top.png", "mailbox_letterbox_bottom.png",
		"mailbox_letterbox_side.png", "mailbox_letterbox_side.png",
		"mailbox_letterbox.png", "mailbox_letterbox.png",
	},
	groups = {
		cracky = 3,
		oddly_breakable_by_hand = 1,
		not_in_creative_inventory = 1,
		tubedevice = 1,
		tubedevice_receiver = 1
	},
	on_rotate = minetest.global_exists("screwdriver") and screwdriver.rotate_simple or nil,
	sounds = xcompat.sounds.node_sound_stone_defaults(),
	paramtype2 = "facedir",
	drop = "mailbox:mailbox",
	after_place_node = mailbox.after_place_node,
	after_dig_node = mailbox.after_dig_node,
	on_rightclick = mailbox.on_rightclick,
	can_dig = mailbox.can_dig,
	on_metadata_inventory_put = mailbox.on_metadata_inventory_put,
	allow_metadata_inventory_put = mailbox.allow_metadata_inventory_put,
	allow_metadata_inventory_take = mailbox.allow_metadata_inventory_take,
	allow_metadata_inventory_move = mailbox.allow_metadata_inventory_move,
	tube = mailbox.pipeworks,
})

minetest.register_tool("mailbox:unrenter", {
	description = S("Mailbox unrenter"),
	inventory_image = "mailbox_unrent.png",
})


local materials = xcompat.materials
minetest.register_craft({
	output = "mailbox:mailbox",
	recipe = {
		{ materials.steel_ingot, materials.steel_ingot, materials.steel_ingot },
		{ materials.book,        materials.chest,       materials.book },
		{ materials.steel_ingot, materials.steel_ingot, materials.steel_ingot }
	}
})
