local S = minetest.get_translator("afk_indicator_kick")
local MAX_INACTIVE_TIME = tonumber(minetest.settings:get("afkkick.max_inactive_time")) or 1300
local WARN_TIME = tonumber(minetest.settings:get("afkkick.warn_time")) or 100

local afk_allow_cache = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local privs = minetest.get_player_privs(name)
	if privs.allow_afk or name == "singleplayer" then
		afk_allow_cache[name] = true
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	afk_allow_cache[name] = nil
end)

minetest.register_privilege("allow_afk",{
	description = S("Can AFK without being kicked"),
	give_to_singleplayer = true,
	give_to_admin = true,
	on_grant = function(name)
		afk_allow_cache[name] = true
	end,
	on_revoke = function(name)
		afk_allow_cache[name] = nil
	end
})

local function loop()
	for x,y in pairs(afk_indicator.get_all_longer_than(MAX_INACTIVE_TIME - WARN_TIME - 1)) do
		if not afk_allow_cache[x] then
			local LEFT_TIME = MAX_INACTIVE_TIME - y
			if LEFT_TIME <= 0 then
				minetest.kick_player(x,"You habe been kicked from the server due to inactivity, if you have any questions write a e-mail to: loki@jma-sig.de")
				return
			end
			minetest.chat_send_player(x,minetest.colorize("#ece81a",S("WARNING: Please move in @1 seconds or you will be kicked due to inactivity!",LEFT_TIME)))
		end
	end
	minetest.after(1,loop)
end
minetest.after(1,loop)
