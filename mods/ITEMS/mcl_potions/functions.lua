local EF = {}
EF.invisibility = {}
EF.poisoning = {}
EF.regeneration = {}
EF.strength = {}
EF.weakness = {}
EF.water_breathing = {}
EF.leaping = {}
EF.swiftness = {}
EF.slowness = {}
EF.night_vision = {}
EF.fire_resistance = {}
EF.bad_omen = {}
EF.slow_falling = {}
EF.withering = {}
EF.resistance = {}

local EFFECT_TYPES = 13

local icon_ids = {}

local function potions_set_hudbar(player)
	if EF.regeneration[player] then
		if EF.poisoning[player] then
			hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_regen_poison.png", nil, "hudbars_bar_health.png")
		elseif EF.withering[player] then
			hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regen_withering.png", nil, "hudbars_bar_health.png")
		else
			hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regenerate.png", nil, "hudbars_bar_health.png")
		end
	else
		if EF.poisoning[player] then 
			hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hudbars_bar_health.png")
		elseif EF.withering[player] then
			hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_withering.png", nil, "hudbars_bar_health.png")
		else
			hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
		end
	end
end

local function potions_init_icons(player)
	local name = player:get_player_name()
	icon_ids[name] = {}
	for e=1, EFFECT_TYPES do
		local x = -52 * e - 2
		local icon = player:hud_add({
			hud_elem_type = "image",
			text = "blank.png",
			position = { x = 1, y = 0 },
			offset = { x = x, y = 3 },
			scale = { x = 0.375, y = 0.375 },
			alignment = { x = 1, y = 1 },
			z_index = 100,
		})
		local timer = player:hud_add({
			hud_elem_type = "text",
			text = "",
			number=0xFFFFFF,
			position = { x = 1, y = 0 },
			offset = { x = x+3.75, y = 45 },
			scale = { x = 0.375, y = 0.375},
			alignment = { x = 1, y = 1 },
			z_index = 100,
		})
		table.insert(icon_ids[name], {icon, timer})
	end
end

local function _ParseTime(total, gone)
	return os.date("%X", total-gone):sub(4)
end

local function potions_set_icons(player)
	local name = player:get_player_name()
	if not icon_ids[name] then
		return
	end
	local active_effects = {}
	for effect_name, effect in pairs(EF) do
		if effect[player] then
			table.insert(active_effects, effect_name)
		end
	end

	for i=1, EFFECT_TYPES do
		local icon, timer = unpack(icon_ids[name][i])
		local effect_name = active_effects[i]
		if effect_name == "swiftness" and EF.swiftness[player].is_slow then
			effect_name = "slowness"
		end
		if effect_name == nil then
			player:hud_change(icon, "text", "blank.png")
			player:hud_change(timer, "text", "")
		else
			player:hud_change(icon, "text", "mcl_potions_"..effect_name..".png^[resize:128x128")
			local data = EF[effect_name][player]
			player:hud_change(timer, "text", _ParseTime(data.dur, data.timer))
		end
	end

end

local function potions_set_hud(player)

	potions_set_hudbar(player)
	potions_set_icons(player)

end


-- ███╗░░░███╗░█████╗░██╗███╗░░██╗  ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ████╗░████║██╔══██╗██║████╗░██║  ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- ██╔████╔██║███████║██║██╔██╗██║  █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██║╚██╔╝██║██╔══██║██║██║╚████║  ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ██║░╚═╝░██║██║░░██║██║██║░╚███║  ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝  ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ░█████╗░██╗░░██╗███████╗░█████╗░██╗░░██╗███████╗██████╗░
-- ██╔══██╗██║░░██║██╔════╝██╔══██╗██║░██╔╝██╔════╝██╔══██╗
-- ██║░░╚═╝███████║█████╗░░██║░░╚═╝█████═╝░█████╗░░██████╔╝
-- ██║░░██╗██╔══██║██╔══╝░░██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
-- ╚█████╔╝██║░░██║███████╗╚█████╔╝██║░╚██╗███████╗██║░░██║
-- ░╚════╝░╚═╝░░╚═╝╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

local is_player, entity, meta
local timer = 0
minetest.register_globalstep(function(dtime)

	-- Check for invisible players
	for player, vals in pairs(EF.invisibility) do

		EF.invisibility[player].timer = EF.invisibility[player].timer + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#7F8392") end

		if EF.invisibility[player].timer >= EF.invisibility[player].dur then
			mcl_potions.make_invisible(player, false)
			EF.invisibility[player] = nil
			if player:is_player() then
				meta = player:get_meta()
				meta:set_string("_has_invisibility", minetest.serialize(EF.invisibility[player]))
			end
		end
	end

	-- Check for resistant players
	for player, vals in pairs(EF.resistance) do
		EF.resistance[player].timer = EF.resistance[player].timer + dtime
		if player:get_pos() then mcl_potions._add_spawner(player, "#7F8392") end
		if EF.resistance[player].timer >= EF.resistance[player].dur then
			EF.resistance[player] = nil
			if player:is_player() then
				player:get_meta():set_string("_has_resistance", {})
			end
		end
	end

	-- Check for poisoned players
	for player, vals in pairs(EF.poisoning) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.poisoning[player].timer = EF.poisoning[player].timer + dtime
		EF.poisoning[player].hit_timer = (EF.poisoning[player].hit_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#4E9331") end

		if EF.poisoning[player].hit_timer >= EF.poisoning[player].step then
			if mcl_util.get_hp(player) - 1 > 0 then
				mcl_util.deal_damage(player, 1, {type = "magic"})
			end
			EF.poisoning[player].hit_timer = 0
		end

		if EF.poisoning[player] and EF.poisoning[player].timer >= EF.poisoning[player].dur then
			EF.poisoning[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_has_poisoning", minetest.serialize(EF.poisoning[player]))
			end
		end

	end

	-- Check for regnerating players
	for player, vals in pairs(EF.regeneration) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.regeneration[player].timer = EF.regeneration[player].timer + dtime
		EF.regeneration[player].heal_timer = (EF.regeneration[player].heal_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#CD5CAB") end

		if EF.regeneration[player].heal_timer >= EF.regeneration[player].step then

			if is_player then
				player:set_hp(math.min(player:get_properties().hp_max or 20, player:get_hp() + 1), { type = "set_hp", other = "regeneration" })
				EF.regeneration[player].heal_timer = 0
			elseif entity and entity.is_mob then
				entity.health = math.min(entity.hp_max, entity.health + 1)
				EF.regeneration[player].heal_timer = 0
			else -- stop regenerating if not a player or mob
				EF.regeneration[player] = nil
			end

		end

		if EF.regeneration[player] and EF.regeneration[player].timer >= EF.regeneration[player].dur then
			EF.regeneration[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_has_regeneration", minetest.serialize(EF.regeneration[player]))
			end
		end
	end

	-- Check for water breathing players
	for player, vals in pairs(EF.water_breathing) do

		if player:is_player() then

			EF.water_breathing[player].timer = EF.water_breathing[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#2E5299") end

			if player:get_breath() then
				hb.hide_hudbar(player, "breath")
				if player:get_breath() < 10 then player:set_breath(10) end
			end

			if EF.water_breathing[player].timer >= EF.water_breathing[player].dur then
				meta = player:get_meta()
				meta:set_string("_has_water_breathing", minetest.serialize(EF.water_breathing[player]))
				EF.water_breathing[player] = nil
			end
		else
			EF.water_breathing[player] = nil
		end

	end

	-- Check for leaping players
	for player, vals in pairs(EF.leaping) do

		if player:is_player() then

			EF.leaping[player].timer = EF.leaping[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#22FF4C") end

			if EF.leaping[player].timer >= EF.leaping[player].dur then
				playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")
				EF.leaping[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_leaping", minetest.serialize(EF.leaping[player]))
			end
		else
			EF.leaping[player] = nil
		end

	end

	-- Check for swift players
	for player, vals in pairs(EF.swiftness) do
		if player:is_player() then
			EF.swiftness[player].timer = EF.swiftness[player].timer + dtime
			if player:get_pos() then mcl_potions._add_spawner(player, "#7CAFC6") end
			if EF.swiftness[player].timer >= EF.swiftness[player].dur then
				playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")
				EF.swiftness[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_swiftness", minetest.serialize(EF.swiftness[player]))
			end
		else
			EF.swiftness[player] = nil
		end
	end

	-- Check for slow players
	for player, _ in pairs(EF.slowness) do
		if player:is_player() then
			EF.slowness[player].timer = EF.slowness[player].timer + dtime
			if player:get_pos() then mcl_potions._add_spawner(player, "#7CAFC6") end
			if EF.slowness[player].timer >= EF.slowness[player].dur then
				playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")
				EF.slowness[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_slowness", minetest.serialize(EF.slowness[player]))
			end
		else
			EF.slowness[player] = nil
		end
	end

	-- Check for slow falling players
	for player, vals in pairs(EF.slow_falling) do
		if player:is_player() then
			EF.slow_falling[player].timer = EF.slow_falling[player].timer + dtime
			if player:get_pos() then mcl_potions._add_spawner(player, "#7CAFC6") end
			if EF.slow_falling[player].timer >= EF.slow_falling[player].dur then
				playerphysics.remove_physics_factor(player, "gravity", "mcl_potions:slow_falling")
				EF.slow_falling[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_slow_falling", minetest.serialize(EF.slow_falling[player]))
			end
		else
			EF.slow_falling[player] = nil
		end
	end

	-- Check for Night Vision equipped players
	for player, vals in pairs(EF.night_vision) do

		if player:is_player() then

			EF.night_vision[player].timer = EF.night_vision[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#1F1FA1") end

			if EF.night_vision[player].timer >= EF.night_vision[player].dur then
				EF.night_vision[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_night_vision", minetest.serialize(EF.night_vision[player]))
				meta:set_int("night_vision", 0)
			end
			mcl_weather.skycolor.update_sky_color({player})
		else
			EF.night_vision[player] = nil
		end

	end

	-- Check for Fire Proof players
	for player, vals in pairs(EF.fire_resistance) do

		if player:is_player() then

			player = player or player:get_luaentity()

			EF.fire_resistance[player].timer = EF.fire_resistance[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#E49A3A") end

			if EF.fire_resistance[player].timer >= EF.fire_resistance[player].dur then
				EF.fire_resistance[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_fire_resistance", minetest.serialize(EF.fire_resistance[player]))
			end
		else
			EF.fire_resistance[player] = nil
		end

	end

	-- Check for Weak players
	for player, vals in pairs(EF.weakness) do

		if player:is_player() then

			EF.weakness[player].timer = EF.weakness[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#484D48") end

			if EF.weakness[player].timer >= EF.weakness[player].dur then
				EF.weakness[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_weakness", minetest.serialize(EF.weakness[player]))
			end
		else
			EF.weakness[player] = nil
		end

	end

	-- Check for Strong players
	for player, vals in pairs(EF.strength) do

		if player:is_player() then

			EF.strength[player].timer = EF.strength[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#932423") end

			if EF.strength[player].timer >= EF.strength[player].dur then
				EF.strength[player] = nil
				meta = player:get_meta()
				meta:set_string("_has_strength", minetest.serialize(EF.strength[player]))
			end

		else
			EF.strength[player] = nil
		end

	end


	-- Check for Withered players
	for player, vals in pairs(EF.withering) do
		is_player = player:is_player()
		entity = player:get_luaentity()
		EF.withering[player].timer = EF.withering[player].timer + dtime
		EF.withering[player].hit_timer = (EF.withering[player].hit_timer or 0) + dtime
		if player:get_pos() then mcl_potions._add_spawner(player, "#000000") end
		if EF.withering[player].hit_timer >= EF.withering[player].step then
			if is_player or entity then mcl_util.deal_damage(player, 1, {type = "magic"}) end
			if EF.withering[player] then EF.withering[player].hit_timer = 0 end
		end
		if EF.withering[player].timer >= EF.withering[player].dur then
			EF.withering[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_withering", minetest.serialize(EF.withering[player]))
			end
		end
	end

	-- Check for Bad Omen
	for player, vals in pairs(EF.bad_omen) do

		is_player = player:is_player()

		EF.bad_omen[player].timer = EF.bad_omen[player].timer + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#0b6138") end

		if EF.bad_omen[player] and EF.bad_omen[player].timer >= EF.bad_omen[player].dur then
			EF.bad_omen[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_has_bad_omen", minetest.serialize(EF.bad_omen[player]))
			end
		end

	end
        
    if timer > 22 then
		for _, player in ipairs(minetest.get_connected_players()) do
			potions_set_hud(player)
		end
		timer = 0
	end
	timer = timer + 1
end)

-- Prevent damage to player with Fire Resistance enabled
mcl_damage.register_modifier(function(obj, damage, reason)
	if EF.fire_resistance[obj] and not reason.flags.bypasses_magic and reason.flags.is_fire then
		return 0
	end
end, -50)



-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ██╗░░░░░░█████╗░░█████╗░██████╗░░░░░██╗░██████╗░█████╗░██╗░░░██╗███████╗
-- ██║░░░░░██╔══██╗██╔══██╗██╔══██╗░░░██╔╝██╔════╝██╔══██╗██║░░░██║██╔════╝
-- ██║░░░░░██║░░██║███████║██║░░██║░░██╔╝░╚█████╗░███████║╚██╗░██╔╝█████╗░░
-- ██║░░░░░██║░░██║██╔══██║██║░░██║░██╔╝░░░╚═══██╗██╔══██║░╚████╔╝░██╔══╝░░
-- ███████╗╚█████╔╝██║░░██║██████╔╝██╔╝░░░██████╔╝██║░░██║░░╚██╔╝░░███████╗
-- ╚══════╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝

local effects_list = {"invisibility", "poisoning", "regeneration", "strength", "weakness", "water_breathing", "leaping", "swiftness", "night_vision", "fire_resistance", "bad_omen", "slow_falling", "resistance", "slowness"}

function mcl_potions._clear_cached_player_data(player)
	for _, effect in ipairs(effects_list) do
		EF[effect][player] = nil
	end
	meta = player:get_meta()
	meta:set_int("night_vision", 0)
end

function mcl_potions._reset_player_effects(player, set_hud)
	if not player:is_player() then return end
	mcl_potions.make_invisible(player, false)
	playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")
	playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")
	playerphysics.remove_physics_factor(player, "gravity", "mcl_potions:slow_falling")
	mcl_weather.skycolor.update_sky_color({player})
	mcl_potions._clear_cached_player_data(player)
end

function mcl_potions._save_player_effects(player)
	if not player:is_player() then return end
	meta = player:get_meta()
	for _, effect in ipairs(effects_list) do
		meta:set_string("_has_" .. effect, minetest.serialize(EF[effect][player]))
	end
end

function mcl_potions._load_player_effects(player)
	if not player:is_player() then return end
	meta = player:get_meta()
	for _, effect in ipairs(effects_list) do
		local data = minetest.deserialize(meta:get_string("_has_" .. effect))
		if data then
			EF[effect][player] = data
			if effect == "invisibility" then mcl_potions.make_invisible(player, true) end
		end
	end
end

-- Returns true if player has given effect
function mcl_potions.player_has_effect(player, effect_name)
	if not EF[effect_name] then
		return false
	end
	return EF[effect_name][player] ~= nil
end

function mcl_potions.player_get_effect(player, effect_name)
	if not EF[effect_name] or not EF[effect_name][player] then
		return false
	end
	return EF[effect_name][player]
end

function mcl_potions.player_clear_effect(player,effect)
	EF[effect][player] = nil
	potions_set_icons(player)
end

minetest.register_on_leaveplayer(function(player)
	mcl_potions._save_player_effects(player)
	mcl_potions._clear_cached_player_data(player) -- clearout the buffer to prevent looking for a player not there
	icon_ids[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer(function(player)
	mcl_potions._reset_player_effects(player)
end)

minetest.register_on_joinplayer( function(player)
	mcl_potions._reset_player_effects(player, false) -- make sure there are no wierd holdover effects
	mcl_potions._load_player_effects(player)
	potions_init_icons(player)
	-- .after required because player:hud_change doesn't work when called
	-- in same tick as player:hud_add
	-- (see <https://github.com/minetest/minetest/pull/9611>)
	-- FIXME: Remove minetest.after
	minetest.after(3, function(player)
		if player and player:is_player() then
		end
	end, player)
end)

minetest.register_on_shutdown(function()
	-- save player effects on server shutdown
	for _,player in pairs(minetest.get_connected_players()) do
		mcl_potions._save_player_effects(player)
	end

end)


-- ░██████╗██╗░░░██╗██████╗░██████╗░░█████╗░██████╗░████████╗██╗███╗░░██╗░██████╗░
-- ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░
-- ╚█████╗░██║░░░██║██████╔╝██████╔╝██║░░██║██████╔╝░░░██║░░░██║██╔██╗██║██║░░██╗░
-- ░╚═══██╗██║░░░██║██╔═══╝░██╔═══╝░██║░░██║██╔══██╗░░░██║░░░██║██║╚████║██║░░╚██╗
-- ██████╔╝╚██████╔╝██║░░░░░██║░░░░░╚█████╔╝██║░░██║░░░██║░░░██║██║░╚███║╚██████╔╝
-- ╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

function mcl_potions.is_obj_hit(self, pos)

	local entity
	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1.1)) do

		entity = object:get_luaentity()

		if entity and entity.name ~= self.object:get_luaentity().name then

			if entity.is_mob then
				return true
			end

		elseif object:is_player() and self._thrower ~= object:get_player_name() then
			return true
		end

	end
	return false
end

function mcl_potions.make_invisible(obj_ref, hide)
	if obj_ref:is_player() then
		if hide then
			mcl_player.player_set_visibility(obj_ref, false)
			obj_ref:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}, text=" "})
            obj_ref:set_properties({show_on_minimap = false})
		else
			mcl_player.player_set_visibility(obj_ref, true)
            obj_ref:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}, text=obj_ref:get_player_name()})
            obj_ref:set_properties({show_on_minimap = true})
		end
	else
		if hide then
			local luaentity = obj_ref:get_luaentity()
			EF.invisibility[obj_ref].old_size = luaentity.visual_size
			obj_ref:set_properties({ visual_size = { x = 0, y = 0 } })
		else
			obj_ref:set_properties({ visual_size = EF.invisibility[obj_ref].old_size })
		end
	end
end


function mcl_potions._use_potion(item, obj, color)
	local d = 0.1
	local pos = obj:get_pos()
	minetest.sound_play("mcl_potions_drinking", {pos = pos, max_hear_distance = 6, gain = 1})
	minetest.add_particlespawner({
		amount = 25,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 1,
		maxexptime = 5,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = true,
		vertical = false,
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
	})
end


function mcl_potions._add_spawner(obj, color)
	local d = 0.2
	local pos = obj:get_pos()
	minetest.add_particlespawner({
		amount = 1,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
	})
end



-- ██████╗░░█████╗░░██████╗███████╗  ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗██╔════╝██╔════╝  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╦╝███████║╚█████╗░█████╗░░  ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔══██╗██╔══██║░╚═══██╗██╔══╝░░  ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██████╦╝██║░░██║██████╔╝███████╗  ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝  ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

function mcl_potions.swiftness_func(player, level, duration)
	if not player:get_meta() then return false end
	if not EF.swiftness[player] then
		EF.swiftness[player] = {dur = duration, timer = 0}
	else
		local victim = EF.swiftness[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
	playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", 1 + 0.20*level)
end

function mcl_potions.slowness_func(player, level, duration)
	if not player:get_meta() then return false end
	if not EF.slowness[player] then
		EF.slowness[player] = {dur = duration, timer = 0}
	else
		local victim = EF.slowness[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
	playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", 1 - 0.15*level)
end

function mcl_potions.leaping_func(player, level, duration)
	if not player:get_meta() then return false end
	if not EF.leaping[player] then
		EF.leaping[player] = {dur = duration, timer = 0}
	else
		local victim = EF.leaping[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
	playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", 1 + 0.50*level)
end

function mcl_potions.apply_usual_effect(player, level, duration, effect_name)
	if not EF[effect_name][player] then
		EF[effect_name][player] = {dur = duration, timer = 0, factor = level}
	else
		local victim = EF[effect_name][player]
		victim.factor = level
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
end

function mcl_potions.fire_resistance_func(player, level, duration)
    mcl_potions.apply_usual_effect(player, level, duration, "fire_resistance")
end

function mcl_potions.slow_falling_func(player, factor, duration)
	if not player:get_meta() then return false end
	if not EF.slow_falling[player] then
		EF.slow_falling[player] = {dur = duration, timer = 0}
	else
		local victim = EF.slow_falling[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
	playerphysics.add_physics_factor(player, "gravity", "mcl_potions:slow_falling", 0.3)
end


function mcl_potions.poison_func(player, factor, duration)

	if not EF.poisoning[player] then

		EF.poisoning[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = EF.poisoning[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end
end


function mcl_potions.regeneration_func(player, factor, duration)
	if not EF.regeneration[player] then
		EF.regeneration[player] = {step = factor, dur = duration, timer = 0}
	else
		local victim = EF.regeneration[player]
		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
end


function mcl_potions.invisiblility_func(player, null, duration)

	if not EF.invisibility[player] then

		EF.invisibility[player] = {dur = duration, timer = 0}
		mcl_potions.make_invisible(player, true)

	else

		local victim = EF.invisibility[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end

function mcl_potions.night_vision_func(player, null, duration)

	meta = player:get_meta()
	if not EF.night_vision[player] then

		EF.night_vision[player] = {dur = duration, timer = 0}

	else

		local victim = EF.night_vision[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	is_player = player:is_player()
	if is_player then
		meta:set_int("night_vision", 1)
	else
		return -- Do not attempt to set night_vision on mobs
	end
	mcl_weather.skycolor.update_sky_color({player})
end

function mcl_potions.withering_func(player, factor, duration)
	if not player or player:get_hp() <= 0 then return false end
	local entity = player:get_luaentity()
	if entity and (entity.is_boss or string.find(entity.name, "wither")) then return false end
	if not EF.withering[player] then
		EF.withering[player] = {step = factor, dur = duration, timer = 0}
	else
		local victim = EF.withering[player]
		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
	end
end

function mcl_potions._extinguish_nearby_fire(pos, radius)
	local epos = {x=pos.x, y=pos.y+0.5, z=pos.z}
	local dnode = minetest.get_node({x=pos.x,y=pos.y-0.5,z=pos.z})
	if minetest.get_item_group(dnode.name, "fire") ~= 0 then
		epos.y = pos.y - 0.5
	end
	local exting = false
	-- No radius: Splash, extinguish epos and 4 nodes around
	if not radius then
		local dirs = {
			{x=0,y=0,z=0},
			{x=0,y=0,z=-1},
			{x=0,y=0,z=1},
			{x=-1,y=0,z=0},
			{x=1,y=0,z=0},
		}
		for d=1, #dirs do
			local tpos = vector.add(epos, dirs[d])
			local node = minetest.get_node(tpos)
			if minetest.get_item_group(node.name, "fire") ~= 0 then
				minetest.sound_play("fire_extinguish_flame", {pos = tpos, gain = 0.25, max_hear_distance = 16}, true)
				minetest.remove_node(tpos)
				exting = true
			end
		end
	-- Has radius: lingering, extinguish all nodes in area
	else
		local nodes = minetest.find_nodes_in_area(
			{x=epos.x-radius,y=epos.y,z=epos.z-radius},
			{x=epos.x+radius,y=epos.y,z=epos.z+radius},
			{"group:fire"})
		for n=1, #nodes do
			minetest.sound_play("fire_extinguish_flame", {pos = nodes[n], gain = 0.25, max_hear_distance = 16}, true)
			minetest.remove_node(nodes[n])
			exting = true
		end
	end
	return exting
end

function mcl_potions.bad_omen_func(player, factor, duration)
	if not EF.bad_omen[player] then
		EF.bad_omen[player] = {dur = duration, timer = 0, factor = factor}
	else
		local victim = EF.bad_omen[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
		victim.factor = factor
	end
end