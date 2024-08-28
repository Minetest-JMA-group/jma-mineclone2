-- mcl_decor/api.lua

local S = minetest.get_translator(minetest.get_current_modname())

local DISTANCE_THRESHOLD = 3
local VELOCITY_THRESHOLD = 0.125
local PLAYERSP_THRESHOLD = 0.1

-- originally from the ts_furniture mod (which is from cozy) by Thomas-S
-- <https://github.com/minetest-mods/ts_furniture/>
mcl_decor.sit = function(pos, _, player)
	local name = player:get_player_name()
	local ppos = player:get_pos()
	if not player or not name then return end
	if not mcl_player.player_attached[name] then
		-- check distance
		if vector.distance(pos, ppos) > DISTANCE_THRESHOLD then
			mcl_title.set(player, "actionbar", {text=S("You can't sit, the block's too far away!"), stay=60})
			return
		end
		-- check movement
		if vector.length(player:get_velocity() or player:get_player_velocity()) > VELOCITY_THRESHOLD then
			mcl_title.set(player, "actionbar", {text=S("You have to stop moving before sitting down!"), stay=60})
			return
		end
		-- check if occupied
		for _, other_pos in pairs(mcl_cozy.pos) do
			if vector.distance(pos, other_pos) < PLAYERSP_THRESHOLD then
				mcl_title.set(player, "actionbar", {text=S("This block is already occupied!"), stay=60})
				return
			end
		end

		player:move_to(pos)
		player:set_eye_offset({x = 0, y = -7, z = 0}, {x = 0, y = -7, z = 0})
		playerphysics.add_physics_factor(player, "speed", "mcl_cozy:attached", 0)
		playerphysics.add_physics_factor(player, "jump", "mcl_cozy:attached", 0)

		mcl_player.player_attached[name] = true

		mcl_cozy.pos[name] = pos

		minetest.after(0.1, function()
			if player then
				mcl_player.player_set_animation(player, "sit" , 30)
			end
		end)

		mcl_cozy.print_action(name, "sit")
		mcl_cozy.actionbar_show_status(player)
	else
		mcl_cozy.pos[name] = nil
		mcl_decor.stand(player, name)
	end
end

mcl_decor.up = function(_, _, player)
	local name = player:get_player_name()
	if not player or not name then return end
	mcl_cozy.pos[name] = nil
	if mcl_player.player_attached[name] then
		mcl_decor.stand(player, name)
	end
end

mcl_decor.stand = function(player, name)
	player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
	playerphysics.remove_physics_factor(player, "speed", "mcl_cozy:attached")
	playerphysics.remove_physics_factor(player, "jump", "mcl_cozy:attached")
	mcl_player.player_attached[name] = false
	mcl_player.player_set_animation(player, "stand", 30)
	mcl_cozy.print_action(name, "stand")
end
