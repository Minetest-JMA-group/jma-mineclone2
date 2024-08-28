local S = minetest.get_translator(minetest.get_current_modname())
local mcl_cozy_print_actions = minetest.settings:get_bool("mcl_cozy_print_actions") or false

local SIT_EYE_OFFSET = {x=0, y=-7,  z=2 }
local LAY_EYE_OFFSET = {x=0, y=-13, z=-5}

mcl_cozy = {}
mcl_cozy.pos = {}

-- functions
function mcl_cozy.print_action(name, kind)
	if not mcl_cozy_print_actions then return end
	local msg
	if kind == "sit" then
		msg = " sits"
	elseif kind == "lay" then
		msg = " lies"
	elseif kind == "stand" then
		msg = " stands up"
	end
	minetest.chat_send_all("* "..name..S(msg))
end

function mcl_cozy.actionbar_show_status(player, message)
	if not message then message = S("Move to stand up") end
	if minetest.get_modpath("mcl_title") then
		mcl_title.set(player, "actionbar", {text=message, color="white", stay=60})
	elseif minetest.get_modpath("mcl_tmp_message") then
		mcl_tmp_message.message(player, message)
	else
		minetest.log("warning", "[mcl_cozy] Didn't find any mod to set titles in actionbar (mcl_title or mcl_tmp_message)!")
	end
end

local function stand_up(player, name)
	player:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
	playerphysics.remove_physics_factor(player, "speed", "mcl_cozy:attached")
	playerphysics.remove_physics_factor(player, "jump", "mcl_cozy:attached")
	mcl_player.player_attached[name] = false
	mcl_player.player_set_animation(player, "stand", 30)
	mcl_cozy.pos[name] = nil
	mcl_cozy.print_action(name, "stand")
end

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	for i=1, #players do
		local name = players[i]:get_player_name()
		-- unmount when player tries to move
		if mcl_player.player_attached[name] and not players[i]:get_attach() and
			(players[i]:get_player_control().up == true or
			players[i]:get_player_control().down == true or
			players[i]:get_player_control().left == true or
			players[i]:get_player_control().right == true or
			players[i]:get_player_control().jump == true or
			players[i]:get_player_control().sneak == true) then
				stand_up(players[i], name)
		end
		-- check the node below player (and if it's air, just unmount)
		if minetest.get_node(vector.offset(players[i]:get_pos(),0,-1,0)).name == "air" then
			players[i]:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
			playerphysics.remove_physics_factor(players[i], "speed", "mcl_cozy:attached")
			playerphysics.remove_physics_factor(players[i], "jump", "mcl_cozy:attached")
			mcl_player.player_attached[name] = false
			mcl_cozy.pos[name] = nil
		end
	end
end)

-- fix players getting stuck after they leave while still sitting
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	playerphysics.remove_physics_factor(player, "speed", "mcl_cozy:attached")
	playerphysics.remove_physics_factor(player, "jump", "mcl_cozy:attached")
	mcl_cozy.pos[name] = nil
end)

minetest.register_chatcommand("sit", {
	description = S("Sit down"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		-- check the node below player (and if it's air, just don't sit)
		if mcl_playerinfo[name].node_stand_below.name == "air" then return end

		if mcl_player.player_attached[name] then stand_up(player, name)
		else
			-- check if occupied
			for _, other_pos in pairs(mcl_cozy.pos) do
				if vector.distance(pos, other_pos) < 1 then
					mcl_cozy.actionbar_show_status(player, S("This spot is already occupied!"))
					return
				end
			end
			player:set_eye_offset(SIT_EYE_OFFSET, SIT_EYE_OFFSET)
			playerphysics.add_physics_factor(player, "speed", "mcl_cozy:attached", 0)
			playerphysics.add_physics_factor(player, "jump", "mcl_cozy:attached", 0)
			mcl_player.player_attached[name] = true
			mcl_player.player_set_animation(player, "sit", 30)
			mcl_cozy.pos[name] = pos
			mcl_cozy.print_action(name, "sit")
			mcl_cozy.actionbar_show_status(player)
		end
	end
})

minetest.register_chatcommand("lay", {
	description = S("Lay down"),
	func = function(name)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos()
		if mcl_playerinfo[name].node_stand_below.name == "air" then return end

		if mcl_player.player_attached[name] then stand_up(player, name)
		else
			-- check if occupied
			for _, other_pos in pairs(mcl_cozy.pos) do
				if vector.distance(pos, other_pos) < 1 then
					mcl_cozy.actionbar_show_status(player, S("This spot is already occupied!"))
					return
				end
			end
			player:set_eye_offset(LAY_EYE_OFFSET, LAY_EYE_OFFSET)
			playerphysics.add_physics_factor(player, "speed", "mcl_cozy:attached", 0)
			playerphysics.add_physics_factor(player, "jump", "mcl_cozy:attached", 0)
			mcl_player.player_attached[name] = true
			mcl_player.player_set_animation(player, "lay", 0)
			mcl_cozy.pos[name] = pos
			mcl_cozy.print_action(name, "lay")
			mcl_cozy.actionbar_show_status(player)
		end
	end
})

