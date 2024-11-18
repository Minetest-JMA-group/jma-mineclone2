afk_indicator = {}

local MP = minetest.get_modpath(minetest.get_current_modname())

local function require(name)
	return dofile(MP .. "/src/" .. name .. ".lua")
end

require("api")
require("updates")
require("commands")

