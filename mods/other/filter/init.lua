
--[[

	Copyright 2017-8 Auke Kok <sofar@foo-projects.org>
	Copyright 2018 rubenwardy <rw@rubenwardy.com>

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject
	to the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]--

local discordCooldown = 10
filter = { registered_on_violations = {}, phrase = "Filter mod has detected the player using bad word: " }
local violations = {}
local storage = minetest.get_mod_storage()
local last_bad_word = ""
local last_matched = ""
local words = minetest.deserialize(storage:get_string("words")) or {}
local whitelist = minetest.deserialize(storage:get_string("whitelist")) or {}
local mode = storage:get_int("mode") or 1		-- 1 - Enforcing
local agg_num = storage:get_int("agg_num") or 0		-- 0 - No aggregation of words
local LCSthreshold = storage:get_int("LCSthreshold") or 4
local maxLen = storage:get_int("maxLen") or 20
local last_kicked_time = os.time()
local last_lcs_used = false
local discord_channel = "1092069636792659989"

if maxLen == 0 then
	maxLen = 20
end

function filter.init()
	if #words == 0 then
		words = filter.import_file(minetest.get_modpath("filter") .. "/words")
		storage:set_string("words", minetest.serialize(words))
	end
	if #whitelist == 0 then
		whitelist = filter.import_file(minetest.get_modpath("filter") .. "/whitelist")
		storage:set_string("whitelist", minetest.serialize(whitelist))
	end
end

function filter.import_file(filepath)
	local file = io.open(filepath, "r")
	local imported_words = {}
	if file then
		for line in file:lines() do
			line = line:trim()
			if line ~= "" then
				table.insert(imported_words, line)
			end
		end
	end
	return imported_words
end

function filter.register_on_violation(func)
	table.insert(filter.registered_on_violations, func)
end

function filter.is_whitelisted(word_msg)
	for _, word in ipairs(whitelist) do
		word = word:lower()
		if utf8_simple.len(word) > LCSthreshold and word == algorithms.lcs(word, word_msg) then
			return true
		end
		if word_msg:find(word) ~= nil then
			return true
		end
	end
	return false
end

local function aggregate_words(word_list)
	local new_word_list = {}
	local agg_word = ""
	local prev_word = ""
	for _, word in ipairs(word_list) do
		local word_len = utf8_simple.len(word)
		if word_len <= agg_num and agg_word == "" then
			agg_word = prev_word
		end
		agg_word = agg_word..word
		if word_len > agg_num then
			table.insert(new_word_list, agg_word)
			prev_word = agg_word
			agg_word = ""
		end
	end
	if agg_word ~= "" then
		table.insert(new_word_list, agg_word)
	end
	return new_word_list
end

function filter.check_message(message)
	if type(message) ~= "string" then
		return false
	end
	message = message:lower()
	local word_list = {}
	for word_msg in message:gmatch("[^%s-_]+") do
		table.insert(word_list, word_msg)
	end
	word_list = aggregate_words(word_list)

	for _, word_msg in ipairs(word_list) do
		local word_msg_len = utf8_simple.len(word_msg)
		if word_msg_len > maxLen then
			last_bad_word = word_msg
			last_matched = "spam"
			return false
		end
		local hitOnce = false
		local inWhitelist = filter.is_whitelisted(word_msg)

		for _, word in ipairs(words) do
			local word_len = utf8_simple.len(word)
			if word_msg_len < word_len then
				goto continue
			end
			word = word:lower()
			if word_len > LCSthreshold and word ~= algorithms.lcs(word, word_msg) then
				goto continue
			end
			if word_len <= LCSthreshold and word_msg:find(word) == nil then
				goto continue
			end

			if hitOnce or not inWhitelist then
				last_bad_word = word_msg
				last_matched = word
				last_lcs_used = (word_len > LCSthreshold)
				return false
			end
			hitOnce = true
			::continue::
		end
	end
	return true
end

function filter.mute(name, duration)
	
	minetest.chat_send_all(name .. " has been temporarily muted for using offensive language.")
	minetest.chat_send_player(name, "Watch your language!")

	xban.mute_player(name, "filter", os.time() + (duration*60), filter.phrase .. last_bad_word)
end

function filter.show_warning_formspec(name)
	local formspec = "size[7,3]bgcolor[#080808BB;true]" .. default.gui_bg .. default.gui_bg_img .. [[
		image[0,0;2,2;filter_warning.png]
		label[2.3,0.5;Please watch your language!]
	]]

	if minetest.global_exists("rules") and rules.show then
		formspec = formspec .. [[
				button[0.5,2.1;3,1;rules;Show Rules]
				button_exit[3.5,2.1;3,1;close;Okay]
			]]
	else
		formspec = formspec .. [[
				button_exit[2,2.1;3,1;close;Okay]
			]]
	end
	minetest.show_formspec(name, "filter:warning", formspec)
end

function filter.on_violation(name, message)
	violations[name] = (violations[name] or 0) + 1

	local resolution
	if mode == 0 then
		resolution = "permissive"
	end

	for _, cb in pairs(filter.registered_on_violations) do
		if cb(name, message, violations) then
			resolution = "custom"
		end
	end

	if not resolution then
		if violations[name] == 1 and minetest.get_player_by_name(name) then
			resolution = "warned"
			filter.show_warning_formspec(name)
		elseif violations[name] <= 3 then
			resolution = "muted"
			filter.mute(name, 1)
		else
			resolution = "kicked"
			minetest.kick_player(name, "Please mind your language!")
			if discord and discord.enabled and (os.time() - last_kicked_time) > discordCooldown then
				discord.send("***filter***: Kicked "..name.." for saying the bad word "..last_bad_word, discord_channel)
				last_kicked_time = os.time()
			end
		end
	end

	local logmsg = "VIOLATION (" .. resolution .. "): <" .. name .. "> "..  message
	if last_lcs_used then
		logmsg = "[filter] [LCS] "..logmsg
	else
		logmsg = "[filter] "..logmsg
	end
	minetest.log("action", logmsg)

	local email_to = minetest.settings:get("filter.email_to")
	if email_to and minetest.global_exists("email") then
		email.send_mail(name, email_to, logmsg)
	end
end

-- Insert this check after xban checks whether the player is muted
table.insert(minetest.registered_on_chat_messages, 2, function(name, message)
	if message:sub(1, 1) == "/" then
		return
	end

	if not filter.check_message(message) then
		filter.on_violation(name, message)
		if mode == 1 then
			return true
		end
	end
end)


local function make_checker(old_func)
	return function(name, param)
		if not filter.check_message(param) then
			filter.on_violation(name, param)
			if mode == 1 then
				return true
			end
		end

		return old_func(name, param)
	end
end

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

local function step()
	for name, v in pairs(violations) do
		violations[name] = math.floor(v * 0.5)
		if violations[name] < 1 then
			violations[name] = nil
		end
	end
	minetest.after(10*60, step)
end
minetest.after(10*60, step)

if minetest.global_exists("rules") and rules.show then
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname == "filter:warning" and fields.rules then
			rules.show(player)
		end
	end)
end

filter.init()

local function findElement(table, elem)
	for index, element in ipairs(table) do
		if elem == element then
			return index
		end
	end
	return nil
end

minetest.register_chatcommand("filter_mode", {
	description = "Set the chat filter status of operation",
	params = "<permissive/enforcing>",
	privs = { dev=true },
	func = function(name, param)
		if param == "permissive" then
			if mode == 0 then
				return false, "Mode is already permissive"
			end
			mode = 0
			storage:set_int("mode", 0)
			return true, "Chat filter mode set to permissive"
		end
		if param == "enforcing" then
			if mode == 1 then
				return false, "Mode is already enforcing"
			end
			mode = 1
			storage:set_int("mode", 1)
			return true, "Chat filter mode set to enforcing"
		end
		return false, "Error: Your parameter doesn't match any operation.\nParameters: <permissive/enforcing>"
	end
})

minetest.register_chatcommand("filter_add", {
	description = "Add a new word to the filter bad word list",
	privs = { dev=true },
	func = function(_, param)
		if findElement(words, param) then
			return false, "Word "..param.." is already on the blacklist"
		end
		table.insert(words, param)
		storage:set_string("words", minetest.serialize(words))
		return true, "Word "..param.." blacklisted"
	end,
})

minetest.register_chatcommand("filter_rm", {
	description = "Remove word from the filter bad word list",
	privs = { dev=true },
	func = function(_, param)
		local index = findElement(words, param)
		if not index then
			return false, "Word "..param.." isn't blacklisted"
		end
		table.remove(words, index)
		storage:set_string("words", minetest.serialize(words))
		return true, "Word "..param.." removed from the blacklist"
	end,
})

minetest.register_chatcommand("filter_wl", {
	description = "Add a new word to the filter word whitelist",
	privs = { dev=true },
	func = function(_, param)
		if findElement(whitelist, param) then
			return false, "Word "..param.." is already on the whitelist"
		end
		table.insert(whitelist, param)
		storage:set_string("whitelist", minetest.serialize(whitelist))
		return true, "Word "..param.." whitelisted"
	end,
})

minetest.register_chatcommand("filter_wlrm", {
	description = "Remove word from the filter whitelist",
	privs = { dev=true },
	func = function(_, param)
		local index = findElement(whitelist, param)
		if not index then
			return false, "Word "..param.." isn't whitelisted"
		end
		table.remove(whitelist, index)
		storage:set_string("whitelist", minetest.serialize(whitelist))
		return true, "Word "..param.." removed from the whitelist"
	end,
})

minetest.register_chatcommand("filter_dump", {
	description = "Dump the filter blacklist table",
	privs = { dev=true },
	func = function(name, param)
		minetest.chat_send_player(name, dump(words))
	end,
})

minetest.register_chatcommand("filter_dumpwl", {
	description = "Dump the filter whitelist table",
	privs = { dev=true },
	func = function(name, param)
		minetest.chat_send_player(name, dump(whitelist))
	end,
})

minetest.register_chatcommand("filter_reload", {
	description = "Replace the blacklist table with the content from the file",
	privs = { dev=true },
	func = function(name, param)
		words = filter.import_file(minetest.get_modpath("filter") .. "/words")
		storage:set_string("words", minetest.serialize(words))
		return true, "Blacklist reloaded"
	end,
})

minetest.register_chatcommand("filter_reloadwl", {
	description = "Replace the whitelist table with the content from the file",
	privs = { dev=true },
	func = function(name, param)
		whitelist = filter.import_file(minetest.get_modpath("filter") .. "/whitelist")
		storage:set_string("whitelist", minetest.serialize(whitelist))
		return true, "Whitelist reloaded"
	end,
})

minetest.register_chatcommand("filter_last", {
	description = "Get the word from the blacklist that was last matched",
	privs = { dev=true },
	func = function(name, param)
		minetest.chat_send_player(name, last_matched)
	end,
})

minetest.register_chatcommand("filter_lcs", {
	description = "Set minimal pattern length for LCS to be employed",
	params = "<pattern length>",
	privs = { dev=true },
	func = function(name, param)
		local number = tonumber(param) or 4
		number = math.floor(number)
		if number < 0 then
			return false, "You have to enter a valid non-negative integer"
		end
		LCSthreshold = number
		storage:set_int("LCSthreshold", number)
		return true, "Filter LCSthreshold set to "..tostring(number)
	end,
})

minetest.register_chatcommand("filter_agg", {
	description = "Set maximum word length for it to be considered for aggregation with surrounding words",
	params = "<word length>",
	privs = { dev=true },
	func = function(name, param)
		local number = tonumber(param) or 1
		number = math.floor(number)
		if number < 0 then
			return false, "You have to enter a valid non-negative integer"
		end
		agg_num = number
		storage:set_int("agg_num", number)
		return true, "Word aggregation number set to "..tostring(number)
	end,
})

minetest.register_chatcommand("filter_maxLen", {
	description = "Set maximum word length that's not spam",
	params = "<word length>",
	privs = { dev=true },
	func = function(name, param)
		local number = tonumber(param) or 20
		number = math.floor(number)
		if number < 1 then
			return false, "You have to enter a valid integer larger than 0"
		end
		maxLen = number
		storage:set_int("maxLen", number)
		return true, "Maximum word length set to "..tostring(number)
	end,
})
