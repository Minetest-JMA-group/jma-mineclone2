local S = minetest.get_translator(minetest.get_current_modname())

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local music_enabled = minetest.settings:get_bool("mcl_game_music", true)

local pianowtune  = "diminixed-pianowtune02"
local end_tune    = "diminixed-ambientwip02"
local never_grow_up = "diminixed-nevergrowup04"
local nether_tune = "horizonchris96-traitor"
local odd_block = "Jester-0dd-BL0ck"
local flock_of_one = "Jester-Flock-of-One"
local gift = "Jester-Gift"
local hailing_forest = "Jester-Hailing_Forest"
local lonely_blossom = "exhale_and_tim_unwin-lonely_blossom"
local valley_of_ghosts = "exhale_and_tim_unwin-valley_of_ghosts"
local farmer = "exhale_and_tim_unwin-farmer"

local dimension_to_base_track = {
	["overworld"]	= {pianowtune, never_grow_up, flock_of_one, gift, hailing_forest, lonely_blossom, farmer},
	["nether"]		= {nether_tune, valley_of_ghosts},
	["end"]			= {end_tune},
	["mining"]		= {odd_block},
}

local listeners = {}

local function pick_track(dimension, underground)
	local track_key

	if dimension == "overworld" and underground then
		track_key = "mining"
	else
		-- Pick random dimension song
		track_key = dimension
	end

	local dimension_tracks = dimension_to_base_track[track_key]

	if dimension_tracks and #dimension_tracks >= 1 then
		local index = 1
		if #dimension_tracks > 1 then
			index = math.random(1, #dimension_tracks)
		end
		local chosen_track = dimension_tracks[index]
		--minetest.log("chosen_track: " .. chosen_track)
		minetest.log("action", "[mcl_music] Playing track: " .. chosen_track .. ", for context: " .. track_key)
		return chosen_track
	else
		-- ?
	end

	return nil
end


local function stop_music_for_listener_name(listener_name)
	if not listener_name then return end
	local listener = listeners[listener_name]
	if not listener then return end
	local handle = listener.handle
	if not handle then return end

	minetest.log("action", "[mcl_music] Stopping music")
	minetest.sound_stop(handle)
	listeners[listener_name].handle = nil
end

local function stop_music_for_all()
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end
end

local function play_song(track, player_name, dimension, day_count)
	local spec = {
		name  = track,
		gain  = 0.3,
		pitch = 1.0,
	}
	local parameters = {
		to_player = player_name,
		gain      = 1.0,
		fade      = 0.0,
		pitch     = 1.0,
	}
	local handle = minetest.sound_play(spec, parameters, false)
	listeners[player_name] = {
		handle     = handle,
		dimension  = dimension,
		day_count  = day_count,
	}
end

local function play()
	local time = minetest.get_timeofday()
	if time < 0.25 or time >= 0.75 then
		stop_music_for_all()
		minetest.after(10, play)
		return
	end

	local day_count = minetest.get_day_count()
	for _, player in pairs(minetest.get_connected_players()) do
		if not player:get_meta():get("mcl_music:disable") then
			local player_name = player:get_player_name()
			local hp          = player:get_hp()
			local pos         = player:get_pos()
			local dimension   = mcl_worlds.pos_to_dimension(pos)

			local listener      = listeners[player_name]
			local handle = listener and listener.handle

			--local old_hp			= listener and listener.hp
			--local is_hp_changed 	= old_hp and (math.abs(old_hp - hp) > 0.00001) or false

			local old_dimension		= listener and listener.dimension
			local is_dimension_changed = old_dimension and (old_dimension ~= dimension) or false

			-- minetest.log("handle: " .. dump (handle))
			if is_dimension_changed then
				stop_music_for_listener_name(player_name)
				if not listeners[player_name] then
					listeners[player_name] = {}
				end
				listeners[player_name].hp = hp
				listeners[player_name].dimension = dimension
			elseif not handle and (not listener or (listener.day_count ~= day_count)) then
				local underground = dimension == "overworld" and pos and pos.y < 0
				local track = pick_track(dimension, underground)
				if track then
					play_song(track, player_name, dimension, day_count)
				else
					--minetest.log("no track found. weird")
				end
			else
				--minetest.log("else")
			end
		end
	end

	minetest.after(7, play)
end

if music_enabled then
	minetest.log("action", "[mcl_music] In-game music is activated")
	minetest.after(15, play)

	minetest.register_on_joinplayer(function(player, last_login)
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end)

	minetest.register_on_leaveplayer(function(player, timed_out)
		listeners[player:get_player_name()] = nil
	end)

	minetest.register_on_respawnplayer(function(player)
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end)
else
	minetest.log("action", "[mcl_music] In-game music is deactivated")
end

minetest.register_chatcommand("music", {
	params = "[on|off|invert [<player name>]]",
	description = S("Turns music for yourself or another player on or off."),
	func = function(sender_name, params)
		local argtable = {}
		for str in string.gmatch(params, "([^%s]+)") do
			table.insert(argtable, str)
		end

		local action = argtable[1]
		local playername = argtable[2]

		local sender = minetest.get_player_by_name(sender_name)
		local target_player = nil

		if not action or action == "" then action = "invert" end

		if not playername or playername == "" or sender_name == playername then
			target_player = sender
			playername =sender_name
		elseif not minetest.check_player_privs(sender, "debug") then -- Self-use handled above
			minetest.chat_send_player(sender_name, S("You need the debug privilege in order to turn ingame music on or off for somebody else!"))
			return
		else -- Admin
			target_player = minetest.get_player_by_name(playername)
		end

		if not target_player then
			minetest.chat_send_player(sender_name, S("Couldn't find player @1!", playername))
			return
		end

		local meta = target_player:get_meta()
		local display_new_state = "unknown" -- Should never be displayed -> no translation

		if action == "invert" then
			if not meta:get("mcl_music:disable") then
				meta:set_int("mcl_music:disable", 1)
				display_new_state = S("off")
			else
				meta:set_string("mcl_music:disable", "") -- This deletes the meta value!
				display_new_state = S("on")
			end
		elseif action == "on" then
			meta:set_string("mcl_music:disable", "") -- Delete
			display_new_state = S("on")
		else
			meta:set_int("mcl_music:disable", 1)
			display_new_state = S("off")
		end
		
		stop_music_for_listener_name(playername)
		minetest.chat_send_player(sender_name, S("Set music for @1 to: @2", playername, display_new_state))
	end, 
})