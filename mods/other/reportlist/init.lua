--[[This is a mod that contains a player register with the count of the reports.
          Mod created by Lejo!]]
local settings = {
	time_played_to_report = 3600, --  in seconds  Only needed when using playtime
	time_of_tempban = minetest.settings:get("report_tempbantime") or 259200, --  bantime inseconds
}

local min_message_length = 8
reportlist = {}
local s = minetest.get_mod_storage()
local new_table = {r = {}}
local private_messages = {}
--[[
Player table schem:
reporter = {["name"] = {reason = "..", time=os.time()}}
{r = {["name"] = {r = "Reason", t = os.time()}},
}
]]
minetest.register_privilege("moderator", {
	description = "Moderators",
	give_to_admin = true,
	give_to_singleplayer = false,
})


function reportlist.get_data(name)
	local data = s:get_string(name)
	if data ~= "" then
		return minetest.deserialize(data)
	else s:set_string(name, new_table)
		return new_table
	end
end

function reportlist.get_all_data()
	local out = {}
	for name, data in pairs(s:to_table().fields) do
		out[name] = minetest.deserialize(data)
	end
	return out
end

function reportlist.set_data(name, data)
	s:set_string(name, minetest.serialize(data))
end

function reportlist.remove_data(name, param)
	s:set_string(name, "")
	s:set_string(param, "")
end

function reportlist.exist(name)
	if s:get_string(name) ~= "" then
		return true
	else return false
	end
end

function reportlist.is_reporter(name, reportername)
	local data = reportlist.get_data(name)
	if data.r[reportername] then
		return true
	end
end

function reportlist.add_reporter(name, reportername, reason)
	local data = reportlist.get_data(name)
	data.r[reportername] = {r = reason, t = os.time()}
	reportlist.set_data(name, data)
end

-- Imported from ctf_report
local function string_difference(str1, str2)
	local count = math.abs(str1:len() - str2:len())

	for i=1, math.min(str1:len(), str2:len()) do
		if str1[i] ~= str2[i] then
			count = count + 1
		end
	end

	return count
end

local timers   = {}
local cooldown = {}
-- End import from ctf_report

--  Add the report Command
minetest.register_chatcommand("report", {
	privs = {shout = true},
	params = "<name> <reason>",
	description = "Use it to report players, if they are hacking, cheating...",
	func = function(name, param)
		local reported, reason = param:match("(%S+)%s+(.+)")

		if type(reported) ~= "string" or type(reason) ~= "string" or (#reason < min_message_length and reason ~= "PM" and reason ~= "DM") then
			return false, "Please specific a playername and a reason (Report must have " .. min_message_length .. " charactes long, please describe problem!)"
		end
		if not minetest.player_exists(reported) then
			return false, "The Player doesn't exist."
		end
		if name == reported then
			return false, "You can't report yourself."
		end
		if not minetest.get_player_by_name(reported) then
			return false, "The Player "..reported.." is not online!"
		end
		if playtime and playtime.get_total_playtime(name) < settings.time_played_to_report then
			return false, "You have to play longer to report a player!"
		end

		if reason == "PM" or reason == "DM" then
			if not (private_messages[name] and private_messages[name][reported]) then
				return false, "There is no private message to report!"
			end
			reason = "PM report: " .. private_messages[name][reported]
			private_messages[name][reported] = nil
		end
		-- Imported from ctf_report
		if not cooldown[name] or string_difference(cooldown[name], param) >= 6 then
			cooldown[name] = param

			if timers[name] then
				timers[name]:cancel()
			end

			timers[name] = minetest.after(30, function()
				cooldown[name] = nil
				timers[name] = nil
			end)
		else
			return false, "You are sending reports too fast. You only need to report things once"
		end
		-- End import from ctf_report

		reportlist.add_reporter(reported, name, reason)
		minetest.log("action", "Player "..reported.." has been reported by "..name)
		return true, reported.." has been reported!"
	end,
})


function reportlist.show_form(name, fields)
	local reported = fields.name or ""
	local tabledata = ""
	local form = "size[30,9.5]" ..
	"label[3.5,0.1;Reportlist. Enter playername to do an action.]" ..
	"button[11.2,2.6;2.5,1;reset;reset]"

	if fields and fields.name and fields.name ~= "" then
		if reportlist.exist(fields.name) then
			local data = reportlist.get_data(fields.name)
			for playername, d in pairs(data.r) do
				local pdata = reportlist.get_data(playername)
				tabledata = tabledata..playername..","..os.date("%c", d.t)..","..minetest.formspec_escape(d.r)..","
    			end
		else
			tabledata = "Player hasn't been reported yet"
		end
		form = form .. "tablecolumns[text;text;text]"
	else
		for name, data in pairs(reportlist.get_all_data()) do
			local count = 0
			local pstuff = ""
			for name, d in pairs(data.r) do
				pstuff = pstuff.."1,"..name..","..os.date("%c", d.t)..","..minetest.formspec_escape(d.r)..","
				count = count + 1
			end
			tabledata = tabledata.."0,"..name..","..count..",,"..pstuff
		end
		form = form .. "tablecolumns[tree;text;text;text]"
	end

	form = form .. "table[0.2,0.6;28.8,7.6;reports;"..tabledata..";1]"
	minetest.show_formspec(name, "reportlist:reportlist", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "reportlist:reportlist" then
		local name = player:get_player_name()
		if minetest.get_player_privs(name).moderator then
			if fields.name and fields.name ~= "" then
				if fields.reset then
					reportlist.remove_data(fields.name)
					minetest.chat_send_player(name, "Reseted the reports of the player "..fields.name)
				elseif fields.tempban and fields.reason and fields.reason ~= "" then
					--  Support for sban mod or others using this command
					if minetest.registered_chatcommands["tempban"] then
						local success, msg = minetest.registered_chatcommands["tempban"].func(name, fields.name.." "..tostring(settings.time_of_tempban).." "..fields.reason)
						minetest.chat_send_player(name, msg)
						--  Xban support
					elseif xban and xban.ban_player then
						local success, err = xban.ban_player(fields.name, name, settings.time_of_tempban, fields.reason)
						if success then
							minetest.chat_send_player(name, "Banned "..fields.name)
						else
							minetest.chat_send_player(name, "Failed to ban "..fields.name.." Err:"..err)
						end
					else
						minetest.chat_send_player(name, "No compatible ban mod found, use sban or xban!")
					end
				end
			end
			if fields.reset or fields.tempban or fields.go or fields.key_enter then
				reportlist.show_form(name, fields)
			end
		else
			minetest.log("error", "Player "..name.." sent fields to reportlist:reportlist without the ban privi")
			minetest.kick_player(name)
		end
	end
end)

--  Add a chat command to get the report counter
minetest.register_chatcommand("reportlist", {
	privs = {moderator = true},
	params = "[<name>]",
	description = "Use it to open the reportlist form.",
	func = function(name, param)
  		reportlist.show_form(name, {name = param})
	end,
})

--  Add a chat command to set the report counter
minetest.register_chatcommand("report_reset", {
	privs = {moderator = true},
	params = "<name>",
	description = "Use it to reset the reports of a player.",
	func = function(name, param)
	  	if minetest.player_exists(param) then
	    		reportlist.remove_data(param, name)
	    		minetest.chat_send_player(name, "Reseted the reports of the player "..param)
	  	else
	  		minetest.chat_send_player(name, "The Player "..param.." doesn't exist.")
	  	end
	end,
})


local colors = {
	["0"] = "#ff0000", -- red
	["1"] = "#ff5500", -- orange
	["2"] = "#0000ff", -- blue
	["3"] = "#00ff00", -- green
	["4"] = "#ffff00", -- yellow
}
-- you can change the color in "minetest.chat_send_all" command

local function get_escape(color)
	return minetest.get_color_escape_sequence(colors[string.upper(color)] or "#FFFFFF")
end

local function colorize(text)
	return string.gsub(text,"#([01234])",get_escape)
end

-- end of color

--end of register privilege "servertext"


minetest.register_chatcommand("ssay", {
	params = "<message>",
	description = "Send text to chat",
	privs = {moderator = true},
	func = function( _ , message)
		minetest.chat_send_all(colorize("#4[Server] #4")..message)
	end,
})

minetest.register_chatcommand("warn",{
	description = "Warn someone",
	privs = {moderator=true},
	params = "<playername> <message>",
	func = function(name, param)
		local pname, msg = param:match("^(%S+) (.+)$")
		if not (pname and msg) then
			return false, "Invalid params"
		end
		local player = minetest.get_player_by_name(pname)
		if not player then
			return false, "Player "..pname.." is not online"
		end

		minetest.chat_send_all(minetest.colorize("red", "[Warn] ") .. pname .. " has been warned by " .. name .. ": " .. msg)
		return true, "Warned "..pname
	end
})

local cmd_list = {
	"msg",
	"bmsg",
}

local function components(mystring)
	local iter = mystring:gmatch("%S+")
	local first = iter()
	if not first then
		return nil
	end
	if not iter() then
		return first, nil
	end

	local second = mystring:gsub("^"..first.." ", "", 1)
	return first, second
end

minetest.register_on_chatcommand(function(name, command, params)
	for i = 1, #cmd_list do
		if command == cmd_list[i] then
			local receiver_name, message = components(params)
			if not receiver_name or not message then
				return false
			end

			private_messages[receiver_name] = private_messages[receiver_name] or {}
			private_messages[receiver_name][name] = message
		end
	end
	return false
end)
