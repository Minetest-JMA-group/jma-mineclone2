local old_pos = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	afk_indicator.update(name)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	afk_indicator.delete(name)
	old_pos[name] = nil
end)

minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
	if player and player:is_player() and not player.is_fake_player then
		local name = player:get_player_name()
		afk_indicator.update(name)
	end
end)

minetest.register_on_dignode(function(pos, oldnode, player)
	if player and player:is_player() and not player.is_fake_player then
		local name = player:get_player_name()
		afk_indicator.update(name)
	end
end)

minetest.register_on_punchnode(function(pos, node, player, pointed_thing)
	if player and player:is_player() and not player.is_fake_player then
		local name = player:get_player_name()
		afk_indicator.update(name)
	end
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if player and player:is_player() and not player.is_fake_player then
		local name = player:get_player_name()
		afk_indicator.update(name)
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local name = player:get_player_name()
	afk_indicator.update(name)
end)

minetest.register_on_item_eat(function(hp_change, replace_with_item, itemstack, player, pointed_thing)
	if player and player:is_player() and not player.is_fake_player then
		local name = player:get_player_name()
		afk_indicator.update(name)
	end
end)

minetest.register_on_chat_message(function(name, message)
	afk_indicator.update(name)
end)

minetest.register_on_chatcommand(function(name, command, params)
	afk_indicator.update(name)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()
	afk_indicator.update(name)
end)

local function loop()
	for _,player in ipairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos  = player:get_pos()
		if old_pos[name] then
			if vector.distance(old_pos[name],pos) > 0.5 then
				afk_indicator.update(name)
			end
		end
		old_pos[name] = pos
	end
	minetest.after(1,loop)
end

minetest.after(0, loop)
