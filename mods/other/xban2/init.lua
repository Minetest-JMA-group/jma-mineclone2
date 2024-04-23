-- Muting functionality added; backwards-compatible with old database and API
xban = { MP = minetest.get_modpath(minetest.get_current_modname()) }

local is_discordmt_enabled = discord and discord.enabled
local discord_channel = "1092069636792659989"
local discord_mute_log_channel = "1210689151993774180"

dofile(xban.MP.."/serialize.lua")

local db = { }
local tempbans = { }
local tempmutes = { }

local DEF_SAVE_INTERVAL = 300 -- 5 minutes
local DEF_DB_FILENAME = minetest.get_worldpath().."/xban.db"

local DB_FILENAME = minetest.settings:get("xban.db_filename")
local SAVE_INTERVAL = tonumber(
  minetest.settings:get("xban.db_save_interval")) or DEF_SAVE_INTERVAL

if (not DB_FILENAME) or (DB_FILENAME == "") then
	DB_FILENAME = DEF_DB_FILENAME
end

local function make_logger(level)
	return function(text, ...)
		minetest.log(level, "[xban] "..text:format(...))
	end
end

local ACTION = make_logger("action")
local WARNING = make_logger("warning")

function xban.report_to_discord(message, ...)
	if not is_discordmt_enabled then
		return
	end
	discord.send(string.format(message, ...), discord_channel)
end

function xban.log_message_to_discord(message, ...)
	if not is_discordmt_enabled then
		return
	end
	discord.send(string.format(message, ...), discord_mute_log_channel)
end

local unit_to_secs = {
	s = 1, m = 60, h = 3600,
	D = 86400, W = 604800, M = 2592000, Y = 31104000,
	[""] = 1,
}

local function parse_time(t) --> secs
	local secs = 0
	for num, unit in t:gmatch("(%d+)([smhDWMY]?)") do
		secs = secs + (tonumber(num) * (unit_to_secs[unit] or 1))
	end
	return secs
end

local function concat_keys(t, sep)
	local keys = {}
	for k, _ in pairs(t) do
		keys[#keys + 1] = k
	end
	return table.concat(keys, sep)
end

function xban.find_entry(player, create, modname) --> entry, [index]
	for index, e in ipairs(db) do
		for name in pairs(e.names) do
			if name == player then
				if modname then
					modname = "modstorage:"..modname
					e[modname] = e[modname] or {}
					return e[modname]
				end
				return e, index
			end
		end
	end
	if create then
		print(("Created new entry for `%s'"):format(player))
		local e = {
			names = { [player]=true },
			banned = false,
			muted = false,
			record = { },
		}
		table.insert(db, e)
		if modname then
			modname = "modstorage:"..modname
			e[modname] = e[modname] or {}
			return e[modname]
		end
		return e, #db
	end
	return nil
end

function xban.get_info(player) --> ip_name_list, banned, last_record, muted
	local e = xban.find_entry(player)
	if not e then
		return nil, "No such entry"
	end
	return e.names, e.banned, e.record[#e.record], (e.muted or false)
end

function xban.ban_player(player, source, expires, reason) --> bool, err
	if xban.get_whitelist(player) then
		return nil, "Player is whitelisted; remove from whitelist first"
	end
	local e = xban.find_entry(player, true)
	if e.banned then
		return nil, "Already banned"
	end
	local rec = {
		source = source,
		time = os.time(),
		expires = expires,
		reason = reason,
		action = "ban",
	}
	table.insert(e.record, rec)
	e.names[player] = true
	local pl = minetest.get_player_by_name(player)
	if pl then
		local ip = minetest.get_player_ip(player)
		if ip then
			e.names[ip] = true
		end
		e.last_pos = pl:getpos()
	end
	e.reason = reason
	e.time = os.time()
	e.expires = expires
	e.banned = true
	if expires then
		table.insert(tempbans, e)
	end
	local msg
	local date = (expires and os.date("%c", expires) or "the end of time")
	msg = ("Banned: Expires: %s, Reason: %s"):format(date, reason)
	for nm in pairs(e.names) do
		minetest.kick_player(nm, msg)
	end
	ACTION("%s bans %s until %s for reason: %s", source, player,
	  date, reason)
	ACTION("Banned Names/IPs: %s", concat_keys(e.names, ", "))
	xban.report_to_discord("xban: **%s** banned **%s** for `%s` with the reason: `%s`",
        source, player, date, reason)
	return true
end

function xban.unban_player(player, source) --> bool, err
	local e = xban.find_entry(player)
	if not e then
		return nil, "No such entry"
	end
	if not e.banned then
		return nil, "Not banned"
	end
	local rec = {
		source = source,
		time = os.time(),
		reason = "Unbanned",
	}
	table.insert(e.record, rec)
	e.banned = false
	e.reason = nil
	e.expires = nil
	e.time = nil
	ACTION("%s unbans %s", source, player)
	ACTION("Unbanned Names/IPs: %s", concat_keys(e.names, ", "))
	xban.report_to_discord("xunban: **%s** unbanned **%s**", source, player)
	return true
end

-- Made with xban.ban_player as a template
function xban.mute_player(player, source, expires, reason) --> bool, err
	if xban.get_whitelist(player) then
		return nil, "Player is whitelisted; remove from whitelist first"
	end
	local e = xban.find_entry(player, true)
	if e.muted then
		return nil, "Already muted"
	end
	local rec = {
		source = source,
		time = os.time(),
		expires = expires,
		reason = reason,
		action = "mute",
	}
	table.insert(e.record, rec)
	e.names[player] = true
	local pl = minetest.get_player_by_name(player)
	if pl then
		local ip = minetest.get_player_ip(player)
		if ip then
			e.names[ip] = true
		end
		e.last_pos = pl:getpos()
	end
	e.mute_reason = reason
	e.mute_time = os.time()
	e.mute_expires = expires
	e.muted = true
	if expires then
		table.insert(tempmutes, e)
	end
	local msg
	local date = (expires and os.date("%c", expires) or "the end of time")
	msg = ("Muted: Expires: %s, Reason: %s"):format(date, reason)
	ACTION("%s mutes %s until %s for reason: %s", source, player,
	  date, reason)
	ACTION("Muted Names/IPs: %s", concat_keys(e.names, ", "))
	xban.report_to_discord("xmute: **%s** muted **%s** for `%s` with the reason: `%s`",
        source, player, date, reason)
	return true
end

-- Made with xban.unban_player as a template
function xban.unmute_player(player, source) --> bool, err
	local e = xban.find_entry(player)
	if not e then
		return nil, "No such entry"
	end
	if not e.muted then
		return nil, "Not muted"
	end
	local rec = {
		source = source,
		time = os.time(),
		reason = "Unmuted",
	}
	table.insert(e.record, rec)
	e.muted = false
	e.mute_reason = nil
	e.mute_expires = nil
	e.mute_time = nil
	ACTION("%s unmutes %s", source, player)
	ACTION("Unmuted Names/IPs: %s", concat_keys(e.names, ", "))
	xban.report_to_discord("xunmute: **%s** unmuted **%s**", source, player)
	return true
end

function xban.get_whitelist(name_or_ip)
	return db.whitelist and db.whitelist[name_or_ip]
end

function xban.remove_whitelist(name_or_ip)
	if db.whitelist then
		db.whitelist[name_or_ip] = nil
	end
end

function xban.add_whitelist(name_or_ip, source)
	local wl = db.whitelist
	if not wl then
		wl = { }
		db.whitelist = wl
	end
	wl[name_or_ip] = {
		source=source,
	}
	return true
end

function xban.get_record(player)
	local e = xban.find_entry(player)
	if not e then
		return nil, ("No entry for `%s'"):format(player)
	elseif (not e.record) or (#e.record == 0) then
		return nil, ("`%s' has no ban records"):format(player)
	end
	local record = { }
	for _, rec in ipairs(e.record) do
		local msg
		if rec.action and rec.action == "mute" then
			msg = "MUTE: "
		else
			msg = "BAN: "
		end
		msg = msg..(rec.reason or "No reason given.")
		if rec.expires then
			msg = msg..(", Expires: %s"):format(os.date("%c", rec.expires))
		end
		if rec.source then
			msg = msg..", Source: "..rec.source
		end
		if rec.expires and rec.expires > os.time() then
			if not e.muted and rec.action and rec.action == "mute" then
				msg = msg..", Manually unmuted"
			elseif not e.banned then
				msg = msg..", Manually unbanned"
			end
		end
		table.insert(record, ("[%s]: %s"):format(os.date("%c", rec.time), msg))
	end
	local last_pos
	if e.last_pos then
		last_pos = ("User was last seen at %s"):format(
		  minetest.pos_to_string(e.last_pos))
	end
	return record, last_pos
end

minetest.register_on_prejoinplayer(function(name, ip)
	local wl = db.whitelist or { }
	if wl[name] or wl[ip] then return end
	local e = xban.find_entry(name) or xban.find_entry(ip)
	if not e then return end
	if e.banned then
		local date = (e.expires and os.date("%c", e.expires)
		  or "the end of time")
		return ("Banned: Expires: %s, Reason: %s"):format(
		  date, e.reason)
	end
end)

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local e = xban.find_entry(name)
	local ip = minetest.get_player_ip(name)
	if not e then
		e = xban.find_entry(name, true)
	end
	e.names[name] = true
	if ip then
		e.names[ip] = true
	end
	e.last_seen = os.time()
end)

minetest.register_chatcommand("xban", {
	description = "XBan a player",
	params = "<player> <reason>",
	privs = { ban=true },
	func = function(name, params)
		local plname, reason = params:match("(%S+)%s+(.+)")
		if not (plname and reason) then
			return false, "Usage: /xban <player> <reason>"
		end
		local ok, e = xban.ban_player(plname, name, nil, reason)
		return ok, ok and ("Banned %s."):format(plname) or e
	end,
})

minetest.register_chatcommand("xtempban", {
	description = "XBan a player temporarily",
	params = "<player> <time> <reason>",
	privs = { ban=true },
	func = function(name, params)
		local plname, time, reason = params:match("(%S+)%s+(%S+)%s+(.+)")
		if not (plname and time and reason) then
			return false, "Usage: /xtempban <player> <time> <reason>"
		end
		time = parse_time(time)
		if time < 60 then
			return false, "You must ban for at least 60 seconds."
		end
		local expires = os.time() + time
		local ok, e = xban.ban_player(plname, name, expires, reason)
		return ok, (ok and ("Banned %s until %s."):format(
				plname, os.date("%c", expires)) or e)
	end,
})

minetest.register_chatcommand("xunban", {
	description = "XUnBan a player",
	params = "<player_or_ip>",
	privs = { ban=true },
	func = function(name, params)
		local plname = params:match("%S+")
		if not plname then
			minetest.chat_send_player(name,
			  "Usage: /xunban <player_or_ip>")
			return
		end
		local ok, e = xban.unban_player(plname, name)
		return ok, ok and ("Unbanned %s."):format(plname) or e
	end,
})

minetest.register_chatcommand("xmute", {
	description = "XMute a player",
	params = "<player> <reason>",
	privs = { pmute=true },
	func = function(name, params)
		local plname, reason = params:match("(%S+)%s+(.+)")
		if not (plname and reason) then
			return false, "Usage: /xmute <player> <reason>"
		end
		local ok, e = xban.mute_player(plname, name, nil, reason)
		return ok, ok and ("Muted %s."):format(plname) or e
	end,
})

minetest.register_chatcommand("xtempmute", {
	description = "XMute a player temporarily",
	params = "<player> <time> <reason>",
	privs = { pmute=true },
	func = function(name, params)
		local plname, time, reason = params:match("(%S+)%s+(%S+)%s+(.+)")
		if not (plname and time and reason) then
			return false, "Usage: /xtempmute <player> <time> <reason>"
		end
		time = parse_time(time)
		if time < 60 then
			return false, "You must mute for at least 60 seconds."
		end
		local expires = os.time() + time
		local ok, e = xban.mute_player(plname, name, expires, reason)
		return ok, (ok and ("Muted %s until %s."):format(
				plname, os.date("%c", expires)) or e)
	end,
})

minetest.register_chatcommand("xunmute", {
	description = "XUnMute a player",
	params = "<player_or_ip>",
	privs = { pmute=true },
	func = function(name, params)
		local plname = params:match("%S+")
		if not plname then
			minetest.chat_send_player(name,
			  "Usage: /xunmute <player_or_ip>")
			return
		end
		local ok, e = xban.unmute_player(plname, name)
		return ok, ok and ("Unmuted %s."):format(plname) or e
	end,
})

minetest.register_chatcommand("xban_record", {
	description = "Show the ban records of a player",
	params = "<player_or_ip>",
	privs = { ban=true },
	func = function(name, params)
		local plname = params:match("%S+")
		if not plname then
			return false, "Usage: /xban_record <player_or_ip>"
		end
		local record, last_pos = xban.get_record(plname)
		if not record then
			local err = last_pos
			minetest.chat_send_player(name, "[xban] "..err)
			return
		end
		for _, e in ipairs(record) do
			minetest.chat_send_player(name, "[xban] "..e)
		end
		if last_pos then
			minetest.chat_send_player(name, "[xban] "..last_pos)
		end
		return true, "Record listed."
	end,
})

minetest.register_chatcommand("xban_wl", {
	description = "Manages the whitelist",
	params = "(add|del|get) <name_or_ip>",
	privs = { ban=true },
	func = function(name, params)
		local cmd, plname = params:match("%s*(%S+)%s*(%S+)")
		if cmd == "add" then
			xban.add_whitelist(plname, name)
			ACTION("%s adds %s to whitelist", name, plname)
			return true, "Added to whitelist: "..plname
		elseif cmd == "del" then
			xban.remove_whitelist(plname)
			ACTION("%s removes %s to whitelist", name, plname)
			return true, "Removed from whitelist: "..plname
		elseif cmd == "get" then
			local e = xban.get_whitelist(plname)
			if e then
				return true, "Source: "..(e.source or "Unknown")
			else
				return true, "No whitelist for: "..plname
			end
		end
	end,
})

minetest.register_chatcommand("mutereason", {
	description = "Check the reason why moderator muted you",
	func = function(name, params)
		local entry = xban.find_entry(name)
		if not entry or not entry.muted then
			return false, "You are not muted"
		end
		return true, "Reason: "..entry.mute_reason
	end,
})

local function unban_report(t, time, time_exp, is_mute)
	if not is_discordmt_enabled then
		return
	end

	local count = 0
	local names = {}
	for key, _ in pairs(t) do
		if key:match("(%d+%.%d+%.%d+%.%d+)") then
			count = count + 1
		else
			table.insert(names, key)
		end
	end
	local str = table.concat(names, ", ")
	local time_left = time_exp - time
	if not is_mute then
		xban.report_to_discord("AUTO unban: tempban expired\nList: [`%s`] and **%s IPs**\nBan time : %ss", str, count, time_left)
	else
		xban.report_to_discord("AUTO unmute: tempmute expired\nList: [`%s`] and **%s IPs**\nMute time : %ss", str, count, time_left)
	end
end

local function check_temp_bans()
	minetest.after(60, check_temp_bans)
	local to_rm = { }
	local now = os.time()
	for i, e in ipairs(tempbans) do
		if e.expires and (e.expires <= now) then
			table.insert(to_rm, i)
			unban_report(e.names, e.time, e.expires)
			e.banned = false
			e.expires = nil
			e.reason = nil
			e.time = nil
		end
	end
	for _, i in ipairs(to_rm) do
		table.remove(tempbans, i)
	end
end

local function check_temp_mutes()
	minetest.after(60, check_temp_mutes)
	local to_rm = { }
	local now = os.time()
	for i, e in ipairs(tempmutes) do
		if e.mute_expires and (e.mute_expires <= now) then
			table.insert(to_rm, i)
			if not filter or not filter.phrase or filter.phrase ~= string.sub(e.mute_reason, 1, #filter.phrase) then
				unban_report(e.names, e.mute_time, e.mute_expires, true)
			end
			e.muted = false
			e.mute_expires = nil
			e.mute_reason = nil
			e.mute_time = nil
			for name in pairs(e.names) do
				if minetest.get_player_by_name(name) then
					minetest.chat_send_player(name, "Your mute has expired. You can talk now. Do not abuse the chat again!")
				end
			end
		end
	end
	for _, i in ipairs(to_rm) do
		table.remove(tempmutes, i)
	end
end

local function save_db()
	minetest.after(SAVE_INTERVAL, save_db)
	local f, e = io.open(DB_FILENAME, "wt")
	db.timestamp = os.time()
	if f then
		local ok, err = f:write(xban.serialize(db))
		if not ok then
			WARNING("Unable to save database: %s", err)
		end
	else
		WARNING("Unable to save database: %s", e)
	end
	if f then f:close() end
	return
end

local function load_db()
	local f, e = io.open(DB_FILENAME, "rt")
	if not f then
		WARNING("Unable to load database: %s", e)
		return
	end
	local cont = f:read("*a")
	if not cont then
		WARNING("Unable to load database: %s", "Read failed")
		return
	end
	local t, e2 = minetest.deserialize(cont)
	if not t then
		WARNING("Unable to load database: %s",
		  "Deserialization failed: "..(e2 or "unknown error"))
		return
	end
	db = t
	tempbans = { }
	tempmutes = { }
	for _, entry in ipairs(db) do
		if entry.banned and entry.expires then
			table.insert(tempbans, entry)
		end
		if entry.muted and entry.mute_expires then
			table.insert(tempmutes, entry)
		end
	end
end

minetest.register_chatcommand("xban_cleanup", {
	description = "Removes all non-banned entries from the xban db",
	privs = { server=true },
	func = function(name, params)
		local old_count = #db

		local i = 1
		while i <= #db do
			if not db[i].banned and not db[i].muted then
				-- not banned, remove from db
				table.remove(db, i)
			else
				-- banned, hold entry back
				i = i + 1
			end
		end

		-- save immediately
		save_db()

		return true, "Removed " .. (old_count - #db) .. " entries, new db entry-count: " .. #db
	end,
})

minetest.register_on_shutdown(save_db)
minetest.after(SAVE_INTERVAL, save_db)
load_db()
xban.db = db

minetest.after(1, check_temp_bans)
minetest.after(1, check_temp_mutes)

dofile(xban.MP.."/dbimport.lua")
dofile(xban.MP.."/gui.lua")
dofile(xban.MP.."/overrides.lua")

-- Override 'msg' command

xban.cmd_list = {
	["msg"] = true,
	["bmsg"] = true,
	["me"] = true,
	["pm"] = true,
	["mail"] = true,
	["t"] = true,
}

local function report_mutetime(name, entry)
	if entry.mute_expires then
		local time = os.time()
		if time >= entry.mute_expires then
			minetest.chat_send_player(name, "You will be AUTO unmuted in less than a minute. Please be patient.")
		else
			minetest.chat_send_player(name, "You will be muted for "..tostring(entry.mute_expires-time).." more seconds.")
		end
	end
end

local function make_checker(old_func)
	return function(name, param)
		local entry = xban.find_entry(name)
		if entry and entry.muted then
			local a = ""
			if not entry.mute_expires then
				a = "perm"
			end
			minetest.chat_send_player(name, "You're "..a.."muted, you can't use this command. Check /mutereason for details.")
			report_mutetime(name, entry)
			return true
		end

		return old_func(name, param)
	end
end

minetest.after(0, function()
	for name, def in pairs(minetest.registered_chatcommands) do
		if (def.privs and def.privs.shout) or xban.cmd_list[name] then
			def.func = make_checker(def.func)
		end
	end

	local old_register_chatcommand = minetest.register_chatcommand
	function minetest.register_chatcommand(name, def)
		if (def.privs and def.privs.shout) or xban.cmd_list[name] then
			def.func = make_checker(def.func)
		end
		return old_register_chatcommand(name, def)
	end

	local old_override_chatcommand = minetest.override_chatcommand
	function minetest.override_chatcommand(name, def)
		if (def.privs and def.privs.shout) or xban.cmd_list[name] then
			def.func = make_checker(def.func)
		end
		return old_override_chatcommand(name, def)
	end
end)

local moderators = {
	"Loki", "novaosoba", "DeadXWolf", "ScaleRaker", "Ottobunny", "PadrePio"
}

table.insert(minetest.registered_on_chat_messages, 1, function(name, message)
	if message:sub(1, 1) == "/" then
		return
	end
	local entry = xban.find_entry(name)
	if entry and entry.muted then
		local a = ""
		if not entry.mute_expires then
			a = "perm"
		end
		minetest.chat_send_player(name, "You're "..a.."muted, only moderators can see your message. Check /mutereason for details.")
		report_mutetime(name, entry)
		local changed_message = nil
		for _, mname in ipairs(moderators) do
			if minetest.get_player_by_name(mname) then
				if not changed_message then
					changed_message = minetest.format_chat_message(name, message)
				end
				minetest.chat_send_player(mname, minetest.colorize("red", "[MUTED] ")..changed_message)
			end
		end
		if filter_caps then
			message = filter_caps.parse(name, message)
		end
		changed_message = string.format("**%s**: %s", name, message)

		local rank = ranks.get_player_prefix(name)
		if rank then
			msg = string.format("%s %s", rank.prefix, changed_message)
		end
		xban.log_message_to_discord("%s", changed_message)

		return true
	end
end)



-- Privileges
minetest.register_privilege("pmute", "Players with this privilege can mute players")
