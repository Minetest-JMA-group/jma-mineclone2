minetest.override_chatcommand("ban", {
	func = function(name, param)
		if param == "" then
			local ban_list = minetest.get_ban_list()
			if ban_list == "" then
				return true, "The ban list is empty."
			else
				return true, "Ban list: " .. ban_list
			end
		end
		if not minetest.get_player_by_name(param) then
			return false, "Player is not online."
		end
		if not minetest.ban_player(param) then
			return false, "Failed to ban player."
		end
		local desc = minetest.get_ban_description(param)
		minetest.log("action", name .. " bans " .. desc .. ".")
        xban.report_to_discord("ban: **%s** banned **%s**", name, desc)
		return true, "Banned " .. desc
	end,
})

minetest.override_chatcommand("unban", {
	func = function(name, param)
		if not minetest.unban_player_or_ip(param) then
			return false, "Failed to unban player/IP."
		end
		minetest.log("action", name .. " unbans " .. param)
        xban.report_to_discord("unban: **%s** unbanned **%s**", name, param)
		return true, "Unbanned " .. param
	end,
})

minetest.override_chatcommand("kick", {
	func = function(name, param)
		local tokick, reason = param:match("([^ ]+) (.+)")
		tokick = tokick or param
		if not minetest.kick_player(tokick, reason) then
			return false, "Failed to kick player " .. tokick
		end
		local log_reason = ""
		if reason then
			log_reason = " with reason \"" .. reason .. "\""
		end
		minetest.log("action", name .. " kicks " .. tokick .. log_reason)
        xban.report_to_discord("kick: **%s** kicked **%s** with reason: `%s`", name, tokick, reason or "")
		return true, "Kicked " .. tokick
	end,
})